#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>
#define CACHE_NAMELEN 16

// 定义内存缓存结构
struct kmem_cache_t {
    list_entry_t slabs_full;        // 完全分配的内存块列表
    list_entry_t slabs_partial;     // 部分分配的内存块列表
    list_entry_t slabs_free;        // 空闲的内存块列表
    uint16_t objsize;               // 每个对象的大小
    uint16_t num;                   // 每个内存块可以容纳的对象数量
    void (*ctor)(void*, struct kmem_cache_t *, size_t); // 构造函数指针
    void (*dtor)(void*, struct kmem_cache_t *, size_t); // 析构函数指针
    char name[CACHE_NAMELEN];       // 缓存名称
    list_entry_t cache_link;        // 缓存链表节点
};

// 内存块结构
struct slab_t {
    int ref;                       // 引用计数
    struct kmem_cache_t *cachep;   // 所属缓存
    uint16_t inuse;                // 已使用对象数量
    uint16_t free;                 // 空闲对象数量
    list_entry_t slab_link;        // 内存块链表节点
};

#define SIZED_CACHE_NUM 8
#define SIZED_CACHE_MIN 16
#define SIZED_CACHE_MAX 2048

#define le2slab(le, link) ((struct slab_t*)le2page((struct Page*)le, link))
#define slab2kva(slab) (page2kva((struct Page*)slab))

static list_entry_t cache_chain;        // 缓存链表头
static struct kmem_cache_t cache_cache; // 用于管理缓存的缓存
static struct kmem_cache_t *sized_caches[SIZED_CACHE_NUM]; // 各个大小的内存缓存数组

// 内存缓存创建函数
struct kmem_cache_t *kmem_cache_create(const char *name, size_t size,
                                       void (*ctor)(void*, struct kmem_cache_t *, size_t),
                                       void (*dtor)(void*, struct kmem_cache_t *, size_t)) {
    assert(size <= (PGSIZE - 2)); // 确保对象大小不超过一页大小
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache)); // 分配内存缓存结构
    if (cachep != NULL) {
        cachep->objsize = size; // 设置对象大小
        cachep->num = PGSIZE / (sizeof(int16_t) + size); // 计算每个内存块可以容纳的对象数量
        cachep->ctor = ctor; // 设置构造函数指针
        cachep->dtor = dtor; // 设置析构函数指针
        memcpy(cachep->name, name, CACHE_NAMELEN); // 复制缓存名称
        list_init(&(cachep->slabs_full)); // 初始化完全分配的内存块列表
        list_init(&(cachep->slabs_partial)); // 初始化部分分配的内存块列表
        list_init(&(cachep->slabs_free)); // 初始化空闲的内存块列表
        list_add(&(cache_chain), &(cachep->cache_link)); // 将缓存添加到缓存链表中
    }
    return cachep;
}

// 内存缓存销毁函数
void kmem_cache_destroy(struct kmem_cache_t *cachep) {
    list_entry_t *head, *le;

    // 销毁完全分配的内存块
    head = &(cachep->slabs_full);
    le = list_next(head);
    while (le != head) {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }

    // 销毁部分分配的内存块
    head = &(cachep->slabs_partial);
    le = list_next(head);
    while (le != head) {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }

    // 销毁空闲的内存块
    head = &(cachep->slabs_free);
    le = list_next(head);
    while (le != head) {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }

    // 释放内存缓存结构
    kmem_cache_free(&(cache_cache), cachep);
}

// 分配一个对象
void *kmem_cache_alloc(struct kmem_cache_t *cachep) {
    list_entry_t *le = NULL;

    // 在部分分配的内存块列表中查找可用内存块
    if (!list_empty(&(cachep->slabs_partial)))
        le = list_next(&(cachep->slabs_partial));
    // 如果部分分配的内存块列表为空，则尝试从空闲内存块列表中获取内存块，如果失败则尝试增长内存块
    else {
        if (list_empty(&(cachep->slabs_free)) && kmem_cache_grow(cachep) == NULL)
            return NULL;
        le = list_next(&(cachep->slabs_free));
    }

    list_del(le);
    struct slab_t *slab = le2slab(le, page_link);
    void *kva = slab2kva(slab);
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    void *objp = buf + slab->free * cachep->objsize;

    slab->inuse++;
    slab->free = bufctl[slab->free];
    if (slab->inuse == cachep->num)
        list_add(&(cachep->slabs_full), le);
    else
        list_add(&(cachep->slabs_partial), le);
    return objp;
}

// 分配一个对象并清零
void *kmem_cache_zalloc(struct kmem_cache_t *cachep) {
    void *objp = kmem_cache_alloc(cachep);
    memset(objp, 0, cachep->objsize);
    return objp;
}

// 释放一个对象
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp) {
    void *base = page2kva(pages);
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    int16_t *bufctl = kva;
    void *buf = bufctl + cachep->num;
    int offset = (objp - buf) / cachep->objsize;

    list_del(&(slab->slab_link));
    bufctl[offset] = slab->free;
    slab->inuse--;
    slab->free = offset;
    if (slab->inuse == 0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
    else
        list_add(&(cachep->slabs_partial), &(slab->slab_link));
}

// 获取内存对象的大小
size_t kmem_cache_size(struct kmem_cache_t *cachep) {
    return cachep->objsize;
}

// 获取内存缓存的名称
const char *kmem_cache_name(struct kmem_cache_t *cachep) {
    return cachep->name;
}

// 销毁空闲内存块列表中的所有内存块
int kmem_cache_shrink(struct kmem_cache_t *cachep) {
    int count = 0;
    list_entry_t *le = list_next(&(cachep->slabs_free));
    while (le != &(cachep->slabs_free)) {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
        count++;
    }
    return count;
}

// 销毁所有空闲内存块列表中的内存块
int kmem_cache_reap() {
    int count = 0;
    list_entry_t *le = &(cache_chain);
    while ((le = list_next(le)) != &(cache_chain))
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
    return count;
}

// 分配指定大小的内存
void *kmalloc(size_t size) {
    assert(size <= SIZED_CACHE_MAX);
    return kmem_cache_alloc(sized_caches[kmem_sized_index(size)]);
}

// 释放内存
void kfree(void *objp) {
    void *base = slab2kva(pages);
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE];
    kmem_cache_free(slab->cachep, objp);
}

void kmem_int() {
    cache_cache.objsize = sizeof(struct kmem_cache_t);
    cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(struct kmem_cache_t));
    cache_cache.ctor = NULL;
    cache_cache.dtor = NULL;
    memcpy(cache_cache.name, cache_cache_name, CACHE_NAMELEN);
    list_init(&(cache_cache.slabs_full));
    list_init(&(cache_cache.slabs_partial));
    list_init(&(cache_cache.slabs_free));
    list_init(&(cache_chain));
    list_add(&(cache_chain), &(cache_cache.cache_link));

    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2)
        sized_caches[i] = kmem_cache_create(sized_cache_name, size, NULL, NULL);
}
