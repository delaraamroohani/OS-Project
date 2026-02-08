#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Basic PID Namespace Test

int
main(int argc, char *argv[])
{
  int pid1, pid2;

  printf("=== PID Namespace Test Program ===\n\n");

  printf("Main process:\n");
  printf("  Global PID: %d\n", getpid());
  printf("  Namespace PID: %d\n\n", get_pid());

  // Create first child
  pid1 = fork();
  if(pid1 == 0) {
    // First child
    printf("First child:\n");
    printf("  Global PID: %d\n", getpid());
    printf("  Namespace PID: %d\n\n", get_pid());
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

  // Test new namespace
  printf("Creating new namespace...\n");
  if(unshare(CLONE_NEWPID) == 0) {
    printf("New namespace created:\n");
    printf("  Namespace PID: %d (reset to 1 in new ns)\n\n", get_pid());
  }

  printf("=== Test Complete ===\n");
  
  exit(0);
}
