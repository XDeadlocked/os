#include <stdio.h>
#include <monitor.h>
#include <kmalloc.h>
#include <assert.h>


// Initialize monitor.
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
    int i;
    assert(num_cv>0);
    mtp->next_count = 0;
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
    assert(mtp->cv!=NULL);
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
        sem_init(&(mtp->cv[i].sem),0);
        mtp->cv[i].owner=mtp;
    }
}

// Free monitor.
void
monitor_free (monitor_t * mtp, size_t num_cv) {
    kfree(mtp->cv);
}

// Unlock one of threads waiting on the condition variable. 
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE: YOUR CODE
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
  /*
   *      cond_signal(cv) {
   *          if(cv.count>0) {
   *             mt.next_count ++;
   *             signal(cv.sem);
   *             wait(mt.next);
   *             mt.next_count--;
   *          }
   *       }
   */
    //如果不存在线程正在等待带释放的条件变量，则不执行任何操作，否则，对传入条件变量内置的信号执行操作。
    if(cvp->count>0) {
            cvp->owner->next_count ++;//增加next_count
            up(&(cvp->sem));//增加信号量
            down(&(cvp->owner->next));//减少next信号量
            cvp->owner->next_count --;//减少next_count
    }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}

/*
当某个线程准备离开临界区、准备释放对应的条件变量时，线程会执行函数cond_signal。

函数内部接下来会执行down(&(cvp->owner->next))操作。

由于monitor->next在初始化时就设置为0，所以当执行到该条代码时

无论如何，当前正在执行cond_signal函数的线程一定会被挂起。这也正是管程中next信号量的用途。

为什么要做这一步呢？原因是保证管程代码的互斥访问。

一个简单的例子：线程1因等待条件变量a而挂起，过了一段时间，线程2释放条件变量a，此时线程1被唤醒，并等待调度。
注意！此时在管程代码中，存在两个活跃线程（这里的活跃指的是正在运行/就绪线程），而这违背了管程的互斥性。
因此，线程2在释放条件变量a后应当立即挂起以保证管程代码互斥。而next信号量便是帮助线程2立即挂起的一个信号。
*/

// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
   /*
    *         cv.count ++;
    *         if(mt.next_count>0)
    *            signal(mt.next)
    *         else
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
    //当某个线程因为等待条件变量而准备将自身挂起前，此时条件变量中的count变量应自增1。
    cvp->count++;
    if(cvp->owner->next_count > 0)
        up(&(cvp->owner->next));
    else
        up(&(cvp->owner->mutex));
    //之后当前进程应该释放所等待的条件变量所属的管程互斥锁，以便于让其他线程执行管程代码。但如果存在一个已经在管程中、但因为执行cond_signal而挂起的线程，则优先继续执行该线程。
    down(&(cvp->sem));
    cvp->count--;
    //释放管程后，尝试获取该条件变量。如果获取失败，则当前线程将在down函数的内部被挂起，然后将等待条件变量的线程数量-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
