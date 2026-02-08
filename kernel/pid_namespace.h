#ifndef _PID_NAMESPACE_H_
#define _PID_NAMESPACE_H_

// PID namespace structure
struct pid_namespace {
  int refcount;           // Reference count
  int next_pid;           // Next PID to assign
  struct spinlock lock;   // Lock for PID allocation
};

#endif // _PID_NAMESPACE_H_
