#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>

typedef struct slub_t {
	int ref;
	kmem_cache_t *p;
	uint16_t used;
	uint16_t freeoff;
	list_entry_t slub_linklist;
}slub_t;

#define SIZED_CACHE_NUM 8
#define SIZED_CACHE_MIN 16
#define SIZED_CACHE_MAX 2048

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

#define LE2SLUB(le,link) ((slub_t*)le2page((struct Page*)le,link))
#define SLUB2KVA(slub) (KADDR(page2pa((struct Page*)slub)))

static list_entry_t cache_chain;
static kmem_cache_t cache_cache;
static kmem_cache_t *cache_sized[SIZED_CACHE_NUM];
static char *cache_name = "cache";
static char *sized_name = "sized";

static void *kmem_cache_grow(kmem_cache_t *p){
	struct Page *page = alloc_page();
	void *kva = KADDR(page2pa(page));
	slub_t *slub = (slub_t *)page;
	slub->p = p;
	slub->used = slub->freeoff = 0;
	list_add(&(p->slubs_free), &(slub->slub_linklist));
	int16_t *bufctl = kva;
	for(int i = 1; i < p->num; i++)
	{
		bufctl[i-1] = i;
	}
	bufctl[p->num-1] = -1;
	void *buf = bufctl + p->num;
	if (p->ctor)
	{
		for(void *t = buf; t < buf + p->objsize * p->num; t += p->objsize)
		{
			p->ctor(t,p,p->objsize);
		}
	}
	return slub;
}

static void kmem_slub_destory(kmem_cache_t *p, slub_t *slub)
{
	struct Page *page = (struct Page *)slub;
	int16_t *bufctl = KADDR(page2pa(page));
	void *buf = bufctl + p->num;
	if(p->dtor)
	{
		for(void *t = buf; t < buf + p->objsize * p->num; t+= p->objsize)
		{
			p->dtor(t,p,p->objsize);
		}
	}
	page->property = page->flags = 0;
	list_del(&(page->page_link));
	free_page(page);
}

static int kmem_sized_index(size_t size)
{
	size_t s = ROUNDUP(size, 2);
	if(s < SIZED_CACHE_MIN){s = SIZED_CACHE_MIN;}
	int index = 0;
	for (int t = s/32; t!=0; t/=2)
	{
		index++;
	}
	return index;
}

kmem_cache_t *kmem_cache_create(const char *name, size_t size,
		void (*ctor)(void*, kmem_cache_t *, size_t),
		void (*dtor)(void*, kmem_cache_t *, size_t)){

	assert(size <= (PGSIZE -2));
	kmem_cache_t *p = kmem_cache_alloc(&(cache_cache));
	if(p != NULL)
	{
		p->objsize = size;
		p->num = PGSIZE / (sizeof(int16_t) + size);
		p->ctor = ctor;
		p->dtor = dtor;
		memcpy(p->name, name, CACHE_NAMELEN);
		list_init(&(p->slubs_full));
		list_init(&(p->slubs_part));
		list_init(&(p->slubs_free));
		list_add(&(cache_chain), &(p->cache_link));
	}
	return p;
}

// destory

void kmem_cache_destory(kmem_cache_t *p)
{
	list_entry_t *head,*le;
	
	head = &(p->slubs_full);
	le = list_next(head);
	while(le != head)
	{
		list_entry_t *temp = le;
		le = list_next(le);
		kmem_slub_destory(p,LE2SLUB(temp, page_link));
	}

	head = &(p->slubs_part);
        le = list_next(head);
        while(le != head)
        {
                list_entry_t *temp = le;
                le = list_next(le);
                kmem_slub_destory(p,LE2SLUB(temp, page_link));
        }

	head = &(p->slubs_free);
        le = list_next(head);
        while(le != head)
        {
                list_entry_t *temp = le;
                le = list_next(le);
                kmem_slub_destory(p,LE2SLUB(temp, page_link));
        }

	kmem_cache_free(&(cache_cache),p);
}

void *kmem_cache_alloc(kmem_cache_t *p)
{
	list_entry_t *le = NULL;

	if(!list_empty(&(p->slubs_part)))
	{
		le = list_next(&(p->slubs_part));
	}
	else
	{
		if(list_empty(&(p->slubs_free)) && kmem_cache_grow(p) == NULL)
		{
			return NULL;
		}
		le = list_next(&(p->slubs_free));
	}

	list_del(le);
	slub_t *slub = LE2SLUB(le, page_link);
	void *kva = SLUB2KVA(slub);
	int16_t *bufctl = kva;
	void *buf = bufctl + p->num;
	void *obj = buf + slub->freeoff * p->objsize;

	slub->used++;
	slub->freeoff = bufctl[slub->freeoff];

	if(slub->used == p->num)
	{
		list_add(&(p->slubs_full), le);
	}
	else
	{
		list_add(&(p->slubs_part), le);
	}

	return obj;
}

void *kmem_cache_zalloc(kmem_cache_t *p)
{
	void *obj = kmem_cache_alloc(p);
	memset(obj, 0, p->objsize);
	return obj;
}

void kmem_cache_free(kmem_cache_t *p, void *obj)
{
	void *base = KADDR(page2pa(pages));
	void *kva = ROUNDDOWN(obj, PGSIZE);
	slub_t *slub = (slub_t *) &pages[(kva-base)/PGSIZE];

	int16_t *bufctl = kva;
	void *buf = bufctl + p->num;
	int offset = (obj-buf) / p->objsize;

	list_del(&(slub->slub_linklist));
	bufctl[offset] = slub->freeoff;
	slub->used--;
	slub->freeoff = offset;
	if(slub->used == 0)
	{
		list_add(&(p->slubs_free), &(slub->slub_linklist));
	}
	else
	{
		list_add(&(p->slubs_part), &(slub->slub_linklist));
	}
}

size_t kmem_cache_size(kmem_cache_t *p)
{
	return p->objsize;
}

const char *kmem_cache_name(kmem_cache_t *p)
{
	return p->name;
}

int kmem_cache_shrink(kmem_cache_t *p)
{
	int count = 0;
	list_entry_t *le = list_next(&(p->slubs_free));
	while(le != &(p->slubs_free))
	{
		list_entry_t *temp = le;
		le = list_next(le);
		kmem_slub_destory(p,LE2SLUB(temp,page_link));
		count++;
	}
	return count;
}

int kmem_cache_reap()
{
	int count = 0;
	list_entry_t *le = &(cache_chain);
	while((le = list_next(le)) != &(cache_chain))
	{
		count += kmem_cache_shrink(to_struct(le, kmem_cache_t, cache_link));
	}
	return count;
}

void *kmalloc(size_t size)
{
	assert(size <= SIZED_CACHE_MAX);
	return kmem_cache_alloc(cache_sized[kmem_sized_index(size)]);
}

void kfree(void *obj)
{
	void *base = SLUB2KVA(pages);
	void *kva = ROUNDDOWN(obj,PGSIZE);
	slub_t *slub = (slub_t *)&pages[(kva-base)/PGSIZE];
        kmem_cache_free(slub->p, obj);	
}


void slub_init()
{
	list_init(&free_list);
    nr_free = 0;

    // Initialize the cache_chain
    list_init(&cache_chain);
    
    // Create a cache for caches
    kmem_cache_t *result = kmem_cache_create(cache_name, sizeof(kmem_cache_t), NULL, NULL);
    assert(result == &cache_cache);

    // Create caches for commonly sized objects
    for (int i = 0; i < SIZED_CACHE_NUM; i++) {
        char name[16];
        cache_sized[i] = kmem_cache_create(name, (SIZED_CACHE_MIN << i), NULL, NULL);
    }
}
static void slub_init_memmap(struct Page *base, size_t size) {
	for (size_t i = 0; i < size; i++) {
        struct Page *page = base + i;
        assert(PageReserved(page));
        ClearPageReserved(page);
        page->property = 1;
        SetPageProperty(page);
        nr_free++;
        list_add_before(&free_list, &(page->page_link));
    }
}

static size_t
slub_nr_free_pages(void) {
	return nr_free;
}

static void
slub_check(void) {
	list_entry_t *le = &free_list;
    size_t count = 0;
    while ((le = list_next(le)) != &free_list) {
        count++;
    }
    assert(count == nr_free);

	cprintf("Memory block validation test passed!\n");
}

static void
slub_free_pages(struct Page *base, size_t n){
	 for (size_t i = 0; i < n; i++) {
        struct Page *page = base + i;
        assert(!PageReserved(page));
        list_add_before(&free_list, &(page->page_link));
        page->property += 1;
        nr_free++;
    }
}

static struct Page *
slub_alloc_pages(size_t n) {
	return NULL;
}

const struct pmm_manager s_pmm_manager = {
    .name = "s_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check =  slub_check,
};

