#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
extern const struct pmm_manager buddy_pmm_manager;

#define MAX_BUDDY_NUMBER 10 // The max number of buddy system is 10

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))















extern const struct pmm_manager slub_pmm_manager;

#endif /* ! __KERN_MM_BEST_FIT_PMM_H__ */