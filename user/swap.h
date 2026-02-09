#pragma once
#include "kernel/types.h"   

#define SWAP_OP_WRITE 1
#define SWAP_OP_READ  2

struct swap_task {
  int op;
  int pid;
  uint64 va;
};
