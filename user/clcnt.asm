
user/_clcnt:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("System call count: %d\n", clcnt());
   8:	362000ef          	jal	36a <clcnt>
   c:	85aa                	mv	a1,a0
   e:	00001517          	auipc	a0,0x1
  12:	8e250513          	addi	a0,a0,-1822 # 8f0 <malloc+0xfa>
  16:	72c000ef          	jal	742 <printf>
  getpid();
  1a:	330000ef          	jal	34a <getpid>
  printf("System call count after getpid: %d\n", clcnt());
  1e:	34c000ef          	jal	36a <clcnt>
  22:	85aa                	mv	a1,a0
  24:	00001517          	auipc	a0,0x1
  28:	8e450513          	addi	a0,a0,-1820 # 908 <malloc+0x112>
  2c:	716000ef          	jal	742 <printf>
  exit(0);
  30:	4501                	li	a0,0
  32:	298000ef          	jal	2ca <exit>

0000000000000036 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  36:	1141                	addi	sp,sp,-16
  38:	e406                	sd	ra,8(sp)
  3a:	e022                	sd	s0,0(sp)
  3c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  3e:	fc3ff0ef          	jal	0 <main>
  exit(r);
  42:	288000ef          	jal	2ca <exit>

0000000000000046 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0x8>
    ;
  return os;
}
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x1e>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x1e>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x26>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	86be                	mv	a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	ff65                	bnez	a4,9e <strlen+0x10>
  a8:	40a6853b          	subw	a0,a3,a0
  ac:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfe5                	j	ae <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  be:	ca19                	beqz	a2,d4 <memset+0x1c>
  c0:	87aa                	mv	a5,a0
  c2:	1602                	slli	a2,a2,0x20
  c4:	9201                	srli	a2,a2,0x20
  c6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ce:	0785                	addi	a5,a5,1
  d0:	fee79de3          	bne	a5,a4,ca <memset+0x12>
  }
  return dst;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strchr>:

char*
strchr(const char *s, char c)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb99                	beqz	a5,fa <strchr+0x20>
    if(*s == c)
  e6:	00f58763          	beq	a1,a5,f4 <strchr+0x1a>
  for(; *s; s++)
  ea:	0505                	addi	a0,a0,1
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbfd                	bnez	a5,e6 <strchr+0xc>
      return (char*)s;
  return 0;
  f2:	4501                	li	a0,0
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  return 0;
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strchr+0x1a>

00000000000000fe <gets>:

char*
gets(char *buf, int max)
{
  fe:	711d                	addi	sp,sp,-96
 100:	ec86                	sd	ra,88(sp)
 102:	e8a2                	sd	s0,80(sp)
 104:	e4a6                	sd	s1,72(sp)
 106:	e0ca                	sd	s2,64(sp)
 108:	fc4e                	sd	s3,56(sp)
 10a:	f852                	sd	s4,48(sp)
 10c:	f456                	sd	s5,40(sp)
 10e:	f05a                	sd	s6,32(sp)
 110:	ec5e                	sd	s7,24(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11c:	4aa9                	li	s5,10
 11e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 120:	89a6                	mv	s3,s1
 122:	2485                	addiw	s1,s1,1
 124:	0344d663          	bge	s1,s4,150 <gets+0x52>
    cc = read(0, &c, 1);
 128:	4605                	li	a2,1
 12a:	faf40593          	addi	a1,s0,-81
 12e:	4501                	li	a0,0
 130:	1b2000ef          	jal	2e2 <read>
    if(cc < 1)
 134:	00a05e63          	blez	a0,150 <gets+0x52>
    buf[i++] = c;
 138:	faf44783          	lbu	a5,-81(s0)
 13c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 140:	01578763          	beq	a5,s5,14e <gets+0x50>
 144:	0905                	addi	s2,s2,1
 146:	fd679de3          	bne	a5,s6,120 <gets+0x22>
    buf[i++] = c;
 14a:	89a6                	mv	s3,s1
 14c:	a011                	j	150 <gets+0x52>
 14e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 150:	99de                	add	s3,s3,s7
 152:	00098023          	sb	zero,0(s3)
  return buf;
}
 156:	855e                	mv	a0,s7
 158:	60e6                	ld	ra,88(sp)
 15a:	6446                	ld	s0,80(sp)
 15c:	64a6                	ld	s1,72(sp)
 15e:	6906                	ld	s2,64(sp)
 160:	79e2                	ld	s3,56(sp)
 162:	7a42                	ld	s4,48(sp)
 164:	7aa2                	ld	s5,40(sp)
 166:	7b02                	ld	s6,32(sp)
 168:	6be2                	ld	s7,24(sp)
 16a:	6125                	addi	sp,sp,96
 16c:	8082                	ret

000000000000016e <stat>:

int
stat(const char *n, struct stat *st)
{
 16e:	1101                	addi	sp,sp,-32
 170:	ec06                	sd	ra,24(sp)
 172:	e822                	sd	s0,16(sp)
 174:	e04a                	sd	s2,0(sp)
 176:	1000                	addi	s0,sp,32
 178:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17a:	4581                	li	a1,0
 17c:	18e000ef          	jal	30a <open>
  if(fd < 0)
 180:	02054263          	bltz	a0,1a4 <stat+0x36>
 184:	e426                	sd	s1,8(sp)
 186:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 188:	85ca                	mv	a1,s2
 18a:	198000ef          	jal	322 <fstat>
 18e:	892a                	mv	s2,a0
  close(fd);
 190:	8526                	mv	a0,s1
 192:	160000ef          	jal	2f2 <close>
  return r;
 196:	64a2                	ld	s1,8(sp)
}
 198:	854a                	mv	a0,s2
 19a:	60e2                	ld	ra,24(sp)
 19c:	6442                	ld	s0,16(sp)
 19e:	6902                	ld	s2,0(sp)
 1a0:	6105                	addi	sp,sp,32
 1a2:	8082                	ret
    return -1;
 1a4:	597d                	li	s2,-1
 1a6:	bfcd                	j	198 <stat+0x2a>

00000000000001a8 <atoi>:

int
atoi(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ae:	00054683          	lbu	a3,0(a0)
 1b2:	fd06879b          	addiw	a5,a3,-48
 1b6:	0ff7f793          	zext.b	a5,a5
 1ba:	4625                	li	a2,9
 1bc:	02f66863          	bltu	a2,a5,1ec <atoi+0x44>
 1c0:	872a                	mv	a4,a0
  n = 0;
 1c2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c4:	0705                	addi	a4,a4,1
 1c6:	0025179b          	slliw	a5,a0,0x2
 1ca:	9fa9                	addw	a5,a5,a0
 1cc:	0017979b          	slliw	a5,a5,0x1
 1d0:	9fb5                	addw	a5,a5,a3
 1d2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d6:	00074683          	lbu	a3,0(a4)
 1da:	fd06879b          	addiw	a5,a3,-48
 1de:	0ff7f793          	zext.b	a5,a5
 1e2:	fef671e3          	bgeu	a2,a5,1c4 <atoi+0x1c>
  return n;
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  n = 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <atoi+0x3e>

00000000000001f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f6:	02b57463          	bgeu	a0,a1,21e <memmove+0x2e>
    while(n-- > 0)
 1fa:	00c05f63          	blez	a2,218 <memmove+0x28>
 1fe:	1602                	slli	a2,a2,0x20
 200:	9201                	srli	a2,a2,0x20
 202:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 206:	872a                	mv	a4,a0
      *dst++ = *src++;
 208:	0585                	addi	a1,a1,1
 20a:	0705                	addi	a4,a4,1
 20c:	fff5c683          	lbu	a3,-1(a1)
 210:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 214:	fef71ae3          	bne	a4,a5,208 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
    dst += n;
 21e:	00c50733          	add	a4,a0,a2
    src += n;
 222:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 224:	fec05ae3          	blez	a2,218 <memmove+0x28>
 228:	fff6079b          	addiw	a5,a2,-1
 22c:	1782                	slli	a5,a5,0x20
 22e:	9381                	srli	a5,a5,0x20
 230:	fff7c793          	not	a5,a5
 234:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 236:	15fd                	addi	a1,a1,-1
 238:	177d                	addi	a4,a4,-1
 23a:	0005c683          	lbu	a3,0(a1)
 23e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 242:	fee79ae3          	bne	a5,a4,236 <memmove+0x46>
 246:	bfc9                	j	218 <memmove+0x28>

0000000000000248 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24e:	ca05                	beqz	a2,27e <memcmp+0x36>
 250:	fff6069b          	addiw	a3,a2,-1
 254:	1682                	slli	a3,a3,0x20
 256:	9281                	srli	a3,a3,0x20
 258:	0685                	addi	a3,a3,1
 25a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25c:	00054783          	lbu	a5,0(a0)
 260:	0005c703          	lbu	a4,0(a1)
 264:	00e79863          	bne	a5,a4,274 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 268:	0505                	addi	a0,a0,1
    p2++;
 26a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26c:	fed518e3          	bne	a0,a3,25c <memcmp+0x14>
  }
  return 0;
 270:	4501                	li	a0,0
 272:	a019                	j	278 <memcmp+0x30>
      return *p1 - *p2;
 274:	40e7853b          	subw	a0,a5,a4
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret
  return 0;
 27e:	4501                	li	a0,0
 280:	bfe5                	j	278 <memcmp+0x30>

0000000000000282 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 282:	1141                	addi	sp,sp,-16
 284:	e406                	sd	ra,8(sp)
 286:	e022                	sd	s0,0(sp)
 288:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28a:	f67ff0ef          	jal	1f0 <memmove>
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret

0000000000000296 <sbrk>:

char *
sbrk(int n) {
 296:	1141                	addi	sp,sp,-16
 298:	e406                	sd	ra,8(sp)
 29a:	e022                	sd	s0,0(sp)
 29c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 29e:	4585                	li	a1,1
 2a0:	0b2000ef          	jal	352 <sys_sbrk>
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <sbrklazy>:

char *
sbrklazy(int n) {
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2b4:	4589                	li	a1,2
 2b6:	09c000ef          	jal	352 <sys_sbrk>
}
 2ba:	60a2                	ld	ra,8(sp)
 2bc:	6402                	ld	s0,0(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c2:	4885                	li	a7,1
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ca:	4889                	li	a7,2
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d2:	488d                	li	a7,3
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2da:	4891                	li	a7,4
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <read>:
.global read
read:
 li a7, SYS_read
 2e2:	4895                	li	a7,5
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <write>:
.global write
write:
 li a7, SYS_write
 2ea:	48c1                	li	a7,16
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <close>:
.global close
close:
 li a7, SYS_close
 2f2:	48d5                	li	a7,21
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fa:	4899                	li	a7,6
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <exec>:
.global exec
exec:
 li a7, SYS_exec
 302:	489d                	li	a7,7
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <open>:
.global open
open:
 li a7, SYS_open
 30a:	48bd                	li	a7,15
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 312:	48c5                	li	a7,17
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31a:	48c9                	li	a7,18
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 322:	48a1                	li	a7,8
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <link>:
.global link
link:
 li a7, SYS_link
 32a:	48cd                	li	a7,19
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 332:	48d1                	li	a7,20
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33a:	48a5                	li	a7,9
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <dup>:
.global dup
dup:
 li a7, SYS_dup
 342:	48a9                	li	a7,10
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34a:	48ad                	li	a7,11
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 352:	48b1                	li	a7,12
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <pause>:
.global pause
pause:
 li a7, SYS_pause
 35a:	48b5                	li	a7,13
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 362:	48b9                	li	a7,14
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 36a:	48d9                	li	a7,22
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 372:	48dd                	li	a7,23
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 37a:	48e1                	li	a7,24
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 382:	48e5                	li	a7,25
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 38a:	48e9                	li	a7,26
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 392:	48ed                	li	a7,27
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 39a:	48f1                	li	a7,28
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 3a2:	48f5                	li	a7,29
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 3aa:	48f9                	li	a7,30
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 3b2:	48fd                	li	a7,31
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ba:	1101                	addi	sp,sp,-32
 3bc:	ec06                	sd	ra,24(sp)
 3be:	e822                	sd	s0,16(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c6:	4605                	li	a2,1
 3c8:	fef40593          	addi	a1,s0,-17
 3cc:	f1fff0ef          	jal	2ea <write>
}
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6105                	addi	sp,sp,32
 3d6:	8082                	ret

00000000000003d8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d8:	715d                	addi	sp,sp,-80
 3da:	e486                	sd	ra,72(sp)
 3dc:	e0a2                	sd	s0,64(sp)
 3de:	f84a                	sd	s2,48(sp)
 3e0:	0880                	addi	s0,sp,80
 3e2:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e4:	c299                	beqz	a3,3ea <printint+0x12>
 3e6:	0805c363          	bltz	a1,46c <printint+0x94>
  neg = 0;
 3ea:	4881                	li	a7,0
 3ec:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3f0:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3f2:	00000517          	auipc	a0,0x0
 3f6:	54650513          	addi	a0,a0,1350 # 938 <digits>
 3fa:	883e                	mv	a6,a5
 3fc:	2785                	addiw	a5,a5,1
 3fe:	02c5f733          	remu	a4,a1,a2
 402:	972a                	add	a4,a4,a0
 404:	00074703          	lbu	a4,0(a4)
 408:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 40c:	872e                	mv	a4,a1
 40e:	02c5d5b3          	divu	a1,a1,a2
 412:	0685                	addi	a3,a3,1
 414:	fec773e3          	bgeu	a4,a2,3fa <printint+0x22>
  if(neg)
 418:	00088b63          	beqz	a7,42e <printint+0x56>
    buf[i++] = '-';
 41c:	fd078793          	addi	a5,a5,-48
 420:	97a2                	add	a5,a5,s0
 422:	02d00713          	li	a4,45
 426:	fee78423          	sb	a4,-24(a5)
 42a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42e:	02f05a63          	blez	a5,462 <printint+0x8a>
 432:	fc26                	sd	s1,56(sp)
 434:	f44e                	sd	s3,40(sp)
 436:	fb840713          	addi	a4,s0,-72
 43a:	00f704b3          	add	s1,a4,a5
 43e:	fff70993          	addi	s3,a4,-1
 442:	99be                	add	s3,s3,a5
 444:	37fd                	addiw	a5,a5,-1
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 44e:	fff4c583          	lbu	a1,-1(s1)
 452:	854a                	mv	a0,s2
 454:	f67ff0ef          	jal	3ba <putc>
  while(--i >= 0)
 458:	14fd                	addi	s1,s1,-1
 45a:	ff349ae3          	bne	s1,s3,44e <printint+0x76>
 45e:	74e2                	ld	s1,56(sp)
 460:	79a2                	ld	s3,40(sp)
}
 462:	60a6                	ld	ra,72(sp)
 464:	6406                	ld	s0,64(sp)
 466:	7942                	ld	s2,48(sp)
 468:	6161                	addi	sp,sp,80
 46a:	8082                	ret
    x = -xx;
 46c:	40b005b3          	neg	a1,a1
    neg = 1;
 470:	4885                	li	a7,1
    x = -xx;
 472:	bfad                	j	3ec <printint+0x14>

0000000000000474 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 474:	711d                	addi	sp,sp,-96
 476:	ec86                	sd	ra,88(sp)
 478:	e8a2                	sd	s0,80(sp)
 47a:	e0ca                	sd	s2,64(sp)
 47c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47e:	0005c903          	lbu	s2,0(a1)
 482:	28090663          	beqz	s2,70e <vprintf+0x29a>
 486:	e4a6                	sd	s1,72(sp)
 488:	fc4e                	sd	s3,56(sp)
 48a:	f852                	sd	s4,48(sp)
 48c:	f456                	sd	s5,40(sp)
 48e:	f05a                	sd	s6,32(sp)
 490:	ec5e                	sd	s7,24(sp)
 492:	e862                	sd	s8,16(sp)
 494:	e466                	sd	s9,8(sp)
 496:	8b2a                	mv	s6,a0
 498:	8a2e                	mv	s4,a1
 49a:	8bb2                	mv	s7,a2
  state = 0;
 49c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49e:	4481                	li	s1,0
 4a0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4a2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4aa:	06c00c93          	li	s9,108
 4ae:	a005                	j	4ce <vprintf+0x5a>
        putc(fd, c0);
 4b0:	85ca                	mv	a1,s2
 4b2:	855a                	mv	a0,s6
 4b4:	f07ff0ef          	jal	3ba <putc>
 4b8:	a019                	j	4be <vprintf+0x4a>
    } else if(state == '%'){
 4ba:	03598263          	beq	s3,s5,4de <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4be:	2485                	addiw	s1,s1,1
 4c0:	8726                	mv	a4,s1
 4c2:	009a07b3          	add	a5,s4,s1
 4c6:	0007c903          	lbu	s2,0(a5)
 4ca:	22090a63          	beqz	s2,6fe <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ce:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4d2:	fe0994e3          	bnez	s3,4ba <vprintf+0x46>
      if(c0 == '%'){
 4d6:	fd579de3          	bne	a5,s5,4b0 <vprintf+0x3c>
        state = '%';
 4da:	89be                	mv	s3,a5
 4dc:	b7cd                	j	4be <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4de:	00ea06b3          	add	a3,s4,a4
 4e2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4e6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4e8:	c681                	beqz	a3,4f0 <vprintf+0x7c>
 4ea:	9752                	add	a4,a4,s4
 4ec:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4f0:	05878363          	beq	a5,s8,536 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4f4:	05978d63          	beq	a5,s9,54e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f8:	07500713          	li	a4,117
 4fc:	0ee78763          	beq	a5,a4,5ea <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 500:	07800713          	li	a4,120
 504:	12e78963          	beq	a5,a4,636 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 508:	07000713          	li	a4,112
 50c:	14e78e63          	beq	a5,a4,668 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 510:	06300713          	li	a4,99
 514:	18e78e63          	beq	a5,a4,6b0 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 518:	07300713          	li	a4,115
 51c:	1ae78463          	beq	a5,a4,6c4 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 520:	02500713          	li	a4,37
 524:	04e79563          	bne	a5,a4,56e <vprintf+0xfa>
        putc(fd, '%');
 528:	02500593          	li	a1,37
 52c:	855a                	mv	a0,s6
 52e:	e8dff0ef          	jal	3ba <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 532:	4981                	li	s3,0
 534:	b769                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 536:	008b8913          	addi	s2,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000ba583          	lw	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	e95ff0ef          	jal	3d8 <printint>
 548:	8bca                	mv	s7,s2
      state = 0;
 54a:	4981                	li	s3,0
 54c:	bf8d                	j	4be <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 54e:	06400793          	li	a5,100
 552:	02f68963          	beq	a3,a5,584 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 556:	06c00793          	li	a5,108
 55a:	04f68263          	beq	a3,a5,59e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 55e:	07500793          	li	a5,117
 562:	0af68063          	beq	a3,a5,602 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 566:	07800793          	li	a5,120
 56a:	0ef68263          	beq	a3,a5,64e <vprintf+0x1da>
        putc(fd, '%');
 56e:	02500593          	li	a1,37
 572:	855a                	mv	a0,s6
 574:	e47ff0ef          	jal	3ba <putc>
        putc(fd, c0);
 578:	85ca                	mv	a1,s2
 57a:	855a                	mv	a0,s6
 57c:	e3fff0ef          	jal	3ba <putc>
      state = 0;
 580:	4981                	li	s3,0
 582:	bf35                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	008b8913          	addi	s2,s7,8
 588:	4685                	li	a3,1
 58a:	4629                	li	a2,10
 58c:	000bb583          	ld	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e47ff0ef          	jal	3d8 <printint>
        i += 1;
 596:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 598:	8bca                	mv	s7,s2
      state = 0;
 59a:	4981                	li	s3,0
        i += 1;
 59c:	b70d                	j	4be <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 59e:	06400793          	li	a5,100
 5a2:	02f60763          	beq	a2,a5,5d0 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a6:	07500793          	li	a5,117
 5aa:	06f60963          	beq	a2,a5,61c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ae:	07800793          	li	a5,120
 5b2:	faf61ee3          	bne	a2,a5,56e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4641                	li	a2,16
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e15ff0ef          	jal	3d8 <printint>
        i += 2;
 5c8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ca:	8bca                	mv	s7,s2
      state = 0;
 5cc:	4981                	li	s3,0
        i += 2;
 5ce:	bdc5                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d0:	008b8913          	addi	s2,s7,8
 5d4:	4685                	li	a3,1
 5d6:	4629                	li	a2,10
 5d8:	000bb583          	ld	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	dfbff0ef          	jal	3d8 <printint>
        i += 2;
 5e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e4:	8bca                	mv	s7,s2
      state = 0;
 5e6:	4981                	li	s3,0
        i += 2;
 5e8:	bdd9                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4681                	li	a3,0
 5f0:	4629                	li	a2,10
 5f2:	000be583          	lwu	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	de1ff0ef          	jal	3d8 <printint>
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bd7d                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 602:	008b8913          	addi	s2,s7,8
 606:	4681                	li	a3,0
 608:	4629                	li	a2,10
 60a:	000bb583          	ld	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	dc9ff0ef          	jal	3d8 <printint>
        i += 1;
 614:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 616:	8bca                	mv	s7,s2
      state = 0;
 618:	4981                	li	s3,0
        i += 1;
 61a:	b555                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61c:	008b8913          	addi	s2,s7,8
 620:	4681                	li	a3,0
 622:	4629                	li	a2,10
 624:	000bb583          	ld	a1,0(s7)
 628:	855a                	mv	a0,s6
 62a:	dafff0ef          	jal	3d8 <printint>
        i += 2;
 62e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 630:	8bca                	mv	s7,s2
      state = 0;
 632:	4981                	li	s3,0
        i += 2;
 634:	b569                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 636:	008b8913          	addi	s2,s7,8
 63a:	4681                	li	a3,0
 63c:	4641                	li	a2,16
 63e:	000be583          	lwu	a1,0(s7)
 642:	855a                	mv	a0,s6
 644:	d95ff0ef          	jal	3d8 <printint>
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bd8d                	j	4be <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64e:	008b8913          	addi	s2,s7,8
 652:	4681                	li	a3,0
 654:	4641                	li	a2,16
 656:	000bb583          	ld	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	d7dff0ef          	jal	3d8 <printint>
        i += 1;
 660:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 662:	8bca                	mv	s7,s2
      state = 0;
 664:	4981                	li	s3,0
        i += 1;
 666:	bda1                	j	4be <vprintf+0x4a>
 668:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 66a:	008b8d13          	addi	s10,s7,8
 66e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 672:	03000593          	li	a1,48
 676:	855a                	mv	a0,s6
 678:	d43ff0ef          	jal	3ba <putc>
  putc(fd, 'x');
 67c:	07800593          	li	a1,120
 680:	855a                	mv	a0,s6
 682:	d39ff0ef          	jal	3ba <putc>
 686:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 688:	00000b97          	auipc	s7,0x0
 68c:	2b0b8b93          	addi	s7,s7,688 # 938 <digits>
 690:	03c9d793          	srli	a5,s3,0x3c
 694:	97de                	add	a5,a5,s7
 696:	0007c583          	lbu	a1,0(a5)
 69a:	855a                	mv	a0,s6
 69c:	d1fff0ef          	jal	3ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a0:	0992                	slli	s3,s3,0x4
 6a2:	397d                	addiw	s2,s2,-1
 6a4:	fe0916e3          	bnez	s2,690 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6a8:	8bea                	mv	s7,s10
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	6d02                	ld	s10,0(sp)
 6ae:	bd01                	j	4be <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	000bc583          	lbu	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	d01ff0ef          	jal	3ba <putc>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bbf5                	j	4be <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6c4:	008b8993          	addi	s3,s7,8
 6c8:	000bb903          	ld	s2,0(s7)
 6cc:	00090f63          	beqz	s2,6ea <vprintf+0x276>
        for(; *s; s++)
 6d0:	00094583          	lbu	a1,0(s2)
 6d4:	c195                	beqz	a1,6f8 <vprintf+0x284>
          putc(fd, *s);
 6d6:	855a                	mv	a0,s6
 6d8:	ce3ff0ef          	jal	3ba <putc>
        for(; *s; s++)
 6dc:	0905                	addi	s2,s2,1
 6de:	00094583          	lbu	a1,0(s2)
 6e2:	f9f5                	bnez	a1,6d6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6e4:	8bce                	mv	s7,s3
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bbd9                	j	4be <vprintf+0x4a>
          s = "(null)";
 6ea:	00000917          	auipc	s2,0x0
 6ee:	24690913          	addi	s2,s2,582 # 930 <malloc+0x13a>
        for(; *s; s++)
 6f2:	02800593          	li	a1,40
 6f6:	b7c5                	j	6d6 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6f8:	8bce                	mv	s7,s3
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b3c9                	j	4be <vprintf+0x4a>
 6fe:	64a6                	ld	s1,72(sp)
 700:	79e2                	ld	s3,56(sp)
 702:	7a42                	ld	s4,48(sp)
 704:	7aa2                	ld	s5,40(sp)
 706:	7b02                	ld	s6,32(sp)
 708:	6be2                	ld	s7,24(sp)
 70a:	6c42                	ld	s8,16(sp)
 70c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 70e:	60e6                	ld	ra,88(sp)
 710:	6446                	ld	s0,80(sp)
 712:	6906                	ld	s2,64(sp)
 714:	6125                	addi	sp,sp,96
 716:	8082                	ret

0000000000000718 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 718:	715d                	addi	sp,sp,-80
 71a:	ec06                	sd	ra,24(sp)
 71c:	e822                	sd	s0,16(sp)
 71e:	1000                	addi	s0,sp,32
 720:	e010                	sd	a2,0(s0)
 722:	e414                	sd	a3,8(s0)
 724:	e818                	sd	a4,16(s0)
 726:	ec1c                	sd	a5,24(s0)
 728:	03043023          	sd	a6,32(s0)
 72c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 734:	8622                	mv	a2,s0
 736:	d3fff0ef          	jal	474 <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6161                	addi	sp,sp,80
 740:	8082                	ret

0000000000000742 <printf>:

void
printf(const char *fmt, ...)
{
 742:	711d                	addi	sp,sp,-96
 744:	ec06                	sd	ra,24(sp)
 746:	e822                	sd	s0,16(sp)
 748:	1000                	addi	s0,sp,32
 74a:	e40c                	sd	a1,8(s0)
 74c:	e810                	sd	a2,16(s0)
 74e:	ec14                	sd	a3,24(s0)
 750:	f018                	sd	a4,32(s0)
 752:	f41c                	sd	a5,40(s0)
 754:	03043823          	sd	a6,48(s0)
 758:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75c:	00840613          	addi	a2,s0,8
 760:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 764:	85aa                	mv	a1,a0
 766:	4505                	li	a0,1
 768:	d0dff0ef          	jal	474 <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	1141                	addi	sp,sp,-16
 776:	e422                	sd	s0,8(sp)
 778:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	00001797          	auipc	a5,0x1
 782:	8827b783          	ld	a5,-1918(a5) # 1000 <freep>
 786:	a02d                	j	7b0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 788:	4618                	lw	a4,8(a2)
 78a:	9f2d                	addw	a4,a4,a1
 78c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	6310                	ld	a2,0(a4)
 794:	a83d                	j	7d2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 796:	ff852703          	lw	a4,-8(a0)
 79a:	9f31                	addw	a4,a4,a2
 79c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79e:	ff053683          	ld	a3,-16(a0)
 7a2:	a091                	j	7e6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a4:	6398                	ld	a4,0(a5)
 7a6:	00e7e463          	bltu	a5,a4,7ae <free+0x3a>
 7aa:	00e6ea63          	bltu	a3,a4,7be <free+0x4a>
{
 7ae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b0:	fed7fae3          	bgeu	a5,a3,7a4 <free+0x30>
 7b4:	6398                	ld	a4,0(a5)
 7b6:	00e6e463          	bltu	a3,a4,7be <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ba:	fee7eae3          	bltu	a5,a4,7ae <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7be:	ff852583          	lw	a1,-8(a0)
 7c2:	6390                	ld	a2,0(a5)
 7c4:	02059813          	slli	a6,a1,0x20
 7c8:	01c85713          	srli	a4,a6,0x1c
 7cc:	9736                	add	a4,a4,a3
 7ce:	fae60de3          	beq	a2,a4,788 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d6:	4790                	lw	a2,8(a5)
 7d8:	02061593          	slli	a1,a2,0x20
 7dc:	01c5d713          	srli	a4,a1,0x1c
 7e0:	973e                	add	a4,a4,a5
 7e2:	fae68ae3          	beq	a3,a4,796 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e8:	00001717          	auipc	a4,0x1
 7ec:	80f73c23          	sd	a5,-2024(a4) # 1000 <freep>
}
 7f0:	6422                	ld	s0,8(sp)
 7f2:	0141                	addi	sp,sp,16
 7f4:	8082                	ret

00000000000007f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f6:	7139                	addi	sp,sp,-64
 7f8:	fc06                	sd	ra,56(sp)
 7fa:	f822                	sd	s0,48(sp)
 7fc:	f426                	sd	s1,40(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 802:	02051493          	slli	s1,a0,0x20
 806:	9081                	srli	s1,s1,0x20
 808:	04bd                	addi	s1,s1,15
 80a:	8091                	srli	s1,s1,0x4
 80c:	0014899b          	addiw	s3,s1,1
 810:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 812:	00000517          	auipc	a0,0x0
 816:	7ee53503          	ld	a0,2030(a0) # 1000 <freep>
 81a:	c915                	beqz	a0,84e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81e:	4798                	lw	a4,8(a5)
 820:	08977a63          	bgeu	a4,s1,8b4 <malloc+0xbe>
 824:	f04a                	sd	s2,32(sp)
 826:	e852                	sd	s4,16(sp)
 828:	e456                	sd	s5,8(sp)
 82a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 82c:	8a4e                	mv	s4,s3
 82e:	0009871b          	sext.w	a4,s3
 832:	6685                	lui	a3,0x1
 834:	00d77363          	bgeu	a4,a3,83a <malloc+0x44>
 838:	6a05                	lui	s4,0x1
 83a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 842:	00000917          	auipc	s2,0x0
 846:	7be90913          	addi	s2,s2,1982 # 1000 <freep>
  if(p == SBRK_ERROR)
 84a:	5afd                	li	s5,-1
 84c:	a081                	j	88c <malloc+0x96>
 84e:	f04a                	sd	s2,32(sp)
 850:	e852                	sd	s4,16(sp)
 852:	e456                	sd	s5,8(sp)
 854:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 856:	00000797          	auipc	a5,0x0
 85a:	7ba78793          	addi	a5,a5,1978 # 1010 <base>
 85e:	00000717          	auipc	a4,0x0
 862:	7af73123          	sd	a5,1954(a4) # 1000 <freep>
 866:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 868:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86c:	b7c1                	j	82c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 86e:	6398                	ld	a4,0(a5)
 870:	e118                	sd	a4,0(a0)
 872:	a8a9                	j	8cc <malloc+0xd6>
  hp->s.size = nu;
 874:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 878:	0541                	addi	a0,a0,16
 87a:	efbff0ef          	jal	774 <free>
  return freep;
 87e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 882:	c12d                	beqz	a0,8e4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 884:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 886:	4798                	lw	a4,8(a5)
 888:	02977263          	bgeu	a4,s1,8ac <malloc+0xb6>
    if(p == freep)
 88c:	00093703          	ld	a4,0(s2)
 890:	853e                	mv	a0,a5
 892:	fef719e3          	bne	a4,a5,884 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 896:	8552                	mv	a0,s4
 898:	9ffff0ef          	jal	296 <sbrk>
  if(p == SBRK_ERROR)
 89c:	fd551ce3          	bne	a0,s5,874 <malloc+0x7e>
        return 0;
 8a0:	4501                	li	a0,0
 8a2:	7902                	ld	s2,32(sp)
 8a4:	6a42                	ld	s4,16(sp)
 8a6:	6aa2                	ld	s5,8(sp)
 8a8:	6b02                	ld	s6,0(sp)
 8aa:	a03d                	j	8d8 <malloc+0xe2>
 8ac:	7902                	ld	s2,32(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b4:	fae48de3          	beq	s1,a4,86e <malloc+0x78>
        p->s.size -= nunits;
 8b8:	4137073b          	subw	a4,a4,s3
 8bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8be:	02071693          	slli	a3,a4,0x20
 8c2:	01c6d713          	srli	a4,a3,0x1c
 8c6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72a73a23          	sd	a0,1844(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d4:	01078513          	addi	a0,a5,16
  }
}
 8d8:	70e2                	ld	ra,56(sp)
 8da:	7442                	ld	s0,48(sp)
 8dc:	74a2                	ld	s1,40(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6121                	addi	sp,sp,64
 8e2:	8082                	ret
 8e4:	7902                	ld	s2,32(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
 8ec:	b7f5                	j	8d8 <malloc+0xe2>
