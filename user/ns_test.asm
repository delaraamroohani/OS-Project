
user/_ns_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Comprehensive namespace test

int
main(int argc, char *argv[])
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	1080                	addi	s0,sp,96
  char hostname[64];
  int pid;

  printf("=== Comprehensive Namespace Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	b9850513          	addi	a0,a0,-1128 # ba0 <malloc+0x104>
  10:	1d9000ef          	jal	9e8 <printf>

  // Test 1: PID Namespace
  printf("Test 1: PID Namespace\n");
  14:	00001517          	auipc	a0,0x1
  18:	bbc50513          	addi	a0,a0,-1092 # bd0 <malloc+0x134>
  1c:	1cd000ef          	jal	9e8 <printf>
  printf("  Current namespace next_pid: %d\n", get_pid_namespace());
  20:	620000ef          	jal	640 <get_pid_namespace>
  24:	85aa                	mv	a1,a0
  26:	00001517          	auipc	a0,0x1
  2a:	bc250513          	addi	a0,a0,-1086 # be8 <malloc+0x14c>
  2e:	1bb000ef          	jal	9e8 <printf>
  
  pid = fork();
  32:	536000ef          	jal	568 <fork>
  if(pid == 0) {
  36:	e115                	bnez	a0,5a <main+0x5a>
  38:	e4a6                	sd	s1,72(sp)
    printf("  Child PID: %d, Next: %d\n", getpid(), get_pid_namespace());
  3a:	5b6000ef          	jal	5f0 <getpid>
  3e:	84aa                	mv	s1,a0
  40:	600000ef          	jal	640 <get_pid_namespace>
  44:	862a                	mv	a2,a0
  46:	85a6                	mv	a1,s1
  48:	00001517          	auipc	a0,0x1
  4c:	bc850513          	addi	a0,a0,-1080 # c10 <malloc+0x174>
  50:	199000ef          	jal	9e8 <printf>
    exit(0);
  54:	4501                	li	a0,0
  56:	51a000ef          	jal	570 <exit>
  } else {
    wait(0);
  5a:	4501                	li	a0,0
  5c:	51c000ef          	jal	578 <wait>
  }
  printf("\n");
  60:	00001517          	auipc	a0,0x1
  64:	bd050513          	addi	a0,a0,-1072 # c30 <malloc+0x194>
  68:	181000ef          	jal	9e8 <printf>

  // Test 2: UTS Namespace (Hostname)
  printf("Test 2: UTS Namespace (Hostname)\n");
  6c:	00001517          	auipc	a0,0x1
  70:	bcc50513          	addi	a0,a0,-1076 # c38 <malloc+0x19c>
  74:	175000ef          	jal	9e8 <printf>
  printf("  Getting hostname...\n");
  78:	00001517          	auipc	a0,0x1
  7c:	be850513          	addi	a0,a0,-1048 # c60 <malloc+0x1c4>
  80:	169000ef          	jal	9e8 <printf>
  if(getHostname(hostname, 64) == 0) {
  84:	04000593          	li	a1,64
  88:	fa040513          	addi	a0,s0,-96
  8c:	5bc000ef          	jal	648 <getHostname>
  90:	ed59                	bnez	a0,12e <main+0x12e>
    printf("  Hostname: %s\n", hostname);
  92:	fa040593          	addi	a1,s0,-96
  96:	00001517          	auipc	a0,0x1
  9a:	be250513          	addi	a0,a0,-1054 # c78 <malloc+0x1dc>
  9e:	14b000ef          	jal	9e8 <printf>
  } else {
    printf("  No hostname set\n");
  }

  printf("  Setting hostname to 'container1'...\n");
  a2:	00001517          	auipc	a0,0x1
  a6:	bfe50513          	addi	a0,a0,-1026 # ca0 <malloc+0x204>
  aa:	13f000ef          	jal	9e8 <printf>
  if(setHostname("container1", 10) == 0) {
  ae:	45a9                	li	a1,10
  b0:	00001517          	auipc	a0,0x1
  b4:	c1850513          	addi	a0,a0,-1000 # cc8 <malloc+0x22c>
  b8:	598000ef          	jal	650 <setHostname>
  bc:	c141                	beqz	a0,13c <main+0x13c>
    if(getHostname(hostname, 64) == 0) {
      printf("  New hostname: %s\n", hostname);
    }
  }
  printf("\n");
  be:	00001517          	auipc	a0,0x1
  c2:	b7250513          	addi	a0,a0,-1166 # c30 <malloc+0x194>
  c6:	123000ef          	jal	9e8 <printf>

  // Test 3: Unshare with CLONE_NEWUTS
  printf("Test 3: Unshare UTS Namespace\n");
  ca:	00001517          	auipc	a0,0x1
  ce:	c2650513          	addi	a0,a0,-986 # cf0 <malloc+0x254>
  d2:	117000ef          	jal	9e8 <printf>
  pid = fork();
  d6:	492000ef          	jal	568 <fork>
  if(pid == 0) {
  da:	e15d                	bnez	a0,180 <main+0x180>
  dc:	e4a6                	sd	s1,72(sp)
    // Child creates new UTS namespace
    printf("  Child before unshare:\n");
  de:	00001517          	auipc	a0,0x1
  e2:	c3250513          	addi	a0,a0,-974 # d10 <malloc+0x274>
  e6:	103000ef          	jal	9e8 <printf>
    if(getHostname(hostname, 64) == 0) {
  ea:	04000593          	li	a1,64
  ee:	fa040513          	addi	a0,s0,-96
  f2:	556000ef          	jal	648 <getHostname>
  f6:	c13d                	beqz	a0,15c <main+0x15c>
      printf("    Hostname: %s\n", hostname);
    }

    unshare(CLONE_NEWUTS);
  f8:	04000537          	lui	a0,0x4000
  fc:	55c000ef          	jal	658 <unshare>
    printf("  Child after unshare(CLONE_NEWUTS):\n");
 100:	00001517          	auipc	a0,0x1
 104:	c4850513          	addi	a0,a0,-952 # d48 <malloc+0x2ac>
 108:	0e1000ef          	jal	9e8 <printf>
    setHostname("isolated-host", 14);
 10c:	45b9                	li	a1,14
 10e:	00001517          	auipc	a0,0x1
 112:	c6250513          	addi	a0,a0,-926 # d70 <malloc+0x2d4>
 116:	53a000ef          	jal	650 <setHostname>
    if(getHostname(hostname, 64) == 0) {
 11a:	04000593          	li	a1,64
 11e:	fa040513          	addi	a0,s0,-96
 122:	526000ef          	jal	648 <getHostname>
 126:	c521                	beqz	a0,16e <main+0x16e>
      printf("    New hostname: %s\n", hostname);
    }
    exit(0);
 128:	4501                	li	a0,0
 12a:	446000ef          	jal	570 <exit>
    printf("  No hostname set\n");
 12e:	00001517          	auipc	a0,0x1
 132:	b5a50513          	addi	a0,a0,-1190 # c88 <malloc+0x1ec>
 136:	0b3000ef          	jal	9e8 <printf>
 13a:	b7a5                	j	a2 <main+0xa2>
    if(getHostname(hostname, 64) == 0) {
 13c:	04000593          	li	a1,64
 140:	fa040513          	addi	a0,s0,-96
 144:	504000ef          	jal	648 <getHostname>
 148:	f93d                	bnez	a0,be <main+0xbe>
      printf("  New hostname: %s\n", hostname);
 14a:	fa040593          	addi	a1,s0,-96
 14e:	00001517          	auipc	a0,0x1
 152:	b8a50513          	addi	a0,a0,-1142 # cd8 <malloc+0x23c>
 156:	093000ef          	jal	9e8 <printf>
 15a:	b795                	j	be <main+0xbe>
      printf("    Hostname: %s\n", hostname);
 15c:	fa040593          	addi	a1,s0,-96
 160:	00001517          	auipc	a0,0x1
 164:	bd050513          	addi	a0,a0,-1072 # d30 <malloc+0x294>
 168:	081000ef          	jal	9e8 <printf>
 16c:	b771                	j	f8 <main+0xf8>
      printf("    New hostname: %s\n", hostname);
 16e:	fa040593          	addi	a1,s0,-96
 172:	00001517          	auipc	a0,0x1
 176:	c0e50513          	addi	a0,a0,-1010 # d80 <malloc+0x2e4>
 17a:	06f000ef          	jal	9e8 <printf>
 17e:	b76d                	j	128 <main+0x128>
  } else {
    wait(0);
 180:	4501                	li	a0,0
 182:	3f6000ef          	jal	578 <wait>
    printf("  Parent after child exits:\n");
 186:	00001517          	auipc	a0,0x1
 18a:	c1250513          	addi	a0,a0,-1006 # d98 <malloc+0x2fc>
 18e:	05b000ef          	jal	9e8 <printf>
    if(getHostname(hostname, 64) == 0) {
 192:	04000593          	li	a1,64
 196:	fa040513          	addi	a0,s0,-96
 19a:	4ae000ef          	jal	648 <getHostname>
 19e:	c931                	beqz	a0,1f2 <main+0x1f2>
      printf("    Hostname (unchanged): %s\n", hostname);
    }
  }
  printf("\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	a9050513          	addi	a0,a0,-1392 # c30 <malloc+0x194>
 1a8:	041000ef          	jal	9e8 <printf>

  // Test 4: Unshare with CLONE_NEWPID
  printf("Test 4: Unshare PID Namespace\n");
 1ac:	00001517          	auipc	a0,0x1
 1b0:	c2c50513          	addi	a0,a0,-980 # dd8 <malloc+0x33c>
 1b4:	035000ef          	jal	9e8 <printf>
  pid = fork();
 1b8:	3b0000ef          	jal	568 <fork>
  if(pid == 0) {
 1bc:	e521                	bnez	a0,204 <main+0x204>
 1be:	e4a6                	sd	s1,72(sp)
    printf("  Child before unshare: next_pid = %d\n", get_pid_namespace());
 1c0:	480000ef          	jal	640 <get_pid_namespace>
 1c4:	85aa                	mv	a1,a0
 1c6:	00001517          	auipc	a0,0x1
 1ca:	c3250513          	addi	a0,a0,-974 # df8 <malloc+0x35c>
 1ce:	01b000ef          	jal	9e8 <printf>
    unshare(CLONE_NEWPID);
 1d2:	20000537          	lui	a0,0x20000
 1d6:	482000ef          	jal	658 <unshare>
    printf("  Child after unshare(CLONE_NEWPID): next_pid = %d\n", get_pid_namespace());
 1da:	466000ef          	jal	640 <get_pid_namespace>
 1de:	85aa                	mv	a1,a0
 1e0:	00001517          	auipc	a0,0x1
 1e4:	c4050513          	addi	a0,a0,-960 # e20 <malloc+0x384>
 1e8:	001000ef          	jal	9e8 <printf>
    exit(0);
 1ec:	4501                	li	a0,0
 1ee:	382000ef          	jal	570 <exit>
      printf("    Hostname (unchanged): %s\n", hostname);
 1f2:	fa040593          	addi	a1,s0,-96
 1f6:	00001517          	auipc	a0,0x1
 1fa:	bc250513          	addi	a0,a0,-1086 # db8 <malloc+0x31c>
 1fe:	7ea000ef          	jal	9e8 <printf>
 202:	bf79                	j	1a0 <main+0x1a0>
  } else {
    wait(0);
 204:	4501                	li	a0,0
 206:	372000ef          	jal	578 <wait>
  }
  printf("\n");
 20a:	00001517          	auipc	a0,0x1
 20e:	a2650513          	addi	a0,a0,-1498 # c30 <malloc+0x194>
 212:	7d6000ef          	jal	9e8 <printf>

  // Test 5: Multiple unshare flags
  printf("Test 5: Unshare Multiple Namespaces\n");
 216:	00001517          	auipc	a0,0x1
 21a:	c4250513          	addi	a0,a0,-958 # e58 <malloc+0x3bc>
 21e:	7ca000ef          	jal	9e8 <printf>
  pid = fork();
 222:	346000ef          	jal	568 <fork>
  if(pid == 0) {
 226:	ed51                	bnez	a0,2c2 <main+0x2c2>
 228:	e4a6                	sd	s1,72(sp)
    printf("  Child before unshare:\n");
 22a:	00001517          	auipc	a0,0x1
 22e:	ae650513          	addi	a0,a0,-1306 # d10 <malloc+0x274>
 232:	7b6000ef          	jal	9e8 <printf>
    printf("    PID ns next: %d\n", get_pid_namespace());
 236:	40a000ef          	jal	640 <get_pid_namespace>
 23a:	85aa                	mv	a1,a0
 23c:	00001517          	auipc	a0,0x1
 240:	c4450513          	addi	a0,a0,-956 # e80 <malloc+0x3e4>
 244:	7a4000ef          	jal	9e8 <printf>
    if(getHostname(hostname, 64) == 0) {
 248:	04000593          	li	a1,64
 24c:	fa040513          	addi	a0,s0,-96
 250:	3f8000ef          	jal	648 <getHostname>
 254:	c529                	beqz	a0,29e <main+0x29e>
      printf("    Hostname: %s\n", hostname);
    }

    unshare(CLONE_NEWPID | CLONE_NEWUTS);
 256:	24000537          	lui	a0,0x24000
 25a:	3fe000ef          	jal	658 <unshare>
    printf("  Child after unshare(CLONE_NEWPID | CLONE_NEWUTS):\n");
 25e:	00001517          	auipc	a0,0x1
 262:	c3a50513          	addi	a0,a0,-966 # e98 <malloc+0x3fc>
 266:	782000ef          	jal	9e8 <printf>
    printf("    PID ns next: %d\n", get_pid_namespace());
 26a:	3d6000ef          	jal	640 <get_pid_namespace>
 26e:	85aa                	mv	a1,a0
 270:	00001517          	auipc	a0,0x1
 274:	c1050513          	addi	a0,a0,-1008 # e80 <malloc+0x3e4>
 278:	770000ef          	jal	9e8 <printf>
    setHostname("multi-isolated", 14);
 27c:	45b9                	li	a1,14
 27e:	00001517          	auipc	a0,0x1
 282:	c5250513          	addi	a0,a0,-942 # ed0 <malloc+0x434>
 286:	3ca000ef          	jal	650 <setHostname>
    if(getHostname(hostname, 64) == 0) {
 28a:	04000593          	li	a1,64
 28e:	fa040513          	addi	a0,s0,-96
 292:	3b6000ef          	jal	648 <getHostname>
 296:	cd09                	beqz	a0,2b0 <main+0x2b0>
      printf("    Hostname: %s\n", hostname);
    }
    exit(0);
 298:	4501                	li	a0,0
 29a:	2d6000ef          	jal	570 <exit>
      printf("    Hostname: %s\n", hostname);
 29e:	fa040593          	addi	a1,s0,-96
 2a2:	00001517          	auipc	a0,0x1
 2a6:	a8e50513          	addi	a0,a0,-1394 # d30 <malloc+0x294>
 2aa:	73e000ef          	jal	9e8 <printf>
 2ae:	b765                	j	256 <main+0x256>
      printf("    Hostname: %s\n", hostname);
 2b0:	fa040593          	addi	a1,s0,-96
 2b4:	00001517          	auipc	a0,0x1
 2b8:	a7c50513          	addi	a0,a0,-1412 # d30 <malloc+0x294>
 2bc:	72c000ef          	jal	9e8 <printf>
 2c0:	bfe1                	j	298 <main+0x298>
 2c2:	e4a6                	sd	s1,72(sp)
  } else {
    wait(0);
 2c4:	4501                	li	a0,0
 2c6:	2b2000ef          	jal	578 <wait>
  }

  printf("\n=== All Tests Complete ===\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	c1650513          	addi	a0,a0,-1002 # ee0 <malloc+0x444>
 2d2:	716000ef          	jal	9e8 <printf>
  exit(0);
 2d6:	4501                	li	a0,0
 2d8:	298000ef          	jal	570 <exit>

00000000000002dc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2e4:	d1dff0ef          	jal	0 <main>
  exit(r);
 2e8:	288000ef          	jal	570 <exit>

00000000000002ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f2:	87aa                	mv	a5,a0
 2f4:	0585                	addi	a1,a1,1
 2f6:	0785                	addi	a5,a5,1
 2f8:	fff5c703          	lbu	a4,-1(a1)
 2fc:	fee78fa3          	sb	a4,-1(a5)
 300:	fb75                	bnez	a4,2f4 <strcpy+0x8>
    ;
  return os;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 30e:	00054783          	lbu	a5,0(a0)
 312:	cb91                	beqz	a5,326 <strcmp+0x1e>
 314:	0005c703          	lbu	a4,0(a1)
 318:	00f71763          	bne	a4,a5,326 <strcmp+0x1e>
    p++, q++;
 31c:	0505                	addi	a0,a0,1
 31e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 320:	00054783          	lbu	a5,0(a0)
 324:	fbe5                	bnez	a5,314 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 326:	0005c503          	lbu	a0,0(a1)
}
 32a:	40a7853b          	subw	a0,a5,a0
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret

0000000000000334 <strlen>:

uint
strlen(const char *s)
{
 334:	1141                	addi	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 33a:	00054783          	lbu	a5,0(a0)
 33e:	cf91                	beqz	a5,35a <strlen+0x26>
 340:	0505                	addi	a0,a0,1
 342:	87aa                	mv	a5,a0
 344:	86be                	mv	a3,a5
 346:	0785                	addi	a5,a5,1
 348:	fff7c703          	lbu	a4,-1(a5)
 34c:	ff65                	bnez	a4,344 <strlen+0x10>
 34e:	40a6853b          	subw	a0,a3,a0
 352:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
  for(n = 0; s[n]; n++)
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <strlen+0x20>

000000000000035e <memset>:

void*
memset(void *dst, int c, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 364:	ca19                	beqz	a2,37a <memset+0x1c>
 366:	87aa                	mv	a5,a0
 368:	1602                	slli	a2,a2,0x20
 36a:	9201                	srli	a2,a2,0x20
 36c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 370:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 374:	0785                	addi	a5,a5,1
 376:	fee79de3          	bne	a5,a4,370 <memset+0x12>
  }
  return dst;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <strchr>:

char*
strchr(const char *s, char c)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  for(; *s; s++)
 386:	00054783          	lbu	a5,0(a0)
 38a:	cb99                	beqz	a5,3a0 <strchr+0x20>
    if(*s == c)
 38c:	00f58763          	beq	a1,a5,39a <strchr+0x1a>
  for(; *s; s++)
 390:	0505                	addi	a0,a0,1
 392:	00054783          	lbu	a5,0(a0)
 396:	fbfd                	bnez	a5,38c <strchr+0xc>
      return (char*)s;
  return 0;
 398:	4501                	li	a0,0
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <strchr+0x1a>

00000000000003a4 <gets>:

char*
gets(char *buf, int max)
{
 3a4:	711d                	addi	sp,sp,-96
 3a6:	ec86                	sd	ra,88(sp)
 3a8:	e8a2                	sd	s0,80(sp)
 3aa:	e4a6                	sd	s1,72(sp)
 3ac:	e0ca                	sd	s2,64(sp)
 3ae:	fc4e                	sd	s3,56(sp)
 3b0:	f852                	sd	s4,48(sp)
 3b2:	f456                	sd	s5,40(sp)
 3b4:	f05a                	sd	s6,32(sp)
 3b6:	ec5e                	sd	s7,24(sp)
 3b8:	1080                	addi	s0,sp,96
 3ba:	8baa                	mv	s7,a0
 3bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3be:	892a                	mv	s2,a0
 3c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c2:	4aa9                	li	s5,10
 3c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3c6:	89a6                	mv	s3,s1
 3c8:	2485                	addiw	s1,s1,1
 3ca:	0344d663          	bge	s1,s4,3f6 <gets+0x52>
    cc = read(0, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	faf40593          	addi	a1,s0,-81
 3d4:	4501                	li	a0,0
 3d6:	1b2000ef          	jal	588 <read>
    if(cc < 1)
 3da:	00a05e63          	blez	a0,3f6 <gets+0x52>
    buf[i++] = c;
 3de:	faf44783          	lbu	a5,-81(s0)
 3e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3e6:	01578763          	beq	a5,s5,3f4 <gets+0x50>
 3ea:	0905                	addi	s2,s2,1
 3ec:	fd679de3          	bne	a5,s6,3c6 <gets+0x22>
    buf[i++] = c;
 3f0:	89a6                	mv	s3,s1
 3f2:	a011                	j	3f6 <gets+0x52>
 3f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3f6:	99de                	add	s3,s3,s7
 3f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3fc:	855e                	mv	a0,s7
 3fe:	60e6                	ld	ra,88(sp)
 400:	6446                	ld	s0,80(sp)
 402:	64a6                	ld	s1,72(sp)
 404:	6906                	ld	s2,64(sp)
 406:	79e2                	ld	s3,56(sp)
 408:	7a42                	ld	s4,48(sp)
 40a:	7aa2                	ld	s5,40(sp)
 40c:	7b02                	ld	s6,32(sp)
 40e:	6be2                	ld	s7,24(sp)
 410:	6125                	addi	sp,sp,96
 412:	8082                	ret

0000000000000414 <stat>:

int
stat(const char *n, struct stat *st)
{
 414:	1101                	addi	sp,sp,-32
 416:	ec06                	sd	ra,24(sp)
 418:	e822                	sd	s0,16(sp)
 41a:	e04a                	sd	s2,0(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 420:	4581                	li	a1,0
 422:	18e000ef          	jal	5b0 <open>
  if(fd < 0)
 426:	02054263          	bltz	a0,44a <stat+0x36>
 42a:	e426                	sd	s1,8(sp)
 42c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 42e:	85ca                	mv	a1,s2
 430:	198000ef          	jal	5c8 <fstat>
 434:	892a                	mv	s2,a0
  close(fd);
 436:	8526                	mv	a0,s1
 438:	160000ef          	jal	598 <close>
  return r;
 43c:	64a2                	ld	s1,8(sp)
}
 43e:	854a                	mv	a0,s2
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	6902                	ld	s2,0(sp)
 446:	6105                	addi	sp,sp,32
 448:	8082                	ret
    return -1;
 44a:	597d                	li	s2,-1
 44c:	bfcd                	j	43e <stat+0x2a>

000000000000044e <atoi>:

int
atoi(const char *s)
{
 44e:	1141                	addi	sp,sp,-16
 450:	e422                	sd	s0,8(sp)
 452:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 454:	00054683          	lbu	a3,0(a0)
 458:	fd06879b          	addiw	a5,a3,-48
 45c:	0ff7f793          	zext.b	a5,a5
 460:	4625                	li	a2,9
 462:	02f66863          	bltu	a2,a5,492 <atoi+0x44>
 466:	872a                	mv	a4,a0
  n = 0;
 468:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 46a:	0705                	addi	a4,a4,1
 46c:	0025179b          	slliw	a5,a0,0x2
 470:	9fa9                	addw	a5,a5,a0
 472:	0017979b          	slliw	a5,a5,0x1
 476:	9fb5                	addw	a5,a5,a3
 478:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 47c:	00074683          	lbu	a3,0(a4)
 480:	fd06879b          	addiw	a5,a3,-48
 484:	0ff7f793          	zext.b	a5,a5
 488:	fef671e3          	bgeu	a2,a5,46a <atoi+0x1c>
  return n;
}
 48c:	6422                	ld	s0,8(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret
  n = 0;
 492:	4501                	li	a0,0
 494:	bfe5                	j	48c <atoi+0x3e>

0000000000000496 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 496:	1141                	addi	sp,sp,-16
 498:	e422                	sd	s0,8(sp)
 49a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 49c:	02b57463          	bgeu	a0,a1,4c4 <memmove+0x2e>
    while(n-- > 0)
 4a0:	00c05f63          	blez	a2,4be <memmove+0x28>
 4a4:	1602                	slli	a2,a2,0x20
 4a6:	9201                	srli	a2,a2,0x20
 4a8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 4ae:	0585                	addi	a1,a1,1
 4b0:	0705                	addi	a4,a4,1
 4b2:	fff5c683          	lbu	a3,-1(a1)
 4b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ba:	fef71ae3          	bne	a4,a5,4ae <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4be:	6422                	ld	s0,8(sp)
 4c0:	0141                	addi	sp,sp,16
 4c2:	8082                	ret
    dst += n;
 4c4:	00c50733          	add	a4,a0,a2
    src += n;
 4c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4ca:	fec05ae3          	blez	a2,4be <memmove+0x28>
 4ce:	fff6079b          	addiw	a5,a2,-1
 4d2:	1782                	slli	a5,a5,0x20
 4d4:	9381                	srli	a5,a5,0x20
 4d6:	fff7c793          	not	a5,a5
 4da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4dc:	15fd                	addi	a1,a1,-1
 4de:	177d                	addi	a4,a4,-1
 4e0:	0005c683          	lbu	a3,0(a1)
 4e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4e8:	fee79ae3          	bne	a5,a4,4dc <memmove+0x46>
 4ec:	bfc9                	j	4be <memmove+0x28>

00000000000004ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4ee:	1141                	addi	sp,sp,-16
 4f0:	e422                	sd	s0,8(sp)
 4f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f4:	ca05                	beqz	a2,524 <memcmp+0x36>
 4f6:	fff6069b          	addiw	a3,a2,-1
 4fa:	1682                	slli	a3,a3,0x20
 4fc:	9281                	srli	a3,a3,0x20
 4fe:	0685                	addi	a3,a3,1
 500:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 502:	00054783          	lbu	a5,0(a0)
 506:	0005c703          	lbu	a4,0(a1)
 50a:	00e79863          	bne	a5,a4,51a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 50e:	0505                	addi	a0,a0,1
    p2++;
 510:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 512:	fed518e3          	bne	a0,a3,502 <memcmp+0x14>
  }
  return 0;
 516:	4501                	li	a0,0
 518:	a019                	j	51e <memcmp+0x30>
      return *p1 - *p2;
 51a:	40e7853b          	subw	a0,a5,a4
}
 51e:	6422                	ld	s0,8(sp)
 520:	0141                	addi	sp,sp,16
 522:	8082                	ret
  return 0;
 524:	4501                	li	a0,0
 526:	bfe5                	j	51e <memcmp+0x30>

0000000000000528 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e406                	sd	ra,8(sp)
 52c:	e022                	sd	s0,0(sp)
 52e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 530:	f67ff0ef          	jal	496 <memmove>
}
 534:	60a2                	ld	ra,8(sp)
 536:	6402                	ld	s0,0(sp)
 538:	0141                	addi	sp,sp,16
 53a:	8082                	ret

000000000000053c <sbrk>:

char *
sbrk(int n) {
 53c:	1141                	addi	sp,sp,-16
 53e:	e406                	sd	ra,8(sp)
 540:	e022                	sd	s0,0(sp)
 542:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 544:	4585                	li	a1,1
 546:	0b2000ef          	jal	5f8 <sys_sbrk>
}
 54a:	60a2                	ld	ra,8(sp)
 54c:	6402                	ld	s0,0(sp)
 54e:	0141                	addi	sp,sp,16
 550:	8082                	ret

0000000000000552 <sbrklazy>:

char *
sbrklazy(int n) {
 552:	1141                	addi	sp,sp,-16
 554:	e406                	sd	ra,8(sp)
 556:	e022                	sd	s0,0(sp)
 558:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 55a:	4589                	li	a1,2
 55c:	09c000ef          	jal	5f8 <sys_sbrk>
}
 560:	60a2                	ld	ra,8(sp)
 562:	6402                	ld	s0,0(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret

0000000000000568 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 568:	4885                	li	a7,1
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <exit>:
.global exit
exit:
 li a7, SYS_exit
 570:	4889                	li	a7,2
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <wait>:
.global wait
wait:
 li a7, SYS_wait
 578:	488d                	li	a7,3
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 580:	4891                	li	a7,4
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <read>:
.global read
read:
 li a7, SYS_read
 588:	4895                	li	a7,5
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <write>:
.global write
write:
 li a7, SYS_write
 590:	48c1                	li	a7,16
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <close>:
.global close
close:
 li a7, SYS_close
 598:	48d5                	li	a7,21
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5a0:	4899                	li	a7,6
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5a8:	489d                	li	a7,7
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <open>:
.global open
open:
 li a7, SYS_open
 5b0:	48bd                	li	a7,15
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5b8:	48c5                	li	a7,17
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5c0:	48c9                	li	a7,18
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5c8:	48a1                	li	a7,8
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <link>:
.global link
link:
 li a7, SYS_link
 5d0:	48cd                	li	a7,19
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5d8:	48d1                	li	a7,20
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5e0:	48a5                	li	a7,9
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5e8:	48a9                	li	a7,10
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5f0:	48ad                	li	a7,11
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5f8:	48b1                	li	a7,12
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <pause>:
.global pause
pause:
 li a7, SYS_pause
 600:	48b5                	li	a7,13
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 608:	48b9                	li	a7,14
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 610:	48d9                	li	a7,22
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 618:	48dd                	li	a7,23
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 620:	48e1                	li	a7,24
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 628:	48e5                	li	a7,25
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 630:	48e9                	li	a7,26
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 638:	48ed                	li	a7,27
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 640:	48f1                	li	a7,28
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 648:	48f5                	li	a7,29
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 650:	48f9                	li	a7,30
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 658:	48fd                	li	a7,31
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 660:	1101                	addi	sp,sp,-32
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	1000                	addi	s0,sp,32
 668:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 66c:	4605                	li	a2,1
 66e:	fef40593          	addi	a1,s0,-17
 672:	f1fff0ef          	jal	590 <write>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6105                	addi	sp,sp,32
 67c:	8082                	ret

000000000000067e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 67e:	715d                	addi	sp,sp,-80
 680:	e486                	sd	ra,72(sp)
 682:	e0a2                	sd	s0,64(sp)
 684:	f84a                	sd	s2,48(sp)
 686:	0880                	addi	s0,sp,80
 688:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 68a:	c299                	beqz	a3,690 <printint+0x12>
 68c:	0805c363          	bltz	a1,712 <printint+0x94>
  neg = 0;
 690:	4881                	li	a7,0
 692:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 696:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 698:	00001517          	auipc	a0,0x1
 69c:	87050513          	addi	a0,a0,-1936 # f08 <digits>
 6a0:	883e                	mv	a6,a5
 6a2:	2785                	addiw	a5,a5,1
 6a4:	02c5f733          	remu	a4,a1,a2
 6a8:	972a                	add	a4,a4,a0
 6aa:	00074703          	lbu	a4,0(a4)
 6ae:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6b2:	872e                	mv	a4,a1
 6b4:	02c5d5b3          	divu	a1,a1,a2
 6b8:	0685                	addi	a3,a3,1
 6ba:	fec773e3          	bgeu	a4,a2,6a0 <printint+0x22>
  if(neg)
 6be:	00088b63          	beqz	a7,6d4 <printint+0x56>
    buf[i++] = '-';
 6c2:	fd078793          	addi	a5,a5,-48
 6c6:	97a2                	add	a5,a5,s0
 6c8:	02d00713          	li	a4,45
 6cc:	fee78423          	sb	a4,-24(a5)
 6d0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6d4:	02f05a63          	blez	a5,708 <printint+0x8a>
 6d8:	fc26                	sd	s1,56(sp)
 6da:	f44e                	sd	s3,40(sp)
 6dc:	fb840713          	addi	a4,s0,-72
 6e0:	00f704b3          	add	s1,a4,a5
 6e4:	fff70993          	addi	s3,a4,-1
 6e8:	99be                	add	s3,s3,a5
 6ea:	37fd                	addiw	a5,a5,-1
 6ec:	1782                	slli	a5,a5,0x20
 6ee:	9381                	srli	a5,a5,0x20
 6f0:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 6f4:	fff4c583          	lbu	a1,-1(s1)
 6f8:	854a                	mv	a0,s2
 6fa:	f67ff0ef          	jal	660 <putc>
  while(--i >= 0)
 6fe:	14fd                	addi	s1,s1,-1
 700:	ff349ae3          	bne	s1,s3,6f4 <printint+0x76>
 704:	74e2                	ld	s1,56(sp)
 706:	79a2                	ld	s3,40(sp)
}
 708:	60a6                	ld	ra,72(sp)
 70a:	6406                	ld	s0,64(sp)
 70c:	7942                	ld	s2,48(sp)
 70e:	6161                	addi	sp,sp,80
 710:	8082                	ret
    x = -xx;
 712:	40b005b3          	neg	a1,a1
    neg = 1;
 716:	4885                	li	a7,1
    x = -xx;
 718:	bfad                	j	692 <printint+0x14>

000000000000071a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71a:	711d                	addi	sp,sp,-96
 71c:	ec86                	sd	ra,88(sp)
 71e:	e8a2                	sd	s0,80(sp)
 720:	e0ca                	sd	s2,64(sp)
 722:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 724:	0005c903          	lbu	s2,0(a1)
 728:	28090663          	beqz	s2,9b4 <vprintf+0x29a>
 72c:	e4a6                	sd	s1,72(sp)
 72e:	fc4e                	sd	s3,56(sp)
 730:	f852                	sd	s4,48(sp)
 732:	f456                	sd	s5,40(sp)
 734:	f05a                	sd	s6,32(sp)
 736:	ec5e                	sd	s7,24(sp)
 738:	e862                	sd	s8,16(sp)
 73a:	e466                	sd	s9,8(sp)
 73c:	8b2a                	mv	s6,a0
 73e:	8a2e                	mv	s4,a1
 740:	8bb2                	mv	s7,a2
  state = 0;
 742:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 744:	4481                	li	s1,0
 746:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 748:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 74c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 750:	06c00c93          	li	s9,108
 754:	a005                	j	774 <vprintf+0x5a>
        putc(fd, c0);
 756:	85ca                	mv	a1,s2
 758:	855a                	mv	a0,s6
 75a:	f07ff0ef          	jal	660 <putc>
 75e:	a019                	j	764 <vprintf+0x4a>
    } else if(state == '%'){
 760:	03598263          	beq	s3,s5,784 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 764:	2485                	addiw	s1,s1,1
 766:	8726                	mv	a4,s1
 768:	009a07b3          	add	a5,s4,s1
 76c:	0007c903          	lbu	s2,0(a5)
 770:	22090a63          	beqz	s2,9a4 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 774:	0009079b          	sext.w	a5,s2
    if(state == 0){
 778:	fe0994e3          	bnez	s3,760 <vprintf+0x46>
      if(c0 == '%'){
 77c:	fd579de3          	bne	a5,s5,756 <vprintf+0x3c>
        state = '%';
 780:	89be                	mv	s3,a5
 782:	b7cd                	j	764 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 784:	00ea06b3          	add	a3,s4,a4
 788:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 78c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 78e:	c681                	beqz	a3,796 <vprintf+0x7c>
 790:	9752                	add	a4,a4,s4
 792:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 796:	05878363          	beq	a5,s8,7dc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 79a:	05978d63          	beq	a5,s9,7f4 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 79e:	07500713          	li	a4,117
 7a2:	0ee78763          	beq	a5,a4,890 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7a6:	07800713          	li	a4,120
 7aa:	12e78963          	beq	a5,a4,8dc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7ae:	07000713          	li	a4,112
 7b2:	14e78e63          	beq	a5,a4,90e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7b6:	06300713          	li	a4,99
 7ba:	18e78e63          	beq	a5,a4,956 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7be:	07300713          	li	a4,115
 7c2:	1ae78463          	beq	a5,a4,96a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7c6:	02500713          	li	a4,37
 7ca:	04e79563          	bne	a5,a4,814 <vprintf+0xfa>
        putc(fd, '%');
 7ce:	02500593          	li	a1,37
 7d2:	855a                	mv	a0,s6
 7d4:	e8dff0ef          	jal	660 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b769                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7dc:	008b8913          	addi	s2,s7,8
 7e0:	4685                	li	a3,1
 7e2:	4629                	li	a2,10
 7e4:	000ba583          	lw	a1,0(s7)
 7e8:	855a                	mv	a0,s6
 7ea:	e95ff0ef          	jal	67e <printint>
 7ee:	8bca                	mv	s7,s2
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	bf8d                	j	764 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 7f4:	06400793          	li	a5,100
 7f8:	02f68963          	beq	a3,a5,82a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7fc:	06c00793          	li	a5,108
 800:	04f68263          	beq	a3,a5,844 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 804:	07500793          	li	a5,117
 808:	0af68063          	beq	a3,a5,8a8 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 80c:	07800793          	li	a5,120
 810:	0ef68263          	beq	a3,a5,8f4 <vprintf+0x1da>
        putc(fd, '%');
 814:	02500593          	li	a1,37
 818:	855a                	mv	a0,s6
 81a:	e47ff0ef          	jal	660 <putc>
        putc(fd, c0);
 81e:	85ca                	mv	a1,s2
 820:	855a                	mv	a0,s6
 822:	e3fff0ef          	jal	660 <putc>
      state = 0;
 826:	4981                	li	s3,0
 828:	bf35                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 82a:	008b8913          	addi	s2,s7,8
 82e:	4685                	li	a3,1
 830:	4629                	li	a2,10
 832:	000bb583          	ld	a1,0(s7)
 836:	855a                	mv	a0,s6
 838:	e47ff0ef          	jal	67e <printint>
        i += 1;
 83c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 83e:	8bca                	mv	s7,s2
      state = 0;
 840:	4981                	li	s3,0
        i += 1;
 842:	b70d                	j	764 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 844:	06400793          	li	a5,100
 848:	02f60763          	beq	a2,a5,876 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 84c:	07500793          	li	a5,117
 850:	06f60963          	beq	a2,a5,8c2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 854:	07800793          	li	a5,120
 858:	faf61ee3          	bne	a2,a5,814 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 85c:	008b8913          	addi	s2,s7,8
 860:	4681                	li	a3,0
 862:	4641                	li	a2,16
 864:	000bb583          	ld	a1,0(s7)
 868:	855a                	mv	a0,s6
 86a:	e15ff0ef          	jal	67e <printint>
        i += 2;
 86e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 870:	8bca                	mv	s7,s2
      state = 0;
 872:	4981                	li	s3,0
        i += 2;
 874:	bdc5                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 876:	008b8913          	addi	s2,s7,8
 87a:	4685                	li	a3,1
 87c:	4629                	li	a2,10
 87e:	000bb583          	ld	a1,0(s7)
 882:	855a                	mv	a0,s6
 884:	dfbff0ef          	jal	67e <printint>
        i += 2;
 888:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 88a:	8bca                	mv	s7,s2
      state = 0;
 88c:	4981                	li	s3,0
        i += 2;
 88e:	bdd9                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 890:	008b8913          	addi	s2,s7,8
 894:	4681                	li	a3,0
 896:	4629                	li	a2,10
 898:	000be583          	lwu	a1,0(s7)
 89c:	855a                	mv	a0,s6
 89e:	de1ff0ef          	jal	67e <printint>
 8a2:	8bca                	mv	s7,s2
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	bd7d                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a8:	008b8913          	addi	s2,s7,8
 8ac:	4681                	li	a3,0
 8ae:	4629                	li	a2,10
 8b0:	000bb583          	ld	a1,0(s7)
 8b4:	855a                	mv	a0,s6
 8b6:	dc9ff0ef          	jal	67e <printint>
        i += 1;
 8ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8bc:	8bca                	mv	s7,s2
      state = 0;
 8be:	4981                	li	s3,0
        i += 1;
 8c0:	b555                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8c2:	008b8913          	addi	s2,s7,8
 8c6:	4681                	li	a3,0
 8c8:	4629                	li	a2,10
 8ca:	000bb583          	ld	a1,0(s7)
 8ce:	855a                	mv	a0,s6
 8d0:	dafff0ef          	jal	67e <printint>
        i += 2;
 8d4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d6:	8bca                	mv	s7,s2
      state = 0;
 8d8:	4981                	li	s3,0
        i += 2;
 8da:	b569                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8dc:	008b8913          	addi	s2,s7,8
 8e0:	4681                	li	a3,0
 8e2:	4641                	li	a2,16
 8e4:	000be583          	lwu	a1,0(s7)
 8e8:	855a                	mv	a0,s6
 8ea:	d95ff0ef          	jal	67e <printint>
 8ee:	8bca                	mv	s7,s2
      state = 0;
 8f0:	4981                	li	s3,0
 8f2:	bd8d                	j	764 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8f4:	008b8913          	addi	s2,s7,8
 8f8:	4681                	li	a3,0
 8fa:	4641                	li	a2,16
 8fc:	000bb583          	ld	a1,0(s7)
 900:	855a                	mv	a0,s6
 902:	d7dff0ef          	jal	67e <printint>
        i += 1;
 906:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 908:	8bca                	mv	s7,s2
      state = 0;
 90a:	4981                	li	s3,0
        i += 1;
 90c:	bda1                	j	764 <vprintf+0x4a>
 90e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 910:	008b8d13          	addi	s10,s7,8
 914:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 918:	03000593          	li	a1,48
 91c:	855a                	mv	a0,s6
 91e:	d43ff0ef          	jal	660 <putc>
  putc(fd, 'x');
 922:	07800593          	li	a1,120
 926:	855a                	mv	a0,s6
 928:	d39ff0ef          	jal	660 <putc>
 92c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92e:	00000b97          	auipc	s7,0x0
 932:	5dab8b93          	addi	s7,s7,1498 # f08 <digits>
 936:	03c9d793          	srli	a5,s3,0x3c
 93a:	97de                	add	a5,a5,s7
 93c:	0007c583          	lbu	a1,0(a5)
 940:	855a                	mv	a0,s6
 942:	d1fff0ef          	jal	660 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 946:	0992                	slli	s3,s3,0x4
 948:	397d                	addiw	s2,s2,-1
 94a:	fe0916e3          	bnez	s2,936 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 94e:	8bea                	mv	s7,s10
      state = 0;
 950:	4981                	li	s3,0
 952:	6d02                	ld	s10,0(sp)
 954:	bd01                	j	764 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 956:	008b8913          	addi	s2,s7,8
 95a:	000bc583          	lbu	a1,0(s7)
 95e:	855a                	mv	a0,s6
 960:	d01ff0ef          	jal	660 <putc>
 964:	8bca                	mv	s7,s2
      state = 0;
 966:	4981                	li	s3,0
 968:	bbf5                	j	764 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 96a:	008b8993          	addi	s3,s7,8
 96e:	000bb903          	ld	s2,0(s7)
 972:	00090f63          	beqz	s2,990 <vprintf+0x276>
        for(; *s; s++)
 976:	00094583          	lbu	a1,0(s2)
 97a:	c195                	beqz	a1,99e <vprintf+0x284>
          putc(fd, *s);
 97c:	855a                	mv	a0,s6
 97e:	ce3ff0ef          	jal	660 <putc>
        for(; *s; s++)
 982:	0905                	addi	s2,s2,1
 984:	00094583          	lbu	a1,0(s2)
 988:	f9f5                	bnez	a1,97c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 98a:	8bce                	mv	s7,s3
      state = 0;
 98c:	4981                	li	s3,0
 98e:	bbd9                	j	764 <vprintf+0x4a>
          s = "(null)";
 990:	00000917          	auipc	s2,0x0
 994:	57090913          	addi	s2,s2,1392 # f00 <malloc+0x464>
        for(; *s; s++)
 998:	02800593          	li	a1,40
 99c:	b7c5                	j	97c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 99e:	8bce                	mv	s7,s3
      state = 0;
 9a0:	4981                	li	s3,0
 9a2:	b3c9                	j	764 <vprintf+0x4a>
 9a4:	64a6                	ld	s1,72(sp)
 9a6:	79e2                	ld	s3,56(sp)
 9a8:	7a42                	ld	s4,48(sp)
 9aa:	7aa2                	ld	s5,40(sp)
 9ac:	7b02                	ld	s6,32(sp)
 9ae:	6be2                	ld	s7,24(sp)
 9b0:	6c42                	ld	s8,16(sp)
 9b2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9b4:	60e6                	ld	ra,88(sp)
 9b6:	6446                	ld	s0,80(sp)
 9b8:	6906                	ld	s2,64(sp)
 9ba:	6125                	addi	sp,sp,96
 9bc:	8082                	ret

00000000000009be <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9be:	715d                	addi	sp,sp,-80
 9c0:	ec06                	sd	ra,24(sp)
 9c2:	e822                	sd	s0,16(sp)
 9c4:	1000                	addi	s0,sp,32
 9c6:	e010                	sd	a2,0(s0)
 9c8:	e414                	sd	a3,8(s0)
 9ca:	e818                	sd	a4,16(s0)
 9cc:	ec1c                	sd	a5,24(s0)
 9ce:	03043023          	sd	a6,32(s0)
 9d2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9d6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9da:	8622                	mv	a2,s0
 9dc:	d3fff0ef          	jal	71a <vprintf>
}
 9e0:	60e2                	ld	ra,24(sp)
 9e2:	6442                	ld	s0,16(sp)
 9e4:	6161                	addi	sp,sp,80
 9e6:	8082                	ret

00000000000009e8 <printf>:

void
printf(const char *fmt, ...)
{
 9e8:	711d                	addi	sp,sp,-96
 9ea:	ec06                	sd	ra,24(sp)
 9ec:	e822                	sd	s0,16(sp)
 9ee:	1000                	addi	s0,sp,32
 9f0:	e40c                	sd	a1,8(s0)
 9f2:	e810                	sd	a2,16(s0)
 9f4:	ec14                	sd	a3,24(s0)
 9f6:	f018                	sd	a4,32(s0)
 9f8:	f41c                	sd	a5,40(s0)
 9fa:	03043823          	sd	a6,48(s0)
 9fe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a02:	00840613          	addi	a2,s0,8
 a06:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a0a:	85aa                	mv	a1,a0
 a0c:	4505                	li	a0,1
 a0e:	d0dff0ef          	jal	71a <vprintf>
}
 a12:	60e2                	ld	ra,24(sp)
 a14:	6442                	ld	s0,16(sp)
 a16:	6125                	addi	sp,sp,96
 a18:	8082                	ret

0000000000000a1a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a1a:	1141                	addi	sp,sp,-16
 a1c:	e422                	sd	s0,8(sp)
 a1e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a20:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a24:	00000797          	auipc	a5,0x0
 a28:	5dc7b783          	ld	a5,1500(a5) # 1000 <freep>
 a2c:	a02d                	j	a56 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a2e:	4618                	lw	a4,8(a2)
 a30:	9f2d                	addw	a4,a4,a1
 a32:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a36:	6398                	ld	a4,0(a5)
 a38:	6310                	ld	a2,0(a4)
 a3a:	a83d                	j	a78 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a3c:	ff852703          	lw	a4,-8(a0)
 a40:	9f31                	addw	a4,a4,a2
 a42:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a44:	ff053683          	ld	a3,-16(a0)
 a48:	a091                	j	a8c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a4a:	6398                	ld	a4,0(a5)
 a4c:	00e7e463          	bltu	a5,a4,a54 <free+0x3a>
 a50:	00e6ea63          	bltu	a3,a4,a64 <free+0x4a>
{
 a54:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a56:	fed7fae3          	bgeu	a5,a3,a4a <free+0x30>
 a5a:	6398                	ld	a4,0(a5)
 a5c:	00e6e463          	bltu	a3,a4,a64 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a60:	fee7eae3          	bltu	a5,a4,a54 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a64:	ff852583          	lw	a1,-8(a0)
 a68:	6390                	ld	a2,0(a5)
 a6a:	02059813          	slli	a6,a1,0x20
 a6e:	01c85713          	srli	a4,a6,0x1c
 a72:	9736                	add	a4,a4,a3
 a74:	fae60de3          	beq	a2,a4,a2e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a78:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a7c:	4790                	lw	a2,8(a5)
 a7e:	02061593          	slli	a1,a2,0x20
 a82:	01c5d713          	srli	a4,a1,0x1c
 a86:	973e                	add	a4,a4,a5
 a88:	fae68ae3          	beq	a3,a4,a3c <free+0x22>
    p->s.ptr = bp->s.ptr;
 a8c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a8e:	00000717          	auipc	a4,0x0
 a92:	56f73923          	sd	a5,1394(a4) # 1000 <freep>
}
 a96:	6422                	ld	s0,8(sp)
 a98:	0141                	addi	sp,sp,16
 a9a:	8082                	ret

0000000000000a9c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a9c:	7139                	addi	sp,sp,-64
 a9e:	fc06                	sd	ra,56(sp)
 aa0:	f822                	sd	s0,48(sp)
 aa2:	f426                	sd	s1,40(sp)
 aa4:	ec4e                	sd	s3,24(sp)
 aa6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aa8:	02051493          	slli	s1,a0,0x20
 aac:	9081                	srli	s1,s1,0x20
 aae:	04bd                	addi	s1,s1,15
 ab0:	8091                	srli	s1,s1,0x4
 ab2:	0014899b          	addiw	s3,s1,1
 ab6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ab8:	00000517          	auipc	a0,0x0
 abc:	54853503          	ld	a0,1352(a0) # 1000 <freep>
 ac0:	c915                	beqz	a0,af4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac4:	4798                	lw	a4,8(a5)
 ac6:	08977a63          	bgeu	a4,s1,b5a <malloc+0xbe>
 aca:	f04a                	sd	s2,32(sp)
 acc:	e852                	sd	s4,16(sp)
 ace:	e456                	sd	s5,8(sp)
 ad0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 ad2:	8a4e                	mv	s4,s3
 ad4:	0009871b          	sext.w	a4,s3
 ad8:	6685                	lui	a3,0x1
 ada:	00d77363          	bgeu	a4,a3,ae0 <malloc+0x44>
 ade:	6a05                	lui	s4,0x1
 ae0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ae4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ae8:	00000917          	auipc	s2,0x0
 aec:	51890913          	addi	s2,s2,1304 # 1000 <freep>
  if(p == SBRK_ERROR)
 af0:	5afd                	li	s5,-1
 af2:	a081                	j	b32 <malloc+0x96>
 af4:	f04a                	sd	s2,32(sp)
 af6:	e852                	sd	s4,16(sp)
 af8:	e456                	sd	s5,8(sp)
 afa:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 afc:	00000797          	auipc	a5,0x0
 b00:	51478793          	addi	a5,a5,1300 # 1010 <base>
 b04:	00000717          	auipc	a4,0x0
 b08:	4ef73e23          	sd	a5,1276(a4) # 1000 <freep>
 b0c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b0e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b12:	b7c1                	j	ad2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b14:	6398                	ld	a4,0(a5)
 b16:	e118                	sd	a4,0(a0)
 b18:	a8a9                	j	b72 <malloc+0xd6>
  hp->s.size = nu;
 b1a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b1e:	0541                	addi	a0,a0,16
 b20:	efbff0ef          	jal	a1a <free>
  return freep;
 b24:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b28:	c12d                	beqz	a0,b8a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b2a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b2c:	4798                	lw	a4,8(a5)
 b2e:	02977263          	bgeu	a4,s1,b52 <malloc+0xb6>
    if(p == freep)
 b32:	00093703          	ld	a4,0(s2)
 b36:	853e                	mv	a0,a5
 b38:	fef719e3          	bne	a4,a5,b2a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b3c:	8552                	mv	a0,s4
 b3e:	9ffff0ef          	jal	53c <sbrk>
  if(p == SBRK_ERROR)
 b42:	fd551ce3          	bne	a0,s5,b1a <malloc+0x7e>
        return 0;
 b46:	4501                	li	a0,0
 b48:	7902                	ld	s2,32(sp)
 b4a:	6a42                	ld	s4,16(sp)
 b4c:	6aa2                	ld	s5,8(sp)
 b4e:	6b02                	ld	s6,0(sp)
 b50:	a03d                	j	b7e <malloc+0xe2>
 b52:	7902                	ld	s2,32(sp)
 b54:	6a42                	ld	s4,16(sp)
 b56:	6aa2                	ld	s5,8(sp)
 b58:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b5a:	fae48de3          	beq	s1,a4,b14 <malloc+0x78>
        p->s.size -= nunits;
 b5e:	4137073b          	subw	a4,a4,s3
 b62:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b64:	02071693          	slli	a3,a4,0x20
 b68:	01c6d713          	srli	a4,a3,0x1c
 b6c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b6e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b72:	00000717          	auipc	a4,0x0
 b76:	48a73723          	sd	a0,1166(a4) # 1000 <freep>
      return (void*)(p + 1);
 b7a:	01078513          	addi	a0,a5,16
  }
}
 b7e:	70e2                	ld	ra,56(sp)
 b80:	7442                	ld	s0,48(sp)
 b82:	74a2                	ld	s1,40(sp)
 b84:	69e2                	ld	s3,24(sp)
 b86:	6121                	addi	sp,sp,64
 b88:	8082                	ret
 b8a:	7902                	ld	s2,32(sp)
 b8c:	6a42                	ld	s4,16(sp)
 b8e:	6aa2                	ld	s5,8(sp)
 b90:	6b02                	ld	s6,0(sp)
 b92:	b7f5                	j	b7e <malloc+0xe2>
