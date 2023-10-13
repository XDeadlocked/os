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

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (!IS_POWER_OF_2(n))
        n = next_power_of_2(n);

    size_t id = 0;
    size_t sn;
    size_t offset = 0;

    struct buddy *buddy = NULL;
    for (int i = 0; i < id_; i++) {
        if (b[i].longest[id] >= n) {
            buddy = &b[i];
            break;
        }
    }

    if (!buddy) {
        return NULL;
    }

    for (sn = buddy->size; sn != n; sn /= 2) {
        if (buddy->longest[LEFT_LEAF(id)] >= n)
            id = LEFT_LEAF(id);
        else
            id = RIGHT_LEAF(id);
    }

    buddy->longest[id] = 0;
    offset = (id + 1) * sn - buddy->size;

    while (id) {
        id = PARENT(id);
        buddy->longest[id] = MAX(buddy->longest[LEFT_LEAF(id)], buddy->longest[RIGHT_LEAF(id)]);
    }

    buddy->curr_free -= n;

    return buddy->begin_page + offset;
}


static void
buddy_free_pages(struct Page *base, size_t n) {
    struct buddy *buddy = NULL;

    for (int i = 0; i < id_; i++) {
        struct buddy *t = &b[i];
        if (base >= t->begin_page && base < t->begin_page + t->size) {
            buddy = t;
        }
    }

    if (!buddy) return;

    unsigned sn, id = 0;
    unsigned left_longest, right_longest;
    unsigned offset = base - buddy->begin_page;

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