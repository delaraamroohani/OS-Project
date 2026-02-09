#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "swap.h"

#define SWAPQ_SIZE NPROC

// ------------------------------------------------------------
// Swap I/O mailbox (shared with sys_swap_fetch/sys_swap_complete)
// ------------------------------------------------------------
// IMPORTANT: these must be global (non-static) so sysproc.c can extern them.

struct spinlock swapio_lock;
struct swap_task swapio_task;
char swapio_page[PGSIZE];

int swapio_pending = 0;     // 1 if a request is pending for user swapper
int swapio_done = 0;        // 1 if user swapper finished
int swapio_status = 0;      // completion status from user swapper

int swapio_req_chan;        // user swapper sleeps on this waiting for request
int swapio_done_chan;       // kernel sleeps on this waiting for completion

static int swapio_inited = 0;

static void
swapio_init_once(void)
{
  if(!swapio_inited){
    initlock(&swapio_lock, "swapio");
    swapio_pending = 0;
    swapio_done = 0;
    swapio_status = 0;
    swapio_inited = 1;
  }
}

// Submit a WRITE request and block until user swapper completes it.
static int
swapio_write_page(int pid, uint64 va, uint64 pa)
{
  swapio_init_once();

  acquire(&swapio_lock);

  // wait if a previous request is still outstanding
  while(swapio_pending){
    sleep((void*)&swapio_done_chan, &swapio_lock);
  }

  swapio_task.op  = SWAP_OP_WRITE;
  swapio_task.pid = pid;
  swapio_task.va  = va;

  // copy page contents into kernel mailbox buffer
  memmove(swapio_page, (void*)pa, PGSIZE);

  swapio_done = 0;
  swapio_status = 0;
  swapio_pending = 1;

  // wake user swapper (blocked in sys_swap_fetch)
  wakeup((void*)&swapio_req_chan);

  // wait for completion
  while(!swapio_done){
    sleep((void*)&swapio_done_chan, &swapio_lock);
  }

  int st = swapio_status;
  release(&swapio_lock);
  return st;
}

// ------------------------------------------------------------
// Swap-out request queue + swapd
// ------------------------------------------------------------

struct swap_request {
  struct proc *requester;
};

static struct spinlock swap_lock;
static struct swap_request swapq[SWAPQ_SIZE];
static int qhead = 0, qtail = 0, qcount = 0;

// channels for sleep/wakeup
static int swapq_chan;        // swapd sleeps here when queue empty
static int swap_wait_chan;    // memory waiters sleep here until a page freed

static int
swapq_push(struct proc *p)
{
  if(qcount == SWAPQ_SIZE)
    return -1;
  swapq[qtail].requester = p;
  qtail = (qtail + 1) % SWAPQ_SIZE;
  qcount++;
  return 0;
}

static struct swap_request
swapq_pop(void)
{
  struct swap_request r;
  r.requester = 0;

  if(qcount == 0)
    return r;

  r = swapq[qhead];
  qhead = (qhead + 1) % SWAPQ_SIZE;
  qcount--;
  return r;
}

void
swap_init(void)
{
  initlock(&swap_lock, "swap");
  qhead = qtail = qcount = 0;

  // also init swapio lock here so it’s ready before swap pressure hits
  swapio_init_once();
}

// ---- LRU-ish victim selection using PTE_A (second chance) ----

static int
is_evictable_pte(pte_t pte)
{
  if((pte & PTE_V) == 0) return 0;
  if((pte & PTE_U) == 0) return 0;
  if(pte & PTE_SWP) return 0;
  return 1;
}

// Returns with victim proc lock held on success.
static int
find_victim_lru(struct proc **outp, uint64 *outva, pte_t **outpte)
{
  for(int pass = 0; pass < 2; pass++){
    for(struct proc *p = proc; p < &proc[NPROC]; p++){
      acquire(&p->lock);

      if(p->state == UNUSED || p->is_kproc){
        release(&p->lock);
        continue;
      }

      for(uint64 va = 0; va < p->sz; va += PGSIZE){
        pte_t *pte = walk(p->pagetable, va, 0);
        if(pte == 0)
          continue;

        if(!is_evictable_pte(*pte))
          continue;

        if(pass == 0){
          if(*pte & PTE_A){
            *pte &= ~PTE_A; // second chance: clear accessed and skip
            continue;
          }
          // A==0 => good victim
        }

        *outp = p;
        *outva = va;
        *outpte = pte;
        return 0; // p->lock still held
      }

      release(&p->lock);
    }
  }

  return -1;
}

static int
swapout_one_page(void)
{
  struct proc *vp = 0;
  uint64 va = 0;
  pte_t *pte = 0;

  if(find_victim_lru(&vp, &va, &pte) < 0)
    return -1;

  uint64 pa = PTE2PA(*pte);

  // 1) write out via user-space helper
  int st = swapio_write_page(vp->pid, va, pa);
  if(st < 0){
    release(&vp->lock);
    return -1;
  }

  // 2) update PTE: mark swapped + invalid
  *pte = (*pte & ~PTE_V) | PTE_SWP;

  // 3) free physical memory
  kfree((void*)pa);

  release(&vp->lock);
  return 0;
}

// Called by memory allocation path when RAM is full.
void
swap_wait_for_free_page(void)
{
  struct proc *me = myproc();

  acquire(&swap_lock);

  // enqueue request (best-effort)
  swapq_push(me);

  // wake swapd (if sleeping)
  wakeup((void*)&swapq_chan);

  // sleep until swapd frees at least one page
  sleep((void*)&swap_wait_chan, &swap_lock);

  release(&swap_lock);
}

// The swap-out kernel daemon.
void
swapd(void)
{
  for(;;){
    acquire(&swap_lock);
    while(qcount == 0){
      sleep((void*)&swapq_chan, &swap_lock);
    }
    struct swap_request req = swapq_pop();
    release(&swap_lock);

    (void)req;

    // free exactly one page per request
    swapout_one_page();

    // wake all processes sleeping due to lack of RAM
    acquire(&swap_lock);
    wakeup((void*)&swap_wait_chan);
    release(&swap_lock);
  }
}
