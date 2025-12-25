#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  char *buf = malloc(4096);
  if(buf == 0) {
    printf("malloc failed\n");
    exit(1);
  }
  
  buf[0] = 'A';
  
  int parent_page_before = physaddr(buf);
  printf("Parent: initial page number value = %d\n", parent_page_before);
  
  int pid = cowfork();
  if(pid < 0) {
    printf("cowfork failed\n");
    exit(1);
  }
  
  if(pid == 0) {
    // Child process
    int child_page_before = physaddr(buf);
    printf("Child: initial page number value = %d\n", child_page_before);
    printf("Child: initial buffer val = %c\n", buf[0]);
    
    // Write to the buffer - this should trigger COW
    buf[0] = 'C';
    
    int child_page_after = physaddr(buf);
    printf("Child: page number after writing = %d\n", child_page_after);
    printf("Child: buffer value after write: %c\n", buf[0]);
    
    if(child_page_before == child_page_after) {
      printf("ERROR: Page should have changed after write!\n");
    } else {
      printf("SUCCESS: Page changed after write (COW worked!)\n");
    }
    
    exit(0);
  }
  
  // Parent waits for child
  wait(0);
  
  int parent_page_after = physaddr(buf);
  printf("Parent: after child write, page number value = %d\n", parent_page_after);
  printf("Parent: after child write, buffer value = %c\n", buf[0]);
  
  // Verify COW semantics:
  // 1. Parent's page should be the same as before (or changed if only ref remaining)
  // 2. Parent's buffer value should still be 'A' (unchanged by child's write)
  
  if(buf[0] == 'A') {
    printf("SUCCESS: Parent's data unchanged by child's write!\n");
  } else {
    printf("ERROR: Parent's data was modified by child's write!\n");
  }
  
  if(parent_page_before == parent_page_after) {
    printf("Parent's page number unchanged.\n");
  } else {
    printf("Parent's page number changed (expected if refcount dropped to 1).\n");
  }
  
  return 0;
}
