
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	9e8a0a13          	addi	s4,s4,-1560 # a20 <malloc+0x104>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a035                	j	6e <wc+0x6e>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	1ba000ef          	jal	200 <strchr>
  4a:	c919                	beqz	a0,60 <wc+0x60>
        inword = 0;
  4c:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  4e:	0485                	addi	s1,s1,1
  50:	01348d63          	beq	s1,s3,6a <wc+0x6a>
      if(buf[i] == '\n')
  54:	0004c583          	lbu	a1,0(s1)
  58:	ff5596e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  5c:	2c05                	addiw	s8,s8,1
  5e:	b7dd                	j	44 <wc+0x44>
      else if(!inword){
  60:	fe0917e3          	bnez	s2,4e <wc+0x4e>
        w++;
  64:	2c85                	addiw	s9,s9,1
        inword = 1;
  66:	4905                	li	s2,1
  68:	b7dd                	j	4e <wc+0x4e>
  6a:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	20000613          	li	a2,512
  72:	85ee                	mv	a1,s11
  74:	f8843503          	ld	a0,-120(s0)
  78:	390000ef          	jal	408 <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
    for(i=0; i<n; i++){
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009509b3          	add	s3,a0,s1
  8e:	b7d9                	j	54 <wc+0x54>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86ea                	mv	a3,s10
  9a:	8666                	mv	a2,s9
  9c:	85e2                	mv	a1,s8
  9e:	00001517          	auipc	a0,0x1
  a2:	9a250513          	addi	a0,a0,-1630 # a40 <malloc+0x124>
  a6:	7c2000ef          	jal	868 <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	96850513          	addi	a0,a0,-1688 # a30 <malloc+0x114>
  d0:	798000ef          	jal	868 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	31a000ef          	jal	3f0 <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	328000ef          	jal	430 <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	2fc000ef          	jal	418 <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2c8000ef          	jal	3f0 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	8f658593          	addi	a1,a1,-1802 # a28 <malloc+0x10c>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2ae000ef          	jal	3f0 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	90650513          	addi	a0,a0,-1786 # a50 <malloc+0x134>
 152:	716000ef          	jal	868 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	298000ef          	jal	3f0 <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 164:	f77ff0ef          	jal	da <main>
  exit(r);
 168:	288000ef          	jal	3f0 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d663          	bge	s1,s4,276 <gets+0x52>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	1b2000ef          	jal	408 <read>
    if(cc < 1)
 25a:	00a05e63          	blez	a0,276 <gets+0x52>
    buf[i++] = c;
 25e:	faf44783          	lbu	a5,-81(s0)
 262:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 266:	01578763          	beq	a5,s5,274 <gets+0x50>
 26a:	0905                	addi	s2,s2,1
 26c:	fd679de3          	bne	a5,s6,246 <gets+0x22>
    buf[i++] = c;
 270:	89a6                	mv	s3,s1
 272:	a011                	j	276 <gets+0x52>
 274:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 276:	99de                	add	s3,s3,s7
 278:	00098023          	sb	zero,0(s3)
  return buf;
}
 27c:	855e                	mv	a0,s7
 27e:	60e6                	ld	ra,88(sp)
 280:	6446                	ld	s0,80(sp)
 282:	64a6                	ld	s1,72(sp)
 284:	6906                	ld	s2,64(sp)
 286:	79e2                	ld	s3,56(sp)
 288:	7a42                	ld	s4,48(sp)
 28a:	7aa2                	ld	s5,40(sp)
 28c:	7b02                	ld	s6,32(sp)
 28e:	6be2                	ld	s7,24(sp)
 290:	6125                	addi	sp,sp,96
 292:	8082                	ret

0000000000000294 <stat>:

int
stat(const char *n, struct stat *st)
{
 294:	1101                	addi	sp,sp,-32
 296:	ec06                	sd	ra,24(sp)
 298:	e822                	sd	s0,16(sp)
 29a:	e04a                	sd	s2,0(sp)
 29c:	1000                	addi	s0,sp,32
 29e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a0:	4581                	li	a1,0
 2a2:	18e000ef          	jal	430 <open>
  if(fd < 0)
 2a6:	02054263          	bltz	a0,2ca <stat+0x36>
 2aa:	e426                	sd	s1,8(sp)
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	198000ef          	jal	448 <fstat>
 2b4:	892a                	mv	s2,a0
  close(fd);
 2b6:	8526                	mv	a0,s1
 2b8:	160000ef          	jal	418 <close>
  return r;
 2bc:	64a2                	ld	s1,8(sp)
}
 2be:	854a                	mv	a0,s2
 2c0:	60e2                	ld	ra,24(sp)
 2c2:	6442                	ld	s0,16(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfcd                	j	2be <stat+0x2a>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054683          	lbu	a3,0(a0)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	4625                	li	a2,9
 2e2:	02f66863          	bltu	a2,a5,312 <atoi+0x44>
 2e6:	872a                	mv	a4,a0
  n = 0;
 2e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ea:	0705                	addi	a4,a4,1
 2ec:	0025179b          	slliw	a5,a0,0x2
 2f0:	9fa9                	addw	a5,a5,a0
 2f2:	0017979b          	slliw	a5,a5,0x1
 2f6:	9fb5                	addw	a5,a5,a3
 2f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fc:	00074683          	lbu	a3,0(a4)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	fef671e3          	bgeu	a2,a5,2ea <atoi+0x1c>
  return n;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <atoi+0x3e>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57463          	bgeu	a0,a1,344 <memmove+0x2e>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x28>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fef71ae3          	bne	a4,a5,32e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x28>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x46>
 36c:	bfc9                	j	33e <memmove+0x28>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	f67ff0ef          	jal	316 <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <sbrk>:

char *
sbrk(int n) {
 3bc:	1141                	addi	sp,sp,-16
 3be:	e406                	sd	ra,8(sp)
 3c0:	e022                	sd	s0,0(sp)
 3c2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c4:	4585                	li	a1,1
 3c6:	0b2000ef          	jal	478 <sys_sbrk>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <sbrklazy>:

char *
sbrklazy(int n) {
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e406                	sd	ra,8(sp)
 3d6:	e022                	sd	s0,0(sp)
 3d8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3da:	4589                	li	a1,2
 3dc:	09c000ef          	jal	478 <sys_sbrk>
}
 3e0:	60a2                	ld	ra,8(sp)
 3e2:	6402                	ld	s0,0(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret

00000000000003e8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e8:	4885                	li	a7,1
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f0:	4889                	li	a7,2
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f8:	488d                	li	a7,3
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 400:	4891                	li	a7,4
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <read>:
.global read
read:
 li a7, SYS_read
 408:	4895                	li	a7,5
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <write>:
.global write
write:
 li a7, SYS_write
 410:	48c1                	li	a7,16
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <close>:
.global close
close:
 li a7, SYS_close
 418:	48d5                	li	a7,21
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <kill>:
.global kill
kill:
 li a7, SYS_kill
 420:	4899                	li	a7,6
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <exec>:
.global exec
exec:
 li a7, SYS_exec
 428:	489d                	li	a7,7
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <open>:
.global open
open:
 li a7, SYS_open
 430:	48bd                	li	a7,15
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 438:	48c5                	li	a7,17
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 440:	48c9                	li	a7,18
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 448:	48a1                	li	a7,8
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <link>:
.global link
link:
 li a7, SYS_link
 450:	48cd                	li	a7,19
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 458:	48d1                	li	a7,20
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 460:	48a5                	li	a7,9
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <dup>:
.global dup
dup:
 li a7, SYS_dup
 468:	48a9                	li	a7,10
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 470:	48ad                	li	a7,11
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 478:	48b1                	li	a7,12
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <pause>:
.global pause
pause:
 li a7, SYS_pause
 480:	48b5                	li	a7,13
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 488:	48b9                	li	a7,14
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 490:	48d9                	li	a7,22
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 498:	48dd                	li	a7,23
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 4a0:	48e1                	li	a7,24
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 4a8:	48e5                	li	a7,25
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 4b0:	48e9                	li	a7,26
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 4b8:	48ed                	li	a7,27
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 4c0:	48f1                	li	a7,28
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 4c8:	48f5                	li	a7,29
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 4d0:	48f9                	li	a7,30
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 4d8:	48fd                	li	a7,31
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4e0:	1101                	addi	sp,sp,-32
 4e2:	ec06                	sd	ra,24(sp)
 4e4:	e822                	sd	s0,16(sp)
 4e6:	1000                	addi	s0,sp,32
 4e8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ec:	4605                	li	a2,1
 4ee:	fef40593          	addi	a1,s0,-17
 4f2:	f1fff0ef          	jal	410 <write>
}
 4f6:	60e2                	ld	ra,24(sp)
 4f8:	6442                	ld	s0,16(sp)
 4fa:	6105                	addi	sp,sp,32
 4fc:	8082                	ret

00000000000004fe <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4fe:	715d                	addi	sp,sp,-80
 500:	e486                	sd	ra,72(sp)
 502:	e0a2                	sd	s0,64(sp)
 504:	f84a                	sd	s2,48(sp)
 506:	0880                	addi	s0,sp,80
 508:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 50a:	c299                	beqz	a3,510 <printint+0x12>
 50c:	0805c363          	bltz	a1,592 <printint+0x94>
  neg = 0;
 510:	4881                	li	a7,0
 512:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 516:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 518:	00000517          	auipc	a0,0x0
 51c:	55850513          	addi	a0,a0,1368 # a70 <digits>
 520:	883e                	mv	a6,a5
 522:	2785                	addiw	a5,a5,1
 524:	02c5f733          	remu	a4,a1,a2
 528:	972a                	add	a4,a4,a0
 52a:	00074703          	lbu	a4,0(a4)
 52e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 532:	872e                	mv	a4,a1
 534:	02c5d5b3          	divu	a1,a1,a2
 538:	0685                	addi	a3,a3,1
 53a:	fec773e3          	bgeu	a4,a2,520 <printint+0x22>
  if(neg)
 53e:	00088b63          	beqz	a7,554 <printint+0x56>
    buf[i++] = '-';
 542:	fd078793          	addi	a5,a5,-48
 546:	97a2                	add	a5,a5,s0
 548:	02d00713          	li	a4,45
 54c:	fee78423          	sb	a4,-24(a5)
 550:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 554:	02f05a63          	blez	a5,588 <printint+0x8a>
 558:	fc26                	sd	s1,56(sp)
 55a:	f44e                	sd	s3,40(sp)
 55c:	fb840713          	addi	a4,s0,-72
 560:	00f704b3          	add	s1,a4,a5
 564:	fff70993          	addi	s3,a4,-1
 568:	99be                	add	s3,s3,a5
 56a:	37fd                	addiw	a5,a5,-1
 56c:	1782                	slli	a5,a5,0x20
 56e:	9381                	srli	a5,a5,0x20
 570:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 574:	fff4c583          	lbu	a1,-1(s1)
 578:	854a                	mv	a0,s2
 57a:	f67ff0ef          	jal	4e0 <putc>
  while(--i >= 0)
 57e:	14fd                	addi	s1,s1,-1
 580:	ff349ae3          	bne	s1,s3,574 <printint+0x76>
 584:	74e2                	ld	s1,56(sp)
 586:	79a2                	ld	s3,40(sp)
}
 588:	60a6                	ld	ra,72(sp)
 58a:	6406                	ld	s0,64(sp)
 58c:	7942                	ld	s2,48(sp)
 58e:	6161                	addi	sp,sp,80
 590:	8082                	ret
    x = -xx;
 592:	40b005b3          	neg	a1,a1
    neg = 1;
 596:	4885                	li	a7,1
    x = -xx;
 598:	bfad                	j	512 <printint+0x14>

000000000000059a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59a:	711d                	addi	sp,sp,-96
 59c:	ec86                	sd	ra,88(sp)
 59e:	e8a2                	sd	s0,80(sp)
 5a0:	e0ca                	sd	s2,64(sp)
 5a2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a4:	0005c903          	lbu	s2,0(a1)
 5a8:	28090663          	beqz	s2,834 <vprintf+0x29a>
 5ac:	e4a6                	sd	s1,72(sp)
 5ae:	fc4e                	sd	s3,56(sp)
 5b0:	f852                	sd	s4,48(sp)
 5b2:	f456                	sd	s5,40(sp)
 5b4:	f05a                	sd	s6,32(sp)
 5b6:	ec5e                	sd	s7,24(sp)
 5b8:	e862                	sd	s8,16(sp)
 5ba:	e466                	sd	s9,8(sp)
 5bc:	8b2a                	mv	s6,a0
 5be:	8a2e                	mv	s4,a1
 5c0:	8bb2                	mv	s7,a2
  state = 0;
 5c2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5c4:	4481                	li	s1,0
 5c6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5c8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5cc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5d0:	06c00c93          	li	s9,108
 5d4:	a005                	j	5f4 <vprintf+0x5a>
        putc(fd, c0);
 5d6:	85ca                	mv	a1,s2
 5d8:	855a                	mv	a0,s6
 5da:	f07ff0ef          	jal	4e0 <putc>
 5de:	a019                	j	5e4 <vprintf+0x4a>
    } else if(state == '%'){
 5e0:	03598263          	beq	s3,s5,604 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5e4:	2485                	addiw	s1,s1,1
 5e6:	8726                	mv	a4,s1
 5e8:	009a07b3          	add	a5,s4,s1
 5ec:	0007c903          	lbu	s2,0(a5)
 5f0:	22090a63          	beqz	s2,824 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5f4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f8:	fe0994e3          	bnez	s3,5e0 <vprintf+0x46>
      if(c0 == '%'){
 5fc:	fd579de3          	bne	a5,s5,5d6 <vprintf+0x3c>
        state = '%';
 600:	89be                	mv	s3,a5
 602:	b7cd                	j	5e4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 604:	00ea06b3          	add	a3,s4,a4
 608:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 60c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 60e:	c681                	beqz	a3,616 <vprintf+0x7c>
 610:	9752                	add	a4,a4,s4
 612:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 616:	05878363          	beq	a5,s8,65c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 61a:	05978d63          	beq	a5,s9,674 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 61e:	07500713          	li	a4,117
 622:	0ee78763          	beq	a5,a4,710 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 626:	07800713          	li	a4,120
 62a:	12e78963          	beq	a5,a4,75c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 62e:	07000713          	li	a4,112
 632:	14e78e63          	beq	a5,a4,78e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 636:	06300713          	li	a4,99
 63a:	18e78e63          	beq	a5,a4,7d6 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 63e:	07300713          	li	a4,115
 642:	1ae78463          	beq	a5,a4,7ea <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 646:	02500713          	li	a4,37
 64a:	04e79563          	bne	a5,a4,694 <vprintf+0xfa>
        putc(fd, '%');
 64e:	02500593          	li	a1,37
 652:	855a                	mv	a0,s6
 654:	e8dff0ef          	jal	4e0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 658:	4981                	li	s3,0
 65a:	b769                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 65c:	008b8913          	addi	s2,s7,8
 660:	4685                	li	a3,1
 662:	4629                	li	a2,10
 664:	000ba583          	lw	a1,0(s7)
 668:	855a                	mv	a0,s6
 66a:	e95ff0ef          	jal	4fe <printint>
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	bf8d                	j	5e4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 674:	06400793          	li	a5,100
 678:	02f68963          	beq	a3,a5,6aa <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 67c:	06c00793          	li	a5,108
 680:	04f68263          	beq	a3,a5,6c4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 684:	07500793          	li	a5,117
 688:	0af68063          	beq	a3,a5,728 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 68c:	07800793          	li	a5,120
 690:	0ef68263          	beq	a3,a5,774 <vprintf+0x1da>
        putc(fd, '%');
 694:	02500593          	li	a1,37
 698:	855a                	mv	a0,s6
 69a:	e47ff0ef          	jal	4e0 <putc>
        putc(fd, c0);
 69e:	85ca                	mv	a1,s2
 6a0:	855a                	mv	a0,s6
 6a2:	e3fff0ef          	jal	4e0 <putc>
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf35                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	008b8913          	addi	s2,s7,8
 6ae:	4685                	li	a3,1
 6b0:	4629                	li	a2,10
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	e47ff0ef          	jal	4fe <printint>
        i += 1;
 6bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6be:	8bca                	mv	s7,s2
      state = 0;
 6c0:	4981                	li	s3,0
        i += 1;
 6c2:	b70d                	j	5e4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c4:	06400793          	li	a5,100
 6c8:	02f60763          	beq	a2,a5,6f6 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6cc:	07500793          	li	a5,117
 6d0:	06f60963          	beq	a2,a5,742 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6d4:	07800793          	li	a5,120
 6d8:	faf61ee3          	bne	a2,a5,694 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	4681                	li	a3,0
 6e2:	4641                	li	a2,16
 6e4:	000bb583          	ld	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	e15ff0ef          	jal	4fe <printint>
        i += 2;
 6ee:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f0:	8bca                	mv	s7,s2
      state = 0;
 6f2:	4981                	li	s3,0
        i += 2;
 6f4:	bdc5                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6f6:	008b8913          	addi	s2,s7,8
 6fa:	4685                	li	a3,1
 6fc:	4629                	li	a2,10
 6fe:	000bb583          	ld	a1,0(s7)
 702:	855a                	mv	a0,s6
 704:	dfbff0ef          	jal	4fe <printint>
        i += 2;
 708:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 70a:	8bca                	mv	s7,s2
      state = 0;
 70c:	4981                	li	s3,0
        i += 2;
 70e:	bdd9                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 710:	008b8913          	addi	s2,s7,8
 714:	4681                	li	a3,0
 716:	4629                	li	a2,10
 718:	000be583          	lwu	a1,0(s7)
 71c:	855a                	mv	a0,s6
 71e:	de1ff0ef          	jal	4fe <printint>
 722:	8bca                	mv	s7,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bd7d                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 728:	008b8913          	addi	s2,s7,8
 72c:	4681                	li	a3,0
 72e:	4629                	li	a2,10
 730:	000bb583          	ld	a1,0(s7)
 734:	855a                	mv	a0,s6
 736:	dc9ff0ef          	jal	4fe <printint>
        i += 1;
 73a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 73c:	8bca                	mv	s7,s2
      state = 0;
 73e:	4981                	li	s3,0
        i += 1;
 740:	b555                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 742:	008b8913          	addi	s2,s7,8
 746:	4681                	li	a3,0
 748:	4629                	li	a2,10
 74a:	000bb583          	ld	a1,0(s7)
 74e:	855a                	mv	a0,s6
 750:	dafff0ef          	jal	4fe <printint>
        i += 2;
 754:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 756:	8bca                	mv	s7,s2
      state = 0;
 758:	4981                	li	s3,0
        i += 2;
 75a:	b569                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 75c:	008b8913          	addi	s2,s7,8
 760:	4681                	li	a3,0
 762:	4641                	li	a2,16
 764:	000be583          	lwu	a1,0(s7)
 768:	855a                	mv	a0,s6
 76a:	d95ff0ef          	jal	4fe <printint>
 76e:	8bca                	mv	s7,s2
      state = 0;
 770:	4981                	li	s3,0
 772:	bd8d                	j	5e4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 774:	008b8913          	addi	s2,s7,8
 778:	4681                	li	a3,0
 77a:	4641                	li	a2,16
 77c:	000bb583          	ld	a1,0(s7)
 780:	855a                	mv	a0,s6
 782:	d7dff0ef          	jal	4fe <printint>
        i += 1;
 786:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 788:	8bca                	mv	s7,s2
      state = 0;
 78a:	4981                	li	s3,0
        i += 1;
 78c:	bda1                	j	5e4 <vprintf+0x4a>
 78e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 790:	008b8d13          	addi	s10,s7,8
 794:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 798:	03000593          	li	a1,48
 79c:	855a                	mv	a0,s6
 79e:	d43ff0ef          	jal	4e0 <putc>
  putc(fd, 'x');
 7a2:	07800593          	li	a1,120
 7a6:	855a                	mv	a0,s6
 7a8:	d39ff0ef          	jal	4e0 <putc>
 7ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ae:	00000b97          	auipc	s7,0x0
 7b2:	2c2b8b93          	addi	s7,s7,706 # a70 <digits>
 7b6:	03c9d793          	srli	a5,s3,0x3c
 7ba:	97de                	add	a5,a5,s7
 7bc:	0007c583          	lbu	a1,0(a5)
 7c0:	855a                	mv	a0,s6
 7c2:	d1fff0ef          	jal	4e0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7c6:	0992                	slli	s3,s3,0x4
 7c8:	397d                	addiw	s2,s2,-1
 7ca:	fe0916e3          	bnez	s2,7b6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7ce:	8bea                	mv	s7,s10
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	6d02                	ld	s10,0(sp)
 7d4:	bd01                	j	5e4 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7d6:	008b8913          	addi	s2,s7,8
 7da:	000bc583          	lbu	a1,0(s7)
 7de:	855a                	mv	a0,s6
 7e0:	d01ff0ef          	jal	4e0 <putc>
 7e4:	8bca                	mv	s7,s2
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	bbf5                	j	5e4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7ea:	008b8993          	addi	s3,s7,8
 7ee:	000bb903          	ld	s2,0(s7)
 7f2:	00090f63          	beqz	s2,810 <vprintf+0x276>
        for(; *s; s++)
 7f6:	00094583          	lbu	a1,0(s2)
 7fa:	c195                	beqz	a1,81e <vprintf+0x284>
          putc(fd, *s);
 7fc:	855a                	mv	a0,s6
 7fe:	ce3ff0ef          	jal	4e0 <putc>
        for(; *s; s++)
 802:	0905                	addi	s2,s2,1
 804:	00094583          	lbu	a1,0(s2)
 808:	f9f5                	bnez	a1,7fc <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 80a:	8bce                	mv	s7,s3
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bbd9                	j	5e4 <vprintf+0x4a>
          s = "(null)";
 810:	00000917          	auipc	s2,0x0
 814:	25890913          	addi	s2,s2,600 # a68 <malloc+0x14c>
        for(; *s; s++)
 818:	02800593          	li	a1,40
 81c:	b7c5                	j	7fc <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 81e:	8bce                	mv	s7,s3
      state = 0;
 820:	4981                	li	s3,0
 822:	b3c9                	j	5e4 <vprintf+0x4a>
 824:	64a6                	ld	s1,72(sp)
 826:	79e2                	ld	s3,56(sp)
 828:	7a42                	ld	s4,48(sp)
 82a:	7aa2                	ld	s5,40(sp)
 82c:	7b02                	ld	s6,32(sp)
 82e:	6be2                	ld	s7,24(sp)
 830:	6c42                	ld	s8,16(sp)
 832:	6ca2                	ld	s9,8(sp)
    }
  }
}
 834:	60e6                	ld	ra,88(sp)
 836:	6446                	ld	s0,80(sp)
 838:	6906                	ld	s2,64(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 83e:	715d                	addi	sp,sp,-80
 840:	ec06                	sd	ra,24(sp)
 842:	e822                	sd	s0,16(sp)
 844:	1000                	addi	s0,sp,32
 846:	e010                	sd	a2,0(s0)
 848:	e414                	sd	a3,8(s0)
 84a:	e818                	sd	a4,16(s0)
 84c:	ec1c                	sd	a5,24(s0)
 84e:	03043023          	sd	a6,32(s0)
 852:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 856:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 85a:	8622                	mv	a2,s0
 85c:	d3fff0ef          	jal	59a <vprintf>
}
 860:	60e2                	ld	ra,24(sp)
 862:	6442                	ld	s0,16(sp)
 864:	6161                	addi	sp,sp,80
 866:	8082                	ret

0000000000000868 <printf>:

void
printf(const char *fmt, ...)
{
 868:	711d                	addi	sp,sp,-96
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	addi	s0,sp,32
 870:	e40c                	sd	a1,8(s0)
 872:	e810                	sd	a2,16(s0)
 874:	ec14                	sd	a3,24(s0)
 876:	f018                	sd	a4,32(s0)
 878:	f41c                	sd	a5,40(s0)
 87a:	03043823          	sd	a6,48(s0)
 87e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 882:	00840613          	addi	a2,s0,8
 886:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 88a:	85aa                	mv	a1,a0
 88c:	4505                	li	a0,1
 88e:	d0dff0ef          	jal	59a <vprintf>
}
 892:	60e2                	ld	ra,24(sp)
 894:	6442                	ld	s0,16(sp)
 896:	6125                	addi	sp,sp,96
 898:	8082                	ret

000000000000089a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89a:	1141                	addi	sp,sp,-16
 89c:	e422                	sd	s0,8(sp)
 89e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a4:	00000797          	auipc	a5,0x0
 8a8:	75c7b783          	ld	a5,1884(a5) # 1000 <freep>
 8ac:	a02d                	j	8d6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ae:	4618                	lw	a4,8(a2)
 8b0:	9f2d                	addw	a4,a4,a1
 8b2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b6:	6398                	ld	a4,0(a5)
 8b8:	6310                	ld	a2,0(a4)
 8ba:	a83d                	j	8f8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8bc:	ff852703          	lw	a4,-8(a0)
 8c0:	9f31                	addw	a4,a4,a2
 8c2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c4:	ff053683          	ld	a3,-16(a0)
 8c8:	a091                	j	90c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	6398                	ld	a4,0(a5)
 8cc:	00e7e463          	bltu	a5,a4,8d4 <free+0x3a>
 8d0:	00e6ea63          	bltu	a3,a4,8e4 <free+0x4a>
{
 8d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d6:	fed7fae3          	bgeu	a5,a3,8ca <free+0x30>
 8da:	6398                	ld	a4,0(a5)
 8dc:	00e6e463          	bltu	a3,a4,8e4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e0:	fee7eae3          	bltu	a5,a4,8d4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8e4:	ff852583          	lw	a1,-8(a0)
 8e8:	6390                	ld	a2,0(a5)
 8ea:	02059813          	slli	a6,a1,0x20
 8ee:	01c85713          	srli	a4,a6,0x1c
 8f2:	9736                	add	a4,a4,a3
 8f4:	fae60de3          	beq	a2,a4,8ae <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8fc:	4790                	lw	a2,8(a5)
 8fe:	02061593          	slli	a1,a2,0x20
 902:	01c5d713          	srli	a4,a1,0x1c
 906:	973e                	add	a4,a4,a5
 908:	fae68ae3          	beq	a3,a4,8bc <free+0x22>
    p->s.ptr = bp->s.ptr;
 90c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 90e:	00000717          	auipc	a4,0x0
 912:	6ef73923          	sd	a5,1778(a4) # 1000 <freep>
}
 916:	6422                	ld	s0,8(sp)
 918:	0141                	addi	sp,sp,16
 91a:	8082                	ret

000000000000091c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 91c:	7139                	addi	sp,sp,-64
 91e:	fc06                	sd	ra,56(sp)
 920:	f822                	sd	s0,48(sp)
 922:	f426                	sd	s1,40(sp)
 924:	ec4e                	sd	s3,24(sp)
 926:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 928:	02051493          	slli	s1,a0,0x20
 92c:	9081                	srli	s1,s1,0x20
 92e:	04bd                	addi	s1,s1,15
 930:	8091                	srli	s1,s1,0x4
 932:	0014899b          	addiw	s3,s1,1
 936:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 938:	00000517          	auipc	a0,0x0
 93c:	6c853503          	ld	a0,1736(a0) # 1000 <freep>
 940:	c915                	beqz	a0,974 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 942:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 944:	4798                	lw	a4,8(a5)
 946:	08977a63          	bgeu	a4,s1,9da <malloc+0xbe>
 94a:	f04a                	sd	s2,32(sp)
 94c:	e852                	sd	s4,16(sp)
 94e:	e456                	sd	s5,8(sp)
 950:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 952:	8a4e                	mv	s4,s3
 954:	0009871b          	sext.w	a4,s3
 958:	6685                	lui	a3,0x1
 95a:	00d77363          	bgeu	a4,a3,960 <malloc+0x44>
 95e:	6a05                	lui	s4,0x1
 960:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 964:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 968:	00000917          	auipc	s2,0x0
 96c:	69890913          	addi	s2,s2,1688 # 1000 <freep>
  if(p == SBRK_ERROR)
 970:	5afd                	li	s5,-1
 972:	a081                	j	9b2 <malloc+0x96>
 974:	f04a                	sd	s2,32(sp)
 976:	e852                	sd	s4,16(sp)
 978:	e456                	sd	s5,8(sp)
 97a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 97c:	00001797          	auipc	a5,0x1
 980:	89478793          	addi	a5,a5,-1900 # 1210 <base>
 984:	00000717          	auipc	a4,0x0
 988:	66f73e23          	sd	a5,1660(a4) # 1000 <freep>
 98c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 98e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 992:	b7c1                	j	952 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 994:	6398                	ld	a4,0(a5)
 996:	e118                	sd	a4,0(a0)
 998:	a8a9                	j	9f2 <malloc+0xd6>
  hp->s.size = nu;
 99a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 99e:	0541                	addi	a0,a0,16
 9a0:	efbff0ef          	jal	89a <free>
  return freep;
 9a4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a8:	c12d                	beqz	a0,a0a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ac:	4798                	lw	a4,8(a5)
 9ae:	02977263          	bgeu	a4,s1,9d2 <malloc+0xb6>
    if(p == freep)
 9b2:	00093703          	ld	a4,0(s2)
 9b6:	853e                	mv	a0,a5
 9b8:	fef719e3          	bne	a4,a5,9aa <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9bc:	8552                	mv	a0,s4
 9be:	9ffff0ef          	jal	3bc <sbrk>
  if(p == SBRK_ERROR)
 9c2:	fd551ce3          	bne	a0,s5,99a <malloc+0x7e>
        return 0;
 9c6:	4501                	li	a0,0
 9c8:	7902                	ld	s2,32(sp)
 9ca:	6a42                	ld	s4,16(sp)
 9cc:	6aa2                	ld	s5,8(sp)
 9ce:	6b02                	ld	s6,0(sp)
 9d0:	a03d                	j	9fe <malloc+0xe2>
 9d2:	7902                	ld	s2,32(sp)
 9d4:	6a42                	ld	s4,16(sp)
 9d6:	6aa2                	ld	s5,8(sp)
 9d8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9da:	fae48de3          	beq	s1,a4,994 <malloc+0x78>
        p->s.size -= nunits;
 9de:	4137073b          	subw	a4,a4,s3
 9e2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9e4:	02071693          	slli	a3,a4,0x20
 9e8:	01c6d713          	srli	a4,a3,0x1c
 9ec:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ee:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f2:	00000717          	auipc	a4,0x0
 9f6:	60a73723          	sd	a0,1550(a4) # 1000 <freep>
      return (void*)(p + 1);
 9fa:	01078513          	addi	a0,a5,16
  }
}
 9fe:	70e2                	ld	ra,56(sp)
 a00:	7442                	ld	s0,48(sp)
 a02:	74a2                	ld	s1,40(sp)
 a04:	69e2                	ld	s3,24(sp)
 a06:	6121                	addi	sp,sp,64
 a08:	8082                	ret
 a0a:	7902                	ld	s2,32(sp)
 a0c:	6a42                	ld	s4,16(sp)
 a0e:	6aa2                	ld	s5,8(sp)
 a10:	6b02                	ld	s6,0(sp)
 a12:	b7f5                	j	9fe <malloc+0xe2>
