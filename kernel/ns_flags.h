#ifndef _NS_FLAGS_H_
#define _NS_FLAGS_H_

// Namespace flags for unshare()
#define CLONE_NEWPID       0x20000000  // PID namespace
#define CLONE_NEWUTS       0x04000000  // UTS namespace
#define CLONE_NEWIPC       0x08000000  // IPC namespace
#define CLONE_NEWNS        0x00020000  // Mount namespace
#define CLONE_NEWNET       0x40000000  // Network namespace (not implemented)

#endif // _NS_FLAGS_H_
