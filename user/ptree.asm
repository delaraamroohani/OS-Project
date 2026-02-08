
user/_ptree:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_tree_recursive>:
#include "kernel/stat.h"
#include "user/user.h"

void
print_tree_recursive(struct proc_tree *tree, int index, char *prefix, int is_last)
{
   0:	7129                	addi	sp,sp,-320
   2:	fe06                	sd	ra,312(sp)
   4:	fa22                	sd	s0,304(sp)
   6:	f626                	sd	s1,296(sp)
   8:	f24a                	sd	s2,288(sp)
   a:	ee4e                	sd	s3,280(sp)
   c:	ea52                	sd	s4,272(sp)
   e:	0280                	addi	s0,sp,320
  10:	89aa                	mv	s3,a0
  12:	892e                	mv	s2,a1
  14:	84b2                	mv	s1,a2
  16:	8a36                	mv	s4,a3
  struct proc_info *proc = &tree->processes[index];
  
  // Print the current process with tree characters
  printf("%s", prefix);
  18:	85b2                	mv	a1,a2
  1a:	00001517          	auipc	a0,0x1
  1e:	b2650513          	addi	a0,a0,-1242 # b40 <malloc+0x102>
  22:	169000ef          	jal	98a <printf>
  if (index != 0) {  // Not root
  26:	1a090763          	beqz	s2,1d4 <print_tree_recursive+0x1d4>
    if (is_last) {
  2a:	020a0b63          	beqz	s4,60 <print_tree_recursive+0x60>
      printf("└─");  
  2e:	00001517          	auipc	a0,0x1
  32:	b2250513          	addi	a0,a0,-1246 # b50 <malloc+0x112>
  36:	155000ef          	jal	98a <printf>
    } else {
      printf("├─");  
    }
  }
  printf(" PID: %d\n", proc->pid);
  3a:	00391793          	slli	a5,s2,0x3
  3e:	412787b3          	sub	a5,a5,s2
  42:	078a                	slli	a5,a5,0x2
  44:	97ce                	add	a5,a5,s3
  46:	4bcc                	lw	a1,20(a5)
  48:	00001517          	auipc	a0,0x1
  4c:	b1050513          	addi	a0,a0,-1264 # b58 <malloc+0x11a>
  50:	13b000ef          	jal	98a <printf>
  // Build prefix for children
  char new_prefix[256];
  int prefix_len = 0;
  
  // Copy existing prefix
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
  54:	0004c703          	lbu	a4,0(s1)
  int prefix_len = 0;
  58:	4781                	li	a5,0
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
  5a:	18071963          	bnez	a4,1ec <print_tree_recursive+0x1ec>
  5e:	a04d                	j	100 <print_tree_recursive+0x100>
      printf("├─");  
  60:	00001517          	auipc	a0,0x1
  64:	b0850513          	addi	a0,a0,-1272 # b68 <malloc+0x12a>
  68:	123000ef          	jal	98a <printf>
  printf(" PID: %d\n", proc->pid);
  6c:	00391793          	slli	a5,s2,0x3
  70:	412787b3          	sub	a5,a5,s2
  74:	078a                	slli	a5,a5,0x2
  76:	97ce                	add	a5,a5,s3
  78:	4bcc                	lw	a1,20(a5)
  7a:	00001517          	auipc	a0,0x1
  7e:	ade50513          	addi	a0,a0,-1314 # b58 <malloc+0x11a>
  82:	109000ef          	jal	98a <printf>
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
  86:	0004c703          	lbu	a4,0(s1)
  8a:	16071163          	bnez	a4,1ec <print_tree_recursive+0x1ec>
  int prefix_len = 0;
  8e:	87d2                	mv	a5,s4
    if (is_last) {
      new_prefix[prefix_len++] = ' ';
      new_prefix[prefix_len++] = ' ';
    } else {
      // UTF-8 encoding for │ (0xE29482)
      new_prefix[prefix_len++] = 0xE2;
  90:	fc078713          	addi	a4,a5,-64
  94:	9722                	add	a4,a4,s0
  96:	5689                	li	a3,-30
  98:	f0d70023          	sb	a3,-256(a4)
      new_prefix[prefix_len++] = 0x94;
  9c:	0017871b          	addiw	a4,a5,1
  a0:	fc070713          	addi	a4,a4,-64
  a4:	9722                	add	a4,a4,s0
  a6:	f9400693          	li	a3,-108
  aa:	f0d70023          	sb	a3,-256(a4)
      new_prefix[prefix_len++] = 0x82;
  ae:	0037871b          	addiw	a4,a5,3
  b2:	0027869b          	addiw	a3,a5,2
  b6:	fc068693          	addi	a3,a3,-64
  ba:	96a2                	add	a3,a3,s0
  bc:	f8200613          	li	a2,-126
  c0:	f0c68023          	sb	a2,-256(a3)
      new_prefix[prefix_len++] = ' ';
  c4:	fc070713          	addi	a4,a4,-64
  c8:	9722                	add	a4,a4,s0
  ca:	2791                	addiw	a5,a5,4
  cc:	02000693          	li	a3,32
  d0:	f0d70023          	sb	a3,-256(a4)
  d4:	a0b1                	j	120 <print_tree_recursive+0x120>
  d6:	87c2                	mv	a5,a6
    new_prefix[prefix_len++] = prefix[i];
  d8:	ec040693          	addi	a3,s0,-320
  dc:	00f68833          	add	a6,a3,a5
  e0:	fee80fa3          	sb	a4,-1(a6)
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
  e4:	00f48733          	add	a4,s1,a5
  e8:	00074703          	lbu	a4,0(a4)
  ec:	c709                	beqz	a4,f6 <print_tree_recursive+0xf6>
  ee:	00178813          	addi	a6,a5,1
  f2:	fec812e3          	bne	a6,a2,d6 <print_tree_recursive+0xd6>
    new_prefix[prefix_len++] = prefix[i];
  f6:	2781                	sext.w	a5,a5
  if (index != 0) {  // Not root
  f8:	02090463          	beqz	s2,120 <print_tree_recursive+0x120>
    if (is_last) {
  fc:	f80a0ae3          	beqz	s4,90 <print_tree_recursive+0x90>
      new_prefix[prefix_len++] = ' ';
 100:	0017871b          	addiw	a4,a5,1
 104:	fc078693          	addi	a3,a5,-64
 108:	00868633          	add	a2,a3,s0
 10c:	02000693          	li	a3,32
 110:	f0d60023          	sb	a3,-256(a2)
      new_prefix[prefix_len++] = ' ';
 114:	fc070713          	addi	a4,a4,-64
 118:	9722                	add	a4,a4,s0
 11a:	2789                	addiw	a5,a5,2
 11c:	f0d70023          	sb	a3,-256(a4)
    }
  }
  new_prefix[prefix_len] = '\0';
 120:	fc078793          	addi	a5,a5,-64
 124:	97a2                	add	a5,a5,s0
 126:	f0078023          	sb	zero,-256(a5)
  
  // Find and print all children
  int child_count = 0;
  
  // Count children
  for (int i = index + 1; i < tree->count; i++) {
 12a:	00190a1b          	addiw	s4,s2,1
 12e:	0009a783          	lw	a5,0(s3)
 132:	06fa5d63          	bge	s4,a5,1ac <print_tree_recursive+0x1ac>
 136:	e656                	sd	s5,264(sp)
 138:	e25a                	sd	s6,256(sp)
    if (tree->processes[i].ppid == proc->pid) {
 13a:	00391713          	slli	a4,s2,0x3
 13e:	412706b3          	sub	a3,a4,s2
 142:	068a                	slli	a3,a3,0x2
 144:	96ce                	add	a3,a3,s3
 146:	4ad0                	lw	a2,20(a3)
 148:	412704b3          	sub	s1,a4,s2
 14c:	048a                	slli	s1,s1,0x2
 14e:	03448493          	addi	s1,s1,52
 152:	94ce                	add	s1,s1,s3
 154:	412787bb          	subw	a5,a5,s2
 158:	37f9                	addiw	a5,a5,-2
 15a:	1782                	slli	a5,a5,0x20
 15c:	9381                	srli	a5,a5,0x20
 15e:	97ca                	add	a5,a5,s2
 160:	00379693          	slli	a3,a5,0x3
 164:	8e9d                	sub	a3,a3,a5
 166:	068a                	slli	a3,a3,0x2
 168:	05098793          	addi	a5,s3,80
 16c:	96be                	add	a3,a3,a5
 16e:	87a6                	mv	a5,s1
  int child_count = 0;
 170:	4a81                	li	s5,0
 172:	a021                	j	17a <print_tree_recursive+0x17a>
  for (int i = index + 1; i < tree->count; i++) {
 174:	07f1                	addi	a5,a5,28
 176:	00d78763          	beq	a5,a3,184 <print_tree_recursive+0x184>
    if (tree->processes[i].ppid == proc->pid) {
 17a:	4398                	lw	a4,0(a5)
 17c:	fec71ce3          	bne	a4,a2,174 <print_tree_recursive+0x174>
      child_count++;
 180:	2a85                	addiw	s5,s5,1
 182:	bfcd                	j	174 <print_tree_recursive+0x174>
    }
  }
  
  // Print children
  int printed = 0;
 184:	4b01                	li	s6,0
  for (int i = index + 1; i < tree->count; i++) {
    if (tree->processes[i].ppid == proc->pid) {
 186:	00391793          	slli	a5,s2,0x3
 18a:	41278933          	sub	s2,a5,s2
 18e:	090a                	slli	s2,s2,0x2
 190:	994e                	add	s2,s2,s3
 192:	4098                	lw	a4,0(s1)
 194:	01492783          	lw	a5,20(s2)
 198:	02f70263          	beq	a4,a5,1bc <print_tree_recursive+0x1bc>
  for (int i = index + 1; i < tree->count; i++) {
 19c:	2a05                	addiw	s4,s4,1
 19e:	04f1                	addi	s1,s1,28
 1a0:	0009a783          	lw	a5,0(s3)
 1a4:	fefa47e3          	blt	s4,a5,192 <print_tree_recursive+0x192>
 1a8:	6ab2                	ld	s5,264(sp)
 1aa:	6b12                	ld	s6,256(sp)
      printed++;
      print_tree_recursive(tree, i, new_prefix, (printed == child_count));
    }
  }
}
 1ac:	70f2                	ld	ra,312(sp)
 1ae:	7452                	ld	s0,304(sp)
 1b0:	74b2                	ld	s1,296(sp)
 1b2:	7912                	ld	s2,288(sp)
 1b4:	69f2                	ld	s3,280(sp)
 1b6:	6a52                	ld	s4,272(sp)
 1b8:	6131                	addi	sp,sp,320
 1ba:	8082                	ret
      printed++;
 1bc:	2b05                	addiw	s6,s6,1
      print_tree_recursive(tree, i, new_prefix, (printed == child_count));
 1be:	416a86b3          	sub	a3,s5,s6
 1c2:	0016b693          	seqz	a3,a3
 1c6:	ec040613          	addi	a2,s0,-320
 1ca:	85d2                	mv	a1,s4
 1cc:	854e                	mv	a0,s3
 1ce:	e33ff0ef          	jal	0 <print_tree_recursive>
 1d2:	b7e9                	j	19c <print_tree_recursive+0x19c>
  printf(" PID: %d\n", proc->pid);
 1d4:	0149a583          	lw	a1,20(s3)
 1d8:	00001517          	auipc	a0,0x1
 1dc:	98050513          	addi	a0,a0,-1664 # b58 <malloc+0x11a>
 1e0:	7aa000ef          	jal	98a <printf>
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
 1e4:	0004c703          	lbu	a4,0(s1)
  int prefix_len = 0;
 1e8:	87ca                	mv	a5,s2
  for (int i = 0; prefix[i] != '\0' && prefix_len < 250; i++) {
 1ea:	db1d                	beqz	a4,120 <print_tree_recursive+0x120>
 1ec:	4785                	li	a5,1
 1ee:	0fb00613          	li	a2,251
 1f2:	b5dd                	j	d8 <print_tree_recursive+0xd8>

00000000000001f4 <main>:

int
main(int argc, char *argv[])
{
 1f4:	8d010113          	addi	sp,sp,-1840
 1f8:	72113423          	sd	ra,1832(sp)
 1fc:	72813023          	sd	s0,1824(sp)
 200:	70913c23          	sd	s1,1816(sp)
 204:	73010413          	addi	s0,sp,1840
  struct proc_tree tree;
  int pid = 1; // Default to init process
  
  if (argc > 1) {
 208:	4785                	li	a5,1
  int pid = 1; // Default to init process
 20a:	4485                	li	s1,1
  if (argc > 1) {
 20c:	02a7cf63          	blt	a5,a0,24a <main+0x56>
    pid = atoi(argv[1]);
  }

  if (ptree(pid, &tree) < 0) {
 210:	8d840593          	addi	a1,s0,-1832
 214:	8526                	mv	a0,s1
 216:	3a4000ef          	jal	5ba <ptree>
 21a:	02054d63          	bltz	a0,254 <main+0x60>
    printf("ptree failed: process %d not found\n", pid);
    exit(1);
  }

  printf("Process tree rooted at PID %d:\n", pid);
 21e:	85a6                	mv	a1,s1
 220:	00001517          	auipc	a0,0x1
 224:	97850513          	addi	a0,a0,-1672 # b98 <malloc+0x15a>
 228:	762000ef          	jal	98a <printf>
  printf("Total processes in tree: %d\n\n", tree.count);
 22c:	8d842583          	lw	a1,-1832(s0)
 230:	00001517          	auipc	a0,0x1
 234:	98850513          	addi	a0,a0,-1656 # bb8 <malloc+0x17a>
 238:	752000ef          	jal	98a <printf>
  
  if (tree.count > 0) {
 23c:	8d842783          	lw	a5,-1832(s0)
 240:	02f04463          	bgtz	a5,268 <main+0x74>
    print_tree_recursive(&tree, 0, "", 1);
  }
  
  exit(0);
 244:	4501                	li	a0,0
 246:	2cc000ef          	jal	512 <exit>
    pid = atoi(argv[1]);
 24a:	6588                	ld	a0,8(a1)
 24c:	1a4000ef          	jal	3f0 <atoi>
 250:	84aa                	mv	s1,a0
 252:	bf7d                	j	210 <main+0x1c>
    printf("ptree failed: process %d not found\n", pid);
 254:	85a6                	mv	a1,s1
 256:	00001517          	auipc	a0,0x1
 25a:	91a50513          	addi	a0,a0,-1766 # b70 <malloc+0x132>
 25e:	72c000ef          	jal	98a <printf>
    exit(1);
 262:	4505                	li	a0,1
 264:	2ae000ef          	jal	512 <exit>
    print_tree_recursive(&tree, 0, "", 1);
 268:	4685                	li	a3,1
 26a:	00001617          	auipc	a2,0x1
 26e:	8de60613          	addi	a2,a2,-1826 # b48 <malloc+0x10a>
 272:	4581                	li	a1,0
 274:	8d840513          	addi	a0,s0,-1832
 278:	d89ff0ef          	jal	0 <print_tree_recursive>
 27c:	b7e1                	j	244 <main+0x50>

000000000000027e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 286:	f6fff0ef          	jal	1f4 <main>
  exit(r);
 28a:	288000ef          	jal	512 <exit>

000000000000028e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 294:	87aa                	mv	a5,a0
 296:	0585                	addi	a1,a1,1
 298:	0785                	addi	a5,a5,1
 29a:	fff5c703          	lbu	a4,-1(a1)
 29e:	fee78fa3          	sb	a4,-1(a5)
 2a2:	fb75                	bnez	a4,296 <strcpy+0x8>
    ;
  return os;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cb91                	beqz	a5,2c8 <strcmp+0x1e>
 2b6:	0005c703          	lbu	a4,0(a1)
 2ba:	00f71763          	bne	a4,a5,2c8 <strcmp+0x1e>
    p++, q++;
 2be:	0505                	addi	a0,a0,1
 2c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	fbe5                	bnez	a5,2b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2c8:	0005c503          	lbu	a0,0(a1)
}
 2cc:	40a7853b          	subw	a0,a5,a0
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	addi	sp,sp,16
 2d4:	8082                	ret

00000000000002d6 <strlen>:

uint
strlen(const char *s)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	cf91                	beqz	a5,2fc <strlen+0x26>
 2e2:	0505                	addi	a0,a0,1
 2e4:	87aa                	mv	a5,a0
 2e6:	86be                	mv	a3,a5
 2e8:	0785                	addi	a5,a5,1
 2ea:	fff7c703          	lbu	a4,-1(a5)
 2ee:	ff65                	bnez	a4,2e6 <strlen+0x10>
 2f0:	40a6853b          	subw	a0,a3,a0
 2f4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	addi	sp,sp,16
 2fa:	8082                	ret
  for(n = 0; s[n]; n++)
 2fc:	4501                	li	a0,0
 2fe:	bfe5                	j	2f6 <strlen+0x20>

0000000000000300 <memset>:

void*
memset(void *dst, int c, uint n)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 306:	ca19                	beqz	a2,31c <memset+0x1c>
 308:	87aa                	mv	a5,a0
 30a:	1602                	slli	a2,a2,0x20
 30c:	9201                	srli	a2,a2,0x20
 30e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 312:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 316:	0785                	addi	a5,a5,1
 318:	fee79de3          	bne	a5,a4,312 <memset+0x12>
  }
  return dst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <strchr>:

char*
strchr(const char *s, char c)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  for(; *s; s++)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cb99                	beqz	a5,342 <strchr+0x20>
    if(*s == c)
 32e:	00f58763          	beq	a1,a5,33c <strchr+0x1a>
  for(; *s; s++)
 332:	0505                	addi	a0,a0,1
 334:	00054783          	lbu	a5,0(a0)
 338:	fbfd                	bnez	a5,32e <strchr+0xc>
      return (char*)s;
  return 0;
 33a:	4501                	li	a0,0
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strchr+0x1a>

0000000000000346 <gets>:

char*
gets(char *buf, int max)
{
 346:	711d                	addi	sp,sp,-96
 348:	ec86                	sd	ra,88(sp)
 34a:	e8a2                	sd	s0,80(sp)
 34c:	e4a6                	sd	s1,72(sp)
 34e:	e0ca                	sd	s2,64(sp)
 350:	fc4e                	sd	s3,56(sp)
 352:	f852                	sd	s4,48(sp)
 354:	f456                	sd	s5,40(sp)
 356:	f05a                	sd	s6,32(sp)
 358:	ec5e                	sd	s7,24(sp)
 35a:	1080                	addi	s0,sp,96
 35c:	8baa                	mv	s7,a0
 35e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 360:	892a                	mv	s2,a0
 362:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 364:	4aa9                	li	s5,10
 366:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 368:	89a6                	mv	s3,s1
 36a:	2485                	addiw	s1,s1,1
 36c:	0344d663          	bge	s1,s4,398 <gets+0x52>
    cc = read(0, &c, 1);
 370:	4605                	li	a2,1
 372:	faf40593          	addi	a1,s0,-81
 376:	4501                	li	a0,0
 378:	1b2000ef          	jal	52a <read>
    if(cc < 1)
 37c:	00a05e63          	blez	a0,398 <gets+0x52>
    buf[i++] = c;
 380:	faf44783          	lbu	a5,-81(s0)
 384:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 388:	01578763          	beq	a5,s5,396 <gets+0x50>
 38c:	0905                	addi	s2,s2,1
 38e:	fd679de3          	bne	a5,s6,368 <gets+0x22>
    buf[i++] = c;
 392:	89a6                	mv	s3,s1
 394:	a011                	j	398 <gets+0x52>
 396:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 398:	99de                	add	s3,s3,s7
 39a:	00098023          	sb	zero,0(s3)
  return buf;
}
 39e:	855e                	mv	a0,s7
 3a0:	60e6                	ld	ra,88(sp)
 3a2:	6446                	ld	s0,80(sp)
 3a4:	64a6                	ld	s1,72(sp)
 3a6:	6906                	ld	s2,64(sp)
 3a8:	79e2                	ld	s3,56(sp)
 3aa:	7a42                	ld	s4,48(sp)
 3ac:	7aa2                	ld	s5,40(sp)
 3ae:	7b02                	ld	s6,32(sp)
 3b0:	6be2                	ld	s7,24(sp)
 3b2:	6125                	addi	sp,sp,96
 3b4:	8082                	ret

00000000000003b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	e04a                	sd	s2,0(sp)
 3be:	1000                	addi	s0,sp,32
 3c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c2:	4581                	li	a1,0
 3c4:	18e000ef          	jal	552 <open>
  if(fd < 0)
 3c8:	02054263          	bltz	a0,3ec <stat+0x36>
 3cc:	e426                	sd	s1,8(sp)
 3ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d0:	85ca                	mv	a1,s2
 3d2:	198000ef          	jal	56a <fstat>
 3d6:	892a                	mv	s2,a0
  close(fd);
 3d8:	8526                	mv	a0,s1
 3da:	160000ef          	jal	53a <close>
  return r;
 3de:	64a2                	ld	s1,8(sp)
}
 3e0:	854a                	mv	a0,s2
 3e2:	60e2                	ld	ra,24(sp)
 3e4:	6442                	ld	s0,16(sp)
 3e6:	6902                	ld	s2,0(sp)
 3e8:	6105                	addi	sp,sp,32
 3ea:	8082                	ret
    return -1;
 3ec:	597d                	li	s2,-1
 3ee:	bfcd                	j	3e0 <stat+0x2a>

00000000000003f0 <atoi>:

int
atoi(const char *s)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e422                	sd	s0,8(sp)
 3f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f6:	00054683          	lbu	a3,0(a0)
 3fa:	fd06879b          	addiw	a5,a3,-48
 3fe:	0ff7f793          	zext.b	a5,a5
 402:	4625                	li	a2,9
 404:	02f66863          	bltu	a2,a5,434 <atoi+0x44>
 408:	872a                	mv	a4,a0
  n = 0;
 40a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 40c:	0705                	addi	a4,a4,1
 40e:	0025179b          	slliw	a5,a0,0x2
 412:	9fa9                	addw	a5,a5,a0
 414:	0017979b          	slliw	a5,a5,0x1
 418:	9fb5                	addw	a5,a5,a3
 41a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 41e:	00074683          	lbu	a3,0(a4)
 422:	fd06879b          	addiw	a5,a3,-48
 426:	0ff7f793          	zext.b	a5,a5
 42a:	fef671e3          	bgeu	a2,a5,40c <atoi+0x1c>
  return n;
}
 42e:	6422                	ld	s0,8(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret
  n = 0;
 434:	4501                	li	a0,0
 436:	bfe5                	j	42e <atoi+0x3e>

0000000000000438 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 438:	1141                	addi	sp,sp,-16
 43a:	e422                	sd	s0,8(sp)
 43c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43e:	02b57463          	bgeu	a0,a1,466 <memmove+0x2e>
    while(n-- > 0)
 442:	00c05f63          	blez	a2,460 <memmove+0x28>
 446:	1602                	slli	a2,a2,0x20
 448:	9201                	srli	a2,a2,0x20
 44a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 44e:	872a                	mv	a4,a0
      *dst++ = *src++;
 450:	0585                	addi	a1,a1,1
 452:	0705                	addi	a4,a4,1
 454:	fff5c683          	lbu	a3,-1(a1)
 458:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 45c:	fef71ae3          	bne	a4,a5,450 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 460:	6422                	ld	s0,8(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
    dst += n;
 466:	00c50733          	add	a4,a0,a2
    src += n;
 46a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 46c:	fec05ae3          	blez	a2,460 <memmove+0x28>
 470:	fff6079b          	addiw	a5,a2,-1
 474:	1782                	slli	a5,a5,0x20
 476:	9381                	srli	a5,a5,0x20
 478:	fff7c793          	not	a5,a5
 47c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47e:	15fd                	addi	a1,a1,-1
 480:	177d                	addi	a4,a4,-1
 482:	0005c683          	lbu	a3,0(a1)
 486:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48a:	fee79ae3          	bne	a5,a4,47e <memmove+0x46>
 48e:	bfc9                	j	460 <memmove+0x28>

0000000000000490 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 490:	1141                	addi	sp,sp,-16
 492:	e422                	sd	s0,8(sp)
 494:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 496:	ca05                	beqz	a2,4c6 <memcmp+0x36>
 498:	fff6069b          	addiw	a3,a2,-1
 49c:	1682                	slli	a3,a3,0x20
 49e:	9281                	srli	a3,a3,0x20
 4a0:	0685                	addi	a3,a3,1
 4a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a4:	00054783          	lbu	a5,0(a0)
 4a8:	0005c703          	lbu	a4,0(a1)
 4ac:	00e79863          	bne	a5,a4,4bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4b0:	0505                	addi	a0,a0,1
    p2++;
 4b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b4:	fed518e3          	bne	a0,a3,4a4 <memcmp+0x14>
  }
  return 0;
 4b8:	4501                	li	a0,0
 4ba:	a019                	j	4c0 <memcmp+0x30>
      return *p1 - *p2;
 4bc:	40e7853b          	subw	a0,a5,a4
}
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
  return 0;
 4c6:	4501                	li	a0,0
 4c8:	bfe5                	j	4c0 <memcmp+0x30>

00000000000004ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ca:	1141                	addi	sp,sp,-16
 4cc:	e406                	sd	ra,8(sp)
 4ce:	e022                	sd	s0,0(sp)
 4d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d2:	f67ff0ef          	jal	438 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	addi	sp,sp,16
 4dc:	8082                	ret

00000000000004de <sbrk>:

char *
sbrk(int n) {
 4de:	1141                	addi	sp,sp,-16
 4e0:	e406                	sd	ra,8(sp)
 4e2:	e022                	sd	s0,0(sp)
 4e4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4e6:	4585                	li	a1,1
 4e8:	0b2000ef          	jal	59a <sys_sbrk>
}
 4ec:	60a2                	ld	ra,8(sp)
 4ee:	6402                	ld	s0,0(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <sbrklazy>:

char *
sbrklazy(int n) {
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e406                	sd	ra,8(sp)
 4f8:	e022                	sd	s0,0(sp)
 4fa:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4fc:	4589                	li	a1,2
 4fe:	09c000ef          	jal	59a <sys_sbrk>
}
 502:	60a2                	ld	ra,8(sp)
 504:	6402                	ld	s0,0(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 50a:	4885                	li	a7,1
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <exit>:
.global exit
exit:
 li a7, SYS_exit
 512:	4889                	li	a7,2
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <wait>:
.global wait
wait:
 li a7, SYS_wait
 51a:	488d                	li	a7,3
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 522:	4891                	li	a7,4
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <read>:
.global read
read:
 li a7, SYS_read
 52a:	4895                	li	a7,5
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <write>:
.global write
write:
 li a7, SYS_write
 532:	48c1                	li	a7,16
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <close>:
.global close
close:
 li a7, SYS_close
 53a:	48d5                	li	a7,21
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <kill>:
.global kill
kill:
 li a7, SYS_kill
 542:	4899                	li	a7,6
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <exec>:
.global exec
exec:
 li a7, SYS_exec
 54a:	489d                	li	a7,7
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <open>:
.global open
open:
 li a7, SYS_open
 552:	48bd                	li	a7,15
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 55a:	48c5                	li	a7,17
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 562:	48c9                	li	a7,18
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 56a:	48a1                	li	a7,8
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <link>:
.global link
link:
 li a7, SYS_link
 572:	48cd                	li	a7,19
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 57a:	48d1                	li	a7,20
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 582:	48a5                	li	a7,9
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <dup>:
.global dup
dup:
 li a7, SYS_dup
 58a:	48a9                	li	a7,10
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 592:	48ad                	li	a7,11
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 59a:	48b1                	li	a7,12
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <pause>:
.global pause
pause:
 li a7, SYS_pause
 5a2:	48b5                	li	a7,13
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5aa:	48b9                	li	a7,14
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <clcnt>:
.global clcnt
clcnt:
 li a7, SYS_clcnt
 5b2:	48d9                	li	a7,22
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <ptree>:
.global ptree
ptree:
 li a7, SYS_ptree
 5ba:	48dd                	li	a7,23
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <cowfork>:
.global cowfork
cowfork:
 li a7, SYS_cowfork
 5c2:	48e1                	li	a7,24
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <physaddr>:
.global physaddr
physaddr:
 li a7, SYS_physaddr
 5ca:	48e5                	li	a7,25
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <get_pid>:
.global get_pid
get_pid:
 li a7, SYS_get_pid
 5d2:	48e9                	li	a7,26
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <set_pid_namespace>:
.global set_pid_namespace
set_pid_namespace:
 li a7, SYS_set_pid_namespace
 5da:	48ed                	li	a7,27
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <get_pid_namespace>:
.global get_pid_namespace
get_pid_namespace:
 li a7, SYS_get_pid_namespace
 5e2:	48f1                	li	a7,28
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <getHostname>:
.global getHostname
getHostname:
 li a7, SYS_getHostname
 5ea:	48f5                	li	a7,29
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <setHostname>:
.global setHostname
setHostname:
 li a7, SYS_setHostname
 5f2:	48f9                	li	a7,30
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <unshare>:
.global unshare
unshare:
 li a7, SYS_unshare
 5fa:	48fd                	li	a7,31
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 602:	1101                	addi	sp,sp,-32
 604:	ec06                	sd	ra,24(sp)
 606:	e822                	sd	s0,16(sp)
 608:	1000                	addi	s0,sp,32
 60a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60e:	4605                	li	a2,1
 610:	fef40593          	addi	a1,s0,-17
 614:	f1fff0ef          	jal	532 <write>
}
 618:	60e2                	ld	ra,24(sp)
 61a:	6442                	ld	s0,16(sp)
 61c:	6105                	addi	sp,sp,32
 61e:	8082                	ret

0000000000000620 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 620:	715d                	addi	sp,sp,-80
 622:	e486                	sd	ra,72(sp)
 624:	e0a2                	sd	s0,64(sp)
 626:	f84a                	sd	s2,48(sp)
 628:	0880                	addi	s0,sp,80
 62a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 62c:	c299                	beqz	a3,632 <printint+0x12>
 62e:	0805c363          	bltz	a1,6b4 <printint+0x94>
  neg = 0;
 632:	4881                	li	a7,0
 634:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 638:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 63a:	00000517          	auipc	a0,0x0
 63e:	5a650513          	addi	a0,a0,1446 # be0 <digits>
 642:	883e                	mv	a6,a5
 644:	2785                	addiw	a5,a5,1
 646:	02c5f733          	remu	a4,a1,a2
 64a:	972a                	add	a4,a4,a0
 64c:	00074703          	lbu	a4,0(a4)
 650:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 654:	872e                	mv	a4,a1
 656:	02c5d5b3          	divu	a1,a1,a2
 65a:	0685                	addi	a3,a3,1
 65c:	fec773e3          	bgeu	a4,a2,642 <printint+0x22>
  if(neg)
 660:	00088b63          	beqz	a7,676 <printint+0x56>
    buf[i++] = '-';
 664:	fd078793          	addi	a5,a5,-48
 668:	97a2                	add	a5,a5,s0
 66a:	02d00713          	li	a4,45
 66e:	fee78423          	sb	a4,-24(a5)
 672:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 676:	02f05a63          	blez	a5,6aa <printint+0x8a>
 67a:	fc26                	sd	s1,56(sp)
 67c:	f44e                	sd	s3,40(sp)
 67e:	fb840713          	addi	a4,s0,-72
 682:	00f704b3          	add	s1,a4,a5
 686:	fff70993          	addi	s3,a4,-1
 68a:	99be                	add	s3,s3,a5
 68c:	37fd                	addiw	a5,a5,-1
 68e:	1782                	slli	a5,a5,0x20
 690:	9381                	srli	a5,a5,0x20
 692:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 696:	fff4c583          	lbu	a1,-1(s1)
 69a:	854a                	mv	a0,s2
 69c:	f67ff0ef          	jal	602 <putc>
  while(--i >= 0)
 6a0:	14fd                	addi	s1,s1,-1
 6a2:	ff349ae3          	bne	s1,s3,696 <printint+0x76>
 6a6:	74e2                	ld	s1,56(sp)
 6a8:	79a2                	ld	s3,40(sp)
}
 6aa:	60a6                	ld	ra,72(sp)
 6ac:	6406                	ld	s0,64(sp)
 6ae:	7942                	ld	s2,48(sp)
 6b0:	6161                	addi	sp,sp,80
 6b2:	8082                	ret
    x = -xx;
 6b4:	40b005b3          	neg	a1,a1
    neg = 1;
 6b8:	4885                	li	a7,1
    x = -xx;
 6ba:	bfad                	j	634 <printint+0x14>

00000000000006bc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6bc:	711d                	addi	sp,sp,-96
 6be:	ec86                	sd	ra,88(sp)
 6c0:	e8a2                	sd	s0,80(sp)
 6c2:	e0ca                	sd	s2,64(sp)
 6c4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6c6:	0005c903          	lbu	s2,0(a1)
 6ca:	28090663          	beqz	s2,956 <vprintf+0x29a>
 6ce:	e4a6                	sd	s1,72(sp)
 6d0:	fc4e                	sd	s3,56(sp)
 6d2:	f852                	sd	s4,48(sp)
 6d4:	f456                	sd	s5,40(sp)
 6d6:	f05a                	sd	s6,32(sp)
 6d8:	ec5e                	sd	s7,24(sp)
 6da:	e862                	sd	s8,16(sp)
 6dc:	e466                	sd	s9,8(sp)
 6de:	8b2a                	mv	s6,a0
 6e0:	8a2e                	mv	s4,a1
 6e2:	8bb2                	mv	s7,a2
  state = 0;
 6e4:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6e6:	4481                	li	s1,0
 6e8:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6ea:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6ee:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6f2:	06c00c93          	li	s9,108
 6f6:	a005                	j	716 <vprintf+0x5a>
        putc(fd, c0);
 6f8:	85ca                	mv	a1,s2
 6fa:	855a                	mv	a0,s6
 6fc:	f07ff0ef          	jal	602 <putc>
 700:	a019                	j	706 <vprintf+0x4a>
    } else if(state == '%'){
 702:	03598263          	beq	s3,s5,726 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 706:	2485                	addiw	s1,s1,1
 708:	8726                	mv	a4,s1
 70a:	009a07b3          	add	a5,s4,s1
 70e:	0007c903          	lbu	s2,0(a5)
 712:	22090a63          	beqz	s2,946 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 716:	0009079b          	sext.w	a5,s2
    if(state == 0){
 71a:	fe0994e3          	bnez	s3,702 <vprintf+0x46>
      if(c0 == '%'){
 71e:	fd579de3          	bne	a5,s5,6f8 <vprintf+0x3c>
        state = '%';
 722:	89be                	mv	s3,a5
 724:	b7cd                	j	706 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 726:	00ea06b3          	add	a3,s4,a4
 72a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 72e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 730:	c681                	beqz	a3,738 <vprintf+0x7c>
 732:	9752                	add	a4,a4,s4
 734:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 738:	05878363          	beq	a5,s8,77e <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 73c:	05978d63          	beq	a5,s9,796 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 740:	07500713          	li	a4,117
 744:	0ee78763          	beq	a5,a4,832 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 748:	07800713          	li	a4,120
 74c:	12e78963          	beq	a5,a4,87e <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 750:	07000713          	li	a4,112
 754:	14e78e63          	beq	a5,a4,8b0 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 758:	06300713          	li	a4,99
 75c:	18e78e63          	beq	a5,a4,8f8 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 760:	07300713          	li	a4,115
 764:	1ae78463          	beq	a5,a4,90c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 768:	02500713          	li	a4,37
 76c:	04e79563          	bne	a5,a4,7b6 <vprintf+0xfa>
        putc(fd, '%');
 770:	02500593          	li	a1,37
 774:	855a                	mv	a0,s6
 776:	e8dff0ef          	jal	602 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 77a:	4981                	li	s3,0
 77c:	b769                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 77e:	008b8913          	addi	s2,s7,8
 782:	4685                	li	a3,1
 784:	4629                	li	a2,10
 786:	000ba583          	lw	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	e95ff0ef          	jal	620 <printint>
 790:	8bca                	mv	s7,s2
      state = 0;
 792:	4981                	li	s3,0
 794:	bf8d                	j	706 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 796:	06400793          	li	a5,100
 79a:	02f68963          	beq	a3,a5,7cc <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 79e:	06c00793          	li	a5,108
 7a2:	04f68263          	beq	a3,a5,7e6 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 7a6:	07500793          	li	a5,117
 7aa:	0af68063          	beq	a3,a5,84a <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 7ae:	07800793          	li	a5,120
 7b2:	0ef68263          	beq	a3,a5,896 <vprintf+0x1da>
        putc(fd, '%');
 7b6:	02500593          	li	a1,37
 7ba:	855a                	mv	a0,s6
 7bc:	e47ff0ef          	jal	602 <putc>
        putc(fd, c0);
 7c0:	85ca                	mv	a1,s2
 7c2:	855a                	mv	a0,s6
 7c4:	e3fff0ef          	jal	602 <putc>
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bf35                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	4685                	li	a3,1
 7d2:	4629                	li	a2,10
 7d4:	000bb583          	ld	a1,0(s7)
 7d8:	855a                	mv	a0,s6
 7da:	e47ff0ef          	jal	620 <printint>
        i += 1;
 7de:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7e0:	8bca                	mv	s7,s2
      state = 0;
 7e2:	4981                	li	s3,0
        i += 1;
 7e4:	b70d                	j	706 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7e6:	06400793          	li	a5,100
 7ea:	02f60763          	beq	a2,a5,818 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ee:	07500793          	li	a5,117
 7f2:	06f60963          	beq	a2,a5,864 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7f6:	07800793          	li	a5,120
 7fa:	faf61ee3          	bne	a2,a5,7b6 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7fe:	008b8913          	addi	s2,s7,8
 802:	4681                	li	a3,0
 804:	4641                	li	a2,16
 806:	000bb583          	ld	a1,0(s7)
 80a:	855a                	mv	a0,s6
 80c:	e15ff0ef          	jal	620 <printint>
        i += 2;
 810:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 812:	8bca                	mv	s7,s2
      state = 0;
 814:	4981                	li	s3,0
        i += 2;
 816:	bdc5                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 818:	008b8913          	addi	s2,s7,8
 81c:	4685                	li	a3,1
 81e:	4629                	li	a2,10
 820:	000bb583          	ld	a1,0(s7)
 824:	855a                	mv	a0,s6
 826:	dfbff0ef          	jal	620 <printint>
        i += 2;
 82a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 82c:	8bca                	mv	s7,s2
      state = 0;
 82e:	4981                	li	s3,0
        i += 2;
 830:	bdd9                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 832:	008b8913          	addi	s2,s7,8
 836:	4681                	li	a3,0
 838:	4629                	li	a2,10
 83a:	000be583          	lwu	a1,0(s7)
 83e:	855a                	mv	a0,s6
 840:	de1ff0ef          	jal	620 <printint>
 844:	8bca                	mv	s7,s2
      state = 0;
 846:	4981                	li	s3,0
 848:	bd7d                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 84a:	008b8913          	addi	s2,s7,8
 84e:	4681                	li	a3,0
 850:	4629                	li	a2,10
 852:	000bb583          	ld	a1,0(s7)
 856:	855a                	mv	a0,s6
 858:	dc9ff0ef          	jal	620 <printint>
        i += 1;
 85c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 85e:	8bca                	mv	s7,s2
      state = 0;
 860:	4981                	li	s3,0
        i += 1;
 862:	b555                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 864:	008b8913          	addi	s2,s7,8
 868:	4681                	li	a3,0
 86a:	4629                	li	a2,10
 86c:	000bb583          	ld	a1,0(s7)
 870:	855a                	mv	a0,s6
 872:	dafff0ef          	jal	620 <printint>
        i += 2;
 876:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 878:	8bca                	mv	s7,s2
      state = 0;
 87a:	4981                	li	s3,0
        i += 2;
 87c:	b569                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 87e:	008b8913          	addi	s2,s7,8
 882:	4681                	li	a3,0
 884:	4641                	li	a2,16
 886:	000be583          	lwu	a1,0(s7)
 88a:	855a                	mv	a0,s6
 88c:	d95ff0ef          	jal	620 <printint>
 890:	8bca                	mv	s7,s2
      state = 0;
 892:	4981                	li	s3,0
 894:	bd8d                	j	706 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 896:	008b8913          	addi	s2,s7,8
 89a:	4681                	li	a3,0
 89c:	4641                	li	a2,16
 89e:	000bb583          	ld	a1,0(s7)
 8a2:	855a                	mv	a0,s6
 8a4:	d7dff0ef          	jal	620 <printint>
        i += 1;
 8a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8aa:	8bca                	mv	s7,s2
      state = 0;
 8ac:	4981                	li	s3,0
        i += 1;
 8ae:	bda1                	j	706 <vprintf+0x4a>
 8b0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8b2:	008b8d13          	addi	s10,s7,8
 8b6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8ba:	03000593          	li	a1,48
 8be:	855a                	mv	a0,s6
 8c0:	d43ff0ef          	jal	602 <putc>
  putc(fd, 'x');
 8c4:	07800593          	li	a1,120
 8c8:	855a                	mv	a0,s6
 8ca:	d39ff0ef          	jal	602 <putc>
 8ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8d0:	00000b97          	auipc	s7,0x0
 8d4:	310b8b93          	addi	s7,s7,784 # be0 <digits>
 8d8:	03c9d793          	srli	a5,s3,0x3c
 8dc:	97de                	add	a5,a5,s7
 8de:	0007c583          	lbu	a1,0(a5)
 8e2:	855a                	mv	a0,s6
 8e4:	d1fff0ef          	jal	602 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8e8:	0992                	slli	s3,s3,0x4
 8ea:	397d                	addiw	s2,s2,-1
 8ec:	fe0916e3          	bnez	s2,8d8 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8f0:	8bea                	mv	s7,s10
      state = 0;
 8f2:	4981                	li	s3,0
 8f4:	6d02                	ld	s10,0(sp)
 8f6:	bd01                	j	706 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8f8:	008b8913          	addi	s2,s7,8
 8fc:	000bc583          	lbu	a1,0(s7)
 900:	855a                	mv	a0,s6
 902:	d01ff0ef          	jal	602 <putc>
 906:	8bca                	mv	s7,s2
      state = 0;
 908:	4981                	li	s3,0
 90a:	bbf5                	j	706 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 90c:	008b8993          	addi	s3,s7,8
 910:	000bb903          	ld	s2,0(s7)
 914:	00090f63          	beqz	s2,932 <vprintf+0x276>
        for(; *s; s++)
 918:	00094583          	lbu	a1,0(s2)
 91c:	c195                	beqz	a1,940 <vprintf+0x284>
          putc(fd, *s);
 91e:	855a                	mv	a0,s6
 920:	ce3ff0ef          	jal	602 <putc>
        for(; *s; s++)
 924:	0905                	addi	s2,s2,1
 926:	00094583          	lbu	a1,0(s2)
 92a:	f9f5                	bnez	a1,91e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 92c:	8bce                	mv	s7,s3
      state = 0;
 92e:	4981                	li	s3,0
 930:	bbd9                	j	706 <vprintf+0x4a>
          s = "(null)";
 932:	00000917          	auipc	s2,0x0
 936:	2a690913          	addi	s2,s2,678 # bd8 <malloc+0x19a>
        for(; *s; s++)
 93a:	02800593          	li	a1,40
 93e:	b7c5                	j	91e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 940:	8bce                	mv	s7,s3
      state = 0;
 942:	4981                	li	s3,0
 944:	b3c9                	j	706 <vprintf+0x4a>
 946:	64a6                	ld	s1,72(sp)
 948:	79e2                	ld	s3,56(sp)
 94a:	7a42                	ld	s4,48(sp)
 94c:	7aa2                	ld	s5,40(sp)
 94e:	7b02                	ld	s6,32(sp)
 950:	6be2                	ld	s7,24(sp)
 952:	6c42                	ld	s8,16(sp)
 954:	6ca2                	ld	s9,8(sp)
    }
  }
}
 956:	60e6                	ld	ra,88(sp)
 958:	6446                	ld	s0,80(sp)
 95a:	6906                	ld	s2,64(sp)
 95c:	6125                	addi	sp,sp,96
 95e:	8082                	ret

0000000000000960 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 960:	715d                	addi	sp,sp,-80
 962:	ec06                	sd	ra,24(sp)
 964:	e822                	sd	s0,16(sp)
 966:	1000                	addi	s0,sp,32
 968:	e010                	sd	a2,0(s0)
 96a:	e414                	sd	a3,8(s0)
 96c:	e818                	sd	a4,16(s0)
 96e:	ec1c                	sd	a5,24(s0)
 970:	03043023          	sd	a6,32(s0)
 974:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 97c:	8622                	mv	a2,s0
 97e:	d3fff0ef          	jal	6bc <vprintf>
}
 982:	60e2                	ld	ra,24(sp)
 984:	6442                	ld	s0,16(sp)
 986:	6161                	addi	sp,sp,80
 988:	8082                	ret

000000000000098a <printf>:

void
printf(const char *fmt, ...)
{
 98a:	711d                	addi	sp,sp,-96
 98c:	ec06                	sd	ra,24(sp)
 98e:	e822                	sd	s0,16(sp)
 990:	1000                	addi	s0,sp,32
 992:	e40c                	sd	a1,8(s0)
 994:	e810                	sd	a2,16(s0)
 996:	ec14                	sd	a3,24(s0)
 998:	f018                	sd	a4,32(s0)
 99a:	f41c                	sd	a5,40(s0)
 99c:	03043823          	sd	a6,48(s0)
 9a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9a4:	00840613          	addi	a2,s0,8
 9a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ac:	85aa                	mv	a1,a0
 9ae:	4505                	li	a0,1
 9b0:	d0dff0ef          	jal	6bc <vprintf>
}
 9b4:	60e2                	ld	ra,24(sp)
 9b6:	6442                	ld	s0,16(sp)
 9b8:	6125                	addi	sp,sp,96
 9ba:	8082                	ret

00000000000009bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9bc:	1141                	addi	sp,sp,-16
 9be:	e422                	sd	s0,8(sp)
 9c0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9c2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c6:	00000797          	auipc	a5,0x0
 9ca:	63a7b783          	ld	a5,1594(a5) # 1000 <freep>
 9ce:	a02d                	j	9f8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9d0:	4618                	lw	a4,8(a2)
 9d2:	9f2d                	addw	a4,a4,a1
 9d4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9d8:	6398                	ld	a4,0(a5)
 9da:	6310                	ld	a2,0(a4)
 9dc:	a83d                	j	a1a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9de:	ff852703          	lw	a4,-8(a0)
 9e2:	9f31                	addw	a4,a4,a2
 9e4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9e6:	ff053683          	ld	a3,-16(a0)
 9ea:	a091                	j	a2e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ec:	6398                	ld	a4,0(a5)
 9ee:	00e7e463          	bltu	a5,a4,9f6 <free+0x3a>
 9f2:	00e6ea63          	bltu	a3,a4,a06 <free+0x4a>
{
 9f6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9f8:	fed7fae3          	bgeu	a5,a3,9ec <free+0x30>
 9fc:	6398                	ld	a4,0(a5)
 9fe:	00e6e463          	bltu	a3,a4,a06 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a02:	fee7eae3          	bltu	a5,a4,9f6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a06:	ff852583          	lw	a1,-8(a0)
 a0a:	6390                	ld	a2,0(a5)
 a0c:	02059813          	slli	a6,a1,0x20
 a10:	01c85713          	srli	a4,a6,0x1c
 a14:	9736                	add	a4,a4,a3
 a16:	fae60de3          	beq	a2,a4,9d0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a1a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a1e:	4790                	lw	a2,8(a5)
 a20:	02061593          	slli	a1,a2,0x20
 a24:	01c5d713          	srli	a4,a1,0x1c
 a28:	973e                	add	a4,a4,a5
 a2a:	fae68ae3          	beq	a3,a4,9de <free+0x22>
    p->s.ptr = bp->s.ptr;
 a2e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a30:	00000717          	auipc	a4,0x0
 a34:	5cf73823          	sd	a5,1488(a4) # 1000 <freep>
}
 a38:	6422                	ld	s0,8(sp)
 a3a:	0141                	addi	sp,sp,16
 a3c:	8082                	ret

0000000000000a3e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a3e:	7139                	addi	sp,sp,-64
 a40:	fc06                	sd	ra,56(sp)
 a42:	f822                	sd	s0,48(sp)
 a44:	f426                	sd	s1,40(sp)
 a46:	ec4e                	sd	s3,24(sp)
 a48:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4a:	02051493          	slli	s1,a0,0x20
 a4e:	9081                	srli	s1,s1,0x20
 a50:	04bd                	addi	s1,s1,15
 a52:	8091                	srli	s1,s1,0x4
 a54:	0014899b          	addiw	s3,s1,1
 a58:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a5a:	00000517          	auipc	a0,0x0
 a5e:	5a653503          	ld	a0,1446(a0) # 1000 <freep>
 a62:	c915                	beqz	a0,a96 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a64:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a66:	4798                	lw	a4,8(a5)
 a68:	08977a63          	bgeu	a4,s1,afc <malloc+0xbe>
 a6c:	f04a                	sd	s2,32(sp)
 a6e:	e852                	sd	s4,16(sp)
 a70:	e456                	sd	s5,8(sp)
 a72:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a74:	8a4e                	mv	s4,s3
 a76:	0009871b          	sext.w	a4,s3
 a7a:	6685                	lui	a3,0x1
 a7c:	00d77363          	bgeu	a4,a3,a82 <malloc+0x44>
 a80:	6a05                	lui	s4,0x1
 a82:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a86:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a8a:	00000917          	auipc	s2,0x0
 a8e:	57690913          	addi	s2,s2,1398 # 1000 <freep>
  if(p == SBRK_ERROR)
 a92:	5afd                	li	s5,-1
 a94:	a081                	j	ad4 <malloc+0x96>
 a96:	f04a                	sd	s2,32(sp)
 a98:	e852                	sd	s4,16(sp)
 a9a:	e456                	sd	s5,8(sp)
 a9c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a9e:	00000797          	auipc	a5,0x0
 aa2:	57278793          	addi	a5,a5,1394 # 1010 <base>
 aa6:	00000717          	auipc	a4,0x0
 aaa:	54f73d23          	sd	a5,1370(a4) # 1000 <freep>
 aae:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ab0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ab4:	b7c1                	j	a74 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 ab6:	6398                	ld	a4,0(a5)
 ab8:	e118                	sd	a4,0(a0)
 aba:	a8a9                	j	b14 <malloc+0xd6>
  hp->s.size = nu;
 abc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ac0:	0541                	addi	a0,a0,16
 ac2:	efbff0ef          	jal	9bc <free>
  return freep;
 ac6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aca:	c12d                	beqz	a0,b2c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 acc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ace:	4798                	lw	a4,8(a5)
 ad0:	02977263          	bgeu	a4,s1,af4 <malloc+0xb6>
    if(p == freep)
 ad4:	00093703          	ld	a4,0(s2)
 ad8:	853e                	mv	a0,a5
 ada:	fef719e3          	bne	a4,a5,acc <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ade:	8552                	mv	a0,s4
 ae0:	9ffff0ef          	jal	4de <sbrk>
  if(p == SBRK_ERROR)
 ae4:	fd551ce3          	bne	a0,s5,abc <malloc+0x7e>
        return 0;
 ae8:	4501                	li	a0,0
 aea:	7902                	ld	s2,32(sp)
 aec:	6a42                	ld	s4,16(sp)
 aee:	6aa2                	ld	s5,8(sp)
 af0:	6b02                	ld	s6,0(sp)
 af2:	a03d                	j	b20 <malloc+0xe2>
 af4:	7902                	ld	s2,32(sp)
 af6:	6a42                	ld	s4,16(sp)
 af8:	6aa2                	ld	s5,8(sp)
 afa:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 afc:	fae48de3          	beq	s1,a4,ab6 <malloc+0x78>
        p->s.size -= nunits;
 b00:	4137073b          	subw	a4,a4,s3
 b04:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b06:	02071693          	slli	a3,a4,0x20
 b0a:	01c6d713          	srli	a4,a3,0x1c
 b0e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b10:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b14:	00000717          	auipc	a4,0x0
 b18:	4ea73623          	sd	a0,1260(a4) # 1000 <freep>
      return (void*)(p + 1);
 b1c:	01078513          	addi	a0,a5,16
  }
}
 b20:	70e2                	ld	ra,56(sp)
 b22:	7442                	ld	s0,48(sp)
 b24:	74a2                	ld	s1,40(sp)
 b26:	69e2                	ld	s3,24(sp)
 b28:	6121                	addi	sp,sp,64
 b2a:	8082                	ret
 b2c:	7902                	ld	s2,32(sp)
 b2e:	6a42                	ld	s4,16(sp)
 b30:	6aa2                	ld	s5,8(sp)
 b32:	6b02                	ld	s6,0(sp)
 b34:	b7f5                	j	b20 <malloc+0xe2>
