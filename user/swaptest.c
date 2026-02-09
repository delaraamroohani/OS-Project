#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NCHILD 20
#define NALLOC 10
#define PGSZ   4096

static void
fill_pattern(char *p, int child, int iter)
{
  // deterministic per-child/per-iter pattern
  unsigned char v = (unsigned char)(child * 31 + iter * 17 + 7);
  for(int i = 0; i < PGSZ; i++)
    p[i] = (char)(v + (i & 0xFF));
}

static int
check_pattern(char *p, int child, int iter)
{
  unsigned char v = (unsigned char)(child * 31 + iter * 17 + 7);
  for(int i = 0; i < PGSZ; i++){
    char exp = (char)(v + (i & 0xFF));
    if(p[i] != exp)
      return -1;
  }
  return 0;
}

int
main(void)
{
  printf("swaptest: forking %d children...\n", NCHILD);

  for(int c = 0; c < NCHILD; c++){
    int pid = fork();
    if(pid < 0){
      printf("swaptest: fork failed at child %d\n", c);
      exit(1);
    }

    if(pid == 0){
      // child
      char *bufs[NALLOC];

      for(int i = 0; i < NALLOC; i++){
        bufs[i] = malloc(PGSZ);
        if(bufs[i] == 0){
          printf("swaptest(child %d): malloc failed at iter %d\n", c, i);
          exit(1);
        }
        fill_pattern(bufs[i], c, i);

        // Touch bytes again to encourage paging activity
        for(int k = 0; k < PGSZ; k += 64)
          bufs[i][k] ^= 0;
      }

      // Verify all allocations still contain correct data
      for(int i = 0; i < NALLOC; i++){
        if(check_pattern(bufs[i], c, i) < 0){
          printf("swaptest(child %d): data CORRUPTION at iter %d\n", c, i);
          exit(1);
        }
      }

      // keep pages mapped until end
      printf("swaptest(child %d): OK\n", c);
      exit(0);
    }
  }

  // Parent waits
  int ok = 1;
  for(int i = 0; i < NCHILD; i++){
    int st = 0;
    int w = wait(&st);
    if(w < 0){
      printf("swaptest: wait failed\n");
      ok = 0;
      continue;
    }
    if(st != 0){
      printf("swaptest: child pid %d FAILED (status=%d)\n", w, st);
      ok = 0;
    }
  }

  if(ok)
    printf("swaptest: ALL OK\n");
  else
    printf("swaptest: FAILED\n");

  exit(ok ? 0 : 1);
}
