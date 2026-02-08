
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	376000ef          	jal	396 <read>
  24:	84aa                	mv	s1,a0
  26:	02a05363          	blez	a0,4c <cat+0x4c>
    if (write(1, buf, n) != n) {
  2a:	8626                	mv	a2,s1
  2c:	85ca                	mv	a1,s2
  2e:	4505                	li	a0,1
  30:	36e000ef          	jal	39e <write>
  34:	fe9502e3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  38:	00001597          	auipc	a1,0x1
  3c:	97858593          	addi	a1,a1,-1672 # 9b0 <malloc+0x106>
  40:	4509                	li	a0,2
  42:	78a000ef          	jal	7cc <fprintf>
      exit(1);
  46:	4505                	li	a0,1
  48:	336000ef          	jal	37e <exit>
    }
  }
  if(n < 0){
  4c:	00054963          	bltz	a0,5e <cat+0x5e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  50:	70a2                	ld	ra,40(sp)
  52:	7402                	ld	s0,32(sp)
  54:	64e2                	ld	s1,24(sp)
  56:	6942                	ld	s2,16(sp)
  58:	69a2                	ld	s3,8(sp)
  5a:	6145                	addi	sp,sp,48
  5c:	8082                	ret
    fprintf(2, "cat: read error\n");
  5e:	00001597          	auipc	a1,0x1
  62:	96a58593          	addi	a1,a1,-1686 # 9c8 <malloc+0x11e>
  66:	4509                	li	a0,2
  68:	764000ef          	jal	7cc <fprintf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	310000ef          	jal	37e <exit>

0000000000000072 <main>:

int
main(int argc, char *argv[])
{
  72:	7179                	addi	sp,sp,-48
  74:	f406                	sd	ra,40(sp)
  76:	f022                	sd	s0,32(sp)
  78:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  7a:	4785                	li	a5,1
  7c:	04a7d263          	bge	a5,a0,c0 <main+0x4e>
  80:	ec26                	sd	s1,24(sp)
  82:	e84a                	sd	s2,16(sp)
  84:	e44e                	sd	s3,8(sp)
  86:	00858913          	addi	s2,a1,8
  8a:	ffe5099b          	addiw	s3,a0,-2
  8e:	02099793          	slli	a5,s3,0x20
  92:	01d7d993          	srli	s3,a5,0x1d
  96:	05c1                	addi	a1,a1,16
  98:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
  9a:	4581                	li	a1,0
  9c:	00093503          	ld	a0,0(s2) # 1010 <buf>
  a0:	31e000ef          	jal	3be <open>
  a4:	84aa                	mv	s1,a0
  a6:	02054663          	bltz	a0,d2 <main+0x60>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  aa:	f57ff0ef          	jal	0 <cat>
    close(fd);
  ae:	8526                	mv	a0,s1
  b0:	2f6000ef          	jal	3a6 <close>
  for(i = 1; i < argc; i++){
  b4:	0921                	addi	s2,s2,8
  b6:	ff3912e3          	bne	s2,s3,9a <main+0x28>
  }
  exit(0);
  ba:	4501                	li	a0,0
  bc:	2c2000ef          	jal	37e <exit>
  c0:	ec26                	sd	s1,24(sp)
  c2:	e84a                	sd	s2,16(sp)
  c4:	e44e                	sd	s3,8(sp)
    cat(0);
  c6:	4501                	li	a0,0
  c8:	f39ff0ef          	jal	0 <cat>
    exit(0);
  cc:	4501                	li	a0,0
  ce:	2b0000ef          	jal	37e <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  d2:	00093603          	ld	a2,0(s2)
  d6:	00001597          	auipc	a1,0x1
  da:	90a58593          	addi	a1,a1,-1782 # 9e0 <malloc+0x136>
  de:	4509                	li	a0,2
  e0:	6ec000ef          	jal	7cc <fprintf>
      exit(1);
  e4:	4505                	li	a0,1
  e6:	298000ef          	jal	37e <exit>

00000000000000ea <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e406                	sd	ra,8(sp)
  ee:	e022                	sd	s0,0(sp)
  f0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  f2:	f81ff0ef          	jal	72 <main>
  exit(r);
  f6:	288000ef          	jal	37e <exit>

00000000000000fa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 100:	87aa                	mv	a5,a0
 102:	0585                	addi	a1,a1,1
 104:	0785                	addi	a5,a5,1
 106:	fff5c703          	lbu	a4,-1(a1)
 10a:	fee78fa3          	sb	a4,-1(a5)
 10e:	fb75                	bnez	a4,102 <strcpy+0x8>
    ;
  return os;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cb91                	beqz	a5,134 <strcmp+0x1e>
 122:	0005c703          	lbu	a4,0(a1)
 126:	00f71763          	bne	a4,a5,134 <strcmp+0x1e>
    p++, q++;
 12a:	0505                	addi	a0,a0,1
 12c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbe5                	bnez	a5,122 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 134:	0005c503          	lbu	a0,0(a1)
}
 138:	40a7853b          	subw	a0,a5,a0
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strlen>:

uint
strlen(const char *s)
{
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cf91                	beqz	a5,168 <strlen+0x26>
 14e:	0505                	addi	a0,a0,1
 150:	87aa                	mv	a5,a0
 152:	86be                	mv	a3,a5
 154:	0785                	addi	a5,a5,1
 156:	fff7c703          	lbu	a4,-1(a5)
 15a:	ff65                	bnez	a4,152 <strlen+0x10>
 15c:	40a6853b          	subw	a0,a3,a0
 160:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  for(n = 0; s[n]; n++)
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strlen+0x20>

000000000000016c <memset>:

void*
memset(void *dst, int c, uint n)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 172:	ca19                	beqz	a2,188 <memset+0x1c>
 174:	87aa                	mv	a5,a0
 176:	1602                	slli	a2,a2,0x20
 178:	9201                	srli	a2,a2,0x20
 17a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 182:	0785                	addi	a5,a5,1
 184:	fee79de3          	bne	a5,a4,17e <memset+0x12>
  }
  return dst;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strchr>:

char*
strchr(const char *s, char c)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  for(; *s; s++)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb99                	beqz	a5,1ae <strchr+0x20>
    if(*s == c)
 19a:	00f58763          	beq	a1,a5,1a8 <strchr+0x1a>
  for(; *s; s++)
 19e:	0505                	addi	a0,a0,1
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbfd                	bnez	a5,19a <strchr+0xc>
      return (char*)s;
  return 0;
 1a6:	4501                	li	a0,0
}
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret
  return 0;
 1ae:	4501                	li	a0,0
 1b0:	bfe5                	j	1a8 <strchr+0x1a>

00000000000001b2 <gets>:

char*
gets(char *buf, int max)
{
 1b2:	711d                	addi	sp,sp,-96
 1b4:	ec86                	sd	ra,88(sp)
 1b6:	e8a2                	sd	s0,80(sp)
 1b8:	e4a6                	sd	s1,72(sp)
 1ba:	e0ca                	sd	s2,64(sp)
 1bc:	fc4e                	sd	s3,56(sp)
 1be:	f852                	sd	s4,48(sp)
 1c0:	f456                	sd	s5,40(sp)
 1c2:	f05a                	sd	s6,32(sp)
 1c4:	ec5e                	sd	s7,24(sp)
 1c6:	1080                	addi	s0,sp,96
 1c8:	8baa                	mv	s7,a0
 1ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cc:	892a                	mv	s2,a0
 1ce:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d0:	4aa9                	li	s5,10
 1d2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d4:	89a6                	mv	s3,s1
 1d6:	2485                	addiw	s1,s1,1
 1d8:	0344d663          	bge	s1,s4,204 <gets+0x52>
    cc = read(0, &c, 1);
 1dc:	4605                	li	a2,1
 1de:	faf40593          	addi	a1,s0,-81
 1e2:	4501                	li	a0,0
 1e4:	1b2000ef          	jal	396 <read>
    if(cc < 1)
 1e8:	00a05e63          	blez	a0,204 <gets+0x52>
    buf[i++] = c;
 1ec:	faf44783          	lbu	a5,-81(s0)
 1f0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f4:	01578763          	beq	a5,s5,202 <gets+0x50>
 1f8:	0905                	addi	s2,s2,1
 1fa:	fd679de3          	bne	a5,s6,1d4 <gets+0x22>
    buf[i++] = c;
 1fe:	89a6                	mv	s3,s1
 200:	a011                	j	204 <gets+0x52>
 202:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 204:	99de                	add	s3,s3,s7
 206:	00098023          	sb	zero,0(s3)
  return buf;
}
 20a:	855e                	mv	a0,s7
 20c:	60e6                	ld	ra,88(sp)
 20e:	6446                	ld	s0,80(sp)
 210:	64a6                	ld	s1,72(sp)
 212:	6906                	ld	s2,64(sp)
 214:	79e2                	ld	s3,56(sp)
 216:	7a42                	ld	s4,48(sp)
 218:	7aa2                	ld	s5,40(sp)
 21a:	7b02                	ld	s6,32(sp)
 21c:	6be2                	ld	s7,24(sp)
 21e:	6125                	addi	sp,sp,96
 220:	8082                	ret

0000000000000222 <stat>:

int
stat(const char *n, struct stat *st)
{
 222:	1101                	addi	sp,sp,-32
 224:	ec06                	sd	ra,24(sp)
 226:	e822                	sd	s0,16(sp)
 228:	e04a                	sd	s2,0(sp)
 22a:	1000                	addi	s0,sp,32
 22c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22e:	4581                	li	a1,0
 230:	18e000ef          	jal	3be <open>
  if(fd < 0)
 234:	02054263          	bltz	a0,258 <stat+0x36>
 238:	e426                	sd	s1,8(sp)
 23a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23c:	85ca                	mv	a1,s2
 23e:	198000ef          	jal	3d6 <fstat>
 242:	892a                	mv	s2,a0
  close(fd);
 244:	8526                	mv	a0,s1
 246:	160000ef          	jal	3a6 <close>
  return r;
 24a:	64a2                	ld	s1,8(sp)
}
 24c:	854a                	mv	a0,s2
 24e:	60e2                	ld	ra,24(sp)
 250:	6442                	ld	s0,16(sp)
 252:	6902                	ld	s2,0(sp)
 254:	6105                	addi	sp,sp,32
 256:	8082                	ret
    return -1;
 258:	597d                	li	s2,-1
 25a:	bfcd                	j	24c <stat+0x2a>

000000000000025c <atoi>:

int
atoi(const char *s)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 262:	00054683          	lbu	a3,0(a0)
 266:	fd06879b          	addiw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	4625                	li	a2,9
 270:	02f66863          	bltu	a2,a5,2a0 <atoi+0x44>
 274:	872a                	mv	a4,a0
  n = 0;
 276:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 278:	0705                	addi	a4,a4,1
 27a:	0025179b          	slliw	a5,a0,0x2
 27e:	9fa9                	addw	a5,a5,a0
 280:	0017979b          	slliw	a5,a5,0x1
 284:	9fb5                	addw	a5,a5,a3
 286:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28a:	00074683          	lbu	a3,0(a4)
 28e:	fd06879b          	addiw	a5,a3,-48
 292:	0ff7f793          	zext.b	a5,a5
 296:	fef671e3          	bgeu	a2,a5,278 <atoi+0x1c>
  return n;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  n = 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <atoi+0x3e>

00000000000002a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2aa:	02b57463          	bgeu	a0,a1,2d2 <memmove+0x2e>
    while(n-- > 0)
 2ae:	00c05f63          	blez	a2,2cc <memmove+0x28>
 2b2:	1602                	slli	a2,a2,0x20
 2b4:	9201                	srli	a2,a2,0x20
 2b6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ba:	872a                	mv	a4,a0
      *dst++ = *src++;
 2bc:	0585                	addi	a1,a1,1
 2be:	0705                	addi	a4,a4,1
 2c0:	fff5c683          	lbu	a3,-1(a1)
 2c4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c8:	fef71ae3          	bne	a4,a5,2bc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
    dst += n;
 2d2:	00c50733          	add	a4,a0,a2
    src += n;
 2d6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d8:	fec05ae3          	blez	a2,2cc <memmove+0x28>
 2dc:	fff6079b          	addiw	a5,a2,-1
 2e0:	1782                	slli	a5,a5,0x20
 2e2:	9381                	srli	a5,a5,0x20
 2e4:	fff7c793          	not	a5,a5
 2e8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ea:	15fd                	addi	a1,a1,-1
 2ec:	177d                	addi	a4,a4,-1
 2ee:	0005c683          	lbu	a3,0(a1)
 2f2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f6:	fee79ae3          	bne	a5,a4,2ea <memmove+0x46>
 2fa:	bfc9                	j	2cc <memmove+0x28>

00000000000002fc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fc:	1141                	addi	sp,sp,-16
 2fe:	e422                	sd	s0,8(sp)
 300:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 302:	ca05                	beqz	a2,332 <memcmp+0x36>
 304:	fff6069b          	addiw	a3,a2,-1
 308:	1682                	slli	a3,a3,0x20
 30a:	9281                	srli	a3,a3,0x20
 30c:	0685                	addi	a3,a3,1
 30e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 310:	00054783          	lbu	a5,0(a0)
 314:	0005c703          	lbu	a4,0(a1)
 318:	00e79863          	bne	a5,a4,328 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 31c:	0505                	addi	a0,a0,1
    p2++;
 31e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 320:	fed518e3          	bne	a0,a3,310 <memcmp+0x14>
  }
  return 0;
 324:	4501                	li	a0,0
 326:	a019                	j	32c <memcmp+0x30>
      return *p1 - *p2;
 328:	40e7853b          	subw	a0,a5,a4
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <memcmp+0x30>

0000000000000336 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e406                	sd	ra,8(sp)
 33a:	e022                	sd	s0,0(sp)
 33c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33e:	f67ff0ef          	jal	2a4 <memmove>
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <sbrk>:

char *
sbrk(int n) {
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 352:	4585                	li	a1,1
 354:	0b2000ef          	jal	406 <sys_sbrk>
}
 358:	60a2                	ld	ra,8(sp)
 35a:	6402                	ld	s0,0(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <sbrklazy>:

char *
sbrklazy(int n) {
 360:	1141                	addi	sp,sp,-16
 362:	e406                	sd	ra,8(sp)
 364:	e022                	sd	s0,0(sp)
 366:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 368:	4589                	li	a1,2
 36a:	09c000ef          	jal	406 <sys_sbrk>
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret

0000000000000376 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 376:	4885                	li	a7,1
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <exit>:
.global exit
exit:
 li a7, SYS_exit
 37e:	4889                	li	a7,2
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <wait>:
.global wait
wait:
 li a7, SYS_wait
 386:	488d                	li	a7,3
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38e:	4891                	li	a7,4
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <read>:
.global read
read:
 li a7, SYS_read
 396:	4895                	li	a7,5
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <write>:
.global write
write:
 li a7, SYS_write
 39e:	48c1                	li	a7,16
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <close>:
.global close
close:
 li a7, SYS_close
 3a6:	48d5                	li	a7,21
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ae:	4899                	li	a7,6
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b6:	489d                	li	a7,7
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <open>:
.global open
open:
 li a7, SYS_open
 3be:	48bd                	li	a7,15
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c6:	48c5                	li	a7,17
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ce:	48c9                	li	a7,18
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d6:	48a1                	li	a7,8
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <link>:
.global link
link:
 li a7, SYS_link
 3de:	48cd                	li	a7,19
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e6:	48d1                	li	a7,20
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ee:	48a5                	li	a7,9
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f6:	48a9                	li	a7,10
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fe:	48ad                	li	a7,11
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 406:	48b1                	li	a7,12
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <pause>:
.global pause
pause:
 li a7, SYS_pause
 40e:	48b5                	li	a7,13
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 416:	48b9                	li	a7,14
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 41e:	48d9                	li	a7,22
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 426:	48dd                	li	a7,23
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 42e:	48e1                	li	a7,24
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 436:	48e5                	li	a7,25
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 43e:	48e9                	li	a7,26
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 446:	48ed                	li	a7,27
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 44e:	48f1                	li	a7,28
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 456:	48f5                	li	a7,29
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 45e:	48f9                	li	a7,30
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 466:	48fd                	li	a7,31
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46e:	1101                	addi	sp,sp,-32
 470:	ec06                	sd	ra,24(sp)
 472:	e822                	sd	s0,16(sp)
 474:	1000                	addi	s0,sp,32
 476:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47a:	4605                	li	a2,1
 47c:	fef40593          	addi	a1,s0,-17
 480:	f1fff0ef          	jal	39e <write>
}
 484:	60e2                	ld	ra,24(sp)
 486:	6442                	ld	s0,16(sp)
 488:	6105                	addi	sp,sp,32
 48a:	8082                	ret

000000000000048c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 48c:	715d                	addi	sp,sp,-80
 48e:	e486                	sd	ra,72(sp)
 490:	e0a2                	sd	s0,64(sp)
 492:	f84a                	sd	s2,48(sp)
 494:	0880                	addi	s0,sp,80
 496:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x12>
 49a:	0805c363          	bltz	a1,520 <printint+0x94>
  neg = 0;
 49e:	4881                	li	a7,0
 4a0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a6:	00000517          	auipc	a0,0x0
 4aa:	55a50513          	addi	a0,a0,1370 # a00 <digits>
 4ae:	883e                	mv	a6,a5
 4b0:	2785                	addiw	a5,a5,1
 4b2:	02c5f733          	remu	a4,a1,a2
 4b6:	972a                	add	a4,a4,a0
 4b8:	00074703          	lbu	a4,0(a4)
 4bc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c0:	872e                	mv	a4,a1
 4c2:	02c5d5b3          	divu	a1,a1,a2
 4c6:	0685                	addi	a3,a3,1
 4c8:	fec773e3          	bgeu	a4,a2,4ae <printint+0x22>
  if(neg)
 4cc:	00088b63          	beqz	a7,4e2 <printint+0x56>
    buf[i++] = '-';
 4d0:	fd078793          	addi	a5,a5,-48
 4d4:	97a2                	add	a5,a5,s0
 4d6:	02d00713          	li	a4,45
 4da:	fee78423          	sb	a4,-24(a5)
 4de:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e2:	02f05a63          	blez	a5,516 <printint+0x8a>
 4e6:	fc26                	sd	s1,56(sp)
 4e8:	f44e                	sd	s3,40(sp)
 4ea:	fb840713          	addi	a4,s0,-72
 4ee:	00f704b3          	add	s1,a4,a5
 4f2:	fff70993          	addi	s3,a4,-1
 4f6:	99be                	add	s3,s3,a5
 4f8:	37fd                	addiw	a5,a5,-1
 4fa:	1782                	slli	a5,a5,0x20
 4fc:	9381                	srli	a5,a5,0x20
 4fe:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 502:	fff4c583          	lbu	a1,-1(s1)
 506:	854a                	mv	a0,s2
 508:	f67ff0ef          	jal	46e <putc>
  while(--i >= 0)
 50c:	14fd                	addi	s1,s1,-1
 50e:	ff349ae3          	bne	s1,s3,502 <printint+0x76>
 512:	74e2                	ld	s1,56(sp)
 514:	79a2                	ld	s3,40(sp)
}
 516:	60a6                	ld	ra,72(sp)
 518:	6406                	ld	s0,64(sp)
 51a:	7942                	ld	s2,48(sp)
 51c:	6161                	addi	sp,sp,80
 51e:	8082                	ret
    x = -xx;
 520:	40b005b3          	neg	a1,a1
    neg = 1;
 524:	4885                	li	a7,1
    x = -xx;
 526:	bfad                	j	4a0 <printint+0x14>

0000000000000528 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 528:	711d                	addi	sp,sp,-96
 52a:	ec86                	sd	ra,88(sp)
 52c:	e8a2                	sd	s0,80(sp)
 52e:	e0ca                	sd	s2,64(sp)
 530:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 532:	0005c903          	lbu	s2,0(a1)
 536:	28090663          	beqz	s2,7c2 <vprintf+0x29a>
 53a:	e4a6                	sd	s1,72(sp)
 53c:	fc4e                	sd	s3,56(sp)
 53e:	f852                	sd	s4,48(sp)
 540:	f456                	sd	s5,40(sp)
 542:	f05a                	sd	s6,32(sp)
 544:	ec5e                	sd	s7,24(sp)
 546:	e862                	sd	s8,16(sp)
 548:	e466                	sd	s9,8(sp)
 54a:	8b2a                	mv	s6,a0
 54c:	8a2e                	mv	s4,a1
 54e:	8bb2                	mv	s7,a2
  state = 0;
 550:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 552:	4481                	li	s1,0
 554:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 556:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 55a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55e:	06c00c93          	li	s9,108
 562:	a005                	j	582 <vprintf+0x5a>
        putc(fd, c0);
 564:	85ca                	mv	a1,s2
 566:	855a                	mv	a0,s6
 568:	f07ff0ef          	jal	46e <putc>
 56c:	a019                	j	572 <vprintf+0x4a>
    } else if(state == '%'){
 56e:	03598263          	beq	s3,s5,592 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 572:	2485                	addiw	s1,s1,1
 574:	8726                	mv	a4,s1
 576:	009a07b3          	add	a5,s4,s1
 57a:	0007c903          	lbu	s2,0(a5)
 57e:	22090a63          	beqz	s2,7b2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 582:	0009079b          	sext.w	a5,s2
    if(state == 0){
 586:	fe0994e3          	bnez	s3,56e <vprintf+0x46>
      if(c0 == '%'){
 58a:	fd579de3          	bne	a5,s5,564 <vprintf+0x3c>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7cd                	j	572 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 592:	00ea06b3          	add	a3,s4,a4
 596:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 59a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 59c:	c681                	beqz	a3,5a4 <vprintf+0x7c>
 59e:	9752                	add	a4,a4,s4
 5a0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5a4:	05878363          	beq	a5,s8,5ea <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	05978d63          	beq	a5,s9,602 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ac:	07500713          	li	a4,117
 5b0:	0ee78763          	beq	a5,a4,69e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5b4:	07800713          	li	a4,120
 5b8:	12e78963          	beq	a5,a4,6ea <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5bc:	07000713          	li	a4,112
 5c0:	14e78e63          	beq	a5,a4,71c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5c4:	06300713          	li	a4,99
 5c8:	18e78e63          	beq	a5,a4,764 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5cc:	07300713          	li	a4,115
 5d0:	1ae78463          	beq	a5,a4,778 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5d4:	02500713          	li	a4,37
 5d8:	04e79563          	bne	a5,a4,622 <vprintf+0xfa>
        putc(fd, '%');
 5dc:	02500593          	li	a1,37
 5e0:	855a                	mv	a0,s6
 5e2:	e8dff0ef          	jal	46e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b769                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000ba583          	lw	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e95ff0ef          	jal	48c <printint>
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf8d                	j	572 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 602:	06400793          	li	a5,100
 606:	02f68963          	beq	a3,a5,638 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 60a:	06c00793          	li	a5,108
 60e:	04f68263          	beq	a3,a5,652 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 612:	07500793          	li	a5,117
 616:	0af68063          	beq	a3,a5,6b6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 61a:	07800793          	li	a5,120
 61e:	0ef68263          	beq	a3,a5,702 <vprintf+0x1da>
        putc(fd, '%');
 622:	02500593          	li	a1,37
 626:	855a                	mv	a0,s6
 628:	e47ff0ef          	jal	46e <putc>
        putc(fd, c0);
 62c:	85ca                	mv	a1,s2
 62e:	855a                	mv	a0,s6
 630:	e3fff0ef          	jal	46e <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bf35                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e47ff0ef          	jal	48c <printint>
        i += 1;
 64a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 1;
 650:	b70d                	j	572 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 652:	06400793          	li	a5,100
 656:	02f60763          	beq	a2,a5,684 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65a:	07500793          	li	a5,117
 65e:	06f60963          	beq	a2,a5,6d0 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 662:	07800793          	li	a5,120
 666:	faf61ee3          	bne	a2,a5,622 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e15ff0ef          	jal	48c <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	bdc5                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	dfbff0ef          	jal	48c <printint>
        i += 2;
 696:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 2;
 69c:	bdd9                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000be583          	lwu	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	de1ff0ef          	jal	48c <printint>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bd7d                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	dc9ff0ef          	jal	48c <printint>
        i += 1;
 6c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 1;
 6ce:	b555                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	dafff0ef          	jal	48c <printint>
        i += 2;
 6e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	b569                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000be583          	lwu	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	d95ff0ef          	jal	48c <printint>
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd8d                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 702:	008b8913          	addi	s2,s7,8
 706:	4681                	li	a3,0
 708:	4641                	li	a2,16
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	d7dff0ef          	jal	48c <printint>
        i += 1;
 714:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
        i += 1;
 71a:	bda1                	j	572 <vprintf+0x4a>
 71c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 71e:	008b8d13          	addi	s10,s7,8
 722:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 726:	03000593          	li	a1,48
 72a:	855a                	mv	a0,s6
 72c:	d43ff0ef          	jal	46e <putc>
  putc(fd, 'x');
 730:	07800593          	li	a1,120
 734:	855a                	mv	a0,s6
 736:	d39ff0ef          	jal	46e <putc>
 73a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73c:	00000b97          	auipc	s7,0x0
 740:	2c4b8b93          	addi	s7,s7,708 # a00 <digits>
 744:	03c9d793          	srli	a5,s3,0x3c
 748:	97de                	add	a5,a5,s7
 74a:	0007c583          	lbu	a1,0(a5)
 74e:	855a                	mv	a0,s6
 750:	d1fff0ef          	jal	46e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 754:	0992                	slli	s3,s3,0x4
 756:	397d                	addiw	s2,s2,-1
 758:	fe0916e3          	bnez	s2,744 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 75c:	8bea                	mv	s7,s10
      state = 0;
 75e:	4981                	li	s3,0
 760:	6d02                	ld	s10,0(sp)
 762:	bd01                	j	572 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 764:	008b8913          	addi	s2,s7,8
 768:	000bc583          	lbu	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d01ff0ef          	jal	46e <putc>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bbf5                	j	572 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 778:	008b8993          	addi	s3,s7,8
 77c:	000bb903          	ld	s2,0(s7)
 780:	00090f63          	beqz	s2,79e <vprintf+0x276>
        for(; *s; s++)
 784:	00094583          	lbu	a1,0(s2)
 788:	c195                	beqz	a1,7ac <vprintf+0x284>
          putc(fd, *s);
 78a:	855a                	mv	a0,s6
 78c:	ce3ff0ef          	jal	46e <putc>
        for(; *s; s++)
 790:	0905                	addi	s2,s2,1
 792:	00094583          	lbu	a1,0(s2)
 796:	f9f5                	bnez	a1,78a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 798:	8bce                	mv	s7,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bbd9                	j	572 <vprintf+0x4a>
          s = "(null)";
 79e:	00000917          	auipc	s2,0x0
 7a2:	25a90913          	addi	s2,s2,602 # 9f8 <malloc+0x14e>
        for(; *s; s++)
 7a6:	02800593          	li	a1,40
 7aa:	b7c5                	j	78a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ac:	8bce                	mv	s7,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b3c9                	j	572 <vprintf+0x4a>
 7b2:	64a6                	ld	s1,72(sp)
 7b4:	79e2                	ld	s3,56(sp)
 7b6:	7a42                	ld	s4,48(sp)
 7b8:	7aa2                	ld	s5,40(sp)
 7ba:	7b02                	ld	s6,32(sp)
 7bc:	6be2                	ld	s7,24(sp)
 7be:	6c42                	ld	s8,16(sp)
 7c0:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7c2:	60e6                	ld	ra,88(sp)
 7c4:	6446                	ld	s0,80(sp)
 7c6:	6906                	ld	s2,64(sp)
 7c8:	6125                	addi	sp,sp,96
 7ca:	8082                	ret

00000000000007cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7cc:	715d                	addi	sp,sp,-80
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e010                	sd	a2,0(s0)
 7d6:	e414                	sd	a3,8(s0)
 7d8:	e818                	sd	a4,16(s0)
 7da:	ec1c                	sd	a5,24(s0)
 7dc:	03043023          	sd	a6,32(s0)
 7e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e8:	8622                	mv	a2,s0
 7ea:	d3fff0ef          	jal	528 <vprintf>
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	6161                	addi	sp,sp,80
 7f4:	8082                	ret

00000000000007f6 <printf>:

void
printf(const char *fmt, ...)
{
 7f6:	711d                	addi	sp,sp,-96
 7f8:	ec06                	sd	ra,24(sp)
 7fa:	e822                	sd	s0,16(sp)
 7fc:	1000                	addi	s0,sp,32
 7fe:	e40c                	sd	a1,8(s0)
 800:	e810                	sd	a2,16(s0)
 802:	ec14                	sd	a3,24(s0)
 804:	f018                	sd	a4,32(s0)
 806:	f41c                	sd	a5,40(s0)
 808:	03043823          	sd	a6,48(s0)
 80c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 810:	00840613          	addi	a2,s0,8
 814:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 818:	85aa                	mv	a1,a0
 81a:	4505                	li	a0,1
 81c:	d0dff0ef          	jal	528 <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6125                	addi	sp,sp,96
 826:	8082                	ret

0000000000000828 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 828:	1141                	addi	sp,sp,-16
 82a:	e422                	sd	s0,8(sp)
 82c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 832:	00000797          	auipc	a5,0x0
 836:	7ce7b783          	ld	a5,1998(a5) # 1000 <freep>
 83a:	a02d                	j	864 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83c:	4618                	lw	a4,8(a2)
 83e:	9f2d                	addw	a4,a4,a1
 840:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	6310                	ld	a2,0(a4)
 848:	a83d                	j	886 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84a:	ff852703          	lw	a4,-8(a0)
 84e:	9f31                	addw	a4,a4,a2
 850:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 852:	ff053683          	ld	a3,-16(a0)
 856:	a091                	j	89a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 858:	6398                	ld	a4,0(a5)
 85a:	00e7e463          	bltu	a5,a4,862 <free+0x3a>
 85e:	00e6ea63          	bltu	a3,a4,872 <free+0x4a>
{
 862:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 864:	fed7fae3          	bgeu	a5,a3,858 <free+0x30>
 868:	6398                	ld	a4,0(a5)
 86a:	00e6e463          	bltu	a3,a4,872 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	fee7eae3          	bltu	a5,a4,862 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 872:	ff852583          	lw	a1,-8(a0)
 876:	6390                	ld	a2,0(a5)
 878:	02059813          	slli	a6,a1,0x20
 87c:	01c85713          	srli	a4,a6,0x1c
 880:	9736                	add	a4,a4,a3
 882:	fae60de3          	beq	a2,a4,83c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 886:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88a:	4790                	lw	a2,8(a5)
 88c:	02061593          	slli	a1,a2,0x20
 890:	01c5d713          	srli	a4,a1,0x1c
 894:	973e                	add	a4,a4,a5
 896:	fae68ae3          	beq	a3,a4,84a <free+0x22>
    p->s.ptr = bp->s.ptr;
 89a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 89c:	00000717          	auipc	a4,0x0
 8a0:	76f73223          	sd	a5,1892(a4) # 1000 <freep>
}
 8a4:	6422                	ld	s0,8(sp)
 8a6:	0141                	addi	sp,sp,16
 8a8:	8082                	ret

00000000000008aa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8aa:	7139                	addi	sp,sp,-64
 8ac:	fc06                	sd	ra,56(sp)
 8ae:	f822                	sd	s0,48(sp)
 8b0:	f426                	sd	s1,40(sp)
 8b2:	ec4e                	sd	s3,24(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	73a53503          	ld	a0,1850(a0) # 1000 <freep>
 8ce:	c915                	beqz	a0,902 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	08977a63          	bgeu	a4,s1,968 <malloc+0xbe>
 8d8:	f04a                	sd	s2,32(sp)
 8da:	e852                	sd	s4,16(sp)
 8dc:	e456                	sd	s5,8(sp)
 8de:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e0:	8a4e                	mv	s4,s3
 8e2:	0009871b          	sext.w	a4,s3
 8e6:	6685                	lui	a3,0x1
 8e8:	00d77363          	bgeu	a4,a3,8ee <malloc+0x44>
 8ec:	6a05                	lui	s4,0x1
 8ee:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f6:	00000917          	auipc	s2,0x0
 8fa:	70a90913          	addi	s2,s2,1802 # 1000 <freep>
  if(p == SBRK_ERROR)
 8fe:	5afd                	li	s5,-1
 900:	a081                	j	940 <malloc+0x96>
 902:	f04a                	sd	s2,32(sp)
 904:	e852                	sd	s4,16(sp)
 906:	e456                	sd	s5,8(sp)
 908:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 90a:	00001797          	auipc	a5,0x1
 90e:	90678793          	addi	a5,a5,-1786 # 1210 <base>
 912:	00000717          	auipc	a4,0x0
 916:	6ef73723          	sd	a5,1774(a4) # 1000 <freep>
 91a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 920:	b7c1                	j	8e0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 922:	6398                	ld	a4,0(a5)
 924:	e118                	sd	a4,0(a0)
 926:	a8a9                	j	980 <malloc+0xd6>
  hp->s.size = nu;
 928:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 92c:	0541                	addi	a0,a0,16
 92e:	efbff0ef          	jal	828 <free>
  return freep;
 932:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 936:	c12d                	beqz	a0,998 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 938:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93a:	4798                	lw	a4,8(a5)
 93c:	02977263          	bgeu	a4,s1,960 <malloc+0xb6>
    if(p == freep)
 940:	00093703          	ld	a4,0(s2)
 944:	853e                	mv	a0,a5
 946:	fef719e3          	bne	a4,a5,938 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 94a:	8552                	mv	a0,s4
 94c:	9ffff0ef          	jal	34a <sbrk>
  if(p == SBRK_ERROR)
 950:	fd551ce3          	bne	a0,s5,928 <malloc+0x7e>
        return 0;
 954:	4501                	li	a0,0
 956:	7902                	ld	s2,32(sp)
 958:	6a42                	ld	s4,16(sp)
 95a:	6aa2                	ld	s5,8(sp)
 95c:	6b02                	ld	s6,0(sp)
 95e:	a03d                	j	98c <malloc+0xe2>
 960:	7902                	ld	s2,32(sp)
 962:	6a42                	ld	s4,16(sp)
 964:	6aa2                	ld	s5,8(sp)
 966:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 968:	fae48de3          	beq	s1,a4,922 <malloc+0x78>
        p->s.size -= nunits;
 96c:	4137073b          	subw	a4,a4,s3
 970:	c798                	sw	a4,8(a5)
        p += p->s.size;
 972:	02071693          	slli	a3,a4,0x20
 976:	01c6d713          	srli	a4,a3,0x1c
 97a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 980:	00000717          	auipc	a4,0x0
 984:	68a73023          	sd	a0,1664(a4) # 1000 <freep>
      return (void*)(p + 1);
 988:	01078513          	addi	a0,a5,16
  }
}
 98c:	70e2                	ld	ra,56(sp)
 98e:	7442                	ld	s0,48(sp)
 990:	74a2                	ld	s1,40(sp)
 992:	69e2                	ld	s3,24(sp)
 994:	6121                	addi	sp,sp,64
 996:	8082                	ret
 998:	7902                	ld	s2,32(sp)
 99a:	6a42                	ld	s4,16(sp)
 99c:	6aa2                	ld	s5,8(sp)
 99e:	6b02                	ld	s6,0(sp)
 9a0:	b7f5                	j	98c <malloc+0xe2>
