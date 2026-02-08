
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  if(argc != 3){
   8:	478d                	li	a5,3
   a:	00f50d63          	beq	a0,a5,24 <main+0x24>
   e:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	90058593          	addi	a1,a1,-1792 # 910 <malloc+0x102>
  18:	4509                	li	a0,2
  1a:	716000ef          	jal	730 <fprintf>
    exit(1);
  1e:	4505                	li	a0,1
  20:	2c2000ef          	jal	2e2 <exit>
  24:	e426                	sd	s1,8(sp)
  26:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  28:	698c                	ld	a1,16(a1)
  2a:	6488                	ld	a0,8(s1)
  2c:	316000ef          	jal	342 <link>
  30:	00054563          	bltz	a0,3a <main+0x3a>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  34:	4501                	li	a0,0
  36:	2ac000ef          	jal	2e2 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  3a:	6894                	ld	a3,16(s1)
  3c:	6490                	ld	a2,8(s1)
  3e:	00001597          	auipc	a1,0x1
  42:	8ea58593          	addi	a1,a1,-1814 # 928 <malloc+0x11a>
  46:	4509                	li	a0,2
  48:	6e8000ef          	jal	730 <fprintf>
  4c:	b7e5                	j	34 <main+0x34>

000000000000004e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e406                	sd	ra,8(sp)
  52:	e022                	sd	s0,0(sp)
  54:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  56:	fabff0ef          	jal	0 <main>
  exit(r);
  5a:	288000ef          	jal	2e2 <exit>

000000000000005e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  64:	87aa                	mv	a5,a0
  66:	0585                	addi	a1,a1,1
  68:	0785                	addi	a5,a5,1
  6a:	fff5c703          	lbu	a4,-1(a1)
  6e:	fee78fa3          	sb	a4,-1(a5)
  72:	fb75                	bnez	a4,66 <strcpy+0x8>
    ;
  return os;
}
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	cb91                	beqz	a5,98 <strcmp+0x1e>
  86:	0005c703          	lbu	a4,0(a1)
  8a:	00f71763          	bne	a4,a5,98 <strcmp+0x1e>
    p++, q++;
  8e:	0505                	addi	a0,a0,1
  90:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	fbe5                	bnez	a5,86 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  98:	0005c503          	lbu	a0,0(a1)
}
  9c:	40a7853b          	subw	a0,a5,a0
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strlen>:

uint
strlen(const char *s)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cf91                	beqz	a5,cc <strlen+0x26>
  b2:	0505                	addi	a0,a0,1
  b4:	87aa                	mv	a5,a0
  b6:	86be                	mv	a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	ff65                	bnez	a4,b6 <strlen+0x10>
  c0:	40a6853b          	subw	a0,a3,a0
  c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret
  for(n = 0; s[n]; n++)
  cc:	4501                	li	a0,0
  ce:	bfe5                	j	c6 <strlen+0x20>

00000000000000d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d6:	ca19                	beqz	a2,ec <memset+0x1c>
  d8:	87aa                	mv	a5,a0
  da:	1602                	slli	a2,a2,0x20
  dc:	9201                	srli	a2,a2,0x20
  de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x12>
  }
  return dst;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strchr>:

char*
strchr(const char *s, char c)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb99                	beqz	a5,112 <strchr+0x20>
    if(*s == c)
  fe:	00f58763          	beq	a1,a5,10c <strchr+0x1a>
  for(; *s; s++)
 102:	0505                	addi	a0,a0,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbfd                	bnez	a5,fe <strchr+0xc>
      return (char*)s;
  return 0;
 10a:	4501                	li	a0,0
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  return 0;
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strchr+0x1a>

0000000000000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	711d                	addi	sp,sp,-96
 118:	ec86                	sd	ra,88(sp)
 11a:	e8a2                	sd	s0,80(sp)
 11c:	e4a6                	sd	s1,72(sp)
 11e:	e0ca                	sd	s2,64(sp)
 120:	fc4e                	sd	s3,56(sp)
 122:	f852                	sd	s4,48(sp)
 124:	f456                	sd	s5,40(sp)
 126:	f05a                	sd	s6,32(sp)
 128:	ec5e                	sd	s7,24(sp)
 12a:	1080                	addi	s0,sp,96
 12c:	8baa                	mv	s7,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 134:	4aa9                	li	s5,10
 136:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	2485                	addiw	s1,s1,1
 13c:	0344d663          	bge	s1,s4,168 <gets+0x52>
    cc = read(0, &c, 1);
 140:	4605                	li	a2,1
 142:	faf40593          	addi	a1,s0,-81
 146:	4501                	li	a0,0
 148:	1b2000ef          	jal	2fa <read>
    if(cc < 1)
 14c:	00a05e63          	blez	a0,168 <gets+0x52>
    buf[i++] = c;
 150:	faf44783          	lbu	a5,-81(s0)
 154:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 158:	01578763          	beq	a5,s5,166 <gets+0x50>
 15c:	0905                	addi	s2,s2,1
 15e:	fd679de3          	bne	a5,s6,138 <gets+0x22>
    buf[i++] = c;
 162:	89a6                	mv	s3,s1
 164:	a011                	j	168 <gets+0x52>
 166:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 168:	99de                	add	s3,s3,s7
 16a:	00098023          	sb	zero,0(s3)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6125                	addi	sp,sp,96
 184:	8082                	ret

0000000000000186 <stat>:

int
stat(const char *n, struct stat *st)
{
 186:	1101                	addi	sp,sp,-32
 188:	ec06                	sd	ra,24(sp)
 18a:	e822                	sd	s0,16(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	18e000ef          	jal	322 <open>
  if(fd < 0)
 198:	02054263          	bltz	a0,1bc <stat+0x36>
 19c:	e426                	sd	s1,8(sp)
 19e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a0:	85ca                	mv	a1,s2
 1a2:	198000ef          	jal	33a <fstat>
 1a6:	892a                	mv	s2,a0
  close(fd);
 1a8:	8526                	mv	a0,s1
 1aa:	160000ef          	jal	30a <close>
  return r;
 1ae:	64a2                	ld	s1,8(sp)
}
 1b0:	854a                	mv	a0,s2
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	6902                	ld	s2,0(sp)
 1b8:	6105                	addi	sp,sp,32
 1ba:	8082                	ret
    return -1;
 1bc:	597d                	li	s2,-1
 1be:	bfcd                	j	1b0 <stat+0x2a>

00000000000001c0 <atoi>:

int
atoi(const char *s)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c6:	00054683          	lbu	a3,0(a0)
 1ca:	fd06879b          	addiw	a5,a3,-48
 1ce:	0ff7f793          	zext.b	a5,a5
 1d2:	4625                	li	a2,9
 1d4:	02f66863          	bltu	a2,a5,204 <atoi+0x44>
 1d8:	872a                	mv	a4,a0
  n = 0;
 1da:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1dc:	0705                	addi	a4,a4,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb5                	addw	a5,a5,a3
 1ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ee:	00074683          	lbu	a3,0(a4)
 1f2:	fd06879b          	addiw	a5,a3,-48
 1f6:	0ff7f793          	zext.b	a5,a5
 1fa:	fef671e3          	bgeu	a2,a5,1dc <atoi+0x1c>
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <atoi+0x3e>

0000000000000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20e:	02b57463          	bgeu	a0,a1,236 <memmove+0x2e>
    while(n-- > 0)
 212:	00c05f63          	blez	a2,230 <memmove+0x28>
 216:	1602                	slli	a2,a2,0x20
 218:	9201                	srli	a2,a2,0x20
 21a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 21e:	872a                	mv	a4,a0
      *dst++ = *src++;
 220:	0585                	addi	a1,a1,1
 222:	0705                	addi	a4,a4,1
 224:	fff5c683          	lbu	a3,-1(a1)
 228:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22c:	fef71ae3          	bne	a4,a5,220 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
    dst += n;
 236:	00c50733          	add	a4,a0,a2
    src += n;
 23a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23c:	fec05ae3          	blez	a2,230 <memmove+0x28>
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	fff7c793          	not	a5,a5
 24c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24e:	15fd                	addi	a1,a1,-1
 250:	177d                	addi	a4,a4,-1
 252:	0005c683          	lbu	a3,0(a1)
 256:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x46>
 25e:	bfc9                	j	230 <memmove+0x28>

0000000000000260 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 266:	ca05                	beqz	a2,296 <memcmp+0x36>
 268:	fff6069b          	addiw	a3,a2,-1
 26c:	1682                	slli	a3,a3,0x20
 26e:	9281                	srli	a3,a3,0x20
 270:	0685                	addi	a3,a3,1
 272:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 274:	00054783          	lbu	a5,0(a0)
 278:	0005c703          	lbu	a4,0(a1)
 27c:	00e79863          	bne	a5,a4,28c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 280:	0505                	addi	a0,a0,1
    p2++;
 282:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 284:	fed518e3          	bne	a0,a3,274 <memcmp+0x14>
  }
  return 0;
 288:	4501                	li	a0,0
 28a:	a019                	j	290 <memcmp+0x30>
      return *p1 - *p2;
 28c:	40e7853b          	subw	a0,a5,a4
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
  return 0;
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <memcmp+0x30>

000000000000029a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a2:	f67ff0ef          	jal	208 <memmove>
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <sbrk>:

char *
sbrk(int n) {
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2b6:	4585                	li	a1,1
 2b8:	0b2000ef          	jal	36a <sys_sbrk>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <sbrklazy>:

char *
sbrklazy(int n) {
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2cc:	4589                	li	a1,2
 2ce:	09c000ef          	jal	36a <sys_sbrk>
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret

00000000000002da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2da:	4885                	li	a7,1
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e2:	4889                	li	a7,2
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ea:	488d                	li	a7,3
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f2:	4891                	li	a7,4
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <read>:
.global read
read:
 li a7, SYS_read
 2fa:	4895                	li	a7,5
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <write>:
.global write
write:
 li a7, SYS_write
 302:	48c1                	li	a7,16
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <close>:
.global close
close:
 li a7, SYS_close
 30a:	48d5                	li	a7,21
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <kill>:
.global kill
kill:
 li a7, SYS_kill
 312:	4899                	li	a7,6
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exec>:
.global exec
exec:
 li a7, SYS_exec
 31a:	489d                	li	a7,7
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <open>:
.global open
open:
 li a7, SYS_open
 322:	48bd                	li	a7,15
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32a:	48c5                	li	a7,17
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 332:	48c9                	li	a7,18
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33a:	48a1                	li	a7,8
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <link>:
.global link
link:
 li a7, SYS_link
 342:	48cd                	li	a7,19
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34a:	48d1                	li	a7,20
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 352:	48a5                	li	a7,9
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <dup>:
.global dup
dup:
 li a7, SYS_dup
 35a:	48a9                	li	a7,10
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 362:	48ad                	li	a7,11
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36a:	48b1                	li	a7,12
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <pause>:
.global pause
pause:
 li a7, SYS_pause
 372:	48b5                	li	a7,13
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37a:	48b9                	li	a7,14
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 382:	48d9                	li	a7,22
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 38a:	48dd                	li	a7,23
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 39a:	48e5                	li	a7,25
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 3a2:	48e9                	li	a7,26
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 3aa:	48ed                	li	a7,27
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 3b2:	48f1                	li	a7,28
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 3ba:	48f5                	li	a7,29
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 3c2:	48f9                	li	a7,30
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 3ca:	48fd                	li	a7,31
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d2:	1101                	addi	sp,sp,-32
 3d4:	ec06                	sd	ra,24(sp)
 3d6:	e822                	sd	s0,16(sp)
 3d8:	1000                	addi	s0,sp,32
 3da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3de:	4605                	li	a2,1
 3e0:	fef40593          	addi	a1,s0,-17
 3e4:	f1fff0ef          	jal	302 <write>
}
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6105                	addi	sp,sp,32
 3ee:	8082                	ret

00000000000003f0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3f0:	715d                	addi	sp,sp,-80
 3f2:	e486                	sd	ra,72(sp)
 3f4:	e0a2                	sd	s0,64(sp)
 3f6:	f84a                	sd	s2,48(sp)
 3f8:	0880                	addi	s0,sp,80
 3fa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3fc:	c299                	beqz	a3,402 <printint+0x12>
 3fe:	0805c363          	bltz	a1,484 <printint+0x94>
  neg = 0;
 402:	4881                	li	a7,0
 404:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 408:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 40a:	00000517          	auipc	a0,0x0
 40e:	53e50513          	addi	a0,a0,1342 # 948 <digits>
 412:	883e                	mv	a6,a5
 414:	2785                	addiw	a5,a5,1
 416:	02c5f733          	remu	a4,a1,a2
 41a:	972a                	add	a4,a4,a0
 41c:	00074703          	lbu	a4,0(a4)
 420:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 424:	872e                	mv	a4,a1
 426:	02c5d5b3          	divu	a1,a1,a2
 42a:	0685                	addi	a3,a3,1
 42c:	fec773e3          	bgeu	a4,a2,412 <printint+0x22>
  if(neg)
 430:	00088b63          	beqz	a7,446 <printint+0x56>
    buf[i++] = '-';
 434:	fd078793          	addi	a5,a5,-48
 438:	97a2                	add	a5,a5,s0
 43a:	02d00713          	li	a4,45
 43e:	fee78423          	sb	a4,-24(a5)
 442:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 446:	02f05a63          	blez	a5,47a <printint+0x8a>
 44a:	fc26                	sd	s1,56(sp)
 44c:	f44e                	sd	s3,40(sp)
 44e:	fb840713          	addi	a4,s0,-72
 452:	00f704b3          	add	s1,a4,a5
 456:	fff70993          	addi	s3,a4,-1
 45a:	99be                	add	s3,s3,a5
 45c:	37fd                	addiw	a5,a5,-1
 45e:	1782                	slli	a5,a5,0x20
 460:	9381                	srli	a5,a5,0x20
 462:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 466:	fff4c583          	lbu	a1,-1(s1)
 46a:	854a                	mv	a0,s2
 46c:	f67ff0ef          	jal	3d2 <putc>
  while(--i >= 0)
 470:	14fd                	addi	s1,s1,-1
 472:	ff349ae3          	bne	s1,s3,466 <printint+0x76>
 476:	74e2                	ld	s1,56(sp)
 478:	79a2                	ld	s3,40(sp)
}
 47a:	60a6                	ld	ra,72(sp)
 47c:	6406                	ld	s0,64(sp)
 47e:	7942                	ld	s2,48(sp)
 480:	6161                	addi	sp,sp,80
 482:	8082                	ret
    x = -xx;
 484:	40b005b3          	neg	a1,a1
    neg = 1;
 488:	4885                	li	a7,1
    x = -xx;
 48a:	bfad                	j	404 <printint+0x14>

000000000000048c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48c:	711d                	addi	sp,sp,-96
 48e:	ec86                	sd	ra,88(sp)
 490:	e8a2                	sd	s0,80(sp)
 492:	e0ca                	sd	s2,64(sp)
 494:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 496:	0005c903          	lbu	s2,0(a1)
 49a:	28090663          	beqz	s2,726 <vprintf+0x29a>
 49e:	e4a6                	sd	s1,72(sp)
 4a0:	fc4e                	sd	s3,56(sp)
 4a2:	f852                	sd	s4,48(sp)
 4a4:	f456                	sd	s5,40(sp)
 4a6:	f05a                	sd	s6,32(sp)
 4a8:	ec5e                	sd	s7,24(sp)
 4aa:	e862                	sd	s8,16(sp)
 4ac:	e466                	sd	s9,8(sp)
 4ae:	8b2a                	mv	s6,a0
 4b0:	8a2e                	mv	s4,a1
 4b2:	8bb2                	mv	s7,a2
  state = 0;
 4b4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4b6:	4481                	li	s1,0
 4b8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ba:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4be:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4c2:	06c00c93          	li	s9,108
 4c6:	a005                	j	4e6 <vprintf+0x5a>
        putc(fd, c0);
 4c8:	85ca                	mv	a1,s2
 4ca:	855a                	mv	a0,s6
 4cc:	f07ff0ef          	jal	3d2 <putc>
 4d0:	a019                	j	4d6 <vprintf+0x4a>
    } else if(state == '%'){
 4d2:	03598263          	beq	s3,s5,4f6 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4d6:	2485                	addiw	s1,s1,1
 4d8:	8726                	mv	a4,s1
 4da:	009a07b3          	add	a5,s4,s1
 4de:	0007c903          	lbu	s2,0(a5)
 4e2:	22090a63          	beqz	s2,716 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4e6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ea:	fe0994e3          	bnez	s3,4d2 <vprintf+0x46>
      if(c0 == '%'){
 4ee:	fd579de3          	bne	a5,s5,4c8 <vprintf+0x3c>
        state = '%';
 4f2:	89be                	mv	s3,a5
 4f4:	b7cd                	j	4d6 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4f6:	00ea06b3          	add	a3,s4,a4
 4fa:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4fe:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 500:	c681                	beqz	a3,508 <vprintf+0x7c>
 502:	9752                	add	a4,a4,s4
 504:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 508:	05878363          	beq	a5,s8,54e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 50c:	05978d63          	beq	a5,s9,566 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 510:	07500713          	li	a4,117
 514:	0ee78763          	beq	a5,a4,602 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 518:	07800713          	li	a4,120
 51c:	12e78963          	beq	a5,a4,64e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 520:	07000713          	li	a4,112
 524:	14e78e63          	beq	a5,a4,680 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 528:	06300713          	li	a4,99
 52c:	18e78e63          	beq	a5,a4,6c8 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 530:	07300713          	li	a4,115
 534:	1ae78463          	beq	a5,a4,6dc <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 538:	02500713          	li	a4,37
 53c:	04e79563          	bne	a5,a4,586 <vprintf+0xfa>
        putc(fd, '%');
 540:	02500593          	li	a1,37
 544:	855a                	mv	a0,s6
 546:	e8dff0ef          	jal	3d2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 54a:	4981                	li	s3,0
 54c:	b769                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 54e:	008b8913          	addi	s2,s7,8
 552:	4685                	li	a3,1
 554:	4629                	li	a2,10
 556:	000ba583          	lw	a1,0(s7)
 55a:	855a                	mv	a0,s6
 55c:	e95ff0ef          	jal	3f0 <printint>
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	bf8d                	j	4d6 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 566:	06400793          	li	a5,100
 56a:	02f68963          	beq	a3,a5,59c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 56e:	06c00793          	li	a5,108
 572:	04f68263          	beq	a3,a5,5b6 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 576:	07500793          	li	a5,117
 57a:	0af68063          	beq	a3,a5,61a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 57e:	07800793          	li	a5,120
 582:	0ef68263          	beq	a3,a5,666 <vprintf+0x1da>
        putc(fd, '%');
 586:	02500593          	li	a1,37
 58a:	855a                	mv	a0,s6
 58c:	e47ff0ef          	jal	3d2 <putc>
        putc(fd, c0);
 590:	85ca                	mv	a1,s2
 592:	855a                	mv	a0,s6
 594:	e3fff0ef          	jal	3d2 <putc>
      state = 0;
 598:	4981                	li	s3,0
 59a:	bf35                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e47ff0ef          	jal	3f0 <printint>
        i += 1;
 5ae:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
        i += 1;
 5b4:	b70d                	j	4d6 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b6:	06400793          	li	a5,100
 5ba:	02f60763          	beq	a2,a5,5e8 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5be:	07500793          	li	a5,117
 5c2:	06f60963          	beq	a2,a5,634 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5c6:	07800793          	li	a5,120
 5ca:	faf61ee3          	bne	a2,a5,586 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4641                	li	a2,16
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	e15ff0ef          	jal	3f0 <printint>
        i += 2;
 5e0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 2;
 5e6:	bdc5                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4685                	li	a3,1
 5ee:	4629                	li	a2,10
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	dfbff0ef          	jal	3f0 <printint>
        i += 2;
 5fa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
        i += 2;
 600:	bdd9                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 602:	008b8913          	addi	s2,s7,8
 606:	4681                	li	a3,0
 608:	4629                	li	a2,10
 60a:	000be583          	lwu	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	de1ff0ef          	jal	3f0 <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	bd7d                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4629                	li	a2,10
 622:	000bb583          	ld	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	dc9ff0ef          	jal	3f0 <printint>
        i += 1;
 62c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 1;
 632:	b555                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	008b8913          	addi	s2,s7,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000bb583          	ld	a1,0(s7)
 640:	855a                	mv	a0,s6
 642:	dafff0ef          	jal	3f0 <printint>
        i += 2;
 646:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 648:	8bca                	mv	s7,s2
      state = 0;
 64a:	4981                	li	s3,0
        i += 2;
 64c:	b569                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 64e:	008b8913          	addi	s2,s7,8
 652:	4681                	li	a3,0
 654:	4641                	li	a2,16
 656:	000be583          	lwu	a1,0(s7)
 65a:	855a                	mv	a0,s6
 65c:	d95ff0ef          	jal	3f0 <printint>
 660:	8bca                	mv	s7,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	bd8d                	j	4d6 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	008b8913          	addi	s2,s7,8
 66a:	4681                	li	a3,0
 66c:	4641                	li	a2,16
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	d7dff0ef          	jal	3f0 <printint>
        i += 1;
 678:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 1;
 67e:	bda1                	j	4d6 <vprintf+0x4a>
 680:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 682:	008b8d13          	addi	s10,s7,8
 686:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 68a:	03000593          	li	a1,48
 68e:	855a                	mv	a0,s6
 690:	d43ff0ef          	jal	3d2 <putc>
  putc(fd, 'x');
 694:	07800593          	li	a1,120
 698:	855a                	mv	a0,s6
 69a:	d39ff0ef          	jal	3d2 <putc>
 69e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a0:	00000b97          	auipc	s7,0x0
 6a4:	2a8b8b93          	addi	s7,s7,680 # 948 <digits>
 6a8:	03c9d793          	srli	a5,s3,0x3c
 6ac:	97de                	add	a5,a5,s7
 6ae:	0007c583          	lbu	a1,0(a5)
 6b2:	855a                	mv	a0,s6
 6b4:	d1fff0ef          	jal	3d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b8:	0992                	slli	s3,s3,0x4
 6ba:	397d                	addiw	s2,s2,-1
 6bc:	fe0916e3          	bnez	s2,6a8 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6c0:	8bea                	mv	s7,s10
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	6d02                	ld	s10,0(sp)
 6c6:	bd01                	j	4d6 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	000bc583          	lbu	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	d01ff0ef          	jal	3d2 <putc>
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bbf5                	j	4d6 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6dc:	008b8993          	addi	s3,s7,8
 6e0:	000bb903          	ld	s2,0(s7)
 6e4:	00090f63          	beqz	s2,702 <vprintf+0x276>
        for(; *s; s++)
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	c195                	beqz	a1,710 <vprintf+0x284>
          putc(fd, *s);
 6ee:	855a                	mv	a0,s6
 6f0:	ce3ff0ef          	jal	3d2 <putc>
        for(; *s; s++)
 6f4:	0905                	addi	s2,s2,1
 6f6:	00094583          	lbu	a1,0(s2)
 6fa:	f9f5                	bnez	a1,6ee <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6fc:	8bce                	mv	s7,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bbd9                	j	4d6 <vprintf+0x4a>
          s = "(null)";
 702:	00000917          	auipc	s2,0x0
 706:	23e90913          	addi	s2,s2,574 # 940 <malloc+0x132>
        for(; *s; s++)
 70a:	02800593          	li	a1,40
 70e:	b7c5                	j	6ee <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 710:	8bce                	mv	s7,s3
      state = 0;
 712:	4981                	li	s3,0
 714:	b3c9                	j	4d6 <vprintf+0x4a>
 716:	64a6                	ld	s1,72(sp)
 718:	79e2                	ld	s3,56(sp)
 71a:	7a42                	ld	s4,48(sp)
 71c:	7aa2                	ld	s5,40(sp)
 71e:	7b02                	ld	s6,32(sp)
 720:	6be2                	ld	s7,24(sp)
 722:	6c42                	ld	s8,16(sp)
 724:	6ca2                	ld	s9,8(sp)
    }
  }
}
 726:	60e6                	ld	ra,88(sp)
 728:	6446                	ld	s0,80(sp)
 72a:	6906                	ld	s2,64(sp)
 72c:	6125                	addi	sp,sp,96
 72e:	8082                	ret

0000000000000730 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 730:	715d                	addi	sp,sp,-80
 732:	ec06                	sd	ra,24(sp)
 734:	e822                	sd	s0,16(sp)
 736:	1000                	addi	s0,sp,32
 738:	e010                	sd	a2,0(s0)
 73a:	e414                	sd	a3,8(s0)
 73c:	e818                	sd	a4,16(s0)
 73e:	ec1c                	sd	a5,24(s0)
 740:	03043023          	sd	a6,32(s0)
 744:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 74c:	8622                	mv	a2,s0
 74e:	d3fff0ef          	jal	48c <vprintf>
}
 752:	60e2                	ld	ra,24(sp)
 754:	6442                	ld	s0,16(sp)
 756:	6161                	addi	sp,sp,80
 758:	8082                	ret

000000000000075a <printf>:

void
printf(const char *fmt, ...)
{
 75a:	711d                	addi	sp,sp,-96
 75c:	ec06                	sd	ra,24(sp)
 75e:	e822                	sd	s0,16(sp)
 760:	1000                	addi	s0,sp,32
 762:	e40c                	sd	a1,8(s0)
 764:	e810                	sd	a2,16(s0)
 766:	ec14                	sd	a3,24(s0)
 768:	f018                	sd	a4,32(s0)
 76a:	f41c                	sd	a5,40(s0)
 76c:	03043823          	sd	a6,48(s0)
 770:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 774:	00840613          	addi	a2,s0,8
 778:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77c:	85aa                	mv	a1,a0
 77e:	4505                	li	a0,1
 780:	d0dff0ef          	jal	48c <vprintf>
}
 784:	60e2                	ld	ra,24(sp)
 786:	6442                	ld	s0,16(sp)
 788:	6125                	addi	sp,sp,96
 78a:	8082                	ret

000000000000078c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78c:	1141                	addi	sp,sp,-16
 78e:	e422                	sd	s0,8(sp)
 790:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 792:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 796:	00001797          	auipc	a5,0x1
 79a:	86a7b783          	ld	a5,-1942(a5) # 1000 <freep>
 79e:	a02d                	j	7c8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a0:	4618                	lw	a4,8(a2)
 7a2:	9f2d                	addw	a4,a4,a1
 7a4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a8:	6398                	ld	a4,0(a5)
 7aa:	6310                	ld	a2,0(a4)
 7ac:	a83d                	j	7ea <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ae:	ff852703          	lw	a4,-8(a0)
 7b2:	9f31                	addw	a4,a4,a2
 7b4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b6:	ff053683          	ld	a3,-16(a0)
 7ba:	a091                	j	7fe <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e7e463          	bltu	a5,a4,7c6 <free+0x3a>
 7c2:	00e6ea63          	bltu	a3,a4,7d6 <free+0x4a>
{
 7c6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c8:	fed7fae3          	bgeu	a5,a3,7bc <free+0x30>
 7cc:	6398                	ld	a4,0(a5)
 7ce:	00e6e463          	bltu	a3,a4,7d6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d2:	fee7eae3          	bltu	a5,a4,7c6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d6:	ff852583          	lw	a1,-8(a0)
 7da:	6390                	ld	a2,0(a5)
 7dc:	02059813          	slli	a6,a1,0x20
 7e0:	01c85713          	srli	a4,a6,0x1c
 7e4:	9736                	add	a4,a4,a3
 7e6:	fae60de3          	beq	a2,a4,7a0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ea:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ee:	4790                	lw	a2,8(a5)
 7f0:	02061593          	slli	a1,a2,0x20
 7f4:	01c5d713          	srli	a4,a1,0x1c
 7f8:	973e                	add	a4,a4,a5
 7fa:	fae68ae3          	beq	a3,a4,7ae <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fe:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 800:	00001717          	auipc	a4,0x1
 804:	80f73023          	sd	a5,-2048(a4) # 1000 <freep>
}
 808:	6422                	ld	s0,8(sp)
 80a:	0141                	addi	sp,sp,16
 80c:	8082                	ret

000000000000080e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80e:	7139                	addi	sp,sp,-64
 810:	fc06                	sd	ra,56(sp)
 812:	f822                	sd	s0,48(sp)
 814:	f426                	sd	s1,40(sp)
 816:	ec4e                	sd	s3,24(sp)
 818:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 81a:	02051493          	slli	s1,a0,0x20
 81e:	9081                	srli	s1,s1,0x20
 820:	04bd                	addi	s1,s1,15
 822:	8091                	srli	s1,s1,0x4
 824:	0014899b          	addiw	s3,s1,1
 828:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 82a:	00000517          	auipc	a0,0x0
 82e:	7d653503          	ld	a0,2006(a0) # 1000 <freep>
 832:	c915                	beqz	a0,866 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 836:	4798                	lw	a4,8(a5)
 838:	08977a63          	bgeu	a4,s1,8cc <malloc+0xbe>
 83c:	f04a                	sd	s2,32(sp)
 83e:	e852                	sd	s4,16(sp)
 840:	e456                	sd	s5,8(sp)
 842:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 844:	8a4e                	mv	s4,s3
 846:	0009871b          	sext.w	a4,s3
 84a:	6685                	lui	a3,0x1
 84c:	00d77363          	bgeu	a4,a3,852 <malloc+0x44>
 850:	6a05                	lui	s4,0x1
 852:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 856:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85a:	00000917          	auipc	s2,0x0
 85e:	7a690913          	addi	s2,s2,1958 # 1000 <freep>
  if(p == SBRK_ERROR)
 862:	5afd                	li	s5,-1
 864:	a081                	j	8a4 <malloc+0x96>
 866:	f04a                	sd	s2,32(sp)
 868:	e852                	sd	s4,16(sp)
 86a:	e456                	sd	s5,8(sp)
 86c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 86e:	00000797          	auipc	a5,0x0
 872:	7a278793          	addi	a5,a5,1954 # 1010 <base>
 876:	00000717          	auipc	a4,0x0
 87a:	78f73523          	sd	a5,1930(a4) # 1000 <freep>
 87e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 880:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 884:	b7c1                	j	844 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 886:	6398                	ld	a4,0(a5)
 888:	e118                	sd	a4,0(a0)
 88a:	a8a9                	j	8e4 <malloc+0xd6>
  hp->s.size = nu;
 88c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 890:	0541                	addi	a0,a0,16
 892:	efbff0ef          	jal	78c <free>
  return freep;
 896:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 89a:	c12d                	beqz	a0,8fc <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89e:	4798                	lw	a4,8(a5)
 8a0:	02977263          	bgeu	a4,s1,8c4 <malloc+0xb6>
    if(p == freep)
 8a4:	00093703          	ld	a4,0(s2)
 8a8:	853e                	mv	a0,a5
 8aa:	fef719e3          	bne	a4,a5,89c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ae:	8552                	mv	a0,s4
 8b0:	9ffff0ef          	jal	2ae <sbrk>
  if(p == SBRK_ERROR)
 8b4:	fd551ce3          	bne	a0,s5,88c <malloc+0x7e>
        return 0;
 8b8:	4501                	li	a0,0
 8ba:	7902                	ld	s2,32(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	a03d                	j	8f0 <malloc+0xe2>
 8c4:	7902                	ld	s2,32(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8cc:	fae48de3          	beq	s1,a4,886 <malloc+0x78>
        p->s.size -= nunits;
 8d0:	4137073b          	subw	a4,a4,s3
 8d4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d6:	02071693          	slli	a3,a4,0x20
 8da:	01c6d713          	srli	a4,a3,0x1c
 8de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70a73e23          	sd	a0,1820(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ec:	01078513          	addi	a0,a5,16
  }
}
 8f0:	70e2                	ld	ra,56(sp)
 8f2:	7442                	ld	s0,48(sp)
 8f4:	74a2                	ld	s1,40(sp)
 8f6:	69e2                	ld	s3,24(sp)
 8f8:	6121                	addi	sp,sp,64
 8fa:	8082                	ret
 8fc:	7902                	ld	s2,32(sp)
 8fe:	6a42                	ld	s4,16(sp)
 900:	6aa2                	ld	s5,8(sp)
 902:	6b02                	ld	s6,0(sp)
 904:	b7f5                	j	8f0 <malloc+0xe2>
