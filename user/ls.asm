
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2b8000ef          	jal	2c4 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	290000ef          	jal	2c4 <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	272000ef          	jal	2c4 <strlen>
  56:	00001997          	auipc	s3,0x1
  5a:	fba98993          	addi	s3,s3,-70 # 1010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	3c0000ef          	jal	426 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	258000ef          	jal	2c4 <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	24e000ef          	jal	2c4 <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	02000593          	li	a1,32
  88:	01298533          	add	a0,s3,s2
  8c:	262000ef          	jal	2ee <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00098723          	sb	zero,14(s3)
  return buf;
  94:	84ce                	mv	s1,s3
  96:	6942                	ld	s2,16(sp)
  98:	69a2                	ld	s3,8(sp)
  9a:	b75d                	j	40 <fmtname+0x40>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	25213823          	sd	s2,592(sp)
  ac:	1c80                	addi	s0,sp,624
  ae:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  b0:	4581                	li	a1,0
  b2:	48e000ef          	jal	540 <open>
  b6:	06054363          	bltz	a0,11c <ls+0x80>
  ba:	24913c23          	sd	s1,600(sp)
  be:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  c0:	d9840593          	addi	a1,s0,-616
  c4:	494000ef          	jal	558 <fstat>
  c8:	06054363          	bltz	a0,12e <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	da041783          	lh	a5,-608(s0)
  d0:	4705                	li	a4,1
  d2:	06e78c63          	beq	a5,a4,14a <ls+0xae>
  d6:	37f9                	addiw	a5,a5,-2
  d8:	17c2                	slli	a5,a5,0x30
  da:	93c1                	srli	a5,a5,0x30
  dc:	02f76263          	bltu	a4,a5,100 <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  e0:	854a                	mv	a0,s2
  e2:	f1fff0ef          	jal	0 <fmtname>
  e6:	85aa                	mv	a1,a0
  e8:	da842703          	lw	a4,-600(s0)
  ec:	d9c42683          	lw	a3,-612(s0)
  f0:	da041603          	lh	a2,-608(s0)
  f4:	00001517          	auipc	a0,0x1
  f8:	a6c50513          	addi	a0,a0,-1428 # b60 <malloc+0x134>
  fc:	07d000ef          	jal	978 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 100:	8526                	mv	a0,s1
 102:	426000ef          	jal	528 <close>
 106:	25813483          	ld	s1,600(sp)
}
 10a:	26813083          	ld	ra,616(sp)
 10e:	26013403          	ld	s0,608(sp)
 112:	25013903          	ld	s2,592(sp)
 116:	27010113          	addi	sp,sp,624
 11a:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 11c:	864a                	mv	a2,s2
 11e:	00001597          	auipc	a1,0x1
 122:	a1258593          	addi	a1,a1,-1518 # b30 <malloc+0x104>
 126:	4509                	li	a0,2
 128:	027000ef          	jal	94e <fprintf>
    return;
 12c:	bff9                	j	10a <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12e:	864a                	mv	a2,s2
 130:	00001597          	auipc	a1,0x1
 134:	a1858593          	addi	a1,a1,-1512 # b48 <malloc+0x11c>
 138:	4509                	li	a0,2
 13a:	015000ef          	jal	94e <fprintf>
    close(fd);
 13e:	8526                	mv	a0,s1
 140:	3e8000ef          	jal	528 <close>
    return;
 144:	25813483          	ld	s1,600(sp)
 148:	b7c9                	j	10a <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14a:	854a                	mv	a0,s2
 14c:	178000ef          	jal	2c4 <strlen>
 150:	2541                	addiw	a0,a0,16
 152:	20000793          	li	a5,512
 156:	00a7f963          	bgeu	a5,a0,168 <ls+0xcc>
      printf("ls: path too long\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	a1650513          	addi	a0,a0,-1514 # b70 <malloc+0x144>
 162:	017000ef          	jal	978 <printf>
      break;
 166:	bf69                	j	100 <ls+0x64>
 168:	25313423          	sd	s3,584(sp)
 16c:	25413023          	sd	s4,576(sp)
 170:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 174:	85ca                	mv	a1,s2
 176:	dc040513          	addi	a0,s0,-576
 17a:	102000ef          	jal	27c <strcpy>
    p = buf+strlen(buf);
 17e:	dc040513          	addi	a0,s0,-576
 182:	142000ef          	jal	2c4 <strlen>
 186:	1502                	slli	a0,a0,0x20
 188:	9101                	srli	a0,a0,0x20
 18a:	dc040793          	addi	a5,s0,-576
 18e:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 192:	00190993          	addi	s3,s2,1
 196:	02f00793          	li	a5,47
 19a:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 19e:	00001a17          	auipc	s4,0x1
 1a2:	9c2a0a13          	addi	s4,s4,-1598 # b60 <malloc+0x134>
        printf("ls: cannot stat %s\n", buf);
 1a6:	00001a97          	auipc	s5,0x1
 1aa:	9a2a8a93          	addi	s5,s5,-1630 # b48 <malloc+0x11c>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ae:	a031                	j	1ba <ls+0x11e>
        printf("ls: cannot stat %s\n", buf);
 1b0:	dc040593          	addi	a1,s0,-576
 1b4:	8556                	mv	a0,s5
 1b6:	7c2000ef          	jal	978 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ba:	4641                	li	a2,16
 1bc:	db040593          	addi	a1,s0,-592
 1c0:	8526                	mv	a0,s1
 1c2:	356000ef          	jal	518 <read>
 1c6:	47c1                	li	a5,16
 1c8:	04f51463          	bne	a0,a5,210 <ls+0x174>
      if(de.inum == 0)
 1cc:	db045783          	lhu	a5,-592(s0)
 1d0:	d7ed                	beqz	a5,1ba <ls+0x11e>
      memmove(p, de.name, DIRSIZ);
 1d2:	4639                	li	a2,14
 1d4:	db240593          	addi	a1,s0,-590
 1d8:	854e                	mv	a0,s3
 1da:	24c000ef          	jal	426 <memmove>
      p[DIRSIZ] = 0;
 1de:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1e2:	d9840593          	addi	a1,s0,-616
 1e6:	dc040513          	addi	a0,s0,-576
 1ea:	1ba000ef          	jal	3a4 <stat>
 1ee:	fc0541e3          	bltz	a0,1b0 <ls+0x114>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1f2:	dc040513          	addi	a0,s0,-576
 1f6:	e0bff0ef          	jal	0 <fmtname>
 1fa:	85aa                	mv	a1,a0
 1fc:	da842703          	lw	a4,-600(s0)
 200:	d9c42683          	lw	a3,-612(s0)
 204:	da041603          	lh	a2,-608(s0)
 208:	8552                	mv	a0,s4
 20a:	76e000ef          	jal	978 <printf>
 20e:	b775                	j	1ba <ls+0x11e>
 210:	24813983          	ld	s3,584(sp)
 214:	24013a03          	ld	s4,576(sp)
 218:	23813a83          	ld	s5,568(sp)
 21c:	b5d5                	j	100 <ls+0x64>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 226:	4785                	li	a5,1
 228:	02a7d763          	bge	a5,a0,256 <main+0x38>
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	02091793          	slli	a5,s2,0x20
 23c:	01d7d913          	srli	s2,a5,0x1d
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ae000ef          	jal	500 <exit>
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
    ls(".");
 25a:	00001517          	auipc	a0,0x1
 25e:	92e50513          	addi	a0,a0,-1746 # b88 <malloc+0x15c>
 262:	e3bff0ef          	jal	9c <ls>
    exit(0);
 266:	4501                	li	a0,0
 268:	298000ef          	jal	500 <exit>

000000000000026c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 274:	fabff0ef          	jal	21e <main>
  exit(r);
 278:	288000ef          	jal	500 <exit>

000000000000027c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 282:	87aa                	mv	a5,a0
 284:	0585                	addi	a1,a1,1
 286:	0785                	addi	a5,a5,1
 288:	fff5c703          	lbu	a4,-1(a1)
 28c:	fee78fa3          	sb	a4,-1(a5)
 290:	fb75                	bnez	a4,284 <strcpy+0x8>
    ;
  return os;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb91                	beqz	a5,2b6 <strcmp+0x1e>
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00f71763          	bne	a4,a5,2b6 <strcmp+0x1e>
    p++, q++;
 2ac:	0505                	addi	a0,a0,1
 2ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbe5                	bnez	a5,2a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b6:	0005c503          	lbu	a0,0(a1)
}
 2ba:	40a7853b          	subw	a0,a5,a0
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <strlen>:

uint
strlen(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf91                	beqz	a5,2ea <strlen+0x26>
 2d0:	0505                	addi	a0,a0,1
 2d2:	87aa                	mv	a5,a0
 2d4:	86be                	mv	a3,a5
 2d6:	0785                	addi	a5,a5,1
 2d8:	fff7c703          	lbu	a4,-1(a5)
 2dc:	ff65                	bnez	a4,2d4 <strlen+0x10>
 2de:	40a6853b          	subw	a0,a3,a0
 2e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strlen+0x20>

00000000000002ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f4:	ca19                	beqz	a2,30a <memset+0x1c>
 2f6:	87aa                	mv	a5,a0
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x12>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d663          	bge	s1,s4,386 <gets+0x52>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	1b2000ef          	jal	518 <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x52>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x50>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679de3          	bne	a5,s6,356 <gets+0x22>
    buf[i++] = c;
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x52>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e04a                	sd	s2,0(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b0:	4581                	li	a1,0
 3b2:	18e000ef          	jal	540 <open>
  if(fd < 0)
 3b6:	02054263          	bltz	a0,3da <stat+0x36>
 3ba:	e426                	sd	s1,8(sp)
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	198000ef          	jal	558 <fstat>
 3c4:	892a                	mv	s2,a0
  close(fd);
 3c6:	8526                	mv	a0,s1
 3c8:	160000ef          	jal	528 <close>
  return r;
 3cc:	64a2                	ld	s1,8(sp)
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6902                	ld	s2,0(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret
    return -1;
 3da:	597d                	li	s2,-1
 3dc:	bfcd                	j	3ce <stat+0x2a>

00000000000003de <atoi>:

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054683          	lbu	a3,0(a0)
 3e8:	fd06879b          	addiw	a5,a3,-48
 3ec:	0ff7f793          	zext.b	a5,a5
 3f0:	4625                	li	a2,9
 3f2:	02f66863          	bltu	a2,a5,422 <atoi+0x44>
 3f6:	872a                	mv	a4,a0
  n = 0;
 3f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fa:	0705                	addi	a4,a4,1
 3fc:	0025179b          	slliw	a5,a0,0x2
 400:	9fa9                	addw	a5,a5,a0
 402:	0017979b          	slliw	a5,a5,0x1
 406:	9fb5                	addw	a5,a5,a3
 408:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40c:	00074683          	lbu	a3,0(a4)
 410:	fd06879b          	addiw	a5,a3,-48
 414:	0ff7f793          	zext.b	a5,a5
 418:	fef671e3          	bgeu	a2,a5,3fa <atoi+0x1c>
  return n;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  n = 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <atoi+0x3e>

0000000000000426 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57463          	bgeu	a0,a1,454 <memmove+0x2e>
    while(n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x28>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
    dst += n;
 454:	00c50733          	add	a4,a0,a2
    src += n;
 458:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45a:	fec05ae3          	blez	a2,44e <memmove+0x28>
 45e:	fff6079b          	addiw	a5,a2,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	fff7c793          	not	a5,a5
 46a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46c:	15fd                	addi	a1,a1,-1
 46e:	177d                	addi	a4,a4,-1
 470:	0005c683          	lbu	a3,0(a1)
 474:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 478:	fee79ae3          	bne	a5,a4,46c <memmove+0x46>
 47c:	bfc9                	j	44e <memmove+0x28>

000000000000047e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	ca05                	beqz	a2,4b4 <memcmp+0x36>
 486:	fff6069b          	addiw	a3,a2,-1
 48a:	1682                	slli	a3,a3,0x20
 48c:	9281                	srli	a3,a3,0x20
 48e:	0685                	addi	a3,a3,1
 490:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x14>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x30>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	6422                	ld	s0,8(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfe5                	j	4ae <memcmp+0x30>

00000000000004b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e406                	sd	ra,8(sp)
 4bc:	e022                	sd	s0,0(sp)
 4be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c0:	f67ff0ef          	jal	426 <memmove>
}
 4c4:	60a2                	ld	ra,8(sp)
 4c6:	6402                	ld	s0,0(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <sbrk>:

char *
sbrk(int n) {
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d4:	4585                	li	a1,1
 4d6:	0b2000ef          	jal	588 <sys_sbrk>
}
 4da:	60a2                	ld	ra,8(sp)
 4dc:	6402                	ld	s0,0(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <sbrklazy>:

char *
sbrklazy(int n) {
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e406                	sd	ra,8(sp)
 4e6:	e022                	sd	s0,0(sp)
 4e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ea:	4589                	li	a1,2
 4ec:	09c000ef          	jal	588 <sys_sbrk>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f8:	4885                	li	a7,1
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exit>:
.global exit
exit:
 li a7, SYS_exit
 500:	4889                	li	a7,2
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <wait>:
.global wait
wait:
 li a7, SYS_wait
 508:	488d                	li	a7,3
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 510:	4891                	li	a7,4
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <read>:
.global read
read:
 li a7, SYS_read
 518:	4895                	li	a7,5
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <write>:
.global write
write:
 li a7, SYS_write
 520:	48c1                	li	a7,16
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <close>:
.global close
close:
 li a7, SYS_close
 528:	48d5                	li	a7,21
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <kill>:
.global kill
kill:
 li a7, SYS_kill
 530:	4899                	li	a7,6
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <exec>:
.global exec
exec:
 li a7, SYS_exec
 538:	489d                	li	a7,7
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <open>:
.global open
open:
 li a7, SYS_open
 540:	48bd                	li	a7,15
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 548:	48c5                	li	a7,17
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 550:	48c9                	li	a7,18
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 558:	48a1                	li	a7,8
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <link>:
.global link
link:
 li a7, SYS_link
 560:	48cd                	li	a7,19
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 568:	48d1                	li	a7,20
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 570:	48a5                	li	a7,9
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <dup>:
.global dup
dup:
 li a7, SYS_dup
 578:	48a9                	li	a7,10
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 580:	48ad                	li	a7,11
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 588:	48b1                	li	a7,12
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <pause>:
.global pause
pause:
 li a7, SYS_pause
 590:	48b5                	li	a7,13
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 598:	48b9                	li	a7,14
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 5a0:	48d9                	li	a7,22
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 5a8:	48dd                	li	a7,23
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 5b0:	48e1                	li	a7,24
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 5b8:	48e5                	li	a7,25
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 5c0:	48e9                	li	a7,26
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 5c8:	48ed                	li	a7,27
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 5d0:	48f1                	li	a7,28
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 5d8:	48f5                	li	a7,29
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 5e0:	48f9                	li	a7,30
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 5e8:	48fd                	li	a7,31
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f0:	1101                	addi	sp,sp,-32
 5f2:	ec06                	sd	ra,24(sp)
 5f4:	e822                	sd	s0,16(sp)
 5f6:	1000                	addi	s0,sp,32
 5f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fc:	4605                	li	a2,1
 5fe:	fef40593          	addi	a1,s0,-17
 602:	f1fff0ef          	jal	520 <write>
}
 606:	60e2                	ld	ra,24(sp)
 608:	6442                	ld	s0,16(sp)
 60a:	6105                	addi	sp,sp,32
 60c:	8082                	ret

000000000000060e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 60e:	715d                	addi	sp,sp,-80
 610:	e486                	sd	ra,72(sp)
 612:	e0a2                	sd	s0,64(sp)
 614:	f84a                	sd	s2,48(sp)
 616:	0880                	addi	s0,sp,80
 618:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 61a:	c299                	beqz	a3,620 <printint+0x12>
 61c:	0805c363          	bltz	a1,6a2 <printint+0x94>
  neg = 0;
 620:	4881                	li	a7,0
 622:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 626:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 628:	00000517          	auipc	a0,0x0
 62c:	57050513          	addi	a0,a0,1392 # b98 <digits>
 630:	883e                	mv	a6,a5
 632:	2785                	addiw	a5,a5,1
 634:	02c5f733          	remu	a4,a1,a2
 638:	972a                	add	a4,a4,a0
 63a:	00074703          	lbu	a4,0(a4)
 63e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 642:	872e                	mv	a4,a1
 644:	02c5d5b3          	divu	a1,a1,a2
 648:	0685                	addi	a3,a3,1
 64a:	fec773e3          	bgeu	a4,a2,630 <printint+0x22>
  if(neg)
 64e:	00088b63          	beqz	a7,664 <printint+0x56>
    buf[i++] = '-';
 652:	fd078793          	addi	a5,a5,-48
 656:	97a2                	add	a5,a5,s0
 658:	02d00713          	li	a4,45
 65c:	fee78423          	sb	a4,-24(a5)
 660:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 664:	02f05a63          	blez	a5,698 <printint+0x8a>
 668:	fc26                	sd	s1,56(sp)
 66a:	f44e                	sd	s3,40(sp)
 66c:	fb840713          	addi	a4,s0,-72
 670:	00f704b3          	add	s1,a4,a5
 674:	fff70993          	addi	s3,a4,-1
 678:	99be                	add	s3,s3,a5
 67a:	37fd                	addiw	a5,a5,-1
 67c:	1782                	slli	a5,a5,0x20
 67e:	9381                	srli	a5,a5,0x20
 680:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 684:	fff4c583          	lbu	a1,-1(s1)
 688:	854a                	mv	a0,s2
 68a:	f67ff0ef          	jal	5f0 <putc>
  while(--i >= 0)
 68e:	14fd                	addi	s1,s1,-1
 690:	ff349ae3          	bne	s1,s3,684 <printint+0x76>
 694:	74e2                	ld	s1,56(sp)
 696:	79a2                	ld	s3,40(sp)
}
 698:	60a6                	ld	ra,72(sp)
 69a:	6406                	ld	s0,64(sp)
 69c:	7942                	ld	s2,48(sp)
 69e:	6161                	addi	sp,sp,80
 6a0:	8082                	ret
    x = -xx;
 6a2:	40b005b3          	neg	a1,a1
    neg = 1;
 6a6:	4885                	li	a7,1
    x = -xx;
 6a8:	bfad                	j	622 <printint+0x14>

00000000000006aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6aa:	711d                	addi	sp,sp,-96
 6ac:	ec86                	sd	ra,88(sp)
 6ae:	e8a2                	sd	s0,80(sp)
 6b0:	e0ca                	sd	s2,64(sp)
 6b2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6b4:	0005c903          	lbu	s2,0(a1)
 6b8:	28090663          	beqz	s2,944 <vprintf+0x29a>
 6bc:	e4a6                	sd	s1,72(sp)
 6be:	fc4e                	sd	s3,56(sp)
 6c0:	f852                	sd	s4,48(sp)
 6c2:	f456                	sd	s5,40(sp)
 6c4:	f05a                	sd	s6,32(sp)
 6c6:	ec5e                	sd	s7,24(sp)
 6c8:	e862                	sd	s8,16(sp)
 6ca:	e466                	sd	s9,8(sp)
 6cc:	8b2a                	mv	s6,a0
 6ce:	8a2e                	mv	s4,a1
 6d0:	8bb2                	mv	s7,a2
  state = 0;
 6d2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6d4:	4481                	li	s1,0
 6d6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6d8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6e0:	06c00c93          	li	s9,108
 6e4:	a005                	j	704 <vprintf+0x5a>
        putc(fd, c0);
 6e6:	85ca                	mv	a1,s2
 6e8:	855a                	mv	a0,s6
 6ea:	f07ff0ef          	jal	5f0 <putc>
 6ee:	a019                	j	6f4 <vprintf+0x4a>
    } else if(state == '%'){
 6f0:	03598263          	beq	s3,s5,714 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6f4:	2485                	addiw	s1,s1,1
 6f6:	8726                	mv	a4,s1
 6f8:	009a07b3          	add	a5,s4,s1
 6fc:	0007c903          	lbu	s2,0(a5)
 700:	22090a63          	beqz	s2,934 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 704:	0009079b          	sext.w	a5,s2
    if(state == 0){
 708:	fe0994e3          	bnez	s3,6f0 <vprintf+0x46>
      if(c0 == '%'){
 70c:	fd579de3          	bne	a5,s5,6e6 <vprintf+0x3c>
        state = '%';
 710:	89be                	mv	s3,a5
 712:	b7cd                	j	6f4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 714:	00ea06b3          	add	a3,s4,a4
 718:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 71c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 71e:	c681                	beqz	a3,726 <vprintf+0x7c>
 720:	9752                	add	a4,a4,s4
 722:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 726:	05878363          	beq	a5,s8,76c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 72a:	05978d63          	beq	a5,s9,784 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 72e:	07500713          	li	a4,117
 732:	0ee78763          	beq	a5,a4,820 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 736:	07800713          	li	a4,120
 73a:	12e78963          	beq	a5,a4,86c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 73e:	07000713          	li	a4,112
 742:	14e78e63          	beq	a5,a4,89e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 746:	06300713          	li	a4,99
 74a:	18e78e63          	beq	a5,a4,8e6 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 74e:	07300713          	li	a4,115
 752:	1ae78463          	beq	a5,a4,8fa <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 756:	02500713          	li	a4,37
 75a:	04e79563          	bne	a5,a4,7a4 <vprintf+0xfa>
        putc(fd, '%');
 75e:	02500593          	li	a1,37
 762:	855a                	mv	a0,s6
 764:	e8dff0ef          	jal	5f0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 768:	4981                	li	s3,0
 76a:	b769                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 76c:	008b8913          	addi	s2,s7,8
 770:	4685                	li	a3,1
 772:	4629                	li	a2,10
 774:	000ba583          	lw	a1,0(s7)
 778:	855a                	mv	a0,s6
 77a:	e95ff0ef          	jal	60e <printint>
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
 782:	bf8d                	j	6f4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 784:	06400793          	li	a5,100
 788:	02f68963          	beq	a3,a5,7ba <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 78c:	06c00793          	li	a5,108
 790:	04f68263          	beq	a3,a5,7d4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 794:	07500793          	li	a5,117
 798:	0af68063          	beq	a3,a5,838 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 79c:	07800793          	li	a5,120
 7a0:	0ef68263          	beq	a3,a5,884 <vprintf+0x1da>
        putc(fd, '%');
 7a4:	02500593          	li	a1,37
 7a8:	855a                	mv	a0,s6
 7aa:	e47ff0ef          	jal	5f0 <putc>
        putc(fd, c0);
 7ae:	85ca                	mv	a1,s2
 7b0:	855a                	mv	a0,s6
 7b2:	e3fff0ef          	jal	5f0 <putc>
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	bf35                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ba:	008b8913          	addi	s2,s7,8
 7be:	4685                	li	a3,1
 7c0:	4629                	li	a2,10
 7c2:	000bb583          	ld	a1,0(s7)
 7c6:	855a                	mv	a0,s6
 7c8:	e47ff0ef          	jal	60e <printint>
        i += 1;
 7cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ce:	8bca                	mv	s7,s2
      state = 0;
 7d0:	4981                	li	s3,0
        i += 1;
 7d2:	b70d                	j	6f4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7d4:	06400793          	li	a5,100
 7d8:	02f60763          	beq	a2,a5,806 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7dc:	07500793          	li	a5,117
 7e0:	06f60963          	beq	a2,a5,852 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7e4:	07800793          	li	a5,120
 7e8:	faf61ee3          	bne	a2,a5,7a4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ec:	008b8913          	addi	s2,s7,8
 7f0:	4681                	li	a3,0
 7f2:	4641                	li	a2,16
 7f4:	000bb583          	ld	a1,0(s7)
 7f8:	855a                	mv	a0,s6
 7fa:	e15ff0ef          	jal	60e <printint>
        i += 2;
 7fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 800:	8bca                	mv	s7,s2
      state = 0;
 802:	4981                	li	s3,0
        i += 2;
 804:	bdc5                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 806:	008b8913          	addi	s2,s7,8
 80a:	4685                	li	a3,1
 80c:	4629                	li	a2,10
 80e:	000bb583          	ld	a1,0(s7)
 812:	855a                	mv	a0,s6
 814:	dfbff0ef          	jal	60e <printint>
        i += 2;
 818:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 81a:	8bca                	mv	s7,s2
      state = 0;
 81c:	4981                	li	s3,0
        i += 2;
 81e:	bdd9                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 820:	008b8913          	addi	s2,s7,8
 824:	4681                	li	a3,0
 826:	4629                	li	a2,10
 828:	000be583          	lwu	a1,0(s7)
 82c:	855a                	mv	a0,s6
 82e:	de1ff0ef          	jal	60e <printint>
 832:	8bca                	mv	s7,s2
      state = 0;
 834:	4981                	li	s3,0
 836:	bd7d                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 838:	008b8913          	addi	s2,s7,8
 83c:	4681                	li	a3,0
 83e:	4629                	li	a2,10
 840:	000bb583          	ld	a1,0(s7)
 844:	855a                	mv	a0,s6
 846:	dc9ff0ef          	jal	60e <printint>
        i += 1;
 84a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 84c:	8bca                	mv	s7,s2
      state = 0;
 84e:	4981                	li	s3,0
        i += 1;
 850:	b555                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 852:	008b8913          	addi	s2,s7,8
 856:	4681                	li	a3,0
 858:	4629                	li	a2,10
 85a:	000bb583          	ld	a1,0(s7)
 85e:	855a                	mv	a0,s6
 860:	dafff0ef          	jal	60e <printint>
        i += 2;
 864:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 866:	8bca                	mv	s7,s2
      state = 0;
 868:	4981                	li	s3,0
        i += 2;
 86a:	b569                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 86c:	008b8913          	addi	s2,s7,8
 870:	4681                	li	a3,0
 872:	4641                	li	a2,16
 874:	000be583          	lwu	a1,0(s7)
 878:	855a                	mv	a0,s6
 87a:	d95ff0ef          	jal	60e <printint>
 87e:	8bca                	mv	s7,s2
      state = 0;
 880:	4981                	li	s3,0
 882:	bd8d                	j	6f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 884:	008b8913          	addi	s2,s7,8
 888:	4681                	li	a3,0
 88a:	4641                	li	a2,16
 88c:	000bb583          	ld	a1,0(s7)
 890:	855a                	mv	a0,s6
 892:	d7dff0ef          	jal	60e <printint>
        i += 1;
 896:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 898:	8bca                	mv	s7,s2
      state = 0;
 89a:	4981                	li	s3,0
        i += 1;
 89c:	bda1                	j	6f4 <vprintf+0x4a>
 89e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8a0:	008b8d13          	addi	s10,s7,8
 8a4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8a8:	03000593          	li	a1,48
 8ac:	855a                	mv	a0,s6
 8ae:	d43ff0ef          	jal	5f0 <putc>
  putc(fd, 'x');
 8b2:	07800593          	li	a1,120
 8b6:	855a                	mv	a0,s6
 8b8:	d39ff0ef          	jal	5f0 <putc>
 8bc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8be:	00000b97          	auipc	s7,0x0
 8c2:	2dab8b93          	addi	s7,s7,730 # b98 <digits>
 8c6:	03c9d793          	srli	a5,s3,0x3c
 8ca:	97de                	add	a5,a5,s7
 8cc:	0007c583          	lbu	a1,0(a5)
 8d0:	855a                	mv	a0,s6
 8d2:	d1fff0ef          	jal	5f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8d6:	0992                	slli	s3,s3,0x4
 8d8:	397d                	addiw	s2,s2,-1
 8da:	fe0916e3          	bnez	s2,8c6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8de:	8bea                	mv	s7,s10
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	6d02                	ld	s10,0(sp)
 8e4:	bd01                	j	6f4 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8e6:	008b8913          	addi	s2,s7,8
 8ea:	000bc583          	lbu	a1,0(s7)
 8ee:	855a                	mv	a0,s6
 8f0:	d01ff0ef          	jal	5f0 <putc>
 8f4:	8bca                	mv	s7,s2
      state = 0;
 8f6:	4981                	li	s3,0
 8f8:	bbf5                	j	6f4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8fa:	008b8993          	addi	s3,s7,8
 8fe:	000bb903          	ld	s2,0(s7)
 902:	00090f63          	beqz	s2,920 <vprintf+0x276>
        for(; *s; s++)
 906:	00094583          	lbu	a1,0(s2)
 90a:	c195                	beqz	a1,92e <vprintf+0x284>
          putc(fd, *s);
 90c:	855a                	mv	a0,s6
 90e:	ce3ff0ef          	jal	5f0 <putc>
        for(; *s; s++)
 912:	0905                	addi	s2,s2,1
 914:	00094583          	lbu	a1,0(s2)
 918:	f9f5                	bnez	a1,90c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 91a:	8bce                	mv	s7,s3
      state = 0;
 91c:	4981                	li	s3,0
 91e:	bbd9                	j	6f4 <vprintf+0x4a>
          s = "(null)";
 920:	00000917          	auipc	s2,0x0
 924:	27090913          	addi	s2,s2,624 # b90 <malloc+0x164>
        for(; *s; s++)
 928:	02800593          	li	a1,40
 92c:	b7c5                	j	90c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 92e:	8bce                	mv	s7,s3
      state = 0;
 930:	4981                	li	s3,0
 932:	b3c9                	j	6f4 <vprintf+0x4a>
 934:	64a6                	ld	s1,72(sp)
 936:	79e2                	ld	s3,56(sp)
 938:	7a42                	ld	s4,48(sp)
 93a:	7aa2                	ld	s5,40(sp)
 93c:	7b02                	ld	s6,32(sp)
 93e:	6be2                	ld	s7,24(sp)
 940:	6c42                	ld	s8,16(sp)
 942:	6ca2                	ld	s9,8(sp)
    }
  }
}
 944:	60e6                	ld	ra,88(sp)
 946:	6446                	ld	s0,80(sp)
 948:	6906                	ld	s2,64(sp)
 94a:	6125                	addi	sp,sp,96
 94c:	8082                	ret

000000000000094e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 94e:	715d                	addi	sp,sp,-80
 950:	ec06                	sd	ra,24(sp)
 952:	e822                	sd	s0,16(sp)
 954:	1000                	addi	s0,sp,32
 956:	e010                	sd	a2,0(s0)
 958:	e414                	sd	a3,8(s0)
 95a:	e818                	sd	a4,16(s0)
 95c:	ec1c                	sd	a5,24(s0)
 95e:	03043023          	sd	a6,32(s0)
 962:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 966:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 96a:	8622                	mv	a2,s0
 96c:	d3fff0ef          	jal	6aa <vprintf>
}
 970:	60e2                	ld	ra,24(sp)
 972:	6442                	ld	s0,16(sp)
 974:	6161                	addi	sp,sp,80
 976:	8082                	ret

0000000000000978 <printf>:

void
printf(const char *fmt, ...)
{
 978:	711d                	addi	sp,sp,-96
 97a:	ec06                	sd	ra,24(sp)
 97c:	e822                	sd	s0,16(sp)
 97e:	1000                	addi	s0,sp,32
 980:	e40c                	sd	a1,8(s0)
 982:	e810                	sd	a2,16(s0)
 984:	ec14                	sd	a3,24(s0)
 986:	f018                	sd	a4,32(s0)
 988:	f41c                	sd	a5,40(s0)
 98a:	03043823          	sd	a6,48(s0)
 98e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 992:	00840613          	addi	a2,s0,8
 996:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 99a:	85aa                	mv	a1,a0
 99c:	4505                	li	a0,1
 99e:	d0dff0ef          	jal	6aa <vprintf>
}
 9a2:	60e2                	ld	ra,24(sp)
 9a4:	6442                	ld	s0,16(sp)
 9a6:	6125                	addi	sp,sp,96
 9a8:	8082                	ret

00000000000009aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9aa:	1141                	addi	sp,sp,-16
 9ac:	e422                	sd	s0,8(sp)
 9ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b4:	00000797          	auipc	a5,0x0
 9b8:	64c7b783          	ld	a5,1612(a5) # 1000 <freep>
 9bc:	a02d                	j	9e6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9be:	4618                	lw	a4,8(a2)
 9c0:	9f2d                	addw	a4,a4,a1
 9c2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	6398                	ld	a4,0(a5)
 9c8:	6310                	ld	a2,0(a4)
 9ca:	a83d                	j	a08 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9cc:	ff852703          	lw	a4,-8(a0)
 9d0:	9f31                	addw	a4,a4,a2
 9d2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9d4:	ff053683          	ld	a3,-16(a0)
 9d8:	a091                	j	a1c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9da:	6398                	ld	a4,0(a5)
 9dc:	00e7e463          	bltu	a5,a4,9e4 <free+0x3a>
 9e0:	00e6ea63          	bltu	a3,a4,9f4 <free+0x4a>
{
 9e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9e6:	fed7fae3          	bgeu	a5,a3,9da <free+0x30>
 9ea:	6398                	ld	a4,0(a5)
 9ec:	00e6e463          	bltu	a3,a4,9f4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9f0:	fee7eae3          	bltu	a5,a4,9e4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9f4:	ff852583          	lw	a1,-8(a0)
 9f8:	6390                	ld	a2,0(a5)
 9fa:	02059813          	slli	a6,a1,0x20
 9fe:	01c85713          	srli	a4,a6,0x1c
 a02:	9736                	add	a4,a4,a3
 a04:	fae60de3          	beq	a2,a4,9be <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a08:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a0c:	4790                	lw	a2,8(a5)
 a0e:	02061593          	slli	a1,a2,0x20
 a12:	01c5d713          	srli	a4,a1,0x1c
 a16:	973e                	add	a4,a4,a5
 a18:	fae68ae3          	beq	a3,a4,9cc <free+0x22>
    p->s.ptr = bp->s.ptr;
 a1c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a1e:	00000717          	auipc	a4,0x0
 a22:	5ef73123          	sd	a5,1506(a4) # 1000 <freep>
}
 a26:	6422                	ld	s0,8(sp)
 a28:	0141                	addi	sp,sp,16
 a2a:	8082                	ret

0000000000000a2c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a2c:	7139                	addi	sp,sp,-64
 a2e:	fc06                	sd	ra,56(sp)
 a30:	f822                	sd	s0,48(sp)
 a32:	f426                	sd	s1,40(sp)
 a34:	ec4e                	sd	s3,24(sp)
 a36:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a38:	02051493          	slli	s1,a0,0x20
 a3c:	9081                	srli	s1,s1,0x20
 a3e:	04bd                	addi	s1,s1,15
 a40:	8091                	srli	s1,s1,0x4
 a42:	0014899b          	addiw	s3,s1,1
 a46:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a48:	00000517          	auipc	a0,0x0
 a4c:	5b853503          	ld	a0,1464(a0) # 1000 <freep>
 a50:	c915                	beqz	a0,a84 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a52:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a54:	4798                	lw	a4,8(a5)
 a56:	08977a63          	bgeu	a4,s1,aea <malloc+0xbe>
 a5a:	f04a                	sd	s2,32(sp)
 a5c:	e852                	sd	s4,16(sp)
 a5e:	e456                	sd	s5,8(sp)
 a60:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a62:	8a4e                	mv	s4,s3
 a64:	0009871b          	sext.w	a4,s3
 a68:	6685                	lui	a3,0x1
 a6a:	00d77363          	bgeu	a4,a3,a70 <malloc+0x44>
 a6e:	6a05                	lui	s4,0x1
 a70:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a74:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a78:	00000917          	auipc	s2,0x0
 a7c:	58890913          	addi	s2,s2,1416 # 1000 <freep>
  if(p == SBRK_ERROR)
 a80:	5afd                	li	s5,-1
 a82:	a081                	j	ac2 <malloc+0x96>
 a84:	f04a                	sd	s2,32(sp)
 a86:	e852                	sd	s4,16(sp)
 a88:	e456                	sd	s5,8(sp)
 a8a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a8c:	00000797          	auipc	a5,0x0
 a90:	59478793          	addi	a5,a5,1428 # 1020 <base>
 a94:	00000717          	auipc	a4,0x0
 a98:	56f73623          	sd	a5,1388(a4) # 1000 <freep>
 a9c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a9e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 aa2:	b7c1                	j	a62 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 aa4:	6398                	ld	a4,0(a5)
 aa6:	e118                	sd	a4,0(a0)
 aa8:	a8a9                	j	b02 <malloc+0xd6>
  hp->s.size = nu;
 aaa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aae:	0541                	addi	a0,a0,16
 ab0:	efbff0ef          	jal	9aa <free>
  return freep;
 ab4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ab8:	c12d                	beqz	a0,b1a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 abc:	4798                	lw	a4,8(a5)
 abe:	02977263          	bgeu	a4,s1,ae2 <malloc+0xb6>
    if(p == freep)
 ac2:	00093703          	ld	a4,0(s2)
 ac6:	853e                	mv	a0,a5
 ac8:	fef719e3          	bne	a4,a5,aba <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 acc:	8552                	mv	a0,s4
 ace:	9ffff0ef          	jal	4cc <sbrk>
  if(p == SBRK_ERROR)
 ad2:	fd551ce3          	bne	a0,s5,aaa <malloc+0x7e>
        return 0;
 ad6:	4501                	li	a0,0
 ad8:	7902                	ld	s2,32(sp)
 ada:	6a42                	ld	s4,16(sp)
 adc:	6aa2                	ld	s5,8(sp)
 ade:	6b02                	ld	s6,0(sp)
 ae0:	a03d                	j	b0e <malloc+0xe2>
 ae2:	7902                	ld	s2,32(sp)
 ae4:	6a42                	ld	s4,16(sp)
 ae6:	6aa2                	ld	s5,8(sp)
 ae8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aea:	fae48de3          	beq	s1,a4,aa4 <malloc+0x78>
        p->s.size -= nunits;
 aee:	4137073b          	subw	a4,a4,s3
 af2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 af4:	02071693          	slli	a3,a4,0x20
 af8:	01c6d713          	srli	a4,a3,0x1c
 afc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 afe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b02:	00000717          	auipc	a4,0x0
 b06:	4ea73f23          	sd	a0,1278(a4) # 1000 <freep>
      return (void*)(p + 1);
 b0a:	01078513          	addi	a0,a5,16
  }
}
 b0e:	70e2                	ld	ra,56(sp)
 b10:	7442                	ld	s0,48(sp)
 b12:	74a2                	ld	s1,40(sp)
 b14:	69e2                	ld	s3,24(sp)
 b16:	6121                	addi	sp,sp,64
 b18:	8082                	ret
 b1a:	7902                	ld	s2,32(sp)
 b1c:	6a42                	ld	s4,16(sp)
 b1e:	6aa2                	ld	s5,8(sp)
 b20:	6b02                	ld	s6,0(sp)
 b22:	b7f5                	j	b0e <malloc+0xe2>
