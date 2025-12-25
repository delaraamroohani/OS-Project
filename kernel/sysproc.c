#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

// Forward declaration
int ptree(int pid, struct proc_tree *tree);

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_clcnt(void)
{
  extern uint sysclcnt;
  return sysclcnt;
}

uint64
sys_ptree(void)
{
  int pid;
  uint64 tree_addr;
  struct proc_tree tree;
  struct proc *p = myproc();

  argint(0, &pid);
  argaddr(1, &tree_addr);

  // Call the kernel ptree function
  int result = ptree(pid, &tree);
  
  if (result < 0) {
    return -1;
  }

  // Copy the result to user space
  if (copyout(p->pagetable, tree_addr, (char *)&tree, sizeof(tree)) < 0) {
    return -1;
  }

  return 0;
}

// COW fork system call
uint64
sys_cowfork(void)
{
  return kcowfork();
}

// physaddr system call - returns the physical page number for a virtual address
// If no argument, uses the process's stack pointer area
uint64
sys_physaddr(void)
{
  struct proc *p = myproc();
  uint64 va;
  pte_t *pte;
  uint64 pa;

  // Get virtual address from argument (if provided)
  argaddr(0, &va);
  
  // If va is 0, use the stack pointer
  if(va == 0)
    va = p->trapframe->sp;
  
  va = PGROUNDDOWN(va);
  
  pte = walk(p->pagetable, va, 0);
  if(pte == 0 || (*pte & PTE_V) == 0)
    return -1;
  
  pa = PTE2PA(*pte);
  // Return page number (physical address divided by page size)
  return pa / PGSIZE;
}