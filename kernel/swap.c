#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

//
// Stage 2 swap-out: request queue + swapd evicts one page and frees RAM.
//

#define SWAPQ_SIZE NPROC

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
  struct swap_request r = {0};
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
}

// ---- Victim selection + swapout ----

// TODO (later stage): actually write the page to a .swp file via user helper.
// For stage 2 plumbing you can leave this as a stub.
static void
write_page_to_swap_file(int pid, uint64 va, uint64 pa)
{
  // Placeholder: implement in later stage.
  // Keep empty to avoid kernel file I/O in this phase.
  (void)pid; (void)va; (void)pa;
}

// Choose a victim page and evict it.
// Minimal policy: first valid user page that isn't already swapped.
// (You can improve to LRU with PTE_A later.)
static int
swapout_one_page(void)
{
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->state == UNUSED || p->is_kproc){
      release(&p->lock);
      continue;
    }

    // scan user virtual memory range [0, p->sz)
    // only page-aligned addresses
    for(uint64 va = 0; va < p->sz; va += PGSIZE){
      pte_t *pte = walk(p->pagetable, va, 0);
      if(pte == 0)
        continue;

      // candidate: valid, user, not swapped already
      if((*pte & PTE_V) && (*pte & PTE_U) && ((*pte & PTE_SWP) == 0)){
        uint64 pa = PTE2PA(*pte);

        // record contents to swap (later stage)
        write_page_to_swap_file(p->pid, va, pa);

        // mark swapped: clear valid, set swapped bit
        // keep permission bits if you want; swapped+!valid is the key signal.
        *pte = (*pte & ~PTE_V) | PTE_SWP;

        // free physical page
        kfree((void*)pa);

        release(&p->lock);
        return 0; // success: freed one page
      }
    }

    release(&p->lock);
  }

  return -1; // no victim found
}

// Called by memory allocation path when RAM is full.
// Put requester to sleep and ask swapd to free one page.
void
swap_wait_for_free_page(void)
{
  struct proc *me = myproc();

  acquire(&swap_lock);

  // enqueue a request; if full, still sleep — swapd may free eventually
  swapq_push(me);

  // wake swapd (if sleeping)
  wakeup((void*)&swapq_chan);

  // sleep until swapd frees at least one page
  sleep((void*)&swap_wait_chan, &swap_lock);

  // lock is reacquired by sleep() before returning; now release it
  release(&swap_lock);
}

// The swap-out kernel daemon.
void
swapd(void)
{
  // optional: print once
  // printf("swapd: started\n");

  for(;;){
    acquire(&swap_lock);
    while(qcount == 0){
      // sleep until someone enqueues a request
      sleep((void*)&swapq_chan, &swap_lock);
    }
    struct swap_request req = swapq_pop();
    release(&swap_lock);

    (void)req; // stage 2: requests are just “free one page”

    // Free exactly one page per request (simple and matches assignment)
    swapout_one_page();

    // wake all processes sleeping due to lack of RAM
    acquire(&swap_lock);
    wakeup((void*)&swap_wait_chan);
    release(&swap_lock);
  }
}
