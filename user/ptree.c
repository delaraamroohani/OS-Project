#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
print_tree_recursive(struct proc_tree *tree, int index, char *prefix, int is_last)
{
  struct proc_info *proc = &tree->processes[index];
  
  // Print the current process with tree characters
  printf("%s", prefix);
  if (index != 0) {  // Not root
    if (is_last) {
      printf("└─");  
    } else {
      printf("├─");  
    }
  }
  printf("PID: %d\n", proc->pid);
  
  // Build prefix for children
  char new_prefix[256];
  int prefix_len = 0;
  
  // Copy existing prefix
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
    new_prefix[prefix_len++] = prefix[i];
  }
  
  // Add to prefix for children
  if (index != 0) {  // Not root
    if (is_last) {
      new_prefix[prefix_len++] = ' ';
      new_prefix[prefix_len++] = ' ';
    } else {
      // UTF-8 encoding for │ (0xE29482)
      new_prefix[prefix_len++] = 0xE2;
      new_prefix[prefix_len++] = 0x94;
      new_prefix[prefix_len++] = 0x82;
      new_prefix[prefix_len++] = ' ';
    }
  }
  new_prefix[prefix_len] = '\0';
  
  // Find and print all children
  int child_count = 0;
  
  // Count children
  for (int i = index + 1; i < tree->count; i++) {
    if (tree->processes[i].ppid == proc->pid) {
      child_count++;
    }
  }
  
  // Print children
  int printed = 0;
  for (int i = index + 1; i < tree->count; i++) {
    if (tree->processes[i].ppid == proc->pid) {
      printed++;
      print_tree_recursive(tree, i, new_prefix, (printed == child_count));
    }
  }
}

int
main(int argc, char *argv[])
{
  struct proc_tree tree;
  int pid = 1; // Default to init process
  
  if (argc > 1) {
    pid = atoi(argv[1]);
  }

  if (ptree(pid, &tree) < 0) {
    printf("ptree failed: process %d not found\n", pid);
    exit(1);
  }

  printf("Process tree rooted at PID %d:\n", pid);
  printf("Total processes in tree: %d\n\n", tree.count);
  
  if (tree.count > 0) {
    print_tree_recursive(&tree, 0, "", 1);
  }
  
  exit(0);
}