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
    size_t total = buddy_nr_free_pages();
    cprintf("total: %d\n", total);

    struct Page *p0 = alloc_page();
    assert(p0 != NULL);
    assert(buddy_nr_free_pages() == total - 1);
    assert(p0 == b[0].begin_page);

    struct Page *p1 = alloc_page();
    assert(p1 != NULL);
    assert(buddy_nr_free_pages() == total - 2);
    assert(p1 == b[0].begin_page + 1);

    assert(p1 == p0 + 1);

    buddy_free_pages(p0, 1);
    buddy_free_pages(p1, 1);
    assert(buddy_nr_free_pages() == total);

    p0 = buddy_alloc_pages(11);
    assert(buddy_nr_free_pages() == total - 16);

    p1 = buddy_alloc_pages(100);
    assert(buddy_nr_free_pages() == total - 144);

    buddy_free_pages(p0, -1);
    buddy_free_pages(p1, -1);
    assert(buddy_nr_free_pages() == total);

    p0 = buddy_alloc_pages(total);
    assert(p0 == NULL);

    p0 = buddy_alloc_pages(512);
    assert(buddy_nr_free_pages() == total - 512);

    p1 = buddy_alloc_pages(1024);
    assert(buddy_nr_free_pages() == total - 512 - 1024);

    struct Page *p2 = buddy_alloc_pages(2048);
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048);

    struct Page *p3 = buddy_alloc_pages(4096);
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096);

    struct Page *p4 = buddy_alloc_pages(8192);
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192);

    struct Page *p5 = buddy_alloc_pages(8192);
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192 - 8192);

    buddy_free_pages(p0, -1);
    buddy_free_pages(p1, -1);
    buddy_free_pages(p2, -1);
    buddy_free_pages(p3, -1);
    buddy_free_pages(p4, -1);
    buddy_free_pages(p5, -1);

    assert(buddy_nr_free_pages() == total);

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