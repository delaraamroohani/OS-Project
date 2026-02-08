#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// Comprehensive namespace test

int
main(int argc, char *argv[])
{
  char hostname[64];
  int pid;

  printf("=== Comprehensive Namespace Test ===\n\n");

  // Test 1: PID Namespace
  printf("Test 1: PID Namespace\n");
  printf("  Current namespace next_pid: %d\n", get_pid_namespace());
  
  pid = fork();
  if(pid == 0) {
    printf("  Child PID: %d, Next: %d\n", getpid(), get_pid_namespace());
    exit(0);
  } else {
    wait(0);
  }
  printf("\n");

  // Test 2: UTS Namespace (Hostname)
  printf("Test 2: UTS Namespace (Hostname)\n");
  printf("  Getting hostname...\n");
  if(getHostname(hostname, 64) == 0) {
    printf("  Hostname: %s\n", hostname);
  } else {
    printf("  No hostname set\n");
  }

  printf("  Setting hostname to 'container1'...\n");
  if(setHostname("container1", 10) == 0) {
    if(getHostname(hostname, 64) == 0) {
      printf("  New hostname: %s\n", hostname);
    }
  }
  printf("\n");

  // Test 3: Unshare with CLONE_NEWUTS
  printf("Test 3: Unshare UTS Namespace\n");
  pid = fork();
  if(pid == 0) {
    // Child creates new UTS namespace
    printf("  Child before unshare:\n");
    if(getHostname(hostname, 64) == 0) {
      printf("    Hostname: %s\n", hostname);
    }

    unshare(CLONE_NEWUTS);
    printf("  Child after unshare(CLONE_NEWUTS):\n");
    setHostname("isolated-host", 14);
    if(getHostname(hostname, 64) == 0) {
      printf("    New hostname: %s\n", hostname);
    }
    exit(0);
  } else {
    wait(0);
    printf("  Parent after child exits:\n");
    if(getHostname(hostname, 64) == 0) {
      printf("    Hostname (unchanged): %s\n", hostname);
    }
  }
  printf("\n");

  // Test 4: Unshare with CLONE_NEWPID
  printf("Test 4: Unshare PID Namespace\n");
  pid = fork();
  if(pid == 0) {
    printf("  Child before unshare: next_pid = %d\n", get_pid_namespace());
    unshare(CLONE_NEWPID);
    printf("  Child after unshare(CLONE_NEWPID): next_pid = %d\n", get_pid_namespace());
    exit(0);
  } else {
    wait(0);
  }
  printf("\n");

  // Test 5: Multiple unshare flags
  printf("Test 5: Unshare Multiple Namespaces\n");
  pid = fork();
  if(pid == 0) {
    printf("  Child before unshare:\n");
    printf("    PID ns next: %d\n", get_pid_namespace());
    if(getHostname(hostname, 64) == 0) {
      printf("    Hostname: %s\n", hostname);
    }

    unshare(CLONE_NEWPID | CLONE_NEWUTS);
    printf("  Child after unshare(CLONE_NEWPID | CLONE_NEWUTS):\n");
    printf("    PID ns next: %d\n", get_pid_namespace());
    setHostname("multi-isolated", 14);
    if(getHostname(hostname, 64) == 0) {
      printf("    Hostname: %s\n", hostname);
    }
    exit(0);
  } else {
    wait(0);
  }

  printf("\n=== All Tests Complete ===\n");
  exit(0);
}
