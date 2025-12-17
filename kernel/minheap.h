// Organizes processes by vruntime for efficient scheduling

#ifndef MINHEAP_H
#define MINHEAP_H

#include "types.h"
#include "param.h"

struct proc;

// Min-heap structure for scheduling
struct minheap {
  struct proc *procs[NPROC];  // Array of process pointers
  int size;                   // Current number of elements in heap
  int capacity;               // Maximum capacity (NPROC)
};

// Initialize a min-heap
void minheap_init(struct minheap *heap);

// Insert a process into the heap
int minheap_insert(struct minheap *heap, struct proc *p);

// Extract the process with minimum vruntime
struct proc* minheap_extract_min(struct minheap *heap);

#endif // MINHEAP_H
