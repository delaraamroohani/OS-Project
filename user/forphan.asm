
user/_forphan:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char buf[BUFSZ];

int
main(int argc, char **argv)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  int fd = 0;
  char *s = argv[0];
   a:	6184                	ld	s1,0(a1)
  struct stat st;
  char *ff = "file0";
  
  if ((fd = open(ff, O_CREATE|O_WRONLY)) < 0) {
   c:	20100593          	li	a1,513
  10:	00001517          	auipc	a0,0x1
  14:	97050513          	addi	a0,a0,-1680 # 980 <malloc+0xfc>
  18:	380000ef          	jal	398 <open>
  1c:	04054463          	bltz	a0,64 <main+0x64>
    printf("%s: open failed\n", s);
    exit(1);
  }
  if(fstat(fd, &st) < 0){
  20:	fc840593          	addi	a1,s0,-56
  24:	38c000ef          	jal	3b0 <fstat>
  28:	04054863          	bltz	a0,78 <main+0x78>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
    exit(1);
  }
  if (unlink(ff) < 0) {
  2c:	00001517          	auipc	a0,0x1
  30:	95450513          	addi	a0,a0,-1708 # 980 <malloc+0xfc>
  34:	374000ef          	jal	3a8 <unlink>
  38:	04054f63          	bltz	a0,96 <main+0x96>
    printf("%s: unlink failed\n", s);
    exit(1);
  }
  if (open(ff, O_RDONLY) != -1) {
  3c:	4581                	li	a1,0
  3e:	00001517          	auipc	a0,0x1
  42:	94250513          	addi	a0,a0,-1726 # 980 <malloc+0xfc>
  46:	352000ef          	jal	398 <open>
  4a:	57fd                	li	a5,-1
  4c:	04f50f63          	beq	a0,a5,aa <main+0xaa>
    printf("%s: open successed\n", s);
  50:	85a6                	mv	a1,s1
  52:	00001517          	auipc	a0,0x1
  56:	98e50513          	addi	a0,a0,-1650 # 9e0 <malloc+0x15c>
  5a:	776000ef          	jal	7d0 <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	2f8000ef          	jal	358 <exit>
    printf("%s: open failed\n", s);
  64:	85a6                	mv	a1,s1
  66:	00001517          	auipc	a0,0x1
  6a:	92a50513          	addi	a0,a0,-1750 # 990 <malloc+0x10c>
  6e:	762000ef          	jal	7d0 <printf>
    exit(1);
  72:	4505                	li	a0,1
  74:	2e4000ef          	jal	358 <exit>
    fprintf(2, "%s: cannot stat %s\n", s, "ff");
  78:	00001697          	auipc	a3,0x1
  7c:	93068693          	addi	a3,a3,-1744 # 9a8 <malloc+0x124>
  80:	8626                	mv	a2,s1
  82:	00001597          	auipc	a1,0x1
  86:	92e58593          	addi	a1,a1,-1746 # 9b0 <malloc+0x12c>
  8a:	4509                	li	a0,2
  8c:	71a000ef          	jal	7a6 <fprintf>
    exit(1);
  90:	4505                	li	a0,1
  92:	2c6000ef          	jal	358 <exit>
    printf("%s: unlink failed\n", s);
  96:	85a6                	mv	a1,s1
  98:	00001517          	auipc	a0,0x1
  9c:	93050513          	addi	a0,a0,-1744 # 9c8 <malloc+0x144>
  a0:	730000ef          	jal	7d0 <printf>
    exit(1);
  a4:	4505                	li	a0,1
  a6:	2b2000ef          	jal	358 <exit>
  }
  printf("wait for kill and reclaim %d\n", st.ino);
  aa:	fcc42583          	lw	a1,-52(s0)
  ae:	00001517          	auipc	a0,0x1
  b2:	94a50513          	addi	a0,a0,-1718 # 9f8 <malloc+0x174>
  b6:	71a000ef          	jal	7d0 <printf>
  // sit around until killed
  for(;;) pause(1000);
  ba:	3e800513          	li	a0,1000
  be:	32a000ef          	jal	3e8 <pause>
  c2:	bfe5                	j	ba <main+0xba>

00000000000000c4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e406                	sd	ra,8(sp)
  c8:	e022                	sd	s0,0(sp)
  ca:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  cc:	f35ff0ef          	jal	0 <main>
  exit(r);
  d0:	288000ef          	jal	358 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	addi	a1,a1,1
  de:	0785                	addi	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	addi	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	addi	a0,a0,1
 106:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	addi	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	addi	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	slli	a2,a2,0x20
 152:	9201                	srli	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d663          	bge	s1,s4,1de <gets+0x52>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	1b2000ef          	jal	370 <read>
    if(cc < 1)
 1c2:	00a05e63          	blez	a0,1de <gets+0x52>
    buf[i++] = c;
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x50>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679de3          	bne	a5,s6,1ae <gets+0x22>
    buf[i++] = c;
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x52>
 1dc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:

int
stat(const char *n, struct stat *st)
{
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	18e000ef          	jal	398 <open>
  if(fd < 0)
 20e:	02054263          	bltz	a0,232 <stat+0x36>
 212:	e426                	sd	s1,8(sp)
 214:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 216:	85ca                	mv	a1,s2
 218:	198000ef          	jal	3b0 <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	160000ef          	jal	380 <close>
  return r;
 224:	64a2                	ld	s1,8(sp)
}
 226:	854a                	mv	a0,s2
 228:	60e2                	ld	ra,24(sp)
 22a:	6442                	ld	s0,16(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfcd                	j	226 <stat+0x2a>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054683          	lbu	a3,0(a0)
 240:	fd06879b          	addiw	a5,a3,-48
 244:	0ff7f793          	zext.b	a5,a5
 248:	4625                	li	a2,9
 24a:	02f66863          	bltu	a2,a5,27a <atoi+0x44>
 24e:	872a                	mv	a4,a0
  n = 0;
 250:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 252:	0705                	addi	a4,a4,1
 254:	0025179b          	slliw	a5,a0,0x2
 258:	9fa9                	addw	a5,a5,a0
 25a:	0017979b          	slliw	a5,a5,0x1
 25e:	9fb5                	addw	a5,a5,a3
 260:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 264:	00074683          	lbu	a3,0(a4)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	fef671e3          	bgeu	a2,a5,252 <atoi+0x1c>
  return n;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  n = 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <atoi+0x3e>

000000000000027e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 284:	02b57463          	bgeu	a0,a1,2ac <memmove+0x2e>
    while(n-- > 0)
 288:	00c05f63          	blez	a2,2a6 <memmove+0x28>
 28c:	1602                	slli	a2,a2,0x20
 28e:	9201                	srli	a2,a2,0x20
 290:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fef71ae3          	bne	a4,a5,296 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x28>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x46>
 2d4:	bfc9                	j	2a6 <memmove+0x28>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	f67ff0ef          	jal	27e <memmove>
}
 31c:	60a2                	ld	ra,8(sp)
 31e:	6402                	ld	s0,0(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret

0000000000000324 <sbrk>:

char *
sbrk(int n) {
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 32c:	4585                	li	a1,1
 32e:	0b2000ef          	jal	3e0 <sys_sbrk>
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <sbrklazy>:

char *
sbrklazy(int n) {
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 342:	4589                	li	a1,2
 344:	09c000ef          	jal	3e0 <sys_sbrk>
}
 348:	60a2                	ld	ra,8(sp)
 34a:	6402                	ld	s0,0(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret

0000000000000350 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 350:	4885                	li	a7,1
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exit>:
.global exit
exit:
 li a7, SYS_exit
 358:	4889                	li	a7,2
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <wait>:
.global wait
wait:
 li a7, SYS_wait
 360:	488d                	li	a7,3
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 368:	4891                	li	a7,4
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <read>:
.global read
read:
 li a7, SYS_read
 370:	4895                	li	a7,5
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <write>:
.global write
write:
 li a7, SYS_write
 378:	48c1                	li	a7,16
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <close>:
.global close
close:
 li a7, SYS_close
 380:	48d5                	li	a7,21
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <kill>:
.global kill
kill:
 li a7, SYS_kill
 388:	4899                	li	a7,6
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exec>:
.global exec
exec:
 li a7, SYS_exec
 390:	489d                	li	a7,7
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <open>:
.global open
open:
 li a7, SYS_open
 398:	48bd                	li	a7,15
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a0:	48c5                	li	a7,17
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a8:	48c9                	li	a7,18
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b0:	48a1                	li	a7,8
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <link>:
.global link
link:
 li a7, SYS_link
 3b8:	48cd                	li	a7,19
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c0:	48d1                	li	a7,20
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c8:	48a5                	li	a7,9
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d0:	48a9                	li	a7,10
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d8:	48ad                	li	a7,11
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3e0:	48b1                	li	a7,12
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3e8:	48b5                	li	a7,13
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f0:	48b9                	li	a7,14
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 3f8:	48d9                	li	a7,22
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 400:	48dd                	li	a7,23
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 408:	48e1                	li	a7,24
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 410:	48e5                	li	a7,25
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 418:	48e9                	li	a7,26
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 420:	48ed                	li	a7,27
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 428:	48f1                	li	a7,28
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 430:	48f5                	li	a7,29
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 438:	48f9                	li	a7,30
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 440:	48fd                	li	a7,31
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 448:	1101                	addi	sp,sp,-32
 44a:	ec06                	sd	ra,24(sp)
 44c:	e822                	sd	s0,16(sp)
 44e:	1000                	addi	s0,sp,32
 450:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 454:	4605                	li	a2,1
 456:	fef40593          	addi	a1,s0,-17
 45a:	f1fff0ef          	jal	378 <write>
}
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 466:	715d                	addi	sp,sp,-80
 468:	e486                	sd	ra,72(sp)
 46a:	e0a2                	sd	s0,64(sp)
 46c:	f84a                	sd	s2,48(sp)
 46e:	0880                	addi	s0,sp,80
 470:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 472:	c299                	beqz	a3,478 <printint+0x12>
 474:	0805c363          	bltz	a1,4fa <printint+0x94>
  neg = 0;
 478:	4881                	li	a7,0
 47a:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 47e:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 480:	00000517          	auipc	a0,0x0
 484:	5a050513          	addi	a0,a0,1440 # a20 <digits>
 488:	883e                	mv	a6,a5
 48a:	2785                	addiw	a5,a5,1
 48c:	02c5f733          	remu	a4,a1,a2
 490:	972a                	add	a4,a4,a0
 492:	00074703          	lbu	a4,0(a4)
 496:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 49a:	872e                	mv	a4,a1
 49c:	02c5d5b3          	divu	a1,a1,a2
 4a0:	0685                	addi	a3,a3,1
 4a2:	fec773e3          	bgeu	a4,a2,488 <printint+0x22>
  if(neg)
 4a6:	00088b63          	beqz	a7,4bc <printint+0x56>
    buf[i++] = '-';
 4aa:	fd078793          	addi	a5,a5,-48
 4ae:	97a2                	add	a5,a5,s0
 4b0:	02d00713          	li	a4,45
 4b4:	fee78423          	sb	a4,-24(a5)
 4b8:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4bc:	02f05a63          	blez	a5,4f0 <printint+0x8a>
 4c0:	fc26                	sd	s1,56(sp)
 4c2:	f44e                	sd	s3,40(sp)
 4c4:	fb840713          	addi	a4,s0,-72
 4c8:	00f704b3          	add	s1,a4,a5
 4cc:	fff70993          	addi	s3,a4,-1
 4d0:	99be                	add	s3,s3,a5
 4d2:	37fd                	addiw	a5,a5,-1
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4dc:	fff4c583          	lbu	a1,-1(s1)
 4e0:	854a                	mv	a0,s2
 4e2:	f67ff0ef          	jal	448 <putc>
  while(--i >= 0)
 4e6:	14fd                	addi	s1,s1,-1
 4e8:	ff349ae3          	bne	s1,s3,4dc <printint+0x76>
 4ec:	74e2                	ld	s1,56(sp)
 4ee:	79a2                	ld	s3,40(sp)
}
 4f0:	60a6                	ld	ra,72(sp)
 4f2:	6406                	ld	s0,64(sp)
 4f4:	7942                	ld	s2,48(sp)
 4f6:	6161                	addi	sp,sp,80
 4f8:	8082                	ret
    x = -xx;
 4fa:	40b005b3          	neg	a1,a1
    neg = 1;
 4fe:	4885                	li	a7,1
    x = -xx;
 500:	bfad                	j	47a <printint+0x14>

0000000000000502 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 502:	711d                	addi	sp,sp,-96
 504:	ec86                	sd	ra,88(sp)
 506:	e8a2                	sd	s0,80(sp)
 508:	e0ca                	sd	s2,64(sp)
 50a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 50c:	0005c903          	lbu	s2,0(a1)
 510:	28090663          	beqz	s2,79c <vprintf+0x29a>
 514:	e4a6                	sd	s1,72(sp)
 516:	fc4e                	sd	s3,56(sp)
 518:	f852                	sd	s4,48(sp)
 51a:	f456                	sd	s5,40(sp)
 51c:	f05a                	sd	s6,32(sp)
 51e:	ec5e                	sd	s7,24(sp)
 520:	e862                	sd	s8,16(sp)
 522:	e466                	sd	s9,8(sp)
 524:	8b2a                	mv	s6,a0
 526:	8a2e                	mv	s4,a1
 528:	8bb2                	mv	s7,a2
  state = 0;
 52a:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 52c:	4481                	li	s1,0
 52e:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 530:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 534:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 538:	06c00c93          	li	s9,108
 53c:	a005                	j	55c <vprintf+0x5a>
        putc(fd, c0);
 53e:	85ca                	mv	a1,s2
 540:	855a                	mv	a0,s6
 542:	f07ff0ef          	jal	448 <putc>
 546:	a019                	j	54c <vprintf+0x4a>
    } else if(state == '%'){
 548:	03598263          	beq	s3,s5,56c <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 54c:	2485                	addiw	s1,s1,1
 54e:	8726                	mv	a4,s1
 550:	009a07b3          	add	a5,s4,s1
 554:	0007c903          	lbu	s2,0(a5)
 558:	22090a63          	beqz	s2,78c <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 55c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 560:	fe0994e3          	bnez	s3,548 <vprintf+0x46>
      if(c0 == '%'){
 564:	fd579de3          	bne	a5,s5,53e <vprintf+0x3c>
        state = '%';
 568:	89be                	mv	s3,a5
 56a:	b7cd                	j	54c <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 56c:	00ea06b3          	add	a3,s4,a4
 570:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 574:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 576:	c681                	beqz	a3,57e <vprintf+0x7c>
 578:	9752                	add	a4,a4,s4
 57a:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 57e:	05878363          	beq	a5,s8,5c4 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 582:	05978d63          	beq	a5,s9,5dc <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 586:	07500713          	li	a4,117
 58a:	0ee78763          	beq	a5,a4,678 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 58e:	07800713          	li	a4,120
 592:	12e78963          	beq	a5,a4,6c4 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 596:	07000713          	li	a4,112
 59a:	14e78e63          	beq	a5,a4,6f6 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 59e:	06300713          	li	a4,99
 5a2:	18e78e63          	beq	a5,a4,73e <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a6:	07300713          	li	a4,115
 5aa:	1ae78463          	beq	a5,a4,752 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5ae:	02500713          	li	a4,37
 5b2:	04e79563          	bne	a5,a4,5fc <vprintf+0xfa>
        putc(fd, '%');
 5b6:	02500593          	li	a1,37
 5ba:	855a                	mv	a0,s6
 5bc:	e8dff0ef          	jal	448 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b769                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000ba583          	lw	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	e95ff0ef          	jal	466 <printint>
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bf8d                	j	54c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5dc:	06400793          	li	a5,100
 5e0:	02f68963          	beq	a3,a5,612 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e4:	06c00793          	li	a5,108
 5e8:	04f68263          	beq	a3,a5,62c <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5ec:	07500793          	li	a5,117
 5f0:	0af68063          	beq	a3,a5,690 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5f4:	07800793          	li	a5,120
 5f8:	0ef68263          	beq	a3,a5,6dc <vprintf+0x1da>
        putc(fd, '%');
 5fc:	02500593          	li	a1,37
 600:	855a                	mv	a0,s6
 602:	e47ff0ef          	jal	448 <putc>
        putc(fd, c0);
 606:	85ca                	mv	a1,s2
 608:	855a                	mv	a0,s6
 60a:	e3fff0ef          	jal	448 <putc>
      state = 0;
 60e:	4981                	li	s3,0
 610:	bf35                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 612:	008b8913          	addi	s2,s7,8
 616:	4685                	li	a3,1
 618:	4629                	li	a2,10
 61a:	000bb583          	ld	a1,0(s7)
 61e:	855a                	mv	a0,s6
 620:	e47ff0ef          	jal	466 <printint>
        i += 1;
 624:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
        i += 1;
 62a:	b70d                	j	54c <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62c:	06400793          	li	a5,100
 630:	02f60763          	beq	a2,a5,65e <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 634:	07500793          	li	a5,117
 638:	06f60963          	beq	a2,a5,6aa <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 63c:	07800793          	li	a5,120
 640:	faf61ee3          	bne	a2,a5,5fc <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 644:	008b8913          	addi	s2,s7,8
 648:	4681                	li	a3,0
 64a:	4641                	li	a2,16
 64c:	000bb583          	ld	a1,0(s7)
 650:	855a                	mv	a0,s6
 652:	e15ff0ef          	jal	466 <printint>
        i += 2;
 656:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
        i += 2;
 65c:	bdc5                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	008b8913          	addi	s2,s7,8
 662:	4685                	li	a3,1
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	dfbff0ef          	jal	466 <printint>
        i += 2;
 670:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 672:	8bca                	mv	s7,s2
      state = 0;
 674:	4981                	li	s3,0
        i += 2;
 676:	bdd9                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 678:	008b8913          	addi	s2,s7,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000be583          	lwu	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	de1ff0ef          	jal	466 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bd7d                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	008b8913          	addi	s2,s7,8
 694:	4681                	li	a3,0
 696:	4629                	li	a2,10
 698:	000bb583          	ld	a1,0(s7)
 69c:	855a                	mv	a0,s6
 69e:	dc9ff0ef          	jal	466 <printint>
        i += 1;
 6a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a4:	8bca                	mv	s7,s2
      state = 0;
 6a6:	4981                	li	s3,0
        i += 1;
 6a8:	b555                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	dafff0ef          	jal	466 <printint>
        i += 2;
 6bc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 2;
 6c2:	b569                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c4:	008b8913          	addi	s2,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4641                	li	a2,16
 6cc:	000be583          	lwu	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	d95ff0ef          	jal	466 <printint>
 6d6:	8bca                	mv	s7,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bd8d                	j	54c <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4641                	li	a2,16
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	d7dff0ef          	jal	466 <printint>
        i += 1;
 6ee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 1;
 6f4:	bda1                	j	54c <vprintf+0x4a>
 6f6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6f8:	008b8d13          	addi	s10,s7,8
 6fc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 700:	03000593          	li	a1,48
 704:	855a                	mv	a0,s6
 706:	d43ff0ef          	jal	448 <putc>
  putc(fd, 'x');
 70a:	07800593          	li	a1,120
 70e:	855a                	mv	a0,s6
 710:	d39ff0ef          	jal	448 <putc>
 714:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 716:	00000b97          	auipc	s7,0x0
 71a:	30ab8b93          	addi	s7,s7,778 # a20 <digits>
 71e:	03c9d793          	srli	a5,s3,0x3c
 722:	97de                	add	a5,a5,s7
 724:	0007c583          	lbu	a1,0(a5)
 728:	855a                	mv	a0,s6
 72a:	d1fff0ef          	jal	448 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72e:	0992                	slli	s3,s3,0x4
 730:	397d                	addiw	s2,s2,-1
 732:	fe0916e3          	bnez	s2,71e <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 736:	8bea                	mv	s7,s10
      state = 0;
 738:	4981                	li	s3,0
 73a:	6d02                	ld	s10,0(sp)
 73c:	bd01                	j	54c <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 73e:	008b8913          	addi	s2,s7,8
 742:	000bc583          	lbu	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	d01ff0ef          	jal	448 <putc>
 74c:	8bca                	mv	s7,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bbf5                	j	54c <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 752:	008b8993          	addi	s3,s7,8
 756:	000bb903          	ld	s2,0(s7)
 75a:	00090f63          	beqz	s2,778 <vprintf+0x276>
        for(; *s; s++)
 75e:	00094583          	lbu	a1,0(s2)
 762:	c195                	beqz	a1,786 <vprintf+0x284>
          putc(fd, *s);
 764:	855a                	mv	a0,s6
 766:	ce3ff0ef          	jal	448 <putc>
        for(; *s; s++)
 76a:	0905                	addi	s2,s2,1
 76c:	00094583          	lbu	a1,0(s2)
 770:	f9f5                	bnez	a1,764 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 772:	8bce                	mv	s7,s3
      state = 0;
 774:	4981                	li	s3,0
 776:	bbd9                	j	54c <vprintf+0x4a>
          s = "(null)";
 778:	00000917          	auipc	s2,0x0
 77c:	2a090913          	addi	s2,s2,672 # a18 <malloc+0x194>
        for(; *s; s++)
 780:	02800593          	li	a1,40
 784:	b7c5                	j	764 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 786:	8bce                	mv	s7,s3
      state = 0;
 788:	4981                	li	s3,0
 78a:	b3c9                	j	54c <vprintf+0x4a>
 78c:	64a6                	ld	s1,72(sp)
 78e:	79e2                	ld	s3,56(sp)
 790:	7a42                	ld	s4,48(sp)
 792:	7aa2                	ld	s5,40(sp)
 794:	7b02                	ld	s6,32(sp)
 796:	6be2                	ld	s7,24(sp)
 798:	6c42                	ld	s8,16(sp)
 79a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 79c:	60e6                	ld	ra,88(sp)
 79e:	6446                	ld	s0,80(sp)
 7a0:	6906                	ld	s2,64(sp)
 7a2:	6125                	addi	sp,sp,96
 7a4:	8082                	ret

00000000000007a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a6:	715d                	addi	sp,sp,-80
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e010                	sd	a2,0(s0)
 7b0:	e414                	sd	a3,8(s0)
 7b2:	e818                	sd	a4,16(s0)
 7b4:	ec1c                	sd	a5,24(s0)
 7b6:	03043023          	sd	a6,32(s0)
 7ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c2:	8622                	mv	a2,s0
 7c4:	d3fff0ef          	jal	502 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6161                	addi	sp,sp,80
 7ce:	8082                	ret

00000000000007d0 <printf>:

void
printf(const char *fmt, ...)
{
 7d0:	711d                	addi	sp,sp,-96
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e40c                	sd	a1,8(s0)
 7da:	e810                	sd	a2,16(s0)
 7dc:	ec14                	sd	a3,24(s0)
 7de:	f018                	sd	a4,32(s0)
 7e0:	f41c                	sd	a5,40(s0)
 7e2:	03043823          	sd	a6,48(s0)
 7e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	00840613          	addi	a2,s0,8
 7ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f2:	85aa                	mv	a1,a0
 7f4:	4505                	li	a0,1
 7f6:	d0dff0ef          	jal	502 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6125                	addi	sp,sp,96
 800:	8082                	ret

0000000000000802 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 802:	1141                	addi	sp,sp,-16
 804:	e422                	sd	s0,8(sp)
 806:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 808:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80c:	00000797          	auipc	a5,0x0
 810:	7f47b783          	ld	a5,2036(a5) # 1000 <freep>
 814:	a02d                	j	83e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 816:	4618                	lw	a4,8(a2)
 818:	9f2d                	addw	a4,a4,a1
 81a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81e:	6398                	ld	a4,0(a5)
 820:	6310                	ld	a2,0(a4)
 822:	a83d                	j	860 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 824:	ff852703          	lw	a4,-8(a0)
 828:	9f31                	addw	a4,a4,a2
 82a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 82c:	ff053683          	ld	a3,-16(a0)
 830:	a091                	j	874 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	6398                	ld	a4,0(a5)
 834:	00e7e463          	bltu	a5,a4,83c <free+0x3a>
 838:	00e6ea63          	bltu	a3,a4,84c <free+0x4a>
{
 83c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	fed7fae3          	bgeu	a5,a3,832 <free+0x30>
 842:	6398                	ld	a4,0(a5)
 844:	00e6e463          	bltu	a3,a4,84c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	fee7eae3          	bltu	a5,a4,83c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 84c:	ff852583          	lw	a1,-8(a0)
 850:	6390                	ld	a2,0(a5)
 852:	02059813          	slli	a6,a1,0x20
 856:	01c85713          	srli	a4,a6,0x1c
 85a:	9736                	add	a4,a4,a3
 85c:	fae60de3          	beq	a2,a4,816 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 864:	4790                	lw	a2,8(a5)
 866:	02061593          	slli	a1,a2,0x20
 86a:	01c5d713          	srli	a4,a1,0x1c
 86e:	973e                	add	a4,a4,a5
 870:	fae68ae3          	beq	a3,a4,824 <free+0x22>
    p->s.ptr = bp->s.ptr;
 874:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 876:	00000717          	auipc	a4,0x0
 87a:	78f73523          	sd	a5,1930(a4) # 1000 <freep>
}
 87e:	6422                	ld	s0,8(sp)
 880:	0141                	addi	sp,sp,16
 882:	8082                	ret

0000000000000884 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 884:	7139                	addi	sp,sp,-64
 886:	fc06                	sd	ra,56(sp)
 888:	f822                	sd	s0,48(sp)
 88a:	f426                	sd	s1,40(sp)
 88c:	ec4e                	sd	s3,24(sp)
 88e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 890:	02051493          	slli	s1,a0,0x20
 894:	9081                	srli	s1,s1,0x20
 896:	04bd                	addi	s1,s1,15
 898:	8091                	srli	s1,s1,0x4
 89a:	0014899b          	addiw	s3,s1,1
 89e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a0:	00000517          	auipc	a0,0x0
 8a4:	76053503          	ld	a0,1888(a0) # 1000 <freep>
 8a8:	c915                	beqz	a0,8dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ac:	4798                	lw	a4,8(a5)
 8ae:	08977a63          	bgeu	a4,s1,942 <malloc+0xbe>
 8b2:	f04a                	sd	s2,32(sp)
 8b4:	e852                	sd	s4,16(sp)
 8b6:	e456                	sd	s5,8(sp)
 8b8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ba:	8a4e                	mv	s4,s3
 8bc:	0009871b          	sext.w	a4,s3
 8c0:	6685                	lui	a3,0x1
 8c2:	00d77363          	bgeu	a4,a3,8c8 <malloc+0x44>
 8c6:	6a05                	lui	s4,0x1
 8c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8cc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d0:	00000917          	auipc	s2,0x0
 8d4:	73090913          	addi	s2,s2,1840 # 1000 <freep>
  if(p == SBRK_ERROR)
 8d8:	5afd                	li	s5,-1
 8da:	a081                	j	91a <malloc+0x96>
 8dc:	f04a                	sd	s2,32(sp)
 8de:	e852                	sd	s4,16(sp)
 8e0:	e456                	sd	s5,8(sp)
 8e2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8e4:	00001797          	auipc	a5,0x1
 8e8:	92478793          	addi	a5,a5,-1756 # 1208 <base>
 8ec:	00000717          	auipc	a4,0x0
 8f0:	70f73a23          	sd	a5,1812(a4) # 1000 <freep>
 8f4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fa:	b7c1                	j	8ba <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8fc:	6398                	ld	a4,0(a5)
 8fe:	e118                	sd	a4,0(a0)
 900:	a8a9                	j	95a <malloc+0xd6>
  hp->s.size = nu;
 902:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 906:	0541                	addi	a0,a0,16
 908:	efbff0ef          	jal	802 <free>
  return freep;
 90c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 910:	c12d                	beqz	a0,972 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	02977263          	bgeu	a4,s1,93a <malloc+0xb6>
    if(p == freep)
 91a:	00093703          	ld	a4,0(s2)
 91e:	853e                	mv	a0,a5
 920:	fef719e3          	bne	a4,a5,912 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 924:	8552                	mv	a0,s4
 926:	9ffff0ef          	jal	324 <sbrk>
  if(p == SBRK_ERROR)
 92a:	fd551ce3          	bne	a0,s5,902 <malloc+0x7e>
        return 0;
 92e:	4501                	li	a0,0
 930:	7902                	ld	s2,32(sp)
 932:	6a42                	ld	s4,16(sp)
 934:	6aa2                	ld	s5,8(sp)
 936:	6b02                	ld	s6,0(sp)
 938:	a03d                	j	966 <malloc+0xe2>
 93a:	7902                	ld	s2,32(sp)
 93c:	6a42                	ld	s4,16(sp)
 93e:	6aa2                	ld	s5,8(sp)
 940:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 942:	fae48de3          	beq	s1,a4,8fc <malloc+0x78>
        p->s.size -= nunits;
 946:	4137073b          	subw	a4,a4,s3
 94a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94c:	02071693          	slli	a3,a4,0x20
 950:	01c6d713          	srli	a4,a3,0x1c
 954:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 956:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95a:	00000717          	auipc	a4,0x0
 95e:	6aa73323          	sd	a0,1702(a4) # 1000 <freep>
      return (void*)(p + 1);
 962:	01078513          	addi	a0,a5,16
  }
}
 966:	70e2                	ld	ra,56(sp)
 968:	7442                	ld	s0,48(sp)
 96a:	74a2                	ld	s1,40(sp)
 96c:	69e2                	ld	s3,24(sp)
 96e:	6121                	addi	sp,sp,64
 970:	8082                	ret
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
 97a:	b7f5                	j	966 <malloc+0xe2>
