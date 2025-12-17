// Maintains processes ordered by vruntime

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "minheap.h"

// Helper: Get parent index
static inline int parent(int i) {
  return (i - 1) / 2;
}

// Helper: Get left child index
static inline int left_child(int i) {
  return 2 * i + 1;
}

// Helper: Get right child index
static inline int right_child(int i) {
  return 2 * i + 2;
}

// Helper: Swap two elements in the heap
static void swap(struct minheap *heap, int i, int j) {
  struct proc *temp = heap->procs[i];
  heap->procs[i] = heap->procs[j];
  heap->procs[j] = temp;
}

// Heapify up: Move element up until heap property is satisfied
static void heapify_up(struct minheap *heap, int idx) {
  while (idx > 0) {
    int p = parent(idx);
    // Compare vruntime values
    if (heap->procs[idx]->vruntime < heap->procs[p]->vruntime) {
      swap(heap, idx, p);
      idx = p;
    } else {
      break;
    }
  }
}

// Heapify down: Move element down until heap property is satisfied
static void heapify_down(struct minheap *heap, int idx) {
  while (1) {
    int smallest = idx;
    int left = left_child(idx);
    int right = right_child(idx);

    // Check if left child has smaller vruntime
    if (left < heap->size && 
        heap->procs[left]->vruntime < heap->procs[smallest]->vruntime) {
      smallest = left;
    }

    // Check if right child has smaller vruntime
    if (right < heap->size && 
        heap->procs[right]->vruntime < heap->procs[smallest]->vruntime) {
      smallest = right;
    }

    // If smallest is not the current node, swap and continue
    if (smallest != idx) {
      swap(heap, idx, smallest);
      idx = smallest;
    } else {
      break;
    }
  }
}

// Initialize a min-heap
void minheap_init(struct minheap *heap) {
  heap->size = 0;
  heap->capacity = NPROC;
  for (int i = 0; i < NPROC; i++) {
    heap->procs[i] = 0;
  }
}

// Insert a process into the heap
int minheap_insert(struct minheap *heap, struct proc *p) {
  if (heap->size >= heap->capacity) {
    return -1;  // Heap is full
  }

  // Add the new process at the end
  heap->procs[heap->size] = p;
  heap->size++;

  // Heapify up to maintain heap property
  heapify_up(heap, heap->size - 1);

  return 0;
}

// Extract the process with minimum vruntime
struct proc* minheap_extract_min(struct minheap *heap) {
  if (heap->size == 0) {
    return 0;  // Heap is empty
  }

  struct proc *min_proc = heap->procs[0];

  // Move the last element to the root
  heap->procs[0] = heap->procs[heap->size - 1];
  heap->size--;

  // Heapify down from the root
  if (heap->size > 0) {
    heapify_down(heap, 0);
  }

  return min_proc;
}
