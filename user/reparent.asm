
user/_reparent:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_tree>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void print_tree(struct proc_tree *t, int rootpid)
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	e8ca                	sd	s2,80(sp)
   8:	1880                	addi	s0,sp,112
   a:	892e                	mv	s2,a1
  for (int i = 0; i < t->count; i++) {
   c:	410c                	lw	a1,0(a0)
   e:	0ab05a63          	blez	a1,c2 <print_tree+0xc2>
  12:	eca6                	sd	s1,88(sp)
  14:	e4ce                	sd	s3,72(sp)
  16:	e0d2                	sd	s4,64(sp)
  18:	fc56                	sd	s5,56(sp)
  1a:	f85a                	sd	s6,48(sp)
  1c:	f45e                	sd	s7,40(sp)
  1e:	f062                	sd	s8,32(sp)
  20:	ec66                	sd	s9,24(sp)
  22:	e86a                	sd	s10,16(sp)
  24:	e46e                	sd	s11,8(sp)
  26:	89aa                	mv	s3,a0
  28:	01450a93          	addi	s5,a0,20
  2c:	8b56                	mv	s6,s5
  2e:	4c01                	li	s8,0
    struct proc_info *pi = &t->processes[i];
    // Only show processes in this subtree
    int depth = 0;
  30:	4a01                	li	s4,0
      if (!found) break; // parent not in captured tree
    }
    if (!in_subtree) continue;
    // print indentation
    for (int d = 0; d < depth; d++) printf("  ");
    printf("%d\n", pi->pid);
  32:	00001d17          	auipc	s10,0x1
  36:	a76d0d13          	addi	s10,s10,-1418 # aa8 <malloc+0x108>
    for (int d = 0; d < depth; d++) printf("  ");
  3a:	00001b97          	auipc	s7,0x1
  3e:	a66b8b93          	addi	s7,s7,-1434 # aa0 <malloc+0x100>
  42:	a8b9                	j	a0 <print_tree+0xa0>
        depth++;
  44:	2485                	addiw	s1,s1,1
    for (int d = 0; d < depth; d++) printf("  ");
  46:	00905963          	blez	s1,58 <print_tree+0x58>
  4a:	8dd2                	mv	s11,s4
  4c:	855e                	mv	a0,s7
  4e:	09f000ef          	jal	8ec <printf>
  52:	2d85                	addiw	s11,s11,1
  54:	fe9d9ce3          	bne	s11,s1,4c <print_tree+0x4c>
    printf("%d\n", pi->pid);
  58:	000ca583          	lw	a1,0(s9)
  5c:	856a                	mv	a0,s10
  5e:	08f000ef          	jal	8ec <printf>
  62:	a80d                	j	94 <print_tree+0x94>
          depth++;
  64:	2485                	addiw	s1,s1,1
          cur_ppid = t->processes[j].ppid;
  66:	00379713          	slli	a4,a5,0x3
  6a:	40f707b3          	sub	a5,a4,a5
  6e:	078a                	slli	a5,a5,0x2
  70:	97ce                	add	a5,a5,s3
  72:	4f90                	lw	a2,24(a5)
    while (!in_subtree && cur_ppid != 0) {
  74:	fd2509e3          	beq	a0,s2,46 <print_tree+0x46>
  78:	ce11                	beqz	a2,94 <print_tree+0x94>
      if (cur_ppid == rootpid) {
  7a:	fd2605e3          	beq	a2,s2,44 <print_tree+0x44>
      for (int j = 0; j < t->count; j++) {
  7e:	00b05b63          	blez	a1,94 <print_tree+0x94>
  82:	8756                	mv	a4,s5
  84:	87d2                	mv	a5,s4
        if (t->processes[j].pid == cur_ppid) {
  86:	4314                	lw	a3,0(a4)
  88:	fcc68ee3          	beq	a3,a2,64 <print_tree+0x64>
      for (int j = 0; j < t->count; j++) {
  8c:	2785                	addiw	a5,a5,1
  8e:	0771                	addi	a4,a4,28
  90:	feb79be3          	bne	a5,a1,86 <print_tree+0x86>
  for (int i = 0; i < t->count; i++) {
  94:	2c05                	addiw	s8,s8,1
  96:	0009a583          	lw	a1,0(s3)
  9a:	0b71                	addi	s6,s6,28
  9c:	00bc5963          	bge	s8,a1,ae <print_tree+0xae>
    int cur_ppid = pi->ppid;
  a0:	8cda                	mv	s9,s6
  a2:	004b2603          	lw	a2,4(s6)
    int in_subtree = (pi->pid == rootpid);
  a6:	000b2503          	lw	a0,0(s6)
    int depth = 0;
  aa:	84d2                	mv	s1,s4
    while (!in_subtree && cur_ppid != 0) {
  ac:	b7e1                	j	74 <print_tree+0x74>
  ae:	64e6                	ld	s1,88(sp)
  b0:	69a6                	ld	s3,72(sp)
  b2:	6a06                	ld	s4,64(sp)
  b4:	7ae2                	ld	s5,56(sp)
  b6:	7b42                	ld	s6,48(sp)
  b8:	7ba2                	ld	s7,40(sp)
  ba:	7c02                	ld	s8,32(sp)
  bc:	6ce2                	ld	s9,24(sp)
  be:	6d42                	ld	s10,16(sp)
  c0:	6da2                	ld	s11,8(sp)
  }
}
  c2:	70a6                	ld	ra,104(sp)
  c4:	7406                	ld	s0,96(sp)
  c6:	6946                	ld	s2,80(sp)
  c8:	6165                	addi	sp,sp,112
  ca:	8082                	ret

00000000000000cc <main>:

int
main(int argc, char *argv[])
{
  cc:	81010113          	addi	sp,sp,-2032
  d0:	7e113423          	sd	ra,2024(sp)
  d4:	7e813023          	sd	s0,2016(sp)
  d8:	7c913c23          	sd	s1,2008(sp)
  dc:	7f010413          	addi	s0,sp,2032
  e0:	9c010113          	addi	sp,sp,-1600
  int grandpid = getpid();
  e4:	410000ef          	jal	4f4 <getpid>
  e8:	84aa                	mv	s1,a0
  struct proc_tree tree;
  struct proc_tree tree_after;

  int parent_pid = fork();
  ea:	382000ef          	jal	46c <fork>
  if (parent_pid < 0) {
  ee:	02054363          	bltz	a0,114 <main+0x48>
    printf("fork failed\n");
    exit(1);
  }

  if (parent_pid == 0) {
  f2:	e931                	bnez	a0,146 <main+0x7a>
    // Parent process P
    int child_pid = fork();
  f4:	378000ef          	jal	46c <fork>
    if (child_pid < 0) {
  f8:	02054763          	bltz	a0,126 <main+0x5a>
      printf("child fork failed\n");
      exit(1);
    }
    if (child_pid == 0) {
  fc:	ed15                	bnez	a0,138 <main+0x6c>
      // Child process C: wait for parent to exit then wait a bit
      pause(60); // parent will exit earlier
  fe:	03c00513          	li	a0,60
 102:	402000ef          	jal	504 <pause>
      // wait until grandparent becomes parent
      pause(80);
 106:	05000513          	li	a0,80
 10a:	3fa000ef          	jal	504 <pause>
      exit(0);
 10e:	4501                	li	a0,0
 110:	364000ef          	jal	474 <exit>
    printf("fork failed\n");
 114:	00001517          	auipc	a0,0x1
 118:	99c50513          	addi	a0,a0,-1636 # ab0 <malloc+0x110>
 11c:	7d0000ef          	jal	8ec <printf>
    exit(1);
 120:	4505                	li	a0,1
 122:	352000ef          	jal	474 <exit>
      printf("child fork failed\n");
 126:	00001517          	auipc	a0,0x1
 12a:	99a50513          	addi	a0,a0,-1638 # ac0 <malloc+0x120>
 12e:	7be000ef          	jal	8ec <printf>
      exit(1);
 132:	4505                	li	a0,1
 134:	340000ef          	jal	474 <exit>
    }
    // parent waits a bit then exits to orphan child
    pause(40);
 138:	02800513          	li	a0,40
 13c:	3c8000ef          	jal	504 <pause>
    exit(0);
 140:	4501                	li	a0,0
 142:	332000ef          	jal	474 <exit>
  }

  // Grandparent process G
  // Allow parent & child to be created
  pause(20);
 146:	4551                	li	a0,20
 148:	3bc000ef          	jal	504 <pause>
  if (ptree(grandpid, &tree) == 0) {
 14c:	8d840593          	addi	a1,s0,-1832
 150:	8526                	mv	a0,s1
 152:	3ca000ef          	jal	51c <ptree>
 156:	e53d                	bnez	a0,1c4 <main+0xf8>
    printf("Before parent exit (expected G->P->C):\n");
 158:	00001517          	auipc	a0,0x1
 15c:	98050513          	addi	a0,a0,-1664 # ad8 <malloc+0x138>
 160:	78c000ef          	jal	8ec <printf>
    print_tree(&tree, grandpid);
 164:	85a6                	mv	a1,s1
 166:	8d840513          	addi	a0,s0,-1832
 16a:	e97ff0ef          	jal	0 <print_tree>
  } else {
    printf("ptree failed (before)\n");
  }

  // wait for parent to exit
  wait(0);
 16e:	4501                	li	a0,0
 170:	30c000ef          	jal	47c <wait>

  // Give kernel time to perform reparent
  pause(30);
 174:	4579                	li	a0,30
 176:	38e000ef          	jal	504 <pause>
  if (ptree(grandpid, &tree_after) == 0) {
 17a:	75fd                	lui	a1,0xfffff
 17c:	1d058793          	addi	a5,a1,464 # fffffffffffff1d0 <base+0xffffffffffffe1c0>
 180:	008785b3          	add	a1,a5,s0
 184:	8526                	mv	a0,s1
 186:	396000ef          	jal	51c <ptree>
 18a:	e521                	bnez	a0,1d2 <main+0x106>
    printf("After parent exit (expected G->C):\n");
 18c:	00001517          	auipc	a0,0x1
 190:	98c50513          	addi	a0,a0,-1652 # b18 <malloc+0x178>
 194:	758000ef          	jal	8ec <printf>
    print_tree(&tree_after, grandpid);
 198:	757d                	lui	a0,0xfffff
 19a:	85a6                	mv	a1,s1
 19c:	1d050793          	addi	a5,a0,464 # fffffffffffff1d0 <base+0xffffffffffffe1c0>
 1a0:	00878533          	add	a0,a5,s0
 1a4:	e5dff0ef          	jal	0 <print_tree>
  } else {
    printf("ptree failed (after)\n");
  }

  // reap orphaned child now adopted by grandparent
  while (wait(0) > 0) {}
 1a8:	4501                	li	a0,0
 1aa:	2d2000ef          	jal	47c <wait>
 1ae:	fea04de3          	bgtz	a0,1a8 <main+0xdc>

  printf("reparent_simple test done\n");
 1b2:	00001517          	auipc	a0,0x1
 1b6:	9a650513          	addi	a0,a0,-1626 # b58 <malloc+0x1b8>
 1ba:	732000ef          	jal	8ec <printf>
  exit(0);
 1be:	4501                	li	a0,0
 1c0:	2b4000ef          	jal	474 <exit>
    printf("ptree failed (before)\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	93c50513          	addi	a0,a0,-1732 # b00 <malloc+0x160>
 1cc:	720000ef          	jal	8ec <printf>
 1d0:	bf79                	j	16e <main+0xa2>
    printf("ptree failed (after)\n");
 1d2:	00001517          	auipc	a0,0x1
 1d6:	96e50513          	addi	a0,a0,-1682 # b40 <malloc+0x1a0>
 1da:	712000ef          	jal	8ec <printf>
 1de:	b7e9                	j	1a8 <main+0xdc>

00000000000001e0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1e8:	ee5ff0ef          	jal	cc <main>
  exit(r);
 1ec:	288000ef          	jal	474 <exit>

00000000000001f0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f6:	87aa                	mv	a5,a0
 1f8:	0585                	addi	a1,a1,1
 1fa:	0785                	addi	a5,a5,1
 1fc:	fff5c703          	lbu	a4,-1(a1)
 200:	fee78fa3          	sb	a4,-1(a5)
 204:	fb75                	bnez	a4,1f8 <strcpy+0x8>
    ;
  return os;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret

000000000000020c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0)
 216:	cb91                	beqz	a5,22a <strcmp+0x1e>
 218:	0005c703          	lbu	a4,0(a1)
 21c:	00f71763          	bne	a4,a5,22a <strcmp+0x1e>
    p++, q++;
 220:	0505                	addi	a0,a0,1
 222:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 224:	00054783          	lbu	a5,0(a0)
 228:	fbe5                	bnez	a5,218 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22a:	0005c503          	lbu	a0,0(a1)
}
 22e:	40a7853b          	subw	a0,a5,a0
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strlen>:

uint
strlen(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cf91                	beqz	a5,25e <strlen+0x26>
 244:	0505                	addi	a0,a0,1
 246:	87aa                	mv	a5,a0
 248:	86be                	mv	a3,a5
 24a:	0785                	addi	a5,a5,1
 24c:	fff7c703          	lbu	a4,-1(a5)
 250:	ff65                	bnez	a4,248 <strlen+0x10>
 252:	40a6853b          	subw	a0,a3,a0
 256:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  for(n = 0; s[n]; n++)
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <strlen+0x20>

0000000000000262 <memset>:

void*
memset(void *dst, int c, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 268:	ca19                	beqz	a2,27e <memset+0x1c>
 26a:	87aa                	mv	a5,a0
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 274:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 278:	0785                	addi	a5,a5,1
 27a:	fee79de3          	bne	a5,a4,274 <memset+0x12>
  }
  return dst;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret

0000000000000284 <strchr>:

char*
strchr(const char *s, char c)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28a:	00054783          	lbu	a5,0(a0)
 28e:	cb99                	beqz	a5,2a4 <strchr+0x20>
    if(*s == c)
 290:	00f58763          	beq	a1,a5,29e <strchr+0x1a>
  for(; *s; s++)
 294:	0505                	addi	a0,a0,1
 296:	00054783          	lbu	a5,0(a0)
 29a:	fbfd                	bnez	a5,290 <strchr+0xc>
      return (char*)s;
  return 0;
 29c:	4501                	li	a0,0
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  return 0;
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <strchr+0x1a>

00000000000002a8 <gets>:

char*
gets(char *buf, int max)
{
 2a8:	711d                	addi	sp,sp,-96
 2aa:	ec86                	sd	ra,88(sp)
 2ac:	e8a2                	sd	s0,80(sp)
 2ae:	e4a6                	sd	s1,72(sp)
 2b0:	e0ca                	sd	s2,64(sp)
 2b2:	fc4e                	sd	s3,56(sp)
 2b4:	f852                	sd	s4,48(sp)
 2b6:	f456                	sd	s5,40(sp)
 2b8:	f05a                	sd	s6,32(sp)
 2ba:	ec5e                	sd	s7,24(sp)
 2bc:	1080                	addi	s0,sp,96
 2be:	8baa                	mv	s7,a0
 2c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c2:	892a                	mv	s2,a0
 2c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c6:	4aa9                	li	s5,10
 2c8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ca:	89a6                	mv	s3,s1
 2cc:	2485                	addiw	s1,s1,1
 2ce:	0344d663          	bge	s1,s4,2fa <gets+0x52>
    cc = read(0, &c, 1);
 2d2:	4605                	li	a2,1
 2d4:	faf40593          	addi	a1,s0,-81
 2d8:	4501                	li	a0,0
 2da:	1b2000ef          	jal	48c <read>
    if(cc < 1)
 2de:	00a05e63          	blez	a0,2fa <gets+0x52>
    buf[i++] = c;
 2e2:	faf44783          	lbu	a5,-81(s0)
 2e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ea:	01578763          	beq	a5,s5,2f8 <gets+0x50>
 2ee:	0905                	addi	s2,s2,1
 2f0:	fd679de3          	bne	a5,s6,2ca <gets+0x22>
    buf[i++] = c;
 2f4:	89a6                	mv	s3,s1
 2f6:	a011                	j	2fa <gets+0x52>
 2f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fa:	99de                	add	s3,s3,s7
 2fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 300:	855e                	mv	a0,s7
 302:	60e6                	ld	ra,88(sp)
 304:	6446                	ld	s0,80(sp)
 306:	64a6                	ld	s1,72(sp)
 308:	6906                	ld	s2,64(sp)
 30a:	79e2                	ld	s3,56(sp)
 30c:	7a42                	ld	s4,48(sp)
 30e:	7aa2                	ld	s5,40(sp)
 310:	7b02                	ld	s6,32(sp)
 312:	6be2                	ld	s7,24(sp)
 314:	6125                	addi	sp,sp,96
 316:	8082                	ret

0000000000000318 <stat>:

int
stat(const char *n, struct stat *st)
{
 318:	1101                	addi	sp,sp,-32
 31a:	ec06                	sd	ra,24(sp)
 31c:	e822                	sd	s0,16(sp)
 31e:	e04a                	sd	s2,0(sp)
 320:	1000                	addi	s0,sp,32
 322:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 324:	4581                	li	a1,0
 326:	18e000ef          	jal	4b4 <open>
  if(fd < 0)
 32a:	02054263          	bltz	a0,34e <stat+0x36>
 32e:	e426                	sd	s1,8(sp)
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	198000ef          	jal	4cc <fstat>
 338:	892a                	mv	s2,a0
  close(fd);
 33a:	8526                	mv	a0,s1
 33c:	160000ef          	jal	49c <close>
  return r;
 340:	64a2                	ld	s1,8(sp)
}
 342:	854a                	mv	a0,s2
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	597d                	li	s2,-1
 350:	bfcd                	j	342 <stat+0x2a>

0000000000000352 <atoi>:

int
atoi(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 358:	00054683          	lbu	a3,0(a0)
 35c:	fd06879b          	addiw	a5,a3,-48
 360:	0ff7f793          	zext.b	a5,a5
 364:	4625                	li	a2,9
 366:	02f66863          	bltu	a2,a5,396 <atoi+0x44>
 36a:	872a                	mv	a4,a0
  n = 0;
 36c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 36e:	0705                	addi	a4,a4,1
 370:	0025179b          	slliw	a5,a0,0x2
 374:	9fa9                	addw	a5,a5,a0
 376:	0017979b          	slliw	a5,a5,0x1
 37a:	9fb5                	addw	a5,a5,a3
 37c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 380:	00074683          	lbu	a3,0(a4)
 384:	fd06879b          	addiw	a5,a3,-48
 388:	0ff7f793          	zext.b	a5,a5
 38c:	fef671e3          	bgeu	a2,a5,36e <atoi+0x1c>
  return n;
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  n = 0;
 396:	4501                	li	a0,0
 398:	bfe5                	j	390 <atoi+0x3e>

000000000000039a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e422                	sd	s0,8(sp)
 39e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a0:	02b57463          	bgeu	a0,a1,3c8 <memmove+0x2e>
    while(n-- > 0)
 3a4:	00c05f63          	blez	a2,3c2 <memmove+0x28>
 3a8:	1602                	slli	a2,a2,0x20
 3aa:	9201                	srli	a2,a2,0x20
 3ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b2:	0585                	addi	a1,a1,1
 3b4:	0705                	addi	a4,a4,1
 3b6:	fff5c683          	lbu	a3,-1(a1)
 3ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3be:	fef71ae3          	bne	a4,a5,3b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ce:	fec05ae3          	blez	a2,3c2 <memmove+0x28>
 3d2:	fff6079b          	addiw	a5,a2,-1
 3d6:	1782                	slli	a5,a5,0x20
 3d8:	9381                	srli	a5,a5,0x20
 3da:	fff7c793          	not	a5,a5
 3de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e0:	15fd                	addi	a1,a1,-1
 3e2:	177d                	addi	a4,a4,-1
 3e4:	0005c683          	lbu	a3,0(a1)
 3e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ec:	fee79ae3          	bne	a5,a4,3e0 <memmove+0x46>
 3f0:	bfc9                	j	3c2 <memmove+0x28>

00000000000003f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e422                	sd	s0,8(sp)
 3f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f8:	ca05                	beqz	a2,428 <memcmp+0x36>
 3fa:	fff6069b          	addiw	a3,a2,-1
 3fe:	1682                	slli	a3,a3,0x20
 400:	9281                	srli	a3,a3,0x20
 402:	0685                	addi	a3,a3,1
 404:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 406:	00054783          	lbu	a5,0(a0)
 40a:	0005c703          	lbu	a4,0(a1)
 40e:	00e79863          	bne	a5,a4,41e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 412:	0505                	addi	a0,a0,1
    p2++;
 414:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 416:	fed518e3          	bne	a0,a3,406 <memcmp+0x14>
  }
  return 0;
 41a:	4501                	li	a0,0
 41c:	a019                	j	422 <memcmp+0x30>
      return *p1 - *p2;
 41e:	40e7853b          	subw	a0,a5,a4
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
  return 0;
 428:	4501                	li	a0,0
 42a:	bfe5                	j	422 <memcmp+0x30>

000000000000042c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 434:	f67ff0ef          	jal	39a <memmove>
}
 438:	60a2                	ld	ra,8(sp)
 43a:	6402                	ld	s0,0(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret

0000000000000440 <sbrk>:

char *
sbrk(int n) {
 440:	1141                	addi	sp,sp,-16
 442:	e406                	sd	ra,8(sp)
 444:	e022                	sd	s0,0(sp)
 446:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 448:	4585                	li	a1,1
 44a:	0b2000ef          	jal	4fc <sys_sbrk>
}
 44e:	60a2                	ld	ra,8(sp)
 450:	6402                	ld	s0,0(sp)
 452:	0141                	addi	sp,sp,16
 454:	8082                	ret

0000000000000456 <sbrklazy>:

char *
sbrklazy(int n) {
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 45e:	4589                	li	a1,2
 460:	09c000ef          	jal	4fc <sys_sbrk>
}
 464:	60a2                	ld	ra,8(sp)
 466:	6402                	ld	s0,0(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret

000000000000046c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46c:	4885                	li	a7,1
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <exit>:
.global exit
exit:
 li a7, SYS_exit
 474:	4889                	li	a7,2
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <wait>:
.global wait
wait:
 li a7, SYS_wait
 47c:	488d                	li	a7,3
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 484:	4891                	li	a7,4
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <read>:
.global read
read:
 li a7, SYS_read
 48c:	4895                	li	a7,5
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <write>:
.global write
write:
 li a7, SYS_write
 494:	48c1                	li	a7,16
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <close>:
.global close
close:
 li a7, SYS_close
 49c:	48d5                	li	a7,21
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a4:	4899                	li	a7,6
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ac:	489d                	li	a7,7
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <open>:
.global open
open:
 li a7, SYS_open
 4b4:	48bd                	li	a7,15
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4bc:	48c5                	li	a7,17
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c4:	48c9                	li	a7,18
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4cc:	48a1                	li	a7,8
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <link>:
.global link
link:
 li a7, SYS_link
 4d4:	48cd                	li	a7,19
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4dc:	48d1                	li	a7,20
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e4:	48a5                	li	a7,9
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ec:	48a9                	li	a7,10
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f4:	48ad                	li	a7,11
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4fc:	48b1                	li	a7,12
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <pause>:
.global pause
pause:
 li a7, SYS_pause
 504:	48b5                	li	a7,13
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50c:	48b9                	li	a7,14
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 514:	48d9                	li	a7,22
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 51c:	48dd                	li	a7,23
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 524:	48e1                	li	a7,24
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 52c:	48e5                	li	a7,25
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 534:	48e9                	li	a7,26
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 53c:	48ed                	li	a7,27
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 544:	48f1                	li	a7,28
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 54c:	48f5                	li	a7,29
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 554:	48f9                	li	a7,30
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 55c:	48fd                	li	a7,31
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 564:	1101                	addi	sp,sp,-32
 566:	ec06                	sd	ra,24(sp)
 568:	e822                	sd	s0,16(sp)
 56a:	1000                	addi	s0,sp,32
 56c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 570:	4605                	li	a2,1
 572:	fef40593          	addi	a1,s0,-17
 576:	f1fff0ef          	jal	494 <write>
}
 57a:	60e2                	ld	ra,24(sp)
 57c:	6442                	ld	s0,16(sp)
 57e:	6105                	addi	sp,sp,32
 580:	8082                	ret

0000000000000582 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 582:	715d                	addi	sp,sp,-80
 584:	e486                	sd	ra,72(sp)
 586:	e0a2                	sd	s0,64(sp)
 588:	f84a                	sd	s2,48(sp)
 58a:	0880                	addi	s0,sp,80
 58c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 58e:	c299                	beqz	a3,594 <printint+0x12>
 590:	0805c363          	bltz	a1,616 <printint+0x94>
  neg = 0;
 594:	4881                	li	a7,0
 596:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 59a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 59c:	00000517          	auipc	a0,0x0
 5a0:	5e450513          	addi	a0,a0,1508 # b80 <digits>
 5a4:	883e                	mv	a6,a5
 5a6:	2785                	addiw	a5,a5,1
 5a8:	02c5f733          	remu	a4,a1,a2
 5ac:	972a                	add	a4,a4,a0
 5ae:	00074703          	lbu	a4,0(a4)
 5b2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5b6:	872e                	mv	a4,a1
 5b8:	02c5d5b3          	divu	a1,a1,a2
 5bc:	0685                	addi	a3,a3,1
 5be:	fec773e3          	bgeu	a4,a2,5a4 <printint+0x22>
  if(neg)
 5c2:	00088b63          	beqz	a7,5d8 <printint+0x56>
    buf[i++] = '-';
 5c6:	fd078793          	addi	a5,a5,-48
 5ca:	97a2                	add	a5,a5,s0
 5cc:	02d00713          	li	a4,45
 5d0:	fee78423          	sb	a4,-24(a5)
 5d4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5d8:	02f05a63          	blez	a5,60c <printint+0x8a>
 5dc:	fc26                	sd	s1,56(sp)
 5de:	f44e                	sd	s3,40(sp)
 5e0:	fb840713          	addi	a4,s0,-72
 5e4:	00f704b3          	add	s1,a4,a5
 5e8:	fff70993          	addi	s3,a4,-1
 5ec:	99be                	add	s3,s3,a5
 5ee:	37fd                	addiw	a5,a5,-1
 5f0:	1782                	slli	a5,a5,0x20
 5f2:	9381                	srli	a5,a5,0x20
 5f4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5f8:	fff4c583          	lbu	a1,-1(s1)
 5fc:	854a                	mv	a0,s2
 5fe:	f67ff0ef          	jal	564 <putc>
  while(--i >= 0)
 602:	14fd                	addi	s1,s1,-1
 604:	ff349ae3          	bne	s1,s3,5f8 <printint+0x76>
 608:	74e2                	ld	s1,56(sp)
 60a:	79a2                	ld	s3,40(sp)
}
 60c:	60a6                	ld	ra,72(sp)
 60e:	6406                	ld	s0,64(sp)
 610:	7942                	ld	s2,48(sp)
 612:	6161                	addi	sp,sp,80
 614:	8082                	ret
    x = -xx;
 616:	40b005b3          	neg	a1,a1
    neg = 1;
 61a:	4885                	li	a7,1
    x = -xx;
 61c:	bfad                	j	596 <printint+0x14>

000000000000061e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61e:	711d                	addi	sp,sp,-96
 620:	ec86                	sd	ra,88(sp)
 622:	e8a2                	sd	s0,80(sp)
 624:	e0ca                	sd	s2,64(sp)
 626:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 628:	0005c903          	lbu	s2,0(a1)
 62c:	28090663          	beqz	s2,8b8 <vprintf+0x29a>
 630:	e4a6                	sd	s1,72(sp)
 632:	fc4e                	sd	s3,56(sp)
 634:	f852                	sd	s4,48(sp)
 636:	f456                	sd	s5,40(sp)
 638:	f05a                	sd	s6,32(sp)
 63a:	ec5e                	sd	s7,24(sp)
 63c:	e862                	sd	s8,16(sp)
 63e:	e466                	sd	s9,8(sp)
 640:	8b2a                	mv	s6,a0
 642:	8a2e                	mv	s4,a1
 644:	8bb2                	mv	s7,a2
  state = 0;
 646:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 648:	4481                	li	s1,0
 64a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 64c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 650:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 654:	06c00c93          	li	s9,108
 658:	a005                	j	678 <vprintf+0x5a>
        putc(fd, c0);
 65a:	85ca                	mv	a1,s2
 65c:	855a                	mv	a0,s6
 65e:	f07ff0ef          	jal	564 <putc>
 662:	a019                	j	668 <vprintf+0x4a>
    } else if(state == '%'){
 664:	03598263          	beq	s3,s5,688 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 668:	2485                	addiw	s1,s1,1
 66a:	8726                	mv	a4,s1
 66c:	009a07b3          	add	a5,s4,s1
 670:	0007c903          	lbu	s2,0(a5)
 674:	22090a63          	beqz	s2,8a8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 678:	0009079b          	sext.w	a5,s2
    if(state == 0){
 67c:	fe0994e3          	bnez	s3,664 <vprintf+0x46>
      if(c0 == '%'){
 680:	fd579de3          	bne	a5,s5,65a <vprintf+0x3c>
        state = '%';
 684:	89be                	mv	s3,a5
 686:	b7cd                	j	668 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 688:	00ea06b3          	add	a3,s4,a4
 68c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 690:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 692:	c681                	beqz	a3,69a <vprintf+0x7c>
 694:	9752                	add	a4,a4,s4
 696:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 69a:	05878363          	beq	a5,s8,6e0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 69e:	05978d63          	beq	a5,s9,6f8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6a2:	07500713          	li	a4,117
 6a6:	0ee78763          	beq	a5,a4,794 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6aa:	07800713          	li	a4,120
 6ae:	12e78963          	beq	a5,a4,7e0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6b2:	07000713          	li	a4,112
 6b6:	14e78e63          	beq	a5,a4,812 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6ba:	06300713          	li	a4,99
 6be:	18e78e63          	beq	a5,a4,85a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6c2:	07300713          	li	a4,115
 6c6:	1ae78463          	beq	a5,a4,86e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6ca:	02500713          	li	a4,37
 6ce:	04e79563          	bne	a5,a4,718 <vprintf+0xfa>
        putc(fd, '%');
 6d2:	02500593          	li	a1,37
 6d6:	855a                	mv	a0,s6
 6d8:	e8dff0ef          	jal	564 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b769                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4685                	li	a3,1
 6e6:	4629                	li	a2,10
 6e8:	000ba583          	lw	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	e95ff0ef          	jal	582 <printint>
 6f2:	8bca                	mv	s7,s2
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	bf8d                	j	668 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6f8:	06400793          	li	a5,100
 6fc:	02f68963          	beq	a3,a5,72e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 700:	06c00793          	li	a5,108
 704:	04f68263          	beq	a3,a5,748 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 708:	07500793          	li	a5,117
 70c:	0af68063          	beq	a3,a5,7ac <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 710:	07800793          	li	a5,120
 714:	0ef68263          	beq	a3,a5,7f8 <vprintf+0x1da>
        putc(fd, '%');
 718:	02500593          	li	a1,37
 71c:	855a                	mv	a0,s6
 71e:	e47ff0ef          	jal	564 <putc>
        putc(fd, c0);
 722:	85ca                	mv	a1,s2
 724:	855a                	mv	a0,s6
 726:	e3fff0ef          	jal	564 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bf35                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 72e:	008b8913          	addi	s2,s7,8
 732:	4685                	li	a3,1
 734:	4629                	li	a2,10
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	e47ff0ef          	jal	582 <printint>
        i += 1;
 740:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
        i += 1;
 746:	b70d                	j	668 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 748:	06400793          	li	a5,100
 74c:	02f60763          	beq	a2,a5,77a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 750:	07500793          	li	a5,117
 754:	06f60963          	beq	a2,a5,7c6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 758:	07800793          	li	a5,120
 75c:	faf61ee3          	bne	a2,a5,718 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 760:	008b8913          	addi	s2,s7,8
 764:	4681                	li	a3,0
 766:	4641                	li	a2,16
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	e15ff0ef          	jal	582 <printint>
        i += 2;
 772:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 2;
 778:	bdc5                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4685                	li	a3,1
 780:	4629                	li	a2,10
 782:	000bb583          	ld	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	dfbff0ef          	jal	582 <printint>
        i += 2;
 78c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
        i += 2;
 792:	bdd9                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 794:	008b8913          	addi	s2,s7,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000be583          	lwu	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	de1ff0ef          	jal	582 <printint>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bd7d                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4681                	li	a3,0
 7b2:	4629                	li	a2,10
 7b4:	000bb583          	ld	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	dc9ff0ef          	jal	582 <printint>
        i += 1;
 7be:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
        i += 1;
 7c4:	b555                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c6:	008b8913          	addi	s2,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4629                	li	a2,10
 7ce:	000bb583          	ld	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	dafff0ef          	jal	582 <printint>
        i += 2;
 7d8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
        i += 2;
 7de:	b569                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7e0:	008b8913          	addi	s2,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4641                	li	a2,16
 7e8:	000be583          	lwu	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	d95ff0ef          	jal	582 <printint>
 7f2:	8bca                	mv	s7,s2
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bd8d                	j	668 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7f8:	008b8913          	addi	s2,s7,8
 7fc:	4681                	li	a3,0
 7fe:	4641                	li	a2,16
 800:	000bb583          	ld	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	d7dff0ef          	jal	582 <printint>
        i += 1;
 80a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
        i += 1;
 810:	bda1                	j	668 <vprintf+0x4a>
 812:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 814:	008b8d13          	addi	s10,s7,8
 818:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 81c:	03000593          	li	a1,48
 820:	855a                	mv	a0,s6
 822:	d43ff0ef          	jal	564 <putc>
  putc(fd, 'x');
 826:	07800593          	li	a1,120
 82a:	855a                	mv	a0,s6
 82c:	d39ff0ef          	jal	564 <putc>
 830:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 832:	00000b97          	auipc	s7,0x0
 836:	34eb8b93          	addi	s7,s7,846 # b80 <digits>
 83a:	03c9d793          	srli	a5,s3,0x3c
 83e:	97de                	add	a5,a5,s7
 840:	0007c583          	lbu	a1,0(a5)
 844:	855a                	mv	a0,s6
 846:	d1fff0ef          	jal	564 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 84a:	0992                	slli	s3,s3,0x4
 84c:	397d                	addiw	s2,s2,-1
 84e:	fe0916e3          	bnez	s2,83a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 852:	8bea                	mv	s7,s10
      state = 0;
 854:	4981                	li	s3,0
 856:	6d02                	ld	s10,0(sp)
 858:	bd01                	j	668 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 85a:	008b8913          	addi	s2,s7,8
 85e:	000bc583          	lbu	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	d01ff0ef          	jal	564 <putc>
 868:	8bca                	mv	s7,s2
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bbf5                	j	668 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 86e:	008b8993          	addi	s3,s7,8
 872:	000bb903          	ld	s2,0(s7)
 876:	00090f63          	beqz	s2,894 <vprintf+0x276>
        for(; *s; s++)
 87a:	00094583          	lbu	a1,0(s2)
 87e:	c195                	beqz	a1,8a2 <vprintf+0x284>
          putc(fd, *s);
 880:	855a                	mv	a0,s6
 882:	ce3ff0ef          	jal	564 <putc>
        for(; *s; s++)
 886:	0905                	addi	s2,s2,1
 888:	00094583          	lbu	a1,0(s2)
 88c:	f9f5                	bnez	a1,880 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 88e:	8bce                	mv	s7,s3
      state = 0;
 890:	4981                	li	s3,0
 892:	bbd9                	j	668 <vprintf+0x4a>
          s = "(null)";
 894:	00000917          	auipc	s2,0x0
 898:	2e490913          	addi	s2,s2,740 # b78 <malloc+0x1d8>
        for(; *s; s++)
 89c:	02800593          	li	a1,40
 8a0:	b7c5                	j	880 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8a2:	8bce                	mv	s7,s3
      state = 0;
 8a4:	4981                	li	s3,0
 8a6:	b3c9                	j	668 <vprintf+0x4a>
 8a8:	64a6                	ld	s1,72(sp)
 8aa:	79e2                	ld	s3,56(sp)
 8ac:	7a42                	ld	s4,48(sp)
 8ae:	7aa2                	ld	s5,40(sp)
 8b0:	7b02                	ld	s6,32(sp)
 8b2:	6be2                	ld	s7,24(sp)
 8b4:	6c42                	ld	s8,16(sp)
 8b6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8b8:	60e6                	ld	ra,88(sp)
 8ba:	6446                	ld	s0,80(sp)
 8bc:	6906                	ld	s2,64(sp)
 8be:	6125                	addi	sp,sp,96
 8c0:	8082                	ret

00000000000008c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c2:	715d                	addi	sp,sp,-80
 8c4:	ec06                	sd	ra,24(sp)
 8c6:	e822                	sd	s0,16(sp)
 8c8:	1000                	addi	s0,sp,32
 8ca:	e010                	sd	a2,0(s0)
 8cc:	e414                	sd	a3,8(s0)
 8ce:	e818                	sd	a4,16(s0)
 8d0:	ec1c                	sd	a5,24(s0)
 8d2:	03043023          	sd	a6,32(s0)
 8d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8de:	8622                	mv	a2,s0
 8e0:	d3fff0ef          	jal	61e <vprintf>
}
 8e4:	60e2                	ld	ra,24(sp)
 8e6:	6442                	ld	s0,16(sp)
 8e8:	6161                	addi	sp,sp,80
 8ea:	8082                	ret

00000000000008ec <printf>:

void
printf(const char *fmt, ...)
{
 8ec:	711d                	addi	sp,sp,-96
 8ee:	ec06                	sd	ra,24(sp)
 8f0:	e822                	sd	s0,16(sp)
 8f2:	1000                	addi	s0,sp,32
 8f4:	e40c                	sd	a1,8(s0)
 8f6:	e810                	sd	a2,16(s0)
 8f8:	ec14                	sd	a3,24(s0)
 8fa:	f018                	sd	a4,32(s0)
 8fc:	f41c                	sd	a5,40(s0)
 8fe:	03043823          	sd	a6,48(s0)
 902:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 906:	00840613          	addi	a2,s0,8
 90a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 90e:	85aa                	mv	a1,a0
 910:	4505                	li	a0,1
 912:	d0dff0ef          	jal	61e <vprintf>
}
 916:	60e2                	ld	ra,24(sp)
 918:	6442                	ld	s0,16(sp)
 91a:	6125                	addi	sp,sp,96
 91c:	8082                	ret

000000000000091e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 91e:	1141                	addi	sp,sp,-16
 920:	e422                	sd	s0,8(sp)
 922:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 924:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 928:	00000797          	auipc	a5,0x0
 92c:	6d87b783          	ld	a5,1752(a5) # 1000 <freep>
 930:	a02d                	j	95a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 932:	4618                	lw	a4,8(a2)
 934:	9f2d                	addw	a4,a4,a1
 936:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 93a:	6398                	ld	a4,0(a5)
 93c:	6310                	ld	a2,0(a4)
 93e:	a83d                	j	97c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 940:	ff852703          	lw	a4,-8(a0)
 944:	9f31                	addw	a4,a4,a2
 946:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 948:	ff053683          	ld	a3,-16(a0)
 94c:	a091                	j	990 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94e:	6398                	ld	a4,0(a5)
 950:	00e7e463          	bltu	a5,a4,958 <free+0x3a>
 954:	00e6ea63          	bltu	a3,a4,968 <free+0x4a>
{
 958:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95a:	fed7fae3          	bgeu	a5,a3,94e <free+0x30>
 95e:	6398                	ld	a4,0(a5)
 960:	00e6e463          	bltu	a3,a4,968 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 964:	fee7eae3          	bltu	a5,a4,958 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 968:	ff852583          	lw	a1,-8(a0)
 96c:	6390                	ld	a2,0(a5)
 96e:	02059813          	slli	a6,a1,0x20
 972:	01c85713          	srli	a4,a6,0x1c
 976:	9736                	add	a4,a4,a3
 978:	fae60de3          	beq	a2,a4,932 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 97c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 980:	4790                	lw	a2,8(a5)
 982:	02061593          	slli	a1,a2,0x20
 986:	01c5d713          	srli	a4,a1,0x1c
 98a:	973e                	add	a4,a4,a5
 98c:	fae68ae3          	beq	a3,a4,940 <free+0x22>
    p->s.ptr = bp->s.ptr;
 990:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 992:	00000717          	auipc	a4,0x0
 996:	66f73723          	sd	a5,1646(a4) # 1000 <freep>
}
 99a:	6422                	ld	s0,8(sp)
 99c:	0141                	addi	sp,sp,16
 99e:	8082                	ret

00000000000009a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9a0:	7139                	addi	sp,sp,-64
 9a2:	fc06                	sd	ra,56(sp)
 9a4:	f822                	sd	s0,48(sp)
 9a6:	f426                	sd	s1,40(sp)
 9a8:	ec4e                	sd	s3,24(sp)
 9aa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ac:	02051493          	slli	s1,a0,0x20
 9b0:	9081                	srli	s1,s1,0x20
 9b2:	04bd                	addi	s1,s1,15
 9b4:	8091                	srli	s1,s1,0x4
 9b6:	0014899b          	addiw	s3,s1,1
 9ba:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9bc:	00000517          	auipc	a0,0x0
 9c0:	64453503          	ld	a0,1604(a0) # 1000 <freep>
 9c4:	c915                	beqz	a0,9f8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c8:	4798                	lw	a4,8(a5)
 9ca:	08977a63          	bgeu	a4,s1,a5e <malloc+0xbe>
 9ce:	f04a                	sd	s2,32(sp)
 9d0:	e852                	sd	s4,16(sp)
 9d2:	e456                	sd	s5,8(sp)
 9d4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9d6:	8a4e                	mv	s4,s3
 9d8:	0009871b          	sext.w	a4,s3
 9dc:	6685                	lui	a3,0x1
 9de:	00d77363          	bgeu	a4,a3,9e4 <malloc+0x44>
 9e2:	6a05                	lui	s4,0x1
 9e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ec:	00000917          	auipc	s2,0x0
 9f0:	61490913          	addi	s2,s2,1556 # 1000 <freep>
  if(p == SBRK_ERROR)
 9f4:	5afd                	li	s5,-1
 9f6:	a081                	j	a36 <malloc+0x96>
 9f8:	f04a                	sd	s2,32(sp)
 9fa:	e852                	sd	s4,16(sp)
 9fc:	e456                	sd	s5,8(sp)
 9fe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a00:	00000797          	auipc	a5,0x0
 a04:	61078793          	addi	a5,a5,1552 # 1010 <base>
 a08:	00000717          	auipc	a4,0x0
 a0c:	5ef73c23          	sd	a5,1528(a4) # 1000 <freep>
 a10:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a12:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a16:	b7c1                	j	9d6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a18:	6398                	ld	a4,0(a5)
 a1a:	e118                	sd	a4,0(a0)
 a1c:	a8a9                	j	a76 <malloc+0xd6>
  hp->s.size = nu;
 a1e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a22:	0541                	addi	a0,a0,16
 a24:	efbff0ef          	jal	91e <free>
  return freep;
 a28:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a2c:	c12d                	beqz	a0,a8e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a30:	4798                	lw	a4,8(a5)
 a32:	02977263          	bgeu	a4,s1,a56 <malloc+0xb6>
    if(p == freep)
 a36:	00093703          	ld	a4,0(s2)
 a3a:	853e                	mv	a0,a5
 a3c:	fef719e3          	bne	a4,a5,a2e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a40:	8552                	mv	a0,s4
 a42:	9ffff0ef          	jal	440 <sbrk>
  if(p == SBRK_ERROR)
 a46:	fd551ce3          	bne	a0,s5,a1e <malloc+0x7e>
        return 0;
 a4a:	4501                	li	a0,0
 a4c:	7902                	ld	s2,32(sp)
 a4e:	6a42                	ld	s4,16(sp)
 a50:	6aa2                	ld	s5,8(sp)
 a52:	6b02                	ld	s6,0(sp)
 a54:	a03d                	j	a82 <malloc+0xe2>
 a56:	7902                	ld	s2,32(sp)
 a58:	6a42                	ld	s4,16(sp)
 a5a:	6aa2                	ld	s5,8(sp)
 a5c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a5e:	fae48de3          	beq	s1,a4,a18 <malloc+0x78>
        p->s.size -= nunits;
 a62:	4137073b          	subw	a4,a4,s3
 a66:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a68:	02071693          	slli	a3,a4,0x20
 a6c:	01c6d713          	srli	a4,a3,0x1c
 a70:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a72:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a76:	00000717          	auipc	a4,0x0
 a7a:	58a73523          	sd	a0,1418(a4) # 1000 <freep>
      return (void*)(p + 1);
 a7e:	01078513          	addi	a0,a5,16
  }
}
 a82:	70e2                	ld	ra,56(sp)
 a84:	7442                	ld	s0,48(sp)
 a86:	74a2                	ld	s1,40(sp)
 a88:	69e2                	ld	s3,24(sp)
 a8a:	6121                	addi	sp,sp,64
 a8c:	8082                	ret
 a8e:	7902                	ld	s2,32(sp)
 a90:	6a42                	ld	s4,16(sp)
 a92:	6aa2                	ld	s5,8(sp)
 a94:	6b02                	ld	s6,0(sp)
 a96:	b7f5                	j	a82 <malloc+0xe2>
