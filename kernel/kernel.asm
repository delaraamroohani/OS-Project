
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	87010113          	addi	sp,sp,-1936 # 80007870 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc87>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	248020ef          	jal	8000235a <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	0000f517          	auipc	a0,0xf
    80000190:	6e450513          	addi	a0,a0,1764 # 8000f870 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	0000f497          	auipc	s1,0xf
    8000019c:	6d848493          	addi	s1,s1,1752 # 8000f870 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	0000f917          	auipc	s2,0xf
    800001a4:	76890913          	addi	s2,s2,1896 # 8000f908 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	7f2010ef          	jal	800019aa <myproc>
    800001bc:	030020ef          	jal	800021ec <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	5ef010ef          	jal	80001fb4 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	0000f717          	auipc	a4,0xf
    800001dc:	69870713          	addi	a4,a4,1688 # 8000f870 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	106020ef          	jal	80002310 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	0000f517          	auipc	a0,0xf
    80000226:	64e50513          	addi	a0,a0,1614 # 8000f870 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	0000f717          	auipc	a4,0xf
    80000250:	6af72e23          	sw	a5,1724(a4) # 8000f908 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	0000f517          	auipc	a0,0xf
    80000266:	60e50513          	addi	a0,a0,1550 # 8000f870 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	0000f517          	auipc	a0,0xf
    800002ba:	5ba50513          	addi	a0,a0,1466 # 8000f870 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	0cc020ef          	jal	800023a4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	0000f517          	auipc	a0,0xf
    800002e0:	59450513          	addi	a0,a0,1428 # 8000f870 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	0000f717          	auipc	a4,0xf
    800002fe:	57670713          	addi	a4,a4,1398 # 8000f870 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	0000f797          	auipc	a5,0xf
    80000324:	55078793          	addi	a5,a5,1360 # 8000f870 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	5ba7a783          	lw	a5,1466(a5) # 8000f908 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	0000f717          	auipc	a4,0xf
    80000368:	50c70713          	addi	a4,a4,1292 # 8000f870 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	0000f497          	auipc	s1,0xf
    80000378:	4fc48493          	addi	s1,s1,1276 # 8000f870 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	0000f717          	auipc	a4,0xf
    800003ba:	4ba70713          	addi	a4,a4,1210 # 8000f870 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	0000f717          	auipc	a4,0xf
    800003d0:	54f72223          	sw	a5,1348(a4) # 8000f910 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	0000f797          	auipc	a5,0xf
    800003ee:	48678793          	addi	a5,a5,1158 # 8000f870 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	0000f797          	auipc	a5,0xf
    80000412:	4ec7af23          	sw	a2,1278(a5) # 8000f90c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	0000f517          	auipc	a0,0xf
    8000041a:	4f250513          	addi	a0,a0,1266 # 8000f908 <cons+0x98>
    8000041e:	3e3010ef          	jal	80002000 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	0000f517          	auipc	a0,0xf
    80000438:	43c50513          	addi	a0,a0,1084 # 8000f870 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	0001f797          	auipc	a5,0x1f
    80000448:	59c78793          	addi	a5,a5,1436 # 8001f9e0 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	29260613          	addi	a2,a2,658 # 80007710 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	32c7a783          	lw	a5,812(a5) # 80007844 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	3b850513          	addi	a0,a0,952 # 8000f918 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	fe8b8b93          	addi	s7,s7,-24 # 80007710 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00007797          	auipc	a5,0x7
    800007c0:	0887a783          	lw	a5,136(a5) # 80007844 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	0000f517          	auipc	a0,0xf
    800007d6:	14650513          	addi	a0,a0,326 # 8000f918 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00007797          	auipc	a5,0x7
    800007f4:	0527aa23          	sw	s2,84(a5) # 80007844 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00007797          	auipc	a5,0x7
    80000816:	0327a723          	sw	s2,46(a5) # 80007840 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	0000f517          	auipc	a0,0xf
    80000830:	0ec50513          	addi	a0,a0,236 # 8000f918 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	0ac50513          	addi	a0,a0,172 # 8000f930 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	0000f517          	auipc	a0,0xf
    800008ac:	08850513          	addi	a0,a0,136 # 8000f930 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00007497          	auipc	s1,0x7
    800008ca:	f8648493          	addi	s1,s1,-122 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	0000f997          	auipc	s3,0xf
    800008d2:	06298993          	addi	s3,s3,98 # 8000f930 <tx_lock>
    800008d6:	00007917          	auipc	s2,0x7
    800008da:	f7290913          	addi	s2,s2,-142 # 80007848 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	6ca010ef          	jal	80001fb4 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	0000f517          	auipc	a0,0xf
    80000918:	01c50513          	addi	a0,a0,28 # 8000f930 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00007797          	auipc	a5,0x7
    8000093c:	f0c7a783          	lw	a5,-244(a5) # 80007844 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00007797          	auipc	a5,0x7
    80000946:	efe7a783          	lw	a5,-258(a5) # 80007840 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00007797          	auipc	a5,0x7
    8000096c:	edc7a783          	lw	a5,-292(a5) # 80007844 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	0000f517          	auipc	a0,0xf
    800009c8:	f6c50513          	addi	a0,a0,-148 # 8000f930 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	0000f517          	auipc	a0,0xf
    800009e4:	f5050513          	addi	a0,a0,-176 # 8000f930 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00007797          	auipc	a5,0x7
    800009f4:	e407ae23          	sw	zero,-420(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00007517          	auipc	a0,0x7
    800009fc:	e5050513          	addi	a0,a0,-432 # 80007848 <tx_chan>
    80000a00:	600010ef          	jal	80002000 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00020797          	auipc	a5,0x20
    80000a34:	14878793          	addi	a5,a5,328 # 80020b78 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	0000f917          	auipc	s2,0xf
    80000a50:	efc90913          	addi	s2,s2,-260 # 8000f948 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	0000f517          	auipc	a0,0xf
    80000ade:	e6e50513          	addi	a0,a0,-402 # 8000f948 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00020517          	auipc	a0,0x20
    80000aee:	08e50513          	addi	a0,a0,142 # 80020b78 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	0000f497          	auipc	s1,0xf
    80000b0c:	e4048493          	addi	s1,s1,-448 # 8000f948 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	0000f517          	auipc	a0,0xf
    80000b20:	e2c50513          	addi	a0,a0,-468 # 8000f948 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	0000f517          	auipc	a0,0xf
    80000b44:	e0850513          	addi	a0,a0,-504 # 8000f948 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	617000ef          	jal	8000198e <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	5e9000ef          	jal	8000198e <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	5e1000ef          	jal	8000198e <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	5cd000ef          	jal	8000198e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf6:	599000ef          	jal	8000198e <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	575000ef          	jal	8000198e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c80:	0f50000f          	fence	iorw,ow
    80000c84:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde489>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	33b000ef          	jal	8000197e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00007717          	auipc	a4,0x7
    80000e4c:	a0870713          	addi	a4,a4,-1528 # 80007850 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e5c:	323000ef          	jal	8000197e <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	6d0010ef          	jal	80002542 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	722040ef          	jal	80005598 <plicinithart>
  }

  scheduler();        
    80000e7a:	7a3000ef          	jal	80001e1c <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	213000ef          	jal	800018c8 <procinit>
    trapinit();      // trap vectors
    80000eba:	664010ef          	jal	8000251e <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	684010ef          	jal	80002542 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	6bc040ef          	jal	8000557e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	6d2040ef          	jal	80005598 <plicinithart>
    binit();         // buffer cache
    80000eca:	59b010ef          	jal	80002c64 <binit>
    iinit();         // inode table
    80000ece:	320020ef          	jal	800031ee <iinit>
    fileinit();      // file table
    80000ed2:	212030ef          	jal	800040e4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	7b2040ef          	jal	80005688 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	597000ef          	jal	80001c70 <userinit>
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00007717          	auipc	a4,0x7
    80000ee8:	96f72623          	sw	a5,-1684(a4) # 80007850 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00007797          	auipc	a5,0x7
    80000efc:	9607b783          	ld	a5,-1696(a5) # 80007858 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde47f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	6ca000ef          	jal	80001830 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00006797          	auipc	a5,0x6
    80001188:	6ca7ba23          	sd	a0,1748(a5) # 80007858 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	43a000ef          	jal	800019aa <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <ptree_add_recursive>:
static void
ptree_add_recursive(struct proc *root, struct proc_tree *tree)
{
  struct proc *p;
  
  if (tree->count >= NPROC)
    80001754:	4198                	lw	a4,0(a1)
    80001756:	03f00793          	li	a5,63
    8000175a:	00e7d363          	bge	a5,a4,80001760 <ptree_add_recursive+0xc>
    8000175e:	8082                	ret
{
    80001760:	7179                	addi	sp,sp,-48
    80001762:	f406                	sd	ra,40(sp)
    80001764:	f022                	sd	s0,32(sp)
    80001766:	ec26                	sd	s1,24(sp)
    80001768:	e84a                	sd	s2,16(sp)
    8000176a:	e44e                	sd	s3,8(sp)
    8000176c:	e052                	sd	s4,0(sp)
    8000176e:	1800                	addi	s0,sp,48
    80001770:	892a                	mv	s2,a0
    80001772:	8a2e                	mv	s4,a1
    return;

  // Add current process to tree
  acquire(&root->lock);
    80001774:	c5aff0ef          	jal	80000bce <acquire>
  if (root->state != UNUSED) {
    80001778:	01892783          	lw	a5,24(s2)
    8000177c:	ef89                	bnez	a5,80001796 <ptree_add_recursive+0x42>
    info->pid = root->pid;
    info->ppid = root->parent ? root->parent->pid : 0;
    info->state = root->state;
    tree->count++;
  }
  release(&root->lock);
    8000177e:	854a                	mv	a0,s2
    80001780:	ce6ff0ef          	jal	80000c66 <release>

  // Find and add all children recursively
  for (p = proc; p < &proc[NPROC]; p++) {
    80001784:	0000e497          	auipc	s1,0xe
    80001788:	61448493          	addi	s1,s1,1556 # 8000fd98 <proc>
    8000178c:	00014997          	auipc	s3,0x14
    80001790:	00c98993          	addi	s3,s3,12 # 80015798 <tickslock>
    80001794:	a0b5                	j	80001800 <ptree_add_recursive+0xac>
    struct proc_info *info = &tree->processes[tree->count];
    80001796:	000a2983          	lw	s3,0(s4)
    safestrcpy(info->name, root->name, sizeof(info->name));
    8000179a:	00399493          	slli	s1,s3,0x3
    8000179e:	41348533          	sub	a0,s1,s3
    800017a2:	050a                	slli	a0,a0,0x2
    800017a4:	0511                	addi	a0,a0,4
    800017a6:	4641                	li	a2,16
    800017a8:	15890593          	addi	a1,s2,344
    800017ac:	9552                	add	a0,a0,s4
    800017ae:	e32ff0ef          	jal	80000de0 <safestrcpy>
    info->pid = root->pid;
    800017b2:	03092703          	lw	a4,48(s2)
    800017b6:	413487b3          	sub	a5,s1,s3
    800017ba:	078a                	slli	a5,a5,0x2
    800017bc:	97d2                	add	a5,a5,s4
    800017be:	cbd8                	sw	a4,20(a5)
    info->ppid = root->parent ? root->parent->pid : 0;
    800017c0:	03893783          	ld	a5,56(s2)
    800017c4:	4681                	li	a3,0
    800017c6:	c391                	beqz	a5,800017ca <ptree_add_recursive+0x76>
    800017c8:	5b94                	lw	a3,48(a5)
    800017ca:	00399793          	slli	a5,s3,0x3
    800017ce:	41378733          	sub	a4,a5,s3
    800017d2:	070a                	slli	a4,a4,0x2
    800017d4:	9752                	add	a4,a4,s4
    800017d6:	cf14                	sw	a3,24(a4)
    info->state = root->state;
    800017d8:	01892703          	lw	a4,24(s2)
    800017dc:	413787b3          	sub	a5,a5,s3
    800017e0:	078a                	slli	a5,a5,0x2
    800017e2:	97d2                	add	a5,a5,s4
    800017e4:	cfd8                	sw	a4,28(a5)
    tree->count++;
    800017e6:	000a2783          	lw	a5,0(s4)
    800017ea:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde489>
    800017ec:	00fa2023          	sw	a5,0(s4)
    800017f0:	b779                	j	8000177e <ptree_add_recursive+0x2a>
    acquire(&p->lock);
    if (p->parent == root && p->state != UNUSED) {
      release(&p->lock);
      ptree_add_recursive(p, tree);
    } else {
      release(&p->lock);
    800017f2:	8526                	mv	a0,s1
    800017f4:	c72ff0ef          	jal	80000c66 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017f8:	16848493          	addi	s1,s1,360
    800017fc:	03348263          	beq	s1,s3,80001820 <ptree_add_recursive+0xcc>
    acquire(&p->lock);
    80001800:	8526                	mv	a0,s1
    80001802:	bccff0ef          	jal	80000bce <acquire>
    if (p->parent == root && p->state != UNUSED) {
    80001806:	7c9c                	ld	a5,56(s1)
    80001808:	ff2795e3          	bne	a5,s2,800017f2 <ptree_add_recursive+0x9e>
    8000180c:	4c9c                	lw	a5,24(s1)
    8000180e:	d3f5                	beqz	a5,800017f2 <ptree_add_recursive+0x9e>
      release(&p->lock);
    80001810:	8526                	mv	a0,s1
    80001812:	c54ff0ef          	jal	80000c66 <release>
      ptree_add_recursive(p, tree);
    80001816:	85d2                	mv	a1,s4
    80001818:	8526                	mv	a0,s1
    8000181a:	f3bff0ef          	jal	80001754 <ptree_add_recursive>
    8000181e:	bfe9                	j	800017f8 <ptree_add_recursive+0xa4>
    }
  }
}
    80001820:	70a2                	ld	ra,40(sp)
    80001822:	7402                	ld	s0,32(sp)
    80001824:	64e2                	ld	s1,24(sp)
    80001826:	6942                	ld	s2,16(sp)
    80001828:	69a2                	ld	s3,8(sp)
    8000182a:	6a02                	ld	s4,0(sp)
    8000182c:	6145                	addi	sp,sp,48
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	0000e497          	auipc	s1,0xe
    8000184a:	55248493          	addi	s1,s1,1362 # 8000fd98 <proc>
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	04fa5937          	lui	s2,0x4fa5
    80001854:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001858:	0932                	slli	s2,s2,0xc
    8000185a:	fa590913          	addi	s2,s2,-91
    8000185e:	0932                	slli	s2,s2,0xc
    80001860:	fa590913          	addi	s2,s2,-91
    80001864:	0932                	slli	s2,s2,0xc
    80001866:	fa590913          	addi	s2,s2,-91
    8000186a:	040009b7          	lui	s3,0x4000
    8000186e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001870:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001872:	00014a97          	auipc	s5,0x14
    80001876:	f26a8a93          	addi	s5,s5,-218 # 80015798 <tickslock>
    char *pa = kalloc();
    8000187a:	a84ff0ef          	jal	80000afe <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	cd15                	beqz	a0,800018bc <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	858d                	srai	a1,a1,0x3
    80001888:	032585b3          	mul	a1,a1,s2
    8000188c:	2585                	addiw	a1,a1,1
    8000188e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001892:	4719                	li	a4,6
    80001894:	6685                	lui	a3,0x1
    80001896:	40b985b3          	sub	a1,s3,a1
    8000189a:	8552                	mv	a0,s4
    8000189c:	803ff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	16848493          	addi	s1,s1,360
    800018a4:	fd549be3          	bne	s1,s5,8000187a <proc_mapstacks+0x4a>
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00006517          	auipc	a0,0x6
    800018c0:	89c50513          	addi	a0,a0,-1892 # 80007158 <etext+0x158>
    800018c4:	f1dfe0ef          	jal	800007e0 <panic>

00000000800018c8 <procinit>:
{
    800018c8:	7139                	addi	sp,sp,-64
    800018ca:	fc06                	sd	ra,56(sp)
    800018cc:	f822                	sd	s0,48(sp)
    800018ce:	f426                	sd	s1,40(sp)
    800018d0:	f04a                	sd	s2,32(sp)
    800018d2:	ec4e                	sd	s3,24(sp)
    800018d4:	e852                	sd	s4,16(sp)
    800018d6:	e456                	sd	s5,8(sp)
    800018d8:	e05a                	sd	s6,0(sp)
    800018da:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800018dc:	00006597          	auipc	a1,0x6
    800018e0:	88458593          	addi	a1,a1,-1916 # 80007160 <etext+0x160>
    800018e4:	0000e517          	auipc	a0,0xe
    800018e8:	08450513          	addi	a0,a0,132 # 8000f968 <pid_lock>
    800018ec:	a62ff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f0:	00006597          	auipc	a1,0x6
    800018f4:	87858593          	addi	a1,a1,-1928 # 80007168 <etext+0x168>
    800018f8:	0000e517          	auipc	a0,0xe
    800018fc:	08850513          	addi	a0,a0,136 # 8000f980 <wait_lock>
    80001900:	a4eff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001904:	0000e497          	auipc	s1,0xe
    80001908:	49448493          	addi	s1,s1,1172 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    8000190c:	00006b17          	auipc	s6,0x6
    80001910:	86cb0b13          	addi	s6,s6,-1940 # 80007178 <etext+0x178>
      p->kstack = KSTACK((int) (p - proc));
    80001914:	8aa6                	mv	s5,s1
    80001916:	04fa5937          	lui	s2,0x4fa5
    8000191a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000191e:	0932                	slli	s2,s2,0xc
    80001920:	fa590913          	addi	s2,s2,-91
    80001924:	0932                	slli	s2,s2,0xc
    80001926:	fa590913          	addi	s2,s2,-91
    8000192a:	0932                	slli	s2,s2,0xc
    8000192c:	fa590913          	addi	s2,s2,-91
    80001930:	040009b7          	lui	s3,0x4000
    80001934:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001936:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001938:	00014a17          	auipc	s4,0x14
    8000193c:	e60a0a13          	addi	s4,s4,-416 # 80015798 <tickslock>
      initlock(&p->lock, "proc");
    80001940:	85da                	mv	a1,s6
    80001942:	8526                	mv	a0,s1
    80001944:	a0aff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001948:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194c:	415487b3          	sub	a5,s1,s5
    80001950:	878d                	srai	a5,a5,0x3
    80001952:	032787b3          	mul	a5,a5,s2
    80001956:	2785                	addiw	a5,a5,1
    80001958:	00d7979b          	slliw	a5,a5,0xd
    8000195c:	40f987b3          	sub	a5,s3,a5
    80001960:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001962:	16848493          	addi	s1,s1,360
    80001966:	fd449de3          	bne	s1,s4,80001940 <procinit+0x78>
}
    8000196a:	70e2                	ld	ra,56(sp)
    8000196c:	7442                	ld	s0,48(sp)
    8000196e:	74a2                	ld	s1,40(sp)
    80001970:	7902                	ld	s2,32(sp)
    80001972:	69e2                	ld	s3,24(sp)
    80001974:	6a42                	ld	s4,16(sp)
    80001976:	6aa2                	ld	s5,8(sp)
    80001978:	6b02                	ld	s6,0(sp)
    8000197a:	6121                	addi	sp,sp,64
    8000197c:	8082                	ret

000000008000197e <cpuid>:
{
    8000197e:	1141                	addi	sp,sp,-16
    80001980:	e422                	sd	s0,8(sp)
    80001982:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001984:	8512                	mv	a0,tp
}
    80001986:	2501                	sext.w	a0,a0
    80001988:	6422                	ld	s0,8(sp)
    8000198a:	0141                	addi	sp,sp,16
    8000198c:	8082                	ret

000000008000198e <mycpu>:
{
    8000198e:	1141                	addi	sp,sp,-16
    80001990:	e422                	sd	s0,8(sp)
    80001992:	0800                	addi	s0,sp,16
    80001994:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001996:	2781                	sext.w	a5,a5
    80001998:	079e                	slli	a5,a5,0x7
}
    8000199a:	0000e517          	auipc	a0,0xe
    8000199e:	ffe50513          	addi	a0,a0,-2 # 8000f998 <cpus>
    800019a2:	953e                	add	a0,a0,a5
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <myproc>:
{
    800019aa:	1101                	addi	sp,sp,-32
    800019ac:	ec06                	sd	ra,24(sp)
    800019ae:	e822                	sd	s0,16(sp)
    800019b0:	e426                	sd	s1,8(sp)
    800019b2:	1000                	addi	s0,sp,32
  push_off();
    800019b4:	9daff0ef          	jal	80000b8e <push_off>
    800019b8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	slli	a5,a5,0x7
    800019be:	0000e717          	auipc	a4,0xe
    800019c2:	faa70713          	addi	a4,a4,-86 # 8000f968 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	a48ff0ef          	jal	80000c12 <pop_off>
}
    800019ce:	8526                	mv	a0,s1
    800019d0:	60e2                	ld	ra,24(sp)
    800019d2:	6442                	ld	s0,16(sp)
    800019d4:	64a2                	ld	s1,8(sp)
    800019d6:	6105                	addi	sp,sp,32
    800019d8:	8082                	ret

00000000800019da <forkret>:
{
    800019da:	7179                	addi	sp,sp,-48
    800019dc:	f406                	sd	ra,40(sp)
    800019de:	f022                	sd	s0,32(sp)
    800019e0:	ec26                	sd	s1,24(sp)
    800019e2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800019e4:	fc7ff0ef          	jal	800019aa <myproc>
    800019e8:	84aa                	mv	s1,a0
  release(&p->lock);
    800019ea:	a7cff0ef          	jal	80000c66 <release>
  if (first) {
    800019ee:	00006797          	auipc	a5,0x6
    800019f2:	e427a783          	lw	a5,-446(a5) # 80007830 <first.1>
    800019f6:	cf8d                	beqz	a5,80001a30 <forkret+0x56>
    fsinit(ROOTDEV);
    800019f8:	4505                	li	a0,1
    800019fa:	4b1010ef          	jal	800036aa <fsinit>
    first = 0;
    800019fe:	00006797          	auipc	a5,0x6
    80001a02:	e207a923          	sw	zero,-462(a5) # 80007830 <first.1>
    __sync_synchronize();
    80001a06:	0ff0000f          	fence
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001a0a:	00005517          	auipc	a0,0x5
    80001a0e:	77650513          	addi	a0,a0,1910 # 80007180 <etext+0x180>
    80001a12:	fca43823          	sd	a0,-48(s0)
    80001a16:	fc043c23          	sd	zero,-40(s0)
    80001a1a:	fd040593          	addi	a1,s0,-48
    80001a1e:	597020ef          	jal	800047b4 <kexec>
    80001a22:	6cbc                	ld	a5,88(s1)
    80001a24:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a26:	6cbc                	ld	a5,88(s1)
    80001a28:	7bb8                	ld	a4,112(a5)
    80001a2a:	57fd                	li	a5,-1
    80001a2c:	02f70d63          	beq	a4,a5,80001a66 <forkret+0x8c>
  prepare_return();
    80001a30:	32b000ef          	jal	8000255a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a34:	68a8                	ld	a0,80(s1)
    80001a36:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a38:	04000737          	lui	a4,0x4000
    80001a3c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a3e:	0732                	slli	a4,a4,0xc
    80001a40:	00004797          	auipc	a5,0x4
    80001a44:	65c78793          	addi	a5,a5,1628 # 8000609c <userret>
    80001a48:	00004697          	auipc	a3,0x4
    80001a4c:	5b868693          	addi	a3,a3,1464 # 80006000 <_trampoline>
    80001a50:	8f95                	sub	a5,a5,a3
    80001a52:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a54:	577d                	li	a4,-1
    80001a56:	177e                	slli	a4,a4,0x3f
    80001a58:	8d59                	or	a0,a0,a4
    80001a5a:	9782                	jalr	a5
}
    80001a5c:	70a2                	ld	ra,40(sp)
    80001a5e:	7402                	ld	s0,32(sp)
    80001a60:	64e2                	ld	s1,24(sp)
    80001a62:	6145                	addi	sp,sp,48
    80001a64:	8082                	ret
      panic("exec");
    80001a66:	00005517          	auipc	a0,0x5
    80001a6a:	72250513          	addi	a0,a0,1826 # 80007188 <etext+0x188>
    80001a6e:	d73fe0ef          	jal	800007e0 <panic>

0000000080001a72 <allocpid>:
{
    80001a72:	1101                	addi	sp,sp,-32
    80001a74:	ec06                	sd	ra,24(sp)
    80001a76:	e822                	sd	s0,16(sp)
    80001a78:	e426                	sd	s1,8(sp)
    80001a7a:	e04a                	sd	s2,0(sp)
    80001a7c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a7e:	0000e917          	auipc	s2,0xe
    80001a82:	eea90913          	addi	s2,s2,-278 # 8000f968 <pid_lock>
    80001a86:	854a                	mv	a0,s2
    80001a88:	946ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001a8c:	00006797          	auipc	a5,0x6
    80001a90:	da878793          	addi	a5,a5,-600 # 80007834 <nextpid>
    80001a94:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a96:	0014871b          	addiw	a4,s1,1
    80001a9a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9c:	854a                	mv	a0,s2
    80001a9e:	9c8ff0ef          	jal	80000c66 <release>
}
    80001aa2:	8526                	mv	a0,s1
    80001aa4:	60e2                	ld	ra,24(sp)
    80001aa6:	6442                	ld	s0,16(sp)
    80001aa8:	64a2                	ld	s1,8(sp)
    80001aaa:	6902                	ld	s2,0(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret

0000000080001ab0 <proc_pagetable>:
{
    80001ab0:	1101                	addi	sp,sp,-32
    80001ab2:	ec06                	sd	ra,24(sp)
    80001ab4:	e822                	sd	s0,16(sp)
    80001ab6:	e426                	sd	s1,8(sp)
    80001ab8:	e04a                	sd	s2,0(sp)
    80001aba:	1000                	addi	s0,sp,32
    80001abc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001abe:	ed6ff0ef          	jal	80001194 <uvmcreate>
    80001ac2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ac4:	cd05                	beqz	a0,80001afc <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac6:	4729                	li	a4,10
    80001ac8:	00004697          	auipc	a3,0x4
    80001acc:	53868693          	addi	a3,a3,1336 # 80006000 <_trampoline>
    80001ad0:	6605                	lui	a2,0x1
    80001ad2:	040005b7          	lui	a1,0x4000
    80001ad6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad8:	05b2                	slli	a1,a1,0xc
    80001ada:	d14ff0ef          	jal	80000fee <mappages>
    80001ade:	02054663          	bltz	a0,80001b0a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae2:	4719                	li	a4,6
    80001ae4:	05893683          	ld	a3,88(s2)
    80001ae8:	6605                	lui	a2,0x1
    80001aea:	020005b7          	lui	a1,0x2000
    80001aee:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001af0:	05b6                	slli	a1,a1,0xd
    80001af2:	8526                	mv	a0,s1
    80001af4:	cfaff0ef          	jal	80000fee <mappages>
    80001af8:	00054f63          	bltz	a0,80001b16 <proc_pagetable+0x66>
}
    80001afc:	8526                	mv	a0,s1
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6902                	ld	s2,0(sp)
    80001b06:	6105                	addi	sp,sp,32
    80001b08:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0a:	4581                	li	a1,0
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	881ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	b7e5                	j	80001afc <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	8526                	mv	a0,s1
    80001b24:	e96ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001b28:	4581                	li	a1,0
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	863ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001b30:	4481                	li	s1,0
    80001b32:	b7e9                	j	80001afc <proc_pagetable+0x4c>

0000000080001b34 <proc_freepagetable>:
{
    80001b34:	1101                	addi	sp,sp,-32
    80001b36:	ec06                	sd	ra,24(sp)
    80001b38:	e822                	sd	s0,16(sp)
    80001b3a:	e426                	sd	s1,8(sp)
    80001b3c:	e04a                	sd	s2,0(sp)
    80001b3e:	1000                	addi	s0,sp,32
    80001b40:	84aa                	mv	s1,a0
    80001b42:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b44:	4681                	li	a3,0
    80001b46:	4605                	li	a2,1
    80001b48:	040005b7          	lui	a1,0x4000
    80001b4c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b4e:	05b2                	slli	a1,a1,0xc
    80001b50:	e6aff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b54:	4681                	li	a3,0
    80001b56:	4605                	li	a2,1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	e58ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001b66:	85ca                	mv	a1,s2
    80001b68:	8526                	mv	a0,s1
    80001b6a:	825ff0ef          	jal	8000138e <uvmfree>
}
    80001b6e:	60e2                	ld	ra,24(sp)
    80001b70:	6442                	ld	s0,16(sp)
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	6902                	ld	s2,0(sp)
    80001b76:	6105                	addi	sp,sp,32
    80001b78:	8082                	ret

0000000080001b7a <freeproc>:
{
    80001b7a:	1101                	addi	sp,sp,-32
    80001b7c:	ec06                	sd	ra,24(sp)
    80001b7e:	e822                	sd	s0,16(sp)
    80001b80:	e426                	sd	s1,8(sp)
    80001b82:	1000                	addi	s0,sp,32
    80001b84:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b86:	6d28                	ld	a0,88(a0)
    80001b88:	c119                	beqz	a0,80001b8e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b8a:	e93fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001b8e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b92:	68a8                	ld	a0,80(s1)
    80001b94:	c501                	beqz	a0,80001b9c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b96:	64ac                	ld	a1,72(s1)
    80001b98:	f9dff0ef          	jal	80001b34 <proc_freepagetable>
  p->pagetable = 0;
    80001b9c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ba4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ba8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bac:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bb0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bb4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bb8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bbc:	0004ac23          	sw	zero,24(s1)
}
    80001bc0:	60e2                	ld	ra,24(sp)
    80001bc2:	6442                	ld	s0,16(sp)
    80001bc4:	64a2                	ld	s1,8(sp)
    80001bc6:	6105                	addi	sp,sp,32
    80001bc8:	8082                	ret

0000000080001bca <allocproc>:
{
    80001bca:	1101                	addi	sp,sp,-32
    80001bcc:	ec06                	sd	ra,24(sp)
    80001bce:	e822                	sd	s0,16(sp)
    80001bd0:	e426                	sd	s1,8(sp)
    80001bd2:	e04a                	sd	s2,0(sp)
    80001bd4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd6:	0000e497          	auipc	s1,0xe
    80001bda:	1c248493          	addi	s1,s1,450 # 8000fd98 <proc>
    80001bde:	00014917          	auipc	s2,0x14
    80001be2:	bba90913          	addi	s2,s2,-1094 # 80015798 <tickslock>
    acquire(&p->lock);
    80001be6:	8526                	mv	a0,s1
    80001be8:	fe7fe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001bec:	4c9c                	lw	a5,24(s1)
    80001bee:	cb91                	beqz	a5,80001c02 <allocproc+0x38>
      release(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	874ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf6:	16848493          	addi	s1,s1,360
    80001bfa:	ff2496e3          	bne	s1,s2,80001be6 <allocproc+0x1c>
  return 0;
    80001bfe:	4481                	li	s1,0
    80001c00:	a089                	j	80001c42 <allocproc+0x78>
  p->pid = allocpid();
    80001c02:	e71ff0ef          	jal	80001a72 <allocpid>
    80001c06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c08:	4785                	li	a5,1
    80001c0a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c0c:	ef3fe0ef          	jal	80000afe <kalloc>
    80001c10:	892a                	mv	s2,a0
    80001c12:	eca8                	sd	a0,88(s1)
    80001c14:	cd15                	beqz	a0,80001c50 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001c16:	8526                	mv	a0,s1
    80001c18:	e99ff0ef          	jal	80001ab0 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c121                	beqz	a0,80001c60 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	876ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001c30:	00000797          	auipc	a5,0x0
    80001c34:	daa78793          	addi	a5,a5,-598 # 800019da <forkret>
    80001c38:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3a:	60bc                	ld	a5,64(s1)
    80001c3c:	6705                	lui	a4,0x1
    80001c3e:	97ba                	add	a5,a5,a4
    80001c40:	f4bc                	sd	a5,104(s1)
}
    80001c42:	8526                	mv	a0,s1
    80001c44:	60e2                	ld	ra,24(sp)
    80001c46:	6442                	ld	s0,16(sp)
    80001c48:	64a2                	ld	s1,8(sp)
    80001c4a:	6902                	ld	s2,0(sp)
    80001c4c:	6105                	addi	sp,sp,32
    80001c4e:	8082                	ret
    freeproc(p);
    80001c50:	8526                	mv	a0,s1
    80001c52:	f29ff0ef          	jal	80001b7a <freeproc>
    release(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	80eff0ef          	jal	80000c66 <release>
    return 0;
    80001c5c:	84ca                	mv	s1,s2
    80001c5e:	b7d5                	j	80001c42 <allocproc+0x78>
    freeproc(p);
    80001c60:	8526                	mv	a0,s1
    80001c62:	f19ff0ef          	jal	80001b7a <freeproc>
    release(&p->lock);
    80001c66:	8526                	mv	a0,s1
    80001c68:	ffffe0ef          	jal	80000c66 <release>
    return 0;
    80001c6c:	84ca                	mv	s1,s2
    80001c6e:	bfd1                	j	80001c42 <allocproc+0x78>

0000000080001c70 <userinit>:
{
    80001c70:	1101                	addi	sp,sp,-32
    80001c72:	ec06                	sd	ra,24(sp)
    80001c74:	e822                	sd	s0,16(sp)
    80001c76:	e426                	sd	s1,8(sp)
    80001c78:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c7a:	f51ff0ef          	jal	80001bca <allocproc>
    80001c7e:	84aa                	mv	s1,a0
  initproc = p;
    80001c80:	00006797          	auipc	a5,0x6
    80001c84:	bea7b023          	sd	a0,-1056(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001c88:	00005517          	auipc	a0,0x5
    80001c8c:	50850513          	addi	a0,a0,1288 # 80007190 <etext+0x190>
    80001c90:	73d010ef          	jal	80003bcc <namei>
    80001c94:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c98:	478d                	li	a5,3
    80001c9a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	fc9fe0ef          	jal	80000c66 <release>
}
    80001ca2:	60e2                	ld	ra,24(sp)
    80001ca4:	6442                	ld	s0,16(sp)
    80001ca6:	64a2                	ld	s1,8(sp)
    80001ca8:	6105                	addi	sp,sp,32
    80001caa:	8082                	ret

0000000080001cac <growproc>:
{
    80001cac:	1101                	addi	sp,sp,-32
    80001cae:	ec06                	sd	ra,24(sp)
    80001cb0:	e822                	sd	s0,16(sp)
    80001cb2:	e426                	sd	s1,8(sp)
    80001cb4:	e04a                	sd	s2,0(sp)
    80001cb6:	1000                	addi	s0,sp,32
    80001cb8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cba:	cf1ff0ef          	jal	800019aa <myproc>
    80001cbe:	892a                	mv	s2,a0
  sz = p->sz;
    80001cc0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001cc2:	02905963          	blez	s1,80001cf4 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001cc6:	00b48633          	add	a2,s1,a1
    80001cca:	020007b7          	lui	a5,0x2000
    80001cce:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cd0:	07b6                	slli	a5,a5,0xd
    80001cd2:	02c7ea63          	bltu	a5,a2,80001d06 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cd6:	4691                	li	a3,4
    80001cd8:	6928                	ld	a0,80(a0)
    80001cda:	daeff0ef          	jal	80001288 <uvmalloc>
    80001cde:	85aa                	mv	a1,a0
    80001ce0:	c50d                	beqz	a0,80001d0a <growproc+0x5e>
  p->sz = sz;
    80001ce2:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ce6:	4501                	li	a0,0
}
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6902                	ld	s2,0(sp)
    80001cf0:	6105                	addi	sp,sp,32
    80001cf2:	8082                	ret
  } else if(n < 0){
    80001cf4:	fe04d7e3          	bgez	s1,80001ce2 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cf8:	00b48633          	add	a2,s1,a1
    80001cfc:	6928                	ld	a0,80(a0)
    80001cfe:	d46ff0ef          	jal	80001244 <uvmdealloc>
    80001d02:	85aa                	mv	a1,a0
    80001d04:	bff9                	j	80001ce2 <growproc+0x36>
      return -1;
    80001d06:	557d                	li	a0,-1
    80001d08:	b7c5                	j	80001ce8 <growproc+0x3c>
      return -1;
    80001d0a:	557d                	li	a0,-1
    80001d0c:	bff1                	j	80001ce8 <growproc+0x3c>

0000000080001d0e <kfork>:
{
    80001d0e:	7139                	addi	sp,sp,-64
    80001d10:	fc06                	sd	ra,56(sp)
    80001d12:	f822                	sd	s0,48(sp)
    80001d14:	f04a                	sd	s2,32(sp)
    80001d16:	e456                	sd	s5,8(sp)
    80001d18:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d1a:	c91ff0ef          	jal	800019aa <myproc>
    80001d1e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d20:	eabff0ef          	jal	80001bca <allocproc>
    80001d24:	0e050a63          	beqz	a0,80001e18 <kfork+0x10a>
    80001d28:	e852                	sd	s4,16(sp)
    80001d2a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d2c:	048ab603          	ld	a2,72(s5)
    80001d30:	692c                	ld	a1,80(a0)
    80001d32:	050ab503          	ld	a0,80(s5)
    80001d36:	e8aff0ef          	jal	800013c0 <uvmcopy>
    80001d3a:	04054a63          	bltz	a0,80001d8e <kfork+0x80>
    80001d3e:	f426                	sd	s1,40(sp)
    80001d40:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d42:	048ab783          	ld	a5,72(s5)
    80001d46:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d4a:	058ab683          	ld	a3,88(s5)
    80001d4e:	87b6                	mv	a5,a3
    80001d50:	058a3703          	ld	a4,88(s4)
    80001d54:	12068693          	addi	a3,a3,288
    80001d58:	0007b803          	ld	a6,0(a5)
    80001d5c:	6788                	ld	a0,8(a5)
    80001d5e:	6b8c                	ld	a1,16(a5)
    80001d60:	6f90                	ld	a2,24(a5)
    80001d62:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001d66:	e708                	sd	a0,8(a4)
    80001d68:	eb0c                	sd	a1,16(a4)
    80001d6a:	ef10                	sd	a2,24(a4)
    80001d6c:	02078793          	addi	a5,a5,32
    80001d70:	02070713          	addi	a4,a4,32
    80001d74:	fed792e3          	bne	a5,a3,80001d58 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d78:	058a3783          	ld	a5,88(s4)
    80001d7c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d80:	0d0a8493          	addi	s1,s5,208
    80001d84:	0d0a0913          	addi	s2,s4,208
    80001d88:	150a8993          	addi	s3,s5,336
    80001d8c:	a831                	j	80001da8 <kfork+0x9a>
    freeproc(np);
    80001d8e:	8552                	mv	a0,s4
    80001d90:	debff0ef          	jal	80001b7a <freeproc>
    release(&np->lock);
    80001d94:	8552                	mv	a0,s4
    80001d96:	ed1fe0ef          	jal	80000c66 <release>
    return -1;
    80001d9a:	597d                	li	s2,-1
    80001d9c:	6a42                	ld	s4,16(sp)
    80001d9e:	a0b5                	j	80001e0a <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001da0:	04a1                	addi	s1,s1,8
    80001da2:	0921                	addi	s2,s2,8
    80001da4:	01348963          	beq	s1,s3,80001db6 <kfork+0xa8>
    if(p->ofile[i])
    80001da8:	6088                	ld	a0,0(s1)
    80001daa:	d97d                	beqz	a0,80001da0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001dac:	3ba020ef          	jal	80004166 <filedup>
    80001db0:	00a93023          	sd	a0,0(s2)
    80001db4:	b7f5                	j	80001da0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001db6:	150ab503          	ld	a0,336(s5)
    80001dba:	5c6010ef          	jal	80003380 <idup>
    80001dbe:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dc2:	4641                	li	a2,16
    80001dc4:	158a8593          	addi	a1,s5,344
    80001dc8:	158a0513          	addi	a0,s4,344
    80001dcc:	814ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001dd0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001dd4:	8552                	mv	a0,s4
    80001dd6:	e91fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001dda:	0000e497          	auipc	s1,0xe
    80001dde:	ba648493          	addi	s1,s1,-1114 # 8000f980 <wait_lock>
    80001de2:	8526                	mv	a0,s1
    80001de4:	debfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001de8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dec:	8526                	mv	a0,s1
    80001dee:	e79fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001df2:	8552                	mv	a0,s4
    80001df4:	ddbfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001df8:	478d                	li	a5,3
    80001dfa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dfe:	8552                	mv	a0,s4
    80001e00:	e67fe0ef          	jal	80000c66 <release>
  return pid;
    80001e04:	74a2                	ld	s1,40(sp)
    80001e06:	69e2                	ld	s3,24(sp)
    80001e08:	6a42                	ld	s4,16(sp)
}
    80001e0a:	854a                	mv	a0,s2
    80001e0c:	70e2                	ld	ra,56(sp)
    80001e0e:	7442                	ld	s0,48(sp)
    80001e10:	7902                	ld	s2,32(sp)
    80001e12:	6aa2                	ld	s5,8(sp)
    80001e14:	6121                	addi	sp,sp,64
    80001e16:	8082                	ret
    return -1;
    80001e18:	597d                	li	s2,-1
    80001e1a:	bfc5                	j	80001e0a <kfork+0xfc>

0000000080001e1c <scheduler>:
{
    80001e1c:	715d                	addi	sp,sp,-80
    80001e1e:	e486                	sd	ra,72(sp)
    80001e20:	e0a2                	sd	s0,64(sp)
    80001e22:	fc26                	sd	s1,56(sp)
    80001e24:	f84a                	sd	s2,48(sp)
    80001e26:	f44e                	sd	s3,40(sp)
    80001e28:	f052                	sd	s4,32(sp)
    80001e2a:	ec56                	sd	s5,24(sp)
    80001e2c:	e85a                	sd	s6,16(sp)
    80001e2e:	e45e                	sd	s7,8(sp)
    80001e30:	e062                	sd	s8,0(sp)
    80001e32:	0880                	addi	s0,sp,80
    80001e34:	8792                	mv	a5,tp
  int id = r_tp();
    80001e36:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e38:	00779b13          	slli	s6,a5,0x7
    80001e3c:	0000e717          	auipc	a4,0xe
    80001e40:	b2c70713          	addi	a4,a4,-1236 # 8000f968 <pid_lock>
    80001e44:	975a                	add	a4,a4,s6
    80001e46:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e4a:	0000e717          	auipc	a4,0xe
    80001e4e:	b5670713          	addi	a4,a4,-1194 # 8000f9a0 <cpus+0x8>
    80001e52:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e54:	4c11                	li	s8,4
        c->proc = p;
    80001e56:	079e                	slli	a5,a5,0x7
    80001e58:	0000ea17          	auipc	s4,0xe
    80001e5c:	b10a0a13          	addi	s4,s4,-1264 # 8000f968 <pid_lock>
    80001e60:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e62:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e64:	00014997          	auipc	s3,0x14
    80001e68:	93498993          	addi	s3,s3,-1740 # 80015798 <tickslock>
    80001e6c:	a83d                	j	80001eaa <scheduler+0x8e>
      release(&p->lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	df7fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e74:	16848493          	addi	s1,s1,360
    80001e78:	03348563          	beq	s1,s3,80001ea2 <scheduler+0x86>
      acquire(&p->lock);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	d51fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001e82:	4c9c                	lw	a5,24(s1)
    80001e84:	ff2795e3          	bne	a5,s2,80001e6e <scheduler+0x52>
        p->state = RUNNING;
    80001e88:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e8c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e90:	06048593          	addi	a1,s1,96
    80001e94:	855a                	mv	a0,s6
    80001e96:	61e000ef          	jal	800024b4 <swtch>
        c->proc = 0;
    80001e9a:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e9e:	8ade                	mv	s5,s7
    80001ea0:	b7f9                	j	80001e6e <scheduler+0x52>
    if(found == 0) {
    80001ea2:	000a9463          	bnez	s5,80001eaa <scheduler+0x8e>
      asm volatile("wfi");
    80001ea6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eaa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eb2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eb6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001eba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ebc:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001ec0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ec2:	0000e497          	auipc	s1,0xe
    80001ec6:	ed648493          	addi	s1,s1,-298 # 8000fd98 <proc>
      if(p->state == RUNNABLE) {
    80001eca:	490d                	li	s2,3
    80001ecc:	bf45                	j	80001e7c <scheduler+0x60>

0000000080001ece <sched>:
{
    80001ece:	7179                	addi	sp,sp,-48
    80001ed0:	f406                	sd	ra,40(sp)
    80001ed2:	f022                	sd	s0,32(sp)
    80001ed4:	ec26                	sd	s1,24(sp)
    80001ed6:	e84a                	sd	s2,16(sp)
    80001ed8:	e44e                	sd	s3,8(sp)
    80001eda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001edc:	acfff0ef          	jal	800019aa <myproc>
    80001ee0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ee2:	c83fe0ef          	jal	80000b64 <holding>
    80001ee6:	c92d                	beqz	a0,80001f58 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ee8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001eea:	2781                	sext.w	a5,a5
    80001eec:	079e                	slli	a5,a5,0x7
    80001eee:	0000e717          	auipc	a4,0xe
    80001ef2:	a7a70713          	addi	a4,a4,-1414 # 8000f968 <pid_lock>
    80001ef6:	97ba                	add	a5,a5,a4
    80001ef8:	0a87a703          	lw	a4,168(a5)
    80001efc:	4785                	li	a5,1
    80001efe:	06f71363          	bne	a4,a5,80001f64 <sched+0x96>
  if(p->state == RUNNING)
    80001f02:	4c98                	lw	a4,24(s1)
    80001f04:	4791                	li	a5,4
    80001f06:	06f70563          	beq	a4,a5,80001f70 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f0a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f0e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f10:	e7b5                	bnez	a5,80001f7c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f12:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f14:	0000e917          	auipc	s2,0xe
    80001f18:	a5490913          	addi	s2,s2,-1452 # 8000f968 <pid_lock>
    80001f1c:	2781                	sext.w	a5,a5
    80001f1e:	079e                	slli	a5,a5,0x7
    80001f20:	97ca                	add	a5,a5,s2
    80001f22:	0ac7a983          	lw	s3,172(a5)
    80001f26:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f28:	2781                	sext.w	a5,a5
    80001f2a:	079e                	slli	a5,a5,0x7
    80001f2c:	0000e597          	auipc	a1,0xe
    80001f30:	a7458593          	addi	a1,a1,-1420 # 8000f9a0 <cpus+0x8>
    80001f34:	95be                	add	a1,a1,a5
    80001f36:	06048513          	addi	a0,s1,96
    80001f3a:	57a000ef          	jal	800024b4 <swtch>
    80001f3e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f40:	2781                	sext.w	a5,a5
    80001f42:	079e                	slli	a5,a5,0x7
    80001f44:	993e                	add	s2,s2,a5
    80001f46:	0b392623          	sw	s3,172(s2)
}
    80001f4a:	70a2                	ld	ra,40(sp)
    80001f4c:	7402                	ld	s0,32(sp)
    80001f4e:	64e2                	ld	s1,24(sp)
    80001f50:	6942                	ld	s2,16(sp)
    80001f52:	69a2                	ld	s3,8(sp)
    80001f54:	6145                	addi	sp,sp,48
    80001f56:	8082                	ret
    panic("sched p->lock");
    80001f58:	00005517          	auipc	a0,0x5
    80001f5c:	24050513          	addi	a0,a0,576 # 80007198 <etext+0x198>
    80001f60:	881fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001f64:	00005517          	auipc	a0,0x5
    80001f68:	24450513          	addi	a0,a0,580 # 800071a8 <etext+0x1a8>
    80001f6c:	875fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001f70:	00005517          	auipc	a0,0x5
    80001f74:	24850513          	addi	a0,a0,584 # 800071b8 <etext+0x1b8>
    80001f78:	869fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001f7c:	00005517          	auipc	a0,0x5
    80001f80:	24c50513          	addi	a0,a0,588 # 800071c8 <etext+0x1c8>
    80001f84:	85dfe0ef          	jal	800007e0 <panic>

0000000080001f88 <yield>:
{
    80001f88:	1101                	addi	sp,sp,-32
    80001f8a:	ec06                	sd	ra,24(sp)
    80001f8c:	e822                	sd	s0,16(sp)
    80001f8e:	e426                	sd	s1,8(sp)
    80001f90:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f92:	a19ff0ef          	jal	800019aa <myproc>
    80001f96:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f98:	c37fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001f9c:	478d                	li	a5,3
    80001f9e:	cc9c                	sw	a5,24(s1)
  sched();
    80001fa0:	f2fff0ef          	jal	80001ece <sched>
  release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	cc1fe0ef          	jal	80000c66 <release>
}
    80001faa:	60e2                	ld	ra,24(sp)
    80001fac:	6442                	ld	s0,16(sp)
    80001fae:	64a2                	ld	s1,8(sp)
    80001fb0:	6105                	addi	sp,sp,32
    80001fb2:	8082                	ret

0000000080001fb4 <sleep>:
{
    80001fb4:	7179                	addi	sp,sp,-48
    80001fb6:	f406                	sd	ra,40(sp)
    80001fb8:	f022                	sd	s0,32(sp)
    80001fba:	ec26                	sd	s1,24(sp)
    80001fbc:	e84a                	sd	s2,16(sp)
    80001fbe:	e44e                	sd	s3,8(sp)
    80001fc0:	1800                	addi	s0,sp,48
    80001fc2:	89aa                	mv	s3,a0
    80001fc4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fc6:	9e5ff0ef          	jal	800019aa <myproc>
    80001fca:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    80001fcc:	c03fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001fd0:	854a                	mv	a0,s2
    80001fd2:	c95fe0ef          	jal	80000c66 <release>
  p->chan = chan;
    80001fd6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fda:	4789                	li	a5,2
    80001fdc:	cc9c                	sw	a5,24(s1)
  sched();
    80001fde:	ef1ff0ef          	jal	80001ece <sched>
  p->chan = 0;
    80001fe2:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	c7ffe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001fec:	854a                	mv	a0,s2
    80001fee:	be1fe0ef          	jal	80000bce <acquire>
}
    80001ff2:	70a2                	ld	ra,40(sp)
    80001ff4:	7402                	ld	s0,32(sp)
    80001ff6:	64e2                	ld	s1,24(sp)
    80001ff8:	6942                	ld	s2,16(sp)
    80001ffa:	69a2                	ld	s3,8(sp)
    80001ffc:	6145                	addi	sp,sp,48
    80001ffe:	8082                	ret

0000000080002000 <wakeup>:
{
    80002000:	7139                	addi	sp,sp,-64
    80002002:	fc06                	sd	ra,56(sp)
    80002004:	f822                	sd	s0,48(sp)
    80002006:	f426                	sd	s1,40(sp)
    80002008:	f04a                	sd	s2,32(sp)
    8000200a:	ec4e                	sd	s3,24(sp)
    8000200c:	e852                	sd	s4,16(sp)
    8000200e:	e456                	sd	s5,8(sp)
    80002010:	0080                	addi	s0,sp,64
    80002012:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	0000e497          	auipc	s1,0xe
    80002018:	d8448493          	addi	s1,s1,-636 # 8000fd98 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    8000201c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000201e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002020:	00013917          	auipc	s2,0x13
    80002024:	77890913          	addi	s2,s2,1912 # 80015798 <tickslock>
    80002028:	a801                	j	80002038 <wakeup+0x38>
      release(&p->lock);
    8000202a:	8526                	mv	a0,s1
    8000202c:	c3bfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002030:	16848493          	addi	s1,s1,360
    80002034:	03248263          	beq	s1,s2,80002058 <wakeup+0x58>
    if(p != myproc()){
    80002038:	973ff0ef          	jal	800019aa <myproc>
    8000203c:	fea48ae3          	beq	s1,a0,80002030 <wakeup+0x30>
      acquire(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	b8dfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002046:	4c9c                	lw	a5,24(s1)
    80002048:	ff3791e3          	bne	a5,s3,8000202a <wakeup+0x2a>
    8000204c:	709c                	ld	a5,32(s1)
    8000204e:	fd479ee3          	bne	a5,s4,8000202a <wakeup+0x2a>
        p->state = RUNNABLE;
    80002052:	0154ac23          	sw	s5,24(s1)
    80002056:	bfd1                	j	8000202a <wakeup+0x2a>
}
    80002058:	70e2                	ld	ra,56(sp)
    8000205a:	7442                	ld	s0,48(sp)
    8000205c:	74a2                	ld	s1,40(sp)
    8000205e:	7902                	ld	s2,32(sp)
    80002060:	69e2                	ld	s3,24(sp)
    80002062:	6a42                	ld	s4,16(sp)
    80002064:	6aa2                	ld	s5,8(sp)
    80002066:	6121                	addi	sp,sp,64
    80002068:	8082                	ret

000000008000206a <reparent>:
{
    8000206a:	7179                	addi	sp,sp,-48
    8000206c:	f406                	sd	ra,40(sp)
    8000206e:	f022                	sd	s0,32(sp)
    80002070:	ec26                	sd	s1,24(sp)
    80002072:	e84a                	sd	s2,16(sp)
    80002074:	e44e                	sd	s3,8(sp)
    80002076:	e052                	sd	s4,0(sp)
    80002078:	1800                	addi	s0,sp,48
    8000207a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000207c:	0000e497          	auipc	s1,0xe
    80002080:	d1c48493          	addi	s1,s1,-740 # 8000fd98 <proc>
      pp->parent = initproc;
    80002084:	00005a17          	auipc	s4,0x5
    80002088:	7dca0a13          	addi	s4,s4,2012 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000208c:	00013997          	auipc	s3,0x13
    80002090:	70c98993          	addi	s3,s3,1804 # 80015798 <tickslock>
    80002094:	a029                	j	8000209e <reparent+0x34>
    80002096:	16848493          	addi	s1,s1,360
    8000209a:	01348b63          	beq	s1,s3,800020b0 <reparent+0x46>
    if(pp->parent == p){
    8000209e:	7c9c                	ld	a5,56(s1)
    800020a0:	ff279be3          	bne	a5,s2,80002096 <reparent+0x2c>
      pp->parent = initproc;
    800020a4:	000a3503          	ld	a0,0(s4)
    800020a8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020aa:	f57ff0ef          	jal	80002000 <wakeup>
    800020ae:	b7e5                	j	80002096 <reparent+0x2c>
}
    800020b0:	70a2                	ld	ra,40(sp)
    800020b2:	7402                	ld	s0,32(sp)
    800020b4:	64e2                	ld	s1,24(sp)
    800020b6:	6942                	ld	s2,16(sp)
    800020b8:	69a2                	ld	s3,8(sp)
    800020ba:	6a02                	ld	s4,0(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret

00000000800020c0 <kexit>:
{
    800020c0:	7179                	addi	sp,sp,-48
    800020c2:	f406                	sd	ra,40(sp)
    800020c4:	f022                	sd	s0,32(sp)
    800020c6:	ec26                	sd	s1,24(sp)
    800020c8:	e84a                	sd	s2,16(sp)
    800020ca:	e44e                	sd	s3,8(sp)
    800020cc:	e052                	sd	s4,0(sp)
    800020ce:	1800                	addi	s0,sp,48
    800020d0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020d2:	8d9ff0ef          	jal	800019aa <myproc>
    800020d6:	89aa                	mv	s3,a0
  if(p == initproc)
    800020d8:	00005797          	auipc	a5,0x5
    800020dc:	7887b783          	ld	a5,1928(a5) # 80007860 <initproc>
    800020e0:	0d050493          	addi	s1,a0,208
    800020e4:	15050913          	addi	s2,a0,336
    800020e8:	00a79f63          	bne	a5,a0,80002106 <kexit+0x46>
    panic("init exiting");
    800020ec:	00005517          	auipc	a0,0x5
    800020f0:	0f450513          	addi	a0,a0,244 # 800071e0 <etext+0x1e0>
    800020f4:	eecfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    800020f8:	0b4020ef          	jal	800041ac <fileclose>
      p->ofile[fd] = 0;
    800020fc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002100:	04a1                	addi	s1,s1,8
    80002102:	01248563          	beq	s1,s2,8000210c <kexit+0x4c>
    if(p->ofile[fd]){
    80002106:	6088                	ld	a0,0(s1)
    80002108:	f965                	bnez	a0,800020f8 <kexit+0x38>
    8000210a:	bfdd                	j	80002100 <kexit+0x40>
  begin_op();
    8000210c:	495010ef          	jal	80003da0 <begin_op>
  iput(p->cwd);
    80002110:	1509b503          	ld	a0,336(s3)
    80002114:	424010ef          	jal	80003538 <iput>
  end_op();
    80002118:	4f3010ef          	jal	80003e0a <end_op>
  p->cwd = 0;
    8000211c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002120:	0000e497          	auipc	s1,0xe
    80002124:	86048493          	addi	s1,s1,-1952 # 8000f980 <wait_lock>
    80002128:	8526                	mv	a0,s1
    8000212a:	aa5fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000212e:	854e                	mv	a0,s3
    80002130:	f3bff0ef          	jal	8000206a <reparent>
  wakeup(p->parent);
    80002134:	0389b503          	ld	a0,56(s3)
    80002138:	ec9ff0ef          	jal	80002000 <wakeup>
  acquire(&p->lock);
    8000213c:	854e                	mv	a0,s3
    8000213e:	a91fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002142:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002146:	4795                	li	a5,5
    80002148:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000214c:	8526                	mv	a0,s1
    8000214e:	b19fe0ef          	jal	80000c66 <release>
  sched();
    80002152:	d7dff0ef          	jal	80001ece <sched>
  panic("zombie exit");
    80002156:	00005517          	auipc	a0,0x5
    8000215a:	09a50513          	addi	a0,a0,154 # 800071f0 <etext+0x1f0>
    8000215e:	e82fe0ef          	jal	800007e0 <panic>

0000000080002162 <kkill>:
{
    80002162:	7179                	addi	sp,sp,-48
    80002164:	f406                	sd	ra,40(sp)
    80002166:	f022                	sd	s0,32(sp)
    80002168:	ec26                	sd	s1,24(sp)
    8000216a:	e84a                	sd	s2,16(sp)
    8000216c:	e44e                	sd	s3,8(sp)
    8000216e:	1800                	addi	s0,sp,48
    80002170:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002172:	0000e497          	auipc	s1,0xe
    80002176:	c2648493          	addi	s1,s1,-986 # 8000fd98 <proc>
    8000217a:	00013997          	auipc	s3,0x13
    8000217e:	61e98993          	addi	s3,s3,1566 # 80015798 <tickslock>
    acquire(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	a4bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    80002188:	589c                	lw	a5,48(s1)
    8000218a:	01278b63          	beq	a5,s2,800021a0 <kkill+0x3e>
    release(&p->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	ad7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002194:	16848493          	addi	s1,s1,360
    80002198:	ff3495e3          	bne	s1,s3,80002182 <kkill+0x20>
  return -1;
    8000219c:	557d                	li	a0,-1
    8000219e:	a819                	j	800021b4 <kkill+0x52>
      p->killed = 1;
    800021a0:	4785                	li	a5,1
    800021a2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021a4:	4c98                	lw	a4,24(s1)
    800021a6:	4789                	li	a5,2
    800021a8:	00f70d63          	beq	a4,a5,800021c2 <kkill+0x60>
      release(&p->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	ab9fe0ef          	jal	80000c66 <release>
      return 0;
    800021b2:	4501                	li	a0,0
}
    800021b4:	70a2                	ld	ra,40(sp)
    800021b6:	7402                	ld	s0,32(sp)
    800021b8:	64e2                	ld	s1,24(sp)
    800021ba:	6942                	ld	s2,16(sp)
    800021bc:	69a2                	ld	s3,8(sp)
    800021be:	6145                	addi	sp,sp,48
    800021c0:	8082                	ret
        p->state = RUNNABLE;
    800021c2:	478d                	li	a5,3
    800021c4:	cc9c                	sw	a5,24(s1)
    800021c6:	b7dd                	j	800021ac <kkill+0x4a>

00000000800021c8 <setkilled>:
{
    800021c8:	1101                	addi	sp,sp,-32
    800021ca:	ec06                	sd	ra,24(sp)
    800021cc:	e822                	sd	s0,16(sp)
    800021ce:	e426                	sd	s1,8(sp)
    800021d0:	1000                	addi	s0,sp,32
    800021d2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021d4:	9fbfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800021d8:	4785                	li	a5,1
    800021da:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	a89fe0ef          	jal	80000c66 <release>
}
    800021e2:	60e2                	ld	ra,24(sp)
    800021e4:	6442                	ld	s0,16(sp)
    800021e6:	64a2                	ld	s1,8(sp)
    800021e8:	6105                	addi	sp,sp,32
    800021ea:	8082                	ret

00000000800021ec <killed>:
{
    800021ec:	1101                	addi	sp,sp,-32
    800021ee:	ec06                	sd	ra,24(sp)
    800021f0:	e822                	sd	s0,16(sp)
    800021f2:	e426                	sd	s1,8(sp)
    800021f4:	e04a                	sd	s2,0(sp)
    800021f6:	1000                	addi	s0,sp,32
    800021f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021fa:	9d5fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    800021fe:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002202:	8526                	mv	a0,s1
    80002204:	a63fe0ef          	jal	80000c66 <release>
}
    80002208:	854a                	mv	a0,s2
    8000220a:	60e2                	ld	ra,24(sp)
    8000220c:	6442                	ld	s0,16(sp)
    8000220e:	64a2                	ld	s1,8(sp)
    80002210:	6902                	ld	s2,0(sp)
    80002212:	6105                	addi	sp,sp,32
    80002214:	8082                	ret

0000000080002216 <kwait>:
{
    80002216:	715d                	addi	sp,sp,-80
    80002218:	e486                	sd	ra,72(sp)
    8000221a:	e0a2                	sd	s0,64(sp)
    8000221c:	fc26                	sd	s1,56(sp)
    8000221e:	f84a                	sd	s2,48(sp)
    80002220:	f44e                	sd	s3,40(sp)
    80002222:	f052                	sd	s4,32(sp)
    80002224:	ec56                	sd	s5,24(sp)
    80002226:	e85a                	sd	s6,16(sp)
    80002228:	e45e                	sd	s7,8(sp)
    8000222a:	e062                	sd	s8,0(sp)
    8000222c:	0880                	addi	s0,sp,80
    8000222e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002230:	f7aff0ef          	jal	800019aa <myproc>
    80002234:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002236:	0000d517          	auipc	a0,0xd
    8000223a:	74a50513          	addi	a0,a0,1866 # 8000f980 <wait_lock>
    8000223e:	991fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002242:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002244:	4a15                	li	s4,5
        havekids = 1;
    80002246:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002248:	00013997          	auipc	s3,0x13
    8000224c:	55098993          	addi	s3,s3,1360 # 80015798 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002250:	0000dc17          	auipc	s8,0xd
    80002254:	730c0c13          	addi	s8,s8,1840 # 8000f980 <wait_lock>
    80002258:	a871                	j	800022f4 <kwait+0xde>
          pid = pp->pid;
    8000225a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000225e:	000b0c63          	beqz	s6,80002276 <kwait+0x60>
    80002262:	4691                	li	a3,4
    80002264:	02c48613          	addi	a2,s1,44
    80002268:	85da                	mv	a1,s6
    8000226a:	05093503          	ld	a0,80(s2)
    8000226e:	b74ff0ef          	jal	800015e2 <copyout>
    80002272:	02054b63          	bltz	a0,800022a8 <kwait+0x92>
          freeproc(pp);
    80002276:	8526                	mv	a0,s1
    80002278:	903ff0ef          	jal	80001b7a <freeproc>
          release(&pp->lock);
    8000227c:	8526                	mv	a0,s1
    8000227e:	9e9fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002282:	0000d517          	auipc	a0,0xd
    80002286:	6fe50513          	addi	a0,a0,1790 # 8000f980 <wait_lock>
    8000228a:	9ddfe0ef          	jal	80000c66 <release>
}
    8000228e:	854e                	mv	a0,s3
    80002290:	60a6                	ld	ra,72(sp)
    80002292:	6406                	ld	s0,64(sp)
    80002294:	74e2                	ld	s1,56(sp)
    80002296:	7942                	ld	s2,48(sp)
    80002298:	79a2                	ld	s3,40(sp)
    8000229a:	7a02                	ld	s4,32(sp)
    8000229c:	6ae2                	ld	s5,24(sp)
    8000229e:	6b42                	ld	s6,16(sp)
    800022a0:	6ba2                	ld	s7,8(sp)
    800022a2:	6c02                	ld	s8,0(sp)
    800022a4:	6161                	addi	sp,sp,80
    800022a6:	8082                	ret
            release(&pp->lock);
    800022a8:	8526                	mv	a0,s1
    800022aa:	9bdfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800022ae:	0000d517          	auipc	a0,0xd
    800022b2:	6d250513          	addi	a0,a0,1746 # 8000f980 <wait_lock>
    800022b6:	9b1fe0ef          	jal	80000c66 <release>
            return -1;
    800022ba:	59fd                	li	s3,-1
    800022bc:	bfc9                	j	8000228e <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022be:	16848493          	addi	s1,s1,360
    800022c2:	03348063          	beq	s1,s3,800022e2 <kwait+0xcc>
      if(pp->parent == p){
    800022c6:	7c9c                	ld	a5,56(s1)
    800022c8:	ff279be3          	bne	a5,s2,800022be <kwait+0xa8>
        acquire(&pp->lock);
    800022cc:	8526                	mv	a0,s1
    800022ce:	901fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800022d2:	4c9c                	lw	a5,24(s1)
    800022d4:	f94783e3          	beq	a5,s4,8000225a <kwait+0x44>
        release(&pp->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	98dfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800022de:	8756                	mv	a4,s5
    800022e0:	bff9                	j	800022be <kwait+0xa8>
    if(!havekids || killed(p)){
    800022e2:	cf19                	beqz	a4,80002300 <kwait+0xea>
    800022e4:	854a                	mv	a0,s2
    800022e6:	f07ff0ef          	jal	800021ec <killed>
    800022ea:	e919                	bnez	a0,80002300 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022ec:	85e2                	mv	a1,s8
    800022ee:	854a                	mv	a0,s2
    800022f0:	cc5ff0ef          	jal	80001fb4 <sleep>
    havekids = 0;
    800022f4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f6:	0000e497          	auipc	s1,0xe
    800022fa:	aa248493          	addi	s1,s1,-1374 # 8000fd98 <proc>
    800022fe:	b7e1                	j	800022c6 <kwait+0xb0>
      release(&wait_lock);
    80002300:	0000d517          	auipc	a0,0xd
    80002304:	68050513          	addi	a0,a0,1664 # 8000f980 <wait_lock>
    80002308:	95ffe0ef          	jal	80000c66 <release>
      return -1;
    8000230c:	59fd                	li	s3,-1
    8000230e:	b741                	j	8000228e <kwait+0x78>

0000000080002310 <either_copyout>:
{
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	e052                	sd	s4,0(sp)
    8000231e:	1800                	addi	s0,sp,48
    80002320:	84aa                	mv	s1,a0
    80002322:	892e                	mv	s2,a1
    80002324:	89b2                	mv	s3,a2
    80002326:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002328:	e82ff0ef          	jal	800019aa <myproc>
  if(user_dst){
    8000232c:	cc99                	beqz	s1,8000234a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000232e:	86d2                	mv	a3,s4
    80002330:	864e                	mv	a2,s3
    80002332:	85ca                	mv	a1,s2
    80002334:	6928                	ld	a0,80(a0)
    80002336:	aacff0ef          	jal	800015e2 <copyout>
}
    8000233a:	70a2                	ld	ra,40(sp)
    8000233c:	7402                	ld	s0,32(sp)
    8000233e:	64e2                	ld	s1,24(sp)
    80002340:	6942                	ld	s2,16(sp)
    80002342:	69a2                	ld	s3,8(sp)
    80002344:	6a02                	ld	s4,0(sp)
    80002346:	6145                	addi	sp,sp,48
    80002348:	8082                	ret
    memmove((char *)dst, src, len);
    8000234a:	000a061b          	sext.w	a2,s4
    8000234e:	85ce                	mv	a1,s3
    80002350:	854a                	mv	a0,s2
    80002352:	9adfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002356:	8526                	mv	a0,s1
    80002358:	b7cd                	j	8000233a <either_copyout+0x2a>

000000008000235a <either_copyin>:
{
    8000235a:	7179                	addi	sp,sp,-48
    8000235c:	f406                	sd	ra,40(sp)
    8000235e:	f022                	sd	s0,32(sp)
    80002360:	ec26                	sd	s1,24(sp)
    80002362:	e84a                	sd	s2,16(sp)
    80002364:	e44e                	sd	s3,8(sp)
    80002366:	e052                	sd	s4,0(sp)
    80002368:	1800                	addi	s0,sp,48
    8000236a:	892a                	mv	s2,a0
    8000236c:	84ae                	mv	s1,a1
    8000236e:	89b2                	mv	s3,a2
    80002370:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002372:	e38ff0ef          	jal	800019aa <myproc>
  if(user_src){
    80002376:	cc99                	beqz	s1,80002394 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002378:	86d2                	mv	a3,s4
    8000237a:	864e                	mv	a2,s3
    8000237c:	85ca                	mv	a1,s2
    8000237e:	6928                	ld	a0,80(a0)
    80002380:	b46ff0ef          	jal	800016c6 <copyin>
}
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6a02                	ld	s4,0(sp)
    80002390:	6145                	addi	sp,sp,48
    80002392:	8082                	ret
    memmove(dst, (char*)src, len);
    80002394:	000a061b          	sext.w	a2,s4
    80002398:	85ce                	mv	a1,s3
    8000239a:	854a                	mv	a0,s2
    8000239c:	963fe0ef          	jal	80000cfe <memmove>
    return 0;
    800023a0:	8526                	mv	a0,s1
    800023a2:	b7cd                	j	80002384 <either_copyin+0x2a>

00000000800023a4 <procdump>:
{
    800023a4:	715d                	addi	sp,sp,-80
    800023a6:	e486                	sd	ra,72(sp)
    800023a8:	e0a2                	sd	s0,64(sp)
    800023aa:	fc26                	sd	s1,56(sp)
    800023ac:	f84a                	sd	s2,48(sp)
    800023ae:	f44e                	sd	s3,40(sp)
    800023b0:	f052                	sd	s4,32(sp)
    800023b2:	ec56                	sd	s5,24(sp)
    800023b4:	e85a                	sd	s6,16(sp)
    800023b6:	e45e                	sd	s7,8(sp)
    800023b8:	0880                	addi	s0,sp,80
  printf("\n");
    800023ba:	00005517          	auipc	a0,0x5
    800023be:	cbe50513          	addi	a0,a0,-834 # 80007078 <etext+0x78>
    800023c2:	938fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c6:	0000e497          	auipc	s1,0xe
    800023ca:	b2a48493          	addi	s1,s1,-1238 # 8000fef0 <proc+0x158>
    800023ce:	00013917          	auipc	s2,0x13
    800023d2:	52290913          	addi	s2,s2,1314 # 800158f0 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023d6:	4b15                	li	s6,5
      state = "???";
    800023d8:	00005997          	auipc	s3,0x5
    800023dc:	e2898993          	addi	s3,s3,-472 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800023e0:	00005a97          	auipc	s5,0x5
    800023e4:	e28a8a93          	addi	s5,s5,-472 # 80007208 <etext+0x208>
    printf("\n");
    800023e8:	00005a17          	auipc	s4,0x5
    800023ec:	c90a0a13          	addi	s4,s4,-880 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f0:	00005b97          	auipc	s7,0x5
    800023f4:	338b8b93          	addi	s7,s7,824 # 80007728 <states.0>
    800023f8:	a829                	j	80002412 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023fa:	ed86a583          	lw	a1,-296(a3)
    800023fe:	8556                	mv	a0,s5
    80002400:	8fafe0ef          	jal	800004fa <printf>
    printf("\n");
    80002404:	8552                	mv	a0,s4
    80002406:	8f4fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000240a:	16848493          	addi	s1,s1,360
    8000240e:	03248263          	beq	s1,s2,80002432 <procdump+0x8e>
    if(p->state == UNUSED)
    80002412:	86a6                	mv	a3,s1
    80002414:	ec04a783          	lw	a5,-320(s1)
    80002418:	dbed                	beqz	a5,8000240a <procdump+0x66>
      state = "???";
    8000241a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000241c:	fcfb6fe3          	bltu	s6,a5,800023fa <procdump+0x56>
    80002420:	02079713          	slli	a4,a5,0x20
    80002424:	01d75793          	srli	a5,a4,0x1d
    80002428:	97de                	add	a5,a5,s7
    8000242a:	6390                	ld	a2,0(a5)
    8000242c:	f679                	bnez	a2,800023fa <procdump+0x56>
      state = "???";
    8000242e:	864e                	mv	a2,s3
    80002430:	b7e9                	j	800023fa <procdump+0x56>
}
    80002432:	60a6                	ld	ra,72(sp)
    80002434:	6406                	ld	s0,64(sp)
    80002436:	74e2                	ld	s1,56(sp)
    80002438:	7942                	ld	s2,48(sp)
    8000243a:	79a2                	ld	s3,40(sp)
    8000243c:	7a02                	ld	s4,32(sp)
    8000243e:	6ae2                	ld	s5,24(sp)
    80002440:	6b42                	ld	s6,16(sp)
    80002442:	6ba2                	ld	s7,8(sp)
    80002444:	6161                	addi	sp,sp,80
    80002446:	8082                	ret

0000000080002448 <ptree>:

// System call implementation: build process tree rooted at given pid
int
ptree(int rootpid, struct proc_tree *tree)
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	e052                	sd	s4,0(sp)
    80002456:	1800                	addi	s0,sp,48
    80002458:	892a                	mv	s2,a0
    8000245a:	8a2e                	mv	s4,a1
  struct proc *p;
  struct proc *root = 0;

  // Find the root process
  for (p = proc; p < &proc[NPROC]; p++) {
    8000245c:	0000e497          	auipc	s1,0xe
    80002460:	93c48493          	addi	s1,s1,-1732 # 8000fd98 <proc>
    80002464:	00013997          	auipc	s3,0x13
    80002468:	33498993          	addi	s3,s3,820 # 80015798 <tickslock>
    8000246c:	a801                	j	8000247c <ptree+0x34>
    if (p->pid == rootpid && p->state != UNUSED) {
      root = p;
      release(&p->lock);
      break;
    }
    release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ff6fe0ef          	jal	80000c66 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002474:	16848493          	addi	s1,s1,360
    80002478:	03348c63          	beq	s1,s3,800024b0 <ptree+0x68>
    acquire(&p->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	f50fe0ef          	jal	80000bce <acquire>
    if (p->pid == rootpid && p->state != UNUSED) {
    80002482:	589c                	lw	a5,48(s1)
    80002484:	ff2795e3          	bne	a5,s2,8000246e <ptree+0x26>
    80002488:	4c9c                	lw	a5,24(s1)
    8000248a:	d3f5                	beqz	a5,8000246e <ptree+0x26>
      release(&p->lock);
    8000248c:	8526                	mv	a0,s1
    8000248e:	fd8fe0ef          	jal	80000c66 <release>
  if (!root) {
    return -1; // Process not found
  }

  // Initialize tree
  tree->count = 0;
    80002492:	000a2023          	sw	zero,0(s4)

  // Build the tree recursively
  ptree_add_recursive(root, tree);
    80002496:	85d2                	mv	a1,s4
    80002498:	8526                	mv	a0,s1
    8000249a:	abaff0ef          	jal	80001754 <ptree_add_recursive>

  return 0; // Success
    8000249e:	4501                	li	a0,0
}
    800024a0:	70a2                	ld	ra,40(sp)
    800024a2:	7402                	ld	s0,32(sp)
    800024a4:	64e2                	ld	s1,24(sp)
    800024a6:	6942                	ld	s2,16(sp)
    800024a8:	69a2                	ld	s3,8(sp)
    800024aa:	6a02                	ld	s4,0(sp)
    800024ac:	6145                	addi	sp,sp,48
    800024ae:	8082                	ret
    return -1; // Process not found
    800024b0:	557d                	li	a0,-1
    800024b2:	b7fd                	j	800024a0 <ptree+0x58>

00000000800024b4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024b4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024b8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024bc:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024be:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024c0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024c4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024c8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024cc:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024d0:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024d4:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800024d8:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800024dc:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800024e0:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800024e4:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800024e8:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800024ec:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024f0:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024f2:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024f4:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024f8:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024fc:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002500:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002504:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002508:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000250c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002510:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002514:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002518:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000251c:	8082                	ret

000000008000251e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000251e:	1141                	addi	sp,sp,-16
    80002520:	e406                	sd	ra,8(sp)
    80002522:	e022                	sd	s0,0(sp)
    80002524:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002526:	00005597          	auipc	a1,0x5
    8000252a:	d2258593          	addi	a1,a1,-734 # 80007248 <etext+0x248>
    8000252e:	00013517          	auipc	a0,0x13
    80002532:	26a50513          	addi	a0,a0,618 # 80015798 <tickslock>
    80002536:	e18fe0ef          	jal	80000b4e <initlock>
}
    8000253a:	60a2                	ld	ra,8(sp)
    8000253c:	6402                	ld	s0,0(sp)
    8000253e:	0141                	addi	sp,sp,16
    80002540:	8082                	ret

0000000080002542 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002542:	1141                	addi	sp,sp,-16
    80002544:	e422                	sd	s0,8(sp)
    80002546:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002548:	00003797          	auipc	a5,0x3
    8000254c:	fd878793          	addi	a5,a5,-40 # 80005520 <kernelvec>
    80002550:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002554:	6422                	ld	s0,8(sp)
    80002556:	0141                	addi	sp,sp,16
    80002558:	8082                	ret

000000008000255a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000255a:	1141                	addi	sp,sp,-16
    8000255c:	e406                	sd	ra,8(sp)
    8000255e:	e022                	sd	s0,0(sp)
    80002560:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002562:	c48ff0ef          	jal	800019aa <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002566:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000256a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000256c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002570:	04000737          	lui	a4,0x4000
    80002574:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002576:	0732                	slli	a4,a4,0xc
    80002578:	00004797          	auipc	a5,0x4
    8000257c:	a8878793          	addi	a5,a5,-1400 # 80006000 <_trampoline>
    80002580:	00004697          	auipc	a3,0x4
    80002584:	a8068693          	addi	a3,a3,-1408 # 80006000 <_trampoline>
    80002588:	8f95                	sub	a5,a5,a3
    8000258a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000258c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002590:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002592:	18002773          	csrr	a4,satp
    80002596:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002598:	6d38                	ld	a4,88(a0)
    8000259a:	613c                	ld	a5,64(a0)
    8000259c:	6685                	lui	a3,0x1
    8000259e:	97b6                	add	a5,a5,a3
    800025a0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025a2:	6d3c                	ld	a5,88(a0)
    800025a4:	00000717          	auipc	a4,0x0
    800025a8:	0f870713          	addi	a4,a4,248 # 8000269c <usertrap>
    800025ac:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800025ae:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800025b0:	8712                	mv	a4,tp
    800025b2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025b4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025b8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025bc:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025c0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025c4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025c6:	6f9c                	ld	a5,24(a5)
    800025c8:	14179073          	csrw	sepc,a5
}
    800025cc:	60a2                	ld	ra,8(sp)
    800025ce:	6402                	ld	s0,0(sp)
    800025d0:	0141                	addi	sp,sp,16
    800025d2:	8082                	ret

00000000800025d4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025d4:	1101                	addi	sp,sp,-32
    800025d6:	ec06                	sd	ra,24(sp)
    800025d8:	e822                	sd	s0,16(sp)
    800025da:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800025dc:	ba2ff0ef          	jal	8000197e <cpuid>
    800025e0:	cd11                	beqz	a0,800025fc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800025e2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800025e6:	000f4737          	lui	a4,0xf4
    800025ea:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025ee:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800025f0:	14d79073          	csrw	stimecmp,a5
}
    800025f4:	60e2                	ld	ra,24(sp)
    800025f6:	6442                	ld	s0,16(sp)
    800025f8:	6105                	addi	sp,sp,32
    800025fa:	8082                	ret
    800025fc:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800025fe:	00013497          	auipc	s1,0x13
    80002602:	19a48493          	addi	s1,s1,410 # 80015798 <tickslock>
    80002606:	8526                	mv	a0,s1
    80002608:	dc6fe0ef          	jal	80000bce <acquire>
    ticks++;
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	25c50513          	addi	a0,a0,604 # 80007868 <ticks>
    80002614:	411c                	lw	a5,0(a0)
    80002616:	2785                	addiw	a5,a5,1
    80002618:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000261a:	9e7ff0ef          	jal	80002000 <wakeup>
    release(&tickslock);
    8000261e:	8526                	mv	a0,s1
    80002620:	e46fe0ef          	jal	80000c66 <release>
    80002624:	64a2                	ld	s1,8(sp)
    80002626:	bf75                	j	800025e2 <clockintr+0xe>

0000000080002628 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002628:	1101                	addi	sp,sp,-32
    8000262a:	ec06                	sd	ra,24(sp)
    8000262c:	e822                	sd	s0,16(sp)
    8000262e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002634:	57fd                	li	a5,-1
    80002636:	17fe                	slli	a5,a5,0x3f
    80002638:	07a5                	addi	a5,a5,9
    8000263a:	00f70c63          	beq	a4,a5,80002652 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000263e:	57fd                	li	a5,-1
    80002640:	17fe                	slli	a5,a5,0x3f
    80002642:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002644:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002646:	04f70763          	beq	a4,a5,80002694 <devintr+0x6c>
  }
}
    8000264a:	60e2                	ld	ra,24(sp)
    8000264c:	6442                	ld	s0,16(sp)
    8000264e:	6105                	addi	sp,sp,32
    80002650:	8082                	ret
    80002652:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002654:	779020ef          	jal	800055cc <plic_claim>
    80002658:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000265a:	47a9                	li	a5,10
    8000265c:	00f50963          	beq	a0,a5,8000266e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002660:	4785                	li	a5,1
    80002662:	00f50963          	beq	a0,a5,80002674 <devintr+0x4c>
    return 1;
    80002666:	4505                	li	a0,1
    } else if(irq){
    80002668:	e889                	bnez	s1,8000267a <devintr+0x52>
    8000266a:	64a2                	ld	s1,8(sp)
    8000266c:	bff9                	j	8000264a <devintr+0x22>
      uartintr();
    8000266e:	b42fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002672:	a819                	j	80002688 <devintr+0x60>
      virtio_disk_intr();
    80002674:	41e030ef          	jal	80005a92 <virtio_disk_intr>
    if(irq)
    80002678:	a801                	j	80002688 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000267a:	85a6                	mv	a1,s1
    8000267c:	00005517          	auipc	a0,0x5
    80002680:	bd450513          	addi	a0,a0,-1068 # 80007250 <etext+0x250>
    80002684:	e77fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002688:	8526                	mv	a0,s1
    8000268a:	763020ef          	jal	800055ec <plic_complete>
    return 1;
    8000268e:	4505                	li	a0,1
    80002690:	64a2                	ld	s1,8(sp)
    80002692:	bf65                	j	8000264a <devintr+0x22>
    clockintr();
    80002694:	f41ff0ef          	jal	800025d4 <clockintr>
    return 2;
    80002698:	4509                	li	a0,2
    8000269a:	bf45                	j	8000264a <devintr+0x22>

000000008000269c <usertrap>:
{
    8000269c:	1101                	addi	sp,sp,-32
    8000269e:	ec06                	sd	ra,24(sp)
    800026a0:	e822                	sd	s0,16(sp)
    800026a2:	e426                	sd	s1,8(sp)
    800026a4:	e04a                	sd	s2,0(sp)
    800026a6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800026ac:	1007f793          	andi	a5,a5,256
    800026b0:	eba5                	bnez	a5,80002720 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b2:	00003797          	auipc	a5,0x3
    800026b6:	e6e78793          	addi	a5,a5,-402 # 80005520 <kernelvec>
    800026ba:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026be:	aecff0ef          	jal	800019aa <myproc>
    800026c2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026c4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026c6:	14102773          	csrr	a4,sepc
    800026ca:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026cc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800026d0:	47a1                	li	a5,8
    800026d2:	04f70d63          	beq	a4,a5,8000272c <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800026d6:	f53ff0ef          	jal	80002628 <devintr>
    800026da:	892a                	mv	s2,a0
    800026dc:	e945                	bnez	a0,8000278c <usertrap+0xf0>
    800026de:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026e2:	47bd                	li	a5,15
    800026e4:	08f70863          	beq	a4,a5,80002774 <usertrap+0xd8>
    800026e8:	14202773          	csrr	a4,scause
    800026ec:	47b5                	li	a5,13
    800026ee:	08f70363          	beq	a4,a5,80002774 <usertrap+0xd8>
    800026f2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026f6:	5890                	lw	a2,48(s1)
    800026f8:	00005517          	auipc	a0,0x5
    800026fc:	b9850513          	addi	a0,a0,-1128 # 80007290 <etext+0x290>
    80002700:	dfbfd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002704:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002708:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000270c:	00005517          	auipc	a0,0x5
    80002710:	bb450513          	addi	a0,a0,-1100 # 800072c0 <etext+0x2c0>
    80002714:	de7fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002718:	8526                	mv	a0,s1
    8000271a:	aafff0ef          	jal	800021c8 <setkilled>
    8000271e:	a035                	j	8000274a <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002720:	00005517          	auipc	a0,0x5
    80002724:	b5050513          	addi	a0,a0,-1200 # 80007270 <etext+0x270>
    80002728:	8b8fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    8000272c:	ac1ff0ef          	jal	800021ec <killed>
    80002730:	ed15                	bnez	a0,8000276c <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002732:	6cb8                	ld	a4,88(s1)
    80002734:	6f1c                	ld	a5,24(a4)
    80002736:	0791                	addi	a5,a5,4
    80002738:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000273e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002742:	10079073          	csrw	sstatus,a5
    syscall();
    80002746:	246000ef          	jal	8000298c <syscall>
  if(killed(p))
    8000274a:	8526                	mv	a0,s1
    8000274c:	aa1ff0ef          	jal	800021ec <killed>
    80002750:	e139                	bnez	a0,80002796 <usertrap+0xfa>
  prepare_return();
    80002752:	e09ff0ef          	jal	8000255a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002756:	68a8                	ld	a0,80(s1)
    80002758:	8131                	srli	a0,a0,0xc
    8000275a:	57fd                	li	a5,-1
    8000275c:	17fe                	slli	a5,a5,0x3f
    8000275e:	8d5d                	or	a0,a0,a5
}
    80002760:	60e2                	ld	ra,24(sp)
    80002762:	6442                	ld	s0,16(sp)
    80002764:	64a2                	ld	s1,8(sp)
    80002766:	6902                	ld	s2,0(sp)
    80002768:	6105                	addi	sp,sp,32
    8000276a:	8082                	ret
      kexit(-1);
    8000276c:	557d                	li	a0,-1
    8000276e:	953ff0ef          	jal	800020c0 <kexit>
    80002772:	b7c1                	j	80002732 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002774:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002778:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000277c:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    8000277e:	00163613          	seqz	a2,a2
    80002782:	68a8                	ld	a0,80(s1)
    80002784:	dddfe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002788:	f169                	bnez	a0,8000274a <usertrap+0xae>
    8000278a:	b7a5                	j	800026f2 <usertrap+0x56>
  if(killed(p))
    8000278c:	8526                	mv	a0,s1
    8000278e:	a5fff0ef          	jal	800021ec <killed>
    80002792:	c511                	beqz	a0,8000279e <usertrap+0x102>
    80002794:	a011                	j	80002798 <usertrap+0xfc>
    80002796:	4901                	li	s2,0
    kexit(-1);
    80002798:	557d                	li	a0,-1
    8000279a:	927ff0ef          	jal	800020c0 <kexit>
  if(which_dev == 2)
    8000279e:	4789                	li	a5,2
    800027a0:	faf919e3          	bne	s2,a5,80002752 <usertrap+0xb6>
    yield();
    800027a4:	fe4ff0ef          	jal	80001f88 <yield>
    800027a8:	b76d                	j	80002752 <usertrap+0xb6>

00000000800027aa <kerneltrap>:
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027b8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027bc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800027c4:	1004f793          	andi	a5,s1,256
    800027c8:	c795                	beqz	a5,800027f4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ca:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027ce:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800027d0:	eb85                	bnez	a5,80002800 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800027d2:	e57ff0ef          	jal	80002628 <devintr>
    800027d6:	c91d                	beqz	a0,8000280c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800027d8:	4789                	li	a5,2
    800027da:	04f50a63          	beq	a0,a5,8000282e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027de:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e2:	10049073          	csrw	sstatus,s1
}
    800027e6:	70a2                	ld	ra,40(sp)
    800027e8:	7402                	ld	s0,32(sp)
    800027ea:	64e2                	ld	s1,24(sp)
    800027ec:	6942                	ld	s2,16(sp)
    800027ee:	69a2                	ld	s3,8(sp)
    800027f0:	6145                	addi	sp,sp,48
    800027f2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800027f4:	00005517          	auipc	a0,0x5
    800027f8:	af450513          	addi	a0,a0,-1292 # 800072e8 <etext+0x2e8>
    800027fc:	fe5fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002800:	00005517          	auipc	a0,0x5
    80002804:	b1050513          	addi	a0,a0,-1264 # 80007310 <etext+0x310>
    80002808:	fd9fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000280c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002810:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002814:	85ce                	mv	a1,s3
    80002816:	00005517          	auipc	a0,0x5
    8000281a:	b1a50513          	addi	a0,a0,-1254 # 80007330 <etext+0x330>
    8000281e:	cddfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002822:	00005517          	auipc	a0,0x5
    80002826:	b3650513          	addi	a0,a0,-1226 # 80007358 <etext+0x358>
    8000282a:	fb7fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000282e:	97cff0ef          	jal	800019aa <myproc>
    80002832:	d555                	beqz	a0,800027de <kerneltrap+0x34>
    yield();
    80002834:	f54ff0ef          	jal	80001f88 <yield>
    80002838:	b75d                	j	800027de <kerneltrap+0x34>

000000008000283a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000283a:	1101                	addi	sp,sp,-32
    8000283c:	ec06                	sd	ra,24(sp)
    8000283e:	e822                	sd	s0,16(sp)
    80002840:	e426                	sd	s1,8(sp)
    80002842:	1000                	addi	s0,sp,32
    80002844:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002846:	964ff0ef          	jal	800019aa <myproc>
  switch (n) {
    8000284a:	4795                	li	a5,5
    8000284c:	0497e163          	bltu	a5,s1,8000288e <argraw+0x54>
    80002850:	048a                	slli	s1,s1,0x2
    80002852:	00005717          	auipc	a4,0x5
    80002856:	f0670713          	addi	a4,a4,-250 # 80007758 <states.0+0x30>
    8000285a:	94ba                	add	s1,s1,a4
    8000285c:	409c                	lw	a5,0(s1)
    8000285e:	97ba                	add	a5,a5,a4
    80002860:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002862:	6d3c                	ld	a5,88(a0)
    80002864:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6105                	addi	sp,sp,32
    8000286e:	8082                	ret
    return p->trapframe->a1;
    80002870:	6d3c                	ld	a5,88(a0)
    80002872:	7fa8                	ld	a0,120(a5)
    80002874:	bfcd                	j	80002866 <argraw+0x2c>
    return p->trapframe->a2;
    80002876:	6d3c                	ld	a5,88(a0)
    80002878:	63c8                	ld	a0,128(a5)
    8000287a:	b7f5                	j	80002866 <argraw+0x2c>
    return p->trapframe->a3;
    8000287c:	6d3c                	ld	a5,88(a0)
    8000287e:	67c8                	ld	a0,136(a5)
    80002880:	b7dd                	j	80002866 <argraw+0x2c>
    return p->trapframe->a4;
    80002882:	6d3c                	ld	a5,88(a0)
    80002884:	6bc8                	ld	a0,144(a5)
    80002886:	b7c5                	j	80002866 <argraw+0x2c>
    return p->trapframe->a5;
    80002888:	6d3c                	ld	a5,88(a0)
    8000288a:	6fc8                	ld	a0,152(a5)
    8000288c:	bfe9                	j	80002866 <argraw+0x2c>
  panic("argraw");
    8000288e:	00005517          	auipc	a0,0x5
    80002892:	ada50513          	addi	a0,a0,-1318 # 80007368 <etext+0x368>
    80002896:	f4bfd0ef          	jal	800007e0 <panic>

000000008000289a <fetchaddr>:
{
    8000289a:	1101                	addi	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	e426                	sd	s1,8(sp)
    800028a2:	e04a                	sd	s2,0(sp)
    800028a4:	1000                	addi	s0,sp,32
    800028a6:	84aa                	mv	s1,a0
    800028a8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028aa:	900ff0ef          	jal	800019aa <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028ae:	653c                	ld	a5,72(a0)
    800028b0:	02f4f663          	bgeu	s1,a5,800028dc <fetchaddr+0x42>
    800028b4:	00848713          	addi	a4,s1,8
    800028b8:	02e7e463          	bltu	a5,a4,800028e0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800028bc:	46a1                	li	a3,8
    800028be:	8626                	mv	a2,s1
    800028c0:	85ca                	mv	a1,s2
    800028c2:	6928                	ld	a0,80(a0)
    800028c4:	e03fe0ef          	jal	800016c6 <copyin>
    800028c8:	00a03533          	snez	a0,a0
    800028cc:	40a00533          	neg	a0,a0
}
    800028d0:	60e2                	ld	ra,24(sp)
    800028d2:	6442                	ld	s0,16(sp)
    800028d4:	64a2                	ld	s1,8(sp)
    800028d6:	6902                	ld	s2,0(sp)
    800028d8:	6105                	addi	sp,sp,32
    800028da:	8082                	ret
    return -1;
    800028dc:	557d                	li	a0,-1
    800028de:	bfcd                	j	800028d0 <fetchaddr+0x36>
    800028e0:	557d                	li	a0,-1
    800028e2:	b7fd                	j	800028d0 <fetchaddr+0x36>

00000000800028e4 <fetchstr>:
{
    800028e4:	7179                	addi	sp,sp,-48
    800028e6:	f406                	sd	ra,40(sp)
    800028e8:	f022                	sd	s0,32(sp)
    800028ea:	ec26                	sd	s1,24(sp)
    800028ec:	e84a                	sd	s2,16(sp)
    800028ee:	e44e                	sd	s3,8(sp)
    800028f0:	1800                	addi	s0,sp,48
    800028f2:	892a                	mv	s2,a0
    800028f4:	84ae                	mv	s1,a1
    800028f6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800028f8:	8b2ff0ef          	jal	800019aa <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800028fc:	86ce                	mv	a3,s3
    800028fe:	864a                	mv	a2,s2
    80002900:	85a6                	mv	a1,s1
    80002902:	6928                	ld	a0,80(a0)
    80002904:	b85fe0ef          	jal	80001488 <copyinstr>
    80002908:	00054c63          	bltz	a0,80002920 <fetchstr+0x3c>
  return strlen(buf);
    8000290c:	8526                	mv	a0,s1
    8000290e:	d04fe0ef          	jal	80000e12 <strlen>
}
    80002912:	70a2                	ld	ra,40(sp)
    80002914:	7402                	ld	s0,32(sp)
    80002916:	64e2                	ld	s1,24(sp)
    80002918:	6942                	ld	s2,16(sp)
    8000291a:	69a2                	ld	s3,8(sp)
    8000291c:	6145                	addi	sp,sp,48
    8000291e:	8082                	ret
    return -1;
    80002920:	557d                	li	a0,-1
    80002922:	bfc5                	j	80002912 <fetchstr+0x2e>

0000000080002924 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002924:	1101                	addi	sp,sp,-32
    80002926:	ec06                	sd	ra,24(sp)
    80002928:	e822                	sd	s0,16(sp)
    8000292a:	e426                	sd	s1,8(sp)
    8000292c:	1000                	addi	s0,sp,32
    8000292e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002930:	f0bff0ef          	jal	8000283a <argraw>
    80002934:	c088                	sw	a0,0(s1)
}
    80002936:	60e2                	ld	ra,24(sp)
    80002938:	6442                	ld	s0,16(sp)
    8000293a:	64a2                	ld	s1,8(sp)
    8000293c:	6105                	addi	sp,sp,32
    8000293e:	8082                	ret

0000000080002940 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002940:	1101                	addi	sp,sp,-32
    80002942:	ec06                	sd	ra,24(sp)
    80002944:	e822                	sd	s0,16(sp)
    80002946:	e426                	sd	s1,8(sp)
    80002948:	1000                	addi	s0,sp,32
    8000294a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000294c:	eefff0ef          	jal	8000283a <argraw>
    80002950:	e088                	sd	a0,0(s1)
}
    80002952:	60e2                	ld	ra,24(sp)
    80002954:	6442                	ld	s0,16(sp)
    80002956:	64a2                	ld	s1,8(sp)
    80002958:	6105                	addi	sp,sp,32
    8000295a:	8082                	ret

000000008000295c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000295c:	7179                	addi	sp,sp,-48
    8000295e:	f406                	sd	ra,40(sp)
    80002960:	f022                	sd	s0,32(sp)
    80002962:	ec26                	sd	s1,24(sp)
    80002964:	e84a                	sd	s2,16(sp)
    80002966:	1800                	addi	s0,sp,48
    80002968:	84ae                	mv	s1,a1
    8000296a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000296c:	fd840593          	addi	a1,s0,-40
    80002970:	fd1ff0ef          	jal	80002940 <argaddr>
  return fetchstr(addr, buf, max);
    80002974:	864a                	mv	a2,s2
    80002976:	85a6                	mv	a1,s1
    80002978:	fd843503          	ld	a0,-40(s0)
    8000297c:	f69ff0ef          	jal	800028e4 <fetchstr>
}
    80002980:	70a2                	ld	ra,40(sp)
    80002982:	7402                	ld	s0,32(sp)
    80002984:	64e2                	ld	s1,24(sp)
    80002986:	6942                	ld	s2,16(sp)
    80002988:	6145                	addi	sp,sp,48
    8000298a:	8082                	ret

000000008000298c <syscall>:

uint sysclcnt = 0;

void
syscall(void)
{
    8000298c:	1101                	addi	sp,sp,-32
    8000298e:	ec06                	sd	ra,24(sp)
    80002990:	e822                	sd	s0,16(sp)
    80002992:	e426                	sd	s1,8(sp)
    80002994:	e04a                	sd	s2,0(sp)
    80002996:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002998:	812ff0ef          	jal	800019aa <myproc>
    8000299c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000299e:	05853903          	ld	s2,88(a0)
    800029a2:	0a893783          	ld	a5,168(s2)
    800029a6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029aa:	37fd                	addiw	a5,a5,-1
    800029ac:	4759                	li	a4,22
    800029ae:	02f76663          	bltu	a4,a5,800029da <syscall+0x4e>
    800029b2:	00369713          	slli	a4,a3,0x3
    800029b6:	00005797          	auipc	a5,0x5
    800029ba:	dba78793          	addi	a5,a5,-582 # 80007770 <syscalls>
    800029be:	97ba                	add	a5,a5,a4
    800029c0:	6398                	ld	a4,0(a5)
    800029c2:	cf01                	beqz	a4,800029da <syscall+0x4e>
    sysclcnt++;
    800029c4:	00005697          	auipc	a3,0x5
    800029c8:	ea868693          	addi	a3,a3,-344 # 8000786c <sysclcnt>
    800029cc:	429c                	lw	a5,0(a3)
    800029ce:	2785                	addiw	a5,a5,1
    800029d0:	c29c                	sw	a5,0(a3)
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029d2:	9702                	jalr	a4
    800029d4:	06a93823          	sd	a0,112(s2)
    800029d8:	a829                	j	800029f2 <syscall+0x66>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029da:	15848613          	addi	a2,s1,344
    800029de:	588c                	lw	a1,48(s1)
    800029e0:	00005517          	auipc	a0,0x5
    800029e4:	99050513          	addi	a0,a0,-1648 # 80007370 <etext+0x370>
    800029e8:	b13fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800029ec:	6cbc                	ld	a5,88(s1)
    800029ee:	577d                	li	a4,-1
    800029f0:	fbb8                	sd	a4,112(a5)
  }
}
    800029f2:	60e2                	ld	ra,24(sp)
    800029f4:	6442                	ld	s0,16(sp)
    800029f6:	64a2                	ld	s1,8(sp)
    800029f8:	6902                	ld	s2,0(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret

00000000800029fe <sys_exit>:
// Forward declaration
int ptree(int pid, struct proc_tree *tree);

uint64
sys_exit(void)
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a06:	fec40593          	addi	a1,s0,-20
    80002a0a:	4501                	li	a0,0
    80002a0c:	f19ff0ef          	jal	80002924 <argint>
  kexit(n);
    80002a10:	fec42503          	lw	a0,-20(s0)
    80002a14:	eacff0ef          	jal	800020c0 <kexit>
  return 0;  // not reached
}
    80002a18:	4501                	li	a0,0
    80002a1a:	60e2                	ld	ra,24(sp)
    80002a1c:	6442                	ld	s0,16(sp)
    80002a1e:	6105                	addi	sp,sp,32
    80002a20:	8082                	ret

0000000080002a22 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a22:	1141                	addi	sp,sp,-16
    80002a24:	e406                	sd	ra,8(sp)
    80002a26:	e022                	sd	s0,0(sp)
    80002a28:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a2a:	f81fe0ef          	jal	800019aa <myproc>
}
    80002a2e:	5908                	lw	a0,48(a0)
    80002a30:	60a2                	ld	ra,8(sp)
    80002a32:	6402                	ld	s0,0(sp)
    80002a34:	0141                	addi	sp,sp,16
    80002a36:	8082                	ret

0000000080002a38 <sys_fork>:

uint64
sys_fork(void)
{
    80002a38:	1141                	addi	sp,sp,-16
    80002a3a:	e406                	sd	ra,8(sp)
    80002a3c:	e022                	sd	s0,0(sp)
    80002a3e:	0800                	addi	s0,sp,16
  return kfork();
    80002a40:	aceff0ef          	jal	80001d0e <kfork>
}
    80002a44:	60a2                	ld	ra,8(sp)
    80002a46:	6402                	ld	s0,0(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <sys_wait>:

uint64
sys_wait(void)
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a54:	fe840593          	addi	a1,s0,-24
    80002a58:	4501                	li	a0,0
    80002a5a:	ee7ff0ef          	jal	80002940 <argaddr>
  return kwait(p);
    80002a5e:	fe843503          	ld	a0,-24(s0)
    80002a62:	fb4ff0ef          	jal	80002216 <kwait>
}
    80002a66:	60e2                	ld	ra,24(sp)
    80002a68:	6442                	ld	s0,16(sp)
    80002a6a:	6105                	addi	sp,sp,32
    80002a6c:	8082                	ret

0000000080002a6e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a6e:	7179                	addi	sp,sp,-48
    80002a70:	f406                	sd	ra,40(sp)
    80002a72:	f022                	sd	s0,32(sp)
    80002a74:	ec26                	sd	s1,24(sp)
    80002a76:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a78:	fd840593          	addi	a1,s0,-40
    80002a7c:	4501                	li	a0,0
    80002a7e:	ea7ff0ef          	jal	80002924 <argint>
  argint(1, &t);
    80002a82:	fdc40593          	addi	a1,s0,-36
    80002a86:	4505                	li	a0,1
    80002a88:	e9dff0ef          	jal	80002924 <argint>
  addr = myproc()->sz;
    80002a8c:	f1ffe0ef          	jal	800019aa <myproc>
    80002a90:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a92:	fdc42703          	lw	a4,-36(s0)
    80002a96:	4785                	li	a5,1
    80002a98:	02f70763          	beq	a4,a5,80002ac6 <sys_sbrk+0x58>
    80002a9c:	fd842783          	lw	a5,-40(s0)
    80002aa0:	0207c363          	bltz	a5,80002ac6 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002aa4:	97a6                	add	a5,a5,s1
    80002aa6:	0297ee63          	bltu	a5,s1,80002ae2 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002aaa:	02000737          	lui	a4,0x2000
    80002aae:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ab0:	0736                	slli	a4,a4,0xd
    80002ab2:	02f76a63          	bltu	a4,a5,80002ae6 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002ab6:	ef5fe0ef          	jal	800019aa <myproc>
    80002aba:	fd842703          	lw	a4,-40(s0)
    80002abe:	653c                	ld	a5,72(a0)
    80002ac0:	97ba                	add	a5,a5,a4
    80002ac2:	e53c                	sd	a5,72(a0)
    80002ac4:	a039                	j	80002ad2 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002ac6:	fd842503          	lw	a0,-40(s0)
    80002aca:	9e2ff0ef          	jal	80001cac <growproc>
    80002ace:	00054863          	bltz	a0,80002ade <sys_sbrk+0x70>
  }
  return addr;
}
    80002ad2:	8526                	mv	a0,s1
    80002ad4:	70a2                	ld	ra,40(sp)
    80002ad6:	7402                	ld	s0,32(sp)
    80002ad8:	64e2                	ld	s1,24(sp)
    80002ada:	6145                	addi	sp,sp,48
    80002adc:	8082                	ret
      return -1;
    80002ade:	54fd                	li	s1,-1
    80002ae0:	bfcd                	j	80002ad2 <sys_sbrk+0x64>
      return -1;
    80002ae2:	54fd                	li	s1,-1
    80002ae4:	b7fd                	j	80002ad2 <sys_sbrk+0x64>
      return -1;
    80002ae6:	54fd                	li	s1,-1
    80002ae8:	b7ed                	j	80002ad2 <sys_sbrk+0x64>

0000000080002aea <sys_pause>:

uint64
sys_pause(void)
{
    80002aea:	7139                	addi	sp,sp,-64
    80002aec:	fc06                	sd	ra,56(sp)
    80002aee:	f822                	sd	s0,48(sp)
    80002af0:	f04a                	sd	s2,32(sp)
    80002af2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002af4:	fcc40593          	addi	a1,s0,-52
    80002af8:	4501                	li	a0,0
    80002afa:	e2bff0ef          	jal	80002924 <argint>
  if(n < 0)
    80002afe:	fcc42783          	lw	a5,-52(s0)
    80002b02:	0607c763          	bltz	a5,80002b70 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002b06:	00013517          	auipc	a0,0x13
    80002b0a:	c9250513          	addi	a0,a0,-878 # 80015798 <tickslock>
    80002b0e:	8c0fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002b12:	00005917          	auipc	s2,0x5
    80002b16:	d5692903          	lw	s2,-682(s2) # 80007868 <ticks>
  while(ticks - ticks0 < n){
    80002b1a:	fcc42783          	lw	a5,-52(s0)
    80002b1e:	cf8d                	beqz	a5,80002b58 <sys_pause+0x6e>
    80002b20:	f426                	sd	s1,40(sp)
    80002b22:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b24:	00013997          	auipc	s3,0x13
    80002b28:	c7498993          	addi	s3,s3,-908 # 80015798 <tickslock>
    80002b2c:	00005497          	auipc	s1,0x5
    80002b30:	d3c48493          	addi	s1,s1,-708 # 80007868 <ticks>
    if(killed(myproc())){
    80002b34:	e77fe0ef          	jal	800019aa <myproc>
    80002b38:	eb4ff0ef          	jal	800021ec <killed>
    80002b3c:	ed0d                	bnez	a0,80002b76 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002b3e:	85ce                	mv	a1,s3
    80002b40:	8526                	mv	a0,s1
    80002b42:	c72ff0ef          	jal	80001fb4 <sleep>
  while(ticks - ticks0 < n){
    80002b46:	409c                	lw	a5,0(s1)
    80002b48:	412787bb          	subw	a5,a5,s2
    80002b4c:	fcc42703          	lw	a4,-52(s0)
    80002b50:	fee7e2e3          	bltu	a5,a4,80002b34 <sys_pause+0x4a>
    80002b54:	74a2                	ld	s1,40(sp)
    80002b56:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b58:	00013517          	auipc	a0,0x13
    80002b5c:	c4050513          	addi	a0,a0,-960 # 80015798 <tickslock>
    80002b60:	906fe0ef          	jal	80000c66 <release>
  return 0;
    80002b64:	4501                	li	a0,0
}
    80002b66:	70e2                	ld	ra,56(sp)
    80002b68:	7442                	ld	s0,48(sp)
    80002b6a:	7902                	ld	s2,32(sp)
    80002b6c:	6121                	addi	sp,sp,64
    80002b6e:	8082                	ret
    n = 0;
    80002b70:	fc042623          	sw	zero,-52(s0)
    80002b74:	bf49                	j	80002b06 <sys_pause+0x1c>
      release(&tickslock);
    80002b76:	00013517          	auipc	a0,0x13
    80002b7a:	c2250513          	addi	a0,a0,-990 # 80015798 <tickslock>
    80002b7e:	8e8fe0ef          	jal	80000c66 <release>
      return -1;
    80002b82:	557d                	li	a0,-1
    80002b84:	74a2                	ld	s1,40(sp)
    80002b86:	69e2                	ld	s3,24(sp)
    80002b88:	bff9                	j	80002b66 <sys_pause+0x7c>

0000000080002b8a <sys_kill>:

uint64
sys_kill(void)
{
    80002b8a:	1101                	addi	sp,sp,-32
    80002b8c:	ec06                	sd	ra,24(sp)
    80002b8e:	e822                	sd	s0,16(sp)
    80002b90:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b92:	fec40593          	addi	a1,s0,-20
    80002b96:	4501                	li	a0,0
    80002b98:	d8dff0ef          	jal	80002924 <argint>
  return kkill(pid);
    80002b9c:	fec42503          	lw	a0,-20(s0)
    80002ba0:	dc2ff0ef          	jal	80002162 <kkill>
}
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	e426                	sd	s1,8(sp)
    80002bb4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bb6:	00013517          	auipc	a0,0x13
    80002bba:	be250513          	addi	a0,a0,-1054 # 80015798 <tickslock>
    80002bbe:	810fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002bc2:	00005497          	auipc	s1,0x5
    80002bc6:	ca64a483          	lw	s1,-858(s1) # 80007868 <ticks>
  release(&tickslock);
    80002bca:	00013517          	auipc	a0,0x13
    80002bce:	bce50513          	addi	a0,a0,-1074 # 80015798 <tickslock>
    80002bd2:	894fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002bd6:	02049513          	slli	a0,s1,0x20
    80002bda:	9101                	srli	a0,a0,0x20
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	64a2                	ld	s1,8(sp)
    80002be2:	6105                	addi	sp,sp,32
    80002be4:	8082                	ret

0000000080002be6 <sys_clcnt>:

uint64
sys_clcnt(void)
{
    80002be6:	1141                	addi	sp,sp,-16
    80002be8:	e422                	sd	s0,8(sp)
    80002bea:	0800                	addi	s0,sp,16
  extern uint sysclcnt;
  return sysclcnt;
}
    80002bec:	00005517          	auipc	a0,0x5
    80002bf0:	c8056503          	lwu	a0,-896(a0) # 8000786c <sysclcnt>
    80002bf4:	6422                	ld	s0,8(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_ptree>:

uint64
sys_ptree(void)
{
    80002bfa:	8c010113          	addi	sp,sp,-1856
    80002bfe:	72113c23          	sd	ra,1848(sp)
    80002c02:	72813823          	sd	s0,1840(sp)
    80002c06:	72913423          	sd	s1,1832(sp)
    80002c0a:	74010413          	addi	s0,sp,1856
  int pid;
  uint64 tree_addr;
  struct proc_tree tree;
  struct proc *p = myproc();
    80002c0e:	d9dfe0ef          	jal	800019aa <myproc>
    80002c12:	84aa                	mv	s1,a0

  argint(0, &pid);
    80002c14:	fdc40593          	addi	a1,s0,-36
    80002c18:	4501                	li	a0,0
    80002c1a:	d0bff0ef          	jal	80002924 <argint>
  argaddr(1, &tree_addr);
    80002c1e:	fd040593          	addi	a1,s0,-48
    80002c22:	4505                	li	a0,1
    80002c24:	d1dff0ef          	jal	80002940 <argaddr>

  // Call the kernel ptree function
  int result = ptree(pid, &tree);
    80002c28:	8c840593          	addi	a1,s0,-1848
    80002c2c:	fdc42503          	lw	a0,-36(s0)
    80002c30:	819ff0ef          	jal	80002448 <ptree>
  
  if (result < 0) {
    return -1;
    80002c34:	57fd                	li	a5,-1
  if (result < 0) {
    80002c36:	00054d63          	bltz	a0,80002c50 <sys_ptree+0x56>
  }

  // Copy the result to user space
  if (copyout(p->pagetable, tree_addr, (char *)&tree, sizeof(tree)) < 0) {
    80002c3a:	70400693          	li	a3,1796
    80002c3e:	8c840613          	addi	a2,s0,-1848
    80002c42:	fd043583          	ld	a1,-48(s0)
    80002c46:	68a8                	ld	a0,80(s1)
    80002c48:	99bfe0ef          	jal	800015e2 <copyout>
    80002c4c:	43f55793          	srai	a5,a0,0x3f
    return -1;
  }

  return 0;
    80002c50:	853e                	mv	a0,a5
    80002c52:	73813083          	ld	ra,1848(sp)
    80002c56:	73013403          	ld	s0,1840(sp)
    80002c5a:	72813483          	ld	s1,1832(sp)
    80002c5e:	74010113          	addi	sp,sp,1856
    80002c62:	8082                	ret

0000000080002c64 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c64:	7179                	addi	sp,sp,-48
    80002c66:	f406                	sd	ra,40(sp)
    80002c68:	f022                	sd	s0,32(sp)
    80002c6a:	ec26                	sd	s1,24(sp)
    80002c6c:	e84a                	sd	s2,16(sp)
    80002c6e:	e44e                	sd	s3,8(sp)
    80002c70:	e052                	sd	s4,0(sp)
    80002c72:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c74:	00004597          	auipc	a1,0x4
    80002c78:	71c58593          	addi	a1,a1,1820 # 80007390 <etext+0x390>
    80002c7c:	00013517          	auipc	a0,0x13
    80002c80:	b3450513          	addi	a0,a0,-1228 # 800157b0 <bcache>
    80002c84:	ecbfd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c88:	0001b797          	auipc	a5,0x1b
    80002c8c:	b2878793          	addi	a5,a5,-1240 # 8001d7b0 <bcache+0x8000>
    80002c90:	0001b717          	auipc	a4,0x1b
    80002c94:	d8870713          	addi	a4,a4,-632 # 8001da18 <bcache+0x8268>
    80002c98:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002c9c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ca0:	00013497          	auipc	s1,0x13
    80002ca4:	b2848493          	addi	s1,s1,-1240 # 800157c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002ca8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002caa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cac:	00004a17          	auipc	s4,0x4
    80002cb0:	6eca0a13          	addi	s4,s4,1772 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002cb4:	2b893783          	ld	a5,696(s2)
    80002cb8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cbe:	85d2                	mv	a1,s4
    80002cc0:	01048513          	addi	a0,s1,16
    80002cc4:	322010ef          	jal	80003fe6 <initsleeplock>
    bcache.head.next->prev = b;
    80002cc8:	2b893783          	ld	a5,696(s2)
    80002ccc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cce:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002cd2:	45848493          	addi	s1,s1,1112
    80002cd6:	fd349fe3          	bne	s1,s3,80002cb4 <binit+0x50>
  }
}
    80002cda:	70a2                	ld	ra,40(sp)
    80002cdc:	7402                	ld	s0,32(sp)
    80002cde:	64e2                	ld	s1,24(sp)
    80002ce0:	6942                	ld	s2,16(sp)
    80002ce2:	69a2                	ld	s3,8(sp)
    80002ce4:	6a02                	ld	s4,0(sp)
    80002ce6:	6145                	addi	sp,sp,48
    80002ce8:	8082                	ret

0000000080002cea <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002cea:	7179                	addi	sp,sp,-48
    80002cec:	f406                	sd	ra,40(sp)
    80002cee:	f022                	sd	s0,32(sp)
    80002cf0:	ec26                	sd	s1,24(sp)
    80002cf2:	e84a                	sd	s2,16(sp)
    80002cf4:	e44e                	sd	s3,8(sp)
    80002cf6:	1800                	addi	s0,sp,48
    80002cf8:	892a                	mv	s2,a0
    80002cfa:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002cfc:	00013517          	auipc	a0,0x13
    80002d00:	ab450513          	addi	a0,a0,-1356 # 800157b0 <bcache>
    80002d04:	ecbfd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d08:	0001b497          	auipc	s1,0x1b
    80002d0c:	d604b483          	ld	s1,-672(s1) # 8001da68 <bcache+0x82b8>
    80002d10:	0001b797          	auipc	a5,0x1b
    80002d14:	d0878793          	addi	a5,a5,-760 # 8001da18 <bcache+0x8268>
    80002d18:	02f48b63          	beq	s1,a5,80002d4e <bread+0x64>
    80002d1c:	873e                	mv	a4,a5
    80002d1e:	a021                	j	80002d26 <bread+0x3c>
    80002d20:	68a4                	ld	s1,80(s1)
    80002d22:	02e48663          	beq	s1,a4,80002d4e <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d26:	449c                	lw	a5,8(s1)
    80002d28:	ff279ce3          	bne	a5,s2,80002d20 <bread+0x36>
    80002d2c:	44dc                	lw	a5,12(s1)
    80002d2e:	ff3799e3          	bne	a5,s3,80002d20 <bread+0x36>
      b->refcnt++;
    80002d32:	40bc                	lw	a5,64(s1)
    80002d34:	2785                	addiw	a5,a5,1
    80002d36:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d38:	00013517          	auipc	a0,0x13
    80002d3c:	a7850513          	addi	a0,a0,-1416 # 800157b0 <bcache>
    80002d40:	f27fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002d44:	01048513          	addi	a0,s1,16
    80002d48:	2d4010ef          	jal	8000401c <acquiresleep>
      return b;
    80002d4c:	a889                	j	80002d9e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d4e:	0001b497          	auipc	s1,0x1b
    80002d52:	d124b483          	ld	s1,-750(s1) # 8001da60 <bcache+0x82b0>
    80002d56:	0001b797          	auipc	a5,0x1b
    80002d5a:	cc278793          	addi	a5,a5,-830 # 8001da18 <bcache+0x8268>
    80002d5e:	00f48863          	beq	s1,a5,80002d6e <bread+0x84>
    80002d62:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002d64:	40bc                	lw	a5,64(s1)
    80002d66:	cb91                	beqz	a5,80002d7a <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d68:	64a4                	ld	s1,72(s1)
    80002d6a:	fee49de3          	bne	s1,a4,80002d64 <bread+0x7a>
  panic("bget: no buffers");
    80002d6e:	00004517          	auipc	a0,0x4
    80002d72:	63250513          	addi	a0,a0,1586 # 800073a0 <etext+0x3a0>
    80002d76:	a6bfd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002d7a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d7e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d82:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d86:	4785                	li	a5,1
    80002d88:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d8a:	00013517          	auipc	a0,0x13
    80002d8e:	a2650513          	addi	a0,a0,-1498 # 800157b0 <bcache>
    80002d92:	ed5fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002d96:	01048513          	addi	a0,s1,16
    80002d9a:	282010ef          	jal	8000401c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d9e:	409c                	lw	a5,0(s1)
    80002da0:	cb89                	beqz	a5,80002db2 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002da2:	8526                	mv	a0,s1
    80002da4:	70a2                	ld	ra,40(sp)
    80002da6:	7402                	ld	s0,32(sp)
    80002da8:	64e2                	ld	s1,24(sp)
    80002daa:	6942                	ld	s2,16(sp)
    80002dac:	69a2                	ld	s3,8(sp)
    80002dae:	6145                	addi	sp,sp,48
    80002db0:	8082                	ret
    virtio_disk_rw(b, 0);
    80002db2:	4581                	li	a1,0
    80002db4:	8526                	mv	a0,s1
    80002db6:	2cb020ef          	jal	80005880 <virtio_disk_rw>
    b->valid = 1;
    80002dba:	4785                	li	a5,1
    80002dbc:	c09c                	sw	a5,0(s1)
  return b;
    80002dbe:	b7d5                	j	80002da2 <bread+0xb8>

0000000080002dc0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
    80002dca:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002dcc:	0541                	addi	a0,a0,16
    80002dce:	2cc010ef          	jal	8000409a <holdingsleep>
    80002dd2:	c911                	beqz	a0,80002de6 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dd4:	4585                	li	a1,1
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	2a9020ef          	jal	80005880 <virtio_disk_rw>
}
    80002ddc:	60e2                	ld	ra,24(sp)
    80002dde:	6442                	ld	s0,16(sp)
    80002de0:	64a2                	ld	s1,8(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret
    panic("bwrite");
    80002de6:	00004517          	auipc	a0,0x4
    80002dea:	5d250513          	addi	a0,a0,1490 # 800073b8 <etext+0x3b8>
    80002dee:	9f3fd0ef          	jal	800007e0 <panic>

0000000080002df2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002df2:	1101                	addi	sp,sp,-32
    80002df4:	ec06                	sd	ra,24(sp)
    80002df6:	e822                	sd	s0,16(sp)
    80002df8:	e426                	sd	s1,8(sp)
    80002dfa:	e04a                	sd	s2,0(sp)
    80002dfc:	1000                	addi	s0,sp,32
    80002dfe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e00:	01050913          	addi	s2,a0,16
    80002e04:	854a                	mv	a0,s2
    80002e06:	294010ef          	jal	8000409a <holdingsleep>
    80002e0a:	c135                	beqz	a0,80002e6e <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002e0c:	854a                	mv	a0,s2
    80002e0e:	254010ef          	jal	80004062 <releasesleep>

  acquire(&bcache.lock);
    80002e12:	00013517          	auipc	a0,0x13
    80002e16:	99e50513          	addi	a0,a0,-1634 # 800157b0 <bcache>
    80002e1a:	db5fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002e1e:	40bc                	lw	a5,64(s1)
    80002e20:	37fd                	addiw	a5,a5,-1
    80002e22:	0007871b          	sext.w	a4,a5
    80002e26:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e28:	e71d                	bnez	a4,80002e56 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e2a:	68b8                	ld	a4,80(s1)
    80002e2c:	64bc                	ld	a5,72(s1)
    80002e2e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e30:	68b8                	ld	a4,80(s1)
    80002e32:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e34:	0001b797          	auipc	a5,0x1b
    80002e38:	97c78793          	addi	a5,a5,-1668 # 8001d7b0 <bcache+0x8000>
    80002e3c:	2b87b703          	ld	a4,696(a5)
    80002e40:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e42:	0001b717          	auipc	a4,0x1b
    80002e46:	bd670713          	addi	a4,a4,-1066 # 8001da18 <bcache+0x8268>
    80002e4a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e4c:	2b87b703          	ld	a4,696(a5)
    80002e50:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e52:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002e56:	00013517          	auipc	a0,0x13
    80002e5a:	95a50513          	addi	a0,a0,-1702 # 800157b0 <bcache>
    80002e5e:	e09fd0ef          	jal	80000c66 <release>
}
    80002e62:	60e2                	ld	ra,24(sp)
    80002e64:	6442                	ld	s0,16(sp)
    80002e66:	64a2                	ld	s1,8(sp)
    80002e68:	6902                	ld	s2,0(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret
    panic("brelse");
    80002e6e:	00004517          	auipc	a0,0x4
    80002e72:	55250513          	addi	a0,a0,1362 # 800073c0 <etext+0x3c0>
    80002e76:	96bfd0ef          	jal	800007e0 <panic>

0000000080002e7a <bpin>:

void
bpin(struct buf *b) {
    80002e7a:	1101                	addi	sp,sp,-32
    80002e7c:	ec06                	sd	ra,24(sp)
    80002e7e:	e822                	sd	s0,16(sp)
    80002e80:	e426                	sd	s1,8(sp)
    80002e82:	1000                	addi	s0,sp,32
    80002e84:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e86:	00013517          	auipc	a0,0x13
    80002e8a:	92a50513          	addi	a0,a0,-1750 # 800157b0 <bcache>
    80002e8e:	d41fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002e92:	40bc                	lw	a5,64(s1)
    80002e94:	2785                	addiw	a5,a5,1
    80002e96:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e98:	00013517          	auipc	a0,0x13
    80002e9c:	91850513          	addi	a0,a0,-1768 # 800157b0 <bcache>
    80002ea0:	dc7fd0ef          	jal	80000c66 <release>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	64a2                	ld	s1,8(sp)
    80002eaa:	6105                	addi	sp,sp,32
    80002eac:	8082                	ret

0000000080002eae <bunpin>:

void
bunpin(struct buf *b) {
    80002eae:	1101                	addi	sp,sp,-32
    80002eb0:	ec06                	sd	ra,24(sp)
    80002eb2:	e822                	sd	s0,16(sp)
    80002eb4:	e426                	sd	s1,8(sp)
    80002eb6:	1000                	addi	s0,sp,32
    80002eb8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eba:	00013517          	auipc	a0,0x13
    80002ebe:	8f650513          	addi	a0,a0,-1802 # 800157b0 <bcache>
    80002ec2:	d0dfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002ec6:	40bc                	lw	a5,64(s1)
    80002ec8:	37fd                	addiw	a5,a5,-1
    80002eca:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ecc:	00013517          	auipc	a0,0x13
    80002ed0:	8e450513          	addi	a0,a0,-1820 # 800157b0 <bcache>
    80002ed4:	d93fd0ef          	jal	80000c66 <release>
}
    80002ed8:	60e2                	ld	ra,24(sp)
    80002eda:	6442                	ld	s0,16(sp)
    80002edc:	64a2                	ld	s1,8(sp)
    80002ede:	6105                	addi	sp,sp,32
    80002ee0:	8082                	ret

0000000080002ee2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ee2:	1101                	addi	sp,sp,-32
    80002ee4:	ec06                	sd	ra,24(sp)
    80002ee6:	e822                	sd	s0,16(sp)
    80002ee8:	e426                	sd	s1,8(sp)
    80002eea:	e04a                	sd	s2,0(sp)
    80002eec:	1000                	addi	s0,sp,32
    80002eee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ef0:	00d5d59b          	srliw	a1,a1,0xd
    80002ef4:	0001b797          	auipc	a5,0x1b
    80002ef8:	f987a783          	lw	a5,-104(a5) # 8001de8c <sb+0x1c>
    80002efc:	9dbd                	addw	a1,a1,a5
    80002efe:	dedff0ef          	jal	80002cea <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f02:	0074f713          	andi	a4,s1,7
    80002f06:	4785                	li	a5,1
    80002f08:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f0c:	14ce                	slli	s1,s1,0x33
    80002f0e:	90d9                	srli	s1,s1,0x36
    80002f10:	00950733          	add	a4,a0,s1
    80002f14:	05874703          	lbu	a4,88(a4)
    80002f18:	00e7f6b3          	and	a3,a5,a4
    80002f1c:	c29d                	beqz	a3,80002f42 <bfree+0x60>
    80002f1e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f20:	94aa                	add	s1,s1,a0
    80002f22:	fff7c793          	not	a5,a5
    80002f26:	8f7d                	and	a4,a4,a5
    80002f28:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f2c:	7f9000ef          	jal	80003f24 <log_write>
  brelse(bp);
    80002f30:	854a                	mv	a0,s2
    80002f32:	ec1ff0ef          	jal	80002df2 <brelse>
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6902                	ld	s2,0(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret
    panic("freeing free block");
    80002f42:	00004517          	auipc	a0,0x4
    80002f46:	48650513          	addi	a0,a0,1158 # 800073c8 <etext+0x3c8>
    80002f4a:	897fd0ef          	jal	800007e0 <panic>

0000000080002f4e <balloc>:
{
    80002f4e:	711d                	addi	sp,sp,-96
    80002f50:	ec86                	sd	ra,88(sp)
    80002f52:	e8a2                	sd	s0,80(sp)
    80002f54:	e4a6                	sd	s1,72(sp)
    80002f56:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f58:	0001b797          	auipc	a5,0x1b
    80002f5c:	f1c7a783          	lw	a5,-228(a5) # 8001de74 <sb+0x4>
    80002f60:	0e078f63          	beqz	a5,8000305e <balloc+0x110>
    80002f64:	e0ca                	sd	s2,64(sp)
    80002f66:	fc4e                	sd	s3,56(sp)
    80002f68:	f852                	sd	s4,48(sp)
    80002f6a:	f456                	sd	s5,40(sp)
    80002f6c:	f05a                	sd	s6,32(sp)
    80002f6e:	ec5e                	sd	s7,24(sp)
    80002f70:	e862                	sd	s8,16(sp)
    80002f72:	e466                	sd	s9,8(sp)
    80002f74:	8baa                	mv	s7,a0
    80002f76:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f78:	0001bb17          	auipc	s6,0x1b
    80002f7c:	ef8b0b13          	addi	s6,s6,-264 # 8001de70 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f80:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f82:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f84:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f86:	6c89                	lui	s9,0x2
    80002f88:	a0b5                	j	80002ff4 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f8a:	97ca                	add	a5,a5,s2
    80002f8c:	8e55                	or	a2,a2,a3
    80002f8e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f92:	854a                	mv	a0,s2
    80002f94:	791000ef          	jal	80003f24 <log_write>
        brelse(bp);
    80002f98:	854a                	mv	a0,s2
    80002f9a:	e59ff0ef          	jal	80002df2 <brelse>
  bp = bread(dev, bno);
    80002f9e:	85a6                	mv	a1,s1
    80002fa0:	855e                	mv	a0,s7
    80002fa2:	d49ff0ef          	jal	80002cea <bread>
    80002fa6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002fa8:	40000613          	li	a2,1024
    80002fac:	4581                	li	a1,0
    80002fae:	05850513          	addi	a0,a0,88
    80002fb2:	cf1fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	76d000ef          	jal	80003f24 <log_write>
  brelse(bp);
    80002fbc:	854a                	mv	a0,s2
    80002fbe:	e35ff0ef          	jal	80002df2 <brelse>
}
    80002fc2:	6906                	ld	s2,64(sp)
    80002fc4:	79e2                	ld	s3,56(sp)
    80002fc6:	7a42                	ld	s4,48(sp)
    80002fc8:	7aa2                	ld	s5,40(sp)
    80002fca:	7b02                	ld	s6,32(sp)
    80002fcc:	6be2                	ld	s7,24(sp)
    80002fce:	6c42                	ld	s8,16(sp)
    80002fd0:	6ca2                	ld	s9,8(sp)
}
    80002fd2:	8526                	mv	a0,s1
    80002fd4:	60e6                	ld	ra,88(sp)
    80002fd6:	6446                	ld	s0,80(sp)
    80002fd8:	64a6                	ld	s1,72(sp)
    80002fda:	6125                	addi	sp,sp,96
    80002fdc:	8082                	ret
    brelse(bp);
    80002fde:	854a                	mv	a0,s2
    80002fe0:	e13ff0ef          	jal	80002df2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002fe4:	015c87bb          	addw	a5,s9,s5
    80002fe8:	00078a9b          	sext.w	s5,a5
    80002fec:	004b2703          	lw	a4,4(s6)
    80002ff0:	04eaff63          	bgeu	s5,a4,8000304e <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002ff4:	41fad79b          	sraiw	a5,s5,0x1f
    80002ff8:	0137d79b          	srliw	a5,a5,0x13
    80002ffc:	015787bb          	addw	a5,a5,s5
    80003000:	40d7d79b          	sraiw	a5,a5,0xd
    80003004:	01cb2583          	lw	a1,28(s6)
    80003008:	9dbd                	addw	a1,a1,a5
    8000300a:	855e                	mv	a0,s7
    8000300c:	cdfff0ef          	jal	80002cea <bread>
    80003010:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003012:	004b2503          	lw	a0,4(s6)
    80003016:	000a849b          	sext.w	s1,s5
    8000301a:	8762                	mv	a4,s8
    8000301c:	fca4f1e3          	bgeu	s1,a0,80002fde <balloc+0x90>
      m = 1 << (bi % 8);
    80003020:	00777693          	andi	a3,a4,7
    80003024:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003028:	41f7579b          	sraiw	a5,a4,0x1f
    8000302c:	01d7d79b          	srliw	a5,a5,0x1d
    80003030:	9fb9                	addw	a5,a5,a4
    80003032:	4037d79b          	sraiw	a5,a5,0x3
    80003036:	00f90633          	add	a2,s2,a5
    8000303a:	05864603          	lbu	a2,88(a2)
    8000303e:	00c6f5b3          	and	a1,a3,a2
    80003042:	d5a1                	beqz	a1,80002f8a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003044:	2705                	addiw	a4,a4,1
    80003046:	2485                	addiw	s1,s1,1
    80003048:	fd471ae3          	bne	a4,s4,8000301c <balloc+0xce>
    8000304c:	bf49                	j	80002fde <balloc+0x90>
    8000304e:	6906                	ld	s2,64(sp)
    80003050:	79e2                	ld	s3,56(sp)
    80003052:	7a42                	ld	s4,48(sp)
    80003054:	7aa2                	ld	s5,40(sp)
    80003056:	7b02                	ld	s6,32(sp)
    80003058:	6be2                	ld	s7,24(sp)
    8000305a:	6c42                	ld	s8,16(sp)
    8000305c:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000305e:	00004517          	auipc	a0,0x4
    80003062:	38250513          	addi	a0,a0,898 # 800073e0 <etext+0x3e0>
    80003066:	c94fd0ef          	jal	800004fa <printf>
  return 0;
    8000306a:	4481                	li	s1,0
    8000306c:	b79d                	j	80002fd2 <balloc+0x84>

000000008000306e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000306e:	7179                	addi	sp,sp,-48
    80003070:	f406                	sd	ra,40(sp)
    80003072:	f022                	sd	s0,32(sp)
    80003074:	ec26                	sd	s1,24(sp)
    80003076:	e84a                	sd	s2,16(sp)
    80003078:	e44e                	sd	s3,8(sp)
    8000307a:	1800                	addi	s0,sp,48
    8000307c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000307e:	47ad                	li	a5,11
    80003080:	02b7e663          	bltu	a5,a1,800030ac <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003084:	02059793          	slli	a5,a1,0x20
    80003088:	01e7d593          	srli	a1,a5,0x1e
    8000308c:	00b504b3          	add	s1,a0,a1
    80003090:	0504a903          	lw	s2,80(s1)
    80003094:	06091a63          	bnez	s2,80003108 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003098:	4108                	lw	a0,0(a0)
    8000309a:	eb5ff0ef          	jal	80002f4e <balloc>
    8000309e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030a2:	06090363          	beqz	s2,80003108 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800030a6:	0524a823          	sw	s2,80(s1)
    800030aa:	a8b9                	j	80003108 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030ac:	ff45849b          	addiw	s1,a1,-12
    800030b0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800030b4:	0ff00793          	li	a5,255
    800030b8:	06e7ee63          	bltu	a5,a4,80003134 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800030bc:	08052903          	lw	s2,128(a0)
    800030c0:	00091d63          	bnez	s2,800030da <bmap+0x6c>
      addr = balloc(ip->dev);
    800030c4:	4108                	lw	a0,0(a0)
    800030c6:	e89ff0ef          	jal	80002f4e <balloc>
    800030ca:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800030ce:	02090d63          	beqz	s2,80003108 <bmap+0x9a>
    800030d2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030d4:	0929a023          	sw	s2,128(s3)
    800030d8:	a011                	j	800030dc <bmap+0x6e>
    800030da:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030dc:	85ca                	mv	a1,s2
    800030de:	0009a503          	lw	a0,0(s3)
    800030e2:	c09ff0ef          	jal	80002cea <bread>
    800030e6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030e8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800030ec:	02049713          	slli	a4,s1,0x20
    800030f0:	01e75593          	srli	a1,a4,0x1e
    800030f4:	00b784b3          	add	s1,a5,a1
    800030f8:	0004a903          	lw	s2,0(s1)
    800030fc:	00090e63          	beqz	s2,80003118 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003100:	8552                	mv	a0,s4
    80003102:	cf1ff0ef          	jal	80002df2 <brelse>
    return addr;
    80003106:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003108:	854a                	mv	a0,s2
    8000310a:	70a2                	ld	ra,40(sp)
    8000310c:	7402                	ld	s0,32(sp)
    8000310e:	64e2                	ld	s1,24(sp)
    80003110:	6942                	ld	s2,16(sp)
    80003112:	69a2                	ld	s3,8(sp)
    80003114:	6145                	addi	sp,sp,48
    80003116:	8082                	ret
      addr = balloc(ip->dev);
    80003118:	0009a503          	lw	a0,0(s3)
    8000311c:	e33ff0ef          	jal	80002f4e <balloc>
    80003120:	0005091b          	sext.w	s2,a0
      if(addr){
    80003124:	fc090ee3          	beqz	s2,80003100 <bmap+0x92>
        a[bn] = addr;
    80003128:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000312c:	8552                	mv	a0,s4
    8000312e:	5f7000ef          	jal	80003f24 <log_write>
    80003132:	b7f9                	j	80003100 <bmap+0x92>
    80003134:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003136:	00004517          	auipc	a0,0x4
    8000313a:	2c250513          	addi	a0,a0,706 # 800073f8 <etext+0x3f8>
    8000313e:	ea2fd0ef          	jal	800007e0 <panic>

0000000080003142 <iget>:
{
    80003142:	7179                	addi	sp,sp,-48
    80003144:	f406                	sd	ra,40(sp)
    80003146:	f022                	sd	s0,32(sp)
    80003148:	ec26                	sd	s1,24(sp)
    8000314a:	e84a                	sd	s2,16(sp)
    8000314c:	e44e                	sd	s3,8(sp)
    8000314e:	e052                	sd	s4,0(sp)
    80003150:	1800                	addi	s0,sp,48
    80003152:	89aa                	mv	s3,a0
    80003154:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003156:	0001b517          	auipc	a0,0x1b
    8000315a:	d3a50513          	addi	a0,a0,-710 # 8001de90 <itable>
    8000315e:	a71fd0ef          	jal	80000bce <acquire>
  empty = 0;
    80003162:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003164:	0001b497          	auipc	s1,0x1b
    80003168:	d4448493          	addi	s1,s1,-700 # 8001dea8 <itable+0x18>
    8000316c:	0001c697          	auipc	a3,0x1c
    80003170:	7cc68693          	addi	a3,a3,1996 # 8001f938 <log>
    80003174:	a039                	j	80003182 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003176:	02090963          	beqz	s2,800031a8 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000317a:	08848493          	addi	s1,s1,136
    8000317e:	02d48863          	beq	s1,a3,800031ae <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003182:	449c                	lw	a5,8(s1)
    80003184:	fef059e3          	blez	a5,80003176 <iget+0x34>
    80003188:	4098                	lw	a4,0(s1)
    8000318a:	ff3716e3          	bne	a4,s3,80003176 <iget+0x34>
    8000318e:	40d8                	lw	a4,4(s1)
    80003190:	ff4713e3          	bne	a4,s4,80003176 <iget+0x34>
      ip->ref++;
    80003194:	2785                	addiw	a5,a5,1
    80003196:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003198:	0001b517          	auipc	a0,0x1b
    8000319c:	cf850513          	addi	a0,a0,-776 # 8001de90 <itable>
    800031a0:	ac7fd0ef          	jal	80000c66 <release>
      return ip;
    800031a4:	8926                	mv	s2,s1
    800031a6:	a02d                	j	800031d0 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031a8:	fbe9                	bnez	a5,8000317a <iget+0x38>
      empty = ip;
    800031aa:	8926                	mv	s2,s1
    800031ac:	b7f9                	j	8000317a <iget+0x38>
  if(empty == 0)
    800031ae:	02090a63          	beqz	s2,800031e2 <iget+0xa0>
  ip->dev = dev;
    800031b2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031b6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031ba:	4785                	li	a5,1
    800031bc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031c0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800031c4:	0001b517          	auipc	a0,0x1b
    800031c8:	ccc50513          	addi	a0,a0,-820 # 8001de90 <itable>
    800031cc:	a9bfd0ef          	jal	80000c66 <release>
}
    800031d0:	854a                	mv	a0,s2
    800031d2:	70a2                	ld	ra,40(sp)
    800031d4:	7402                	ld	s0,32(sp)
    800031d6:	64e2                	ld	s1,24(sp)
    800031d8:	6942                	ld	s2,16(sp)
    800031da:	69a2                	ld	s3,8(sp)
    800031dc:	6a02                	ld	s4,0(sp)
    800031de:	6145                	addi	sp,sp,48
    800031e0:	8082                	ret
    panic("iget: no inodes");
    800031e2:	00004517          	auipc	a0,0x4
    800031e6:	22e50513          	addi	a0,a0,558 # 80007410 <etext+0x410>
    800031ea:	df6fd0ef          	jal	800007e0 <panic>

00000000800031ee <iinit>:
{
    800031ee:	7179                	addi	sp,sp,-48
    800031f0:	f406                	sd	ra,40(sp)
    800031f2:	f022                	sd	s0,32(sp)
    800031f4:	ec26                	sd	s1,24(sp)
    800031f6:	e84a                	sd	s2,16(sp)
    800031f8:	e44e                	sd	s3,8(sp)
    800031fa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031fc:	00004597          	auipc	a1,0x4
    80003200:	22458593          	addi	a1,a1,548 # 80007420 <etext+0x420>
    80003204:	0001b517          	auipc	a0,0x1b
    80003208:	c8c50513          	addi	a0,a0,-884 # 8001de90 <itable>
    8000320c:	943fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003210:	0001b497          	auipc	s1,0x1b
    80003214:	ca848493          	addi	s1,s1,-856 # 8001deb8 <itable+0x28>
    80003218:	0001c997          	auipc	s3,0x1c
    8000321c:	73098993          	addi	s3,s3,1840 # 8001f948 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003220:	00004917          	auipc	s2,0x4
    80003224:	20890913          	addi	s2,s2,520 # 80007428 <etext+0x428>
    80003228:	85ca                	mv	a1,s2
    8000322a:	8526                	mv	a0,s1
    8000322c:	5bb000ef          	jal	80003fe6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003230:	08848493          	addi	s1,s1,136
    80003234:	ff349ae3          	bne	s1,s3,80003228 <iinit+0x3a>
}
    80003238:	70a2                	ld	ra,40(sp)
    8000323a:	7402                	ld	s0,32(sp)
    8000323c:	64e2                	ld	s1,24(sp)
    8000323e:	6942                	ld	s2,16(sp)
    80003240:	69a2                	ld	s3,8(sp)
    80003242:	6145                	addi	sp,sp,48
    80003244:	8082                	ret

0000000080003246 <ialloc>:
{
    80003246:	7139                	addi	sp,sp,-64
    80003248:	fc06                	sd	ra,56(sp)
    8000324a:	f822                	sd	s0,48(sp)
    8000324c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000324e:	0001b717          	auipc	a4,0x1b
    80003252:	c2e72703          	lw	a4,-978(a4) # 8001de7c <sb+0xc>
    80003256:	4785                	li	a5,1
    80003258:	06e7f063          	bgeu	a5,a4,800032b8 <ialloc+0x72>
    8000325c:	f426                	sd	s1,40(sp)
    8000325e:	f04a                	sd	s2,32(sp)
    80003260:	ec4e                	sd	s3,24(sp)
    80003262:	e852                	sd	s4,16(sp)
    80003264:	e456                	sd	s5,8(sp)
    80003266:	e05a                	sd	s6,0(sp)
    80003268:	8aaa                	mv	s5,a0
    8000326a:	8b2e                	mv	s6,a1
    8000326c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000326e:	0001ba17          	auipc	s4,0x1b
    80003272:	c02a0a13          	addi	s4,s4,-1022 # 8001de70 <sb>
    80003276:	00495593          	srli	a1,s2,0x4
    8000327a:	018a2783          	lw	a5,24(s4)
    8000327e:	9dbd                	addw	a1,a1,a5
    80003280:	8556                	mv	a0,s5
    80003282:	a69ff0ef          	jal	80002cea <bread>
    80003286:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003288:	05850993          	addi	s3,a0,88
    8000328c:	00f97793          	andi	a5,s2,15
    80003290:	079a                	slli	a5,a5,0x6
    80003292:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003294:	00099783          	lh	a5,0(s3)
    80003298:	cb9d                	beqz	a5,800032ce <ialloc+0x88>
    brelse(bp);
    8000329a:	b59ff0ef          	jal	80002df2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000329e:	0905                	addi	s2,s2,1
    800032a0:	00ca2703          	lw	a4,12(s4)
    800032a4:	0009079b          	sext.w	a5,s2
    800032a8:	fce7e7e3          	bltu	a5,a4,80003276 <ialloc+0x30>
    800032ac:	74a2                	ld	s1,40(sp)
    800032ae:	7902                	ld	s2,32(sp)
    800032b0:	69e2                	ld	s3,24(sp)
    800032b2:	6a42                	ld	s4,16(sp)
    800032b4:	6aa2                	ld	s5,8(sp)
    800032b6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800032b8:	00004517          	auipc	a0,0x4
    800032bc:	17850513          	addi	a0,a0,376 # 80007430 <etext+0x430>
    800032c0:	a3afd0ef          	jal	800004fa <printf>
  return 0;
    800032c4:	4501                	li	a0,0
}
    800032c6:	70e2                	ld	ra,56(sp)
    800032c8:	7442                	ld	s0,48(sp)
    800032ca:	6121                	addi	sp,sp,64
    800032cc:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800032ce:	04000613          	li	a2,64
    800032d2:	4581                	li	a1,0
    800032d4:	854e                	mv	a0,s3
    800032d6:	9cdfd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800032da:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800032de:	8526                	mv	a0,s1
    800032e0:	445000ef          	jal	80003f24 <log_write>
      brelse(bp);
    800032e4:	8526                	mv	a0,s1
    800032e6:	b0dff0ef          	jal	80002df2 <brelse>
      return iget(dev, inum);
    800032ea:	0009059b          	sext.w	a1,s2
    800032ee:	8556                	mv	a0,s5
    800032f0:	e53ff0ef          	jal	80003142 <iget>
    800032f4:	74a2                	ld	s1,40(sp)
    800032f6:	7902                	ld	s2,32(sp)
    800032f8:	69e2                	ld	s3,24(sp)
    800032fa:	6a42                	ld	s4,16(sp)
    800032fc:	6aa2                	ld	s5,8(sp)
    800032fe:	6b02                	ld	s6,0(sp)
    80003300:	b7d9                	j	800032c6 <ialloc+0x80>

0000000080003302 <iupdate>:
{
    80003302:	1101                	addi	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	e426                	sd	s1,8(sp)
    8000330a:	e04a                	sd	s2,0(sp)
    8000330c:	1000                	addi	s0,sp,32
    8000330e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003310:	415c                	lw	a5,4(a0)
    80003312:	0047d79b          	srliw	a5,a5,0x4
    80003316:	0001b597          	auipc	a1,0x1b
    8000331a:	b725a583          	lw	a1,-1166(a1) # 8001de88 <sb+0x18>
    8000331e:	9dbd                	addw	a1,a1,a5
    80003320:	4108                	lw	a0,0(a0)
    80003322:	9c9ff0ef          	jal	80002cea <bread>
    80003326:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003328:	05850793          	addi	a5,a0,88
    8000332c:	40d8                	lw	a4,4(s1)
    8000332e:	8b3d                	andi	a4,a4,15
    80003330:	071a                	slli	a4,a4,0x6
    80003332:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003334:	04449703          	lh	a4,68(s1)
    80003338:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000333c:	04649703          	lh	a4,70(s1)
    80003340:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003344:	04849703          	lh	a4,72(s1)
    80003348:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000334c:	04a49703          	lh	a4,74(s1)
    80003350:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003354:	44f8                	lw	a4,76(s1)
    80003356:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003358:	03400613          	li	a2,52
    8000335c:	05048593          	addi	a1,s1,80
    80003360:	00c78513          	addi	a0,a5,12
    80003364:	99bfd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003368:	854a                	mv	a0,s2
    8000336a:	3bb000ef          	jal	80003f24 <log_write>
  brelse(bp);
    8000336e:	854a                	mv	a0,s2
    80003370:	a83ff0ef          	jal	80002df2 <brelse>
}
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6902                	ld	s2,0(sp)
    8000337c:	6105                	addi	sp,sp,32
    8000337e:	8082                	ret

0000000080003380 <idup>:
{
    80003380:	1101                	addi	sp,sp,-32
    80003382:	ec06                	sd	ra,24(sp)
    80003384:	e822                	sd	s0,16(sp)
    80003386:	e426                	sd	s1,8(sp)
    80003388:	1000                	addi	s0,sp,32
    8000338a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000338c:	0001b517          	auipc	a0,0x1b
    80003390:	b0450513          	addi	a0,a0,-1276 # 8001de90 <itable>
    80003394:	83bfd0ef          	jal	80000bce <acquire>
  ip->ref++;
    80003398:	449c                	lw	a5,8(s1)
    8000339a:	2785                	addiw	a5,a5,1
    8000339c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000339e:	0001b517          	auipc	a0,0x1b
    800033a2:	af250513          	addi	a0,a0,-1294 # 8001de90 <itable>
    800033a6:	8c1fd0ef          	jal	80000c66 <release>
}
    800033aa:	8526                	mv	a0,s1
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6105                	addi	sp,sp,32
    800033b4:	8082                	ret

00000000800033b6 <ilock>:
{
    800033b6:	1101                	addi	sp,sp,-32
    800033b8:	ec06                	sd	ra,24(sp)
    800033ba:	e822                	sd	s0,16(sp)
    800033bc:	e426                	sd	s1,8(sp)
    800033be:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033c0:	cd19                	beqz	a0,800033de <ilock+0x28>
    800033c2:	84aa                	mv	s1,a0
    800033c4:	451c                	lw	a5,8(a0)
    800033c6:	00f05c63          	blez	a5,800033de <ilock+0x28>
  acquiresleep(&ip->lock);
    800033ca:	0541                	addi	a0,a0,16
    800033cc:	451000ef          	jal	8000401c <acquiresleep>
  if(ip->valid == 0){
    800033d0:	40bc                	lw	a5,64(s1)
    800033d2:	cf89                	beqz	a5,800033ec <ilock+0x36>
}
    800033d4:	60e2                	ld	ra,24(sp)
    800033d6:	6442                	ld	s0,16(sp)
    800033d8:	64a2                	ld	s1,8(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret
    800033de:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033e0:	00004517          	auipc	a0,0x4
    800033e4:	06850513          	addi	a0,a0,104 # 80007448 <etext+0x448>
    800033e8:	bf8fd0ef          	jal	800007e0 <panic>
    800033ec:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033ee:	40dc                	lw	a5,4(s1)
    800033f0:	0047d79b          	srliw	a5,a5,0x4
    800033f4:	0001b597          	auipc	a1,0x1b
    800033f8:	a945a583          	lw	a1,-1388(a1) # 8001de88 <sb+0x18>
    800033fc:	9dbd                	addw	a1,a1,a5
    800033fe:	4088                	lw	a0,0(s1)
    80003400:	8ebff0ef          	jal	80002cea <bread>
    80003404:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003406:	05850593          	addi	a1,a0,88
    8000340a:	40dc                	lw	a5,4(s1)
    8000340c:	8bbd                	andi	a5,a5,15
    8000340e:	079a                	slli	a5,a5,0x6
    80003410:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003412:	00059783          	lh	a5,0(a1)
    80003416:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000341a:	00259783          	lh	a5,2(a1)
    8000341e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003422:	00459783          	lh	a5,4(a1)
    80003426:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000342a:	00659783          	lh	a5,6(a1)
    8000342e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003432:	459c                	lw	a5,8(a1)
    80003434:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003436:	03400613          	li	a2,52
    8000343a:	05b1                	addi	a1,a1,12
    8000343c:	05048513          	addi	a0,s1,80
    80003440:	8bffd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003444:	854a                	mv	a0,s2
    80003446:	9adff0ef          	jal	80002df2 <brelse>
    ip->valid = 1;
    8000344a:	4785                	li	a5,1
    8000344c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000344e:	04449783          	lh	a5,68(s1)
    80003452:	c399                	beqz	a5,80003458 <ilock+0xa2>
    80003454:	6902                	ld	s2,0(sp)
    80003456:	bfbd                	j	800033d4 <ilock+0x1e>
      panic("ilock: no type");
    80003458:	00004517          	auipc	a0,0x4
    8000345c:	ff850513          	addi	a0,a0,-8 # 80007450 <etext+0x450>
    80003460:	b80fd0ef          	jal	800007e0 <panic>

0000000080003464 <iunlock>:
{
    80003464:	1101                	addi	sp,sp,-32
    80003466:	ec06                	sd	ra,24(sp)
    80003468:	e822                	sd	s0,16(sp)
    8000346a:	e426                	sd	s1,8(sp)
    8000346c:	e04a                	sd	s2,0(sp)
    8000346e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003470:	c505                	beqz	a0,80003498 <iunlock+0x34>
    80003472:	84aa                	mv	s1,a0
    80003474:	01050913          	addi	s2,a0,16
    80003478:	854a                	mv	a0,s2
    8000347a:	421000ef          	jal	8000409a <holdingsleep>
    8000347e:	cd09                	beqz	a0,80003498 <iunlock+0x34>
    80003480:	449c                	lw	a5,8(s1)
    80003482:	00f05b63          	blez	a5,80003498 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003486:	854a                	mv	a0,s2
    80003488:	3db000ef          	jal	80004062 <releasesleep>
}
    8000348c:	60e2                	ld	ra,24(sp)
    8000348e:	6442                	ld	s0,16(sp)
    80003490:	64a2                	ld	s1,8(sp)
    80003492:	6902                	ld	s2,0(sp)
    80003494:	6105                	addi	sp,sp,32
    80003496:	8082                	ret
    panic("iunlock");
    80003498:	00004517          	auipc	a0,0x4
    8000349c:	fc850513          	addi	a0,a0,-56 # 80007460 <etext+0x460>
    800034a0:	b40fd0ef          	jal	800007e0 <panic>

00000000800034a4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034a4:	7179                	addi	sp,sp,-48
    800034a6:	f406                	sd	ra,40(sp)
    800034a8:	f022                	sd	s0,32(sp)
    800034aa:	ec26                	sd	s1,24(sp)
    800034ac:	e84a                	sd	s2,16(sp)
    800034ae:	e44e                	sd	s3,8(sp)
    800034b0:	1800                	addi	s0,sp,48
    800034b2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034b4:	05050493          	addi	s1,a0,80
    800034b8:	08050913          	addi	s2,a0,128
    800034bc:	a021                	j	800034c4 <itrunc+0x20>
    800034be:	0491                	addi	s1,s1,4
    800034c0:	01248b63          	beq	s1,s2,800034d6 <itrunc+0x32>
    if(ip->addrs[i]){
    800034c4:	408c                	lw	a1,0(s1)
    800034c6:	dde5                	beqz	a1,800034be <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800034c8:	0009a503          	lw	a0,0(s3)
    800034cc:	a17ff0ef          	jal	80002ee2 <bfree>
      ip->addrs[i] = 0;
    800034d0:	0004a023          	sw	zero,0(s1)
    800034d4:	b7ed                	j	800034be <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034d6:	0809a583          	lw	a1,128(s3)
    800034da:	ed89                	bnez	a1,800034f4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034dc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034e0:	854e                	mv	a0,s3
    800034e2:	e21ff0ef          	jal	80003302 <iupdate>
}
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret
    800034f4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034f6:	0009a503          	lw	a0,0(s3)
    800034fa:	ff0ff0ef          	jal	80002cea <bread>
    800034fe:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003500:	05850493          	addi	s1,a0,88
    80003504:	45850913          	addi	s2,a0,1112
    80003508:	a021                	j	80003510 <itrunc+0x6c>
    8000350a:	0491                	addi	s1,s1,4
    8000350c:	01248963          	beq	s1,s2,8000351e <itrunc+0x7a>
      if(a[j])
    80003510:	408c                	lw	a1,0(s1)
    80003512:	dde5                	beqz	a1,8000350a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003514:	0009a503          	lw	a0,0(s3)
    80003518:	9cbff0ef          	jal	80002ee2 <bfree>
    8000351c:	b7fd                	j	8000350a <itrunc+0x66>
    brelse(bp);
    8000351e:	8552                	mv	a0,s4
    80003520:	8d3ff0ef          	jal	80002df2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003524:	0809a583          	lw	a1,128(s3)
    80003528:	0009a503          	lw	a0,0(s3)
    8000352c:	9b7ff0ef          	jal	80002ee2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003530:	0809a023          	sw	zero,128(s3)
    80003534:	6a02                	ld	s4,0(sp)
    80003536:	b75d                	j	800034dc <itrunc+0x38>

0000000080003538 <iput>:
{
    80003538:	1101                	addi	sp,sp,-32
    8000353a:	ec06                	sd	ra,24(sp)
    8000353c:	e822                	sd	s0,16(sp)
    8000353e:	e426                	sd	s1,8(sp)
    80003540:	1000                	addi	s0,sp,32
    80003542:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003544:	0001b517          	auipc	a0,0x1b
    80003548:	94c50513          	addi	a0,a0,-1716 # 8001de90 <itable>
    8000354c:	e82fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003550:	4498                	lw	a4,8(s1)
    80003552:	4785                	li	a5,1
    80003554:	02f70063          	beq	a4,a5,80003574 <iput+0x3c>
  ip->ref--;
    80003558:	449c                	lw	a5,8(s1)
    8000355a:	37fd                	addiw	a5,a5,-1
    8000355c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000355e:	0001b517          	auipc	a0,0x1b
    80003562:	93250513          	addi	a0,a0,-1742 # 8001de90 <itable>
    80003566:	f00fd0ef          	jal	80000c66 <release>
}
    8000356a:	60e2                	ld	ra,24(sp)
    8000356c:	6442                	ld	s0,16(sp)
    8000356e:	64a2                	ld	s1,8(sp)
    80003570:	6105                	addi	sp,sp,32
    80003572:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003574:	40bc                	lw	a5,64(s1)
    80003576:	d3ed                	beqz	a5,80003558 <iput+0x20>
    80003578:	04a49783          	lh	a5,74(s1)
    8000357c:	fff1                	bnez	a5,80003558 <iput+0x20>
    8000357e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003580:	01048913          	addi	s2,s1,16
    80003584:	854a                	mv	a0,s2
    80003586:	297000ef          	jal	8000401c <acquiresleep>
    release(&itable.lock);
    8000358a:	0001b517          	auipc	a0,0x1b
    8000358e:	90650513          	addi	a0,a0,-1786 # 8001de90 <itable>
    80003592:	ed4fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    80003596:	8526                	mv	a0,s1
    80003598:	f0dff0ef          	jal	800034a4 <itrunc>
    ip->type = 0;
    8000359c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035a0:	8526                	mv	a0,s1
    800035a2:	d61ff0ef          	jal	80003302 <iupdate>
    ip->valid = 0;
    800035a6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035aa:	854a                	mv	a0,s2
    800035ac:	2b7000ef          	jal	80004062 <releasesleep>
    acquire(&itable.lock);
    800035b0:	0001b517          	auipc	a0,0x1b
    800035b4:	8e050513          	addi	a0,a0,-1824 # 8001de90 <itable>
    800035b8:	e16fd0ef          	jal	80000bce <acquire>
    800035bc:	6902                	ld	s2,0(sp)
    800035be:	bf69                	j	80003558 <iput+0x20>

00000000800035c0 <iunlockput>:
{
    800035c0:	1101                	addi	sp,sp,-32
    800035c2:	ec06                	sd	ra,24(sp)
    800035c4:	e822                	sd	s0,16(sp)
    800035c6:	e426                	sd	s1,8(sp)
    800035c8:	1000                	addi	s0,sp,32
    800035ca:	84aa                	mv	s1,a0
  iunlock(ip);
    800035cc:	e99ff0ef          	jal	80003464 <iunlock>
  iput(ip);
    800035d0:	8526                	mv	a0,s1
    800035d2:	f67ff0ef          	jal	80003538 <iput>
}
    800035d6:	60e2                	ld	ra,24(sp)
    800035d8:	6442                	ld	s0,16(sp)
    800035da:	64a2                	ld	s1,8(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret

00000000800035e0 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035e0:	0001b717          	auipc	a4,0x1b
    800035e4:	89c72703          	lw	a4,-1892(a4) # 8001de7c <sb+0xc>
    800035e8:	4785                	li	a5,1
    800035ea:	0ae7ff63          	bgeu	a5,a4,800036a8 <ireclaim+0xc8>
{
    800035ee:	7139                	addi	sp,sp,-64
    800035f0:	fc06                	sd	ra,56(sp)
    800035f2:	f822                	sd	s0,48(sp)
    800035f4:	f426                	sd	s1,40(sp)
    800035f6:	f04a                	sd	s2,32(sp)
    800035f8:	ec4e                	sd	s3,24(sp)
    800035fa:	e852                	sd	s4,16(sp)
    800035fc:	e456                	sd	s5,8(sp)
    800035fe:	e05a                	sd	s6,0(sp)
    80003600:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003602:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003604:	00050a1b          	sext.w	s4,a0
    80003608:	0001ba97          	auipc	s5,0x1b
    8000360c:	868a8a93          	addi	s5,s5,-1944 # 8001de70 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003610:	00004b17          	auipc	s6,0x4
    80003614:	e58b0b13          	addi	s6,s6,-424 # 80007468 <etext+0x468>
    80003618:	a099                	j	8000365e <ireclaim+0x7e>
    8000361a:	85ce                	mv	a1,s3
    8000361c:	855a                	mv	a0,s6
    8000361e:	eddfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003622:	85ce                	mv	a1,s3
    80003624:	8552                	mv	a0,s4
    80003626:	b1dff0ef          	jal	80003142 <iget>
    8000362a:	89aa                	mv	s3,a0
    brelse(bp);
    8000362c:	854a                	mv	a0,s2
    8000362e:	fc4ff0ef          	jal	80002df2 <brelse>
    if (ip) {
    80003632:	00098f63          	beqz	s3,80003650 <ireclaim+0x70>
      begin_op();
    80003636:	76a000ef          	jal	80003da0 <begin_op>
      ilock(ip);
    8000363a:	854e                	mv	a0,s3
    8000363c:	d7bff0ef          	jal	800033b6 <ilock>
      iunlock(ip);
    80003640:	854e                	mv	a0,s3
    80003642:	e23ff0ef          	jal	80003464 <iunlock>
      iput(ip);
    80003646:	854e                	mv	a0,s3
    80003648:	ef1ff0ef          	jal	80003538 <iput>
      end_op();
    8000364c:	7be000ef          	jal	80003e0a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003650:	0485                	addi	s1,s1,1
    80003652:	00caa703          	lw	a4,12(s5)
    80003656:	0004879b          	sext.w	a5,s1
    8000365a:	02e7fd63          	bgeu	a5,a4,80003694 <ireclaim+0xb4>
    8000365e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003662:	0044d593          	srli	a1,s1,0x4
    80003666:	018aa783          	lw	a5,24(s5)
    8000366a:	9dbd                	addw	a1,a1,a5
    8000366c:	8552                	mv	a0,s4
    8000366e:	e7cff0ef          	jal	80002cea <bread>
    80003672:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003674:	05850793          	addi	a5,a0,88
    80003678:	00f9f713          	andi	a4,s3,15
    8000367c:	071a                	slli	a4,a4,0x6
    8000367e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003680:	00079703          	lh	a4,0(a5)
    80003684:	c701                	beqz	a4,8000368c <ireclaim+0xac>
    80003686:	00679783          	lh	a5,6(a5)
    8000368a:	dbc1                	beqz	a5,8000361a <ireclaim+0x3a>
    brelse(bp);
    8000368c:	854a                	mv	a0,s2
    8000368e:	f64ff0ef          	jal	80002df2 <brelse>
    if (ip) {
    80003692:	bf7d                	j	80003650 <ireclaim+0x70>
}
    80003694:	70e2                	ld	ra,56(sp)
    80003696:	7442                	ld	s0,48(sp)
    80003698:	74a2                	ld	s1,40(sp)
    8000369a:	7902                	ld	s2,32(sp)
    8000369c:	69e2                	ld	s3,24(sp)
    8000369e:	6a42                	ld	s4,16(sp)
    800036a0:	6aa2                	ld	s5,8(sp)
    800036a2:	6b02                	ld	s6,0(sp)
    800036a4:	6121                	addi	sp,sp,64
    800036a6:	8082                	ret
    800036a8:	8082                	ret

00000000800036aa <fsinit>:
fsinit(int dev) {
    800036aa:	7179                	addi	sp,sp,-48
    800036ac:	f406                	sd	ra,40(sp)
    800036ae:	f022                	sd	s0,32(sp)
    800036b0:	ec26                	sd	s1,24(sp)
    800036b2:	e84a                	sd	s2,16(sp)
    800036b4:	e44e                	sd	s3,8(sp)
    800036b6:	1800                	addi	s0,sp,48
    800036b8:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800036ba:	4585                	li	a1,1
    800036bc:	e2eff0ef          	jal	80002cea <bread>
    800036c0:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036c2:	0001a997          	auipc	s3,0x1a
    800036c6:	7ae98993          	addi	s3,s3,1966 # 8001de70 <sb>
    800036ca:	02000613          	li	a2,32
    800036ce:	05850593          	addi	a1,a0,88
    800036d2:	854e                	mv	a0,s3
    800036d4:	e2afd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800036d8:	854a                	mv	a0,s2
    800036da:	f18ff0ef          	jal	80002df2 <brelse>
  if(sb.magic != FSMAGIC)
    800036de:	0009a703          	lw	a4,0(s3)
    800036e2:	102037b7          	lui	a5,0x10203
    800036e6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ea:	02f71363          	bne	a4,a5,80003710 <fsinit+0x66>
  initlog(dev, &sb);
    800036ee:	0001a597          	auipc	a1,0x1a
    800036f2:	78258593          	addi	a1,a1,1922 # 8001de70 <sb>
    800036f6:	8526                	mv	a0,s1
    800036f8:	62a000ef          	jal	80003d22 <initlog>
  ireclaim(dev);
    800036fc:	8526                	mv	a0,s1
    800036fe:	ee3ff0ef          	jal	800035e0 <ireclaim>
}
    80003702:	70a2                	ld	ra,40(sp)
    80003704:	7402                	ld	s0,32(sp)
    80003706:	64e2                	ld	s1,24(sp)
    80003708:	6942                	ld	s2,16(sp)
    8000370a:	69a2                	ld	s3,8(sp)
    8000370c:	6145                	addi	sp,sp,48
    8000370e:	8082                	ret
    panic("invalid file system");
    80003710:	00004517          	auipc	a0,0x4
    80003714:	d7850513          	addi	a0,a0,-648 # 80007488 <etext+0x488>
    80003718:	8c8fd0ef          	jal	800007e0 <panic>

000000008000371c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000371c:	1141                	addi	sp,sp,-16
    8000371e:	e422                	sd	s0,8(sp)
    80003720:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003722:	411c                	lw	a5,0(a0)
    80003724:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003726:	415c                	lw	a5,4(a0)
    80003728:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000372a:	04451783          	lh	a5,68(a0)
    8000372e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003732:	04a51783          	lh	a5,74(a0)
    80003736:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000373a:	04c56783          	lwu	a5,76(a0)
    8000373e:	e99c                	sd	a5,16(a1)
}
    80003740:	6422                	ld	s0,8(sp)
    80003742:	0141                	addi	sp,sp,16
    80003744:	8082                	ret

0000000080003746 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003746:	457c                	lw	a5,76(a0)
    80003748:	0ed7eb63          	bltu	a5,a3,8000383e <readi+0xf8>
{
    8000374c:	7159                	addi	sp,sp,-112
    8000374e:	f486                	sd	ra,104(sp)
    80003750:	f0a2                	sd	s0,96(sp)
    80003752:	eca6                	sd	s1,88(sp)
    80003754:	e0d2                	sd	s4,64(sp)
    80003756:	fc56                	sd	s5,56(sp)
    80003758:	f85a                	sd	s6,48(sp)
    8000375a:	f45e                	sd	s7,40(sp)
    8000375c:	1880                	addi	s0,sp,112
    8000375e:	8b2a                	mv	s6,a0
    80003760:	8bae                	mv	s7,a1
    80003762:	8a32                	mv	s4,a2
    80003764:	84b6                	mv	s1,a3
    80003766:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003768:	9f35                	addw	a4,a4,a3
    return 0;
    8000376a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000376c:	0cd76063          	bltu	a4,a3,8000382c <readi+0xe6>
    80003770:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003772:	00e7f463          	bgeu	a5,a4,8000377a <readi+0x34>
    n = ip->size - off;
    80003776:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000377a:	080a8f63          	beqz	s5,80003818 <readi+0xd2>
    8000377e:	e8ca                	sd	s2,80(sp)
    80003780:	f062                	sd	s8,32(sp)
    80003782:	ec66                	sd	s9,24(sp)
    80003784:	e86a                	sd	s10,16(sp)
    80003786:	e46e                	sd	s11,8(sp)
    80003788:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000378a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000378e:	5c7d                	li	s8,-1
    80003790:	a80d                	j	800037c2 <readi+0x7c>
    80003792:	020d1d93          	slli	s11,s10,0x20
    80003796:	020ddd93          	srli	s11,s11,0x20
    8000379a:	05890613          	addi	a2,s2,88
    8000379e:	86ee                	mv	a3,s11
    800037a0:	963a                	add	a2,a2,a4
    800037a2:	85d2                	mv	a1,s4
    800037a4:	855e                	mv	a0,s7
    800037a6:	b6bfe0ef          	jal	80002310 <either_copyout>
    800037aa:	05850763          	beq	a0,s8,800037f8 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037ae:	854a                	mv	a0,s2
    800037b0:	e42ff0ef          	jal	80002df2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b4:	013d09bb          	addw	s3,s10,s3
    800037b8:	009d04bb          	addw	s1,s10,s1
    800037bc:	9a6e                	add	s4,s4,s11
    800037be:	0559f763          	bgeu	s3,s5,8000380c <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800037c2:	00a4d59b          	srliw	a1,s1,0xa
    800037c6:	855a                	mv	a0,s6
    800037c8:	8a7ff0ef          	jal	8000306e <bmap>
    800037cc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800037d0:	c5b1                	beqz	a1,8000381c <readi+0xd6>
    bp = bread(ip->dev, addr);
    800037d2:	000b2503          	lw	a0,0(s6)
    800037d6:	d14ff0ef          	jal	80002cea <bread>
    800037da:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037dc:	3ff4f713          	andi	a4,s1,1023
    800037e0:	40ec87bb          	subw	a5,s9,a4
    800037e4:	413a86bb          	subw	a3,s5,s3
    800037e8:	8d3e                	mv	s10,a5
    800037ea:	2781                	sext.w	a5,a5
    800037ec:	0006861b          	sext.w	a2,a3
    800037f0:	faf671e3          	bgeu	a2,a5,80003792 <readi+0x4c>
    800037f4:	8d36                	mv	s10,a3
    800037f6:	bf71                	j	80003792 <readi+0x4c>
      brelse(bp);
    800037f8:	854a                	mv	a0,s2
    800037fa:	df8ff0ef          	jal	80002df2 <brelse>
      tot = -1;
    800037fe:	59fd                	li	s3,-1
      break;
    80003800:	6946                	ld	s2,80(sp)
    80003802:	7c02                	ld	s8,32(sp)
    80003804:	6ce2                	ld	s9,24(sp)
    80003806:	6d42                	ld	s10,16(sp)
    80003808:	6da2                	ld	s11,8(sp)
    8000380a:	a831                	j	80003826 <readi+0xe0>
    8000380c:	6946                	ld	s2,80(sp)
    8000380e:	7c02                	ld	s8,32(sp)
    80003810:	6ce2                	ld	s9,24(sp)
    80003812:	6d42                	ld	s10,16(sp)
    80003814:	6da2                	ld	s11,8(sp)
    80003816:	a801                	j	80003826 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003818:	89d6                	mv	s3,s5
    8000381a:	a031                	j	80003826 <readi+0xe0>
    8000381c:	6946                	ld	s2,80(sp)
    8000381e:	7c02                	ld	s8,32(sp)
    80003820:	6ce2                	ld	s9,24(sp)
    80003822:	6d42                	ld	s10,16(sp)
    80003824:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003826:	0009851b          	sext.w	a0,s3
    8000382a:	69a6                	ld	s3,72(sp)
}
    8000382c:	70a6                	ld	ra,104(sp)
    8000382e:	7406                	ld	s0,96(sp)
    80003830:	64e6                	ld	s1,88(sp)
    80003832:	6a06                	ld	s4,64(sp)
    80003834:	7ae2                	ld	s5,56(sp)
    80003836:	7b42                	ld	s6,48(sp)
    80003838:	7ba2                	ld	s7,40(sp)
    8000383a:	6165                	addi	sp,sp,112
    8000383c:	8082                	ret
    return 0;
    8000383e:	4501                	li	a0,0
}
    80003840:	8082                	ret

0000000080003842 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003842:	457c                	lw	a5,76(a0)
    80003844:	10d7e063          	bltu	a5,a3,80003944 <writei+0x102>
{
    80003848:	7159                	addi	sp,sp,-112
    8000384a:	f486                	sd	ra,104(sp)
    8000384c:	f0a2                	sd	s0,96(sp)
    8000384e:	e8ca                	sd	s2,80(sp)
    80003850:	e0d2                	sd	s4,64(sp)
    80003852:	fc56                	sd	s5,56(sp)
    80003854:	f85a                	sd	s6,48(sp)
    80003856:	f45e                	sd	s7,40(sp)
    80003858:	1880                	addi	s0,sp,112
    8000385a:	8aaa                	mv	s5,a0
    8000385c:	8bae                	mv	s7,a1
    8000385e:	8a32                	mv	s4,a2
    80003860:	8936                	mv	s2,a3
    80003862:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003864:	00e687bb          	addw	a5,a3,a4
    80003868:	0ed7e063          	bltu	a5,a3,80003948 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000386c:	00043737          	lui	a4,0x43
    80003870:	0cf76e63          	bltu	a4,a5,8000394c <writei+0x10a>
    80003874:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003876:	0a0b0f63          	beqz	s6,80003934 <writei+0xf2>
    8000387a:	eca6                	sd	s1,88(sp)
    8000387c:	f062                	sd	s8,32(sp)
    8000387e:	ec66                	sd	s9,24(sp)
    80003880:	e86a                	sd	s10,16(sp)
    80003882:	e46e                	sd	s11,8(sp)
    80003884:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003886:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000388a:	5c7d                	li	s8,-1
    8000388c:	a825                	j	800038c4 <writei+0x82>
    8000388e:	020d1d93          	slli	s11,s10,0x20
    80003892:	020ddd93          	srli	s11,s11,0x20
    80003896:	05848513          	addi	a0,s1,88
    8000389a:	86ee                	mv	a3,s11
    8000389c:	8652                	mv	a2,s4
    8000389e:	85de                	mv	a1,s7
    800038a0:	953a                	add	a0,a0,a4
    800038a2:	ab9fe0ef          	jal	8000235a <either_copyin>
    800038a6:	05850a63          	beq	a0,s8,800038fa <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038aa:	8526                	mv	a0,s1
    800038ac:	678000ef          	jal	80003f24 <log_write>
    brelse(bp);
    800038b0:	8526                	mv	a0,s1
    800038b2:	d40ff0ef          	jal	80002df2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038b6:	013d09bb          	addw	s3,s10,s3
    800038ba:	012d093b          	addw	s2,s10,s2
    800038be:	9a6e                	add	s4,s4,s11
    800038c0:	0569f063          	bgeu	s3,s6,80003900 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038c4:	00a9559b          	srliw	a1,s2,0xa
    800038c8:	8556                	mv	a0,s5
    800038ca:	fa4ff0ef          	jal	8000306e <bmap>
    800038ce:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038d2:	c59d                	beqz	a1,80003900 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800038d4:	000aa503          	lw	a0,0(s5)
    800038d8:	c12ff0ef          	jal	80002cea <bread>
    800038dc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038de:	3ff97713          	andi	a4,s2,1023
    800038e2:	40ec87bb          	subw	a5,s9,a4
    800038e6:	413b06bb          	subw	a3,s6,s3
    800038ea:	8d3e                	mv	s10,a5
    800038ec:	2781                	sext.w	a5,a5
    800038ee:	0006861b          	sext.w	a2,a3
    800038f2:	f8f67ee3          	bgeu	a2,a5,8000388e <writei+0x4c>
    800038f6:	8d36                	mv	s10,a3
    800038f8:	bf59                	j	8000388e <writei+0x4c>
      brelse(bp);
    800038fa:	8526                	mv	a0,s1
    800038fc:	cf6ff0ef          	jal	80002df2 <brelse>
  }

  if(off > ip->size)
    80003900:	04caa783          	lw	a5,76(s5)
    80003904:	0327fa63          	bgeu	a5,s2,80003938 <writei+0xf6>
    ip->size = off;
    80003908:	052aa623          	sw	s2,76(s5)
    8000390c:	64e6                	ld	s1,88(sp)
    8000390e:	7c02                	ld	s8,32(sp)
    80003910:	6ce2                	ld	s9,24(sp)
    80003912:	6d42                	ld	s10,16(sp)
    80003914:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003916:	8556                	mv	a0,s5
    80003918:	9ebff0ef          	jal	80003302 <iupdate>

  return tot;
    8000391c:	0009851b          	sext.w	a0,s3
    80003920:	69a6                	ld	s3,72(sp)
}
    80003922:	70a6                	ld	ra,104(sp)
    80003924:	7406                	ld	s0,96(sp)
    80003926:	6946                	ld	s2,80(sp)
    80003928:	6a06                	ld	s4,64(sp)
    8000392a:	7ae2                	ld	s5,56(sp)
    8000392c:	7b42                	ld	s6,48(sp)
    8000392e:	7ba2                	ld	s7,40(sp)
    80003930:	6165                	addi	sp,sp,112
    80003932:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003934:	89da                	mv	s3,s6
    80003936:	b7c5                	j	80003916 <writei+0xd4>
    80003938:	64e6                	ld	s1,88(sp)
    8000393a:	7c02                	ld	s8,32(sp)
    8000393c:	6ce2                	ld	s9,24(sp)
    8000393e:	6d42                	ld	s10,16(sp)
    80003940:	6da2                	ld	s11,8(sp)
    80003942:	bfd1                	j	80003916 <writei+0xd4>
    return -1;
    80003944:	557d                	li	a0,-1
}
    80003946:	8082                	ret
    return -1;
    80003948:	557d                	li	a0,-1
    8000394a:	bfe1                	j	80003922 <writei+0xe0>
    return -1;
    8000394c:	557d                	li	a0,-1
    8000394e:	bfd1                	j	80003922 <writei+0xe0>

0000000080003950 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003950:	1141                	addi	sp,sp,-16
    80003952:	e406                	sd	ra,8(sp)
    80003954:	e022                	sd	s0,0(sp)
    80003956:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003958:	4639                	li	a2,14
    8000395a:	c14fd0ef          	jal	80000d6e <strncmp>
}
    8000395e:	60a2                	ld	ra,8(sp)
    80003960:	6402                	ld	s0,0(sp)
    80003962:	0141                	addi	sp,sp,16
    80003964:	8082                	ret

0000000080003966 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003966:	7139                	addi	sp,sp,-64
    80003968:	fc06                	sd	ra,56(sp)
    8000396a:	f822                	sd	s0,48(sp)
    8000396c:	f426                	sd	s1,40(sp)
    8000396e:	f04a                	sd	s2,32(sp)
    80003970:	ec4e                	sd	s3,24(sp)
    80003972:	e852                	sd	s4,16(sp)
    80003974:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003976:	04451703          	lh	a4,68(a0)
    8000397a:	4785                	li	a5,1
    8000397c:	00f71a63          	bne	a4,a5,80003990 <dirlookup+0x2a>
    80003980:	892a                	mv	s2,a0
    80003982:	89ae                	mv	s3,a1
    80003984:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003986:	457c                	lw	a5,76(a0)
    80003988:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000398a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000398c:	e39d                	bnez	a5,800039b2 <dirlookup+0x4c>
    8000398e:	a095                	j	800039f2 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003990:	00004517          	auipc	a0,0x4
    80003994:	b1050513          	addi	a0,a0,-1264 # 800074a0 <etext+0x4a0>
    80003998:	e49fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    8000399c:	00004517          	auipc	a0,0x4
    800039a0:	b1c50513          	addi	a0,a0,-1252 # 800074b8 <etext+0x4b8>
    800039a4:	e3dfc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039a8:	24c1                	addiw	s1,s1,16
    800039aa:	04c92783          	lw	a5,76(s2)
    800039ae:	04f4f163          	bgeu	s1,a5,800039f0 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039b2:	4741                	li	a4,16
    800039b4:	86a6                	mv	a3,s1
    800039b6:	fc040613          	addi	a2,s0,-64
    800039ba:	4581                	li	a1,0
    800039bc:	854a                	mv	a0,s2
    800039be:	d89ff0ef          	jal	80003746 <readi>
    800039c2:	47c1                	li	a5,16
    800039c4:	fcf51ce3          	bne	a0,a5,8000399c <dirlookup+0x36>
    if(de.inum == 0)
    800039c8:	fc045783          	lhu	a5,-64(s0)
    800039cc:	dff1                	beqz	a5,800039a8 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800039ce:	fc240593          	addi	a1,s0,-62
    800039d2:	854e                	mv	a0,s3
    800039d4:	f7dff0ef          	jal	80003950 <namecmp>
    800039d8:	f961                	bnez	a0,800039a8 <dirlookup+0x42>
      if(poff)
    800039da:	000a0463          	beqz	s4,800039e2 <dirlookup+0x7c>
        *poff = off;
    800039de:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039e2:	fc045583          	lhu	a1,-64(s0)
    800039e6:	00092503          	lw	a0,0(s2)
    800039ea:	f58ff0ef          	jal	80003142 <iget>
    800039ee:	a011                	j	800039f2 <dirlookup+0x8c>
  return 0;
    800039f0:	4501                	li	a0,0
}
    800039f2:	70e2                	ld	ra,56(sp)
    800039f4:	7442                	ld	s0,48(sp)
    800039f6:	74a2                	ld	s1,40(sp)
    800039f8:	7902                	ld	s2,32(sp)
    800039fa:	69e2                	ld	s3,24(sp)
    800039fc:	6a42                	ld	s4,16(sp)
    800039fe:	6121                	addi	sp,sp,64
    80003a00:	8082                	ret

0000000080003a02 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a02:	711d                	addi	sp,sp,-96
    80003a04:	ec86                	sd	ra,88(sp)
    80003a06:	e8a2                	sd	s0,80(sp)
    80003a08:	e4a6                	sd	s1,72(sp)
    80003a0a:	e0ca                	sd	s2,64(sp)
    80003a0c:	fc4e                	sd	s3,56(sp)
    80003a0e:	f852                	sd	s4,48(sp)
    80003a10:	f456                	sd	s5,40(sp)
    80003a12:	f05a                	sd	s6,32(sp)
    80003a14:	ec5e                	sd	s7,24(sp)
    80003a16:	e862                	sd	s8,16(sp)
    80003a18:	e466                	sd	s9,8(sp)
    80003a1a:	1080                	addi	s0,sp,96
    80003a1c:	84aa                	mv	s1,a0
    80003a1e:	8b2e                	mv	s6,a1
    80003a20:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a22:	00054703          	lbu	a4,0(a0)
    80003a26:	02f00793          	li	a5,47
    80003a2a:	00f70e63          	beq	a4,a5,80003a46 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a2e:	f7dfd0ef          	jal	800019aa <myproc>
    80003a32:	15053503          	ld	a0,336(a0)
    80003a36:	94bff0ef          	jal	80003380 <idup>
    80003a3a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a3c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003a40:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a42:	4b85                	li	s7,1
    80003a44:	a871                	j	80003ae0 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003a46:	4585                	li	a1,1
    80003a48:	4505                	li	a0,1
    80003a4a:	ef8ff0ef          	jal	80003142 <iget>
    80003a4e:	8a2a                	mv	s4,a0
    80003a50:	b7f5                	j	80003a3c <namex+0x3a>
      iunlockput(ip);
    80003a52:	8552                	mv	a0,s4
    80003a54:	b6dff0ef          	jal	800035c0 <iunlockput>
      return 0;
    80003a58:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a5a:	8552                	mv	a0,s4
    80003a5c:	60e6                	ld	ra,88(sp)
    80003a5e:	6446                	ld	s0,80(sp)
    80003a60:	64a6                	ld	s1,72(sp)
    80003a62:	6906                	ld	s2,64(sp)
    80003a64:	79e2                	ld	s3,56(sp)
    80003a66:	7a42                	ld	s4,48(sp)
    80003a68:	7aa2                	ld	s5,40(sp)
    80003a6a:	7b02                	ld	s6,32(sp)
    80003a6c:	6be2                	ld	s7,24(sp)
    80003a6e:	6c42                	ld	s8,16(sp)
    80003a70:	6ca2                	ld	s9,8(sp)
    80003a72:	6125                	addi	sp,sp,96
    80003a74:	8082                	ret
      iunlock(ip);
    80003a76:	8552                	mv	a0,s4
    80003a78:	9edff0ef          	jal	80003464 <iunlock>
      return ip;
    80003a7c:	bff9                	j	80003a5a <namex+0x58>
      iunlockput(ip);
    80003a7e:	8552                	mv	a0,s4
    80003a80:	b41ff0ef          	jal	800035c0 <iunlockput>
      return 0;
    80003a84:	8a4e                	mv	s4,s3
    80003a86:	bfd1                	j	80003a5a <namex+0x58>
  len = path - s;
    80003a88:	40998633          	sub	a2,s3,s1
    80003a8c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a90:	099c5063          	bge	s8,s9,80003b10 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003a94:	4639                	li	a2,14
    80003a96:	85a6                	mv	a1,s1
    80003a98:	8556                	mv	a0,s5
    80003a9a:	a64fd0ef          	jal	80000cfe <memmove>
    80003a9e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003aa0:	0004c783          	lbu	a5,0(s1)
    80003aa4:	01279763          	bne	a5,s2,80003ab2 <namex+0xb0>
    path++;
    80003aa8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003aaa:	0004c783          	lbu	a5,0(s1)
    80003aae:	ff278de3          	beq	a5,s2,80003aa8 <namex+0xa6>
    ilock(ip);
    80003ab2:	8552                	mv	a0,s4
    80003ab4:	903ff0ef          	jal	800033b6 <ilock>
    if(ip->type != T_DIR){
    80003ab8:	044a1783          	lh	a5,68(s4)
    80003abc:	f9779be3          	bne	a5,s7,80003a52 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003ac0:	000b0563          	beqz	s6,80003aca <namex+0xc8>
    80003ac4:	0004c783          	lbu	a5,0(s1)
    80003ac8:	d7dd                	beqz	a5,80003a76 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003aca:	4601                	li	a2,0
    80003acc:	85d6                	mv	a1,s5
    80003ace:	8552                	mv	a0,s4
    80003ad0:	e97ff0ef          	jal	80003966 <dirlookup>
    80003ad4:	89aa                	mv	s3,a0
    80003ad6:	d545                	beqz	a0,80003a7e <namex+0x7c>
    iunlockput(ip);
    80003ad8:	8552                	mv	a0,s4
    80003ada:	ae7ff0ef          	jal	800035c0 <iunlockput>
    ip = next;
    80003ade:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ae0:	0004c783          	lbu	a5,0(s1)
    80003ae4:	01279763          	bne	a5,s2,80003af2 <namex+0xf0>
    path++;
    80003ae8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003aea:	0004c783          	lbu	a5,0(s1)
    80003aee:	ff278de3          	beq	a5,s2,80003ae8 <namex+0xe6>
  if(*path == 0)
    80003af2:	cb8d                	beqz	a5,80003b24 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003af4:	0004c783          	lbu	a5,0(s1)
    80003af8:	89a6                	mv	s3,s1
  len = path - s;
    80003afa:	4c81                	li	s9,0
    80003afc:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003afe:	01278963          	beq	a5,s2,80003b10 <namex+0x10e>
    80003b02:	d3d9                	beqz	a5,80003a88 <namex+0x86>
    path++;
    80003b04:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003b06:	0009c783          	lbu	a5,0(s3)
    80003b0a:	ff279ce3          	bne	a5,s2,80003b02 <namex+0x100>
    80003b0e:	bfad                	j	80003a88 <namex+0x86>
    memmove(name, s, len);
    80003b10:	2601                	sext.w	a2,a2
    80003b12:	85a6                	mv	a1,s1
    80003b14:	8556                	mv	a0,s5
    80003b16:	9e8fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003b1a:	9cd6                	add	s9,s9,s5
    80003b1c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003b20:	84ce                	mv	s1,s3
    80003b22:	bfbd                	j	80003aa0 <namex+0x9e>
  if(nameiparent){
    80003b24:	f20b0be3          	beqz	s6,80003a5a <namex+0x58>
    iput(ip);
    80003b28:	8552                	mv	a0,s4
    80003b2a:	a0fff0ef          	jal	80003538 <iput>
    return 0;
    80003b2e:	4a01                	li	s4,0
    80003b30:	b72d                	j	80003a5a <namex+0x58>

0000000080003b32 <dirlink>:
{
    80003b32:	7139                	addi	sp,sp,-64
    80003b34:	fc06                	sd	ra,56(sp)
    80003b36:	f822                	sd	s0,48(sp)
    80003b38:	f04a                	sd	s2,32(sp)
    80003b3a:	ec4e                	sd	s3,24(sp)
    80003b3c:	e852                	sd	s4,16(sp)
    80003b3e:	0080                	addi	s0,sp,64
    80003b40:	892a                	mv	s2,a0
    80003b42:	8a2e                	mv	s4,a1
    80003b44:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b46:	4601                	li	a2,0
    80003b48:	e1fff0ef          	jal	80003966 <dirlookup>
    80003b4c:	e535                	bnez	a0,80003bb8 <dirlink+0x86>
    80003b4e:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b50:	04c92483          	lw	s1,76(s2)
    80003b54:	c48d                	beqz	s1,80003b7e <dirlink+0x4c>
    80003b56:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b58:	4741                	li	a4,16
    80003b5a:	86a6                	mv	a3,s1
    80003b5c:	fc040613          	addi	a2,s0,-64
    80003b60:	4581                	li	a1,0
    80003b62:	854a                	mv	a0,s2
    80003b64:	be3ff0ef          	jal	80003746 <readi>
    80003b68:	47c1                	li	a5,16
    80003b6a:	04f51b63          	bne	a0,a5,80003bc0 <dirlink+0x8e>
    if(de.inum == 0)
    80003b6e:	fc045783          	lhu	a5,-64(s0)
    80003b72:	c791                	beqz	a5,80003b7e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b74:	24c1                	addiw	s1,s1,16
    80003b76:	04c92783          	lw	a5,76(s2)
    80003b7a:	fcf4efe3          	bltu	s1,a5,80003b58 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b7e:	4639                	li	a2,14
    80003b80:	85d2                	mv	a1,s4
    80003b82:	fc240513          	addi	a0,s0,-62
    80003b86:	a1efd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003b8a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b8e:	4741                	li	a4,16
    80003b90:	86a6                	mv	a3,s1
    80003b92:	fc040613          	addi	a2,s0,-64
    80003b96:	4581                	li	a1,0
    80003b98:	854a                	mv	a0,s2
    80003b9a:	ca9ff0ef          	jal	80003842 <writei>
    80003b9e:	1541                	addi	a0,a0,-16
    80003ba0:	00a03533          	snez	a0,a0
    80003ba4:	40a00533          	neg	a0,a0
    80003ba8:	74a2                	ld	s1,40(sp)
}
    80003baa:	70e2                	ld	ra,56(sp)
    80003bac:	7442                	ld	s0,48(sp)
    80003bae:	7902                	ld	s2,32(sp)
    80003bb0:	69e2                	ld	s3,24(sp)
    80003bb2:	6a42                	ld	s4,16(sp)
    80003bb4:	6121                	addi	sp,sp,64
    80003bb6:	8082                	ret
    iput(ip);
    80003bb8:	981ff0ef          	jal	80003538 <iput>
    return -1;
    80003bbc:	557d                	li	a0,-1
    80003bbe:	b7f5                	j	80003baa <dirlink+0x78>
      panic("dirlink read");
    80003bc0:	00004517          	auipc	a0,0x4
    80003bc4:	90850513          	addi	a0,a0,-1784 # 800074c8 <etext+0x4c8>
    80003bc8:	c19fc0ef          	jal	800007e0 <panic>

0000000080003bcc <namei>:

struct inode*
namei(char *path)
{
    80003bcc:	1101                	addi	sp,sp,-32
    80003bce:	ec06                	sd	ra,24(sp)
    80003bd0:	e822                	sd	s0,16(sp)
    80003bd2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003bd4:	fe040613          	addi	a2,s0,-32
    80003bd8:	4581                	li	a1,0
    80003bda:	e29ff0ef          	jal	80003a02 <namex>
}
    80003bde:	60e2                	ld	ra,24(sp)
    80003be0:	6442                	ld	s0,16(sp)
    80003be2:	6105                	addi	sp,sp,32
    80003be4:	8082                	ret

0000000080003be6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003be6:	1141                	addi	sp,sp,-16
    80003be8:	e406                	sd	ra,8(sp)
    80003bea:	e022                	sd	s0,0(sp)
    80003bec:	0800                	addi	s0,sp,16
    80003bee:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003bf0:	4585                	li	a1,1
    80003bf2:	e11ff0ef          	jal	80003a02 <namex>
}
    80003bf6:	60a2                	ld	ra,8(sp)
    80003bf8:	6402                	ld	s0,0(sp)
    80003bfa:	0141                	addi	sp,sp,16
    80003bfc:	8082                	ret

0000000080003bfe <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003bfe:	1101                	addi	sp,sp,-32
    80003c00:	ec06                	sd	ra,24(sp)
    80003c02:	e822                	sd	s0,16(sp)
    80003c04:	e426                	sd	s1,8(sp)
    80003c06:	e04a                	sd	s2,0(sp)
    80003c08:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c0a:	0001c917          	auipc	s2,0x1c
    80003c0e:	d2e90913          	addi	s2,s2,-722 # 8001f938 <log>
    80003c12:	01892583          	lw	a1,24(s2)
    80003c16:	02492503          	lw	a0,36(s2)
    80003c1a:	8d0ff0ef          	jal	80002cea <bread>
    80003c1e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c20:	02892603          	lw	a2,40(s2)
    80003c24:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c26:	00c05f63          	blez	a2,80003c44 <write_head+0x46>
    80003c2a:	0001c717          	auipc	a4,0x1c
    80003c2e:	d3a70713          	addi	a4,a4,-710 # 8001f964 <log+0x2c>
    80003c32:	87aa                	mv	a5,a0
    80003c34:	060a                	slli	a2,a2,0x2
    80003c36:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c38:	4314                	lw	a3,0(a4)
    80003c3a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c3c:	0711                	addi	a4,a4,4
    80003c3e:	0791                	addi	a5,a5,4
    80003c40:	fec79ce3          	bne	a5,a2,80003c38 <write_head+0x3a>
  }
  bwrite(buf);
    80003c44:	8526                	mv	a0,s1
    80003c46:	97aff0ef          	jal	80002dc0 <bwrite>
  brelse(buf);
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	9a6ff0ef          	jal	80002df2 <brelse>
}
    80003c50:	60e2                	ld	ra,24(sp)
    80003c52:	6442                	ld	s0,16(sp)
    80003c54:	64a2                	ld	s1,8(sp)
    80003c56:	6902                	ld	s2,0(sp)
    80003c58:	6105                	addi	sp,sp,32
    80003c5a:	8082                	ret

0000000080003c5c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c5c:	0001c797          	auipc	a5,0x1c
    80003c60:	d047a783          	lw	a5,-764(a5) # 8001f960 <log+0x28>
    80003c64:	0af05e63          	blez	a5,80003d20 <install_trans+0xc4>
{
    80003c68:	715d                	addi	sp,sp,-80
    80003c6a:	e486                	sd	ra,72(sp)
    80003c6c:	e0a2                	sd	s0,64(sp)
    80003c6e:	fc26                	sd	s1,56(sp)
    80003c70:	f84a                	sd	s2,48(sp)
    80003c72:	f44e                	sd	s3,40(sp)
    80003c74:	f052                	sd	s4,32(sp)
    80003c76:	ec56                	sd	s5,24(sp)
    80003c78:	e85a                	sd	s6,16(sp)
    80003c7a:	e45e                	sd	s7,8(sp)
    80003c7c:	0880                	addi	s0,sp,80
    80003c7e:	8b2a                	mv	s6,a0
    80003c80:	0001ca97          	auipc	s5,0x1c
    80003c84:	ce4a8a93          	addi	s5,s5,-796 # 8001f964 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c88:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c8a:	00004b97          	auipc	s7,0x4
    80003c8e:	84eb8b93          	addi	s7,s7,-1970 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c92:	0001ca17          	auipc	s4,0x1c
    80003c96:	ca6a0a13          	addi	s4,s4,-858 # 8001f938 <log>
    80003c9a:	a025                	j	80003cc2 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003c9c:	000aa603          	lw	a2,0(s5)
    80003ca0:	85ce                	mv	a1,s3
    80003ca2:	855e                	mv	a0,s7
    80003ca4:	857fc0ef          	jal	800004fa <printf>
    80003ca8:	a839                	j	80003cc6 <install_trans+0x6a>
    brelse(lbuf);
    80003caa:	854a                	mv	a0,s2
    80003cac:	946ff0ef          	jal	80002df2 <brelse>
    brelse(dbuf);
    80003cb0:	8526                	mv	a0,s1
    80003cb2:	940ff0ef          	jal	80002df2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cb6:	2985                	addiw	s3,s3,1
    80003cb8:	0a91                	addi	s5,s5,4
    80003cba:	028a2783          	lw	a5,40(s4)
    80003cbe:	04f9d663          	bge	s3,a5,80003d0a <install_trans+0xae>
    if(recovering) {
    80003cc2:	fc0b1de3          	bnez	s6,80003c9c <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003cc6:	018a2583          	lw	a1,24(s4)
    80003cca:	013585bb          	addw	a1,a1,s3
    80003cce:	2585                	addiw	a1,a1,1
    80003cd0:	024a2503          	lw	a0,36(s4)
    80003cd4:	816ff0ef          	jal	80002cea <bread>
    80003cd8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003cda:	000aa583          	lw	a1,0(s5)
    80003cde:	024a2503          	lw	a0,36(s4)
    80003ce2:	808ff0ef          	jal	80002cea <bread>
    80003ce6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ce8:	40000613          	li	a2,1024
    80003cec:	05890593          	addi	a1,s2,88
    80003cf0:	05850513          	addi	a0,a0,88
    80003cf4:	80afd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cf8:	8526                	mv	a0,s1
    80003cfa:	8c6ff0ef          	jal	80002dc0 <bwrite>
    if(recovering == 0)
    80003cfe:	fa0b16e3          	bnez	s6,80003caa <install_trans+0x4e>
      bunpin(dbuf);
    80003d02:	8526                	mv	a0,s1
    80003d04:	9aaff0ef          	jal	80002eae <bunpin>
    80003d08:	b74d                	j	80003caa <install_trans+0x4e>
}
    80003d0a:	60a6                	ld	ra,72(sp)
    80003d0c:	6406                	ld	s0,64(sp)
    80003d0e:	74e2                	ld	s1,56(sp)
    80003d10:	7942                	ld	s2,48(sp)
    80003d12:	79a2                	ld	s3,40(sp)
    80003d14:	7a02                	ld	s4,32(sp)
    80003d16:	6ae2                	ld	s5,24(sp)
    80003d18:	6b42                	ld	s6,16(sp)
    80003d1a:	6ba2                	ld	s7,8(sp)
    80003d1c:	6161                	addi	sp,sp,80
    80003d1e:	8082                	ret
    80003d20:	8082                	ret

0000000080003d22 <initlog>:
{
    80003d22:	7179                	addi	sp,sp,-48
    80003d24:	f406                	sd	ra,40(sp)
    80003d26:	f022                	sd	s0,32(sp)
    80003d28:	ec26                	sd	s1,24(sp)
    80003d2a:	e84a                	sd	s2,16(sp)
    80003d2c:	e44e                	sd	s3,8(sp)
    80003d2e:	1800                	addi	s0,sp,48
    80003d30:	892a                	mv	s2,a0
    80003d32:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d34:	0001c497          	auipc	s1,0x1c
    80003d38:	c0448493          	addi	s1,s1,-1020 # 8001f938 <log>
    80003d3c:	00003597          	auipc	a1,0x3
    80003d40:	7bc58593          	addi	a1,a1,1980 # 800074f8 <etext+0x4f8>
    80003d44:	8526                	mv	a0,s1
    80003d46:	e09fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003d4a:	0149a583          	lw	a1,20(s3)
    80003d4e:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003d50:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003d54:	854a                	mv	a0,s2
    80003d56:	f95fe0ef          	jal	80002cea <bread>
  log.lh.n = lh->n;
    80003d5a:	4d30                	lw	a2,88(a0)
    80003d5c:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003d5e:	00c05f63          	blez	a2,80003d7c <initlog+0x5a>
    80003d62:	87aa                	mv	a5,a0
    80003d64:	0001c717          	auipc	a4,0x1c
    80003d68:	c0070713          	addi	a4,a4,-1024 # 8001f964 <log+0x2c>
    80003d6c:	060a                	slli	a2,a2,0x2
    80003d6e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003d70:	4ff4                	lw	a3,92(a5)
    80003d72:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003d74:	0791                	addi	a5,a5,4
    80003d76:	0711                	addi	a4,a4,4
    80003d78:	fec79ce3          	bne	a5,a2,80003d70 <initlog+0x4e>
  brelse(buf);
    80003d7c:	876ff0ef          	jal	80002df2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d80:	4505                	li	a0,1
    80003d82:	edbff0ef          	jal	80003c5c <install_trans>
  log.lh.n = 0;
    80003d86:	0001c797          	auipc	a5,0x1c
    80003d8a:	bc07ad23          	sw	zero,-1062(a5) # 8001f960 <log+0x28>
  write_head(); // clear the log
    80003d8e:	e71ff0ef          	jal	80003bfe <write_head>
}
    80003d92:	70a2                	ld	ra,40(sp)
    80003d94:	7402                	ld	s0,32(sp)
    80003d96:	64e2                	ld	s1,24(sp)
    80003d98:	6942                	ld	s2,16(sp)
    80003d9a:	69a2                	ld	s3,8(sp)
    80003d9c:	6145                	addi	sp,sp,48
    80003d9e:	8082                	ret

0000000080003da0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003da0:	1101                	addi	sp,sp,-32
    80003da2:	ec06                	sd	ra,24(sp)
    80003da4:	e822                	sd	s0,16(sp)
    80003da6:	e426                	sd	s1,8(sp)
    80003da8:	e04a                	sd	s2,0(sp)
    80003daa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dac:	0001c517          	auipc	a0,0x1c
    80003db0:	b8c50513          	addi	a0,a0,-1140 # 8001f938 <log>
    80003db4:	e1bfc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003db8:	0001c497          	auipc	s1,0x1c
    80003dbc:	b8048493          	addi	s1,s1,-1152 # 8001f938 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dc0:	4979                	li	s2,30
    80003dc2:	a029                	j	80003dcc <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003dc4:	85a6                	mv	a1,s1
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	9ecfe0ef          	jal	80001fb4 <sleep>
    if(log.committing){
    80003dcc:	509c                	lw	a5,32(s1)
    80003dce:	fbfd                	bnez	a5,80003dc4 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003dd0:	4cd8                	lw	a4,28(s1)
    80003dd2:	2705                	addiw	a4,a4,1
    80003dd4:	0027179b          	slliw	a5,a4,0x2
    80003dd8:	9fb9                	addw	a5,a5,a4
    80003dda:	0017979b          	slliw	a5,a5,0x1
    80003dde:	5494                	lw	a3,40(s1)
    80003de0:	9fb5                	addw	a5,a5,a3
    80003de2:	00f95763          	bge	s2,a5,80003df0 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003de6:	85a6                	mv	a1,s1
    80003de8:	8526                	mv	a0,s1
    80003dea:	9cafe0ef          	jal	80001fb4 <sleep>
    80003dee:	bff9                	j	80003dcc <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003df0:	0001c517          	auipc	a0,0x1c
    80003df4:	b4850513          	addi	a0,a0,-1208 # 8001f938 <log>
    80003df8:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003dfa:	e6dfc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003dfe:	60e2                	ld	ra,24(sp)
    80003e00:	6442                	ld	s0,16(sp)
    80003e02:	64a2                	ld	s1,8(sp)
    80003e04:	6902                	ld	s2,0(sp)
    80003e06:	6105                	addi	sp,sp,32
    80003e08:	8082                	ret

0000000080003e0a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e0a:	7139                	addi	sp,sp,-64
    80003e0c:	fc06                	sd	ra,56(sp)
    80003e0e:	f822                	sd	s0,48(sp)
    80003e10:	f426                	sd	s1,40(sp)
    80003e12:	f04a                	sd	s2,32(sp)
    80003e14:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e16:	0001c497          	auipc	s1,0x1c
    80003e1a:	b2248493          	addi	s1,s1,-1246 # 8001f938 <log>
    80003e1e:	8526                	mv	a0,s1
    80003e20:	daffc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003e24:	4cdc                	lw	a5,28(s1)
    80003e26:	37fd                	addiw	a5,a5,-1
    80003e28:	0007891b          	sext.w	s2,a5
    80003e2c:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e2e:	509c                	lw	a5,32(s1)
    80003e30:	ef9d                	bnez	a5,80003e6e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e32:	04091763          	bnez	s2,80003e80 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003e36:	0001c497          	auipc	s1,0x1c
    80003e3a:	b0248493          	addi	s1,s1,-1278 # 8001f938 <log>
    80003e3e:	4785                	li	a5,1
    80003e40:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003e42:	8526                	mv	a0,s1
    80003e44:	e23fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003e48:	549c                	lw	a5,40(s1)
    80003e4a:	04f04b63          	bgtz	a5,80003ea0 <end_op+0x96>
    acquire(&log.lock);
    80003e4e:	0001c497          	auipc	s1,0x1c
    80003e52:	aea48493          	addi	s1,s1,-1302 # 8001f938 <log>
    80003e56:	8526                	mv	a0,s1
    80003e58:	d77fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003e5c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003e60:	8526                	mv	a0,s1
    80003e62:	99efe0ef          	jal	80002000 <wakeup>
    release(&log.lock);
    80003e66:	8526                	mv	a0,s1
    80003e68:	dfffc0ef          	jal	80000c66 <release>
}
    80003e6c:	a025                	j	80003e94 <end_op+0x8a>
    80003e6e:	ec4e                	sd	s3,24(sp)
    80003e70:	e852                	sd	s4,16(sp)
    80003e72:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003e74:	00003517          	auipc	a0,0x3
    80003e78:	68c50513          	addi	a0,a0,1676 # 80007500 <etext+0x500>
    80003e7c:	965fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003e80:	0001c497          	auipc	s1,0x1c
    80003e84:	ab848493          	addi	s1,s1,-1352 # 8001f938 <log>
    80003e88:	8526                	mv	a0,s1
    80003e8a:	976fe0ef          	jal	80002000 <wakeup>
  release(&log.lock);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	dd7fc0ef          	jal	80000c66 <release>
}
    80003e94:	70e2                	ld	ra,56(sp)
    80003e96:	7442                	ld	s0,48(sp)
    80003e98:	74a2                	ld	s1,40(sp)
    80003e9a:	7902                	ld	s2,32(sp)
    80003e9c:	6121                	addi	sp,sp,64
    80003e9e:	8082                	ret
    80003ea0:	ec4e                	sd	s3,24(sp)
    80003ea2:	e852                	sd	s4,16(sp)
    80003ea4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea6:	0001ca97          	auipc	s5,0x1c
    80003eaa:	abea8a93          	addi	s5,s5,-1346 # 8001f964 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003eae:	0001ca17          	auipc	s4,0x1c
    80003eb2:	a8aa0a13          	addi	s4,s4,-1398 # 8001f938 <log>
    80003eb6:	018a2583          	lw	a1,24(s4)
    80003eba:	012585bb          	addw	a1,a1,s2
    80003ebe:	2585                	addiw	a1,a1,1
    80003ec0:	024a2503          	lw	a0,36(s4)
    80003ec4:	e27fe0ef          	jal	80002cea <bread>
    80003ec8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003eca:	000aa583          	lw	a1,0(s5)
    80003ece:	024a2503          	lw	a0,36(s4)
    80003ed2:	e19fe0ef          	jal	80002cea <bread>
    80003ed6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003ed8:	40000613          	li	a2,1024
    80003edc:	05850593          	addi	a1,a0,88
    80003ee0:	05848513          	addi	a0,s1,88
    80003ee4:	e1bfc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003ee8:	8526                	mv	a0,s1
    80003eea:	ed7fe0ef          	jal	80002dc0 <bwrite>
    brelse(from);
    80003eee:	854e                	mv	a0,s3
    80003ef0:	f03fe0ef          	jal	80002df2 <brelse>
    brelse(to);
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	efdfe0ef          	jal	80002df2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efa:	2905                	addiw	s2,s2,1
    80003efc:	0a91                	addi	s5,s5,4
    80003efe:	028a2783          	lw	a5,40(s4)
    80003f02:	faf94ae3          	blt	s2,a5,80003eb6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f06:	cf9ff0ef          	jal	80003bfe <write_head>
    install_trans(0); // Now install writes to home locations
    80003f0a:	4501                	li	a0,0
    80003f0c:	d51ff0ef          	jal	80003c5c <install_trans>
    log.lh.n = 0;
    80003f10:	0001c797          	auipc	a5,0x1c
    80003f14:	a407a823          	sw	zero,-1456(a5) # 8001f960 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f18:	ce7ff0ef          	jal	80003bfe <write_head>
    80003f1c:	69e2                	ld	s3,24(sp)
    80003f1e:	6a42                	ld	s4,16(sp)
    80003f20:	6aa2                	ld	s5,8(sp)
    80003f22:	b735                	j	80003e4e <end_op+0x44>

0000000080003f24 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f24:	1101                	addi	sp,sp,-32
    80003f26:	ec06                	sd	ra,24(sp)
    80003f28:	e822                	sd	s0,16(sp)
    80003f2a:	e426                	sd	s1,8(sp)
    80003f2c:	e04a                	sd	s2,0(sp)
    80003f2e:	1000                	addi	s0,sp,32
    80003f30:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003f32:	0001c917          	auipc	s2,0x1c
    80003f36:	a0690913          	addi	s2,s2,-1530 # 8001f938 <log>
    80003f3a:	854a                	mv	a0,s2
    80003f3c:	c93fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003f40:	02892603          	lw	a2,40(s2)
    80003f44:	47f5                	li	a5,29
    80003f46:	04c7cc63          	blt	a5,a2,80003f9e <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003f4a:	0001c797          	auipc	a5,0x1c
    80003f4e:	a0a7a783          	lw	a5,-1526(a5) # 8001f954 <log+0x1c>
    80003f52:	04f05c63          	blez	a5,80003faa <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003f56:	4781                	li	a5,0
    80003f58:	04c05f63          	blez	a2,80003fb6 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f5c:	44cc                	lw	a1,12(s1)
    80003f5e:	0001c717          	auipc	a4,0x1c
    80003f62:	a0670713          	addi	a4,a4,-1530 # 8001f964 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003f66:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003f68:	4314                	lw	a3,0(a4)
    80003f6a:	04b68663          	beq	a3,a1,80003fb6 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003f6e:	2785                	addiw	a5,a5,1
    80003f70:	0711                	addi	a4,a4,4
    80003f72:	fef61be3          	bne	a2,a5,80003f68 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f76:	0621                	addi	a2,a2,8
    80003f78:	060a                	slli	a2,a2,0x2
    80003f7a:	0001c797          	auipc	a5,0x1c
    80003f7e:	9be78793          	addi	a5,a5,-1602 # 8001f938 <log>
    80003f82:	97b2                	add	a5,a5,a2
    80003f84:	44d8                	lw	a4,12(s1)
    80003f86:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	ef1fe0ef          	jal	80002e7a <bpin>
    log.lh.n++;
    80003f8e:	0001c717          	auipc	a4,0x1c
    80003f92:	9aa70713          	addi	a4,a4,-1622 # 8001f938 <log>
    80003f96:	571c                	lw	a5,40(a4)
    80003f98:	2785                	addiw	a5,a5,1
    80003f9a:	d71c                	sw	a5,40(a4)
    80003f9c:	a80d                	j	80003fce <log_write+0xaa>
    panic("too big a transaction");
    80003f9e:	00003517          	auipc	a0,0x3
    80003fa2:	57250513          	addi	a0,a0,1394 # 80007510 <etext+0x510>
    80003fa6:	83bfc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003faa:	00003517          	auipc	a0,0x3
    80003fae:	57e50513          	addi	a0,a0,1406 # 80007528 <etext+0x528>
    80003fb2:	82ffc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003fb6:	00878693          	addi	a3,a5,8
    80003fba:	068a                	slli	a3,a3,0x2
    80003fbc:	0001c717          	auipc	a4,0x1c
    80003fc0:	97c70713          	addi	a4,a4,-1668 # 8001f938 <log>
    80003fc4:	9736                	add	a4,a4,a3
    80003fc6:	44d4                	lw	a3,12(s1)
    80003fc8:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003fca:	faf60fe3          	beq	a2,a5,80003f88 <log_write+0x64>
  }
  release(&log.lock);
    80003fce:	0001c517          	auipc	a0,0x1c
    80003fd2:	96a50513          	addi	a0,a0,-1686 # 8001f938 <log>
    80003fd6:	c91fc0ef          	jal	80000c66 <release>
}
    80003fda:	60e2                	ld	ra,24(sp)
    80003fdc:	6442                	ld	s0,16(sp)
    80003fde:	64a2                	ld	s1,8(sp)
    80003fe0:	6902                	ld	s2,0(sp)
    80003fe2:	6105                	addi	sp,sp,32
    80003fe4:	8082                	ret

0000000080003fe6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003fe6:	1101                	addi	sp,sp,-32
    80003fe8:	ec06                	sd	ra,24(sp)
    80003fea:	e822                	sd	s0,16(sp)
    80003fec:	e426                	sd	s1,8(sp)
    80003fee:	e04a                	sd	s2,0(sp)
    80003ff0:	1000                	addi	s0,sp,32
    80003ff2:	84aa                	mv	s1,a0
    80003ff4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ff6:	00003597          	auipc	a1,0x3
    80003ffa:	55258593          	addi	a1,a1,1362 # 80007548 <etext+0x548>
    80003ffe:	0521                	addi	a0,a0,8
    80004000:	b4ffc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004004:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004008:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000400c:	0204a423          	sw	zero,40(s1)
}
    80004010:	60e2                	ld	ra,24(sp)
    80004012:	6442                	ld	s0,16(sp)
    80004014:	64a2                	ld	s1,8(sp)
    80004016:	6902                	ld	s2,0(sp)
    80004018:	6105                	addi	sp,sp,32
    8000401a:	8082                	ret

000000008000401c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000401c:	1101                	addi	sp,sp,-32
    8000401e:	ec06                	sd	ra,24(sp)
    80004020:	e822                	sd	s0,16(sp)
    80004022:	e426                	sd	s1,8(sp)
    80004024:	e04a                	sd	s2,0(sp)
    80004026:	1000                	addi	s0,sp,32
    80004028:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000402a:	00850913          	addi	s2,a0,8
    8000402e:	854a                	mv	a0,s2
    80004030:	b9ffc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004034:	409c                	lw	a5,0(s1)
    80004036:	c799                	beqz	a5,80004044 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004038:	85ca                	mv	a1,s2
    8000403a:	8526                	mv	a0,s1
    8000403c:	f79fd0ef          	jal	80001fb4 <sleep>
  while (lk->locked) {
    80004040:	409c                	lw	a5,0(s1)
    80004042:	fbfd                	bnez	a5,80004038 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004044:	4785                	li	a5,1
    80004046:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004048:	963fd0ef          	jal	800019aa <myproc>
    8000404c:	591c                	lw	a5,48(a0)
    8000404e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004050:	854a                	mv	a0,s2
    80004052:	c15fc0ef          	jal	80000c66 <release>
}
    80004056:	60e2                	ld	ra,24(sp)
    80004058:	6442                	ld	s0,16(sp)
    8000405a:	64a2                	ld	s1,8(sp)
    8000405c:	6902                	ld	s2,0(sp)
    8000405e:	6105                	addi	sp,sp,32
    80004060:	8082                	ret

0000000080004062 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004062:	1101                	addi	sp,sp,-32
    80004064:	ec06                	sd	ra,24(sp)
    80004066:	e822                	sd	s0,16(sp)
    80004068:	e426                	sd	s1,8(sp)
    8000406a:	e04a                	sd	s2,0(sp)
    8000406c:	1000                	addi	s0,sp,32
    8000406e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004070:	00850913          	addi	s2,a0,8
    80004074:	854a                	mv	a0,s2
    80004076:	b59fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    8000407a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000407e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004082:	8526                	mv	a0,s1
    80004084:	f7dfd0ef          	jal	80002000 <wakeup>
  release(&lk->lk);
    80004088:	854a                	mv	a0,s2
    8000408a:	bddfc0ef          	jal	80000c66 <release>
}
    8000408e:	60e2                	ld	ra,24(sp)
    80004090:	6442                	ld	s0,16(sp)
    80004092:	64a2                	ld	s1,8(sp)
    80004094:	6902                	ld	s2,0(sp)
    80004096:	6105                	addi	sp,sp,32
    80004098:	8082                	ret

000000008000409a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000409a:	7179                	addi	sp,sp,-48
    8000409c:	f406                	sd	ra,40(sp)
    8000409e:	f022                	sd	s0,32(sp)
    800040a0:	ec26                	sd	s1,24(sp)
    800040a2:	e84a                	sd	s2,16(sp)
    800040a4:	1800                	addi	s0,sp,48
    800040a6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800040a8:	00850913          	addi	s2,a0,8
    800040ac:	854a                	mv	a0,s2
    800040ae:	b21fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800040b2:	409c                	lw	a5,0(s1)
    800040b4:	ef81                	bnez	a5,800040cc <holdingsleep+0x32>
    800040b6:	4481                	li	s1,0
  release(&lk->lk);
    800040b8:	854a                	mv	a0,s2
    800040ba:	badfc0ef          	jal	80000c66 <release>
  return r;
}
    800040be:	8526                	mv	a0,s1
    800040c0:	70a2                	ld	ra,40(sp)
    800040c2:	7402                	ld	s0,32(sp)
    800040c4:	64e2                	ld	s1,24(sp)
    800040c6:	6942                	ld	s2,16(sp)
    800040c8:	6145                	addi	sp,sp,48
    800040ca:	8082                	ret
    800040cc:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800040ce:	0284a983          	lw	s3,40(s1)
    800040d2:	8d9fd0ef          	jal	800019aa <myproc>
    800040d6:	5904                	lw	s1,48(a0)
    800040d8:	413484b3          	sub	s1,s1,s3
    800040dc:	0014b493          	seqz	s1,s1
    800040e0:	69a2                	ld	s3,8(sp)
    800040e2:	bfd9                	j	800040b8 <holdingsleep+0x1e>

00000000800040e4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800040e4:	1141                	addi	sp,sp,-16
    800040e6:	e406                	sd	ra,8(sp)
    800040e8:	e022                	sd	s0,0(sp)
    800040ea:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800040ec:	00003597          	auipc	a1,0x3
    800040f0:	46c58593          	addi	a1,a1,1132 # 80007558 <etext+0x558>
    800040f4:	0001c517          	auipc	a0,0x1c
    800040f8:	98c50513          	addi	a0,a0,-1652 # 8001fa80 <ftable>
    800040fc:	a53fc0ef          	jal	80000b4e <initlock>
}
    80004100:	60a2                	ld	ra,8(sp)
    80004102:	6402                	ld	s0,0(sp)
    80004104:	0141                	addi	sp,sp,16
    80004106:	8082                	ret

0000000080004108 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004112:	0001c517          	auipc	a0,0x1c
    80004116:	96e50513          	addi	a0,a0,-1682 # 8001fa80 <ftable>
    8000411a:	ab5fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000411e:	0001c497          	auipc	s1,0x1c
    80004122:	97a48493          	addi	s1,s1,-1670 # 8001fa98 <ftable+0x18>
    80004126:	0001d717          	auipc	a4,0x1d
    8000412a:	91270713          	addi	a4,a4,-1774 # 80020a38 <disk>
    if(f->ref == 0){
    8000412e:	40dc                	lw	a5,4(s1)
    80004130:	cf89                	beqz	a5,8000414a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004132:	02848493          	addi	s1,s1,40
    80004136:	fee49ce3          	bne	s1,a4,8000412e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000413a:	0001c517          	auipc	a0,0x1c
    8000413e:	94650513          	addi	a0,a0,-1722 # 8001fa80 <ftable>
    80004142:	b25fc0ef          	jal	80000c66 <release>
  return 0;
    80004146:	4481                	li	s1,0
    80004148:	a809                	j	8000415a <filealloc+0x52>
      f->ref = 1;
    8000414a:	4785                	li	a5,1
    8000414c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000414e:	0001c517          	auipc	a0,0x1c
    80004152:	93250513          	addi	a0,a0,-1742 # 8001fa80 <ftable>
    80004156:	b11fc0ef          	jal	80000c66 <release>
}
    8000415a:	8526                	mv	a0,s1
    8000415c:	60e2                	ld	ra,24(sp)
    8000415e:	6442                	ld	s0,16(sp)
    80004160:	64a2                	ld	s1,8(sp)
    80004162:	6105                	addi	sp,sp,32
    80004164:	8082                	ret

0000000080004166 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004166:	1101                	addi	sp,sp,-32
    80004168:	ec06                	sd	ra,24(sp)
    8000416a:	e822                	sd	s0,16(sp)
    8000416c:	e426                	sd	s1,8(sp)
    8000416e:	1000                	addi	s0,sp,32
    80004170:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004172:	0001c517          	auipc	a0,0x1c
    80004176:	90e50513          	addi	a0,a0,-1778 # 8001fa80 <ftable>
    8000417a:	a55fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000417e:	40dc                	lw	a5,4(s1)
    80004180:	02f05063          	blez	a5,800041a0 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004184:	2785                	addiw	a5,a5,1
    80004186:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004188:	0001c517          	auipc	a0,0x1c
    8000418c:	8f850513          	addi	a0,a0,-1800 # 8001fa80 <ftable>
    80004190:	ad7fc0ef          	jal	80000c66 <release>
  return f;
}
    80004194:	8526                	mv	a0,s1
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	64a2                	ld	s1,8(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret
    panic("filedup");
    800041a0:	00003517          	auipc	a0,0x3
    800041a4:	3c050513          	addi	a0,a0,960 # 80007560 <etext+0x560>
    800041a8:	e38fc0ef          	jal	800007e0 <panic>

00000000800041ac <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800041ac:	7139                	addi	sp,sp,-64
    800041ae:	fc06                	sd	ra,56(sp)
    800041b0:	f822                	sd	s0,48(sp)
    800041b2:	f426                	sd	s1,40(sp)
    800041b4:	0080                	addi	s0,sp,64
    800041b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800041b8:	0001c517          	auipc	a0,0x1c
    800041bc:	8c850513          	addi	a0,a0,-1848 # 8001fa80 <ftable>
    800041c0:	a0ffc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800041c4:	40dc                	lw	a5,4(s1)
    800041c6:	04f05a63          	blez	a5,8000421a <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800041ca:	37fd                	addiw	a5,a5,-1
    800041cc:	0007871b          	sext.w	a4,a5
    800041d0:	c0dc                	sw	a5,4(s1)
    800041d2:	04e04e63          	bgtz	a4,8000422e <fileclose+0x82>
    800041d6:	f04a                	sd	s2,32(sp)
    800041d8:	ec4e                	sd	s3,24(sp)
    800041da:	e852                	sd	s4,16(sp)
    800041dc:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800041de:	0004a903          	lw	s2,0(s1)
    800041e2:	0094ca83          	lbu	s5,9(s1)
    800041e6:	0104ba03          	ld	s4,16(s1)
    800041ea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800041ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800041f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800041f6:	0001c517          	auipc	a0,0x1c
    800041fa:	88a50513          	addi	a0,a0,-1910 # 8001fa80 <ftable>
    800041fe:	a69fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004202:	4785                	li	a5,1
    80004204:	04f90063          	beq	s2,a5,80004244 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004208:	3979                	addiw	s2,s2,-2
    8000420a:	4785                	li	a5,1
    8000420c:	0527f563          	bgeu	a5,s2,80004256 <fileclose+0xaa>
    80004210:	7902                	ld	s2,32(sp)
    80004212:	69e2                	ld	s3,24(sp)
    80004214:	6a42                	ld	s4,16(sp)
    80004216:	6aa2                	ld	s5,8(sp)
    80004218:	a00d                	j	8000423a <fileclose+0x8e>
    8000421a:	f04a                	sd	s2,32(sp)
    8000421c:	ec4e                	sd	s3,24(sp)
    8000421e:	e852                	sd	s4,16(sp)
    80004220:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004222:	00003517          	auipc	a0,0x3
    80004226:	34650513          	addi	a0,a0,838 # 80007568 <etext+0x568>
    8000422a:	db6fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000422e:	0001c517          	auipc	a0,0x1c
    80004232:	85250513          	addi	a0,a0,-1966 # 8001fa80 <ftable>
    80004236:	a31fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000423a:	70e2                	ld	ra,56(sp)
    8000423c:	7442                	ld	s0,48(sp)
    8000423e:	74a2                	ld	s1,40(sp)
    80004240:	6121                	addi	sp,sp,64
    80004242:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004244:	85d6                	mv	a1,s5
    80004246:	8552                	mv	a0,s4
    80004248:	336000ef          	jal	8000457e <pipeclose>
    8000424c:	7902                	ld	s2,32(sp)
    8000424e:	69e2                	ld	s3,24(sp)
    80004250:	6a42                	ld	s4,16(sp)
    80004252:	6aa2                	ld	s5,8(sp)
    80004254:	b7dd                	j	8000423a <fileclose+0x8e>
    begin_op();
    80004256:	b4bff0ef          	jal	80003da0 <begin_op>
    iput(ff.ip);
    8000425a:	854e                	mv	a0,s3
    8000425c:	adcff0ef          	jal	80003538 <iput>
    end_op();
    80004260:	babff0ef          	jal	80003e0a <end_op>
    80004264:	7902                	ld	s2,32(sp)
    80004266:	69e2                	ld	s3,24(sp)
    80004268:	6a42                	ld	s4,16(sp)
    8000426a:	6aa2                	ld	s5,8(sp)
    8000426c:	b7f9                	j	8000423a <fileclose+0x8e>

000000008000426e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000426e:	715d                	addi	sp,sp,-80
    80004270:	e486                	sd	ra,72(sp)
    80004272:	e0a2                	sd	s0,64(sp)
    80004274:	fc26                	sd	s1,56(sp)
    80004276:	f44e                	sd	s3,40(sp)
    80004278:	0880                	addi	s0,sp,80
    8000427a:	84aa                	mv	s1,a0
    8000427c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000427e:	f2cfd0ef          	jal	800019aa <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004282:	409c                	lw	a5,0(s1)
    80004284:	37f9                	addiw	a5,a5,-2
    80004286:	4705                	li	a4,1
    80004288:	04f76063          	bltu	a4,a5,800042c8 <filestat+0x5a>
    8000428c:	f84a                	sd	s2,48(sp)
    8000428e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004290:	6c88                	ld	a0,24(s1)
    80004292:	924ff0ef          	jal	800033b6 <ilock>
    stati(f->ip, &st);
    80004296:	fb840593          	addi	a1,s0,-72
    8000429a:	6c88                	ld	a0,24(s1)
    8000429c:	c80ff0ef          	jal	8000371c <stati>
    iunlock(f->ip);
    800042a0:	6c88                	ld	a0,24(s1)
    800042a2:	9c2ff0ef          	jal	80003464 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800042a6:	46e1                	li	a3,24
    800042a8:	fb840613          	addi	a2,s0,-72
    800042ac:	85ce                	mv	a1,s3
    800042ae:	05093503          	ld	a0,80(s2)
    800042b2:	b30fd0ef          	jal	800015e2 <copyout>
    800042b6:	41f5551b          	sraiw	a0,a0,0x1f
    800042ba:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800042bc:	60a6                	ld	ra,72(sp)
    800042be:	6406                	ld	s0,64(sp)
    800042c0:	74e2                	ld	s1,56(sp)
    800042c2:	79a2                	ld	s3,40(sp)
    800042c4:	6161                	addi	sp,sp,80
    800042c6:	8082                	ret
  return -1;
    800042c8:	557d                	li	a0,-1
    800042ca:	bfcd                	j	800042bc <filestat+0x4e>

00000000800042cc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800042cc:	7179                	addi	sp,sp,-48
    800042ce:	f406                	sd	ra,40(sp)
    800042d0:	f022                	sd	s0,32(sp)
    800042d2:	e84a                	sd	s2,16(sp)
    800042d4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800042d6:	00854783          	lbu	a5,8(a0)
    800042da:	cfd1                	beqz	a5,80004376 <fileread+0xaa>
    800042dc:	ec26                	sd	s1,24(sp)
    800042de:	e44e                	sd	s3,8(sp)
    800042e0:	84aa                	mv	s1,a0
    800042e2:	89ae                	mv	s3,a1
    800042e4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800042e6:	411c                	lw	a5,0(a0)
    800042e8:	4705                	li	a4,1
    800042ea:	04e78363          	beq	a5,a4,80004330 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042ee:	470d                	li	a4,3
    800042f0:	04e78763          	beq	a5,a4,8000433e <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800042f4:	4709                	li	a4,2
    800042f6:	06e79a63          	bne	a5,a4,8000436a <fileread+0x9e>
    ilock(f->ip);
    800042fa:	6d08                	ld	a0,24(a0)
    800042fc:	8baff0ef          	jal	800033b6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004300:	874a                	mv	a4,s2
    80004302:	5094                	lw	a3,32(s1)
    80004304:	864e                	mv	a2,s3
    80004306:	4585                	li	a1,1
    80004308:	6c88                	ld	a0,24(s1)
    8000430a:	c3cff0ef          	jal	80003746 <readi>
    8000430e:	892a                	mv	s2,a0
    80004310:	00a05563          	blez	a0,8000431a <fileread+0x4e>
      f->off += r;
    80004314:	509c                	lw	a5,32(s1)
    80004316:	9fa9                	addw	a5,a5,a0
    80004318:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000431a:	6c88                	ld	a0,24(s1)
    8000431c:	948ff0ef          	jal	80003464 <iunlock>
    80004320:	64e2                	ld	s1,24(sp)
    80004322:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004324:	854a                	mv	a0,s2
    80004326:	70a2                	ld	ra,40(sp)
    80004328:	7402                	ld	s0,32(sp)
    8000432a:	6942                	ld	s2,16(sp)
    8000432c:	6145                	addi	sp,sp,48
    8000432e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004330:	6908                	ld	a0,16(a0)
    80004332:	388000ef          	jal	800046ba <piperead>
    80004336:	892a                	mv	s2,a0
    80004338:	64e2                	ld	s1,24(sp)
    8000433a:	69a2                	ld	s3,8(sp)
    8000433c:	b7e5                	j	80004324 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000433e:	02451783          	lh	a5,36(a0)
    80004342:	03079693          	slli	a3,a5,0x30
    80004346:	92c1                	srli	a3,a3,0x30
    80004348:	4725                	li	a4,9
    8000434a:	02d76863          	bltu	a4,a3,8000437a <fileread+0xae>
    8000434e:	0792                	slli	a5,a5,0x4
    80004350:	0001b717          	auipc	a4,0x1b
    80004354:	69070713          	addi	a4,a4,1680 # 8001f9e0 <devsw>
    80004358:	97ba                	add	a5,a5,a4
    8000435a:	639c                	ld	a5,0(a5)
    8000435c:	c39d                	beqz	a5,80004382 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000435e:	4505                	li	a0,1
    80004360:	9782                	jalr	a5
    80004362:	892a                	mv	s2,a0
    80004364:	64e2                	ld	s1,24(sp)
    80004366:	69a2                	ld	s3,8(sp)
    80004368:	bf75                	j	80004324 <fileread+0x58>
    panic("fileread");
    8000436a:	00003517          	auipc	a0,0x3
    8000436e:	20e50513          	addi	a0,a0,526 # 80007578 <etext+0x578>
    80004372:	c6efc0ef          	jal	800007e0 <panic>
    return -1;
    80004376:	597d                	li	s2,-1
    80004378:	b775                	j	80004324 <fileread+0x58>
      return -1;
    8000437a:	597d                	li	s2,-1
    8000437c:	64e2                	ld	s1,24(sp)
    8000437e:	69a2                	ld	s3,8(sp)
    80004380:	b755                	j	80004324 <fileread+0x58>
    80004382:	597d                	li	s2,-1
    80004384:	64e2                	ld	s1,24(sp)
    80004386:	69a2                	ld	s3,8(sp)
    80004388:	bf71                	j	80004324 <fileread+0x58>

000000008000438a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000438a:	00954783          	lbu	a5,9(a0)
    8000438e:	10078b63          	beqz	a5,800044a4 <filewrite+0x11a>
{
    80004392:	715d                	addi	sp,sp,-80
    80004394:	e486                	sd	ra,72(sp)
    80004396:	e0a2                	sd	s0,64(sp)
    80004398:	f84a                	sd	s2,48(sp)
    8000439a:	f052                	sd	s4,32(sp)
    8000439c:	e85a                	sd	s6,16(sp)
    8000439e:	0880                	addi	s0,sp,80
    800043a0:	892a                	mv	s2,a0
    800043a2:	8b2e                	mv	s6,a1
    800043a4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800043a6:	411c                	lw	a5,0(a0)
    800043a8:	4705                	li	a4,1
    800043aa:	02e78763          	beq	a5,a4,800043d8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043ae:	470d                	li	a4,3
    800043b0:	02e78863          	beq	a5,a4,800043e0 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800043b4:	4709                	li	a4,2
    800043b6:	0ce79c63          	bne	a5,a4,8000448e <filewrite+0x104>
    800043ba:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800043bc:	0ac05863          	blez	a2,8000446c <filewrite+0xe2>
    800043c0:	fc26                	sd	s1,56(sp)
    800043c2:	ec56                	sd	s5,24(sp)
    800043c4:	e45e                	sd	s7,8(sp)
    800043c6:	e062                	sd	s8,0(sp)
    int i = 0;
    800043c8:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800043ca:	6b85                	lui	s7,0x1
    800043cc:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800043d0:	6c05                	lui	s8,0x1
    800043d2:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800043d6:	a8b5                	j	80004452 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800043d8:	6908                	ld	a0,16(a0)
    800043da:	1fc000ef          	jal	800045d6 <pipewrite>
    800043de:	a04d                	j	80004480 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800043e0:	02451783          	lh	a5,36(a0)
    800043e4:	03079693          	slli	a3,a5,0x30
    800043e8:	92c1                	srli	a3,a3,0x30
    800043ea:	4725                	li	a4,9
    800043ec:	0ad76e63          	bltu	a4,a3,800044a8 <filewrite+0x11e>
    800043f0:	0792                	slli	a5,a5,0x4
    800043f2:	0001b717          	auipc	a4,0x1b
    800043f6:	5ee70713          	addi	a4,a4,1518 # 8001f9e0 <devsw>
    800043fa:	97ba                	add	a5,a5,a4
    800043fc:	679c                	ld	a5,8(a5)
    800043fe:	c7dd                	beqz	a5,800044ac <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004400:	4505                	li	a0,1
    80004402:	9782                	jalr	a5
    80004404:	a8b5                	j	80004480 <filewrite+0xf6>
      if(n1 > max)
    80004406:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000440a:	997ff0ef          	jal	80003da0 <begin_op>
      ilock(f->ip);
    8000440e:	01893503          	ld	a0,24(s2)
    80004412:	fa5fe0ef          	jal	800033b6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004416:	8756                	mv	a4,s5
    80004418:	02092683          	lw	a3,32(s2)
    8000441c:	01698633          	add	a2,s3,s6
    80004420:	4585                	li	a1,1
    80004422:	01893503          	ld	a0,24(s2)
    80004426:	c1cff0ef          	jal	80003842 <writei>
    8000442a:	84aa                	mv	s1,a0
    8000442c:	00a05763          	blez	a0,8000443a <filewrite+0xb0>
        f->off += r;
    80004430:	02092783          	lw	a5,32(s2)
    80004434:	9fa9                	addw	a5,a5,a0
    80004436:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000443a:	01893503          	ld	a0,24(s2)
    8000443e:	826ff0ef          	jal	80003464 <iunlock>
      end_op();
    80004442:	9c9ff0ef          	jal	80003e0a <end_op>

      if(r != n1){
    80004446:	029a9563          	bne	s5,s1,80004470 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000444a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000444e:	0149da63          	bge	s3,s4,80004462 <filewrite+0xd8>
      int n1 = n - i;
    80004452:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004456:	0004879b          	sext.w	a5,s1
    8000445a:	fafbd6e3          	bge	s7,a5,80004406 <filewrite+0x7c>
    8000445e:	84e2                	mv	s1,s8
    80004460:	b75d                	j	80004406 <filewrite+0x7c>
    80004462:	74e2                	ld	s1,56(sp)
    80004464:	6ae2                	ld	s5,24(sp)
    80004466:	6ba2                	ld	s7,8(sp)
    80004468:	6c02                	ld	s8,0(sp)
    8000446a:	a039                	j	80004478 <filewrite+0xee>
    int i = 0;
    8000446c:	4981                	li	s3,0
    8000446e:	a029                	j	80004478 <filewrite+0xee>
    80004470:	74e2                	ld	s1,56(sp)
    80004472:	6ae2                	ld	s5,24(sp)
    80004474:	6ba2                	ld	s7,8(sp)
    80004476:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004478:	033a1c63          	bne	s4,s3,800044b0 <filewrite+0x126>
    8000447c:	8552                	mv	a0,s4
    8000447e:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004480:	60a6                	ld	ra,72(sp)
    80004482:	6406                	ld	s0,64(sp)
    80004484:	7942                	ld	s2,48(sp)
    80004486:	7a02                	ld	s4,32(sp)
    80004488:	6b42                	ld	s6,16(sp)
    8000448a:	6161                	addi	sp,sp,80
    8000448c:	8082                	ret
    8000448e:	fc26                	sd	s1,56(sp)
    80004490:	f44e                	sd	s3,40(sp)
    80004492:	ec56                	sd	s5,24(sp)
    80004494:	e45e                	sd	s7,8(sp)
    80004496:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004498:	00003517          	auipc	a0,0x3
    8000449c:	0f050513          	addi	a0,a0,240 # 80007588 <etext+0x588>
    800044a0:	b40fc0ef          	jal	800007e0 <panic>
    return -1;
    800044a4:	557d                	li	a0,-1
}
    800044a6:	8082                	ret
      return -1;
    800044a8:	557d                	li	a0,-1
    800044aa:	bfd9                	j	80004480 <filewrite+0xf6>
    800044ac:	557d                	li	a0,-1
    800044ae:	bfc9                	j	80004480 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800044b0:	557d                	li	a0,-1
    800044b2:	79a2                	ld	s3,40(sp)
    800044b4:	b7f1                	j	80004480 <filewrite+0xf6>

00000000800044b6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800044b6:	7179                	addi	sp,sp,-48
    800044b8:	f406                	sd	ra,40(sp)
    800044ba:	f022                	sd	s0,32(sp)
    800044bc:	ec26                	sd	s1,24(sp)
    800044be:	e052                	sd	s4,0(sp)
    800044c0:	1800                	addi	s0,sp,48
    800044c2:	84aa                	mv	s1,a0
    800044c4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800044c6:	0005b023          	sd	zero,0(a1)
    800044ca:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800044ce:	c3bff0ef          	jal	80004108 <filealloc>
    800044d2:	e088                	sd	a0,0(s1)
    800044d4:	c549                	beqz	a0,8000455e <pipealloc+0xa8>
    800044d6:	c33ff0ef          	jal	80004108 <filealloc>
    800044da:	00aa3023          	sd	a0,0(s4)
    800044de:	cd25                	beqz	a0,80004556 <pipealloc+0xa0>
    800044e0:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800044e2:	e1cfc0ef          	jal	80000afe <kalloc>
    800044e6:	892a                	mv	s2,a0
    800044e8:	c12d                	beqz	a0,8000454a <pipealloc+0x94>
    800044ea:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800044ec:	4985                	li	s3,1
    800044ee:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800044f2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800044f6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800044fa:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800044fe:	00003597          	auipc	a1,0x3
    80004502:	09a58593          	addi	a1,a1,154 # 80007598 <etext+0x598>
    80004506:	e48fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    8000450a:	609c                	ld	a5,0(s1)
    8000450c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004510:	609c                	ld	a5,0(s1)
    80004512:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004516:	609c                	ld	a5,0(s1)
    80004518:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000451c:	609c                	ld	a5,0(s1)
    8000451e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004522:	000a3783          	ld	a5,0(s4)
    80004526:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000452a:	000a3783          	ld	a5,0(s4)
    8000452e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004532:	000a3783          	ld	a5,0(s4)
    80004536:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000453a:	000a3783          	ld	a5,0(s4)
    8000453e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004542:	4501                	li	a0,0
    80004544:	6942                	ld	s2,16(sp)
    80004546:	69a2                	ld	s3,8(sp)
    80004548:	a01d                	j	8000456e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000454a:	6088                	ld	a0,0(s1)
    8000454c:	c119                	beqz	a0,80004552 <pipealloc+0x9c>
    8000454e:	6942                	ld	s2,16(sp)
    80004550:	a029                	j	8000455a <pipealloc+0xa4>
    80004552:	6942                	ld	s2,16(sp)
    80004554:	a029                	j	8000455e <pipealloc+0xa8>
    80004556:	6088                	ld	a0,0(s1)
    80004558:	c10d                	beqz	a0,8000457a <pipealloc+0xc4>
    fileclose(*f0);
    8000455a:	c53ff0ef          	jal	800041ac <fileclose>
  if(*f1)
    8000455e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004562:	557d                	li	a0,-1
  if(*f1)
    80004564:	c789                	beqz	a5,8000456e <pipealloc+0xb8>
    fileclose(*f1);
    80004566:	853e                	mv	a0,a5
    80004568:	c45ff0ef          	jal	800041ac <fileclose>
  return -1;
    8000456c:	557d                	li	a0,-1
}
    8000456e:	70a2                	ld	ra,40(sp)
    80004570:	7402                	ld	s0,32(sp)
    80004572:	64e2                	ld	s1,24(sp)
    80004574:	6a02                	ld	s4,0(sp)
    80004576:	6145                	addi	sp,sp,48
    80004578:	8082                	ret
  return -1;
    8000457a:	557d                	li	a0,-1
    8000457c:	bfcd                	j	8000456e <pipealloc+0xb8>

000000008000457e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000457e:	1101                	addi	sp,sp,-32
    80004580:	ec06                	sd	ra,24(sp)
    80004582:	e822                	sd	s0,16(sp)
    80004584:	e426                	sd	s1,8(sp)
    80004586:	e04a                	sd	s2,0(sp)
    80004588:	1000                	addi	s0,sp,32
    8000458a:	84aa                	mv	s1,a0
    8000458c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000458e:	e40fc0ef          	jal	80000bce <acquire>
  if(writable){
    80004592:	02090763          	beqz	s2,800045c0 <pipeclose+0x42>
    pi->writeopen = 0;
    80004596:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000459a:	21848513          	addi	a0,s1,536
    8000459e:	a63fd0ef          	jal	80002000 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800045a2:	2204b783          	ld	a5,544(s1)
    800045a6:	e785                	bnez	a5,800045ce <pipeclose+0x50>
    release(&pi->lock);
    800045a8:	8526                	mv	a0,s1
    800045aa:	ebcfc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800045ae:	8526                	mv	a0,s1
    800045b0:	c6cfc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800045b4:	60e2                	ld	ra,24(sp)
    800045b6:	6442                	ld	s0,16(sp)
    800045b8:	64a2                	ld	s1,8(sp)
    800045ba:	6902                	ld	s2,0(sp)
    800045bc:	6105                	addi	sp,sp,32
    800045be:	8082                	ret
    pi->readopen = 0;
    800045c0:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800045c4:	21c48513          	addi	a0,s1,540
    800045c8:	a39fd0ef          	jal	80002000 <wakeup>
    800045cc:	bfd9                	j	800045a2 <pipeclose+0x24>
    release(&pi->lock);
    800045ce:	8526                	mv	a0,s1
    800045d0:	e96fc0ef          	jal	80000c66 <release>
}
    800045d4:	b7c5                	j	800045b4 <pipeclose+0x36>

00000000800045d6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800045d6:	711d                	addi	sp,sp,-96
    800045d8:	ec86                	sd	ra,88(sp)
    800045da:	e8a2                	sd	s0,80(sp)
    800045dc:	e4a6                	sd	s1,72(sp)
    800045de:	e0ca                	sd	s2,64(sp)
    800045e0:	fc4e                	sd	s3,56(sp)
    800045e2:	f852                	sd	s4,48(sp)
    800045e4:	f456                	sd	s5,40(sp)
    800045e6:	1080                	addi	s0,sp,96
    800045e8:	84aa                	mv	s1,a0
    800045ea:	8aae                	mv	s5,a1
    800045ec:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800045ee:	bbcfd0ef          	jal	800019aa <myproc>
    800045f2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800045f4:	8526                	mv	a0,s1
    800045f6:	dd8fc0ef          	jal	80000bce <acquire>
  while(i < n){
    800045fa:	0b405a63          	blez	s4,800046ae <pipewrite+0xd8>
    800045fe:	f05a                	sd	s6,32(sp)
    80004600:	ec5e                	sd	s7,24(sp)
    80004602:	e862                	sd	s8,16(sp)
  int i = 0;
    80004604:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004606:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004608:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000460c:	21c48b93          	addi	s7,s1,540
    80004610:	a81d                	j	80004646 <pipewrite+0x70>
      release(&pi->lock);
    80004612:	8526                	mv	a0,s1
    80004614:	e52fc0ef          	jal	80000c66 <release>
      return -1;
    80004618:	597d                	li	s2,-1
    8000461a:	7b02                	ld	s6,32(sp)
    8000461c:	6be2                	ld	s7,24(sp)
    8000461e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004620:	854a                	mv	a0,s2
    80004622:	60e6                	ld	ra,88(sp)
    80004624:	6446                	ld	s0,80(sp)
    80004626:	64a6                	ld	s1,72(sp)
    80004628:	6906                	ld	s2,64(sp)
    8000462a:	79e2                	ld	s3,56(sp)
    8000462c:	7a42                	ld	s4,48(sp)
    8000462e:	7aa2                	ld	s5,40(sp)
    80004630:	6125                	addi	sp,sp,96
    80004632:	8082                	ret
      wakeup(&pi->nread);
    80004634:	8562                	mv	a0,s8
    80004636:	9cbfd0ef          	jal	80002000 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000463a:	85a6                	mv	a1,s1
    8000463c:	855e                	mv	a0,s7
    8000463e:	977fd0ef          	jal	80001fb4 <sleep>
  while(i < n){
    80004642:	05495b63          	bge	s2,s4,80004698 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004646:	2204a783          	lw	a5,544(s1)
    8000464a:	d7e1                	beqz	a5,80004612 <pipewrite+0x3c>
    8000464c:	854e                	mv	a0,s3
    8000464e:	b9ffd0ef          	jal	800021ec <killed>
    80004652:	f161                	bnez	a0,80004612 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004654:	2184a783          	lw	a5,536(s1)
    80004658:	21c4a703          	lw	a4,540(s1)
    8000465c:	2007879b          	addiw	a5,a5,512
    80004660:	fcf70ae3          	beq	a4,a5,80004634 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004664:	4685                	li	a3,1
    80004666:	01590633          	add	a2,s2,s5
    8000466a:	faf40593          	addi	a1,s0,-81
    8000466e:	0509b503          	ld	a0,80(s3)
    80004672:	854fd0ef          	jal	800016c6 <copyin>
    80004676:	03650e63          	beq	a0,s6,800046b2 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000467a:	21c4a783          	lw	a5,540(s1)
    8000467e:	0017871b          	addiw	a4,a5,1
    80004682:	20e4ae23          	sw	a4,540(s1)
    80004686:	1ff7f793          	andi	a5,a5,511
    8000468a:	97a6                	add	a5,a5,s1
    8000468c:	faf44703          	lbu	a4,-81(s0)
    80004690:	00e78c23          	sb	a4,24(a5)
      i++;
    80004694:	2905                	addiw	s2,s2,1
    80004696:	b775                	j	80004642 <pipewrite+0x6c>
    80004698:	7b02                	ld	s6,32(sp)
    8000469a:	6be2                	ld	s7,24(sp)
    8000469c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000469e:	21848513          	addi	a0,s1,536
    800046a2:	95ffd0ef          	jal	80002000 <wakeup>
  release(&pi->lock);
    800046a6:	8526                	mv	a0,s1
    800046a8:	dbefc0ef          	jal	80000c66 <release>
  return i;
    800046ac:	bf95                	j	80004620 <pipewrite+0x4a>
  int i = 0;
    800046ae:	4901                	li	s2,0
    800046b0:	b7fd                	j	8000469e <pipewrite+0xc8>
    800046b2:	7b02                	ld	s6,32(sp)
    800046b4:	6be2                	ld	s7,24(sp)
    800046b6:	6c42                	ld	s8,16(sp)
    800046b8:	b7dd                	j	8000469e <pipewrite+0xc8>

00000000800046ba <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800046ba:	715d                	addi	sp,sp,-80
    800046bc:	e486                	sd	ra,72(sp)
    800046be:	e0a2                	sd	s0,64(sp)
    800046c0:	fc26                	sd	s1,56(sp)
    800046c2:	f84a                	sd	s2,48(sp)
    800046c4:	f44e                	sd	s3,40(sp)
    800046c6:	f052                	sd	s4,32(sp)
    800046c8:	ec56                	sd	s5,24(sp)
    800046ca:	0880                	addi	s0,sp,80
    800046cc:	84aa                	mv	s1,a0
    800046ce:	892e                	mv	s2,a1
    800046d0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800046d2:	ad8fd0ef          	jal	800019aa <myproc>
    800046d6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800046d8:	8526                	mv	a0,s1
    800046da:	cf4fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046de:	2184a703          	lw	a4,536(s1)
    800046e2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046e6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800046ea:	02f71563          	bne	a4,a5,80004714 <piperead+0x5a>
    800046ee:	2244a783          	lw	a5,548(s1)
    800046f2:	cb85                	beqz	a5,80004722 <piperead+0x68>
    if(killed(pr)){
    800046f4:	8552                	mv	a0,s4
    800046f6:	af7fd0ef          	jal	800021ec <killed>
    800046fa:	ed19                	bnez	a0,80004718 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800046fc:	85a6                	mv	a1,s1
    800046fe:	854e                	mv	a0,s3
    80004700:	8b5fd0ef          	jal	80001fb4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004704:	2184a703          	lw	a4,536(s1)
    80004708:	21c4a783          	lw	a5,540(s1)
    8000470c:	fef701e3          	beq	a4,a5,800046ee <piperead+0x34>
    80004710:	e85a                	sd	s6,16(sp)
    80004712:	a809                	j	80004724 <piperead+0x6a>
    80004714:	e85a                	sd	s6,16(sp)
    80004716:	a039                	j	80004724 <piperead+0x6a>
      release(&pi->lock);
    80004718:	8526                	mv	a0,s1
    8000471a:	d4cfc0ef          	jal	80000c66 <release>
      return -1;
    8000471e:	59fd                	li	s3,-1
    80004720:	a8b9                	j	8000477e <piperead+0xc4>
    80004722:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004724:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004726:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004728:	05505363          	blez	s5,8000476e <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000472c:	2184a783          	lw	a5,536(s1)
    80004730:	21c4a703          	lw	a4,540(s1)
    80004734:	02f70d63          	beq	a4,a5,8000476e <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004738:	1ff7f793          	andi	a5,a5,511
    8000473c:	97a6                	add	a5,a5,s1
    8000473e:	0187c783          	lbu	a5,24(a5)
    80004742:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004746:	4685                	li	a3,1
    80004748:	fbf40613          	addi	a2,s0,-65
    8000474c:	85ca                	mv	a1,s2
    8000474e:	050a3503          	ld	a0,80(s4)
    80004752:	e91fc0ef          	jal	800015e2 <copyout>
    80004756:	03650e63          	beq	a0,s6,80004792 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000475a:	2184a783          	lw	a5,536(s1)
    8000475e:	2785                	addiw	a5,a5,1
    80004760:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004764:	2985                	addiw	s3,s3,1
    80004766:	0905                	addi	s2,s2,1
    80004768:	fd3a92e3          	bne	s5,s3,8000472c <piperead+0x72>
    8000476c:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000476e:	21c48513          	addi	a0,s1,540
    80004772:	88ffd0ef          	jal	80002000 <wakeup>
  release(&pi->lock);
    80004776:	8526                	mv	a0,s1
    80004778:	ceefc0ef          	jal	80000c66 <release>
    8000477c:	6b42                	ld	s6,16(sp)
  return i;
}
    8000477e:	854e                	mv	a0,s3
    80004780:	60a6                	ld	ra,72(sp)
    80004782:	6406                	ld	s0,64(sp)
    80004784:	74e2                	ld	s1,56(sp)
    80004786:	7942                	ld	s2,48(sp)
    80004788:	79a2                	ld	s3,40(sp)
    8000478a:	7a02                	ld	s4,32(sp)
    8000478c:	6ae2                	ld	s5,24(sp)
    8000478e:	6161                	addi	sp,sp,80
    80004790:	8082                	ret
      if(i == 0)
    80004792:	fc099ee3          	bnez	s3,8000476e <piperead+0xb4>
        i = -1;
    80004796:	89aa                	mv	s3,a0
    80004798:	bfd9                	j	8000476e <piperead+0xb4>

000000008000479a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000479a:	1141                	addi	sp,sp,-16
    8000479c:	e422                	sd	s0,8(sp)
    8000479e:	0800                	addi	s0,sp,16
    800047a0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800047a2:	8905                	andi	a0,a0,1
    800047a4:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800047a6:	8b89                	andi	a5,a5,2
    800047a8:	c399                	beqz	a5,800047ae <flags2perm+0x14>
      perm |= PTE_W;
    800047aa:	00456513          	ori	a0,a0,4
    return perm;
}
    800047ae:	6422                	ld	s0,8(sp)
    800047b0:	0141                	addi	sp,sp,16
    800047b2:	8082                	ret

00000000800047b4 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800047b4:	df010113          	addi	sp,sp,-528
    800047b8:	20113423          	sd	ra,520(sp)
    800047bc:	20813023          	sd	s0,512(sp)
    800047c0:	ffa6                	sd	s1,504(sp)
    800047c2:	fbca                	sd	s2,496(sp)
    800047c4:	0c00                	addi	s0,sp,528
    800047c6:	892a                	mv	s2,a0
    800047c8:	dea43c23          	sd	a0,-520(s0)
    800047cc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800047d0:	9dafd0ef          	jal	800019aa <myproc>
    800047d4:	84aa                	mv	s1,a0

  begin_op();
    800047d6:	dcaff0ef          	jal	80003da0 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800047da:	854a                	mv	a0,s2
    800047dc:	bf0ff0ef          	jal	80003bcc <namei>
    800047e0:	c931                	beqz	a0,80004834 <kexec+0x80>
    800047e2:	f3d2                	sd	s4,480(sp)
    800047e4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800047e6:	bd1fe0ef          	jal	800033b6 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800047ea:	04000713          	li	a4,64
    800047ee:	4681                	li	a3,0
    800047f0:	e5040613          	addi	a2,s0,-432
    800047f4:	4581                	li	a1,0
    800047f6:	8552                	mv	a0,s4
    800047f8:	f4ffe0ef          	jal	80003746 <readi>
    800047fc:	04000793          	li	a5,64
    80004800:	00f51a63          	bne	a0,a5,80004814 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004804:	e5042703          	lw	a4,-432(s0)
    80004808:	464c47b7          	lui	a5,0x464c4
    8000480c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004810:	02f70663          	beq	a4,a5,8000483c <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004814:	8552                	mv	a0,s4
    80004816:	dabfe0ef          	jal	800035c0 <iunlockput>
    end_op();
    8000481a:	df0ff0ef          	jal	80003e0a <end_op>
  }
  return -1;
    8000481e:	557d                	li	a0,-1
    80004820:	7a1e                	ld	s4,480(sp)
}
    80004822:	20813083          	ld	ra,520(sp)
    80004826:	20013403          	ld	s0,512(sp)
    8000482a:	74fe                	ld	s1,504(sp)
    8000482c:	795e                	ld	s2,496(sp)
    8000482e:	21010113          	addi	sp,sp,528
    80004832:	8082                	ret
    end_op();
    80004834:	dd6ff0ef          	jal	80003e0a <end_op>
    return -1;
    80004838:	557d                	li	a0,-1
    8000483a:	b7e5                	j	80004822 <kexec+0x6e>
    8000483c:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000483e:	8526                	mv	a0,s1
    80004840:	a70fd0ef          	jal	80001ab0 <proc_pagetable>
    80004844:	8b2a                	mv	s6,a0
    80004846:	2c050b63          	beqz	a0,80004b1c <kexec+0x368>
    8000484a:	f7ce                	sd	s3,488(sp)
    8000484c:	efd6                	sd	s5,472(sp)
    8000484e:	e7de                	sd	s7,456(sp)
    80004850:	e3e2                	sd	s8,448(sp)
    80004852:	ff66                	sd	s9,440(sp)
    80004854:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004856:	e7042d03          	lw	s10,-400(s0)
    8000485a:	e8845783          	lhu	a5,-376(s0)
    8000485e:	12078963          	beqz	a5,80004990 <kexec+0x1dc>
    80004862:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004864:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004866:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004868:	6c85                	lui	s9,0x1
    8000486a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000486e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004872:	6a85                	lui	s5,0x1
    80004874:	a085                	j	800048d4 <kexec+0x120>
      panic("loadseg: address should exist");
    80004876:	00003517          	auipc	a0,0x3
    8000487a:	d2a50513          	addi	a0,a0,-726 # 800075a0 <etext+0x5a0>
    8000487e:	f63fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004882:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004884:	8726                	mv	a4,s1
    80004886:	012c06bb          	addw	a3,s8,s2
    8000488a:	4581                	li	a1,0
    8000488c:	8552                	mv	a0,s4
    8000488e:	eb9fe0ef          	jal	80003746 <readi>
    80004892:	2501                	sext.w	a0,a0
    80004894:	24a49a63          	bne	s1,a0,80004ae8 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004898:	012a893b          	addw	s2,s5,s2
    8000489c:	03397363          	bgeu	s2,s3,800048c2 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800048a0:	02091593          	slli	a1,s2,0x20
    800048a4:	9181                	srli	a1,a1,0x20
    800048a6:	95de                	add	a1,a1,s7
    800048a8:	855a                	mv	a0,s6
    800048aa:	f06fc0ef          	jal	80000fb0 <walkaddr>
    800048ae:	862a                	mv	a2,a0
    if(pa == 0)
    800048b0:	d179                	beqz	a0,80004876 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800048b2:	412984bb          	subw	s1,s3,s2
    800048b6:	0004879b          	sext.w	a5,s1
    800048ba:	fcfcf4e3          	bgeu	s9,a5,80004882 <kexec+0xce>
    800048be:	84d6                	mv	s1,s5
    800048c0:	b7c9                	j	80004882 <kexec+0xce>
    sz = sz1;
    800048c2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048c6:	2d85                	addiw	s11,s11,1
    800048c8:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800048cc:	e8845783          	lhu	a5,-376(s0)
    800048d0:	08fdd063          	bge	s11,a5,80004950 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800048d4:	2d01                	sext.w	s10,s10
    800048d6:	03800713          	li	a4,56
    800048da:	86ea                	mv	a3,s10
    800048dc:	e1840613          	addi	a2,s0,-488
    800048e0:	4581                	li	a1,0
    800048e2:	8552                	mv	a0,s4
    800048e4:	e63fe0ef          	jal	80003746 <readi>
    800048e8:	03800793          	li	a5,56
    800048ec:	1cf51663          	bne	a0,a5,80004ab8 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800048f0:	e1842783          	lw	a5,-488(s0)
    800048f4:	4705                	li	a4,1
    800048f6:	fce798e3          	bne	a5,a4,800048c6 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    800048fa:	e4043483          	ld	s1,-448(s0)
    800048fe:	e3843783          	ld	a5,-456(s0)
    80004902:	1af4ef63          	bltu	s1,a5,80004ac0 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004906:	e2843783          	ld	a5,-472(s0)
    8000490a:	94be                	add	s1,s1,a5
    8000490c:	1af4ee63          	bltu	s1,a5,80004ac8 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004910:	df043703          	ld	a4,-528(s0)
    80004914:	8ff9                	and	a5,a5,a4
    80004916:	1a079d63          	bnez	a5,80004ad0 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000491a:	e1c42503          	lw	a0,-484(s0)
    8000491e:	e7dff0ef          	jal	8000479a <flags2perm>
    80004922:	86aa                	mv	a3,a0
    80004924:	8626                	mv	a2,s1
    80004926:	85ca                	mv	a1,s2
    80004928:	855a                	mv	a0,s6
    8000492a:	95ffc0ef          	jal	80001288 <uvmalloc>
    8000492e:	e0a43423          	sd	a0,-504(s0)
    80004932:	1a050363          	beqz	a0,80004ad8 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004936:	e2843b83          	ld	s7,-472(s0)
    8000493a:	e2042c03          	lw	s8,-480(s0)
    8000493e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004942:	00098463          	beqz	s3,8000494a <kexec+0x196>
    80004946:	4901                	li	s2,0
    80004948:	bfa1                	j	800048a0 <kexec+0xec>
    sz = sz1;
    8000494a:	e0843903          	ld	s2,-504(s0)
    8000494e:	bfa5                	j	800048c6 <kexec+0x112>
    80004950:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004952:	8552                	mv	a0,s4
    80004954:	c6dfe0ef          	jal	800035c0 <iunlockput>
  end_op();
    80004958:	cb2ff0ef          	jal	80003e0a <end_op>
  p = myproc();
    8000495c:	84efd0ef          	jal	800019aa <myproc>
    80004960:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004962:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004966:	6985                	lui	s3,0x1
    80004968:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000496a:	99ca                	add	s3,s3,s2
    8000496c:	77fd                	lui	a5,0xfffff
    8000496e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004972:	4691                	li	a3,4
    80004974:	6609                	lui	a2,0x2
    80004976:	964e                	add	a2,a2,s3
    80004978:	85ce                	mv	a1,s3
    8000497a:	855a                	mv	a0,s6
    8000497c:	90dfc0ef          	jal	80001288 <uvmalloc>
    80004980:	892a                	mv	s2,a0
    80004982:	e0a43423          	sd	a0,-504(s0)
    80004986:	e519                	bnez	a0,80004994 <kexec+0x1e0>
  if(pagetable)
    80004988:	e1343423          	sd	s3,-504(s0)
    8000498c:	4a01                	li	s4,0
    8000498e:	aab1                	j	80004aea <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004990:	4901                	li	s2,0
    80004992:	b7c1                	j	80004952 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004994:	75f9                	lui	a1,0xffffe
    80004996:	95aa                	add	a1,a1,a0
    80004998:	855a                	mv	a0,s6
    8000499a:	ac5fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000499e:	7bfd                	lui	s7,0xfffff
    800049a0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800049a2:	e0043783          	ld	a5,-512(s0)
    800049a6:	6388                	ld	a0,0(a5)
    800049a8:	cd39                	beqz	a0,80004a06 <kexec+0x252>
    800049aa:	e9040993          	addi	s3,s0,-368
    800049ae:	f9040c13          	addi	s8,s0,-112
    800049b2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800049b4:	c5efc0ef          	jal	80000e12 <strlen>
    800049b8:	0015079b          	addiw	a5,a0,1
    800049bc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800049c0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800049c4:	11796e63          	bltu	s2,s7,80004ae0 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800049c8:	e0043d03          	ld	s10,-512(s0)
    800049cc:	000d3a03          	ld	s4,0(s10)
    800049d0:	8552                	mv	a0,s4
    800049d2:	c40fc0ef          	jal	80000e12 <strlen>
    800049d6:	0015069b          	addiw	a3,a0,1
    800049da:	8652                	mv	a2,s4
    800049dc:	85ca                	mv	a1,s2
    800049de:	855a                	mv	a0,s6
    800049e0:	c03fc0ef          	jal	800015e2 <copyout>
    800049e4:	10054063          	bltz	a0,80004ae4 <kexec+0x330>
    ustack[argc] = sp;
    800049e8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800049ec:	0485                	addi	s1,s1,1
    800049ee:	008d0793          	addi	a5,s10,8
    800049f2:	e0f43023          	sd	a5,-512(s0)
    800049f6:	008d3503          	ld	a0,8(s10)
    800049fa:	c909                	beqz	a0,80004a0c <kexec+0x258>
    if(argc >= MAXARG)
    800049fc:	09a1                	addi	s3,s3,8
    800049fe:	fb899be3          	bne	s3,s8,800049b4 <kexec+0x200>
  ip = 0;
    80004a02:	4a01                	li	s4,0
    80004a04:	a0dd                	j	80004aea <kexec+0x336>
  sp = sz;
    80004a06:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004a0a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004a0c:	00349793          	slli	a5,s1,0x3
    80004a10:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde418>
    80004a14:	97a2                	add	a5,a5,s0
    80004a16:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004a1a:	00148693          	addi	a3,s1,1
    80004a1e:	068e                	slli	a3,a3,0x3
    80004a20:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004a24:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004a28:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004a2c:	f5796ee3          	bltu	s2,s7,80004988 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004a30:	e9040613          	addi	a2,s0,-368
    80004a34:	85ca                	mv	a1,s2
    80004a36:	855a                	mv	a0,s6
    80004a38:	babfc0ef          	jal	800015e2 <copyout>
    80004a3c:	0e054263          	bltz	a0,80004b20 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004a40:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004a44:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004a48:	df843783          	ld	a5,-520(s0)
    80004a4c:	0007c703          	lbu	a4,0(a5)
    80004a50:	cf11                	beqz	a4,80004a6c <kexec+0x2b8>
    80004a52:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004a54:	02f00693          	li	a3,47
    80004a58:	a039                	j	80004a66 <kexec+0x2b2>
      last = s+1;
    80004a5a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004a5e:	0785                	addi	a5,a5,1
    80004a60:	fff7c703          	lbu	a4,-1(a5)
    80004a64:	c701                	beqz	a4,80004a6c <kexec+0x2b8>
    if(*s == '/')
    80004a66:	fed71ce3          	bne	a4,a3,80004a5e <kexec+0x2aa>
    80004a6a:	bfc5                	j	80004a5a <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004a6c:	4641                	li	a2,16
    80004a6e:	df843583          	ld	a1,-520(s0)
    80004a72:	158a8513          	addi	a0,s5,344
    80004a76:	b6afc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a7a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004a7e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004a82:	e0843783          	ld	a5,-504(s0)
    80004a86:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004a8a:	058ab783          	ld	a5,88(s5)
    80004a8e:	e6843703          	ld	a4,-408(s0)
    80004a92:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a94:	058ab783          	ld	a5,88(s5)
    80004a98:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a9c:	85e6                	mv	a1,s9
    80004a9e:	896fd0ef          	jal	80001b34 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004aa2:	0004851b          	sext.w	a0,s1
    80004aa6:	79be                	ld	s3,488(sp)
    80004aa8:	7a1e                	ld	s4,480(sp)
    80004aaa:	6afe                	ld	s5,472(sp)
    80004aac:	6b5e                	ld	s6,464(sp)
    80004aae:	6bbe                	ld	s7,456(sp)
    80004ab0:	6c1e                	ld	s8,448(sp)
    80004ab2:	7cfa                	ld	s9,440(sp)
    80004ab4:	7d5a                	ld	s10,432(sp)
    80004ab6:	b3b5                	j	80004822 <kexec+0x6e>
    80004ab8:	e1243423          	sd	s2,-504(s0)
    80004abc:	7dba                	ld	s11,424(sp)
    80004abe:	a035                	j	80004aea <kexec+0x336>
    80004ac0:	e1243423          	sd	s2,-504(s0)
    80004ac4:	7dba                	ld	s11,424(sp)
    80004ac6:	a015                	j	80004aea <kexec+0x336>
    80004ac8:	e1243423          	sd	s2,-504(s0)
    80004acc:	7dba                	ld	s11,424(sp)
    80004ace:	a831                	j	80004aea <kexec+0x336>
    80004ad0:	e1243423          	sd	s2,-504(s0)
    80004ad4:	7dba                	ld	s11,424(sp)
    80004ad6:	a811                	j	80004aea <kexec+0x336>
    80004ad8:	e1243423          	sd	s2,-504(s0)
    80004adc:	7dba                	ld	s11,424(sp)
    80004ade:	a031                	j	80004aea <kexec+0x336>
  ip = 0;
    80004ae0:	4a01                	li	s4,0
    80004ae2:	a021                	j	80004aea <kexec+0x336>
    80004ae4:	4a01                	li	s4,0
  if(pagetable)
    80004ae6:	a011                	j	80004aea <kexec+0x336>
    80004ae8:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004aea:	e0843583          	ld	a1,-504(s0)
    80004aee:	855a                	mv	a0,s6
    80004af0:	844fd0ef          	jal	80001b34 <proc_freepagetable>
  return -1;
    80004af4:	557d                	li	a0,-1
  if(ip){
    80004af6:	000a1b63          	bnez	s4,80004b0c <kexec+0x358>
    80004afa:	79be                	ld	s3,488(sp)
    80004afc:	7a1e                	ld	s4,480(sp)
    80004afe:	6afe                	ld	s5,472(sp)
    80004b00:	6b5e                	ld	s6,464(sp)
    80004b02:	6bbe                	ld	s7,456(sp)
    80004b04:	6c1e                	ld	s8,448(sp)
    80004b06:	7cfa                	ld	s9,440(sp)
    80004b08:	7d5a                	ld	s10,432(sp)
    80004b0a:	bb21                	j	80004822 <kexec+0x6e>
    80004b0c:	79be                	ld	s3,488(sp)
    80004b0e:	6afe                	ld	s5,472(sp)
    80004b10:	6b5e                	ld	s6,464(sp)
    80004b12:	6bbe                	ld	s7,456(sp)
    80004b14:	6c1e                	ld	s8,448(sp)
    80004b16:	7cfa                	ld	s9,440(sp)
    80004b18:	7d5a                	ld	s10,432(sp)
    80004b1a:	b9ed                	j	80004814 <kexec+0x60>
    80004b1c:	6b5e                	ld	s6,464(sp)
    80004b1e:	b9dd                	j	80004814 <kexec+0x60>
  sz = sz1;
    80004b20:	e0843983          	ld	s3,-504(s0)
    80004b24:	b595                	j	80004988 <kexec+0x1d4>

0000000080004b26 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004b26:	7179                	addi	sp,sp,-48
    80004b28:	f406                	sd	ra,40(sp)
    80004b2a:	f022                	sd	s0,32(sp)
    80004b2c:	ec26                	sd	s1,24(sp)
    80004b2e:	e84a                	sd	s2,16(sp)
    80004b30:	1800                	addi	s0,sp,48
    80004b32:	892e                	mv	s2,a1
    80004b34:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004b36:	fdc40593          	addi	a1,s0,-36
    80004b3a:	debfd0ef          	jal	80002924 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004b3e:	fdc42703          	lw	a4,-36(s0)
    80004b42:	47bd                	li	a5,15
    80004b44:	02e7e963          	bltu	a5,a4,80004b76 <argfd+0x50>
    80004b48:	e63fc0ef          	jal	800019aa <myproc>
    80004b4c:	fdc42703          	lw	a4,-36(s0)
    80004b50:	01a70793          	addi	a5,a4,26
    80004b54:	078e                	slli	a5,a5,0x3
    80004b56:	953e                	add	a0,a0,a5
    80004b58:	611c                	ld	a5,0(a0)
    80004b5a:	c385                	beqz	a5,80004b7a <argfd+0x54>
    return -1;
  if(pfd)
    80004b5c:	00090463          	beqz	s2,80004b64 <argfd+0x3e>
    *pfd = fd;
    80004b60:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004b64:	4501                	li	a0,0
  if(pf)
    80004b66:	c091                	beqz	s1,80004b6a <argfd+0x44>
    *pf = f;
    80004b68:	e09c                	sd	a5,0(s1)
}
    80004b6a:	70a2                	ld	ra,40(sp)
    80004b6c:	7402                	ld	s0,32(sp)
    80004b6e:	64e2                	ld	s1,24(sp)
    80004b70:	6942                	ld	s2,16(sp)
    80004b72:	6145                	addi	sp,sp,48
    80004b74:	8082                	ret
    return -1;
    80004b76:	557d                	li	a0,-1
    80004b78:	bfcd                	j	80004b6a <argfd+0x44>
    80004b7a:	557d                	li	a0,-1
    80004b7c:	b7fd                	j	80004b6a <argfd+0x44>

0000000080004b7e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b7e:	1101                	addi	sp,sp,-32
    80004b80:	ec06                	sd	ra,24(sp)
    80004b82:	e822                	sd	s0,16(sp)
    80004b84:	e426                	sd	s1,8(sp)
    80004b86:	1000                	addi	s0,sp,32
    80004b88:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b8a:	e21fc0ef          	jal	800019aa <myproc>
    80004b8e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b90:	0d050793          	addi	a5,a0,208
    80004b94:	4501                	li	a0,0
    80004b96:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b98:	6398                	ld	a4,0(a5)
    80004b9a:	cb19                	beqz	a4,80004bb0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b9c:	2505                	addiw	a0,a0,1
    80004b9e:	07a1                	addi	a5,a5,8
    80004ba0:	fed51ce3          	bne	a0,a3,80004b98 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ba4:	557d                	li	a0,-1
}
    80004ba6:	60e2                	ld	ra,24(sp)
    80004ba8:	6442                	ld	s0,16(sp)
    80004baa:	64a2                	ld	s1,8(sp)
    80004bac:	6105                	addi	sp,sp,32
    80004bae:	8082                	ret
      p->ofile[fd] = f;
    80004bb0:	01a50793          	addi	a5,a0,26
    80004bb4:	078e                	slli	a5,a5,0x3
    80004bb6:	963e                	add	a2,a2,a5
    80004bb8:	e204                	sd	s1,0(a2)
      return fd;
    80004bba:	b7f5                	j	80004ba6 <fdalloc+0x28>

0000000080004bbc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004bbc:	715d                	addi	sp,sp,-80
    80004bbe:	e486                	sd	ra,72(sp)
    80004bc0:	e0a2                	sd	s0,64(sp)
    80004bc2:	fc26                	sd	s1,56(sp)
    80004bc4:	f84a                	sd	s2,48(sp)
    80004bc6:	f44e                	sd	s3,40(sp)
    80004bc8:	ec56                	sd	s5,24(sp)
    80004bca:	e85a                	sd	s6,16(sp)
    80004bcc:	0880                	addi	s0,sp,80
    80004bce:	8b2e                	mv	s6,a1
    80004bd0:	89b2                	mv	s3,a2
    80004bd2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004bd4:	fb040593          	addi	a1,s0,-80
    80004bd8:	80eff0ef          	jal	80003be6 <nameiparent>
    80004bdc:	84aa                	mv	s1,a0
    80004bde:	10050a63          	beqz	a0,80004cf2 <create+0x136>
    return 0;

  ilock(dp);
    80004be2:	fd4fe0ef          	jal	800033b6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004be6:	4601                	li	a2,0
    80004be8:	fb040593          	addi	a1,s0,-80
    80004bec:	8526                	mv	a0,s1
    80004bee:	d79fe0ef          	jal	80003966 <dirlookup>
    80004bf2:	8aaa                	mv	s5,a0
    80004bf4:	c129                	beqz	a0,80004c36 <create+0x7a>
    iunlockput(dp);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	9c9fe0ef          	jal	800035c0 <iunlockput>
    ilock(ip);
    80004bfc:	8556                	mv	a0,s5
    80004bfe:	fb8fe0ef          	jal	800033b6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c02:	4789                	li	a5,2
    80004c04:	02fb1463          	bne	s6,a5,80004c2c <create+0x70>
    80004c08:	044ad783          	lhu	a5,68(s5)
    80004c0c:	37f9                	addiw	a5,a5,-2
    80004c0e:	17c2                	slli	a5,a5,0x30
    80004c10:	93c1                	srli	a5,a5,0x30
    80004c12:	4705                	li	a4,1
    80004c14:	00f76c63          	bltu	a4,a5,80004c2c <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004c18:	8556                	mv	a0,s5
    80004c1a:	60a6                	ld	ra,72(sp)
    80004c1c:	6406                	ld	s0,64(sp)
    80004c1e:	74e2                	ld	s1,56(sp)
    80004c20:	7942                	ld	s2,48(sp)
    80004c22:	79a2                	ld	s3,40(sp)
    80004c24:	6ae2                	ld	s5,24(sp)
    80004c26:	6b42                	ld	s6,16(sp)
    80004c28:	6161                	addi	sp,sp,80
    80004c2a:	8082                	ret
    iunlockput(ip);
    80004c2c:	8556                	mv	a0,s5
    80004c2e:	993fe0ef          	jal	800035c0 <iunlockput>
    return 0;
    80004c32:	4a81                	li	s5,0
    80004c34:	b7d5                	j	80004c18 <create+0x5c>
    80004c36:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004c38:	85da                	mv	a1,s6
    80004c3a:	4088                	lw	a0,0(s1)
    80004c3c:	e0afe0ef          	jal	80003246 <ialloc>
    80004c40:	8a2a                	mv	s4,a0
    80004c42:	cd15                	beqz	a0,80004c7e <create+0xc2>
  ilock(ip);
    80004c44:	f72fe0ef          	jal	800033b6 <ilock>
  ip->major = major;
    80004c48:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004c4c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004c50:	4905                	li	s2,1
    80004c52:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004c56:	8552                	mv	a0,s4
    80004c58:	eaafe0ef          	jal	80003302 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004c5c:	032b0763          	beq	s6,s2,80004c8a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c60:	004a2603          	lw	a2,4(s4)
    80004c64:	fb040593          	addi	a1,s0,-80
    80004c68:	8526                	mv	a0,s1
    80004c6a:	ec9fe0ef          	jal	80003b32 <dirlink>
    80004c6e:	06054563          	bltz	a0,80004cd8 <create+0x11c>
  iunlockput(dp);
    80004c72:	8526                	mv	a0,s1
    80004c74:	94dfe0ef          	jal	800035c0 <iunlockput>
  return ip;
    80004c78:	8ad2                	mv	s5,s4
    80004c7a:	7a02                	ld	s4,32(sp)
    80004c7c:	bf71                	j	80004c18 <create+0x5c>
    iunlockput(dp);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	941fe0ef          	jal	800035c0 <iunlockput>
    return 0;
    80004c84:	8ad2                	mv	s5,s4
    80004c86:	7a02                	ld	s4,32(sp)
    80004c88:	bf41                	j	80004c18 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c8a:	004a2603          	lw	a2,4(s4)
    80004c8e:	00003597          	auipc	a1,0x3
    80004c92:	93258593          	addi	a1,a1,-1742 # 800075c0 <etext+0x5c0>
    80004c96:	8552                	mv	a0,s4
    80004c98:	e9bfe0ef          	jal	80003b32 <dirlink>
    80004c9c:	02054e63          	bltz	a0,80004cd8 <create+0x11c>
    80004ca0:	40d0                	lw	a2,4(s1)
    80004ca2:	00003597          	auipc	a1,0x3
    80004ca6:	92658593          	addi	a1,a1,-1754 # 800075c8 <etext+0x5c8>
    80004caa:	8552                	mv	a0,s4
    80004cac:	e87fe0ef          	jal	80003b32 <dirlink>
    80004cb0:	02054463          	bltz	a0,80004cd8 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cb4:	004a2603          	lw	a2,4(s4)
    80004cb8:	fb040593          	addi	a1,s0,-80
    80004cbc:	8526                	mv	a0,s1
    80004cbe:	e75fe0ef          	jal	80003b32 <dirlink>
    80004cc2:	00054b63          	bltz	a0,80004cd8 <create+0x11c>
    dp->nlink++;  // for ".."
    80004cc6:	04a4d783          	lhu	a5,74(s1)
    80004cca:	2785                	addiw	a5,a5,1
    80004ccc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	e30fe0ef          	jal	80003302 <iupdate>
    80004cd6:	bf71                	j	80004c72 <create+0xb6>
  ip->nlink = 0;
    80004cd8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004cdc:	8552                	mv	a0,s4
    80004cde:	e24fe0ef          	jal	80003302 <iupdate>
  iunlockput(ip);
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	8ddfe0ef          	jal	800035c0 <iunlockput>
  iunlockput(dp);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	8d7fe0ef          	jal	800035c0 <iunlockput>
  return 0;
    80004cee:	7a02                	ld	s4,32(sp)
    80004cf0:	b725                	j	80004c18 <create+0x5c>
    return 0;
    80004cf2:	8aaa                	mv	s5,a0
    80004cf4:	b715                	j	80004c18 <create+0x5c>

0000000080004cf6 <sys_dup>:
{
    80004cf6:	7179                	addi	sp,sp,-48
    80004cf8:	f406                	sd	ra,40(sp)
    80004cfa:	f022                	sd	s0,32(sp)
    80004cfc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004cfe:	fd840613          	addi	a2,s0,-40
    80004d02:	4581                	li	a1,0
    80004d04:	4501                	li	a0,0
    80004d06:	e21ff0ef          	jal	80004b26 <argfd>
    return -1;
    80004d0a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d0c:	02054363          	bltz	a0,80004d32 <sys_dup+0x3c>
    80004d10:	ec26                	sd	s1,24(sp)
    80004d12:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004d14:	fd843903          	ld	s2,-40(s0)
    80004d18:	854a                	mv	a0,s2
    80004d1a:	e65ff0ef          	jal	80004b7e <fdalloc>
    80004d1e:	84aa                	mv	s1,a0
    return -1;
    80004d20:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004d22:	00054d63          	bltz	a0,80004d3c <sys_dup+0x46>
  filedup(f);
    80004d26:	854a                	mv	a0,s2
    80004d28:	c3eff0ef          	jal	80004166 <filedup>
  return fd;
    80004d2c:	87a6                	mv	a5,s1
    80004d2e:	64e2                	ld	s1,24(sp)
    80004d30:	6942                	ld	s2,16(sp)
}
    80004d32:	853e                	mv	a0,a5
    80004d34:	70a2                	ld	ra,40(sp)
    80004d36:	7402                	ld	s0,32(sp)
    80004d38:	6145                	addi	sp,sp,48
    80004d3a:	8082                	ret
    80004d3c:	64e2                	ld	s1,24(sp)
    80004d3e:	6942                	ld	s2,16(sp)
    80004d40:	bfcd                	j	80004d32 <sys_dup+0x3c>

0000000080004d42 <sys_read>:
{
    80004d42:	7179                	addi	sp,sp,-48
    80004d44:	f406                	sd	ra,40(sp)
    80004d46:	f022                	sd	s0,32(sp)
    80004d48:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d4a:	fd840593          	addi	a1,s0,-40
    80004d4e:	4505                	li	a0,1
    80004d50:	bf1fd0ef          	jal	80002940 <argaddr>
  argint(2, &n);
    80004d54:	fe440593          	addi	a1,s0,-28
    80004d58:	4509                	li	a0,2
    80004d5a:	bcbfd0ef          	jal	80002924 <argint>
  if(argfd(0, 0, &f) < 0)
    80004d5e:	fe840613          	addi	a2,s0,-24
    80004d62:	4581                	li	a1,0
    80004d64:	4501                	li	a0,0
    80004d66:	dc1ff0ef          	jal	80004b26 <argfd>
    80004d6a:	87aa                	mv	a5,a0
    return -1;
    80004d6c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d6e:	0007ca63          	bltz	a5,80004d82 <sys_read+0x40>
  return fileread(f, p, n);
    80004d72:	fe442603          	lw	a2,-28(s0)
    80004d76:	fd843583          	ld	a1,-40(s0)
    80004d7a:	fe843503          	ld	a0,-24(s0)
    80004d7e:	d4eff0ef          	jal	800042cc <fileread>
}
    80004d82:	70a2                	ld	ra,40(sp)
    80004d84:	7402                	ld	s0,32(sp)
    80004d86:	6145                	addi	sp,sp,48
    80004d88:	8082                	ret

0000000080004d8a <sys_write>:
{
    80004d8a:	7179                	addi	sp,sp,-48
    80004d8c:	f406                	sd	ra,40(sp)
    80004d8e:	f022                	sd	s0,32(sp)
    80004d90:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d92:	fd840593          	addi	a1,s0,-40
    80004d96:	4505                	li	a0,1
    80004d98:	ba9fd0ef          	jal	80002940 <argaddr>
  argint(2, &n);
    80004d9c:	fe440593          	addi	a1,s0,-28
    80004da0:	4509                	li	a0,2
    80004da2:	b83fd0ef          	jal	80002924 <argint>
  if(argfd(0, 0, &f) < 0)
    80004da6:	fe840613          	addi	a2,s0,-24
    80004daa:	4581                	li	a1,0
    80004dac:	4501                	li	a0,0
    80004dae:	d79ff0ef          	jal	80004b26 <argfd>
    80004db2:	87aa                	mv	a5,a0
    return -1;
    80004db4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004db6:	0007ca63          	bltz	a5,80004dca <sys_write+0x40>
  return filewrite(f, p, n);
    80004dba:	fe442603          	lw	a2,-28(s0)
    80004dbe:	fd843583          	ld	a1,-40(s0)
    80004dc2:	fe843503          	ld	a0,-24(s0)
    80004dc6:	dc4ff0ef          	jal	8000438a <filewrite>
}
    80004dca:	70a2                	ld	ra,40(sp)
    80004dcc:	7402                	ld	s0,32(sp)
    80004dce:	6145                	addi	sp,sp,48
    80004dd0:	8082                	ret

0000000080004dd2 <sys_close>:
{
    80004dd2:	1101                	addi	sp,sp,-32
    80004dd4:	ec06                	sd	ra,24(sp)
    80004dd6:	e822                	sd	s0,16(sp)
    80004dd8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004dda:	fe040613          	addi	a2,s0,-32
    80004dde:	fec40593          	addi	a1,s0,-20
    80004de2:	4501                	li	a0,0
    80004de4:	d43ff0ef          	jal	80004b26 <argfd>
    return -1;
    80004de8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004dea:	02054063          	bltz	a0,80004e0a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004dee:	bbdfc0ef          	jal	800019aa <myproc>
    80004df2:	fec42783          	lw	a5,-20(s0)
    80004df6:	07e9                	addi	a5,a5,26
    80004df8:	078e                	slli	a5,a5,0x3
    80004dfa:	953e                	add	a0,a0,a5
    80004dfc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e00:	fe043503          	ld	a0,-32(s0)
    80004e04:	ba8ff0ef          	jal	800041ac <fileclose>
  return 0;
    80004e08:	4781                	li	a5,0
}
    80004e0a:	853e                	mv	a0,a5
    80004e0c:	60e2                	ld	ra,24(sp)
    80004e0e:	6442                	ld	s0,16(sp)
    80004e10:	6105                	addi	sp,sp,32
    80004e12:	8082                	ret

0000000080004e14 <sys_fstat>:
{
    80004e14:	1101                	addi	sp,sp,-32
    80004e16:	ec06                	sd	ra,24(sp)
    80004e18:	e822                	sd	s0,16(sp)
    80004e1a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e1c:	fe040593          	addi	a1,s0,-32
    80004e20:	4505                	li	a0,1
    80004e22:	b1ffd0ef          	jal	80002940 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004e26:	fe840613          	addi	a2,s0,-24
    80004e2a:	4581                	li	a1,0
    80004e2c:	4501                	li	a0,0
    80004e2e:	cf9ff0ef          	jal	80004b26 <argfd>
    80004e32:	87aa                	mv	a5,a0
    return -1;
    80004e34:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e36:	0007c863          	bltz	a5,80004e46 <sys_fstat+0x32>
  return filestat(f, st);
    80004e3a:	fe043583          	ld	a1,-32(s0)
    80004e3e:	fe843503          	ld	a0,-24(s0)
    80004e42:	c2cff0ef          	jal	8000426e <filestat>
}
    80004e46:	60e2                	ld	ra,24(sp)
    80004e48:	6442                	ld	s0,16(sp)
    80004e4a:	6105                	addi	sp,sp,32
    80004e4c:	8082                	ret

0000000080004e4e <sys_link>:
{
    80004e4e:	7169                	addi	sp,sp,-304
    80004e50:	f606                	sd	ra,296(sp)
    80004e52:	f222                	sd	s0,288(sp)
    80004e54:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e56:	08000613          	li	a2,128
    80004e5a:	ed040593          	addi	a1,s0,-304
    80004e5e:	4501                	li	a0,0
    80004e60:	afdfd0ef          	jal	8000295c <argstr>
    return -1;
    80004e64:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e66:	0c054e63          	bltz	a0,80004f42 <sys_link+0xf4>
    80004e6a:	08000613          	li	a2,128
    80004e6e:	f5040593          	addi	a1,s0,-176
    80004e72:	4505                	li	a0,1
    80004e74:	ae9fd0ef          	jal	8000295c <argstr>
    return -1;
    80004e78:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e7a:	0c054463          	bltz	a0,80004f42 <sys_link+0xf4>
    80004e7e:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e80:	f21fe0ef          	jal	80003da0 <begin_op>
  if((ip = namei(old)) == 0){
    80004e84:	ed040513          	addi	a0,s0,-304
    80004e88:	d45fe0ef          	jal	80003bcc <namei>
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	c53d                	beqz	a0,80004efc <sys_link+0xae>
  ilock(ip);
    80004e90:	d26fe0ef          	jal	800033b6 <ilock>
  if(ip->type == T_DIR){
    80004e94:	04449703          	lh	a4,68(s1)
    80004e98:	4785                	li	a5,1
    80004e9a:	06f70663          	beq	a4,a5,80004f06 <sys_link+0xb8>
    80004e9e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004ea0:	04a4d783          	lhu	a5,74(s1)
    80004ea4:	2785                	addiw	a5,a5,1
    80004ea6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	c56fe0ef          	jal	80003302 <iupdate>
  iunlock(ip);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	db2fe0ef          	jal	80003464 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004eb6:	fd040593          	addi	a1,s0,-48
    80004eba:	f5040513          	addi	a0,s0,-176
    80004ebe:	d29fe0ef          	jal	80003be6 <nameiparent>
    80004ec2:	892a                	mv	s2,a0
    80004ec4:	cd21                	beqz	a0,80004f1c <sys_link+0xce>
  ilock(dp);
    80004ec6:	cf0fe0ef          	jal	800033b6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004eca:	00092703          	lw	a4,0(s2)
    80004ece:	409c                	lw	a5,0(s1)
    80004ed0:	04f71363          	bne	a4,a5,80004f16 <sys_link+0xc8>
    80004ed4:	40d0                	lw	a2,4(s1)
    80004ed6:	fd040593          	addi	a1,s0,-48
    80004eda:	854a                	mv	a0,s2
    80004edc:	c57fe0ef          	jal	80003b32 <dirlink>
    80004ee0:	02054b63          	bltz	a0,80004f16 <sys_link+0xc8>
  iunlockput(dp);
    80004ee4:	854a                	mv	a0,s2
    80004ee6:	edafe0ef          	jal	800035c0 <iunlockput>
  iput(ip);
    80004eea:	8526                	mv	a0,s1
    80004eec:	e4cfe0ef          	jal	80003538 <iput>
  end_op();
    80004ef0:	f1bfe0ef          	jal	80003e0a <end_op>
  return 0;
    80004ef4:	4781                	li	a5,0
    80004ef6:	64f2                	ld	s1,280(sp)
    80004ef8:	6952                	ld	s2,272(sp)
    80004efa:	a0a1                	j	80004f42 <sys_link+0xf4>
    end_op();
    80004efc:	f0ffe0ef          	jal	80003e0a <end_op>
    return -1;
    80004f00:	57fd                	li	a5,-1
    80004f02:	64f2                	ld	s1,280(sp)
    80004f04:	a83d                	j	80004f42 <sys_link+0xf4>
    iunlockput(ip);
    80004f06:	8526                	mv	a0,s1
    80004f08:	eb8fe0ef          	jal	800035c0 <iunlockput>
    end_op();
    80004f0c:	efffe0ef          	jal	80003e0a <end_op>
    return -1;
    80004f10:	57fd                	li	a5,-1
    80004f12:	64f2                	ld	s1,280(sp)
    80004f14:	a03d                	j	80004f42 <sys_link+0xf4>
    iunlockput(dp);
    80004f16:	854a                	mv	a0,s2
    80004f18:	ea8fe0ef          	jal	800035c0 <iunlockput>
  ilock(ip);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	c98fe0ef          	jal	800033b6 <ilock>
  ip->nlink--;
    80004f22:	04a4d783          	lhu	a5,74(s1)
    80004f26:	37fd                	addiw	a5,a5,-1
    80004f28:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	bd4fe0ef          	jal	80003302 <iupdate>
  iunlockput(ip);
    80004f32:	8526                	mv	a0,s1
    80004f34:	e8cfe0ef          	jal	800035c0 <iunlockput>
  end_op();
    80004f38:	ed3fe0ef          	jal	80003e0a <end_op>
  return -1;
    80004f3c:	57fd                	li	a5,-1
    80004f3e:	64f2                	ld	s1,280(sp)
    80004f40:	6952                	ld	s2,272(sp)
}
    80004f42:	853e                	mv	a0,a5
    80004f44:	70b2                	ld	ra,296(sp)
    80004f46:	7412                	ld	s0,288(sp)
    80004f48:	6155                	addi	sp,sp,304
    80004f4a:	8082                	ret

0000000080004f4c <sys_unlink>:
{
    80004f4c:	7151                	addi	sp,sp,-240
    80004f4e:	f586                	sd	ra,232(sp)
    80004f50:	f1a2                	sd	s0,224(sp)
    80004f52:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004f54:	08000613          	li	a2,128
    80004f58:	f3040593          	addi	a1,s0,-208
    80004f5c:	4501                	li	a0,0
    80004f5e:	9fffd0ef          	jal	8000295c <argstr>
    80004f62:	16054063          	bltz	a0,800050c2 <sys_unlink+0x176>
    80004f66:	eda6                	sd	s1,216(sp)
  begin_op();
    80004f68:	e39fe0ef          	jal	80003da0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004f6c:	fb040593          	addi	a1,s0,-80
    80004f70:	f3040513          	addi	a0,s0,-208
    80004f74:	c73fe0ef          	jal	80003be6 <nameiparent>
    80004f78:	84aa                	mv	s1,a0
    80004f7a:	c945                	beqz	a0,8000502a <sys_unlink+0xde>
  ilock(dp);
    80004f7c:	c3afe0ef          	jal	800033b6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f80:	00002597          	auipc	a1,0x2
    80004f84:	64058593          	addi	a1,a1,1600 # 800075c0 <etext+0x5c0>
    80004f88:	fb040513          	addi	a0,s0,-80
    80004f8c:	9c5fe0ef          	jal	80003950 <namecmp>
    80004f90:	10050e63          	beqz	a0,800050ac <sys_unlink+0x160>
    80004f94:	00002597          	auipc	a1,0x2
    80004f98:	63458593          	addi	a1,a1,1588 # 800075c8 <etext+0x5c8>
    80004f9c:	fb040513          	addi	a0,s0,-80
    80004fa0:	9b1fe0ef          	jal	80003950 <namecmp>
    80004fa4:	10050463          	beqz	a0,800050ac <sys_unlink+0x160>
    80004fa8:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004faa:	f2c40613          	addi	a2,s0,-212
    80004fae:	fb040593          	addi	a1,s0,-80
    80004fb2:	8526                	mv	a0,s1
    80004fb4:	9b3fe0ef          	jal	80003966 <dirlookup>
    80004fb8:	892a                	mv	s2,a0
    80004fba:	0e050863          	beqz	a0,800050aa <sys_unlink+0x15e>
  ilock(ip);
    80004fbe:	bf8fe0ef          	jal	800033b6 <ilock>
  if(ip->nlink < 1)
    80004fc2:	04a91783          	lh	a5,74(s2)
    80004fc6:	06f05763          	blez	a5,80005034 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004fca:	04491703          	lh	a4,68(s2)
    80004fce:	4785                	li	a5,1
    80004fd0:	06f70963          	beq	a4,a5,80005042 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004fd4:	4641                	li	a2,16
    80004fd6:	4581                	li	a1,0
    80004fd8:	fc040513          	addi	a0,s0,-64
    80004fdc:	cc7fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fe0:	4741                	li	a4,16
    80004fe2:	f2c42683          	lw	a3,-212(s0)
    80004fe6:	fc040613          	addi	a2,s0,-64
    80004fea:	4581                	li	a1,0
    80004fec:	8526                	mv	a0,s1
    80004fee:	855fe0ef          	jal	80003842 <writei>
    80004ff2:	47c1                	li	a5,16
    80004ff4:	08f51b63          	bne	a0,a5,8000508a <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004ff8:	04491703          	lh	a4,68(s2)
    80004ffc:	4785                	li	a5,1
    80004ffe:	08f70d63          	beq	a4,a5,80005098 <sys_unlink+0x14c>
  iunlockput(dp);
    80005002:	8526                	mv	a0,s1
    80005004:	dbcfe0ef          	jal	800035c0 <iunlockput>
  ip->nlink--;
    80005008:	04a95783          	lhu	a5,74(s2)
    8000500c:	37fd                	addiw	a5,a5,-1
    8000500e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005012:	854a                	mv	a0,s2
    80005014:	aeefe0ef          	jal	80003302 <iupdate>
  iunlockput(ip);
    80005018:	854a                	mv	a0,s2
    8000501a:	da6fe0ef          	jal	800035c0 <iunlockput>
  end_op();
    8000501e:	dedfe0ef          	jal	80003e0a <end_op>
  return 0;
    80005022:	4501                	li	a0,0
    80005024:	64ee                	ld	s1,216(sp)
    80005026:	694e                	ld	s2,208(sp)
    80005028:	a849                	j	800050ba <sys_unlink+0x16e>
    end_op();
    8000502a:	de1fe0ef          	jal	80003e0a <end_op>
    return -1;
    8000502e:	557d                	li	a0,-1
    80005030:	64ee                	ld	s1,216(sp)
    80005032:	a061                	j	800050ba <sys_unlink+0x16e>
    80005034:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005036:	00002517          	auipc	a0,0x2
    8000503a:	59a50513          	addi	a0,a0,1434 # 800075d0 <etext+0x5d0>
    8000503e:	fa2fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005042:	04c92703          	lw	a4,76(s2)
    80005046:	02000793          	li	a5,32
    8000504a:	f8e7f5e3          	bgeu	a5,a4,80004fd4 <sys_unlink+0x88>
    8000504e:	e5ce                	sd	s3,200(sp)
    80005050:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005054:	4741                	li	a4,16
    80005056:	86ce                	mv	a3,s3
    80005058:	f1840613          	addi	a2,s0,-232
    8000505c:	4581                	li	a1,0
    8000505e:	854a                	mv	a0,s2
    80005060:	ee6fe0ef          	jal	80003746 <readi>
    80005064:	47c1                	li	a5,16
    80005066:	00f51c63          	bne	a0,a5,8000507e <sys_unlink+0x132>
    if(de.inum != 0)
    8000506a:	f1845783          	lhu	a5,-232(s0)
    8000506e:	efa1                	bnez	a5,800050c6 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005070:	29c1                	addiw	s3,s3,16
    80005072:	04c92783          	lw	a5,76(s2)
    80005076:	fcf9efe3          	bltu	s3,a5,80005054 <sys_unlink+0x108>
    8000507a:	69ae                	ld	s3,200(sp)
    8000507c:	bfa1                	j	80004fd4 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000507e:	00002517          	auipc	a0,0x2
    80005082:	56a50513          	addi	a0,a0,1386 # 800075e8 <etext+0x5e8>
    80005086:	f5afb0ef          	jal	800007e0 <panic>
    8000508a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000508c:	00002517          	auipc	a0,0x2
    80005090:	57450513          	addi	a0,a0,1396 # 80007600 <etext+0x600>
    80005094:	f4cfb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005098:	04a4d783          	lhu	a5,74(s1)
    8000509c:	37fd                	addiw	a5,a5,-1
    8000509e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050a2:	8526                	mv	a0,s1
    800050a4:	a5efe0ef          	jal	80003302 <iupdate>
    800050a8:	bfa9                	j	80005002 <sys_unlink+0xb6>
    800050aa:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800050ac:	8526                	mv	a0,s1
    800050ae:	d12fe0ef          	jal	800035c0 <iunlockput>
  end_op();
    800050b2:	d59fe0ef          	jal	80003e0a <end_op>
  return -1;
    800050b6:	557d                	li	a0,-1
    800050b8:	64ee                	ld	s1,216(sp)
}
    800050ba:	70ae                	ld	ra,232(sp)
    800050bc:	740e                	ld	s0,224(sp)
    800050be:	616d                	addi	sp,sp,240
    800050c0:	8082                	ret
    return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	bfdd                	j	800050ba <sys_unlink+0x16e>
    iunlockput(ip);
    800050c6:	854a                	mv	a0,s2
    800050c8:	cf8fe0ef          	jal	800035c0 <iunlockput>
    goto bad;
    800050cc:	694e                	ld	s2,208(sp)
    800050ce:	69ae                	ld	s3,200(sp)
    800050d0:	bff1                	j	800050ac <sys_unlink+0x160>

00000000800050d2 <sys_open>:

uint64
sys_open(void)
{
    800050d2:	7131                	addi	sp,sp,-192
    800050d4:	fd06                	sd	ra,184(sp)
    800050d6:	f922                	sd	s0,176(sp)
    800050d8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800050da:	f4c40593          	addi	a1,s0,-180
    800050de:	4505                	li	a0,1
    800050e0:	845fd0ef          	jal	80002924 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050e4:	08000613          	li	a2,128
    800050e8:	f5040593          	addi	a1,s0,-176
    800050ec:	4501                	li	a0,0
    800050ee:	86ffd0ef          	jal	8000295c <argstr>
    800050f2:	87aa                	mv	a5,a0
    return -1;
    800050f4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800050f6:	0a07c263          	bltz	a5,8000519a <sys_open+0xc8>
    800050fa:	f526                	sd	s1,168(sp)

  begin_op();
    800050fc:	ca5fe0ef          	jal	80003da0 <begin_op>

  if(omode & O_CREATE){
    80005100:	f4c42783          	lw	a5,-180(s0)
    80005104:	2007f793          	andi	a5,a5,512
    80005108:	c3d5                	beqz	a5,800051ac <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000510a:	4681                	li	a3,0
    8000510c:	4601                	li	a2,0
    8000510e:	4589                	li	a1,2
    80005110:	f5040513          	addi	a0,s0,-176
    80005114:	aa9ff0ef          	jal	80004bbc <create>
    80005118:	84aa                	mv	s1,a0
    if(ip == 0){
    8000511a:	c541                	beqz	a0,800051a2 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000511c:	04449703          	lh	a4,68(s1)
    80005120:	478d                	li	a5,3
    80005122:	00f71763          	bne	a4,a5,80005130 <sys_open+0x5e>
    80005126:	0464d703          	lhu	a4,70(s1)
    8000512a:	47a5                	li	a5,9
    8000512c:	0ae7ed63          	bltu	a5,a4,800051e6 <sys_open+0x114>
    80005130:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005132:	fd7fe0ef          	jal	80004108 <filealloc>
    80005136:	892a                	mv	s2,a0
    80005138:	c179                	beqz	a0,800051fe <sys_open+0x12c>
    8000513a:	ed4e                	sd	s3,152(sp)
    8000513c:	a43ff0ef          	jal	80004b7e <fdalloc>
    80005140:	89aa                	mv	s3,a0
    80005142:	0a054a63          	bltz	a0,800051f6 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005146:	04449703          	lh	a4,68(s1)
    8000514a:	478d                	li	a5,3
    8000514c:	0cf70263          	beq	a4,a5,80005210 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005150:	4789                	li	a5,2
    80005152:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005156:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000515a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000515e:	f4c42783          	lw	a5,-180(s0)
    80005162:	0017c713          	xori	a4,a5,1
    80005166:	8b05                	andi	a4,a4,1
    80005168:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000516c:	0037f713          	andi	a4,a5,3
    80005170:	00e03733          	snez	a4,a4
    80005174:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005178:	4007f793          	andi	a5,a5,1024
    8000517c:	c791                	beqz	a5,80005188 <sys_open+0xb6>
    8000517e:	04449703          	lh	a4,68(s1)
    80005182:	4789                	li	a5,2
    80005184:	08f70d63          	beq	a4,a5,8000521e <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005188:	8526                	mv	a0,s1
    8000518a:	adafe0ef          	jal	80003464 <iunlock>
  end_op();
    8000518e:	c7dfe0ef          	jal	80003e0a <end_op>

  return fd;
    80005192:	854e                	mv	a0,s3
    80005194:	74aa                	ld	s1,168(sp)
    80005196:	790a                	ld	s2,160(sp)
    80005198:	69ea                	ld	s3,152(sp)
}
    8000519a:	70ea                	ld	ra,184(sp)
    8000519c:	744a                	ld	s0,176(sp)
    8000519e:	6129                	addi	sp,sp,192
    800051a0:	8082                	ret
      end_op();
    800051a2:	c69fe0ef          	jal	80003e0a <end_op>
      return -1;
    800051a6:	557d                	li	a0,-1
    800051a8:	74aa                	ld	s1,168(sp)
    800051aa:	bfc5                	j	8000519a <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800051ac:	f5040513          	addi	a0,s0,-176
    800051b0:	a1dfe0ef          	jal	80003bcc <namei>
    800051b4:	84aa                	mv	s1,a0
    800051b6:	c11d                	beqz	a0,800051dc <sys_open+0x10a>
    ilock(ip);
    800051b8:	9fefe0ef          	jal	800033b6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800051bc:	04449703          	lh	a4,68(s1)
    800051c0:	4785                	li	a5,1
    800051c2:	f4f71de3          	bne	a4,a5,8000511c <sys_open+0x4a>
    800051c6:	f4c42783          	lw	a5,-180(s0)
    800051ca:	d3bd                	beqz	a5,80005130 <sys_open+0x5e>
      iunlockput(ip);
    800051cc:	8526                	mv	a0,s1
    800051ce:	bf2fe0ef          	jal	800035c0 <iunlockput>
      end_op();
    800051d2:	c39fe0ef          	jal	80003e0a <end_op>
      return -1;
    800051d6:	557d                	li	a0,-1
    800051d8:	74aa                	ld	s1,168(sp)
    800051da:	b7c1                	j	8000519a <sys_open+0xc8>
      end_op();
    800051dc:	c2ffe0ef          	jal	80003e0a <end_op>
      return -1;
    800051e0:	557d                	li	a0,-1
    800051e2:	74aa                	ld	s1,168(sp)
    800051e4:	bf5d                	j	8000519a <sys_open+0xc8>
    iunlockput(ip);
    800051e6:	8526                	mv	a0,s1
    800051e8:	bd8fe0ef          	jal	800035c0 <iunlockput>
    end_op();
    800051ec:	c1ffe0ef          	jal	80003e0a <end_op>
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	74aa                	ld	s1,168(sp)
    800051f4:	b75d                	j	8000519a <sys_open+0xc8>
      fileclose(f);
    800051f6:	854a                	mv	a0,s2
    800051f8:	fb5fe0ef          	jal	800041ac <fileclose>
    800051fc:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800051fe:	8526                	mv	a0,s1
    80005200:	bc0fe0ef          	jal	800035c0 <iunlockput>
    end_op();
    80005204:	c07fe0ef          	jal	80003e0a <end_op>
    return -1;
    80005208:	557d                	li	a0,-1
    8000520a:	74aa                	ld	s1,168(sp)
    8000520c:	790a                	ld	s2,160(sp)
    8000520e:	b771                	j	8000519a <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005210:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005214:	04649783          	lh	a5,70(s1)
    80005218:	02f91223          	sh	a5,36(s2)
    8000521c:	bf3d                	j	8000515a <sys_open+0x88>
    itrunc(ip);
    8000521e:	8526                	mv	a0,s1
    80005220:	a84fe0ef          	jal	800034a4 <itrunc>
    80005224:	b795                	j	80005188 <sys_open+0xb6>

0000000080005226 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005226:	7175                	addi	sp,sp,-144
    80005228:	e506                	sd	ra,136(sp)
    8000522a:	e122                	sd	s0,128(sp)
    8000522c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000522e:	b73fe0ef          	jal	80003da0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005232:	08000613          	li	a2,128
    80005236:	f7040593          	addi	a1,s0,-144
    8000523a:	4501                	li	a0,0
    8000523c:	f20fd0ef          	jal	8000295c <argstr>
    80005240:	02054363          	bltz	a0,80005266 <sys_mkdir+0x40>
    80005244:	4681                	li	a3,0
    80005246:	4601                	li	a2,0
    80005248:	4585                	li	a1,1
    8000524a:	f7040513          	addi	a0,s0,-144
    8000524e:	96fff0ef          	jal	80004bbc <create>
    80005252:	c911                	beqz	a0,80005266 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005254:	b6cfe0ef          	jal	800035c0 <iunlockput>
  end_op();
    80005258:	bb3fe0ef          	jal	80003e0a <end_op>
  return 0;
    8000525c:	4501                	li	a0,0
}
    8000525e:	60aa                	ld	ra,136(sp)
    80005260:	640a                	ld	s0,128(sp)
    80005262:	6149                	addi	sp,sp,144
    80005264:	8082                	ret
    end_op();
    80005266:	ba5fe0ef          	jal	80003e0a <end_op>
    return -1;
    8000526a:	557d                	li	a0,-1
    8000526c:	bfcd                	j	8000525e <sys_mkdir+0x38>

000000008000526e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000526e:	7135                	addi	sp,sp,-160
    80005270:	ed06                	sd	ra,152(sp)
    80005272:	e922                	sd	s0,144(sp)
    80005274:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005276:	b2bfe0ef          	jal	80003da0 <begin_op>
  argint(1, &major);
    8000527a:	f6c40593          	addi	a1,s0,-148
    8000527e:	4505                	li	a0,1
    80005280:	ea4fd0ef          	jal	80002924 <argint>
  argint(2, &minor);
    80005284:	f6840593          	addi	a1,s0,-152
    80005288:	4509                	li	a0,2
    8000528a:	e9afd0ef          	jal	80002924 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000528e:	08000613          	li	a2,128
    80005292:	f7040593          	addi	a1,s0,-144
    80005296:	4501                	li	a0,0
    80005298:	ec4fd0ef          	jal	8000295c <argstr>
    8000529c:	02054563          	bltz	a0,800052c6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800052a0:	f6841683          	lh	a3,-152(s0)
    800052a4:	f6c41603          	lh	a2,-148(s0)
    800052a8:	458d                	li	a1,3
    800052aa:	f7040513          	addi	a0,s0,-144
    800052ae:	90fff0ef          	jal	80004bbc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800052b2:	c911                	beqz	a0,800052c6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052b4:	b0cfe0ef          	jal	800035c0 <iunlockput>
  end_op();
    800052b8:	b53fe0ef          	jal	80003e0a <end_op>
  return 0;
    800052bc:	4501                	li	a0,0
}
    800052be:	60ea                	ld	ra,152(sp)
    800052c0:	644a                	ld	s0,144(sp)
    800052c2:	610d                	addi	sp,sp,160
    800052c4:	8082                	ret
    end_op();
    800052c6:	b45fe0ef          	jal	80003e0a <end_op>
    return -1;
    800052ca:	557d                	li	a0,-1
    800052cc:	bfcd                	j	800052be <sys_mknod+0x50>

00000000800052ce <sys_chdir>:

uint64
sys_chdir(void)
{
    800052ce:	7135                	addi	sp,sp,-160
    800052d0:	ed06                	sd	ra,152(sp)
    800052d2:	e922                	sd	s0,144(sp)
    800052d4:	e14a                	sd	s2,128(sp)
    800052d6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800052d8:	ed2fc0ef          	jal	800019aa <myproc>
    800052dc:	892a                	mv	s2,a0
  
  begin_op();
    800052de:	ac3fe0ef          	jal	80003da0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800052e2:	08000613          	li	a2,128
    800052e6:	f6040593          	addi	a1,s0,-160
    800052ea:	4501                	li	a0,0
    800052ec:	e70fd0ef          	jal	8000295c <argstr>
    800052f0:	04054363          	bltz	a0,80005336 <sys_chdir+0x68>
    800052f4:	e526                	sd	s1,136(sp)
    800052f6:	f6040513          	addi	a0,s0,-160
    800052fa:	8d3fe0ef          	jal	80003bcc <namei>
    800052fe:	84aa                	mv	s1,a0
    80005300:	c915                	beqz	a0,80005334 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005302:	8b4fe0ef          	jal	800033b6 <ilock>
  if(ip->type != T_DIR){
    80005306:	04449703          	lh	a4,68(s1)
    8000530a:	4785                	li	a5,1
    8000530c:	02f71963          	bne	a4,a5,8000533e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005310:	8526                	mv	a0,s1
    80005312:	952fe0ef          	jal	80003464 <iunlock>
  iput(p->cwd);
    80005316:	15093503          	ld	a0,336(s2)
    8000531a:	a1efe0ef          	jal	80003538 <iput>
  end_op();
    8000531e:	aedfe0ef          	jal	80003e0a <end_op>
  p->cwd = ip;
    80005322:	14993823          	sd	s1,336(s2)
  return 0;
    80005326:	4501                	li	a0,0
    80005328:	64aa                	ld	s1,136(sp)
}
    8000532a:	60ea                	ld	ra,152(sp)
    8000532c:	644a                	ld	s0,144(sp)
    8000532e:	690a                	ld	s2,128(sp)
    80005330:	610d                	addi	sp,sp,160
    80005332:	8082                	ret
    80005334:	64aa                	ld	s1,136(sp)
    end_op();
    80005336:	ad5fe0ef          	jal	80003e0a <end_op>
    return -1;
    8000533a:	557d                	li	a0,-1
    8000533c:	b7fd                	j	8000532a <sys_chdir+0x5c>
    iunlockput(ip);
    8000533e:	8526                	mv	a0,s1
    80005340:	a80fe0ef          	jal	800035c0 <iunlockput>
    end_op();
    80005344:	ac7fe0ef          	jal	80003e0a <end_op>
    return -1;
    80005348:	557d                	li	a0,-1
    8000534a:	64aa                	ld	s1,136(sp)
    8000534c:	bff9                	j	8000532a <sys_chdir+0x5c>

000000008000534e <sys_exec>:

uint64
sys_exec(void)
{
    8000534e:	7121                	addi	sp,sp,-448
    80005350:	ff06                	sd	ra,440(sp)
    80005352:	fb22                	sd	s0,432(sp)
    80005354:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005356:	e4840593          	addi	a1,s0,-440
    8000535a:	4505                	li	a0,1
    8000535c:	de4fd0ef          	jal	80002940 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005360:	08000613          	li	a2,128
    80005364:	f5040593          	addi	a1,s0,-176
    80005368:	4501                	li	a0,0
    8000536a:	df2fd0ef          	jal	8000295c <argstr>
    8000536e:	87aa                	mv	a5,a0
    return -1;
    80005370:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005372:	0c07c463          	bltz	a5,8000543a <sys_exec+0xec>
    80005376:	f726                	sd	s1,424(sp)
    80005378:	f34a                	sd	s2,416(sp)
    8000537a:	ef4e                	sd	s3,408(sp)
    8000537c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000537e:	10000613          	li	a2,256
    80005382:	4581                	li	a1,0
    80005384:	e5040513          	addi	a0,s0,-432
    80005388:	91bfb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000538c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005390:	89a6                	mv	s3,s1
    80005392:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005394:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005398:	00391513          	slli	a0,s2,0x3
    8000539c:	e4040593          	addi	a1,s0,-448
    800053a0:	e4843783          	ld	a5,-440(s0)
    800053a4:	953e                	add	a0,a0,a5
    800053a6:	cf4fd0ef          	jal	8000289a <fetchaddr>
    800053aa:	02054663          	bltz	a0,800053d6 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800053ae:	e4043783          	ld	a5,-448(s0)
    800053b2:	c3a9                	beqz	a5,800053f4 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800053b4:	f4afb0ef          	jal	80000afe <kalloc>
    800053b8:	85aa                	mv	a1,a0
    800053ba:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800053be:	cd01                	beqz	a0,800053d6 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053c0:	6605                	lui	a2,0x1
    800053c2:	e4043503          	ld	a0,-448(s0)
    800053c6:	d1efd0ef          	jal	800028e4 <fetchstr>
    800053ca:	00054663          	bltz	a0,800053d6 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800053ce:	0905                	addi	s2,s2,1
    800053d0:	09a1                	addi	s3,s3,8
    800053d2:	fd4913e3          	bne	s2,s4,80005398 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053d6:	f5040913          	addi	s2,s0,-176
    800053da:	6088                	ld	a0,0(s1)
    800053dc:	c931                	beqz	a0,80005430 <sys_exec+0xe2>
    kfree(argv[i]);
    800053de:	e3efb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053e2:	04a1                	addi	s1,s1,8
    800053e4:	ff249be3          	bne	s1,s2,800053da <sys_exec+0x8c>
  return -1;
    800053e8:	557d                	li	a0,-1
    800053ea:	74ba                	ld	s1,424(sp)
    800053ec:	791a                	ld	s2,416(sp)
    800053ee:	69fa                	ld	s3,408(sp)
    800053f0:	6a5a                	ld	s4,400(sp)
    800053f2:	a0a1                	j	8000543a <sys_exec+0xec>
      argv[i] = 0;
    800053f4:	0009079b          	sext.w	a5,s2
    800053f8:	078e                	slli	a5,a5,0x3
    800053fa:	fd078793          	addi	a5,a5,-48
    800053fe:	97a2                	add	a5,a5,s0
    80005400:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005404:	e5040593          	addi	a1,s0,-432
    80005408:	f5040513          	addi	a0,s0,-176
    8000540c:	ba8ff0ef          	jal	800047b4 <kexec>
    80005410:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005412:	f5040993          	addi	s3,s0,-176
    80005416:	6088                	ld	a0,0(s1)
    80005418:	c511                	beqz	a0,80005424 <sys_exec+0xd6>
    kfree(argv[i]);
    8000541a:	e02fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000541e:	04a1                	addi	s1,s1,8
    80005420:	ff349be3          	bne	s1,s3,80005416 <sys_exec+0xc8>
  return ret;
    80005424:	854a                	mv	a0,s2
    80005426:	74ba                	ld	s1,424(sp)
    80005428:	791a                	ld	s2,416(sp)
    8000542a:	69fa                	ld	s3,408(sp)
    8000542c:	6a5a                	ld	s4,400(sp)
    8000542e:	a031                	j	8000543a <sys_exec+0xec>
  return -1;
    80005430:	557d                	li	a0,-1
    80005432:	74ba                	ld	s1,424(sp)
    80005434:	791a                	ld	s2,416(sp)
    80005436:	69fa                	ld	s3,408(sp)
    80005438:	6a5a                	ld	s4,400(sp)
}
    8000543a:	70fa                	ld	ra,440(sp)
    8000543c:	745a                	ld	s0,432(sp)
    8000543e:	6139                	addi	sp,sp,448
    80005440:	8082                	ret

0000000080005442 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005442:	7139                	addi	sp,sp,-64
    80005444:	fc06                	sd	ra,56(sp)
    80005446:	f822                	sd	s0,48(sp)
    80005448:	f426                	sd	s1,40(sp)
    8000544a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000544c:	d5efc0ef          	jal	800019aa <myproc>
    80005450:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005452:	fd840593          	addi	a1,s0,-40
    80005456:	4501                	li	a0,0
    80005458:	ce8fd0ef          	jal	80002940 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000545c:	fc840593          	addi	a1,s0,-56
    80005460:	fd040513          	addi	a0,s0,-48
    80005464:	852ff0ef          	jal	800044b6 <pipealloc>
    return -1;
    80005468:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000546a:	0a054463          	bltz	a0,80005512 <sys_pipe+0xd0>
  fd0 = -1;
    8000546e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005472:	fd043503          	ld	a0,-48(s0)
    80005476:	f08ff0ef          	jal	80004b7e <fdalloc>
    8000547a:	fca42223          	sw	a0,-60(s0)
    8000547e:	08054163          	bltz	a0,80005500 <sys_pipe+0xbe>
    80005482:	fc843503          	ld	a0,-56(s0)
    80005486:	ef8ff0ef          	jal	80004b7e <fdalloc>
    8000548a:	fca42023          	sw	a0,-64(s0)
    8000548e:	06054063          	bltz	a0,800054ee <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005492:	4691                	li	a3,4
    80005494:	fc440613          	addi	a2,s0,-60
    80005498:	fd843583          	ld	a1,-40(s0)
    8000549c:	68a8                	ld	a0,80(s1)
    8000549e:	944fc0ef          	jal	800015e2 <copyout>
    800054a2:	00054e63          	bltz	a0,800054be <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800054a6:	4691                	li	a3,4
    800054a8:	fc040613          	addi	a2,s0,-64
    800054ac:	fd843583          	ld	a1,-40(s0)
    800054b0:	0591                	addi	a1,a1,4
    800054b2:	68a8                	ld	a0,80(s1)
    800054b4:	92efc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800054b8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800054ba:	04055c63          	bgez	a0,80005512 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800054be:	fc442783          	lw	a5,-60(s0)
    800054c2:	07e9                	addi	a5,a5,26
    800054c4:	078e                	slli	a5,a5,0x3
    800054c6:	97a6                	add	a5,a5,s1
    800054c8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800054cc:	fc042783          	lw	a5,-64(s0)
    800054d0:	07e9                	addi	a5,a5,26
    800054d2:	078e                	slli	a5,a5,0x3
    800054d4:	94be                	add	s1,s1,a5
    800054d6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800054da:	fd043503          	ld	a0,-48(s0)
    800054de:	ccffe0ef          	jal	800041ac <fileclose>
    fileclose(wf);
    800054e2:	fc843503          	ld	a0,-56(s0)
    800054e6:	cc7fe0ef          	jal	800041ac <fileclose>
    return -1;
    800054ea:	57fd                	li	a5,-1
    800054ec:	a01d                	j	80005512 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800054ee:	fc442783          	lw	a5,-60(s0)
    800054f2:	0007c763          	bltz	a5,80005500 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800054f6:	07e9                	addi	a5,a5,26
    800054f8:	078e                	slli	a5,a5,0x3
    800054fa:	97a6                	add	a5,a5,s1
    800054fc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005500:	fd043503          	ld	a0,-48(s0)
    80005504:	ca9fe0ef          	jal	800041ac <fileclose>
    fileclose(wf);
    80005508:	fc843503          	ld	a0,-56(s0)
    8000550c:	ca1fe0ef          	jal	800041ac <fileclose>
    return -1;
    80005510:	57fd                	li	a5,-1
}
    80005512:	853e                	mv	a0,a5
    80005514:	70e2                	ld	ra,56(sp)
    80005516:	7442                	ld	s0,48(sp)
    80005518:	74a2                	ld	s1,40(sp)
    8000551a:	6121                	addi	sp,sp,64
    8000551c:	8082                	ret
	...

0000000080005520 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005520:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005522:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005524:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005526:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005528:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000552a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000552c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000552e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005530:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005532:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005534:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005536:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005538:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000553a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000553c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000553e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005540:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005542:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005544:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005546:	a64fd0ef          	jal	800027aa <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000554a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000554c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000554e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005550:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005552:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005554:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005556:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005558:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000555a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000555c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000555e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005560:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005562:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005564:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005566:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005568:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000556a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000556c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000556e:	10200073          	sret
	...

000000008000557e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000557e:	1141                	addi	sp,sp,-16
    80005580:	e422                	sd	s0,8(sp)
    80005582:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005584:	0c0007b7          	lui	a5,0xc000
    80005588:	4705                	li	a4,1
    8000558a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000558c:	0c0007b7          	lui	a5,0xc000
    80005590:	c3d8                	sw	a4,4(a5)
}
    80005592:	6422                	ld	s0,8(sp)
    80005594:	0141                	addi	sp,sp,16
    80005596:	8082                	ret

0000000080005598 <plicinithart>:

void
plicinithart(void)
{
    80005598:	1141                	addi	sp,sp,-16
    8000559a:	e406                	sd	ra,8(sp)
    8000559c:	e022                	sd	s0,0(sp)
    8000559e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055a0:	bdefc0ef          	jal	8000197e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800055a4:	0085171b          	slliw	a4,a0,0x8
    800055a8:	0c0027b7          	lui	a5,0xc002
    800055ac:	97ba                	add	a5,a5,a4
    800055ae:	40200713          	li	a4,1026
    800055b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800055b6:	00d5151b          	slliw	a0,a0,0xd
    800055ba:	0c2017b7          	lui	a5,0xc201
    800055be:	97aa                	add	a5,a5,a0
    800055c0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800055c4:	60a2                	ld	ra,8(sp)
    800055c6:	6402                	ld	s0,0(sp)
    800055c8:	0141                	addi	sp,sp,16
    800055ca:	8082                	ret

00000000800055cc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800055cc:	1141                	addi	sp,sp,-16
    800055ce:	e406                	sd	ra,8(sp)
    800055d0:	e022                	sd	s0,0(sp)
    800055d2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055d4:	baafc0ef          	jal	8000197e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800055d8:	00d5151b          	slliw	a0,a0,0xd
    800055dc:	0c2017b7          	lui	a5,0xc201
    800055e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800055e2:	43c8                	lw	a0,4(a5)
    800055e4:	60a2                	ld	ra,8(sp)
    800055e6:	6402                	ld	s0,0(sp)
    800055e8:	0141                	addi	sp,sp,16
    800055ea:	8082                	ret

00000000800055ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800055ec:	1101                	addi	sp,sp,-32
    800055ee:	ec06                	sd	ra,24(sp)
    800055f0:	e822                	sd	s0,16(sp)
    800055f2:	e426                	sd	s1,8(sp)
    800055f4:	1000                	addi	s0,sp,32
    800055f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800055f8:	b86fc0ef          	jal	8000197e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800055fc:	00d5151b          	slliw	a0,a0,0xd
    80005600:	0c2017b7          	lui	a5,0xc201
    80005604:	97aa                	add	a5,a5,a0
    80005606:	c3c4                	sw	s1,4(a5)
}
    80005608:	60e2                	ld	ra,24(sp)
    8000560a:	6442                	ld	s0,16(sp)
    8000560c:	64a2                	ld	s1,8(sp)
    8000560e:	6105                	addi	sp,sp,32
    80005610:	8082                	ret

0000000080005612 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005612:	1141                	addi	sp,sp,-16
    80005614:	e406                	sd	ra,8(sp)
    80005616:	e022                	sd	s0,0(sp)
    80005618:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000561a:	479d                	li	a5,7
    8000561c:	04a7ca63          	blt	a5,a0,80005670 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005620:	0001b797          	auipc	a5,0x1b
    80005624:	41878793          	addi	a5,a5,1048 # 80020a38 <disk>
    80005628:	97aa                	add	a5,a5,a0
    8000562a:	0187c783          	lbu	a5,24(a5)
    8000562e:	e7b9                	bnez	a5,8000567c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005630:	00451693          	slli	a3,a0,0x4
    80005634:	0001b797          	auipc	a5,0x1b
    80005638:	40478793          	addi	a5,a5,1028 # 80020a38 <disk>
    8000563c:	6398                	ld	a4,0(a5)
    8000563e:	9736                	add	a4,a4,a3
    80005640:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005644:	6398                	ld	a4,0(a5)
    80005646:	9736                	add	a4,a4,a3
    80005648:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000564c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005650:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005654:	97aa                	add	a5,a5,a0
    80005656:	4705                	li	a4,1
    80005658:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000565c:	0001b517          	auipc	a0,0x1b
    80005660:	3f450513          	addi	a0,a0,1012 # 80020a50 <disk+0x18>
    80005664:	99dfc0ef          	jal	80002000 <wakeup>
}
    80005668:	60a2                	ld	ra,8(sp)
    8000566a:	6402                	ld	s0,0(sp)
    8000566c:	0141                	addi	sp,sp,16
    8000566e:	8082                	ret
    panic("free_desc 1");
    80005670:	00002517          	auipc	a0,0x2
    80005674:	fa050513          	addi	a0,a0,-96 # 80007610 <etext+0x610>
    80005678:	968fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000567c:	00002517          	auipc	a0,0x2
    80005680:	fa450513          	addi	a0,a0,-92 # 80007620 <etext+0x620>
    80005684:	95cfb0ef          	jal	800007e0 <panic>

0000000080005688 <virtio_disk_init>:
{
    80005688:	1101                	addi	sp,sp,-32
    8000568a:	ec06                	sd	ra,24(sp)
    8000568c:	e822                	sd	s0,16(sp)
    8000568e:	e426                	sd	s1,8(sp)
    80005690:	e04a                	sd	s2,0(sp)
    80005692:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005694:	00002597          	auipc	a1,0x2
    80005698:	f9c58593          	addi	a1,a1,-100 # 80007630 <etext+0x630>
    8000569c:	0001b517          	auipc	a0,0x1b
    800056a0:	4c450513          	addi	a0,a0,1220 # 80020b60 <disk+0x128>
    800056a4:	caafb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056a8:	100017b7          	lui	a5,0x10001
    800056ac:	4398                	lw	a4,0(a5)
    800056ae:	2701                	sext.w	a4,a4
    800056b0:	747277b7          	lui	a5,0x74727
    800056b4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800056b8:	18f71063          	bne	a4,a5,80005838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056bc:	100017b7          	lui	a5,0x10001
    800056c0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800056c2:	439c                	lw	a5,0(a5)
    800056c4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056c6:	4709                	li	a4,2
    800056c8:	16e79863          	bne	a5,a4,80005838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056cc:	100017b7          	lui	a5,0x10001
    800056d0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800056d2:	439c                	lw	a5,0(a5)
    800056d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800056d6:	16e79163          	bne	a5,a4,80005838 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800056da:	100017b7          	lui	a5,0x10001
    800056de:	47d8                	lw	a4,12(a5)
    800056e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056e2:	554d47b7          	lui	a5,0x554d4
    800056e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800056ea:	14f71763          	bne	a4,a5,80005838 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056ee:	100017b7          	lui	a5,0x10001
    800056f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056f6:	4705                	li	a4,1
    800056f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056fa:	470d                	li	a4,3
    800056fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800056fe:	10001737          	lui	a4,0x10001
    80005702:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005704:	c7ffe737          	lui	a4,0xc7ffe
    80005708:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbe7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000570c:	8ef9                	and	a3,a3,a4
    8000570e:	10001737          	lui	a4,0x10001
    80005712:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005714:	472d                	li	a4,11
    80005716:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005718:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000571c:	439c                	lw	a5,0(a5)
    8000571e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005722:	8ba1                	andi	a5,a5,8
    80005724:	12078063          	beqz	a5,80005844 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005728:	100017b7          	lui	a5,0x10001
    8000572c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005730:	100017b7          	lui	a5,0x10001
    80005734:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005738:	439c                	lw	a5,0(a5)
    8000573a:	2781                	sext.w	a5,a5
    8000573c:	10079a63          	bnez	a5,80005850 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005740:	100017b7          	lui	a5,0x10001
    80005744:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005748:	439c                	lw	a5,0(a5)
    8000574a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000574c:	10078863          	beqz	a5,8000585c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005750:	471d                	li	a4,7
    80005752:	10f77b63          	bgeu	a4,a5,80005868 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005756:	ba8fb0ef          	jal	80000afe <kalloc>
    8000575a:	0001b497          	auipc	s1,0x1b
    8000575e:	2de48493          	addi	s1,s1,734 # 80020a38 <disk>
    80005762:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005764:	b9afb0ef          	jal	80000afe <kalloc>
    80005768:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000576a:	b94fb0ef          	jal	80000afe <kalloc>
    8000576e:	87aa                	mv	a5,a0
    80005770:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005772:	6088                	ld	a0,0(s1)
    80005774:	10050063          	beqz	a0,80005874 <virtio_disk_init+0x1ec>
    80005778:	0001b717          	auipc	a4,0x1b
    8000577c:	2c873703          	ld	a4,712(a4) # 80020a40 <disk+0x8>
    80005780:	0e070a63          	beqz	a4,80005874 <virtio_disk_init+0x1ec>
    80005784:	0e078863          	beqz	a5,80005874 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005788:	6605                	lui	a2,0x1
    8000578a:	4581                	li	a1,0
    8000578c:	d16fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005790:	0001b497          	auipc	s1,0x1b
    80005794:	2a848493          	addi	s1,s1,680 # 80020a38 <disk>
    80005798:	6605                	lui	a2,0x1
    8000579a:	4581                	li	a1,0
    8000579c:	6488                	ld	a0,8(s1)
    8000579e:	d04fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800057a2:	6605                	lui	a2,0x1
    800057a4:	4581                	li	a1,0
    800057a6:	6888                	ld	a0,16(s1)
    800057a8:	cfafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800057ac:	100017b7          	lui	a5,0x10001
    800057b0:	4721                	li	a4,8
    800057b2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800057b4:	4098                	lw	a4,0(s1)
    800057b6:	100017b7          	lui	a5,0x10001
    800057ba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800057be:	40d8                	lw	a4,4(s1)
    800057c0:	100017b7          	lui	a5,0x10001
    800057c4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800057c8:	649c                	ld	a5,8(s1)
    800057ca:	0007869b          	sext.w	a3,a5
    800057ce:	10001737          	lui	a4,0x10001
    800057d2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800057d6:	9781                	srai	a5,a5,0x20
    800057d8:	10001737          	lui	a4,0x10001
    800057dc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800057e0:	689c                	ld	a5,16(s1)
    800057e2:	0007869b          	sext.w	a3,a5
    800057e6:	10001737          	lui	a4,0x10001
    800057ea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800057ee:	9781                	srai	a5,a5,0x20
    800057f0:	10001737          	lui	a4,0x10001
    800057f4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800057f8:	10001737          	lui	a4,0x10001
    800057fc:	4785                	li	a5,1
    800057fe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005800:	00f48c23          	sb	a5,24(s1)
    80005804:	00f48ca3          	sb	a5,25(s1)
    80005808:	00f48d23          	sb	a5,26(s1)
    8000580c:	00f48da3          	sb	a5,27(s1)
    80005810:	00f48e23          	sb	a5,28(s1)
    80005814:	00f48ea3          	sb	a5,29(s1)
    80005818:	00f48f23          	sb	a5,30(s1)
    8000581c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005820:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005824:	100017b7          	lui	a5,0x10001
    80005828:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000582c:	60e2                	ld	ra,24(sp)
    8000582e:	6442                	ld	s0,16(sp)
    80005830:	64a2                	ld	s1,8(sp)
    80005832:	6902                	ld	s2,0(sp)
    80005834:	6105                	addi	sp,sp,32
    80005836:	8082                	ret
    panic("could not find virtio disk");
    80005838:	00002517          	auipc	a0,0x2
    8000583c:	e0850513          	addi	a0,a0,-504 # 80007640 <etext+0x640>
    80005840:	fa1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005844:	00002517          	auipc	a0,0x2
    80005848:	e1c50513          	addi	a0,a0,-484 # 80007660 <etext+0x660>
    8000584c:	f95fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005850:	00002517          	auipc	a0,0x2
    80005854:	e3050513          	addi	a0,a0,-464 # 80007680 <etext+0x680>
    80005858:	f89fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000585c:	00002517          	auipc	a0,0x2
    80005860:	e4450513          	addi	a0,a0,-444 # 800076a0 <etext+0x6a0>
    80005864:	f7dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005868:	00002517          	auipc	a0,0x2
    8000586c:	e5850513          	addi	a0,a0,-424 # 800076c0 <etext+0x6c0>
    80005870:	f71fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005874:	00002517          	auipc	a0,0x2
    80005878:	e6c50513          	addi	a0,a0,-404 # 800076e0 <etext+0x6e0>
    8000587c:	f65fa0ef          	jal	800007e0 <panic>

0000000080005880 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005880:	7159                	addi	sp,sp,-112
    80005882:	f486                	sd	ra,104(sp)
    80005884:	f0a2                	sd	s0,96(sp)
    80005886:	eca6                	sd	s1,88(sp)
    80005888:	e8ca                	sd	s2,80(sp)
    8000588a:	e4ce                	sd	s3,72(sp)
    8000588c:	e0d2                	sd	s4,64(sp)
    8000588e:	fc56                	sd	s5,56(sp)
    80005890:	f85a                	sd	s6,48(sp)
    80005892:	f45e                	sd	s7,40(sp)
    80005894:	f062                	sd	s8,32(sp)
    80005896:	ec66                	sd	s9,24(sp)
    80005898:	1880                	addi	s0,sp,112
    8000589a:	8a2a                	mv	s4,a0
    8000589c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000589e:	00c52c83          	lw	s9,12(a0)
    800058a2:	001c9c9b          	slliw	s9,s9,0x1
    800058a6:	1c82                	slli	s9,s9,0x20
    800058a8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800058ac:	0001b517          	auipc	a0,0x1b
    800058b0:	2b450513          	addi	a0,a0,692 # 80020b60 <disk+0x128>
    800058b4:	b1afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800058b8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800058ba:	44a1                	li	s1,8
      disk.free[i] = 0;
    800058bc:	0001bb17          	auipc	s6,0x1b
    800058c0:	17cb0b13          	addi	s6,s6,380 # 80020a38 <disk>
  for(int i = 0; i < 3; i++){
    800058c4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058c6:	0001bc17          	auipc	s8,0x1b
    800058ca:	29ac0c13          	addi	s8,s8,666 # 80020b60 <disk+0x128>
    800058ce:	a8b9                	j	8000592c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800058d0:	00fb0733          	add	a4,s6,a5
    800058d4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800058d8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800058da:	0207c563          	bltz	a5,80005904 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800058de:	2905                	addiw	s2,s2,1
    800058e0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058e2:	05590963          	beq	s2,s5,80005934 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800058e6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800058e8:	0001b717          	auipc	a4,0x1b
    800058ec:	15070713          	addi	a4,a4,336 # 80020a38 <disk>
    800058f0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800058f2:	01874683          	lbu	a3,24(a4)
    800058f6:	fee9                	bnez	a3,800058d0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800058f8:	2785                	addiw	a5,a5,1
    800058fa:	0705                	addi	a4,a4,1
    800058fc:	fe979be3          	bne	a5,s1,800058f2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005900:	57fd                	li	a5,-1
    80005902:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005904:	01205d63          	blez	s2,8000591e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005908:	f9042503          	lw	a0,-112(s0)
    8000590c:	d07ff0ef          	jal	80005612 <free_desc>
      for(int j = 0; j < i; j++)
    80005910:	4785                	li	a5,1
    80005912:	0127d663          	bge	a5,s2,8000591e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005916:	f9442503          	lw	a0,-108(s0)
    8000591a:	cf9ff0ef          	jal	80005612 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000591e:	85e2                	mv	a1,s8
    80005920:	0001b517          	auipc	a0,0x1b
    80005924:	13050513          	addi	a0,a0,304 # 80020a50 <disk+0x18>
    80005928:	e8cfc0ef          	jal	80001fb4 <sleep>
  for(int i = 0; i < 3; i++){
    8000592c:	f9040613          	addi	a2,s0,-112
    80005930:	894e                	mv	s2,s3
    80005932:	bf55                	j	800058e6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005934:	f9042503          	lw	a0,-112(s0)
    80005938:	00451693          	slli	a3,a0,0x4

  if(write)
    8000593c:	0001b797          	auipc	a5,0x1b
    80005940:	0fc78793          	addi	a5,a5,252 # 80020a38 <disk>
    80005944:	00a50713          	addi	a4,a0,10
    80005948:	0712                	slli	a4,a4,0x4
    8000594a:	973e                	add	a4,a4,a5
    8000594c:	01703633          	snez	a2,s7
    80005950:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005952:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005956:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000595a:	6398                	ld	a4,0(a5)
    8000595c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000595e:	0a868613          	addi	a2,a3,168
    80005962:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005964:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005966:	6390                	ld	a2,0(a5)
    80005968:	00d605b3          	add	a1,a2,a3
    8000596c:	4741                	li	a4,16
    8000596e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005970:	4805                	li	a6,1
    80005972:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005976:	f9442703          	lw	a4,-108(s0)
    8000597a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000597e:	0712                	slli	a4,a4,0x4
    80005980:	963a                	add	a2,a2,a4
    80005982:	058a0593          	addi	a1,s4,88
    80005986:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005988:	0007b883          	ld	a7,0(a5)
    8000598c:	9746                	add	a4,a4,a7
    8000598e:	40000613          	li	a2,1024
    80005992:	c710                	sw	a2,8(a4)
  if(write)
    80005994:	001bb613          	seqz	a2,s7
    80005998:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000599c:	00166613          	ori	a2,a2,1
    800059a0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800059a4:	f9842583          	lw	a1,-104(s0)
    800059a8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800059ac:	00250613          	addi	a2,a0,2
    800059b0:	0612                	slli	a2,a2,0x4
    800059b2:	963e                	add	a2,a2,a5
    800059b4:	577d                	li	a4,-1
    800059b6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800059ba:	0592                	slli	a1,a1,0x4
    800059bc:	98ae                	add	a7,a7,a1
    800059be:	03068713          	addi	a4,a3,48
    800059c2:	973e                	add	a4,a4,a5
    800059c4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800059c8:	6398                	ld	a4,0(a5)
    800059ca:	972e                	add	a4,a4,a1
    800059cc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800059d0:	4689                	li	a3,2
    800059d2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800059d6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800059da:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800059de:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800059e2:	6794                	ld	a3,8(a5)
    800059e4:	0026d703          	lhu	a4,2(a3)
    800059e8:	8b1d                	andi	a4,a4,7
    800059ea:	0706                	slli	a4,a4,0x1
    800059ec:	96ba                	add	a3,a3,a4
    800059ee:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800059f2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800059f6:	6798                	ld	a4,8(a5)
    800059f8:	00275783          	lhu	a5,2(a4)
    800059fc:	2785                	addiw	a5,a5,1
    800059fe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005a02:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a06:	100017b7          	lui	a5,0x10001
    80005a0a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005a0e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005a12:	0001b917          	auipc	s2,0x1b
    80005a16:	14e90913          	addi	s2,s2,334 # 80020b60 <disk+0x128>
  while(b->disk == 1) {
    80005a1a:	4485                	li	s1,1
    80005a1c:	01079a63          	bne	a5,a6,80005a30 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005a20:	85ca                	mv	a1,s2
    80005a22:	8552                	mv	a0,s4
    80005a24:	d90fc0ef          	jal	80001fb4 <sleep>
  while(b->disk == 1) {
    80005a28:	004a2783          	lw	a5,4(s4)
    80005a2c:	fe978ae3          	beq	a5,s1,80005a20 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005a30:	f9042903          	lw	s2,-112(s0)
    80005a34:	00290713          	addi	a4,s2,2
    80005a38:	0712                	slli	a4,a4,0x4
    80005a3a:	0001b797          	auipc	a5,0x1b
    80005a3e:	ffe78793          	addi	a5,a5,-2 # 80020a38 <disk>
    80005a42:	97ba                	add	a5,a5,a4
    80005a44:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005a48:	0001b997          	auipc	s3,0x1b
    80005a4c:	ff098993          	addi	s3,s3,-16 # 80020a38 <disk>
    80005a50:	00491713          	slli	a4,s2,0x4
    80005a54:	0009b783          	ld	a5,0(s3)
    80005a58:	97ba                	add	a5,a5,a4
    80005a5a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a5e:	854a                	mv	a0,s2
    80005a60:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a64:	bafff0ef          	jal	80005612 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005a68:	8885                	andi	s1,s1,1
    80005a6a:	f0fd                	bnez	s1,80005a50 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a6c:	0001b517          	auipc	a0,0x1b
    80005a70:	0f450513          	addi	a0,a0,244 # 80020b60 <disk+0x128>
    80005a74:	9f2fb0ef          	jal	80000c66 <release>
}
    80005a78:	70a6                	ld	ra,104(sp)
    80005a7a:	7406                	ld	s0,96(sp)
    80005a7c:	64e6                	ld	s1,88(sp)
    80005a7e:	6946                	ld	s2,80(sp)
    80005a80:	69a6                	ld	s3,72(sp)
    80005a82:	6a06                	ld	s4,64(sp)
    80005a84:	7ae2                	ld	s5,56(sp)
    80005a86:	7b42                	ld	s6,48(sp)
    80005a88:	7ba2                	ld	s7,40(sp)
    80005a8a:	7c02                	ld	s8,32(sp)
    80005a8c:	6ce2                	ld	s9,24(sp)
    80005a8e:	6165                	addi	sp,sp,112
    80005a90:	8082                	ret

0000000080005a92 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a92:	1101                	addi	sp,sp,-32
    80005a94:	ec06                	sd	ra,24(sp)
    80005a96:	e822                	sd	s0,16(sp)
    80005a98:	e426                	sd	s1,8(sp)
    80005a9a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a9c:	0001b497          	auipc	s1,0x1b
    80005aa0:	f9c48493          	addi	s1,s1,-100 # 80020a38 <disk>
    80005aa4:	0001b517          	auipc	a0,0x1b
    80005aa8:	0bc50513          	addi	a0,a0,188 # 80020b60 <disk+0x128>
    80005aac:	922fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ab0:	100017b7          	lui	a5,0x10001
    80005ab4:	53b8                	lw	a4,96(a5)
    80005ab6:	8b0d                	andi	a4,a4,3
    80005ab8:	100017b7          	lui	a5,0x10001
    80005abc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005abe:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005ac2:	689c                	ld	a5,16(s1)
    80005ac4:	0204d703          	lhu	a4,32(s1)
    80005ac8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005acc:	04f70663          	beq	a4,a5,80005b18 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005ad0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ad4:	6898                	ld	a4,16(s1)
    80005ad6:	0204d783          	lhu	a5,32(s1)
    80005ada:	8b9d                	andi	a5,a5,7
    80005adc:	078e                	slli	a5,a5,0x3
    80005ade:	97ba                	add	a5,a5,a4
    80005ae0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ae2:	00278713          	addi	a4,a5,2
    80005ae6:	0712                	slli	a4,a4,0x4
    80005ae8:	9726                	add	a4,a4,s1
    80005aea:	01074703          	lbu	a4,16(a4)
    80005aee:	e321                	bnez	a4,80005b2e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005af0:	0789                	addi	a5,a5,2
    80005af2:	0792                	slli	a5,a5,0x4
    80005af4:	97a6                	add	a5,a5,s1
    80005af6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005af8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005afc:	d04fc0ef          	jal	80002000 <wakeup>

    disk.used_idx += 1;
    80005b00:	0204d783          	lhu	a5,32(s1)
    80005b04:	2785                	addiw	a5,a5,1
    80005b06:	17c2                	slli	a5,a5,0x30
    80005b08:	93c1                	srli	a5,a5,0x30
    80005b0a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005b0e:	6898                	ld	a4,16(s1)
    80005b10:	00275703          	lhu	a4,2(a4)
    80005b14:	faf71ee3          	bne	a4,a5,80005ad0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b18:	0001b517          	auipc	a0,0x1b
    80005b1c:	04850513          	addi	a0,a0,72 # 80020b60 <disk+0x128>
    80005b20:	946fb0ef          	jal	80000c66 <release>
}
    80005b24:	60e2                	ld	ra,24(sp)
    80005b26:	6442                	ld	s0,16(sp)
    80005b28:	64a2                	ld	s1,8(sp)
    80005b2a:	6105                	addi	sp,sp,32
    80005b2c:	8082                	ret
      panic("virtio_disk_intr status");
    80005b2e:	00002517          	auipc	a0,0x2
    80005b32:	bca50513          	addi	a0,a0,-1078 # 800076f8 <etext+0x6f8>
    80005b36:	cabfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
