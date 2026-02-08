#ifndef _MOUNT_NAMESPACE_H_
#define _MOUNT_NAMESPACE_H_

struct inode;

// Mount namespace structure
struct mount_namespace {
  int refcnt;               // Reference count
  struct inode *root;       // Root inode
  struct spinlock lock;     // Lock for synchronization
};

#endif // _MOUNT_NAMESPACE_H_
