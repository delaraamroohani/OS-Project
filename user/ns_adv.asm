
user/_ns_adv:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Advanced PID Namespace Test

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int pid1, pid2;

  printf("=== Advanced PID Namespace Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	a6850513          	addi	a0,a0,-1432 # a70 <malloc+0xfa>
  10:	0b3000ef          	jal	8c2 <printf>

  printf("Parent process:\n");
  14:	00001517          	auipc	a0,0x1
  18:	a8c50513          	addi	a0,a0,-1396 # aa0 <malloc+0x12a>
  1c:	0a7000ef          	jal	8c2 <printf>
  printf("  Global PID: %d\n", getpid());
  20:	4aa000ef          	jal	4ca <getpid>
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	a9250513          	addi	a0,a0,-1390 # ab8 <malloc+0x142>
  2e:	095000ef          	jal	8c2 <printf>
  printf("  Namespace PID: %d\n\n", get_pid());
  32:	4d8000ef          	jal	50a <get_pid>
  36:	85aa                	mv	a1,a0
  38:	00001517          	auipc	a0,0x1
  3c:	a9850513          	addi	a0,a0,-1384 # ad0 <malloc+0x15a>
  40:	083000ef          	jal	8c2 <printf>

  // Create first child
  pid1 = fork();
  44:	3fe000ef          	jal	442 <fork>
  if(pid1 == 0) {
  48:	ed2d                	bnez	a0,c2 <main+0xc2>
    // First child
    printf("First child:\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	a9e50513          	addi	a0,a0,-1378 # ae8 <malloc+0x172>
  52:	071000ef          	jal	8c2 <printf>
    printf("  Global PID: %d\n", getpid());
  56:	474000ef          	jal	4ca <getpid>
  5a:	85aa                	mv	a1,a0
  5c:	00001517          	auipc	a0,0x1
  60:	a5c50513          	addi	a0,a0,-1444 # ab8 <malloc+0x142>
  64:	05f000ef          	jal	8c2 <printf>
    printf("  Namespace PID: %d\n", get_pid());
  68:	4a2000ef          	jal	50a <get_pid>
  6c:	85aa                	mv	a1,a0
  6e:	00001517          	auipc	a0,0x1
  72:	a8a50513          	addi	a0,a0,-1398 # af8 <malloc+0x182>
  76:	04d000ef          	jal	8c2 <printf>
    
    // Grandchild
    int gpid = fork();
  7a:	3c8000ef          	jal	442 <fork>
    if(gpid == 0) {
  7e:	ed05                	bnez	a0,b6 <main+0xb6>
      printf("  Grandchild:\n");
  80:	00001517          	auipc	a0,0x1
  84:	a9050513          	addi	a0,a0,-1392 # b10 <malloc+0x19a>
  88:	03b000ef          	jal	8c2 <printf>
      printf("    Global PID: %d\n", getpid());
  8c:	43e000ef          	jal	4ca <getpid>
  90:	85aa                	mv	a1,a0
  92:	00001517          	auipc	a0,0x1
  96:	a8e50513          	addi	a0,a0,-1394 # b20 <malloc+0x1aa>
  9a:	029000ef          	jal	8c2 <printf>
      printf("    Namespace PID: %d\n\n", get_pid());
  9e:	46c000ef          	jal	50a <get_pid>
  a2:	85aa                	mv	a1,a0
  a4:	00001517          	auipc	a0,0x1
  a8:	a9450513          	addi	a0,a0,-1388 # b38 <malloc+0x1c2>
  ac:	017000ef          	jal	8c2 <printf>
      exit(0);
  b0:	4501                	li	a0,0
  b2:	398000ef          	jal	44a <exit>
    }
    wait(0);
  b6:	4501                	li	a0,0
  b8:	39a000ef          	jal	452 <wait>
    exit(0);
  bc:	4501                	li	a0,0
  be:	38c000ef          	jal	44a <exit>
  }

  // Create second child
  pid2 = fork();
  c2:	380000ef          	jal	442 <fork>
  if(pid2 == 0) {
  c6:	ed05                	bnez	a0,fe <main+0xfe>
    // Second child
    printf("Second child:\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	a8850513          	addi	a0,a0,-1400 # b50 <malloc+0x1da>
  d0:	7f2000ef          	jal	8c2 <printf>
    printf("  Global PID: %d\n", getpid());
  d4:	3f6000ef          	jal	4ca <getpid>
  d8:	85aa                	mv	a1,a0
  da:	00001517          	auipc	a0,0x1
  de:	9de50513          	addi	a0,a0,-1570 # ab8 <malloc+0x142>
  e2:	7e0000ef          	jal	8c2 <printf>
    printf("  Namespace PID: %d\n\n", get_pid());
  e6:	424000ef          	jal	50a <get_pid>
  ea:	85aa                	mv	a1,a0
  ec:	00001517          	auipc	a0,0x1
  f0:	9e450513          	addi	a0,a0,-1564 # ad0 <malloc+0x15a>
  f4:	7ce000ef          	jal	8c2 <printf>
    exit(0);
  f8:	4501                	li	a0,0
  fa:	350000ef          	jal	44a <exit>
  }

  // Wait for children
  wait(0);
  fe:	4501                	li	a0,0
 100:	352000ef          	jal	452 <wait>
  wait(0);
 104:	4501                	li	a0,0
 106:	34c000ef          	jal	452 <wait>

  printf("Parent continues:\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	a5650513          	addi	a0,a0,-1450 # b60 <malloc+0x1ea>
 112:	7b0000ef          	jal	8c2 <printf>
  printf("  Global PID: %d\n", getpid());
 116:	3b4000ef          	jal	4ca <getpid>
 11a:	85aa                	mv	a1,a0
 11c:	00001517          	auipc	a0,0x1
 120:	99c50513          	addi	a0,a0,-1636 # ab8 <malloc+0x142>
 124:	79e000ef          	jal	8c2 <printf>
  printf("  Namespace PID: %d\n\n", get_pid());
 128:	3e2000ef          	jal	50a <get_pid>
 12c:	85aa                	mv	a1,a0
 12e:	00001517          	auipc	a0,0x1
 132:	9a250513          	addi	a0,a0,-1630 # ad0 <malloc+0x15a>
 136:	78c000ef          	jal	8c2 <printf>

  // Test isolated namespace
  printf("Testing isolated namespace:\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	a3e50513          	addi	a0,a0,-1474 # b78 <malloc+0x202>
 142:	780000ef          	jal	8c2 <printf>
  pid1 = fork();
 146:	2fc000ef          	jal	442 <fork>
  if(pid1 == 0) {
 14a:	e931                	bnez	a0,19e <main+0x19e>
    if(unshare(CLONE_NEWPID) == 0) {
 14c:	20000537          	lui	a0,0x20000
 150:	3e2000ef          	jal	532 <unshare>
 154:	e131                	bnez	a0,198 <main+0x198>
      printf("  Child created new PID namespace\n");
 156:	00001517          	auipc	a0,0x1
 15a:	a4250513          	addi	a0,a0,-1470 # b98 <malloc+0x222>
 15e:	764000ef          	jal	8c2 <printf>
      printf("  New namespace PID: %d (should be 1)\n", get_pid());
 162:	3a8000ef          	jal	50a <get_pid>
 166:	85aa                	mv	a1,a0
 168:	00001517          	auipc	a0,0x1
 16c:	a5850513          	addi	a0,a0,-1448 # bc0 <malloc+0x24a>
 170:	752000ef          	jal	8c2 <printf>
      
      int cpid = fork();
 174:	2ce000ef          	jal	442 <fork>
      if(cpid == 0) {
 178:	ed09                	bnez	a0,192 <main+0x192>
        printf("    Grandchild in isolated ns: PID = %d\n", get_pid());
 17a:	390000ef          	jal	50a <get_pid>
 17e:	85aa                	mv	a1,a0
 180:	00001517          	auipc	a0,0x1
 184:	a6850513          	addi	a0,a0,-1432 # be8 <malloc+0x272>
 188:	73a000ef          	jal	8c2 <printf>
        exit(0);
 18c:	4501                	li	a0,0
 18e:	2bc000ef          	jal	44a <exit>
      }
      wait(0);
 192:	4501                	li	a0,0
 194:	2be000ef          	jal	452 <wait>
    }
    exit(0);
 198:	4501                	li	a0,0
 19a:	2b0000ef          	jal	44a <exit>
  }
  wait(0);
 19e:	4501                	li	a0,0
 1a0:	2b2000ef          	jal	452 <wait>

  printf("\n=== Advanced Test Complete ===\n");
 1a4:	00001517          	auipc	a0,0x1
 1a8:	a7450513          	addi	a0,a0,-1420 # c18 <malloc+0x2a2>
 1ac:	716000ef          	jal	8c2 <printf>
  
  exit(0);
 1b0:	4501                	li	a0,0
 1b2:	298000ef          	jal	44a <exit>

00000000000001b6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e406                	sd	ra,8(sp)
 1ba:	e022                	sd	s0,0(sp)
 1bc:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1be:	e43ff0ef          	jal	0 <main>
  exit(r);
 1c2:	288000ef          	jal	44a <exit>

00000000000001c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1cc:	87aa                	mv	a5,a0
 1ce:	0585                	addi	a1,a1,1
 1d0:	0785                	addi	a5,a5,1
 1d2:	fff5c703          	lbu	a4,-1(a1)
 1d6:	fee78fa3          	sb	a4,-1(a5)
 1da:	fb75                	bnez	a4,1ce <strcpy+0x8>
    ;
  return os;
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret

00000000000001e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cb91                	beqz	a5,200 <strcmp+0x1e>
 1ee:	0005c703          	lbu	a4,0(a1)
 1f2:	00f71763          	bne	a4,a5,200 <strcmp+0x1e>
    p++, q++;
 1f6:	0505                	addi	a0,a0,1
 1f8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	fbe5                	bnez	a5,1ee <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 200:	0005c503          	lbu	a0,0(a1)
}
 204:	40a7853b          	subw	a0,a5,a0
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strlen>:

uint
strlen(const char *s)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 214:	00054783          	lbu	a5,0(a0)
 218:	cf91                	beqz	a5,234 <strlen+0x26>
 21a:	0505                	addi	a0,a0,1
 21c:	87aa                	mv	a5,a0
 21e:	86be                	mv	a3,a5
 220:	0785                	addi	a5,a5,1
 222:	fff7c703          	lbu	a4,-1(a5)
 226:	ff65                	bnez	a4,21e <strlen+0x10>
 228:	40a6853b          	subw	a0,a3,a0
 22c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  for(n = 0; s[n]; n++)
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <strlen+0x20>

0000000000000238 <memset>:

void*
memset(void *dst, int c, uint n)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 23e:	ca19                	beqz	a2,254 <memset+0x1c>
 240:	87aa                	mv	a5,a0
 242:	1602                	slli	a2,a2,0x20
 244:	9201                	srli	a2,a2,0x20
 246:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 24a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 24e:	0785                	addi	a5,a5,1
 250:	fee79de3          	bne	a5,a4,24a <memset+0x12>
  }
  return dst;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strchr>:

char*
strchr(const char *s, char c)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 260:	00054783          	lbu	a5,0(a0)
 264:	cb99                	beqz	a5,27a <strchr+0x20>
    if(*s == c)
 266:	00f58763          	beq	a1,a5,274 <strchr+0x1a>
  for(; *s; s++)
 26a:	0505                	addi	a0,a0,1
 26c:	00054783          	lbu	a5,0(a0)
 270:	fbfd                	bnez	a5,266 <strchr+0xc>
      return (char*)s;
  return 0;
 272:	4501                	li	a0,0
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  return 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <strchr+0x1a>

000000000000027e <gets>:

char*
gets(char *buf, int max)
{
 27e:	711d                	addi	sp,sp,-96
 280:	ec86                	sd	ra,88(sp)
 282:	e8a2                	sd	s0,80(sp)
 284:	e4a6                	sd	s1,72(sp)
 286:	e0ca                	sd	s2,64(sp)
 288:	fc4e                	sd	s3,56(sp)
 28a:	f852                	sd	s4,48(sp)
 28c:	f456                	sd	s5,40(sp)
 28e:	f05a                	sd	s6,32(sp)
 290:	ec5e                	sd	s7,24(sp)
 292:	1080                	addi	s0,sp,96
 294:	8baa                	mv	s7,a0
 296:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 298:	892a                	mv	s2,a0
 29a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 29c:	4aa9                	li	s5,10
 29e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2a0:	89a6                	mv	s3,s1
 2a2:	2485                	addiw	s1,s1,1
 2a4:	0344d663          	bge	s1,s4,2d0 <gets+0x52>
    cc = read(0, &c, 1);
 2a8:	4605                	li	a2,1
 2aa:	faf40593          	addi	a1,s0,-81
 2ae:	4501                	li	a0,0
 2b0:	1b2000ef          	jal	462 <read>
    if(cc < 1)
 2b4:	00a05e63          	blez	a0,2d0 <gets+0x52>
    buf[i++] = c;
 2b8:	faf44783          	lbu	a5,-81(s0)
 2bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2c0:	01578763          	beq	a5,s5,2ce <gets+0x50>
 2c4:	0905                	addi	s2,s2,1
 2c6:	fd679de3          	bne	a5,s6,2a0 <gets+0x22>
    buf[i++] = c;
 2ca:	89a6                	mv	s3,s1
 2cc:	a011                	j	2d0 <gets+0x52>
 2ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2d0:	99de                	add	s3,s3,s7
 2d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2d6:	855e                	mv	a0,s7
 2d8:	60e6                	ld	ra,88(sp)
 2da:	6446                	ld	s0,80(sp)
 2dc:	64a6                	ld	s1,72(sp)
 2de:	6906                	ld	s2,64(sp)
 2e0:	79e2                	ld	s3,56(sp)
 2e2:	7a42                	ld	s4,48(sp)
 2e4:	7aa2                	ld	s5,40(sp)
 2e6:	7b02                	ld	s6,32(sp)
 2e8:	6be2                	ld	s7,24(sp)
 2ea:	6125                	addi	sp,sp,96
 2ec:	8082                	ret

00000000000002ee <stat>:

int
stat(const char *n, struct stat *st)
{
 2ee:	1101                	addi	sp,sp,-32
 2f0:	ec06                	sd	ra,24(sp)
 2f2:	e822                	sd	s0,16(sp)
 2f4:	e04a                	sd	s2,0(sp)
 2f6:	1000                	addi	s0,sp,32
 2f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2fa:	4581                	li	a1,0
 2fc:	18e000ef          	jal	48a <open>
  if(fd < 0)
 300:	02054263          	bltz	a0,324 <stat+0x36>
 304:	e426                	sd	s1,8(sp)
 306:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 308:	85ca                	mv	a1,s2
 30a:	198000ef          	jal	4a2 <fstat>
 30e:	892a                	mv	s2,a0
  close(fd);
 310:	8526                	mv	a0,s1
 312:	160000ef          	jal	472 <close>
  return r;
 316:	64a2                	ld	s1,8(sp)
}
 318:	854a                	mv	a0,s2
 31a:	60e2                	ld	ra,24(sp)
 31c:	6442                	ld	s0,16(sp)
 31e:	6902                	ld	s2,0(sp)
 320:	6105                	addi	sp,sp,32
 322:	8082                	ret
    return -1;
 324:	597d                	li	s2,-1
 326:	bfcd                	j	318 <stat+0x2a>

0000000000000328 <atoi>:

int
atoi(const char *s)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 32e:	00054683          	lbu	a3,0(a0)
 332:	fd06879b          	addiw	a5,a3,-48
 336:	0ff7f793          	zext.b	a5,a5
 33a:	4625                	li	a2,9
 33c:	02f66863          	bltu	a2,a5,36c <atoi+0x44>
 340:	872a                	mv	a4,a0
  n = 0;
 342:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 344:	0705                	addi	a4,a4,1
 346:	0025179b          	slliw	a5,a0,0x2
 34a:	9fa9                	addw	a5,a5,a0
 34c:	0017979b          	slliw	a5,a5,0x1
 350:	9fb5                	addw	a5,a5,a3
 352:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 356:	00074683          	lbu	a3,0(a4)
 35a:	fd06879b          	addiw	a5,a3,-48
 35e:	0ff7f793          	zext.b	a5,a5
 362:	fef671e3          	bgeu	a2,a5,344 <atoi+0x1c>
  return n;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret
  n = 0;
 36c:	4501                	li	a0,0
 36e:	bfe5                	j	366 <atoi+0x3e>

0000000000000370 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e422                	sd	s0,8(sp)
 374:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 376:	02b57463          	bgeu	a0,a1,39e <memmove+0x2e>
    while(n-- > 0)
 37a:	00c05f63          	blez	a2,398 <memmove+0x28>
 37e:	1602                	slli	a2,a2,0x20
 380:	9201                	srli	a2,a2,0x20
 382:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 386:	872a                	mv	a4,a0
      *dst++ = *src++;
 388:	0585                	addi	a1,a1,1
 38a:	0705                	addi	a4,a4,1
 38c:	fff5c683          	lbu	a3,-1(a1)
 390:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 394:	fef71ae3          	bne	a4,a5,388 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret
    dst += n;
 39e:	00c50733          	add	a4,a0,a2
    src += n;
 3a2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3a4:	fec05ae3          	blez	a2,398 <memmove+0x28>
 3a8:	fff6079b          	addiw	a5,a2,-1
 3ac:	1782                	slli	a5,a5,0x20
 3ae:	9381                	srli	a5,a5,0x20
 3b0:	fff7c793          	not	a5,a5
 3b4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3b6:	15fd                	addi	a1,a1,-1
 3b8:	177d                	addi	a4,a4,-1
 3ba:	0005c683          	lbu	a3,0(a1)
 3be:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c2:	fee79ae3          	bne	a5,a4,3b6 <memmove+0x46>
 3c6:	bfc9                	j	398 <memmove+0x28>

00000000000003c8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e422                	sd	s0,8(sp)
 3cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ce:	ca05                	beqz	a2,3fe <memcmp+0x36>
 3d0:	fff6069b          	addiw	a3,a2,-1
 3d4:	1682                	slli	a3,a3,0x20
 3d6:	9281                	srli	a3,a3,0x20
 3d8:	0685                	addi	a3,a3,1
 3da:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3dc:	00054783          	lbu	a5,0(a0)
 3e0:	0005c703          	lbu	a4,0(a1)
 3e4:	00e79863          	bne	a5,a4,3f4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3e8:	0505                	addi	a0,a0,1
    p2++;
 3ea:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ec:	fed518e3          	bne	a0,a3,3dc <memcmp+0x14>
  }
  return 0;
 3f0:	4501                	li	a0,0
 3f2:	a019                	j	3f8 <memcmp+0x30>
      return *p1 - *p2;
 3f4:	40e7853b          	subw	a0,a5,a4
}
 3f8:	6422                	ld	s0,8(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret
  return 0;
 3fe:	4501                	li	a0,0
 400:	bfe5                	j	3f8 <memcmp+0x30>

0000000000000402 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 402:	1141                	addi	sp,sp,-16
 404:	e406                	sd	ra,8(sp)
 406:	e022                	sd	s0,0(sp)
 408:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 40a:	f67ff0ef          	jal	370 <memmove>
}
 40e:	60a2                	ld	ra,8(sp)
 410:	6402                	ld	s0,0(sp)
 412:	0141                	addi	sp,sp,16
 414:	8082                	ret

0000000000000416 <sbrk>:

char *
sbrk(int n) {
 416:	1141                	addi	sp,sp,-16
 418:	e406                	sd	ra,8(sp)
 41a:	e022                	sd	s0,0(sp)
 41c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 41e:	4585                	li	a1,1
 420:	0b2000ef          	jal	4d2 <sys_sbrk>
}
 424:	60a2                	ld	ra,8(sp)
 426:	6402                	ld	s0,0(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret

000000000000042c <sbrklazy>:

char *
sbrklazy(int n) {
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 434:	4589                	li	a1,2
 436:	09c000ef          	jal	4d2 <sys_sbrk>
}
 43a:	60a2                	ld	ra,8(sp)
 43c:	6402                	ld	s0,0(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret

0000000000000442 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 442:	4885                	li	a7,1
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exit>:
.global exit
exit:
 li a7, SYS_exit
 44a:	4889                	li	a7,2
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <wait>:
.global wait
wait:
 li a7, SYS_wait
 452:	488d                	li	a7,3
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45a:	4891                	li	a7,4
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <read>:
.global read
read:
 li a7, SYS_read
 462:	4895                	li	a7,5
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <write>:
.global write
write:
 li a7, SYS_write
 46a:	48c1                	li	a7,16
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <close>:
.global close
close:
 li a7, SYS_close
 472:	48d5                	li	a7,21
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <kill>:
.global kill
kill:
 li a7, SYS_kill
 47a:	4899                	li	a7,6
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <exec>:
.global exec
exec:
 li a7, SYS_exec
 482:	489d                	li	a7,7
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <open>:
.global open
open:
 li a7, SYS_open
 48a:	48bd                	li	a7,15
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 492:	48c5                	li	a7,17
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49a:	48c9                	li	a7,18
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a2:	48a1                	li	a7,8
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <link>:
.global link
link:
 li a7, SYS_link
 4aa:	48cd                	li	a7,19
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b2:	48d1                	li	a7,20
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ba:	48a5                	li	a7,9
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c2:	48a9                	li	a7,10
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ca:	48ad                	li	a7,11
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4d2:	48b1                	li	a7,12
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <pause>:
.global pause
pause:
 li a7, SYS_pause
 4da:	48b5                	li	a7,13
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e2:	48b9                	li	a7,14
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 4ea:	48d9                	li	a7,22
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 4f2:	48dd                	li	a7,23
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 4fa:	48e1                	li	a7,24
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 502:	48e5                	li	a7,25
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 50a:	48e9                	li	a7,26
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 512:	48ed                	li	a7,27
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 51a:	48f1                	li	a7,28
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 522:	48f5                	li	a7,29
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 52a:	48f9                	li	a7,30
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 532:	48fd                	li	a7,31
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 53a:	1101                	addi	sp,sp,-32
 53c:	ec06                	sd	ra,24(sp)
 53e:	e822                	sd	s0,16(sp)
 540:	1000                	addi	s0,sp,32
 542:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 546:	4605                	li	a2,1
 548:	fef40593          	addi	a1,s0,-17
 54c:	f1fff0ef          	jal	46a <write>
}
 550:	60e2                	ld	ra,24(sp)
 552:	6442                	ld	s0,16(sp)
 554:	6105                	addi	sp,sp,32
 556:	8082                	ret

0000000000000558 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 558:	715d                	addi	sp,sp,-80
 55a:	e486                	sd	ra,72(sp)
 55c:	e0a2                	sd	s0,64(sp)
 55e:	f84a                	sd	s2,48(sp)
 560:	0880                	addi	s0,sp,80
 562:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 564:	c299                	beqz	a3,56a <printint+0x12>
 566:	0805c363          	bltz	a1,5ec <printint+0x94>
  neg = 0;
 56a:	4881                	li	a7,0
 56c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 570:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 572:	00000517          	auipc	a0,0x0
 576:	6d650513          	addi	a0,a0,1750 # c48 <digits>
 57a:	883e                	mv	a6,a5
 57c:	2785                	addiw	a5,a5,1
 57e:	02c5f733          	remu	a4,a1,a2
 582:	972a                	add	a4,a4,a0
 584:	00074703          	lbu	a4,0(a4)
 588:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 58c:	872e                	mv	a4,a1
 58e:	02c5d5b3          	divu	a1,a1,a2
 592:	0685                	addi	a3,a3,1
 594:	fec773e3          	bgeu	a4,a2,57a <printint+0x22>
  if(neg)
 598:	00088b63          	beqz	a7,5ae <printint+0x56>
    buf[i++] = '-';
 59c:	fd078793          	addi	a5,a5,-48
 5a0:	97a2                	add	a5,a5,s0
 5a2:	02d00713          	li	a4,45
 5a6:	fee78423          	sb	a4,-24(a5)
 5aa:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5ae:	02f05a63          	blez	a5,5e2 <printint+0x8a>
 5b2:	fc26                	sd	s1,56(sp)
 5b4:	f44e                	sd	s3,40(sp)
 5b6:	fb840713          	addi	a4,s0,-72
 5ba:	00f704b3          	add	s1,a4,a5
 5be:	fff70993          	addi	s3,a4,-1
 5c2:	99be                	add	s3,s3,a5
 5c4:	37fd                	addiw	a5,a5,-1
 5c6:	1782                	slli	a5,a5,0x20
 5c8:	9381                	srli	a5,a5,0x20
 5ca:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5ce:	fff4c583          	lbu	a1,-1(s1)
 5d2:	854a                	mv	a0,s2
 5d4:	f67ff0ef          	jal	53a <putc>
  while(--i >= 0)
 5d8:	14fd                	addi	s1,s1,-1
 5da:	ff349ae3          	bne	s1,s3,5ce <printint+0x76>
 5de:	74e2                	ld	s1,56(sp)
 5e0:	79a2                	ld	s3,40(sp)
}
 5e2:	60a6                	ld	ra,72(sp)
 5e4:	6406                	ld	s0,64(sp)
 5e6:	7942                	ld	s2,48(sp)
 5e8:	6161                	addi	sp,sp,80
 5ea:	8082                	ret
    x = -xx;
 5ec:	40b005b3          	neg	a1,a1
    neg = 1;
 5f0:	4885                	li	a7,1
    x = -xx;
 5f2:	bfad                	j	56c <printint+0x14>

00000000000005f4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f4:	711d                	addi	sp,sp,-96
 5f6:	ec86                	sd	ra,88(sp)
 5f8:	e8a2                	sd	s0,80(sp)
 5fa:	e0ca                	sd	s2,64(sp)
 5fc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fe:	0005c903          	lbu	s2,0(a1)
 602:	28090663          	beqz	s2,88e <vprintf+0x29a>
 606:	e4a6                	sd	s1,72(sp)
 608:	fc4e                	sd	s3,56(sp)
 60a:	f852                	sd	s4,48(sp)
 60c:	f456                	sd	s5,40(sp)
 60e:	f05a                	sd	s6,32(sp)
 610:	ec5e                	sd	s7,24(sp)
 612:	e862                	sd	s8,16(sp)
 614:	e466                	sd	s9,8(sp)
 616:	8b2a                	mv	s6,a0
 618:	8a2e                	mv	s4,a1
 61a:	8bb2                	mv	s7,a2
  state = 0;
 61c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 61e:	4481                	li	s1,0
 620:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 622:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 626:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 62a:	06c00c93          	li	s9,108
 62e:	a005                	j	64e <vprintf+0x5a>
        putc(fd, c0);
 630:	85ca                	mv	a1,s2
 632:	855a                	mv	a0,s6
 634:	f07ff0ef          	jal	53a <putc>
 638:	a019                	j	63e <vprintf+0x4a>
    } else if(state == '%'){
 63a:	03598263          	beq	s3,s5,65e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 63e:	2485                	addiw	s1,s1,1
 640:	8726                	mv	a4,s1
 642:	009a07b3          	add	a5,s4,s1
 646:	0007c903          	lbu	s2,0(a5)
 64a:	22090a63          	beqz	s2,87e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 64e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 652:	fe0994e3          	bnez	s3,63a <vprintf+0x46>
      if(c0 == '%'){
 656:	fd579de3          	bne	a5,s5,630 <vprintf+0x3c>
        state = '%';
 65a:	89be                	mv	s3,a5
 65c:	b7cd                	j	63e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 65e:	00ea06b3          	add	a3,s4,a4
 662:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 666:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 668:	c681                	beqz	a3,670 <vprintf+0x7c>
 66a:	9752                	add	a4,a4,s4
 66c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 670:	05878363          	beq	a5,s8,6b6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 674:	05978d63          	beq	a5,s9,6ce <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 678:	07500713          	li	a4,117
 67c:	0ee78763          	beq	a5,a4,76a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 680:	07800713          	li	a4,120
 684:	12e78963          	beq	a5,a4,7b6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 688:	07000713          	li	a4,112
 68c:	14e78e63          	beq	a5,a4,7e8 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 690:	06300713          	li	a4,99
 694:	18e78e63          	beq	a5,a4,830 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 698:	07300713          	li	a4,115
 69c:	1ae78463          	beq	a5,a4,844 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6a0:	02500713          	li	a4,37
 6a4:	04e79563          	bne	a5,a4,6ee <vprintf+0xfa>
        putc(fd, '%');
 6a8:	02500593          	li	a1,37
 6ac:	855a                	mv	a0,s6
 6ae:	e8dff0ef          	jal	53a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b769                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4685                	li	a3,1
 6bc:	4629                	li	a2,10
 6be:	000ba583          	lw	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	e95ff0ef          	jal	558 <printint>
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bf8d                	j	63e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6ce:	06400793          	li	a5,100
 6d2:	02f68963          	beq	a3,a5,704 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6d6:	06c00793          	li	a5,108
 6da:	04f68263          	beq	a3,a5,71e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6de:	07500793          	li	a5,117
 6e2:	0af68063          	beq	a3,a5,782 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6e6:	07800793          	li	a5,120
 6ea:	0ef68263          	beq	a3,a5,7ce <vprintf+0x1da>
        putc(fd, '%');
 6ee:	02500593          	li	a1,37
 6f2:	855a                	mv	a0,s6
 6f4:	e47ff0ef          	jal	53a <putc>
        putc(fd, c0);
 6f8:	85ca                	mv	a1,s2
 6fa:	855a                	mv	a0,s6
 6fc:	e3fff0ef          	jal	53a <putc>
      state = 0;
 700:	4981                	li	s3,0
 702:	bf35                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 704:	008b8913          	addi	s2,s7,8
 708:	4685                	li	a3,1
 70a:	4629                	li	a2,10
 70c:	000bb583          	ld	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	e47ff0ef          	jal	558 <printint>
        i += 1;
 716:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
        i += 1;
 71c:	b70d                	j	63e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71e:	06400793          	li	a5,100
 722:	02f60763          	beq	a2,a5,750 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 726:	07500793          	li	a5,117
 72a:	06f60963          	beq	a2,a5,79c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 72e:	07800793          	li	a5,120
 732:	faf61ee3          	bne	a2,a5,6ee <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 736:	008b8913          	addi	s2,s7,8
 73a:	4681                	li	a3,0
 73c:	4641                	li	a2,16
 73e:	000bb583          	ld	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	e15ff0ef          	jal	558 <printint>
        i += 2;
 748:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
        i += 2;
 74e:	bdc5                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 750:	008b8913          	addi	s2,s7,8
 754:	4685                	li	a3,1
 756:	4629                	li	a2,10
 758:	000bb583          	ld	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	dfbff0ef          	jal	558 <printint>
        i += 2;
 762:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
        i += 2;
 768:	bdd9                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4681                	li	a3,0
 770:	4629                	li	a2,10
 772:	000be583          	lwu	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	de1ff0ef          	jal	558 <printint>
 77c:	8bca                	mv	s7,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	bd7d                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 782:	008b8913          	addi	s2,s7,8
 786:	4681                	li	a3,0
 788:	4629                	li	a2,10
 78a:	000bb583          	ld	a1,0(s7)
 78e:	855a                	mv	a0,s6
 790:	dc9ff0ef          	jal	558 <printint>
        i += 1;
 794:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 796:	8bca                	mv	s7,s2
      state = 0;
 798:	4981                	li	s3,0
        i += 1;
 79a:	b555                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 79c:	008b8913          	addi	s2,s7,8
 7a0:	4681                	li	a3,0
 7a2:	4629                	li	a2,10
 7a4:	000bb583          	ld	a1,0(s7)
 7a8:	855a                	mv	a0,s6
 7aa:	dafff0ef          	jal	558 <printint>
        i += 2;
 7ae:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b0:	8bca                	mv	s7,s2
      state = 0;
 7b2:	4981                	li	s3,0
        i += 2;
 7b4:	b569                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7b6:	008b8913          	addi	s2,s7,8
 7ba:	4681                	li	a3,0
 7bc:	4641                	li	a2,16
 7be:	000be583          	lwu	a1,0(s7)
 7c2:	855a                	mv	a0,s6
 7c4:	d95ff0ef          	jal	558 <printint>
 7c8:	8bca                	mv	s7,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bd8d                	j	63e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ce:	008b8913          	addi	s2,s7,8
 7d2:	4681                	li	a3,0
 7d4:	4641                	li	a2,16
 7d6:	000bb583          	ld	a1,0(s7)
 7da:	855a                	mv	a0,s6
 7dc:	d7dff0ef          	jal	558 <printint>
        i += 1;
 7e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e2:	8bca                	mv	s7,s2
      state = 0;
 7e4:	4981                	li	s3,0
        i += 1;
 7e6:	bda1                	j	63e <vprintf+0x4a>
 7e8:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7ea:	008b8d13          	addi	s10,s7,8
 7ee:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7f2:	03000593          	li	a1,48
 7f6:	855a                	mv	a0,s6
 7f8:	d43ff0ef          	jal	53a <putc>
  putc(fd, 'x');
 7fc:	07800593          	li	a1,120
 800:	855a                	mv	a0,s6
 802:	d39ff0ef          	jal	53a <putc>
 806:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 808:	00000b97          	auipc	s7,0x0
 80c:	440b8b93          	addi	s7,s7,1088 # c48 <digits>
 810:	03c9d793          	srli	a5,s3,0x3c
 814:	97de                	add	a5,a5,s7
 816:	0007c583          	lbu	a1,0(a5)
 81a:	855a                	mv	a0,s6
 81c:	d1fff0ef          	jal	53a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 820:	0992                	slli	s3,s3,0x4
 822:	397d                	addiw	s2,s2,-1
 824:	fe0916e3          	bnez	s2,810 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 828:	8bea                	mv	s7,s10
      state = 0;
 82a:	4981                	li	s3,0
 82c:	6d02                	ld	s10,0(sp)
 82e:	bd01                	j	63e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 830:	008b8913          	addi	s2,s7,8
 834:	000bc583          	lbu	a1,0(s7)
 838:	855a                	mv	a0,s6
 83a:	d01ff0ef          	jal	53a <putc>
 83e:	8bca                	mv	s7,s2
      state = 0;
 840:	4981                	li	s3,0
 842:	bbf5                	j	63e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 844:	008b8993          	addi	s3,s7,8
 848:	000bb903          	ld	s2,0(s7)
 84c:	00090f63          	beqz	s2,86a <vprintf+0x276>
        for(; *s; s++)
 850:	00094583          	lbu	a1,0(s2)
 854:	c195                	beqz	a1,878 <vprintf+0x284>
          putc(fd, *s);
 856:	855a                	mv	a0,s6
 858:	ce3ff0ef          	jal	53a <putc>
        for(; *s; s++)
 85c:	0905                	addi	s2,s2,1
 85e:	00094583          	lbu	a1,0(s2)
 862:	f9f5                	bnez	a1,856 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 864:	8bce                	mv	s7,s3
      state = 0;
 866:	4981                	li	s3,0
 868:	bbd9                	j	63e <vprintf+0x4a>
          s = "(null)";
 86a:	00000917          	auipc	s2,0x0
 86e:	3d690913          	addi	s2,s2,982 # c40 <malloc+0x2ca>
        for(; *s; s++)
 872:	02800593          	li	a1,40
 876:	b7c5                	j	856 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 878:	8bce                	mv	s7,s3
      state = 0;
 87a:	4981                	li	s3,0
 87c:	b3c9                	j	63e <vprintf+0x4a>
 87e:	64a6                	ld	s1,72(sp)
 880:	79e2                	ld	s3,56(sp)
 882:	7a42                	ld	s4,48(sp)
 884:	7aa2                	ld	s5,40(sp)
 886:	7b02                	ld	s6,32(sp)
 888:	6be2                	ld	s7,24(sp)
 88a:	6c42                	ld	s8,16(sp)
 88c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 88e:	60e6                	ld	ra,88(sp)
 890:	6446                	ld	s0,80(sp)
 892:	6906                	ld	s2,64(sp)
 894:	6125                	addi	sp,sp,96
 896:	8082                	ret

0000000000000898 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 898:	715d                	addi	sp,sp,-80
 89a:	ec06                	sd	ra,24(sp)
 89c:	e822                	sd	s0,16(sp)
 89e:	1000                	addi	s0,sp,32
 8a0:	e010                	sd	a2,0(s0)
 8a2:	e414                	sd	a3,8(s0)
 8a4:	e818                	sd	a4,16(s0)
 8a6:	ec1c                	sd	a5,24(s0)
 8a8:	03043023          	sd	a6,32(s0)
 8ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b4:	8622                	mv	a2,s0
 8b6:	d3fff0ef          	jal	5f4 <vprintf>
}
 8ba:	60e2                	ld	ra,24(sp)
 8bc:	6442                	ld	s0,16(sp)
 8be:	6161                	addi	sp,sp,80
 8c0:	8082                	ret

00000000000008c2 <printf>:

void
printf(const char *fmt, ...)
{
 8c2:	711d                	addi	sp,sp,-96
 8c4:	ec06                	sd	ra,24(sp)
 8c6:	e822                	sd	s0,16(sp)
 8c8:	1000                	addi	s0,sp,32
 8ca:	e40c                	sd	a1,8(s0)
 8cc:	e810                	sd	a2,16(s0)
 8ce:	ec14                	sd	a3,24(s0)
 8d0:	f018                	sd	a4,32(s0)
 8d2:	f41c                	sd	a5,40(s0)
 8d4:	03043823          	sd	a6,48(s0)
 8d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8dc:	00840613          	addi	a2,s0,8
 8e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8e4:	85aa                	mv	a1,a0
 8e6:	4505                	li	a0,1
 8e8:	d0dff0ef          	jal	5f4 <vprintf>
}
 8ec:	60e2                	ld	ra,24(sp)
 8ee:	6442                	ld	s0,16(sp)
 8f0:	6125                	addi	sp,sp,96
 8f2:	8082                	ret

00000000000008f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8f4:	1141                	addi	sp,sp,-16
 8f6:	e422                	sd	s0,8(sp)
 8f8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8fa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8fe:	00000797          	auipc	a5,0x0
 902:	7027b783          	ld	a5,1794(a5) # 1000 <freep>
 906:	a02d                	j	930 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 908:	4618                	lw	a4,8(a2)
 90a:	9f2d                	addw	a4,a4,a1
 90c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 910:	6398                	ld	a4,0(a5)
 912:	6310                	ld	a2,0(a4)
 914:	a83d                	j	952 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 916:	ff852703          	lw	a4,-8(a0)
 91a:	9f31                	addw	a4,a4,a2
 91c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 91e:	ff053683          	ld	a3,-16(a0)
 922:	a091                	j	966 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 924:	6398                	ld	a4,0(a5)
 926:	00e7e463          	bltu	a5,a4,92e <free+0x3a>
 92a:	00e6ea63          	bltu	a3,a4,93e <free+0x4a>
{
 92e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 930:	fed7fae3          	bgeu	a5,a3,924 <free+0x30>
 934:	6398                	ld	a4,0(a5)
 936:	00e6e463          	bltu	a3,a4,93e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 93a:	fee7eae3          	bltu	a5,a4,92e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 93e:	ff852583          	lw	a1,-8(a0)
 942:	6390                	ld	a2,0(a5)
 944:	02059813          	slli	a6,a1,0x20
 948:	01c85713          	srli	a4,a6,0x1c
 94c:	9736                	add	a4,a4,a3
 94e:	fae60de3          	beq	a2,a4,908 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 952:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 956:	4790                	lw	a2,8(a5)
 958:	02061593          	slli	a1,a2,0x20
 95c:	01c5d713          	srli	a4,a1,0x1c
 960:	973e                	add	a4,a4,a5
 962:	fae68ae3          	beq	a3,a4,916 <free+0x22>
    p->s.ptr = bp->s.ptr;
 966:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 968:	00000717          	auipc	a4,0x0
 96c:	68f73c23          	sd	a5,1688(a4) # 1000 <freep>
}
 970:	6422                	ld	s0,8(sp)
 972:	0141                	addi	sp,sp,16
 974:	8082                	ret

0000000000000976 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 976:	7139                	addi	sp,sp,-64
 978:	fc06                	sd	ra,56(sp)
 97a:	f822                	sd	s0,48(sp)
 97c:	f426                	sd	s1,40(sp)
 97e:	ec4e                	sd	s3,24(sp)
 980:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 982:	02051493          	slli	s1,a0,0x20
 986:	9081                	srli	s1,s1,0x20
 988:	04bd                	addi	s1,s1,15
 98a:	8091                	srli	s1,s1,0x4
 98c:	0014899b          	addiw	s3,s1,1
 990:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 992:	00000517          	auipc	a0,0x0
 996:	66e53503          	ld	a0,1646(a0) # 1000 <freep>
 99a:	c915                	beqz	a0,9ce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99e:	4798                	lw	a4,8(a5)
 9a0:	08977a63          	bgeu	a4,s1,a34 <malloc+0xbe>
 9a4:	f04a                	sd	s2,32(sp)
 9a6:	e852                	sd	s4,16(sp)
 9a8:	e456                	sd	s5,8(sp)
 9aa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9ac:	8a4e                	mv	s4,s3
 9ae:	0009871b          	sext.w	a4,s3
 9b2:	6685                	lui	a3,0x1
 9b4:	00d77363          	bgeu	a4,a3,9ba <malloc+0x44>
 9b8:	6a05                	lui	s4,0x1
 9ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9c2:	00000917          	auipc	s2,0x0
 9c6:	63e90913          	addi	s2,s2,1598 # 1000 <freep>
  if(p == SBRK_ERROR)
 9ca:	5afd                	li	s5,-1
 9cc:	a081                	j	a0c <malloc+0x96>
 9ce:	f04a                	sd	s2,32(sp)
 9d0:	e852                	sd	s4,16(sp)
 9d2:	e456                	sd	s5,8(sp)
 9d4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9d6:	00000797          	auipc	a5,0x0
 9da:	63a78793          	addi	a5,a5,1594 # 1010 <base>
 9de:	00000717          	auipc	a4,0x0
 9e2:	62f73123          	sd	a5,1570(a4) # 1000 <freep>
 9e6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9e8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ec:	b7c1                	j	9ac <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9ee:	6398                	ld	a4,0(a5)
 9f0:	e118                	sd	a4,0(a0)
 9f2:	a8a9                	j	a4c <malloc+0xd6>
  hp->s.size = nu;
 9f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9f8:	0541                	addi	a0,a0,16
 9fa:	efbff0ef          	jal	8f4 <free>
  return freep;
 9fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a02:	c12d                	beqz	a0,a64 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a04:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a06:	4798                	lw	a4,8(a5)
 a08:	02977263          	bgeu	a4,s1,a2c <malloc+0xb6>
    if(p == freep)
 a0c:	00093703          	ld	a4,0(s2)
 a10:	853e                	mv	a0,a5
 a12:	fef719e3          	bne	a4,a5,a04 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a16:	8552                	mv	a0,s4
 a18:	9ffff0ef          	jal	416 <sbrk>
  if(p == SBRK_ERROR)
 a1c:	fd551ce3          	bne	a0,s5,9f4 <malloc+0x7e>
        return 0;
 a20:	4501                	li	a0,0
 a22:	7902                	ld	s2,32(sp)
 a24:	6a42                	ld	s4,16(sp)
 a26:	6aa2                	ld	s5,8(sp)
 a28:	6b02                	ld	s6,0(sp)
 a2a:	a03d                	j	a58 <malloc+0xe2>
 a2c:	7902                	ld	s2,32(sp)
 a2e:	6a42                	ld	s4,16(sp)
 a30:	6aa2                	ld	s5,8(sp)
 a32:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a34:	fae48de3          	beq	s1,a4,9ee <malloc+0x78>
        p->s.size -= nunits;
 a38:	4137073b          	subw	a4,a4,s3
 a3c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a3e:	02071693          	slli	a3,a4,0x20
 a42:	01c6d713          	srli	a4,a3,0x1c
 a46:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a48:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a4c:	00000717          	auipc	a4,0x0
 a50:	5aa73a23          	sd	a0,1460(a4) # 1000 <freep>
      return (void*)(p + 1);
 a54:	01078513          	addi	a0,a5,16
  }
}
 a58:	70e2                	ld	ra,56(sp)
 a5a:	7442                	ld	s0,48(sp)
 a5c:	74a2                	ld	s1,40(sp)
 a5e:	69e2                	ld	s3,24(sp)
 a60:	6121                	addi	sp,sp,64
 a62:	8082                	ret
 a64:	7902                	ld	s2,32(sp)
 a66:	6a42                	ld	s4,16(sp)
 a68:	6aa2                	ld	s5,8(sp)
 a6a:	6b02                	ld	s6,0(sp)
 a6c:	b7f5                	j	a58 <malloc+0xe2>
