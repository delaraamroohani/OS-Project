#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"   // optional

int
main(int argc, char *argv[])
{
  char buf[4096];
  memset(buf, 0, sizeof(buf));  // Ensure null-termination
  int pid = 1;
  int n;

  if (argc > 1)
    pid = atoi(argv[1]);

  n = ptree(pid, buf, sizeof(buf));
  if (n < 0) {
    printf("ptree failed\n");
    exit(1);
  }
  if (n >= sizeof(buf))
    n = sizeof(buf) - 1;
  buf[n] = '\0';
  printf("%s", buf);
  exit(0);
}