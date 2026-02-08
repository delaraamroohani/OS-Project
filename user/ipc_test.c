#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Test IPC and Mount namespace

int
main(int argc, char *argv[])
{
  int pid;

  printf("=== IPC and Mount Namespace Test ===\n\n");

  printf("Parent process:\n");
  printf("  PID: %d\n", getpid());
  printf("  Next PID in namespace: %d\n\n", get_pid_namespace());

  // Test unshare with CLONE_NEWIPC
  printf("Test 1: IPC Namespace Isolation\n");
  pid = fork();
  if(pid == 0) {
    printf("  Child PID: %d\n", getpid());
    printf("  Before unshare(CLONE_NEWIPC): next_pid = %d\n", get_pid_namespace());
    
    unshare(CLONE_NEWIPC);
    printf("  After unshare(CLONE_NEWIPC): next_pid = %d\n", get_pid_namespace());
    
    // Children should inherit this IPC namespace
    int cpid = fork();
    if(cpid == 0) {
      printf("    Grandchild: next_pid = %d (inherited from parent)\n", get_pid_namespace());
      exit(0);
    } else {
      wait(0);
    }
    exit(0);
  } else {
    wait(0);
  }
  printf("\n");

  // Test unshare with CLONE_NEWNS (Mount namespace)
  printf("Test 2: Mount Namespace Isolation\n");
  pid = fork();
  if(pid == 0) {
    printf("  Child PID: %d\n", getpid());
    printf("  Before unshare(CLONE_NEWNS): next_pid = %d\n", get_pid_namespace());
    
    unshare(CLONE_NEWNS);
    printf("  After unshare(CLONE_NEWNS): next_pid = %d\n", get_pid_namespace());
    
    exit(0);
  } else {
    wait(0);
  }
  printf("\n");

  // Test combined unshare
  printf("Test 3: Combined Namespaces\n");
  pid = fork();
  if(pid == 0) {
    printf("  Child before unshare:\n");
    printf("    PID ns: %d\n", get_pid_namespace());
    
    // Create new PID, IPC, and Mount namespaces
    unshare(CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWNS);
    printf("  Child after unshare(CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWNS):\n");
    printf("    PID ns: %d\n", get_pid_namespace());
    
    exit(0);
  } else {
    wait(0);
  }

  printf("\n=== Test Complete ===\n");
  exit(0);
}
