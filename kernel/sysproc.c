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

// Get PID from current process's namespace
uint64
sys_get_pid(void)
{
  struct proc *p = myproc();
  
  if(p->pid_ns == 0)
    return -1;
  
  return pid_namespace_get_pid(p->pid_ns);
}

// Get the next PID that will be assigned in the namespace
uint64
sys_get_pid_namespace(void)
{
  struct proc *p = myproc();
  
  if(p->pid_ns == 0)
    return -1;
  
  acquire(&p->pid_ns->lock);
  int next_pid = p->pid_ns->next_pid;
  release(&p->pid_ns->lock);
  
  return next_pid;
}

// Set a new PID namespace (for creating new namespace)
uint64
sys_set_pid_namespace(void)
{
  struct proc *p = myproc();
  
  // Create a new namespace
  struct pid_namespace *new_ns = pid_namespace_alloc();
  if(new_ns == 0)
    return -1;
  
  // Release old namespace and set new one
  if(p->pid_ns)
    pid_namespace_put(p->pid_ns);
  
  p->pid_ns = new_ns;
  
  return 0;
}

// Get hostname from UTS namespace
uint64
sys_getHostname(void)
{
  struct proc *p = myproc();
  uint64 addr;
  int len;
  
  argaddr(0, &addr);
  argint(1, &len);
  
  if(p->uts_ns == 0)
    return -1;
  
  acquire(&p->uts_ns->lock);
  int hostname_len = strlen(p->uts_ns->hostname);
  if(len < hostname_len + 1) {
    release(&p->uts_ns->lock);
    return -1;
  }
  
  if(copyout(p->pagetable, addr, p->uts_ns->hostname, hostname_len + 1) < 0) {
    release(&p->uts_ns->lock);
    return -1;
  }
  release(&p->uts_ns->lock);
  
  return 0;
}

// Set hostname in UTS namespace
uint64
sys_setHostname(void)
{
  struct proc *p = myproc();
  uint64 addr;
  int len;
  char hostname[HOSTNAME_LEN];
  
  argaddr(0, &addr);
  argint(1, &len);
  
  if(p->uts_ns == 0)
    return -1;
  
  if(len <= 0 || len >= HOSTNAME_LEN)
    return -1;
  
  if(copyin(p->pagetable, hostname, addr, len) < 0)
    return -1;
  
  hostname[len] = '\0';
  
  acquire(&p->uts_ns->lock);
  safestrcpy(p->uts_ns->hostname, hostname, HOSTNAME_LEN);
  release(&p->uts_ns->lock);
  
  return 0;
}

// Unshare creates new namespaces based on flags
uint64
sys_unshare(void)
{
  struct proc *p = myproc();
  int flags;
  
  argint(0, &flags);
  
  if(flags & CLONE_NEWPID) {
    struct pid_namespace *new_ns = pid_namespace_alloc();
    if(new_ns == 0)
      return -1;
    pid_namespace_put(p->pid_ns);
    p->pid_ns = new_ns;
  }
  
  if(flags & CLONE_NEWUTS) {
    struct uts_namespace *new_ns = uts_namespace_alloc();
    if(new_ns == 0)
      return -1;
    uts_namespace_put(p->uts_ns);
    p->uts_ns = new_ns;
  }
  
  if(flags & CLONE_NEWIPC) {
    struct ipc_namespace *new_ns = ipc_namespace_alloc();
    if(new_ns == 0)
      return -1;
    ipc_namespace_put(p->ipc_ns);
    p->ipc_ns = new_ns;
  }
  
  if(flags & CLONE_NEWNS) {
    struct mount_namespace *new_ns = mount_namespace_alloc(0);
    if(new_ns == 0)
      return -1;
    mount_namespace_put(p->mnt_ns);
    p->mnt_ns = new_ns;
  }
  
  return 0;
}
