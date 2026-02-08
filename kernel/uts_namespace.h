#ifndef _UTS_NAMESPACE_H_
#define _UTS_NAMESPACE_H_

#define HOSTNAME_LEN 64

// UTS namespace structure (hostname, domainname, etc.)
struct uts_namespace {
  int refcnt;                      // Reference count
  char hostname[HOSTNAME_LEN];     // Hostname
  struct spinlock lock;            // Lock for synchronization
};

#endif // _UTS_NAMESPACE_H_
