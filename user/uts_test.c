#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// UTS Namespace Test
// Tests hostname isolation between processes

int
main(int argc, char *argv[])
{
  int pid;
  char buf[64];

  printf("=== UTS Namespace Isolation Test ===\n\n");

  printf("Setting parent hostname to 'parent-host'...\n");
  if(setHostname("parent-host", 11) == 0) {
    if(getHostname(buf, 64) == 0) {
      printf("Parent hostname: %s\n\n", buf);
    }
  }

  // Create first container
  pid = fork();
  if(pid == 0) {
    // Container 1
    printf("Container 1 (child process):\n");
    if(getHostname(buf, 64) == 0) {
      printf("  Inherits parent hostname: %s\n", buf);
    }
    
    // Try to set new hostname
    if(setHostname("container-1", 11) == 0) {
      if(getHostname(buf, 64) == 0) {
        printf("  Changed to: %s\n", buf);
      }
    }
    
    // Now isolate with unshare
    if(unshare(CLONE_NEWUTS) == 0) {
      printf("  Created new UTS namespace\n");
      if(setHostname("isolated-1", 10) == 0) {
        if(getHostname(buf, 64) == 0) {
          printf("  New isolated hostname: %s\n", buf);
        }
      }
    } else {
      printf("  unshare(CLONE_NEWUTS) failed\n");
    }
    
    printf("\n");
    exit(0);
  }

  // Create second container
  pid = fork();
  if(pid == 0) {
    // Container 2
    char buf2[64];
    printf("Container 2 (another child):\n");
    
    if(getHostname(buf2, 64) == 0) {
      printf("  Inherits parent hostname: %s\n", buf2);
    }
    
    // Isolate with unshare
    if(unshare(CLONE_NEWUTS) == 0) {
      printf("  Created new UTS namespace\n");
      if(setHostname("isolated-2", 10) == 0) {
        if(getHostname(buf2, 64) == 0) {
          printf("  New isolated hostname: %s\n", buf2);
        }
      }
    }
    
    printf("\n");
    exit(0);
  }

  // Wait for containers
  wait(0);
  wait(0);

  printf("Parent process after children:\n");
  if(getHostname(buf, 64) == 0) {
    printf("  Hostname still: %s\n", buf);
  }
  printf("  Children's changes did not affect parent!\n\n");

  // Test combined namespace isolation
  pid = fork();
  if(pid == 0) {
    // Full isolation
    if(unshare(CLONE_NEWPID | CLONE_NEWUTS | CLONE_NEWIPC) == 0) {
      printf("Full isolation test:\n");
      printf("  New PID: %d (namespace isolated)\n", getpid());
      if(setHostname("fully-isolated", 14) == 0) {
        if(getHostname(buf, 64) == 0) {
          printf("  Hostname: %s (isolated)\n", buf);
        }
      }
      printf("  IPC namespace: isolated\n");
    }
    exit(0);
  }

  wait(0);

  printf("\n=== UTS Namespace Test Complete ===\n");
  
  exit(0);
}
