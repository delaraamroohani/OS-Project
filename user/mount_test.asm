
user/_mount_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
// Mount Namespace Test
// Tests filesystem root isolation between processes

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  int pid;

  printf("=== Mount Namespace Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	a3850513          	addi	a0,a0,-1480 # a40 <malloc+0xfa>
  10:	083000ef          	jal	892 <printf>

  printf("Parent process:\n");
  14:	00001517          	auipc	a0,0x1
  18:	a5450513          	addi	a0,a0,-1452 # a68 <malloc+0x122>
  1c:	077000ef          	jal	892 <printf>
  printf("  Testing filesystem access\n");
  20:	00001517          	auipc	a0,0x1
  24:	a6050513          	addi	a0,a0,-1440 # a80 <malloc+0x13a>
  28:	06b000ef          	jal	892 <printf>
  printf("  Current directory: /\n\n");
  2c:	00001517          	auipc	a0,0x1
  30:	a7450513          	addi	a0,a0,-1420 # aa0 <malloc+0x15a>
  34:	05f000ef          	jal	892 <printf>

  // Create first child with isolated mount namespace
  pid = fork();
  38:	3da000ef          	jal	412 <fork>
  if(pid == 0) {
  3c:	ed0d                	bnez	a0,76 <main+0x76>
    // Child process
    printf("Child 1 process:\n");
  3e:	00001517          	auipc	a0,0x1
  42:	a8250513          	addi	a0,a0,-1406 # ac0 <malloc+0x17a>
  46:	04d000ef          	jal	892 <printf>
    printf("  Created with fork - inherits parent mount namespace\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	a8e50513          	addi	a0,a0,-1394 # ad8 <malloc+0x192>
  52:	041000ef          	jal	892 <printf>
    
    // Simulate mount namespace operation
    printf("  Root inode: 0x%x (parent's root)\n", (unsigned int)0);
  56:	4581                	li	a1,0
  58:	00001517          	auipc	a0,0x1
  5c:	ab850513          	addi	a0,a0,-1352 # b10 <malloc+0x1ca>
  60:	033000ef          	jal	892 <printf>
    printf("  Can access parent's filesystem\n\n");
  64:	00001517          	auipc	a0,0x1
  68:	ad450513          	addi	a0,a0,-1324 # b38 <malloc+0x1f2>
  6c:	027000ef          	jal	892 <printf>
    
    exit(0);
  70:	4501                	li	a0,0
  72:	3a8000ef          	jal	41a <exit>
  }

  // Create second child
  pid = fork();
  76:	39c000ef          	jal	412 <fork>
  if(pid == 0) {
  7a:	e52d                	bnez	a0,e4 <main+0xe4>
    // Second child
    printf("Child 2 process:\n");
  7c:	00001517          	auipc	a0,0x1
  80:	ae450513          	addi	a0,a0,-1308 # b60 <malloc+0x21a>
  84:	00f000ef          	jal	892 <printf>
    printf("  Also inherits parent mount namespace\n");
  88:	00001517          	auipc	a0,0x1
  8c:	af050513          	addi	a0,a0,-1296 # b78 <malloc+0x232>
  90:	003000ef          	jal	892 <printf>
    printf("  Root inode: 0x%x (parent's root)\n", (unsigned int)0);
  94:	4581                	li	a1,0
  96:	00001517          	auipc	a0,0x1
  9a:	a7a50513          	addi	a0,a0,-1414 # b10 <malloc+0x1ca>
  9e:	7f4000ef          	jal	892 <printf>
    
    // Try to create new mount namespace with unshare
    if(unshare(CLONE_NEWNS) == 0) {
  a2:	00020537          	lui	a0,0x20
  a6:	45c000ef          	jal	502 <unshare>
  aa:	e515                	bnez	a0,d6 <main+0xd6>
      printf("  Successfully created NEW mount namespace with unshare(CLONE_NEWNS)\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	af450513          	addi	a0,a0,-1292 # ba0 <malloc+0x25a>
  b4:	7de000ef          	jal	892 <printf>
      printf("  New root inode: isolated\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	b3050513          	addi	a0,a0,-1232 # be8 <malloc+0x2a2>
  c0:	7d2000ef          	jal	892 <printf>
    } else {
      printf("  unshare(CLONE_NEWNS) not fully functional yet\n");
    }
    
    printf("\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	b7c50513          	addi	a0,a0,-1156 # c40 <malloc+0x2fa>
  cc:	7c6000ef          	jal	892 <printf>
    exit(0);
  d0:	4501                	li	a0,0
  d2:	348000ef          	jal	41a <exit>
      printf("  unshare(CLONE_NEWNS) not fully functional yet\n");
  d6:	00001517          	auipc	a0,0x1
  da:	b3250513          	addi	a0,a0,-1230 # c08 <malloc+0x2c2>
  de:	7b4000ef          	jal	892 <printf>
  e2:	b7cd                	j	c4 <main+0xc4>
  }

  // Wait for both children
  wait(0);
  e4:	4501                	li	a0,0
  e6:	33c000ef          	jal	422 <wait>
  wait(0);
  ea:	4501                	li	a0,0
  ec:	336000ef          	jal	422 <wait>

  printf("Parent continues:\n");
  f0:	00001517          	auipc	a0,0x1
  f4:	b5850513          	addi	a0,a0,-1192 # c48 <malloc+0x302>
  f8:	79a000ef          	jal	892 <printf>
  printf("  Still on original mount namespace\n");
  fc:	00001517          	auipc	a0,0x1
 100:	b6450513          	addi	a0,a0,-1180 # c60 <malloc+0x31a>
 104:	78e000ef          	jal	892 <printf>
  printf("  Root inode unchanged\n\n");
 108:	00001517          	auipc	a0,0x1
 10c:	b8050513          	addi	a0,a0,-1152 # c88 <malloc+0x342>
 110:	782000ef          	jal	892 <printf>

  // Test combined namespaces
  pid = fork();
 114:	2fe000ef          	jal	412 <fork>
  if(pid == 0) {
 118:	e939                	bnez	a0,16e <main+0x16e>
    // Create isolated environment
    printf("Isolated process:\n");
 11a:	00001517          	auipc	a0,0x1
 11e:	b8e50513          	addi	a0,a0,-1138 # ca8 <malloc+0x362>
 122:	770000ef          	jal	892 <printf>
    
    if(unshare(CLONE_NEWPID | CLONE_NEWNS) == 0) {
 126:	20020537          	lui	a0,0x20020
 12a:	3d8000ef          	jal	502 <unshare>
 12e:	e90d                	bnez	a0,160 <main+0x160>
      printf("  PID namespace isolated: PID = %d\n", getpid());
 130:	36a000ef          	jal	49a <getpid>
 134:	85aa                	mv	a1,a0
 136:	00001517          	auipc	a0,0x1
 13a:	b8a50513          	addi	a0,a0,-1142 # cc0 <malloc+0x37a>
 13e:	754000ef          	jal	892 <printf>
      printf("  Mount namespace isolated: independent root\n");
 142:	00001517          	auipc	a0,0x1
 146:	ba650513          	addi	a0,a0,-1114 # ce8 <malloc+0x3a2>
 14a:	748000ef          	jal	892 <printf>
      printf("  Multiple namespaces working together!\n");
 14e:	00001517          	auipc	a0,0x1
 152:	bca50513          	addi	a0,a0,-1078 # d18 <malloc+0x3d2>
 156:	73c000ef          	jal	892 <printf>
    } else {
      printf("  Combined namespace isolation attempted\n");
    }
    
    exit(0);
 15a:	4501                	li	a0,0
 15c:	2be000ef          	jal	41a <exit>
      printf("  Combined namespace isolation attempted\n");
 160:	00001517          	auipc	a0,0x1
 164:	be850513          	addi	a0,a0,-1048 # d48 <malloc+0x402>
 168:	72a000ef          	jal	892 <printf>
 16c:	b7fd                	j	15a <main+0x15a>
  }

  wait(0);
 16e:	4501                	li	a0,0
 170:	2b2000ef          	jal	422 <wait>

  printf("\n=== Mount Namespace Test Complete ===\n");
 174:	00001517          	auipc	a0,0x1
 178:	c0450513          	addi	a0,a0,-1020 # d78 <malloc+0x432>
 17c:	716000ef          	jal	892 <printf>
  
  exit(0);
 180:	4501                	li	a0,0
 182:	298000ef          	jal	41a <exit>

0000000000000186 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 186:	1141                	addi	sp,sp,-16
 188:	e406                	sd	ra,8(sp)
 18a:	e022                	sd	s0,0(sp)
 18c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 18e:	e73ff0ef          	jal	0 <main>
  exit(r);
 192:	288000ef          	jal	41a <exit>

0000000000000196 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19c:	87aa                	mv	a5,a0
 19e:	0585                	addi	a1,a1,1
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff5c703          	lbu	a4,-1(a1)
 1a6:	fee78fa3          	sb	a4,-1(a5)
 1aa:	fb75                	bnez	a4,19e <strcpy+0x8>
    ;
  return os;
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cb91                	beqz	a5,1d0 <strcmp+0x1e>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71763          	bne	a4,a5,1d0 <strcmp+0x1e>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbe5                	bnez	a5,1be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d0:	0005c503          	lbu	a0,0(a1)
}
 1d4:	40a7853b          	subw	a0,a5,a0
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strlen>:

uint
strlen(const char *s)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cf91                	beqz	a5,204 <strlen+0x26>
 1ea:	0505                	addi	a0,a0,1
 1ec:	87aa                	mv	a5,a0
 1ee:	86be                	mv	a3,a5
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff7c703          	lbu	a4,-1(a5)
 1f6:	ff65                	bnez	a4,1ee <strlen+0x10>
 1f8:	40a6853b          	subw	a0,a3,a0
 1fc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  for(n = 0; s[n]; n++)
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strlen+0x20>

0000000000000208 <memset>:

void*
memset(void *dst, int c, uint n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20e:	ca19                	beqz	a2,224 <memset+0x1c>
 210:	87aa                	mv	a5,a0
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21e:	0785                	addi	a5,a5,1
 220:	fee79de3          	bne	a5,a4,21a <memset+0x12>
  }
  return dst;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strchr>:

char*
strchr(const char *s, char c)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cb99                	beqz	a5,24a <strchr+0x20>
    if(*s == c)
 236:	00f58763          	beq	a1,a5,244 <strchr+0x1a>
  for(; *s; s++)
 23a:	0505                	addi	a0,a0,1
 23c:	00054783          	lbu	a5,0(a0)
 240:	fbfd                	bnez	a5,236 <strchr+0xc>
      return (char*)s;
  return 0;
 242:	4501                	li	a0,0
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
  return 0;
 24a:	4501                	li	a0,0
 24c:	bfe5                	j	244 <strchr+0x1a>

000000000000024e <gets>:

char*
gets(char *buf, int max)
{
 24e:	711d                	addi	sp,sp,-96
 250:	ec86                	sd	ra,88(sp)
 252:	e8a2                	sd	s0,80(sp)
 254:	e4a6                	sd	s1,72(sp)
 256:	e0ca                	sd	s2,64(sp)
 258:	fc4e                	sd	s3,56(sp)
 25a:	f852                	sd	s4,48(sp)
 25c:	f456                	sd	s5,40(sp)
 25e:	f05a                	sd	s6,32(sp)
 260:	ec5e                	sd	s7,24(sp)
 262:	1080                	addi	s0,sp,96
 264:	8baa                	mv	s7,a0
 266:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 268:	892a                	mv	s2,a0
 26a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26c:	4aa9                	li	s5,10
 26e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 270:	89a6                	mv	s3,s1
 272:	2485                	addiw	s1,s1,1
 274:	0344d663          	bge	s1,s4,2a0 <gets+0x52>
    cc = read(0, &c, 1);
 278:	4605                	li	a2,1
 27a:	faf40593          	addi	a1,s0,-81
 27e:	4501                	li	a0,0
 280:	1b2000ef          	jal	432 <read>
    if(cc < 1)
 284:	00a05e63          	blez	a0,2a0 <gets+0x52>
    buf[i++] = c;
 288:	faf44783          	lbu	a5,-81(s0)
 28c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 290:	01578763          	beq	a5,s5,29e <gets+0x50>
 294:	0905                	addi	s2,s2,1
 296:	fd679de3          	bne	a5,s6,270 <gets+0x22>
    buf[i++] = c;
 29a:	89a6                	mv	s3,s1
 29c:	a011                	j	2a0 <gets+0x52>
 29e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a0:	99de                	add	s3,s3,s7
 2a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a6:	855e                	mv	a0,s7
 2a8:	60e6                	ld	ra,88(sp)
 2aa:	6446                	ld	s0,80(sp)
 2ac:	64a6                	ld	s1,72(sp)
 2ae:	6906                	ld	s2,64(sp)
 2b0:	79e2                	ld	s3,56(sp)
 2b2:	7a42                	ld	s4,48(sp)
 2b4:	7aa2                	ld	s5,40(sp)
 2b6:	7b02                	ld	s6,32(sp)
 2b8:	6be2                	ld	s7,24(sp)
 2ba:	6125                	addi	sp,sp,96
 2bc:	8082                	ret

00000000000002be <stat>:

int
stat(const char *n, struct stat *st)
{
 2be:	1101                	addi	sp,sp,-32
 2c0:	ec06                	sd	ra,24(sp)
 2c2:	e822                	sd	s0,16(sp)
 2c4:	e04a                	sd	s2,0(sp)
 2c6:	1000                	addi	s0,sp,32
 2c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ca:	4581                	li	a1,0
 2cc:	18e000ef          	jal	45a <open>
  if(fd < 0)
 2d0:	02054263          	bltz	a0,2f4 <stat+0x36>
 2d4:	e426                	sd	s1,8(sp)
 2d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d8:	85ca                	mv	a1,s2
 2da:	198000ef          	jal	472 <fstat>
 2de:	892a                	mv	s2,a0
  close(fd);
 2e0:	8526                	mv	a0,s1
 2e2:	160000ef          	jal	442 <close>
  return r;
 2e6:	64a2                	ld	s1,8(sp)
}
 2e8:	854a                	mv	a0,s2
 2ea:	60e2                	ld	ra,24(sp)
 2ec:	6442                	ld	s0,16(sp)
 2ee:	6902                	ld	s2,0(sp)
 2f0:	6105                	addi	sp,sp,32
 2f2:	8082                	ret
    return -1;
 2f4:	597d                	li	s2,-1
 2f6:	bfcd                	j	2e8 <stat+0x2a>

00000000000002f8 <atoi>:

int
atoi(const char *s)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fe:	00054683          	lbu	a3,0(a0)
 302:	fd06879b          	addiw	a5,a3,-48
 306:	0ff7f793          	zext.b	a5,a5
 30a:	4625                	li	a2,9
 30c:	02f66863          	bltu	a2,a5,33c <atoi+0x44>
 310:	872a                	mv	a4,a0
  n = 0;
 312:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 314:	0705                	addi	a4,a4,1
 316:	0025179b          	slliw	a5,a0,0x2
 31a:	9fa9                	addw	a5,a5,a0
 31c:	0017979b          	slliw	a5,a5,0x1
 320:	9fb5                	addw	a5,a5,a3
 322:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 326:	00074683          	lbu	a3,0(a4)
 32a:	fd06879b          	addiw	a5,a3,-48
 32e:	0ff7f793          	zext.b	a5,a5
 332:	fef671e3          	bgeu	a2,a5,314 <atoi+0x1c>
  return n;
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  n = 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <atoi+0x3e>

0000000000000340 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 346:	02b57463          	bgeu	a0,a1,36e <memmove+0x2e>
    while(n-- > 0)
 34a:	00c05f63          	blez	a2,368 <memmove+0x28>
 34e:	1602                	slli	a2,a2,0x20
 350:	9201                	srli	a2,a2,0x20
 352:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 356:	872a                	mv	a4,a0
      *dst++ = *src++;
 358:	0585                	addi	a1,a1,1
 35a:	0705                	addi	a4,a4,1
 35c:	fff5c683          	lbu	a3,-1(a1)
 360:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 364:	fef71ae3          	bne	a4,a5,358 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	addi	sp,sp,16
 36c:	8082                	ret
    dst += n;
 36e:	00c50733          	add	a4,a0,a2
    src += n;
 372:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 374:	fec05ae3          	blez	a2,368 <memmove+0x28>
 378:	fff6079b          	addiw	a5,a2,-1
 37c:	1782                	slli	a5,a5,0x20
 37e:	9381                	srli	a5,a5,0x20
 380:	fff7c793          	not	a5,a5
 384:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 386:	15fd                	addi	a1,a1,-1
 388:	177d                	addi	a4,a4,-1
 38a:	0005c683          	lbu	a3,0(a1)
 38e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 392:	fee79ae3          	bne	a5,a4,386 <memmove+0x46>
 396:	bfc9                	j	368 <memmove+0x28>

0000000000000398 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39e:	ca05                	beqz	a2,3ce <memcmp+0x36>
 3a0:	fff6069b          	addiw	a3,a2,-1
 3a4:	1682                	slli	a3,a3,0x20
 3a6:	9281                	srli	a3,a3,0x20
 3a8:	0685                	addi	a3,a3,1
 3aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	0005c703          	lbu	a4,0(a1)
 3b4:	00e79863          	bne	a5,a4,3c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b8:	0505                	addi	a0,a0,1
    p2++;
 3ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3bc:	fed518e3          	bne	a0,a3,3ac <memcmp+0x14>
  }
  return 0;
 3c0:	4501                	li	a0,0
 3c2:	a019                	j	3c8 <memcmp+0x30>
      return *p1 - *p2;
 3c4:	40e7853b          	subw	a0,a5,a4
}
 3c8:	6422                	ld	s0,8(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  return 0;
 3ce:	4501                	li	a0,0
 3d0:	bfe5                	j	3c8 <memcmp+0x30>

00000000000003d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3da:	f67ff0ef          	jal	340 <memmove>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <sbrk>:

char *
sbrk(int n) {
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3ee:	4585                	li	a1,1
 3f0:	0b2000ef          	jal	4a2 <sys_sbrk>
}
 3f4:	60a2                	ld	ra,8(sp)
 3f6:	6402                	ld	s0,0(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret

00000000000003fc <sbrklazy>:

char *
sbrklazy(int n) {
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 404:	4589                	li	a1,2
 406:	09c000ef          	jal	4a2 <sys_sbrk>
}
 40a:	60a2                	ld	ra,8(sp)
 40c:	6402                	ld	s0,0(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret

0000000000000412 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 412:	4885                	li	a7,1
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <exit>:
.global exit
exit:
 li a7, SYS_exit
 41a:	4889                	li	a7,2
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <wait>:
.global wait
wait:
 li a7, SYS_wait
 422:	488d                	li	a7,3
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 42a:	4891                	li	a7,4
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <read>:
.global read
read:
 li a7, SYS_read
 432:	4895                	li	a7,5
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <write>:
.global write
write:
 li a7, SYS_write
 43a:	48c1                	li	a7,16
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <close>:
.global close
close:
 li a7, SYS_close
 442:	48d5                	li	a7,21
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <kill>:
.global kill
kill:
 li a7, SYS_kill
 44a:	4899                	li	a7,6
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <exec>:
.global exec
exec:
 li a7, SYS_exec
 452:	489d                	li	a7,7
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <open>:
.global open
open:
 li a7, SYS_open
 45a:	48bd                	li	a7,15
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 462:	48c5                	li	a7,17
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 46a:	48c9                	li	a7,18
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 472:	48a1                	li	a7,8
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <link>:
.global link
link:
 li a7, SYS_link
 47a:	48cd                	li	a7,19
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 482:	48d1                	li	a7,20
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 48a:	48a5                	li	a7,9
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <dup>:
.global dup
dup:
 li a7, SYS_dup
 492:	48a9                	li	a7,10
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 49a:	48ad                	li	a7,11
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4a2:	48b1                	li	a7,12
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <pause>:
.global pause
pause:
 li a7, SYS_pause
 4aa:	48b5                	li	a7,13
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b2:	48b9                	li	a7,14
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 4ba:	48d9                	li	a7,22
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 4c2:	48dd                	li	a7,23
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 4ca:	48e1                	li	a7,24
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 4d2:	48e5                	li	a7,25
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 4da:	48e9                	li	a7,26
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 4e2:	48ed                	li	a7,27
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 4ea:	48f1                	li	a7,28
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 4f2:	48f5                	li	a7,29
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 4fa:	48f9                	li	a7,30
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 502:	48fd                	li	a7,31
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 50a:	1101                	addi	sp,sp,-32
 50c:	ec06                	sd	ra,24(sp)
 50e:	e822                	sd	s0,16(sp)
 510:	1000                	addi	s0,sp,32
 512:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 516:	4605                	li	a2,1
 518:	fef40593          	addi	a1,s0,-17
 51c:	f1fff0ef          	jal	43a <write>
}
 520:	60e2                	ld	ra,24(sp)
 522:	6442                	ld	s0,16(sp)
 524:	6105                	addi	sp,sp,32
 526:	8082                	ret

0000000000000528 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 528:	715d                	addi	sp,sp,-80
 52a:	e486                	sd	ra,72(sp)
 52c:	e0a2                	sd	s0,64(sp)
 52e:	f84a                	sd	s2,48(sp)
 530:	0880                	addi	s0,sp,80
 532:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 534:	c299                	beqz	a3,53a <printint+0x12>
 536:	0805c363          	bltz	a1,5bc <printint+0x94>
  neg = 0;
 53a:	4881                	li	a7,0
 53c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 540:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 542:	00001517          	auipc	a0,0x1
 546:	86650513          	addi	a0,a0,-1946 # da8 <digits>
 54a:	883e                	mv	a6,a5
 54c:	2785                	addiw	a5,a5,1
 54e:	02c5f733          	remu	a4,a1,a2
 552:	972a                	add	a4,a4,a0
 554:	00074703          	lbu	a4,0(a4)
 558:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 55c:	872e                	mv	a4,a1
 55e:	02c5d5b3          	divu	a1,a1,a2
 562:	0685                	addi	a3,a3,1
 564:	fec773e3          	bgeu	a4,a2,54a <printint+0x22>
  if(neg)
 568:	00088b63          	beqz	a7,57e <printint+0x56>
    buf[i++] = '-';
 56c:	fd078793          	addi	a5,a5,-48
 570:	97a2                	add	a5,a5,s0
 572:	02d00713          	li	a4,45
 576:	fee78423          	sb	a4,-24(a5)
 57a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 57e:	02f05a63          	blez	a5,5b2 <printint+0x8a>
 582:	fc26                	sd	s1,56(sp)
 584:	f44e                	sd	s3,40(sp)
 586:	fb840713          	addi	a4,s0,-72
 58a:	00f704b3          	add	s1,a4,a5
 58e:	fff70993          	addi	s3,a4,-1
 592:	99be                	add	s3,s3,a5
 594:	37fd                	addiw	a5,a5,-1
 596:	1782                	slli	a5,a5,0x20
 598:	9381                	srli	a5,a5,0x20
 59a:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 59e:	fff4c583          	lbu	a1,-1(s1)
 5a2:	854a                	mv	a0,s2
 5a4:	f67ff0ef          	jal	50a <putc>
  while(--i >= 0)
 5a8:	14fd                	addi	s1,s1,-1
 5aa:	ff349ae3          	bne	s1,s3,59e <printint+0x76>
 5ae:	74e2                	ld	s1,56(sp)
 5b0:	79a2                	ld	s3,40(sp)
}
 5b2:	60a6                	ld	ra,72(sp)
 5b4:	6406                	ld	s0,64(sp)
 5b6:	7942                	ld	s2,48(sp)
 5b8:	6161                	addi	sp,sp,80
 5ba:	8082                	ret
    x = -xx;
 5bc:	40b005b3          	neg	a1,a1
    neg = 1;
 5c0:	4885                	li	a7,1
    x = -xx;
 5c2:	bfad                	j	53c <printint+0x14>

00000000000005c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c4:	711d                	addi	sp,sp,-96
 5c6:	ec86                	sd	ra,88(sp)
 5c8:	e8a2                	sd	s0,80(sp)
 5ca:	e0ca                	sd	s2,64(sp)
 5cc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ce:	0005c903          	lbu	s2,0(a1)
 5d2:	28090663          	beqz	s2,85e <vprintf+0x29a>
 5d6:	e4a6                	sd	s1,72(sp)
 5d8:	fc4e                	sd	s3,56(sp)
 5da:	f852                	sd	s4,48(sp)
 5dc:	f456                	sd	s5,40(sp)
 5de:	f05a                	sd	s6,32(sp)
 5e0:	ec5e                	sd	s7,24(sp)
 5e2:	e862                	sd	s8,16(sp)
 5e4:	e466                	sd	s9,8(sp)
 5e6:	8b2a                	mv	s6,a0
 5e8:	8a2e                	mv	s4,a1
 5ea:	8bb2                	mv	s7,a2
  state = 0;
 5ec:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5ee:	4481                	li	s1,0
 5f0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5f2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5f6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5fa:	06c00c93          	li	s9,108
 5fe:	a005                	j	61e <vprintf+0x5a>
        putc(fd, c0);
 600:	85ca                	mv	a1,s2
 602:	855a                	mv	a0,s6
 604:	f07ff0ef          	jal	50a <putc>
 608:	a019                	j	60e <vprintf+0x4a>
    } else if(state == '%'){
 60a:	03598263          	beq	s3,s5,62e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 60e:	2485                	addiw	s1,s1,1
 610:	8726                	mv	a4,s1
 612:	009a07b3          	add	a5,s4,s1
 616:	0007c903          	lbu	s2,0(a5)
 61a:	22090a63          	beqz	s2,84e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 61e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 622:	fe0994e3          	bnez	s3,60a <vprintf+0x46>
      if(c0 == '%'){
 626:	fd579de3          	bne	a5,s5,600 <vprintf+0x3c>
        state = '%';
 62a:	89be                	mv	s3,a5
 62c:	b7cd                	j	60e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 62e:	00ea06b3          	add	a3,s4,a4
 632:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 636:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 638:	c681                	beqz	a3,640 <vprintf+0x7c>
 63a:	9752                	add	a4,a4,s4
 63c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 640:	05878363          	beq	a5,s8,686 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 644:	05978d63          	beq	a5,s9,69e <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 648:	07500713          	li	a4,117
 64c:	0ee78763          	beq	a5,a4,73a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 650:	07800713          	li	a4,120
 654:	12e78963          	beq	a5,a4,786 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 658:	07000713          	li	a4,112
 65c:	14e78e63          	beq	a5,a4,7b8 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 660:	06300713          	li	a4,99
 664:	18e78e63          	beq	a5,a4,800 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 668:	07300713          	li	a4,115
 66c:	1ae78463          	beq	a5,a4,814 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 670:	02500713          	li	a4,37
 674:	04e79563          	bne	a5,a4,6be <vprintf+0xfa>
        putc(fd, '%');
 678:	02500593          	li	a1,37
 67c:	855a                	mv	a0,s6
 67e:	e8dff0ef          	jal	50a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 682:	4981                	li	s3,0
 684:	b769                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 686:	008b8913          	addi	s2,s7,8
 68a:	4685                	li	a3,1
 68c:	4629                	li	a2,10
 68e:	000ba583          	lw	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	e95ff0ef          	jal	528 <printint>
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	bf8d                	j	60e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 69e:	06400793          	li	a5,100
 6a2:	02f68963          	beq	a3,a5,6d4 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a6:	06c00793          	li	a5,108
 6aa:	04f68263          	beq	a3,a5,6ee <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6ae:	07500793          	li	a5,117
 6b2:	0af68063          	beq	a3,a5,752 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6b6:	07800793          	li	a5,120
 6ba:	0ef68263          	beq	a3,a5,79e <vprintf+0x1da>
        putc(fd, '%');
 6be:	02500593          	li	a1,37
 6c2:	855a                	mv	a0,s6
 6c4:	e47ff0ef          	jal	50a <putc>
        putc(fd, c0);
 6c8:	85ca                	mv	a1,s2
 6ca:	855a                	mv	a0,s6
 6cc:	e3fff0ef          	jal	50a <putc>
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bf35                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d4:	008b8913          	addi	s2,s7,8
 6d8:	4685                	li	a3,1
 6da:	4629                	li	a2,10
 6dc:	000bb583          	ld	a1,0(s7)
 6e0:	855a                	mv	a0,s6
 6e2:	e47ff0ef          	jal	528 <printint>
        i += 1;
 6e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
        i += 1;
 6ec:	b70d                	j	60e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ee:	06400793          	li	a5,100
 6f2:	02f60763          	beq	a2,a5,720 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6f6:	07500793          	li	a5,117
 6fa:	06f60963          	beq	a2,a5,76c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6fe:	07800793          	li	a5,120
 702:	faf61ee3          	bne	a2,a5,6be <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4641                	li	a2,16
 70e:	000bb583          	ld	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	e15ff0ef          	jal	528 <printint>
        i += 2;
 718:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 71a:	8bca                	mv	s7,s2
      state = 0;
 71c:	4981                	li	s3,0
        i += 2;
 71e:	bdc5                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 720:	008b8913          	addi	s2,s7,8
 724:	4685                	li	a3,1
 726:	4629                	li	a2,10
 728:	000bb583          	ld	a1,0(s7)
 72c:	855a                	mv	a0,s6
 72e:	dfbff0ef          	jal	528 <printint>
        i += 2;
 732:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
        i += 2;
 738:	bdd9                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 73a:	008b8913          	addi	s2,s7,8
 73e:	4681                	li	a3,0
 740:	4629                	li	a2,10
 742:	000be583          	lwu	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	de1ff0ef          	jal	528 <printint>
 74c:	8bca                	mv	s7,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bd7d                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 752:	008b8913          	addi	s2,s7,8
 756:	4681                	li	a3,0
 758:	4629                	li	a2,10
 75a:	000bb583          	ld	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	dc9ff0ef          	jal	528 <printint>
        i += 1;
 764:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 766:	8bca                	mv	s7,s2
      state = 0;
 768:	4981                	li	s3,0
        i += 1;
 76a:	b555                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 76c:	008b8913          	addi	s2,s7,8
 770:	4681                	li	a3,0
 772:	4629                	li	a2,10
 774:	000bb583          	ld	a1,0(s7)
 778:	855a                	mv	a0,s6
 77a:	dafff0ef          	jal	528 <printint>
        i += 2;
 77e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 780:	8bca                	mv	s7,s2
      state = 0;
 782:	4981                	li	s3,0
        i += 2;
 784:	b569                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 786:	008b8913          	addi	s2,s7,8
 78a:	4681                	li	a3,0
 78c:	4641                	li	a2,16
 78e:	000be583          	lwu	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	d95ff0ef          	jal	528 <printint>
 798:	8bca                	mv	s7,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bd8d                	j	60e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 79e:	008b8913          	addi	s2,s7,8
 7a2:	4681                	li	a3,0
 7a4:	4641                	li	a2,16
 7a6:	000bb583          	ld	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	d7dff0ef          	jal	528 <printint>
        i += 1;
 7b0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b2:	8bca                	mv	s7,s2
      state = 0;
 7b4:	4981                	li	s3,0
        i += 1;
 7b6:	bda1                	j	60e <vprintf+0x4a>
 7b8:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7ba:	008b8d13          	addi	s10,s7,8
 7be:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7c2:	03000593          	li	a1,48
 7c6:	855a                	mv	a0,s6
 7c8:	d43ff0ef          	jal	50a <putc>
  putc(fd, 'x');
 7cc:	07800593          	li	a1,120
 7d0:	855a                	mv	a0,s6
 7d2:	d39ff0ef          	jal	50a <putc>
 7d6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d8:	00000b97          	auipc	s7,0x0
 7dc:	5d0b8b93          	addi	s7,s7,1488 # da8 <digits>
 7e0:	03c9d793          	srli	a5,s3,0x3c
 7e4:	97de                	add	a5,a5,s7
 7e6:	0007c583          	lbu	a1,0(a5)
 7ea:	855a                	mv	a0,s6
 7ec:	d1fff0ef          	jal	50a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7f0:	0992                	slli	s3,s3,0x4
 7f2:	397d                	addiw	s2,s2,-1
 7f4:	fe0916e3          	bnez	s2,7e0 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7f8:	8bea                	mv	s7,s10
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	6d02                	ld	s10,0(sp)
 7fe:	bd01                	j	60e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 800:	008b8913          	addi	s2,s7,8
 804:	000bc583          	lbu	a1,0(s7)
 808:	855a                	mv	a0,s6
 80a:	d01ff0ef          	jal	50a <putc>
 80e:	8bca                	mv	s7,s2
      state = 0;
 810:	4981                	li	s3,0
 812:	bbf5                	j	60e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 814:	008b8993          	addi	s3,s7,8
 818:	000bb903          	ld	s2,0(s7)
 81c:	00090f63          	beqz	s2,83a <vprintf+0x276>
        for(; *s; s++)
 820:	00094583          	lbu	a1,0(s2)
 824:	c195                	beqz	a1,848 <vprintf+0x284>
          putc(fd, *s);
 826:	855a                	mv	a0,s6
 828:	ce3ff0ef          	jal	50a <putc>
        for(; *s; s++)
 82c:	0905                	addi	s2,s2,1
 82e:	00094583          	lbu	a1,0(s2)
 832:	f9f5                	bnez	a1,826 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 834:	8bce                	mv	s7,s3
      state = 0;
 836:	4981                	li	s3,0
 838:	bbd9                	j	60e <vprintf+0x4a>
          s = "(null)";
 83a:	00000917          	auipc	s2,0x0
 83e:	56690913          	addi	s2,s2,1382 # da0 <malloc+0x45a>
        for(; *s; s++)
 842:	02800593          	li	a1,40
 846:	b7c5                	j	826 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 848:	8bce                	mv	s7,s3
      state = 0;
 84a:	4981                	li	s3,0
 84c:	b3c9                	j	60e <vprintf+0x4a>
 84e:	64a6                	ld	s1,72(sp)
 850:	79e2                	ld	s3,56(sp)
 852:	7a42                	ld	s4,48(sp)
 854:	7aa2                	ld	s5,40(sp)
 856:	7b02                	ld	s6,32(sp)
 858:	6be2                	ld	s7,24(sp)
 85a:	6c42                	ld	s8,16(sp)
 85c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 85e:	60e6                	ld	ra,88(sp)
 860:	6446                	ld	s0,80(sp)
 862:	6906                	ld	s2,64(sp)
 864:	6125                	addi	sp,sp,96
 866:	8082                	ret

0000000000000868 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 868:	715d                	addi	sp,sp,-80
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	addi	s0,sp,32
 870:	e010                	sd	a2,0(s0)
 872:	e414                	sd	a3,8(s0)
 874:	e818                	sd	a4,16(s0)
 876:	ec1c                	sd	a5,24(s0)
 878:	03043023          	sd	a6,32(s0)
 87c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 880:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 884:	8622                	mv	a2,s0
 886:	d3fff0ef          	jal	5c4 <vprintf>
}
 88a:	60e2                	ld	ra,24(sp)
 88c:	6442                	ld	s0,16(sp)
 88e:	6161                	addi	sp,sp,80
 890:	8082                	ret

0000000000000892 <printf>:

void
printf(const char *fmt, ...)
{
 892:	711d                	addi	sp,sp,-96
 894:	ec06                	sd	ra,24(sp)
 896:	e822                	sd	s0,16(sp)
 898:	1000                	addi	s0,sp,32
 89a:	e40c                	sd	a1,8(s0)
 89c:	e810                	sd	a2,16(s0)
 89e:	ec14                	sd	a3,24(s0)
 8a0:	f018                	sd	a4,32(s0)
 8a2:	f41c                	sd	a5,40(s0)
 8a4:	03043823          	sd	a6,48(s0)
 8a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8ac:	00840613          	addi	a2,s0,8
 8b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b4:	85aa                	mv	a1,a0
 8b6:	4505                	li	a0,1
 8b8:	d0dff0ef          	jal	5c4 <vprintf>
}
 8bc:	60e2                	ld	ra,24(sp)
 8be:	6442                	ld	s0,16(sp)
 8c0:	6125                	addi	sp,sp,96
 8c2:	8082                	ret

00000000000008c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c4:	1141                	addi	sp,sp,-16
 8c6:	e422                	sd	s0,8(sp)
 8c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ce:	00000797          	auipc	a5,0x0
 8d2:	7327b783          	ld	a5,1842(a5) # 1000 <freep>
 8d6:	a02d                	j	900 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8d8:	4618                	lw	a4,8(a2)
 8da:	9f2d                	addw	a4,a4,a1
 8dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	6310                	ld	a2,0(a4)
 8e4:	a83d                	j	922 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8e6:	ff852703          	lw	a4,-8(a0)
 8ea:	9f31                	addw	a4,a4,a2
 8ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ee:	ff053683          	ld	a3,-16(a0)
 8f2:	a091                	j	936 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f4:	6398                	ld	a4,0(a5)
 8f6:	00e7e463          	bltu	a5,a4,8fe <free+0x3a>
 8fa:	00e6ea63          	bltu	a3,a4,90e <free+0x4a>
{
 8fe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 900:	fed7fae3          	bgeu	a5,a3,8f4 <free+0x30>
 904:	6398                	ld	a4,0(a5)
 906:	00e6e463          	bltu	a3,a4,90e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90a:	fee7eae3          	bltu	a5,a4,8fe <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 90e:	ff852583          	lw	a1,-8(a0)
 912:	6390                	ld	a2,0(a5)
 914:	02059813          	slli	a6,a1,0x20
 918:	01c85713          	srli	a4,a6,0x1c
 91c:	9736                	add	a4,a4,a3
 91e:	fae60de3          	beq	a2,a4,8d8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 922:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 926:	4790                	lw	a2,8(a5)
 928:	02061593          	slli	a1,a2,0x20
 92c:	01c5d713          	srli	a4,a1,0x1c
 930:	973e                	add	a4,a4,a5
 932:	fae68ae3          	beq	a3,a4,8e6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 936:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 938:	00000717          	auipc	a4,0x0
 93c:	6cf73423          	sd	a5,1736(a4) # 1000 <freep>
}
 940:	6422                	ld	s0,8(sp)
 942:	0141                	addi	sp,sp,16
 944:	8082                	ret

0000000000000946 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 946:	7139                	addi	sp,sp,-64
 948:	fc06                	sd	ra,56(sp)
 94a:	f822                	sd	s0,48(sp)
 94c:	f426                	sd	s1,40(sp)
 94e:	ec4e                	sd	s3,24(sp)
 950:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 952:	02051493          	slli	s1,a0,0x20
 956:	9081                	srli	s1,s1,0x20
 958:	04bd                	addi	s1,s1,15
 95a:	8091                	srli	s1,s1,0x4
 95c:	0014899b          	addiw	s3,s1,1
 960:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 962:	00000517          	auipc	a0,0x0
 966:	69e53503          	ld	a0,1694(a0) # 1000 <freep>
 96a:	c915                	beqz	a0,99e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96e:	4798                	lw	a4,8(a5)
 970:	08977a63          	bgeu	a4,s1,a04 <malloc+0xbe>
 974:	f04a                	sd	s2,32(sp)
 976:	e852                	sd	s4,16(sp)
 978:	e456                	sd	s5,8(sp)
 97a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 97c:	8a4e                	mv	s4,s3
 97e:	0009871b          	sext.w	a4,s3
 982:	6685                	lui	a3,0x1
 984:	00d77363          	bgeu	a4,a3,98a <malloc+0x44>
 988:	6a05                	lui	s4,0x1
 98a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 98e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 992:	00000917          	auipc	s2,0x0
 996:	66e90913          	addi	s2,s2,1646 # 1000 <freep>
  if(p == SBRK_ERROR)
 99a:	5afd                	li	s5,-1
 99c:	a081                	j	9dc <malloc+0x96>
 99e:	f04a                	sd	s2,32(sp)
 9a0:	e852                	sd	s4,16(sp)
 9a2:	e456                	sd	s5,8(sp)
 9a4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9a6:	00000797          	auipc	a5,0x0
 9aa:	66a78793          	addi	a5,a5,1642 # 1010 <base>
 9ae:	00000717          	auipc	a4,0x0
 9b2:	64f73923          	sd	a5,1618(a4) # 1000 <freep>
 9b6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9b8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9bc:	b7c1                	j	97c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9be:	6398                	ld	a4,0(a5)
 9c0:	e118                	sd	a4,0(a0)
 9c2:	a8a9                	j	a1c <malloc+0xd6>
  hp->s.size = nu;
 9c4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9c8:	0541                	addi	a0,a0,16
 9ca:	efbff0ef          	jal	8c4 <free>
  return freep;
 9ce:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d2:	c12d                	beqz	a0,a34 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d6:	4798                	lw	a4,8(a5)
 9d8:	02977263          	bgeu	a4,s1,9fc <malloc+0xb6>
    if(p == freep)
 9dc:	00093703          	ld	a4,0(s2)
 9e0:	853e                	mv	a0,a5
 9e2:	fef719e3          	bne	a4,a5,9d4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9e6:	8552                	mv	a0,s4
 9e8:	9ffff0ef          	jal	3e6 <sbrk>
  if(p == SBRK_ERROR)
 9ec:	fd551ce3          	bne	a0,s5,9c4 <malloc+0x7e>
        return 0;
 9f0:	4501                	li	a0,0
 9f2:	7902                	ld	s2,32(sp)
 9f4:	6a42                	ld	s4,16(sp)
 9f6:	6aa2                	ld	s5,8(sp)
 9f8:	6b02                	ld	s6,0(sp)
 9fa:	a03d                	j	a28 <malloc+0xe2>
 9fc:	7902                	ld	s2,32(sp)
 9fe:	6a42                	ld	s4,16(sp)
 a00:	6aa2                	ld	s5,8(sp)
 a02:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a04:	fae48de3          	beq	s1,a4,9be <malloc+0x78>
        p->s.size -= nunits;
 a08:	4137073b          	subw	a4,a4,s3
 a0c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a0e:	02071693          	slli	a3,a4,0x20
 a12:	01c6d713          	srli	a4,a3,0x1c
 a16:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a18:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a1c:	00000717          	auipc	a4,0x0
 a20:	5ea73223          	sd	a0,1508(a4) # 1000 <freep>
      return (void*)(p + 1);
 a24:	01078513          	addi	a0,a5,16
  }
}
 a28:	70e2                	ld	ra,56(sp)
 a2a:	7442                	ld	s0,48(sp)
 a2c:	74a2                	ld	s1,40(sp)
 a2e:	69e2                	ld	s3,24(sp)
 a30:	6121                	addi	sp,sp,64
 a32:	8082                	ret
 a34:	7902                	ld	s2,32(sp)
 a36:	6a42                	ld	s4,16(sp)
 a38:	6aa2                	ld	s5,8(sp)
 a3a:	6b02                	ld	s6,0(sp)
 a3c:	b7f5                	j	a28 <malloc+0xe2>
