
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	9aa78793          	addi	a5,a5,-1622 # 9c0 <malloc+0x128>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	96450513          	addi	a0,a0,-1692 # 990 <malloc+0xf8>
  34:	7b0000ef          	jal	7e4 <printf>
  memset(data, 'a', sizeof(data));
  38:	20000613          	li	a2,512
  3c:	06100593          	li	a1,97
  40:	dd040513          	addi	a0,s0,-560
  44:	116000ef          	jal	15a <memset>

  for(i = 0; i < 4; i++)
  48:	4481                	li	s1,0
  4a:	4911                	li	s2,4
    if(fork() > 0)
  4c:	318000ef          	jal	364 <fork>
  50:	00a04563          	bgtz	a0,5a <main+0x5a>
  for(i = 0; i < 4; i++)
  54:	2485                	addiw	s1,s1,1
  56:	ff249be3          	bne	s1,s2,4c <main+0x4c>
      break;

  printf("write %d\n", i);
  5a:	85a6                	mv	a1,s1
  5c:	00001517          	auipc	a0,0x1
  60:	94c50513          	addi	a0,a0,-1716 # 9a8 <malloc+0x110>
  64:	780000ef          	jal	7e4 <printf>

  path[8] += i;
  68:	fd844783          	lbu	a5,-40(s0)
  6c:	9fa5                	addw	a5,a5,s1
  6e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  72:	20200593          	li	a1,514
  76:	fd040513          	addi	a0,s0,-48
  7a:	332000ef          	jal	3ac <open>
  7e:	892a                	mv	s2,a0
  80:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  82:	20000613          	li	a2,512
  86:	dd040593          	addi	a1,s0,-560
  8a:	854a                	mv	a0,s2
  8c:	300000ef          	jal	38c <write>
  for(i = 0; i < 20; i++)
  90:	34fd                	addiw	s1,s1,-1
  92:	f8e5                	bnez	s1,82 <main+0x82>
  close(fd);
  94:	854a                	mv	a0,s2
  96:	2fe000ef          	jal	394 <close>

  printf("read\n");
  9a:	00001517          	auipc	a0,0x1
  9e:	91e50513          	addi	a0,a0,-1762 # 9b8 <malloc+0x120>
  a2:	742000ef          	jal	7e4 <printf>

  fd = open(path, O_RDONLY);
  a6:	4581                	li	a1,0
  a8:	fd040513          	addi	a0,s0,-48
  ac:	300000ef          	jal	3ac <open>
  b0:	892a                	mv	s2,a0
  b2:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  b4:	20000613          	li	a2,512
  b8:	dd040593          	addi	a1,s0,-560
  bc:	854a                	mv	a0,s2
  be:	2c6000ef          	jal	384 <read>
  for (i = 0; i < 20; i++)
  c2:	34fd                	addiw	s1,s1,-1
  c4:	f8e5                	bnez	s1,b4 <main+0xb4>
  close(fd);
  c6:	854a                	mv	a0,s2
  c8:	2cc000ef          	jal	394 <close>

  wait(0);
  cc:	4501                	li	a0,0
  ce:	2a6000ef          	jal	374 <wait>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	298000ef          	jal	36c <exit>

00000000000000d8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e0:	f21ff0ef          	jal	0 <main>
  exit(r);
  e4:	288000ef          	jal	36c <exit>

00000000000000e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ee:	87aa                	mv	a5,a0
  f0:	0585                	addi	a1,a1,1
  f2:	0785                	addi	a5,a5,1
  f4:	fff5c703          	lbu	a4,-1(a1)
  f8:	fee78fa3          	sb	a4,-1(a5)
  fc:	fb75                	bnez	a4,f0 <strcpy+0x8>
    ;
  return os;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	addi	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cb91                	beqz	a5,122 <strcmp+0x1e>
 110:	0005c703          	lbu	a4,0(a1)
 114:	00f71763          	bne	a4,a5,122 <strcmp+0x1e>
    p++, q++;
 118:	0505                	addi	a0,a0,1
 11a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbe5                	bnez	a5,110 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 122:	0005c503          	lbu	a0,0(a1)
}
 126:	40a7853b          	subw	a0,a5,a0
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:

uint
strlen(const char *s)
{
 130:	1141                	addi	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf91                	beqz	a5,156 <strlen+0x26>
 13c:	0505                	addi	a0,a0,1
 13e:	87aa                	mv	a5,a0
 140:	86be                	mv	a3,a5
 142:	0785                	addi	a5,a5,1
 144:	fff7c703          	lbu	a4,-1(a5)
 148:	ff65                	bnez	a4,140 <strlen+0x10>
 14a:	40a6853b          	subw	a0,a3,a0
 14e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  for(n = 0; s[n]; n++)
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strlen+0x20>

000000000000015a <memset>:

void*
memset(void *dst, int c, uint n)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 160:	ca19                	beqz	a2,176 <memset+0x1c>
 162:	87aa                	mv	a5,a0
 164:	1602                	slli	a2,a2,0x20
 166:	9201                	srli	a2,a2,0x20
 168:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	addi	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x12>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	addi	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	addi	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	addi	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addiw	s1,s1,1
 1c6:	0344d663          	bge	s1,s4,1f2 <gets+0x52>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	addi	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	1b2000ef          	jal	384 <read>
    if(cc < 1)
 1d6:	00a05e63          	blez	a0,1f2 <gets+0x52>
    buf[i++] = c;
 1da:	faf44783          	lbu	a5,-81(s0)
 1de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e2:	01578763          	beq	a5,s5,1f0 <gets+0x50>
 1e6:	0905                	addi	s2,s2,1
 1e8:	fd679de3          	bne	a5,s6,1c2 <gets+0x22>
    buf[i++] = c;
 1ec:	89a6                	mv	s3,s1
 1ee:	a011                	j	1f2 <gets+0x52>
 1f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f2:	99de                	add	s3,s3,s7
 1f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f8:	855e                	mv	a0,s7
 1fa:	60e6                	ld	ra,88(sp)
 1fc:	6446                	ld	s0,80(sp)
 1fe:	64a6                	ld	s1,72(sp)
 200:	6906                	ld	s2,64(sp)
 202:	79e2                	ld	s3,56(sp)
 204:	7a42                	ld	s4,48(sp)
 206:	7aa2                	ld	s5,40(sp)
 208:	7b02                	ld	s6,32(sp)
 20a:	6be2                	ld	s7,24(sp)
 20c:	6125                	addi	sp,sp,96
 20e:	8082                	ret

0000000000000210 <stat>:

int
stat(const char *n, struct stat *st)
{
 210:	1101                	addi	sp,sp,-32
 212:	ec06                	sd	ra,24(sp)
 214:	e822                	sd	s0,16(sp)
 216:	e04a                	sd	s2,0(sp)
 218:	1000                	addi	s0,sp,32
 21a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21c:	4581                	li	a1,0
 21e:	18e000ef          	jal	3ac <open>
  if(fd < 0)
 222:	02054263          	bltz	a0,246 <stat+0x36>
 226:	e426                	sd	s1,8(sp)
 228:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22a:	85ca                	mv	a1,s2
 22c:	198000ef          	jal	3c4 <fstat>
 230:	892a                	mv	s2,a0
  close(fd);
 232:	8526                	mv	a0,s1
 234:	160000ef          	jal	394 <close>
  return r;
 238:	64a2                	ld	s1,8(sp)
}
 23a:	854a                	mv	a0,s2
 23c:	60e2                	ld	ra,24(sp)
 23e:	6442                	ld	s0,16(sp)
 240:	6902                	ld	s2,0(sp)
 242:	6105                	addi	sp,sp,32
 244:	8082                	ret
    return -1;
 246:	597d                	li	s2,-1
 248:	bfcd                	j	23a <stat+0x2a>

000000000000024a <atoi>:

int
atoi(const char *s)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 250:	00054683          	lbu	a3,0(a0)
 254:	fd06879b          	addiw	a5,a3,-48
 258:	0ff7f793          	zext.b	a5,a5
 25c:	4625                	li	a2,9
 25e:	02f66863          	bltu	a2,a5,28e <atoi+0x44>
 262:	872a                	mv	a4,a0
  n = 0;
 264:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 266:	0705                	addi	a4,a4,1
 268:	0025179b          	slliw	a5,a0,0x2
 26c:	9fa9                	addw	a5,a5,a0
 26e:	0017979b          	slliw	a5,a5,0x1
 272:	9fb5                	addw	a5,a5,a3
 274:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 278:	00074683          	lbu	a3,0(a4)
 27c:	fd06879b          	addiw	a5,a3,-48
 280:	0ff7f793          	zext.b	a5,a5
 284:	fef671e3          	bgeu	a2,a5,266 <atoi+0x1c>
  return n;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  n = 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <atoi+0x3e>

0000000000000292 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 298:	02b57463          	bgeu	a0,a1,2c0 <memmove+0x2e>
    while(n-- > 0)
 29c:	00c05f63          	blez	a2,2ba <memmove+0x28>
 2a0:	1602                	slli	a2,a2,0x20
 2a2:	9201                	srli	a2,a2,0x20
 2a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2aa:	0585                	addi	a1,a1,1
 2ac:	0705                	addi	a4,a4,1
 2ae:	fff5c683          	lbu	a3,-1(a1)
 2b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b6:	fef71ae3          	bne	a4,a5,2aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
    dst += n;
 2c0:	00c50733          	add	a4,a0,a2
    src += n;
 2c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c6:	fec05ae3          	blez	a2,2ba <memmove+0x28>
 2ca:	fff6079b          	addiw	a5,a2,-1
 2ce:	1782                	slli	a5,a5,0x20
 2d0:	9381                	srli	a5,a5,0x20
 2d2:	fff7c793          	not	a5,a5
 2d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d8:	15fd                	addi	a1,a1,-1
 2da:	177d                	addi	a4,a4,-1
 2dc:	0005c683          	lbu	a3,0(a1)
 2e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e4:	fee79ae3          	bne	a5,a4,2d8 <memmove+0x46>
 2e8:	bfc9                	j	2ba <memmove+0x28>

00000000000002ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f0:	ca05                	beqz	a2,320 <memcmp+0x36>
 2f2:	fff6069b          	addiw	a3,a2,-1
 2f6:	1682                	slli	a3,a3,0x20
 2f8:	9281                	srli	a3,a3,0x20
 2fa:	0685                	addi	a3,a3,1
 2fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fe:	00054783          	lbu	a5,0(a0)
 302:	0005c703          	lbu	a4,0(a1)
 306:	00e79863          	bne	a5,a4,316 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30a:	0505                	addi	a0,a0,1
    p2++;
 30c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30e:	fed518e3          	bne	a0,a3,2fe <memcmp+0x14>
  }
  return 0;
 312:	4501                	li	a0,0
 314:	a019                	j	31a <memcmp+0x30>
      return *p1 - *p2;
 316:	40e7853b          	subw	a0,a5,a4
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  return 0;
 320:	4501                	li	a0,0
 322:	bfe5                	j	31a <memcmp+0x30>

0000000000000324 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32c:	f67ff0ef          	jal	292 <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <sbrk>:

char *
sbrk(int n) {
 338:	1141                	addi	sp,sp,-16
 33a:	e406                	sd	ra,8(sp)
 33c:	e022                	sd	s0,0(sp)
 33e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 340:	4585                	li	a1,1
 342:	0b2000ef          	jal	3f4 <sys_sbrk>
}
 346:	60a2                	ld	ra,8(sp)
 348:	6402                	ld	s0,0(sp)
 34a:	0141                	addi	sp,sp,16
 34c:	8082                	ret

000000000000034e <sbrklazy>:

char *
sbrklazy(int n) {
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 356:	4589                	li	a1,2
 358:	09c000ef          	jal	3f4 <sys_sbrk>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 364:	4885                	li	a7,1
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <exit>:
.global exit
exit:
 li a7, SYS_exit
 36c:	4889                	li	a7,2
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <wait>:
.global wait
wait:
 li a7, SYS_wait
 374:	488d                	li	a7,3
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37c:	4891                	li	a7,4
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <read>:
.global read
read:
 li a7, SYS_read
 384:	4895                	li	a7,5
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <write>:
.global write
write:
 li a7, SYS_write
 38c:	48c1                	li	a7,16
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <close>:
.global close
close:
 li a7, SYS_close
 394:	48d5                	li	a7,21
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <kill>:
.global kill
kill:
 li a7, SYS_kill
 39c:	4899                	li	a7,6
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a4:	489d                	li	a7,7
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <open>:
.global open
open:
 li a7, SYS_open
 3ac:	48bd                	li	a7,15
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b4:	48c5                	li	a7,17
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3bc:	48c9                	li	a7,18
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c4:	48a1                	li	a7,8
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <link>:
.global link
link:
 li a7, SYS_link
 3cc:	48cd                	li	a7,19
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d4:	48d1                	li	a7,20
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3dc:	48a5                	li	a7,9
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e4:	48a9                	li	a7,10
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ec:	48ad                	li	a7,11
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3f4:	48b1                	li	a7,12
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <pause>:
.global pause
pause:
 li a7, SYS_pause
 3fc:	48b5                	li	a7,13
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 404:	48b9                	li	a7,14
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 40c:	48d9                	li	a7,22
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 414:	48dd                	li	a7,23
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 41c:	48e1                	li	a7,24
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 424:	48e5                	li	a7,25
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 42c:	48e9                	li	a7,26
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 434:	48ed                	li	a7,27
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 43c:	48f1                	li	a7,28
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 444:	48f5                	li	a7,29
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 44c:	48f9                	li	a7,30
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 454:	48fd                	li	a7,31
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45c:	1101                	addi	sp,sp,-32
 45e:	ec06                	sd	ra,24(sp)
 460:	e822                	sd	s0,16(sp)
 462:	1000                	addi	s0,sp,32
 464:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 468:	4605                	li	a2,1
 46a:	fef40593          	addi	a1,s0,-17
 46e:	f1fff0ef          	jal	38c <write>
}
 472:	60e2                	ld	ra,24(sp)
 474:	6442                	ld	s0,16(sp)
 476:	6105                	addi	sp,sp,32
 478:	8082                	ret

000000000000047a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 47a:	715d                	addi	sp,sp,-80
 47c:	e486                	sd	ra,72(sp)
 47e:	e0a2                	sd	s0,64(sp)
 480:	f84a                	sd	s2,48(sp)
 482:	0880                	addi	s0,sp,80
 484:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 486:	c299                	beqz	a3,48c <printint+0x12>
 488:	0805c363          	bltz	a1,50e <printint+0x94>
  neg = 0;
 48c:	4881                	li	a7,0
 48e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 492:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 494:	00000517          	auipc	a0,0x0
 498:	54450513          	addi	a0,a0,1348 # 9d8 <digits>
 49c:	883e                	mv	a6,a5
 49e:	2785                	addiw	a5,a5,1
 4a0:	02c5f733          	remu	a4,a1,a2
 4a4:	972a                	add	a4,a4,a0
 4a6:	00074703          	lbu	a4,0(a4)
 4aa:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ae:	872e                	mv	a4,a1
 4b0:	02c5d5b3          	divu	a1,a1,a2
 4b4:	0685                	addi	a3,a3,1
 4b6:	fec773e3          	bgeu	a4,a2,49c <printint+0x22>
  if(neg)
 4ba:	00088b63          	beqz	a7,4d0 <printint+0x56>
    buf[i++] = '-';
 4be:	fd078793          	addi	a5,a5,-48
 4c2:	97a2                	add	a5,a5,s0
 4c4:	02d00713          	li	a4,45
 4c8:	fee78423          	sb	a4,-24(a5)
 4cc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4d0:	02f05a63          	blez	a5,504 <printint+0x8a>
 4d4:	fc26                	sd	s1,56(sp)
 4d6:	f44e                	sd	s3,40(sp)
 4d8:	fb840713          	addi	a4,s0,-72
 4dc:	00f704b3          	add	s1,a4,a5
 4e0:	fff70993          	addi	s3,a4,-1
 4e4:	99be                	add	s3,s3,a5
 4e6:	37fd                	addiw	a5,a5,-1
 4e8:	1782                	slli	a5,a5,0x20
 4ea:	9381                	srli	a5,a5,0x20
 4ec:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4f0:	fff4c583          	lbu	a1,-1(s1)
 4f4:	854a                	mv	a0,s2
 4f6:	f67ff0ef          	jal	45c <putc>
  while(--i >= 0)
 4fa:	14fd                	addi	s1,s1,-1
 4fc:	ff349ae3          	bne	s1,s3,4f0 <printint+0x76>
 500:	74e2                	ld	s1,56(sp)
 502:	79a2                	ld	s3,40(sp)
}
 504:	60a6                	ld	ra,72(sp)
 506:	6406                	ld	s0,64(sp)
 508:	7942                	ld	s2,48(sp)
 50a:	6161                	addi	sp,sp,80
 50c:	8082                	ret
    x = -xx;
 50e:	40b005b3          	neg	a1,a1
    neg = 1;
 512:	4885                	li	a7,1
    x = -xx;
 514:	bfad                	j	48e <printint+0x14>

0000000000000516 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 516:	711d                	addi	sp,sp,-96
 518:	ec86                	sd	ra,88(sp)
 51a:	e8a2                	sd	s0,80(sp)
 51c:	e0ca                	sd	s2,64(sp)
 51e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 520:	0005c903          	lbu	s2,0(a1)
 524:	28090663          	beqz	s2,7b0 <vprintf+0x29a>
 528:	e4a6                	sd	s1,72(sp)
 52a:	fc4e                	sd	s3,56(sp)
 52c:	f852                	sd	s4,48(sp)
 52e:	f456                	sd	s5,40(sp)
 530:	f05a                	sd	s6,32(sp)
 532:	ec5e                	sd	s7,24(sp)
 534:	e862                	sd	s8,16(sp)
 536:	e466                	sd	s9,8(sp)
 538:	8b2a                	mv	s6,a0
 53a:	8a2e                	mv	s4,a1
 53c:	8bb2                	mv	s7,a2
  state = 0;
 53e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 540:	4481                	li	s1,0
 542:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 544:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 548:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54c:	06c00c93          	li	s9,108
 550:	a005                	j	570 <vprintf+0x5a>
        putc(fd, c0);
 552:	85ca                	mv	a1,s2
 554:	855a                	mv	a0,s6
 556:	f07ff0ef          	jal	45c <putc>
 55a:	a019                	j	560 <vprintf+0x4a>
    } else if(state == '%'){
 55c:	03598263          	beq	s3,s5,580 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 560:	2485                	addiw	s1,s1,1
 562:	8726                	mv	a4,s1
 564:	009a07b3          	add	a5,s4,s1
 568:	0007c903          	lbu	s2,0(a5)
 56c:	22090a63          	beqz	s2,7a0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 570:	0009079b          	sext.w	a5,s2
    if(state == 0){
 574:	fe0994e3          	bnez	s3,55c <vprintf+0x46>
      if(c0 == '%'){
 578:	fd579de3          	bne	a5,s5,552 <vprintf+0x3c>
        state = '%';
 57c:	89be                	mv	s3,a5
 57e:	b7cd                	j	560 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 580:	00ea06b3          	add	a3,s4,a4
 584:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 588:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 58a:	c681                	beqz	a3,592 <vprintf+0x7c>
 58c:	9752                	add	a4,a4,s4
 58e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 592:	05878363          	beq	a5,s8,5d8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 596:	05978d63          	beq	a5,s9,5f0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 59a:	07500713          	li	a4,117
 59e:	0ee78763          	beq	a5,a4,68c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a2:	07800713          	li	a4,120
 5a6:	12e78963          	beq	a5,a4,6d8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5aa:	07000713          	li	a4,112
 5ae:	14e78e63          	beq	a5,a4,70a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b2:	06300713          	li	a4,99
 5b6:	18e78e63          	beq	a5,a4,752 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5ba:	07300713          	li	a4,115
 5be:	1ae78463          	beq	a5,a4,766 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c2:	02500713          	li	a4,37
 5c6:	04e79563          	bne	a5,a4,610 <vprintf+0xfa>
        putc(fd, '%');
 5ca:	02500593          	li	a1,37
 5ce:	855a                	mv	a0,s6
 5d0:	e8dff0ef          	jal	45c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b769                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d8:	008b8913          	addi	s2,s7,8
 5dc:	4685                	li	a3,1
 5de:	4629                	li	a2,10
 5e0:	000ba583          	lw	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e95ff0ef          	jal	47a <printint>
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bf8d                	j	560 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5f0:	06400793          	li	a5,100
 5f4:	02f68963          	beq	a3,a5,626 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f8:	06c00793          	li	a5,108
 5fc:	04f68263          	beq	a3,a5,640 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 600:	07500793          	li	a5,117
 604:	0af68063          	beq	a3,a5,6a4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 608:	07800793          	li	a5,120
 60c:	0ef68263          	beq	a3,a5,6f0 <vprintf+0x1da>
        putc(fd, '%');
 610:	02500593          	li	a1,37
 614:	855a                	mv	a0,s6
 616:	e47ff0ef          	jal	45c <putc>
        putc(fd, c0);
 61a:	85ca                	mv	a1,s2
 61c:	855a                	mv	a0,s6
 61e:	e3fff0ef          	jal	45c <putc>
      state = 0;
 622:	4981                	li	s3,0
 624:	bf35                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	008b8913          	addi	s2,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e47ff0ef          	jal	47a <printint>
        i += 1;
 638:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
        i += 1;
 63e:	b70d                	j	560 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 640:	06400793          	li	a5,100
 644:	02f60763          	beq	a2,a5,672 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 648:	07500793          	li	a5,117
 64c:	06f60963          	beq	a2,a5,6be <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 650:	07800793          	li	a5,120
 654:	faf61ee3          	bne	a2,a5,610 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	008b8913          	addi	s2,s7,8
 65c:	4681                	li	a3,0
 65e:	4641                	li	a2,16
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e15ff0ef          	jal	47a <printint>
        i += 2;
 66a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 2;
 670:	bdc5                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	008b8913          	addi	s2,s7,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	dfbff0ef          	jal	47a <printint>
        i += 2;
 684:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	bdd9                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000be583          	lwu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	de1ff0ef          	jal	47a <printint>
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd7d                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	dc9ff0ef          	jal	47a <printint>
        i += 1;
 6b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 1;
 6bc:	b555                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	dafff0ef          	jal	47a <printint>
        i += 2;
 6d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	b569                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000be583          	lwu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	d95ff0ef          	jal	47a <printint>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bd8d                	j	560 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000bb583          	ld	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	d7dff0ef          	jal	47a <printint>
        i += 1;
 702:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 1;
 708:	bda1                	j	560 <vprintf+0x4a>
 70a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 70c:	008b8d13          	addi	s10,s7,8
 710:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 714:	03000593          	li	a1,48
 718:	855a                	mv	a0,s6
 71a:	d43ff0ef          	jal	45c <putc>
  putc(fd, 'x');
 71e:	07800593          	li	a1,120
 722:	855a                	mv	a0,s6
 724:	d39ff0ef          	jal	45c <putc>
 728:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72a:	00000b97          	auipc	s7,0x0
 72e:	2aeb8b93          	addi	s7,s7,686 # 9d8 <digits>
 732:	03c9d793          	srli	a5,s3,0x3c
 736:	97de                	add	a5,a5,s7
 738:	0007c583          	lbu	a1,0(a5)
 73c:	855a                	mv	a0,s6
 73e:	d1fff0ef          	jal	45c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 742:	0992                	slli	s3,s3,0x4
 744:	397d                	addiw	s2,s2,-1
 746:	fe0916e3          	bnez	s2,732 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 74a:	8bea                	mv	s7,s10
      state = 0;
 74c:	4981                	li	s3,0
 74e:	6d02                	ld	s10,0(sp)
 750:	bd01                	j	560 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 752:	008b8913          	addi	s2,s7,8
 756:	000bc583          	lbu	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	d01ff0ef          	jal	45c <putc>
 760:	8bca                	mv	s7,s2
      state = 0;
 762:	4981                	li	s3,0
 764:	bbf5                	j	560 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 766:	008b8993          	addi	s3,s7,8
 76a:	000bb903          	ld	s2,0(s7)
 76e:	00090f63          	beqz	s2,78c <vprintf+0x276>
        for(; *s; s++)
 772:	00094583          	lbu	a1,0(s2)
 776:	c195                	beqz	a1,79a <vprintf+0x284>
          putc(fd, *s);
 778:	855a                	mv	a0,s6
 77a:	ce3ff0ef          	jal	45c <putc>
        for(; *s; s++)
 77e:	0905                	addi	s2,s2,1
 780:	00094583          	lbu	a1,0(s2)
 784:	f9f5                	bnez	a1,778 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 786:	8bce                	mv	s7,s3
      state = 0;
 788:	4981                	li	s3,0
 78a:	bbd9                	j	560 <vprintf+0x4a>
          s = "(null)";
 78c:	00000917          	auipc	s2,0x0
 790:	24490913          	addi	s2,s2,580 # 9d0 <malloc+0x138>
        for(; *s; s++)
 794:	02800593          	li	a1,40
 798:	b7c5                	j	778 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 79a:	8bce                	mv	s7,s3
      state = 0;
 79c:	4981                	li	s3,0
 79e:	b3c9                	j	560 <vprintf+0x4a>
 7a0:	64a6                	ld	s1,72(sp)
 7a2:	79e2                	ld	s3,56(sp)
 7a4:	7a42                	ld	s4,48(sp)
 7a6:	7aa2                	ld	s5,40(sp)
 7a8:	7b02                	ld	s6,32(sp)
 7aa:	6be2                	ld	s7,24(sp)
 7ac:	6c42                	ld	s8,16(sp)
 7ae:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7b0:	60e6                	ld	ra,88(sp)
 7b2:	6446                	ld	s0,80(sp)
 7b4:	6906                	ld	s2,64(sp)
 7b6:	6125                	addi	sp,sp,96
 7b8:	8082                	ret

00000000000007ba <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ba:	715d                	addi	sp,sp,-80
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e010                	sd	a2,0(s0)
 7c4:	e414                	sd	a3,8(s0)
 7c6:	e818                	sd	a4,16(s0)
 7c8:	ec1c                	sd	a5,24(s0)
 7ca:	03043023          	sd	a6,32(s0)
 7ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d6:	8622                	mv	a2,s0
 7d8:	d3fff0ef          	jal	516 <vprintf>
}
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	6161                	addi	sp,sp,80
 7e2:	8082                	ret

00000000000007e4 <printf>:

void
printf(const char *fmt, ...)
{
 7e4:	711d                	addi	sp,sp,-96
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	1000                	addi	s0,sp,32
 7ec:	e40c                	sd	a1,8(s0)
 7ee:	e810                	sd	a2,16(s0)
 7f0:	ec14                	sd	a3,24(s0)
 7f2:	f018                	sd	a4,32(s0)
 7f4:	f41c                	sd	a5,40(s0)
 7f6:	03043823          	sd	a6,48(s0)
 7fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	00840613          	addi	a2,s0,8
 802:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 806:	85aa                	mv	a1,a0
 808:	4505                	li	a0,1
 80a:	d0dff0ef          	jal	516 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	7e07b783          	ld	a5,2016(a5) # 1000 <freep>
 828:	a02d                	j	852 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9f2d                	addw	a4,a4,a1
 82e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6310                	ld	a2,0(a4)
 836:	a83d                	j	874 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9f31                	addw	a4,a4,a2
 83e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053683          	ld	a3,-16(a0)
 844:	a091                	j	888 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	6398                	ld	a4,0(a5)
 848:	00e7e463          	bltu	a5,a4,850 <free+0x3a>
 84c:	00e6ea63          	bltu	a3,a4,860 <free+0x4a>
{
 850:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 852:	fed7fae3          	bgeu	a5,a3,846 <free+0x30>
 856:	6398                	ld	a4,0(a5)
 858:	00e6e463          	bltu	a3,a4,860 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85c:	fee7eae3          	bltu	a5,a4,850 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 860:	ff852583          	lw	a1,-8(a0)
 864:	6390                	ld	a2,0(a5)
 866:	02059813          	slli	a6,a1,0x20
 86a:	01c85713          	srli	a4,a6,0x1c
 86e:	9736                	add	a4,a4,a3
 870:	fae60de3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 878:	4790                	lw	a2,8(a5)
 87a:	02061593          	slli	a1,a2,0x20
 87e:	01c5d713          	srli	a4,a1,0x1c
 882:	973e                	add	a4,a4,a5
 884:	fae68ae3          	beq	a3,a4,838 <free+0x22>
    p->s.ptr = bp->s.ptr;
 888:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 88a:	00000717          	auipc	a4,0x0
 88e:	76f73b23          	sd	a5,1910(a4) # 1000 <freep>
}
 892:	6422                	ld	s0,8(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret

0000000000000898 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 898:	7139                	addi	sp,sp,-64
 89a:	fc06                	sd	ra,56(sp)
 89c:	f822                	sd	s0,48(sp)
 89e:	f426                	sd	s1,40(sp)
 8a0:	ec4e                	sd	s3,24(sp)
 8a2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a4:	02051493          	slli	s1,a0,0x20
 8a8:	9081                	srli	s1,s1,0x20
 8aa:	04bd                	addi	s1,s1,15
 8ac:	8091                	srli	s1,s1,0x4
 8ae:	0014899b          	addiw	s3,s1,1
 8b2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b4:	00000517          	auipc	a0,0x0
 8b8:	74c53503          	ld	a0,1868(a0) # 1000 <freep>
 8bc:	c915                	beqz	a0,8f0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c0:	4798                	lw	a4,8(a5)
 8c2:	08977a63          	bgeu	a4,s1,956 <malloc+0xbe>
 8c6:	f04a                	sd	s2,32(sp)
 8c8:	e852                	sd	s4,16(sp)
 8ca:	e456                	sd	s5,8(sp)
 8cc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ce:	8a4e                	mv	s4,s3
 8d0:	0009871b          	sext.w	a4,s3
 8d4:	6685                	lui	a3,0x1
 8d6:	00d77363          	bgeu	a4,a3,8dc <malloc+0x44>
 8da:	6a05                	lui	s4,0x1
 8dc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e4:	00000917          	auipc	s2,0x0
 8e8:	71c90913          	addi	s2,s2,1820 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ec:	5afd                	li	s5,-1
 8ee:	a081                	j	92e <malloc+0x96>
 8f0:	f04a                	sd	s2,32(sp)
 8f2:	e852                	sd	s4,16(sp)
 8f4:	e456                	sd	s5,8(sp)
 8f6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8f8:	00000797          	auipc	a5,0x0
 8fc:	71878793          	addi	a5,a5,1816 # 1010 <base>
 900:	00000717          	auipc	a4,0x0
 904:	70f73023          	sd	a5,1792(a4) # 1000 <freep>
 908:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 90e:	b7c1                	j	8ce <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 910:	6398                	ld	a4,0(a5)
 912:	e118                	sd	a4,0(a0)
 914:	a8a9                	j	96e <malloc+0xd6>
  hp->s.size = nu;
 916:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 91a:	0541                	addi	a0,a0,16
 91c:	efbff0ef          	jal	816 <free>
  return freep;
 920:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 924:	c12d                	beqz	a0,986 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	02977263          	bgeu	a4,s1,94e <malloc+0xb6>
    if(p == freep)
 92e:	00093703          	ld	a4,0(s2)
 932:	853e                	mv	a0,a5
 934:	fef719e3          	bne	a4,a5,926 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 938:	8552                	mv	a0,s4
 93a:	9ffff0ef          	jal	338 <sbrk>
  if(p == SBRK_ERROR)
 93e:	fd551ce3          	bne	a0,s5,916 <malloc+0x7e>
        return 0;
 942:	4501                	li	a0,0
 944:	7902                	ld	s2,32(sp)
 946:	6a42                	ld	s4,16(sp)
 948:	6aa2                	ld	s5,8(sp)
 94a:	6b02                	ld	s6,0(sp)
 94c:	a03d                	j	97a <malloc+0xe2>
 94e:	7902                	ld	s2,32(sp)
 950:	6a42                	ld	s4,16(sp)
 952:	6aa2                	ld	s5,8(sp)
 954:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 956:	fae48de3          	beq	s1,a4,910 <malloc+0x78>
        p->s.size -= nunits;
 95a:	4137073b          	subw	a4,a4,s3
 95e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 960:	02071693          	slli	a3,a4,0x20
 964:	01c6d713          	srli	a4,a3,0x1c
 968:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 96a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96e:	00000717          	auipc	a4,0x0
 972:	68a73923          	sd	a0,1682(a4) # 1000 <freep>
      return (void*)(p + 1);
 976:	01078513          	addi	a0,a5,16
  }
}
 97a:	70e2                	ld	ra,56(sp)
 97c:	7442                	ld	s0,48(sp)
 97e:	74a2                	ld	s1,40(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6121                	addi	sp,sp,64
 984:	8082                	ret
 986:	7902                	ld	s2,32(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
 98e:	b7f5                	j	97a <malloc+0xe2>
