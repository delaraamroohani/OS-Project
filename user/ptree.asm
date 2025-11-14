
user/_ptree:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fs.h"   // optional

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	72fd                	lui	t0,0xfffff
   e:	9116                	add	sp,sp,t0
  10:	84aa                	mv	s1,a0
  12:	892e                	mv	s2,a1
  char buf[4096];
  memset(buf, 0, sizeof(buf));  // Ensure null-termination
  14:	6605                	lui	a2,0x1
  16:	4581                	li	a1,0
  18:	757d                	lui	a0,0xfffff
  1a:	fe050793          	addi	a5,a0,-32 # ffffffffffffefe0 <base+0xffffffffffffdfd0>
  1e:	00878533          	add	a0,a5,s0
  22:	0f8000ef          	jal	11a <memset>
  int pid = 1;
  int n;

  if (argc > 1)
  26:	4785                	li	a5,1
  int pid = 1;
  28:	4505                	li	a0,1
  if (argc > 1)
  2a:	0497c963          	blt	a5,s1,7c <main+0x7c>
    pid = atoi(argv[1]);

  n = ptree(pid, buf, sizeof(buf));
  2e:	6605                	lui	a2,0x1
  30:	75fd                	lui	a1,0xfffff
  32:	fe058793          	addi	a5,a1,-32 # ffffffffffffefe0 <base+0xffffffffffffdfd0>
  36:	008785b3          	add	a1,a5,s0
  3a:	39a000ef          	jal	3d4 <ptree>
  if (n < 0) {
  3e:	04054463          	bltz	a0,86 <main+0x86>
    printf("ptree failed\n");
    exit(1);
  }
  if (n >= sizeof(buf))
  42:	0005079b          	sext.w	a5,a0
  46:	6705                	lui	a4,0x1
  48:	00e7e463          	bltu	a5,a4,50 <main+0x50>
    n = sizeof(buf) - 1;
  4c:	6505                	lui	a0,0x1
  4e:	157d                	addi	a0,a0,-1 # fff <digits+0x6cf>
  buf[n] = '\0';
  50:	77fd                	lui	a5,0xfffff
  52:	1781                	addi	a5,a5,-32 # ffffffffffffefe0 <base+0xffffffffffffdfd0>
  54:	97a2                	add	a5,a5,s0
  56:	777d                	lui	a4,0xfffff
  58:	fd870693          	addi	a3,a4,-40 # ffffffffffffefd8 <base+0xffffffffffffdfc8>
  5c:	96a2                	add	a3,a3,s0
  5e:	e29c                	sd	a5,0(a3)
  60:	629c                	ld	a5,0(a3)
  62:	953e                	add	a0,a0,a5
  64:	00050023          	sb	zero,0(a0)
  printf("%s", buf);
  68:	628c                	ld	a1,0(a3)
  6a:	00001517          	auipc	a0,0x1
  6e:	8b650513          	addi	a0,a0,-1866 # 920 <malloc+0x108>
  72:	6f2000ef          	jal	764 <printf>
  exit(0);
  76:	4501                	li	a0,0
  78:	2b4000ef          	jal	32c <exit>
    pid = atoi(argv[1]);
  7c:	00893503          	ld	a0,8(s2)
  80:	18a000ef          	jal	20a <atoi>
  84:	b76d                	j	2e <main+0x2e>
    printf("ptree failed\n");
  86:	00001517          	auipc	a0,0x1
  8a:	88a50513          	addi	a0,a0,-1910 # 910 <malloc+0xf8>
  8e:	6d6000ef          	jal	764 <printf>
    exit(1);
  92:	4505                	li	a0,1
  94:	298000ef          	jal	32c <exit>

0000000000000098 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e406                	sd	ra,8(sp)
  9c:	e022                	sd	s0,0(sp)
  9e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  a0:	f61ff0ef          	jal	0 <main>
  exit(r);
  a4:	288000ef          	jal	32c <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	addi	a1,a1,1
  b2:	0785                	addi	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	addi	a0,a0,1
  da:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	addi	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	addi	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	slli	a2,a2,0x20
 126:	9201                	srli	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d663          	bge	s1,s4,1b2 <gets+0x52>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	1b2000ef          	jal	344 <read>
    if(cc < 1)
 196:	00a05e63          	blez	a0,1b2 <gets+0x52>
    buf[i++] = c;
 19a:	faf44783          	lbu	a5,-81(s0)
 19e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a2:	01578763          	beq	a5,s5,1b0 <gets+0x50>
 1a6:	0905                	addi	s2,s2,1
 1a8:	fd679de3          	bne	a5,s6,182 <gets+0x22>
    buf[i++] = c;
 1ac:	89a6                	mv	s3,s1
 1ae:	a011                	j	1b2 <gets+0x52>
 1b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b2:	99de                	add	s3,s3,s7
 1b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b8:	855e                	mv	a0,s7
 1ba:	60e6                	ld	ra,88(sp)
 1bc:	6446                	ld	s0,80(sp)
 1be:	64a6                	ld	s1,72(sp)
 1c0:	6906                	ld	s2,64(sp)
 1c2:	79e2                	ld	s3,56(sp)
 1c4:	7a42                	ld	s4,48(sp)
 1c6:	7aa2                	ld	s5,40(sp)
 1c8:	7b02                	ld	s6,32(sp)
 1ca:	6be2                	ld	s7,24(sp)
 1cc:	6125                	addi	sp,sp,96
 1ce:	8082                	ret

00000000000001d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d0:	1101                	addi	sp,sp,-32
 1d2:	ec06                	sd	ra,24(sp)
 1d4:	e822                	sd	s0,16(sp)
 1d6:	e04a                	sd	s2,0(sp)
 1d8:	1000                	addi	s0,sp,32
 1da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1dc:	4581                	li	a1,0
 1de:	18e000ef          	jal	36c <open>
  if(fd < 0)
 1e2:	02054263          	bltz	a0,206 <stat+0x36>
 1e6:	e426                	sd	s1,8(sp)
 1e8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ea:	85ca                	mv	a1,s2
 1ec:	198000ef          	jal	384 <fstat>
 1f0:	892a                	mv	s2,a0
  close(fd);
 1f2:	8526                	mv	a0,s1
 1f4:	160000ef          	jal	354 <close>
  return r;
 1f8:	64a2                	ld	s1,8(sp)
}
 1fa:	854a                	mv	a0,s2
 1fc:	60e2                	ld	ra,24(sp)
 1fe:	6442                	ld	s0,16(sp)
 200:	6902                	ld	s2,0(sp)
 202:	6105                	addi	sp,sp,32
 204:	8082                	ret
    return -1;
 206:	597d                	li	s2,-1
 208:	bfcd                	j	1fa <stat+0x2a>

000000000000020a <atoi>:

int
atoi(const char *s)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 210:	00054683          	lbu	a3,0(a0)
 214:	fd06879b          	addiw	a5,a3,-48
 218:	0ff7f793          	zext.b	a5,a5
 21c:	4625                	li	a2,9
 21e:	02f66863          	bltu	a2,a5,24e <atoi+0x44>
 222:	872a                	mv	a4,a0
  n = 0;
 224:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 226:	0705                	addi	a4,a4,1
 228:	0025179b          	slliw	a5,a0,0x2
 22c:	9fa9                	addw	a5,a5,a0
 22e:	0017979b          	slliw	a5,a5,0x1
 232:	9fb5                	addw	a5,a5,a3
 234:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 238:	00074683          	lbu	a3,0(a4)
 23c:	fd06879b          	addiw	a5,a3,-48
 240:	0ff7f793          	zext.b	a5,a5
 244:	fef671e3          	bgeu	a2,a5,226 <atoi+0x1c>
  return n;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  n = 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <atoi+0x3e>

0000000000000252 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 258:	02b57463          	bgeu	a0,a1,280 <memmove+0x2e>
    while(n-- > 0)
 25c:	00c05f63          	blez	a2,27a <memmove+0x28>
 260:	1602                	slli	a2,a2,0x20
 262:	9201                	srli	a2,a2,0x20
 264:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 268:	872a                	mv	a4,a0
      *dst++ = *src++;
 26a:	0585                	addi	a1,a1,1
 26c:	0705                	addi	a4,a4,1
 26e:	fff5c683          	lbu	a3,-1(a1)
 272:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 276:	fef71ae3          	bne	a4,a5,26a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
    dst += n;
 280:	00c50733          	add	a4,a0,a2
    src += n;
 284:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 286:	fec05ae3          	blez	a2,27a <memmove+0x28>
 28a:	fff6079b          	addiw	a5,a2,-1 # fff <digits+0x6cf>
 28e:	1782                	slli	a5,a5,0x20
 290:	9381                	srli	a5,a5,0x20
 292:	fff7c793          	not	a5,a5
 296:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 298:	15fd                	addi	a1,a1,-1
 29a:	177d                	addi	a4,a4,-1
 29c:	0005c683          	lbu	a3,0(a1)
 2a0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2a4:	fee79ae3          	bne	a5,a4,298 <memmove+0x46>
 2a8:	bfc9                	j	27a <memmove+0x28>

00000000000002aa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2b0:	ca05                	beqz	a2,2e0 <memcmp+0x36>
 2b2:	fff6069b          	addiw	a3,a2,-1
 2b6:	1682                	slli	a3,a3,0x20
 2b8:	9281                	srli	a3,a3,0x20
 2ba:	0685                	addi	a3,a3,1
 2bc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	0005c703          	lbu	a4,0(a1)
 2c6:	00e79863          	bne	a5,a4,2d6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ca:	0505                	addi	a0,a0,1
    p2++;
 2cc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ce:	fed518e3          	bne	a0,a3,2be <memcmp+0x14>
  }
  return 0;
 2d2:	4501                	li	a0,0
 2d4:	a019                	j	2da <memcmp+0x30>
      return *p1 - *p2;
 2d6:	40e7853b          	subw	a0,a5,a4
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <memcmp+0x30>

00000000000002e4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e406                	sd	ra,8(sp)
 2e8:	e022                	sd	s0,0(sp)
 2ea:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ec:	f67ff0ef          	jal	252 <memmove>
}
 2f0:	60a2                	ld	ra,8(sp)
 2f2:	6402                	ld	s0,0(sp)
 2f4:	0141                	addi	sp,sp,16
 2f6:	8082                	ret

00000000000002f8 <sbrk>:

char *
sbrk(int n) {
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 300:	4585                	li	a1,1
 302:	0b2000ef          	jal	3b4 <sys_sbrk>
}
 306:	60a2                	ld	ra,8(sp)
 308:	6402                	ld	s0,0(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <sbrklazy>:

char *
sbrklazy(int n) {
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 316:	4589                	li	a1,2
 318:	09c000ef          	jal	3b4 <sys_sbrk>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 324:	4885                	li	a7,1
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <exit>:
.global exit
exit:
 li a7, SYS_exit
 32c:	4889                	li	a7,2
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <wait>:
.global wait
wait:
 li a7, SYS_wait
 334:	488d                	li	a7,3
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33c:	4891                	li	a7,4
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <read>:
.global read
read:
 li a7, SYS_read
 344:	4895                	li	a7,5
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <write>:
.global write
write:
 li a7, SYS_write
 34c:	48c1                	li	a7,16
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <close>:
.global close
close:
 li a7, SYS_close
 354:	48d5                	li	a7,21
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <kill>:
.global kill
kill:
 li a7, SYS_kill
 35c:	4899                	li	a7,6
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exec>:
.global exec
exec:
 li a7, SYS_exec
 364:	489d                	li	a7,7
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <open>:
.global open
open:
 li a7, SYS_open
 36c:	48bd                	li	a7,15
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 374:	48c5                	li	a7,17
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37c:	48c9                	li	a7,18
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 384:	48a1                	li	a7,8
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <link>:
.global link
link:
 li a7, SYS_link
 38c:	48cd                	li	a7,19
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 394:	48d1                	li	a7,20
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39c:	48a5                	li	a7,9
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a4:	48a9                	li	a7,10
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ac:	48ad                	li	a7,11
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3b4:	48b1                	li	a7,12
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <pause>:
.global pause
pause:
 li a7, SYS_pause
 3bc:	48b5                	li	a7,13
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c4:	48b9                	li	a7,14
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 3cc:	48d9                	li	a7,22
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 3d4:	48dd                	li	a7,23
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3dc:	1101                	addi	sp,sp,-32
 3de:	ec06                	sd	ra,24(sp)
 3e0:	e822                	sd	s0,16(sp)
 3e2:	1000                	addi	s0,sp,32
 3e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e8:	4605                	li	a2,1
 3ea:	fef40593          	addi	a1,s0,-17
 3ee:	f5fff0ef          	jal	34c <write>
}
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	6105                	addi	sp,sp,32
 3f8:	8082                	ret

00000000000003fa <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3fa:	715d                	addi	sp,sp,-80
 3fc:	e486                	sd	ra,72(sp)
 3fe:	e0a2                	sd	s0,64(sp)
 400:	f84a                	sd	s2,48(sp)
 402:	0880                	addi	s0,sp,80
 404:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 406:	c299                	beqz	a3,40c <printint+0x12>
 408:	0805c363          	bltz	a1,48e <printint+0x94>
  neg = 0;
 40c:	4881                	li	a7,0
 40e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 412:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 414:	00000517          	auipc	a0,0x0
 418:	51c50513          	addi	a0,a0,1308 # 930 <digits>
 41c:	883e                	mv	a6,a5
 41e:	2785                	addiw	a5,a5,1
 420:	02c5f733          	remu	a4,a1,a2
 424:	972a                	add	a4,a4,a0
 426:	00074703          	lbu	a4,0(a4)
 42a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 42e:	872e                	mv	a4,a1
 430:	02c5d5b3          	divu	a1,a1,a2
 434:	0685                	addi	a3,a3,1
 436:	fec773e3          	bgeu	a4,a2,41c <printint+0x22>
  if(neg)
 43a:	00088b63          	beqz	a7,450 <printint+0x56>
    buf[i++] = '-';
 43e:	fd078793          	addi	a5,a5,-48
 442:	97a2                	add	a5,a5,s0
 444:	02d00713          	li	a4,45
 448:	fee78423          	sb	a4,-24(a5)
 44c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 450:	02f05a63          	blez	a5,484 <printint+0x8a>
 454:	fc26                	sd	s1,56(sp)
 456:	f44e                	sd	s3,40(sp)
 458:	fb840713          	addi	a4,s0,-72
 45c:	00f704b3          	add	s1,a4,a5
 460:	fff70993          	addi	s3,a4,-1
 464:	99be                	add	s3,s3,a5
 466:	37fd                	addiw	a5,a5,-1
 468:	1782                	slli	a5,a5,0x20
 46a:	9381                	srli	a5,a5,0x20
 46c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 470:	fff4c583          	lbu	a1,-1(s1)
 474:	854a                	mv	a0,s2
 476:	f67ff0ef          	jal	3dc <putc>
  while(--i >= 0)
 47a:	14fd                	addi	s1,s1,-1
 47c:	ff349ae3          	bne	s1,s3,470 <printint+0x76>
 480:	74e2                	ld	s1,56(sp)
 482:	79a2                	ld	s3,40(sp)
}
 484:	60a6                	ld	ra,72(sp)
 486:	6406                	ld	s0,64(sp)
 488:	7942                	ld	s2,48(sp)
 48a:	6161                	addi	sp,sp,80
 48c:	8082                	ret
    x = -xx;
 48e:	40b005b3          	neg	a1,a1
    neg = 1;
 492:	4885                	li	a7,1
    x = -xx;
 494:	bfad                	j	40e <printint+0x14>

0000000000000496 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 496:	711d                	addi	sp,sp,-96
 498:	ec86                	sd	ra,88(sp)
 49a:	e8a2                	sd	s0,80(sp)
 49c:	e0ca                	sd	s2,64(sp)
 49e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a0:	0005c903          	lbu	s2,0(a1)
 4a4:	28090663          	beqz	s2,730 <vprintf+0x29a>
 4a8:	e4a6                	sd	s1,72(sp)
 4aa:	fc4e                	sd	s3,56(sp)
 4ac:	f852                	sd	s4,48(sp)
 4ae:	f456                	sd	s5,40(sp)
 4b0:	f05a                	sd	s6,32(sp)
 4b2:	ec5e                	sd	s7,24(sp)
 4b4:	e862                	sd	s8,16(sp)
 4b6:	e466                	sd	s9,8(sp)
 4b8:	8b2a                	mv	s6,a0
 4ba:	8a2e                	mv	s4,a1
 4bc:	8bb2                	mv	s7,a2
  state = 0;
 4be:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c0:	4481                	li	s1,0
 4c2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4c8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4cc:	06c00c93          	li	s9,108
 4d0:	a005                	j	4f0 <vprintf+0x5a>
        putc(fd, c0);
 4d2:	85ca                	mv	a1,s2
 4d4:	855a                	mv	a0,s6
 4d6:	f07ff0ef          	jal	3dc <putc>
 4da:	a019                	j	4e0 <vprintf+0x4a>
    } else if(state == '%'){
 4dc:	03598263          	beq	s3,s5,500 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4e0:	2485                	addiw	s1,s1,1
 4e2:	8726                	mv	a4,s1
 4e4:	009a07b3          	add	a5,s4,s1
 4e8:	0007c903          	lbu	s2,0(a5)
 4ec:	22090a63          	beqz	s2,720 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4f0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4f4:	fe0994e3          	bnez	s3,4dc <vprintf+0x46>
      if(c0 == '%'){
 4f8:	fd579de3          	bne	a5,s5,4d2 <vprintf+0x3c>
        state = '%';
 4fc:	89be                	mv	s3,a5
 4fe:	b7cd                	j	4e0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 500:	00ea06b3          	add	a3,s4,a4
 504:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 508:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 50a:	c681                	beqz	a3,512 <vprintf+0x7c>
 50c:	9752                	add	a4,a4,s4
 50e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 512:	05878363          	beq	a5,s8,558 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 516:	05978d63          	beq	a5,s9,570 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 51a:	07500713          	li	a4,117
 51e:	0ee78763          	beq	a5,a4,60c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 522:	07800713          	li	a4,120
 526:	12e78963          	beq	a5,a4,658 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 52a:	07000713          	li	a4,112
 52e:	14e78e63          	beq	a5,a4,68a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 532:	06300713          	li	a4,99
 536:	18e78e63          	beq	a5,a4,6d2 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 53a:	07300713          	li	a4,115
 53e:	1ae78463          	beq	a5,a4,6e6 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 542:	02500713          	li	a4,37
 546:	04e79563          	bne	a5,a4,590 <vprintf+0xfa>
        putc(fd, '%');
 54a:	02500593          	li	a1,37
 54e:	855a                	mv	a0,s6
 550:	e8dff0ef          	jal	3dc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 554:	4981                	li	s3,0
 556:	b769                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 558:	008b8913          	addi	s2,s7,8
 55c:	4685                	li	a3,1
 55e:	4629                	li	a2,10
 560:	000ba583          	lw	a1,0(s7)
 564:	855a                	mv	a0,s6
 566:	e95ff0ef          	jal	3fa <printint>
 56a:	8bca                	mv	s7,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bf8d                	j	4e0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 570:	06400793          	li	a5,100
 574:	02f68963          	beq	a3,a5,5a6 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 578:	06c00793          	li	a5,108
 57c:	04f68263          	beq	a3,a5,5c0 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 580:	07500793          	li	a5,117
 584:	0af68063          	beq	a3,a5,624 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 588:	07800793          	li	a5,120
 58c:	0ef68263          	beq	a3,a5,670 <vprintf+0x1da>
        putc(fd, '%');
 590:	02500593          	li	a1,37
 594:	855a                	mv	a0,s6
 596:	e47ff0ef          	jal	3dc <putc>
        putc(fd, c0);
 59a:	85ca                	mv	a1,s2
 59c:	855a                	mv	a0,s6
 59e:	e3fff0ef          	jal	3dc <putc>
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	bf35                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5a6:	008b8913          	addi	s2,s7,8
 5aa:	4685                	li	a3,1
 5ac:	4629                	li	a2,10
 5ae:	000bb583          	ld	a1,0(s7)
 5b2:	855a                	mv	a0,s6
 5b4:	e47ff0ef          	jal	3fa <printint>
        i += 1;
 5b8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	8bca                	mv	s7,s2
      state = 0;
 5bc:	4981                	li	s3,0
        i += 1;
 5be:	b70d                	j	4e0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5c0:	06400793          	li	a5,100
 5c4:	02f60763          	beq	a2,a5,5f2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5c8:	07500793          	li	a5,117
 5cc:	06f60963          	beq	a2,a5,63e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5d0:	07800793          	li	a5,120
 5d4:	faf61ee3          	bne	a2,a5,590 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4681                	li	a3,0
 5de:	4641                	li	a2,16
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e15ff0ef          	jal	3fa <printint>
        i += 2;
 5ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
        i += 2;
 5f0:	bdc5                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	008b8913          	addi	s2,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000bb583          	ld	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	dfbff0ef          	jal	3fa <printint>
        i += 2;
 604:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
        i += 2;
 60a:	bdd9                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 60c:	008b8913          	addi	s2,s7,8
 610:	4681                	li	a3,0
 612:	4629                	li	a2,10
 614:	000be583          	lwu	a1,0(s7)
 618:	855a                	mv	a0,s6
 61a:	de1ff0ef          	jal	3fa <printint>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bd7d                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 624:	008b8913          	addi	s2,s7,8
 628:	4681                	li	a3,0
 62a:	4629                	li	a2,10
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	dc9ff0ef          	jal	3fa <printint>
        i += 1;
 636:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	b555                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63e:	008b8913          	addi	s2,s7,8
 642:	4681                	li	a3,0
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	dafff0ef          	jal	3fa <printint>
        i += 2;
 650:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 2;
 656:	b569                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000be583          	lwu	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	d95ff0ef          	jal	3fa <printint>
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bd8d                	j	4e0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	d7dff0ef          	jal	3fa <printint>
        i += 1;
 682:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 1;
 688:	bda1                	j	4e0 <vprintf+0x4a>
 68a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 68c:	008b8d13          	addi	s10,s7,8
 690:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 694:	03000593          	li	a1,48
 698:	855a                	mv	a0,s6
 69a:	d43ff0ef          	jal	3dc <putc>
  putc(fd, 'x');
 69e:	07800593          	li	a1,120
 6a2:	855a                	mv	a0,s6
 6a4:	d39ff0ef          	jal	3dc <putc>
 6a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6aa:	00000b97          	auipc	s7,0x0
 6ae:	286b8b93          	addi	s7,s7,646 # 930 <digits>
 6b2:	03c9d793          	srli	a5,s3,0x3c
 6b6:	97de                	add	a5,a5,s7
 6b8:	0007c583          	lbu	a1,0(a5)
 6bc:	855a                	mv	a0,s6
 6be:	d1fff0ef          	jal	3dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c2:	0992                	slli	s3,s3,0x4
 6c4:	397d                	addiw	s2,s2,-1
 6c6:	fe0916e3          	bnez	s2,6b2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6ca:	8bea                	mv	s7,s10
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	6d02                	ld	s10,0(sp)
 6d0:	bd01                	j	4e0 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	000bc583          	lbu	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	d01ff0ef          	jal	3dc <putc>
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bbf5                	j	4e0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6e6:	008b8993          	addi	s3,s7,8
 6ea:	000bb903          	ld	s2,0(s7)
 6ee:	00090f63          	beqz	s2,70c <vprintf+0x276>
        for(; *s; s++)
 6f2:	00094583          	lbu	a1,0(s2)
 6f6:	c195                	beqz	a1,71a <vprintf+0x284>
          putc(fd, *s);
 6f8:	855a                	mv	a0,s6
 6fa:	ce3ff0ef          	jal	3dc <putc>
        for(; *s; s++)
 6fe:	0905                	addi	s2,s2,1
 700:	00094583          	lbu	a1,0(s2)
 704:	f9f5                	bnez	a1,6f8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 706:	8bce                	mv	s7,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	bbd9                	j	4e0 <vprintf+0x4a>
          s = "(null)";
 70c:	00000917          	auipc	s2,0x0
 710:	21c90913          	addi	s2,s2,540 # 928 <malloc+0x110>
        for(; *s; s++)
 714:	02800593          	li	a1,40
 718:	b7c5                	j	6f8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 71a:	8bce                	mv	s7,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b3c9                	j	4e0 <vprintf+0x4a>
 720:	64a6                	ld	s1,72(sp)
 722:	79e2                	ld	s3,56(sp)
 724:	7a42                	ld	s4,48(sp)
 726:	7aa2                	ld	s5,40(sp)
 728:	7b02                	ld	s6,32(sp)
 72a:	6be2                	ld	s7,24(sp)
 72c:	6c42                	ld	s8,16(sp)
 72e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 730:	60e6                	ld	ra,88(sp)
 732:	6446                	ld	s0,80(sp)
 734:	6906                	ld	s2,64(sp)
 736:	6125                	addi	sp,sp,96
 738:	8082                	ret

000000000000073a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73a:	715d                	addi	sp,sp,-80
 73c:	ec06                	sd	ra,24(sp)
 73e:	e822                	sd	s0,16(sp)
 740:	1000                	addi	s0,sp,32
 742:	e010                	sd	a2,0(s0)
 744:	e414                	sd	a3,8(s0)
 746:	e818                	sd	a4,16(s0)
 748:	ec1c                	sd	a5,24(s0)
 74a:	03043023          	sd	a6,32(s0)
 74e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 752:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 756:	8622                	mv	a2,s0
 758:	d3fff0ef          	jal	496 <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6161                	addi	sp,sp,80
 762:	8082                	ret

0000000000000764 <printf>:

void
printf(const char *fmt, ...)
{
 764:	711d                	addi	sp,sp,-96
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e40c                	sd	a1,8(s0)
 76e:	e810                	sd	a2,16(s0)
 770:	ec14                	sd	a3,24(s0)
 772:	f018                	sd	a4,32(s0)
 774:	f41c                	sd	a5,40(s0)
 776:	03043823          	sd	a6,48(s0)
 77a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77e:	00840613          	addi	a2,s0,8
 782:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 786:	85aa                	mv	a1,a0
 788:	4505                	li	a0,1
 78a:	d0dff0ef          	jal	496 <vprintf>
}
 78e:	60e2                	ld	ra,24(sp)
 790:	6442                	ld	s0,16(sp)
 792:	6125                	addi	sp,sp,96
 794:	8082                	ret

0000000000000796 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 796:	1141                	addi	sp,sp,-16
 798:	e422                	sd	s0,8(sp)
 79a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a0:	00001797          	auipc	a5,0x1
 7a4:	8607b783          	ld	a5,-1952(a5) # 1000 <freep>
 7a8:	a02d                	j	7d2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7aa:	4618                	lw	a4,8(a2)
 7ac:	9f2d                	addw	a4,a4,a1
 7ae:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b2:	6398                	ld	a4,0(a5)
 7b4:	6310                	ld	a2,0(a4)
 7b6:	a83d                	j	7f4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b8:	ff852703          	lw	a4,-8(a0)
 7bc:	9f31                	addw	a4,a4,a2
 7be:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c0:	ff053683          	ld	a3,-16(a0)
 7c4:	a091                	j	808 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c6:	6398                	ld	a4,0(a5)
 7c8:	00e7e463          	bltu	a5,a4,7d0 <free+0x3a>
 7cc:	00e6ea63          	bltu	a3,a4,7e0 <free+0x4a>
{
 7d0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d2:	fed7fae3          	bgeu	a5,a3,7c6 <free+0x30>
 7d6:	6398                	ld	a4,0(a5)
 7d8:	00e6e463          	bltu	a3,a4,7e0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	fee7eae3          	bltu	a5,a4,7d0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e0:	ff852583          	lw	a1,-8(a0)
 7e4:	6390                	ld	a2,0(a5)
 7e6:	02059813          	slli	a6,a1,0x20
 7ea:	01c85713          	srli	a4,a6,0x1c
 7ee:	9736                	add	a4,a4,a3
 7f0:	fae60de3          	beq	a2,a4,7aa <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7f4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f8:	4790                	lw	a2,8(a5)
 7fa:	02061593          	slli	a1,a2,0x20
 7fe:	01c5d713          	srli	a4,a1,0x1c
 802:	973e                	add	a4,a4,a5
 804:	fae68ae3          	beq	a3,a4,7b8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 808:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80a:	00000717          	auipc	a4,0x0
 80e:	7ef73b23          	sd	a5,2038(a4) # 1000 <freep>
}
 812:	6422                	ld	s0,8(sp)
 814:	0141                	addi	sp,sp,16
 816:	8082                	ret

0000000000000818 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 818:	7139                	addi	sp,sp,-64
 81a:	fc06                	sd	ra,56(sp)
 81c:	f822                	sd	s0,48(sp)
 81e:	f426                	sd	s1,40(sp)
 820:	ec4e                	sd	s3,24(sp)
 822:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 824:	02051493          	slli	s1,a0,0x20
 828:	9081                	srli	s1,s1,0x20
 82a:	04bd                	addi	s1,s1,15
 82c:	8091                	srli	s1,s1,0x4
 82e:	0014899b          	addiw	s3,s1,1
 832:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 834:	00000517          	auipc	a0,0x0
 838:	7cc53503          	ld	a0,1996(a0) # 1000 <freep>
 83c:	c915                	beqz	a0,870 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	08977a63          	bgeu	a4,s1,8d6 <malloc+0xbe>
 846:	f04a                	sd	s2,32(sp)
 848:	e852                	sd	s4,16(sp)
 84a:	e456                	sd	s5,8(sp)
 84c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 84e:	8a4e                	mv	s4,s3
 850:	0009871b          	sext.w	a4,s3
 854:	6685                	lui	a3,0x1
 856:	00d77363          	bgeu	a4,a3,85c <malloc+0x44>
 85a:	6a05                	lui	s4,0x1
 85c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 860:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 864:	00000917          	auipc	s2,0x0
 868:	79c90913          	addi	s2,s2,1948 # 1000 <freep>
  if(p == SBRK_ERROR)
 86c:	5afd                	li	s5,-1
 86e:	a081                	j	8ae <malloc+0x96>
 870:	f04a                	sd	s2,32(sp)
 872:	e852                	sd	s4,16(sp)
 874:	e456                	sd	s5,8(sp)
 876:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 878:	00000797          	auipc	a5,0x0
 87c:	79878793          	addi	a5,a5,1944 # 1010 <base>
 880:	00000717          	auipc	a4,0x0
 884:	78f73023          	sd	a5,1920(a4) # 1000 <freep>
 888:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88e:	b7c1                	j	84e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 890:	6398                	ld	a4,0(a5)
 892:	e118                	sd	a4,0(a0)
 894:	a8a9                	j	8ee <malloc+0xd6>
  hp->s.size = nu;
 896:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89a:	0541                	addi	a0,a0,16
 89c:	efbff0ef          	jal	796 <free>
  return freep;
 8a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8a4:	c12d                	beqz	a0,906 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a8:	4798                	lw	a4,8(a5)
 8aa:	02977263          	bgeu	a4,s1,8ce <malloc+0xb6>
    if(p == freep)
 8ae:	00093703          	ld	a4,0(s2)
 8b2:	853e                	mv	a0,a5
 8b4:	fef719e3          	bne	a4,a5,8a6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8b8:	8552                	mv	a0,s4
 8ba:	a3fff0ef          	jal	2f8 <sbrk>
  if(p == SBRK_ERROR)
 8be:	fd551ce3          	bne	a0,s5,896 <malloc+0x7e>
        return 0;
 8c2:	4501                	li	a0,0
 8c4:	7902                	ld	s2,32(sp)
 8c6:	6a42                	ld	s4,16(sp)
 8c8:	6aa2                	ld	s5,8(sp)
 8ca:	6b02                	ld	s6,0(sp)
 8cc:	a03d                	j	8fa <malloc+0xe2>
 8ce:	7902                	ld	s2,32(sp)
 8d0:	6a42                	ld	s4,16(sp)
 8d2:	6aa2                	ld	s5,8(sp)
 8d4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8d6:	fae48de3          	beq	s1,a4,890 <malloc+0x78>
        p->s.size -= nunits;
 8da:	4137073b          	subw	a4,a4,s3
 8de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e0:	02071693          	slli	a3,a4,0x20
 8e4:	01c6d713          	srli	a4,a3,0x1c
 8e8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ea:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ee:	00000717          	auipc	a4,0x0
 8f2:	70a73923          	sd	a0,1810(a4) # 1000 <freep>
      return (void*)(p + 1);
 8f6:	01078513          	addi	a0,a5,16
  }
}
 8fa:	70e2                	ld	ra,56(sp)
 8fc:	7442                	ld	s0,48(sp)
 8fe:	74a2                	ld	s1,40(sp)
 900:	69e2                	ld	s3,24(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
 906:	7902                	ld	s2,32(sp)
 908:	6a42                	ld	s4,16(sp)
 90a:	6aa2                	ld	s5,8(sp)
 90c:	6b02                	ld	s6,0(sp)
 90e:	b7f5                	j	8fa <malloc+0xe2>
