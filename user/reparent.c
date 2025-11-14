#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void print_tree(struct proc_tree *t, int rootpid)
{
  for (int i = 0; i < t->count; i++) {
    struct proc_info *pi = &t->processes[i];
    // Only show processes in this subtree
    int depth = 0;
    int cur_ppid = pi->ppid;
    int in_subtree = (pi->pid == rootpid);
    // Walk up parent chain using available entries in proc_tree
    while (!in_subtree && cur_ppid != 0) {
      if (cur_ppid == rootpid) {
        depth++;
        in_subtree = 1;
        break;
      }
      // find parent info
      int found = 0;
      for (int j = 0; j < t->count; j++) {
        if (t->processes[j].pid == cur_ppid) {
          depth++;
          cur_ppid = t->processes[j].ppid;
          found = 1;
          break;
        }
      }
      if (!found) break; // parent not in captured tree
    }
    if (!in_subtree) continue;
    // print indentation
    for (int d = 0; d < depth; d++) printf("  ");
    printf("%d\n", pi->pid);
  }
}

int
main(int argc, char *argv[])
{
  int grandpid = getpid();
  struct proc_tree tree;
  struct proc_tree tree_after;

  int parent_pid = fork();
  if (parent_pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (parent_pid == 0) {
    // Parent process P
    int child_pid = fork();
    if (child_pid < 0) {
      printf("child fork failed\n");
      exit(1);
    }
    if (child_pid == 0) {
      // Child process C: wait for parent to exit then wait a bit
      pause(60); // parent will exit earlier
      // wait until grandparent becomes parent
      pause(80);
      exit(0);
    }
    // parent waits a bit then exits to orphan child
    pause(40);
    exit(0);
  }

  // Grandparent process G
  // Allow parent & child to be created
  pause(20);
  if (ptree(grandpid, &tree) == 0) {
    printf("Before parent exit (expected G->P->C):\n");
    print_tree(&tree, grandpid);
  } else {
    printf("ptree failed (before)\n");
  }

  // wait for parent to exit
  wait(0);

  // Give kernel time to perform reparent
  pause(30);
  if (ptree(grandpid, &tree_after) == 0) {
    printf("After parent exit (expected G->C):\n");
    print_tree(&tree_after, grandpid);
  } else {
    printf("ptree failed (after)\n");
  }

  // reap orphaned child now adopted by grandparent
  while (wait(0) > 0) {}

  printf("reparent_simple test done\n");
  exit(0);
}
