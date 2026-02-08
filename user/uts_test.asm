
user/_uts_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
// UTS Namespace Test
// Tests hostname isolation between processes

int
main(int argc, char *argv[])
{
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	0900                	addi	s0,sp,144
  int pid;
  char buf[64];

  printf("=== UTS Namespace Isolation Test ===\n\n");
   8:	00001517          	auipc	a0,0x1
   c:	b2850513          	addi	a0,a0,-1240 # b30 <malloc+0x100>
  10:	16d000ef          	jal	97c <printf>

  printf("Setting parent hostname to 'parent-host'...\n");
  14:	00001517          	auipc	a0,0x1
  18:	b4c50513          	addi	a0,a0,-1204 # b60 <malloc+0x130>
  1c:	161000ef          	jal	97c <printf>
  if(setHostname("parent-host", 11) == 0) {
  20:	45ad                	li	a1,11
  22:	00001517          	auipc	a0,0x1
  26:	b6e50513          	addi	a0,a0,-1170 # b90 <malloc+0x160>
  2a:	5ba000ef          	jal	5e4 <setHostname>
  2e:	cd2d                	beqz	a0,a8 <main+0xa8>
      printf("Parent hostname: %s\n\n", buf);
    }
  }

  // Create first container
  pid = fork();
  30:	4cc000ef          	jal	4fc <fork>
  if(pid == 0) {
  34:	0e051263          	bnez	a0,118 <main+0x118>
    // Container 1
    printf("Container 1 (child process):\n");
  38:	00001517          	auipc	a0,0x1
  3c:	b8050513          	addi	a0,a0,-1152 # bb8 <malloc+0x188>
  40:	13d000ef          	jal	97c <printf>
    if(getHostname(buf, 64) == 0) {
  44:	04000593          	li	a1,64
  48:	fb040513          	addi	a0,s0,-80
  4c:	590000ef          	jal	5dc <getHostname>
  50:	cd25                	beqz	a0,c8 <main+0xc8>
      printf("  Inherits parent hostname: %s\n", buf);
    }
    
    // Try to set new hostname
    if(setHostname("container-1", 11) == 0) {
  52:	45ad                	li	a1,11
  54:	00001517          	auipc	a0,0x1
  58:	ba450513          	addi	a0,a0,-1116 # bf8 <malloc+0x1c8>
  5c:	588000ef          	jal	5e4 <setHostname>
  60:	cd2d                	beqz	a0,da <main+0xda>
        printf("  Changed to: %s\n", buf);
      }
    }
    
    // Now isolate with unshare
    if(unshare(CLONE_NEWUTS) == 0) {
  62:	04000537          	lui	a0,0x4000
  66:	586000ef          	jal	5ec <unshare>
  6a:	e941                	bnez	a0,fa <main+0xfa>
      printf("  Created new UTS namespace\n");
  6c:	00001517          	auipc	a0,0x1
  70:	bb450513          	addi	a0,a0,-1100 # c20 <malloc+0x1f0>
  74:	109000ef          	jal	97c <printf>
      if(setHostname("isolated-1", 10) == 0) {
  78:	45a9                	li	a1,10
  7a:	00001517          	auipc	a0,0x1
  7e:	bc650513          	addi	a0,a0,-1082 # c40 <malloc+0x210>
  82:	562000ef          	jal	5e4 <setHostname>
  86:	e141                	bnez	a0,106 <main+0x106>
        if(getHostname(buf, 64) == 0) {
  88:	04000593          	li	a1,64
  8c:	fb040513          	addi	a0,s0,-80
  90:	54c000ef          	jal	5dc <getHostname>
  94:	e92d                	bnez	a0,106 <main+0x106>
          printf("  New isolated hostname: %s\n", buf);
  96:	fb040593          	addi	a1,s0,-80
  9a:	00001517          	auipc	a0,0x1
  9e:	bb650513          	addi	a0,a0,-1098 # c50 <malloc+0x220>
  a2:	0db000ef          	jal	97c <printf>
  a6:	a085                	j	106 <main+0x106>
    if(getHostname(buf, 64) == 0) {
  a8:	04000593          	li	a1,64
  ac:	fb040513          	addi	a0,s0,-80
  b0:	52c000ef          	jal	5dc <getHostname>
  b4:	fd35                	bnez	a0,30 <main+0x30>
      printf("Parent hostname: %s\n\n", buf);
  b6:	fb040593          	addi	a1,s0,-80
  ba:	00001517          	auipc	a0,0x1
  be:	ae650513          	addi	a0,a0,-1306 # ba0 <malloc+0x170>
  c2:	0bb000ef          	jal	97c <printf>
  c6:	b7ad                	j	30 <main+0x30>
      printf("  Inherits parent hostname: %s\n", buf);
  c8:	fb040593          	addi	a1,s0,-80
  cc:	00001517          	auipc	a0,0x1
  d0:	b0c50513          	addi	a0,a0,-1268 # bd8 <malloc+0x1a8>
  d4:	0a9000ef          	jal	97c <printf>
  d8:	bfad                	j	52 <main+0x52>
      if(getHostname(buf, 64) == 0) {
  da:	04000593          	li	a1,64
  de:	fb040513          	addi	a0,s0,-80
  e2:	4fa000ef          	jal	5dc <getHostname>
  e6:	fd35                	bnez	a0,62 <main+0x62>
        printf("  Changed to: %s\n", buf);
  e8:	fb040593          	addi	a1,s0,-80
  ec:	00001517          	auipc	a0,0x1
  f0:	b1c50513          	addi	a0,a0,-1252 # c08 <malloc+0x1d8>
  f4:	089000ef          	jal	97c <printf>
  f8:	b7ad                	j	62 <main+0x62>
        }
      }
    } else {
      printf("  unshare(CLONE_NEWUTS) failed\n");
  fa:	00001517          	auipc	a0,0x1
  fe:	b7650513          	addi	a0,a0,-1162 # c70 <malloc+0x240>
 102:	07b000ef          	jal	97c <printf>
    }
    
    printf("\n");
 106:	00001517          	auipc	a0,0x1
 10a:	b8a50513          	addi	a0,a0,-1142 # c90 <malloc+0x260>
 10e:	06f000ef          	jal	97c <printf>
    exit(0);
 112:	4501                	li	a0,0
 114:	3f0000ef          	jal	504 <exit>
  }

  // Create second container
  pid = fork();
 118:	3e4000ef          	jal	4fc <fork>
  if(pid == 0) {
 11c:	e159                	bnez	a0,1a2 <main+0x1a2>
    // Container 2
    char buf2[64];
    printf("Container 2 (another child):\n");
 11e:	00001517          	auipc	a0,0x1
 122:	b7a50513          	addi	a0,a0,-1158 # c98 <malloc+0x268>
 126:	057000ef          	jal	97c <printf>
    
    if(getHostname(buf2, 64) == 0) {
 12a:	04000593          	li	a1,64
 12e:	f7040513          	addi	a0,s0,-144
 132:	4aa000ef          	jal	5dc <getHostname>
 136:	cd19                	beqz	a0,154 <main+0x154>
      printf("  Inherits parent hostname: %s\n", buf2);
    }
    
    // Isolate with unshare
    if(unshare(CLONE_NEWUTS) == 0) {
 138:	04000537          	lui	a0,0x4000
 13c:	4b0000ef          	jal	5ec <unshare>
 140:	c11d                	beqz	a0,166 <main+0x166>
          printf("  New isolated hostname: %s\n", buf2);
        }
      }
    }
    
    printf("\n");
 142:	00001517          	auipc	a0,0x1
 146:	b4e50513          	addi	a0,a0,-1202 # c90 <malloc+0x260>
 14a:	033000ef          	jal	97c <printf>
    exit(0);
 14e:	4501                	li	a0,0
 150:	3b4000ef          	jal	504 <exit>
      printf("  Inherits parent hostname: %s\n", buf2);
 154:	f7040593          	addi	a1,s0,-144
 158:	00001517          	auipc	a0,0x1
 15c:	a8050513          	addi	a0,a0,-1408 # bd8 <malloc+0x1a8>
 160:	01d000ef          	jal	97c <printf>
 164:	bfd1                	j	138 <main+0x138>
      printf("  Created new UTS namespace\n");
 166:	00001517          	auipc	a0,0x1
 16a:	aba50513          	addi	a0,a0,-1350 # c20 <malloc+0x1f0>
 16e:	00f000ef          	jal	97c <printf>
      if(setHostname("isolated-2", 10) == 0) {
 172:	45a9                	li	a1,10
 174:	00001517          	auipc	a0,0x1
 178:	b4450513          	addi	a0,a0,-1212 # cb8 <malloc+0x288>
 17c:	468000ef          	jal	5e4 <setHostname>
 180:	f169                	bnez	a0,142 <main+0x142>
        if(getHostname(buf2, 64) == 0) {
 182:	04000593          	li	a1,64
 186:	f7040513          	addi	a0,s0,-144
 18a:	452000ef          	jal	5dc <getHostname>
 18e:	f955                	bnez	a0,142 <main+0x142>
          printf("  New isolated hostname: %s\n", buf2);
 190:	f7040593          	addi	a1,s0,-144
 194:	00001517          	auipc	a0,0x1
 198:	abc50513          	addi	a0,a0,-1348 # c50 <malloc+0x220>
 19c:	7e0000ef          	jal	97c <printf>
 1a0:	b74d                	j	142 <main+0x142>
  }

  // Wait for containers
  wait(0);
 1a2:	4501                	li	a0,0
 1a4:	368000ef          	jal	50c <wait>
  wait(0);
 1a8:	4501                	li	a0,0
 1aa:	362000ef          	jal	50c <wait>

  printf("Parent process after children:\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	b1a50513          	addi	a0,a0,-1254 # cc8 <malloc+0x298>
 1b6:	7c6000ef          	jal	97c <printf>
  if(getHostname(buf, 64) == 0) {
 1ba:	04000593          	li	a1,64
 1be:	fb040513          	addi	a0,s0,-80
 1c2:	41a000ef          	jal	5dc <getHostname>
 1c6:	c115                	beqz	a0,1ea <main+0x1ea>
    printf("  Hostname still: %s\n", buf);
  }
  printf("  Children's changes did not affect parent!\n\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	b3850513          	addi	a0,a0,-1224 # d00 <malloc+0x2d0>
 1d0:	7ac000ef          	jal	97c <printf>

  // Test combined namespace isolation
  pid = fork();
 1d4:	328000ef          	jal	4fc <fork>
  if(pid == 0) {
 1d8:	e141                	bnez	a0,258 <main+0x258>
    // Full isolation
    if(unshare(CLONE_NEWPID | CLONE_NEWUTS | CLONE_NEWIPC) == 0) {
 1da:	2c000537          	lui	a0,0x2c000
 1de:	40e000ef          	jal	5ec <unshare>
 1e2:	cd09                	beqz	a0,1fc <main+0x1fc>
          printf("  Hostname: %s (isolated)\n", buf);
        }
      }
      printf("  IPC namespace: isolated\n");
    }
    exit(0);
 1e4:	4501                	li	a0,0
 1e6:	31e000ef          	jal	504 <exit>
    printf("  Hostname still: %s\n", buf);
 1ea:	fb040593          	addi	a1,s0,-80
 1ee:	00001517          	auipc	a0,0x1
 1f2:	afa50513          	addi	a0,a0,-1286 # ce8 <malloc+0x2b8>
 1f6:	786000ef          	jal	97c <printf>
 1fa:	b7f9                	j	1c8 <main+0x1c8>
      printf("Full isolation test:\n");
 1fc:	00001517          	auipc	a0,0x1
 200:	b3450513          	addi	a0,a0,-1228 # d30 <malloc+0x300>
 204:	778000ef          	jal	97c <printf>
      printf("  New PID: %d (namespace isolated)\n", getpid());
 208:	37c000ef          	jal	584 <getpid>
 20c:	85aa                	mv	a1,a0
 20e:	00001517          	auipc	a0,0x1
 212:	b3a50513          	addi	a0,a0,-1222 # d48 <malloc+0x318>
 216:	766000ef          	jal	97c <printf>
      if(setHostname("fully-isolated", 14) == 0) {
 21a:	45b9                	li	a1,14
 21c:	00001517          	auipc	a0,0x1
 220:	b5450513          	addi	a0,a0,-1196 # d70 <malloc+0x340>
 224:	3c0000ef          	jal	5e4 <setHostname>
 228:	c901                	beqz	a0,238 <main+0x238>
      printf("  IPC namespace: isolated\n");
 22a:	00001517          	auipc	a0,0x1
 22e:	b7650513          	addi	a0,a0,-1162 # da0 <malloc+0x370>
 232:	74a000ef          	jal	97c <printf>
 236:	b77d                	j	1e4 <main+0x1e4>
        if(getHostname(buf, 64) == 0) {
 238:	04000593          	li	a1,64
 23c:	fb040513          	addi	a0,s0,-80
 240:	39c000ef          	jal	5dc <getHostname>
 244:	f17d                	bnez	a0,22a <main+0x22a>
          printf("  Hostname: %s (isolated)\n", buf);
 246:	fb040593          	addi	a1,s0,-80
 24a:	00001517          	auipc	a0,0x1
 24e:	b3650513          	addi	a0,a0,-1226 # d80 <malloc+0x350>
 252:	72a000ef          	jal	97c <printf>
 256:	bfd1                	j	22a <main+0x22a>
  }

  wait(0);
 258:	4501                	li	a0,0
 25a:	2b2000ef          	jal	50c <wait>

  printf("\n=== UTS Namespace Test Complete ===\n");
 25e:	00001517          	auipc	a0,0x1
 262:	b6250513          	addi	a0,a0,-1182 # dc0 <malloc+0x390>
 266:	716000ef          	jal	97c <printf>
  
  exit(0);
 26a:	4501                	li	a0,0
 26c:	298000ef          	jal	504 <exit>

0000000000000270 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 278:	d89ff0ef          	jal	0 <main>
  exit(r);
 27c:	288000ef          	jal	504 <exit>

0000000000000280 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 286:	87aa                	mv	a5,a0
 288:	0585                	addi	a1,a1,1
 28a:	0785                	addi	a5,a5,1
 28c:	fff5c703          	lbu	a4,-1(a1)
 290:	fee78fa3          	sb	a4,-1(a5)
 294:	fb75                	bnez	a4,288 <strcpy+0x8>
    ;
  return os;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret

000000000000029c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	cb91                	beqz	a5,2ba <strcmp+0x1e>
 2a8:	0005c703          	lbu	a4,0(a1)
 2ac:	00f71763          	bne	a4,a5,2ba <strcmp+0x1e>
    p++, q++;
 2b0:	0505                	addi	a0,a0,1
 2b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	fbe5                	bnez	a5,2a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2ba:	0005c503          	lbu	a0,0(a1)
}
 2be:	40a7853b          	subw	a0,a5,a0
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <strlen>:

uint
strlen(const char *s)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	cf91                	beqz	a5,2ee <strlen+0x26>
 2d4:	0505                	addi	a0,a0,1
 2d6:	87aa                	mv	a5,a0
 2d8:	86be                	mv	a3,a5
 2da:	0785                	addi	a5,a5,1
 2dc:	fff7c703          	lbu	a4,-1(a5)
 2e0:	ff65                	bnez	a4,2d8 <strlen+0x10>
 2e2:	40a6853b          	subw	a0,a3,a0
 2e6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e8:	6422                	ld	s0,8(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  for(n = 0; s[n]; n++)
 2ee:	4501                	li	a0,0
 2f0:	bfe5                	j	2e8 <strlen+0x20>

00000000000002f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f8:	ca19                	beqz	a2,30e <memset+0x1c>
 2fa:	87aa                	mv	a5,a0
 2fc:	1602                	slli	a2,a2,0x20
 2fe:	9201                	srli	a2,a2,0x20
 300:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 304:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 308:	0785                	addi	a5,a5,1
 30a:	fee79de3          	bne	a5,a4,304 <memset+0x12>
  }
  return dst;
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret

0000000000000314 <strchr>:

char*
strchr(const char *s, char c)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  for(; *s; s++)
 31a:	00054783          	lbu	a5,0(a0)
 31e:	cb99                	beqz	a5,334 <strchr+0x20>
    if(*s == c)
 320:	00f58763          	beq	a1,a5,32e <strchr+0x1a>
  for(; *s; s++)
 324:	0505                	addi	a0,a0,1
 326:	00054783          	lbu	a5,0(a0)
 32a:	fbfd                	bnez	a5,320 <strchr+0xc>
      return (char*)s;
  return 0;
 32c:	4501                	li	a0,0
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  return 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <strchr+0x1a>

0000000000000338 <gets>:

char*
gets(char *buf, int max)
{
 338:	711d                	addi	sp,sp,-96
 33a:	ec86                	sd	ra,88(sp)
 33c:	e8a2                	sd	s0,80(sp)
 33e:	e4a6                	sd	s1,72(sp)
 340:	e0ca                	sd	s2,64(sp)
 342:	fc4e                	sd	s3,56(sp)
 344:	f852                	sd	s4,48(sp)
 346:	f456                	sd	s5,40(sp)
 348:	f05a                	sd	s6,32(sp)
 34a:	ec5e                	sd	s7,24(sp)
 34c:	1080                	addi	s0,sp,96
 34e:	8baa                	mv	s7,a0
 350:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 352:	892a                	mv	s2,a0
 354:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 356:	4aa9                	li	s5,10
 358:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 35a:	89a6                	mv	s3,s1
 35c:	2485                	addiw	s1,s1,1
 35e:	0344d663          	bge	s1,s4,38a <gets+0x52>
    cc = read(0, &c, 1);
 362:	4605                	li	a2,1
 364:	faf40593          	addi	a1,s0,-81
 368:	4501                	li	a0,0
 36a:	1b2000ef          	jal	51c <read>
    if(cc < 1)
 36e:	00a05e63          	blez	a0,38a <gets+0x52>
    buf[i++] = c;
 372:	faf44783          	lbu	a5,-81(s0)
 376:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 37a:	01578763          	beq	a5,s5,388 <gets+0x50>
 37e:	0905                	addi	s2,s2,1
 380:	fd679de3          	bne	a5,s6,35a <gets+0x22>
    buf[i++] = c;
 384:	89a6                	mv	s3,s1
 386:	a011                	j	38a <gets+0x52>
 388:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 38a:	99de                	add	s3,s3,s7
 38c:	00098023          	sb	zero,0(s3)
  return buf;
}
 390:	855e                	mv	a0,s7
 392:	60e6                	ld	ra,88(sp)
 394:	6446                	ld	s0,80(sp)
 396:	64a6                	ld	s1,72(sp)
 398:	6906                	ld	s2,64(sp)
 39a:	79e2                	ld	s3,56(sp)
 39c:	7a42                	ld	s4,48(sp)
 39e:	7aa2                	ld	s5,40(sp)
 3a0:	7b02                	ld	s6,32(sp)
 3a2:	6be2                	ld	s7,24(sp)
 3a4:	6125                	addi	sp,sp,96
 3a6:	8082                	ret

00000000000003a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	e04a                	sd	s2,0(sp)
 3b0:	1000                	addi	s0,sp,32
 3b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b4:	4581                	li	a1,0
 3b6:	18e000ef          	jal	544 <open>
  if(fd < 0)
 3ba:	02054263          	bltz	a0,3de <stat+0x36>
 3be:	e426                	sd	s1,8(sp)
 3c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c2:	85ca                	mv	a1,s2
 3c4:	198000ef          	jal	55c <fstat>
 3c8:	892a                	mv	s2,a0
  close(fd);
 3ca:	8526                	mv	a0,s1
 3cc:	160000ef          	jal	52c <close>
  return r;
 3d0:	64a2                	ld	s1,8(sp)
}
 3d2:	854a                	mv	a0,s2
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	6902                	ld	s2,0(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret
    return -1;
 3de:	597d                	li	s2,-1
 3e0:	bfcd                	j	3d2 <stat+0x2a>

00000000000003e2 <atoi>:

int
atoi(const char *s)
{
 3e2:	1141                	addi	sp,sp,-16
 3e4:	e422                	sd	s0,8(sp)
 3e6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e8:	00054683          	lbu	a3,0(a0)
 3ec:	fd06879b          	addiw	a5,a3,-48
 3f0:	0ff7f793          	zext.b	a5,a5
 3f4:	4625                	li	a2,9
 3f6:	02f66863          	bltu	a2,a5,426 <atoi+0x44>
 3fa:	872a                	mv	a4,a0
  n = 0;
 3fc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fe:	0705                	addi	a4,a4,1
 400:	0025179b          	slliw	a5,a0,0x2
 404:	9fa9                	addw	a5,a5,a0
 406:	0017979b          	slliw	a5,a5,0x1
 40a:	9fb5                	addw	a5,a5,a3
 40c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 410:	00074683          	lbu	a3,0(a4)
 414:	fd06879b          	addiw	a5,a3,-48
 418:	0ff7f793          	zext.b	a5,a5
 41c:	fef671e3          	bgeu	a2,a5,3fe <atoi+0x1c>
  return n;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
  n = 0;
 426:	4501                	li	a0,0
 428:	bfe5                	j	420 <atoi+0x3e>

000000000000042a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e422                	sd	s0,8(sp)
 42e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 430:	02b57463          	bgeu	a0,a1,458 <memmove+0x2e>
    while(n-- > 0)
 434:	00c05f63          	blez	a2,452 <memmove+0x28>
 438:	1602                	slli	a2,a2,0x20
 43a:	9201                	srli	a2,a2,0x20
 43c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 440:	872a                	mv	a4,a0
      *dst++ = *src++;
 442:	0585                	addi	a1,a1,1
 444:	0705                	addi	a4,a4,1
 446:	fff5c683          	lbu	a3,-1(a1)
 44a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44e:	fef71ae3          	bne	a4,a5,442 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 452:	6422                	ld	s0,8(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret
    dst += n;
 458:	00c50733          	add	a4,a0,a2
    src += n;
 45c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45e:	fec05ae3          	blez	a2,452 <memmove+0x28>
 462:	fff6079b          	addiw	a5,a2,-1
 466:	1782                	slli	a5,a5,0x20
 468:	9381                	srli	a5,a5,0x20
 46a:	fff7c793          	not	a5,a5
 46e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 470:	15fd                	addi	a1,a1,-1
 472:	177d                	addi	a4,a4,-1
 474:	0005c683          	lbu	a3,0(a1)
 478:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 47c:	fee79ae3          	bne	a5,a4,470 <memmove+0x46>
 480:	bfc9                	j	452 <memmove+0x28>

0000000000000482 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 482:	1141                	addi	sp,sp,-16
 484:	e422                	sd	s0,8(sp)
 486:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 488:	ca05                	beqz	a2,4b8 <memcmp+0x36>
 48a:	fff6069b          	addiw	a3,a2,-1
 48e:	1682                	slli	a3,a3,0x20
 490:	9281                	srli	a3,a3,0x20
 492:	0685                	addi	a3,a3,1
 494:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 496:	00054783          	lbu	a5,0(a0)
 49a:	0005c703          	lbu	a4,0(a1)
 49e:	00e79863          	bne	a5,a4,4ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4a2:	0505                	addi	a0,a0,1
    p2++;
 4a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a6:	fed518e3          	bne	a0,a3,496 <memcmp+0x14>
  }
  return 0;
 4aa:	4501                	li	a0,0
 4ac:	a019                	j	4b2 <memcmp+0x30>
      return *p1 - *p2;
 4ae:	40e7853b          	subw	a0,a5,a4
}
 4b2:	6422                	ld	s0,8(sp)
 4b4:	0141                	addi	sp,sp,16
 4b6:	8082                	ret
  return 0;
 4b8:	4501                	li	a0,0
 4ba:	bfe5                	j	4b2 <memcmp+0x30>

00000000000004bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4bc:	1141                	addi	sp,sp,-16
 4be:	e406                	sd	ra,8(sp)
 4c0:	e022                	sd	s0,0(sp)
 4c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c4:	f67ff0ef          	jal	42a <memmove>
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret

00000000000004d0 <sbrk>:

char *
sbrk(int n) {
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e406                	sd	ra,8(sp)
 4d4:	e022                	sd	s0,0(sp)
 4d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d8:	4585                	li	a1,1
 4da:	0b2000ef          	jal	58c <sys_sbrk>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <sbrklazy>:

char *
sbrklazy(int n) {
 4e6:	1141                	addi	sp,sp,-16
 4e8:	e406                	sd	ra,8(sp)
 4ea:	e022                	sd	s0,0(sp)
 4ec:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ee:	4589                	li	a1,2
 4f0:	09c000ef          	jal	58c <sys_sbrk>
}
 4f4:	60a2                	ld	ra,8(sp)
 4f6:	6402                	ld	s0,0(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret

00000000000004fc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4fc:	4885                	li	a7,1
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <exit>:
.global exit
exit:
 li a7, SYS_exit
 504:	4889                	li	a7,2
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <wait>:
.global wait
wait:
 li a7, SYS_wait
 50c:	488d                	li	a7,3
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 514:	4891                	li	a7,4
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <read>:
.global read
read:
 li a7, SYS_read
 51c:	4895                	li	a7,5
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <write>:
.global write
write:
 li a7, SYS_write
 524:	48c1                	li	a7,16
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <close>:
.global close
close:
 li a7, SYS_close
 52c:	48d5                	li	a7,21
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <kill>:
.global kill
kill:
 li a7, SYS_kill
 534:	4899                	li	a7,6
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <exec>:
.global exec
exec:
 li a7, SYS_exec
 53c:	489d                	li	a7,7
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <open>:
.global open
open:
 li a7, SYS_open
 544:	48bd                	li	a7,15
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 54c:	48c5                	li	a7,17
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 554:	48c9                	li	a7,18
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 55c:	48a1                	li	a7,8
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <link>:
.global link
link:
 li a7, SYS_link
 564:	48cd                	li	a7,19
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 56c:	48d1                	li	a7,20
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 574:	48a5                	li	a7,9
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <dup>:
.global dup
dup:
 li a7, SYS_dup
 57c:	48a9                	li	a7,10
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 584:	48ad                	li	a7,11
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 58c:	48b1                	li	a7,12
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <pause>:
.global pause
pause:
 li a7, SYS_pause
 594:	48b5                	li	a7,13
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 59c:	48b9                	li	a7,14
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 5a4:	48d9                	li	a7,22
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 5ac:	48dd                	li	a7,23
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 5b4:	48e1                	li	a7,24
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 5bc:	48e5                	li	a7,25
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 5c4:	48e9                	li	a7,26
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 5cc:	48ed                	li	a7,27
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 5d4:	48f1                	li	a7,28
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 5dc:	48f5                	li	a7,29
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 5e4:	48f9                	li	a7,30
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 5ec:	48fd                	li	a7,31
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f4:	1101                	addi	sp,sp,-32
 5f6:	ec06                	sd	ra,24(sp)
 5f8:	e822                	sd	s0,16(sp)
 5fa:	1000                	addi	s0,sp,32
 5fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 600:	4605                	li	a2,1
 602:	fef40593          	addi	a1,s0,-17
 606:	f1fff0ef          	jal	524 <write>
}
 60a:	60e2                	ld	ra,24(sp)
 60c:	6442                	ld	s0,16(sp)
 60e:	6105                	addi	sp,sp,32
 610:	8082                	ret

0000000000000612 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 612:	715d                	addi	sp,sp,-80
 614:	e486                	sd	ra,72(sp)
 616:	e0a2                	sd	s0,64(sp)
 618:	f84a                	sd	s2,48(sp)
 61a:	0880                	addi	s0,sp,80
 61c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 61e:	c299                	beqz	a3,624 <printint+0x12>
 620:	0805c363          	bltz	a1,6a6 <printint+0x94>
  neg = 0;
 624:	4881                	li	a7,0
 626:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 62a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 62c:	00000517          	auipc	a0,0x0
 630:	7c450513          	addi	a0,a0,1988 # df0 <digits>
 634:	883e                	mv	a6,a5
 636:	2785                	addiw	a5,a5,1
 638:	02c5f733          	remu	a4,a1,a2
 63c:	972a                	add	a4,a4,a0
 63e:	00074703          	lbu	a4,0(a4)
 642:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 646:	872e                	mv	a4,a1
 648:	02c5d5b3          	divu	a1,a1,a2
 64c:	0685                	addi	a3,a3,1
 64e:	fec773e3          	bgeu	a4,a2,634 <printint+0x22>
  if(neg)
 652:	00088b63          	beqz	a7,668 <printint+0x56>
    buf[i++] = '-';
 656:	fd078793          	addi	a5,a5,-48
 65a:	97a2                	add	a5,a5,s0
 65c:	02d00713          	li	a4,45
 660:	fee78423          	sb	a4,-24(a5)
 664:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 668:	02f05a63          	blez	a5,69c <printint+0x8a>
 66c:	fc26                	sd	s1,56(sp)
 66e:	f44e                	sd	s3,40(sp)
 670:	fb840713          	addi	a4,s0,-72
 674:	00f704b3          	add	s1,a4,a5
 678:	fff70993          	addi	s3,a4,-1
 67c:	99be                	add	s3,s3,a5
 67e:	37fd                	addiw	a5,a5,-1
 680:	1782                	slli	a5,a5,0x20
 682:	9381                	srli	a5,a5,0x20
 684:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 688:	fff4c583          	lbu	a1,-1(s1)
 68c:	854a                	mv	a0,s2
 68e:	f67ff0ef          	jal	5f4 <putc>
  while(--i >= 0)
 692:	14fd                	addi	s1,s1,-1
 694:	ff349ae3          	bne	s1,s3,688 <printint+0x76>
 698:	74e2                	ld	s1,56(sp)
 69a:	79a2                	ld	s3,40(sp)
}
 69c:	60a6                	ld	ra,72(sp)
 69e:	6406                	ld	s0,64(sp)
 6a0:	7942                	ld	s2,48(sp)
 6a2:	6161                	addi	sp,sp,80
 6a4:	8082                	ret
    x = -xx;
 6a6:	40b005b3          	neg	a1,a1
    neg = 1;
 6aa:	4885                	li	a7,1
    x = -xx;
 6ac:	bfad                	j	626 <printint+0x14>

00000000000006ae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ae:	711d                	addi	sp,sp,-96
 6b0:	ec86                	sd	ra,88(sp)
 6b2:	e8a2                	sd	s0,80(sp)
 6b4:	e0ca                	sd	s2,64(sp)
 6b6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6b8:	0005c903          	lbu	s2,0(a1)
 6bc:	28090663          	beqz	s2,948 <vprintf+0x29a>
 6c0:	e4a6                	sd	s1,72(sp)
 6c2:	fc4e                	sd	s3,56(sp)
 6c4:	f852                	sd	s4,48(sp)
 6c6:	f456                	sd	s5,40(sp)
 6c8:	f05a                	sd	s6,32(sp)
 6ca:	ec5e                	sd	s7,24(sp)
 6cc:	e862                	sd	s8,16(sp)
 6ce:	e466                	sd	s9,8(sp)
 6d0:	8b2a                	mv	s6,a0
 6d2:	8a2e                	mv	s4,a1
 6d4:	8bb2                	mv	s7,a2
  state = 0;
 6d6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6d8:	4481                	li	s1,0
 6da:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6dc:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6e0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6e4:	06c00c93          	li	s9,108
 6e8:	a005                	j	708 <vprintf+0x5a>
        putc(fd, c0);
 6ea:	85ca                	mv	a1,s2
 6ec:	855a                	mv	a0,s6
 6ee:	f07ff0ef          	jal	5f4 <putc>
 6f2:	a019                	j	6f8 <vprintf+0x4a>
    } else if(state == '%'){
 6f4:	03598263          	beq	s3,s5,718 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6f8:	2485                	addiw	s1,s1,1
 6fa:	8726                	mv	a4,s1
 6fc:	009a07b3          	add	a5,s4,s1
 700:	0007c903          	lbu	s2,0(a5)
 704:	22090a63          	beqz	s2,938 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 708:	0009079b          	sext.w	a5,s2
    if(state == 0){
 70c:	fe0994e3          	bnez	s3,6f4 <vprintf+0x46>
      if(c0 == '%'){
 710:	fd579de3          	bne	a5,s5,6ea <vprintf+0x3c>
        state = '%';
 714:	89be                	mv	s3,a5
 716:	b7cd                	j	6f8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 718:	00ea06b3          	add	a3,s4,a4
 71c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 720:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 722:	c681                	beqz	a3,72a <vprintf+0x7c>
 724:	9752                	add	a4,a4,s4
 726:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 72a:	05878363          	beq	a5,s8,770 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 72e:	05978d63          	beq	a5,s9,788 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 732:	07500713          	li	a4,117
 736:	0ee78763          	beq	a5,a4,824 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 73a:	07800713          	li	a4,120
 73e:	12e78963          	beq	a5,a4,870 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 742:	07000713          	li	a4,112
 746:	14e78e63          	beq	a5,a4,8a2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 74a:	06300713          	li	a4,99
 74e:	18e78e63          	beq	a5,a4,8ea <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 752:	07300713          	li	a4,115
 756:	1ae78463          	beq	a5,a4,8fe <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 75a:	02500713          	li	a4,37
 75e:	04e79563          	bne	a5,a4,7a8 <vprintf+0xfa>
        putc(fd, '%');
 762:	02500593          	li	a1,37
 766:	855a                	mv	a0,s6
 768:	e8dff0ef          	jal	5f4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 76c:	4981                	li	s3,0
 76e:	b769                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 770:	008b8913          	addi	s2,s7,8
 774:	4685                	li	a3,1
 776:	4629                	li	a2,10
 778:	000ba583          	lw	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	e95ff0ef          	jal	612 <printint>
 782:	8bca                	mv	s7,s2
      state = 0;
 784:	4981                	li	s3,0
 786:	bf8d                	j	6f8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 788:	06400793          	li	a5,100
 78c:	02f68963          	beq	a3,a5,7be <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 790:	06c00793          	li	a5,108
 794:	04f68263          	beq	a3,a5,7d8 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 798:	07500793          	li	a5,117
 79c:	0af68063          	beq	a3,a5,83c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 7a0:	07800793          	li	a5,120
 7a4:	0ef68263          	beq	a3,a5,888 <vprintf+0x1da>
        putc(fd, '%');
 7a8:	02500593          	li	a1,37
 7ac:	855a                	mv	a0,s6
 7ae:	e47ff0ef          	jal	5f4 <putc>
        putc(fd, c0);
 7b2:	85ca                	mv	a1,s2
 7b4:	855a                	mv	a0,s6
 7b6:	e3fff0ef          	jal	5f4 <putc>
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bf35                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7be:	008b8913          	addi	s2,s7,8
 7c2:	4685                	li	a3,1
 7c4:	4629                	li	a2,10
 7c6:	000bb583          	ld	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	e47ff0ef          	jal	612 <printint>
        i += 1;
 7d0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
        i += 1;
 7d6:	b70d                	j	6f8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7d8:	06400793          	li	a5,100
 7dc:	02f60763          	beq	a2,a5,80a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7e0:	07500793          	li	a5,117
 7e4:	06f60963          	beq	a2,a5,856 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7e8:	07800793          	li	a5,120
 7ec:	faf61ee3          	bne	a2,a5,7a8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f0:	008b8913          	addi	s2,s7,8
 7f4:	4681                	li	a3,0
 7f6:	4641                	li	a2,16
 7f8:	000bb583          	ld	a1,0(s7)
 7fc:	855a                	mv	a0,s6
 7fe:	e15ff0ef          	jal	612 <printint>
        i += 2;
 802:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
        i += 2;
 808:	bdc5                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4685                	li	a3,1
 810:	4629                	li	a2,10
 812:	000bb583          	ld	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	dfbff0ef          	jal	612 <printint>
        i += 2;
 81c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
        i += 2;
 822:	bdd9                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 824:	008b8913          	addi	s2,s7,8
 828:	4681                	li	a3,0
 82a:	4629                	li	a2,10
 82c:	000be583          	lwu	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	de1ff0ef          	jal	612 <printint>
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
 83a:	bd7d                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 83c:	008b8913          	addi	s2,s7,8
 840:	4681                	li	a3,0
 842:	4629                	li	a2,10
 844:	000bb583          	ld	a1,0(s7)
 848:	855a                	mv	a0,s6
 84a:	dc9ff0ef          	jal	612 <printint>
        i += 1;
 84e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
        i += 1;
 854:	b555                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 856:	008b8913          	addi	s2,s7,8
 85a:	4681                	li	a3,0
 85c:	4629                	li	a2,10
 85e:	000bb583          	ld	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	dafff0ef          	jal	612 <printint>
        i += 2;
 868:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 86a:	8bca                	mv	s7,s2
      state = 0;
 86c:	4981                	li	s3,0
        i += 2;
 86e:	b569                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 870:	008b8913          	addi	s2,s7,8
 874:	4681                	li	a3,0
 876:	4641                	li	a2,16
 878:	000be583          	lwu	a1,0(s7)
 87c:	855a                	mv	a0,s6
 87e:	d95ff0ef          	jal	612 <printint>
 882:	8bca                	mv	s7,s2
      state = 0;
 884:	4981                	li	s3,0
 886:	bd8d                	j	6f8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 888:	008b8913          	addi	s2,s7,8
 88c:	4681                	li	a3,0
 88e:	4641                	li	a2,16
 890:	000bb583          	ld	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	d7dff0ef          	jal	612 <printint>
        i += 1;
 89a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 89c:	8bca                	mv	s7,s2
      state = 0;
 89e:	4981                	li	s3,0
        i += 1;
 8a0:	bda1                	j	6f8 <vprintf+0x4a>
 8a2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8a4:	008b8d13          	addi	s10,s7,8
 8a8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8ac:	03000593          	li	a1,48
 8b0:	855a                	mv	a0,s6
 8b2:	d43ff0ef          	jal	5f4 <putc>
  putc(fd, 'x');
 8b6:	07800593          	li	a1,120
 8ba:	855a                	mv	a0,s6
 8bc:	d39ff0ef          	jal	5f4 <putc>
 8c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8c2:	00000b97          	auipc	s7,0x0
 8c6:	52eb8b93          	addi	s7,s7,1326 # df0 <digits>
 8ca:	03c9d793          	srli	a5,s3,0x3c
 8ce:	97de                	add	a5,a5,s7
 8d0:	0007c583          	lbu	a1,0(a5)
 8d4:	855a                	mv	a0,s6
 8d6:	d1fff0ef          	jal	5f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8da:	0992                	slli	s3,s3,0x4
 8dc:	397d                	addiw	s2,s2,-1
 8de:	fe0916e3          	bnez	s2,8ca <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8e2:	8bea                	mv	s7,s10
      state = 0;
 8e4:	4981                	li	s3,0
 8e6:	6d02                	ld	s10,0(sp)
 8e8:	bd01                	j	6f8 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8ea:	008b8913          	addi	s2,s7,8
 8ee:	000bc583          	lbu	a1,0(s7)
 8f2:	855a                	mv	a0,s6
 8f4:	d01ff0ef          	jal	5f4 <putc>
 8f8:	8bca                	mv	s7,s2
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	bbf5                	j	6f8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8fe:	008b8993          	addi	s3,s7,8
 902:	000bb903          	ld	s2,0(s7)
 906:	00090f63          	beqz	s2,924 <vprintf+0x276>
        for(; *s; s++)
 90a:	00094583          	lbu	a1,0(s2)
 90e:	c195                	beqz	a1,932 <vprintf+0x284>
          putc(fd, *s);
 910:	855a                	mv	a0,s6
 912:	ce3ff0ef          	jal	5f4 <putc>
        for(; *s; s++)
 916:	0905                	addi	s2,s2,1
 918:	00094583          	lbu	a1,0(s2)
 91c:	f9f5                	bnez	a1,910 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 91e:	8bce                	mv	s7,s3
      state = 0;
 920:	4981                	li	s3,0
 922:	bbd9                	j	6f8 <vprintf+0x4a>
          s = "(null)";
 924:	00000917          	auipc	s2,0x0
 928:	4c490913          	addi	s2,s2,1220 # de8 <malloc+0x3b8>
        for(; *s; s++)
 92c:	02800593          	li	a1,40
 930:	b7c5                	j	910 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 932:	8bce                	mv	s7,s3
      state = 0;
 934:	4981                	li	s3,0
 936:	b3c9                	j	6f8 <vprintf+0x4a>
 938:	64a6                	ld	s1,72(sp)
 93a:	79e2                	ld	s3,56(sp)
 93c:	7a42                	ld	s4,48(sp)
 93e:	7aa2                	ld	s5,40(sp)
 940:	7b02                	ld	s6,32(sp)
 942:	6be2                	ld	s7,24(sp)
 944:	6c42                	ld	s8,16(sp)
 946:	6ca2                	ld	s9,8(sp)
    }
  }
}
 948:	60e6                	ld	ra,88(sp)
 94a:	6446                	ld	s0,80(sp)
 94c:	6906                	ld	s2,64(sp)
 94e:	6125                	addi	sp,sp,96
 950:	8082                	ret

0000000000000952 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 952:	715d                	addi	sp,sp,-80
 954:	ec06                	sd	ra,24(sp)
 956:	e822                	sd	s0,16(sp)
 958:	1000                	addi	s0,sp,32
 95a:	e010                	sd	a2,0(s0)
 95c:	e414                	sd	a3,8(s0)
 95e:	e818                	sd	a4,16(s0)
 960:	ec1c                	sd	a5,24(s0)
 962:	03043023          	sd	a6,32(s0)
 966:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 96a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 96e:	8622                	mv	a2,s0
 970:	d3fff0ef          	jal	6ae <vprintf>
}
 974:	60e2                	ld	ra,24(sp)
 976:	6442                	ld	s0,16(sp)
 978:	6161                	addi	sp,sp,80
 97a:	8082                	ret

000000000000097c <printf>:

void
printf(const char *fmt, ...)
{
 97c:	711d                	addi	sp,sp,-96
 97e:	ec06                	sd	ra,24(sp)
 980:	e822                	sd	s0,16(sp)
 982:	1000                	addi	s0,sp,32
 984:	e40c                	sd	a1,8(s0)
 986:	e810                	sd	a2,16(s0)
 988:	ec14                	sd	a3,24(s0)
 98a:	f018                	sd	a4,32(s0)
 98c:	f41c                	sd	a5,40(s0)
 98e:	03043823          	sd	a6,48(s0)
 992:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 996:	00840613          	addi	a2,s0,8
 99a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 99e:	85aa                	mv	a1,a0
 9a0:	4505                	li	a0,1
 9a2:	d0dff0ef          	jal	6ae <vprintf>
}
 9a6:	60e2                	ld	ra,24(sp)
 9a8:	6442                	ld	s0,16(sp)
 9aa:	6125                	addi	sp,sp,96
 9ac:	8082                	ret

00000000000009ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9ae:	1141                	addi	sp,sp,-16
 9b0:	e422                	sd	s0,8(sp)
 9b2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9b4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b8:	00000797          	auipc	a5,0x0
 9bc:	6487b783          	ld	a5,1608(a5) # 1000 <freep>
 9c0:	a02d                	j	9ea <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9c2:	4618                	lw	a4,8(a2)
 9c4:	9f2d                	addw	a4,a4,a1
 9c6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ca:	6398                	ld	a4,0(a5)
 9cc:	6310                	ld	a2,0(a4)
 9ce:	a83d                	j	a0c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9d0:	ff852703          	lw	a4,-8(a0)
 9d4:	9f31                	addw	a4,a4,a2
 9d6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9d8:	ff053683          	ld	a3,-16(a0)
 9dc:	a091                	j	a20 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9de:	6398                	ld	a4,0(a5)
 9e0:	00e7e463          	bltu	a5,a4,9e8 <free+0x3a>
 9e4:	00e6ea63          	bltu	a3,a4,9f8 <free+0x4a>
{
 9e8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ea:	fed7fae3          	bgeu	a5,a3,9de <free+0x30>
 9ee:	6398                	ld	a4,0(a5)
 9f0:	00e6e463          	bltu	a3,a4,9f8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f4:	fee7eae3          	bltu	a5,a4,9e8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9f8:	ff852583          	lw	a1,-8(a0)
 9fc:	6390                	ld	a2,0(a5)
 9fe:	02059813          	slli	a6,a1,0x20
 a02:	01c85713          	srli	a4,a6,0x1c
 a06:	9736                	add	a4,a4,a3
 a08:	fae60de3          	beq	a2,a4,9c2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a0c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a10:	4790                	lw	a2,8(a5)
 a12:	02061593          	slli	a1,a2,0x20
 a16:	01c5d713          	srli	a4,a1,0x1c
 a1a:	973e                	add	a4,a4,a5
 a1c:	fae68ae3          	beq	a3,a4,9d0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a20:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a22:	00000717          	auipc	a4,0x0
 a26:	5cf73f23          	sd	a5,1502(a4) # 1000 <freep>
}
 a2a:	6422                	ld	s0,8(sp)
 a2c:	0141                	addi	sp,sp,16
 a2e:	8082                	ret

0000000000000a30 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a30:	7139                	addi	sp,sp,-64
 a32:	fc06                	sd	ra,56(sp)
 a34:	f822                	sd	s0,48(sp)
 a36:	f426                	sd	s1,40(sp)
 a38:	ec4e                	sd	s3,24(sp)
 a3a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3c:	02051493          	slli	s1,a0,0x20
 a40:	9081                	srli	s1,s1,0x20
 a42:	04bd                	addi	s1,s1,15
 a44:	8091                	srli	s1,s1,0x4
 a46:	0014899b          	addiw	s3,s1,1
 a4a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a4c:	00000517          	auipc	a0,0x0
 a50:	5b453503          	ld	a0,1460(a0) # 1000 <freep>
 a54:	c915                	beqz	a0,a88 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a58:	4798                	lw	a4,8(a5)
 a5a:	08977a63          	bgeu	a4,s1,aee <malloc+0xbe>
 a5e:	f04a                	sd	s2,32(sp)
 a60:	e852                	sd	s4,16(sp)
 a62:	e456                	sd	s5,8(sp)
 a64:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a66:	8a4e                	mv	s4,s3
 a68:	0009871b          	sext.w	a4,s3
 a6c:	6685                	lui	a3,0x1
 a6e:	00d77363          	bgeu	a4,a3,a74 <malloc+0x44>
 a72:	6a05                	lui	s4,0x1
 a74:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a78:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a7c:	00000917          	auipc	s2,0x0
 a80:	58490913          	addi	s2,s2,1412 # 1000 <freep>
  if(p == SBRK_ERROR)
 a84:	5afd                	li	s5,-1
 a86:	a081                	j	ac6 <malloc+0x96>
 a88:	f04a                	sd	s2,32(sp)
 a8a:	e852                	sd	s4,16(sp)
 a8c:	e456                	sd	s5,8(sp)
 a8e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a90:	00000797          	auipc	a5,0x0
 a94:	58078793          	addi	a5,a5,1408 # 1010 <base>
 a98:	00000717          	auipc	a4,0x0
 a9c:	56f73423          	sd	a5,1384(a4) # 1000 <freep>
 aa0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 aa2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aa6:	b7c1                	j	a66 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 aa8:	6398                	ld	a4,0(a5)
 aaa:	e118                	sd	a4,0(a0)
 aac:	a8a9                	j	b06 <malloc+0xd6>
  hp->s.size = nu;
 aae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ab2:	0541                	addi	a0,a0,16
 ab4:	efbff0ef          	jal	9ae <free>
  return freep;
 ab8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 abc:	c12d                	beqz	a0,b1e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 abe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac0:	4798                	lw	a4,8(a5)
 ac2:	02977263          	bgeu	a4,s1,ae6 <malloc+0xb6>
    if(p == freep)
 ac6:	00093703          	ld	a4,0(s2)
 aca:	853e                	mv	a0,a5
 acc:	fef719e3          	bne	a4,a5,abe <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ad0:	8552                	mv	a0,s4
 ad2:	9ffff0ef          	jal	4d0 <sbrk>
  if(p == SBRK_ERROR)
 ad6:	fd551ce3          	bne	a0,s5,aae <malloc+0x7e>
        return 0;
 ada:	4501                	li	a0,0
 adc:	7902                	ld	s2,32(sp)
 ade:	6a42                	ld	s4,16(sp)
 ae0:	6aa2                	ld	s5,8(sp)
 ae2:	6b02                	ld	s6,0(sp)
 ae4:	a03d                	j	b12 <malloc+0xe2>
 ae6:	7902                	ld	s2,32(sp)
 ae8:	6a42                	ld	s4,16(sp)
 aea:	6aa2                	ld	s5,8(sp)
 aec:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aee:	fae48de3          	beq	s1,a4,aa8 <malloc+0x78>
        p->s.size -= nunits;
 af2:	4137073b          	subw	a4,a4,s3
 af6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 af8:	02071693          	slli	a3,a4,0x20
 afc:	01c6d713          	srli	a4,a3,0x1c
 b00:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b02:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b06:	00000717          	auipc	a4,0x0
 b0a:	4ea73d23          	sd	a0,1274(a4) # 1000 <freep>
      return (void*)(p + 1);
 b0e:	01078513          	addi	a0,a5,16
  }
}
 b12:	70e2                	ld	ra,56(sp)
 b14:	7442                	ld	s0,48(sp)
 b16:	74a2                	ld	s1,40(sp)
 b18:	69e2                	ld	s3,24(sp)
 b1a:	6121                	addi	sp,sp,64
 b1c:	8082                	ret
 b1e:	7902                	ld	s2,32(sp)
 b20:	6a42                	ld	s4,16(sp)
 b22:	6aa2                	ld	s5,8(sp)
 b24:	6b02                	ld	s6,0(sp)
 b26:	b7f5                	j	b12 <malloc+0xe2>
