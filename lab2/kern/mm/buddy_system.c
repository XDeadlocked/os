#include <pmm.h>
#include <buddy_system.h>

struct buddy {
    size_t size;
    uintptr_t *longest;
    size_t longest_num;
    size_t total_num;
    size_t curr_free;
    struct Page *begin_page;
};

struct buddy b[MAX_BUDDY_NUMBER];
int id_ = 0;

static size_t next_power_of_2(size_t size) {
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size + 1;
}

static void
buddy_init() {

}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    cprintf("n: %d\n", n);
    struct buddy *buddy = &b[id_++];

    size_t s = next_power_of_2(n);
    size_t extra = s - n;
    size_t e = next_power_of_2(extra);

    buddy->size = s;
    buddy->curr_free = s - e;
    buddy->longest = KADDR(page2pa(base));
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));
    buddy->longest_num = buddy->begin_page - base;
    buddy->total_num = n - buddy->longest_num;

    size_t sn = buddy->size * 2;

    for (int i = 0; i < 2 * buddy->size - 1; i++) {
        if (IS_POWER_OF_2(i + 1)) {
            sn /= 2;
        }
        buddy->longest[i] = sn;
    }

    int id = 0;
    while (1) {
        if (buddy->longest[id] == e) {
            buddy->longest[id] = 0;
            break;
        }
        id = RIGHT_LEAF(id);
    }

    while (id) {
        id = PARENT(id);
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
    }

    struct Page *p = buddy->begin_page;
    for (; p != base + buddy->curr_free; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
}

// 定义一个函数用于在 buddy system 中分配页面
static struct Page *buddy_alloc_pages(size_t n) {
    // 确保请求的页面数量大于 0
    assert(n > 0);

    // 如果 n 不是 2 的幂，将其调整为下一个最接近的 2 的幂
    if (!IS_POWER_OF_2(n))
        n = next_power_of_2(n);

    size_t id = 0;
    size_t sn;
    size_t offset = 0;

    struct buddy *buddy = NULL;

    // 遍历所有的 buddy，找到一个可以满足页面请求的 buddy
    for (int i = 0; i < id_; i++) {
        if (b[i].longest[id] >= n) {
            buddy = &b[i];
            break;
        }
    }

    // 如果没有找到合适的 buddy，则返回 NULL，表示分配失败
    if (!buddy) {
        return NULL;
    }

    // 在 buddy 的管理树中查找一个大小适中的块来分配
    for (sn = buddy->size; sn != n; sn /= 2) {
        // 检查左子节点是否满足大小需求
        if (buddy->longest[LEFT_LEAF(id)] >= n)
            id = LEFT_LEAF(id);
        // 否则检查右子节点
        else
            id = RIGHT_LEAF(id);
    }

    // 将找到的块标记为已用
    buddy->longest[id] = 0;

    // 计算该块在 buddy 的页面范围内的偏移量
    offset = (id + 1) * sn - buddy->size;

    // 向上更新树的状态，确保父节点表示它的两个子节点中较大的空闲块
    while (id) {
        id = PARENT(id);
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
    }

    // 减少 buddy 的当前空闲页面数
    buddy->curr_free -= n;

    // 返回分配的页面的起始地址
    return buddy->begin_page + offset;
}



static void
buddy_free_pages(struct Page *base, size_t n) {
    struct buddy *buddy = NULL;
    /*
    哪一个 buddy 区域包含了给定的 base 页面
    */
    for (int i = 0; i < id_; i++) {
        struct buddy *t = &b[i];
        if (base >= t->begin_page && base < t->begin_page + t->size) {
            buddy = t;
        }
    }
    //
    if (!buddy) return;

    unsigned sn, id = 0;
    unsigned left_longest, right_longest;
    unsigned offset = base - buddy->begin_page;

    //确定页面在 buddy 中的位置，并设置它为已经释放：
    assert(offset >= 0 && offset < buddy->size);

    sn = 1;
    id = offset + buddy->size - 1;

    for (; buddy->longest[id]; id = PARENT(id)) {
        sn *= 2;
        if (id == 0)
            return;
    }

    buddy->longest[id] = sn;
    buddy->curr_free += sn;

    /*
    sn 代表当前考虑的大小，而 id 代表当前考虑的节点在 buddy 管理数组中的索引。此循环查找第一个表示未被使用的节点。
    释放完成后，代码会尝试合并相邻的、大小相同的空闲块：
    */

    while (id) {
        id = PARENT(id);
        sn *= 2;

        left_longest = buddy->longest[LEFT_LEAF(id)];
        right_longest = buddy->longest[RIGHT_LEAF(id)];

        if (left_longest + right_longest == sn)
            buddy->longest[id] = sn;
        else
            buddy->longest[id] = MAX(left_longest, right_longest);
    }

}


static size_t
buddy_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int i = 0; i < id_; i++) {
        total_free_pages += b[i].curr_free;
    }
    return total_free_pages;
}


static void
buddy_check(void) {

    cprintf("New test case: testing memory block validation...\n");

    // 分配一页内存
    struct Page *p_ = buddy_alloc_pages(1);  // 假定1表示一页
    assert(p_ != NULL);

    // 获取页面的物理地址，并转换为可用的虚拟地址。这里需要根据你的实现来完成。
    // 注意：你可能需要使用其他函数来获取/转换地址，依据你的内核/平台实现。
    uintptr_t pa = page2pa(p_);
    uintptr_t *va = KADDR(pa);

    // 写入数据到分配的内存块
    int *data_ptr = (int *)va;
    *data_ptr = 0xdeadbeef;  // 写入一个魔数，稍后用于验证

    // 读取并验证数据
    assert(*data_ptr == 0xdeadbeef);

    // 释放内存块
    buddy_free_pages(p_, 1);

    // 验证是否可以正常释放，例如再次分配相同的内存块并检查地址是否相同
    struct Page *p_2 = buddy_alloc_pages(1);
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现

    // 清理
    buddy_free_pages(p_2, 1);

    cprintf("Memory block validation test passed!\n");
}



const struct pmm_manager buddy_pmm_manager = {
        .name = "buddy_pmm_manager",
        .init = buddy_init,
        .init_memmap = buddy_init_memmap,
        .alloc_pages = buddy_alloc_pages,
        .free_pages = buddy_free_pages,
        .nr_free_pages = buddy_nr_free_pages,
        .check = buddy_check,
};



























const struct pmm_manager slub_pmm_manager = {
        .name = "slub_pmm_manager",
        .init = buddy_init,
        .init_memmap = buddy_init_memmap,
        .alloc_pages = buddy_alloc_pages,
        .free_pages = buddy_free_pages,
        .nr_free_pages = buddy_nr_free_pages,
        .check = buddy_check,
};