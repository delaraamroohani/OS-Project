
user/_ipc_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Test IPC and Mount namespace

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int pid;

  printf("=== IPC and Mount Namespace Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	a6850513          	addi	a0,a0,-1432 # a70 <malloc+0x104>
  10:	0a9000ef          	jal	8b8 <printf>

  printf("Parent process:\n");
  14:	00001517          	auipc	a0,0x1
  18:	a8c50513          	addi	a0,a0,-1396 # aa0 <malloc+0x134>
  1c:	09d000ef          	jal	8b8 <printf>
  printf("  PID: %d\n", getpid());
  20:	4a0000ef          	jal	4c0 <getpid>
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	a9250513          	addi	a0,a0,-1390 # ab8 <malloc+0x14c>
  2e:	08b000ef          	jal	8b8 <printf>
  printf("  Next PID in namespace: %d\n\n", get_pid_namespace());
  32:	4de000ef          	jal	510 <get_pid_namespace>
  36:	85aa                	mv	a1,a0
  38:	00001517          	auipc	a0,0x1
  3c:	a9050513          	addi	a0,a0,-1392 # ac8 <malloc+0x15c>
  40:	079000ef          	jal	8b8 <printf>

  // Test unshare with CLONE_NEWIPC
  printf("Test 1: IPC Namespace Isolation\n");
  44:	00001517          	auipc	a0,0x1
  48:	aa450513          	addi	a0,a0,-1372 # ae8 <malloc+0x17c>
  4c:	06d000ef          	jal	8b8 <printf>
  pid = fork();
  50:	3e8000ef          	jal	438 <fork>
  if(pid == 0) {
  54:	e52d                	bnez	a0,be <main+0xbe>
    printf("  Child PID: %d\n", getpid());
  56:	46a000ef          	jal	4c0 <getpid>
  5a:	85aa                	mv	a1,a0
  5c:	00001517          	auipc	a0,0x1
  60:	ab450513          	addi	a0,a0,-1356 # b10 <malloc+0x1a4>
  64:	055000ef          	jal	8b8 <printf>
    printf("  Before unshare(CLONE_NEWIPC): next_pid = %d\n", get_pid_namespace());
  68:	4a8000ef          	jal	510 <get_pid_namespace>
  6c:	85aa                	mv	a1,a0
  6e:	00001517          	auipc	a0,0x1
  72:	aba50513          	addi	a0,a0,-1350 # b28 <malloc+0x1bc>
  76:	043000ef          	jal	8b8 <printf>
    
    unshare(CLONE_NEWIPC);
  7a:	08000537          	lui	a0,0x8000
  7e:	4aa000ef          	jal	528 <unshare>
    printf("  After unshare(CLONE_NEWIPC): next_pid = %d\n", get_pid_namespace());
  82:	48e000ef          	jal	510 <get_pid_namespace>
  86:	85aa                	mv	a1,a0
  88:	00001517          	auipc	a0,0x1
  8c:	ad050513          	addi	a0,a0,-1328 # b58 <malloc+0x1ec>
  90:	029000ef          	jal	8b8 <printf>
    
    // Children should inherit this IPC namespace
    int cpid = fork();
  94:	3a4000ef          	jal	438 <fork>
    if(cpid == 0) {
  98:	ed09                	bnez	a0,b2 <main+0xb2>
      printf("    Grandchild: next_pid = %d (inherited from parent)\n", get_pid_namespace());
  9a:	476000ef          	jal	510 <get_pid_namespace>
  9e:	85aa                	mv	a1,a0
  a0:	00001517          	auipc	a0,0x1
  a4:	ae850513          	addi	a0,a0,-1304 # b88 <malloc+0x21c>
  a8:	011000ef          	jal	8b8 <printf>
      exit(0);
  ac:	4501                	li	a0,0
  ae:	392000ef          	jal	440 <exit>
    } else {
      wait(0);
  b2:	4501                	li	a0,0
  b4:	394000ef          	jal	448 <wait>
    }
    exit(0);
  b8:	4501                	li	a0,0
  ba:	386000ef          	jal	440 <exit>
  } else {
    wait(0);
  be:	4501                	li	a0,0
  c0:	388000ef          	jal	448 <wait>
  }
  printf("\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	afc50513          	addi	a0,a0,-1284 # bc0 <malloc+0x254>
  cc:	7ec000ef          	jal	8b8 <printf>

  // Test unshare with CLONE_NEWNS (Mount namespace)
  printf("Test 2: Mount Namespace Isolation\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	af850513          	addi	a0,a0,-1288 # bc8 <malloc+0x25c>
  d8:	7e0000ef          	jal	8b8 <printf>
  pid = fork();
  dc:	35c000ef          	jal	438 <fork>
  if(pid == 0) {
  e0:	e139                	bnez	a0,126 <main+0x126>
    printf("  Child PID: %d\n", getpid());
  e2:	3de000ef          	jal	4c0 <getpid>
  e6:	85aa                	mv	a1,a0
  e8:	00001517          	auipc	a0,0x1
  ec:	a2850513          	addi	a0,a0,-1496 # b10 <malloc+0x1a4>
  f0:	7c8000ef          	jal	8b8 <printf>
    printf("  Before unshare(CLONE_NEWNS): next_pid = %d\n", get_pid_namespace());
  f4:	41c000ef          	jal	510 <get_pid_namespace>
  f8:	85aa                	mv	a1,a0
  fa:	00001517          	auipc	a0,0x1
  fe:	af650513          	addi	a0,a0,-1290 # bf0 <malloc+0x284>
 102:	7b6000ef          	jal	8b8 <printf>
    
    unshare(CLONE_NEWNS);
 106:	00020537          	lui	a0,0x20
 10a:	41e000ef          	jal	528 <unshare>
    printf("  After unshare(CLONE_NEWNS): next_pid = %d\n", get_pid_namespace());
 10e:	402000ef          	jal	510 <get_pid_namespace>
 112:	85aa                	mv	a1,a0
 114:	00001517          	auipc	a0,0x1
 118:	b0c50513          	addi	a0,a0,-1268 # c20 <malloc+0x2b4>
 11c:	79c000ef          	jal	8b8 <printf>
    
    exit(0);
 120:	4501                	li	a0,0
 122:	31e000ef          	jal	440 <exit>
  } else {
    wait(0);
 126:	4501                	li	a0,0
 128:	320000ef          	jal	448 <wait>
  }
  printf("\n");
 12c:	00001517          	auipc	a0,0x1
 130:	a9450513          	addi	a0,a0,-1388 # bc0 <malloc+0x254>
 134:	784000ef          	jal	8b8 <printf>

  // Test combined unshare
  printf("Test 3: Combined Namespaces\n");
 138:	00001517          	auipc	a0,0x1
 13c:	b1850513          	addi	a0,a0,-1256 # c50 <malloc+0x2e4>
 140:	778000ef          	jal	8b8 <printf>
  pid = fork();
 144:	2f4000ef          	jal	438 <fork>
  if(pid == 0) {
 148:	e531                	bnez	a0,194 <main+0x194>
    printf("  Child before unshare:\n");
 14a:	00001517          	auipc	a0,0x1
 14e:	b2650513          	addi	a0,a0,-1242 # c70 <malloc+0x304>
 152:	766000ef          	jal	8b8 <printf>
    printf("    PID ns: %d\n", get_pid_namespace());
 156:	3ba000ef          	jal	510 <get_pid_namespace>
 15a:	85aa                	mv	a1,a0
 15c:	00001517          	auipc	a0,0x1
 160:	b3450513          	addi	a0,a0,-1228 # c90 <malloc+0x324>
 164:	754000ef          	jal	8b8 <printf>
    
    // Create new PID, IPC, and Mount namespaces
    unshare(CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWNS);
 168:	28020537          	lui	a0,0x28020
 16c:	3bc000ef          	jal	528 <unshare>
    printf("  Child after unshare(CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWNS):\n");
 170:	00001517          	auipc	a0,0x1
 174:	b3050513          	addi	a0,a0,-1232 # ca0 <malloc+0x334>
 178:	740000ef          	jal	8b8 <printf>
    printf("    PID ns: %d\n", get_pid_namespace());
 17c:	394000ef          	jal	510 <get_pid_namespace>
 180:	85aa                	mv	a1,a0
 182:	00001517          	auipc	a0,0x1
 186:	b0e50513          	addi	a0,a0,-1266 # c90 <malloc+0x324>
 18a:	72e000ef          	jal	8b8 <printf>
    
    exit(0);
 18e:	4501                	li	a0,0
 190:	2b0000ef          	jal	440 <exit>
  } else {
    wait(0);
 194:	4501                	li	a0,0
 196:	2b2000ef          	jal	448 <wait>
  }

  printf("\n=== Test Complete ===\n");
 19a:	00001517          	auipc	a0,0x1
 19e:	b4e50513          	addi	a0,a0,-1202 # ce8 <malloc+0x37c>
 1a2:	716000ef          	jal	8b8 <printf>
  exit(0);
 1a6:	4501                	li	a0,0
 1a8:	298000ef          	jal	440 <exit>

00000000000001ac <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e406                	sd	ra,8(sp)
 1b0:	e022                	sd	s0,0(sp)
 1b2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1b4:	e4dff0ef          	jal	0 <main>
  exit(r);
 1b8:	288000ef          	jal	440 <exit>

00000000000001bc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c2:	87aa                	mv	a5,a0
 1c4:	0585                	addi	a1,a1,1
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff5c703          	lbu	a4,-1(a1)
 1cc:	fee78fa3          	sb	a4,-1(a5)
 1d0:	fb75                	bnez	a4,1c4 <strcpy+0x8>
    ;
  return os;
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cb91                	beqz	a5,1f6 <strcmp+0x1e>
 1e4:	0005c703          	lbu	a4,0(a1)
 1e8:	00f71763          	bne	a4,a5,1f6 <strcmp+0x1e>
    p++, q++;
 1ec:	0505                	addi	a0,a0,1
 1ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	fbe5                	bnez	a5,1e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f6:	0005c503          	lbu	a0,0(a1)
}
 1fa:	40a7853b          	subw	a0,a5,a0
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strlen>:

uint
strlen(const char *s)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cf91                	beqz	a5,22a <strlen+0x26>
 210:	0505                	addi	a0,a0,1
 212:	87aa                	mv	a5,a0
 214:	86be                	mv	a3,a5
 216:	0785                	addi	a5,a5,1
 218:	fff7c703          	lbu	a4,-1(a5)
 21c:	ff65                	bnez	a4,214 <strlen+0x10>
 21e:	40a6853b          	subw	a0,a3,a0
 222:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  for(n = 0; s[n]; n++)
 22a:	4501                	li	a0,0
 22c:	bfe5                	j	224 <strlen+0x20>

000000000000022e <memset>:

void*
memset(void *dst, int c, uint n)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 234:	ca19                	beqz	a2,24a <memset+0x1c>
 236:	87aa                	mv	a5,a0
 238:	1602                	slli	a2,a2,0x20
 23a:	9201                	srli	a2,a2,0x20
 23c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 240:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 244:	0785                	addi	a5,a5,1
 246:	fee79de3          	bne	a5,a4,240 <memset+0x12>
  }
  return dst;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret

0000000000000250 <strchr>:

char*
strchr(const char *s, char c)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  for(; *s; s++)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cb99                	beqz	a5,270 <strchr+0x20>
    if(*s == c)
 25c:	00f58763          	beq	a1,a5,26a <strchr+0x1a>
  for(; *s; s++)
 260:	0505                	addi	a0,a0,1
 262:	00054783          	lbu	a5,0(a0)
 266:	fbfd                	bnez	a5,25c <strchr+0xc>
      return (char*)s;
  return 0;
 268:	4501                	li	a0,0
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  return 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <strchr+0x1a>

0000000000000274 <gets>:

char*
gets(char *buf, int max)
{
 274:	711d                	addi	sp,sp,-96
 276:	ec86                	sd	ra,88(sp)
 278:	e8a2                	sd	s0,80(sp)
 27a:	e4a6                	sd	s1,72(sp)
 27c:	e0ca                	sd	s2,64(sp)
 27e:	fc4e                	sd	s3,56(sp)
 280:	f852                	sd	s4,48(sp)
 282:	f456                	sd	s5,40(sp)
 284:	f05a                	sd	s6,32(sp)
 286:	ec5e                	sd	s7,24(sp)
 288:	1080                	addi	s0,sp,96
 28a:	8baa                	mv	s7,a0
 28c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28e:	892a                	mv	s2,a0
 290:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 292:	4aa9                	li	s5,10
 294:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 296:	89a6                	mv	s3,s1
 298:	2485                	addiw	s1,s1,1
 29a:	0344d663          	bge	s1,s4,2c6 <gets+0x52>
    cc = read(0, &c, 1);
 29e:	4605                	li	a2,1
 2a0:	faf40593          	addi	a1,s0,-81
 2a4:	4501                	li	a0,0
 2a6:	1b2000ef          	jal	458 <read>
    if(cc < 1)
 2aa:	00a05e63          	blez	a0,2c6 <gets+0x52>
    buf[i++] = c;
 2ae:	faf44783          	lbu	a5,-81(s0)
 2b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b6:	01578763          	beq	a5,s5,2c4 <gets+0x50>
 2ba:	0905                	addi	s2,s2,1
 2bc:	fd679de3          	bne	a5,s6,296 <gets+0x22>
    buf[i++] = c;
 2c0:	89a6                	mv	s3,s1
 2c2:	a011                	j	2c6 <gets+0x52>
 2c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c6:	99de                	add	s3,s3,s7
 2c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2cc:	855e                	mv	a0,s7
 2ce:	60e6                	ld	ra,88(sp)
 2d0:	6446                	ld	s0,80(sp)
 2d2:	64a6                	ld	s1,72(sp)
 2d4:	6906                	ld	s2,64(sp)
 2d6:	79e2                	ld	s3,56(sp)
 2d8:	7a42                	ld	s4,48(sp)
 2da:	7aa2                	ld	s5,40(sp)
 2dc:	7b02                	ld	s6,32(sp)
 2de:	6be2                	ld	s7,24(sp)
 2e0:	6125                	addi	sp,sp,96
 2e2:	8082                	ret

00000000000002e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e4:	1101                	addi	sp,sp,-32
 2e6:	ec06                	sd	ra,24(sp)
 2e8:	e822                	sd	s0,16(sp)
 2ea:	e04a                	sd	s2,0(sp)
 2ec:	1000                	addi	s0,sp,32
 2ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f0:	4581                	li	a1,0
 2f2:	18e000ef          	jal	480 <open>
  if(fd < 0)
 2f6:	02054263          	bltz	a0,31a <stat+0x36>
 2fa:	e426                	sd	s1,8(sp)
 2fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2fe:	85ca                	mv	a1,s2
 300:	198000ef          	jal	498 <fstat>
 304:	892a                	mv	s2,a0
  close(fd);
 306:	8526                	mv	a0,s1
 308:	160000ef          	jal	468 <close>
  return r;
 30c:	64a2                	ld	s1,8(sp)
}
 30e:	854a                	mv	a0,s2
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	6902                	ld	s2,0(sp)
 316:	6105                	addi	sp,sp,32
 318:	8082                	ret
    return -1;
 31a:	597d                	li	s2,-1
 31c:	bfcd                	j	30e <stat+0x2a>

000000000000031e <atoi>:

int
atoi(const char *s)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 324:	00054683          	lbu	a3,0(a0)
 328:	fd06879b          	addiw	a5,a3,-48
 32c:	0ff7f793          	zext.b	a5,a5
 330:	4625                	li	a2,9
 332:	02f66863          	bltu	a2,a5,362 <atoi+0x44>
 336:	872a                	mv	a4,a0
  n = 0;
 338:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 33a:	0705                	addi	a4,a4,1
 33c:	0025179b          	slliw	a5,a0,0x2
 340:	9fa9                	addw	a5,a5,a0
 342:	0017979b          	slliw	a5,a5,0x1
 346:	9fb5                	addw	a5,a5,a3
 348:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34c:	00074683          	lbu	a3,0(a4)
 350:	fd06879b          	addiw	a5,a3,-48
 354:	0ff7f793          	zext.b	a5,a5
 358:	fef671e3          	bgeu	a2,a5,33a <atoi+0x1c>
  return n;
}
 35c:	6422                	ld	s0,8(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
  n = 0;
 362:	4501                	li	a0,0
 364:	bfe5                	j	35c <atoi+0x3e>

0000000000000366 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 366:	1141                	addi	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 36c:	02b57463          	bgeu	a0,a1,394 <memmove+0x2e>
    while(n-- > 0)
 370:	00c05f63          	blez	a2,38e <memmove+0x28>
 374:	1602                	slli	a2,a2,0x20
 376:	9201                	srli	a2,a2,0x20
 378:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 37c:	872a                	mv	a4,a0
      *dst++ = *src++;
 37e:	0585                	addi	a1,a1,1
 380:	0705                	addi	a4,a4,1
 382:	fff5c683          	lbu	a3,-1(a1)
 386:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 38a:	fef71ae3          	bne	a4,a5,37e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
    dst += n;
 394:	00c50733          	add	a4,a0,a2
    src += n;
 398:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 39a:	fec05ae3          	blez	a2,38e <memmove+0x28>
 39e:	fff6079b          	addiw	a5,a2,-1
 3a2:	1782                	slli	a5,a5,0x20
 3a4:	9381                	srli	a5,a5,0x20
 3a6:	fff7c793          	not	a5,a5
 3aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ac:	15fd                	addi	a1,a1,-1
 3ae:	177d                	addi	a4,a4,-1
 3b0:	0005c683          	lbu	a3,0(a1)
 3b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b8:	fee79ae3          	bne	a5,a4,3ac <memmove+0x46>
 3bc:	bfc9                	j	38e <memmove+0x28>

00000000000003be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c4:	ca05                	beqz	a2,3f4 <memcmp+0x36>
 3c6:	fff6069b          	addiw	a3,a2,-1
 3ca:	1682                	slli	a3,a3,0x20
 3cc:	9281                	srli	a3,a3,0x20
 3ce:	0685                	addi	a3,a3,1
 3d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d2:	00054783          	lbu	a5,0(a0)
 3d6:	0005c703          	lbu	a4,0(a1)
 3da:	00e79863          	bne	a5,a4,3ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3de:	0505                	addi	a0,a0,1
    p2++;
 3e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e2:	fed518e3          	bne	a0,a3,3d2 <memcmp+0x14>
  }
  return 0;
 3e6:	4501                	li	a0,0
 3e8:	a019                	j	3ee <memcmp+0x30>
      return *p1 - *p2;
 3ea:	40e7853b          	subw	a0,a5,a4
}
 3ee:	6422                	ld	s0,8(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
  return 0;
 3f4:	4501                	li	a0,0
 3f6:	bfe5                	j	3ee <memcmp+0x30>

00000000000003f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e406                	sd	ra,8(sp)
 3fc:	e022                	sd	s0,0(sp)
 3fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 400:	f67ff0ef          	jal	366 <memmove>
}
 404:	60a2                	ld	ra,8(sp)
 406:	6402                	ld	s0,0(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret

000000000000040c <sbrk>:

char *
sbrk(int n) {
 40c:	1141                	addi	sp,sp,-16
 40e:	e406                	sd	ra,8(sp)
 410:	e022                	sd	s0,0(sp)
 412:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 414:	4585                	li	a1,1
 416:	0b2000ef          	jal	4c8 <sys_sbrk>
}
 41a:	60a2                	ld	ra,8(sp)
 41c:	6402                	ld	s0,0(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret

0000000000000422 <sbrklazy>:

char *
sbrklazy(int n) {
 422:	1141                	addi	sp,sp,-16
 424:	e406                	sd	ra,8(sp)
 426:	e022                	sd	s0,0(sp)
 428:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 42a:	4589                	li	a1,2
 42c:	09c000ef          	jal	4c8 <sys_sbrk>
}
 430:	60a2                	ld	ra,8(sp)
 432:	6402                	ld	s0,0(sp)
 434:	0141                	addi	sp,sp,16
 436:	8082                	ret

0000000000000438 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 438:	4885                	li	a7,1
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <exit>:
.global exit
exit:
 li a7, SYS_exit
 440:	4889                	li	a7,2
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <wait>:
.global wait
wait:
 li a7, SYS_wait
 448:	488d                	li	a7,3
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 450:	4891                	li	a7,4
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <read>:
.global read
read:
 li a7, SYS_read
 458:	4895                	li	a7,5
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <write>:
.global write
write:
 li a7, SYS_write
 460:	48c1                	li	a7,16
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <close>:
.global close
close:
 li a7, SYS_close
 468:	48d5                	li	a7,21
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <kill>:
.global kill
kill:
 li a7, SYS_kill
 470:	4899                	li	a7,6
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <exec>:
.global exec
exec:
 li a7, SYS_exec
 478:	489d                	li	a7,7
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <open>:
.global open
open:
 li a7, SYS_open
 480:	48bd                	li	a7,15
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 488:	48c5                	li	a7,17
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 490:	48c9                	li	a7,18
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 498:	48a1                	li	a7,8
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <link>:
.global link
link:
 li a7, SYS_link
 4a0:	48cd                	li	a7,19
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a8:	48d1                	li	a7,20
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b0:	48a5                	li	a7,9
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b8:	48a9                	li	a7,10
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c0:	48ad                	li	a7,11
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4c8:	48b1                	li	a7,12
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4d0:	48b5                	li	a7,13
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d8:	48b9                	li	a7,14
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 4e0:	48d9                	li	a7,22
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 4e8:	48dd                	li	a7,23
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 4f0:	48e1                	li	a7,24
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 4f8:	48e5                	li	a7,25
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 500:	48e9                	li	a7,26
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 508:	48ed                	li	a7,27
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 510:	48f1                	li	a7,28
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 518:	48f5                	li	a7,29
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 520:	48f9                	li	a7,30
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 528:	48fd                	li	a7,31
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 530:	1101                	addi	sp,sp,-32
 532:	ec06                	sd	ra,24(sp)
 534:	e822                	sd	s0,16(sp)
 536:	1000                	addi	s0,sp,32
 538:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 53c:	4605                	li	a2,1
 53e:	fef40593          	addi	a1,s0,-17
 542:	f1fff0ef          	jal	460 <write>
}
 546:	60e2                	ld	ra,24(sp)
 548:	6442                	ld	s0,16(sp)
 54a:	6105                	addi	sp,sp,32
 54c:	8082                	ret

000000000000054e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 54e:	715d                	addi	sp,sp,-80
 550:	e486                	sd	ra,72(sp)
 552:	e0a2                	sd	s0,64(sp)
 554:	f84a                	sd	s2,48(sp)
 556:	0880                	addi	s0,sp,80
 558:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 55a:	c299                	beqz	a3,560 <printint+0x12>
 55c:	0805c363          	bltz	a1,5e2 <printint+0x94>
  neg = 0;
 560:	4881                	li	a7,0
 562:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 566:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 568:	00000517          	auipc	a0,0x0
 56c:	7a050513          	addi	a0,a0,1952 # d08 <digits>
 570:	883e                	mv	a6,a5
 572:	2785                	addiw	a5,a5,1
 574:	02c5f733          	remu	a4,a1,a2
 578:	972a                	add	a4,a4,a0
 57a:	00074703          	lbu	a4,0(a4)
 57e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 582:	872e                	mv	a4,a1
 584:	02c5d5b3          	divu	a1,a1,a2
 588:	0685                	addi	a3,a3,1
 58a:	fec773e3          	bgeu	a4,a2,570 <printint+0x22>
  if(neg)
 58e:	00088b63          	beqz	a7,5a4 <printint+0x56>
    buf[i++] = '-';
 592:	fd078793          	addi	a5,a5,-48
 596:	97a2                	add	a5,a5,s0
 598:	02d00713          	li	a4,45
 59c:	fee78423          	sb	a4,-24(a5)
 5a0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5a4:	02f05a63          	blez	a5,5d8 <printint+0x8a>
 5a8:	fc26                	sd	s1,56(sp)
 5aa:	f44e                	sd	s3,40(sp)
 5ac:	fb840713          	addi	a4,s0,-72
 5b0:	00f704b3          	add	s1,a4,a5
 5b4:	fff70993          	addi	s3,a4,-1
 5b8:	99be                	add	s3,s3,a5
 5ba:	37fd                	addiw	a5,a5,-1
 5bc:	1782                	slli	a5,a5,0x20
 5be:	9381                	srli	a5,a5,0x20
 5c0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5c4:	fff4c583          	lbu	a1,-1(s1)
 5c8:	854a                	mv	a0,s2
 5ca:	f67ff0ef          	jal	530 <putc>
  while(--i >= 0)
 5ce:	14fd                	addi	s1,s1,-1
 5d0:	ff349ae3          	bne	s1,s3,5c4 <printint+0x76>
 5d4:	74e2                	ld	s1,56(sp)
 5d6:	79a2                	ld	s3,40(sp)
}
 5d8:	60a6                	ld	ra,72(sp)
 5da:	6406                	ld	s0,64(sp)
 5dc:	7942                	ld	s2,48(sp)
 5de:	6161                	addi	sp,sp,80
 5e0:	8082                	ret
    x = -xx;
 5e2:	40b005b3          	neg	a1,a1
    neg = 1;
 5e6:	4885                	li	a7,1
    x = -xx;
 5e8:	bfad                	j	562 <printint+0x14>

00000000000005ea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ea:	711d                	addi	sp,sp,-96
 5ec:	ec86                	sd	ra,88(sp)
 5ee:	e8a2                	sd	s0,80(sp)
 5f0:	e0ca                	sd	s2,64(sp)
 5f2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f4:	0005c903          	lbu	s2,0(a1)
 5f8:	28090663          	beqz	s2,884 <vprintf+0x29a>
 5fc:	e4a6                	sd	s1,72(sp)
 5fe:	fc4e                	sd	s3,56(sp)
 600:	f852                	sd	s4,48(sp)
 602:	f456                	sd	s5,40(sp)
 604:	f05a                	sd	s6,32(sp)
 606:	ec5e                	sd	s7,24(sp)
 608:	e862                	sd	s8,16(sp)
 60a:	e466                	sd	s9,8(sp)
 60c:	8b2a                	mv	s6,a0
 60e:	8a2e                	mv	s4,a1
 610:	8bb2                	mv	s7,a2
  state = 0;
 612:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 614:	4481                	li	s1,0
 616:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 618:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 61c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 620:	06c00c93          	li	s9,108
 624:	a005                	j	644 <vprintf+0x5a>
        putc(fd, c0);
 626:	85ca                	mv	a1,s2
 628:	855a                	mv	a0,s6
 62a:	f07ff0ef          	jal	530 <putc>
 62e:	a019                	j	634 <vprintf+0x4a>
    } else if(state == '%'){
 630:	03598263          	beq	s3,s5,654 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 634:	2485                	addiw	s1,s1,1
 636:	8726                	mv	a4,s1
 638:	009a07b3          	add	a5,s4,s1
 63c:	0007c903          	lbu	s2,0(a5)
 640:	22090a63          	beqz	s2,874 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 644:	0009079b          	sext.w	a5,s2
    if(state == 0){
 648:	fe0994e3          	bnez	s3,630 <vprintf+0x46>
      if(c0 == '%'){
 64c:	fd579de3          	bne	a5,s5,626 <vprintf+0x3c>
        state = '%';
 650:	89be                	mv	s3,a5
 652:	b7cd                	j	634 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 654:	00ea06b3          	add	a3,s4,a4
 658:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 65c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 65e:	c681                	beqz	a3,666 <vprintf+0x7c>
 660:	9752                	add	a4,a4,s4
 662:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 666:	05878363          	beq	a5,s8,6ac <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 66a:	05978d63          	beq	a5,s9,6c4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 66e:	07500713          	li	a4,117
 672:	0ee78763          	beq	a5,a4,760 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 676:	07800713          	li	a4,120
 67a:	12e78963          	beq	a5,a4,7ac <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 67e:	07000713          	li	a4,112
 682:	14e78e63          	beq	a5,a4,7de <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 686:	06300713          	li	a4,99
 68a:	18e78e63          	beq	a5,a4,826 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 68e:	07300713          	li	a4,115
 692:	1ae78463          	beq	a5,a4,83a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 696:	02500713          	li	a4,37
 69a:	04e79563          	bne	a5,a4,6e4 <vprintf+0xfa>
        putc(fd, '%');
 69e:	02500593          	li	a1,37
 6a2:	855a                	mv	a0,s6
 6a4:	e8dff0ef          	jal	530 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b769                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	4685                	li	a3,1
 6b2:	4629                	li	a2,10
 6b4:	000ba583          	lw	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	e95ff0ef          	jal	54e <printint>
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bf8d                	j	634 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6c4:	06400793          	li	a5,100
 6c8:	02f68963          	beq	a3,a5,6fa <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6cc:	06c00793          	li	a5,108
 6d0:	04f68263          	beq	a3,a5,714 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6d4:	07500793          	li	a5,117
 6d8:	0af68063          	beq	a3,a5,778 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6dc:	07800793          	li	a5,120
 6e0:	0ef68263          	beq	a3,a5,7c4 <vprintf+0x1da>
        putc(fd, '%');
 6e4:	02500593          	li	a1,37
 6e8:	855a                	mv	a0,s6
 6ea:	e47ff0ef          	jal	530 <putc>
        putc(fd, c0);
 6ee:	85ca                	mv	a1,s2
 6f0:	855a                	mv	a0,s6
 6f2:	e3fff0ef          	jal	530 <putc>
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bf35                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4685                	li	a3,1
 700:	4629                	li	a2,10
 702:	000bb583          	ld	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	e47ff0ef          	jal	54e <printint>
        i += 1;
 70c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
        i += 1;
 712:	b70d                	j	634 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 714:	06400793          	li	a5,100
 718:	02f60763          	beq	a2,a5,746 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 71c:	07500793          	li	a5,117
 720:	06f60963          	beq	a2,a5,792 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 724:	07800793          	li	a5,120
 728:	faf61ee3          	bne	a2,a5,6e4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 72c:	008b8913          	addi	s2,s7,8
 730:	4681                	li	a3,0
 732:	4641                	li	a2,16
 734:	000bb583          	ld	a1,0(s7)
 738:	855a                	mv	a0,s6
 73a:	e15ff0ef          	jal	54e <printint>
        i += 2;
 73e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
        i += 2;
 744:	bdc5                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 746:	008b8913          	addi	s2,s7,8
 74a:	4685                	li	a3,1
 74c:	4629                	li	a2,10
 74e:	000bb583          	ld	a1,0(s7)
 752:	855a                	mv	a0,s6
 754:	dfbff0ef          	jal	54e <printint>
        i += 2;
 758:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 75a:	8bca                	mv	s7,s2
      state = 0;
 75c:	4981                	li	s3,0
        i += 2;
 75e:	bdd9                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4629                	li	a2,10
 768:	000be583          	lwu	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	de1ff0ef          	jal	54e <printint>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bd7d                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 778:	008b8913          	addi	s2,s7,8
 77c:	4681                	li	a3,0
 77e:	4629                	li	a2,10
 780:	000bb583          	ld	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	dc9ff0ef          	jal	54e <printint>
        i += 1;
 78a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 78c:	8bca                	mv	s7,s2
      state = 0;
 78e:	4981                	li	s3,0
        i += 1;
 790:	b555                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 792:	008b8913          	addi	s2,s7,8
 796:	4681                	li	a3,0
 798:	4629                	li	a2,10
 79a:	000bb583          	ld	a1,0(s7)
 79e:	855a                	mv	a0,s6
 7a0:	dafff0ef          	jal	54e <printint>
        i += 2;
 7a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
        i += 2;
 7aa:	b569                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4681                	li	a3,0
 7b2:	4641                	li	a2,16
 7b4:	000be583          	lwu	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	d95ff0ef          	jal	54e <printint>
 7be:	8bca                	mv	s7,s2
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bd8d                	j	634 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7c4:	008b8913          	addi	s2,s7,8
 7c8:	4681                	li	a3,0
 7ca:	4641                	li	a2,16
 7cc:	000bb583          	ld	a1,0(s7)
 7d0:	855a                	mv	a0,s6
 7d2:	d7dff0ef          	jal	54e <printint>
        i += 1;
 7d6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d8:	8bca                	mv	s7,s2
      state = 0;
 7da:	4981                	li	s3,0
        i += 1;
 7dc:	bda1                	j	634 <vprintf+0x4a>
 7de:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7e0:	008b8d13          	addi	s10,s7,8
 7e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7e8:	03000593          	li	a1,48
 7ec:	855a                	mv	a0,s6
 7ee:	d43ff0ef          	jal	530 <putc>
  putc(fd, 'x');
 7f2:	07800593          	li	a1,120
 7f6:	855a                	mv	a0,s6
 7f8:	d39ff0ef          	jal	530 <putc>
 7fc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7fe:	00000b97          	auipc	s7,0x0
 802:	50ab8b93          	addi	s7,s7,1290 # d08 <digits>
 806:	03c9d793          	srli	a5,s3,0x3c
 80a:	97de                	add	a5,a5,s7
 80c:	0007c583          	lbu	a1,0(a5)
 810:	855a                	mv	a0,s6
 812:	d1fff0ef          	jal	530 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 816:	0992                	slli	s3,s3,0x4
 818:	397d                	addiw	s2,s2,-1
 81a:	fe0916e3          	bnez	s2,806 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 81e:	8bea                	mv	s7,s10
      state = 0;
 820:	4981                	li	s3,0
 822:	6d02                	ld	s10,0(sp)
 824:	bd01                	j	634 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 826:	008b8913          	addi	s2,s7,8
 82a:	000bc583          	lbu	a1,0(s7)
 82e:	855a                	mv	a0,s6
 830:	d01ff0ef          	jal	530 <putc>
 834:	8bca                	mv	s7,s2
      state = 0;
 836:	4981                	li	s3,0
 838:	bbf5                	j	634 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 83a:	008b8993          	addi	s3,s7,8
 83e:	000bb903          	ld	s2,0(s7)
 842:	00090f63          	beqz	s2,860 <vprintf+0x276>
        for(; *s; s++)
 846:	00094583          	lbu	a1,0(s2)
 84a:	c195                	beqz	a1,86e <vprintf+0x284>
          putc(fd, *s);
 84c:	855a                	mv	a0,s6
 84e:	ce3ff0ef          	jal	530 <putc>
        for(; *s; s++)
 852:	0905                	addi	s2,s2,1
 854:	00094583          	lbu	a1,0(s2)
 858:	f9f5                	bnez	a1,84c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 85a:	8bce                	mv	s7,s3
      state = 0;
 85c:	4981                	li	s3,0
 85e:	bbd9                	j	634 <vprintf+0x4a>
          s = "(null)";
 860:	00000917          	auipc	s2,0x0
 864:	4a090913          	addi	s2,s2,1184 # d00 <malloc+0x394>
        for(; *s; s++)
 868:	02800593          	li	a1,40
 86c:	b7c5                	j	84c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 86e:	8bce                	mv	s7,s3
      state = 0;
 870:	4981                	li	s3,0
 872:	b3c9                	j	634 <vprintf+0x4a>
 874:	64a6                	ld	s1,72(sp)
 876:	79e2                	ld	s3,56(sp)
 878:	7a42                	ld	s4,48(sp)
 87a:	7aa2                	ld	s5,40(sp)
 87c:	7b02                	ld	s6,32(sp)
 87e:	6be2                	ld	s7,24(sp)
 880:	6c42                	ld	s8,16(sp)
 882:	6ca2                	ld	s9,8(sp)
    }
  }
}
 884:	60e6                	ld	ra,88(sp)
 886:	6446                	ld	s0,80(sp)
 888:	6906                	ld	s2,64(sp)
 88a:	6125                	addi	sp,sp,96
 88c:	8082                	ret

000000000000088e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 88e:	715d                	addi	sp,sp,-80
 890:	ec06                	sd	ra,24(sp)
 892:	e822                	sd	s0,16(sp)
 894:	1000                	addi	s0,sp,32
 896:	e010                	sd	a2,0(s0)
 898:	e414                	sd	a3,8(s0)
 89a:	e818                	sd	a4,16(s0)
 89c:	ec1c                	sd	a5,24(s0)
 89e:	03043023          	sd	a6,32(s0)
 8a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8aa:	8622                	mv	a2,s0
 8ac:	d3fff0ef          	jal	5ea <vprintf>
}
 8b0:	60e2                	ld	ra,24(sp)
 8b2:	6442                	ld	s0,16(sp)
 8b4:	6161                	addi	sp,sp,80
 8b6:	8082                	ret

00000000000008b8 <printf>:

void
printf(const char *fmt, ...)
{
 8b8:	711d                	addi	sp,sp,-96
 8ba:	ec06                	sd	ra,24(sp)
 8bc:	e822                	sd	s0,16(sp)
 8be:	1000                	addi	s0,sp,32
 8c0:	e40c                	sd	a1,8(s0)
 8c2:	e810                	sd	a2,16(s0)
 8c4:	ec14                	sd	a3,24(s0)
 8c6:	f018                	sd	a4,32(s0)
 8c8:	f41c                	sd	a5,40(s0)
 8ca:	03043823          	sd	a6,48(s0)
 8ce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8d2:	00840613          	addi	a2,s0,8
 8d6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8da:	85aa                	mv	a1,a0
 8dc:	4505                	li	a0,1
 8de:	d0dff0ef          	jal	5ea <vprintf>
}
 8e2:	60e2                	ld	ra,24(sp)
 8e4:	6442                	ld	s0,16(sp)
 8e6:	6125                	addi	sp,sp,96
 8e8:	8082                	ret

00000000000008ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ea:	1141                	addi	sp,sp,-16
 8ec:	e422                	sd	s0,8(sp)
 8ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f4:	00000797          	auipc	a5,0x0
 8f8:	70c7b783          	ld	a5,1804(a5) # 1000 <freep>
 8fc:	a02d                	j	926 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8fe:	4618                	lw	a4,8(a2)
 900:	9f2d                	addw	a4,a4,a1
 902:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	6310                	ld	a2,0(a4)
 90a:	a83d                	j	948 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 90c:	ff852703          	lw	a4,-8(a0)
 910:	9f31                	addw	a4,a4,a2
 912:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 914:	ff053683          	ld	a3,-16(a0)
 918:	a091                	j	95c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91a:	6398                	ld	a4,0(a5)
 91c:	00e7e463          	bltu	a5,a4,924 <free+0x3a>
 920:	00e6ea63          	bltu	a3,a4,934 <free+0x4a>
{
 924:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 926:	fed7fae3          	bgeu	a5,a3,91a <free+0x30>
 92a:	6398                	ld	a4,0(a5)
 92c:	00e6e463          	bltu	a3,a4,934 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 930:	fee7eae3          	bltu	a5,a4,924 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 934:	ff852583          	lw	a1,-8(a0)
 938:	6390                	ld	a2,0(a5)
 93a:	02059813          	slli	a6,a1,0x20
 93e:	01c85713          	srli	a4,a6,0x1c
 942:	9736                	add	a4,a4,a3
 944:	fae60de3          	beq	a2,a4,8fe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 948:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 94c:	4790                	lw	a2,8(a5)
 94e:	02061593          	slli	a1,a2,0x20
 952:	01c5d713          	srli	a4,a1,0x1c
 956:	973e                	add	a4,a4,a5
 958:	fae68ae3          	beq	a3,a4,90c <free+0x22>
    p->s.ptr = bp->s.ptr;
 95c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 95e:	00000717          	auipc	a4,0x0
 962:	6af73123          	sd	a5,1698(a4) # 1000 <freep>
}
 966:	6422                	ld	s0,8(sp)
 968:	0141                	addi	sp,sp,16
 96a:	8082                	ret

000000000000096c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 96c:	7139                	addi	sp,sp,-64
 96e:	fc06                	sd	ra,56(sp)
 970:	f822                	sd	s0,48(sp)
 972:	f426                	sd	s1,40(sp)
 974:	ec4e                	sd	s3,24(sp)
 976:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 978:	02051493          	slli	s1,a0,0x20
 97c:	9081                	srli	s1,s1,0x20
 97e:	04bd                	addi	s1,s1,15
 980:	8091                	srli	s1,s1,0x4
 982:	0014899b          	addiw	s3,s1,1
 986:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 988:	00000517          	auipc	a0,0x0
 98c:	67853503          	ld	a0,1656(a0) # 1000 <freep>
 990:	c915                	beqz	a0,9c4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 992:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 994:	4798                	lw	a4,8(a5)
 996:	08977a63          	bgeu	a4,s1,a2a <malloc+0xbe>
 99a:	f04a                	sd	s2,32(sp)
 99c:	e852                	sd	s4,16(sp)
 99e:	e456                	sd	s5,8(sp)
 9a0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9a2:	8a4e                	mv	s4,s3
 9a4:	0009871b          	sext.w	a4,s3
 9a8:	6685                	lui	a3,0x1
 9aa:	00d77363          	bgeu	a4,a3,9b0 <malloc+0x44>
 9ae:	6a05                	lui	s4,0x1
 9b0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9b4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9b8:	00000917          	auipc	s2,0x0
 9bc:	64890913          	addi	s2,s2,1608 # 1000 <freep>
  if(p == SBRK_ERROR)
 9c0:	5afd                	li	s5,-1
 9c2:	a081                	j	a02 <malloc+0x96>
 9c4:	f04a                	sd	s2,32(sp)
 9c6:	e852                	sd	s4,16(sp)
 9c8:	e456                	sd	s5,8(sp)
 9ca:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9cc:	00000797          	auipc	a5,0x0
 9d0:	64478793          	addi	a5,a5,1604 # 1010 <base>
 9d4:	00000717          	auipc	a4,0x0
 9d8:	62f73623          	sd	a5,1580(a4) # 1000 <freep>
 9dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9e2:	b7c1                	j	9a2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9e4:	6398                	ld	a4,0(a5)
 9e6:	e118                	sd	a4,0(a0)
 9e8:	a8a9                	j	a42 <malloc+0xd6>
  hp->s.size = nu;
 9ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ee:	0541                	addi	a0,a0,16
 9f0:	efbff0ef          	jal	8ea <free>
  return freep;
 9f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9f8:	c12d                	beqz	a0,a5a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9fc:	4798                	lw	a4,8(a5)
 9fe:	02977263          	bgeu	a4,s1,a22 <malloc+0xb6>
    if(p == freep)
 a02:	00093703          	ld	a4,0(s2)
 a06:	853e                	mv	a0,a5
 a08:	fef719e3          	bne	a4,a5,9fa <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a0c:	8552                	mv	a0,s4
 a0e:	9ffff0ef          	jal	40c <sbrk>
  if(p == SBRK_ERROR)
 a12:	fd551ce3          	bne	a0,s5,9ea <malloc+0x7e>
        return 0;
 a16:	4501                	li	a0,0
 a18:	7902                	ld	s2,32(sp)
 a1a:	6a42                	ld	s4,16(sp)
 a1c:	6aa2                	ld	s5,8(sp)
 a1e:	6b02                	ld	s6,0(sp)
 a20:	a03d                	j	a4e <malloc+0xe2>
 a22:	7902                	ld	s2,32(sp)
 a24:	6a42                	ld	s4,16(sp)
 a26:	6aa2                	ld	s5,8(sp)
 a28:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a2a:	fae48de3          	beq	s1,a4,9e4 <malloc+0x78>
        p->s.size -= nunits;
 a2e:	4137073b          	subw	a4,a4,s3
 a32:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a34:	02071693          	slli	a3,a4,0x20
 a38:	01c6d713          	srli	a4,a3,0x1c
 a3c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a3e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a42:	00000717          	auipc	a4,0x0
 a46:	5aa73f23          	sd	a0,1470(a4) # 1000 <freep>
      return (void*)(p + 1);
 a4a:	01078513          	addi	a0,a5,16
  }
}
 a4e:	70e2                	ld	ra,56(sp)
 a50:	7442                	ld	s0,48(sp)
 a52:	74a2                	ld	s1,40(sp)
 a54:	69e2                	ld	s3,24(sp)
 a56:	6121                	addi	sp,sp,64
 a58:	8082                	ret
 a5a:	7902                	ld	s2,32(sp)
 a5c:	6a42                	ld	s4,16(sp)
 a5e:	6aa2                	ld	s5,8(sp)
 a60:	6b02                	ld	s6,0(sp)
 a62:	b7f5                	j	a4e <malloc+0xe2>
