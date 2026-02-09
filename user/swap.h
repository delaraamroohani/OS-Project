#pragma once
#include "kernel/types.h"   

#define SWAP_OP_WRITE 1

struct swap_task {
  int op;
  int pid;
  uint64 va;
};
