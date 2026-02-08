
user/_ns_basic:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Basic PID Namespace Test

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int pid1, pid2;

  printf("=== PID Namespace Test Program ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	9f850513          	addi	a0,a0,-1544 # a00 <malloc+0x100>
  10:	03d000ef          	jal	84c <printf>

  printf("Main process:\n");
  14:	00001517          	auipc	a0,0x1
  18:	a1450513          	addi	a0,a0,-1516 # a28 <malloc+0x128>
  1c:	031000ef          	jal	84c <printf>
  printf("  Global PID: %d\n", getpid());
  20:	434000ef          	jal	454 <getpid>
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	a1250513          	addi	a0,a0,-1518 # a38 <malloc+0x138>
  2e:	01f000ef          	jal	84c <printf>
  printf("  Namespace PID: %d\n\n", get_pid());
  32:	462000ef          	jal	494 <get_pid>
  36:	85aa                	mv	a1,a0
  38:	00001517          	auipc	a0,0x1
  3c:	a1850513          	addi	a0,a0,-1512 # a50 <malloc+0x150>
  40:	00d000ef          	jal	84c <printf>

  // Create first child
  pid1 = fork();
  44:	388000ef          	jal	3cc <fork>
  if(pid1 == 0) {
  48:	ed05                	bnez	a0,80 <main+0x80>
    // First child
    printf("First child:\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	a1e50513          	addi	a0,a0,-1506 # a68 <malloc+0x168>
  52:	7fa000ef          	jal	84c <printf>
    printf("  Global PID: %d\n", getpid());
  56:	3fe000ef          	jal	454 <getpid>
  5a:	85aa                	mv	a1,a0
  5c:	00001517          	auipc	a0,0x1
  60:	9dc50513          	addi	a0,a0,-1572 # a38 <malloc+0x138>
  64:	7e8000ef          	jal	84c <printf>
    printf("  Namespace PID: %d\n\n", get_pid());
  68:	42c000ef          	jal	494 <get_pid>
  6c:	85aa                	mv	a1,a0
  6e:	00001517          	auipc	a0,0x1
  72:	9e250513          	addi	a0,a0,-1566 # a50 <malloc+0x150>
  76:	7d6000ef          	jal	84c <printf>
    exit(0);
  7a:	4501                	li	a0,0
  7c:	358000ef          	jal	3d4 <exit>
  }

  // Create second child
  pid2 = fork();
  80:	34c000ef          	jal	3cc <fork>
  if(pid2 == 0) {
  84:	ed05                	bnez	a0,bc <main+0xbc>
    // Second child
    printf("Second child:\n");
  86:	00001517          	auipc	a0,0x1
  8a:	9f250513          	addi	a0,a0,-1550 # a78 <malloc+0x178>
  8e:	7be000ef          	jal	84c <printf>
    printf("  Global PID: %d\n", getpid());
  92:	3c2000ef          	jal	454 <getpid>
  96:	85aa                	mv	a1,a0
  98:	00001517          	auipc	a0,0x1
  9c:	9a050513          	addi	a0,a0,-1632 # a38 <malloc+0x138>
  a0:	7ac000ef          	jal	84c <printf>
    printf("  Namespace PID: %d\n\n", get_pid());
  a4:	3f0000ef          	jal	494 <get_pid>
  a8:	85aa                	mv	a1,a0
  aa:	00001517          	auipc	a0,0x1
  ae:	9a650513          	addi	a0,a0,-1626 # a50 <malloc+0x150>
  b2:	79a000ef          	jal	84c <printf>
    exit(0);
  b6:	4501                	li	a0,0
  b8:	31c000ef          	jal	3d4 <exit>
  }

  // Wait for children
  wait(0);
  bc:	4501                	li	a0,0
  be:	31e000ef          	jal	3dc <wait>
  wait(0);
  c2:	4501                	li	a0,0
  c4:	318000ef          	jal	3dc <wait>

  printf("Parent continues:\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	9c050513          	addi	a0,a0,-1600 # a88 <malloc+0x188>
  d0:	77c000ef          	jal	84c <printf>
  printf("  Global PID: %d\n", getpid());
  d4:	380000ef          	jal	454 <getpid>
  d8:	85aa                	mv	a1,a0
  da:	00001517          	auipc	a0,0x1
  de:	95e50513          	addi	a0,a0,-1698 # a38 <malloc+0x138>
  e2:	76a000ef          	jal	84c <printf>
  printf("  Namespace PID: %d\n\n", get_pid());
  e6:	3ae000ef          	jal	494 <get_pid>
  ea:	85aa                	mv	a1,a0
  ec:	00001517          	auipc	a0,0x1
  f0:	96450513          	addi	a0,a0,-1692 # a50 <malloc+0x150>
  f4:	758000ef          	jal	84c <printf>

  // Test new namespace
  printf("Creating new namespace...\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	9a850513          	addi	a0,a0,-1624 # aa0 <malloc+0x1a0>
 100:	74c000ef          	jal	84c <printf>
  if(unshare(CLONE_NEWPID) == 0) {
 104:	20000537          	lui	a0,0x20000
 108:	3b4000ef          	jal	4bc <unshare>
 10c:	c911                	beqz	a0,120 <main+0x120>
    printf("New namespace created:\n");
    printf("  Namespace PID: %d (reset to 1 in new ns)\n\n", get_pid());
  }

  printf("=== Test Complete ===\n");
 10e:	00001517          	auipc	a0,0x1
 112:	9fa50513          	addi	a0,a0,-1542 # b08 <malloc+0x208>
 116:	736000ef          	jal	84c <printf>
  
  exit(0);
 11a:	4501                	li	a0,0
 11c:	2b8000ef          	jal	3d4 <exit>
    printf("New namespace created:\n");
 120:	00001517          	auipc	a0,0x1
 124:	9a050513          	addi	a0,a0,-1632 # ac0 <malloc+0x1c0>
 128:	724000ef          	jal	84c <printf>
    printf("  Namespace PID: %d (reset to 1 in new ns)\n\n", get_pid());
 12c:	368000ef          	jal	494 <get_pid>
 130:	85aa                	mv	a1,a0
 132:	00001517          	auipc	a0,0x1
 136:	9a650513          	addi	a0,a0,-1626 # ad8 <malloc+0x1d8>
 13a:	712000ef          	jal	84c <printf>
 13e:	bfc1                	j	10e <main+0x10e>

0000000000000140 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 140:	1141                	addi	sp,sp,-16
 142:	e406                	sd	ra,8(sp)
 144:	e022                	sd	s0,0(sp)
 146:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 148:	eb9ff0ef          	jal	0 <main>
  exit(r);
 14c:	288000ef          	jal	3d4 <exit>

0000000000000150 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 156:	87aa                	mv	a5,a0
 158:	0585                	addi	a1,a1,1
 15a:	0785                	addi	a5,a5,1
 15c:	fff5c703          	lbu	a4,-1(a1)
 160:	fee78fa3          	sb	a4,-1(a5)
 164:	fb75                	bnez	a4,158 <strcpy+0x8>
    ;
  return os;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb91                	beqz	a5,18a <strcmp+0x1e>
 178:	0005c703          	lbu	a4,0(a1)
 17c:	00f71763          	bne	a4,a5,18a <strcmp+0x1e>
    p++, q++;
 180:	0505                	addi	a0,a0,1
 182:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 184:	00054783          	lbu	a5,0(a0)
 188:	fbe5                	bnez	a5,178 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18a:	0005c503          	lbu	a0,0(a1)
}
 18e:	40a7853b          	subw	a0,a5,a0
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cf91                	beqz	a5,1be <strlen+0x26>
 1a4:	0505                	addi	a0,a0,1
 1a6:	87aa                	mv	a5,a0
 1a8:	86be                	mv	a3,a5
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff7c703          	lbu	a4,-1(a5)
 1b0:	ff65                	bnez	a4,1a8 <strlen+0x10>
 1b2:	40a6853b          	subw	a0,a3,a0
 1b6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  for(n = 0; s[n]; n++)
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strlen+0x20>

00000000000001c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c8:	ca19                	beqz	a2,1de <memset+0x1c>
 1ca:	87aa                	mv	a5,a0
 1cc:	1602                	slli	a2,a2,0x20
 1ce:	9201                	srli	a2,a2,0x20
 1d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d8:	0785                	addi	a5,a5,1
 1da:	fee79de3          	bne	a5,a4,1d4 <memset+0x12>
  }
  return dst;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cb99                	beqz	a5,204 <strchr+0x20>
    if(*s == c)
 1f0:	00f58763          	beq	a1,a5,1fe <strchr+0x1a>
  for(; *s; s++)
 1f4:	0505                	addi	a0,a0,1
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	fbfd                	bnez	a5,1f0 <strchr+0xc>
      return (char*)s;
  return 0;
 1fc:	4501                	li	a0,0
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  return 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strchr+0x1a>

0000000000000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	711d                	addi	sp,sp,-96
 20a:	ec86                	sd	ra,88(sp)
 20c:	e8a2                	sd	s0,80(sp)
 20e:	e4a6                	sd	s1,72(sp)
 210:	e0ca                	sd	s2,64(sp)
 212:	fc4e                	sd	s3,56(sp)
 214:	f852                	sd	s4,48(sp)
 216:	f456                	sd	s5,40(sp)
 218:	f05a                	sd	s6,32(sp)
 21a:	ec5e                	sd	s7,24(sp)
 21c:	1080                	addi	s0,sp,96
 21e:	8baa                	mv	s7,a0
 220:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	892a                	mv	s2,a0
 224:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 226:	4aa9                	li	s5,10
 228:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	2485                	addiw	s1,s1,1
 22e:	0344d663          	bge	s1,s4,25a <gets+0x52>
    cc = read(0, &c, 1);
 232:	4605                	li	a2,1
 234:	faf40593          	addi	a1,s0,-81
 238:	4501                	li	a0,0
 23a:	1b2000ef          	jal	3ec <read>
    if(cc < 1)
 23e:	00a05e63          	blez	a0,25a <gets+0x52>
    buf[i++] = c;
 242:	faf44783          	lbu	a5,-81(s0)
 246:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24a:	01578763          	beq	a5,s5,258 <gets+0x50>
 24e:	0905                	addi	s2,s2,1
 250:	fd679de3          	bne	a5,s6,22a <gets+0x22>
    buf[i++] = c;
 254:	89a6                	mv	s3,s1
 256:	a011                	j	25a <gets+0x52>
 258:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25a:	99de                	add	s3,s3,s7
 25c:	00098023          	sb	zero,0(s3)
  return buf;
}
 260:	855e                	mv	a0,s7
 262:	60e6                	ld	ra,88(sp)
 264:	6446                	ld	s0,80(sp)
 266:	64a6                	ld	s1,72(sp)
 268:	6906                	ld	s2,64(sp)
 26a:	79e2                	ld	s3,56(sp)
 26c:	7a42                	ld	s4,48(sp)
 26e:	7aa2                	ld	s5,40(sp)
 270:	7b02                	ld	s6,32(sp)
 272:	6be2                	ld	s7,24(sp)
 274:	6125                	addi	sp,sp,96
 276:	8082                	ret

0000000000000278 <stat>:

int
stat(const char *n, struct stat *st)
{
 278:	1101                	addi	sp,sp,-32
 27a:	ec06                	sd	ra,24(sp)
 27c:	e822                	sd	s0,16(sp)
 27e:	e04a                	sd	s2,0(sp)
 280:	1000                	addi	s0,sp,32
 282:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 284:	4581                	li	a1,0
 286:	18e000ef          	jal	414 <open>
  if(fd < 0)
 28a:	02054263          	bltz	a0,2ae <stat+0x36>
 28e:	e426                	sd	s1,8(sp)
 290:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 292:	85ca                	mv	a1,s2
 294:	198000ef          	jal	42c <fstat>
 298:	892a                	mv	s2,a0
  close(fd);
 29a:	8526                	mv	a0,s1
 29c:	160000ef          	jal	3fc <close>
  return r;
 2a0:	64a2                	ld	s1,8(sp)
}
 2a2:	854a                	mv	a0,s2
 2a4:	60e2                	ld	ra,24(sp)
 2a6:	6442                	ld	s0,16(sp)
 2a8:	6902                	ld	s2,0(sp)
 2aa:	6105                	addi	sp,sp,32
 2ac:	8082                	ret
    return -1;
 2ae:	597d                	li	s2,-1
 2b0:	bfcd                	j	2a2 <stat+0x2a>

00000000000002b2 <atoi>:

int
atoi(const char *s)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b8:	00054683          	lbu	a3,0(a0)
 2bc:	fd06879b          	addiw	a5,a3,-48
 2c0:	0ff7f793          	zext.b	a5,a5
 2c4:	4625                	li	a2,9
 2c6:	02f66863          	bltu	a2,a5,2f6 <atoi+0x44>
 2ca:	872a                	mv	a4,a0
  n = 0;
 2cc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ce:	0705                	addi	a4,a4,1
 2d0:	0025179b          	slliw	a5,a0,0x2
 2d4:	9fa9                	addw	a5,a5,a0
 2d6:	0017979b          	slliw	a5,a5,0x1
 2da:	9fb5                	addw	a5,a5,a3
 2dc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2e0:	00074683          	lbu	a3,0(a4)
 2e4:	fd06879b          	addiw	a5,a3,-48
 2e8:	0ff7f793          	zext.b	a5,a5
 2ec:	fef671e3          	bgeu	a2,a5,2ce <atoi+0x1c>
  return n;
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
  n = 0;
 2f6:	4501                	li	a0,0
 2f8:	bfe5                	j	2f0 <atoi+0x3e>

00000000000002fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 300:	02b57463          	bgeu	a0,a1,328 <memmove+0x2e>
    while(n-- > 0)
 304:	00c05f63          	blez	a2,322 <memmove+0x28>
 308:	1602                	slli	a2,a2,0x20
 30a:	9201                	srli	a2,a2,0x20
 30c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 310:	872a                	mv	a4,a0
      *dst++ = *src++;
 312:	0585                	addi	a1,a1,1
 314:	0705                	addi	a4,a4,1
 316:	fff5c683          	lbu	a3,-1(a1)
 31a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 31e:	fef71ae3          	bne	a4,a5,312 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
    dst += n;
 328:	00c50733          	add	a4,a0,a2
    src += n;
 32c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 32e:	fec05ae3          	blez	a2,322 <memmove+0x28>
 332:	fff6079b          	addiw	a5,a2,-1
 336:	1782                	slli	a5,a5,0x20
 338:	9381                	srli	a5,a5,0x20
 33a:	fff7c793          	not	a5,a5
 33e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 340:	15fd                	addi	a1,a1,-1
 342:	177d                	addi	a4,a4,-1
 344:	0005c683          	lbu	a3,0(a1)
 348:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x46>
 350:	bfc9                	j	322 <memmove+0x28>

0000000000000352 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 358:	ca05                	beqz	a2,388 <memcmp+0x36>
 35a:	fff6069b          	addiw	a3,a2,-1
 35e:	1682                	slli	a3,a3,0x20
 360:	9281                	srli	a3,a3,0x20
 362:	0685                	addi	a3,a3,1
 364:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 366:	00054783          	lbu	a5,0(a0)
 36a:	0005c703          	lbu	a4,0(a1)
 36e:	00e79863          	bne	a5,a4,37e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 372:	0505                	addi	a0,a0,1
    p2++;
 374:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 376:	fed518e3          	bne	a0,a3,366 <memcmp+0x14>
  }
  return 0;
 37a:	4501                	li	a0,0
 37c:	a019                	j	382 <memcmp+0x30>
      return *p1 - *p2;
 37e:	40e7853b          	subw	a0,a5,a4
}
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret
  return 0;
 388:	4501                	li	a0,0
 38a:	bfe5                	j	382 <memcmp+0x30>

000000000000038c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e406                	sd	ra,8(sp)
 390:	e022                	sd	s0,0(sp)
 392:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 394:	f67ff0ef          	jal	2fa <memmove>
}
 398:	60a2                	ld	ra,8(sp)
 39a:	6402                	ld	s0,0(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret

00000000000003a0 <sbrk>:

char *
sbrk(int n) {
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e406                	sd	ra,8(sp)
 3a4:	e022                	sd	s0,0(sp)
 3a6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a8:	4585                	li	a1,1
 3aa:	0b2000ef          	jal	45c <sys_sbrk>
}
 3ae:	60a2                	ld	ra,8(sp)
 3b0:	6402                	ld	s0,0(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret

00000000000003b6 <sbrklazy>:

char *
sbrklazy(int n) {
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3be:	4589                	li	a1,2
 3c0:	09c000ef          	jal	45c <sys_sbrk>
}
 3c4:	60a2                	ld	ra,8(sp)
 3c6:	6402                	ld	s0,0(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret

00000000000003cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3cc:	4885                	li	a7,1
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d4:	4889                	li	a7,2
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3dc:	488d                	li	a7,3
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e4:	4891                	li	a7,4
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <read>:
.global read
read:
 li a7, SYS_read
 3ec:	4895                	li	a7,5
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <write>:
.global write
write:
 li a7, SYS_write
 3f4:	48c1                	li	a7,16
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <close>:
.global close
close:
 li a7, SYS_close
 3fc:	48d5                	li	a7,21
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <kill>:
.global kill
kill:
 li a7, SYS_kill
 404:	4899                	li	a7,6
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <exec>:
.global exec
exec:
 li a7, SYS_exec
 40c:	489d                	li	a7,7
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <open>:
.global open
open:
 li a7, SYS_open
 414:	48bd                	li	a7,15
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41c:	48c5                	li	a7,17
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 424:	48c9                	li	a7,18
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42c:	48a1                	li	a7,8
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <link>:
.global link
link:
 li a7, SYS_link
 434:	48cd                	li	a7,19
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43c:	48d1                	li	a7,20
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 444:	48a5                	li	a7,9
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <dup>:
.global dup
dup:
 li a7, SYS_dup
 44c:	48a9                	li	a7,10
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 454:	48ad                	li	a7,11
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 45c:	48b1                	li	a7,12
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <pause>:
.global pause
pause:
 li a7, SYS_pause
 464:	48b5                	li	a7,13
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46c:	48b9                	li	a7,14
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 474:	48d9                	li	a7,22
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 47c:	48dd                	li	a7,23
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 484:	48e1                	li	a7,24
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 48c:	48e5                	li	a7,25
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 494:	48e9                	li	a7,26
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 49c:	48ed                	li	a7,27
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 4a4:	48f1                	li	a7,28
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 4ac:	48f5                	li	a7,29
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 4b4:	48f9                	li	a7,30
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 4bc:	48fd                	li	a7,31
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c4:	1101                	addi	sp,sp,-32
 4c6:	ec06                	sd	ra,24(sp)
 4c8:	e822                	sd	s0,16(sp)
 4ca:	1000                	addi	s0,sp,32
 4cc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d0:	4605                	li	a2,1
 4d2:	fef40593          	addi	a1,s0,-17
 4d6:	f1fff0ef          	jal	3f4 <write>
}
 4da:	60e2                	ld	ra,24(sp)
 4dc:	6442                	ld	s0,16(sp)
 4de:	6105                	addi	sp,sp,32
 4e0:	8082                	ret

00000000000004e2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4e2:	715d                	addi	sp,sp,-80
 4e4:	e486                	sd	ra,72(sp)
 4e6:	e0a2                	sd	s0,64(sp)
 4e8:	f84a                	sd	s2,48(sp)
 4ea:	0880                	addi	s0,sp,80
 4ec:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4ee:	c299                	beqz	a3,4f4 <printint+0x12>
 4f0:	0805c363          	bltz	a1,576 <printint+0x94>
  neg = 0;
 4f4:	4881                	li	a7,0
 4f6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4fa:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4fc:	00000517          	auipc	a0,0x0
 500:	62c50513          	addi	a0,a0,1580 # b28 <digits>
 504:	883e                	mv	a6,a5
 506:	2785                	addiw	a5,a5,1
 508:	02c5f733          	remu	a4,a1,a2
 50c:	972a                	add	a4,a4,a0
 50e:	00074703          	lbu	a4,0(a4)
 512:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 516:	872e                	mv	a4,a1
 518:	02c5d5b3          	divu	a1,a1,a2
 51c:	0685                	addi	a3,a3,1
 51e:	fec773e3          	bgeu	a4,a2,504 <printint+0x22>
  if(neg)
 522:	00088b63          	beqz	a7,538 <printint+0x56>
    buf[i++] = '-';
 526:	fd078793          	addi	a5,a5,-48
 52a:	97a2                	add	a5,a5,s0
 52c:	02d00713          	li	a4,45
 530:	fee78423          	sb	a4,-24(a5)
 534:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 538:	02f05a63          	blez	a5,56c <printint+0x8a>
 53c:	fc26                	sd	s1,56(sp)
 53e:	f44e                	sd	s3,40(sp)
 540:	fb840713          	addi	a4,s0,-72
 544:	00f704b3          	add	s1,a4,a5
 548:	fff70993          	addi	s3,a4,-1
 54c:	99be                	add	s3,s3,a5
 54e:	37fd                	addiw	a5,a5,-1
 550:	1782                	slli	a5,a5,0x20
 552:	9381                	srli	a5,a5,0x20
 554:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 558:	fff4c583          	lbu	a1,-1(s1)
 55c:	854a                	mv	a0,s2
 55e:	f67ff0ef          	jal	4c4 <putc>
  while(--i >= 0)
 562:	14fd                	addi	s1,s1,-1
 564:	ff349ae3          	bne	s1,s3,558 <printint+0x76>
 568:	74e2                	ld	s1,56(sp)
 56a:	79a2                	ld	s3,40(sp)
}
 56c:	60a6                	ld	ra,72(sp)
 56e:	6406                	ld	s0,64(sp)
 570:	7942                	ld	s2,48(sp)
 572:	6161                	addi	sp,sp,80
 574:	8082                	ret
    x = -xx;
 576:	40b005b3          	neg	a1,a1
    neg = 1;
 57a:	4885                	li	a7,1
    x = -xx;
 57c:	bfad                	j	4f6 <printint+0x14>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	711d                	addi	sp,sp,-96
 580:	ec86                	sd	ra,88(sp)
 582:	e8a2                	sd	s0,80(sp)
 584:	e0ca                	sd	s2,64(sp)
 586:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c903          	lbu	s2,0(a1)
 58c:	28090663          	beqz	s2,818 <vprintf+0x29a>
 590:	e4a6                	sd	s1,72(sp)
 592:	fc4e                	sd	s3,56(sp)
 594:	f852                	sd	s4,48(sp)
 596:	f456                	sd	s5,40(sp)
 598:	f05a                	sd	s6,32(sp)
 59a:	ec5e                	sd	s7,24(sp)
 59c:	e862                	sd	s8,16(sp)
 59e:	e466                	sd	s9,8(sp)
 5a0:	8b2a                	mv	s6,a0
 5a2:	8a2e                	mv	s4,a1
 5a4:	8bb2                	mv	s7,a2
  state = 0;
 5a6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5a8:	4481                	li	s1,0
 5aa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ac:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	06c00c93          	li	s9,108
 5b8:	a005                	j	5d8 <vprintf+0x5a>
        putc(fd, c0);
 5ba:	85ca                	mv	a1,s2
 5bc:	855a                	mv	a0,s6
 5be:	f07ff0ef          	jal	4c4 <putc>
 5c2:	a019                	j	5c8 <vprintf+0x4a>
    } else if(state == '%'){
 5c4:	03598263          	beq	s3,s5,5e8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5c8:	2485                	addiw	s1,s1,1
 5ca:	8726                	mv	a4,s1
 5cc:	009a07b3          	add	a5,s4,s1
 5d0:	0007c903          	lbu	s2,0(a5)
 5d4:	22090a63          	beqz	s2,808 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5dc:	fe0994e3          	bnez	s3,5c4 <vprintf+0x46>
      if(c0 == '%'){
 5e0:	fd579de3          	bne	a5,s5,5ba <vprintf+0x3c>
        state = '%';
 5e4:	89be                	mv	s3,a5
 5e6:	b7cd                	j	5c8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e8:	00ea06b3          	add	a3,s4,a4
 5ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f2:	c681                	beqz	a3,5fa <vprintf+0x7c>
 5f4:	9752                	add	a4,a4,s4
 5f6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5fa:	05878363          	beq	a5,s8,640 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	05978d63          	beq	a5,s9,658 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 602:	07500713          	li	a4,117
 606:	0ee78763          	beq	a5,a4,6f4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 60a:	07800713          	li	a4,120
 60e:	12e78963          	beq	a5,a4,740 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 612:	07000713          	li	a4,112
 616:	14e78e63          	beq	a5,a4,772 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 61a:	06300713          	li	a4,99
 61e:	18e78e63          	beq	a5,a4,7ba <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 622:	07300713          	li	a4,115
 626:	1ae78463          	beq	a5,a4,7ce <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 62a:	02500713          	li	a4,37
 62e:	04e79563          	bne	a5,a4,678 <vprintf+0xfa>
        putc(fd, '%');
 632:	02500593          	li	a1,37
 636:	855a                	mv	a0,s6
 638:	e8dff0ef          	jal	4c4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 63c:	4981                	li	s3,0
 63e:	b769                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 640:	008b8913          	addi	s2,s7,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e95ff0ef          	jal	4e2 <printint>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bf8d                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 658:	06400793          	li	a5,100
 65c:	02f68963          	beq	a3,a5,68e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 660:	06c00793          	li	a5,108
 664:	04f68263          	beq	a3,a5,6a8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 668:	07500793          	li	a5,117
 66c:	0af68063          	beq	a3,a5,70c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 670:	07800793          	li	a5,120
 674:	0ef68263          	beq	a3,a5,758 <vprintf+0x1da>
        putc(fd, '%');
 678:	02500593          	li	a1,37
 67c:	855a                	mv	a0,s6
 67e:	e47ff0ef          	jal	4c4 <putc>
        putc(fd, c0);
 682:	85ca                	mv	a1,s2
 684:	855a                	mv	a0,s6
 686:	e3fff0ef          	jal	4c4 <putc>
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bf35                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68e:	008b8913          	addi	s2,s7,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000bb583          	ld	a1,0(s7)
 69a:	855a                	mv	a0,s6
 69c:	e47ff0ef          	jal	4e2 <printint>
        i += 1;
 6a0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a2:	8bca                	mv	s7,s2
      state = 0;
 6a4:	4981                	li	s3,0
        i += 1;
 6a6:	b70d                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a8:	06400793          	li	a5,100
 6ac:	02f60763          	beq	a2,a5,6da <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6b0:	07500793          	li	a5,117
 6b4:	06f60963          	beq	a2,a5,726 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b8:	07800793          	li	a5,120
 6bc:	faf61ee3          	bne	a2,a5,678 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000bb583          	ld	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	e15ff0ef          	jal	4e2 <printint>
        i += 2;
 6d2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
        i += 2;
 6d8:	bdc5                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6da:	008b8913          	addi	s2,s7,8
 6de:	4685                	li	a3,1
 6e0:	4629                	li	a2,10
 6e2:	000bb583          	ld	a1,0(s7)
 6e6:	855a                	mv	a0,s6
 6e8:	dfbff0ef          	jal	4e2 <printint>
        i += 2;
 6ec:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	8bca                	mv	s7,s2
      state = 0;
 6f0:	4981                	li	s3,0
        i += 2;
 6f2:	bdd9                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6f4:	008b8913          	addi	s2,s7,8
 6f8:	4681                	li	a3,0
 6fa:	4629                	li	a2,10
 6fc:	000be583          	lwu	a1,0(s7)
 700:	855a                	mv	a0,s6
 702:	de1ff0ef          	jal	4e2 <printint>
 706:	8bca                	mv	s7,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd7d                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70c:	008b8913          	addi	s2,s7,8
 710:	4681                	li	a3,0
 712:	4629                	li	a2,10
 714:	000bb583          	ld	a1,0(s7)
 718:	855a                	mv	a0,s6
 71a:	dc9ff0ef          	jal	4e2 <printint>
        i += 1;
 71e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 720:	8bca                	mv	s7,s2
      state = 0;
 722:	4981                	li	s3,0
        i += 1;
 724:	b555                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b8913          	addi	s2,s7,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000bb583          	ld	a1,0(s7)
 732:	855a                	mv	a0,s6
 734:	dafff0ef          	jal	4e2 <printint>
        i += 2;
 738:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	8bca                	mv	s7,s2
      state = 0;
 73c:	4981                	li	s3,0
        i += 2;
 73e:	b569                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 740:	008b8913          	addi	s2,s7,8
 744:	4681                	li	a3,0
 746:	4641                	li	a2,16
 748:	000be583          	lwu	a1,0(s7)
 74c:	855a                	mv	a0,s6
 74e:	d95ff0ef          	jal	4e2 <printint>
 752:	8bca                	mv	s7,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bd8d                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 758:	008b8913          	addi	s2,s7,8
 75c:	4681                	li	a3,0
 75e:	4641                	li	a2,16
 760:	000bb583          	ld	a1,0(s7)
 764:	855a                	mv	a0,s6
 766:	d7dff0ef          	jal	4e2 <printint>
        i += 1;
 76a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 76c:	8bca                	mv	s7,s2
      state = 0;
 76e:	4981                	li	s3,0
        i += 1;
 770:	bda1                	j	5c8 <vprintf+0x4a>
 772:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 774:	008b8d13          	addi	s10,s7,8
 778:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 77c:	03000593          	li	a1,48
 780:	855a                	mv	a0,s6
 782:	d43ff0ef          	jal	4c4 <putc>
  putc(fd, 'x');
 786:	07800593          	li	a1,120
 78a:	855a                	mv	a0,s6
 78c:	d39ff0ef          	jal	4c4 <putc>
 790:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	00000b97          	auipc	s7,0x0
 796:	396b8b93          	addi	s7,s7,918 # b28 <digits>
 79a:	03c9d793          	srli	a5,s3,0x3c
 79e:	97de                	add	a5,a5,s7
 7a0:	0007c583          	lbu	a1,0(a5)
 7a4:	855a                	mv	a0,s6
 7a6:	d1fff0ef          	jal	4c4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7aa:	0992                	slli	s3,s3,0x4
 7ac:	397d                	addiw	s2,s2,-1
 7ae:	fe0916e3          	bnez	s2,79a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7b2:	8bea                	mv	s7,s10
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	6d02                	ld	s10,0(sp)
 7b8:	bd01                	j	5c8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7ba:	008b8913          	addi	s2,s7,8
 7be:	000bc583          	lbu	a1,0(s7)
 7c2:	855a                	mv	a0,s6
 7c4:	d01ff0ef          	jal	4c4 <putc>
 7c8:	8bca                	mv	s7,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bbf5                	j	5c8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7ce:	008b8993          	addi	s3,s7,8
 7d2:	000bb903          	ld	s2,0(s7)
 7d6:	00090f63          	beqz	s2,7f4 <vprintf+0x276>
        for(; *s; s++)
 7da:	00094583          	lbu	a1,0(s2)
 7de:	c195                	beqz	a1,802 <vprintf+0x284>
          putc(fd, *s);
 7e0:	855a                	mv	a0,s6
 7e2:	ce3ff0ef          	jal	4c4 <putc>
        for(; *s; s++)
 7e6:	0905                	addi	s2,s2,1
 7e8:	00094583          	lbu	a1,0(s2)
 7ec:	f9f5                	bnez	a1,7e0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ee:	8bce                	mv	s7,s3
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	bbd9                	j	5c8 <vprintf+0x4a>
          s = "(null)";
 7f4:	00000917          	auipc	s2,0x0
 7f8:	32c90913          	addi	s2,s2,812 # b20 <malloc+0x220>
        for(; *s; s++)
 7fc:	02800593          	li	a1,40
 800:	b7c5                	j	7e0 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 802:	8bce                	mv	s7,s3
      state = 0;
 804:	4981                	li	s3,0
 806:	b3c9                	j	5c8 <vprintf+0x4a>
 808:	64a6                	ld	s1,72(sp)
 80a:	79e2                	ld	s3,56(sp)
 80c:	7a42                	ld	s4,48(sp)
 80e:	7aa2                	ld	s5,40(sp)
 810:	7b02                	ld	s6,32(sp)
 812:	6be2                	ld	s7,24(sp)
 814:	6c42                	ld	s8,16(sp)
 816:	6ca2                	ld	s9,8(sp)
    }
  }
}
 818:	60e6                	ld	ra,88(sp)
 81a:	6446                	ld	s0,80(sp)
 81c:	6906                	ld	s2,64(sp)
 81e:	6125                	addi	sp,sp,96
 820:	8082                	ret

0000000000000822 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 822:	715d                	addi	sp,sp,-80
 824:	ec06                	sd	ra,24(sp)
 826:	e822                	sd	s0,16(sp)
 828:	1000                	addi	s0,sp,32
 82a:	e010                	sd	a2,0(s0)
 82c:	e414                	sd	a3,8(s0)
 82e:	e818                	sd	a4,16(s0)
 830:	ec1c                	sd	a5,24(s0)
 832:	03043023          	sd	a6,32(s0)
 836:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 83a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83e:	8622                	mv	a2,s0
 840:	d3fff0ef          	jal	57e <vprintf>
}
 844:	60e2                	ld	ra,24(sp)
 846:	6442                	ld	s0,16(sp)
 848:	6161                	addi	sp,sp,80
 84a:	8082                	ret

000000000000084c <printf>:

void
printf(const char *fmt, ...)
{
 84c:	711d                	addi	sp,sp,-96
 84e:	ec06                	sd	ra,24(sp)
 850:	e822                	sd	s0,16(sp)
 852:	1000                	addi	s0,sp,32
 854:	e40c                	sd	a1,8(s0)
 856:	e810                	sd	a2,16(s0)
 858:	ec14                	sd	a3,24(s0)
 85a:	f018                	sd	a4,32(s0)
 85c:	f41c                	sd	a5,40(s0)
 85e:	03043823          	sd	a6,48(s0)
 862:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 866:	00840613          	addi	a2,s0,8
 86a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 86e:	85aa                	mv	a1,a0
 870:	4505                	li	a0,1
 872:	d0dff0ef          	jal	57e <vprintf>
}
 876:	60e2                	ld	ra,24(sp)
 878:	6442                	ld	s0,16(sp)
 87a:	6125                	addi	sp,sp,96
 87c:	8082                	ret

000000000000087e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 87e:	1141                	addi	sp,sp,-16
 880:	e422                	sd	s0,8(sp)
 882:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 884:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 888:	00000797          	auipc	a5,0x0
 88c:	7787b783          	ld	a5,1912(a5) # 1000 <freep>
 890:	a02d                	j	8ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 892:	4618                	lw	a4,8(a2)
 894:	9f2d                	addw	a4,a4,a1
 896:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	6310                	ld	a2,0(a4)
 89e:	a83d                	j	8dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a0:	ff852703          	lw	a4,-8(a0)
 8a4:	9f31                	addw	a4,a4,a2
 8a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a8:	ff053683          	ld	a3,-16(a0)
 8ac:	a091                	j	8f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ae:	6398                	ld	a4,0(a5)
 8b0:	00e7e463          	bltu	a5,a4,8b8 <free+0x3a>
 8b4:	00e6ea63          	bltu	a3,a4,8c8 <free+0x4a>
{
 8b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ba:	fed7fae3          	bgeu	a5,a3,8ae <free+0x30>
 8be:	6398                	ld	a4,0(a5)
 8c0:	00e6e463          	bltu	a3,a4,8c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c4:	fee7eae3          	bltu	a5,a4,8b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c8:	ff852583          	lw	a1,-8(a0)
 8cc:	6390                	ld	a2,0(a5)
 8ce:	02059813          	slli	a6,a1,0x20
 8d2:	01c85713          	srli	a4,a6,0x1c
 8d6:	9736                	add	a4,a4,a3
 8d8:	fae60de3          	beq	a2,a4,892 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e0:	4790                	lw	a2,8(a5)
 8e2:	02061593          	slli	a1,a2,0x20
 8e6:	01c5d713          	srli	a4,a1,0x1c
 8ea:	973e                	add	a4,a4,a5
 8ec:	fae68ae3          	beq	a3,a4,8a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f2:	00000717          	auipc	a4,0x0
 8f6:	70f73723          	sd	a5,1806(a4) # 1000 <freep>
}
 8fa:	6422                	ld	s0,8(sp)
 8fc:	0141                	addi	sp,sp,16
 8fe:	8082                	ret

0000000000000900 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 900:	7139                	addi	sp,sp,-64
 902:	fc06                	sd	ra,56(sp)
 904:	f822                	sd	s0,48(sp)
 906:	f426                	sd	s1,40(sp)
 908:	ec4e                	sd	s3,24(sp)
 90a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90c:	02051493          	slli	s1,a0,0x20
 910:	9081                	srli	s1,s1,0x20
 912:	04bd                	addi	s1,s1,15
 914:	8091                	srli	s1,s1,0x4
 916:	0014899b          	addiw	s3,s1,1
 91a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91c:	00000517          	auipc	a0,0x0
 920:	6e453503          	ld	a0,1764(a0) # 1000 <freep>
 924:	c915                	beqz	a0,958 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	08977a63          	bgeu	a4,s1,9be <malloc+0xbe>
 92e:	f04a                	sd	s2,32(sp)
 930:	e852                	sd	s4,16(sp)
 932:	e456                	sd	s5,8(sp)
 934:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 936:	8a4e                	mv	s4,s3
 938:	0009871b          	sext.w	a4,s3
 93c:	6685                	lui	a3,0x1
 93e:	00d77363          	bgeu	a4,a3,944 <malloc+0x44>
 942:	6a05                	lui	s4,0x1
 944:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 948:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94c:	00000917          	auipc	s2,0x0
 950:	6b490913          	addi	s2,s2,1716 # 1000 <freep>
  if(p == SBRK_ERROR)
 954:	5afd                	li	s5,-1
 956:	a081                	j	996 <malloc+0x96>
 958:	f04a                	sd	s2,32(sp)
 95a:	e852                	sd	s4,16(sp)
 95c:	e456                	sd	s5,8(sp)
 95e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 960:	00000797          	auipc	a5,0x0
 964:	6b078793          	addi	a5,a5,1712 # 1010 <base>
 968:	00000717          	auipc	a4,0x0
 96c:	68f73c23          	sd	a5,1688(a4) # 1000 <freep>
 970:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 972:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 976:	b7c1                	j	936 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 978:	6398                	ld	a4,0(a5)
 97a:	e118                	sd	a4,0(a0)
 97c:	a8a9                	j	9d6 <malloc+0xd6>
  hp->s.size = nu;
 97e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 982:	0541                	addi	a0,a0,16
 984:	efbff0ef          	jal	87e <free>
  return freep;
 988:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 98c:	c12d                	beqz	a0,9ee <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 990:	4798                	lw	a4,8(a5)
 992:	02977263          	bgeu	a4,s1,9b6 <malloc+0xb6>
    if(p == freep)
 996:	00093703          	ld	a4,0(s2)
 99a:	853e                	mv	a0,a5
 99c:	fef719e3          	bne	a4,a5,98e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9a0:	8552                	mv	a0,s4
 9a2:	9ffff0ef          	jal	3a0 <sbrk>
  if(p == SBRK_ERROR)
 9a6:	fd551ce3          	bne	a0,s5,97e <malloc+0x7e>
        return 0;
 9aa:	4501                	li	a0,0
 9ac:	7902                	ld	s2,32(sp)
 9ae:	6a42                	ld	s4,16(sp)
 9b0:	6aa2                	ld	s5,8(sp)
 9b2:	6b02                	ld	s6,0(sp)
 9b4:	a03d                	j	9e2 <malloc+0xe2>
 9b6:	7902                	ld	s2,32(sp)
 9b8:	6a42                	ld	s4,16(sp)
 9ba:	6aa2                	ld	s5,8(sp)
 9bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9be:	fae48de3          	beq	s1,a4,978 <malloc+0x78>
        p->s.size -= nunits;
 9c2:	4137073b          	subw	a4,a4,s3
 9c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9c8:	02071693          	slli	a3,a4,0x20
 9cc:	01c6d713          	srli	a4,a3,0x1c
 9d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9d6:	00000717          	auipc	a4,0x0
 9da:	62a73523          	sd	a0,1578(a4) # 1000 <freep>
      return (void*)(p + 1);
 9de:	01078513          	addi	a0,a5,16
  }
}
 9e2:	70e2                	ld	ra,56(sp)
 9e4:	7442                	ld	s0,48(sp)
 9e6:	74a2                	ld	s1,40(sp)
 9e8:	69e2                	ld	s3,24(sp)
 9ea:	6121                	addi	sp,sp,64
 9ec:	8082                	ret
 9ee:	7902                	ld	s2,32(sp)
 9f0:	6a42                	ld	s4,16(sp)
 9f2:	6aa2                	ld	s5,8(sp)
 9f4:	6b02                	ld	s6,0(sp)
 9f6:	b7f5                	j	9e2 <malloc+0xe2>
