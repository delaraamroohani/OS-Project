
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  char *buf = malloc(4096);
   e:	6505                	lui	a0,0x1
  10:	0db000ef          	jal	8ea <malloc>
  if(buf == 0) {
  14:	c559                	beqz	a0,a2 <main+0xa2>
  16:	84aa                	mv	s1,a0
    printf("malloc failed\n");
    exit(1);
  }
  
  buf[0] = 'A';
  18:	04100793          	li	a5,65
  1c:	00f50023          	sb	a5,0(a0) # 1000 <freep>
  
  int parent_page_before = physaddr(buf);
  20:	486000ef          	jal	4a6 <physaddr>
  24:	892a                	mv	s2,a0
  printf("Parent: initial page number value = %d\n", parent_page_before);
  26:	85aa                	mv	a1,a0
  28:	00001517          	auipc	a0,0x1
  2c:	9e050513          	addi	a0,a0,-1568 # a08 <malloc+0x11e>
  30:	007000ef          	jal	836 <printf>
  
  int pid = cowfork();
  34:	46a000ef          	jal	49e <cowfork>
  if(pid < 0) {
  38:	06054e63          	bltz	a0,b4 <main+0xb4>
    printf("cowfork failed\n");
    exit(1);
  }
  
  if(pid == 0) {
  3c:	c549                	beqz	a0,c6 <main+0xc6>
    
    exit(0);
  }
  
  // Parent waits for child
  wait(0);
  3e:	4501                	li	a0,0
  40:	3b6000ef          	jal	3f6 <wait>
  
  int parent_page_after = physaddr(buf);
  44:	8526                	mv	a0,s1
  46:	460000ef          	jal	4a6 <physaddr>
  4a:	89aa                	mv	s3,a0
  printf("Parent: after child write, page number value = %d\n", parent_page_after);
  4c:	85aa                	mv	a1,a0
  4e:	00001517          	auipc	a0,0x1
  52:	af250513          	addi	a0,a0,-1294 # b40 <malloc+0x256>
  56:	7e0000ef          	jal	836 <printf>
  printf("Parent: after child write, buffer value = %c\n", buf[0]);
  5a:	0004c583          	lbu	a1,0(s1)
  5e:	00001517          	auipc	a0,0x1
  62:	b1a50513          	addi	a0,a0,-1254 # b78 <malloc+0x28e>
  66:	7d0000ef          	jal	836 <printf>
  
  // Verify COW semantics:
  // 1. Parent's page should be the same as before (or changed if only ref remaining)
  // 2. Parent's buffer value should still be 'A' (unchanged by child's write)
  
  if(buf[0] == 'A') {
  6a:	0004c703          	lbu	a4,0(s1)
  6e:	04100793          	li	a5,65
  72:	0cf70663          	beq	a4,a5,13e <main+0x13e>
    printf("SUCCESS: Parent's data unchanged by child's write!\n");
  } else {
    printf("ERROR: Parent's data was modified by child's write!\n");
  76:	00001517          	auipc	a0,0x1
  7a:	b6a50513          	addi	a0,a0,-1174 # be0 <malloc+0x2f6>
  7e:	7b8000ef          	jal	836 <printf>
  }
  
  if(parent_page_before == parent_page_after) {
  82:	0d390563          	beq	s2,s3,14c <main+0x14c>
    printf("Parent's page number unchanged.\n");
  } else {
    printf("Parent's page number changed (expected if refcount dropped to 1).\n");
  86:	00001517          	auipc	a0,0x1
  8a:	bba50513          	addi	a0,a0,-1094 # c40 <malloc+0x356>
  8e:	7a8000ef          	jal	836 <printf>
  }
  
  return 0;
}
  92:	4501                	li	a0,0
  94:	70a2                	ld	ra,40(sp)
  96:	7402                	ld	s0,32(sp)
  98:	64e2                	ld	s1,24(sp)
  9a:	6942                	ld	s2,16(sp)
  9c:	69a2                	ld	s3,8(sp)
  9e:	6145                	addi	sp,sp,48
  a0:	8082                	ret
    printf("malloc failed\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	94e50513          	addi	a0,a0,-1714 # 9f0 <malloc+0x106>
  aa:	78c000ef          	jal	836 <printf>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	33e000ef          	jal	3ee <exit>
    printf("cowfork failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	97c50513          	addi	a0,a0,-1668 # a30 <malloc+0x146>
  bc:	77a000ef          	jal	836 <printf>
    exit(1);
  c0:	4505                	li	a0,1
  c2:	32c000ef          	jal	3ee <exit>
    int child_page_before = physaddr(buf);
  c6:	8526                	mv	a0,s1
  c8:	3de000ef          	jal	4a6 <physaddr>
  cc:	89aa                	mv	s3,a0
    printf("Child: initial page number value = %d\n", child_page_before);
  ce:	85aa                	mv	a1,a0
  d0:	00001517          	auipc	a0,0x1
  d4:	97050513          	addi	a0,a0,-1680 # a40 <malloc+0x156>
  d8:	75e000ef          	jal	836 <printf>
    printf("Child: initial buffer val = %c\n", buf[0]);
  dc:	0004c583          	lbu	a1,0(s1)
  e0:	00001517          	auipc	a0,0x1
  e4:	98850513          	addi	a0,a0,-1656 # a68 <malloc+0x17e>
  e8:	74e000ef          	jal	836 <printf>
    buf[0] = 'C';
  ec:	04300793          	li	a5,67
  f0:	00f48023          	sb	a5,0(s1)
    int child_page_after = physaddr(buf);
  f4:	8526                	mv	a0,s1
  f6:	3b0000ef          	jal	4a6 <physaddr>
  fa:	892a                	mv	s2,a0
    printf("Child: page number after writing = %d\n", child_page_after);
  fc:	85aa                	mv	a1,a0
  fe:	00001517          	auipc	a0,0x1
 102:	98a50513          	addi	a0,a0,-1654 # a88 <malloc+0x19e>
 106:	730000ef          	jal	836 <printf>
    printf("Child: buffer value after write: %c\n", buf[0]);
 10a:	0004c583          	lbu	a1,0(s1)
 10e:	00001517          	auipc	a0,0x1
 112:	9a250513          	addi	a0,a0,-1630 # ab0 <malloc+0x1c6>
 116:	720000ef          	jal	836 <printf>
    if(child_page_before == child_page_after) {
 11a:	01298b63          	beq	s3,s2,130 <main+0x130>
      printf("SUCCESS: Page changed after write (COW worked!)\n");
 11e:	00001517          	auipc	a0,0x1
 122:	9ea50513          	addi	a0,a0,-1558 # b08 <malloc+0x21e>
 126:	710000ef          	jal	836 <printf>
    exit(0);
 12a:	4501                	li	a0,0
 12c:	2c2000ef          	jal	3ee <exit>
      printf("ERROR: Page should have changed after write!\n");
 130:	00001517          	auipc	a0,0x1
 134:	9a850513          	addi	a0,a0,-1624 # ad8 <malloc+0x1ee>
 138:	6fe000ef          	jal	836 <printf>
 13c:	b7fd                	j	12a <main+0x12a>
    printf("SUCCESS: Parent's data unchanged by child's write!\n");
 13e:	00001517          	auipc	a0,0x1
 142:	a6a50513          	addi	a0,a0,-1430 # ba8 <malloc+0x2be>
 146:	6f0000ef          	jal	836 <printf>
 14a:	bf25                	j	82 <main+0x82>
    printf("Parent's page number unchanged.\n");
 14c:	00001517          	auipc	a0,0x1
 150:	acc50513          	addi	a0,a0,-1332 # c18 <malloc+0x32e>
 154:	6e2000ef          	jal	836 <printf>
 158:	bf2d                	j	92 <main+0x92>

000000000000015a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 162:	e9fff0ef          	jal	0 <main>
  exit(r);
 166:	288000ef          	jal	3ee <exit>

000000000000016a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 170:	87aa                	mv	a5,a0
 172:	0585                	addi	a1,a1,1
 174:	0785                	addi	a5,a5,1
 176:	fff5c703          	lbu	a4,-1(a1)
 17a:	fee78fa3          	sb	a4,-1(a5)
 17e:	fb75                	bnez	a4,172 <strcpy+0x8>
    ;
  return os;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18c:	00054783          	lbu	a5,0(a0)
 190:	cb91                	beqz	a5,1a4 <strcmp+0x1e>
 192:	0005c703          	lbu	a4,0(a1)
 196:	00f71763          	bne	a4,a5,1a4 <strcmp+0x1e>
    p++, q++;
 19a:	0505                	addi	a0,a0,1
 19c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	fbe5                	bnez	a5,192 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a4:	0005c503          	lbu	a0,0(a1)
}
 1a8:	40a7853b          	subw	a0,a5,a0
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strlen>:

uint
strlen(const char *s)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cf91                	beqz	a5,1d8 <strlen+0x26>
 1be:	0505                	addi	a0,a0,1
 1c0:	87aa                	mv	a5,a0
 1c2:	86be                	mv	a3,a5
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff7c703          	lbu	a4,-1(a5)
 1ca:	ff65                	bnez	a4,1c2 <strlen+0x10>
 1cc:	40a6853b          	subw	a0,a3,a0
 1d0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret
  for(n = 0; s[n]; n++)
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <strlen+0x20>

00000000000001dc <memset>:

void*
memset(void *dst, int c, uint n)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e2:	ca19                	beqz	a2,1f8 <memset+0x1c>
 1e4:	87aa                	mv	a5,a0
 1e6:	1602                	slli	a2,a2,0x20
 1e8:	9201                	srli	a2,a2,0x20
 1ea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1ee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f2:	0785                	addi	a5,a5,1
 1f4:	fee79de3          	bne	a5,a4,1ee <memset+0x12>
  }
  return dst;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret

00000000000001fe <strchr>:

char*
strchr(const char *s, char c)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  for(; *s; s++)
 204:	00054783          	lbu	a5,0(a0)
 208:	cb99                	beqz	a5,21e <strchr+0x20>
    if(*s == c)
 20a:	00f58763          	beq	a1,a5,218 <strchr+0x1a>
  for(; *s; s++)
 20e:	0505                	addi	a0,a0,1
 210:	00054783          	lbu	a5,0(a0)
 214:	fbfd                	bnez	a5,20a <strchr+0xc>
      return (char*)s;
  return 0;
 216:	4501                	li	a0,0
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  return 0;
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <strchr+0x1a>

0000000000000222 <gets>:

char*
gets(char *buf, int max)
{
 222:	711d                	addi	sp,sp,-96
 224:	ec86                	sd	ra,88(sp)
 226:	e8a2                	sd	s0,80(sp)
 228:	e4a6                	sd	s1,72(sp)
 22a:	e0ca                	sd	s2,64(sp)
 22c:	fc4e                	sd	s3,56(sp)
 22e:	f852                	sd	s4,48(sp)
 230:	f456                	sd	s5,40(sp)
 232:	f05a                	sd	s6,32(sp)
 234:	ec5e                	sd	s7,24(sp)
 236:	1080                	addi	s0,sp,96
 238:	8baa                	mv	s7,a0
 23a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23c:	892a                	mv	s2,a0
 23e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 240:	4aa9                	li	s5,10
 242:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 244:	89a6                	mv	s3,s1
 246:	2485                	addiw	s1,s1,1
 248:	0344d663          	bge	s1,s4,274 <gets+0x52>
    cc = read(0, &c, 1);
 24c:	4605                	li	a2,1
 24e:	faf40593          	addi	a1,s0,-81
 252:	4501                	li	a0,0
 254:	1b2000ef          	jal	406 <read>
    if(cc < 1)
 258:	00a05e63          	blez	a0,274 <gets+0x52>
    buf[i++] = c;
 25c:	faf44783          	lbu	a5,-81(s0)
 260:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 264:	01578763          	beq	a5,s5,272 <gets+0x50>
 268:	0905                	addi	s2,s2,1
 26a:	fd679de3          	bne	a5,s6,244 <gets+0x22>
    buf[i++] = c;
 26e:	89a6                	mv	s3,s1
 270:	a011                	j	274 <gets+0x52>
 272:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 274:	99de                	add	s3,s3,s7
 276:	00098023          	sb	zero,0(s3)
  return buf;
}
 27a:	855e                	mv	a0,s7
 27c:	60e6                	ld	ra,88(sp)
 27e:	6446                	ld	s0,80(sp)
 280:	64a6                	ld	s1,72(sp)
 282:	6906                	ld	s2,64(sp)
 284:	79e2                	ld	s3,56(sp)
 286:	7a42                	ld	s4,48(sp)
 288:	7aa2                	ld	s5,40(sp)
 28a:	7b02                	ld	s6,32(sp)
 28c:	6be2                	ld	s7,24(sp)
 28e:	6125                	addi	sp,sp,96
 290:	8082                	ret

0000000000000292 <stat>:

int
stat(const char *n, struct stat *st)
{
 292:	1101                	addi	sp,sp,-32
 294:	ec06                	sd	ra,24(sp)
 296:	e822                	sd	s0,16(sp)
 298:	e04a                	sd	s2,0(sp)
 29a:	1000                	addi	s0,sp,32
 29c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29e:	4581                	li	a1,0
 2a0:	18e000ef          	jal	42e <open>
  if(fd < 0)
 2a4:	02054263          	bltz	a0,2c8 <stat+0x36>
 2a8:	e426                	sd	s1,8(sp)
 2aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ac:	85ca                	mv	a1,s2
 2ae:	198000ef          	jal	446 <fstat>
 2b2:	892a                	mv	s2,a0
  close(fd);
 2b4:	8526                	mv	a0,s1
 2b6:	160000ef          	jal	416 <close>
  return r;
 2ba:	64a2                	ld	s1,8(sp)
}
 2bc:	854a                	mv	a0,s2
 2be:	60e2                	ld	ra,24(sp)
 2c0:	6442                	ld	s0,16(sp)
 2c2:	6902                	ld	s2,0(sp)
 2c4:	6105                	addi	sp,sp,32
 2c6:	8082                	ret
    return -1;
 2c8:	597d                	li	s2,-1
 2ca:	bfcd                	j	2bc <stat+0x2a>

00000000000002cc <atoi>:

int
atoi(const char *s)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d2:	00054683          	lbu	a3,0(a0)
 2d6:	fd06879b          	addiw	a5,a3,-48
 2da:	0ff7f793          	zext.b	a5,a5
 2de:	4625                	li	a2,9
 2e0:	02f66863          	bltu	a2,a5,310 <atoi+0x44>
 2e4:	872a                	mv	a4,a0
  n = 0;
 2e6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e8:	0705                	addi	a4,a4,1
 2ea:	0025179b          	slliw	a5,a0,0x2
 2ee:	9fa9                	addw	a5,a5,a0
 2f0:	0017979b          	slliw	a5,a5,0x1
 2f4:	9fb5                	addw	a5,a5,a3
 2f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fa:	00074683          	lbu	a3,0(a4)
 2fe:	fd06879b          	addiw	a5,a3,-48
 302:	0ff7f793          	zext.b	a5,a5
 306:	fef671e3          	bgeu	a2,a5,2e8 <atoi+0x1c>
  return n;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret
  n = 0;
 310:	4501                	li	a0,0
 312:	bfe5                	j	30a <atoi+0x3e>

0000000000000314 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31a:	02b57463          	bgeu	a0,a1,342 <memmove+0x2e>
    while(n-- > 0)
 31e:	00c05f63          	blez	a2,33c <memmove+0x28>
 322:	1602                	slli	a2,a2,0x20
 324:	9201                	srli	a2,a2,0x20
 326:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32a:	872a                	mv	a4,a0
      *dst++ = *src++;
 32c:	0585                	addi	a1,a1,1
 32e:	0705                	addi	a4,a4,1
 330:	fff5c683          	lbu	a3,-1(a1)
 334:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 338:	fef71ae3          	bne	a4,a5,32c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
    dst += n;
 342:	00c50733          	add	a4,a0,a2
    src += n;
 346:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 348:	fec05ae3          	blez	a2,33c <memmove+0x28>
 34c:	fff6079b          	addiw	a5,a2,-1
 350:	1782                	slli	a5,a5,0x20
 352:	9381                	srli	a5,a5,0x20
 354:	fff7c793          	not	a5,a5
 358:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35a:	15fd                	addi	a1,a1,-1
 35c:	177d                	addi	a4,a4,-1
 35e:	0005c683          	lbu	a3,0(a1)
 362:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x46>
 36a:	bfc9                	j	33c <memmove+0x28>

000000000000036c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 372:	ca05                	beqz	a2,3a2 <memcmp+0x36>
 374:	fff6069b          	addiw	a3,a2,-1
 378:	1682                	slli	a3,a3,0x20
 37a:	9281                	srli	a3,a3,0x20
 37c:	0685                	addi	a3,a3,1
 37e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 380:	00054783          	lbu	a5,0(a0)
 384:	0005c703          	lbu	a4,0(a1)
 388:	00e79863          	bne	a5,a4,398 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38c:	0505                	addi	a0,a0,1
    p2++;
 38e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 390:	fed518e3          	bne	a0,a3,380 <memcmp+0x14>
  }
  return 0;
 394:	4501                	li	a0,0
 396:	a019                	j	39c <memcmp+0x30>
      return *p1 - *p2;
 398:	40e7853b          	subw	a0,a5,a4
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	bfe5                	j	39c <memcmp+0x30>

00000000000003a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ae:	f67ff0ef          	jal	314 <memmove>
}
 3b2:	60a2                	ld	ra,8(sp)
 3b4:	6402                	ld	s0,0(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <sbrk>:

char *
sbrk(int n) {
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c2:	4585                	li	a1,1
 3c4:	0b2000ef          	jal	476 <sys_sbrk>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <sbrklazy>:

char *
sbrklazy(int n) {
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3d8:	4589                	li	a1,2
 3da:	09c000ef          	jal	476 <sys_sbrk>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e6:	4885                	li	a7,1
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ee:	4889                	li	a7,2
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f6:	488d                	li	a7,3
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fe:	4891                	li	a7,4
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <read>:
.global read
read:
 li a7, SYS_read
 406:	4895                	li	a7,5
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <write>:
.global write
write:
 li a7, SYS_write
 40e:	48c1                	li	a7,16
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <close>:
.global close
close:
 li a7, SYS_close
 416:	48d5                	li	a7,21
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <kill>:
.global kill
kill:
 li a7, SYS_kill
 41e:	4899                	li	a7,6
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exec>:
.global exec
exec:
 li a7, SYS_exec
 426:	489d                	li	a7,7
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <open>:
.global open
open:
 li a7, SYS_open
 42e:	48bd                	li	a7,15
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 436:	48c5                	li	a7,17
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43e:	48c9                	li	a7,18
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 446:	48a1                	li	a7,8
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <link>:
.global link
link:
 li a7, SYS_link
 44e:	48cd                	li	a7,19
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 456:	48d1                	li	a7,20
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45e:	48a5                	li	a7,9
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <dup>:
.global dup
dup:
 li a7, SYS_dup
 466:	48a9                	li	a7,10
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46e:	48ad                	li	a7,11
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 476:	48b1                	li	a7,12
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <pause>:
.global pause
pause:
 li a7, SYS_pause
 47e:	48b5                	li	a7,13
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 486:	48b9                	li	a7,14
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 48e:	48d9                	li	a7,22
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 496:	48dd                	li	a7,23
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 49e:	48e1                	li	a7,24
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 4a6:	48e5                	li	a7,25
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ae:	1101                	addi	sp,sp,-32
 4b0:	ec06                	sd	ra,24(sp)
 4b2:	e822                	sd	s0,16(sp)
 4b4:	1000                	addi	s0,sp,32
 4b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ba:	4605                	li	a2,1
 4bc:	fef40593          	addi	a1,s0,-17
 4c0:	f4fff0ef          	jal	40e <write>
}
 4c4:	60e2                	ld	ra,24(sp)
 4c6:	6442                	ld	s0,16(sp)
 4c8:	6105                	addi	sp,sp,32
 4ca:	8082                	ret

00000000000004cc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4cc:	715d                	addi	sp,sp,-80
 4ce:	e486                	sd	ra,72(sp)
 4d0:	e0a2                	sd	s0,64(sp)
 4d2:	f84a                	sd	s2,48(sp)
 4d4:	0880                	addi	s0,sp,80
 4d6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4d8:	c299                	beqz	a3,4de <printint+0x12>
 4da:	0805c363          	bltz	a1,560 <printint+0x94>
  neg = 0;
 4de:	4881                	li	a7,0
 4e0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4e4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4e6:	00000517          	auipc	a0,0x0
 4ea:	7aa50513          	addi	a0,a0,1962 # c90 <digits>
 4ee:	883e                	mv	a6,a5
 4f0:	2785                	addiw	a5,a5,1
 4f2:	02c5f733          	remu	a4,a1,a2
 4f6:	972a                	add	a4,a4,a0
 4f8:	00074703          	lbu	a4,0(a4)
 4fc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 500:	872e                	mv	a4,a1
 502:	02c5d5b3          	divu	a1,a1,a2
 506:	0685                	addi	a3,a3,1
 508:	fec773e3          	bgeu	a4,a2,4ee <printint+0x22>
  if(neg)
 50c:	00088b63          	beqz	a7,522 <printint+0x56>
    buf[i++] = '-';
 510:	fd078793          	addi	a5,a5,-48
 514:	97a2                	add	a5,a5,s0
 516:	02d00713          	li	a4,45
 51a:	fee78423          	sb	a4,-24(a5)
 51e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 522:	02f05a63          	blez	a5,556 <printint+0x8a>
 526:	fc26                	sd	s1,56(sp)
 528:	f44e                	sd	s3,40(sp)
 52a:	fb840713          	addi	a4,s0,-72
 52e:	00f704b3          	add	s1,a4,a5
 532:	fff70993          	addi	s3,a4,-1
 536:	99be                	add	s3,s3,a5
 538:	37fd                	addiw	a5,a5,-1
 53a:	1782                	slli	a5,a5,0x20
 53c:	9381                	srli	a5,a5,0x20
 53e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 542:	fff4c583          	lbu	a1,-1(s1)
 546:	854a                	mv	a0,s2
 548:	f67ff0ef          	jal	4ae <putc>
  while(--i >= 0)
 54c:	14fd                	addi	s1,s1,-1
 54e:	ff349ae3          	bne	s1,s3,542 <printint+0x76>
 552:	74e2                	ld	s1,56(sp)
 554:	79a2                	ld	s3,40(sp)
}
 556:	60a6                	ld	ra,72(sp)
 558:	6406                	ld	s0,64(sp)
 55a:	7942                	ld	s2,48(sp)
 55c:	6161                	addi	sp,sp,80
 55e:	8082                	ret
    x = -xx;
 560:	40b005b3          	neg	a1,a1
    neg = 1;
 564:	4885                	li	a7,1
    x = -xx;
 566:	bfad                	j	4e0 <printint+0x14>

0000000000000568 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 568:	711d                	addi	sp,sp,-96
 56a:	ec86                	sd	ra,88(sp)
 56c:	e8a2                	sd	s0,80(sp)
 56e:	e0ca                	sd	s2,64(sp)
 570:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 572:	0005c903          	lbu	s2,0(a1)
 576:	28090663          	beqz	s2,802 <vprintf+0x29a>
 57a:	e4a6                	sd	s1,72(sp)
 57c:	fc4e                	sd	s3,56(sp)
 57e:	f852                	sd	s4,48(sp)
 580:	f456                	sd	s5,40(sp)
 582:	f05a                	sd	s6,32(sp)
 584:	ec5e                	sd	s7,24(sp)
 586:	e862                	sd	s8,16(sp)
 588:	e466                	sd	s9,8(sp)
 58a:	8b2a                	mv	s6,a0
 58c:	8a2e                	mv	s4,a1
 58e:	8bb2                	mv	s7,a2
  state = 0;
 590:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 592:	4481                	li	s1,0
 594:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 596:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 59a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 59e:	06c00c93          	li	s9,108
 5a2:	a005                	j	5c2 <vprintf+0x5a>
        putc(fd, c0);
 5a4:	85ca                	mv	a1,s2
 5a6:	855a                	mv	a0,s6
 5a8:	f07ff0ef          	jal	4ae <putc>
 5ac:	a019                	j	5b2 <vprintf+0x4a>
    } else if(state == '%'){
 5ae:	03598263          	beq	s3,s5,5d2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5b2:	2485                	addiw	s1,s1,1
 5b4:	8726                	mv	a4,s1
 5b6:	009a07b3          	add	a5,s4,s1
 5ba:	0007c903          	lbu	s2,0(a5)
 5be:	22090a63          	beqz	s2,7f2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5c2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c6:	fe0994e3          	bnez	s3,5ae <vprintf+0x46>
      if(c0 == '%'){
 5ca:	fd579de3          	bne	a5,s5,5a4 <vprintf+0x3c>
        state = '%';
 5ce:	89be                	mv	s3,a5
 5d0:	b7cd                	j	5b2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5d2:	00ea06b3          	add	a3,s4,a4
 5d6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5da:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5dc:	c681                	beqz	a3,5e4 <vprintf+0x7c>
 5de:	9752                	add	a4,a4,s4
 5e0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5e4:	05878363          	beq	a5,s8,62a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5e8:	05978d63          	beq	a5,s9,642 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ec:	07500713          	li	a4,117
 5f0:	0ee78763          	beq	a5,a4,6de <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5f4:	07800713          	li	a4,120
 5f8:	12e78963          	beq	a5,a4,72a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5fc:	07000713          	li	a4,112
 600:	14e78e63          	beq	a5,a4,75c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 604:	06300713          	li	a4,99
 608:	18e78e63          	beq	a5,a4,7a4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 60c:	07300713          	li	a4,115
 610:	1ae78463          	beq	a5,a4,7b8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 614:	02500713          	li	a4,37
 618:	04e79563          	bne	a5,a4,662 <vprintf+0xfa>
        putc(fd, '%');
 61c:	02500593          	li	a1,37
 620:	855a                	mv	a0,s6
 622:	e8dff0ef          	jal	4ae <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 626:	4981                	li	s3,0
 628:	b769                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 62a:	008b8913          	addi	s2,s7,8
 62e:	4685                	li	a3,1
 630:	4629                	li	a2,10
 632:	000ba583          	lw	a1,0(s7)
 636:	855a                	mv	a0,s6
 638:	e95ff0ef          	jal	4cc <printint>
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	bf8d                	j	5b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 642:	06400793          	li	a5,100
 646:	02f68963          	beq	a3,a5,678 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 64a:	06c00793          	li	a5,108
 64e:	04f68263          	beq	a3,a5,692 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 652:	07500793          	li	a5,117
 656:	0af68063          	beq	a3,a5,6f6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 65a:	07800793          	li	a5,120
 65e:	0ef68263          	beq	a3,a5,742 <vprintf+0x1da>
        putc(fd, '%');
 662:	02500593          	li	a1,37
 666:	855a                	mv	a0,s6
 668:	e47ff0ef          	jal	4ae <putc>
        putc(fd, c0);
 66c:	85ca                	mv	a1,s2
 66e:	855a                	mv	a0,s6
 670:	e3fff0ef          	jal	4ae <putc>
      state = 0;
 674:	4981                	li	s3,0
 676:	bf35                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 678:	008b8913          	addi	s2,s7,8
 67c:	4685                	li	a3,1
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e47ff0ef          	jal	4cc <printint>
        i += 1;
 68a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
        i += 1;
 690:	b70d                	j	5b2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 692:	06400793          	li	a5,100
 696:	02f60763          	beq	a2,a5,6c4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 69a:	07500793          	li	a5,117
 69e:	06f60963          	beq	a2,a5,710 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6a2:	07800793          	li	a5,120
 6a6:	faf61ee3          	bne	a2,a5,662 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	e15ff0ef          	jal	4cc <printint>
        i += 2;
 6bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 2;
 6c2:	bdc5                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4685                	li	a3,1
 6ca:	4629                	li	a2,10
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	dfbff0ef          	jal	4cc <printint>
        i += 2;
 6d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
        i += 2;
 6dc:	bdd9                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6de:	008b8913          	addi	s2,s7,8
 6e2:	4681                	li	a3,0
 6e4:	4629                	li	a2,10
 6e6:	000be583          	lwu	a1,0(s7)
 6ea:	855a                	mv	a0,s6
 6ec:	de1ff0ef          	jal	4cc <printint>
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd7d                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4681                	li	a3,0
 6fc:	4629                	li	a2,10
 6fe:	000bb583          	ld	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	dc9ff0ef          	jal	4cc <printint>
        i += 1;
 708:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
        i += 1;
 70e:	b555                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	008b8913          	addi	s2,s7,8
 714:	4681                	li	a3,0
 716:	4629                	li	a2,10
 718:	000bb583          	ld	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	dafff0ef          	jal	4cc <printint>
        i += 2;
 722:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
        i += 2;
 728:	b569                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 72a:	008b8913          	addi	s2,s7,8
 72e:	4681                	li	a3,0
 730:	4641                	li	a2,16
 732:	000be583          	lwu	a1,0(s7)
 736:	855a                	mv	a0,s6
 738:	d95ff0ef          	jal	4cc <printint>
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bd8d                	j	5b2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 742:	008b8913          	addi	s2,s7,8
 746:	4681                	li	a3,0
 748:	4641                	li	a2,16
 74a:	000bb583          	ld	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	d7dff0ef          	jal	4cc <printint>
        i += 1;
 754:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	8bca                	mv	s7,s2
      state = 0;
 758:	4981                	li	s3,0
        i += 1;
 75a:	bda1                	j	5b2 <vprintf+0x4a>
 75c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 75e:	008b8d13          	addi	s10,s7,8
 762:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 766:	03000593          	li	a1,48
 76a:	855a                	mv	a0,s6
 76c:	d43ff0ef          	jal	4ae <putc>
  putc(fd, 'x');
 770:	07800593          	li	a1,120
 774:	855a                	mv	a0,s6
 776:	d39ff0ef          	jal	4ae <putc>
 77a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 77c:	00000b97          	auipc	s7,0x0
 780:	514b8b93          	addi	s7,s7,1300 # c90 <digits>
 784:	03c9d793          	srli	a5,s3,0x3c
 788:	97de                	add	a5,a5,s7
 78a:	0007c583          	lbu	a1,0(a5)
 78e:	855a                	mv	a0,s6
 790:	d1fff0ef          	jal	4ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 794:	0992                	slli	s3,s3,0x4
 796:	397d                	addiw	s2,s2,-1
 798:	fe0916e3          	bnez	s2,784 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 79c:	8bea                	mv	s7,s10
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	6d02                	ld	s10,0(sp)
 7a2:	bd01                	j	5b2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7a4:	008b8913          	addi	s2,s7,8
 7a8:	000bc583          	lbu	a1,0(s7)
 7ac:	855a                	mv	a0,s6
 7ae:	d01ff0ef          	jal	4ae <putc>
 7b2:	8bca                	mv	s7,s2
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	bbf5                	j	5b2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b8:	008b8993          	addi	s3,s7,8
 7bc:	000bb903          	ld	s2,0(s7)
 7c0:	00090f63          	beqz	s2,7de <vprintf+0x276>
        for(; *s; s++)
 7c4:	00094583          	lbu	a1,0(s2)
 7c8:	c195                	beqz	a1,7ec <vprintf+0x284>
          putc(fd, *s);
 7ca:	855a                	mv	a0,s6
 7cc:	ce3ff0ef          	jal	4ae <putc>
        for(; *s; s++)
 7d0:	0905                	addi	s2,s2,1
 7d2:	00094583          	lbu	a1,0(s2)
 7d6:	f9f5                	bnez	a1,7ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7d8:	8bce                	mv	s7,s3
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bbd9                	j	5b2 <vprintf+0x4a>
          s = "(null)";
 7de:	00000917          	auipc	s2,0x0
 7e2:	4aa90913          	addi	s2,s2,1194 # c88 <malloc+0x39e>
        for(; *s; s++)
 7e6:	02800593          	li	a1,40
 7ea:	b7c5                	j	7ca <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ec:	8bce                	mv	s7,s3
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	b3c9                	j	5b2 <vprintf+0x4a>
 7f2:	64a6                	ld	s1,72(sp)
 7f4:	79e2                	ld	s3,56(sp)
 7f6:	7a42                	ld	s4,48(sp)
 7f8:	7aa2                	ld	s5,40(sp)
 7fa:	7b02                	ld	s6,32(sp)
 7fc:	6be2                	ld	s7,24(sp)
 7fe:	6c42                	ld	s8,16(sp)
 800:	6ca2                	ld	s9,8(sp)
    }
  }
}
 802:	60e6                	ld	ra,88(sp)
 804:	6446                	ld	s0,80(sp)
 806:	6906                	ld	s2,64(sp)
 808:	6125                	addi	sp,sp,96
 80a:	8082                	ret

000000000000080c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80c:	715d                	addi	sp,sp,-80
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e010                	sd	a2,0(s0)
 816:	e414                	sd	a3,8(s0)
 818:	e818                	sd	a4,16(s0)
 81a:	ec1c                	sd	a5,24(s0)
 81c:	03043023          	sd	a6,32(s0)
 820:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 824:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 828:	8622                	mv	a2,s0
 82a:	d3fff0ef          	jal	568 <vprintf>
}
 82e:	60e2                	ld	ra,24(sp)
 830:	6442                	ld	s0,16(sp)
 832:	6161                	addi	sp,sp,80
 834:	8082                	ret

0000000000000836 <printf>:

void
printf(const char *fmt, ...)
{
 836:	711d                	addi	sp,sp,-96
 838:	ec06                	sd	ra,24(sp)
 83a:	e822                	sd	s0,16(sp)
 83c:	1000                	addi	s0,sp,32
 83e:	e40c                	sd	a1,8(s0)
 840:	e810                	sd	a2,16(s0)
 842:	ec14                	sd	a3,24(s0)
 844:	f018                	sd	a4,32(s0)
 846:	f41c                	sd	a5,40(s0)
 848:	03043823          	sd	a6,48(s0)
 84c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 850:	00840613          	addi	a2,s0,8
 854:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 858:	85aa                	mv	a1,a0
 85a:	4505                	li	a0,1
 85c:	d0dff0ef          	jal	568 <vprintf>
}
 860:	60e2                	ld	ra,24(sp)
 862:	6442                	ld	s0,16(sp)
 864:	6125                	addi	sp,sp,96
 866:	8082                	ret

0000000000000868 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 868:	1141                	addi	sp,sp,-16
 86a:	e422                	sd	s0,8(sp)
 86c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 86e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 872:	00000797          	auipc	a5,0x0
 876:	78e7b783          	ld	a5,1934(a5) # 1000 <freep>
 87a:	a02d                	j	8a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 87c:	4618                	lw	a4,8(a2)
 87e:	9f2d                	addw	a4,a4,a1
 880:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 884:	6398                	ld	a4,0(a5)
 886:	6310                	ld	a2,0(a4)
 888:	a83d                	j	8c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 88a:	ff852703          	lw	a4,-8(a0)
 88e:	9f31                	addw	a4,a4,a2
 890:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 892:	ff053683          	ld	a3,-16(a0)
 896:	a091                	j	8da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 898:	6398                	ld	a4,0(a5)
 89a:	00e7e463          	bltu	a5,a4,8a2 <free+0x3a>
 89e:	00e6ea63          	bltu	a3,a4,8b2 <free+0x4a>
{
 8a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a4:	fed7fae3          	bgeu	a5,a3,898 <free+0x30>
 8a8:	6398                	ld	a4,0(a5)
 8aa:	00e6e463          	bltu	a3,a4,8b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ae:	fee7eae3          	bltu	a5,a4,8a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8b2:	ff852583          	lw	a1,-8(a0)
 8b6:	6390                	ld	a2,0(a5)
 8b8:	02059813          	slli	a6,a1,0x20
 8bc:	01c85713          	srli	a4,a6,0x1c
 8c0:	9736                	add	a4,a4,a3
 8c2:	fae60de3          	beq	a2,a4,87c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ca:	4790                	lw	a2,8(a5)
 8cc:	02061593          	slli	a1,a2,0x20
 8d0:	01c5d713          	srli	a4,a1,0x1c
 8d4:	973e                	add	a4,a4,a5
 8d6:	fae68ae3          	beq	a3,a4,88a <free+0x22>
    p->s.ptr = bp->s.ptr;
 8da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8dc:	00000717          	auipc	a4,0x0
 8e0:	72f73223          	sd	a5,1828(a4) # 1000 <freep>
}
 8e4:	6422                	ld	s0,8(sp)
 8e6:	0141                	addi	sp,sp,16
 8e8:	8082                	ret

00000000000008ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ea:	7139                	addi	sp,sp,-64
 8ec:	fc06                	sd	ra,56(sp)
 8ee:	f822                	sd	s0,48(sp)
 8f0:	f426                	sd	s1,40(sp)
 8f2:	ec4e                	sd	s3,24(sp)
 8f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f6:	02051493          	slli	s1,a0,0x20
 8fa:	9081                	srli	s1,s1,0x20
 8fc:	04bd                	addi	s1,s1,15
 8fe:	8091                	srli	s1,s1,0x4
 900:	0014899b          	addiw	s3,s1,1
 904:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 906:	00000517          	auipc	a0,0x0
 90a:	6fa53503          	ld	a0,1786(a0) # 1000 <freep>
 90e:	c915                	beqz	a0,942 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 910:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 912:	4798                	lw	a4,8(a5)
 914:	08977a63          	bgeu	a4,s1,9a8 <malloc+0xbe>
 918:	f04a                	sd	s2,32(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 920:	8a4e                	mv	s4,s3
 922:	0009871b          	sext.w	a4,s3
 926:	6685                	lui	a3,0x1
 928:	00d77363          	bgeu	a4,a3,92e <malloc+0x44>
 92c:	6a05                	lui	s4,0x1
 92e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 932:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 936:	00000917          	auipc	s2,0x0
 93a:	6ca90913          	addi	s2,s2,1738 # 1000 <freep>
  if(p == SBRK_ERROR)
 93e:	5afd                	li	s5,-1
 940:	a081                	j	980 <malloc+0x96>
 942:	f04a                	sd	s2,32(sp)
 944:	e852                	sd	s4,16(sp)
 946:	e456                	sd	s5,8(sp)
 948:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 94a:	00000797          	auipc	a5,0x0
 94e:	6c678793          	addi	a5,a5,1734 # 1010 <base>
 952:	00000717          	auipc	a4,0x0
 956:	6af73723          	sd	a5,1710(a4) # 1000 <freep>
 95a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 960:	b7c1                	j	920 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 962:	6398                	ld	a4,0(a5)
 964:	e118                	sd	a4,0(a0)
 966:	a8a9                	j	9c0 <malloc+0xd6>
  hp->s.size = nu;
 968:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96c:	0541                	addi	a0,a0,16
 96e:	efbff0ef          	jal	868 <free>
  return freep;
 972:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 976:	c12d                	beqz	a0,9d8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 978:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97a:	4798                	lw	a4,8(a5)
 97c:	02977263          	bgeu	a4,s1,9a0 <malloc+0xb6>
    if(p == freep)
 980:	00093703          	ld	a4,0(s2)
 984:	853e                	mv	a0,a5
 986:	fef719e3          	bne	a4,a5,978 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 98a:	8552                	mv	a0,s4
 98c:	a2fff0ef          	jal	3ba <sbrk>
  if(p == SBRK_ERROR)
 990:	fd551ce3          	bne	a0,s5,968 <malloc+0x7e>
        return 0;
 994:	4501                	li	a0,0
 996:	7902                	ld	s2,32(sp)
 998:	6a42                	ld	s4,16(sp)
 99a:	6aa2                	ld	s5,8(sp)
 99c:	6b02                	ld	s6,0(sp)
 99e:	a03d                	j	9cc <malloc+0xe2>
 9a0:	7902                	ld	s2,32(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a8:	fae48de3          	beq	s1,a4,962 <malloc+0x78>
        p->s.size -= nunits;
 9ac:	4137073b          	subw	a4,a4,s3
 9b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b2:	02071693          	slli	a3,a4,0x20
 9b6:	01c6d713          	srli	a4,a3,0x1c
 9ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	64a73023          	sd	a0,1600(a4) # 1000 <freep>
      return (void*)(p + 1);
 9c8:	01078513          	addi	a0,a5,16
  }
}
 9cc:	70e2                	ld	ra,56(sp)
 9ce:	7442                	ld	s0,48(sp)
 9d0:	74a2                	ld	s1,40(sp)
 9d2:	69e2                	ld	s3,24(sp)
 9d4:	6121                	addi	sp,sp,64
 9d6:	8082                	ret
 9d8:	7902                	ld	s2,32(sp)
 9da:	6a42                	ld	s4,16(sp)
 9dc:	6aa2                	ld	s5,8(sp)
 9de:	6b02                	ld	s6,0(sp)
 9e0:	b7f5                	j	9cc <malloc+0xe2>
