#include "kernel/types.h"
#include "user/user.h"
#include "swap.h"          
#include "kernel/riscv.h"  
#include "kernel/fcntl.h"

static void
append_char(char *s, int *idx, int max, char c)
{
  if(*idx < max-1) s[(*idx)++] = c;
}

static void
append_int(char *s, int *idx, int max, int x)
{
  char buf[16];
  int n = 0;
  if(x == 0){
    append_char(s, idx, max, '0');
    return;
  }
  while(x > 0 && n < (int)sizeof(buf)){
    buf[n++] = '0' + (x % 10);
    x /= 10;
  }
  while(n > 0){
    append_char(s, idx, max, buf[--n]);
  }
}

static void
format_swap_filename(char *out, int outsz, int pid, uint64 va)
{
  int l0 = (va >> 12) & 0x1FF;
  int l1 = (va >> 21) & 0x1FF;
  int l2 = (va >> 30) & 0x1FF;

  int i = 0;
  append_int(out, &i, outsz, pid);
  append_char(out, &i, outsz, '_');
  append_char(out, &i, outsz, '[');
  append_int(out, &i, outsz, l2);
  append_char(out, &i, outsz, ',');
  append_int(out, &i, outsz, l1);
  append_char(out, &i, outsz, ',');
  append_int(out, &i, outsz, l0);
  append_char(out, &i, outsz, ']');
  append_char(out, &i, outsz, '.');
  append_char(out, &i, outsz, 's');
  append_char(out, &i, outsz, 'w');
  append_char(out, &i, outsz, 'p');

  out[i] = 0;
}

int
main(void)
{
  struct swap_task t;
  static char page[4096];
  char fname[64];

  for(;;){
    if(swap_fetch(&t, page) < 0){
      // if this fails just loop, kernel might not be ready yet
      continue;
    }

    if(t.op == SWAP_OP_WRITE){
      format_swap_filename(fname, sizeof(fname), t.pid, t.va);

      int fd = open(fname, O_CREATE | O_WRONLY);
      if(fd < 0){
        swap_complete(-1);
        continue;
      }

      int n = write(fd, page, 4096);
      close(fd);

      if(n != 4096){
        swap_complete(-1);
      } else {
        swap_complete(0);
      }
    } else {
      swap_complete(-1);
    }
  }
}
