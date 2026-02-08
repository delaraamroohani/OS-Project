#ifndef _IPC_NAMESPACE_H_
#define _IPC_NAMESPACE_H_

// IPC namespace structure
// In xv6, only pipes are used for IPC
struct ipc_namespace {
  int refcnt;               // Reference count
  struct spinlock lock;     // Lock for synchronization
};

#endif // _IPC_NAMESPACE_H_
