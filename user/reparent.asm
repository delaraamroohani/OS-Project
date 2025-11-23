
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
  36:	a36d0d13          	addi	s10,s10,-1482 # a68 <malloc+0x108>
    for (int d = 0; d < depth; d++) printf("  ");
  3a:	00001b97          	auipc	s7,0x1
  3e:	a26b8b93          	addi	s7,s7,-1498 # a60 <malloc+0x100>
  42:	a8b9                	j	a0 <print_tree+0xa0>
        depth++;
  44:	2485                	addiw	s1,s1,1
    for (int d = 0; d < depth; d++) printf("  ");
  46:	00905963          	blez	s1,58 <print_tree+0x58>
  4a:	8dd2                	mv	s11,s4
  4c:	855e                	mv	a0,s7
  4e:	05f000ef          	jal	8ac <printf>
  52:	2d85                	addiw	s11,s11,1
  54:	fe9d9ce3          	bne	s11,s1,4c <print_tree+0x4c>
    printf("%d\n", pi->pid);
  58:	000ca583          	lw	a1,0(s9)
  5c:	856a                	mv	a0,s10
  5e:	04f000ef          	jal	8ac <printf>
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
 118:	95c50513          	addi	a0,a0,-1700 # a70 <malloc+0x110>
 11c:	790000ef          	jal	8ac <printf>
    exit(1);
 120:	4505                	li	a0,1
 122:	352000ef          	jal	474 <exit>
      printf("child fork failed\n");
 126:	00001517          	auipc	a0,0x1
 12a:	95a50513          	addi	a0,a0,-1702 # a80 <malloc+0x120>
 12e:	77e000ef          	jal	8ac <printf>
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
 15c:	94050513          	addi	a0,a0,-1728 # a98 <malloc+0x138>
 160:	74c000ef          	jal	8ac <printf>
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
 190:	94c50513          	addi	a0,a0,-1716 # ad8 <malloc+0x178>
 194:	718000ef          	jal	8ac <printf>
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
 1b6:	96650513          	addi	a0,a0,-1690 # b18 <malloc+0x1b8>
 1ba:	6f2000ef          	jal	8ac <printf>
  exit(0);
 1be:	4501                	li	a0,0
 1c0:	2b4000ef          	jal	474 <exit>
    printf("ptree failed (before)\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	8fc50513          	addi	a0,a0,-1796 # ac0 <malloc+0x160>
 1cc:	6e0000ef          	jal	8ac <printf>
 1d0:	bf79                	j	16e <main+0xa2>
    printf("ptree failed (after)\n");
 1d2:	00001517          	auipc	a0,0x1
 1d6:	92e50513          	addi	a0,a0,-1746 # b00 <malloc+0x1a0>
 1da:	6d2000ef          	jal	8ac <printf>
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

0000000000000524 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 524:	1101                	addi	sp,sp,-32
 526:	ec06                	sd	ra,24(sp)
 528:	e822                	sd	s0,16(sp)
 52a:	1000                	addi	s0,sp,32
 52c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 530:	4605                	li	a2,1
 532:	fef40593          	addi	a1,s0,-17
 536:	f5fff0ef          	jal	494 <write>
}
 53a:	60e2                	ld	ra,24(sp)
 53c:	6442                	ld	s0,16(sp)
 53e:	6105                	addi	sp,sp,32
 540:	8082                	ret

0000000000000542 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 542:	715d                	addi	sp,sp,-80
 544:	e486                	sd	ra,72(sp)
 546:	e0a2                	sd	s0,64(sp)
 548:	f84a                	sd	s2,48(sp)
 54a:	0880                	addi	s0,sp,80
 54c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 54e:	c299                	beqz	a3,554 <printint+0x12>
 550:	0805c363          	bltz	a1,5d6 <printint+0x94>
  neg = 0;
 554:	4881                	li	a7,0
 556:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 55a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 55c:	00000517          	auipc	a0,0x0
 560:	5e450513          	addi	a0,a0,1508 # b40 <digits>
 564:	883e                	mv	a6,a5
 566:	2785                	addiw	a5,a5,1
 568:	02c5f733          	remu	a4,a1,a2
 56c:	972a                	add	a4,a4,a0
 56e:	00074703          	lbu	a4,0(a4)
 572:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 576:	872e                	mv	a4,a1
 578:	02c5d5b3          	divu	a1,a1,a2
 57c:	0685                	addi	a3,a3,1
 57e:	fec773e3          	bgeu	a4,a2,564 <printint+0x22>
  if(neg)
 582:	00088b63          	beqz	a7,598 <printint+0x56>
    buf[i++] = '-';
 586:	fd078793          	addi	a5,a5,-48
 58a:	97a2                	add	a5,a5,s0
 58c:	02d00713          	li	a4,45
 590:	fee78423          	sb	a4,-24(a5)
 594:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 598:	02f05a63          	blez	a5,5cc <printint+0x8a>
 59c:	fc26                	sd	s1,56(sp)
 59e:	f44e                	sd	s3,40(sp)
 5a0:	fb840713          	addi	a4,s0,-72
 5a4:	00f704b3          	add	s1,a4,a5
 5a8:	fff70993          	addi	s3,a4,-1
 5ac:	99be                	add	s3,s3,a5
 5ae:	37fd                	addiw	a5,a5,-1
 5b0:	1782                	slli	a5,a5,0x20
 5b2:	9381                	srli	a5,a5,0x20
 5b4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 5b8:	fff4c583          	lbu	a1,-1(s1)
 5bc:	854a                	mv	a0,s2
 5be:	f67ff0ef          	jal	524 <putc>
  while(--i >= 0)
 5c2:	14fd                	addi	s1,s1,-1
 5c4:	ff349ae3          	bne	s1,s3,5b8 <printint+0x76>
 5c8:	74e2                	ld	s1,56(sp)
 5ca:	79a2                	ld	s3,40(sp)
}
 5cc:	60a6                	ld	ra,72(sp)
 5ce:	6406                	ld	s0,64(sp)
 5d0:	7942                	ld	s2,48(sp)
 5d2:	6161                	addi	sp,sp,80
 5d4:	8082                	ret
    x = -xx;
 5d6:	40b005b3          	neg	a1,a1
    neg = 1;
 5da:	4885                	li	a7,1
    x = -xx;
 5dc:	bfad                	j	556 <printint+0x14>

00000000000005de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5de:	711d                	addi	sp,sp,-96
 5e0:	ec86                	sd	ra,88(sp)
 5e2:	e8a2                	sd	s0,80(sp)
 5e4:	e0ca                	sd	s2,64(sp)
 5e6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e8:	0005c903          	lbu	s2,0(a1)
 5ec:	28090663          	beqz	s2,878 <vprintf+0x29a>
 5f0:	e4a6                	sd	s1,72(sp)
 5f2:	fc4e                	sd	s3,56(sp)
 5f4:	f852                	sd	s4,48(sp)
 5f6:	f456                	sd	s5,40(sp)
 5f8:	f05a                	sd	s6,32(sp)
 5fa:	ec5e                	sd	s7,24(sp)
 5fc:	e862                	sd	s8,16(sp)
 5fe:	e466                	sd	s9,8(sp)
 600:	8b2a                	mv	s6,a0
 602:	8a2e                	mv	s4,a1
 604:	8bb2                	mv	s7,a2
  state = 0;
 606:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 608:	4481                	li	s1,0
 60a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 60c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 610:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 614:	06c00c93          	li	s9,108
 618:	a005                	j	638 <vprintf+0x5a>
        putc(fd, c0);
 61a:	85ca                	mv	a1,s2
 61c:	855a                	mv	a0,s6
 61e:	f07ff0ef          	jal	524 <putc>
 622:	a019                	j	628 <vprintf+0x4a>
    } else if(state == '%'){
 624:	03598263          	beq	s3,s5,648 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 628:	2485                	addiw	s1,s1,1
 62a:	8726                	mv	a4,s1
 62c:	009a07b3          	add	a5,s4,s1
 630:	0007c903          	lbu	s2,0(a5)
 634:	22090a63          	beqz	s2,868 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 638:	0009079b          	sext.w	a5,s2
    if(state == 0){
 63c:	fe0994e3          	bnez	s3,624 <vprintf+0x46>
      if(c0 == '%'){
 640:	fd579de3          	bne	a5,s5,61a <vprintf+0x3c>
        state = '%';
 644:	89be                	mv	s3,a5
 646:	b7cd                	j	628 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 648:	00ea06b3          	add	a3,s4,a4
 64c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 650:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 652:	c681                	beqz	a3,65a <vprintf+0x7c>
 654:	9752                	add	a4,a4,s4
 656:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 65a:	05878363          	beq	a5,s8,6a0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 65e:	05978d63          	beq	a5,s9,6b8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 662:	07500713          	li	a4,117
 666:	0ee78763          	beq	a5,a4,754 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 66a:	07800713          	li	a4,120
 66e:	12e78963          	beq	a5,a4,7a0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 672:	07000713          	li	a4,112
 676:	14e78e63          	beq	a5,a4,7d2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 67a:	06300713          	li	a4,99
 67e:	18e78e63          	beq	a5,a4,81a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 682:	07300713          	li	a4,115
 686:	1ae78463          	beq	a5,a4,82e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 68a:	02500713          	li	a4,37
 68e:	04e79563          	bne	a5,a4,6d8 <vprintf+0xfa>
        putc(fd, '%');
 692:	02500593          	li	a1,37
 696:	855a                	mv	a0,s6
 698:	e8dff0ef          	jal	524 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 69c:	4981                	li	s3,0
 69e:	b769                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000ba583          	lw	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	e95ff0ef          	jal	542 <printint>
 6b2:	8bca                	mv	s7,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bf8d                	j	628 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6b8:	06400793          	li	a5,100
 6bc:	02f68963          	beq	a3,a5,6ee <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6c0:	06c00793          	li	a5,108
 6c4:	04f68263          	beq	a3,a5,708 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 6c8:	07500793          	li	a5,117
 6cc:	0af68063          	beq	a3,a5,76c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 6d0:	07800793          	li	a5,120
 6d4:	0ef68263          	beq	a3,a5,7b8 <vprintf+0x1da>
        putc(fd, '%');
 6d8:	02500593          	li	a1,37
 6dc:	855a                	mv	a0,s6
 6de:	e47ff0ef          	jal	524 <putc>
        putc(fd, c0);
 6e2:	85ca                	mv	a1,s2
 6e4:	855a                	mv	a0,s6
 6e6:	e3fff0ef          	jal	524 <putc>
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bf35                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4685                	li	a3,1
 6f4:	4629                	li	a2,10
 6f6:	000bb583          	ld	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	e47ff0ef          	jal	542 <printint>
        i += 1;
 700:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
        i += 1;
 706:	b70d                	j	628 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 708:	06400793          	li	a5,100
 70c:	02f60763          	beq	a2,a5,73a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 710:	07500793          	li	a5,117
 714:	06f60963          	beq	a2,a5,786 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 718:	07800793          	li	a5,120
 71c:	faf61ee3          	bne	a2,a5,6d8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 720:	008b8913          	addi	s2,s7,8
 724:	4681                	li	a3,0
 726:	4641                	li	a2,16
 728:	000bb583          	ld	a1,0(s7)
 72c:	855a                	mv	a0,s6
 72e:	e15ff0ef          	jal	542 <printint>
        i += 2;
 732:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 734:	8bca                	mv	s7,s2
      state = 0;
 736:	4981                	li	s3,0
        i += 2;
 738:	bdc5                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 73a:	008b8913          	addi	s2,s7,8
 73e:	4685                	li	a3,1
 740:	4629                	li	a2,10
 742:	000bb583          	ld	a1,0(s7)
 746:	855a                	mv	a0,s6
 748:	dfbff0ef          	jal	542 <printint>
        i += 2;
 74c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 74e:	8bca                	mv	s7,s2
      state = 0;
 750:	4981                	li	s3,0
        i += 2;
 752:	bdd9                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 754:	008b8913          	addi	s2,s7,8
 758:	4681                	li	a3,0
 75a:	4629                	li	a2,10
 75c:	000be583          	lwu	a1,0(s7)
 760:	855a                	mv	a0,s6
 762:	de1ff0ef          	jal	542 <printint>
 766:	8bca                	mv	s7,s2
      state = 0;
 768:	4981                	li	s3,0
 76a:	bd7d                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 76c:	008b8913          	addi	s2,s7,8
 770:	4681                	li	a3,0
 772:	4629                	li	a2,10
 774:	000bb583          	ld	a1,0(s7)
 778:	855a                	mv	a0,s6
 77a:	dc9ff0ef          	jal	542 <printint>
        i += 1;
 77e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 780:	8bca                	mv	s7,s2
      state = 0;
 782:	4981                	li	s3,0
        i += 1;
 784:	b555                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 786:	008b8913          	addi	s2,s7,8
 78a:	4681                	li	a3,0
 78c:	4629                	li	a2,10
 78e:	000bb583          	ld	a1,0(s7)
 792:	855a                	mv	a0,s6
 794:	dafff0ef          	jal	542 <printint>
        i += 2;
 798:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 79a:	8bca                	mv	s7,s2
      state = 0;
 79c:	4981                	li	s3,0
        i += 2;
 79e:	b569                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7a0:	008b8913          	addi	s2,s7,8
 7a4:	4681                	li	a3,0
 7a6:	4641                	li	a2,16
 7a8:	000be583          	lwu	a1,0(s7)
 7ac:	855a                	mv	a0,s6
 7ae:	d95ff0ef          	jal	542 <printint>
 7b2:	8bca                	mv	s7,s2
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	bd8d                	j	628 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7b8:	008b8913          	addi	s2,s7,8
 7bc:	4681                	li	a3,0
 7be:	4641                	li	a2,16
 7c0:	000bb583          	ld	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	d7dff0ef          	jal	542 <printint>
        i += 1;
 7ca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7cc:	8bca                	mv	s7,s2
      state = 0;
 7ce:	4981                	li	s3,0
        i += 1;
 7d0:	bda1                	j	628 <vprintf+0x4a>
 7d2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7d4:	008b8d13          	addi	s10,s7,8
 7d8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7dc:	03000593          	li	a1,48
 7e0:	855a                	mv	a0,s6
 7e2:	d43ff0ef          	jal	524 <putc>
  putc(fd, 'x');
 7e6:	07800593          	li	a1,120
 7ea:	855a                	mv	a0,s6
 7ec:	d39ff0ef          	jal	524 <putc>
 7f0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f2:	00000b97          	auipc	s7,0x0
 7f6:	34eb8b93          	addi	s7,s7,846 # b40 <digits>
 7fa:	03c9d793          	srli	a5,s3,0x3c
 7fe:	97de                	add	a5,a5,s7
 800:	0007c583          	lbu	a1,0(a5)
 804:	855a                	mv	a0,s6
 806:	d1fff0ef          	jal	524 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 80a:	0992                	slli	s3,s3,0x4
 80c:	397d                	addiw	s2,s2,-1
 80e:	fe0916e3          	bnez	s2,7fa <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 812:	8bea                	mv	s7,s10
      state = 0;
 814:	4981                	li	s3,0
 816:	6d02                	ld	s10,0(sp)
 818:	bd01                	j	628 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 81a:	008b8913          	addi	s2,s7,8
 81e:	000bc583          	lbu	a1,0(s7)
 822:	855a                	mv	a0,s6
 824:	d01ff0ef          	jal	524 <putc>
 828:	8bca                	mv	s7,s2
      state = 0;
 82a:	4981                	li	s3,0
 82c:	bbf5                	j	628 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 82e:	008b8993          	addi	s3,s7,8
 832:	000bb903          	ld	s2,0(s7)
 836:	00090f63          	beqz	s2,854 <vprintf+0x276>
        for(; *s; s++)
 83a:	00094583          	lbu	a1,0(s2)
 83e:	c195                	beqz	a1,862 <vprintf+0x284>
          putc(fd, *s);
 840:	855a                	mv	a0,s6
 842:	ce3ff0ef          	jal	524 <putc>
        for(; *s; s++)
 846:	0905                	addi	s2,s2,1
 848:	00094583          	lbu	a1,0(s2)
 84c:	f9f5                	bnez	a1,840 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 84e:	8bce                	mv	s7,s3
      state = 0;
 850:	4981                	li	s3,0
 852:	bbd9                	j	628 <vprintf+0x4a>
          s = "(null)";
 854:	00000917          	auipc	s2,0x0
 858:	2e490913          	addi	s2,s2,740 # b38 <malloc+0x1d8>
        for(; *s; s++)
 85c:	02800593          	li	a1,40
 860:	b7c5                	j	840 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 862:	8bce                	mv	s7,s3
      state = 0;
 864:	4981                	li	s3,0
 866:	b3c9                	j	628 <vprintf+0x4a>
 868:	64a6                	ld	s1,72(sp)
 86a:	79e2                	ld	s3,56(sp)
 86c:	7a42                	ld	s4,48(sp)
 86e:	7aa2                	ld	s5,40(sp)
 870:	7b02                	ld	s6,32(sp)
 872:	6be2                	ld	s7,24(sp)
 874:	6c42                	ld	s8,16(sp)
 876:	6ca2                	ld	s9,8(sp)
    }
  }
}
 878:	60e6                	ld	ra,88(sp)
 87a:	6446                	ld	s0,80(sp)
 87c:	6906                	ld	s2,64(sp)
 87e:	6125                	addi	sp,sp,96
 880:	8082                	ret

0000000000000882 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 882:	715d                	addi	sp,sp,-80
 884:	ec06                	sd	ra,24(sp)
 886:	e822                	sd	s0,16(sp)
 888:	1000                	addi	s0,sp,32
 88a:	e010                	sd	a2,0(s0)
 88c:	e414                	sd	a3,8(s0)
 88e:	e818                	sd	a4,16(s0)
 890:	ec1c                	sd	a5,24(s0)
 892:	03043023          	sd	a6,32(s0)
 896:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 89a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 89e:	8622                	mv	a2,s0
 8a0:	d3fff0ef          	jal	5de <vprintf>
}
 8a4:	60e2                	ld	ra,24(sp)
 8a6:	6442                	ld	s0,16(sp)
 8a8:	6161                	addi	sp,sp,80
 8aa:	8082                	ret

00000000000008ac <printf>:

void
printf(const char *fmt, ...)
{
 8ac:	711d                	addi	sp,sp,-96
 8ae:	ec06                	sd	ra,24(sp)
 8b0:	e822                	sd	s0,16(sp)
 8b2:	1000                	addi	s0,sp,32
 8b4:	e40c                	sd	a1,8(s0)
 8b6:	e810                	sd	a2,16(s0)
 8b8:	ec14                	sd	a3,24(s0)
 8ba:	f018                	sd	a4,32(s0)
 8bc:	f41c                	sd	a5,40(s0)
 8be:	03043823          	sd	a6,48(s0)
 8c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8c6:	00840613          	addi	a2,s0,8
 8ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ce:	85aa                	mv	a1,a0
 8d0:	4505                	li	a0,1
 8d2:	d0dff0ef          	jal	5de <vprintf>
}
 8d6:	60e2                	ld	ra,24(sp)
 8d8:	6442                	ld	s0,16(sp)
 8da:	6125                	addi	sp,sp,96
 8dc:	8082                	ret

00000000000008de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8de:	1141                	addi	sp,sp,-16
 8e0:	e422                	sd	s0,8(sp)
 8e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	00000797          	auipc	a5,0x0
 8ec:	7187b783          	ld	a5,1816(a5) # 1000 <freep>
 8f0:	a02d                	j	91a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8f2:	4618                	lw	a4,8(a2)
 8f4:	9f2d                	addw	a4,a4,a1
 8f6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fa:	6398                	ld	a4,0(a5)
 8fc:	6310                	ld	a2,0(a4)
 8fe:	a83d                	j	93c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 900:	ff852703          	lw	a4,-8(a0)
 904:	9f31                	addw	a4,a4,a2
 906:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 908:	ff053683          	ld	a3,-16(a0)
 90c:	a091                	j	950 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90e:	6398                	ld	a4,0(a5)
 910:	00e7e463          	bltu	a5,a4,918 <free+0x3a>
 914:	00e6ea63          	bltu	a3,a4,928 <free+0x4a>
{
 918:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91a:	fed7fae3          	bgeu	a5,a3,90e <free+0x30>
 91e:	6398                	ld	a4,0(a5)
 920:	00e6e463          	bltu	a3,a4,928 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 924:	fee7eae3          	bltu	a5,a4,918 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 928:	ff852583          	lw	a1,-8(a0)
 92c:	6390                	ld	a2,0(a5)
 92e:	02059813          	slli	a6,a1,0x20
 932:	01c85713          	srli	a4,a6,0x1c
 936:	9736                	add	a4,a4,a3
 938:	fae60de3          	beq	a2,a4,8f2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 93c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 940:	4790                	lw	a2,8(a5)
 942:	02061593          	slli	a1,a2,0x20
 946:	01c5d713          	srli	a4,a1,0x1c
 94a:	973e                	add	a4,a4,a5
 94c:	fae68ae3          	beq	a3,a4,900 <free+0x22>
    p->s.ptr = bp->s.ptr;
 950:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 952:	00000717          	auipc	a4,0x0
 956:	6af73723          	sd	a5,1710(a4) # 1000 <freep>
}
 95a:	6422                	ld	s0,8(sp)
 95c:	0141                	addi	sp,sp,16
 95e:	8082                	ret

0000000000000960 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 960:	7139                	addi	sp,sp,-64
 962:	fc06                	sd	ra,56(sp)
 964:	f822                	sd	s0,48(sp)
 966:	f426                	sd	s1,40(sp)
 968:	ec4e                	sd	s3,24(sp)
 96a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 96c:	02051493          	slli	s1,a0,0x20
 970:	9081                	srli	s1,s1,0x20
 972:	04bd                	addi	s1,s1,15
 974:	8091                	srli	s1,s1,0x4
 976:	0014899b          	addiw	s3,s1,1
 97a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 97c:	00000517          	auipc	a0,0x0
 980:	68453503          	ld	a0,1668(a0) # 1000 <freep>
 984:	c915                	beqz	a0,9b8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 986:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 988:	4798                	lw	a4,8(a5)
 98a:	08977a63          	bgeu	a4,s1,a1e <malloc+0xbe>
 98e:	f04a                	sd	s2,32(sp)
 990:	e852                	sd	s4,16(sp)
 992:	e456                	sd	s5,8(sp)
 994:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 996:	8a4e                	mv	s4,s3
 998:	0009871b          	sext.w	a4,s3
 99c:	6685                	lui	a3,0x1
 99e:	00d77363          	bgeu	a4,a3,9a4 <malloc+0x44>
 9a2:	6a05                	lui	s4,0x1
 9a4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ac:	00000917          	auipc	s2,0x0
 9b0:	65490913          	addi	s2,s2,1620 # 1000 <freep>
  if(p == SBRK_ERROR)
 9b4:	5afd                	li	s5,-1
 9b6:	a081                	j	9f6 <malloc+0x96>
 9b8:	f04a                	sd	s2,32(sp)
 9ba:	e852                	sd	s4,16(sp)
 9bc:	e456                	sd	s5,8(sp)
 9be:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9c0:	00000797          	auipc	a5,0x0
 9c4:	65078793          	addi	a5,a5,1616 # 1010 <base>
 9c8:	00000717          	auipc	a4,0x0
 9cc:	62f73c23          	sd	a5,1592(a4) # 1000 <freep>
 9d0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9d2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9d6:	b7c1                	j	996 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9d8:	6398                	ld	a4,0(a5)
 9da:	e118                	sd	a4,0(a0)
 9dc:	a8a9                	j	a36 <malloc+0xd6>
  hp->s.size = nu;
 9de:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e2:	0541                	addi	a0,a0,16
 9e4:	efbff0ef          	jal	8de <free>
  return freep;
 9e8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ec:	c12d                	beqz	a0,a4e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f0:	4798                	lw	a4,8(a5)
 9f2:	02977263          	bgeu	a4,s1,a16 <malloc+0xb6>
    if(p == freep)
 9f6:	00093703          	ld	a4,0(s2)
 9fa:	853e                	mv	a0,a5
 9fc:	fef719e3          	bne	a4,a5,9ee <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a00:	8552                	mv	a0,s4
 a02:	a3fff0ef          	jal	440 <sbrk>
  if(p == SBRK_ERROR)
 a06:	fd551ce3          	bne	a0,s5,9de <malloc+0x7e>
        return 0;
 a0a:	4501                	li	a0,0
 a0c:	7902                	ld	s2,32(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
 a14:	a03d                	j	a42 <malloc+0xe2>
 a16:	7902                	ld	s2,32(sp)
 a18:	6a42                	ld	s4,16(sp)
 a1a:	6aa2                	ld	s5,8(sp)
 a1c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a1e:	fae48de3          	beq	s1,a4,9d8 <malloc+0x78>
        p->s.size -= nunits;
 a22:	4137073b          	subw	a4,a4,s3
 a26:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a28:	02071693          	slli	a3,a4,0x20
 a2c:	01c6d713          	srli	a4,a3,0x1c
 a30:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a32:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a36:	00000717          	auipc	a4,0x0
 a3a:	5ca73523          	sd	a0,1482(a4) # 1000 <freep>
      return (void*)(p + 1);
 a3e:	01078513          	addi	a0,a5,16
  }
}
 a42:	70e2                	ld	ra,56(sp)
 a44:	7442                	ld	s0,48(sp)
 a46:	74a2                	ld	s1,40(sp)
 a48:	69e2                	ld	s3,24(sp)
 a4a:	6121                	addi	sp,sp,64
 a4c:	8082                	ret
 a4e:	7902                	ld	s2,32(sp)
 a50:	6a42                	ld	s4,16(sp)
 a52:	6aa2                	ld	s5,8(sp)
 a54:	6b02                	ld	s6,0(sp)
 a56:	b7f5                	j	a42 <malloc+0xe2>
