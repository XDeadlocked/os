# uCore实验 - Lab5
<!-- TOC -->

- [uCore实验 - Lab5](#ucore实验---lab5)
  - [简介](#简介)
  - [练习解答](#练习解答)
    - [0) 练习0](#0-练习0)
    - [1) 练习1](#1-练习1)
    - [2) 练习2](#2-练习2)
    - [3) 练习3](#3-练习3)
      - [1. do_fork](#1-do_fork)
      - [2. do_execve](#2-do_execve)
      - [3. do_wait](#3-do_wait)
      - [4. do_exit](#4-do_exit)
      - [5. syscall系统调用](#5-syscall系统调用)
      - [*. Questions](#-questions)
<!-- /TOC -->
## 简介

- 这里是笔者在完成`uCore` Lab 5时写下的一些笔记
- 内容涉及`fork/exec/wait/exit`机制的具体实现。

## 练习解答

### 0) 练习0

除了将lab 1/2/3/4的代码填写至lab5以外，其他地方还有部分代码需要完善一下：

- 在`alloc_proc`函数中，添加对`proc_struct::wait_state`以及`proc_struct::cptr/optr/yptr`成员的初始化。

  ```cpp
  static struct proc_struct *
  alloc_proc(void) {
      struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
      if (proc != NULL) {
          // .....
          // Lab5 code
          proc->wait_state = 0;
          proc->cptr = proc->optr = proc->yptr = NULL;
      }
      return proc;
  }
  ```

- 在`idt_init`函数中，设置中断`T_SYSCALL`的触发特权级为`DPL_USER`

  ```cpp
  void idt_init(void) {
       // ......
      // Lab5 code
      SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
      // ......
  }
  ```

- 在`trap_dispatch`中，设置每100次时间中断后，当前正在执行的进程准备被调度。同时，注释掉原来的"100ticks"输出

  ```cpp
  static void
  trap_dispatch(struct trapframe *tf) {
      char c;
      int ret=0;
      switch (tf->tf_trapno) {
      // ......
      case IRQ_OFFSET + IRQ_TIMER:
          ticks++;
          if(ticks % TICK_NUM == 0){
              // Lab5 Code
              assert(current != NULL);
              current->need_resched = 1;
              //print_ticks();
          }
          break;
     // ......
  ```

- 在`do_fork`函数中，添加对当前进程等待状态的检查，以及使用`set_links`函数来设置进程之间的关系。

  ```cpp
  int
  do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
      // ..........
      if ((proc = alloc_proc()) == NULL)
          goto fork_out;
      proc->parent = current;
      // Lab5: 确保当前进程的wait状态为空
      assert(current->wait_state == 0);
      if (setup_kstack(proc) != 0)
          goto bad_fork_cleanup_proc;
      if (copy_mm(clone_flags, proc) != 0)
          goto bad_fork_cleanup_kstack;
      copy_thread(proc, stack, tf);
      bool intr_flag;
      local_intr_save(intr_flag);
      {
          proc->pid = get_pid();
          hash_proc(proc);
          // Lab5: 设置进程间的关系
          set_links(proc);
      }
      local_intr_restore(intr_flag);
      wakeup_proc(proc);
      ret = proc->pid;
      // ..........
  }
  ```

### 1) 练习1

> **加载应用程序并执行**
>
> **do_execv**函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

- 相关实现代码如下

  ```cpp
  // codes in `load_icode` function
  
  //(6) setup trapframe for user environment
  struct trapframe *tf = current->tf;
  memset(tf, 0, sizeof(struct trapframe));
  /* LAB5:EXERCISE1 YOUR CODE
   * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
   * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
   *          tf_cs should be USER_CS segment (see memlayout.h)
   *          tf_ds=tf_es=tf_ss should be USER_DS segment
   *          tf_esp should be the top addr of user stack (USTACKTOP)
   *          tf_eip should be the entry point of this binary program (elf->e_entry)
   *          tf_eflags should be set to enable computer to produce Interrupt
   */
  tf->tf_cs = USER_CS;
  tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
  tf->tf_esp = USTACKTOP;
  tf->tf_eip = elf->e_entry;
  tf->tf_eflags = FL_IF;
  ret = 0;
  ```

- 请描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

  > 为便于描述得当，笔者将介绍一个用户态程序从开始执行`sys_execve`到具体执行新加载应用程序的第一条指令这个过程。

  - 当一个用户态程序执行`sys_execve`时，该程序将触发`0x80`中断，并进入中断处理例程。与Lab1类似，中断处理例程的入口代码会保存`trapframe`作为跳转回用户态的上下文环境。但与lab1代码所不同的是，lab5中的`trap`函数实现如下：

    ```cpp
    void trap(struct trapframe *tf) {
        // dispatch based on what type of trap occurred
        // used for previous projects
        if (current == NULL)
            trap_dispatch(tf);
        else {
            // 因为可能会发生嵌套中断的情况，所以保存上一次的trapframe
            struct trapframe *otf = current->tf;
            // 注意这一步，设置当前process的栈帧为当前中断栈帧
            current->tf = tf;
            bool in_kernel = trap_in_kernel(tf);
            trap_dispatch(tf);
            current->tf = otf;

            if (!in_kernel) {
                if (current->flags & PF_EXITING)
                    do_exit(-E_KILLED);
                if (current->need_resched)
                    schedule();
            }
        }
    }
    ```

  - 由于`trap`函数的设计，在`do_execve`中，此时的`current->tf`保存的就是用户态的上下文。

  - 因此在执行`load_icode`函数时，程序只会修改`current->trapframe`。因为当中断处理程序返回时，CPU所加载的上下文就是`current->trapframe`。

### 2) 练习2

> **父进程复制自己的内存空间给子进程**
>
> 创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数实现的，请补充copy_range的实现，确保能够正确执行。。

实现代码如下，详细信息以注释的形式写到代码中：

```cpp
/* copy_range - copy content of memory (start, end) of one process A to another process B
 * @to:    the addr of process B's Page Directory
 * @from:  the addr of process A's Page Directory
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
        uint32_t perm = (*ptep & PTE_USER);
        //get page from ptep
        struct Page *page = pte2page(*ptep);
        // alloc a page for process B
        struct Page *npage=alloc_page();
        assert(page!=NULL);
        assert(npage!=NULL);
        int ret=0;
        /* LAB5:EXERCISE2 YOUR CODE
         * replicate content of page to npage, build the map of phy addr of nage with the linear addr start
         */
        // 获取源页面所在的虚拟地址（注意，此时的PDT是内核状态下的页目录表）
        void * kva_src = page2kva(page);
        // 获取目标页面所在的虚拟地址
        void * kva_dst = page2kva(npage);
        // 页面数据复制
        memcpy(kva_dst, kva_src, PGSIZE);
        // 将该页面设置至对应的PTE中
        ret = page_insert(to, npage, start, perm);

        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

- 简要说明如何设计实现”Copy on Write 机制“，给出概要设计，鼓励给出详细设计。

  > 请移步**扩展练习** 。

### 3) 练习3

> **阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现**

#### 1. do_fork

- lab5中的`do_fork`函数与lab4中的实现类似，所不同的是lab5中使用`set_links(proc)`函数来设置进程间的关系，而不是简单的`list_add`与`nr_process++`。

- `set_links`函数会为当前进程间设置合适的关系，其实现如下：

  ```cpp
  /*************************************************************
  process relations
  parent:           proc->parent  (proc is children)
  children:         proc->cptr    (proc is parent)
  older sibling:    proc->optr    (proc is younger sibling)
  younger sibling:  proc->yptr    (proc is older sibling)
  *************************************************************/
  // set_links - set the relation links of process
  static void set_links(struct proc_struct *proc) {
      list_add(&proc_list, &(proc->list_link));
      proc->yptr = NULL;
      if ((proc->optr = proc->parent->cptr) != NULL)
          proc->optr->yptr = proc;
      proc->parent->cptr = proc;
      nr_process ++;
  }
  ```

  - 除了lab4熟知的``list_add``与`nr_process++`，该函数还设置了`proc_struct`中的`optr、yptr`以及`cptr`成员。

  - 其中，`cptr`指针指向当前进程的子进程中，**最晚创建**的那个子进程，即`children`；`yptr`指向**与当前进程共享同一个父进程，但比当前进程的创建时间更晚的进程**，即`younger sibling`。而`optr`指针的功能则与`yptr`相反，指向`older sibling`。

  - 进程间关系如下图所示

    ```text
                         +----------------+
                         | parent process |
                         +----------------+
                  parent ^         \       ^  parent
                        /           \       \
                       /             \ cptr  \
                      /         yptr  V       \      yptr
               +-------------+  -->  +-------------+  -->  NULL
               | old process |       | New Process |
    NULL  <--  +-------------+  <--  +-------------+
          optr                  optr
    ```

#### 2. do_execve

- `do_execve`函数做的事请比较简单

  - 检查当前进程所分配的内存区域是否存在异常。
  - 回收当前进程的所有资源，包括已分配的内存空间/页目录表等等。
  - 读取可执行文件，并根据`ELFheader`分配特定位置的虚拟内存，并加载代码与数据至特定的内存地址，最后分配堆栈并设置`trapframe`属性。
  - 设置新进程名称。

- 该函数**几乎释放原进程所有的资源，除了PCB**。也就是说，`do_execve`保留了原进程的PID、原进程的属性、原进程与其他进程之间的关系等等。

- 该函数的具体实现如下

  ```cpp
  int
  do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
      struct mm_struct *mm = current->mm;
      if (!user_mem_check(mm, (uintptr_t)name, len, 0))
          return -E_INVAL;
      if (len > PROC_NAME_LEN)
          len = PROC_NAME_LEN;
      char local_name[PROC_NAME_LEN + 1];
      memset(local_name, 0, sizeof(local_name));
      memcpy(local_name, name, len);
      // 释放内存
      if (mm != NULL) {
          lcr3(boot_cr3);
          if (mm_count_dec(mm) == 0) {
              exit_mmap(mm);
              // 删除该内存管理所对应的PDT
              put_pgdir(mm);
              mm_destroy(mm);
          }
          current->mm = NULL;
      }
      // 加载可执行文件代码，重设mm_struct，以及重置trapframe
      int ret;
      if ((ret = load_icode(binary, size)) != 0)
          goto execve_exit;
      // 设置进程名称
      set_proc_name(current, local_name);
      return 0;
  execve_exit:
      do_exit(ret);
      panic("already exit: %e.\n", ret);
  }
  ```

#### 3. do_wait

- `do_wait`程序会使某个进程一直等待，直到（特定）子进程退出后，该进程才会回收该子进程的资源并函数返回。该函数的具体操作如下：

  - 检查当前进程所分配的内存区域是否存在异常。
  - 查找特定/所有子进程中是否存在某个等待父进程回收的子进程（`PROC_ZOMBIE`）。
    - 如果有，则回收该进程并函数返回。
    - 如果没有，则设置当前进程状态为`PROC_SLEEPING`并执行`schedule`调度其他进程运行。当该进程的某个子进程结束运行后，当前进程会被唤醒，并在`do_wait`函数中回收子进程的**PCB内存**资源。

- 该函数的具体实现如下：

  ```cpp
  int
  do_wait(int pid, int *code_store) {
      struct mm_struct *mm = current->mm;
      if (code_store != NULL) {
          if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
              return -E_INVAL;
          }
      }
      struct proc_struct *proc;
      bool intr_flag, haskid;
  repeat:
      haskid = 0;
      if (pid != 0) {
          proc = find_proc(pid);
          if (proc != NULL && proc->parent == current) {
              haskid = 1;
              if (proc->state == PROC_ZOMBIE)
                  goto found;
          }
      }
      else {
          proc = current->cptr;
          for (; proc != NULL; proc = proc->optr) {
              haskid = 1;
              if (proc->state == PROC_ZOMBIE)
                  goto found;
          }
      }
      if (haskid) {
          current->state = PROC_SLEEPING;
          current->wait_state = WT_CHILD;
          schedule();
          if (current->flags & PF_EXITING)
              do_exit(-E_KILLED);
          goto repeat;
      }
      return -E_BAD_PROC;
  
  found:
      if (proc == idleproc || proc == initproc)
          panic("wait idleproc or initproc.\n");
      if (code_store != NULL)
          *code_store = proc->exit_code;
      local_intr_save(intr_flag);
      {
          unhash_proc(proc);
          remove_links(proc);
      }
      local_intr_restore(intr_flag);
      put_kstack(proc);
      kfree(proc);
      return 0;
  }
  ```

#### 4. do_exit

- 该函数与`do_execve/do_wait`函数中的进程回收代码类似，但又有所不同。其具体操作如下：
  - ·回收所有内存（除了PCB，该结构只能由父进程回收）

  - 设置当前的进程状态为`PROC_ZOMBIE`

  - 设置当前进程的退出值`current->exit_code`。

  - 如果有父进程，则唤醒父进程，使其准备回收该进程的PCB。

    > 正常情况下，除了`initproc`和`idleproc`以外，其他进程一定存在父进程。

  - 如果当前进程存在子进程，则设置所有子进程的父进程为`initproc`。这样倘若这些子进程进入结束状态，则`initproc`可以代为回收资源。

  - 执行进程调度。一旦调度到当前进程的父进程，则可以马上回收该终止进程的`PCB`。

- 该函数的具体实现如下

  ```cpp
  int do_exit(int error_code) {
      if (current == idleproc)
          panic("idleproc exit.\n");
      if (current == initproc)
          panic("initproc exit.\n");
      // 释放所有内存空间
      struct mm_struct *mm = current->mm;
      if (mm != NULL) {
          lcr3(boot_cr3);
          if (mm_count_dec(mm) == 0) {
              exit_mmap(mm);
              put_pgdir(mm);
              mm_destroy(mm);
          }
          current->mm = NULL;
      }
      // 设置当前进程状态
      current->state = PROC_ZOMBIE;
      current->exit_code = error_code;
      // 请求父进程回收剩余资源
      bool intr_flag;
      struct proc_struct *proc;
      local_intr_save(intr_flag);
      {
          proc = current->parent;
          // 唤醒父进程。父进程准备回收该进程的PCB资源。
          if (proc->wait_state == WT_CHILD)
              wakeup_proc(proc);
          // 如果当前进程存在子进程，则设置所有子进程的父进程为init。
          while (current->cptr != NULL) {
              proc = current->cptr;
              current->cptr = proc->optr;

              proc->yptr = NULL;
              if ((proc->optr = initproc->cptr) != NULL)
                  initproc->cptr->yptr = proc;
              proc->parent = initproc;
              initproc->cptr = proc;
              if (proc->state == PROC_ZOMBIE) {
                  if (initproc->wait_state == WT_CHILD)
                      wakeup_proc(initproc);
              }
          }
      }
      local_intr_restore(intr_flag);
      // 该进程的生命周期即将结束，调度其他进程执行。
      schedule();
      panic("do_exit will not return!! %d.\n", current->pid);
  }
  ```

#### 5. syscall系统调用

- `syscall`是内核程序为用户程序提供内核服务的一种方式。

- 在用户程序中，若需用到内核服务，则需要执行`sys_xxxx`函数，例如`sys_kill`：

  ```cpp
  int sys_kill(int pid) {
      return syscall(SYS_kill, pid);
  }
  ```

- 实际上，`sys_xxxx`函数全都是用户态`syscall`函数的wrapper。那些函数会设置参数并执行`syscall`函数，而该函数的实现如下：

  ```cpp
  static inline int syscall(int num, ...) {
      va_list ap;
      va_start(ap, num);
      uint32_t a[MAX_ARGS];
      int i, ret;
      for (i = 0; i < MAX_ARGS; i ++)
          a[i] = va_arg(ap, uint32_t);
      va_end(ap);
  
      asm volatile (
          "int %1;"
          : "=a" (ret)
          : "i" (T_SYSCALL),
            "a" (num),
            "d" (a[0]),
            "c" (a[1]),
            "b" (a[2]),
            "D" (a[3]),
            "S" (a[4])
          : "cc", "memory");
      return ret;
  }
  ```

  该函数会设置`%eax, %edx, %ecx, %ebx, %edi, %esi`五个寄存器的值分别为**syscall调用号、参数1、参数2、参数3、参数4、参数5**，然后执行int中断进入中断处理例程。

- 在中断处理例程中，程序会根据中断号，执行`syscall`函数（注意该syscall函数为内核代码，非用户库中的syscall函数）。内核syscall函数会一一取出六个寄存器的值，并根据系统调用号来执行不同的系统调用。而那些系统调用的实质就是其他内核函数的wrapper。以下为`syscall`函数实现的代码：

  ```cpp
  void
  syscall(void) {
      struct trapframe *tf = current->tf;
      uint32_t arg[5];
      int num = tf->tf_regs.reg_eax;
      if (num >= 0 && num < NUM_SYSCALLS) {
          if (syscalls[num] != NULL) {
              arg[0] = tf->tf_regs.reg_edx;
              arg[1] = tf->tf_regs.reg_ecx;
              arg[2] = tf->tf_regs.reg_ebx;
              arg[3] = tf->tf_regs.reg_edi;
              arg[4] = tf->tf_regs.reg_esi;
              tf->tf_regs.reg_eax = syscalls[num](arg);
              return ;
          }
      }
      print_trapframe(tf);
      panic("undefined syscall %d, pid = %d, name = %s.\n",
              num, current->pid, current->name);
  }
  ```

- 等相应的内核函数结束后，程序通过之前保留的`trapframe`返回用户态。一次系统调用结束。

#### *. Questions

简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

- 请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的？
  - fork会修改其子进程的状态为`PROC_RUNNABLE`，而当前进程状态不变。
  - exec不修改当前进程的状态，但会替换内存空间里所有的数据与代码。
  - wait会先检测是否存在子进程。如果存在进入`PROC_ZONBIE`的子进程，则回收该进程并函数返回。但若存在尚处于`PROC_RUNNABLE`的子进程，则当前进程会进入`PROC_SLEEPING`状态，并等待子进程唤醒。
  - exit会将当前进程状态设置为`PROC_ZONBIE`，并唤醒父进程，使其处于`PROC_RUNNABLE`的状态，之后主动让出CPU。

- 请给出ucore中一个用户态进程的执行状态生命周期图（包括执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。

    ```mermaid
    stateDiagram-v2
    [*]-->UNINIT : alloc_proc
    UNINIT-->RUNNABLE : proc_init/wakeup_proc
    RUNNING-->SLEEPING : try_free_pages/do_wait/do_sleep
    RUNNING-->ZONBIE : do_exit
    RUNNABLE-->RUNNING : 调度器调度
    RUNNING-->RUNNABLE : 时间片耗尽
    SLEEPING-->RUNNABLE : wakeup_proc
    ZONBIE-->[*] : 资源回收
    ```

在 ucore 或类似的操作系统中，当从用户模式（U mode）使用 ecall 指令进入监管模式（S mode）时，会发生一系列事件，这些事件构成了从用户空间到内核空间的上下文切换。具体过程如下：

触发陷阱（Trap）:

当用户模式下的程序执行 ecall 指令时，它会触发一个异常，导致控制权转移到操作系统的内核。
保存上下文:

在切换到内核模式之前，当前进程的状态（如寄存器状态）需要被保存，以便以后恢复。这通常包括程序计数器（PC）和堆栈指针（SP）。
跳转到异常处理程序:

控制权转移到异常处理程序。这通常是操作系统内核中预先定义好的，用于处理系统调用和其他异常情况的代码。
确定系统调用类型:

内核会检查触发 ecall 的具体原因。在一些系统中，ecall 指令后紧跟的立即数或者某个寄存器的值会被用于指示具体的系统调用类型。
执行系统调用:

根据确定的系统调用类型，内核执行相应的操作。这可能涉及访问硬件资源、管理文件系统、创建或终止进程等。
返回结果:

系统调用完成后，其结果（如返回值或错误代码）通常会被放置在某个寄存器中，以供用户模式的程序使用。
恢复用户模式上下文:

操作系统完成处理后，将恢复用户模式程序的上下文（如寄存器状态），并从系统调用返回点继续执行用户程序。
返回用户模式:

控制权返回给用户模式的程序，程序继续执行。
在整个 ecall 过程中，操作系统负责在用户模式和监管模式之间进行上下文切换，确保系统的稳定性和安全性，同时满足用户程序的请求。这种机制是现代操作系统设计中的一个关键部分，它允许用户程序以受控的方式请求操作系统提供的服务。

