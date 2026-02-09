#pragma once
#include "types.h"

#define SWAP_OP_WRITE 1
#define SWAP_OP_READ  2

struct swap_task {
  int op;        // SWAP_OP_WRITE for now
  int pid;
  uint64 va;     // page-aligned virtual address
};
