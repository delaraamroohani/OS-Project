
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
  10:	10b000ef          	jal	91a <malloc>
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
  2c:	a1050513          	addi	a0,a0,-1520 # a38 <malloc+0x11e>
  30:	037000ef          	jal	866 <printf>
  
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
  52:	b2250513          	addi	a0,a0,-1246 # b70 <malloc+0x256>
  56:	011000ef          	jal	866 <printf>
  printf("Parent: after child write, buffer value = %c\n", buf[0]);
  5a:	0004c583          	lbu	a1,0(s1)
  5e:	00001517          	auipc	a0,0x1
  62:	b4a50513          	addi	a0,a0,-1206 # ba8 <malloc+0x28e>
  66:	001000ef          	jal	866 <printf>
  
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
  7a:	b9a50513          	addi	a0,a0,-1126 # c10 <malloc+0x2f6>
  7e:	7e8000ef          	jal	866 <printf>
  }
  
  if(parent_page_before == parent_page_after) {
  82:	0d390563          	beq	s2,s3,14c <main+0x14c>
    printf("Parent's page number unchanged.\n");
  } else {
    printf("Parent's page number changed (expected if refcount dropped to 1).\n");
  86:	00001517          	auipc	a0,0x1
  8a:	bea50513          	addi	a0,a0,-1046 # c70 <malloc+0x356>
  8e:	7d8000ef          	jal	866 <printf>
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
  a6:	97e50513          	addi	a0,a0,-1666 # a20 <malloc+0x106>
  aa:	7bc000ef          	jal	866 <printf>
    exit(1);
  ae:	4505                	li	a0,1
  b0:	33e000ef          	jal	3ee <exit>
    printf("cowfork failed\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	9ac50513          	addi	a0,a0,-1620 # a60 <malloc+0x146>
  bc:	7aa000ef          	jal	866 <printf>
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
  d4:	9a050513          	addi	a0,a0,-1632 # a70 <malloc+0x156>
  d8:	78e000ef          	jal	866 <printf>
    printf("Child: initial buffer val = %c\n", buf[0]);
  dc:	0004c583          	lbu	a1,0(s1)
  e0:	00001517          	auipc	a0,0x1
  e4:	9b850513          	addi	a0,a0,-1608 # a98 <malloc+0x17e>
  e8:	77e000ef          	jal	866 <printf>
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
 102:	9ba50513          	addi	a0,a0,-1606 # ab8 <malloc+0x19e>
 106:	760000ef          	jal	866 <printf>
    printf("Child: buffer value after write: %c\n", buf[0]);
 10a:	0004c583          	lbu	a1,0(s1)
 10e:	00001517          	auipc	a0,0x1
 112:	9d250513          	addi	a0,a0,-1582 # ae0 <malloc+0x1c6>
 116:	750000ef          	jal	866 <printf>
    if(child_page_before == child_page_after) {
 11a:	01298b63          	beq	s3,s2,130 <main+0x130>
      printf("SUCCESS: Page changed after write (COW worked!)\n");
 11e:	00001517          	auipc	a0,0x1
 122:	a1a50513          	addi	a0,a0,-1510 # b38 <malloc+0x21e>
 126:	740000ef          	jal	866 <printf>
    exit(0);
 12a:	4501                	li	a0,0
 12c:	2c2000ef          	jal	3ee <exit>
      printf("ERROR: Page should have changed after write!\n");
 130:	00001517          	auipc	a0,0x1
 134:	9d850513          	addi	a0,a0,-1576 # b08 <malloc+0x1ee>
 138:	72e000ef          	jal	866 <printf>
 13c:	b7fd                	j	12a <main+0x12a>
    printf("SUCCESS: Parent's data unchanged by child's write!\n");
 13e:	00001517          	auipc	a0,0x1
 142:	a9a50513          	addi	a0,a0,-1382 # bd8 <malloc+0x2be>
 146:	720000ef          	jal	866 <printf>
 14a:	bf25                	j	82 <main+0x82>
    printf("Parent's page number unchanged.\n");
 14c:	00001517          	auipc	a0,0x1
 150:	afc50513          	addi	a0,a0,-1284 # c48 <malloc+0x32e>
 154:	712000ef          	jal	866 <printf>
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

00000000000004ae <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 4ae:	48e9                	li	a7,26
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 4b6:	48ed                	li	a7,27
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 4be:	48f1                	li	a7,28
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 4c6:	48f5                	li	a7,29
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 4ce:	48f9                	li	a7,30
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 4d6:	48fd                	li	a7,31
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4de:	1101                	addi	sp,sp,-32
 4e0:	ec06                	sd	ra,24(sp)
 4e2:	e822                	sd	s0,16(sp)
 4e4:	1000                	addi	s0,sp,32
 4e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ea:	4605                	li	a2,1
 4ec:	fef40593          	addi	a1,s0,-17
 4f0:	f1fff0ef          	jal	40e <write>
}
 4f4:	60e2                	ld	ra,24(sp)
 4f6:	6442                	ld	s0,16(sp)
 4f8:	6105                	addi	sp,sp,32
 4fa:	8082                	ret

00000000000004fc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4fc:	715d                	addi	sp,sp,-80
 4fe:	e486                	sd	ra,72(sp)
 500:	e0a2                	sd	s0,64(sp)
 502:	f84a                	sd	s2,48(sp)
 504:	0880                	addi	s0,sp,80
 506:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 508:	c299                	beqz	a3,50e <printint+0x12>
 50a:	0805c363          	bltz	a1,590 <printint+0x94>
  neg = 0;
 50e:	4881                	li	a7,0
 510:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 514:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 516:	00000517          	auipc	a0,0x0
 51a:	7aa50513          	addi	a0,a0,1962 # cc0 <digits>
 51e:	883e                	mv	a6,a5
 520:	2785                	addiw	a5,a5,1
 522:	02c5f733          	remu	a4,a1,a2
 526:	972a                	add	a4,a4,a0
 528:	00074703          	lbu	a4,0(a4)
 52c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 530:	872e                	mv	a4,a1
 532:	02c5d5b3          	divu	a1,a1,a2
 536:	0685                	addi	a3,a3,1
 538:	fec773e3          	bgeu	a4,a2,51e <printint+0x22>
  if(neg)
 53c:	00088b63          	beqz	a7,552 <printint+0x56>
    buf[i++] = '-';
 540:	fd078793          	addi	a5,a5,-48
 544:	97a2                	add	a5,a5,s0
 546:	02d00713          	li	a4,45
 54a:	fee78423          	sb	a4,-24(a5)
 54e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 552:	02f05a63          	blez	a5,586 <printint+0x8a>
 556:	fc26                	sd	s1,56(sp)
 558:	f44e                	sd	s3,40(sp)
 55a:	fb840713          	addi	a4,s0,-72
 55e:	00f704b3          	add	s1,a4,a5
 562:	fff70993          	addi	s3,a4,-1
 566:	99be                	add	s3,s3,a5
 568:	37fd                	addiw	a5,a5,-1
 56a:	1782                	slli	a5,a5,0x20
 56c:	9381                	srli	a5,a5,0x20
 56e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 572:	fff4c583          	lbu	a1,-1(s1)
 576:	854a                	mv	a0,s2
 578:	f67ff0ef          	jal	4de <putc>
  while(--i >= 0)
 57c:	14fd                	addi	s1,s1,-1
 57e:	ff349ae3          	bne	s1,s3,572 <printint+0x76>
 582:	74e2                	ld	s1,56(sp)
 584:	79a2                	ld	s3,40(sp)
}
 586:	60a6                	ld	ra,72(sp)
 588:	6406                	ld	s0,64(sp)
 58a:	7942                	ld	s2,48(sp)
 58c:	6161                	addi	sp,sp,80
 58e:	8082                	ret
    x = -xx;
 590:	40b005b3          	neg	a1,a1
    neg = 1;
 594:	4885                	li	a7,1
    x = -xx;
 596:	bfad                	j	510 <printint+0x14>

0000000000000598 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 598:	711d                	addi	sp,sp,-96
 59a:	ec86                	sd	ra,88(sp)
 59c:	e8a2                	sd	s0,80(sp)
 59e:	e0ca                	sd	s2,64(sp)
 5a0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a2:	0005c903          	lbu	s2,0(a1)
 5a6:	28090663          	beqz	s2,832 <vprintf+0x29a>
 5aa:	e4a6                	sd	s1,72(sp)
 5ac:	fc4e                	sd	s3,56(sp)
 5ae:	f852                	sd	s4,48(sp)
 5b0:	f456                	sd	s5,40(sp)
 5b2:	f05a                	sd	s6,32(sp)
 5b4:	ec5e                	sd	s7,24(sp)
 5b6:	e862                	sd	s8,16(sp)
 5b8:	e466                	sd	s9,8(sp)
 5ba:	8b2a                	mv	s6,a0
 5bc:	8a2e                	mv	s4,a1
 5be:	8bb2                	mv	s7,a2
  state = 0;
 5c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c2:	4481                	li	s1,0
 5c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	06c00c93          	li	s9,108
 5d2:	a005                	j	5f2 <vprintf+0x5a>
        putc(fd, c0);
 5d4:	85ca                	mv	a1,s2
 5d6:	855a                	mv	a0,s6
 5d8:	f07ff0ef          	jal	4de <putc>
 5dc:	a019                	j	5e2 <vprintf+0x4a>
    } else if(state == '%'){
 5de:	03598263          	beq	s3,s5,602 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5e2:	2485                	addiw	s1,s1,1
 5e4:	8726                	mv	a4,s1
 5e6:	009a07b3          	add	a5,s4,s1
 5ea:	0007c903          	lbu	s2,0(a5)
 5ee:	22090a63          	beqz	s2,822 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5f2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f6:	fe0994e3          	bnez	s3,5de <vprintf+0x46>
      if(c0 == '%'){
 5fa:	fd579de3          	bne	a5,s5,5d4 <vprintf+0x3c>
        state = '%';
 5fe:	89be                	mv	s3,a5
 600:	b7cd                	j	5e2 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 602:	00ea06b3          	add	a3,s4,a4
 606:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60c:	c681                	beqz	a3,614 <vprintf+0x7c>
 60e:	9752                	add	a4,a4,s4
 610:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 614:	05878363          	beq	a5,s8,65a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 618:	05978d63          	beq	a5,s9,672 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 61c:	07500713          	li	a4,117
 620:	0ee78763          	beq	a5,a4,70e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 624:	07800713          	li	a4,120
 628:	12e78963          	beq	a5,a4,75a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62c:	07000713          	li	a4,112
 630:	14e78e63          	beq	a5,a4,78c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 634:	06300713          	li	a4,99
 638:	18e78e63          	beq	a5,a4,7d4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63c:	07300713          	li	a4,115
 640:	1ae78463          	beq	a5,a4,7e8 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 644:	02500713          	li	a4,37
 648:	04e79563          	bne	a5,a4,692 <vprintf+0xfa>
        putc(fd, '%');
 64c:	02500593          	li	a1,37
 650:	855a                	mv	a0,s6
 652:	e8dff0ef          	jal	4de <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 656:	4981                	li	s3,0
 658:	b769                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000ba583          	lw	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	e95ff0ef          	jal	4fc <printint>
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
 670:	bf8d                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 672:	06400793          	li	a5,100
 676:	02f68963          	beq	a3,a5,6a8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 67a:	06c00793          	li	a5,108
 67e:	04f68263          	beq	a3,a5,6c2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 682:	07500793          	li	a5,117
 686:	0af68063          	beq	a3,a5,726 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 68a:	07800793          	li	a5,120
 68e:	0ef68263          	beq	a3,a5,772 <vprintf+0x1da>
        putc(fd, '%');
 692:	02500593          	li	a1,37
 696:	855a                	mv	a0,s6
 698:	e47ff0ef          	jal	4de <putc>
        putc(fd, c0);
 69c:	85ca                	mv	a1,s2
 69e:	855a                	mv	a0,s6
 6a0:	e3fff0ef          	jal	4de <putc>
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bf35                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a8:	008b8913          	addi	s2,s7,8
 6ac:	4685                	li	a3,1
 6ae:	4629                	li	a2,10
 6b0:	000bb583          	ld	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	e47ff0ef          	jal	4fc <printint>
        i += 1;
 6ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
        i += 1;
 6c0:	b70d                	j	5e2 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c2:	06400793          	li	a5,100
 6c6:	02f60763          	beq	a2,a5,6f4 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ca:	07500793          	li	a5,117
 6ce:	06f60963          	beq	a2,a5,740 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6d2:	07800793          	li	a5,120
 6d6:	faf61ee3          	bne	a2,a5,692 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4681                	li	a3,0
 6e0:	4641                	li	a2,16
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	e15ff0ef          	jal	4fc <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdc5                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4685                	li	a3,1
 6fa:	4629                	li	a2,10
 6fc:	000bb583          	ld	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	dfbff0ef          	jal	4fc <printint>
        i += 2;
 706:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 708:	8bca                	mv	s7,s2
      state = 0;
 70a:	4981                	li	s3,0
        i += 2;
 70c:	bdd9                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 70e:	008b8913          	addi	s2,s7,8
 712:	4681                	li	a3,0
 714:	4629                	li	a2,10
 716:	000be583          	lwu	a1,0(s7)
 71a:	855a                	mv	a0,s6
 71c:	de1ff0ef          	jal	4fc <printint>
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bd7d                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	dc9ff0ef          	jal	4fc <printint>
        i += 1;
 738:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 1;
 73e:	b555                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4629                	li	a2,10
 748:	000bb583          	ld	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	dafff0ef          	jal	4fc <printint>
        i += 2;
 752:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 754:	8bca                	mv	s7,s2
      state = 0;
 756:	4981                	li	s3,0
        i += 2;
 758:	b569                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 75a:	008b8913          	addi	s2,s7,8
 75e:	4681                	li	a3,0
 760:	4641                	li	a2,16
 762:	000be583          	lwu	a1,0(s7)
 766:	855a                	mv	a0,s6
 768:	d95ff0ef          	jal	4fc <printint>
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bd8d                	j	5e2 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 772:	008b8913          	addi	s2,s7,8
 776:	4681                	li	a3,0
 778:	4641                	li	a2,16
 77a:	000bb583          	ld	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	d7dff0ef          	jal	4fc <printint>
        i += 1;
 784:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 786:	8bca                	mv	s7,s2
      state = 0;
 788:	4981                	li	s3,0
        i += 1;
 78a:	bda1                	j	5e2 <vprintf+0x4a>
 78c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 78e:	008b8d13          	addi	s10,s7,8
 792:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 796:	03000593          	li	a1,48
 79a:	855a                	mv	a0,s6
 79c:	d43ff0ef          	jal	4de <putc>
  putc(fd, 'x');
 7a0:	07800593          	li	a1,120
 7a4:	855a                	mv	a0,s6
 7a6:	d39ff0ef          	jal	4de <putc>
 7aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ac:	00000b97          	auipc	s7,0x0
 7b0:	514b8b93          	addi	s7,s7,1300 # cc0 <digits>
 7b4:	03c9d793          	srli	a5,s3,0x3c
 7b8:	97de                	add	a5,a5,s7
 7ba:	0007c583          	lbu	a1,0(a5)
 7be:	855a                	mv	a0,s6
 7c0:	d1fff0ef          	jal	4de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c4:	0992                	slli	s3,s3,0x4
 7c6:	397d                	addiw	s2,s2,-1
 7c8:	fe0916e3          	bnez	s2,7b4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7cc:	8bea                	mv	s7,s10
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	6d02                	ld	s10,0(sp)
 7d2:	bd01                	j	5e2 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7d4:	008b8913          	addi	s2,s7,8
 7d8:	000bc583          	lbu	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	d01ff0ef          	jal	4de <putc>
 7e2:	8bca                	mv	s7,s2
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	bbf5                	j	5e2 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7e8:	008b8993          	addi	s3,s7,8
 7ec:	000bb903          	ld	s2,0(s7)
 7f0:	00090f63          	beqz	s2,80e <vprintf+0x276>
        for(; *s; s++)
 7f4:	00094583          	lbu	a1,0(s2)
 7f8:	c195                	beqz	a1,81c <vprintf+0x284>
          putc(fd, *s);
 7fa:	855a                	mv	a0,s6
 7fc:	ce3ff0ef          	jal	4de <putc>
        for(; *s; s++)
 800:	0905                	addi	s2,s2,1
 802:	00094583          	lbu	a1,0(s2)
 806:	f9f5                	bnez	a1,7fa <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 808:	8bce                	mv	s7,s3
      state = 0;
 80a:	4981                	li	s3,0
 80c:	bbd9                	j	5e2 <vprintf+0x4a>
          s = "(null)";
 80e:	00000917          	auipc	s2,0x0
 812:	4aa90913          	addi	s2,s2,1194 # cb8 <malloc+0x39e>
        for(; *s; s++)
 816:	02800593          	li	a1,40
 81a:	b7c5                	j	7fa <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 81c:	8bce                	mv	s7,s3
      state = 0;
 81e:	4981                	li	s3,0
 820:	b3c9                	j	5e2 <vprintf+0x4a>
 822:	64a6                	ld	s1,72(sp)
 824:	79e2                	ld	s3,56(sp)
 826:	7a42                	ld	s4,48(sp)
 828:	7aa2                	ld	s5,40(sp)
 82a:	7b02                	ld	s6,32(sp)
 82c:	6be2                	ld	s7,24(sp)
 82e:	6c42                	ld	s8,16(sp)
 830:	6ca2                	ld	s9,8(sp)
    }
  }
}
 832:	60e6                	ld	ra,88(sp)
 834:	6446                	ld	s0,80(sp)
 836:	6906                	ld	s2,64(sp)
 838:	6125                	addi	sp,sp,96
 83a:	8082                	ret

000000000000083c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 83c:	715d                	addi	sp,sp,-80
 83e:	ec06                	sd	ra,24(sp)
 840:	e822                	sd	s0,16(sp)
 842:	1000                	addi	s0,sp,32
 844:	e010                	sd	a2,0(s0)
 846:	e414                	sd	a3,8(s0)
 848:	e818                	sd	a4,16(s0)
 84a:	ec1c                	sd	a5,24(s0)
 84c:	03043023          	sd	a6,32(s0)
 850:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 854:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 858:	8622                	mv	a2,s0
 85a:	d3fff0ef          	jal	598 <vprintf>
}
 85e:	60e2                	ld	ra,24(sp)
 860:	6442                	ld	s0,16(sp)
 862:	6161                	addi	sp,sp,80
 864:	8082                	ret

0000000000000866 <printf>:

void
printf(const char *fmt, ...)
{
 866:	711d                	addi	sp,sp,-96
 868:	ec06                	sd	ra,24(sp)
 86a:	e822                	sd	s0,16(sp)
 86c:	1000                	addi	s0,sp,32
 86e:	e40c                	sd	a1,8(s0)
 870:	e810                	sd	a2,16(s0)
 872:	ec14                	sd	a3,24(s0)
 874:	f018                	sd	a4,32(s0)
 876:	f41c                	sd	a5,40(s0)
 878:	03043823          	sd	a6,48(s0)
 87c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 880:	00840613          	addi	a2,s0,8
 884:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 888:	85aa                	mv	a1,a0
 88a:	4505                	li	a0,1
 88c:	d0dff0ef          	jal	598 <vprintf>
}
 890:	60e2                	ld	ra,24(sp)
 892:	6442                	ld	s0,16(sp)
 894:	6125                	addi	sp,sp,96
 896:	8082                	ret

0000000000000898 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 898:	1141                	addi	sp,sp,-16
 89a:	e422                	sd	s0,8(sp)
 89c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 89e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a2:	00000797          	auipc	a5,0x0
 8a6:	75e7b783          	ld	a5,1886(a5) # 1000 <freep>
 8aa:	a02d                	j	8d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ac:	4618                	lw	a4,8(a2)
 8ae:	9f2d                	addw	a4,a4,a1
 8b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b4:	6398                	ld	a4,0(a5)
 8b6:	6310                	ld	a2,0(a4)
 8b8:	a83d                	j	8f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ba:	ff852703          	lw	a4,-8(a0)
 8be:	9f31                	addw	a4,a4,a2
 8c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c2:	ff053683          	ld	a3,-16(a0)
 8c6:	a091                	j	90a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c8:	6398                	ld	a4,0(a5)
 8ca:	00e7e463          	bltu	a5,a4,8d2 <free+0x3a>
 8ce:	00e6ea63          	bltu	a3,a4,8e2 <free+0x4a>
{
 8d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d4:	fed7fae3          	bgeu	a5,a3,8c8 <free+0x30>
 8d8:	6398                	ld	a4,0(a5)
 8da:	00e6e463          	bltu	a3,a4,8e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8de:	fee7eae3          	bltu	a5,a4,8d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8e2:	ff852583          	lw	a1,-8(a0)
 8e6:	6390                	ld	a2,0(a5)
 8e8:	02059813          	slli	a6,a1,0x20
 8ec:	01c85713          	srli	a4,a6,0x1c
 8f0:	9736                	add	a4,a4,a3
 8f2:	fae60de3          	beq	a2,a4,8ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8fa:	4790                	lw	a2,8(a5)
 8fc:	02061593          	slli	a1,a2,0x20
 900:	01c5d713          	srli	a4,a1,0x1c
 904:	973e                	add	a4,a4,a5
 906:	fae68ae3          	beq	a3,a4,8ba <free+0x22>
    p->s.ptr = bp->s.ptr;
 90a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 90c:	00000717          	auipc	a4,0x0
 910:	6ef73a23          	sd	a5,1780(a4) # 1000 <freep>
}
 914:	6422                	ld	s0,8(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret

000000000000091a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 91a:	7139                	addi	sp,sp,-64
 91c:	fc06                	sd	ra,56(sp)
 91e:	f822                	sd	s0,48(sp)
 920:	f426                	sd	s1,40(sp)
 922:	ec4e                	sd	s3,24(sp)
 924:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 926:	02051493          	slli	s1,a0,0x20
 92a:	9081                	srli	s1,s1,0x20
 92c:	04bd                	addi	s1,s1,15
 92e:	8091                	srli	s1,s1,0x4
 930:	0014899b          	addiw	s3,s1,1
 934:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 936:	00000517          	auipc	a0,0x0
 93a:	6ca53503          	ld	a0,1738(a0) # 1000 <freep>
 93e:	c915                	beqz	a0,972 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 942:	4798                	lw	a4,8(a5)
 944:	08977a63          	bgeu	a4,s1,9d8 <malloc+0xbe>
 948:	f04a                	sd	s2,32(sp)
 94a:	e852                	sd	s4,16(sp)
 94c:	e456                	sd	s5,8(sp)
 94e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 950:	8a4e                	mv	s4,s3
 952:	0009871b          	sext.w	a4,s3
 956:	6685                	lui	a3,0x1
 958:	00d77363          	bgeu	a4,a3,95e <malloc+0x44>
 95c:	6a05                	lui	s4,0x1
 95e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 962:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 966:	00000917          	auipc	s2,0x0
 96a:	69a90913          	addi	s2,s2,1690 # 1000 <freep>
  if(p == SBRK_ERROR)
 96e:	5afd                	li	s5,-1
 970:	a081                	j	9b0 <malloc+0x96>
 972:	f04a                	sd	s2,32(sp)
 974:	e852                	sd	s4,16(sp)
 976:	e456                	sd	s5,8(sp)
 978:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 97a:	00000797          	auipc	a5,0x0
 97e:	69678793          	addi	a5,a5,1686 # 1010 <base>
 982:	00000717          	auipc	a4,0x0
 986:	66f73f23          	sd	a5,1662(a4) # 1000 <freep>
 98a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 98c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 990:	b7c1                	j	950 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 992:	6398                	ld	a4,0(a5)
 994:	e118                	sd	a4,0(a0)
 996:	a8a9                	j	9f0 <malloc+0xd6>
  hp->s.size = nu;
 998:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 99c:	0541                	addi	a0,a0,16
 99e:	efbff0ef          	jal	898 <free>
  return freep;
 9a2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a6:	c12d                	beqz	a0,a08 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	02977263          	bgeu	a4,s1,9d0 <malloc+0xb6>
    if(p == freep)
 9b0:	00093703          	ld	a4,0(s2)
 9b4:	853e                	mv	a0,a5
 9b6:	fef719e3          	bne	a4,a5,9a8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9ba:	8552                	mv	a0,s4
 9bc:	9ffff0ef          	jal	3ba <sbrk>
  if(p == SBRK_ERROR)
 9c0:	fd551ce3          	bne	a0,s5,998 <malloc+0x7e>
        return 0;
 9c4:	4501                	li	a0,0
 9c6:	7902                	ld	s2,32(sp)
 9c8:	6a42                	ld	s4,16(sp)
 9ca:	6aa2                	ld	s5,8(sp)
 9cc:	6b02                	ld	s6,0(sp)
 9ce:	a03d                	j	9fc <malloc+0xe2>
 9d0:	7902                	ld	s2,32(sp)
 9d2:	6a42                	ld	s4,16(sp)
 9d4:	6aa2                	ld	s5,8(sp)
 9d6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9d8:	fae48de3          	beq	s1,a4,992 <malloc+0x78>
        p->s.size -= nunits;
 9dc:	4137073b          	subw	a4,a4,s3
 9e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9e2:	02071693          	slli	a3,a4,0x20
 9e6:	01c6d713          	srli	a4,a3,0x1c
 9ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f0:	00000717          	auipc	a4,0x0
 9f4:	60a73823          	sd	a0,1552(a4) # 1000 <freep>
      return (void*)(p + 1);
 9f8:	01078513          	addi	a0,a5,16
  }
}
 9fc:	70e2                	ld	ra,56(sp)
 9fe:	7442                	ld	s0,48(sp)
 a00:	74a2                	ld	s1,40(sp)
 a02:	69e2                	ld	s3,24(sp)
 a04:	6121                	addi	sp,sp,64
 a06:	8082                	ret
 a08:	7902                	ld	s2,32(sp)
 a0a:	6a42                	ld	s4,16(sp)
 a0c:	6aa2                	ld	s5,8(sp)
 a0e:	6b02                	ld	s6,0(sp)
 a10:	b7f5                	j	9fc <malloc+0xe2>
