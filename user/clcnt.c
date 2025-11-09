#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
  printf("System call count: %d\n", clcnt());
  getpid();
  printf("System call count after getpid: %d\n", clcnt());
  exit(0);
}
