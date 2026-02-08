#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Advanced PID Namespace Test

int
main(int argc, char *argv[])
{
  int pid1, pid2;

  printf("=== Advanced PID Namespace Test ===\n\n");

  printf("Parent process:\n");
  printf("  Global PID: %d\n", getpid());
  printf("  Namespace PID: %d\n\n", get_pid());

  // Create first child
  pid1 = fork();
  if(pid1 == 0) {
    // First child
    printf("First child:\n");
    printf("  Global PID: %d\n", getpid());
    printf("  Namespace PID: %d\n", get_pid());
    
    // Grandchild
    int gpid = fork();
    if(gpid == 0) {
      printf("  Grandchild:\n");
      printf("    Global PID: %d\n", getpid());
      printf("    Namespace PID: %d\n\n", get_pid());
      exit(0);
    }
    wait(0);
    exit(0);
  }

  // Create second child
  pid2 = fork();
  if(pid2 == 0) {
    // Second child
    printf("Second child:\n");
    printf("  Global PID: %d\n", getpid());
    printf("  Namespace PID: %d\n\n", get_pid());
    exit(0);
  }

  // Wait for children
  wait(0);
  wait(0);

  printf("Parent continues:\n");
  printf("  Global PID: %d\n", getpid());
  printf("  Namespace PID: %d\n\n", get_pid());

  // Test isolated namespace
  printf("Testing isolated namespace:\n");
  pid1 = fork();
  if(pid1 == 0) {
    if(unshare(CLONE_NEWPID) == 0) {
      printf("  Child created new PID namespace\n");
      printf("  New namespace PID: %d (should be 1)\n", get_pid());
      
      int cpid = fork();
      if(cpid == 0) {
        printf("    Grandchild in isolated ns: PID = %d\n", get_pid());
        exit(0);
      }
      wait(0);
    }
    exit(0);
  }
  wait(0);

  printf("\n=== Advanced Test Complete ===\n");
  
  exit(0);
}
