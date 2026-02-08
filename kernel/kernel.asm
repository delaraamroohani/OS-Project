
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9e010113          	addi	sp,sp,-1568 # 800089e0 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb6c7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	fc878793          	addi	a5,a5,-56 # 80001048 <main>
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
    80000112:	491020ef          	jal	80002da2 <either_copyin>
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
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	85450513          	addi	a0,a0,-1964 # 800109e0 <cons>
    80000194:	447000ef          	jal	80000dda <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00011497          	auipc	s1,0x11
    8000019c:	84848493          	addi	s1,s1,-1976 # 800109e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00011917          	auipc	s2,0x11
    800001a4:	8d890913          	addi	s2,s2,-1832 # 80010a78 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	3af010ef          	jal	80001d66 <myproc>
    800001bc:	279020ef          	jal	80002c34 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	7a4020ef          	jal	8000296a <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00011717          	auipc	a4,0x11
    800001dc:	80870713          	addi	a4,a4,-2040 # 800109e0 <cons>
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
    8000020a:	34f020ef          	jal	80002d58 <either_copyout>
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
    80000222:	00010517          	auipc	a0,0x10
    80000226:	7be50513          	addi	a0,a0,1982 # 800109e0 <cons>
    8000022a:	449000ef          	jal	80000e72 <release>
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
    8000024c:	00011717          	auipc	a4,0x11
    80000250:	82f72623          	sw	a5,-2004(a4) # 80010a78 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00010517          	auipc	a0,0x10
    80000266:	77e50513          	addi	a0,a0,1918 # 800109e0 <cons>
    8000026a:	409000ef          	jal	80000e72 <release>
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
    800002b6:	00010517          	auipc	a0,0x10
    800002ba:	72a50513          	addi	a0,a0,1834 # 800109e0 <cons>
    800002be:	31d000ef          	jal	80000dda <acquire>

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
    800002d8:	315020ef          	jal	80002dec <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00010517          	auipc	a0,0x10
    800002e0:	70450513          	addi	a0,a0,1796 # 800109e0 <cons>
    800002e4:	38f000ef          	jal	80000e72 <release>
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
    800002fa:	00010717          	auipc	a4,0x10
    800002fe:	6e670713          	addi	a4,a4,1766 # 800109e0 <cons>
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
    80000320:	00010797          	auipc	a5,0x10
    80000324:	6c078793          	addi	a5,a5,1728 # 800109e0 <cons>
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
    8000034e:	00010797          	auipc	a5,0x10
    80000352:	72a7a783          	lw	a5,1834(a5) # 80010a78 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00010717          	auipc	a4,0x10
    80000368:	67c70713          	addi	a4,a4,1660 # 800109e0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00010497          	auipc	s1,0x10
    80000378:	66c48493          	addi	s1,s1,1644 # 800109e0 <cons>
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
    800003b6:	00010717          	auipc	a4,0x10
    800003ba:	62a70713          	addi	a4,a4,1578 # 800109e0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00010717          	auipc	a4,0x10
    800003d0:	6af72a23          	sw	a5,1716(a4) # 80010a80 <cons+0xa0>
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
    800003ea:	00010797          	auipc	a5,0x10
    800003ee:	5f678793          	addi	a5,a5,1526 # 800109e0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	66c7a723          	sw	a2,1646(a5) # 80010a7c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00010517          	auipc	a0,0x10
    8000041a:	66250513          	addi	a0,a0,1634 # 80010a78 <cons+0x98>
    8000041e:	598020ef          	jal	800029b6 <wakeup>
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
    8000042c:	00008597          	auipc	a1,0x8
    80000430:	bd458593          	addi	a1,a1,-1068 # 80008000 <etext>
    80000434:	00010517          	auipc	a0,0x10
    80000438:	5ac50513          	addi	a0,a0,1452 # 800109e0 <cons>
    8000043c:	11f000ef          	jal	80000d5a <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00042797          	auipc	a5,0x42
    80000448:	94478793          	addi	a5,a5,-1724 # 80041d88 <devsw>
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
    8000047e:	00008617          	auipc	a2,0x8
    80000482:	39a60613          	addi	a2,a2,922 # 80008818 <digits>
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
    80000518:	00008797          	auipc	a5,0x8
    8000051c:	47c7a783          	lw	a5,1148(a5) # 80008994 <panicking>
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
    80000560:	00010517          	auipc	a0,0x10
    80000564:	52850513          	addi	a0,a0,1320 # 80010a88 <pr>
    80000568:	073000ef          	jal	80000dda <acquire>
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
    80000728:	00008b97          	auipc	s7,0x8
    8000072c:	0f0b8b93          	addi	s7,s7,240 # 80008818 <digits>
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
    80000788:	00008917          	auipc	s2,0x8
    8000078c:	88090913          	addi	s2,s2,-1920 # 80008008 <etext+0x8>
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
    800007bc:	00008797          	auipc	a5,0x8
    800007c0:	1d87a783          	lw	a5,472(a5) # 80008994 <panicking>
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
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	2b650513          	addi	a0,a0,694 # 80010a88 <pr>
    800007da:	698000ef          	jal	80000e72 <release>
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
    800007f0:	00008797          	auipc	a5,0x8
    800007f4:	1b27a223          	sw	s2,420(a5) # 80008994 <panicking>
  printf("panic: ");
    800007f8:	00008517          	auipc	a0,0x8
    800007fc:	82050513          	addi	a0,a0,-2016 # 80008018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00008517          	auipc	a0,0x8
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80008020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00008797          	auipc	a5,0x8
    80000816:	1727af23          	sw	s2,382(a5) # 80008990 <panicked>
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
    80000824:	00008597          	auipc	a1,0x8
    80000828:	80458593          	addi	a1,a1,-2044 # 80008028 <etext+0x28>
    8000082c:	00010517          	auipc	a0,0x10
    80000830:	25c50513          	addi	a0,a0,604 # 80010a88 <pr>
    80000834:	526000ef          	jal	80000d5a <initlock>
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
    8000087c:	00007597          	auipc	a1,0x7
    80000880:	7b458593          	addi	a1,a1,1972 # 80008030 <etext+0x30>
    80000884:	00010517          	auipc	a0,0x10
    80000888:	21c50513          	addi	a0,a0,540 # 80010aa0 <tx_lock>
    8000088c:	4ce000ef          	jal	80000d5a <initlock>
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
    800008a8:	00010517          	auipc	a0,0x10
    800008ac:	1f850513          	addi	a0,a0,504 # 80010aa0 <tx_lock>
    800008b0:	52a000ef          	jal	80000dda <acquire>

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
    800008c6:	00008497          	auipc	s1,0x8
    800008ca:	0d648493          	addi	s1,s1,214 # 8000899c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00010997          	auipc	s3,0x10
    800008d2:	1d298993          	addi	s3,s3,466 # 80010aa0 <tx_lock>
    800008d6:	00008917          	auipc	s2,0x8
    800008da:	0c290913          	addi	s2,s2,194 # 80008998 <tx_chan>
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
    800008ea:	080020ef          	jal	8000296a <sleep>
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
    80000914:	00010517          	auipc	a0,0x10
    80000918:	18c50513          	addi	a0,a0,396 # 80010aa0 <tx_lock>
    8000091c:	556000ef          	jal	80000e72 <release>
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
    80000938:	00008797          	auipc	a5,0x8
    8000093c:	05c7a783          	lw	a5,92(a5) # 80008994 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00008797          	auipc	a5,0x8
    80000946:	04e7a783          	lw	a5,78(a5) # 80008990 <panicked>
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
    80000968:	00008797          	auipc	a5,0x8
    8000096c:	02c7a783          	lw	a5,44(a5) # 80008994 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	41e000ef          	jal	80000d9a <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	49a000ef          	jal	80000e1e <pop_off>
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
    800009c4:	00010517          	auipc	a0,0x10
    800009c8:	0dc50513          	addi	a0,a0,220 # 80010aa0 <tx_lock>
    800009cc:	40e000ef          	jal	80000dda <acquire>
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
    800009e0:	00010517          	auipc	a0,0x10
    800009e4:	0c050513          	addi	a0,a0,192 # 80010aa0 <tx_lock>
    800009e8:	48a000ef          	jal	80000e72 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00008797          	auipc	a5,0x8
    800009f4:	fa07a623          	sw	zero,-84(a5) # 8000899c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00008517          	auipc	a0,0x8
    800009fc:	fa050513          	addi	a0,a0,-96 # 80008998 <tx_chan>
    80000a00:	7b7010ef          	jal	800029b6 <wakeup>
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

0000000080000a1c <kref_incr>:
  }
}
// Increment the reference count for a physical page
void
kref_incr(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	1000                	addi	s0,sp,32
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a26:	03451793          	slli	a5,a0,0x34
    80000a2a:	e7b9                	bnez	a5,80000a78 <kref_incr+0x5c>
    80000a2c:	84aa                	mv	s1,a0
    80000a2e:	00042797          	auipc	a5,0x42
    80000a32:	70a78793          	addi	a5,a5,1802 # 80043138 <end>
    80000a36:	04f56163          	bltu	a0,a5,80000a78 <kref_incr+0x5c>
    80000a3a:	47c5                	li	a5,17
    80000a3c:	07ee                	slli	a5,a5,0x1b
    80000a3e:	02f57d63          	bgeu	a0,a5,80000a78 <kref_incr+0x5c>
    panic("kref_incr");
  
  acquire(&pageref.lock);
    80000a42:	00010517          	auipc	a0,0x10
    80000a46:	09650513          	addi	a0,a0,150 # 80010ad8 <pageref>
    80000a4a:	390000ef          	jal	80000dda <acquire>
  pageref.count[PA2IDX(pa)]++;
    80000a4e:	800007b7          	lui	a5,0x80000
    80000a52:	97a6                	add	a5,a5,s1
    80000a54:	83b1                	srli	a5,a5,0xc
    80000a56:	00010517          	auipc	a0,0x10
    80000a5a:	08250513          	addi	a0,a0,130 # 80010ad8 <pageref>
    80000a5e:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbcecc>
    80000a60:	078a                	slli	a5,a5,0x2
    80000a62:	97aa                	add	a5,a5,a0
    80000a64:	4798                	lw	a4,8(a5)
    80000a66:	2705                	addiw	a4,a4,1
    80000a68:	c798                	sw	a4,8(a5)
  release(&pageref.lock);
    80000a6a:	408000ef          	jal	80000e72 <release>
}
    80000a6e:	60e2                	ld	ra,24(sp)
    80000a70:	6442                	ld	s0,16(sp)
    80000a72:	64a2                	ld	s1,8(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kref_incr");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5c050513          	addi	a0,a0,1472 # 80008038 <etext+0x38>
    80000a80:	d61ff0ef          	jal	800007e0 <panic>

0000000080000a84 <kref_decr>:

// Decrement the reference count and return the new count
int
kref_decr(void *pa)
{
    80000a84:	1101                	addi	sp,sp,-32
    80000a86:	ec06                	sd	ra,24(sp)
    80000a88:	e822                	sd	s0,16(sp)
    80000a8a:	e426                	sd	s1,8(sp)
    80000a8c:	1000                	addi	s0,sp,32
  int cnt;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a8e:	03451793          	slli	a5,a0,0x34
    80000a92:	ebb1                	bnez	a5,80000ae6 <kref_decr+0x62>
    80000a94:	84aa                	mv	s1,a0
    80000a96:	00042797          	auipc	a5,0x42
    80000a9a:	6a278793          	addi	a5,a5,1698 # 80043138 <end>
    80000a9e:	04f56463          	bltu	a0,a5,80000ae6 <kref_decr+0x62>
    80000aa2:	47c5                	li	a5,17
    80000aa4:	07ee                	slli	a5,a5,0x1b
    80000aa6:	04f57063          	bgeu	a0,a5,80000ae6 <kref_decr+0x62>
    panic("kref_decr");
  
  acquire(&pageref.lock);
    80000aaa:	00010517          	auipc	a0,0x10
    80000aae:	02e50513          	addi	a0,a0,46 # 80010ad8 <pageref>
    80000ab2:	328000ef          	jal	80000dda <acquire>
  cnt = --pageref.count[PA2IDX(pa)];
    80000ab6:	800007b7          	lui	a5,0x80000
    80000aba:	97a6                	add	a5,a5,s1
    80000abc:	83b1                	srli	a5,a5,0xc
    80000abe:	00010517          	auipc	a0,0x10
    80000ac2:	01a50513          	addi	a0,a0,26 # 80010ad8 <pageref>
    80000ac6:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbcecc>
    80000ac8:	078a                	slli	a5,a5,0x2
    80000aca:	97aa                	add	a5,a5,a0
    80000acc:	4798                	lw	a4,8(a5)
    80000ace:	377d                	addiw	a4,a4,-1
    80000ad0:	0007049b          	sext.w	s1,a4
    80000ad4:	c798                	sw	a4,8(a5)
  release(&pageref.lock);
    80000ad6:	39c000ef          	jal	80000e72 <release>
  return cnt;
}
    80000ada:	8526                	mv	a0,s1
    80000adc:	60e2                	ld	ra,24(sp)
    80000ade:	6442                	ld	s0,16(sp)
    80000ae0:	64a2                	ld	s1,8(sp)
    80000ae2:	6105                	addi	sp,sp,32
    80000ae4:	8082                	ret
    panic("kref_decr");
    80000ae6:	00007517          	auipc	a0,0x7
    80000aea:	56250513          	addi	a0,a0,1378 # 80008048 <etext+0x48>
    80000aee:	cf3ff0ef          	jal	800007e0 <panic>

0000000080000af2 <kref_get>:

// Get the reference count for a physical page
int
kref_get(void *pa)
{
    80000af2:	1101                	addi	sp,sp,-32
    80000af4:	ec06                	sd	ra,24(sp)
    80000af6:	e822                	sd	s0,16(sp)
    80000af8:	e04a                	sd	s2,0(sp)
    80000afa:	1000                	addi	s0,sp,32
  int cnt;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000afc:	03451793          	slli	a5,a0,0x34
    return 0;
    80000b00:	4901                	li	s2,0
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b02:	eba1                	bnez	a5,80000b52 <kref_get+0x60>
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	84aa                	mv	s1,a0
    80000b08:	00042797          	auipc	a5,0x42
    80000b0c:	63078793          	addi	a5,a5,1584 # 80043138 <end>
    return 0;
    80000b10:	4901                	li	s2,0
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b12:	02f56f63          	bltu	a0,a5,80000b50 <kref_get+0x5e>
    80000b16:	47c5                	li	a5,17
    80000b18:	07ee                	slli	a5,a5,0x1b
    80000b1a:	00f56463          	bltu	a0,a5,80000b22 <kref_get+0x30>
    80000b1e:	64a2                	ld	s1,8(sp)
    80000b20:	a80d                	j	80000b52 <kref_get+0x60>
  
  acquire(&pageref.lock);
    80000b22:	00010517          	auipc	a0,0x10
    80000b26:	fb650513          	addi	a0,a0,-74 # 80010ad8 <pageref>
    80000b2a:	2b0000ef          	jal	80000dda <acquire>
  cnt = pageref.count[PA2IDX(pa)];
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	faa50513          	addi	a0,a0,-86 # 80010ad8 <pageref>
    80000b36:	800007b7          	lui	a5,0x80000
    80000b3a:	97a6                	add	a5,a5,s1
    80000b3c:	83b1                	srli	a5,a5,0xc
    80000b3e:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbcecc>
    80000b40:	078a                	slli	a5,a5,0x2
    80000b42:	97aa                	add	a5,a5,a0
    80000b44:	0087a903          	lw	s2,8(a5)
  release(&pageref.lock);
    80000b48:	32a000ef          	jal	80000e72 <release>
  return cnt;
    80000b4c:	64a2                	ld	s1,8(sp)
    80000b4e:	a011                	j	80000b52 <kref_get+0x60>
    80000b50:	64a2                	ld	s1,8(sp)
}
    80000b52:	854a                	mv	a0,s2
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	6902                	ld	s2,0(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret

0000000080000b5e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b68:	03451793          	slli	a5,a0,0x34
    80000b6c:	ebc1                	bnez	a5,80000bfc <kfree+0x9e>
    80000b6e:	84aa                	mv	s1,a0
    80000b70:	00042797          	auipc	a5,0x42
    80000b74:	5c878793          	addi	a5,a5,1480 # 80043138 <end>
    80000b78:	08f56263          	bltu	a0,a5,80000bfc <kfree+0x9e>
    80000b7c:	47c5                	li	a5,17
    80000b7e:	07ee                	slli	a5,a5,0x1b
    80000b80:	06f57e63          	bgeu	a0,a5,80000bfc <kfree+0x9e>
    panic("kfree");


// Only free if reference count reaches 0
  acquire(&pageref.lock);
    80000b84:	00010517          	auipc	a0,0x10
    80000b88:	f5450513          	addi	a0,a0,-172 # 80010ad8 <pageref>
    80000b8c:	24e000ef          	jal	80000dda <acquire>
  if(pageref.count[PA2IDX(pa)] > 1) {
    80000b90:	800007b7          	lui	a5,0x80000
    80000b94:	97a6                	add	a5,a5,s1
    80000b96:	83b1                	srli	a5,a5,0xc
    80000b98:	00478693          	addi	a3,a5,4 # ffffffff80000004 <end+0xfffffffefffbcecc>
    80000b9c:	068a                	slli	a3,a3,0x2
    80000b9e:	00010717          	auipc	a4,0x10
    80000ba2:	f3a70713          	addi	a4,a4,-198 # 80010ad8 <pageref>
    80000ba6:	9736                	add	a4,a4,a3
    80000ba8:	4718                	lw	a4,8(a4)
    80000baa:	4685                	li	a3,1
    80000bac:	04e6cf63          	blt	a3,a4,80000c0a <kfree+0xac>
    80000bb0:	e04a                	sd	s2,0(sp)
    pageref.count[PA2IDX(pa)]--;
    release(&pageref.lock);
    return;
  }
  pageref.count[PA2IDX(pa)] = 0;
    80000bb2:	00010517          	auipc	a0,0x10
    80000bb6:	f2650513          	addi	a0,a0,-218 # 80010ad8 <pageref>
    80000bba:	0791                	addi	a5,a5,4
    80000bbc:	078a                	slli	a5,a5,0x2
    80000bbe:	97aa                	add	a5,a5,a0
    80000bc0:	0007a423          	sw	zero,8(a5)
  release(&pageref.lock);
    80000bc4:	2ae000ef          	jal	80000e72 <release>


  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000bc8:	6605                	lui	a2,0x1
    80000bca:	4585                	li	a1,1
    80000bcc:	8526                	mv	a0,s1
    80000bce:	2e0000ef          	jal	80000eae <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000bd2:	00010917          	auipc	s2,0x10
    80000bd6:	ee690913          	addi	s2,s2,-282 # 80010ab8 <kmem>
    80000bda:	854a                	mv	a0,s2
    80000bdc:	1fe000ef          	jal	80000dda <acquire>
  r->next = kmem.freelist;
    80000be0:	01893783          	ld	a5,24(s2)
    80000be4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000be6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000bea:	854a                	mv	a0,s2
    80000bec:	286000ef          	jal	80000e72 <release>
    80000bf0:	6902                	ld	s2,0(sp)
}
    80000bf2:	60e2                	ld	ra,24(sp)
    80000bf4:	6442                	ld	s0,16(sp)
    80000bf6:	64a2                	ld	s1,8(sp)
    80000bf8:	6105                	addi	sp,sp,32
    80000bfa:	8082                	ret
    80000bfc:	e04a                	sd	s2,0(sp)
    panic("kfree");
    80000bfe:	00007517          	auipc	a0,0x7
    80000c02:	45a50513          	addi	a0,a0,1114 # 80008058 <etext+0x58>
    80000c06:	bdbff0ef          	jal	800007e0 <panic>
    pageref.count[PA2IDX(pa)]--;
    80000c0a:	00010517          	auipc	a0,0x10
    80000c0e:	ece50513          	addi	a0,a0,-306 # 80010ad8 <pageref>
    80000c12:	0791                	addi	a5,a5,4
    80000c14:	078a                	slli	a5,a5,0x2
    80000c16:	97aa                	add	a5,a5,a0
    80000c18:	377d                	addiw	a4,a4,-1
    80000c1a:	c798                	sw	a4,8(a5)
    release(&pageref.lock);
    80000c1c:	256000ef          	jal	80000e72 <release>
    return;
    80000c20:	bfc9                	j	80000bf2 <kfree+0x94>

0000000080000c22 <freerange>:
{
    80000c22:	715d                	addi	sp,sp,-80
    80000c24:	e486                	sd	ra,72(sp)
    80000c26:	e0a2                	sd	s0,64(sp)
    80000c28:	fc26                	sd	s1,56(sp)
    80000c2a:	0880                	addi	s0,sp,80
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000c2c:	6785                	lui	a5,0x1
    80000c2e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000c32:	00e504b3          	add	s1,a0,a4
    80000c36:	777d                	lui	a4,0xfffff
    80000c38:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000c3a:	94be                	add	s1,s1,a5
    80000c3c:	0495e963          	bltu	a1,s1,80000c8e <freerange+0x6c>
    80000c40:	f84a                	sd	s2,48(sp)
    80000c42:	f44e                	sd	s3,40(sp)
    80000c44:	f052                	sd	s4,32(sp)
    80000c46:	ec56                	sd	s5,24(sp)
    80000c48:	e85a                	sd	s6,16(sp)
    80000c4a:	e45e                	sd	s7,8(sp)
    80000c4c:	89ae                	mv	s3,a1
    pageref.count[PA2IDX(p)] = 1; // Initialize reference count to 1  
    80000c4e:	00010b97          	auipc	s7,0x10
    80000c52:	e8ab8b93          	addi	s7,s7,-374 # 80010ad8 <pageref>
    80000c56:	fff80937          	lui	s2,0xfff80
    80000c5a:	197d                	addi	s2,s2,-1 # fffffffffff7ffff <end+0xffffffff7ff3cec7>
    80000c5c:	0932                	slli	s2,s2,0xc
    80000c5e:	4b05                	li	s6,1
    kfree(p);
    80000c60:	7afd                	lui	s5,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000c62:	6a05                	lui	s4,0x1
    pageref.count[PA2IDX(p)] = 1; // Initialize reference count to 1  
    80000c64:	012487b3          	add	a5,s1,s2
    80000c68:	83b1                	srli	a5,a5,0xc
    80000c6a:	0791                	addi	a5,a5,4
    80000c6c:	078a                	slli	a5,a5,0x2
    80000c6e:	97de                	add	a5,a5,s7
    80000c70:	0167a423          	sw	s6,8(a5)
    kfree(p);
    80000c74:	01548533          	add	a0,s1,s5
    80000c78:	ee7ff0ef          	jal	80000b5e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000c7c:	94d2                	add	s1,s1,s4
    80000c7e:	fe99f3e3          	bgeu	s3,s1,80000c64 <freerange+0x42>
    80000c82:	7942                	ld	s2,48(sp)
    80000c84:	79a2                	ld	s3,40(sp)
    80000c86:	7a02                	ld	s4,32(sp)
    80000c88:	6ae2                	ld	s5,24(sp)
    80000c8a:	6b42                	ld	s6,16(sp)
    80000c8c:	6ba2                	ld	s7,8(sp)
}
    80000c8e:	60a6                	ld	ra,72(sp)
    80000c90:	6406                	ld	s0,64(sp)
    80000c92:	74e2                	ld	s1,56(sp)
    80000c94:	6161                	addi	sp,sp,80
    80000c96:	8082                	ret

0000000080000c98 <kinit>:
{
    80000c98:	1141                	addi	sp,sp,-16
    80000c9a:	e406                	sd	ra,8(sp)
    80000c9c:	e022                	sd	s0,0(sp)
    80000c9e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ca0:	00007597          	auipc	a1,0x7
    80000ca4:	3c058593          	addi	a1,a1,960 # 80008060 <etext+0x60>
    80000ca8:	00010517          	auipc	a0,0x10
    80000cac:	e1050513          	addi	a0,a0,-496 # 80010ab8 <kmem>
    80000cb0:	0aa000ef          	jal	80000d5a <initlock>
  initlock(&pageref.lock, "pageref");
    80000cb4:	00007597          	auipc	a1,0x7
    80000cb8:	3b458593          	addi	a1,a1,948 # 80008068 <etext+0x68>
    80000cbc:	00010517          	auipc	a0,0x10
    80000cc0:	e1c50513          	addi	a0,a0,-484 # 80010ad8 <pageref>
    80000cc4:	096000ef          	jal	80000d5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000cc8:	45c5                	li	a1,17
    80000cca:	05ee                	slli	a1,a1,0x1b
    80000ccc:	00042517          	auipc	a0,0x42
    80000cd0:	46c50513          	addi	a0,a0,1132 # 80043138 <end>
    80000cd4:	f4fff0ef          	jal	80000c22 <freerange>
}
    80000cd8:	60a2                	ld	ra,8(sp)
    80000cda:	6402                	ld	s0,0(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ce0:	1101                	addi	sp,sp,-32
    80000ce2:	ec06                	sd	ra,24(sp)
    80000ce4:	e822                	sd	s0,16(sp)
    80000ce6:	e426                	sd	s1,8(sp)
    80000ce8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000cea:	00010497          	auipc	s1,0x10
    80000cee:	dce48493          	addi	s1,s1,-562 # 80010ab8 <kmem>
    80000cf2:	8526                	mv	a0,s1
    80000cf4:	0e6000ef          	jal	80000dda <acquire>
  r = kmem.freelist;
    80000cf8:	6c84                	ld	s1,24(s1)
  if(r)
    80000cfa:	c8a9                	beqz	s1,80000d4c <kalloc+0x6c>
    kmem.freelist = r->next;
    80000cfc:	609c                	ld	a5,0(s1)
    80000cfe:	00010517          	auipc	a0,0x10
    80000d02:	dba50513          	addi	a0,a0,-582 # 80010ab8 <kmem>
    80000d06:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000d08:	16a000ef          	jal	80000e72 <release>

  if(r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000d0c:	6605                	lui	a2,0x1
    80000d0e:	4595                	li	a1,5
    80000d10:	8526                	mv	a0,s1
    80000d12:	19c000ef          	jal	80000eae <memset>
    // Initialize reference count to 1
    acquire(&pageref.lock);
    80000d16:	00010517          	auipc	a0,0x10
    80000d1a:	dc250513          	addi	a0,a0,-574 # 80010ad8 <pageref>
    80000d1e:	0bc000ef          	jal	80000dda <acquire>
    pageref.count[PA2IDX(r)] = 1;
    80000d22:	00010517          	auipc	a0,0x10
    80000d26:	db650513          	addi	a0,a0,-586 # 80010ad8 <pageref>
    80000d2a:	800007b7          	lui	a5,0x80000
    80000d2e:	97a6                	add	a5,a5,s1
    80000d30:	83b1                	srli	a5,a5,0xc
    80000d32:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbcecc>
    80000d34:	078a                	slli	a5,a5,0x2
    80000d36:	97aa                	add	a5,a5,a0
    80000d38:	4705                	li	a4,1
    80000d3a:	c798                	sw	a4,8(a5)
    release(&pageref.lock);
    80000d3c:	136000ef          	jal	80000e72 <release>
  }
  return (void*)r;
}
    80000d40:	8526                	mv	a0,s1
    80000d42:	60e2                	ld	ra,24(sp)
    80000d44:	6442                	ld	s0,16(sp)
    80000d46:	64a2                	ld	s1,8(sp)
    80000d48:	6105                	addi	sp,sp,32
    80000d4a:	8082                	ret
  release(&kmem.lock);
    80000d4c:	00010517          	auipc	a0,0x10
    80000d50:	d6c50513          	addi	a0,a0,-660 # 80010ab8 <kmem>
    80000d54:	11e000ef          	jal	80000e72 <release>
  if(r) {
    80000d58:	b7e5                	j	80000d40 <kalloc+0x60>

0000000080000d5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e422                	sd	s0,8(sp)
    80000d5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d66:	00053823          	sd	zero,16(a0)
}
    80000d6a:	6422                	ld	s0,8(sp)
    80000d6c:	0141                	addi	sp,sp,16
    80000d6e:	8082                	ret

0000000080000d70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d70:	411c                	lw	a5,0(a0)
    80000d72:	e399                	bnez	a5,80000d78 <holding+0x8>
    80000d74:	4501                	li	a0,0
  return r;
}
    80000d76:	8082                	ret
{
    80000d78:	1101                	addi	sp,sp,-32
    80000d7a:	ec06                	sd	ra,24(sp)
    80000d7c:	e822                	sd	s0,16(sp)
    80000d7e:	e426                	sd	s1,8(sp)
    80000d80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d82:	6904                	ld	s1,16(a0)
    80000d84:	7c7000ef          	jal	80001d4a <mycpu>
    80000d88:	40a48533          	sub	a0,s1,a0
    80000d8c:	00153513          	seqz	a0,a0
}
    80000d90:	60e2                	ld	ra,24(sp)
    80000d92:	6442                	ld	s0,16(sp)
    80000d94:	64a2                	ld	s1,8(sp)
    80000d96:	6105                	addi	sp,sp,32
    80000d98:	8082                	ret

0000000080000d9a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d9a:	1101                	addi	sp,sp,-32
    80000d9c:	ec06                	sd	ra,24(sp)
    80000d9e:	e822                	sd	s0,16(sp)
    80000da0:	e426                	sd	s1,8(sp)
    80000da2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000da4:	100024f3          	csrr	s1,sstatus
    80000da8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000dac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000dae:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000db2:	799000ef          	jal	80001d4a <mycpu>
    80000db6:	5d3c                	lw	a5,120(a0)
    80000db8:	cb99                	beqz	a5,80000dce <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000dba:	791000ef          	jal	80001d4a <mycpu>
    80000dbe:	5d3c                	lw	a5,120(a0)
    80000dc0:	2785                	addiw	a5,a5,1
    80000dc2:	dd3c                	sw	a5,120(a0)
}
    80000dc4:	60e2                	ld	ra,24(sp)
    80000dc6:	6442                	ld	s0,16(sp)
    80000dc8:	64a2                	ld	s1,8(sp)
    80000dca:	6105                	addi	sp,sp,32
    80000dcc:	8082                	ret
    mycpu()->intena = old;
    80000dce:	77d000ef          	jal	80001d4a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000dd2:	8085                	srli	s1,s1,0x1
    80000dd4:	8885                	andi	s1,s1,1
    80000dd6:	dd64                	sw	s1,124(a0)
    80000dd8:	b7cd                	j	80000dba <push_off+0x20>

0000000080000dda <acquire>:
{
    80000dda:	1101                	addi	sp,sp,-32
    80000ddc:	ec06                	sd	ra,24(sp)
    80000dde:	e822                	sd	s0,16(sp)
    80000de0:	e426                	sd	s1,8(sp)
    80000de2:	1000                	addi	s0,sp,32
    80000de4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000de6:	fb5ff0ef          	jal	80000d9a <push_off>
  if(holding(lk))
    80000dea:	8526                	mv	a0,s1
    80000dec:	f85ff0ef          	jal	80000d70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000df0:	4705                	li	a4,1
  if(holding(lk))
    80000df2:	e105                	bnez	a0,80000e12 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000df4:	87ba                	mv	a5,a4
    80000df6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dfa:	2781                	sext.w	a5,a5
    80000dfc:	ffe5                	bnez	a5,80000df4 <acquire+0x1a>
  __sync_synchronize();
    80000dfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e02:	749000ef          	jal	80001d4a <mycpu>
    80000e06:	e888                	sd	a0,16(s1)
}
    80000e08:	60e2                	ld	ra,24(sp)
    80000e0a:	6442                	ld	s0,16(sp)
    80000e0c:	64a2                	ld	s1,8(sp)
    80000e0e:	6105                	addi	sp,sp,32
    80000e10:	8082                	ret
    panic("acquire");
    80000e12:	00007517          	auipc	a0,0x7
    80000e16:	25e50513          	addi	a0,a0,606 # 80008070 <etext+0x70>
    80000e1a:	9c7ff0ef          	jal	800007e0 <panic>

0000000080000e1e <pop_off>:

void
pop_off(void)
{
    80000e1e:	1141                	addi	sp,sp,-16
    80000e20:	e406                	sd	ra,8(sp)
    80000e22:	e022                	sd	s0,0(sp)
    80000e24:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e26:	725000ef          	jal	80001d4a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e2e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e30:	e78d                	bnez	a5,80000e5a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e32:	5d3c                	lw	a5,120(a0)
    80000e34:	02f05963          	blez	a5,80000e66 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000e38:	37fd                	addiw	a5,a5,-1
    80000e3a:	0007871b          	sext.w	a4,a5
    80000e3e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e40:	eb09                	bnez	a4,80000e52 <pop_off+0x34>
    80000e42:	5d7c                	lw	a5,124(a0)
    80000e44:	c799                	beqz	a5,80000e52 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e4e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e52:	60a2                	ld	ra,8(sp)
    80000e54:	6402                	ld	s0,0(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret
    panic("pop_off - interruptible");
    80000e5a:	00007517          	auipc	a0,0x7
    80000e5e:	21e50513          	addi	a0,a0,542 # 80008078 <etext+0x78>
    80000e62:	97fff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000e66:	00007517          	auipc	a0,0x7
    80000e6a:	22a50513          	addi	a0,a0,554 # 80008090 <etext+0x90>
    80000e6e:	973ff0ef          	jal	800007e0 <panic>

0000000080000e72 <release>:
{
    80000e72:	1101                	addi	sp,sp,-32
    80000e74:	ec06                	sd	ra,24(sp)
    80000e76:	e822                	sd	s0,16(sp)
    80000e78:	e426                	sd	s1,8(sp)
    80000e7a:	1000                	addi	s0,sp,32
    80000e7c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e7e:	ef3ff0ef          	jal	80000d70 <holding>
    80000e82:	c105                	beqz	a0,80000ea2 <release+0x30>
  lk->cpu = 0;
    80000e84:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e88:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e8c:	0f50000f          	fence	iorw,ow
    80000e90:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e94:	f8bff0ef          	jal	80000e1e <pop_off>
}
    80000e98:	60e2                	ld	ra,24(sp)
    80000e9a:	6442                	ld	s0,16(sp)
    80000e9c:	64a2                	ld	s1,8(sp)
    80000e9e:	6105                	addi	sp,sp,32
    80000ea0:	8082                	ret
    panic("release");
    80000ea2:	00007517          	auipc	a0,0x7
    80000ea6:	1f650513          	addi	a0,a0,502 # 80008098 <etext+0x98>
    80000eaa:	937ff0ef          	jal	800007e0 <panic>

0000000080000eae <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e422                	sd	s0,8(sp)
    80000eb2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000eb4:	ca19                	beqz	a2,80000eca <memset+0x1c>
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	1602                	slli	a2,a2,0x20
    80000eba:	9201                	srli	a2,a2,0x20
    80000ebc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ec0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ec4:	0785                	addi	a5,a5,1
    80000ec6:	fee79de3          	bne	a5,a4,80000ec0 <memset+0x12>
  }
  return dst;
}
    80000eca:	6422                	ld	s0,8(sp)
    80000ecc:	0141                	addi	sp,sp,16
    80000ece:	8082                	ret

0000000080000ed0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ed0:	1141                	addi	sp,sp,-16
    80000ed2:	e422                	sd	s0,8(sp)
    80000ed4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ed6:	ca05                	beqz	a2,80000f06 <memcmp+0x36>
    80000ed8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000edc:	1682                	slli	a3,a3,0x20
    80000ede:	9281                	srli	a3,a3,0x20
    80000ee0:	0685                	addi	a3,a3,1
    80000ee2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ee4:	00054783          	lbu	a5,0(a0)
    80000ee8:	0005c703          	lbu	a4,0(a1)
    80000eec:	00e79863          	bne	a5,a4,80000efc <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ef0:	0505                	addi	a0,a0,1
    80000ef2:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ef4:	fed518e3          	bne	a0,a3,80000ee4 <memcmp+0x14>
  }

  return 0;
    80000ef8:	4501                	li	a0,0
    80000efa:	a019                	j	80000f00 <memcmp+0x30>
      return *s1 - *s2;
    80000efc:	40e7853b          	subw	a0,a5,a4
}
    80000f00:	6422                	ld	s0,8(sp)
    80000f02:	0141                	addi	sp,sp,16
    80000f04:	8082                	ret
  return 0;
    80000f06:	4501                	li	a0,0
    80000f08:	bfe5                	j	80000f00 <memcmp+0x30>

0000000080000f0a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f0a:	1141                	addi	sp,sp,-16
    80000f0c:	e422                	sd	s0,8(sp)
    80000f0e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f10:	c205                	beqz	a2,80000f30 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f12:	02a5e263          	bltu	a1,a0,80000f36 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f16:	1602                	slli	a2,a2,0x20
    80000f18:	9201                	srli	a2,a2,0x20
    80000f1a:	00c587b3          	add	a5,a1,a2
{
    80000f1e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f20:	0585                	addi	a1,a1,1
    80000f22:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffbbec9>
    80000f24:	fff5c683          	lbu	a3,-1(a1)
    80000f28:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f2c:	feb79ae3          	bne	a5,a1,80000f20 <memmove+0x16>

  return dst;
}
    80000f30:	6422                	ld	s0,8(sp)
    80000f32:	0141                	addi	sp,sp,16
    80000f34:	8082                	ret
  if(s < d && s + n > d){
    80000f36:	02061693          	slli	a3,a2,0x20
    80000f3a:	9281                	srli	a3,a3,0x20
    80000f3c:	00d58733          	add	a4,a1,a3
    80000f40:	fce57be3          	bgeu	a0,a4,80000f16 <memmove+0xc>
    d += n;
    80000f44:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f46:	fff6079b          	addiw	a5,a2,-1
    80000f4a:	1782                	slli	a5,a5,0x20
    80000f4c:	9381                	srli	a5,a5,0x20
    80000f4e:	fff7c793          	not	a5,a5
    80000f52:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f54:	177d                	addi	a4,a4,-1
    80000f56:	16fd                	addi	a3,a3,-1
    80000f58:	00074603          	lbu	a2,0(a4)
    80000f5c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f60:	fef71ae3          	bne	a4,a5,80000f54 <memmove+0x4a>
    80000f64:	b7f1                	j	80000f30 <memmove+0x26>

0000000080000f66 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f66:	1141                	addi	sp,sp,-16
    80000f68:	e406                	sd	ra,8(sp)
    80000f6a:	e022                	sd	s0,0(sp)
    80000f6c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f6e:	f9dff0ef          	jal	80000f0a <memmove>
}
    80000f72:	60a2                	ld	ra,8(sp)
    80000f74:	6402                	ld	s0,0(sp)
    80000f76:	0141                	addi	sp,sp,16
    80000f78:	8082                	ret

0000000080000f7a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f7a:	1141                	addi	sp,sp,-16
    80000f7c:	e422                	sd	s0,8(sp)
    80000f7e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f80:	ce11                	beqz	a2,80000f9c <strncmp+0x22>
    80000f82:	00054783          	lbu	a5,0(a0)
    80000f86:	cf89                	beqz	a5,80000fa0 <strncmp+0x26>
    80000f88:	0005c703          	lbu	a4,0(a1)
    80000f8c:	00f71a63          	bne	a4,a5,80000fa0 <strncmp+0x26>
    n--, p++, q++;
    80000f90:	367d                	addiw	a2,a2,-1
    80000f92:	0505                	addi	a0,a0,1
    80000f94:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f96:	f675                	bnez	a2,80000f82 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f98:	4501                	li	a0,0
    80000f9a:	a801                	j	80000faa <strncmp+0x30>
    80000f9c:	4501                	li	a0,0
    80000f9e:	a031                	j	80000faa <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000fa0:	00054503          	lbu	a0,0(a0)
    80000fa4:	0005c783          	lbu	a5,0(a1)
    80000fa8:	9d1d                	subw	a0,a0,a5
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e422                	sd	s0,8(sp)
    80000fb4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fb6:	87aa                	mv	a5,a0
    80000fb8:	86b2                	mv	a3,a2
    80000fba:	367d                	addiw	a2,a2,-1
    80000fbc:	02d05563          	blez	a3,80000fe6 <strncpy+0x36>
    80000fc0:	0785                	addi	a5,a5,1
    80000fc2:	0005c703          	lbu	a4,0(a1)
    80000fc6:	fee78fa3          	sb	a4,-1(a5)
    80000fca:	0585                	addi	a1,a1,1
    80000fcc:	f775                	bnez	a4,80000fb8 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fce:	873e                	mv	a4,a5
    80000fd0:	9fb5                	addw	a5,a5,a3
    80000fd2:	37fd                	addiw	a5,a5,-1
    80000fd4:	00c05963          	blez	a2,80000fe6 <strncpy+0x36>
    *s++ = 0;
    80000fd8:	0705                	addi	a4,a4,1
    80000fda:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000fde:	40e786bb          	subw	a3,a5,a4
    80000fe2:	fed04be3          	bgtz	a3,80000fd8 <strncpy+0x28>
  return os;
}
    80000fe6:	6422                	ld	s0,8(sp)
    80000fe8:	0141                	addi	sp,sp,16
    80000fea:	8082                	ret

0000000080000fec <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e422                	sd	s0,8(sp)
    80000ff0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ff2:	02c05363          	blez	a2,80001018 <safestrcpy+0x2c>
    80000ff6:	fff6069b          	addiw	a3,a2,-1
    80000ffa:	1682                	slli	a3,a3,0x20
    80000ffc:	9281                	srli	a3,a3,0x20
    80000ffe:	96ae                	add	a3,a3,a1
    80001000:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001002:	00d58963          	beq	a1,a3,80001014 <safestrcpy+0x28>
    80001006:	0585                	addi	a1,a1,1
    80001008:	0785                	addi	a5,a5,1
    8000100a:	fff5c703          	lbu	a4,-1(a1)
    8000100e:	fee78fa3          	sb	a4,-1(a5)
    80001012:	fb65                	bnez	a4,80001002 <safestrcpy+0x16>
    ;
  *s = 0;
    80001014:	00078023          	sb	zero,0(a5)
  return os;
}
    80001018:	6422                	ld	s0,8(sp)
    8000101a:	0141                	addi	sp,sp,16
    8000101c:	8082                	ret

000000008000101e <strlen>:

int
strlen(const char *s)
{
    8000101e:	1141                	addi	sp,sp,-16
    80001020:	e422                	sd	s0,8(sp)
    80001022:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001024:	00054783          	lbu	a5,0(a0)
    80001028:	cf91                	beqz	a5,80001044 <strlen+0x26>
    8000102a:	0505                	addi	a0,a0,1
    8000102c:	87aa                	mv	a5,a0
    8000102e:	86be                	mv	a3,a5
    80001030:	0785                	addi	a5,a5,1
    80001032:	fff7c703          	lbu	a4,-1(a5)
    80001036:	ff65                	bnez	a4,8000102e <strlen+0x10>
    80001038:	40a6853b          	subw	a0,a3,a0
    8000103c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    8000103e:	6422                	ld	s0,8(sp)
    80001040:	0141                	addi	sp,sp,16
    80001042:	8082                	ret
  for(n = 0; s[n]; n++)
    80001044:	4501                	li	a0,0
    80001046:	bfe5                	j	8000103e <strlen+0x20>

0000000080001048 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001048:	1141                	addi	sp,sp,-16
    8000104a:	e406                	sd	ra,8(sp)
    8000104c:	e022                	sd	s0,0(sp)
    8000104e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001050:	4eb000ef          	jal	80001d3a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001054:	00008717          	auipc	a4,0x8
    80001058:	94c70713          	addi	a4,a4,-1716 # 800089a0 <started>
  if(cpuid() == 0){
    8000105c:	c51d                	beqz	a0,8000108a <main+0x42>
    while(started == 0)
    8000105e:	431c                	lw	a5,0(a4)
    80001060:	2781                	sext.w	a5,a5
    80001062:	dff5                	beqz	a5,8000105e <main+0x16>
      ;
    __sync_synchronize();
    80001064:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001068:	4d3000ef          	jal	80001d3a <cpuid>
    8000106c:	85aa                	mv	a1,a0
    8000106e:	00007517          	auipc	a0,0x7
    80001072:	05250513          	addi	a0,a0,82 # 800080c0 <etext+0xc0>
    80001076:	c84ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    8000107a:	080000ef          	jal	800010fa <kvminithart>
    trapinithart();   // install kernel trap vector
    8000107e:	072020ef          	jal	800030f0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001082:	426050ef          	jal	800064a8 <plicinithart>
  }

  scheduler();        
    80001086:	6b6010ef          	jal	8000273c <scheduler>
    consoleinit();
    8000108a:	b9aff0ef          	jal	80000424 <consoleinit>
    printfinit();
    8000108e:	f8eff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80001092:	00007517          	auipc	a0,0x7
    80001096:	00e50513          	addi	a0,a0,14 # 800080a0 <etext+0xa0>
    8000109a:	c60ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    8000109e:	00007517          	auipc	a0,0x7
    800010a2:	00a50513          	addi	a0,a0,10 # 800080a8 <etext+0xa8>
    800010a6:	c54ff0ef          	jal	800004fa <printf>
    printf("\n");
    800010aa:	00007517          	auipc	a0,0x7
    800010ae:	ff650513          	addi	a0,a0,-10 # 800080a0 <etext+0xa0>
    800010b2:	c48ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    800010b6:	be3ff0ef          	jal	80000c98 <kinit>
    kvminit();       // create kernel page table
    800010ba:	2ca000ef          	jal	80001384 <kvminit>
    kvminithart();   // turn on paging
    800010be:	03c000ef          	jal	800010fa <kvminithart>
    procinit();      // process table
    800010c2:	39b000ef          	jal	80001c5c <procinit>
    trapinit();      // trap vectors
    800010c6:	006020ef          	jal	800030cc <trapinit>
    trapinithart();  // install kernel trap vector
    800010ca:	026020ef          	jal	800030f0 <trapinithart>
    plicinit();      // set up interrupt controller
    800010ce:	3c0050ef          	jal	8000648e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800010d2:	3d6050ef          	jal	800064a8 <plicinithart>
    binit();         // buffer cache
    800010d6:	295020ef          	jal	80003b6a <binit>
    iinit();         // inode table
    800010da:	01a030ef          	jal	800040f4 <iinit>
    fileinit();      // file table
    800010de:	70d030ef          	jal	80004fea <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	4b6050ef          	jal	80006598 <virtio_disk_init>
    userinit();      // first user process
    800010e6:	28e010ef          	jal	80002374 <userinit>
    __sync_synchronize();
    800010ea:	0ff0000f          	fence
    started = 1;
    800010ee:	4785                	li	a5,1
    800010f0:	00008717          	auipc	a4,0x8
    800010f4:	8af72823          	sw	a5,-1872(a4) # 800089a0 <started>
    800010f8:	b779                	j	80001086 <main+0x3e>

00000000800010fa <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    800010fa:	1141                	addi	sp,sp,-16
    800010fc:	e422                	sd	s0,8(sp)
    800010fe:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001100:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001104:	00008797          	auipc	a5,0x8
    80001108:	8a47b783          	ld	a5,-1884(a5) # 800089a8 <kernel_pagetable>
    8000110c:	83b1                	srli	a5,a5,0xc
    8000110e:	577d                	li	a4,-1
    80001110:	177e                	slli	a4,a4,0x3f
    80001112:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001114:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001118:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000111c:	6422                	ld	s0,8(sp)
    8000111e:	0141                	addi	sp,sp,16
    80001120:	8082                	ret

0000000080001122 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001122:	7139                	addi	sp,sp,-64
    80001124:	fc06                	sd	ra,56(sp)
    80001126:	f822                	sd	s0,48(sp)
    80001128:	f426                	sd	s1,40(sp)
    8000112a:	f04a                	sd	s2,32(sp)
    8000112c:	ec4e                	sd	s3,24(sp)
    8000112e:	e852                	sd	s4,16(sp)
    80001130:	e456                	sd	s5,8(sp)
    80001132:	e05a                	sd	s6,0(sp)
    80001134:	0080                	addi	s0,sp,64
    80001136:	84aa                	mv	s1,a0
    80001138:	89ae                	mv	s3,a1
    8000113a:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000113c:	57fd                	li	a5,-1
    8000113e:	83e9                	srli	a5,a5,0x1a
    80001140:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001142:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001144:	02b7fc63          	bgeu	a5,a1,8000117c <walk+0x5a>
    panic("walk");
    80001148:	00007517          	auipc	a0,0x7
    8000114c:	f9050513          	addi	a0,a0,-112 # 800080d8 <etext+0xd8>
    80001150:	e90ff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001154:	060a8263          	beqz	s5,800011b8 <walk+0x96>
    80001158:	b89ff0ef          	jal	80000ce0 <kalloc>
    8000115c:	84aa                	mv	s1,a0
    8000115e:	c139                	beqz	a0,800011a4 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001160:	6605                	lui	a2,0x1
    80001162:	4581                	li	a1,0
    80001164:	d4bff0ef          	jal	80000eae <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001168:	00c4d793          	srli	a5,s1,0xc
    8000116c:	07aa                	slli	a5,a5,0xa
    8000116e:	0017e793          	ori	a5,a5,1
    80001172:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001176:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    80001178:	036a0063          	beq	s4,s6,80001198 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000117c:	0149d933          	srl	s2,s3,s4
    80001180:	1ff97913          	andi	s2,s2,511
    80001184:	090e                	slli	s2,s2,0x3
    80001186:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001188:	00093483          	ld	s1,0(s2)
    8000118c:	0014f793          	andi	a5,s1,1
    80001190:	d3f1                	beqz	a5,80001154 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001192:	80a9                	srli	s1,s1,0xa
    80001194:	04b2                	slli	s1,s1,0xc
    80001196:	b7c5                	j	80001176 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001198:	00c9d513          	srli	a0,s3,0xc
    8000119c:	1ff57513          	andi	a0,a0,511
    800011a0:	050e                	slli	a0,a0,0x3
    800011a2:	9526                	add	a0,a0,s1
}
    800011a4:	70e2                	ld	ra,56(sp)
    800011a6:	7442                	ld	s0,48(sp)
    800011a8:	74a2                	ld	s1,40(sp)
    800011aa:	7902                	ld	s2,32(sp)
    800011ac:	69e2                	ld	s3,24(sp)
    800011ae:	6a42                	ld	s4,16(sp)
    800011b0:	6aa2                	ld	s5,8(sp)
    800011b2:	6b02                	ld	s6,0(sp)
    800011b4:	6121                	addi	sp,sp,64
    800011b6:	8082                	ret
        return 0;
    800011b8:	4501                	li	a0,0
    800011ba:	b7ed                	j	800011a4 <walk+0x82>

00000000800011bc <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800011bc:	57fd                	li	a5,-1
    800011be:	83e9                	srli	a5,a5,0x1a
    800011c0:	00b7f463          	bgeu	a5,a1,800011c8 <walkaddr+0xc>
    return 0;
    800011c4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800011c6:	8082                	ret
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e406                	sd	ra,8(sp)
    800011cc:	e022                	sd	s0,0(sp)
    800011ce:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011d0:	4601                	li	a2,0
    800011d2:	f51ff0ef          	jal	80001122 <walk>
  if(pte == 0)
    800011d6:	c105                	beqz	a0,800011f6 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800011d8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011da:	0117f693          	andi	a3,a5,17
    800011de:	4745                	li	a4,17
    return 0;
    800011e0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011e2:	00e68663          	beq	a3,a4,800011ee <walkaddr+0x32>
}
    800011e6:	60a2                	ld	ra,8(sp)
    800011e8:	6402                	ld	s0,0(sp)
    800011ea:	0141                	addi	sp,sp,16
    800011ec:	8082                	ret
  pa = PTE2PA(*pte);
    800011ee:	83a9                	srli	a5,a5,0xa
    800011f0:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011f4:	bfcd                	j	800011e6 <walkaddr+0x2a>
    return 0;
    800011f6:	4501                	li	a0,0
    800011f8:	b7fd                	j	800011e6 <walkaddr+0x2a>

00000000800011fa <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011fa:	715d                	addi	sp,sp,-80
    800011fc:	e486                	sd	ra,72(sp)
    800011fe:	e0a2                	sd	s0,64(sp)
    80001200:	fc26                	sd	s1,56(sp)
    80001202:	f84a                	sd	s2,48(sp)
    80001204:	f44e                	sd	s3,40(sp)
    80001206:	f052                	sd	s4,32(sp)
    80001208:	ec56                	sd	s5,24(sp)
    8000120a:	e85a                	sd	s6,16(sp)
    8000120c:	e45e                	sd	s7,8(sp)
    8000120e:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001210:	03459793          	slli	a5,a1,0x34
    80001214:	e7a9                	bnez	a5,8000125e <mappages+0x64>
    80001216:	8aaa                	mv	s5,a0
    80001218:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000121a:	03461793          	slli	a5,a2,0x34
    8000121e:	e7b1                	bnez	a5,8000126a <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001220:	ca39                	beqz	a2,80001276 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001222:	77fd                	lui	a5,0xfffff
    80001224:	963e                	add	a2,a2,a5
    80001226:	00b609b3          	add	s3,a2,a1
  a = va;
    8000122a:	892e                	mv	s2,a1
    8000122c:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001230:	6b85                	lui	s7,0x1
    80001232:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001236:	4605                	li	a2,1
    80001238:	85ca                	mv	a1,s2
    8000123a:	8556                	mv	a0,s5
    8000123c:	ee7ff0ef          	jal	80001122 <walk>
    80001240:	c539                	beqz	a0,8000128e <mappages+0x94>
    if(*pte & PTE_V)
    80001242:	611c                	ld	a5,0(a0)
    80001244:	8b85                	andi	a5,a5,1
    80001246:	ef95                	bnez	a5,80001282 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001248:	80b1                	srli	s1,s1,0xc
    8000124a:	04aa                	slli	s1,s1,0xa
    8000124c:	0164e4b3          	or	s1,s1,s6
    80001250:	0014e493          	ori	s1,s1,1
    80001254:	e104                	sd	s1,0(a0)
    if(a == last)
    80001256:	05390863          	beq	s2,s3,800012a6 <mappages+0xac>
    a += PGSIZE;
    8000125a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000125c:	bfd9                	j	80001232 <mappages+0x38>
    panic("mappages: va not aligned");
    8000125e:	00007517          	auipc	a0,0x7
    80001262:	e8250513          	addi	a0,a0,-382 # 800080e0 <etext+0xe0>
    80001266:	d7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000126a:	00007517          	auipc	a0,0x7
    8000126e:	e9650513          	addi	a0,a0,-362 # 80008100 <etext+0x100>
    80001272:	d6eff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    80001276:	00007517          	auipc	a0,0x7
    8000127a:	eaa50513          	addi	a0,a0,-342 # 80008120 <etext+0x120>
    8000127e:	d62ff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001282:	00007517          	auipc	a0,0x7
    80001286:	eae50513          	addi	a0,a0,-338 # 80008130 <etext+0x130>
    8000128a:	d56ff0ef          	jal	800007e0 <panic>
      return -1;
    8000128e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001290:	60a6                	ld	ra,72(sp)
    80001292:	6406                	ld	s0,64(sp)
    80001294:	74e2                	ld	s1,56(sp)
    80001296:	7942                	ld	s2,48(sp)
    80001298:	79a2                	ld	s3,40(sp)
    8000129a:	7a02                	ld	s4,32(sp)
    8000129c:	6ae2                	ld	s5,24(sp)
    8000129e:	6b42                	ld	s6,16(sp)
    800012a0:	6ba2                	ld	s7,8(sp)
    800012a2:	6161                	addi	sp,sp,80
    800012a4:	8082                	ret
  return 0;
    800012a6:	4501                	li	a0,0
    800012a8:	b7e5                	j	80001290 <mappages+0x96>

00000000800012aa <kvmmap>:
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e406                	sd	ra,8(sp)
    800012ae:	e022                	sd	s0,0(sp)
    800012b0:	0800                	addi	s0,sp,16
    800012b2:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012b4:	86b2                	mv	a3,a2
    800012b6:	863e                	mv	a2,a5
    800012b8:	f43ff0ef          	jal	800011fa <mappages>
    800012bc:	e509                	bnez	a0,800012c6 <kvmmap+0x1c>
}
    800012be:	60a2                	ld	ra,8(sp)
    800012c0:	6402                	ld	s0,0(sp)
    800012c2:	0141                	addi	sp,sp,16
    800012c4:	8082                	ret
    panic("kvmmap");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e7a50513          	addi	a0,a0,-390 # 80008140 <etext+0x140>
    800012ce:	d12ff0ef          	jal	800007e0 <panic>

00000000800012d2 <kvmmake>:
{
    800012d2:	1101                	addi	sp,sp,-32
    800012d4:	ec06                	sd	ra,24(sp)
    800012d6:	e822                	sd	s0,16(sp)
    800012d8:	e426                	sd	s1,8(sp)
    800012da:	e04a                	sd	s2,0(sp)
    800012dc:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012de:	a03ff0ef          	jal	80000ce0 <kalloc>
    800012e2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012e4:	6605                	lui	a2,0x1
    800012e6:	4581                	li	a1,0
    800012e8:	bc7ff0ef          	jal	80000eae <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012ec:	4719                	li	a4,6
    800012ee:	6685                	lui	a3,0x1
    800012f0:	10000637          	lui	a2,0x10000
    800012f4:	100005b7          	lui	a1,0x10000
    800012f8:	8526                	mv	a0,s1
    800012fa:	fb1ff0ef          	jal	800012aa <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012fe:	4719                	li	a4,6
    80001300:	6685                	lui	a3,0x1
    80001302:	10001637          	lui	a2,0x10001
    80001306:	100015b7          	lui	a1,0x10001
    8000130a:	8526                	mv	a0,s1
    8000130c:	f9fff0ef          	jal	800012aa <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001310:	4719                	li	a4,6
    80001312:	040006b7          	lui	a3,0x4000
    80001316:	0c000637          	lui	a2,0xc000
    8000131a:	0c0005b7          	lui	a1,0xc000
    8000131e:	8526                	mv	a0,s1
    80001320:	f8bff0ef          	jal	800012aa <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001324:	00007917          	auipc	s2,0x7
    80001328:	cdc90913          	addi	s2,s2,-804 # 80008000 <etext>
    8000132c:	4729                	li	a4,10
    8000132e:	80007697          	auipc	a3,0x80007
    80001332:	cd268693          	addi	a3,a3,-814 # 8000 <_entry-0x7fff8000>
    80001336:	4605                	li	a2,1
    80001338:	067e                	slli	a2,a2,0x1f
    8000133a:	85b2                	mv	a1,a2
    8000133c:	8526                	mv	a0,s1
    8000133e:	f6dff0ef          	jal	800012aa <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001342:	46c5                	li	a3,17
    80001344:	06ee                	slli	a3,a3,0x1b
    80001346:	4719                	li	a4,6
    80001348:	412686b3          	sub	a3,a3,s2
    8000134c:	864a                	mv	a2,s2
    8000134e:	85ca                	mv	a1,s2
    80001350:	8526                	mv	a0,s1
    80001352:	f59ff0ef          	jal	800012aa <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001356:	4729                	li	a4,10
    80001358:	6685                	lui	a3,0x1
    8000135a:	00006617          	auipc	a2,0x6
    8000135e:	ca660613          	addi	a2,a2,-858 # 80007000 <_trampoline>
    80001362:	040005b7          	lui	a1,0x4000
    80001366:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001368:	05b2                	slli	a1,a1,0xc
    8000136a:	8526                	mv	a0,s1
    8000136c:	f3fff0ef          	jal	800012aa <kvmmap>
  proc_mapstacks(kpgtbl);
    80001370:	8526                	mv	a0,s1
    80001372:	053000ef          	jal	80001bc4 <proc_mapstacks>
}
    80001376:	8526                	mv	a0,s1
    80001378:	60e2                	ld	ra,24(sp)
    8000137a:	6442                	ld	s0,16(sp)
    8000137c:	64a2                	ld	s1,8(sp)
    8000137e:	6902                	ld	s2,0(sp)
    80001380:	6105                	addi	sp,sp,32
    80001382:	8082                	ret

0000000080001384 <kvminit>:
{
    80001384:	1141                	addi	sp,sp,-16
    80001386:	e406                	sd	ra,8(sp)
    80001388:	e022                	sd	s0,0(sp)
    8000138a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000138c:	f47ff0ef          	jal	800012d2 <kvmmake>
    80001390:	00007797          	auipc	a5,0x7
    80001394:	60a7bc23          	sd	a0,1560(a5) # 800089a8 <kernel_pagetable>
}
    80001398:	60a2                	ld	ra,8(sp)
    8000139a:	6402                	ld	s0,0(sp)
    8000139c:	0141                	addi	sp,sp,16
    8000139e:	8082                	ret

00000000800013a0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013a0:	1101                	addi	sp,sp,-32
    800013a2:	ec06                	sd	ra,24(sp)
    800013a4:	e822                	sd	s0,16(sp)
    800013a6:	e426                	sd	s1,8(sp)
    800013a8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013aa:	937ff0ef          	jal	80000ce0 <kalloc>
    800013ae:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013b0:	c509                	beqz	a0,800013ba <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013b2:	6605                	lui	a2,0x1
    800013b4:	4581                	li	a1,0
    800013b6:	af9ff0ef          	jal	80000eae <memset>
  return pagetable;
}
    800013ba:	8526                	mv	a0,s1
    800013bc:	60e2                	ld	ra,24(sp)
    800013be:	6442                	ld	s0,16(sp)
    800013c0:	64a2                	ld	s1,8(sp)
    800013c2:	6105                	addi	sp,sp,32
    800013c4:	8082                	ret

00000000800013c6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013c6:	7139                	addi	sp,sp,-64
    800013c8:	fc06                	sd	ra,56(sp)
    800013ca:	f822                	sd	s0,48(sp)
    800013cc:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013ce:	03459793          	slli	a5,a1,0x34
    800013d2:	e38d                	bnez	a5,800013f4 <uvmunmap+0x2e>
    800013d4:	f04a                	sd	s2,32(sp)
    800013d6:	ec4e                	sd	s3,24(sp)
    800013d8:	e852                	sd	s4,16(sp)
    800013da:	e456                	sd	s5,8(sp)
    800013dc:	e05a                	sd	s6,0(sp)
    800013de:	8a2a                	mv	s4,a0
    800013e0:	892e                	mv	s2,a1
    800013e2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013e4:	0632                	slli	a2,a2,0xc
    800013e6:	00b609b3          	add	s3,a2,a1
    800013ea:	6b05                	lui	s6,0x1
    800013ec:	0535f963          	bgeu	a1,s3,8000143e <uvmunmap+0x78>
    800013f0:	f426                	sd	s1,40(sp)
    800013f2:	a015                	j	80001416 <uvmunmap+0x50>
    800013f4:	f426                	sd	s1,40(sp)
    800013f6:	f04a                	sd	s2,32(sp)
    800013f8:	ec4e                	sd	s3,24(sp)
    800013fa:	e852                	sd	s4,16(sp)
    800013fc:	e456                	sd	s5,8(sp)
    800013fe:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001400:	00007517          	auipc	a0,0x7
    80001404:	d4850513          	addi	a0,a0,-696 # 80008148 <etext+0x148>
    80001408:	bd8ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000140c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001410:	995a                	add	s2,s2,s6
    80001412:	03397563          	bgeu	s2,s3,8000143c <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001416:	4601                	li	a2,0
    80001418:	85ca                	mv	a1,s2
    8000141a:	8552                	mv	a0,s4
    8000141c:	d07ff0ef          	jal	80001122 <walk>
    80001420:	84aa                	mv	s1,a0
    80001422:	d57d                	beqz	a0,80001410 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001424:	611c                	ld	a5,0(a0)
    80001426:	0017f713          	andi	a4,a5,1
    8000142a:	d37d                	beqz	a4,80001410 <uvmunmap+0x4a>
    if(do_free){
    8000142c:	fe0a80e3          	beqz	s5,8000140c <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001430:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001432:	00c79513          	slli	a0,a5,0xc
    80001436:	f28ff0ef          	jal	80000b5e <kfree>
    8000143a:	bfc9                	j	8000140c <uvmunmap+0x46>
    8000143c:	74a2                	ld	s1,40(sp)
    8000143e:	7902                	ld	s2,32(sp)
    80001440:	69e2                	ld	s3,24(sp)
    80001442:	6a42                	ld	s4,16(sp)
    80001444:	6aa2                	ld	s5,8(sp)
    80001446:	6b02                	ld	s6,0(sp)
  }
}
    80001448:	70e2                	ld	ra,56(sp)
    8000144a:	7442                	ld	s0,48(sp)
    8000144c:	6121                	addi	sp,sp,64
    8000144e:	8082                	ret

0000000080001450 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001450:	1101                	addi	sp,sp,-32
    80001452:	ec06                	sd	ra,24(sp)
    80001454:	e822                	sd	s0,16(sp)
    80001456:	e426                	sd	s1,8(sp)
    80001458:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000145a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000145c:	00b67d63          	bgeu	a2,a1,80001476 <uvmdealloc+0x26>
    80001460:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	00f60733          	add	a4,a2,a5
    8000146a:	76fd                	lui	a3,0xfffff
    8000146c:	8f75                	and	a4,a4,a3
    8000146e:	97ae                	add	a5,a5,a1
    80001470:	8ff5                	and	a5,a5,a3
    80001472:	00f76863          	bltu	a4,a5,80001482 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001476:	8526                	mv	a0,s1
    80001478:	60e2                	ld	ra,24(sp)
    8000147a:	6442                	ld	s0,16(sp)
    8000147c:	64a2                	ld	s1,8(sp)
    8000147e:	6105                	addi	sp,sp,32
    80001480:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001482:	8f99                	sub	a5,a5,a4
    80001484:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001486:	4685                	li	a3,1
    80001488:	0007861b          	sext.w	a2,a5
    8000148c:	85ba                	mv	a1,a4
    8000148e:	f39ff0ef          	jal	800013c6 <uvmunmap>
    80001492:	b7d5                	j	80001476 <uvmdealloc+0x26>

0000000080001494 <uvmalloc>:
  if(newsz < oldsz)
    80001494:	08b66763          	bltu	a2,a1,80001522 <uvmalloc+0x8e>
{
    80001498:	7139                	addi	sp,sp,-64
    8000149a:	fc06                	sd	ra,56(sp)
    8000149c:	f822                	sd	s0,48(sp)
    8000149e:	f04a                	sd	s2,32(sp)
    800014a0:	ec4e                	sd	s3,24(sp)
    800014a2:	e852                	sd	s4,16(sp)
    800014a4:	e456                	sd	s5,8(sp)
    800014a6:	e05a                	sd	s6,0(sp)
    800014a8:	0080                	addi	s0,sp,64
    800014aa:	8aaa                	mv	s5,a0
    800014ac:	89b2                	mv	s3,a2
  oldsz = PGROUNDUP(oldsz);
    800014ae:	6785                	lui	a5,0x1
    800014b0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014b2:	95be                	add	a1,a1,a5
    800014b4:	77fd                	lui	a5,0xfffff
    800014b6:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ba:	8952                	mv	s2,s4
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014bc:	0126eb13          	ori	s6,a3,18
  return newsz;
    800014c0:	8532                	mv	a0,a2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014c2:	04ca7763          	bgeu	s4,a2,80001510 <uvmalloc+0x7c>
    800014c6:	f426                	sd	s1,40(sp)
    800014c8:	a019                	j	800014ce <uvmalloc+0x3a>
      swap_wait_for_free_page();
    800014ca:	728050ef          	jal	80006bf2 <swap_wait_for_free_page>
    while((mem = kalloc()) == 0){
    800014ce:	813ff0ef          	jal	80000ce0 <kalloc>
    800014d2:	84aa                	mv	s1,a0
    800014d4:	d97d                	beqz	a0,800014ca <uvmalloc+0x36>
    memset(mem, 0, PGSIZE);
    800014d6:	6605                	lui	a2,0x1
    800014d8:	4581                	li	a1,0
    800014da:	9d5ff0ef          	jal	80000eae <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014de:	875a                	mv	a4,s6
    800014e0:	86a6                	mv	a3,s1
    800014e2:	6605                	lui	a2,0x1
    800014e4:	85ca                	mv	a1,s2
    800014e6:	8556                	mv	a0,s5
    800014e8:	d13ff0ef          	jal	800011fa <mappages>
    800014ec:	e901                	bnez	a0,800014fc <uvmalloc+0x68>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ee:	6785                	lui	a5,0x1
    800014f0:	993e                	add	s2,s2,a5
    800014f2:	fd396ee3          	bltu	s2,s3,800014ce <uvmalloc+0x3a>
  return newsz;
    800014f6:	854e                	mv	a0,s3
    800014f8:	74a2                	ld	s1,40(sp)
    800014fa:	a819                	j	80001510 <uvmalloc+0x7c>
      kfree(mem);
    800014fc:	8526                	mv	a0,s1
    800014fe:	e60ff0ef          	jal	80000b5e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001502:	8652                	mv	a2,s4
    80001504:	85ca                	mv	a1,s2
    80001506:	8556                	mv	a0,s5
    80001508:	f49ff0ef          	jal	80001450 <uvmdealloc>
      return 0;
    8000150c:	4501                	li	a0,0
    8000150e:	74a2                	ld	s1,40(sp)
}
    80001510:	70e2                	ld	ra,56(sp)
    80001512:	7442                	ld	s0,48(sp)
    80001514:	7902                	ld	s2,32(sp)
    80001516:	69e2                	ld	s3,24(sp)
    80001518:	6a42                	ld	s4,16(sp)
    8000151a:	6aa2                	ld	s5,8(sp)
    8000151c:	6b02                	ld	s6,0(sp)
    8000151e:	6121                	addi	sp,sp,64
    80001520:	8082                	ret
    return oldsz;
    80001522:	852e                	mv	a0,a1
}
    80001524:	8082                	ret

0000000080001526 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001526:	7179                	addi	sp,sp,-48
    80001528:	f406                	sd	ra,40(sp)
    8000152a:	f022                	sd	s0,32(sp)
    8000152c:	ec26                	sd	s1,24(sp)
    8000152e:	e84a                	sd	s2,16(sp)
    80001530:	e44e                	sd	s3,8(sp)
    80001532:	e052                	sd	s4,0(sp)
    80001534:	1800                	addi	s0,sp,48
    80001536:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001538:	84aa                	mv	s1,a0
    8000153a:	6905                	lui	s2,0x1
    8000153c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000153e:	4985                	li	s3,1
    80001540:	a819                	j	80001556 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001542:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001544:	00c79513          	slli	a0,a5,0xc
    80001548:	fdfff0ef          	jal	80001526 <freewalk>
      pagetable[i] = 0;
    8000154c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001550:	04a1                	addi	s1,s1,8
    80001552:	01248f63          	beq	s1,s2,80001570 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001556:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001558:	00f7f713          	andi	a4,a5,15
    8000155c:	ff3703e3          	beq	a4,s3,80001542 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001560:	8b85                	andi	a5,a5,1
    80001562:	d7fd                	beqz	a5,80001550 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001564:	00007517          	auipc	a0,0x7
    80001568:	bfc50513          	addi	a0,a0,-1028 # 80008160 <etext+0x160>
    8000156c:	a74ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001570:	8552                	mv	a0,s4
    80001572:	decff0ef          	jal	80000b5e <kfree>
}
    80001576:	70a2                	ld	ra,40(sp)
    80001578:	7402                	ld	s0,32(sp)
    8000157a:	64e2                	ld	s1,24(sp)
    8000157c:	6942                	ld	s2,16(sp)
    8000157e:	69a2                	ld	s3,8(sp)
    80001580:	6a02                	ld	s4,0(sp)
    80001582:	6145                	addi	sp,sp,48
    80001584:	8082                	ret

0000000080001586 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001586:	1101                	addi	sp,sp,-32
    80001588:	ec06                	sd	ra,24(sp)
    8000158a:	e822                	sd	s0,16(sp)
    8000158c:	e426                	sd	s1,8(sp)
    8000158e:	1000                	addi	s0,sp,32
    80001590:	84aa                	mv	s1,a0
  if(sz > 0)
    80001592:	e989                	bnez	a1,800015a4 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001594:	8526                	mv	a0,s1
    80001596:	f91ff0ef          	jal	80001526 <freewalk>
}
    8000159a:	60e2                	ld	ra,24(sp)
    8000159c:	6442                	ld	s0,16(sp)
    8000159e:	64a2                	ld	s1,8(sp)
    800015a0:	6105                	addi	sp,sp,32
    800015a2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015a4:	6785                	lui	a5,0x1
    800015a6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015a8:	95be                	add	a1,a1,a5
    800015aa:	4685                	li	a3,1
    800015ac:	00c5d613          	srli	a2,a1,0xc
    800015b0:	4581                	li	a1,0
    800015b2:	e15ff0ef          	jal	800013c6 <uvmunmap>
    800015b6:	bff9                	j	80001594 <uvmfree+0xe>

00000000800015b8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015b8:	ce49                	beqz	a2,80001652 <uvmcopy+0x9a>
{
    800015ba:	715d                	addi	sp,sp,-80
    800015bc:	e486                	sd	ra,72(sp)
    800015be:	e0a2                	sd	s0,64(sp)
    800015c0:	fc26                	sd	s1,56(sp)
    800015c2:	f84a                	sd	s2,48(sp)
    800015c4:	f44e                	sd	s3,40(sp)
    800015c6:	f052                	sd	s4,32(sp)
    800015c8:	ec56                	sd	s5,24(sp)
    800015ca:	e85a                	sd	s6,16(sp)
    800015cc:	e45e                	sd	s7,8(sp)
    800015ce:	0880                	addi	s0,sp,80
    800015d0:	8aaa                	mv	s5,a0
    800015d2:	8b2e                	mv	s6,a1
    800015d4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015d6:	4481                	li	s1,0
    800015d8:	a029                	j	800015e2 <uvmcopy+0x2a>
    800015da:	6785                	lui	a5,0x1
    800015dc:	94be                	add	s1,s1,a5
    800015de:	0544fe63          	bgeu	s1,s4,8000163a <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800015e2:	4601                	li	a2,0
    800015e4:	85a6                	mv	a1,s1
    800015e6:	8556                	mv	a0,s5
    800015e8:	b3bff0ef          	jal	80001122 <walk>
    800015ec:	d57d                	beqz	a0,800015da <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800015ee:	6118                	ld	a4,0(a0)
    800015f0:	00177793          	andi	a5,a4,1
    800015f4:	d3fd                	beqz	a5,800015da <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800015f6:	00a75593          	srli	a1,a4,0xa
    800015fa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015fe:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001602:	edeff0ef          	jal	80000ce0 <kalloc>
    80001606:	89aa                	mv	s3,a0
    80001608:	c105                	beqz	a0,80001628 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000160a:	6605                	lui	a2,0x1
    8000160c:	85de                	mv	a1,s7
    8000160e:	8fdff0ef          	jal	80000f0a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001612:	874a                	mv	a4,s2
    80001614:	86ce                	mv	a3,s3
    80001616:	6605                	lui	a2,0x1
    80001618:	85a6                	mv	a1,s1
    8000161a:	855a                	mv	a0,s6
    8000161c:	bdfff0ef          	jal	800011fa <mappages>
    80001620:	dd4d                	beqz	a0,800015da <uvmcopy+0x22>
      kfree(mem);
    80001622:	854e                	mv	a0,s3
    80001624:	d3aff0ef          	jal	80000b5e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001628:	4685                	li	a3,1
    8000162a:	00c4d613          	srli	a2,s1,0xc
    8000162e:	4581                	li	a1,0
    80001630:	855a                	mv	a0,s6
    80001632:	d95ff0ef          	jal	800013c6 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
    80001638:	a011                	j	8000163c <uvmcopy+0x84>
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	60a6                	ld	ra,72(sp)
    8000163e:	6406                	ld	s0,64(sp)
    80001640:	74e2                	ld	s1,56(sp)
    80001642:	7942                	ld	s2,48(sp)
    80001644:	79a2                	ld	s3,40(sp)
    80001646:	7a02                	ld	s4,32(sp)
    80001648:	6ae2                	ld	s5,24(sp)
    8000164a:	6b42                	ld	s6,16(sp)
    8000164c:	6ba2                	ld	s7,8(sp)
    8000164e:	6161                	addi	sp,sp,80
    80001650:	8082                	ret
  return 0;
    80001652:	4501                	li	a0,0
}
    80001654:	8082                	ret

0000000080001656 <uvmcopy_cow>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    80001656:	c655                	beqz	a2,80001702 <uvmcopy_cow+0xac>
{
    80001658:	7139                	addi	sp,sp,-64
    8000165a:	fc06                	sd	ra,56(sp)
    8000165c:	f822                	sd	s0,48(sp)
    8000165e:	f426                	sd	s1,40(sp)
    80001660:	f04a                	sd	s2,32(sp)
    80001662:	ec4e                	sd	s3,24(sp)
    80001664:	e852                	sd	s4,16(sp)
    80001666:	e456                	sd	s5,8(sp)
    80001668:	e05a                	sd	s6,0(sp)
    8000166a:	0080                	addi	s0,sp,64
    8000166c:	89aa                	mv	s3,a0
    8000166e:	8a2e                	mv	s4,a1
    80001670:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001672:	4481                	li	s1,0
    
    // If the page is writable, mark it as COW and remove write permission
    if(flags & PTE_W) {
      flags = (flags & ~PTE_W) | PTE_COW;
      // Update parent's PTE to also be read-only with COW bit
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001674:	7afd                	lui	s5,0xfffff
    80001676:	002ada93          	srli	s5,s5,0x2
    8000167a:	a81d                	j	800016b0 <uvmcopy_cow+0x5a>
      flags = (flags & ~PTE_W) | PTE_COW;
    8000167c:	2fb77813          	andi	a6,a4,763
    80001680:	10086713          	ori	a4,a6,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001684:	0157f7b3          	and	a5,a5,s5
    80001688:	00f86833          	or	a6,a6,a5
    8000168c:	10186813          	ori	a6,a6,257
    80001690:	01053023          	sd	a6,0(a0)
    }
    
    // Map same physical page in child's page table
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001694:	86da                	mv	a3,s6
    80001696:	6605                	lui	a2,0x1
    80001698:	85a6                	mv	a1,s1
    8000169a:	8552                	mv	a0,s4
    8000169c:	b5fff0ef          	jal	800011fa <mappages>
    800016a0:	ed0d                	bnez	a0,800016da <uvmcopy_cow+0x84>
      goto err;
    }
    
    // Increment reference count for this physical page
    kref_incr((void*)pa);
    800016a2:	855a                	mv	a0,s6
    800016a4:	b78ff0ef          	jal	80000a1c <kref_incr>
  for(i = 0; i < sz; i += PGSIZE){
    800016a8:	6785                	lui	a5,0x1
    800016aa:	94be                	add	s1,s1,a5
    800016ac:	0524f063          	bgeu	s1,s2,800016ec <uvmcopy_cow+0x96>
    if((pte = walk(old, i, 0)) == 0)
    800016b0:	4601                	li	a2,0
    800016b2:	85a6                	mv	a1,s1
    800016b4:	854e                	mv	a0,s3
    800016b6:	a6dff0ef          	jal	80001122 <walk>
    800016ba:	d57d                	beqz	a0,800016a8 <uvmcopy_cow+0x52>
    if((*pte & PTE_V) == 0)
    800016bc:	611c                	ld	a5,0(a0)
    800016be:	0017f713          	andi	a4,a5,1
    800016c2:	d37d                	beqz	a4,800016a8 <uvmcopy_cow+0x52>
    pa = PTE2PA(*pte);
    800016c4:	00a7db13          	srli	s6,a5,0xa
    800016c8:	0b32                	slli	s6,s6,0xc
    flags = PTE_FLAGS(*pte);
    800016ca:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W) {
    800016ce:	0047f693          	andi	a3,a5,4
    800016d2:	f6cd                	bnez	a3,8000167c <uvmcopy_cow+0x26>
    flags = PTE_FLAGS(*pte);
    800016d4:	3ff77713          	andi	a4,a4,1023
    800016d8:	bf75                	j	80001694 <uvmcopy_cow+0x3e>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016da:	4685                	li	a3,1
    800016dc:	00c4d613          	srli	a2,s1,0xc
    800016e0:	4581                	li	a1,0
    800016e2:	8552                	mv	a0,s4
    800016e4:	ce3ff0ef          	jal	800013c6 <uvmunmap>
  return -1;
    800016e8:	557d                	li	a0,-1
    800016ea:	a011                	j	800016ee <uvmcopy_cow+0x98>
  return 0;
    800016ec:	4501                	li	a0,0
}
    800016ee:	70e2                	ld	ra,56(sp)
    800016f0:	7442                	ld	s0,48(sp)
    800016f2:	74a2                	ld	s1,40(sp)
    800016f4:	7902                	ld	s2,32(sp)
    800016f6:	69e2                	ld	s3,24(sp)
    800016f8:	6a42                	ld	s4,16(sp)
    800016fa:	6aa2                	ld	s5,8(sp)
    800016fc:	6b02                	ld	s6,0(sp)
    800016fe:	6121                	addi	sp,sp,64
    80001700:	8082                	ret
  return 0;
    80001702:	4501                	li	a0,0
}
    80001704:	8082                	ret

0000000080001706 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001706:	1141                	addi	sp,sp,-16
    80001708:	e406                	sd	ra,8(sp)
    8000170a:	e022                	sd	s0,0(sp)
    8000170c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170e:	4601                	li	a2,0
    80001710:	a13ff0ef          	jal	80001122 <walk>
  if(pte == 0)
    80001714:	c901                	beqz	a0,80001724 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001716:	611c                	ld	a5,0(a0)
    80001718:	9bbd                	andi	a5,a5,-17
    8000171a:	e11c                	sd	a5,0(a0)
}
    8000171c:	60a2                	ld	ra,8(sp)
    8000171e:	6402                	ld	s0,0(sp)
    80001720:	0141                	addi	sp,sp,16
    80001722:	8082                	ret
    panic("uvmclear");
    80001724:	00007517          	auipc	a0,0x7
    80001728:	a4c50513          	addi	a0,a0,-1460 # 80008170 <etext+0x170>
    8000172c:	8b4ff0ef          	jal	800007e0 <panic>

0000000080001730 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001730:	c6dd                	beqz	a3,800017de <copyinstr+0xae>
{
    80001732:	715d                	addi	sp,sp,-80
    80001734:	e486                	sd	ra,72(sp)
    80001736:	e0a2                	sd	s0,64(sp)
    80001738:	fc26                	sd	s1,56(sp)
    8000173a:	f84a                	sd	s2,48(sp)
    8000173c:	f44e                	sd	s3,40(sp)
    8000173e:	f052                	sd	s4,32(sp)
    80001740:	ec56                	sd	s5,24(sp)
    80001742:	e85a                	sd	s6,16(sp)
    80001744:	e45e                	sd	s7,8(sp)
    80001746:	0880                	addi	s0,sp,80
    80001748:	8a2a                	mv	s4,a0
    8000174a:	8b2e                	mv	s6,a1
    8000174c:	8bb2                	mv	s7,a2
    8000174e:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001750:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001752:	6985                	lui	s3,0x1
    80001754:	a825                	j	8000178c <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001756:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000175a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000175c:	37fd                	addiw	a5,a5,-1
    8000175e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001762:	60a6                	ld	ra,72(sp)
    80001764:	6406                	ld	s0,64(sp)
    80001766:	74e2                	ld	s1,56(sp)
    80001768:	7942                	ld	s2,48(sp)
    8000176a:	79a2                	ld	s3,40(sp)
    8000176c:	7a02                	ld	s4,32(sp)
    8000176e:	6ae2                	ld	s5,24(sp)
    80001770:	6b42                	ld	s6,16(sp)
    80001772:	6ba2                	ld	s7,8(sp)
    80001774:	6161                	addi	sp,sp,80
    80001776:	8082                	ret
    80001778:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    8000177c:	9742                	add	a4,a4,a6
      --max;
    8000177e:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001782:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001786:	04e58463          	beq	a1,a4,800017ce <copyinstr+0x9e>
{
    8000178a:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000178c:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001790:	85a6                	mv	a1,s1
    80001792:	8552                	mv	a0,s4
    80001794:	a29ff0ef          	jal	800011bc <walkaddr>
    if(pa0 == 0)
    80001798:	cd0d                	beqz	a0,800017d2 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000179a:	417486b3          	sub	a3,s1,s7
    8000179e:	96ce                	add	a3,a3,s3
    if(n > max)
    800017a0:	00d97363          	bgeu	s2,a3,800017a6 <copyinstr+0x76>
    800017a4:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800017a6:	955e                	add	a0,a0,s7
    800017a8:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800017aa:	c695                	beqz	a3,800017d6 <copyinstr+0xa6>
    800017ac:	87da                	mv	a5,s6
    800017ae:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017b0:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017b4:	96da                	add	a3,a3,s6
    800017b6:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017b8:	00f60733          	add	a4,a2,a5
    800017bc:	00074703          	lbu	a4,0(a4)
    800017c0:	db59                	beqz	a4,80001756 <copyinstr+0x26>
        *dst = *p;
    800017c2:	00e78023          	sb	a4,0(a5)
      dst++;
    800017c6:	0785                	addi	a5,a5,1
    while(n > 0){
    800017c8:	fed797e3          	bne	a5,a3,800017b6 <copyinstr+0x86>
    800017cc:	b775                	j	80001778 <copyinstr+0x48>
    800017ce:	4781                	li	a5,0
    800017d0:	b771                	j	8000175c <copyinstr+0x2c>
      return -1;
    800017d2:	557d                	li	a0,-1
    800017d4:	b779                	j	80001762 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017d6:	6b85                	lui	s7,0x1
    800017d8:	9ba6                	add	s7,s7,s1
    800017da:	87da                	mv	a5,s6
    800017dc:	b77d                	j	8000178a <copyinstr+0x5a>
  int got_null = 0;
    800017de:	4781                	li	a5,0
  if(got_null){
    800017e0:	37fd                	addiw	a5,a5,-1
    800017e2:	0007851b          	sext.w	a0,a5
}
    800017e6:	8082                	ret

00000000800017e8 <cowfault>:
// Handle COW page fault.
// Allocates a new page, copies the content, and updates the page table.
// Returns 0 on success, -1 on failure.
int
cowfault(pagetable_t pagetable, uint64 va)
{
    800017e8:	7179                	addi	sp,sp,-48
    800017ea:	f406                	sd	ra,40(sp)
    800017ec:	f022                	sd	s0,32(sp)
    800017ee:	1800                	addi	s0,sp,48
  char *mem;

  va = PGROUNDDOWN(va);
  
  // Get the PTE for this virtual address
  pte = walk(pagetable, va, 0);
    800017f0:	4601                	li	a2,0
    800017f2:	77fd                	lui	a5,0xfffff
    800017f4:	8dfd                	and	a1,a1,a5
    800017f6:	92dff0ef          	jal	80001122 <walk>
  if(pte == 0)
    800017fa:	c541                	beqz	a0,80001882 <cowfault+0x9a>
    800017fc:	e84a                	sd	s2,16(sp)
    800017fe:	e44e                	sd	s3,8(sp)
    80001800:	892a                	mv	s2,a0
    return -1;
  if((*pte & PTE_V) == 0)
    80001802:	00053983          	ld	s3,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    80001806:	0119f713          	andi	a4,s3,17
    8000180a:	47c5                	li	a5,17
    8000180c:	06f71d63          	bne	a4,a5,80001886 <cowfault+0x9e>
    return -1;
  
  // Check if this is a COW page
  if((*pte & PTE_COW) == 0)
    80001810:	1009f793          	andi	a5,s3,256
    80001814:	cfad                	beqz	a5,8000188e <cowfault+0xa6>
    80001816:	e052                	sd	s4,0(sp)
    return -1;
  
  pa = PTE2PA(*pte);
    80001818:	00a9da13          	srli	s4,s3,0xa
    8000181c:	0a32                	slli	s4,s4,0xc
  flags = PTE_FLAGS(*pte);
  
  // If this is the only reference, just restore write permission
  if(kref_get((void*)pa) == 1) {
    8000181e:	8552                	mv	a0,s4
    80001820:	ad2ff0ef          	jal	80000af2 <kref_get>
    80001824:	4785                	li	a5,1
    80001826:	04f50163          	beq	a0,a5,80001868 <cowfault+0x80>
    8000182a:	ec26                	sd	s1,24(sp)
    *pte = (*pte | PTE_W) & ~PTE_COW;
    return 0;
  }
  
  // Allocate a new page
  mem = kalloc();
    8000182c:	cb4ff0ef          	jal	80000ce0 <kalloc>
    80001830:	84aa                	mv	s1,a0
  if(mem == 0)
    80001832:	c135                	beqz	a0,80001896 <cowfault+0xae>
    return -1;
  
  // Copy the content
  memmove(mem, (char*)pa, PGSIZE);
    80001834:	6605                	lui	a2,0x1
    80001836:	85d2                	mv	a1,s4
    80001838:	ed2ff0ef          	jal	80000f0a <memmove>
  
  // Update flags: restore write permission, remove COW bit
  flags = (flags | PTE_W) & ~PTE_COW;
  
  // Update the PTE to point to the new page
  *pte = PA2PTE(mem) | flags | PTE_V;
    8000183c:	80b1                	srli	s1,s1,0xc
    8000183e:	04aa                	slli	s1,s1,0xa
  flags = (flags | PTE_W) & ~PTE_COW;
    80001840:	2fb9f993          	andi	s3,s3,763
  *pte = PA2PTE(mem) | flags | PTE_V;
    80001844:	0134e4b3          	or	s1,s1,s3
    80001848:	0054e493          	ori	s1,s1,5
    8000184c:	00993023          	sd	s1,0(s2)
  
  // Decrement reference count on old page (may free it)
  kfree((void*)pa);
    80001850:	8552                	mv	a0,s4
    80001852:	b0cff0ef          	jal	80000b5e <kfree>
  
  return 0;
    80001856:	4501                	li	a0,0
    80001858:	64e2                	ld	s1,24(sp)
    8000185a:	6942                	ld	s2,16(sp)
    8000185c:	69a2                	ld	s3,8(sp)
    8000185e:	6a02                	ld	s4,0(sp)
}
    80001860:	70a2                	ld	ra,40(sp)
    80001862:	7402                	ld	s0,32(sp)
    80001864:	6145                	addi	sp,sp,48
    80001866:	8082                	ret
    *pte = (*pte | PTE_W) & ~PTE_COW;
    80001868:	00093783          	ld	a5,0(s2)
    8000186c:	efb7f793          	andi	a5,a5,-261
    80001870:	0047e793          	ori	a5,a5,4
    80001874:	00f93023          	sd	a5,0(s2)
    return 0;
    80001878:	4501                	li	a0,0
    8000187a:	6942                	ld	s2,16(sp)
    8000187c:	69a2                	ld	s3,8(sp)
    8000187e:	6a02                	ld	s4,0(sp)
    80001880:	b7c5                	j	80001860 <cowfault+0x78>
    return -1;
    80001882:	557d                	li	a0,-1
    80001884:	bff1                	j	80001860 <cowfault+0x78>
    return -1;
    80001886:	557d                	li	a0,-1
    80001888:	6942                	ld	s2,16(sp)
    8000188a:	69a2                	ld	s3,8(sp)
    8000188c:	bfd1                	j	80001860 <cowfault+0x78>
    return -1;
    8000188e:	557d                	li	a0,-1
    80001890:	6942                	ld	s2,16(sp)
    80001892:	69a2                	ld	s3,8(sp)
    80001894:	b7f1                	j	80001860 <cowfault+0x78>
    return -1;
    80001896:	557d                	li	a0,-1
    80001898:	64e2                	ld	s1,24(sp)
    8000189a:	6942                	ld	s2,16(sp)
    8000189c:	69a2                	ld	s3,8(sp)
    8000189e:	6a02                	ld	s4,0(sp)
    800018a0:	b7c1                	j	80001860 <cowfault+0x78>

00000000800018a2 <ismapped>:

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e406                	sd	ra,8(sp)
    800018a6:	e022                	sd	s0,0(sp)
    800018a8:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800018aa:	4601                	li	a2,0
    800018ac:	877ff0ef          	jal	80001122 <walk>
  if (pte == 0) {
    800018b0:	c519                	beqz	a0,800018be <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800018b2:	6108                	ld	a0,0(a0)
    800018b4:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800018b6:	60a2                	ld	ra,8(sp)
    800018b8:	6402                	ld	s0,0(sp)
    800018ba:	0141                	addi	sp,sp,16
    800018bc:	8082                	ret
    return 0;
    800018be:	4501                	li	a0,0
    800018c0:	bfdd                	j	800018b6 <ismapped+0x14>

00000000800018c2 <vmfault>:
{
    800018c2:	7179                	addi	sp,sp,-48
    800018c4:	f406                	sd	ra,40(sp)
    800018c6:	f022                	sd	s0,32(sp)
    800018c8:	ec26                	sd	s1,24(sp)
    800018ca:	e44e                	sd	s3,8(sp)
    800018cc:	1800                	addi	s0,sp,48
    800018ce:	89aa                	mv	s3,a0
    800018d0:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800018d2:	494000ef          	jal	80001d66 <myproc>
  if (va >= p->sz)
    800018d6:	653c                	ld	a5,72(a0)
    800018d8:	00f4ea63          	bltu	s1,a5,800018ec <vmfault+0x2a>
    return 0;
    800018dc:	4981                	li	s3,0
}
    800018de:	854e                	mv	a0,s3
    800018e0:	70a2                	ld	ra,40(sp)
    800018e2:	7402                	ld	s0,32(sp)
    800018e4:	64e2                	ld	s1,24(sp)
    800018e6:	69a2                	ld	s3,8(sp)
    800018e8:	6145                	addi	sp,sp,48
    800018ea:	8082                	ret
    800018ec:	e84a                	sd	s2,16(sp)
    800018ee:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    800018f0:	77fd                	lui	a5,0xfffff
    800018f2:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    800018f4:	85a6                	mv	a1,s1
    800018f6:	854e                	mv	a0,s3
    800018f8:	fabff0ef          	jal	800018a2 <ismapped>
    return 0;
    800018fc:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800018fe:	c119                	beqz	a0,80001904 <vmfault+0x42>
    80001900:	6942                	ld	s2,16(sp)
    80001902:	bff1                	j	800018de <vmfault+0x1c>
    80001904:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    80001906:	bdaff0ef          	jal	80000ce0 <kalloc>
    8000190a:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000190c:	c90d                	beqz	a0,8000193e <vmfault+0x7c>
  mem = (uint64) kalloc();
    8000190e:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001910:	6605                	lui	a2,0x1
    80001912:	4581                	li	a1,0
    80001914:	d9aff0ef          	jal	80000eae <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001918:	4759                	li	a4,22
    8000191a:	86d2                	mv	a3,s4
    8000191c:	6605                	lui	a2,0x1
    8000191e:	85a6                	mv	a1,s1
    80001920:	05093503          	ld	a0,80(s2)
    80001924:	8d7ff0ef          	jal	800011fa <mappages>
    80001928:	e501                	bnez	a0,80001930 <vmfault+0x6e>
    8000192a:	6942                	ld	s2,16(sp)
    8000192c:	6a02                	ld	s4,0(sp)
    8000192e:	bf45                	j	800018de <vmfault+0x1c>
    kfree((void *)mem);
    80001930:	8552                	mv	a0,s4
    80001932:	a2cff0ef          	jal	80000b5e <kfree>
    return 0;
    80001936:	4981                	li	s3,0
    80001938:	6942                	ld	s2,16(sp)
    8000193a:	6a02                	ld	s4,0(sp)
    8000193c:	b74d                	j	800018de <vmfault+0x1c>
    8000193e:	6942                	ld	s2,16(sp)
    80001940:	6a02                	ld	s4,0(sp)
    80001942:	bf71                	j	800018de <vmfault+0x1c>

0000000080001944 <copyout>:
  while(len > 0){
    80001944:	c2f9                	beqz	a3,80001a0a <copyout+0xc6>
{
    80001946:	711d                	addi	sp,sp,-96
    80001948:	ec86                	sd	ra,88(sp)
    8000194a:	e8a2                	sd	s0,80(sp)
    8000194c:	e0ca                	sd	s2,64(sp)
    8000194e:	f456                	sd	s5,40(sp)
    80001950:	f05a                	sd	s6,32(sp)
    80001952:	ec5e                	sd	s7,24(sp)
    80001954:	e862                	sd	s8,16(sp)
    80001956:	1080                	addi	s0,sp,96
    80001958:	8c2a                	mv	s8,a0
    8000195a:	8b2e                	mv	s6,a1
    8000195c:	8bb2                	mv	s7,a2
    8000195e:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001960:	797d                	lui	s2,0xfffff
    80001962:	0125f933          	and	s2,a1,s2
    if(va0 >= MAXVA)
    80001966:	57fd                	li	a5,-1
    80001968:	83e9                	srli	a5,a5,0x1a
    8000196a:	0b27e263          	bltu	a5,s2,80001a0e <copyout+0xca>
    8000196e:	e4a6                	sd	s1,72(sp)
    80001970:	fc4e                	sd	s3,56(sp)
    80001972:	f852                	sd	s4,48(sp)
    80001974:	e466                	sd	s9,8(sp)
    80001976:	e06a                	sd	s10,0(sp)
    80001978:	6d05                	lui	s10,0x1
    8000197a:	8cbe                	mv	s9,a5
    8000197c:	a82d                	j	800019b6 <copyout+0x72>
      if(cowfault(pagetable, va0) < 0) {
    8000197e:	85ca                	mv	a1,s2
    80001980:	8562                	mv	a0,s8
    80001982:	e67ff0ef          	jal	800017e8 <cowfault>
    80001986:	0a054463          	bltz	a0,80001a2e <copyout+0xea>
      pa0 = PTE2PA(*pte);
    8000198a:	0009b483          	ld	s1,0(s3) # 1000 <_entry-0x7ffff000>
    8000198e:	80a9                	srli	s1,s1,0xa
    80001990:	04b2                	slli	s1,s1,0xc
    80001992:	a889                	j	800019e4 <copyout+0xa0>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001994:	412b0533          	sub	a0,s6,s2
    80001998:	0009861b          	sext.w	a2,s3
    8000199c:	85de                	mv	a1,s7
    8000199e:	9526                	add	a0,a0,s1
    800019a0:	d6aff0ef          	jal	80000f0a <memmove>
    len -= n;
    800019a4:	413a8ab3          	sub	s5,s5,s3
    src += n;
    800019a8:	9bce                	add	s7,s7,s3
  while(len > 0){
    800019aa:	040a8963          	beqz	s5,800019fc <copyout+0xb8>
    if(va0 >= MAXVA)
    800019ae:	074ce263          	bltu	s9,s4,80001a12 <copyout+0xce>
    800019b2:	8952                	mv	s2,s4
    800019b4:	8b52                	mv	s6,s4
    pa0 = walkaddr(pagetable, va0);
    800019b6:	85ca                	mv	a1,s2
    800019b8:	8562                	mv	a0,s8
    800019ba:	803ff0ef          	jal	800011bc <walkaddr>
    800019be:	84aa                	mv	s1,a0
    if(pa0 == 0) {
    800019c0:	e901                	bnez	a0,800019d0 <copyout+0x8c>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800019c2:	4601                	li	a2,0
    800019c4:	85ca                	mv	a1,s2
    800019c6:	8562                	mv	a0,s8
    800019c8:	efbff0ef          	jal	800018c2 <vmfault>
    800019cc:	84aa                	mv	s1,a0
    800019ce:	c929                	beqz	a0,80001a20 <copyout+0xdc>
    pte = walk(pagetable, va0, 0);
    800019d0:	4601                	li	a2,0
    800019d2:	85ca                	mv	a1,s2
    800019d4:	8562                	mv	a0,s8
    800019d6:	f4cff0ef          	jal	80001122 <walk>
    800019da:	89aa                	mv	s3,a0
    if((*pte & PTE_COW) != 0) {
    800019dc:	611c                	ld	a5,0(a0)
    800019de:	1007f793          	andi	a5,a5,256
    800019e2:	ffd1                	bnez	a5,8000197e <copyout+0x3a>
    if((*pte & PTE_W) == 0)
    800019e4:	0009b783          	ld	a5,0(s3)
    800019e8:	8b91                	andi	a5,a5,4
    800019ea:	cba9                	beqz	a5,80001a3c <copyout+0xf8>
    n = PGSIZE - (dstva - va0);
    800019ec:	01a90a33          	add	s4,s2,s10
    800019f0:	416a09b3          	sub	s3,s4,s6
    if(n > len)
    800019f4:	fb3af0e3          	bgeu	s5,s3,80001994 <copyout+0x50>
    800019f8:	89d6                	mv	s3,s5
    800019fa:	bf69                	j	80001994 <copyout+0x50>
  return 0;
    800019fc:	4501                	li	a0,0
    800019fe:	64a6                	ld	s1,72(sp)
    80001a00:	79e2                	ld	s3,56(sp)
    80001a02:	7a42                	ld	s4,48(sp)
    80001a04:	6ca2                	ld	s9,8(sp)
    80001a06:	6d02                	ld	s10,0(sp)
    80001a08:	a081                	j	80001a48 <copyout+0x104>
    80001a0a:	4501                	li	a0,0
}
    80001a0c:	8082                	ret
      return -1;
    80001a0e:	557d                	li	a0,-1
    80001a10:	a825                	j	80001a48 <copyout+0x104>
    80001a12:	557d                	li	a0,-1
    80001a14:	64a6                	ld	s1,72(sp)
    80001a16:	79e2                	ld	s3,56(sp)
    80001a18:	7a42                	ld	s4,48(sp)
    80001a1a:	6ca2                	ld	s9,8(sp)
    80001a1c:	6d02                	ld	s10,0(sp)
    80001a1e:	a02d                	j	80001a48 <copyout+0x104>
        return -1;
    80001a20:	557d                	li	a0,-1
    80001a22:	64a6                	ld	s1,72(sp)
    80001a24:	79e2                	ld	s3,56(sp)
    80001a26:	7a42                	ld	s4,48(sp)
    80001a28:	6ca2                	ld	s9,8(sp)
    80001a2a:	6d02                	ld	s10,0(sp)
    80001a2c:	a831                	j	80001a48 <copyout+0x104>
        return -1;
    80001a2e:	557d                	li	a0,-1
    80001a30:	64a6                	ld	s1,72(sp)
    80001a32:	79e2                	ld	s3,56(sp)
    80001a34:	7a42                	ld	s4,48(sp)
    80001a36:	6ca2                	ld	s9,8(sp)
    80001a38:	6d02                	ld	s10,0(sp)
    80001a3a:	a039                	j	80001a48 <copyout+0x104>
      return -1;
    80001a3c:	557d                	li	a0,-1
    80001a3e:	64a6                	ld	s1,72(sp)
    80001a40:	79e2                	ld	s3,56(sp)
    80001a42:	7a42                	ld	s4,48(sp)
    80001a44:	6ca2                	ld	s9,8(sp)
    80001a46:	6d02                	ld	s10,0(sp)
}
    80001a48:	60e6                	ld	ra,88(sp)
    80001a4a:	6446                	ld	s0,80(sp)
    80001a4c:	6906                	ld	s2,64(sp)
    80001a4e:	7aa2                	ld	s5,40(sp)
    80001a50:	7b02                	ld	s6,32(sp)
    80001a52:	6be2                	ld	s7,24(sp)
    80001a54:	6c42                	ld	s8,16(sp)
    80001a56:	6125                	addi	sp,sp,96
    80001a58:	8082                	ret

0000000080001a5a <copyin>:
  while(len > 0){
    80001a5a:	c6c9                	beqz	a3,80001ae4 <copyin+0x8a>
{
    80001a5c:	715d                	addi	sp,sp,-80
    80001a5e:	e486                	sd	ra,72(sp)
    80001a60:	e0a2                	sd	s0,64(sp)
    80001a62:	fc26                	sd	s1,56(sp)
    80001a64:	f84a                	sd	s2,48(sp)
    80001a66:	f44e                	sd	s3,40(sp)
    80001a68:	f052                	sd	s4,32(sp)
    80001a6a:	ec56                	sd	s5,24(sp)
    80001a6c:	e85a                	sd	s6,16(sp)
    80001a6e:	e45e                	sd	s7,8(sp)
    80001a70:	e062                	sd	s8,0(sp)
    80001a72:	0880                	addi	s0,sp,80
    80001a74:	8baa                	mv	s7,a0
    80001a76:	8aae                	mv	s5,a1
    80001a78:	8932                	mv	s2,a2
    80001a7a:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a7c:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a7e:	6b05                	lui	s6,0x1
    80001a80:	a035                	j	80001aac <copyin+0x52>
    80001a82:	412984b3          	sub	s1,s3,s2
    80001a86:	94da                	add	s1,s1,s6
    if(n > len)
    80001a88:	009a7363          	bgeu	s4,s1,80001a8e <copyin+0x34>
    80001a8c:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a8e:	413905b3          	sub	a1,s2,s3
    80001a92:	0004861b          	sext.w	a2,s1
    80001a96:	95aa                	add	a1,a1,a0
    80001a98:	8556                	mv	a0,s5
    80001a9a:	c70ff0ef          	jal	80000f0a <memmove>
    len -= n;
    80001a9e:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001aa2:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001aa4:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001aa8:	020a0163          	beqz	s4,80001aca <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001aac:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001ab0:	85ce                	mv	a1,s3
    80001ab2:	855e                	mv	a0,s7
    80001ab4:	f08ff0ef          	jal	800011bc <walkaddr>
    if(pa0 == 0) {
    80001ab8:	f569                	bnez	a0,80001a82 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001aba:	4601                	li	a2,0
    80001abc:	85ce                	mv	a1,s3
    80001abe:	855e                	mv	a0,s7
    80001ac0:	e03ff0ef          	jal	800018c2 <vmfault>
    80001ac4:	fd5d                	bnez	a0,80001a82 <copyin+0x28>
        return -1;
    80001ac6:	557d                	li	a0,-1
    80001ac8:	a011                	j	80001acc <copyin+0x72>
  return 0;
    80001aca:	4501                	li	a0,0
}
    80001acc:	60a6                	ld	ra,72(sp)
    80001ace:	6406                	ld	s0,64(sp)
    80001ad0:	74e2                	ld	s1,56(sp)
    80001ad2:	7942                	ld	s2,48(sp)
    80001ad4:	79a2                	ld	s3,40(sp)
    80001ad6:	7a02                	ld	s4,32(sp)
    80001ad8:	6ae2                	ld	s5,24(sp)
    80001ada:	6b42                	ld	s6,16(sp)
    80001adc:	6ba2                	ld	s7,8(sp)
    80001ade:	6c02                	ld	s8,0(sp)
    80001ae0:	6161                	addi	sp,sp,80
    80001ae2:	8082                	ret
  return 0;
    80001ae4:	4501                	li	a0,0
}
    80001ae6:	8082                	ret

0000000080001ae8 <ptree_add_recursive>:
static void
ptree_add_recursive(struct proc *root, struct proc_tree *tree)
{
  struct proc *p;
  
  if (tree->count >= NPROC)
    80001ae8:	4198                	lw	a4,0(a1)
    80001aea:	03f00793          	li	a5,63
    80001aee:	00e7d363          	bge	a5,a4,80001af4 <ptree_add_recursive+0xc>
    80001af2:	8082                	ret
{
    80001af4:	7179                	addi	sp,sp,-48
    80001af6:	f406                	sd	ra,40(sp)
    80001af8:	f022                	sd	s0,32(sp)
    80001afa:	ec26                	sd	s1,24(sp)
    80001afc:	e84a                	sd	s2,16(sp)
    80001afe:	e44e                	sd	s3,8(sp)
    80001b00:	e052                	sd	s4,0(sp)
    80001b02:	1800                	addi	s0,sp,48
    80001b04:	892a                	mv	s2,a0
    80001b06:	8a2e                	mv	s4,a1
    return;

  // Add current process to tree
  acquire(&root->lock);
    80001b08:	ad2ff0ef          	jal	80000dda <acquire>
  if (root->state != UNUSED) {
    80001b0c:	01892783          	lw	a5,24(s2) # fffffffffffff018 <end+0xffffffff7ffbbee0>
    80001b10:	ef89                	bnez	a5,80001b2a <ptree_add_recursive+0x42>
    info->pid = root->pid;
    info->ppid = root->parent ? root->parent->pid : 0;
    info->state = root->state;
    tree->count++;
  }
  release(&root->lock);
    80001b12:	854a                	mv	a0,s2
    80001b14:	b5eff0ef          	jal	80000e72 <release>

  // Find and add all children recursively
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b18:	0002f497          	auipc	s1,0x2f
    80001b1c:	62848493          	addi	s1,s1,1576 # 80031140 <proc>
    80001b20:	00036997          	auipc	s3,0x36
    80001b24:	02098993          	addi	s3,s3,32 # 80037b40 <tickslock>
    80001b28:	a0b5                	j	80001b94 <ptree_add_recursive+0xac>
    struct proc_info *info = &tree->processes[tree->count];
    80001b2a:	000a2983          	lw	s3,0(s4)
    safestrcpy(info->name, root->name, sizeof(info->name));
    80001b2e:	00399493          	slli	s1,s3,0x3
    80001b32:	41348533          	sub	a0,s1,s3
    80001b36:	050a                	slli	a0,a0,0x2
    80001b38:	0511                	addi	a0,a0,4
    80001b3a:	4641                	li	a2,16
    80001b3c:	15890593          	addi	a1,s2,344
    80001b40:	9552                	add	a0,a0,s4
    80001b42:	caaff0ef          	jal	80000fec <safestrcpy>
    info->pid = root->pid;
    80001b46:	03092703          	lw	a4,48(s2)
    80001b4a:	413487b3          	sub	a5,s1,s3
    80001b4e:	078a                	slli	a5,a5,0x2
    80001b50:	97d2                	add	a5,a5,s4
    80001b52:	cbd8                	sw	a4,20(a5)
    info->ppid = root->parent ? root->parent->pid : 0;
    80001b54:	03893783          	ld	a5,56(s2)
    80001b58:	4681                	li	a3,0
    80001b5a:	c391                	beqz	a5,80001b5e <ptree_add_recursive+0x76>
    80001b5c:	5b94                	lw	a3,48(a5)
    80001b5e:	00399793          	slli	a5,s3,0x3
    80001b62:	41378733          	sub	a4,a5,s3
    80001b66:	070a                	slli	a4,a4,0x2
    80001b68:	9752                	add	a4,a4,s4
    80001b6a:	cf14                	sw	a3,24(a4)
    info->state = root->state;
    80001b6c:	01892703          	lw	a4,24(s2)
    80001b70:	413787b3          	sub	a5,a5,s3
    80001b74:	078a                	slli	a5,a5,0x2
    80001b76:	97d2                	add	a5,a5,s4
    80001b78:	cfd8                	sw	a4,28(a5)
    tree->count++;
    80001b7a:	000a2783          	lw	a5,0(s4)
    80001b7e:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffbbec9>
    80001b80:	00fa2023          	sw	a5,0(s4)
    80001b84:	b779                	j	80001b12 <ptree_add_recursive+0x2a>
    acquire(&p->lock);
    if (p->parent == root && p->state != UNUSED) {
      release(&p->lock);
      ptree_add_recursive(p, tree);
    } else {
      release(&p->lock);
    80001b86:	8526                	mv	a0,s1
    80001b88:	aeaff0ef          	jal	80000e72 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b8c:	1a848493          	addi	s1,s1,424
    80001b90:	03348263          	beq	s1,s3,80001bb4 <ptree_add_recursive+0xcc>
    acquire(&p->lock);
    80001b94:	8526                	mv	a0,s1
    80001b96:	a44ff0ef          	jal	80000dda <acquire>
    if (p->parent == root && p->state != UNUSED) {
    80001b9a:	7c9c                	ld	a5,56(s1)
    80001b9c:	ff2795e3          	bne	a5,s2,80001b86 <ptree_add_recursive+0x9e>
    80001ba0:	4c9c                	lw	a5,24(s1)
    80001ba2:	d3f5                	beqz	a5,80001b86 <ptree_add_recursive+0x9e>
      release(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	accff0ef          	jal	80000e72 <release>
      ptree_add_recursive(p, tree);
    80001baa:	85d2                	mv	a1,s4
    80001bac:	8526                	mv	a0,s1
    80001bae:	f3bff0ef          	jal	80001ae8 <ptree_add_recursive>
    80001bb2:	bfe9                	j	80001b8c <ptree_add_recursive+0xa4>
    }
  }
}
    80001bb4:	70a2                	ld	ra,40(sp)
    80001bb6:	7402                	ld	s0,32(sp)
    80001bb8:	64e2                	ld	s1,24(sp)
    80001bba:	6942                	ld	s2,16(sp)
    80001bbc:	69a2                	ld	s3,8(sp)
    80001bbe:	6a02                	ld	s4,0(sp)
    80001bc0:	6145                	addi	sp,sp,48
    80001bc2:	8082                	ret

0000000080001bc4 <proc_mapstacks>:
{
    80001bc4:	7139                	addi	sp,sp,-64
    80001bc6:	fc06                	sd	ra,56(sp)
    80001bc8:	f822                	sd	s0,48(sp)
    80001bca:	f426                	sd	s1,40(sp)
    80001bcc:	f04a                	sd	s2,32(sp)
    80001bce:	ec4e                	sd	s3,24(sp)
    80001bd0:	e852                	sd	s4,16(sp)
    80001bd2:	e456                	sd	s5,8(sp)
    80001bd4:	e05a                	sd	s6,0(sp)
    80001bd6:	0080                	addi	s0,sp,64
    80001bd8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bda:	0002f497          	auipc	s1,0x2f
    80001bde:	56648493          	addi	s1,s1,1382 # 80031140 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001be2:	8b26                	mv	s6,s1
    80001be4:	00874937          	lui	s2,0x874
    80001be8:	ecb90913          	addi	s2,s2,-309 # 873ecb <_entry-0x7f78c135>
    80001bec:	0932                	slli	s2,s2,0xc
    80001bee:	de390913          	addi	s2,s2,-541
    80001bf2:	093a                	slli	s2,s2,0xe
    80001bf4:	13590913          	addi	s2,s2,309
    80001bf8:	0932                	slli	s2,s2,0xc
    80001bfa:	21d90913          	addi	s2,s2,541
    80001bfe:	040009b7          	lui	s3,0x4000
    80001c02:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001c04:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c06:	00036a97          	auipc	s5,0x36
    80001c0a:	f3aa8a93          	addi	s5,s5,-198 # 80037b40 <tickslock>
    char *pa = kalloc();
    80001c0e:	8d2ff0ef          	jal	80000ce0 <kalloc>
    80001c12:	862a                	mv	a2,a0
    if(pa == 0)
    80001c14:	cd15                	beqz	a0,80001c50 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001c16:	416485b3          	sub	a1,s1,s6
    80001c1a:	858d                	srai	a1,a1,0x3
    80001c1c:	032585b3          	mul	a1,a1,s2
    80001c20:	2585                	addiw	a1,a1,1
    80001c22:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c26:	4719                	li	a4,6
    80001c28:	6685                	lui	a3,0x1
    80001c2a:	40b985b3          	sub	a1,s3,a1
    80001c2e:	8552                	mv	a0,s4
    80001c30:	e7aff0ef          	jal	800012aa <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c34:	1a848493          	addi	s1,s1,424
    80001c38:	fd549be3          	bne	s1,s5,80001c0e <proc_mapstacks+0x4a>
}
    80001c3c:	70e2                	ld	ra,56(sp)
    80001c3e:	7442                	ld	s0,48(sp)
    80001c40:	74a2                	ld	s1,40(sp)
    80001c42:	7902                	ld	s2,32(sp)
    80001c44:	69e2                	ld	s3,24(sp)
    80001c46:	6a42                	ld	s4,16(sp)
    80001c48:	6aa2                	ld	s5,8(sp)
    80001c4a:	6b02                	ld	s6,0(sp)
    80001c4c:	6121                	addi	sp,sp,64
    80001c4e:	8082                	ret
      panic("kalloc");
    80001c50:	00006517          	auipc	a0,0x6
    80001c54:	53050513          	addi	a0,a0,1328 # 80008180 <etext+0x180>
    80001c58:	b89fe0ef          	jal	800007e0 <panic>

0000000080001c5c <procinit>:
{
    80001c5c:	7139                	addi	sp,sp,-64
    80001c5e:	fc06                	sd	ra,56(sp)
    80001c60:	f822                	sd	s0,48(sp)
    80001c62:	f426                	sd	s1,40(sp)
    80001c64:	f04a                	sd	s2,32(sp)
    80001c66:	ec4e                	sd	s3,24(sp)
    80001c68:	e852                	sd	s4,16(sp)
    80001c6a:	e456                	sd	s5,8(sp)
    80001c6c:	e05a                	sd	s6,0(sp)
    80001c6e:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001c70:	00006597          	auipc	a1,0x6
    80001c74:	51858593          	addi	a1,a1,1304 # 80008188 <etext+0x188>
    80001c78:	0002f517          	auipc	a0,0x2f
    80001c7c:	e7850513          	addi	a0,a0,-392 # 80030af0 <pid_lock>
    80001c80:	8daff0ef          	jal	80000d5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c84:	00006597          	auipc	a1,0x6
    80001c88:	50c58593          	addi	a1,a1,1292 # 80008190 <etext+0x190>
    80001c8c:	0002f517          	auipc	a0,0x2f
    80001c90:	e7c50513          	addi	a0,a0,-388 # 80030b08 <wait_lock>
    80001c94:	8c6ff0ef          	jal	80000d5a <initlock>
  initlock(&runq_lock, "runqueue");
    80001c98:	00006597          	auipc	a1,0x6
    80001c9c:	50858593          	addi	a1,a1,1288 # 800081a0 <etext+0x1a0>
    80001ca0:	0002f517          	auipc	a0,0x2f
    80001ca4:	e8050513          	addi	a0,a0,-384 # 80030b20 <runq_lock>
    80001ca8:	8b2ff0ef          	jal	80000d5a <initlock>
  minheap_init(&run_queue);
    80001cac:	0002f517          	auipc	a0,0x2f
    80001cb0:	e8c50513          	addi	a0,a0,-372 # 80030b38 <run_queue>
    80001cb4:	597040ef          	jal	80006a4a <minheap_init>
  min_vruntime = 0;
    80001cb8:	00007797          	auipc	a5,0x7
    80001cbc:	ce07bc23          	sd	zero,-776(a5) # 800089b0 <min_vruntime>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc0:	0002f497          	auipc	s1,0x2f
    80001cc4:	48048493          	addi	s1,s1,1152 # 80031140 <proc>
      initlock(&p->lock, "proc");
    80001cc8:	00006b17          	auipc	s6,0x6
    80001ccc:	4e8b0b13          	addi	s6,s6,1256 # 800081b0 <etext+0x1b0>
      p->kstack = KSTACK((int) (p - proc));
    80001cd0:	8aa6                	mv	s5,s1
    80001cd2:	00874937          	lui	s2,0x874
    80001cd6:	ecb90913          	addi	s2,s2,-309 # 873ecb <_entry-0x7f78c135>
    80001cda:	0932                	slli	s2,s2,0xc
    80001cdc:	de390913          	addi	s2,s2,-541
    80001ce0:	093a                	slli	s2,s2,0xe
    80001ce2:	13590913          	addi	s2,s2,309
    80001ce6:	0932                	slli	s2,s2,0xc
    80001ce8:	21d90913          	addi	s2,s2,541
    80001cec:	040009b7          	lui	s3,0x4000
    80001cf0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001cf2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cf4:	00036a17          	auipc	s4,0x36
    80001cf8:	e4ca0a13          	addi	s4,s4,-436 # 80037b40 <tickslock>
      initlock(&p->lock, "proc");
    80001cfc:	85da                	mv	a1,s6
    80001cfe:	8526                	mv	a0,s1
    80001d00:	85aff0ef          	jal	80000d5a <initlock>
      p->state = UNUSED;
    80001d04:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001d08:	415487b3          	sub	a5,s1,s5
    80001d0c:	878d                	srai	a5,a5,0x3
    80001d0e:	032787b3          	mul	a5,a5,s2
    80001d12:	2785                	addiw	a5,a5,1
    80001d14:	00d7979b          	slliw	a5,a5,0xd
    80001d18:	40f987b3          	sub	a5,s3,a5
    80001d1c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d1e:	1a848493          	addi	s1,s1,424
    80001d22:	fd449de3          	bne	s1,s4,80001cfc <procinit+0xa0>
}
    80001d26:	70e2                	ld	ra,56(sp)
    80001d28:	7442                	ld	s0,48(sp)
    80001d2a:	74a2                	ld	s1,40(sp)
    80001d2c:	7902                	ld	s2,32(sp)
    80001d2e:	69e2                	ld	s3,24(sp)
    80001d30:	6a42                	ld	s4,16(sp)
    80001d32:	6aa2                	ld	s5,8(sp)
    80001d34:	6b02                	ld	s6,0(sp)
    80001d36:	6121                	addi	sp,sp,64
    80001d38:	8082                	ret

0000000080001d3a <cpuid>:
{
    80001d3a:	1141                	addi	sp,sp,-16
    80001d3c:	e422                	sd	s0,8(sp)
    80001d3e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d40:	8512                	mv	a0,tp
}
    80001d42:	2501                	sext.w	a0,a0
    80001d44:	6422                	ld	s0,8(sp)
    80001d46:	0141                	addi	sp,sp,16
    80001d48:	8082                	ret

0000000080001d4a <mycpu>:
{
    80001d4a:	1141                	addi	sp,sp,-16
    80001d4c:	e422                	sd	s0,8(sp)
    80001d4e:	0800                	addi	s0,sp,16
    80001d50:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d52:	2781                	sext.w	a5,a5
    80001d54:	079e                	slli	a5,a5,0x7
}
    80001d56:	0002f517          	auipc	a0,0x2f
    80001d5a:	fea50513          	addi	a0,a0,-22 # 80030d40 <cpus>
    80001d5e:	953e                	add	a0,a0,a5
    80001d60:	6422                	ld	s0,8(sp)
    80001d62:	0141                	addi	sp,sp,16
    80001d64:	8082                	ret

0000000080001d66 <myproc>:
{
    80001d66:	1101                	addi	sp,sp,-32
    80001d68:	ec06                	sd	ra,24(sp)
    80001d6a:	e822                	sd	s0,16(sp)
    80001d6c:	e426                	sd	s1,8(sp)
    80001d6e:	1000                	addi	s0,sp,32
  push_off();
    80001d70:	82aff0ef          	jal	80000d9a <push_off>
    80001d74:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001d76:	2781                	sext.w	a5,a5
    80001d78:	079e                	slli	a5,a5,0x7
    80001d7a:	0002f717          	auipc	a4,0x2f
    80001d7e:	d7670713          	addi	a4,a4,-650 # 80030af0 <pid_lock>
    80001d82:	97ba                	add	a5,a5,a4
    80001d84:	2507b483          	ld	s1,592(a5)
  pop_off();
    80001d88:	896ff0ef          	jal	80000e1e <pop_off>
}
    80001d8c:	8526                	mv	a0,s1
    80001d8e:	60e2                	ld	ra,24(sp)
    80001d90:	6442                	ld	s0,16(sp)
    80001d92:	64a2                	ld	s1,8(sp)
    80001d94:	6105                	addi	sp,sp,32
    80001d96:	8082                	ret

0000000080001d98 <allocpid>:
{
    80001d98:	1101                	addi	sp,sp,-32
    80001d9a:	ec06                	sd	ra,24(sp)
    80001d9c:	e822                	sd	s0,16(sp)
    80001d9e:	e426                	sd	s1,8(sp)
    80001da0:	e04a                	sd	s2,0(sp)
    80001da2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001da4:	0002f917          	auipc	s2,0x2f
    80001da8:	d4c90913          	addi	s2,s2,-692 # 80030af0 <pid_lock>
    80001dac:	854a                	mv	a0,s2
    80001dae:	82cff0ef          	jal	80000dda <acquire>
  pid = nextpid;
    80001db2:	00007797          	auipc	a5,0x7
    80001db6:	bd278793          	addi	a5,a5,-1070 # 80008984 <nextpid>
    80001dba:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dbc:	0014871b          	addiw	a4,s1,1
    80001dc0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001dc2:	854a                	mv	a0,s2
    80001dc4:	8aeff0ef          	jal	80000e72 <release>
}
    80001dc8:	8526                	mv	a0,s1
    80001dca:	60e2                	ld	ra,24(sp)
    80001dcc:	6442                	ld	s0,16(sp)
    80001dce:	64a2                	ld	s1,8(sp)
    80001dd0:	6902                	ld	s2,0(sp)
    80001dd2:	6105                	addi	sp,sp,32
    80001dd4:	8082                	ret

0000000080001dd6 <pid_namespace_alloc>:
{
    80001dd6:	1101                	addi	sp,sp,-32
    80001dd8:	ec06                	sd	ra,24(sp)
    80001dda:	e822                	sd	s0,16(sp)
    80001ddc:	e426                	sd	s1,8(sp)
    80001dde:	1000                	addi	s0,sp,32
  ns = (struct pid_namespace *)kalloc();
    80001de0:	f01fe0ef          	jal	80000ce0 <kalloc>
    80001de4:	84aa                	mv	s1,a0
  if(ns == 0)
    80001de6:	c919                	beqz	a0,80001dfc <pid_namespace_alloc+0x26>
  ns->refcount = 1;
    80001de8:	4785                	li	a5,1
    80001dea:	c11c                	sw	a5,0(a0)
  ns->next_pid = 1;
    80001dec:	c15c                	sw	a5,4(a0)
  initlock(&ns->lock, "pid_ns");
    80001dee:	00006597          	auipc	a1,0x6
    80001df2:	3ca58593          	addi	a1,a1,970 # 800081b8 <etext+0x1b8>
    80001df6:	0521                	addi	a0,a0,8
    80001df8:	f63fe0ef          	jal	80000d5a <initlock>
}
    80001dfc:	8526                	mv	a0,s1
    80001dfe:	60e2                	ld	ra,24(sp)
    80001e00:	6442                	ld	s0,16(sp)
    80001e02:	64a2                	ld	s1,8(sp)
    80001e04:	6105                	addi	sp,sp,32
    80001e06:	8082                	ret

0000000080001e08 <pid_namespace_get_pid>:
{
    80001e08:	7179                	addi	sp,sp,-48
    80001e0a:	f406                	sd	ra,40(sp)
    80001e0c:	f022                	sd	s0,32(sp)
    80001e0e:	e84a                	sd	s2,16(sp)
    80001e10:	1800                	addi	s0,sp,48
  if(ns == 0)
    80001e12:	c90d                	beqz	a0,80001e44 <pid_namespace_get_pid+0x3c>
    80001e14:	ec26                	sd	s1,24(sp)
    80001e16:	e44e                	sd	s3,8(sp)
    80001e18:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001e1a:	00850993          	addi	s3,a0,8
    80001e1e:	854e                	mv	a0,s3
    80001e20:	fbbfe0ef          	jal	80000dda <acquire>
  pid = ns->next_pid;
    80001e24:	0044a903          	lw	s2,4(s1)
  ns->next_pid = ns->next_pid + 1;
    80001e28:	0019079b          	addiw	a5,s2,1
    80001e2c:	c0dc                	sw	a5,4(s1)
  release(&ns->lock);
    80001e2e:	854e                	mv	a0,s3
    80001e30:	842ff0ef          	jal	80000e72 <release>
  return pid;
    80001e34:	64e2                	ld	s1,24(sp)
    80001e36:	69a2                	ld	s3,8(sp)
}
    80001e38:	854a                	mv	a0,s2
    80001e3a:	70a2                	ld	ra,40(sp)
    80001e3c:	7402                	ld	s0,32(sp)
    80001e3e:	6942                	ld	s2,16(sp)
    80001e40:	6145                	addi	sp,sp,48
    80001e42:	8082                	ret
    return -1;
    80001e44:	597d                	li	s2,-1
    80001e46:	bfcd                	j	80001e38 <pid_namespace_get_pid+0x30>

0000000080001e48 <pid_namespace_get>:
  if(ns == 0)
    80001e48:	c90d                	beqz	a0,80001e7a <pid_namespace_get+0x32>
{
    80001e4a:	1101                	addi	sp,sp,-32
    80001e4c:	ec06                	sd	ra,24(sp)
    80001e4e:	e822                	sd	s0,16(sp)
    80001e50:	e426                	sd	s1,8(sp)
    80001e52:	e04a                	sd	s2,0(sp)
    80001e54:	1000                	addi	s0,sp,32
    80001e56:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001e58:	00850913          	addi	s2,a0,8
    80001e5c:	854a                	mv	a0,s2
    80001e5e:	f7dfe0ef          	jal	80000dda <acquire>
  ns->refcount++;
    80001e62:	409c                	lw	a5,0(s1)
    80001e64:	2785                	addiw	a5,a5,1
    80001e66:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80001e68:	854a                	mv	a0,s2
    80001e6a:	808ff0ef          	jal	80000e72 <release>
}
    80001e6e:	60e2                	ld	ra,24(sp)
    80001e70:	6442                	ld	s0,16(sp)
    80001e72:	64a2                	ld	s1,8(sp)
    80001e74:	6902                	ld	s2,0(sp)
    80001e76:	6105                	addi	sp,sp,32
    80001e78:	8082                	ret
    80001e7a:	8082                	ret

0000000080001e7c <pid_namespace_put>:
  if(ns == 0)
    80001e7c:	c139                	beqz	a0,80001ec2 <pid_namespace_put+0x46>
{
    80001e7e:	7179                	addi	sp,sp,-48
    80001e80:	f406                	sd	ra,40(sp)
    80001e82:	f022                	sd	s0,32(sp)
    80001e84:	ec26                	sd	s1,24(sp)
    80001e86:	e84a                	sd	s2,16(sp)
    80001e88:	e44e                	sd	s3,8(sp)
    80001e8a:	1800                	addi	s0,sp,48
    80001e8c:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001e8e:	00850913          	addi	s2,a0,8
    80001e92:	854a                	mv	a0,s2
    80001e94:	f47fe0ef          	jal	80000dda <acquire>
  ns->refcount--;
    80001e98:	409c                	lw	a5,0(s1)
    80001e9a:	37fd                	addiw	a5,a5,-1
    80001e9c:	0007899b          	sext.w	s3,a5
    80001ea0:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80001ea2:	854a                	mv	a0,s2
    80001ea4:	fcffe0ef          	jal	80000e72 <release>
  if(refcount == 0) {
    80001ea8:	00098963          	beqz	s3,80001eba <pid_namespace_put+0x3e>
}
    80001eac:	70a2                	ld	ra,40(sp)
    80001eae:	7402                	ld	s0,32(sp)
    80001eb0:	64e2                	ld	s1,24(sp)
    80001eb2:	6942                	ld	s2,16(sp)
    80001eb4:	69a2                	ld	s3,8(sp)
    80001eb6:	6145                	addi	sp,sp,48
    80001eb8:	8082                	ret
    kfree((void *)ns);
    80001eba:	8526                	mv	a0,s1
    80001ebc:	ca3fe0ef          	jal	80000b5e <kfree>
    80001ec0:	b7f5                	j	80001eac <pid_namespace_put+0x30>
    80001ec2:	8082                	ret

0000000080001ec4 <mount_namespace_alloc>:
{
    80001ec4:	1101                	addi	sp,sp,-32
    80001ec6:	ec06                	sd	ra,24(sp)
    80001ec8:	e822                	sd	s0,16(sp)
    80001eca:	e426                	sd	s1,8(sp)
    80001ecc:	e04a                	sd	s2,0(sp)
    80001ece:	1000                	addi	s0,sp,32
    80001ed0:	892a                	mv	s2,a0
  ns = (struct mount_namespace *)kalloc();
    80001ed2:	e0ffe0ef          	jal	80000ce0 <kalloc>
    80001ed6:	84aa                	mv	s1,a0
  if(ns == 0)
    80001ed8:	cd01                	beqz	a0,80001ef0 <mount_namespace_alloc+0x2c>
  ns->refcnt = 1;
    80001eda:	4785                	li	a5,1
    80001edc:	c11c                	sw	a5,0(a0)
  ns->root = root;
    80001ede:	01253423          	sd	s2,8(a0)
  initlock(&ns->lock, "mount_ns");
    80001ee2:	00006597          	auipc	a1,0x6
    80001ee6:	2de58593          	addi	a1,a1,734 # 800081c0 <etext+0x1c0>
    80001eea:	0541                	addi	a0,a0,16
    80001eec:	e6ffe0ef          	jal	80000d5a <initlock>
}
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	60e2                	ld	ra,24(sp)
    80001ef4:	6442                	ld	s0,16(sp)
    80001ef6:	64a2                	ld	s1,8(sp)
    80001ef8:	6902                	ld	s2,0(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret

0000000080001efe <mount_namespace_get>:
  if(ns == 0)
    80001efe:	c90d                	beqz	a0,80001f30 <mount_namespace_get+0x32>
{
    80001f00:	1101                	addi	sp,sp,-32
    80001f02:	ec06                	sd	ra,24(sp)
    80001f04:	e822                	sd	s0,16(sp)
    80001f06:	e426                	sd	s1,8(sp)
    80001f08:	e04a                	sd	s2,0(sp)
    80001f0a:	1000                	addi	s0,sp,32
    80001f0c:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001f0e:	01050913          	addi	s2,a0,16
    80001f12:	854a                	mv	a0,s2
    80001f14:	ec7fe0ef          	jal	80000dda <acquire>
  ns->refcnt++;
    80001f18:	409c                	lw	a5,0(s1)
    80001f1a:	2785                	addiw	a5,a5,1
    80001f1c:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80001f1e:	854a                	mv	a0,s2
    80001f20:	f53fe0ef          	jal	80000e72 <release>
}
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6902                	ld	s2,0(sp)
    80001f2c:	6105                	addi	sp,sp,32
    80001f2e:	8082                	ret
    80001f30:	8082                	ret

0000000080001f32 <mount_namespace_put>:
  if(ns == 0)
    80001f32:	c531                	beqz	a0,80001f7e <mount_namespace_put+0x4c>
{
    80001f34:	7179                	addi	sp,sp,-48
    80001f36:	f406                	sd	ra,40(sp)
    80001f38:	f022                	sd	s0,32(sp)
    80001f3a:	ec26                	sd	s1,24(sp)
    80001f3c:	e84a                	sd	s2,16(sp)
    80001f3e:	e44e                	sd	s3,8(sp)
    80001f40:	1800                	addi	s0,sp,48
    80001f42:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001f44:	01050913          	addi	s2,a0,16
    80001f48:	854a                	mv	a0,s2
    80001f4a:	e91fe0ef          	jal	80000dda <acquire>
  ns->refcnt--;
    80001f4e:	409c                	lw	a5,0(s1)
    80001f50:	37fd                	addiw	a5,a5,-1
    80001f52:	0007899b          	sext.w	s3,a5
    80001f56:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80001f58:	854a                	mv	a0,s2
    80001f5a:	f19fe0ef          	jal	80000e72 <release>
  if(refcnt == 0) {
    80001f5e:	00099963          	bnez	s3,80001f70 <mount_namespace_put+0x3e>
    if(ns->root)
    80001f62:	6488                	ld	a0,8(s1)
    80001f64:	c119                	beqz	a0,80001f6a <mount_namespace_put+0x38>
      iput(ns->root);
    80001f66:	4d8020ef          	jal	8000443e <iput>
    kfree((void *)ns);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	bf3fe0ef          	jal	80000b5e <kfree>
}
    80001f70:	70a2                	ld	ra,40(sp)
    80001f72:	7402                	ld	s0,32(sp)
    80001f74:	64e2                	ld	s1,24(sp)
    80001f76:	6942                	ld	s2,16(sp)
    80001f78:	69a2                	ld	s3,8(sp)
    80001f7a:	6145                	addi	sp,sp,48
    80001f7c:	8082                	ret
    80001f7e:	8082                	ret

0000000080001f80 <uts_namespace_alloc>:
{
    80001f80:	1101                	addi	sp,sp,-32
    80001f82:	ec06                	sd	ra,24(sp)
    80001f84:	e822                	sd	s0,16(sp)
    80001f86:	e426                	sd	s1,8(sp)
    80001f88:	1000                	addi	s0,sp,32
  ns = (struct uts_namespace *)kalloc();
    80001f8a:	d57fe0ef          	jal	80000ce0 <kalloc>
    80001f8e:	84aa                	mv	s1,a0
  if(ns == 0)
    80001f90:	c10d                	beqz	a0,80001fb2 <uts_namespace_alloc+0x32>
  ns->refcnt = 1;
    80001f92:	4785                	li	a5,1
    80001f94:	c11c                	sw	a5,0(a0)
  memset(ns->hostname, 0, HOSTNAME_LEN);
    80001f96:	04000613          	li	a2,64
    80001f9a:	4581                	li	a1,0
    80001f9c:	0511                	addi	a0,a0,4
    80001f9e:	f11fe0ef          	jal	80000eae <memset>
  initlock(&ns->lock, "uts_ns");
    80001fa2:	00006597          	auipc	a1,0x6
    80001fa6:	22e58593          	addi	a1,a1,558 # 800081d0 <etext+0x1d0>
    80001faa:	04848513          	addi	a0,s1,72
    80001fae:	dadfe0ef          	jal	80000d5a <initlock>
}
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	60e2                	ld	ra,24(sp)
    80001fb6:	6442                	ld	s0,16(sp)
    80001fb8:	64a2                	ld	s1,8(sp)
    80001fba:	6105                	addi	sp,sp,32
    80001fbc:	8082                	ret

0000000080001fbe <uts_namespace_get>:
  if(ns == 0)
    80001fbe:	c90d                	beqz	a0,80001ff0 <uts_namespace_get+0x32>
{
    80001fc0:	1101                	addi	sp,sp,-32
    80001fc2:	ec06                	sd	ra,24(sp)
    80001fc4:	e822                	sd	s0,16(sp)
    80001fc6:	e426                	sd	s1,8(sp)
    80001fc8:	e04a                	sd	s2,0(sp)
    80001fca:	1000                	addi	s0,sp,32
    80001fcc:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80001fce:	04850913          	addi	s2,a0,72
    80001fd2:	854a                	mv	a0,s2
    80001fd4:	e07fe0ef          	jal	80000dda <acquire>
  ns->refcnt++;
    80001fd8:	409c                	lw	a5,0(s1)
    80001fda:	2785                	addiw	a5,a5,1
    80001fdc:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80001fde:	854a                	mv	a0,s2
    80001fe0:	e93fe0ef          	jal	80000e72 <release>
}
    80001fe4:	60e2                	ld	ra,24(sp)
    80001fe6:	6442                	ld	s0,16(sp)
    80001fe8:	64a2                	ld	s1,8(sp)
    80001fea:	6902                	ld	s2,0(sp)
    80001fec:	6105                	addi	sp,sp,32
    80001fee:	8082                	ret
    80001ff0:	8082                	ret

0000000080001ff2 <uts_namespace_put>:
  if(ns == 0)
    80001ff2:	c139                	beqz	a0,80002038 <uts_namespace_put+0x46>
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	1800                	addi	s0,sp,48
    80002002:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    80002004:	04850913          	addi	s2,a0,72
    80002008:	854a                	mv	a0,s2
    8000200a:	dd1fe0ef          	jal	80000dda <acquire>
  ns->refcnt--;
    8000200e:	409c                	lw	a5,0(s1)
    80002010:	37fd                	addiw	a5,a5,-1
    80002012:	0007899b          	sext.w	s3,a5
    80002016:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    80002018:	854a                	mv	a0,s2
    8000201a:	e59fe0ef          	jal	80000e72 <release>
  if(refcnt == 0) {
    8000201e:	00098963          	beqz	s3,80002030 <uts_namespace_put+0x3e>
}
    80002022:	70a2                	ld	ra,40(sp)
    80002024:	7402                	ld	s0,32(sp)
    80002026:	64e2                	ld	s1,24(sp)
    80002028:	6942                	ld	s2,16(sp)
    8000202a:	69a2                	ld	s3,8(sp)
    8000202c:	6145                	addi	sp,sp,48
    8000202e:	8082                	ret
    kfree((void *)ns);
    80002030:	8526                	mv	a0,s1
    80002032:	b2dfe0ef          	jal	80000b5e <kfree>
    80002036:	b7f5                	j	80002022 <uts_namespace_put+0x30>
    80002038:	8082                	ret

000000008000203a <ipc_namespace_alloc>:
{
    8000203a:	1101                	addi	sp,sp,-32
    8000203c:	ec06                	sd	ra,24(sp)
    8000203e:	e822                	sd	s0,16(sp)
    80002040:	e426                	sd	s1,8(sp)
    80002042:	1000                	addi	s0,sp,32
  ns = (struct ipc_namespace *)kalloc();
    80002044:	c9dfe0ef          	jal	80000ce0 <kalloc>
    80002048:	84aa                	mv	s1,a0
  if(ns == 0)
    8000204a:	c911                	beqz	a0,8000205e <ipc_namespace_alloc+0x24>
  ns->refcnt = 1;
    8000204c:	4785                	li	a5,1
    8000204e:	c11c                	sw	a5,0(a0)
  initlock(&ns->lock, "ipc_ns");
    80002050:	00006597          	auipc	a1,0x6
    80002054:	18858593          	addi	a1,a1,392 # 800081d8 <etext+0x1d8>
    80002058:	0521                	addi	a0,a0,8
    8000205a:	d01fe0ef          	jal	80000d5a <initlock>
}
    8000205e:	8526                	mv	a0,s1
    80002060:	60e2                	ld	ra,24(sp)
    80002062:	6442                	ld	s0,16(sp)
    80002064:	64a2                	ld	s1,8(sp)
    80002066:	6105                	addi	sp,sp,32
    80002068:	8082                	ret

000000008000206a <ipc_namespace_get>:
  if(ns == 0)
    8000206a:	c90d                	beqz	a0,8000209c <ipc_namespace_get+0x32>
{
    8000206c:	1101                	addi	sp,sp,-32
    8000206e:	ec06                	sd	ra,24(sp)
    80002070:	e822                	sd	s0,16(sp)
    80002072:	e426                	sd	s1,8(sp)
    80002074:	e04a                	sd	s2,0(sp)
    80002076:	1000                	addi	s0,sp,32
    80002078:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    8000207a:	00850913          	addi	s2,a0,8
    8000207e:	854a                	mv	a0,s2
    80002080:	d5bfe0ef          	jal	80000dda <acquire>
  ns->refcnt++;
    80002084:	409c                	lw	a5,0(s1)
    80002086:	2785                	addiw	a5,a5,1
    80002088:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    8000208a:	854a                	mv	a0,s2
    8000208c:	de7fe0ef          	jal	80000e72 <release>
}
    80002090:	60e2                	ld	ra,24(sp)
    80002092:	6442                	ld	s0,16(sp)
    80002094:	64a2                	ld	s1,8(sp)
    80002096:	6902                	ld	s2,0(sp)
    80002098:	6105                	addi	sp,sp,32
    8000209a:	8082                	ret
    8000209c:	8082                	ret

000000008000209e <ipc_namespace_put>:
  if(ns == 0)
    8000209e:	c139                	beqz	a0,800020e4 <ipc_namespace_put+0x46>
{
    800020a0:	7179                	addi	sp,sp,-48
    800020a2:	f406                	sd	ra,40(sp)
    800020a4:	f022                	sd	s0,32(sp)
    800020a6:	ec26                	sd	s1,24(sp)
    800020a8:	e84a                	sd	s2,16(sp)
    800020aa:	e44e                	sd	s3,8(sp)
    800020ac:	1800                	addi	s0,sp,48
    800020ae:	84aa                	mv	s1,a0
  acquire(&ns->lock);
    800020b0:	00850913          	addi	s2,a0,8
    800020b4:	854a                	mv	a0,s2
    800020b6:	d25fe0ef          	jal	80000dda <acquire>
  ns->refcnt--;
    800020ba:	409c                	lw	a5,0(s1)
    800020bc:	37fd                	addiw	a5,a5,-1
    800020be:	0007899b          	sext.w	s3,a5
    800020c2:	c09c                	sw	a5,0(s1)
  release(&ns->lock);
    800020c4:	854a                	mv	a0,s2
    800020c6:	dadfe0ef          	jal	80000e72 <release>
  if(refcnt == 0) {
    800020ca:	00098963          	beqz	s3,800020dc <ipc_namespace_put+0x3e>
}
    800020ce:	70a2                	ld	ra,40(sp)
    800020d0:	7402                	ld	s0,32(sp)
    800020d2:	64e2                	ld	s1,24(sp)
    800020d4:	6942                	ld	s2,16(sp)
    800020d6:	69a2                	ld	s3,8(sp)
    800020d8:	6145                	addi	sp,sp,48
    800020da:	8082                	ret
    kfree((void *)ns);
    800020dc:	8526                	mv	a0,s1
    800020de:	a81fe0ef          	jal	80000b5e <kfree>
    800020e2:	b7f5                	j	800020ce <ipc_namespace_put+0x30>
    800020e4:	8082                	ret

00000000800020e6 <proc_pagetable>:
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800020f4:	aacff0ef          	jal	800013a0 <uvmcreate>
    800020f8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800020fa:	cd05                	beqz	a0,80002132 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800020fc:	4729                	li	a4,10
    800020fe:	00005697          	auipc	a3,0x5
    80002102:	f0268693          	addi	a3,a3,-254 # 80007000 <_trampoline>
    80002106:	6605                	lui	a2,0x1
    80002108:	040005b7          	lui	a1,0x4000
    8000210c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000210e:	05b2                	slli	a1,a1,0xc
    80002110:	8eaff0ef          	jal	800011fa <mappages>
    80002114:	02054663          	bltz	a0,80002140 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80002118:	4719                	li	a4,6
    8000211a:	05893683          	ld	a3,88(s2)
    8000211e:	6605                	lui	a2,0x1
    80002120:	020005b7          	lui	a1,0x2000
    80002124:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002126:	05b6                	slli	a1,a1,0xd
    80002128:	8526                	mv	a0,s1
    8000212a:	8d0ff0ef          	jal	800011fa <mappages>
    8000212e:	00054f63          	bltz	a0,8000214c <proc_pagetable+0x66>
}
    80002132:	8526                	mv	a0,s1
    80002134:	60e2                	ld	ra,24(sp)
    80002136:	6442                	ld	s0,16(sp)
    80002138:	64a2                	ld	s1,8(sp)
    8000213a:	6902                	ld	s2,0(sp)
    8000213c:	6105                	addi	sp,sp,32
    8000213e:	8082                	ret
    uvmfree(pagetable, 0);
    80002140:	4581                	li	a1,0
    80002142:	8526                	mv	a0,s1
    80002144:	c42ff0ef          	jal	80001586 <uvmfree>
    return 0;
    80002148:	4481                	li	s1,0
    8000214a:	b7e5                	j	80002132 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000214c:	4681                	li	a3,0
    8000214e:	4605                	li	a2,1
    80002150:	040005b7          	lui	a1,0x4000
    80002154:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002156:	05b2                	slli	a1,a1,0xc
    80002158:	8526                	mv	a0,s1
    8000215a:	a6cff0ef          	jal	800013c6 <uvmunmap>
    uvmfree(pagetable, 0);
    8000215e:	4581                	li	a1,0
    80002160:	8526                	mv	a0,s1
    80002162:	c24ff0ef          	jal	80001586 <uvmfree>
    return 0;
    80002166:	4481                	li	s1,0
    80002168:	b7e9                	j	80002132 <proc_pagetable+0x4c>

000000008000216a <proc_freepagetable>:
{
    8000216a:	1101                	addi	sp,sp,-32
    8000216c:	ec06                	sd	ra,24(sp)
    8000216e:	e822                	sd	s0,16(sp)
    80002170:	e426                	sd	s1,8(sp)
    80002172:	e04a                	sd	s2,0(sp)
    80002174:	1000                	addi	s0,sp,32
    80002176:	84aa                	mv	s1,a0
    80002178:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000217a:	4681                	li	a3,0
    8000217c:	4605                	li	a2,1
    8000217e:	040005b7          	lui	a1,0x4000
    80002182:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002184:	05b2                	slli	a1,a1,0xc
    80002186:	a40ff0ef          	jal	800013c6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000218a:	4681                	li	a3,0
    8000218c:	4605                	li	a2,1
    8000218e:	020005b7          	lui	a1,0x2000
    80002192:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002194:	05b6                	slli	a1,a1,0xd
    80002196:	8526                	mv	a0,s1
    80002198:	a2eff0ef          	jal	800013c6 <uvmunmap>
  uvmfree(pagetable, sz);
    8000219c:	85ca                	mv	a1,s2
    8000219e:	8526                	mv	a0,s1
    800021a0:	be6ff0ef          	jal	80001586 <uvmfree>
}
    800021a4:	60e2                	ld	ra,24(sp)
    800021a6:	6442                	ld	s0,16(sp)
    800021a8:	64a2                	ld	s1,8(sp)
    800021aa:	6902                	ld	s2,0(sp)
    800021ac:	6105                	addi	sp,sp,32
    800021ae:	8082                	ret

00000000800021b0 <freeproc>:
{
    800021b0:	1101                	addi	sp,sp,-32
    800021b2:	ec06                	sd	ra,24(sp)
    800021b4:	e822                	sd	s0,16(sp)
    800021b6:	e426                	sd	s1,8(sp)
    800021b8:	1000                	addi	s0,sp,32
    800021ba:	84aa                	mv	s1,a0
  if(p->trapframe)
    800021bc:	6d28                	ld	a0,88(a0)
    800021be:	c119                	beqz	a0,800021c4 <freeproc+0x14>
    kfree((void*)p->trapframe);
    800021c0:	99ffe0ef          	jal	80000b5e <kfree>
  p->trapframe = 0;
    800021c4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800021c8:	68a8                	ld	a0,80(s1)
    800021ca:	c501                	beqz	a0,800021d2 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800021cc:	64ac                	ld	a1,72(s1)
    800021ce:	f9dff0ef          	jal	8000216a <proc_freepagetable>
  p->pagetable = 0;
    800021d2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800021d6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800021da:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800021de:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800021e2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800021e6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800021ea:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800021ee:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800021f2:	0004ac23          	sw	zero,24(s1)
  p->is_kproc = 0;
    800021f6:	1604ac23          	sw	zero,376(s1)
  p->kentry = 0;
    800021fa:	1804b023          	sd	zero,384(s1)
  if(p->pid_ns) {
    800021fe:	1884b503          	ld	a0,392(s1)
    80002202:	c509                	beqz	a0,8000220c <freeproc+0x5c>
    pid_namespace_put(p->pid_ns);
    80002204:	c79ff0ef          	jal	80001e7c <pid_namespace_put>
    p->pid_ns = 0;
    80002208:	1804b423          	sd	zero,392(s1)
  if(p->mnt_ns) {
    8000220c:	1904b503          	ld	a0,400(s1)
    80002210:	c509                	beqz	a0,8000221a <freeproc+0x6a>
    mount_namespace_put(p->mnt_ns);
    80002212:	d21ff0ef          	jal	80001f32 <mount_namespace_put>
    p->mnt_ns = 0;
    80002216:	1804b823          	sd	zero,400(s1)
  if(p->uts_ns) {
    8000221a:	1984b503          	ld	a0,408(s1)
    8000221e:	c509                	beqz	a0,80002228 <freeproc+0x78>
    uts_namespace_put(p->uts_ns);
    80002220:	dd3ff0ef          	jal	80001ff2 <uts_namespace_put>
    p->uts_ns = 0;
    80002224:	1804bc23          	sd	zero,408(s1)
  if(p->ipc_ns) {
    80002228:	1a04b503          	ld	a0,416(s1)
    8000222c:	c509                	beqz	a0,80002236 <freeproc+0x86>
    ipc_namespace_put(p->ipc_ns);
    8000222e:	e71ff0ef          	jal	8000209e <ipc_namespace_put>
    p->ipc_ns = 0;
    80002232:	1a04b023          	sd	zero,416(s1)
}
    80002236:	60e2                	ld	ra,24(sp)
    80002238:	6442                	ld	s0,16(sp)
    8000223a:	64a2                	ld	s1,8(sp)
    8000223c:	6105                	addi	sp,sp,32
    8000223e:	8082                	ret

0000000080002240 <allocproc>:
{
    80002240:	1101                	addi	sp,sp,-32
    80002242:	ec06                	sd	ra,24(sp)
    80002244:	e822                	sd	s0,16(sp)
    80002246:	e426                	sd	s1,8(sp)
    80002248:	e04a                	sd	s2,0(sp)
    8000224a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000224c:	0002f497          	auipc	s1,0x2f
    80002250:	ef448493          	addi	s1,s1,-268 # 80031140 <proc>
    80002254:	00036917          	auipc	s2,0x36
    80002258:	8ec90913          	addi	s2,s2,-1812 # 80037b40 <tickslock>
    acquire(&p->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	b7dfe0ef          	jal	80000dda <acquire>
    if(p->state == UNUSED) {
    80002262:	4c9c                	lw	a5,24(s1)
    80002264:	cb91                	beqz	a5,80002278 <allocproc+0x38>
      release(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	c0bfe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000226c:	1a848493          	addi	s1,s1,424
    80002270:	ff2496e3          	bne	s1,s2,8000225c <allocproc+0x1c>
  return 0;
    80002274:	4481                	li	s1,0
    80002276:	a841                	j	80002306 <allocproc+0xc6>
  p->pid = allocpid();
    80002278:	b21ff0ef          	jal	80001d98 <allocpid>
    8000227c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000227e:	4785                	li	a5,1
    80002280:	cc9c                	sw	a5,24(s1)
  p->is_kproc = 0;
    80002282:	1604ac23          	sw	zero,376(s1)
  p->kentry = 0;
    80002286:	1804b023          	sd	zero,384(s1)
  p->pid_ns = pid_namespace_alloc();
    8000228a:	b4dff0ef          	jal	80001dd6 <pid_namespace_alloc>
    8000228e:	892a                	mv	s2,a0
    80002290:	18a4b423          	sd	a0,392(s1)
  if(p->pid_ns == 0){
    80002294:	c141                	beqz	a0,80002314 <allocproc+0xd4>
  p->mnt_ns = mount_namespace_alloc(0);
    80002296:	4501                	li	a0,0
    80002298:	c2dff0ef          	jal	80001ec4 <mount_namespace_alloc>
    8000229c:	892a                	mv	s2,a0
    8000229e:	18a4b823          	sd	a0,400(s1)
  if(p->mnt_ns == 0){
    800022a2:	c149                	beqz	a0,80002324 <allocproc+0xe4>
  p->uts_ns = uts_namespace_alloc();
    800022a4:	cddff0ef          	jal	80001f80 <uts_namespace_alloc>
    800022a8:	892a                	mv	s2,a0
    800022aa:	18a4bc23          	sd	a0,408(s1)
  if(p->uts_ns == 0){
    800022ae:	c159                	beqz	a0,80002334 <allocproc+0xf4>
  p->ipc_ns = ipc_namespace_alloc();
    800022b0:	d8bff0ef          	jal	8000203a <ipc_namespace_alloc>
    800022b4:	892a                	mv	s2,a0
    800022b6:	1aa4b023          	sd	a0,416(s1)
  if(p->ipc_ns == 0){
    800022ba:	c549                	beqz	a0,80002344 <allocproc+0x104>
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800022bc:	a25fe0ef          	jal	80000ce0 <kalloc>
    800022c0:	892a                	mv	s2,a0
    800022c2:	eca8                	sd	a0,88(s1)
    800022c4:	c941                	beqz	a0,80002354 <allocproc+0x114>
  p->pagetable = proc_pagetable(p);
    800022c6:	8526                	mv	a0,s1
    800022c8:	e1fff0ef          	jal	800020e6 <proc_pagetable>
    800022cc:	892a                	mv	s2,a0
    800022ce:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800022d0:	c951                	beqz	a0,80002364 <allocproc+0x124>
  memset(&p->context, 0, sizeof(p->context));
    800022d2:	07000613          	li	a2,112
    800022d6:	4581                	li	a1,0
    800022d8:	06048513          	addi	a0,s1,96
    800022dc:	bd3fe0ef          	jal	80000eae <memset>
  p->context.ra = (uint64)forkret;
    800022e0:	00001797          	auipc	a5,0x1
    800022e4:	cd278793          	addi	a5,a5,-814 # 80002fb2 <forkret>
    800022e8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800022ea:	60bc                	ld	a5,64(s1)
    800022ec:	6705                	lui	a4,0x1
    800022ee:	97ba                	add	a5,a5,a4
    800022f0:	f4bc                	sd	a5,104(s1)
  p->vruntime = min_vruntime;
    800022f2:	00006797          	auipc	a5,0x6
    800022f6:	6be7b783          	ld	a5,1726(a5) # 800089b0 <min_vruntime>
    800022fa:	16f4b823          	sd	a5,368(s1)
  p->weight = 1024;  // Default weight (nice value 0)
    800022fe:	40000793          	li	a5,1024
    80002302:	16f4a423          	sw	a5,360(s1)
}
    80002306:	8526                	mv	a0,s1
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6902                	ld	s2,0(sp)
    80002310:	6105                	addi	sp,sp,32
    80002312:	8082                	ret
    freeproc(p);
    80002314:	8526                	mv	a0,s1
    80002316:	e9bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	b57fe0ef          	jal	80000e72 <release>
    return 0;
    80002320:	84ca                	mv	s1,s2
    80002322:	b7d5                	j	80002306 <allocproc+0xc6>
    freeproc(p);
    80002324:	8526                	mv	a0,s1
    80002326:	e8bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	b47fe0ef          	jal	80000e72 <release>
    return 0;
    80002330:	84ca                	mv	s1,s2
    80002332:	bfd1                	j	80002306 <allocproc+0xc6>
    freeproc(p);
    80002334:	8526                	mv	a0,s1
    80002336:	e7bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	b37fe0ef          	jal	80000e72 <release>
    return 0;
    80002340:	84ca                	mv	s1,s2
    80002342:	b7d1                	j	80002306 <allocproc+0xc6>
    freeproc(p);
    80002344:	8526                	mv	a0,s1
    80002346:	e6bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	b27fe0ef          	jal	80000e72 <release>
    return 0;
    80002350:	84ca                	mv	s1,s2
    80002352:	bf55                	j	80002306 <allocproc+0xc6>
    freeproc(p);
    80002354:	8526                	mv	a0,s1
    80002356:	e5bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	b17fe0ef          	jal	80000e72 <release>
    return 0;
    80002360:	84ca                	mv	s1,s2
    80002362:	b755                	j	80002306 <allocproc+0xc6>
    freeproc(p);
    80002364:	8526                	mv	a0,s1
    80002366:	e4bff0ef          	jal	800021b0 <freeproc>
    release(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	b07fe0ef          	jal	80000e72 <release>
    return 0;
    80002370:	84ca                	mv	s1,s2
    80002372:	bf51                	j	80002306 <allocproc+0xc6>

0000000080002374 <userinit>:
{
    80002374:	1101                	addi	sp,sp,-32
    80002376:	ec06                	sd	ra,24(sp)
    80002378:	e822                	sd	s0,16(sp)
    8000237a:	e426                	sd	s1,8(sp)
    8000237c:	e04a                	sd	s2,0(sp)
    8000237e:	1000                	addi	s0,sp,32
  p = allocproc();
    80002380:	ec1ff0ef          	jal	80002240 <allocproc>
    80002384:	84aa                	mv	s1,a0
  initproc = p;
    80002386:	00006797          	auipc	a5,0x6
    8000238a:	62a7b923          	sd	a0,1586(a5) # 800089b8 <initproc>
  p->cwd = namei("/");
    8000238e:	00006517          	auipc	a0,0x6
    80002392:	e5250513          	addi	a0,a0,-430 # 800081e0 <etext+0x1e0>
    80002396:	73c020ef          	jal	80004ad2 <namei>
    8000239a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000239e:	478d                	li	a5,3
    800023a0:	cc9c                	sw	a5,24(s1)
  acquire(&runq_lock);
    800023a2:	0002e917          	auipc	s2,0x2e
    800023a6:	77e90913          	addi	s2,s2,1918 # 80030b20 <runq_lock>
    800023aa:	854a                	mv	a0,s2
    800023ac:	a2ffe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    800023b0:	85a6                	mv	a1,s1
    800023b2:	0002e517          	auipc	a0,0x2e
    800023b6:	78650513          	addi	a0,a0,1926 # 80030b38 <run_queue>
    800023ba:	6b8040ef          	jal	80006a72 <minheap_insert>
  release(&runq_lock);
    800023be:	854a                	mv	a0,s2
    800023c0:	ab3fe0ef          	jal	80000e72 <release>
  release(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	aadfe0ef          	jal	80000e72 <release>
}
    800023ca:	60e2                	ld	ra,24(sp)
    800023cc:	6442                	ld	s0,16(sp)
    800023ce:	64a2                	ld	s1,8(sp)
    800023d0:	6902                	ld	s2,0(sp)
    800023d2:	6105                	addi	sp,sp,32
    800023d4:	8082                	ret

00000000800023d6 <growproc>:
{
    800023d6:	1101                	addi	sp,sp,-32
    800023d8:	ec06                	sd	ra,24(sp)
    800023da:	e822                	sd	s0,16(sp)
    800023dc:	e426                	sd	s1,8(sp)
    800023de:	e04a                	sd	s2,0(sp)
    800023e0:	1000                	addi	s0,sp,32
    800023e2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800023e4:	983ff0ef          	jal	80001d66 <myproc>
    800023e8:	892a                	mv	s2,a0
  sz = p->sz;
    800023ea:	652c                	ld	a1,72(a0)
  if(n > 0){
    800023ec:	02905963          	blez	s1,8000241e <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    800023f0:	00b48633          	add	a2,s1,a1
    800023f4:	020007b7          	lui	a5,0x2000
    800023f8:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    800023fa:	07b6                	slli	a5,a5,0xd
    800023fc:	02c7ea63          	bltu	a5,a2,80002430 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002400:	4691                	li	a3,4
    80002402:	6928                	ld	a0,80(a0)
    80002404:	890ff0ef          	jal	80001494 <uvmalloc>
    80002408:	85aa                	mv	a1,a0
    8000240a:	c50d                	beqz	a0,80002434 <growproc+0x5e>
  p->sz = sz;
    8000240c:	04b93423          	sd	a1,72(s2)
  return 0;
    80002410:	4501                	li	a0,0
}
    80002412:	60e2                	ld	ra,24(sp)
    80002414:	6442                	ld	s0,16(sp)
    80002416:	64a2                	ld	s1,8(sp)
    80002418:	6902                	ld	s2,0(sp)
    8000241a:	6105                	addi	sp,sp,32
    8000241c:	8082                	ret
  } else if(n < 0){
    8000241e:	fe04d7e3          	bgez	s1,8000240c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002422:	00b48633          	add	a2,s1,a1
    80002426:	6928                	ld	a0,80(a0)
    80002428:	828ff0ef          	jal	80001450 <uvmdealloc>
    8000242c:	85aa                	mv	a1,a0
    8000242e:	bff9                	j	8000240c <growproc+0x36>
      return -1;
    80002430:	557d                	li	a0,-1
    80002432:	b7c5                	j	80002412 <growproc+0x3c>
      return -1;
    80002434:	557d                	li	a0,-1
    80002436:	bff1                	j	80002412 <growproc+0x3c>

0000000080002438 <kfork>:
{
    80002438:	7139                	addi	sp,sp,-64
    8000243a:	fc06                	sd	ra,56(sp)
    8000243c:	f822                	sd	s0,48(sp)
    8000243e:	f04a                	sd	s2,32(sp)
    80002440:	e456                	sd	s5,8(sp)
    80002442:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002444:	923ff0ef          	jal	80001d66 <myproc>
    80002448:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000244a:	df7ff0ef          	jal	80002240 <allocproc>
    8000244e:	16050463          	beqz	a0,800025b6 <kfork+0x17e>
    80002452:	ec4e                	sd	s3,24(sp)
    80002454:	89aa                	mv	s3,a0
  pid_namespace_put(np->pid_ns);
    80002456:	18853503          	ld	a0,392(a0)
    8000245a:	a23ff0ef          	jal	80001e7c <pid_namespace_put>
  np->pid_ns = p->pid_ns;
    8000245e:	188ab503          	ld	a0,392(s5)
    80002462:	18a9b423          	sd	a0,392(s3)
  pid_namespace_get(np->pid_ns);
    80002466:	9e3ff0ef          	jal	80001e48 <pid_namespace_get>
  mount_namespace_put(np->mnt_ns);
    8000246a:	1909b503          	ld	a0,400(s3)
    8000246e:	ac5ff0ef          	jal	80001f32 <mount_namespace_put>
  np->mnt_ns = p->mnt_ns;
    80002472:	190ab503          	ld	a0,400(s5)
    80002476:	18a9b823          	sd	a0,400(s3)
  mount_namespace_get(np->mnt_ns);
    8000247a:	a85ff0ef          	jal	80001efe <mount_namespace_get>
  uts_namespace_put(np->uts_ns);
    8000247e:	1989b503          	ld	a0,408(s3)
    80002482:	b71ff0ef          	jal	80001ff2 <uts_namespace_put>
  np->uts_ns = p->uts_ns;
    80002486:	198ab503          	ld	a0,408(s5)
    8000248a:	18a9bc23          	sd	a0,408(s3)
  uts_namespace_get(np->uts_ns);
    8000248e:	b31ff0ef          	jal	80001fbe <uts_namespace_get>
  ipc_namespace_put(np->ipc_ns);
    80002492:	1a09b503          	ld	a0,416(s3)
    80002496:	c09ff0ef          	jal	8000209e <ipc_namespace_put>
  np->ipc_ns = p->ipc_ns;
    8000249a:	1a0ab503          	ld	a0,416(s5)
    8000249e:	1aa9b023          	sd	a0,416(s3)
  ipc_namespace_get(np->ipc_ns);
    800024a2:	bc9ff0ef          	jal	8000206a <ipc_namespace_get>
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800024a6:	048ab603          	ld	a2,72(s5)
    800024aa:	0509b583          	ld	a1,80(s3)
    800024ae:	050ab503          	ld	a0,80(s5)
    800024b2:	906ff0ef          	jal	800015b8 <uvmcopy>
    800024b6:	04054a63          	bltz	a0,8000250a <kfork+0xd2>
    800024ba:	f426                	sd	s1,40(sp)
    800024bc:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800024be:	048ab783          	ld	a5,72(s5)
    800024c2:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800024c6:	058ab683          	ld	a3,88(s5)
    800024ca:	87b6                	mv	a5,a3
    800024cc:	0589b703          	ld	a4,88(s3)
    800024d0:	12068693          	addi	a3,a3,288
    800024d4:	0007b803          	ld	a6,0(a5)
    800024d8:	6788                	ld	a0,8(a5)
    800024da:	6b8c                	ld	a1,16(a5)
    800024dc:	6f90                	ld	a2,24(a5)
    800024de:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800024e2:	e708                	sd	a0,8(a4)
    800024e4:	eb0c                	sd	a1,16(a4)
    800024e6:	ef10                	sd	a2,24(a4)
    800024e8:	02078793          	addi	a5,a5,32
    800024ec:	02070713          	addi	a4,a4,32
    800024f0:	fed792e3          	bne	a5,a3,800024d4 <kfork+0x9c>
  np->trapframe->a0 = 0;
    800024f4:	0589b783          	ld	a5,88(s3)
    800024f8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800024fc:	0d0a8493          	addi	s1,s5,208
    80002500:	0d098913          	addi	s2,s3,208
    80002504:	150a8a13          	addi	s4,s5,336
    80002508:	a831                	j	80002524 <kfork+0xec>
    freeproc(np);
    8000250a:	854e                	mv	a0,s3
    8000250c:	ca5ff0ef          	jal	800021b0 <freeproc>
    release(&np->lock);
    80002510:	854e                	mv	a0,s3
    80002512:	961fe0ef          	jal	80000e72 <release>
    return -1;
    80002516:	597d                	li	s2,-1
    80002518:	69e2                	ld	s3,24(sp)
    8000251a:	a079                	j	800025a8 <kfork+0x170>
  for(i = 0; i < NOFILE; i++)
    8000251c:	04a1                	addi	s1,s1,8
    8000251e:	0921                	addi	s2,s2,8
    80002520:	01448963          	beq	s1,s4,80002532 <kfork+0xfa>
    if(p->ofile[i])
    80002524:	6088                	ld	a0,0(s1)
    80002526:	d97d                	beqz	a0,8000251c <kfork+0xe4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002528:	345020ef          	jal	8000506c <filedup>
    8000252c:	00a93023          	sd	a0,0(s2)
    80002530:	b7f5                	j	8000251c <kfork+0xe4>
  np->cwd = idup(p->cwd);
    80002532:	150ab503          	ld	a0,336(s5)
    80002536:	551010ef          	jal	80004286 <idup>
    8000253a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000253e:	4641                	li	a2,16
    80002540:	158a8593          	addi	a1,s5,344
    80002544:	15898513          	addi	a0,s3,344
    80002548:	aa5fe0ef          	jal	80000fec <safestrcpy>
  pid = np->pid;
    8000254c:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002550:	854e                	mv	a0,s3
    80002552:	921fe0ef          	jal	80000e72 <release>
  acquire(&wait_lock);
    80002556:	0002e497          	auipc	s1,0x2e
    8000255a:	5b248493          	addi	s1,s1,1458 # 80030b08 <wait_lock>
    8000255e:	8526                	mv	a0,s1
    80002560:	87bfe0ef          	jal	80000dda <acquire>
  np->parent = p;
    80002564:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002568:	8526                	mv	a0,s1
    8000256a:	909fe0ef          	jal	80000e72 <release>
  acquire(&np->lock);
    8000256e:	854e                	mv	a0,s3
    80002570:	86bfe0ef          	jal	80000dda <acquire>
  np->state = RUNNABLE;
    80002574:	478d                	li	a5,3
    80002576:	00f9ac23          	sw	a5,24(s3)
  acquire(&runq_lock);
    8000257a:	0002e497          	auipc	s1,0x2e
    8000257e:	5a648493          	addi	s1,s1,1446 # 80030b20 <runq_lock>
    80002582:	8526                	mv	a0,s1
    80002584:	857fe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, np);
    80002588:	85ce                	mv	a1,s3
    8000258a:	0002e517          	auipc	a0,0x2e
    8000258e:	5ae50513          	addi	a0,a0,1454 # 80030b38 <run_queue>
    80002592:	4e0040ef          	jal	80006a72 <minheap_insert>
  release(&runq_lock);
    80002596:	8526                	mv	a0,s1
    80002598:	8dbfe0ef          	jal	80000e72 <release>
  release(&np->lock);
    8000259c:	854e                	mv	a0,s3
    8000259e:	8d5fe0ef          	jal	80000e72 <release>
  return pid;
    800025a2:	74a2                	ld	s1,40(sp)
    800025a4:	69e2                	ld	s3,24(sp)
    800025a6:	6a42                	ld	s4,16(sp)
}
    800025a8:	854a                	mv	a0,s2
    800025aa:	70e2                	ld	ra,56(sp)
    800025ac:	7442                	ld	s0,48(sp)
    800025ae:	7902                	ld	s2,32(sp)
    800025b0:	6aa2                	ld	s5,8(sp)
    800025b2:	6121                	addi	sp,sp,64
    800025b4:	8082                	ret
    return -1;
    800025b6:	597d                	li	s2,-1
    800025b8:	bfc5                	j	800025a8 <kfork+0x170>

00000000800025ba <kcowfork>:
{
    800025ba:	7139                	addi	sp,sp,-64
    800025bc:	fc06                	sd	ra,56(sp)
    800025be:	f822                	sd	s0,48(sp)
    800025c0:	f04a                	sd	s2,32(sp)
    800025c2:	e456                	sd	s5,8(sp)
    800025c4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800025c6:	fa0ff0ef          	jal	80001d66 <myproc>
    800025ca:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800025cc:	c75ff0ef          	jal	80002240 <allocproc>
    800025d0:	16050463          	beqz	a0,80002738 <kcowfork+0x17e>
    800025d4:	ec4e                	sd	s3,24(sp)
    800025d6:	89aa                	mv	s3,a0
  pid_namespace_put(np->pid_ns);
    800025d8:	18853503          	ld	a0,392(a0)
    800025dc:	8a1ff0ef          	jal	80001e7c <pid_namespace_put>
  np->pid_ns = p->pid_ns;
    800025e0:	188ab503          	ld	a0,392(s5)
    800025e4:	18a9b423          	sd	a0,392(s3)
  pid_namespace_get(np->pid_ns);
    800025e8:	861ff0ef          	jal	80001e48 <pid_namespace_get>
  mount_namespace_put(np->mnt_ns);
    800025ec:	1909b503          	ld	a0,400(s3)
    800025f0:	943ff0ef          	jal	80001f32 <mount_namespace_put>
  np->mnt_ns = p->mnt_ns;
    800025f4:	190ab503          	ld	a0,400(s5)
    800025f8:	18a9b823          	sd	a0,400(s3)
  mount_namespace_get(np->mnt_ns);
    800025fc:	903ff0ef          	jal	80001efe <mount_namespace_get>
  uts_namespace_put(np->uts_ns);
    80002600:	1989b503          	ld	a0,408(s3)
    80002604:	9efff0ef          	jal	80001ff2 <uts_namespace_put>
  np->uts_ns = p->uts_ns;
    80002608:	198ab503          	ld	a0,408(s5)
    8000260c:	18a9bc23          	sd	a0,408(s3)
  uts_namespace_get(np->uts_ns);
    80002610:	9afff0ef          	jal	80001fbe <uts_namespace_get>
  ipc_namespace_put(np->ipc_ns);
    80002614:	1a09b503          	ld	a0,416(s3)
    80002618:	a87ff0ef          	jal	8000209e <ipc_namespace_put>
  np->ipc_ns = p->ipc_ns;
    8000261c:	1a0ab503          	ld	a0,416(s5)
    80002620:	1aa9b023          	sd	a0,416(s3)
  ipc_namespace_get(np->ipc_ns);
    80002624:	a47ff0ef          	jal	8000206a <ipc_namespace_get>
  if(uvmcopy_cow(p->pagetable, np->pagetable, p->sz) < 0){
    80002628:	048ab603          	ld	a2,72(s5)
    8000262c:	0509b583          	ld	a1,80(s3)
    80002630:	050ab503          	ld	a0,80(s5)
    80002634:	822ff0ef          	jal	80001656 <uvmcopy_cow>
    80002638:	04054a63          	bltz	a0,8000268c <kcowfork+0xd2>
    8000263c:	f426                	sd	s1,40(sp)
    8000263e:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80002640:	048ab783          	ld	a5,72(s5)
    80002644:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002648:	058ab683          	ld	a3,88(s5)
    8000264c:	87b6                	mv	a5,a3
    8000264e:	0589b703          	ld	a4,88(s3)
    80002652:	12068693          	addi	a3,a3,288
    80002656:	0007b803          	ld	a6,0(a5)
    8000265a:	6788                	ld	a0,8(a5)
    8000265c:	6b8c                	ld	a1,16(a5)
    8000265e:	6f90                	ld	a2,24(a5)
    80002660:	01073023          	sd	a6,0(a4)
    80002664:	e708                	sd	a0,8(a4)
    80002666:	eb0c                	sd	a1,16(a4)
    80002668:	ef10                	sd	a2,24(a4)
    8000266a:	02078793          	addi	a5,a5,32
    8000266e:	02070713          	addi	a4,a4,32
    80002672:	fed792e3          	bne	a5,a3,80002656 <kcowfork+0x9c>
  np->trapframe->a0 = 0;
    80002676:	0589b783          	ld	a5,88(s3)
    8000267a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000267e:	0d0a8493          	addi	s1,s5,208
    80002682:	0d098913          	addi	s2,s3,208
    80002686:	150a8a13          	addi	s4,s5,336
    8000268a:	a831                	j	800026a6 <kcowfork+0xec>
    freeproc(np);
    8000268c:	854e                	mv	a0,s3
    8000268e:	b23ff0ef          	jal	800021b0 <freeproc>
    release(&np->lock);
    80002692:	854e                	mv	a0,s3
    80002694:	fdefe0ef          	jal	80000e72 <release>
    return -1;
    80002698:	597d                	li	s2,-1
    8000269a:	69e2                	ld	s3,24(sp)
    8000269c:	a079                	j	8000272a <kcowfork+0x170>
  for(i = 0; i < NOFILE; i++)
    8000269e:	04a1                	addi	s1,s1,8
    800026a0:	0921                	addi	s2,s2,8
    800026a2:	01448963          	beq	s1,s4,800026b4 <kcowfork+0xfa>
    if(p->ofile[i])
    800026a6:	6088                	ld	a0,0(s1)
    800026a8:	d97d                	beqz	a0,8000269e <kcowfork+0xe4>
      np->ofile[i] = filedup(p->ofile[i]);
    800026aa:	1c3020ef          	jal	8000506c <filedup>
    800026ae:	00a93023          	sd	a0,0(s2)
    800026b2:	b7f5                	j	8000269e <kcowfork+0xe4>
  np->cwd = idup(p->cwd);
    800026b4:	150ab503          	ld	a0,336(s5)
    800026b8:	3cf010ef          	jal	80004286 <idup>
    800026bc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800026c0:	4641                	li	a2,16
    800026c2:	158a8593          	addi	a1,s5,344
    800026c6:	15898513          	addi	a0,s3,344
    800026ca:	923fe0ef          	jal	80000fec <safestrcpy>
  pid = np->pid;
    800026ce:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800026d2:	854e                	mv	a0,s3
    800026d4:	f9efe0ef          	jal	80000e72 <release>
  acquire(&wait_lock);
    800026d8:	0002e497          	auipc	s1,0x2e
    800026dc:	43048493          	addi	s1,s1,1072 # 80030b08 <wait_lock>
    800026e0:	8526                	mv	a0,s1
    800026e2:	ef8fe0ef          	jal	80000dda <acquire>
  np->parent = p;
    800026e6:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	f86fe0ef          	jal	80000e72 <release>
  acquire(&np->lock);
    800026f0:	854e                	mv	a0,s3
    800026f2:	ee8fe0ef          	jal	80000dda <acquire>
  np->state = RUNNABLE;
    800026f6:	478d                	li	a5,3
    800026f8:	00f9ac23          	sw	a5,24(s3)
  acquire(&runq_lock);
    800026fc:	0002e497          	auipc	s1,0x2e
    80002700:	42448493          	addi	s1,s1,1060 # 80030b20 <runq_lock>
    80002704:	8526                	mv	a0,s1
    80002706:	ed4fe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, np);
    8000270a:	85ce                	mv	a1,s3
    8000270c:	0002e517          	auipc	a0,0x2e
    80002710:	42c50513          	addi	a0,a0,1068 # 80030b38 <run_queue>
    80002714:	35e040ef          	jal	80006a72 <minheap_insert>
  release(&runq_lock);
    80002718:	8526                	mv	a0,s1
    8000271a:	f58fe0ef          	jal	80000e72 <release>
  release(&np->lock);
    8000271e:	854e                	mv	a0,s3
    80002720:	f52fe0ef          	jal	80000e72 <release>
  return pid;
    80002724:	74a2                	ld	s1,40(sp)
    80002726:	69e2                	ld	s3,24(sp)
    80002728:	6a42                	ld	s4,16(sp)
}
    8000272a:	854a                	mv	a0,s2
    8000272c:	70e2                	ld	ra,56(sp)
    8000272e:	7442                	ld	s0,48(sp)
    80002730:	7902                	ld	s2,32(sp)
    80002732:	6aa2                	ld	s5,8(sp)
    80002734:	6121                	addi	sp,sp,64
    80002736:	8082                	ret
    return -1;
    80002738:	597d                	li	s2,-1
    8000273a:	bfc5                	j	8000272a <kcowfork+0x170>

000000008000273c <scheduler>:
{
    8000273c:	715d                	addi	sp,sp,-80
    8000273e:	e486                	sd	ra,72(sp)
    80002740:	e0a2                	sd	s0,64(sp)
    80002742:	fc26                	sd	s1,56(sp)
    80002744:	f84a                	sd	s2,48(sp)
    80002746:	f44e                	sd	s3,40(sp)
    80002748:	f052                	sd	s4,32(sp)
    8000274a:	ec56                	sd	s5,24(sp)
    8000274c:	e85a                	sd	s6,16(sp)
    8000274e:	e45e                	sd	s7,8(sp)
    80002750:	0880                	addi	s0,sp,80
    80002752:	8792                	mv	a5,tp
  int id = r_tp();
    80002754:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002756:	00779b13          	slli	s6,a5,0x7
    8000275a:	0002e717          	auipc	a4,0x2e
    8000275e:	39670713          	addi	a4,a4,918 # 80030af0 <pid_lock>
    80002762:	975a                	add	a4,a4,s6
    80002764:	24073823          	sd	zero,592(a4)
        swtch(&c->context, &p->context);
    80002768:	0002e717          	auipc	a4,0x2e
    8000276c:	5e070713          	addi	a4,a4,1504 # 80030d48 <cpus+0x8>
    80002770:	9b3a                	add	s6,s6,a4
    acquire(&runq_lock);
    80002772:	0002e917          	auipc	s2,0x2e
    80002776:	3ae90913          	addi	s2,s2,942 # 80030b20 <runq_lock>
    p = minheap_extract_min(&run_queue);
    8000277a:	0002e997          	auipc	s3,0x2e
    8000277e:	3be98993          	addi	s3,s3,958 # 80030b38 <run_queue>
      if(p->state == RUNNABLE) {
    80002782:	4a0d                	li	s4,3
        p->state = RUNNING;
    80002784:	4b91                	li	s7,4
        c->proc = p;
    80002786:	079e                	slli	a5,a5,0x7
    80002788:	0002ea97          	auipc	s5,0x2e
    8000278c:	368a8a93          	addi	s5,s5,872 # 80030af0 <pid_lock>
    80002790:	9abe                	add	s5,s5,a5
    80002792:	a021                	j	8000279a <scheduler+0x5e>
      release(&p->lock);
    80002794:	8526                	mv	a0,s1
    80002796:	edcfe0ef          	jal	80000e72 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000279e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027a2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027a6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027aa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ac:	10079073          	csrw	sstatus,a5
    acquire(&runq_lock);
    800027b0:	854a                	mv	a0,s2
    800027b2:	e28fe0ef          	jal	80000dda <acquire>
    p = minheap_extract_min(&run_queue);
    800027b6:	854e                	mv	a0,s3
    800027b8:	32c040ef          	jal	80006ae4 <minheap_extract_min>
    800027bc:	84aa                	mv	s1,a0
    release(&runq_lock);
    800027be:	854a                	mv	a0,s2
    800027c0:	eb2fe0ef          	jal	80000e72 <release>
    if(p != 0) {
    800027c4:	c09d                	beqz	s1,800027ea <scheduler+0xae>
      acquire(&p->lock);
    800027c6:	8526                	mv	a0,s1
    800027c8:	e12fe0ef          	jal	80000dda <acquire>
      if(p->state == RUNNABLE) {
    800027cc:	4c9c                	lw	a5,24(s1)
    800027ce:	fd4793e3          	bne	a5,s4,80002794 <scheduler+0x58>
        p->state = RUNNING;
    800027d2:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    800027d6:	249ab823          	sd	s1,592(s5)
        swtch(&c->context, &p->context);
    800027da:	06048593          	addi	a1,s1,96
    800027de:	855a                	mv	a0,s6
    800027e0:	083000ef          	jal	80003062 <swtch>
        c->proc = 0;
    800027e4:	240ab823          	sd	zero,592(s5)
    800027e8:	b775                	j	80002794 <scheduler+0x58>
      asm volatile("wfi");
    800027ea:	10500073          	wfi
    800027ee:	b775                	j	8000279a <scheduler+0x5e>

00000000800027f0 <sched>:
{
    800027f0:	7179                	addi	sp,sp,-48
    800027f2:	f406                	sd	ra,40(sp)
    800027f4:	f022                	sd	s0,32(sp)
    800027f6:	ec26                	sd	s1,24(sp)
    800027f8:	e84a                	sd	s2,16(sp)
    800027fa:	e44e                	sd	s3,8(sp)
    800027fc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800027fe:	d68ff0ef          	jal	80001d66 <myproc>
    80002802:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002804:	d6cfe0ef          	jal	80000d70 <holding>
    80002808:	c92d                	beqz	a0,8000287a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000280a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000280c:	2781                	sext.w	a5,a5
    8000280e:	079e                	slli	a5,a5,0x7
    80002810:	0002e717          	auipc	a4,0x2e
    80002814:	2e070713          	addi	a4,a4,736 # 80030af0 <pid_lock>
    80002818:	97ba                	add	a5,a5,a4
    8000281a:	2c87a703          	lw	a4,712(a5)
    8000281e:	4785                	li	a5,1
    80002820:	06f71363          	bne	a4,a5,80002886 <sched+0x96>
  if(p->state == RUNNING)
    80002824:	4c98                	lw	a4,24(s1)
    80002826:	4791                	li	a5,4
    80002828:	06f70563          	beq	a4,a5,80002892 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000282c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002830:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002832:	e7b5                	bnez	a5,8000289e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002834:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002836:	0002e917          	auipc	s2,0x2e
    8000283a:	2ba90913          	addi	s2,s2,698 # 80030af0 <pid_lock>
    8000283e:	2781                	sext.w	a5,a5
    80002840:	079e                	slli	a5,a5,0x7
    80002842:	97ca                	add	a5,a5,s2
    80002844:	2cc7a983          	lw	s3,716(a5)
    80002848:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000284a:	2781                	sext.w	a5,a5
    8000284c:	079e                	slli	a5,a5,0x7
    8000284e:	0002e597          	auipc	a1,0x2e
    80002852:	4fa58593          	addi	a1,a1,1274 # 80030d48 <cpus+0x8>
    80002856:	95be                	add	a1,a1,a5
    80002858:	06048513          	addi	a0,s1,96
    8000285c:	007000ef          	jal	80003062 <swtch>
    80002860:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002862:	2781                	sext.w	a5,a5
    80002864:	079e                	slli	a5,a5,0x7
    80002866:	993e                	add	s2,s2,a5
    80002868:	2d392623          	sw	s3,716(s2)
}
    8000286c:	70a2                	ld	ra,40(sp)
    8000286e:	7402                	ld	s0,32(sp)
    80002870:	64e2                	ld	s1,24(sp)
    80002872:	6942                	ld	s2,16(sp)
    80002874:	69a2                	ld	s3,8(sp)
    80002876:	6145                	addi	sp,sp,48
    80002878:	8082                	ret
    panic("sched p->lock");
    8000287a:	00006517          	auipc	a0,0x6
    8000287e:	96e50513          	addi	a0,a0,-1682 # 800081e8 <etext+0x1e8>
    80002882:	f5ffd0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002886:	00006517          	auipc	a0,0x6
    8000288a:	97250513          	addi	a0,a0,-1678 # 800081f8 <etext+0x1f8>
    8000288e:	f53fd0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002892:	00006517          	auipc	a0,0x6
    80002896:	97650513          	addi	a0,a0,-1674 # 80008208 <etext+0x208>
    8000289a:	f47fd0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    8000289e:	00006517          	auipc	a0,0x6
    800028a2:	97a50513          	addi	a0,a0,-1670 # 80008218 <etext+0x218>
    800028a6:	f3bfd0ef          	jal	800007e0 <panic>

00000000800028aa <yield>:
{
    800028aa:	1101                	addi	sp,sp,-32
    800028ac:	ec06                	sd	ra,24(sp)
    800028ae:	e822                	sd	s0,16(sp)
    800028b0:	e426                	sd	s1,8(sp)
    800028b2:	e04a                	sd	s2,0(sp)
    800028b4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800028b6:	cb0ff0ef          	jal	80001d66 <myproc>
    800028ba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800028bc:	d1efe0ef          	jal	80000dda <acquire>
  p->vruntime += (1024 / p->weight);
    800028c0:	1684a783          	lw	a5,360(s1)
    800028c4:	40000713          	li	a4,1024
    800028c8:	02f7473b          	divw	a4,a4,a5
    800028cc:	1704b783          	ld	a5,368(s1)
    800028d0:	97ba                	add	a5,a5,a4
    800028d2:	16f4b823          	sd	a5,368(s1)
  acquire(&runq_lock);
    800028d6:	0002e517          	auipc	a0,0x2e
    800028da:	24a50513          	addi	a0,a0,586 # 80030b20 <runq_lock>
    800028de:	cfcfe0ef          	jal	80000dda <acquire>
  if(p->vruntime > min_vruntime)
    800028e2:	1704b783          	ld	a5,368(s1)
    800028e6:	00006717          	auipc	a4,0x6
    800028ea:	0ca73703          	ld	a4,202(a4) # 800089b0 <min_vruntime>
    800028ee:	00f77663          	bgeu	a4,a5,800028fa <yield+0x50>
    min_vruntime = p->vruntime;
    800028f2:	00006717          	auipc	a4,0x6
    800028f6:	0af73f23          	sd	a5,190(a4) # 800089b0 <min_vruntime>
  release(&runq_lock);
    800028fa:	0002e917          	auipc	s2,0x2e
    800028fe:	22690913          	addi	s2,s2,550 # 80030b20 <runq_lock>
    80002902:	854a                	mv	a0,s2
    80002904:	d6efe0ef          	jal	80000e72 <release>
  p->state = RUNNABLE;
    80002908:	478d                	li	a5,3
    8000290a:	cc9c                	sw	a5,24(s1)
  acquire(&runq_lock);
    8000290c:	854a                	mv	a0,s2
    8000290e:	cccfe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    80002912:	85a6                	mv	a1,s1
    80002914:	0002e517          	auipc	a0,0x2e
    80002918:	22450513          	addi	a0,a0,548 # 80030b38 <run_queue>
    8000291c:	156040ef          	jal	80006a72 <minheap_insert>
  release(&runq_lock);
    80002920:	854a                	mv	a0,s2
    80002922:	d50fe0ef          	jal	80000e72 <release>
  sched();
    80002926:	ecbff0ef          	jal	800027f0 <sched>
  release(&p->lock);
    8000292a:	8526                	mv	a0,s1
    8000292c:	d46fe0ef          	jal	80000e72 <release>
}
    80002930:	60e2                	ld	ra,24(sp)
    80002932:	6442                	ld	s0,16(sp)
    80002934:	64a2                	ld	s1,8(sp)
    80002936:	6902                	ld	s2,0(sp)
    80002938:	6105                	addi	sp,sp,32
    8000293a:	8082                	ret

000000008000293c <kproc_start>:
{
    8000293c:	1101                	addi	sp,sp,-32
    8000293e:	ec06                	sd	ra,24(sp)
    80002940:	e822                	sd	s0,16(sp)
    80002942:	e426                	sd	s1,8(sp)
    80002944:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002946:	c20ff0ef          	jal	80001d66 <myproc>
    8000294a:	84aa                	mv	s1,a0
  release(&p->lock);
    8000294c:	d26fe0ef          	jal	80000e72 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002950:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002954:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002958:	10079073          	csrw	sstatus,a5
  if(p->kentry)
    8000295c:	1804b783          	ld	a5,384(s1)
    80002960:	c391                	beqz	a5,80002964 <kproc_start+0x28>
    p->kentry();
    80002962:	9782                	jalr	a5
    yield();
    80002964:	f47ff0ef          	jal	800028aa <yield>
  for(;;)
    80002968:	bff5                	j	80002964 <kproc_start+0x28>

000000008000296a <sleep>:
{
    8000296a:	7179                	addi	sp,sp,-48
    8000296c:	f406                	sd	ra,40(sp)
    8000296e:	f022                	sd	s0,32(sp)
    80002970:	ec26                	sd	s1,24(sp)
    80002972:	e84a                	sd	s2,16(sp)
    80002974:	e44e                	sd	s3,8(sp)
    80002976:	1800                	addi	s0,sp,48
    80002978:	89aa                	mv	s3,a0
    8000297a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000297c:	beaff0ef          	jal	80001d66 <myproc>
    80002980:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    80002982:	c58fe0ef          	jal	80000dda <acquire>
  release(lk);
    80002986:	854a                	mv	a0,s2
    80002988:	ceafe0ef          	jal	80000e72 <release>
  p->chan = chan;
    8000298c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002990:	4789                	li	a5,2
    80002992:	cc9c                	sw	a5,24(s1)
  sched();
    80002994:	e5dff0ef          	jal	800027f0 <sched>
  p->chan = 0;
    80002998:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    8000299c:	8526                	mv	a0,s1
    8000299e:	cd4fe0ef          	jal	80000e72 <release>
  acquire(lk);
    800029a2:	854a                	mv	a0,s2
    800029a4:	c36fe0ef          	jal	80000dda <acquire>
}
    800029a8:	70a2                	ld	ra,40(sp)
    800029aa:	7402                	ld	s0,32(sp)
    800029ac:	64e2                	ld	s1,24(sp)
    800029ae:	6942                	ld	s2,16(sp)
    800029b0:	69a2                	ld	s3,8(sp)
    800029b2:	6145                	addi	sp,sp,48
    800029b4:	8082                	ret

00000000800029b6 <wakeup>:
{
    800029b6:	715d                	addi	sp,sp,-80
    800029b8:	e486                	sd	ra,72(sp)
    800029ba:	e0a2                	sd	s0,64(sp)
    800029bc:	fc26                	sd	s1,56(sp)
    800029be:	f84a                	sd	s2,48(sp)
    800029c0:	f44e                	sd	s3,40(sp)
    800029c2:	f052                	sd	s4,32(sp)
    800029c4:	ec56                	sd	s5,24(sp)
    800029c6:	e85a                	sd	s6,16(sp)
    800029c8:	e45e                	sd	s7,8(sp)
    800029ca:	e062                	sd	s8,0(sp)
    800029cc:	0880                	addi	s0,sp,80
    800029ce:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800029d0:	0002e497          	auipc	s1,0x2e
    800029d4:	77048493          	addi	s1,s1,1904 # 80031140 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    800029d8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800029da:	4c0d                	li	s8,3
        if(p->vruntime < min_vruntime)
    800029dc:	00006b97          	auipc	s7,0x6
    800029e0:	fd4b8b93          	addi	s7,s7,-44 # 800089b0 <min_vruntime>
        acquire(&runq_lock);
    800029e4:	0002ea97          	auipc	s5,0x2e
    800029e8:	13ca8a93          	addi	s5,s5,316 # 80030b20 <runq_lock>
        minheap_insert(&run_queue, p);
    800029ec:	0002eb17          	auipc	s6,0x2e
    800029f0:	14cb0b13          	addi	s6,s6,332 # 80030b38 <run_queue>
  for(p = proc; p < &proc[NPROC]; p++) {
    800029f4:	00035917          	auipc	s2,0x35
    800029f8:	14c90913          	addi	s2,s2,332 # 80037b40 <tickslock>
    800029fc:	a015                	j	80002a20 <wakeup+0x6a>
        acquire(&runq_lock);
    800029fe:	8556                	mv	a0,s5
    80002a00:	bdafe0ef          	jal	80000dda <acquire>
        minheap_insert(&run_queue, p);
    80002a04:	85a6                	mv	a1,s1
    80002a06:	855a                	mv	a0,s6
    80002a08:	06a040ef          	jal	80006a72 <minheap_insert>
        release(&runq_lock);
    80002a0c:	8556                	mv	a0,s5
    80002a0e:	c64fe0ef          	jal	80000e72 <release>
      release(&p->lock);
    80002a12:	8526                	mv	a0,s1
    80002a14:	c5efe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a18:	1a848493          	addi	s1,s1,424
    80002a1c:	03248a63          	beq	s1,s2,80002a50 <wakeup+0x9a>
    if(p != myproc()){
    80002a20:	b46ff0ef          	jal	80001d66 <myproc>
    80002a24:	fea48ae3          	beq	s1,a0,80002a18 <wakeup+0x62>
      acquire(&p->lock);
    80002a28:	8526                	mv	a0,s1
    80002a2a:	bb0fe0ef          	jal	80000dda <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002a2e:	4c9c                	lw	a5,24(s1)
    80002a30:	ff3791e3          	bne	a5,s3,80002a12 <wakeup+0x5c>
    80002a34:	709c                	ld	a5,32(s1)
    80002a36:	fd479ee3          	bne	a5,s4,80002a12 <wakeup+0x5c>
        p->state = RUNNABLE;
    80002a3a:	0184ac23          	sw	s8,24(s1)
        if(p->vruntime < min_vruntime)
    80002a3e:	000bb783          	ld	a5,0(s7)
    80002a42:	1704b703          	ld	a4,368(s1)
    80002a46:	faf77ce3          	bgeu	a4,a5,800029fe <wakeup+0x48>
          p->vruntime = min_vruntime;
    80002a4a:	16f4b823          	sd	a5,368(s1)
    80002a4e:	bf45                	j	800029fe <wakeup+0x48>
}
    80002a50:	60a6                	ld	ra,72(sp)
    80002a52:	6406                	ld	s0,64(sp)
    80002a54:	74e2                	ld	s1,56(sp)
    80002a56:	7942                	ld	s2,48(sp)
    80002a58:	79a2                	ld	s3,40(sp)
    80002a5a:	7a02                	ld	s4,32(sp)
    80002a5c:	6ae2                	ld	s5,24(sp)
    80002a5e:	6b42                	ld	s6,16(sp)
    80002a60:	6ba2                	ld	s7,8(sp)
    80002a62:	6c02                	ld	s8,0(sp)
    80002a64:	6161                	addi	sp,sp,80
    80002a66:	8082                	ret

0000000080002a68 <reparent>:
{
    80002a68:	7179                	addi	sp,sp,-48
    80002a6a:	f406                	sd	ra,40(sp)
    80002a6c:	f022                	sd	s0,32(sp)
    80002a6e:	ec26                	sd	s1,24(sp)
    80002a70:	e84a                	sd	s2,16(sp)
    80002a72:	e44e                	sd	s3,8(sp)
    80002a74:	e052                	sd	s4,0(sp)
    80002a76:	1800                	addi	s0,sp,48
    80002a78:	892a                	mv	s2,a0
  if(p->parent != 0 && p->parent != initproc){
    80002a7a:	03853a03          	ld	s4,56(a0)
    80002a7e:	000a0863          	beqz	s4,80002a8e <reparent+0x26>
    80002a82:	00006797          	auipc	a5,0x6
    80002a86:	f367b783          	ld	a5,-202(a5) # 800089b8 <initproc>
    80002a8a:	00fa1663          	bne	s4,a5,80002a96 <reparent+0x2e>
    new_parent = initproc;
    80002a8e:	00006a17          	auipc	s4,0x6
    80002a92:	f2aa3a03          	ld	s4,-214(s4) # 800089b8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a96:	0002e497          	auipc	s1,0x2e
    80002a9a:	6aa48493          	addi	s1,s1,1706 # 80031140 <proc>
    80002a9e:	00035997          	auipc	s3,0x35
    80002aa2:	0a298993          	addi	s3,s3,162 # 80037b40 <tickslock>
    80002aa6:	a029                	j	80002ab0 <reparent+0x48>
    80002aa8:	1a848493          	addi	s1,s1,424
    80002aac:	01348b63          	beq	s1,s3,80002ac2 <reparent+0x5a>
    if(pp->parent == p){
    80002ab0:	7c9c                	ld	a5,56(s1)
    80002ab2:	ff279be3          	bne	a5,s2,80002aa8 <reparent+0x40>
      pp->parent = new_parent;
    80002ab6:	0344bc23          	sd	s4,56(s1)
      wakeup(new_parent);
    80002aba:	8552                	mv	a0,s4
    80002abc:	efbff0ef          	jal	800029b6 <wakeup>
    80002ac0:	b7e5                	j	80002aa8 <reparent+0x40>
}
    80002ac2:	70a2                	ld	ra,40(sp)
    80002ac4:	7402                	ld	s0,32(sp)
    80002ac6:	64e2                	ld	s1,24(sp)
    80002ac8:	6942                	ld	s2,16(sp)
    80002aca:	69a2                	ld	s3,8(sp)
    80002acc:	6a02                	ld	s4,0(sp)
    80002ace:	6145                	addi	sp,sp,48
    80002ad0:	8082                	ret

0000000080002ad2 <kexit>:
{
    80002ad2:	7179                	addi	sp,sp,-48
    80002ad4:	f406                	sd	ra,40(sp)
    80002ad6:	f022                	sd	s0,32(sp)
    80002ad8:	ec26                	sd	s1,24(sp)
    80002ada:	e84a                	sd	s2,16(sp)
    80002adc:	e44e                	sd	s3,8(sp)
    80002ade:	e052                	sd	s4,0(sp)
    80002ae0:	1800                	addi	s0,sp,48
    80002ae2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002ae4:	a82ff0ef          	jal	80001d66 <myproc>
    80002ae8:	89aa                	mv	s3,a0
  if(p == initproc)
    80002aea:	00006797          	auipc	a5,0x6
    80002aee:	ece7b783          	ld	a5,-306(a5) # 800089b8 <initproc>
    80002af2:	0d050493          	addi	s1,a0,208
    80002af6:	15050913          	addi	s2,a0,336
    80002afa:	00a79f63          	bne	a5,a0,80002b18 <kexit+0x46>
    panic("init exiting");
    80002afe:	00005517          	auipc	a0,0x5
    80002b02:	73250513          	addi	a0,a0,1842 # 80008230 <etext+0x230>
    80002b06:	cdbfd0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002b0a:	5a8020ef          	jal	800050b2 <fileclose>
      p->ofile[fd] = 0;
    80002b0e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002b12:	04a1                	addi	s1,s1,8
    80002b14:	01248563          	beq	s1,s2,80002b1e <kexit+0x4c>
    if(p->ofile[fd]){
    80002b18:	6088                	ld	a0,0(s1)
    80002b1a:	f965                	bnez	a0,80002b0a <kexit+0x38>
    80002b1c:	bfdd                	j	80002b12 <kexit+0x40>
  begin_op();
    80002b1e:	188020ef          	jal	80004ca6 <begin_op>
  iput(p->cwd);
    80002b22:	1509b503          	ld	a0,336(s3)
    80002b26:	119010ef          	jal	8000443e <iput>
  end_op();
    80002b2a:	1e6020ef          	jal	80004d10 <end_op>
  p->cwd = 0;
    80002b2e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002b32:	0002e497          	auipc	s1,0x2e
    80002b36:	fd648493          	addi	s1,s1,-42 # 80030b08 <wait_lock>
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	a9efe0ef          	jal	80000dda <acquire>
  reparent(p);
    80002b40:	854e                	mv	a0,s3
    80002b42:	f27ff0ef          	jal	80002a68 <reparent>
  wakeup(p->parent);
    80002b46:	0389b503          	ld	a0,56(s3)
    80002b4a:	e6dff0ef          	jal	800029b6 <wakeup>
  acquire(&p->lock);
    80002b4e:	854e                	mv	a0,s3
    80002b50:	a8afe0ef          	jal	80000dda <acquire>
  p->xstate = status;
    80002b54:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002b58:	4795                	li	a5,5
    80002b5a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002b5e:	8526                	mv	a0,s1
    80002b60:	b12fe0ef          	jal	80000e72 <release>
  sched();
    80002b64:	c8dff0ef          	jal	800027f0 <sched>
  panic("zombie exit");
    80002b68:	00005517          	auipc	a0,0x5
    80002b6c:	6d850513          	addi	a0,a0,1752 # 80008240 <etext+0x240>
    80002b70:	c71fd0ef          	jal	800007e0 <panic>

0000000080002b74 <kkill>:
{
    80002b74:	7179                	addi	sp,sp,-48
    80002b76:	f406                	sd	ra,40(sp)
    80002b78:	f022                	sd	s0,32(sp)
    80002b7a:	ec26                	sd	s1,24(sp)
    80002b7c:	e84a                	sd	s2,16(sp)
    80002b7e:	e44e                	sd	s3,8(sp)
    80002b80:	1800                	addi	s0,sp,48
    80002b82:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002b84:	0002e497          	auipc	s1,0x2e
    80002b88:	5bc48493          	addi	s1,s1,1468 # 80031140 <proc>
    80002b8c:	00035997          	auipc	s3,0x35
    80002b90:	fb498993          	addi	s3,s3,-76 # 80037b40 <tickslock>
    acquire(&p->lock);
    80002b94:	8526                	mv	a0,s1
    80002b96:	a44fe0ef          	jal	80000dda <acquire>
    if(p->pid == pid){
    80002b9a:	589c                	lw	a5,48(s1)
    80002b9c:	01278b63          	beq	a5,s2,80002bb2 <kkill+0x3e>
    release(&p->lock);
    80002ba0:	8526                	mv	a0,s1
    80002ba2:	ad0fe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ba6:	1a848493          	addi	s1,s1,424
    80002baa:	ff3495e3          	bne	s1,s3,80002b94 <kkill+0x20>
  return -1;
    80002bae:	557d                	li	a0,-1
    80002bb0:	a819                	j	80002bc6 <kkill+0x52>
      p->killed = 1;
    80002bb2:	4785                	li	a5,1
    80002bb4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002bb6:	4c98                	lw	a4,24(s1)
    80002bb8:	4789                	li	a5,2
    80002bba:	00f70d63          	beq	a4,a5,80002bd4 <kkill+0x60>
      release(&p->lock);
    80002bbe:	8526                	mv	a0,s1
    80002bc0:	ab2fe0ef          	jal	80000e72 <release>
      return 0;
    80002bc4:	4501                	li	a0,0
}
    80002bc6:	70a2                	ld	ra,40(sp)
    80002bc8:	7402                	ld	s0,32(sp)
    80002bca:	64e2                	ld	s1,24(sp)
    80002bcc:	6942                	ld	s2,16(sp)
    80002bce:	69a2                	ld	s3,8(sp)
    80002bd0:	6145                	addi	sp,sp,48
    80002bd2:	8082                	ret
        p->state = RUNNABLE;
    80002bd4:	478d                	li	a5,3
    80002bd6:	cc9c                	sw	a5,24(s1)
        if(p->vruntime < min_vruntime)
    80002bd8:	00006797          	auipc	a5,0x6
    80002bdc:	dd87b783          	ld	a5,-552(a5) # 800089b0 <min_vruntime>
    80002be0:	1704b703          	ld	a4,368(s1)
    80002be4:	00f77463          	bgeu	a4,a5,80002bec <kkill+0x78>
          p->vruntime = min_vruntime;
    80002be8:	16f4b823          	sd	a5,368(s1)
        acquire(&runq_lock);
    80002bec:	0002e917          	auipc	s2,0x2e
    80002bf0:	f3490913          	addi	s2,s2,-204 # 80030b20 <runq_lock>
    80002bf4:	854a                	mv	a0,s2
    80002bf6:	9e4fe0ef          	jal	80000dda <acquire>
        minheap_insert(&run_queue, p);
    80002bfa:	85a6                	mv	a1,s1
    80002bfc:	0002e517          	auipc	a0,0x2e
    80002c00:	f3c50513          	addi	a0,a0,-196 # 80030b38 <run_queue>
    80002c04:	66f030ef          	jal	80006a72 <minheap_insert>
        release(&runq_lock);
    80002c08:	854a                	mv	a0,s2
    80002c0a:	a68fe0ef          	jal	80000e72 <release>
    80002c0e:	bf45                	j	80002bbe <kkill+0x4a>

0000000080002c10 <setkilled>:
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	e426                	sd	s1,8(sp)
    80002c18:	1000                	addi	s0,sp,32
    80002c1a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002c1c:	9befe0ef          	jal	80000dda <acquire>
  p->killed = 1;
    80002c20:	4785                	li	a5,1
    80002c22:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002c24:	8526                	mv	a0,s1
    80002c26:	a4cfe0ef          	jal	80000e72 <release>
}
    80002c2a:	60e2                	ld	ra,24(sp)
    80002c2c:	6442                	ld	s0,16(sp)
    80002c2e:	64a2                	ld	s1,8(sp)
    80002c30:	6105                	addi	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <killed>:
{
    80002c34:	1101                	addi	sp,sp,-32
    80002c36:	ec06                	sd	ra,24(sp)
    80002c38:	e822                	sd	s0,16(sp)
    80002c3a:	e426                	sd	s1,8(sp)
    80002c3c:	e04a                	sd	s2,0(sp)
    80002c3e:	1000                	addi	s0,sp,32
    80002c40:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002c42:	998fe0ef          	jal	80000dda <acquire>
  k = p->killed;
    80002c46:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	a26fe0ef          	jal	80000e72 <release>
}
    80002c50:	854a                	mv	a0,s2
    80002c52:	60e2                	ld	ra,24(sp)
    80002c54:	6442                	ld	s0,16(sp)
    80002c56:	64a2                	ld	s1,8(sp)
    80002c58:	6902                	ld	s2,0(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <kwait>:
{
    80002c5e:	715d                	addi	sp,sp,-80
    80002c60:	e486                	sd	ra,72(sp)
    80002c62:	e0a2                	sd	s0,64(sp)
    80002c64:	fc26                	sd	s1,56(sp)
    80002c66:	f84a                	sd	s2,48(sp)
    80002c68:	f44e                	sd	s3,40(sp)
    80002c6a:	f052                	sd	s4,32(sp)
    80002c6c:	ec56                	sd	s5,24(sp)
    80002c6e:	e85a                	sd	s6,16(sp)
    80002c70:	e45e                	sd	s7,8(sp)
    80002c72:	e062                	sd	s8,0(sp)
    80002c74:	0880                	addi	s0,sp,80
    80002c76:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002c78:	8eeff0ef          	jal	80001d66 <myproc>
    80002c7c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002c7e:	0002e517          	auipc	a0,0x2e
    80002c82:	e8a50513          	addi	a0,a0,-374 # 80030b08 <wait_lock>
    80002c86:	954fe0ef          	jal	80000dda <acquire>
    havekids = 0;
    80002c8a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002c8c:	4a15                	li	s4,5
        havekids = 1;
    80002c8e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c90:	00035997          	auipc	s3,0x35
    80002c94:	eb098993          	addi	s3,s3,-336 # 80037b40 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002c98:	0002ec17          	auipc	s8,0x2e
    80002c9c:	e70c0c13          	addi	s8,s8,-400 # 80030b08 <wait_lock>
    80002ca0:	a871                	j	80002d3c <kwait+0xde>
          pid = pp->pid;
    80002ca2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002ca6:	000b0c63          	beqz	s6,80002cbe <kwait+0x60>
    80002caa:	4691                	li	a3,4
    80002cac:	02c48613          	addi	a2,s1,44
    80002cb0:	85da                	mv	a1,s6
    80002cb2:	05093503          	ld	a0,80(s2)
    80002cb6:	c8ffe0ef          	jal	80001944 <copyout>
    80002cba:	02054b63          	bltz	a0,80002cf0 <kwait+0x92>
          freeproc(pp);
    80002cbe:	8526                	mv	a0,s1
    80002cc0:	cf0ff0ef          	jal	800021b0 <freeproc>
          release(&pp->lock);
    80002cc4:	8526                	mv	a0,s1
    80002cc6:	9acfe0ef          	jal	80000e72 <release>
          release(&wait_lock);
    80002cca:	0002e517          	auipc	a0,0x2e
    80002cce:	e3e50513          	addi	a0,a0,-450 # 80030b08 <wait_lock>
    80002cd2:	9a0fe0ef          	jal	80000e72 <release>
}
    80002cd6:	854e                	mv	a0,s3
    80002cd8:	60a6                	ld	ra,72(sp)
    80002cda:	6406                	ld	s0,64(sp)
    80002cdc:	74e2                	ld	s1,56(sp)
    80002cde:	7942                	ld	s2,48(sp)
    80002ce0:	79a2                	ld	s3,40(sp)
    80002ce2:	7a02                	ld	s4,32(sp)
    80002ce4:	6ae2                	ld	s5,24(sp)
    80002ce6:	6b42                	ld	s6,16(sp)
    80002ce8:	6ba2                	ld	s7,8(sp)
    80002cea:	6c02                	ld	s8,0(sp)
    80002cec:	6161                	addi	sp,sp,80
    80002cee:	8082                	ret
            release(&pp->lock);
    80002cf0:	8526                	mv	a0,s1
    80002cf2:	980fe0ef          	jal	80000e72 <release>
            release(&wait_lock);
    80002cf6:	0002e517          	auipc	a0,0x2e
    80002cfa:	e1250513          	addi	a0,a0,-494 # 80030b08 <wait_lock>
    80002cfe:	974fe0ef          	jal	80000e72 <release>
            return -1;
    80002d02:	59fd                	li	s3,-1
    80002d04:	bfc9                	j	80002cd6 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002d06:	1a848493          	addi	s1,s1,424
    80002d0a:	03348063          	beq	s1,s3,80002d2a <kwait+0xcc>
      if(pp->parent == p){
    80002d0e:	7c9c                	ld	a5,56(s1)
    80002d10:	ff279be3          	bne	a5,s2,80002d06 <kwait+0xa8>
        acquire(&pp->lock);
    80002d14:	8526                	mv	a0,s1
    80002d16:	8c4fe0ef          	jal	80000dda <acquire>
        if(pp->state == ZOMBIE){
    80002d1a:	4c9c                	lw	a5,24(s1)
    80002d1c:	f94783e3          	beq	a5,s4,80002ca2 <kwait+0x44>
        release(&pp->lock);
    80002d20:	8526                	mv	a0,s1
    80002d22:	950fe0ef          	jal	80000e72 <release>
        havekids = 1;
    80002d26:	8756                	mv	a4,s5
    80002d28:	bff9                	j	80002d06 <kwait+0xa8>
    if(!havekids || killed(p)){
    80002d2a:	cf19                	beqz	a4,80002d48 <kwait+0xea>
    80002d2c:	854a                	mv	a0,s2
    80002d2e:	f07ff0ef          	jal	80002c34 <killed>
    80002d32:	e919                	bnez	a0,80002d48 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002d34:	85e2                	mv	a1,s8
    80002d36:	854a                	mv	a0,s2
    80002d38:	c33ff0ef          	jal	8000296a <sleep>
    havekids = 0;
    80002d3c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002d3e:	0002e497          	auipc	s1,0x2e
    80002d42:	40248493          	addi	s1,s1,1026 # 80031140 <proc>
    80002d46:	b7e1                	j	80002d0e <kwait+0xb0>
      release(&wait_lock);
    80002d48:	0002e517          	auipc	a0,0x2e
    80002d4c:	dc050513          	addi	a0,a0,-576 # 80030b08 <wait_lock>
    80002d50:	922fe0ef          	jal	80000e72 <release>
      return -1;
    80002d54:	59fd                	li	s3,-1
    80002d56:	b741                	j	80002cd6 <kwait+0x78>

0000000080002d58 <either_copyout>:
{
    80002d58:	7179                	addi	sp,sp,-48
    80002d5a:	f406                	sd	ra,40(sp)
    80002d5c:	f022                	sd	s0,32(sp)
    80002d5e:	ec26                	sd	s1,24(sp)
    80002d60:	e84a                	sd	s2,16(sp)
    80002d62:	e44e                	sd	s3,8(sp)
    80002d64:	e052                	sd	s4,0(sp)
    80002d66:	1800                	addi	s0,sp,48
    80002d68:	84aa                	mv	s1,a0
    80002d6a:	892e                	mv	s2,a1
    80002d6c:	89b2                	mv	s3,a2
    80002d6e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002d70:	ff7fe0ef          	jal	80001d66 <myproc>
  if(user_dst){
    80002d74:	cc99                	beqz	s1,80002d92 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002d76:	86d2                	mv	a3,s4
    80002d78:	864e                	mv	a2,s3
    80002d7a:	85ca                	mv	a1,s2
    80002d7c:	6928                	ld	a0,80(a0)
    80002d7e:	bc7fe0ef          	jal	80001944 <copyout>
}
    80002d82:	70a2                	ld	ra,40(sp)
    80002d84:	7402                	ld	s0,32(sp)
    80002d86:	64e2                	ld	s1,24(sp)
    80002d88:	6942                	ld	s2,16(sp)
    80002d8a:	69a2                	ld	s3,8(sp)
    80002d8c:	6a02                	ld	s4,0(sp)
    80002d8e:	6145                	addi	sp,sp,48
    80002d90:	8082                	ret
    memmove((char *)dst, src, len);
    80002d92:	000a061b          	sext.w	a2,s4
    80002d96:	85ce                	mv	a1,s3
    80002d98:	854a                	mv	a0,s2
    80002d9a:	970fe0ef          	jal	80000f0a <memmove>
    return 0;
    80002d9e:	8526                	mv	a0,s1
    80002da0:	b7cd                	j	80002d82 <either_copyout+0x2a>

0000000080002da2 <either_copyin>:
{
    80002da2:	7179                	addi	sp,sp,-48
    80002da4:	f406                	sd	ra,40(sp)
    80002da6:	f022                	sd	s0,32(sp)
    80002da8:	ec26                	sd	s1,24(sp)
    80002daa:	e84a                	sd	s2,16(sp)
    80002dac:	e44e                	sd	s3,8(sp)
    80002dae:	e052                	sd	s4,0(sp)
    80002db0:	1800                	addi	s0,sp,48
    80002db2:	892a                	mv	s2,a0
    80002db4:	84ae                	mv	s1,a1
    80002db6:	89b2                	mv	s3,a2
    80002db8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002dba:	fadfe0ef          	jal	80001d66 <myproc>
  if(user_src){
    80002dbe:	cc99                	beqz	s1,80002ddc <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002dc0:	86d2                	mv	a3,s4
    80002dc2:	864e                	mv	a2,s3
    80002dc4:	85ca                	mv	a1,s2
    80002dc6:	6928                	ld	a0,80(a0)
    80002dc8:	c93fe0ef          	jal	80001a5a <copyin>
}
    80002dcc:	70a2                	ld	ra,40(sp)
    80002dce:	7402                	ld	s0,32(sp)
    80002dd0:	64e2                	ld	s1,24(sp)
    80002dd2:	6942                	ld	s2,16(sp)
    80002dd4:	69a2                	ld	s3,8(sp)
    80002dd6:	6a02                	ld	s4,0(sp)
    80002dd8:	6145                	addi	sp,sp,48
    80002dda:	8082                	ret
    memmove(dst, (char*)src, len);
    80002ddc:	000a061b          	sext.w	a2,s4
    80002de0:	85ce                	mv	a1,s3
    80002de2:	854a                	mv	a0,s2
    80002de4:	926fe0ef          	jal	80000f0a <memmove>
    return 0;
    80002de8:	8526                	mv	a0,s1
    80002dea:	b7cd                	j	80002dcc <either_copyin+0x2a>

0000000080002dec <procdump>:
{
    80002dec:	715d                	addi	sp,sp,-80
    80002dee:	e486                	sd	ra,72(sp)
    80002df0:	e0a2                	sd	s0,64(sp)
    80002df2:	fc26                	sd	s1,56(sp)
    80002df4:	f84a                	sd	s2,48(sp)
    80002df6:	f44e                	sd	s3,40(sp)
    80002df8:	f052                	sd	s4,32(sp)
    80002dfa:	ec56                	sd	s5,24(sp)
    80002dfc:	e85a                	sd	s6,16(sp)
    80002dfe:	e45e                	sd	s7,8(sp)
    80002e00:	0880                	addi	s0,sp,80
  printf("\n");
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	29e50513          	addi	a0,a0,670 # 800080a0 <etext+0xa0>
    80002e0a:	ef0fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002e0e:	0002e497          	auipc	s1,0x2e
    80002e12:	48a48493          	addi	s1,s1,1162 # 80031298 <proc+0x158>
    80002e16:	00035917          	auipc	s2,0x35
    80002e1a:	e8290913          	addi	s2,s2,-382 # 80037c98 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e1e:	4b15                	li	s6,5
      state = "???";
    80002e20:	00005997          	auipc	s3,0x5
    80002e24:	43098993          	addi	s3,s3,1072 # 80008250 <etext+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    80002e28:	00005a97          	auipc	s5,0x5
    80002e2c:	430a8a93          	addi	s5,s5,1072 # 80008258 <etext+0x258>
    printf("\n");
    80002e30:	00005a17          	auipc	s4,0x5
    80002e34:	270a0a13          	addi	s4,s4,624 # 800080a0 <etext+0xa0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e38:	00006b97          	auipc	s7,0x6
    80002e3c:	9f8b8b93          	addi	s7,s7,-1544 # 80008830 <states.0>
    80002e40:	a829                	j	80002e5a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002e42:	ed86a583          	lw	a1,-296(a3)
    80002e46:	8556                	mv	a0,s5
    80002e48:	eb2fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002e4c:	8552                	mv	a0,s4
    80002e4e:	eacfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002e52:	1a848493          	addi	s1,s1,424
    80002e56:	03248263          	beq	s1,s2,80002e7a <procdump+0x8e>
    if(p->state == UNUSED)
    80002e5a:	86a6                	mv	a3,s1
    80002e5c:	ec04a783          	lw	a5,-320(s1)
    80002e60:	dbed                	beqz	a5,80002e52 <procdump+0x66>
      state = "???";
    80002e62:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002e64:	fcfb6fe3          	bltu	s6,a5,80002e42 <procdump+0x56>
    80002e68:	02079713          	slli	a4,a5,0x20
    80002e6c:	01d75793          	srli	a5,a4,0x1d
    80002e70:	97de                	add	a5,a5,s7
    80002e72:	6390                	ld	a2,0(a5)
    80002e74:	f679                	bnez	a2,80002e42 <procdump+0x56>
      state = "???";
    80002e76:	864e                	mv	a2,s3
    80002e78:	b7e9                	j	80002e42 <procdump+0x56>
}
    80002e7a:	60a6                	ld	ra,72(sp)
    80002e7c:	6406                	ld	s0,64(sp)
    80002e7e:	74e2                	ld	s1,56(sp)
    80002e80:	7942                	ld	s2,48(sp)
    80002e82:	79a2                	ld	s3,40(sp)
    80002e84:	7a02                	ld	s4,32(sp)
    80002e86:	6ae2                	ld	s5,24(sp)
    80002e88:	6b42                	ld	s6,16(sp)
    80002e8a:	6ba2                	ld	s7,8(sp)
    80002e8c:	6161                	addi	sp,sp,80
    80002e8e:	8082                	ret

0000000080002e90 <ptree>:

// System call implementation: build process tree rooted at given pid
int
ptree(int rootpid, struct proc_tree *tree)
{
    80002e90:	7179                	addi	sp,sp,-48
    80002e92:	f406                	sd	ra,40(sp)
    80002e94:	f022                	sd	s0,32(sp)
    80002e96:	ec26                	sd	s1,24(sp)
    80002e98:	e84a                	sd	s2,16(sp)
    80002e9a:	e44e                	sd	s3,8(sp)
    80002e9c:	e052                	sd	s4,0(sp)
    80002e9e:	1800                	addi	s0,sp,48
    80002ea0:	892a                	mv	s2,a0
    80002ea2:	8a2e                	mv	s4,a1
  struct proc *p;
  struct proc *root = 0;

  // Find the root process
  for (p = proc; p < &proc[NPROC]; p++) {
    80002ea4:	0002e497          	auipc	s1,0x2e
    80002ea8:	29c48493          	addi	s1,s1,668 # 80031140 <proc>
    80002eac:	00035997          	auipc	s3,0x35
    80002eb0:	c9498993          	addi	s3,s3,-876 # 80037b40 <tickslock>
    80002eb4:	a801                	j	80002ec4 <ptree+0x34>
    if (p->pid == rootpid && p->state != UNUSED) {
      root = p;
      release(&p->lock);
      break;
    }
    release(&p->lock);
    80002eb6:	8526                	mv	a0,s1
    80002eb8:	fbbfd0ef          	jal	80000e72 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002ebc:	1a848493          	addi	s1,s1,424
    80002ec0:	03348c63          	beq	s1,s3,80002ef8 <ptree+0x68>
    acquire(&p->lock);
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	f15fd0ef          	jal	80000dda <acquire>
    if (p->pid == rootpid && p->state != UNUSED) {
    80002eca:	589c                	lw	a5,48(s1)
    80002ecc:	ff2795e3          	bne	a5,s2,80002eb6 <ptree+0x26>
    80002ed0:	4c9c                	lw	a5,24(s1)
    80002ed2:	d3f5                	beqz	a5,80002eb6 <ptree+0x26>
      release(&p->lock);
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	f9dfd0ef          	jal	80000e72 <release>
  if (!root) {
    return -1; // Process not found
  }

  // Initialize tree
  tree->count = 0;
    80002eda:	000a2023          	sw	zero,0(s4)

  // Build the tree recursively
  ptree_add_recursive(root, tree);
    80002ede:	85d2                	mv	a1,s4
    80002ee0:	8526                	mv	a0,s1
    80002ee2:	c07fe0ef          	jal	80001ae8 <ptree_add_recursive>

  return 0; // Success
    80002ee6:	4501                	li	a0,0
}
    80002ee8:	70a2                	ld	ra,40(sp)
    80002eea:	7402                	ld	s0,32(sp)
    80002eec:	64e2                	ld	s1,24(sp)
    80002eee:	6942                	ld	s2,16(sp)
    80002ef0:	69a2                	ld	s3,8(sp)
    80002ef2:	6a02                	ld	s4,0(sp)
    80002ef4:	6145                	addi	sp,sp,48
    80002ef6:	8082                	ret
    return -1; // Process not found
    80002ef8:	557d                	li	a0,-1
    80002efa:	b7fd                	j	80002ee8 <ptree+0x58>

0000000080002efc <create_kernel_process>:

void
create_kernel_process(const char *name, void (*entrypoint)(void))
{
    80002efc:	7179                	addi	sp,sp,-48
    80002efe:	f406                	sd	ra,40(sp)
    80002f00:	f022                	sd	s0,32(sp)
    80002f02:	ec26                	sd	s1,24(sp)
    80002f04:	e84a                	sd	s2,16(sp)
    80002f06:	e44e                	sd	s3,8(sp)
    80002f08:	1800                	addi	s0,sp,48
    80002f0a:	892a                	mv	s2,a0
    80002f0c:	89ae                	mv	s3,a1
  struct proc *p = allocproc();
    80002f0e:	b32ff0ef          	jal	80002240 <allocproc>
  if(p == 0)
    80002f12:	c951                	beqz	a0,80002fa6 <create_kernel_process+0xaa>
    80002f14:	84aa                	mv	s1,a0
    panic("create_kernel_process: allocproc failed");

  // Mark as kernel process + store entrypoint
  p->is_kproc = 1;
    80002f16:	4785                	li	a5,1
    80002f18:	16f52c23          	sw	a5,376(a0)
  p->kentry = entrypoint;
    80002f1c:	19353023          	sd	s3,384(a0)

  // Give it a name
  safestrcpy(p->name, name, sizeof(p->name));
    80002f20:	4641                	li	a2,16
    80002f22:	85ca                	mv	a1,s2
    80002f24:	15850513          	addi	a0,a0,344
    80002f28:	8c4fe0ef          	jal	80000fec <safestrcpy>

  // IMPORTANT: make it start in kernel at kproc_start, not forkret
  memset(&p->context, 0, sizeof(p->context));
    80002f2c:	07000613          	li	a2,112
    80002f30:	4581                	li	a1,0
    80002f32:	06048513          	addi	a0,s1,96
    80002f36:	f79fd0ef          	jal	80000eae <memset>
  p->context.ra = (uint64)kproc_start;
    80002f3a:	00000797          	auipc	a5,0x0
    80002f3e:	a0278793          	addi	a5,a5,-1534 # 8000293c <kproc_start>
    80002f42:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002f44:	60bc                	ld	a5,64(s1)
    80002f46:	6705                	lui	a4,0x1
    80002f48:	97ba                	add	a5,a5,a4
    80002f4a:	f4bc                	sd	a5,104(s1)

  // CFS fields: start at current minimum to avoid unfairness
  acquire(&runq_lock);
    80002f4c:	0002e917          	auipc	s2,0x2e
    80002f50:	bd490913          	addi	s2,s2,-1068 # 80030b20 <runq_lock>
    80002f54:	854a                	mv	a0,s2
    80002f56:	e85fd0ef          	jal	80000dda <acquire>
  p->vruntime = min_vruntime;
    80002f5a:	00006797          	auipc	a5,0x6
    80002f5e:	a567b783          	ld	a5,-1450(a5) # 800089b0 <min_vruntime>
    80002f62:	16f4b823          	sd	a5,368(s1)
  release(&runq_lock);
    80002f66:	854a                	mv	a0,s2
    80002f68:	f0bfd0ef          	jal	80000e72 <release>
  p->weight = 1024;
    80002f6c:	40000793          	li	a5,1024
    80002f70:	16f4a423          	sw	a5,360(s1)

  // Make runnable + insert into CFS runqueue (your scheduler uses heap)
  p->state = RUNNABLE;
    80002f74:	478d                	li	a5,3
    80002f76:	cc9c                	sw	a5,24(s1)

  acquire(&runq_lock);
    80002f78:	854a                	mv	a0,s2
    80002f7a:	e61fd0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    80002f7e:	85a6                	mv	a1,s1
    80002f80:	0002e517          	auipc	a0,0x2e
    80002f84:	bb850513          	addi	a0,a0,-1096 # 80030b38 <run_queue>
    80002f88:	2eb030ef          	jal	80006a72 <minheap_insert>
  release(&runq_lock);
    80002f8c:	854a                	mv	a0,s2
    80002f8e:	ee5fd0ef          	jal	80000e72 <release>

  release(&p->lock);
    80002f92:	8526                	mv	a0,s1
    80002f94:	edffd0ef          	jal	80000e72 <release>
}
    80002f98:	70a2                	ld	ra,40(sp)
    80002f9a:	7402                	ld	s0,32(sp)
    80002f9c:	64e2                	ld	s1,24(sp)
    80002f9e:	6942                	ld	s2,16(sp)
    80002fa0:	69a2                	ld	s3,8(sp)
    80002fa2:	6145                	addi	sp,sp,48
    80002fa4:	8082                	ret
    panic("create_kernel_process: allocproc failed");
    80002fa6:	00005517          	auipc	a0,0x5
    80002faa:	2c250513          	addi	a0,a0,706 # 80008268 <etext+0x268>
    80002fae:	833fd0ef          	jal	800007e0 <panic>

0000000080002fb2 <forkret>:
{
    80002fb2:	7179                	addi	sp,sp,-48
    80002fb4:	f406                	sd	ra,40(sp)
    80002fb6:	f022                	sd	s0,32(sp)
    80002fb8:	ec26                	sd	s1,24(sp)
    80002fba:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002fbc:	dabfe0ef          	jal	80001d66 <myproc>
    80002fc0:	84aa                	mv	s1,a0
  release(&p->lock);
    80002fc2:	eb1fd0ef          	jal	80000e72 <release>
  if (first) {
    80002fc6:	00006797          	auipc	a5,0x6
    80002fca:	9ba7a783          	lw	a5,-1606(a5) # 80008980 <first.1>
    80002fce:	cba9                	beqz	a5,80003020 <forkret+0x6e>
    fsinit(ROOTDEV);
    80002fd0:	4505                	li	a0,1
    80002fd2:	5de010ef          	jal	800045b0 <fsinit>
    swap_init();
    80002fd6:	3e1030ef          	jal	80006bb6 <swap_init>
    create_kernel_process("swapd", swapd);
    80002fda:	00004597          	auipc	a1,0x4
    80002fde:	cae58593          	addi	a1,a1,-850 # 80006c88 <swapd>
    80002fe2:	00005517          	auipc	a0,0x5
    80002fe6:	2ae50513          	addi	a0,a0,686 # 80008290 <etext+0x290>
    80002fea:	f13ff0ef          	jal	80002efc <create_kernel_process>
    first = 0;
    80002fee:	00006797          	auipc	a5,0x6
    80002ff2:	9807a923          	sw	zero,-1646(a5) # 80008980 <first.1>
    __sync_synchronize();
    80002ff6:	0ff0000f          	fence
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80002ffa:	00005517          	auipc	a0,0x5
    80002ffe:	29e50513          	addi	a0,a0,670 # 80008298 <etext+0x298>
    80003002:	fca43823          	sd	a0,-48(s0)
    80003006:	fc043c23          	sd	zero,-40(s0)
    8000300a:	fd040593          	addi	a1,s0,-48
    8000300e:	6ac020ef          	jal	800056ba <kexec>
    80003012:	6cbc                	ld	a5,88(s1)
    80003014:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80003016:	6cbc                	ld	a5,88(s1)
    80003018:	7bb8                	ld	a4,112(a5)
    8000301a:	57fd                	li	a5,-1
    8000301c:	02f70d63          	beq	a4,a5,80003056 <forkret+0xa4>
  prepare_return();
    80003020:	0e8000ef          	jal	80003108 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80003024:	68a8                	ld	a0,80(s1)
    80003026:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80003028:	04000737          	lui	a4,0x4000
    8000302c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000302e:	0732                	slli	a4,a4,0xc
    80003030:	00004797          	auipc	a5,0x4
    80003034:	06c78793          	addi	a5,a5,108 # 8000709c <userret>
    80003038:	00004697          	auipc	a3,0x4
    8000303c:	fc868693          	addi	a3,a3,-56 # 80007000 <_trampoline>
    80003040:	8f95                	sub	a5,a5,a3
    80003042:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80003044:	577d                	li	a4,-1
    80003046:	177e                	slli	a4,a4,0x3f
    80003048:	8d59                	or	a0,a0,a4
    8000304a:	9782                	jalr	a5
}
    8000304c:	70a2                	ld	ra,40(sp)
    8000304e:	7402                	ld	s0,32(sp)
    80003050:	64e2                	ld	s1,24(sp)
    80003052:	6145                	addi	sp,sp,48
    80003054:	8082                	ret
      panic("exec");
    80003056:	00005517          	auipc	a0,0x5
    8000305a:	24a50513          	addi	a0,a0,586 # 800082a0 <etext+0x2a0>
    8000305e:	f82fd0ef          	jal	800007e0 <panic>

0000000080003062 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80003062:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80003066:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000306a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000306c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000306e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80003072:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80003076:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000307a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000307e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80003082:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80003086:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000308a:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000308e:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80003092:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80003096:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000309a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000309e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800030a0:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800030a2:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800030a6:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800030aa:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800030ae:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800030b2:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800030b6:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800030ba:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800030be:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800030c2:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800030c6:	0685bd83          	ld	s11,104(a1)
        
        ret
    800030ca:	8082                	ret

00000000800030cc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800030cc:	1141                	addi	sp,sp,-16
    800030ce:	e406                	sd	ra,8(sp)
    800030d0:	e022                	sd	s0,0(sp)
    800030d2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800030d4:	00005597          	auipc	a1,0x5
    800030d8:	20458593          	addi	a1,a1,516 # 800082d8 <etext+0x2d8>
    800030dc:	00035517          	auipc	a0,0x35
    800030e0:	a6450513          	addi	a0,a0,-1436 # 80037b40 <tickslock>
    800030e4:	c77fd0ef          	jal	80000d5a <initlock>
}
    800030e8:	60a2                	ld	ra,8(sp)
    800030ea:	6402                	ld	s0,0(sp)
    800030ec:	0141                	addi	sp,sp,16
    800030ee:	8082                	ret

00000000800030f0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800030f0:	1141                	addi	sp,sp,-16
    800030f2:	e422                	sd	s0,8(sp)
    800030f4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800030f6:	00003797          	auipc	a5,0x3
    800030fa:	33a78793          	addi	a5,a5,826 # 80006430 <kernelvec>
    800030fe:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003102:	6422                	ld	s0,8(sp)
    80003104:	0141                	addi	sp,sp,16
    80003106:	8082                	ret

0000000080003108 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80003108:	1141                	addi	sp,sp,-16
    8000310a:	e406                	sd	ra,8(sp)
    8000310c:	e022                	sd	s0,0(sp)
    8000310e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003110:	c57fe0ef          	jal	80001d66 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003114:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003118:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000311a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000311e:	04000737          	lui	a4,0x4000
    80003122:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80003124:	0732                	slli	a4,a4,0xc
    80003126:	00004797          	auipc	a5,0x4
    8000312a:	eda78793          	addi	a5,a5,-294 # 80007000 <_trampoline>
    8000312e:	00004697          	auipc	a3,0x4
    80003132:	ed268693          	addi	a3,a3,-302 # 80007000 <_trampoline>
    80003136:	8f95                	sub	a5,a5,a3
    80003138:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000313a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000313e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003140:	18002773          	csrr	a4,satp
    80003144:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003146:	6d38                	ld	a4,88(a0)
    80003148:	613c                	ld	a5,64(a0)
    8000314a:	6685                	lui	a3,0x1
    8000314c:	97b6                	add	a5,a5,a3
    8000314e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003150:	6d3c                	ld	a5,88(a0)
    80003152:	00000717          	auipc	a4,0x0
    80003156:	0f870713          	addi	a4,a4,248 # 8000324a <usertrap>
    8000315a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000315c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000315e:	8712                	mv	a4,tp
    80003160:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003162:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003166:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000316a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000316e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80003172:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003174:	6f9c                	ld	a5,24(a5)
    80003176:	14179073          	csrw	sepc,a5
}
    8000317a:	60a2                	ld	ra,8(sp)
    8000317c:	6402                	ld	s0,0(sp)
    8000317e:	0141                	addi	sp,sp,16
    80003180:	8082                	ret

0000000080003182 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003182:	1101                	addi	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000318a:	bb1fe0ef          	jal	80001d3a <cpuid>
    8000318e:	cd11                	beqz	a0,800031aa <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80003190:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80003194:	000f4737          	lui	a4,0xf4
    80003198:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000319c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000319e:	14d79073          	csrw	stimecmp,a5
}
    800031a2:	60e2                	ld	ra,24(sp)
    800031a4:	6442                	ld	s0,16(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret
    800031aa:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800031ac:	00035497          	auipc	s1,0x35
    800031b0:	99448493          	addi	s1,s1,-1644 # 80037b40 <tickslock>
    800031b4:	8526                	mv	a0,s1
    800031b6:	c25fd0ef          	jal	80000dda <acquire>
    ticks++;
    800031ba:	00006517          	auipc	a0,0x6
    800031be:	80650513          	addi	a0,a0,-2042 # 800089c0 <ticks>
    800031c2:	411c                	lw	a5,0(a0)
    800031c4:	2785                	addiw	a5,a5,1
    800031c6:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800031c8:	feeff0ef          	jal	800029b6 <wakeup>
    release(&tickslock);
    800031cc:	8526                	mv	a0,s1
    800031ce:	ca5fd0ef          	jal	80000e72 <release>
    800031d2:	64a2                	ld	s1,8(sp)
    800031d4:	bf75                	j	80003190 <clockintr+0xe>

00000000800031d6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031de:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800031e2:	57fd                	li	a5,-1
    800031e4:	17fe                	slli	a5,a5,0x3f
    800031e6:	07a5                	addi	a5,a5,9
    800031e8:	00f70c63          	beq	a4,a5,80003200 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800031ec:	57fd                	li	a5,-1
    800031ee:	17fe                	slli	a5,a5,0x3f
    800031f0:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800031f2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800031f4:	04f70763          	beq	a4,a5,80003242 <devintr+0x6c>
  }
}
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	6105                	addi	sp,sp,32
    800031fe:	8082                	ret
    80003200:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80003202:	2da030ef          	jal	800064dc <plic_claim>
    80003206:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003208:	47a9                	li	a5,10
    8000320a:	00f50963          	beq	a0,a5,8000321c <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    8000320e:	4785                	li	a5,1
    80003210:	00f50963          	beq	a0,a5,80003222 <devintr+0x4c>
    return 1;
    80003214:	4505                	li	a0,1
    } else if(irq){
    80003216:	e889                	bnez	s1,80003228 <devintr+0x52>
    80003218:	64a2                	ld	s1,8(sp)
    8000321a:	bff9                	j	800031f8 <devintr+0x22>
      uartintr();
    8000321c:	f94fd0ef          	jal	800009b0 <uartintr>
    if(irq)
    80003220:	a819                	j	80003236 <devintr+0x60>
      virtio_disk_intr();
    80003222:	780030ef          	jal	800069a2 <virtio_disk_intr>
    if(irq)
    80003226:	a801                	j	80003236 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80003228:	85a6                	mv	a1,s1
    8000322a:	00005517          	auipc	a0,0x5
    8000322e:	0b650513          	addi	a0,a0,182 # 800082e0 <etext+0x2e0>
    80003232:	ac8fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80003236:	8526                	mv	a0,s1
    80003238:	2c4030ef          	jal	800064fc <plic_complete>
    return 1;
    8000323c:	4505                	li	a0,1
    8000323e:	64a2                	ld	s1,8(sp)
    80003240:	bf65                	j	800031f8 <devintr+0x22>
    clockintr();
    80003242:	f41ff0ef          	jal	80003182 <clockintr>
    return 2;
    80003246:	4509                	li	a0,2
    80003248:	bf45                	j	800031f8 <devintr+0x22>

000000008000324a <usertrap>:
{
    8000324a:	1101                	addi	sp,sp,-32
    8000324c:	ec06                	sd	ra,24(sp)
    8000324e:	e822                	sd	s0,16(sp)
    80003250:	e426                	sd	s1,8(sp)
    80003252:	e04a                	sd	s2,0(sp)
    80003254:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003256:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000325a:	1007f793          	andi	a5,a5,256
    8000325e:	ebad                	bnez	a5,800032d0 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003260:	00003797          	auipc	a5,0x3
    80003264:	1d078793          	addi	a5,a5,464 # 80006430 <kernelvec>
    80003268:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000326c:	afbfe0ef          	jal	80001d66 <myproc>
    80003270:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003272:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003274:	14102773          	csrr	a4,sepc
    80003278:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000327a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000327e:	47a1                	li	a5,8
    80003280:	04f70e63          	beq	a4,a5,800032dc <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80003284:	f53ff0ef          	jal	800031d6 <devintr>
    80003288:	892a                	mv	s2,a0
    8000328a:	10051863          	bnez	a0,8000339a <usertrap+0x150>
    8000328e:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15) {
    80003292:	47bd                	li	a5,15
    80003294:	08f70863          	beq	a4,a5,80003324 <usertrap+0xda>
    80003298:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13 && vmfault(p->pagetable, r_stval(), 1) != 0) {
    8000329c:	47b5                	li	a5,13
    8000329e:	0ef70663          	beq	a4,a5,8000338a <usertrap+0x140>
    800032a2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800032a6:	5890                	lw	a2,48(s1)
    800032a8:	00005517          	auipc	a0,0x5
    800032ac:	0e850513          	addi	a0,a0,232 # 80008390 <etext+0x390>
    800032b0:	a4afd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032b8:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800032bc:	00005517          	auipc	a0,0x5
    800032c0:	10450513          	addi	a0,a0,260 # 800083c0 <etext+0x3c0>
    800032c4:	a36fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800032c8:	8526                	mv	a0,s1
    800032ca:	947ff0ef          	jal	80002c10 <setkilled>
    800032ce:	a035                	j	800032fa <usertrap+0xb0>
    panic("usertrap: not from user mode");
    800032d0:	00005517          	auipc	a0,0x5
    800032d4:	03050513          	addi	a0,a0,48 # 80008300 <etext+0x300>
    800032d8:	d08fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    800032dc:	959ff0ef          	jal	80002c34 <killed>
    800032e0:	ed15                	bnez	a0,8000331c <usertrap+0xd2>
    p->trapframe->epc += 4;
    800032e2:	6cb8                	ld	a4,88(s1)
    800032e4:	6f1c                	ld	a5,24(a4)
    800032e6:	0791                	addi	a5,a5,4
    800032e8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800032ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800032ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800032f2:	10079073          	csrw	sstatus,a5
    syscall();
    800032f6:	2a4000ef          	jal	8000359a <syscall>
  if(killed(p))
    800032fa:	8526                	mv	a0,s1
    800032fc:	939ff0ef          	jal	80002c34 <killed>
    80003300:	e155                	bnez	a0,800033a4 <usertrap+0x15a>
  prepare_return();
    80003302:	e07ff0ef          	jal	80003108 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80003306:	68a8                	ld	a0,80(s1)
    80003308:	8131                	srli	a0,a0,0xc
    8000330a:	57fd                	li	a5,-1
    8000330c:	17fe                	slli	a5,a5,0x3f
    8000330e:	8d5d                	or	a0,a0,a5
}
    80003310:	60e2                	ld	ra,24(sp)
    80003312:	6442                	ld	s0,16(sp)
    80003314:	64a2                	ld	s1,8(sp)
    80003316:	6902                	ld	s2,0(sp)
    80003318:	6105                	addi	sp,sp,32
    8000331a:	8082                	ret
      kexit(-1);
    8000331c:	557d                	li	a0,-1
    8000331e:	fb4ff0ef          	jal	80002ad2 <kexit>
    80003322:	b7c1                	j	800032e2 <usertrap+0x98>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003324:	14302973          	csrr	s2,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    80003328:	4601                	li	a2,0
    8000332a:	85ca                	mv	a1,s2
    8000332c:	68a8                	ld	a0,80(s1)
    8000332e:	df5fd0ef          	jal	80001122 <walk>
    if(pte != 0 && (*pte & PTE_V) && (*pte & PTE_COW)) {
    80003332:	c901                	beqz	a0,80003342 <usertrap+0xf8>
    80003334:	611c                	ld	a5,0(a0)
    80003336:	1017f793          	andi	a5,a5,257
    8000333a:	10100713          	li	a4,257
    8000333e:	02e78463          	beq	a5,a4,80003366 <usertrap+0x11c>
    } else if(vmfault(p->pagetable, va, 0) == 0) {
    80003342:	4601                	li	a2,0
    80003344:	85ca                	mv	a1,s2
    80003346:	68a8                	ld	a0,80(s1)
    80003348:	d7afe0ef          	jal	800018c2 <vmfault>
    8000334c:	f55d                	bnez	a0,800032fa <usertrap+0xb0>
      printf("usertrap(): page fault failed for va=0x%lx pid=%d\n", va, p->pid);
    8000334e:	5890                	lw	a2,48(s1)
    80003350:	85ca                	mv	a1,s2
    80003352:	00005517          	auipc	a0,0x5
    80003356:	00650513          	addi	a0,a0,6 # 80008358 <etext+0x358>
    8000335a:	9a0fd0ef          	jal	800004fa <printf>
      setkilled(p);
    8000335e:	8526                	mv	a0,s1
    80003360:	8b1ff0ef          	jal	80002c10 <setkilled>
    80003364:	bf59                	j	800032fa <usertrap+0xb0>
      if(cowfault(p->pagetable, va) < 0) {
    80003366:	85ca                	mv	a1,s2
    80003368:	68a8                	ld	a0,80(s1)
    8000336a:	c7efe0ef          	jal	800017e8 <cowfault>
    8000336e:	f80556e3          	bgez	a0,800032fa <usertrap+0xb0>
        printf("usertrap(): COW fault failed for va=0x%lx pid=%d\n", va, p->pid);
    80003372:	5890                	lw	a2,48(s1)
    80003374:	85ca                	mv	a1,s2
    80003376:	00005517          	auipc	a0,0x5
    8000337a:	faa50513          	addi	a0,a0,-86 # 80008320 <etext+0x320>
    8000337e:	97cfd0ef          	jal	800004fa <printf>
        setkilled(p);
    80003382:	8526                	mv	a0,s1
    80003384:	88dff0ef          	jal	80002c10 <setkilled>
    80003388:	bf8d                	j	800032fa <usertrap+0xb0>
    8000338a:	143025f3          	csrr	a1,stval
  } else if(r_scause() == 13 && vmfault(p->pagetable, r_stval(), 1) != 0) {
    8000338e:	4605                	li	a2,1
    80003390:	68a8                	ld	a0,80(s1)
    80003392:	d30fe0ef          	jal	800018c2 <vmfault>
    80003396:	f135                	bnez	a0,800032fa <usertrap+0xb0>
    80003398:	b729                	j	800032a2 <usertrap+0x58>
  if(killed(p))
    8000339a:	8526                	mv	a0,s1
    8000339c:	899ff0ef          	jal	80002c34 <killed>
    800033a0:	c511                	beqz	a0,800033ac <usertrap+0x162>
    800033a2:	a011                	j	800033a6 <usertrap+0x15c>
    800033a4:	4901                	li	s2,0
    kexit(-1);
    800033a6:	557d                	li	a0,-1
    800033a8:	f2aff0ef          	jal	80002ad2 <kexit>
  if(which_dev == 2)
    800033ac:	4789                	li	a5,2
    800033ae:	f4f91ae3          	bne	s2,a5,80003302 <usertrap+0xb8>
    yield();
    800033b2:	cf8ff0ef          	jal	800028aa <yield>
    800033b6:	b7b1                	j	80003302 <usertrap+0xb8>

00000000800033b8 <kerneltrap>:
{
    800033b8:	7179                	addi	sp,sp,-48
    800033ba:	f406                	sd	ra,40(sp)
    800033bc:	f022                	sd	s0,32(sp)
    800033be:	ec26                	sd	s1,24(sp)
    800033c0:	e84a                	sd	s2,16(sp)
    800033c2:	e44e                	sd	s3,8(sp)
    800033c4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800033c6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800033ca:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800033ce:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800033d2:	1004f793          	andi	a5,s1,256
    800033d6:	c795                	beqz	a5,80003402 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800033d8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800033dc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800033de:	eb85                	bnez	a5,8000340e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800033e0:	df7ff0ef          	jal	800031d6 <devintr>
    800033e4:	c91d                	beqz	a0,8000341a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800033e6:	4789                	li	a5,2
    800033e8:	04f50a63          	beq	a0,a5,8000343c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800033ec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800033f0:	10049073          	csrw	sstatus,s1
}
    800033f4:	70a2                	ld	ra,40(sp)
    800033f6:	7402                	ld	s0,32(sp)
    800033f8:	64e2                	ld	s1,24(sp)
    800033fa:	6942                	ld	s2,16(sp)
    800033fc:	69a2                	ld	s3,8(sp)
    800033fe:	6145                	addi	sp,sp,48
    80003400:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003402:	00005517          	auipc	a0,0x5
    80003406:	fe650513          	addi	a0,a0,-26 # 800083e8 <etext+0x3e8>
    8000340a:	bd6fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	00250513          	addi	a0,a0,2 # 80008410 <etext+0x410>
    80003416:	bcafd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000341a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000341e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80003422:	85ce                	mv	a1,s3
    80003424:	00005517          	auipc	a0,0x5
    80003428:	00c50513          	addi	a0,a0,12 # 80008430 <etext+0x430>
    8000342c:	8cefd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003430:	00005517          	auipc	a0,0x5
    80003434:	02850513          	addi	a0,a0,40 # 80008458 <etext+0x458>
    80003438:	ba8fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000343c:	92bfe0ef          	jal	80001d66 <myproc>
    80003440:	d555                	beqz	a0,800033ec <kerneltrap+0x34>
    yield();
    80003442:	c68ff0ef          	jal	800028aa <yield>
    80003446:	b75d                	j	800033ec <kerneltrap+0x34>

0000000080003448 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003448:	1101                	addi	sp,sp,-32
    8000344a:	ec06                	sd	ra,24(sp)
    8000344c:	e822                	sd	s0,16(sp)
    8000344e:	e426                	sd	s1,8(sp)
    80003450:	1000                	addi	s0,sp,32
    80003452:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003454:	913fe0ef          	jal	80001d66 <myproc>
  switch (n) {
    80003458:	4795                	li	a5,5
    8000345a:	0497e163          	bltu	a5,s1,8000349c <argraw+0x54>
    8000345e:	048a                	slli	s1,s1,0x2
    80003460:	00005717          	auipc	a4,0x5
    80003464:	40070713          	addi	a4,a4,1024 # 80008860 <states.0+0x30>
    80003468:	94ba                	add	s1,s1,a4
    8000346a:	409c                	lw	a5,0(s1)
    8000346c:	97ba                	add	a5,a5,a4
    8000346e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003470:	6d3c                	ld	a5,88(a0)
    80003472:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003474:	60e2                	ld	ra,24(sp)
    80003476:	6442                	ld	s0,16(sp)
    80003478:	64a2                	ld	s1,8(sp)
    8000347a:	6105                	addi	sp,sp,32
    8000347c:	8082                	ret
    return p->trapframe->a1;
    8000347e:	6d3c                	ld	a5,88(a0)
    80003480:	7fa8                	ld	a0,120(a5)
    80003482:	bfcd                	j	80003474 <argraw+0x2c>
    return p->trapframe->a2;
    80003484:	6d3c                	ld	a5,88(a0)
    80003486:	63c8                	ld	a0,128(a5)
    80003488:	b7f5                	j	80003474 <argraw+0x2c>
    return p->trapframe->a3;
    8000348a:	6d3c                	ld	a5,88(a0)
    8000348c:	67c8                	ld	a0,136(a5)
    8000348e:	b7dd                	j	80003474 <argraw+0x2c>
    return p->trapframe->a4;
    80003490:	6d3c                	ld	a5,88(a0)
    80003492:	6bc8                	ld	a0,144(a5)
    80003494:	b7c5                	j	80003474 <argraw+0x2c>
    return p->trapframe->a5;
    80003496:	6d3c                	ld	a5,88(a0)
    80003498:	6fc8                	ld	a0,152(a5)
    8000349a:	bfe9                	j	80003474 <argraw+0x2c>
  panic("argraw");
    8000349c:	00005517          	auipc	a0,0x5
    800034a0:	fcc50513          	addi	a0,a0,-52 # 80008468 <etext+0x468>
    800034a4:	b3cfd0ef          	jal	800007e0 <panic>

00000000800034a8 <fetchaddr>:
{
    800034a8:	1101                	addi	sp,sp,-32
    800034aa:	ec06                	sd	ra,24(sp)
    800034ac:	e822                	sd	s0,16(sp)
    800034ae:	e426                	sd	s1,8(sp)
    800034b0:	e04a                	sd	s2,0(sp)
    800034b2:	1000                	addi	s0,sp,32
    800034b4:	84aa                	mv	s1,a0
    800034b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800034b8:	8affe0ef          	jal	80001d66 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800034bc:	653c                	ld	a5,72(a0)
    800034be:	02f4f663          	bgeu	s1,a5,800034ea <fetchaddr+0x42>
    800034c2:	00848713          	addi	a4,s1,8
    800034c6:	02e7e463          	bltu	a5,a4,800034ee <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800034ca:	46a1                	li	a3,8
    800034cc:	8626                	mv	a2,s1
    800034ce:	85ca                	mv	a1,s2
    800034d0:	6928                	ld	a0,80(a0)
    800034d2:	d88fe0ef          	jal	80001a5a <copyin>
    800034d6:	00a03533          	snez	a0,a0
    800034da:	40a00533          	neg	a0,a0
}
    800034de:	60e2                	ld	ra,24(sp)
    800034e0:	6442                	ld	s0,16(sp)
    800034e2:	64a2                	ld	s1,8(sp)
    800034e4:	6902                	ld	s2,0(sp)
    800034e6:	6105                	addi	sp,sp,32
    800034e8:	8082                	ret
    return -1;
    800034ea:	557d                	li	a0,-1
    800034ec:	bfcd                	j	800034de <fetchaddr+0x36>
    800034ee:	557d                	li	a0,-1
    800034f0:	b7fd                	j	800034de <fetchaddr+0x36>

00000000800034f2 <fetchstr>:
{
    800034f2:	7179                	addi	sp,sp,-48
    800034f4:	f406                	sd	ra,40(sp)
    800034f6:	f022                	sd	s0,32(sp)
    800034f8:	ec26                	sd	s1,24(sp)
    800034fa:	e84a                	sd	s2,16(sp)
    800034fc:	e44e                	sd	s3,8(sp)
    800034fe:	1800                	addi	s0,sp,48
    80003500:	892a                	mv	s2,a0
    80003502:	84ae                	mv	s1,a1
    80003504:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003506:	861fe0ef          	jal	80001d66 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000350a:	86ce                	mv	a3,s3
    8000350c:	864a                	mv	a2,s2
    8000350e:	85a6                	mv	a1,s1
    80003510:	6928                	ld	a0,80(a0)
    80003512:	a1efe0ef          	jal	80001730 <copyinstr>
    80003516:	00054c63          	bltz	a0,8000352e <fetchstr+0x3c>
  return strlen(buf);
    8000351a:	8526                	mv	a0,s1
    8000351c:	b03fd0ef          	jal	8000101e <strlen>
}
    80003520:	70a2                	ld	ra,40(sp)
    80003522:	7402                	ld	s0,32(sp)
    80003524:	64e2                	ld	s1,24(sp)
    80003526:	6942                	ld	s2,16(sp)
    80003528:	69a2                	ld	s3,8(sp)
    8000352a:	6145                	addi	sp,sp,48
    8000352c:	8082                	ret
    return -1;
    8000352e:	557d                	li	a0,-1
    80003530:	bfc5                	j	80003520 <fetchstr+0x2e>

0000000080003532 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003532:	1101                	addi	sp,sp,-32
    80003534:	ec06                	sd	ra,24(sp)
    80003536:	e822                	sd	s0,16(sp)
    80003538:	e426                	sd	s1,8(sp)
    8000353a:	1000                	addi	s0,sp,32
    8000353c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000353e:	f0bff0ef          	jal	80003448 <argraw>
    80003542:	c088                	sw	a0,0(s1)
}
    80003544:	60e2                	ld	ra,24(sp)
    80003546:	6442                	ld	s0,16(sp)
    80003548:	64a2                	ld	s1,8(sp)
    8000354a:	6105                	addi	sp,sp,32
    8000354c:	8082                	ret

000000008000354e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000354e:	1101                	addi	sp,sp,-32
    80003550:	ec06                	sd	ra,24(sp)
    80003552:	e822                	sd	s0,16(sp)
    80003554:	e426                	sd	s1,8(sp)
    80003556:	1000                	addi	s0,sp,32
    80003558:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000355a:	eefff0ef          	jal	80003448 <argraw>
    8000355e:	e088                	sd	a0,0(s1)
}
    80003560:	60e2                	ld	ra,24(sp)
    80003562:	6442                	ld	s0,16(sp)
    80003564:	64a2                	ld	s1,8(sp)
    80003566:	6105                	addi	sp,sp,32
    80003568:	8082                	ret

000000008000356a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	1800                	addi	s0,sp,48
    80003576:	84ae                	mv	s1,a1
    80003578:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000357a:	fd840593          	addi	a1,s0,-40
    8000357e:	fd1ff0ef          	jal	8000354e <argaddr>
  return fetchstr(addr, buf, max);
    80003582:	864a                	mv	a2,s2
    80003584:	85a6                	mv	a1,s1
    80003586:	fd843503          	ld	a0,-40(s0)
    8000358a:	f69ff0ef          	jal	800034f2 <fetchstr>
}
    8000358e:	70a2                	ld	ra,40(sp)
    80003590:	7402                	ld	s0,32(sp)
    80003592:	64e2                	ld	s1,24(sp)
    80003594:	6942                	ld	s2,16(sp)
    80003596:	6145                	addi	sp,sp,48
    80003598:	8082                	ret

000000008000359a <syscall>:

uint sysclcnt = 0;

void
syscall(void)
{
    8000359a:	1101                	addi	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	e04a                	sd	s2,0(sp)
    800035a4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800035a6:	fc0fe0ef          	jal	80001d66 <myproc>
    800035aa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800035ac:	05853903          	ld	s2,88(a0)
    800035b0:	0a893783          	ld	a5,168(s2)
    800035b4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800035b8:	37fd                	addiw	a5,a5,-1
    800035ba:	4779                	li	a4,30
    800035bc:	02f76663          	bltu	a4,a5,800035e8 <syscall+0x4e>
    800035c0:	00369713          	slli	a4,a3,0x3
    800035c4:	00005797          	auipc	a5,0x5
    800035c8:	2b478793          	addi	a5,a5,692 # 80008878 <syscalls>
    800035cc:	97ba                	add	a5,a5,a4
    800035ce:	6398                	ld	a4,0(a5)
    800035d0:	cf01                	beqz	a4,800035e8 <syscall+0x4e>
    sysclcnt++;
    800035d2:	00005697          	auipc	a3,0x5
    800035d6:	3f268693          	addi	a3,a3,1010 # 800089c4 <sysclcnt>
    800035da:	429c                	lw	a5,0(a3)
    800035dc:	2785                	addiw	a5,a5,1
    800035de:	c29c                	sw	a5,0(a3)
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800035e0:	9702                	jalr	a4
    800035e2:	06a93823          	sd	a0,112(s2)
    800035e6:	a829                	j	80003600 <syscall+0x66>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800035e8:	15848613          	addi	a2,s1,344
    800035ec:	588c                	lw	a1,48(s1)
    800035ee:	00005517          	auipc	a0,0x5
    800035f2:	e8250513          	addi	a0,a0,-382 # 80008470 <etext+0x470>
    800035f6:	f05fc0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800035fa:	6cbc                	ld	a5,88(s1)
    800035fc:	577d                	li	a4,-1
    800035fe:	fbb8                	sd	a4,112(a5)
  }
}
    80003600:	60e2                	ld	ra,24(sp)
    80003602:	6442                	ld	s0,16(sp)
    80003604:	64a2                	ld	s1,8(sp)
    80003606:	6902                	ld	s2,0(sp)
    80003608:	6105                	addi	sp,sp,32
    8000360a:	8082                	ret

000000008000360c <sys_exit>:
// Forward declaration
int ptree(int pid, struct proc_tree *tree);

uint64
sys_exit(void)
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003614:	fec40593          	addi	a1,s0,-20
    80003618:	4501                	li	a0,0
    8000361a:	f19ff0ef          	jal	80003532 <argint>
  kexit(n);
    8000361e:	fec42503          	lw	a0,-20(s0)
    80003622:	cb0ff0ef          	jal	80002ad2 <kexit>
  return 0;  // not reached
}
    80003626:	4501                	li	a0,0
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	6105                	addi	sp,sp,32
    8000362e:	8082                	ret

0000000080003630 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003630:	1141                	addi	sp,sp,-16
    80003632:	e406                	sd	ra,8(sp)
    80003634:	e022                	sd	s0,0(sp)
    80003636:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003638:	f2efe0ef          	jal	80001d66 <myproc>
}
    8000363c:	5908                	lw	a0,48(a0)
    8000363e:	60a2                	ld	ra,8(sp)
    80003640:	6402                	ld	s0,0(sp)
    80003642:	0141                	addi	sp,sp,16
    80003644:	8082                	ret

0000000080003646 <sys_fork>:

uint64
sys_fork(void)
{
    80003646:	1141                	addi	sp,sp,-16
    80003648:	e406                	sd	ra,8(sp)
    8000364a:	e022                	sd	s0,0(sp)
    8000364c:	0800                	addi	s0,sp,16
  return kfork();
    8000364e:	debfe0ef          	jal	80002438 <kfork>
}
    80003652:	60a2                	ld	ra,8(sp)
    80003654:	6402                	ld	s0,0(sp)
    80003656:	0141                	addi	sp,sp,16
    80003658:	8082                	ret

000000008000365a <sys_wait>:

uint64
sys_wait(void)
{
    8000365a:	1101                	addi	sp,sp,-32
    8000365c:	ec06                	sd	ra,24(sp)
    8000365e:	e822                	sd	s0,16(sp)
    80003660:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003662:	fe840593          	addi	a1,s0,-24
    80003666:	4501                	li	a0,0
    80003668:	ee7ff0ef          	jal	8000354e <argaddr>
  return kwait(p);
    8000366c:	fe843503          	ld	a0,-24(s0)
    80003670:	deeff0ef          	jal	80002c5e <kwait>
}
    80003674:	60e2                	ld	ra,24(sp)
    80003676:	6442                	ld	s0,16(sp)
    80003678:	6105                	addi	sp,sp,32
    8000367a:	8082                	ret

000000008000367c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000367c:	7179                	addi	sp,sp,-48
    8000367e:	f406                	sd	ra,40(sp)
    80003680:	f022                	sd	s0,32(sp)
    80003682:	ec26                	sd	s1,24(sp)
    80003684:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80003686:	fd840593          	addi	a1,s0,-40
    8000368a:	4501                	li	a0,0
    8000368c:	ea7ff0ef          	jal	80003532 <argint>
  argint(1, &t);
    80003690:	fdc40593          	addi	a1,s0,-36
    80003694:	4505                	li	a0,1
    80003696:	e9dff0ef          	jal	80003532 <argint>
  addr = myproc()->sz;
    8000369a:	eccfe0ef          	jal	80001d66 <myproc>
    8000369e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800036a0:	fdc42703          	lw	a4,-36(s0)
    800036a4:	4785                	li	a5,1
    800036a6:	02f70763          	beq	a4,a5,800036d4 <sys_sbrk+0x58>
    800036aa:	fd842783          	lw	a5,-40(s0)
    800036ae:	0207c363          	bltz	a5,800036d4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800036b2:	97a6                	add	a5,a5,s1
    800036b4:	0297ee63          	bltu	a5,s1,800036f0 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    800036b8:	02000737          	lui	a4,0x2000
    800036bc:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800036be:	0736                	slli	a4,a4,0xd
    800036c0:	02f76a63          	bltu	a4,a5,800036f4 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    800036c4:	ea2fe0ef          	jal	80001d66 <myproc>
    800036c8:	fd842703          	lw	a4,-40(s0)
    800036cc:	653c                	ld	a5,72(a0)
    800036ce:	97ba                	add	a5,a5,a4
    800036d0:	e53c                	sd	a5,72(a0)
    800036d2:	a039                	j	800036e0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800036d4:	fd842503          	lw	a0,-40(s0)
    800036d8:	cfffe0ef          	jal	800023d6 <growproc>
    800036dc:	00054863          	bltz	a0,800036ec <sys_sbrk+0x70>
  }
  return addr;
}
    800036e0:	8526                	mv	a0,s1
    800036e2:	70a2                	ld	ra,40(sp)
    800036e4:	7402                	ld	s0,32(sp)
    800036e6:	64e2                	ld	s1,24(sp)
    800036e8:	6145                	addi	sp,sp,48
    800036ea:	8082                	ret
      return -1;
    800036ec:	54fd                	li	s1,-1
    800036ee:	bfcd                	j	800036e0 <sys_sbrk+0x64>
      return -1;
    800036f0:	54fd                	li	s1,-1
    800036f2:	b7fd                	j	800036e0 <sys_sbrk+0x64>
      return -1;
    800036f4:	54fd                	li	s1,-1
    800036f6:	b7ed                	j	800036e0 <sys_sbrk+0x64>

00000000800036f8 <sys_pause>:

uint64
sys_pause(void)
{
    800036f8:	7139                	addi	sp,sp,-64
    800036fa:	fc06                	sd	ra,56(sp)
    800036fc:	f822                	sd	s0,48(sp)
    800036fe:	f04a                	sd	s2,32(sp)
    80003700:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003702:	fcc40593          	addi	a1,s0,-52
    80003706:	4501                	li	a0,0
    80003708:	e2bff0ef          	jal	80003532 <argint>
  if(n < 0)
    8000370c:	fcc42783          	lw	a5,-52(s0)
    80003710:	0607c763          	bltz	a5,8000377e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003714:	00034517          	auipc	a0,0x34
    80003718:	42c50513          	addi	a0,a0,1068 # 80037b40 <tickslock>
    8000371c:	ebefd0ef          	jal	80000dda <acquire>
  ticks0 = ticks;
    80003720:	00005917          	auipc	s2,0x5
    80003724:	2a092903          	lw	s2,672(s2) # 800089c0 <ticks>
  while(ticks - ticks0 < n){
    80003728:	fcc42783          	lw	a5,-52(s0)
    8000372c:	cf8d                	beqz	a5,80003766 <sys_pause+0x6e>
    8000372e:	f426                	sd	s1,40(sp)
    80003730:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003732:	00034997          	auipc	s3,0x34
    80003736:	40e98993          	addi	s3,s3,1038 # 80037b40 <tickslock>
    8000373a:	00005497          	auipc	s1,0x5
    8000373e:	28648493          	addi	s1,s1,646 # 800089c0 <ticks>
    if(killed(myproc())){
    80003742:	e24fe0ef          	jal	80001d66 <myproc>
    80003746:	ceeff0ef          	jal	80002c34 <killed>
    8000374a:	ed0d                	bnez	a0,80003784 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000374c:	85ce                	mv	a1,s3
    8000374e:	8526                	mv	a0,s1
    80003750:	a1aff0ef          	jal	8000296a <sleep>
  while(ticks - ticks0 < n){
    80003754:	409c                	lw	a5,0(s1)
    80003756:	412787bb          	subw	a5,a5,s2
    8000375a:	fcc42703          	lw	a4,-52(s0)
    8000375e:	fee7e2e3          	bltu	a5,a4,80003742 <sys_pause+0x4a>
    80003762:	74a2                	ld	s1,40(sp)
    80003764:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003766:	00034517          	auipc	a0,0x34
    8000376a:	3da50513          	addi	a0,a0,986 # 80037b40 <tickslock>
    8000376e:	f04fd0ef          	jal	80000e72 <release>
  return 0;
    80003772:	4501                	li	a0,0
}
    80003774:	70e2                	ld	ra,56(sp)
    80003776:	7442                	ld	s0,48(sp)
    80003778:	7902                	ld	s2,32(sp)
    8000377a:	6121                	addi	sp,sp,64
    8000377c:	8082                	ret
    n = 0;
    8000377e:	fc042623          	sw	zero,-52(s0)
    80003782:	bf49                	j	80003714 <sys_pause+0x1c>
      release(&tickslock);
    80003784:	00034517          	auipc	a0,0x34
    80003788:	3bc50513          	addi	a0,a0,956 # 80037b40 <tickslock>
    8000378c:	ee6fd0ef          	jal	80000e72 <release>
      return -1;
    80003790:	557d                	li	a0,-1
    80003792:	74a2                	ld	s1,40(sp)
    80003794:	69e2                	ld	s3,24(sp)
    80003796:	bff9                	j	80003774 <sys_pause+0x7c>

0000000080003798 <sys_kill>:

uint64
sys_kill(void)
{
    80003798:	1101                	addi	sp,sp,-32
    8000379a:	ec06                	sd	ra,24(sp)
    8000379c:	e822                	sd	s0,16(sp)
    8000379e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800037a0:	fec40593          	addi	a1,s0,-20
    800037a4:	4501                	li	a0,0
    800037a6:	d8dff0ef          	jal	80003532 <argint>
  return kkill(pid);
    800037aa:	fec42503          	lw	a0,-20(s0)
    800037ae:	bc6ff0ef          	jal	80002b74 <kkill>
}
    800037b2:	60e2                	ld	ra,24(sp)
    800037b4:	6442                	ld	s0,16(sp)
    800037b6:	6105                	addi	sp,sp,32
    800037b8:	8082                	ret

00000000800037ba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	e426                	sd	s1,8(sp)
    800037c2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800037c4:	00034517          	auipc	a0,0x34
    800037c8:	37c50513          	addi	a0,a0,892 # 80037b40 <tickslock>
    800037cc:	e0efd0ef          	jal	80000dda <acquire>
  xticks = ticks;
    800037d0:	00005497          	auipc	s1,0x5
    800037d4:	1f04a483          	lw	s1,496(s1) # 800089c0 <ticks>
  release(&tickslock);
    800037d8:	00034517          	auipc	a0,0x34
    800037dc:	36850513          	addi	a0,a0,872 # 80037b40 <tickslock>
    800037e0:	e92fd0ef          	jal	80000e72 <release>
  return xticks;
}
    800037e4:	02049513          	slli	a0,s1,0x20
    800037e8:	9101                	srli	a0,a0,0x20
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6105                	addi	sp,sp,32
    800037f2:	8082                	ret

00000000800037f4 <sys_clcnt>:

uint64
sys_clcnt(void)
{
    800037f4:	1141                	addi	sp,sp,-16
    800037f6:	e422                	sd	s0,8(sp)
    800037f8:	0800                	addi	s0,sp,16
  extern uint sysclcnt;
  return sysclcnt;
}
    800037fa:	00005517          	auipc	a0,0x5
    800037fe:	1ca56503          	lwu	a0,458(a0) # 800089c4 <sysclcnt>
    80003802:	6422                	ld	s0,8(sp)
    80003804:	0141                	addi	sp,sp,16
    80003806:	8082                	ret

0000000080003808 <sys_ptree>:

uint64
sys_ptree(void)
{
    80003808:	8c010113          	addi	sp,sp,-1856
    8000380c:	72113c23          	sd	ra,1848(sp)
    80003810:	72813823          	sd	s0,1840(sp)
    80003814:	72913423          	sd	s1,1832(sp)
    80003818:	74010413          	addi	s0,sp,1856
  int pid;
  uint64 tree_addr;
  struct proc_tree tree;
  struct proc *p = myproc();
    8000381c:	d4afe0ef          	jal	80001d66 <myproc>
    80003820:	84aa                	mv	s1,a0

  argint(0, &pid);
    80003822:	fdc40593          	addi	a1,s0,-36
    80003826:	4501                	li	a0,0
    80003828:	d0bff0ef          	jal	80003532 <argint>
  argaddr(1, &tree_addr);
    8000382c:	fd040593          	addi	a1,s0,-48
    80003830:	4505                	li	a0,1
    80003832:	d1dff0ef          	jal	8000354e <argaddr>

  // Call the kernel ptree function
  int result = ptree(pid, &tree);
    80003836:	8c840593          	addi	a1,s0,-1848
    8000383a:	fdc42503          	lw	a0,-36(s0)
    8000383e:	e52ff0ef          	jal	80002e90 <ptree>
  
  if (result < 0) {
    return -1;
    80003842:	57fd                	li	a5,-1
  if (result < 0) {
    80003844:	00054d63          	bltz	a0,8000385e <sys_ptree+0x56>
  }

  // Copy the result to user space
  if (copyout(p->pagetable, tree_addr, (char *)&tree, sizeof(tree)) < 0) {
    80003848:	70400693          	li	a3,1796
    8000384c:	8c840613          	addi	a2,s0,-1848
    80003850:	fd043583          	ld	a1,-48(s0)
    80003854:	68a8                	ld	a0,80(s1)
    80003856:	8eefe0ef          	jal	80001944 <copyout>
    8000385a:	43f55793          	srai	a5,a0,0x3f
    return -1;
  }

  return 0;
}
    8000385e:	853e                	mv	a0,a5
    80003860:	73813083          	ld	ra,1848(sp)
    80003864:	73013403          	ld	s0,1840(sp)
    80003868:	72813483          	ld	s1,1832(sp)
    8000386c:	74010113          	addi	sp,sp,1856
    80003870:	8082                	ret

0000000080003872 <sys_cowfork>:

// COW fork system call
uint64
sys_cowfork(void)
{
    80003872:	1141                	addi	sp,sp,-16
    80003874:	e406                	sd	ra,8(sp)
    80003876:	e022                	sd	s0,0(sp)
    80003878:	0800                	addi	s0,sp,16
  return kcowfork();
    8000387a:	d41fe0ef          	jal	800025ba <kcowfork>
}
    8000387e:	60a2                	ld	ra,8(sp)
    80003880:	6402                	ld	s0,0(sp)
    80003882:	0141                	addi	sp,sp,16
    80003884:	8082                	ret

0000000080003886 <sys_physaddr>:

// physaddr system call - returns the physical page number for a virtual address
// If no argument, uses the process's stack pointer area
uint64
sys_physaddr(void)
{
    80003886:	7179                	addi	sp,sp,-48
    80003888:	f406                	sd	ra,40(sp)
    8000388a:	f022                	sd	s0,32(sp)
    8000388c:	ec26                	sd	s1,24(sp)
    8000388e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003890:	cd6fe0ef          	jal	80001d66 <myproc>
    80003894:	84aa                	mv	s1,a0
  uint64 va;
  pte_t *pte;
  uint64 pa;

  // Get virtual address from argument (if provided)
  argaddr(0, &va);
    80003896:	fd840593          	addi	a1,s0,-40
    8000389a:	4501                	li	a0,0
    8000389c:	cb3ff0ef          	jal	8000354e <argaddr>
  
  // If va is 0, use the stack pointer
  if(va == 0)
    800038a0:	fd843783          	ld	a5,-40(s0)
    800038a4:	e789                	bnez	a5,800038ae <sys_physaddr+0x28>
    va = p->trapframe->sp;
    800038a6:	6cbc                	ld	a5,88(s1)
    800038a8:	7b9c                	ld	a5,48(a5)
    800038aa:	fcf43c23          	sd	a5,-40(s0)
  
  va = PGROUNDDOWN(va);
    800038ae:	75fd                	lui	a1,0xfffff
    800038b0:	fd843783          	ld	a5,-40(s0)
    800038b4:	8dfd                	and	a1,a1,a5
    800038b6:	fcb43c23          	sd	a1,-40(s0)
  
  pte = walk(p->pagetable, va, 0);
    800038ba:	4601                	li	a2,0
    800038bc:	68a8                	ld	a0,80(s1)
    800038be:	865fd0ef          	jal	80001122 <walk>
  if(pte == 0 || (*pte & PTE_V) == 0)
    800038c2:	cd11                	beqz	a0,800038de <sys_physaddr+0x58>
    800038c4:	611c                	ld	a5,0(a0)
    800038c6:	0017f713          	andi	a4,a5,1
    return -1;
    800038ca:	557d                	li	a0,-1
  if(pte == 0 || (*pte & PTE_V) == 0)
    800038cc:	c701                	beqz	a4,800038d4 <sys_physaddr+0x4e>
  
  pa = PTE2PA(*pte);
    800038ce:	078a                	slli	a5,a5,0x2
  // Return page number (physical address divided by page size)
  return pa / PGSIZE;
    800038d0:	00c7d513          	srli	a0,a5,0xc
}
    800038d4:	70a2                	ld	ra,40(sp)
    800038d6:	7402                	ld	s0,32(sp)
    800038d8:	64e2                	ld	s1,24(sp)
    800038da:	6145                	addi	sp,sp,48
    800038dc:	8082                	ret
    return -1;
    800038de:	557d                	li	a0,-1
    800038e0:	bfd5                	j	800038d4 <sys_physaddr+0x4e>

00000000800038e2 <sys_get_pid>:

// Get PID from current process's namespace
uint64
sys_get_pid(void)
{
    800038e2:	1141                	addi	sp,sp,-16
    800038e4:	e406                	sd	ra,8(sp)
    800038e6:	e022                	sd	s0,0(sp)
    800038e8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800038ea:	c7cfe0ef          	jal	80001d66 <myproc>
  
  if(p->pid_ns == 0)
    800038ee:	18853503          	ld	a0,392(a0)
    800038f2:	c519                	beqz	a0,80003900 <sys_get_pid+0x1e>
    return -1;
  
  return pid_namespace_get_pid(p->pid_ns);
    800038f4:	d14fe0ef          	jal	80001e08 <pid_namespace_get_pid>
}
    800038f8:	60a2                	ld	ra,8(sp)
    800038fa:	6402                	ld	s0,0(sp)
    800038fc:	0141                	addi	sp,sp,16
    800038fe:	8082                	ret
    return -1;
    80003900:	557d                	li	a0,-1
    80003902:	bfdd                	j	800038f8 <sys_get_pid+0x16>

0000000080003904 <sys_get_pid_namespace>:

// Get the next PID that will be assigned in the namespace
uint64
sys_get_pid_namespace(void)
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000390e:	c58fe0ef          	jal	80001d66 <myproc>
    80003912:	84aa                	mv	s1,a0
  
  if(p->pid_ns == 0)
    80003914:	18853503          	ld	a0,392(a0)
    80003918:	c105                	beqz	a0,80003938 <sys_get_pid_namespace+0x34>
    return -1;
  
  acquire(&p->pid_ns->lock);
    8000391a:	0521                	addi	a0,a0,8
    8000391c:	cbefd0ef          	jal	80000dda <acquire>
  int next_pid = p->pid_ns->next_pid;
    80003920:	1884b503          	ld	a0,392(s1)
    80003924:	4144                	lw	s1,4(a0)
  release(&p->pid_ns->lock);
    80003926:	0521                	addi	a0,a0,8
    80003928:	d4afd0ef          	jal	80000e72 <release>
  
  return next_pid;
    8000392c:	8526                	mv	a0,s1
}
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6105                	addi	sp,sp,32
    80003936:	8082                	ret
    return -1;
    80003938:	557d                	li	a0,-1
    8000393a:	bfd5                	j	8000392e <sys_get_pid_namespace+0x2a>

000000008000393c <sys_set_pid_namespace>:

// Set a new PID namespace (for creating new namespace)
uint64
sys_set_pid_namespace(void)
{
    8000393c:	1101                	addi	sp,sp,-32
    8000393e:	ec06                	sd	ra,24(sp)
    80003940:	e822                	sd	s0,16(sp)
    80003942:	e04a                	sd	s2,0(sp)
    80003944:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003946:	c20fe0ef          	jal	80001d66 <myproc>
    8000394a:	892a                	mv	s2,a0
  
  // Create a new namespace
  struct pid_namespace *new_ns = pid_namespace_alloc();
    8000394c:	c8afe0ef          	jal	80001dd6 <pid_namespace_alloc>
  if(new_ns == 0)
    80003950:	c10d                	beqz	a0,80003972 <sys_set_pid_namespace+0x36>
    80003952:	e426                	sd	s1,8(sp)
    80003954:	84aa                	mv	s1,a0
    return -1;
  
  // Release old namespace and set new one
  if(p->pid_ns)
    80003956:	18893503          	ld	a0,392(s2)
    8000395a:	c119                	beqz	a0,80003960 <sys_set_pid_namespace+0x24>
    pid_namespace_put(p->pid_ns);
    8000395c:	d20fe0ef          	jal	80001e7c <pid_namespace_put>
  
  p->pid_ns = new_ns;
    80003960:	18993423          	sd	s1,392(s2)
  
  return 0;
    80003964:	4501                	li	a0,0
    80003966:	64a2                	ld	s1,8(sp)
}
    80003968:	60e2                	ld	ra,24(sp)
    8000396a:	6442                	ld	s0,16(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret
    return -1;
    80003972:	557d                	li	a0,-1
    80003974:	bfd5                	j	80003968 <sys_set_pid_namespace+0x2c>

0000000080003976 <sys_getHostname>:

// Get hostname from UTS namespace
uint64
sys_getHostname(void)
{
    80003976:	7179                	addi	sp,sp,-48
    80003978:	f406                	sd	ra,40(sp)
    8000397a:	f022                	sd	s0,32(sp)
    8000397c:	ec26                	sd	s1,24(sp)
    8000397e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003980:	be6fe0ef          	jal	80001d66 <myproc>
    80003984:	84aa                	mv	s1,a0
  uint64 addr;
  int len;
  
  argaddr(0, &addr);
    80003986:	fd840593          	addi	a1,s0,-40
    8000398a:	4501                	li	a0,0
    8000398c:	bc3ff0ef          	jal	8000354e <argaddr>
  argint(1, &len);
    80003990:	fd440593          	addi	a1,s0,-44
    80003994:	4505                	li	a0,1
    80003996:	b9dff0ef          	jal	80003532 <argint>
  
  if(p->uts_ns == 0)
    8000399a:	1984b503          	ld	a0,408(s1)
    8000399e:	c535                	beqz	a0,80003a0a <sys_getHostname+0x94>
    return -1;
  
  acquire(&p->uts_ns->lock);
    800039a0:	04850513          	addi	a0,a0,72
    800039a4:	c36fd0ef          	jal	80000dda <acquire>
  int hostname_len = strlen(p->uts_ns->hostname);
    800039a8:	1984b503          	ld	a0,408(s1)
    800039ac:	0511                	addi	a0,a0,4
    800039ae:	e70fd0ef          	jal	8000101e <strlen>
  if(len < hostname_len + 1) {
    800039b2:	fd442783          	lw	a5,-44(s0)
    800039b6:	02f55a63          	bge	a0,a5,800039ea <sys_getHostname+0x74>
    release(&p->uts_ns->lock);
    return -1;
  }
  
  if(copyout(p->pagetable, addr, p->uts_ns->hostname, hostname_len + 1) < 0) {
    800039ba:	1984b603          	ld	a2,408(s1)
    800039be:	0015069b          	addiw	a3,a0,1
    800039c2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800039c4:	fd843583          	ld	a1,-40(s0)
    800039c8:	68a8                	ld	a0,80(s1)
    800039ca:	f7bfd0ef          	jal	80001944 <copyout>
    800039ce:	02054663          	bltz	a0,800039fa <sys_getHostname+0x84>
    release(&p->uts_ns->lock);
    return -1;
  }
  release(&p->uts_ns->lock);
    800039d2:	1984b503          	ld	a0,408(s1)
    800039d6:	04850513          	addi	a0,a0,72
    800039da:	c98fd0ef          	jal	80000e72 <release>
  
  return 0;
    800039de:	4501                	li	a0,0
}
    800039e0:	70a2                	ld	ra,40(sp)
    800039e2:	7402                	ld	s0,32(sp)
    800039e4:	64e2                	ld	s1,24(sp)
    800039e6:	6145                	addi	sp,sp,48
    800039e8:	8082                	ret
    release(&p->uts_ns->lock);
    800039ea:	1984b503          	ld	a0,408(s1)
    800039ee:	04850513          	addi	a0,a0,72
    800039f2:	c80fd0ef          	jal	80000e72 <release>
    return -1;
    800039f6:	557d                	li	a0,-1
    800039f8:	b7e5                	j	800039e0 <sys_getHostname+0x6a>
    release(&p->uts_ns->lock);
    800039fa:	1984b503          	ld	a0,408(s1)
    800039fe:	04850513          	addi	a0,a0,72
    80003a02:	c70fd0ef          	jal	80000e72 <release>
    return -1;
    80003a06:	557d                	li	a0,-1
    80003a08:	bfe1                	j	800039e0 <sys_getHostname+0x6a>
    return -1;
    80003a0a:	557d                	li	a0,-1
    80003a0c:	bfd1                	j	800039e0 <sys_getHostname+0x6a>

0000000080003a0e <sys_setHostname>:

// Set hostname in UTS namespace
uint64
sys_setHostname(void)
{
    80003a0e:	7159                	addi	sp,sp,-112
    80003a10:	f486                	sd	ra,104(sp)
    80003a12:	f0a2                	sd	s0,96(sp)
    80003a14:	eca6                	sd	s1,88(sp)
    80003a16:	1880                	addi	s0,sp,112
  struct proc *p = myproc();
    80003a18:	b4efe0ef          	jal	80001d66 <myproc>
    80003a1c:	84aa                	mv	s1,a0
  uint64 addr;
  int len;
  char hostname[HOSTNAME_LEN];
  
  argaddr(0, &addr);
    80003a1e:	fd840593          	addi	a1,s0,-40
    80003a22:	4501                	li	a0,0
    80003a24:	b2bff0ef          	jal	8000354e <argaddr>
  argint(1, &len);
    80003a28:	fd440593          	addi	a1,s0,-44
    80003a2c:	4505                	li	a0,1
    80003a2e:	b05ff0ef          	jal	80003532 <argint>
  
  if(p->uts_ns == 0)
    80003a32:	1984b783          	ld	a5,408(s1)
    80003a36:	c7b5                	beqz	a5,80003aa2 <sys_setHostname+0x94>
    return -1;
  
  if(len <= 0 || len >= HOSTNAME_LEN)
    80003a38:	fd442683          	lw	a3,-44(s0)
    80003a3c:	fff6871b          	addiw	a4,a3,-1
    80003a40:	03e00793          	li	a5,62
    return -1;
    80003a44:	557d                	li	a0,-1
  if(len <= 0 || len >= HOSTNAME_LEN)
    80003a46:	04e7e963          	bltu	a5,a4,80003a98 <sys_setHostname+0x8a>
  
  if(copyin(p->pagetable, hostname, addr, len) < 0)
    80003a4a:	fd843603          	ld	a2,-40(s0)
    80003a4e:	f9040593          	addi	a1,s0,-112
    80003a52:	68a8                	ld	a0,80(s1)
    80003a54:	806fe0ef          	jal	80001a5a <copyin>
    80003a58:	87aa                	mv	a5,a0
    return -1;
    80003a5a:	557d                	li	a0,-1
  if(copyin(p->pagetable, hostname, addr, len) < 0)
    80003a5c:	0207ce63          	bltz	a5,80003a98 <sys_setHostname+0x8a>
  
  hostname[len] = '\0';
    80003a60:	fd442783          	lw	a5,-44(s0)
    80003a64:	1781                	addi	a5,a5,-32
    80003a66:	97a2                	add	a5,a5,s0
    80003a68:	fa078823          	sb	zero,-80(a5)
  
  acquire(&p->uts_ns->lock);
    80003a6c:	1984b503          	ld	a0,408(s1)
    80003a70:	04850513          	addi	a0,a0,72
    80003a74:	b66fd0ef          	jal	80000dda <acquire>
  safestrcpy(p->uts_ns->hostname, hostname, HOSTNAME_LEN);
    80003a78:	1984b503          	ld	a0,408(s1)
    80003a7c:	04000613          	li	a2,64
    80003a80:	f9040593          	addi	a1,s0,-112
    80003a84:	0511                	addi	a0,a0,4
    80003a86:	d66fd0ef          	jal	80000fec <safestrcpy>
  release(&p->uts_ns->lock);
    80003a8a:	1984b503          	ld	a0,408(s1)
    80003a8e:	04850513          	addi	a0,a0,72
    80003a92:	be0fd0ef          	jal	80000e72 <release>
  
  return 0;
    80003a96:	4501                	li	a0,0
}
    80003a98:	70a6                	ld	ra,104(sp)
    80003a9a:	7406                	ld	s0,96(sp)
    80003a9c:	64e6                	ld	s1,88(sp)
    80003a9e:	6165                	addi	sp,sp,112
    80003aa0:	8082                	ret
    return -1;
    80003aa2:	557d                	li	a0,-1
    80003aa4:	bfd5                	j	80003a98 <sys_setHostname+0x8a>

0000000080003aa6 <sys_unshare>:

// Unshare creates new namespaces based on flags
uint64
sys_unshare(void)
{
    80003aa6:	7179                	addi	sp,sp,-48
    80003aa8:	f406                	sd	ra,40(sp)
    80003aaa:	f022                	sd	s0,32(sp)
    80003aac:	ec26                	sd	s1,24(sp)
    80003aae:	e84a                	sd	s2,16(sp)
    80003ab0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003ab2:	ab4fe0ef          	jal	80001d66 <myproc>
    80003ab6:	84aa                	mv	s1,a0
  int flags;
  
  argint(0, &flags);
    80003ab8:	fdc40593          	addi	a1,s0,-36
    80003abc:	4501                	li	a0,0
    80003abe:	a75ff0ef          	jal	80003532 <argint>
  
  if(flags & CLONE_NEWPID) {
    80003ac2:	fdc42783          	lw	a5,-36(s0)
    80003ac6:	02279713          	slli	a4,a5,0x22
    80003aca:	02074b63          	bltz	a4,80003b00 <sys_unshare+0x5a>
      return -1;
    pid_namespace_put(p->pid_ns);
    p->pid_ns = new_ns;
  }
  
  if(flags & CLONE_NEWUTS) {
    80003ace:	fdc42783          	lw	a5,-36(s0)
    80003ad2:	02579713          	slli	a4,a5,0x25
    80003ad6:	04074063          	bltz	a4,80003b16 <sys_unshare+0x70>
      return -1;
    uts_namespace_put(p->uts_ns);
    p->uts_ns = new_ns;
  }
  
  if(flags & CLONE_NEWIPC) {
    80003ada:	fdc42783          	lw	a5,-36(s0)
    80003ade:	02479713          	slli	a4,a5,0x24
    80003ae2:	04074563          	bltz	a4,80003b2c <sys_unshare+0x86>
      return -1;
    ipc_namespace_put(p->ipc_ns);
    p->ipc_ns = new_ns;
  }
  
  if(flags & CLONE_NEWNS) {
    80003ae6:	fdc42783          	lw	a5,-36(s0)
      return -1;
    mount_namespace_put(p->mnt_ns);
    p->mnt_ns = new_ns;
  }
  
  return 0;
    80003aea:	4501                	li	a0,0
  if(flags & CLONE_NEWNS) {
    80003aec:	02e79713          	slli	a4,a5,0x2e
    80003af0:	04074963          	bltz	a4,80003b42 <sys_unshare+0x9c>
}
    80003af4:	70a2                	ld	ra,40(sp)
    80003af6:	7402                	ld	s0,32(sp)
    80003af8:	64e2                	ld	s1,24(sp)
    80003afa:	6942                	ld	s2,16(sp)
    80003afc:	6145                	addi	sp,sp,48
    80003afe:	8082                	ret
    struct pid_namespace *new_ns = pid_namespace_alloc();
    80003b00:	ad6fe0ef          	jal	80001dd6 <pid_namespace_alloc>
    80003b04:	892a                	mv	s2,a0
    if(new_ns == 0)
    80003b06:	c931                	beqz	a0,80003b5a <sys_unshare+0xb4>
    pid_namespace_put(p->pid_ns);
    80003b08:	1884b503          	ld	a0,392(s1)
    80003b0c:	b70fe0ef          	jal	80001e7c <pid_namespace_put>
    p->pid_ns = new_ns;
    80003b10:	1924b423          	sd	s2,392(s1)
    80003b14:	bf6d                	j	80003ace <sys_unshare+0x28>
    struct uts_namespace *new_ns = uts_namespace_alloc();
    80003b16:	c6afe0ef          	jal	80001f80 <uts_namespace_alloc>
    80003b1a:	892a                	mv	s2,a0
    if(new_ns == 0)
    80003b1c:	c129                	beqz	a0,80003b5e <sys_unshare+0xb8>
    uts_namespace_put(p->uts_ns);
    80003b1e:	1984b503          	ld	a0,408(s1)
    80003b22:	cd0fe0ef          	jal	80001ff2 <uts_namespace_put>
    p->uts_ns = new_ns;
    80003b26:	1924bc23          	sd	s2,408(s1)
    80003b2a:	bf45                	j	80003ada <sys_unshare+0x34>
    struct ipc_namespace *new_ns = ipc_namespace_alloc();
    80003b2c:	d0efe0ef          	jal	8000203a <ipc_namespace_alloc>
    80003b30:	892a                	mv	s2,a0
    if(new_ns == 0)
    80003b32:	c905                	beqz	a0,80003b62 <sys_unshare+0xbc>
    ipc_namespace_put(p->ipc_ns);
    80003b34:	1a04b503          	ld	a0,416(s1)
    80003b38:	d66fe0ef          	jal	8000209e <ipc_namespace_put>
    p->ipc_ns = new_ns;
    80003b3c:	1b24b023          	sd	s2,416(s1)
    80003b40:	b75d                	j	80003ae6 <sys_unshare+0x40>
    struct mount_namespace *new_ns = mount_namespace_alloc(0);
    80003b42:	b82fe0ef          	jal	80001ec4 <mount_namespace_alloc>
    80003b46:	892a                	mv	s2,a0
    if(new_ns == 0)
    80003b48:	cd19                	beqz	a0,80003b66 <sys_unshare+0xc0>
    mount_namespace_put(p->mnt_ns);
    80003b4a:	1904b503          	ld	a0,400(s1)
    80003b4e:	be4fe0ef          	jal	80001f32 <mount_namespace_put>
    p->mnt_ns = new_ns;
    80003b52:	1924b823          	sd	s2,400(s1)
  return 0;
    80003b56:	4501                	li	a0,0
    80003b58:	bf71                	j	80003af4 <sys_unshare+0x4e>
      return -1;
    80003b5a:	557d                	li	a0,-1
    80003b5c:	bf61                	j	80003af4 <sys_unshare+0x4e>
      return -1;
    80003b5e:	557d                	li	a0,-1
    80003b60:	bf51                	j	80003af4 <sys_unshare+0x4e>
      return -1;
    80003b62:	557d                	li	a0,-1
    80003b64:	bf41                	j	80003af4 <sys_unshare+0x4e>
      return -1;
    80003b66:	557d                	li	a0,-1
    80003b68:	b771                	j	80003af4 <sys_unshare+0x4e>

0000000080003b6a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003b6a:	7179                	addi	sp,sp,-48
    80003b6c:	f406                	sd	ra,40(sp)
    80003b6e:	f022                	sd	s0,32(sp)
    80003b70:	ec26                	sd	s1,24(sp)
    80003b72:	e84a                	sd	s2,16(sp)
    80003b74:	e44e                	sd	s3,8(sp)
    80003b76:	e052                	sd	s4,0(sp)
    80003b78:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003b7a:	00005597          	auipc	a1,0x5
    80003b7e:	91658593          	addi	a1,a1,-1770 # 80008490 <etext+0x490>
    80003b82:	00034517          	auipc	a0,0x34
    80003b86:	fd650513          	addi	a0,a0,-42 # 80037b58 <bcache>
    80003b8a:	9d0fd0ef          	jal	80000d5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003b8e:	0003c797          	auipc	a5,0x3c
    80003b92:	fca78793          	addi	a5,a5,-54 # 8003fb58 <bcache+0x8000>
    80003b96:	0003c717          	auipc	a4,0x3c
    80003b9a:	22a70713          	addi	a4,a4,554 # 8003fdc0 <bcache+0x8268>
    80003b9e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003ba2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003ba6:	00034497          	auipc	s1,0x34
    80003baa:	fca48493          	addi	s1,s1,-54 # 80037b70 <bcache+0x18>
    b->next = bcache.head.next;
    80003bae:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003bb0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003bb2:	00005a17          	auipc	s4,0x5
    80003bb6:	8e6a0a13          	addi	s4,s4,-1818 # 80008498 <etext+0x498>
    b->next = bcache.head.next;
    80003bba:	2b893783          	ld	a5,696(s2)
    80003bbe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003bc0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003bc4:	85d2                	mv	a1,s4
    80003bc6:	01048513          	addi	a0,s1,16
    80003bca:	322010ef          	jal	80004eec <initsleeplock>
    bcache.head.next->prev = b;
    80003bce:	2b893783          	ld	a5,696(s2)
    80003bd2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003bd4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003bd8:	45848493          	addi	s1,s1,1112
    80003bdc:	fd349fe3          	bne	s1,s3,80003bba <binit+0x50>
  }
}
    80003be0:	70a2                	ld	ra,40(sp)
    80003be2:	7402                	ld	s0,32(sp)
    80003be4:	64e2                	ld	s1,24(sp)
    80003be6:	6942                	ld	s2,16(sp)
    80003be8:	69a2                	ld	s3,8(sp)
    80003bea:	6a02                	ld	s4,0(sp)
    80003bec:	6145                	addi	sp,sp,48
    80003bee:	8082                	ret

0000000080003bf0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003bf0:	7179                	addi	sp,sp,-48
    80003bf2:	f406                	sd	ra,40(sp)
    80003bf4:	f022                	sd	s0,32(sp)
    80003bf6:	ec26                	sd	s1,24(sp)
    80003bf8:	e84a                	sd	s2,16(sp)
    80003bfa:	e44e                	sd	s3,8(sp)
    80003bfc:	1800                	addi	s0,sp,48
    80003bfe:	892a                	mv	s2,a0
    80003c00:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003c02:	00034517          	auipc	a0,0x34
    80003c06:	f5650513          	addi	a0,a0,-170 # 80037b58 <bcache>
    80003c0a:	9d0fd0ef          	jal	80000dda <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003c0e:	0003c497          	auipc	s1,0x3c
    80003c12:	2024b483          	ld	s1,514(s1) # 8003fe10 <bcache+0x82b8>
    80003c16:	0003c797          	auipc	a5,0x3c
    80003c1a:	1aa78793          	addi	a5,a5,426 # 8003fdc0 <bcache+0x8268>
    80003c1e:	02f48b63          	beq	s1,a5,80003c54 <bread+0x64>
    80003c22:	873e                	mv	a4,a5
    80003c24:	a021                	j	80003c2c <bread+0x3c>
    80003c26:	68a4                	ld	s1,80(s1)
    80003c28:	02e48663          	beq	s1,a4,80003c54 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003c2c:	449c                	lw	a5,8(s1)
    80003c2e:	ff279ce3          	bne	a5,s2,80003c26 <bread+0x36>
    80003c32:	44dc                	lw	a5,12(s1)
    80003c34:	ff3799e3          	bne	a5,s3,80003c26 <bread+0x36>
      b->refcnt++;
    80003c38:	40bc                	lw	a5,64(s1)
    80003c3a:	2785                	addiw	a5,a5,1
    80003c3c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003c3e:	00034517          	auipc	a0,0x34
    80003c42:	f1a50513          	addi	a0,a0,-230 # 80037b58 <bcache>
    80003c46:	a2cfd0ef          	jal	80000e72 <release>
      acquiresleep(&b->lock);
    80003c4a:	01048513          	addi	a0,s1,16
    80003c4e:	2d4010ef          	jal	80004f22 <acquiresleep>
      return b;
    80003c52:	a889                	j	80003ca4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003c54:	0003c497          	auipc	s1,0x3c
    80003c58:	1b44b483          	ld	s1,436(s1) # 8003fe08 <bcache+0x82b0>
    80003c5c:	0003c797          	auipc	a5,0x3c
    80003c60:	16478793          	addi	a5,a5,356 # 8003fdc0 <bcache+0x8268>
    80003c64:	00f48863          	beq	s1,a5,80003c74 <bread+0x84>
    80003c68:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003c6a:	40bc                	lw	a5,64(s1)
    80003c6c:	cb91                	beqz	a5,80003c80 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003c6e:	64a4                	ld	s1,72(s1)
    80003c70:	fee49de3          	bne	s1,a4,80003c6a <bread+0x7a>
  panic("bget: no buffers");
    80003c74:	00005517          	auipc	a0,0x5
    80003c78:	82c50513          	addi	a0,a0,-2004 # 800084a0 <etext+0x4a0>
    80003c7c:	b65fc0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80003c80:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003c84:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003c88:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003c8c:	4785                	li	a5,1
    80003c8e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003c90:	00034517          	auipc	a0,0x34
    80003c94:	ec850513          	addi	a0,a0,-312 # 80037b58 <bcache>
    80003c98:	9dafd0ef          	jal	80000e72 <release>
      acquiresleep(&b->lock);
    80003c9c:	01048513          	addi	a0,s1,16
    80003ca0:	282010ef          	jal	80004f22 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003ca4:	409c                	lw	a5,0(s1)
    80003ca6:	cb89                	beqz	a5,80003cb8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003ca8:	8526                	mv	a0,s1
    80003caa:	70a2                	ld	ra,40(sp)
    80003cac:	7402                	ld	s0,32(sp)
    80003cae:	64e2                	ld	s1,24(sp)
    80003cb0:	6942                	ld	s2,16(sp)
    80003cb2:	69a2                	ld	s3,8(sp)
    80003cb4:	6145                	addi	sp,sp,48
    80003cb6:	8082                	ret
    virtio_disk_rw(b, 0);
    80003cb8:	4581                	li	a1,0
    80003cba:	8526                	mv	a0,s1
    80003cbc:	2d5020ef          	jal	80006790 <virtio_disk_rw>
    b->valid = 1;
    80003cc0:	4785                	li	a5,1
    80003cc2:	c09c                	sw	a5,0(s1)
  return b;
    80003cc4:	b7d5                	j	80003ca8 <bread+0xb8>

0000000080003cc6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003cc6:	1101                	addi	sp,sp,-32
    80003cc8:	ec06                	sd	ra,24(sp)
    80003cca:	e822                	sd	s0,16(sp)
    80003ccc:	e426                	sd	s1,8(sp)
    80003cce:	1000                	addi	s0,sp,32
    80003cd0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003cd2:	0541                	addi	a0,a0,16
    80003cd4:	2cc010ef          	jal	80004fa0 <holdingsleep>
    80003cd8:	c911                	beqz	a0,80003cec <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003cda:	4585                	li	a1,1
    80003cdc:	8526                	mv	a0,s1
    80003cde:	2b3020ef          	jal	80006790 <virtio_disk_rw>
}
    80003ce2:	60e2                	ld	ra,24(sp)
    80003ce4:	6442                	ld	s0,16(sp)
    80003ce6:	64a2                	ld	s1,8(sp)
    80003ce8:	6105                	addi	sp,sp,32
    80003cea:	8082                	ret
    panic("bwrite");
    80003cec:	00004517          	auipc	a0,0x4
    80003cf0:	7cc50513          	addi	a0,a0,1996 # 800084b8 <etext+0x4b8>
    80003cf4:	aedfc0ef          	jal	800007e0 <panic>

0000000080003cf8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003cf8:	1101                	addi	sp,sp,-32
    80003cfa:	ec06                	sd	ra,24(sp)
    80003cfc:	e822                	sd	s0,16(sp)
    80003cfe:	e426                	sd	s1,8(sp)
    80003d00:	e04a                	sd	s2,0(sp)
    80003d02:	1000                	addi	s0,sp,32
    80003d04:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003d06:	01050913          	addi	s2,a0,16
    80003d0a:	854a                	mv	a0,s2
    80003d0c:	294010ef          	jal	80004fa0 <holdingsleep>
    80003d10:	c135                	beqz	a0,80003d74 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80003d12:	854a                	mv	a0,s2
    80003d14:	254010ef          	jal	80004f68 <releasesleep>

  acquire(&bcache.lock);
    80003d18:	00034517          	auipc	a0,0x34
    80003d1c:	e4050513          	addi	a0,a0,-448 # 80037b58 <bcache>
    80003d20:	8bafd0ef          	jal	80000dda <acquire>
  b->refcnt--;
    80003d24:	40bc                	lw	a5,64(s1)
    80003d26:	37fd                	addiw	a5,a5,-1
    80003d28:	0007871b          	sext.w	a4,a5
    80003d2c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003d2e:	e71d                	bnez	a4,80003d5c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003d30:	68b8                	ld	a4,80(s1)
    80003d32:	64bc                	ld	a5,72(s1)
    80003d34:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003d36:	68b8                	ld	a4,80(s1)
    80003d38:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003d3a:	0003c797          	auipc	a5,0x3c
    80003d3e:	e1e78793          	addi	a5,a5,-482 # 8003fb58 <bcache+0x8000>
    80003d42:	2b87b703          	ld	a4,696(a5)
    80003d46:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003d48:	0003c717          	auipc	a4,0x3c
    80003d4c:	07870713          	addi	a4,a4,120 # 8003fdc0 <bcache+0x8268>
    80003d50:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003d52:	2b87b703          	ld	a4,696(a5)
    80003d56:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003d58:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003d5c:	00034517          	auipc	a0,0x34
    80003d60:	dfc50513          	addi	a0,a0,-516 # 80037b58 <bcache>
    80003d64:	90efd0ef          	jal	80000e72 <release>
}
    80003d68:	60e2                	ld	ra,24(sp)
    80003d6a:	6442                	ld	s0,16(sp)
    80003d6c:	64a2                	ld	s1,8(sp)
    80003d6e:	6902                	ld	s2,0(sp)
    80003d70:	6105                	addi	sp,sp,32
    80003d72:	8082                	ret
    panic("brelse");
    80003d74:	00004517          	auipc	a0,0x4
    80003d78:	74c50513          	addi	a0,a0,1868 # 800084c0 <etext+0x4c0>
    80003d7c:	a65fc0ef          	jal	800007e0 <panic>

0000000080003d80 <bpin>:

void
bpin(struct buf *b) {
    80003d80:	1101                	addi	sp,sp,-32
    80003d82:	ec06                	sd	ra,24(sp)
    80003d84:	e822                	sd	s0,16(sp)
    80003d86:	e426                	sd	s1,8(sp)
    80003d88:	1000                	addi	s0,sp,32
    80003d8a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003d8c:	00034517          	auipc	a0,0x34
    80003d90:	dcc50513          	addi	a0,a0,-564 # 80037b58 <bcache>
    80003d94:	846fd0ef          	jal	80000dda <acquire>
  b->refcnt++;
    80003d98:	40bc                	lw	a5,64(s1)
    80003d9a:	2785                	addiw	a5,a5,1
    80003d9c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d9e:	00034517          	auipc	a0,0x34
    80003da2:	dba50513          	addi	a0,a0,-582 # 80037b58 <bcache>
    80003da6:	8ccfd0ef          	jal	80000e72 <release>
}
    80003daa:	60e2                	ld	ra,24(sp)
    80003dac:	6442                	ld	s0,16(sp)
    80003dae:	64a2                	ld	s1,8(sp)
    80003db0:	6105                	addi	sp,sp,32
    80003db2:	8082                	ret

0000000080003db4 <bunpin>:

void
bunpin(struct buf *b) {
    80003db4:	1101                	addi	sp,sp,-32
    80003db6:	ec06                	sd	ra,24(sp)
    80003db8:	e822                	sd	s0,16(sp)
    80003dba:	e426                	sd	s1,8(sp)
    80003dbc:	1000                	addi	s0,sp,32
    80003dbe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003dc0:	00034517          	auipc	a0,0x34
    80003dc4:	d9850513          	addi	a0,a0,-616 # 80037b58 <bcache>
    80003dc8:	812fd0ef          	jal	80000dda <acquire>
  b->refcnt--;
    80003dcc:	40bc                	lw	a5,64(s1)
    80003dce:	37fd                	addiw	a5,a5,-1
    80003dd0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003dd2:	00034517          	auipc	a0,0x34
    80003dd6:	d8650513          	addi	a0,a0,-634 # 80037b58 <bcache>
    80003dda:	898fd0ef          	jal	80000e72 <release>
}
    80003dde:	60e2                	ld	ra,24(sp)
    80003de0:	6442                	ld	s0,16(sp)
    80003de2:	64a2                	ld	s1,8(sp)
    80003de4:	6105                	addi	sp,sp,32
    80003de6:	8082                	ret

0000000080003de8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003de8:	1101                	addi	sp,sp,-32
    80003dea:	ec06                	sd	ra,24(sp)
    80003dec:	e822                	sd	s0,16(sp)
    80003dee:	e426                	sd	s1,8(sp)
    80003df0:	e04a                	sd	s2,0(sp)
    80003df2:	1000                	addi	s0,sp,32
    80003df4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003df6:	00d5d59b          	srliw	a1,a1,0xd
    80003dfa:	0003c797          	auipc	a5,0x3c
    80003dfe:	43a7a783          	lw	a5,1082(a5) # 80040234 <sb+0x1c>
    80003e02:	9dbd                	addw	a1,a1,a5
    80003e04:	dedff0ef          	jal	80003bf0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003e08:	0074f713          	andi	a4,s1,7
    80003e0c:	4785                	li	a5,1
    80003e0e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003e12:	14ce                	slli	s1,s1,0x33
    80003e14:	90d9                	srli	s1,s1,0x36
    80003e16:	00950733          	add	a4,a0,s1
    80003e1a:	05874703          	lbu	a4,88(a4)
    80003e1e:	00e7f6b3          	and	a3,a5,a4
    80003e22:	c29d                	beqz	a3,80003e48 <bfree+0x60>
    80003e24:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003e26:	94aa                	add	s1,s1,a0
    80003e28:	fff7c793          	not	a5,a5
    80003e2c:	8f7d                	and	a4,a4,a5
    80003e2e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003e32:	7f9000ef          	jal	80004e2a <log_write>
  brelse(bp);
    80003e36:	854a                	mv	a0,s2
    80003e38:	ec1ff0ef          	jal	80003cf8 <brelse>
}
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6902                	ld	s2,0(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret
    panic("freeing free block");
    80003e48:	00004517          	auipc	a0,0x4
    80003e4c:	68050513          	addi	a0,a0,1664 # 800084c8 <etext+0x4c8>
    80003e50:	991fc0ef          	jal	800007e0 <panic>

0000000080003e54 <balloc>:
{
    80003e54:	711d                	addi	sp,sp,-96
    80003e56:	ec86                	sd	ra,88(sp)
    80003e58:	e8a2                	sd	s0,80(sp)
    80003e5a:	e4a6                	sd	s1,72(sp)
    80003e5c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003e5e:	0003c797          	auipc	a5,0x3c
    80003e62:	3be7a783          	lw	a5,958(a5) # 8004021c <sb+0x4>
    80003e66:	0e078f63          	beqz	a5,80003f64 <balloc+0x110>
    80003e6a:	e0ca                	sd	s2,64(sp)
    80003e6c:	fc4e                	sd	s3,56(sp)
    80003e6e:	f852                	sd	s4,48(sp)
    80003e70:	f456                	sd	s5,40(sp)
    80003e72:	f05a                	sd	s6,32(sp)
    80003e74:	ec5e                	sd	s7,24(sp)
    80003e76:	e862                	sd	s8,16(sp)
    80003e78:	e466                	sd	s9,8(sp)
    80003e7a:	8baa                	mv	s7,a0
    80003e7c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003e7e:	0003cb17          	auipc	s6,0x3c
    80003e82:	39ab0b13          	addi	s6,s6,922 # 80040218 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e86:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003e88:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e8a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003e8c:	6c89                	lui	s9,0x2
    80003e8e:	a0b5                	j	80003efa <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003e90:	97ca                	add	a5,a5,s2
    80003e92:	8e55                	or	a2,a2,a3
    80003e94:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003e98:	854a                	mv	a0,s2
    80003e9a:	791000ef          	jal	80004e2a <log_write>
        brelse(bp);
    80003e9e:	854a                	mv	a0,s2
    80003ea0:	e59ff0ef          	jal	80003cf8 <brelse>
  bp = bread(dev, bno);
    80003ea4:	85a6                	mv	a1,s1
    80003ea6:	855e                	mv	a0,s7
    80003ea8:	d49ff0ef          	jal	80003bf0 <bread>
    80003eac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003eae:	40000613          	li	a2,1024
    80003eb2:	4581                	li	a1,0
    80003eb4:	05850513          	addi	a0,a0,88
    80003eb8:	ff7fc0ef          	jal	80000eae <memset>
  log_write(bp);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	76d000ef          	jal	80004e2a <log_write>
  brelse(bp);
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	e35ff0ef          	jal	80003cf8 <brelse>
}
    80003ec8:	6906                	ld	s2,64(sp)
    80003eca:	79e2                	ld	s3,56(sp)
    80003ecc:	7a42                	ld	s4,48(sp)
    80003ece:	7aa2                	ld	s5,40(sp)
    80003ed0:	7b02                	ld	s6,32(sp)
    80003ed2:	6be2                	ld	s7,24(sp)
    80003ed4:	6c42                	ld	s8,16(sp)
    80003ed6:	6ca2                	ld	s9,8(sp)
}
    80003ed8:	8526                	mv	a0,s1
    80003eda:	60e6                	ld	ra,88(sp)
    80003edc:	6446                	ld	s0,80(sp)
    80003ede:	64a6                	ld	s1,72(sp)
    80003ee0:	6125                	addi	sp,sp,96
    80003ee2:	8082                	ret
    brelse(bp);
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	e13ff0ef          	jal	80003cf8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003eea:	015c87bb          	addw	a5,s9,s5
    80003eee:	00078a9b          	sext.w	s5,a5
    80003ef2:	004b2703          	lw	a4,4(s6)
    80003ef6:	04eaff63          	bgeu	s5,a4,80003f54 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003efa:	41fad79b          	sraiw	a5,s5,0x1f
    80003efe:	0137d79b          	srliw	a5,a5,0x13
    80003f02:	015787bb          	addw	a5,a5,s5
    80003f06:	40d7d79b          	sraiw	a5,a5,0xd
    80003f0a:	01cb2583          	lw	a1,28(s6)
    80003f0e:	9dbd                	addw	a1,a1,a5
    80003f10:	855e                	mv	a0,s7
    80003f12:	cdfff0ef          	jal	80003bf0 <bread>
    80003f16:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003f18:	004b2503          	lw	a0,4(s6)
    80003f1c:	000a849b          	sext.w	s1,s5
    80003f20:	8762                	mv	a4,s8
    80003f22:	fca4f1e3          	bgeu	s1,a0,80003ee4 <balloc+0x90>
      m = 1 << (bi % 8);
    80003f26:	00777693          	andi	a3,a4,7
    80003f2a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003f2e:	41f7579b          	sraiw	a5,a4,0x1f
    80003f32:	01d7d79b          	srliw	a5,a5,0x1d
    80003f36:	9fb9                	addw	a5,a5,a4
    80003f38:	4037d79b          	sraiw	a5,a5,0x3
    80003f3c:	00f90633          	add	a2,s2,a5
    80003f40:	05864603          	lbu	a2,88(a2)
    80003f44:	00c6f5b3          	and	a1,a3,a2
    80003f48:	d5a1                	beqz	a1,80003e90 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003f4a:	2705                	addiw	a4,a4,1
    80003f4c:	2485                	addiw	s1,s1,1
    80003f4e:	fd471ae3          	bne	a4,s4,80003f22 <balloc+0xce>
    80003f52:	bf49                	j	80003ee4 <balloc+0x90>
    80003f54:	6906                	ld	s2,64(sp)
    80003f56:	79e2                	ld	s3,56(sp)
    80003f58:	7a42                	ld	s4,48(sp)
    80003f5a:	7aa2                	ld	s5,40(sp)
    80003f5c:	7b02                	ld	s6,32(sp)
    80003f5e:	6be2                	ld	s7,24(sp)
    80003f60:	6c42                	ld	s8,16(sp)
    80003f62:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003f64:	00004517          	auipc	a0,0x4
    80003f68:	57c50513          	addi	a0,a0,1404 # 800084e0 <etext+0x4e0>
    80003f6c:	d8efc0ef          	jal	800004fa <printf>
  return 0;
    80003f70:	4481                	li	s1,0
    80003f72:	b79d                	j	80003ed8 <balloc+0x84>

0000000080003f74 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003f74:	7179                	addi	sp,sp,-48
    80003f76:	f406                	sd	ra,40(sp)
    80003f78:	f022                	sd	s0,32(sp)
    80003f7a:	ec26                	sd	s1,24(sp)
    80003f7c:	e84a                	sd	s2,16(sp)
    80003f7e:	e44e                	sd	s3,8(sp)
    80003f80:	1800                	addi	s0,sp,48
    80003f82:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003f84:	47ad                	li	a5,11
    80003f86:	02b7e663          	bltu	a5,a1,80003fb2 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003f8a:	02059793          	slli	a5,a1,0x20
    80003f8e:	01e7d593          	srli	a1,a5,0x1e
    80003f92:	00b504b3          	add	s1,a0,a1
    80003f96:	0504a903          	lw	s2,80(s1)
    80003f9a:	06091a63          	bnez	s2,8000400e <bmap+0x9a>
      addr = balloc(ip->dev);
    80003f9e:	4108                	lw	a0,0(a0)
    80003fa0:	eb5ff0ef          	jal	80003e54 <balloc>
    80003fa4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003fa8:	06090363          	beqz	s2,8000400e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003fac:	0524a823          	sw	s2,80(s1)
    80003fb0:	a8b9                	j	8000400e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003fb2:	ff45849b          	addiw	s1,a1,-12
    80003fb6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003fba:	0ff00793          	li	a5,255
    80003fbe:	06e7ee63          	bltu	a5,a4,8000403a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003fc2:	08052903          	lw	s2,128(a0)
    80003fc6:	00091d63          	bnez	s2,80003fe0 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003fca:	4108                	lw	a0,0(a0)
    80003fcc:	e89ff0ef          	jal	80003e54 <balloc>
    80003fd0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003fd4:	02090d63          	beqz	s2,8000400e <bmap+0x9a>
    80003fd8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003fda:	0929a023          	sw	s2,128(s3)
    80003fde:	a011                	j	80003fe2 <bmap+0x6e>
    80003fe0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003fe2:	85ca                	mv	a1,s2
    80003fe4:	0009a503          	lw	a0,0(s3)
    80003fe8:	c09ff0ef          	jal	80003bf0 <bread>
    80003fec:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003fee:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003ff2:	02049713          	slli	a4,s1,0x20
    80003ff6:	01e75593          	srli	a1,a4,0x1e
    80003ffa:	00b784b3          	add	s1,a5,a1
    80003ffe:	0004a903          	lw	s2,0(s1)
    80004002:	00090e63          	beqz	s2,8000401e <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80004006:	8552                	mv	a0,s4
    80004008:	cf1ff0ef          	jal	80003cf8 <brelse>
    return addr;
    8000400c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000400e:	854a                	mv	a0,s2
    80004010:	70a2                	ld	ra,40(sp)
    80004012:	7402                	ld	s0,32(sp)
    80004014:	64e2                	ld	s1,24(sp)
    80004016:	6942                	ld	s2,16(sp)
    80004018:	69a2                	ld	s3,8(sp)
    8000401a:	6145                	addi	sp,sp,48
    8000401c:	8082                	ret
      addr = balloc(ip->dev);
    8000401e:	0009a503          	lw	a0,0(s3)
    80004022:	e33ff0ef          	jal	80003e54 <balloc>
    80004026:	0005091b          	sext.w	s2,a0
      if(addr){
    8000402a:	fc090ee3          	beqz	s2,80004006 <bmap+0x92>
        a[bn] = addr;
    8000402e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80004032:	8552                	mv	a0,s4
    80004034:	5f7000ef          	jal	80004e2a <log_write>
    80004038:	b7f9                	j	80004006 <bmap+0x92>
    8000403a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000403c:	00004517          	auipc	a0,0x4
    80004040:	4bc50513          	addi	a0,a0,1212 # 800084f8 <etext+0x4f8>
    80004044:	f9cfc0ef          	jal	800007e0 <panic>

0000000080004048 <iget>:
{
    80004048:	7179                	addi	sp,sp,-48
    8000404a:	f406                	sd	ra,40(sp)
    8000404c:	f022                	sd	s0,32(sp)
    8000404e:	ec26                	sd	s1,24(sp)
    80004050:	e84a                	sd	s2,16(sp)
    80004052:	e44e                	sd	s3,8(sp)
    80004054:	e052                	sd	s4,0(sp)
    80004056:	1800                	addi	s0,sp,48
    80004058:	89aa                	mv	s3,a0
    8000405a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000405c:	0003c517          	auipc	a0,0x3c
    80004060:	1dc50513          	addi	a0,a0,476 # 80040238 <itable>
    80004064:	d77fc0ef          	jal	80000dda <acquire>
  empty = 0;
    80004068:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000406a:	0003c497          	auipc	s1,0x3c
    8000406e:	1e648493          	addi	s1,s1,486 # 80040250 <itable+0x18>
    80004072:	0003e697          	auipc	a3,0x3e
    80004076:	c6e68693          	addi	a3,a3,-914 # 80041ce0 <log>
    8000407a:	a039                	j	80004088 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000407c:	02090963          	beqz	s2,800040ae <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004080:	08848493          	addi	s1,s1,136
    80004084:	02d48863          	beq	s1,a3,800040b4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004088:	449c                	lw	a5,8(s1)
    8000408a:	fef059e3          	blez	a5,8000407c <iget+0x34>
    8000408e:	4098                	lw	a4,0(s1)
    80004090:	ff3716e3          	bne	a4,s3,8000407c <iget+0x34>
    80004094:	40d8                	lw	a4,4(s1)
    80004096:	ff4713e3          	bne	a4,s4,8000407c <iget+0x34>
      ip->ref++;
    8000409a:	2785                	addiw	a5,a5,1
    8000409c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000409e:	0003c517          	auipc	a0,0x3c
    800040a2:	19a50513          	addi	a0,a0,410 # 80040238 <itable>
    800040a6:	dcdfc0ef          	jal	80000e72 <release>
      return ip;
    800040aa:	8926                	mv	s2,s1
    800040ac:	a02d                	j	800040d6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800040ae:	fbe9                	bnez	a5,80004080 <iget+0x38>
      empty = ip;
    800040b0:	8926                	mv	s2,s1
    800040b2:	b7f9                	j	80004080 <iget+0x38>
  if(empty == 0)
    800040b4:	02090a63          	beqz	s2,800040e8 <iget+0xa0>
  ip->dev = dev;
    800040b8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800040bc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800040c0:	4785                	li	a5,1
    800040c2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800040c6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800040ca:	0003c517          	auipc	a0,0x3c
    800040ce:	16e50513          	addi	a0,a0,366 # 80040238 <itable>
    800040d2:	da1fc0ef          	jal	80000e72 <release>
}
    800040d6:	854a                	mv	a0,s2
    800040d8:	70a2                	ld	ra,40(sp)
    800040da:	7402                	ld	s0,32(sp)
    800040dc:	64e2                	ld	s1,24(sp)
    800040de:	6942                	ld	s2,16(sp)
    800040e0:	69a2                	ld	s3,8(sp)
    800040e2:	6a02                	ld	s4,0(sp)
    800040e4:	6145                	addi	sp,sp,48
    800040e6:	8082                	ret
    panic("iget: no inodes");
    800040e8:	00004517          	auipc	a0,0x4
    800040ec:	42850513          	addi	a0,a0,1064 # 80008510 <etext+0x510>
    800040f0:	ef0fc0ef          	jal	800007e0 <panic>

00000000800040f4 <iinit>:
{
    800040f4:	7179                	addi	sp,sp,-48
    800040f6:	f406                	sd	ra,40(sp)
    800040f8:	f022                	sd	s0,32(sp)
    800040fa:	ec26                	sd	s1,24(sp)
    800040fc:	e84a                	sd	s2,16(sp)
    800040fe:	e44e                	sd	s3,8(sp)
    80004100:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004102:	00004597          	auipc	a1,0x4
    80004106:	41e58593          	addi	a1,a1,1054 # 80008520 <etext+0x520>
    8000410a:	0003c517          	auipc	a0,0x3c
    8000410e:	12e50513          	addi	a0,a0,302 # 80040238 <itable>
    80004112:	c49fc0ef          	jal	80000d5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80004116:	0003c497          	auipc	s1,0x3c
    8000411a:	14a48493          	addi	s1,s1,330 # 80040260 <itable+0x28>
    8000411e:	0003e997          	auipc	s3,0x3e
    80004122:	bd298993          	addi	s3,s3,-1070 # 80041cf0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004126:	00004917          	auipc	s2,0x4
    8000412a:	40290913          	addi	s2,s2,1026 # 80008528 <etext+0x528>
    8000412e:	85ca                	mv	a1,s2
    80004130:	8526                	mv	a0,s1
    80004132:	5bb000ef          	jal	80004eec <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004136:	08848493          	addi	s1,s1,136
    8000413a:	ff349ae3          	bne	s1,s3,8000412e <iinit+0x3a>
}
    8000413e:	70a2                	ld	ra,40(sp)
    80004140:	7402                	ld	s0,32(sp)
    80004142:	64e2                	ld	s1,24(sp)
    80004144:	6942                	ld	s2,16(sp)
    80004146:	69a2                	ld	s3,8(sp)
    80004148:	6145                	addi	sp,sp,48
    8000414a:	8082                	ret

000000008000414c <ialloc>:
{
    8000414c:	7139                	addi	sp,sp,-64
    8000414e:	fc06                	sd	ra,56(sp)
    80004150:	f822                	sd	s0,48(sp)
    80004152:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80004154:	0003c717          	auipc	a4,0x3c
    80004158:	0d072703          	lw	a4,208(a4) # 80040224 <sb+0xc>
    8000415c:	4785                	li	a5,1
    8000415e:	06e7f063          	bgeu	a5,a4,800041be <ialloc+0x72>
    80004162:	f426                	sd	s1,40(sp)
    80004164:	f04a                	sd	s2,32(sp)
    80004166:	ec4e                	sd	s3,24(sp)
    80004168:	e852                	sd	s4,16(sp)
    8000416a:	e456                	sd	s5,8(sp)
    8000416c:	e05a                	sd	s6,0(sp)
    8000416e:	8aaa                	mv	s5,a0
    80004170:	8b2e                	mv	s6,a1
    80004172:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004174:	0003ca17          	auipc	s4,0x3c
    80004178:	0a4a0a13          	addi	s4,s4,164 # 80040218 <sb>
    8000417c:	00495593          	srli	a1,s2,0x4
    80004180:	018a2783          	lw	a5,24(s4)
    80004184:	9dbd                	addw	a1,a1,a5
    80004186:	8556                	mv	a0,s5
    80004188:	a69ff0ef          	jal	80003bf0 <bread>
    8000418c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000418e:	05850993          	addi	s3,a0,88
    80004192:	00f97793          	andi	a5,s2,15
    80004196:	079a                	slli	a5,a5,0x6
    80004198:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000419a:	00099783          	lh	a5,0(s3)
    8000419e:	cb9d                	beqz	a5,800041d4 <ialloc+0x88>
    brelse(bp);
    800041a0:	b59ff0ef          	jal	80003cf8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800041a4:	0905                	addi	s2,s2,1
    800041a6:	00ca2703          	lw	a4,12(s4)
    800041aa:	0009079b          	sext.w	a5,s2
    800041ae:	fce7e7e3          	bltu	a5,a4,8000417c <ialloc+0x30>
    800041b2:	74a2                	ld	s1,40(sp)
    800041b4:	7902                	ld	s2,32(sp)
    800041b6:	69e2                	ld	s3,24(sp)
    800041b8:	6a42                	ld	s4,16(sp)
    800041ba:	6aa2                	ld	s5,8(sp)
    800041bc:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800041be:	00004517          	auipc	a0,0x4
    800041c2:	37250513          	addi	a0,a0,882 # 80008530 <etext+0x530>
    800041c6:	b34fc0ef          	jal	800004fa <printf>
  return 0;
    800041ca:	4501                	li	a0,0
}
    800041cc:	70e2                	ld	ra,56(sp)
    800041ce:	7442                	ld	s0,48(sp)
    800041d0:	6121                	addi	sp,sp,64
    800041d2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800041d4:	04000613          	li	a2,64
    800041d8:	4581                	li	a1,0
    800041da:	854e                	mv	a0,s3
    800041dc:	cd3fc0ef          	jal	80000eae <memset>
      dip->type = type;
    800041e0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800041e4:	8526                	mv	a0,s1
    800041e6:	445000ef          	jal	80004e2a <log_write>
      brelse(bp);
    800041ea:	8526                	mv	a0,s1
    800041ec:	b0dff0ef          	jal	80003cf8 <brelse>
      return iget(dev, inum);
    800041f0:	0009059b          	sext.w	a1,s2
    800041f4:	8556                	mv	a0,s5
    800041f6:	e53ff0ef          	jal	80004048 <iget>
    800041fa:	74a2                	ld	s1,40(sp)
    800041fc:	7902                	ld	s2,32(sp)
    800041fe:	69e2                	ld	s3,24(sp)
    80004200:	6a42                	ld	s4,16(sp)
    80004202:	6aa2                	ld	s5,8(sp)
    80004204:	6b02                	ld	s6,0(sp)
    80004206:	b7d9                	j	800041cc <ialloc+0x80>

0000000080004208 <iupdate>:
{
    80004208:	1101                	addi	sp,sp,-32
    8000420a:	ec06                	sd	ra,24(sp)
    8000420c:	e822                	sd	s0,16(sp)
    8000420e:	e426                	sd	s1,8(sp)
    80004210:	e04a                	sd	s2,0(sp)
    80004212:	1000                	addi	s0,sp,32
    80004214:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004216:	415c                	lw	a5,4(a0)
    80004218:	0047d79b          	srliw	a5,a5,0x4
    8000421c:	0003c597          	auipc	a1,0x3c
    80004220:	0145a583          	lw	a1,20(a1) # 80040230 <sb+0x18>
    80004224:	9dbd                	addw	a1,a1,a5
    80004226:	4108                	lw	a0,0(a0)
    80004228:	9c9ff0ef          	jal	80003bf0 <bread>
    8000422c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000422e:	05850793          	addi	a5,a0,88
    80004232:	40d8                	lw	a4,4(s1)
    80004234:	8b3d                	andi	a4,a4,15
    80004236:	071a                	slli	a4,a4,0x6
    80004238:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000423a:	04449703          	lh	a4,68(s1)
    8000423e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004242:	04649703          	lh	a4,70(s1)
    80004246:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000424a:	04849703          	lh	a4,72(s1)
    8000424e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004252:	04a49703          	lh	a4,74(s1)
    80004256:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000425a:	44f8                	lw	a4,76(s1)
    8000425c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000425e:	03400613          	li	a2,52
    80004262:	05048593          	addi	a1,s1,80
    80004266:	00c78513          	addi	a0,a5,12
    8000426a:	ca1fc0ef          	jal	80000f0a <memmove>
  log_write(bp);
    8000426e:	854a                	mv	a0,s2
    80004270:	3bb000ef          	jal	80004e2a <log_write>
  brelse(bp);
    80004274:	854a                	mv	a0,s2
    80004276:	a83ff0ef          	jal	80003cf8 <brelse>
}
    8000427a:	60e2                	ld	ra,24(sp)
    8000427c:	6442                	ld	s0,16(sp)
    8000427e:	64a2                	ld	s1,8(sp)
    80004280:	6902                	ld	s2,0(sp)
    80004282:	6105                	addi	sp,sp,32
    80004284:	8082                	ret

0000000080004286 <idup>:
{
    80004286:	1101                	addi	sp,sp,-32
    80004288:	ec06                	sd	ra,24(sp)
    8000428a:	e822                	sd	s0,16(sp)
    8000428c:	e426                	sd	s1,8(sp)
    8000428e:	1000                	addi	s0,sp,32
    80004290:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004292:	0003c517          	auipc	a0,0x3c
    80004296:	fa650513          	addi	a0,a0,-90 # 80040238 <itable>
    8000429a:	b41fc0ef          	jal	80000dda <acquire>
  ip->ref++;
    8000429e:	449c                	lw	a5,8(s1)
    800042a0:	2785                	addiw	a5,a5,1
    800042a2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800042a4:	0003c517          	auipc	a0,0x3c
    800042a8:	f9450513          	addi	a0,a0,-108 # 80040238 <itable>
    800042ac:	bc7fc0ef          	jal	80000e72 <release>
}
    800042b0:	8526                	mv	a0,s1
    800042b2:	60e2                	ld	ra,24(sp)
    800042b4:	6442                	ld	s0,16(sp)
    800042b6:	64a2                	ld	s1,8(sp)
    800042b8:	6105                	addi	sp,sp,32
    800042ba:	8082                	ret

00000000800042bc <ilock>:
{
    800042bc:	1101                	addi	sp,sp,-32
    800042be:	ec06                	sd	ra,24(sp)
    800042c0:	e822                	sd	s0,16(sp)
    800042c2:	e426                	sd	s1,8(sp)
    800042c4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800042c6:	cd19                	beqz	a0,800042e4 <ilock+0x28>
    800042c8:	84aa                	mv	s1,a0
    800042ca:	451c                	lw	a5,8(a0)
    800042cc:	00f05c63          	blez	a5,800042e4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800042d0:	0541                	addi	a0,a0,16
    800042d2:	451000ef          	jal	80004f22 <acquiresleep>
  if(ip->valid == 0){
    800042d6:	40bc                	lw	a5,64(s1)
    800042d8:	cf89                	beqz	a5,800042f2 <ilock+0x36>
}
    800042da:	60e2                	ld	ra,24(sp)
    800042dc:	6442                	ld	s0,16(sp)
    800042de:	64a2                	ld	s1,8(sp)
    800042e0:	6105                	addi	sp,sp,32
    800042e2:	8082                	ret
    800042e4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800042e6:	00004517          	auipc	a0,0x4
    800042ea:	26250513          	addi	a0,a0,610 # 80008548 <etext+0x548>
    800042ee:	cf2fc0ef          	jal	800007e0 <panic>
    800042f2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800042f4:	40dc                	lw	a5,4(s1)
    800042f6:	0047d79b          	srliw	a5,a5,0x4
    800042fa:	0003c597          	auipc	a1,0x3c
    800042fe:	f365a583          	lw	a1,-202(a1) # 80040230 <sb+0x18>
    80004302:	9dbd                	addw	a1,a1,a5
    80004304:	4088                	lw	a0,0(s1)
    80004306:	8ebff0ef          	jal	80003bf0 <bread>
    8000430a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000430c:	05850593          	addi	a1,a0,88
    80004310:	40dc                	lw	a5,4(s1)
    80004312:	8bbd                	andi	a5,a5,15
    80004314:	079a                	slli	a5,a5,0x6
    80004316:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004318:	00059783          	lh	a5,0(a1)
    8000431c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004320:	00259783          	lh	a5,2(a1)
    80004324:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004328:	00459783          	lh	a5,4(a1)
    8000432c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004330:	00659783          	lh	a5,6(a1)
    80004334:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004338:	459c                	lw	a5,8(a1)
    8000433a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000433c:	03400613          	li	a2,52
    80004340:	05b1                	addi	a1,a1,12
    80004342:	05048513          	addi	a0,s1,80
    80004346:	bc5fc0ef          	jal	80000f0a <memmove>
    brelse(bp);
    8000434a:	854a                	mv	a0,s2
    8000434c:	9adff0ef          	jal	80003cf8 <brelse>
    ip->valid = 1;
    80004350:	4785                	li	a5,1
    80004352:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004354:	04449783          	lh	a5,68(s1)
    80004358:	c399                	beqz	a5,8000435e <ilock+0xa2>
    8000435a:	6902                	ld	s2,0(sp)
    8000435c:	bfbd                	j	800042da <ilock+0x1e>
      panic("ilock: no type");
    8000435e:	00004517          	auipc	a0,0x4
    80004362:	1f250513          	addi	a0,a0,498 # 80008550 <etext+0x550>
    80004366:	c7afc0ef          	jal	800007e0 <panic>

000000008000436a <iunlock>:
{
    8000436a:	1101                	addi	sp,sp,-32
    8000436c:	ec06                	sd	ra,24(sp)
    8000436e:	e822                	sd	s0,16(sp)
    80004370:	e426                	sd	s1,8(sp)
    80004372:	e04a                	sd	s2,0(sp)
    80004374:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004376:	c505                	beqz	a0,8000439e <iunlock+0x34>
    80004378:	84aa                	mv	s1,a0
    8000437a:	01050913          	addi	s2,a0,16
    8000437e:	854a                	mv	a0,s2
    80004380:	421000ef          	jal	80004fa0 <holdingsleep>
    80004384:	cd09                	beqz	a0,8000439e <iunlock+0x34>
    80004386:	449c                	lw	a5,8(s1)
    80004388:	00f05b63          	blez	a5,8000439e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000438c:	854a                	mv	a0,s2
    8000438e:	3db000ef          	jal	80004f68 <releasesleep>
}
    80004392:	60e2                	ld	ra,24(sp)
    80004394:	6442                	ld	s0,16(sp)
    80004396:	64a2                	ld	s1,8(sp)
    80004398:	6902                	ld	s2,0(sp)
    8000439a:	6105                	addi	sp,sp,32
    8000439c:	8082                	ret
    panic("iunlock");
    8000439e:	00004517          	auipc	a0,0x4
    800043a2:	1c250513          	addi	a0,a0,450 # 80008560 <etext+0x560>
    800043a6:	c3afc0ef          	jal	800007e0 <panic>

00000000800043aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800043aa:	7179                	addi	sp,sp,-48
    800043ac:	f406                	sd	ra,40(sp)
    800043ae:	f022                	sd	s0,32(sp)
    800043b0:	ec26                	sd	s1,24(sp)
    800043b2:	e84a                	sd	s2,16(sp)
    800043b4:	e44e                	sd	s3,8(sp)
    800043b6:	1800                	addi	s0,sp,48
    800043b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800043ba:	05050493          	addi	s1,a0,80
    800043be:	08050913          	addi	s2,a0,128
    800043c2:	a021                	j	800043ca <itrunc+0x20>
    800043c4:	0491                	addi	s1,s1,4
    800043c6:	01248b63          	beq	s1,s2,800043dc <itrunc+0x32>
    if(ip->addrs[i]){
    800043ca:	408c                	lw	a1,0(s1)
    800043cc:	dde5                	beqz	a1,800043c4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800043ce:	0009a503          	lw	a0,0(s3)
    800043d2:	a17ff0ef          	jal	80003de8 <bfree>
      ip->addrs[i] = 0;
    800043d6:	0004a023          	sw	zero,0(s1)
    800043da:	b7ed                	j	800043c4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800043dc:	0809a583          	lw	a1,128(s3)
    800043e0:	ed89                	bnez	a1,800043fa <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800043e2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800043e6:	854e                	mv	a0,s3
    800043e8:	e21ff0ef          	jal	80004208 <iupdate>
}
    800043ec:	70a2                	ld	ra,40(sp)
    800043ee:	7402                	ld	s0,32(sp)
    800043f0:	64e2                	ld	s1,24(sp)
    800043f2:	6942                	ld	s2,16(sp)
    800043f4:	69a2                	ld	s3,8(sp)
    800043f6:	6145                	addi	sp,sp,48
    800043f8:	8082                	ret
    800043fa:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800043fc:	0009a503          	lw	a0,0(s3)
    80004400:	ff0ff0ef          	jal	80003bf0 <bread>
    80004404:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004406:	05850493          	addi	s1,a0,88
    8000440a:	45850913          	addi	s2,a0,1112
    8000440e:	a021                	j	80004416 <itrunc+0x6c>
    80004410:	0491                	addi	s1,s1,4
    80004412:	01248963          	beq	s1,s2,80004424 <itrunc+0x7a>
      if(a[j])
    80004416:	408c                	lw	a1,0(s1)
    80004418:	dde5                	beqz	a1,80004410 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000441a:	0009a503          	lw	a0,0(s3)
    8000441e:	9cbff0ef          	jal	80003de8 <bfree>
    80004422:	b7fd                	j	80004410 <itrunc+0x66>
    brelse(bp);
    80004424:	8552                	mv	a0,s4
    80004426:	8d3ff0ef          	jal	80003cf8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000442a:	0809a583          	lw	a1,128(s3)
    8000442e:	0009a503          	lw	a0,0(s3)
    80004432:	9b7ff0ef          	jal	80003de8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004436:	0809a023          	sw	zero,128(s3)
    8000443a:	6a02                	ld	s4,0(sp)
    8000443c:	b75d                	j	800043e2 <itrunc+0x38>

000000008000443e <iput>:
{
    8000443e:	1101                	addi	sp,sp,-32
    80004440:	ec06                	sd	ra,24(sp)
    80004442:	e822                	sd	s0,16(sp)
    80004444:	e426                	sd	s1,8(sp)
    80004446:	1000                	addi	s0,sp,32
    80004448:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000444a:	0003c517          	auipc	a0,0x3c
    8000444e:	dee50513          	addi	a0,a0,-530 # 80040238 <itable>
    80004452:	989fc0ef          	jal	80000dda <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004456:	4498                	lw	a4,8(s1)
    80004458:	4785                	li	a5,1
    8000445a:	02f70063          	beq	a4,a5,8000447a <iput+0x3c>
  ip->ref--;
    8000445e:	449c                	lw	a5,8(s1)
    80004460:	37fd                	addiw	a5,a5,-1
    80004462:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004464:	0003c517          	auipc	a0,0x3c
    80004468:	dd450513          	addi	a0,a0,-556 # 80040238 <itable>
    8000446c:	a07fc0ef          	jal	80000e72 <release>
}
    80004470:	60e2                	ld	ra,24(sp)
    80004472:	6442                	ld	s0,16(sp)
    80004474:	64a2                	ld	s1,8(sp)
    80004476:	6105                	addi	sp,sp,32
    80004478:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000447a:	40bc                	lw	a5,64(s1)
    8000447c:	d3ed                	beqz	a5,8000445e <iput+0x20>
    8000447e:	04a49783          	lh	a5,74(s1)
    80004482:	fff1                	bnez	a5,8000445e <iput+0x20>
    80004484:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80004486:	01048913          	addi	s2,s1,16
    8000448a:	854a                	mv	a0,s2
    8000448c:	297000ef          	jal	80004f22 <acquiresleep>
    release(&itable.lock);
    80004490:	0003c517          	auipc	a0,0x3c
    80004494:	da850513          	addi	a0,a0,-600 # 80040238 <itable>
    80004498:	9dbfc0ef          	jal	80000e72 <release>
    itrunc(ip);
    8000449c:	8526                	mv	a0,s1
    8000449e:	f0dff0ef          	jal	800043aa <itrunc>
    ip->type = 0;
    800044a2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800044a6:	8526                	mv	a0,s1
    800044a8:	d61ff0ef          	jal	80004208 <iupdate>
    ip->valid = 0;
    800044ac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800044b0:	854a                	mv	a0,s2
    800044b2:	2b7000ef          	jal	80004f68 <releasesleep>
    acquire(&itable.lock);
    800044b6:	0003c517          	auipc	a0,0x3c
    800044ba:	d8250513          	addi	a0,a0,-638 # 80040238 <itable>
    800044be:	91dfc0ef          	jal	80000dda <acquire>
    800044c2:	6902                	ld	s2,0(sp)
    800044c4:	bf69                	j	8000445e <iput+0x20>

00000000800044c6 <iunlockput>:
{
    800044c6:	1101                	addi	sp,sp,-32
    800044c8:	ec06                	sd	ra,24(sp)
    800044ca:	e822                	sd	s0,16(sp)
    800044cc:	e426                	sd	s1,8(sp)
    800044ce:	1000                	addi	s0,sp,32
    800044d0:	84aa                	mv	s1,a0
  iunlock(ip);
    800044d2:	e99ff0ef          	jal	8000436a <iunlock>
  iput(ip);
    800044d6:	8526                	mv	a0,s1
    800044d8:	f67ff0ef          	jal	8000443e <iput>
}
    800044dc:	60e2                	ld	ra,24(sp)
    800044de:	6442                	ld	s0,16(sp)
    800044e0:	64a2                	ld	s1,8(sp)
    800044e2:	6105                	addi	sp,sp,32
    800044e4:	8082                	ret

00000000800044e6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800044e6:	0003c717          	auipc	a4,0x3c
    800044ea:	d3e72703          	lw	a4,-706(a4) # 80040224 <sb+0xc>
    800044ee:	4785                	li	a5,1
    800044f0:	0ae7ff63          	bgeu	a5,a4,800045ae <ireclaim+0xc8>
{
    800044f4:	7139                	addi	sp,sp,-64
    800044f6:	fc06                	sd	ra,56(sp)
    800044f8:	f822                	sd	s0,48(sp)
    800044fa:	f426                	sd	s1,40(sp)
    800044fc:	f04a                	sd	s2,32(sp)
    800044fe:	ec4e                	sd	s3,24(sp)
    80004500:	e852                	sd	s4,16(sp)
    80004502:	e456                	sd	s5,8(sp)
    80004504:	e05a                	sd	s6,0(sp)
    80004506:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004508:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000450a:	00050a1b          	sext.w	s4,a0
    8000450e:	0003ca97          	auipc	s5,0x3c
    80004512:	d0aa8a93          	addi	s5,s5,-758 # 80040218 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80004516:	00004b17          	auipc	s6,0x4
    8000451a:	052b0b13          	addi	s6,s6,82 # 80008568 <etext+0x568>
    8000451e:	a099                	j	80004564 <ireclaim+0x7e>
    80004520:	85ce                	mv	a1,s3
    80004522:	855a                	mv	a0,s6
    80004524:	fd7fb0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80004528:	85ce                	mv	a1,s3
    8000452a:	8552                	mv	a0,s4
    8000452c:	b1dff0ef          	jal	80004048 <iget>
    80004530:	89aa                	mv	s3,a0
    brelse(bp);
    80004532:	854a                	mv	a0,s2
    80004534:	fc4ff0ef          	jal	80003cf8 <brelse>
    if (ip) {
    80004538:	00098f63          	beqz	s3,80004556 <ireclaim+0x70>
      begin_op();
    8000453c:	76a000ef          	jal	80004ca6 <begin_op>
      ilock(ip);
    80004540:	854e                	mv	a0,s3
    80004542:	d7bff0ef          	jal	800042bc <ilock>
      iunlock(ip);
    80004546:	854e                	mv	a0,s3
    80004548:	e23ff0ef          	jal	8000436a <iunlock>
      iput(ip);
    8000454c:	854e                	mv	a0,s3
    8000454e:	ef1ff0ef          	jal	8000443e <iput>
      end_op();
    80004552:	7be000ef          	jal	80004d10 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80004556:	0485                	addi	s1,s1,1
    80004558:	00caa703          	lw	a4,12(s5)
    8000455c:	0004879b          	sext.w	a5,s1
    80004560:	02e7fd63          	bgeu	a5,a4,8000459a <ireclaim+0xb4>
    80004564:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80004568:	0044d593          	srli	a1,s1,0x4
    8000456c:	018aa783          	lw	a5,24(s5)
    80004570:	9dbd                	addw	a1,a1,a5
    80004572:	8552                	mv	a0,s4
    80004574:	e7cff0ef          	jal	80003bf0 <bread>
    80004578:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000457a:	05850793          	addi	a5,a0,88
    8000457e:	00f9f713          	andi	a4,s3,15
    80004582:	071a                	slli	a4,a4,0x6
    80004584:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80004586:	00079703          	lh	a4,0(a5)
    8000458a:	c701                	beqz	a4,80004592 <ireclaim+0xac>
    8000458c:	00679783          	lh	a5,6(a5)
    80004590:	dbc1                	beqz	a5,80004520 <ireclaim+0x3a>
    brelse(bp);
    80004592:	854a                	mv	a0,s2
    80004594:	f64ff0ef          	jal	80003cf8 <brelse>
    if (ip) {
    80004598:	bf7d                	j	80004556 <ireclaim+0x70>
}
    8000459a:	70e2                	ld	ra,56(sp)
    8000459c:	7442                	ld	s0,48(sp)
    8000459e:	74a2                	ld	s1,40(sp)
    800045a0:	7902                	ld	s2,32(sp)
    800045a2:	69e2                	ld	s3,24(sp)
    800045a4:	6a42                	ld	s4,16(sp)
    800045a6:	6aa2                	ld	s5,8(sp)
    800045a8:	6b02                	ld	s6,0(sp)
    800045aa:	6121                	addi	sp,sp,64
    800045ac:	8082                	ret
    800045ae:	8082                	ret

00000000800045b0 <fsinit>:
fsinit(int dev) {
    800045b0:	7179                	addi	sp,sp,-48
    800045b2:	f406                	sd	ra,40(sp)
    800045b4:	f022                	sd	s0,32(sp)
    800045b6:	ec26                	sd	s1,24(sp)
    800045b8:	e84a                	sd	s2,16(sp)
    800045ba:	e44e                	sd	s3,8(sp)
    800045bc:	1800                	addi	s0,sp,48
    800045be:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800045c0:	4585                	li	a1,1
    800045c2:	e2eff0ef          	jal	80003bf0 <bread>
    800045c6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800045c8:	0003c997          	auipc	s3,0x3c
    800045cc:	c5098993          	addi	s3,s3,-944 # 80040218 <sb>
    800045d0:	02000613          	li	a2,32
    800045d4:	05850593          	addi	a1,a0,88
    800045d8:	854e                	mv	a0,s3
    800045da:	931fc0ef          	jal	80000f0a <memmove>
  brelse(bp);
    800045de:	854a                	mv	a0,s2
    800045e0:	f18ff0ef          	jal	80003cf8 <brelse>
  if(sb.magic != FSMAGIC)
    800045e4:	0009a703          	lw	a4,0(s3)
    800045e8:	102037b7          	lui	a5,0x10203
    800045ec:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800045f0:	02f71363          	bne	a4,a5,80004616 <fsinit+0x66>
  initlog(dev, &sb);
    800045f4:	0003c597          	auipc	a1,0x3c
    800045f8:	c2458593          	addi	a1,a1,-988 # 80040218 <sb>
    800045fc:	8526                	mv	a0,s1
    800045fe:	62a000ef          	jal	80004c28 <initlog>
  ireclaim(dev);
    80004602:	8526                	mv	a0,s1
    80004604:	ee3ff0ef          	jal	800044e6 <ireclaim>
}
    80004608:	70a2                	ld	ra,40(sp)
    8000460a:	7402                	ld	s0,32(sp)
    8000460c:	64e2                	ld	s1,24(sp)
    8000460e:	6942                	ld	s2,16(sp)
    80004610:	69a2                	ld	s3,8(sp)
    80004612:	6145                	addi	sp,sp,48
    80004614:	8082                	ret
    panic("invalid file system");
    80004616:	00004517          	auipc	a0,0x4
    8000461a:	f7250513          	addi	a0,a0,-142 # 80008588 <etext+0x588>
    8000461e:	9c2fc0ef          	jal	800007e0 <panic>

0000000080004622 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004622:	1141                	addi	sp,sp,-16
    80004624:	e422                	sd	s0,8(sp)
    80004626:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004628:	411c                	lw	a5,0(a0)
    8000462a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000462c:	415c                	lw	a5,4(a0)
    8000462e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004630:	04451783          	lh	a5,68(a0)
    80004634:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004638:	04a51783          	lh	a5,74(a0)
    8000463c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004640:	04c56783          	lwu	a5,76(a0)
    80004644:	e99c                	sd	a5,16(a1)
}
    80004646:	6422                	ld	s0,8(sp)
    80004648:	0141                	addi	sp,sp,16
    8000464a:	8082                	ret

000000008000464c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000464c:	457c                	lw	a5,76(a0)
    8000464e:	0ed7eb63          	bltu	a5,a3,80004744 <readi+0xf8>
{
    80004652:	7159                	addi	sp,sp,-112
    80004654:	f486                	sd	ra,104(sp)
    80004656:	f0a2                	sd	s0,96(sp)
    80004658:	eca6                	sd	s1,88(sp)
    8000465a:	e0d2                	sd	s4,64(sp)
    8000465c:	fc56                	sd	s5,56(sp)
    8000465e:	f85a                	sd	s6,48(sp)
    80004660:	f45e                	sd	s7,40(sp)
    80004662:	1880                	addi	s0,sp,112
    80004664:	8b2a                	mv	s6,a0
    80004666:	8bae                	mv	s7,a1
    80004668:	8a32                	mv	s4,a2
    8000466a:	84b6                	mv	s1,a3
    8000466c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000466e:	9f35                	addw	a4,a4,a3
    return 0;
    80004670:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004672:	0cd76063          	bltu	a4,a3,80004732 <readi+0xe6>
    80004676:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80004678:	00e7f463          	bgeu	a5,a4,80004680 <readi+0x34>
    n = ip->size - off;
    8000467c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004680:	080a8f63          	beqz	s5,8000471e <readi+0xd2>
    80004684:	e8ca                	sd	s2,80(sp)
    80004686:	f062                	sd	s8,32(sp)
    80004688:	ec66                	sd	s9,24(sp)
    8000468a:	e86a                	sd	s10,16(sp)
    8000468c:	e46e                	sd	s11,8(sp)
    8000468e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004690:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004694:	5c7d                	li	s8,-1
    80004696:	a80d                	j	800046c8 <readi+0x7c>
    80004698:	020d1d93          	slli	s11,s10,0x20
    8000469c:	020ddd93          	srli	s11,s11,0x20
    800046a0:	05890613          	addi	a2,s2,88
    800046a4:	86ee                	mv	a3,s11
    800046a6:	963a                	add	a2,a2,a4
    800046a8:	85d2                	mv	a1,s4
    800046aa:	855e                	mv	a0,s7
    800046ac:	eacfe0ef          	jal	80002d58 <either_copyout>
    800046b0:	05850763          	beq	a0,s8,800046fe <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800046b4:	854a                	mv	a0,s2
    800046b6:	e42ff0ef          	jal	80003cf8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800046ba:	013d09bb          	addw	s3,s10,s3
    800046be:	009d04bb          	addw	s1,s10,s1
    800046c2:	9a6e                	add	s4,s4,s11
    800046c4:	0559f763          	bgeu	s3,s5,80004712 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800046c8:	00a4d59b          	srliw	a1,s1,0xa
    800046cc:	855a                	mv	a0,s6
    800046ce:	8a7ff0ef          	jal	80003f74 <bmap>
    800046d2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800046d6:	c5b1                	beqz	a1,80004722 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800046d8:	000b2503          	lw	a0,0(s6)
    800046dc:	d14ff0ef          	jal	80003bf0 <bread>
    800046e0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800046e2:	3ff4f713          	andi	a4,s1,1023
    800046e6:	40ec87bb          	subw	a5,s9,a4
    800046ea:	413a86bb          	subw	a3,s5,s3
    800046ee:	8d3e                	mv	s10,a5
    800046f0:	2781                	sext.w	a5,a5
    800046f2:	0006861b          	sext.w	a2,a3
    800046f6:	faf671e3          	bgeu	a2,a5,80004698 <readi+0x4c>
    800046fa:	8d36                	mv	s10,a3
    800046fc:	bf71                	j	80004698 <readi+0x4c>
      brelse(bp);
    800046fe:	854a                	mv	a0,s2
    80004700:	df8ff0ef          	jal	80003cf8 <brelse>
      tot = -1;
    80004704:	59fd                	li	s3,-1
      break;
    80004706:	6946                	ld	s2,80(sp)
    80004708:	7c02                	ld	s8,32(sp)
    8000470a:	6ce2                	ld	s9,24(sp)
    8000470c:	6d42                	ld	s10,16(sp)
    8000470e:	6da2                	ld	s11,8(sp)
    80004710:	a831                	j	8000472c <readi+0xe0>
    80004712:	6946                	ld	s2,80(sp)
    80004714:	7c02                	ld	s8,32(sp)
    80004716:	6ce2                	ld	s9,24(sp)
    80004718:	6d42                	ld	s10,16(sp)
    8000471a:	6da2                	ld	s11,8(sp)
    8000471c:	a801                	j	8000472c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000471e:	89d6                	mv	s3,s5
    80004720:	a031                	j	8000472c <readi+0xe0>
    80004722:	6946                	ld	s2,80(sp)
    80004724:	7c02                	ld	s8,32(sp)
    80004726:	6ce2                	ld	s9,24(sp)
    80004728:	6d42                	ld	s10,16(sp)
    8000472a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000472c:	0009851b          	sext.w	a0,s3
    80004730:	69a6                	ld	s3,72(sp)
}
    80004732:	70a6                	ld	ra,104(sp)
    80004734:	7406                	ld	s0,96(sp)
    80004736:	64e6                	ld	s1,88(sp)
    80004738:	6a06                	ld	s4,64(sp)
    8000473a:	7ae2                	ld	s5,56(sp)
    8000473c:	7b42                	ld	s6,48(sp)
    8000473e:	7ba2                	ld	s7,40(sp)
    80004740:	6165                	addi	sp,sp,112
    80004742:	8082                	ret
    return 0;
    80004744:	4501                	li	a0,0
}
    80004746:	8082                	ret

0000000080004748 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004748:	457c                	lw	a5,76(a0)
    8000474a:	10d7e063          	bltu	a5,a3,8000484a <writei+0x102>
{
    8000474e:	7159                	addi	sp,sp,-112
    80004750:	f486                	sd	ra,104(sp)
    80004752:	f0a2                	sd	s0,96(sp)
    80004754:	e8ca                	sd	s2,80(sp)
    80004756:	e0d2                	sd	s4,64(sp)
    80004758:	fc56                	sd	s5,56(sp)
    8000475a:	f85a                	sd	s6,48(sp)
    8000475c:	f45e                	sd	s7,40(sp)
    8000475e:	1880                	addi	s0,sp,112
    80004760:	8aaa                	mv	s5,a0
    80004762:	8bae                	mv	s7,a1
    80004764:	8a32                	mv	s4,a2
    80004766:	8936                	mv	s2,a3
    80004768:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000476a:	00e687bb          	addw	a5,a3,a4
    8000476e:	0ed7e063          	bltu	a5,a3,8000484e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004772:	00043737          	lui	a4,0x43
    80004776:	0cf76e63          	bltu	a4,a5,80004852 <writei+0x10a>
    8000477a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000477c:	0a0b0f63          	beqz	s6,8000483a <writei+0xf2>
    80004780:	eca6                	sd	s1,88(sp)
    80004782:	f062                	sd	s8,32(sp)
    80004784:	ec66                	sd	s9,24(sp)
    80004786:	e86a                	sd	s10,16(sp)
    80004788:	e46e                	sd	s11,8(sp)
    8000478a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000478c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004790:	5c7d                	li	s8,-1
    80004792:	a825                	j	800047ca <writei+0x82>
    80004794:	020d1d93          	slli	s11,s10,0x20
    80004798:	020ddd93          	srli	s11,s11,0x20
    8000479c:	05848513          	addi	a0,s1,88
    800047a0:	86ee                	mv	a3,s11
    800047a2:	8652                	mv	a2,s4
    800047a4:	85de                	mv	a1,s7
    800047a6:	953a                	add	a0,a0,a4
    800047a8:	dfafe0ef          	jal	80002da2 <either_copyin>
    800047ac:	05850a63          	beq	a0,s8,80004800 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800047b0:	8526                	mv	a0,s1
    800047b2:	678000ef          	jal	80004e2a <log_write>
    brelse(bp);
    800047b6:	8526                	mv	a0,s1
    800047b8:	d40ff0ef          	jal	80003cf8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800047bc:	013d09bb          	addw	s3,s10,s3
    800047c0:	012d093b          	addw	s2,s10,s2
    800047c4:	9a6e                	add	s4,s4,s11
    800047c6:	0569f063          	bgeu	s3,s6,80004806 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800047ca:	00a9559b          	srliw	a1,s2,0xa
    800047ce:	8556                	mv	a0,s5
    800047d0:	fa4ff0ef          	jal	80003f74 <bmap>
    800047d4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800047d8:	c59d                	beqz	a1,80004806 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800047da:	000aa503          	lw	a0,0(s5)
    800047de:	c12ff0ef          	jal	80003bf0 <bread>
    800047e2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800047e4:	3ff97713          	andi	a4,s2,1023
    800047e8:	40ec87bb          	subw	a5,s9,a4
    800047ec:	413b06bb          	subw	a3,s6,s3
    800047f0:	8d3e                	mv	s10,a5
    800047f2:	2781                	sext.w	a5,a5
    800047f4:	0006861b          	sext.w	a2,a3
    800047f8:	f8f67ee3          	bgeu	a2,a5,80004794 <writei+0x4c>
    800047fc:	8d36                	mv	s10,a3
    800047fe:	bf59                	j	80004794 <writei+0x4c>
      brelse(bp);
    80004800:	8526                	mv	a0,s1
    80004802:	cf6ff0ef          	jal	80003cf8 <brelse>
  }

  if(off > ip->size)
    80004806:	04caa783          	lw	a5,76(s5)
    8000480a:	0327fa63          	bgeu	a5,s2,8000483e <writei+0xf6>
    ip->size = off;
    8000480e:	052aa623          	sw	s2,76(s5)
    80004812:	64e6                	ld	s1,88(sp)
    80004814:	7c02                	ld	s8,32(sp)
    80004816:	6ce2                	ld	s9,24(sp)
    80004818:	6d42                	ld	s10,16(sp)
    8000481a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000481c:	8556                	mv	a0,s5
    8000481e:	9ebff0ef          	jal	80004208 <iupdate>

  return tot;
    80004822:	0009851b          	sext.w	a0,s3
    80004826:	69a6                	ld	s3,72(sp)
}
    80004828:	70a6                	ld	ra,104(sp)
    8000482a:	7406                	ld	s0,96(sp)
    8000482c:	6946                	ld	s2,80(sp)
    8000482e:	6a06                	ld	s4,64(sp)
    80004830:	7ae2                	ld	s5,56(sp)
    80004832:	7b42                	ld	s6,48(sp)
    80004834:	7ba2                	ld	s7,40(sp)
    80004836:	6165                	addi	sp,sp,112
    80004838:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000483a:	89da                	mv	s3,s6
    8000483c:	b7c5                	j	8000481c <writei+0xd4>
    8000483e:	64e6                	ld	s1,88(sp)
    80004840:	7c02                	ld	s8,32(sp)
    80004842:	6ce2                	ld	s9,24(sp)
    80004844:	6d42                	ld	s10,16(sp)
    80004846:	6da2                	ld	s11,8(sp)
    80004848:	bfd1                	j	8000481c <writei+0xd4>
    return -1;
    8000484a:	557d                	li	a0,-1
}
    8000484c:	8082                	ret
    return -1;
    8000484e:	557d                	li	a0,-1
    80004850:	bfe1                	j	80004828 <writei+0xe0>
    return -1;
    80004852:	557d                	li	a0,-1
    80004854:	bfd1                	j	80004828 <writei+0xe0>

0000000080004856 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004856:	1141                	addi	sp,sp,-16
    80004858:	e406                	sd	ra,8(sp)
    8000485a:	e022                	sd	s0,0(sp)
    8000485c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000485e:	4639                	li	a2,14
    80004860:	f1afc0ef          	jal	80000f7a <strncmp>
}
    80004864:	60a2                	ld	ra,8(sp)
    80004866:	6402                	ld	s0,0(sp)
    80004868:	0141                	addi	sp,sp,16
    8000486a:	8082                	ret

000000008000486c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000486c:	7139                	addi	sp,sp,-64
    8000486e:	fc06                	sd	ra,56(sp)
    80004870:	f822                	sd	s0,48(sp)
    80004872:	f426                	sd	s1,40(sp)
    80004874:	f04a                	sd	s2,32(sp)
    80004876:	ec4e                	sd	s3,24(sp)
    80004878:	e852                	sd	s4,16(sp)
    8000487a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000487c:	04451703          	lh	a4,68(a0)
    80004880:	4785                	li	a5,1
    80004882:	00f71a63          	bne	a4,a5,80004896 <dirlookup+0x2a>
    80004886:	892a                	mv	s2,a0
    80004888:	89ae                	mv	s3,a1
    8000488a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000488c:	457c                	lw	a5,76(a0)
    8000488e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004890:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004892:	e39d                	bnez	a5,800048b8 <dirlookup+0x4c>
    80004894:	a095                	j	800048f8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004896:	00004517          	auipc	a0,0x4
    8000489a:	d0a50513          	addi	a0,a0,-758 # 800085a0 <etext+0x5a0>
    8000489e:	f43fb0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800048a2:	00004517          	auipc	a0,0x4
    800048a6:	d1650513          	addi	a0,a0,-746 # 800085b8 <etext+0x5b8>
    800048aa:	f37fb0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800048ae:	24c1                	addiw	s1,s1,16
    800048b0:	04c92783          	lw	a5,76(s2)
    800048b4:	04f4f163          	bgeu	s1,a5,800048f6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048b8:	4741                	li	a4,16
    800048ba:	86a6                	mv	a3,s1
    800048bc:	fc040613          	addi	a2,s0,-64
    800048c0:	4581                	li	a1,0
    800048c2:	854a                	mv	a0,s2
    800048c4:	d89ff0ef          	jal	8000464c <readi>
    800048c8:	47c1                	li	a5,16
    800048ca:	fcf51ce3          	bne	a0,a5,800048a2 <dirlookup+0x36>
    if(de.inum == 0)
    800048ce:	fc045783          	lhu	a5,-64(s0)
    800048d2:	dff1                	beqz	a5,800048ae <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800048d4:	fc240593          	addi	a1,s0,-62
    800048d8:	854e                	mv	a0,s3
    800048da:	f7dff0ef          	jal	80004856 <namecmp>
    800048de:	f961                	bnez	a0,800048ae <dirlookup+0x42>
      if(poff)
    800048e0:	000a0463          	beqz	s4,800048e8 <dirlookup+0x7c>
        *poff = off;
    800048e4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800048e8:	fc045583          	lhu	a1,-64(s0)
    800048ec:	00092503          	lw	a0,0(s2)
    800048f0:	f58ff0ef          	jal	80004048 <iget>
    800048f4:	a011                	j	800048f8 <dirlookup+0x8c>
  return 0;
    800048f6:	4501                	li	a0,0
}
    800048f8:	70e2                	ld	ra,56(sp)
    800048fa:	7442                	ld	s0,48(sp)
    800048fc:	74a2                	ld	s1,40(sp)
    800048fe:	7902                	ld	s2,32(sp)
    80004900:	69e2                	ld	s3,24(sp)
    80004902:	6a42                	ld	s4,16(sp)
    80004904:	6121                	addi	sp,sp,64
    80004906:	8082                	ret

0000000080004908 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004908:	711d                	addi	sp,sp,-96
    8000490a:	ec86                	sd	ra,88(sp)
    8000490c:	e8a2                	sd	s0,80(sp)
    8000490e:	e4a6                	sd	s1,72(sp)
    80004910:	e0ca                	sd	s2,64(sp)
    80004912:	fc4e                	sd	s3,56(sp)
    80004914:	f852                	sd	s4,48(sp)
    80004916:	f456                	sd	s5,40(sp)
    80004918:	f05a                	sd	s6,32(sp)
    8000491a:	ec5e                	sd	s7,24(sp)
    8000491c:	e862                	sd	s8,16(sp)
    8000491e:	e466                	sd	s9,8(sp)
    80004920:	1080                	addi	s0,sp,96
    80004922:	84aa                	mv	s1,a0
    80004924:	8b2e                	mv	s6,a1
    80004926:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004928:	00054703          	lbu	a4,0(a0)
    8000492c:	02f00793          	li	a5,47
    80004930:	00f70e63          	beq	a4,a5,8000494c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004934:	c32fd0ef          	jal	80001d66 <myproc>
    80004938:	15053503          	ld	a0,336(a0)
    8000493c:	94bff0ef          	jal	80004286 <idup>
    80004940:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004942:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004946:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004948:	4b85                	li	s7,1
    8000494a:	a871                	j	800049e6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000494c:	4585                	li	a1,1
    8000494e:	4505                	li	a0,1
    80004950:	ef8ff0ef          	jal	80004048 <iget>
    80004954:	8a2a                	mv	s4,a0
    80004956:	b7f5                	j	80004942 <namex+0x3a>
      iunlockput(ip);
    80004958:	8552                	mv	a0,s4
    8000495a:	b6dff0ef          	jal	800044c6 <iunlockput>
      return 0;
    8000495e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004960:	8552                	mv	a0,s4
    80004962:	60e6                	ld	ra,88(sp)
    80004964:	6446                	ld	s0,80(sp)
    80004966:	64a6                	ld	s1,72(sp)
    80004968:	6906                	ld	s2,64(sp)
    8000496a:	79e2                	ld	s3,56(sp)
    8000496c:	7a42                	ld	s4,48(sp)
    8000496e:	7aa2                	ld	s5,40(sp)
    80004970:	7b02                	ld	s6,32(sp)
    80004972:	6be2                	ld	s7,24(sp)
    80004974:	6c42                	ld	s8,16(sp)
    80004976:	6ca2                	ld	s9,8(sp)
    80004978:	6125                	addi	sp,sp,96
    8000497a:	8082                	ret
      iunlock(ip);
    8000497c:	8552                	mv	a0,s4
    8000497e:	9edff0ef          	jal	8000436a <iunlock>
      return ip;
    80004982:	bff9                	j	80004960 <namex+0x58>
      iunlockput(ip);
    80004984:	8552                	mv	a0,s4
    80004986:	b41ff0ef          	jal	800044c6 <iunlockput>
      return 0;
    8000498a:	8a4e                	mv	s4,s3
    8000498c:	bfd1                	j	80004960 <namex+0x58>
  len = path - s;
    8000498e:	40998633          	sub	a2,s3,s1
    80004992:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004996:	099c5063          	bge	s8,s9,80004a16 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    8000499a:	4639                	li	a2,14
    8000499c:	85a6                	mv	a1,s1
    8000499e:	8556                	mv	a0,s5
    800049a0:	d6afc0ef          	jal	80000f0a <memmove>
    800049a4:	84ce                	mv	s1,s3
  while(*path == '/')
    800049a6:	0004c783          	lbu	a5,0(s1)
    800049aa:	01279763          	bne	a5,s2,800049b8 <namex+0xb0>
    path++;
    800049ae:	0485                	addi	s1,s1,1
  while(*path == '/')
    800049b0:	0004c783          	lbu	a5,0(s1)
    800049b4:	ff278de3          	beq	a5,s2,800049ae <namex+0xa6>
    ilock(ip);
    800049b8:	8552                	mv	a0,s4
    800049ba:	903ff0ef          	jal	800042bc <ilock>
    if(ip->type != T_DIR){
    800049be:	044a1783          	lh	a5,68(s4)
    800049c2:	f9779be3          	bne	a5,s7,80004958 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800049c6:	000b0563          	beqz	s6,800049d0 <namex+0xc8>
    800049ca:	0004c783          	lbu	a5,0(s1)
    800049ce:	d7dd                	beqz	a5,8000497c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800049d0:	4601                	li	a2,0
    800049d2:	85d6                	mv	a1,s5
    800049d4:	8552                	mv	a0,s4
    800049d6:	e97ff0ef          	jal	8000486c <dirlookup>
    800049da:	89aa                	mv	s3,a0
    800049dc:	d545                	beqz	a0,80004984 <namex+0x7c>
    iunlockput(ip);
    800049de:	8552                	mv	a0,s4
    800049e0:	ae7ff0ef          	jal	800044c6 <iunlockput>
    ip = next;
    800049e4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800049e6:	0004c783          	lbu	a5,0(s1)
    800049ea:	01279763          	bne	a5,s2,800049f8 <namex+0xf0>
    path++;
    800049ee:	0485                	addi	s1,s1,1
  while(*path == '/')
    800049f0:	0004c783          	lbu	a5,0(s1)
    800049f4:	ff278de3          	beq	a5,s2,800049ee <namex+0xe6>
  if(*path == 0)
    800049f8:	cb8d                	beqz	a5,80004a2a <namex+0x122>
  while(*path != '/' && *path != 0)
    800049fa:	0004c783          	lbu	a5,0(s1)
    800049fe:	89a6                	mv	s3,s1
  len = path - s;
    80004a00:	4c81                	li	s9,0
    80004a02:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004a04:	01278963          	beq	a5,s2,80004a16 <namex+0x10e>
    80004a08:	d3d9                	beqz	a5,8000498e <namex+0x86>
    path++;
    80004a0a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004a0c:	0009c783          	lbu	a5,0(s3)
    80004a10:	ff279ce3          	bne	a5,s2,80004a08 <namex+0x100>
    80004a14:	bfad                	j	8000498e <namex+0x86>
    memmove(name, s, len);
    80004a16:	2601                	sext.w	a2,a2
    80004a18:	85a6                	mv	a1,s1
    80004a1a:	8556                	mv	a0,s5
    80004a1c:	ceefc0ef          	jal	80000f0a <memmove>
    name[len] = 0;
    80004a20:	9cd6                	add	s9,s9,s5
    80004a22:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004a26:	84ce                	mv	s1,s3
    80004a28:	bfbd                	j	800049a6 <namex+0x9e>
  if(nameiparent){
    80004a2a:	f20b0be3          	beqz	s6,80004960 <namex+0x58>
    iput(ip);
    80004a2e:	8552                	mv	a0,s4
    80004a30:	a0fff0ef          	jal	8000443e <iput>
    return 0;
    80004a34:	4a01                	li	s4,0
    80004a36:	b72d                	j	80004960 <namex+0x58>

0000000080004a38 <dirlink>:
{
    80004a38:	7139                	addi	sp,sp,-64
    80004a3a:	fc06                	sd	ra,56(sp)
    80004a3c:	f822                	sd	s0,48(sp)
    80004a3e:	f04a                	sd	s2,32(sp)
    80004a40:	ec4e                	sd	s3,24(sp)
    80004a42:	e852                	sd	s4,16(sp)
    80004a44:	0080                	addi	s0,sp,64
    80004a46:	892a                	mv	s2,a0
    80004a48:	8a2e                	mv	s4,a1
    80004a4a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a4c:	4601                	li	a2,0
    80004a4e:	e1fff0ef          	jal	8000486c <dirlookup>
    80004a52:	e535                	bnez	a0,80004abe <dirlink+0x86>
    80004a54:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a56:	04c92483          	lw	s1,76(s2)
    80004a5a:	c48d                	beqz	s1,80004a84 <dirlink+0x4c>
    80004a5c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a5e:	4741                	li	a4,16
    80004a60:	86a6                	mv	a3,s1
    80004a62:	fc040613          	addi	a2,s0,-64
    80004a66:	4581                	li	a1,0
    80004a68:	854a                	mv	a0,s2
    80004a6a:	be3ff0ef          	jal	8000464c <readi>
    80004a6e:	47c1                	li	a5,16
    80004a70:	04f51b63          	bne	a0,a5,80004ac6 <dirlink+0x8e>
    if(de.inum == 0)
    80004a74:	fc045783          	lhu	a5,-64(s0)
    80004a78:	c791                	beqz	a5,80004a84 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a7a:	24c1                	addiw	s1,s1,16
    80004a7c:	04c92783          	lw	a5,76(s2)
    80004a80:	fcf4efe3          	bltu	s1,a5,80004a5e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004a84:	4639                	li	a2,14
    80004a86:	85d2                	mv	a1,s4
    80004a88:	fc240513          	addi	a0,s0,-62
    80004a8c:	d24fc0ef          	jal	80000fb0 <strncpy>
  de.inum = inum;
    80004a90:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a94:	4741                	li	a4,16
    80004a96:	86a6                	mv	a3,s1
    80004a98:	fc040613          	addi	a2,s0,-64
    80004a9c:	4581                	li	a1,0
    80004a9e:	854a                	mv	a0,s2
    80004aa0:	ca9ff0ef          	jal	80004748 <writei>
    80004aa4:	1541                	addi	a0,a0,-16
    80004aa6:	00a03533          	snez	a0,a0
    80004aaa:	40a00533          	neg	a0,a0
    80004aae:	74a2                	ld	s1,40(sp)
}
    80004ab0:	70e2                	ld	ra,56(sp)
    80004ab2:	7442                	ld	s0,48(sp)
    80004ab4:	7902                	ld	s2,32(sp)
    80004ab6:	69e2                	ld	s3,24(sp)
    80004ab8:	6a42                	ld	s4,16(sp)
    80004aba:	6121                	addi	sp,sp,64
    80004abc:	8082                	ret
    iput(ip);
    80004abe:	981ff0ef          	jal	8000443e <iput>
    return -1;
    80004ac2:	557d                	li	a0,-1
    80004ac4:	b7f5                	j	80004ab0 <dirlink+0x78>
      panic("dirlink read");
    80004ac6:	00004517          	auipc	a0,0x4
    80004aca:	b0250513          	addi	a0,a0,-1278 # 800085c8 <etext+0x5c8>
    80004ace:	d13fb0ef          	jal	800007e0 <panic>

0000000080004ad2 <namei>:

struct inode*
namei(char *path)
{
    80004ad2:	1101                	addi	sp,sp,-32
    80004ad4:	ec06                	sd	ra,24(sp)
    80004ad6:	e822                	sd	s0,16(sp)
    80004ad8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004ada:	fe040613          	addi	a2,s0,-32
    80004ade:	4581                	li	a1,0
    80004ae0:	e29ff0ef          	jal	80004908 <namex>
}
    80004ae4:	60e2                	ld	ra,24(sp)
    80004ae6:	6442                	ld	s0,16(sp)
    80004ae8:	6105                	addi	sp,sp,32
    80004aea:	8082                	ret

0000000080004aec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004aec:	1141                	addi	sp,sp,-16
    80004aee:	e406                	sd	ra,8(sp)
    80004af0:	e022                	sd	s0,0(sp)
    80004af2:	0800                	addi	s0,sp,16
    80004af4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004af6:	4585                	li	a1,1
    80004af8:	e11ff0ef          	jal	80004908 <namex>
}
    80004afc:	60a2                	ld	ra,8(sp)
    80004afe:	6402                	ld	s0,0(sp)
    80004b00:	0141                	addi	sp,sp,16
    80004b02:	8082                	ret

0000000080004b04 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004b04:	1101                	addi	sp,sp,-32
    80004b06:	ec06                	sd	ra,24(sp)
    80004b08:	e822                	sd	s0,16(sp)
    80004b0a:	e426                	sd	s1,8(sp)
    80004b0c:	e04a                	sd	s2,0(sp)
    80004b0e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004b10:	0003d917          	auipc	s2,0x3d
    80004b14:	1d090913          	addi	s2,s2,464 # 80041ce0 <log>
    80004b18:	01892583          	lw	a1,24(s2)
    80004b1c:	02492503          	lw	a0,36(s2)
    80004b20:	8d0ff0ef          	jal	80003bf0 <bread>
    80004b24:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004b26:	02892603          	lw	a2,40(s2)
    80004b2a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004b2c:	00c05f63          	blez	a2,80004b4a <write_head+0x46>
    80004b30:	0003d717          	auipc	a4,0x3d
    80004b34:	1dc70713          	addi	a4,a4,476 # 80041d0c <log+0x2c>
    80004b38:	87aa                	mv	a5,a0
    80004b3a:	060a                	slli	a2,a2,0x2
    80004b3c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004b3e:	4314                	lw	a3,0(a4)
    80004b40:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004b42:	0711                	addi	a4,a4,4
    80004b44:	0791                	addi	a5,a5,4
    80004b46:	fec79ce3          	bne	a5,a2,80004b3e <write_head+0x3a>
  }
  bwrite(buf);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	97aff0ef          	jal	80003cc6 <bwrite>
  brelse(buf);
    80004b50:	8526                	mv	a0,s1
    80004b52:	9a6ff0ef          	jal	80003cf8 <brelse>
}
    80004b56:	60e2                	ld	ra,24(sp)
    80004b58:	6442                	ld	s0,16(sp)
    80004b5a:	64a2                	ld	s1,8(sp)
    80004b5c:	6902                	ld	s2,0(sp)
    80004b5e:	6105                	addi	sp,sp,32
    80004b60:	8082                	ret

0000000080004b62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b62:	0003d797          	auipc	a5,0x3d
    80004b66:	1a67a783          	lw	a5,422(a5) # 80041d08 <log+0x28>
    80004b6a:	0af05e63          	blez	a5,80004c26 <install_trans+0xc4>
{
    80004b6e:	715d                	addi	sp,sp,-80
    80004b70:	e486                	sd	ra,72(sp)
    80004b72:	e0a2                	sd	s0,64(sp)
    80004b74:	fc26                	sd	s1,56(sp)
    80004b76:	f84a                	sd	s2,48(sp)
    80004b78:	f44e                	sd	s3,40(sp)
    80004b7a:	f052                	sd	s4,32(sp)
    80004b7c:	ec56                	sd	s5,24(sp)
    80004b7e:	e85a                	sd	s6,16(sp)
    80004b80:	e45e                	sd	s7,8(sp)
    80004b82:	0880                	addi	s0,sp,80
    80004b84:	8b2a                	mv	s6,a0
    80004b86:	0003da97          	auipc	s5,0x3d
    80004b8a:	186a8a93          	addi	s5,s5,390 # 80041d0c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b8e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004b90:	00004b97          	auipc	s7,0x4
    80004b94:	a48b8b93          	addi	s7,s7,-1464 # 800085d8 <etext+0x5d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b98:	0003da17          	auipc	s4,0x3d
    80004b9c:	148a0a13          	addi	s4,s4,328 # 80041ce0 <log>
    80004ba0:	a025                	j	80004bc8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004ba2:	000aa603          	lw	a2,0(s5)
    80004ba6:	85ce                	mv	a1,s3
    80004ba8:	855e                	mv	a0,s7
    80004baa:	951fb0ef          	jal	800004fa <printf>
    80004bae:	a839                	j	80004bcc <install_trans+0x6a>
    brelse(lbuf);
    80004bb0:	854a                	mv	a0,s2
    80004bb2:	946ff0ef          	jal	80003cf8 <brelse>
    brelse(dbuf);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	940ff0ef          	jal	80003cf8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bbc:	2985                	addiw	s3,s3,1
    80004bbe:	0a91                	addi	s5,s5,4
    80004bc0:	028a2783          	lw	a5,40(s4)
    80004bc4:	04f9d663          	bge	s3,a5,80004c10 <install_trans+0xae>
    if(recovering) {
    80004bc8:	fc0b1de3          	bnez	s6,80004ba2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004bcc:	018a2583          	lw	a1,24(s4)
    80004bd0:	013585bb          	addw	a1,a1,s3
    80004bd4:	2585                	addiw	a1,a1,1
    80004bd6:	024a2503          	lw	a0,36(s4)
    80004bda:	816ff0ef          	jal	80003bf0 <bread>
    80004bde:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004be0:	000aa583          	lw	a1,0(s5)
    80004be4:	024a2503          	lw	a0,36(s4)
    80004be8:	808ff0ef          	jal	80003bf0 <bread>
    80004bec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004bee:	40000613          	li	a2,1024
    80004bf2:	05890593          	addi	a1,s2,88
    80004bf6:	05850513          	addi	a0,a0,88
    80004bfa:	b10fc0ef          	jal	80000f0a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004bfe:	8526                	mv	a0,s1
    80004c00:	8c6ff0ef          	jal	80003cc6 <bwrite>
    if(recovering == 0)
    80004c04:	fa0b16e3          	bnez	s6,80004bb0 <install_trans+0x4e>
      bunpin(dbuf);
    80004c08:	8526                	mv	a0,s1
    80004c0a:	9aaff0ef          	jal	80003db4 <bunpin>
    80004c0e:	b74d                	j	80004bb0 <install_trans+0x4e>
}
    80004c10:	60a6                	ld	ra,72(sp)
    80004c12:	6406                	ld	s0,64(sp)
    80004c14:	74e2                	ld	s1,56(sp)
    80004c16:	7942                	ld	s2,48(sp)
    80004c18:	79a2                	ld	s3,40(sp)
    80004c1a:	7a02                	ld	s4,32(sp)
    80004c1c:	6ae2                	ld	s5,24(sp)
    80004c1e:	6b42                	ld	s6,16(sp)
    80004c20:	6ba2                	ld	s7,8(sp)
    80004c22:	6161                	addi	sp,sp,80
    80004c24:	8082                	ret
    80004c26:	8082                	ret

0000000080004c28 <initlog>:
{
    80004c28:	7179                	addi	sp,sp,-48
    80004c2a:	f406                	sd	ra,40(sp)
    80004c2c:	f022                	sd	s0,32(sp)
    80004c2e:	ec26                	sd	s1,24(sp)
    80004c30:	e84a                	sd	s2,16(sp)
    80004c32:	e44e                	sd	s3,8(sp)
    80004c34:	1800                	addi	s0,sp,48
    80004c36:	892a                	mv	s2,a0
    80004c38:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c3a:	0003d497          	auipc	s1,0x3d
    80004c3e:	0a648493          	addi	s1,s1,166 # 80041ce0 <log>
    80004c42:	00004597          	auipc	a1,0x4
    80004c46:	9b658593          	addi	a1,a1,-1610 # 800085f8 <etext+0x5f8>
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	90efc0ef          	jal	80000d5a <initlock>
  log.start = sb->logstart;
    80004c50:	0149a583          	lw	a1,20(s3)
    80004c54:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80004c56:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004c5a:	854a                	mv	a0,s2
    80004c5c:	f95fe0ef          	jal	80003bf0 <bread>
  log.lh.n = lh->n;
    80004c60:	4d30                	lw	a2,88(a0)
    80004c62:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004c64:	00c05f63          	blez	a2,80004c82 <initlog+0x5a>
    80004c68:	87aa                	mv	a5,a0
    80004c6a:	0003d717          	auipc	a4,0x3d
    80004c6e:	0a270713          	addi	a4,a4,162 # 80041d0c <log+0x2c>
    80004c72:	060a                	slli	a2,a2,0x2
    80004c74:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004c76:	4ff4                	lw	a3,92(a5)
    80004c78:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004c7a:	0791                	addi	a5,a5,4
    80004c7c:	0711                	addi	a4,a4,4
    80004c7e:	fec79ce3          	bne	a5,a2,80004c76 <initlog+0x4e>
  brelse(buf);
    80004c82:	876ff0ef          	jal	80003cf8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004c86:	4505                	li	a0,1
    80004c88:	edbff0ef          	jal	80004b62 <install_trans>
  log.lh.n = 0;
    80004c8c:	0003d797          	auipc	a5,0x3d
    80004c90:	0607ae23          	sw	zero,124(a5) # 80041d08 <log+0x28>
  write_head(); // clear the log
    80004c94:	e71ff0ef          	jal	80004b04 <write_head>
}
    80004c98:	70a2                	ld	ra,40(sp)
    80004c9a:	7402                	ld	s0,32(sp)
    80004c9c:	64e2                	ld	s1,24(sp)
    80004c9e:	6942                	ld	s2,16(sp)
    80004ca0:	69a2                	ld	s3,8(sp)
    80004ca2:	6145                	addi	sp,sp,48
    80004ca4:	8082                	ret

0000000080004ca6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004ca6:	1101                	addi	sp,sp,-32
    80004ca8:	ec06                	sd	ra,24(sp)
    80004caa:	e822                	sd	s0,16(sp)
    80004cac:	e426                	sd	s1,8(sp)
    80004cae:	e04a                	sd	s2,0(sp)
    80004cb0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004cb2:	0003d517          	auipc	a0,0x3d
    80004cb6:	02e50513          	addi	a0,a0,46 # 80041ce0 <log>
    80004cba:	920fc0ef          	jal	80000dda <acquire>
  while(1){
    if(log.committing){
    80004cbe:	0003d497          	auipc	s1,0x3d
    80004cc2:	02248493          	addi	s1,s1,34 # 80041ce0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004cc6:	4979                	li	s2,30
    80004cc8:	a029                	j	80004cd2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004cca:	85a6                	mv	a1,s1
    80004ccc:	8526                	mv	a0,s1
    80004cce:	c9dfd0ef          	jal	8000296a <sleep>
    if(log.committing){
    80004cd2:	509c                	lw	a5,32(s1)
    80004cd4:	fbfd                	bnez	a5,80004cca <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004cd6:	4cd8                	lw	a4,28(s1)
    80004cd8:	2705                	addiw	a4,a4,1
    80004cda:	0027179b          	slliw	a5,a4,0x2
    80004cde:	9fb9                	addw	a5,a5,a4
    80004ce0:	0017979b          	slliw	a5,a5,0x1
    80004ce4:	5494                	lw	a3,40(s1)
    80004ce6:	9fb5                	addw	a5,a5,a3
    80004ce8:	00f95763          	bge	s2,a5,80004cf6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004cec:	85a6                	mv	a1,s1
    80004cee:	8526                	mv	a0,s1
    80004cf0:	c7bfd0ef          	jal	8000296a <sleep>
    80004cf4:	bff9                	j	80004cd2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004cf6:	0003d517          	auipc	a0,0x3d
    80004cfa:	fea50513          	addi	a0,a0,-22 # 80041ce0 <log>
    80004cfe:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004d00:	972fc0ef          	jal	80000e72 <release>
      break;
    }
  }
}
    80004d04:	60e2                	ld	ra,24(sp)
    80004d06:	6442                	ld	s0,16(sp)
    80004d08:	64a2                	ld	s1,8(sp)
    80004d0a:	6902                	ld	s2,0(sp)
    80004d0c:	6105                	addi	sp,sp,32
    80004d0e:	8082                	ret

0000000080004d10 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d10:	7139                	addi	sp,sp,-64
    80004d12:	fc06                	sd	ra,56(sp)
    80004d14:	f822                	sd	s0,48(sp)
    80004d16:	f426                	sd	s1,40(sp)
    80004d18:	f04a                	sd	s2,32(sp)
    80004d1a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d1c:	0003d497          	auipc	s1,0x3d
    80004d20:	fc448493          	addi	s1,s1,-60 # 80041ce0 <log>
    80004d24:	8526                	mv	a0,s1
    80004d26:	8b4fc0ef          	jal	80000dda <acquire>
  log.outstanding -= 1;
    80004d2a:	4cdc                	lw	a5,28(s1)
    80004d2c:	37fd                	addiw	a5,a5,-1
    80004d2e:	0007891b          	sext.w	s2,a5
    80004d32:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004d34:	509c                	lw	a5,32(s1)
    80004d36:	ef9d                	bnez	a5,80004d74 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004d38:	04091763          	bnez	s2,80004d86 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004d3c:	0003d497          	auipc	s1,0x3d
    80004d40:	fa448493          	addi	s1,s1,-92 # 80041ce0 <log>
    80004d44:	4785                	li	a5,1
    80004d46:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	928fc0ef          	jal	80000e72 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004d4e:	549c                	lw	a5,40(s1)
    80004d50:	04f04b63          	bgtz	a5,80004da6 <end_op+0x96>
    acquire(&log.lock);
    80004d54:	0003d497          	auipc	s1,0x3d
    80004d58:	f8c48493          	addi	s1,s1,-116 # 80041ce0 <log>
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	87cfc0ef          	jal	80000dda <acquire>
    log.committing = 0;
    80004d62:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80004d66:	8526                	mv	a0,s1
    80004d68:	c4ffd0ef          	jal	800029b6 <wakeup>
    release(&log.lock);
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	904fc0ef          	jal	80000e72 <release>
}
    80004d72:	a025                	j	80004d9a <end_op+0x8a>
    80004d74:	ec4e                	sd	s3,24(sp)
    80004d76:	e852                	sd	s4,16(sp)
    80004d78:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004d7a:	00004517          	auipc	a0,0x4
    80004d7e:	88650513          	addi	a0,a0,-1914 # 80008600 <etext+0x600>
    80004d82:	a5ffb0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80004d86:	0003d497          	auipc	s1,0x3d
    80004d8a:	f5a48493          	addi	s1,s1,-166 # 80041ce0 <log>
    80004d8e:	8526                	mv	a0,s1
    80004d90:	c27fd0ef          	jal	800029b6 <wakeup>
  release(&log.lock);
    80004d94:	8526                	mv	a0,s1
    80004d96:	8dcfc0ef          	jal	80000e72 <release>
}
    80004d9a:	70e2                	ld	ra,56(sp)
    80004d9c:	7442                	ld	s0,48(sp)
    80004d9e:	74a2                	ld	s1,40(sp)
    80004da0:	7902                	ld	s2,32(sp)
    80004da2:	6121                	addi	sp,sp,64
    80004da4:	8082                	ret
    80004da6:	ec4e                	sd	s3,24(sp)
    80004da8:	e852                	sd	s4,16(sp)
    80004daa:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004dac:	0003da97          	auipc	s5,0x3d
    80004db0:	f60a8a93          	addi	s5,s5,-160 # 80041d0c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004db4:	0003da17          	auipc	s4,0x3d
    80004db8:	f2ca0a13          	addi	s4,s4,-212 # 80041ce0 <log>
    80004dbc:	018a2583          	lw	a1,24(s4)
    80004dc0:	012585bb          	addw	a1,a1,s2
    80004dc4:	2585                	addiw	a1,a1,1
    80004dc6:	024a2503          	lw	a0,36(s4)
    80004dca:	e27fe0ef          	jal	80003bf0 <bread>
    80004dce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004dd0:	000aa583          	lw	a1,0(s5)
    80004dd4:	024a2503          	lw	a0,36(s4)
    80004dd8:	e19fe0ef          	jal	80003bf0 <bread>
    80004ddc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004dde:	40000613          	li	a2,1024
    80004de2:	05850593          	addi	a1,a0,88
    80004de6:	05848513          	addi	a0,s1,88
    80004dea:	920fc0ef          	jal	80000f0a <memmove>
    bwrite(to);  // write the log
    80004dee:	8526                	mv	a0,s1
    80004df0:	ed7fe0ef          	jal	80003cc6 <bwrite>
    brelse(from);
    80004df4:	854e                	mv	a0,s3
    80004df6:	f03fe0ef          	jal	80003cf8 <brelse>
    brelse(to);
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	efdfe0ef          	jal	80003cf8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e00:	2905                	addiw	s2,s2,1
    80004e02:	0a91                	addi	s5,s5,4
    80004e04:	028a2783          	lw	a5,40(s4)
    80004e08:	faf94ae3          	blt	s2,a5,80004dbc <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004e0c:	cf9ff0ef          	jal	80004b04 <write_head>
    install_trans(0); // Now install writes to home locations
    80004e10:	4501                	li	a0,0
    80004e12:	d51ff0ef          	jal	80004b62 <install_trans>
    log.lh.n = 0;
    80004e16:	0003d797          	auipc	a5,0x3d
    80004e1a:	ee07a923          	sw	zero,-270(a5) # 80041d08 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004e1e:	ce7ff0ef          	jal	80004b04 <write_head>
    80004e22:	69e2                	ld	s3,24(sp)
    80004e24:	6a42                	ld	s4,16(sp)
    80004e26:	6aa2                	ld	s5,8(sp)
    80004e28:	b735                	j	80004d54 <end_op+0x44>

0000000080004e2a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004e2a:	1101                	addi	sp,sp,-32
    80004e2c:	ec06                	sd	ra,24(sp)
    80004e2e:	e822                	sd	s0,16(sp)
    80004e30:	e426                	sd	s1,8(sp)
    80004e32:	e04a                	sd	s2,0(sp)
    80004e34:	1000                	addi	s0,sp,32
    80004e36:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004e38:	0003d917          	auipc	s2,0x3d
    80004e3c:	ea890913          	addi	s2,s2,-344 # 80041ce0 <log>
    80004e40:	854a                	mv	a0,s2
    80004e42:	f99fb0ef          	jal	80000dda <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004e46:	02892603          	lw	a2,40(s2)
    80004e4a:	47f5                	li	a5,29
    80004e4c:	04c7cc63          	blt	a5,a2,80004ea4 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004e50:	0003d797          	auipc	a5,0x3d
    80004e54:	eac7a783          	lw	a5,-340(a5) # 80041cfc <log+0x1c>
    80004e58:	04f05c63          	blez	a5,80004eb0 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004e5c:	4781                	li	a5,0
    80004e5e:	04c05f63          	blez	a2,80004ebc <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004e62:	44cc                	lw	a1,12(s1)
    80004e64:	0003d717          	auipc	a4,0x3d
    80004e68:	ea870713          	addi	a4,a4,-344 # 80041d0c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004e6c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004e6e:	4314                	lw	a3,0(a4)
    80004e70:	04b68663          	beq	a3,a1,80004ebc <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004e74:	2785                	addiw	a5,a5,1
    80004e76:	0711                	addi	a4,a4,4
    80004e78:	fef61be3          	bne	a2,a5,80004e6e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004e7c:	0621                	addi	a2,a2,8
    80004e7e:	060a                	slli	a2,a2,0x2
    80004e80:	0003d797          	auipc	a5,0x3d
    80004e84:	e6078793          	addi	a5,a5,-416 # 80041ce0 <log>
    80004e88:	97b2                	add	a5,a5,a2
    80004e8a:	44d8                	lw	a4,12(s1)
    80004e8c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004e8e:	8526                	mv	a0,s1
    80004e90:	ef1fe0ef          	jal	80003d80 <bpin>
    log.lh.n++;
    80004e94:	0003d717          	auipc	a4,0x3d
    80004e98:	e4c70713          	addi	a4,a4,-436 # 80041ce0 <log>
    80004e9c:	571c                	lw	a5,40(a4)
    80004e9e:	2785                	addiw	a5,a5,1
    80004ea0:	d71c                	sw	a5,40(a4)
    80004ea2:	a80d                	j	80004ed4 <log_write+0xaa>
    panic("too big a transaction");
    80004ea4:	00003517          	auipc	a0,0x3
    80004ea8:	76c50513          	addi	a0,a0,1900 # 80008610 <etext+0x610>
    80004eac:	935fb0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004eb0:	00003517          	auipc	a0,0x3
    80004eb4:	77850513          	addi	a0,a0,1912 # 80008628 <etext+0x628>
    80004eb8:	929fb0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004ebc:	00878693          	addi	a3,a5,8
    80004ec0:	068a                	slli	a3,a3,0x2
    80004ec2:	0003d717          	auipc	a4,0x3d
    80004ec6:	e1e70713          	addi	a4,a4,-482 # 80041ce0 <log>
    80004eca:	9736                	add	a4,a4,a3
    80004ecc:	44d4                	lw	a3,12(s1)
    80004ece:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004ed0:	faf60fe3          	beq	a2,a5,80004e8e <log_write+0x64>
  }
  release(&log.lock);
    80004ed4:	0003d517          	auipc	a0,0x3d
    80004ed8:	e0c50513          	addi	a0,a0,-500 # 80041ce0 <log>
    80004edc:	f97fb0ef          	jal	80000e72 <release>
}
    80004ee0:	60e2                	ld	ra,24(sp)
    80004ee2:	6442                	ld	s0,16(sp)
    80004ee4:	64a2                	ld	s1,8(sp)
    80004ee6:	6902                	ld	s2,0(sp)
    80004ee8:	6105                	addi	sp,sp,32
    80004eea:	8082                	ret

0000000080004eec <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004eec:	1101                	addi	sp,sp,-32
    80004eee:	ec06                	sd	ra,24(sp)
    80004ef0:	e822                	sd	s0,16(sp)
    80004ef2:	e426                	sd	s1,8(sp)
    80004ef4:	e04a                	sd	s2,0(sp)
    80004ef6:	1000                	addi	s0,sp,32
    80004ef8:	84aa                	mv	s1,a0
    80004efa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004efc:	00003597          	auipc	a1,0x3
    80004f00:	74c58593          	addi	a1,a1,1868 # 80008648 <etext+0x648>
    80004f04:	0521                	addi	a0,a0,8
    80004f06:	e55fb0ef          	jal	80000d5a <initlock>
  lk->name = name;
    80004f0a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004f0e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f12:	0204a423          	sw	zero,40(s1)
}
    80004f16:	60e2                	ld	ra,24(sp)
    80004f18:	6442                	ld	s0,16(sp)
    80004f1a:	64a2                	ld	s1,8(sp)
    80004f1c:	6902                	ld	s2,0(sp)
    80004f1e:	6105                	addi	sp,sp,32
    80004f20:	8082                	ret

0000000080004f22 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004f22:	1101                	addi	sp,sp,-32
    80004f24:	ec06                	sd	ra,24(sp)
    80004f26:	e822                	sd	s0,16(sp)
    80004f28:	e426                	sd	s1,8(sp)
    80004f2a:	e04a                	sd	s2,0(sp)
    80004f2c:	1000                	addi	s0,sp,32
    80004f2e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004f30:	00850913          	addi	s2,a0,8
    80004f34:	854a                	mv	a0,s2
    80004f36:	ea5fb0ef          	jal	80000dda <acquire>
  while (lk->locked) {
    80004f3a:	409c                	lw	a5,0(s1)
    80004f3c:	c799                	beqz	a5,80004f4a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004f3e:	85ca                	mv	a1,s2
    80004f40:	8526                	mv	a0,s1
    80004f42:	a29fd0ef          	jal	8000296a <sleep>
  while (lk->locked) {
    80004f46:	409c                	lw	a5,0(s1)
    80004f48:	fbfd                	bnez	a5,80004f3e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004f4a:	4785                	li	a5,1
    80004f4c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004f4e:	e19fc0ef          	jal	80001d66 <myproc>
    80004f52:	591c                	lw	a5,48(a0)
    80004f54:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004f56:	854a                	mv	a0,s2
    80004f58:	f1bfb0ef          	jal	80000e72 <release>
}
    80004f5c:	60e2                	ld	ra,24(sp)
    80004f5e:	6442                	ld	s0,16(sp)
    80004f60:	64a2                	ld	s1,8(sp)
    80004f62:	6902                	ld	s2,0(sp)
    80004f64:	6105                	addi	sp,sp,32
    80004f66:	8082                	ret

0000000080004f68 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004f68:	1101                	addi	sp,sp,-32
    80004f6a:	ec06                	sd	ra,24(sp)
    80004f6c:	e822                	sd	s0,16(sp)
    80004f6e:	e426                	sd	s1,8(sp)
    80004f70:	e04a                	sd	s2,0(sp)
    80004f72:	1000                	addi	s0,sp,32
    80004f74:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004f76:	00850913          	addi	s2,a0,8
    80004f7a:	854a                	mv	a0,s2
    80004f7c:	e5ffb0ef          	jal	80000dda <acquire>
  lk->locked = 0;
    80004f80:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f84:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	a2dfd0ef          	jal	800029b6 <wakeup>
  release(&lk->lk);
    80004f8e:	854a                	mv	a0,s2
    80004f90:	ee3fb0ef          	jal	80000e72 <release>
}
    80004f94:	60e2                	ld	ra,24(sp)
    80004f96:	6442                	ld	s0,16(sp)
    80004f98:	64a2                	ld	s1,8(sp)
    80004f9a:	6902                	ld	s2,0(sp)
    80004f9c:	6105                	addi	sp,sp,32
    80004f9e:	8082                	ret

0000000080004fa0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004fa0:	7179                	addi	sp,sp,-48
    80004fa2:	f406                	sd	ra,40(sp)
    80004fa4:	f022                	sd	s0,32(sp)
    80004fa6:	ec26                	sd	s1,24(sp)
    80004fa8:	e84a                	sd	s2,16(sp)
    80004faa:	1800                	addi	s0,sp,48
    80004fac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004fae:	00850913          	addi	s2,a0,8
    80004fb2:	854a                	mv	a0,s2
    80004fb4:	e27fb0ef          	jal	80000dda <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004fb8:	409c                	lw	a5,0(s1)
    80004fba:	ef81                	bnez	a5,80004fd2 <holdingsleep+0x32>
    80004fbc:	4481                	li	s1,0
  release(&lk->lk);
    80004fbe:	854a                	mv	a0,s2
    80004fc0:	eb3fb0ef          	jal	80000e72 <release>
  return r;
}
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	70a2                	ld	ra,40(sp)
    80004fc8:	7402                	ld	s0,32(sp)
    80004fca:	64e2                	ld	s1,24(sp)
    80004fcc:	6942                	ld	s2,16(sp)
    80004fce:	6145                	addi	sp,sp,48
    80004fd0:	8082                	ret
    80004fd2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004fd4:	0284a983          	lw	s3,40(s1)
    80004fd8:	d8ffc0ef          	jal	80001d66 <myproc>
    80004fdc:	5904                	lw	s1,48(a0)
    80004fde:	413484b3          	sub	s1,s1,s3
    80004fe2:	0014b493          	seqz	s1,s1
    80004fe6:	69a2                	ld	s3,8(sp)
    80004fe8:	bfd9                	j	80004fbe <holdingsleep+0x1e>

0000000080004fea <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004fea:	1141                	addi	sp,sp,-16
    80004fec:	e406                	sd	ra,8(sp)
    80004fee:	e022                	sd	s0,0(sp)
    80004ff0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ff2:	00003597          	auipc	a1,0x3
    80004ff6:	66658593          	addi	a1,a1,1638 # 80008658 <etext+0x658>
    80004ffa:	0003d517          	auipc	a0,0x3d
    80004ffe:	e2e50513          	addi	a0,a0,-466 # 80041e28 <ftable>
    80005002:	d59fb0ef          	jal	80000d5a <initlock>
}
    80005006:	60a2                	ld	ra,8(sp)
    80005008:	6402                	ld	s0,0(sp)
    8000500a:	0141                	addi	sp,sp,16
    8000500c:	8082                	ret

000000008000500e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000500e:	1101                	addi	sp,sp,-32
    80005010:	ec06                	sd	ra,24(sp)
    80005012:	e822                	sd	s0,16(sp)
    80005014:	e426                	sd	s1,8(sp)
    80005016:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005018:	0003d517          	auipc	a0,0x3d
    8000501c:	e1050513          	addi	a0,a0,-496 # 80041e28 <ftable>
    80005020:	dbbfb0ef          	jal	80000dda <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005024:	0003d497          	auipc	s1,0x3d
    80005028:	e1c48493          	addi	s1,s1,-484 # 80041e40 <ftable+0x18>
    8000502c:	0003e717          	auipc	a4,0x3e
    80005030:	db470713          	addi	a4,a4,-588 # 80042de0 <disk>
    if(f->ref == 0){
    80005034:	40dc                	lw	a5,4(s1)
    80005036:	cf89                	beqz	a5,80005050 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005038:	02848493          	addi	s1,s1,40
    8000503c:	fee49ce3          	bne	s1,a4,80005034 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005040:	0003d517          	auipc	a0,0x3d
    80005044:	de850513          	addi	a0,a0,-536 # 80041e28 <ftable>
    80005048:	e2bfb0ef          	jal	80000e72 <release>
  return 0;
    8000504c:	4481                	li	s1,0
    8000504e:	a809                	j	80005060 <filealloc+0x52>
      f->ref = 1;
    80005050:	4785                	li	a5,1
    80005052:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005054:	0003d517          	auipc	a0,0x3d
    80005058:	dd450513          	addi	a0,a0,-556 # 80041e28 <ftable>
    8000505c:	e17fb0ef          	jal	80000e72 <release>
}
    80005060:	8526                	mv	a0,s1
    80005062:	60e2                	ld	ra,24(sp)
    80005064:	6442                	ld	s0,16(sp)
    80005066:	64a2                	ld	s1,8(sp)
    80005068:	6105                	addi	sp,sp,32
    8000506a:	8082                	ret

000000008000506c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000506c:	1101                	addi	sp,sp,-32
    8000506e:	ec06                	sd	ra,24(sp)
    80005070:	e822                	sd	s0,16(sp)
    80005072:	e426                	sd	s1,8(sp)
    80005074:	1000                	addi	s0,sp,32
    80005076:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005078:	0003d517          	auipc	a0,0x3d
    8000507c:	db050513          	addi	a0,a0,-592 # 80041e28 <ftable>
    80005080:	d5bfb0ef          	jal	80000dda <acquire>
  if(f->ref < 1)
    80005084:	40dc                	lw	a5,4(s1)
    80005086:	02f05063          	blez	a5,800050a6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000508a:	2785                	addiw	a5,a5,1
    8000508c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000508e:	0003d517          	auipc	a0,0x3d
    80005092:	d9a50513          	addi	a0,a0,-614 # 80041e28 <ftable>
    80005096:	dddfb0ef          	jal	80000e72 <release>
  return f;
}
    8000509a:	8526                	mv	a0,s1
    8000509c:	60e2                	ld	ra,24(sp)
    8000509e:	6442                	ld	s0,16(sp)
    800050a0:	64a2                	ld	s1,8(sp)
    800050a2:	6105                	addi	sp,sp,32
    800050a4:	8082                	ret
    panic("filedup");
    800050a6:	00003517          	auipc	a0,0x3
    800050aa:	5ba50513          	addi	a0,a0,1466 # 80008660 <etext+0x660>
    800050ae:	f32fb0ef          	jal	800007e0 <panic>

00000000800050b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800050b2:	7139                	addi	sp,sp,-64
    800050b4:	fc06                	sd	ra,56(sp)
    800050b6:	f822                	sd	s0,48(sp)
    800050b8:	f426                	sd	s1,40(sp)
    800050ba:	0080                	addi	s0,sp,64
    800050bc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800050be:	0003d517          	auipc	a0,0x3d
    800050c2:	d6a50513          	addi	a0,a0,-662 # 80041e28 <ftable>
    800050c6:	d15fb0ef          	jal	80000dda <acquire>
  if(f->ref < 1)
    800050ca:	40dc                	lw	a5,4(s1)
    800050cc:	04f05a63          	blez	a5,80005120 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800050d0:	37fd                	addiw	a5,a5,-1
    800050d2:	0007871b          	sext.w	a4,a5
    800050d6:	c0dc                	sw	a5,4(s1)
    800050d8:	04e04e63          	bgtz	a4,80005134 <fileclose+0x82>
    800050dc:	f04a                	sd	s2,32(sp)
    800050de:	ec4e                	sd	s3,24(sp)
    800050e0:	e852                	sd	s4,16(sp)
    800050e2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800050e4:	0004a903          	lw	s2,0(s1)
    800050e8:	0094ca83          	lbu	s5,9(s1)
    800050ec:	0104ba03          	ld	s4,16(s1)
    800050f0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800050f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800050f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800050fc:	0003d517          	auipc	a0,0x3d
    80005100:	d2c50513          	addi	a0,a0,-724 # 80041e28 <ftable>
    80005104:	d6ffb0ef          	jal	80000e72 <release>

  if(ff.type == FD_PIPE){
    80005108:	4785                	li	a5,1
    8000510a:	04f90063          	beq	s2,a5,8000514a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000510e:	3979                	addiw	s2,s2,-2
    80005110:	4785                	li	a5,1
    80005112:	0527f563          	bgeu	a5,s2,8000515c <fileclose+0xaa>
    80005116:	7902                	ld	s2,32(sp)
    80005118:	69e2                	ld	s3,24(sp)
    8000511a:	6a42                	ld	s4,16(sp)
    8000511c:	6aa2                	ld	s5,8(sp)
    8000511e:	a00d                	j	80005140 <fileclose+0x8e>
    80005120:	f04a                	sd	s2,32(sp)
    80005122:	ec4e                	sd	s3,24(sp)
    80005124:	e852                	sd	s4,16(sp)
    80005126:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80005128:	00003517          	auipc	a0,0x3
    8000512c:	54050513          	addi	a0,a0,1344 # 80008668 <etext+0x668>
    80005130:	eb0fb0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80005134:	0003d517          	auipc	a0,0x3d
    80005138:	cf450513          	addi	a0,a0,-780 # 80041e28 <ftable>
    8000513c:	d37fb0ef          	jal	80000e72 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80005140:	70e2                	ld	ra,56(sp)
    80005142:	7442                	ld	s0,48(sp)
    80005144:	74a2                	ld	s1,40(sp)
    80005146:	6121                	addi	sp,sp,64
    80005148:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000514a:	85d6                	mv	a1,s5
    8000514c:	8552                	mv	a0,s4
    8000514e:	336000ef          	jal	80005484 <pipeclose>
    80005152:	7902                	ld	s2,32(sp)
    80005154:	69e2                	ld	s3,24(sp)
    80005156:	6a42                	ld	s4,16(sp)
    80005158:	6aa2                	ld	s5,8(sp)
    8000515a:	b7dd                	j	80005140 <fileclose+0x8e>
    begin_op();
    8000515c:	b4bff0ef          	jal	80004ca6 <begin_op>
    iput(ff.ip);
    80005160:	854e                	mv	a0,s3
    80005162:	adcff0ef          	jal	8000443e <iput>
    end_op();
    80005166:	babff0ef          	jal	80004d10 <end_op>
    8000516a:	7902                	ld	s2,32(sp)
    8000516c:	69e2                	ld	s3,24(sp)
    8000516e:	6a42                	ld	s4,16(sp)
    80005170:	6aa2                	ld	s5,8(sp)
    80005172:	b7f9                	j	80005140 <fileclose+0x8e>

0000000080005174 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005174:	715d                	addi	sp,sp,-80
    80005176:	e486                	sd	ra,72(sp)
    80005178:	e0a2                	sd	s0,64(sp)
    8000517a:	fc26                	sd	s1,56(sp)
    8000517c:	f44e                	sd	s3,40(sp)
    8000517e:	0880                	addi	s0,sp,80
    80005180:	84aa                	mv	s1,a0
    80005182:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005184:	be3fc0ef          	jal	80001d66 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005188:	409c                	lw	a5,0(s1)
    8000518a:	37f9                	addiw	a5,a5,-2
    8000518c:	4705                	li	a4,1
    8000518e:	04f76063          	bltu	a4,a5,800051ce <filestat+0x5a>
    80005192:	f84a                	sd	s2,48(sp)
    80005194:	892a                	mv	s2,a0
    ilock(f->ip);
    80005196:	6c88                	ld	a0,24(s1)
    80005198:	924ff0ef          	jal	800042bc <ilock>
    stati(f->ip, &st);
    8000519c:	fb840593          	addi	a1,s0,-72
    800051a0:	6c88                	ld	a0,24(s1)
    800051a2:	c80ff0ef          	jal	80004622 <stati>
    iunlock(f->ip);
    800051a6:	6c88                	ld	a0,24(s1)
    800051a8:	9c2ff0ef          	jal	8000436a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800051ac:	46e1                	li	a3,24
    800051ae:	fb840613          	addi	a2,s0,-72
    800051b2:	85ce                	mv	a1,s3
    800051b4:	05093503          	ld	a0,80(s2)
    800051b8:	f8cfc0ef          	jal	80001944 <copyout>
    800051bc:	41f5551b          	sraiw	a0,a0,0x1f
    800051c0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800051c2:	60a6                	ld	ra,72(sp)
    800051c4:	6406                	ld	s0,64(sp)
    800051c6:	74e2                	ld	s1,56(sp)
    800051c8:	79a2                	ld	s3,40(sp)
    800051ca:	6161                	addi	sp,sp,80
    800051cc:	8082                	ret
  return -1;
    800051ce:	557d                	li	a0,-1
    800051d0:	bfcd                	j	800051c2 <filestat+0x4e>

00000000800051d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800051d2:	7179                	addi	sp,sp,-48
    800051d4:	f406                	sd	ra,40(sp)
    800051d6:	f022                	sd	s0,32(sp)
    800051d8:	e84a                	sd	s2,16(sp)
    800051da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800051dc:	00854783          	lbu	a5,8(a0)
    800051e0:	cfd1                	beqz	a5,8000527c <fileread+0xaa>
    800051e2:	ec26                	sd	s1,24(sp)
    800051e4:	e44e                	sd	s3,8(sp)
    800051e6:	84aa                	mv	s1,a0
    800051e8:	89ae                	mv	s3,a1
    800051ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800051ec:	411c                	lw	a5,0(a0)
    800051ee:	4705                	li	a4,1
    800051f0:	04e78363          	beq	a5,a4,80005236 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051f4:	470d                	li	a4,3
    800051f6:	04e78763          	beq	a5,a4,80005244 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800051fa:	4709                	li	a4,2
    800051fc:	06e79a63          	bne	a5,a4,80005270 <fileread+0x9e>
    ilock(f->ip);
    80005200:	6d08                	ld	a0,24(a0)
    80005202:	8baff0ef          	jal	800042bc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005206:	874a                	mv	a4,s2
    80005208:	5094                	lw	a3,32(s1)
    8000520a:	864e                	mv	a2,s3
    8000520c:	4585                	li	a1,1
    8000520e:	6c88                	ld	a0,24(s1)
    80005210:	c3cff0ef          	jal	8000464c <readi>
    80005214:	892a                	mv	s2,a0
    80005216:	00a05563          	blez	a0,80005220 <fileread+0x4e>
      f->off += r;
    8000521a:	509c                	lw	a5,32(s1)
    8000521c:	9fa9                	addw	a5,a5,a0
    8000521e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005220:	6c88                	ld	a0,24(s1)
    80005222:	948ff0ef          	jal	8000436a <iunlock>
    80005226:	64e2                	ld	s1,24(sp)
    80005228:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000522a:	854a                	mv	a0,s2
    8000522c:	70a2                	ld	ra,40(sp)
    8000522e:	7402                	ld	s0,32(sp)
    80005230:	6942                	ld	s2,16(sp)
    80005232:	6145                	addi	sp,sp,48
    80005234:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005236:	6908                	ld	a0,16(a0)
    80005238:	388000ef          	jal	800055c0 <piperead>
    8000523c:	892a                	mv	s2,a0
    8000523e:	64e2                	ld	s1,24(sp)
    80005240:	69a2                	ld	s3,8(sp)
    80005242:	b7e5                	j	8000522a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005244:	02451783          	lh	a5,36(a0)
    80005248:	03079693          	slli	a3,a5,0x30
    8000524c:	92c1                	srli	a3,a3,0x30
    8000524e:	4725                	li	a4,9
    80005250:	02d76863          	bltu	a4,a3,80005280 <fileread+0xae>
    80005254:	0792                	slli	a5,a5,0x4
    80005256:	0003d717          	auipc	a4,0x3d
    8000525a:	b3270713          	addi	a4,a4,-1230 # 80041d88 <devsw>
    8000525e:	97ba                	add	a5,a5,a4
    80005260:	639c                	ld	a5,0(a5)
    80005262:	c39d                	beqz	a5,80005288 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80005264:	4505                	li	a0,1
    80005266:	9782                	jalr	a5
    80005268:	892a                	mv	s2,a0
    8000526a:	64e2                	ld	s1,24(sp)
    8000526c:	69a2                	ld	s3,8(sp)
    8000526e:	bf75                	j	8000522a <fileread+0x58>
    panic("fileread");
    80005270:	00003517          	auipc	a0,0x3
    80005274:	40850513          	addi	a0,a0,1032 # 80008678 <etext+0x678>
    80005278:	d68fb0ef          	jal	800007e0 <panic>
    return -1;
    8000527c:	597d                	li	s2,-1
    8000527e:	b775                	j	8000522a <fileread+0x58>
      return -1;
    80005280:	597d                	li	s2,-1
    80005282:	64e2                	ld	s1,24(sp)
    80005284:	69a2                	ld	s3,8(sp)
    80005286:	b755                	j	8000522a <fileread+0x58>
    80005288:	597d                	li	s2,-1
    8000528a:	64e2                	ld	s1,24(sp)
    8000528c:	69a2                	ld	s3,8(sp)
    8000528e:	bf71                	j	8000522a <fileread+0x58>

0000000080005290 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005290:	00954783          	lbu	a5,9(a0)
    80005294:	10078b63          	beqz	a5,800053aa <filewrite+0x11a>
{
    80005298:	715d                	addi	sp,sp,-80
    8000529a:	e486                	sd	ra,72(sp)
    8000529c:	e0a2                	sd	s0,64(sp)
    8000529e:	f84a                	sd	s2,48(sp)
    800052a0:	f052                	sd	s4,32(sp)
    800052a2:	e85a                	sd	s6,16(sp)
    800052a4:	0880                	addi	s0,sp,80
    800052a6:	892a                	mv	s2,a0
    800052a8:	8b2e                	mv	s6,a1
    800052aa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800052ac:	411c                	lw	a5,0(a0)
    800052ae:	4705                	li	a4,1
    800052b0:	02e78763          	beq	a5,a4,800052de <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800052b4:	470d                	li	a4,3
    800052b6:	02e78863          	beq	a5,a4,800052e6 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800052ba:	4709                	li	a4,2
    800052bc:	0ce79c63          	bne	a5,a4,80005394 <filewrite+0x104>
    800052c0:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800052c2:	0ac05863          	blez	a2,80005372 <filewrite+0xe2>
    800052c6:	fc26                	sd	s1,56(sp)
    800052c8:	ec56                	sd	s5,24(sp)
    800052ca:	e45e                	sd	s7,8(sp)
    800052cc:	e062                	sd	s8,0(sp)
    int i = 0;
    800052ce:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800052d0:	6b85                	lui	s7,0x1
    800052d2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800052d6:	6c05                	lui	s8,0x1
    800052d8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800052dc:	a8b5                	j	80005358 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800052de:	6908                	ld	a0,16(a0)
    800052e0:	1fc000ef          	jal	800054dc <pipewrite>
    800052e4:	a04d                	j	80005386 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800052e6:	02451783          	lh	a5,36(a0)
    800052ea:	03079693          	slli	a3,a5,0x30
    800052ee:	92c1                	srli	a3,a3,0x30
    800052f0:	4725                	li	a4,9
    800052f2:	0ad76e63          	bltu	a4,a3,800053ae <filewrite+0x11e>
    800052f6:	0792                	slli	a5,a5,0x4
    800052f8:	0003d717          	auipc	a4,0x3d
    800052fc:	a9070713          	addi	a4,a4,-1392 # 80041d88 <devsw>
    80005300:	97ba                	add	a5,a5,a4
    80005302:	679c                	ld	a5,8(a5)
    80005304:	c7dd                	beqz	a5,800053b2 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80005306:	4505                	li	a0,1
    80005308:	9782                	jalr	a5
    8000530a:	a8b5                	j	80005386 <filewrite+0xf6>
      if(n1 > max)
    8000530c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80005310:	997ff0ef          	jal	80004ca6 <begin_op>
      ilock(f->ip);
    80005314:	01893503          	ld	a0,24(s2)
    80005318:	fa5fe0ef          	jal	800042bc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000531c:	8756                	mv	a4,s5
    8000531e:	02092683          	lw	a3,32(s2)
    80005322:	01698633          	add	a2,s3,s6
    80005326:	4585                	li	a1,1
    80005328:	01893503          	ld	a0,24(s2)
    8000532c:	c1cff0ef          	jal	80004748 <writei>
    80005330:	84aa                	mv	s1,a0
    80005332:	00a05763          	blez	a0,80005340 <filewrite+0xb0>
        f->off += r;
    80005336:	02092783          	lw	a5,32(s2)
    8000533a:	9fa9                	addw	a5,a5,a0
    8000533c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005340:	01893503          	ld	a0,24(s2)
    80005344:	826ff0ef          	jal	8000436a <iunlock>
      end_op();
    80005348:	9c9ff0ef          	jal	80004d10 <end_op>

      if(r != n1){
    8000534c:	029a9563          	bne	s5,s1,80005376 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80005350:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005354:	0149da63          	bge	s3,s4,80005368 <filewrite+0xd8>
      int n1 = n - i;
    80005358:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000535c:	0004879b          	sext.w	a5,s1
    80005360:	fafbd6e3          	bge	s7,a5,8000530c <filewrite+0x7c>
    80005364:	84e2                	mv	s1,s8
    80005366:	b75d                	j	8000530c <filewrite+0x7c>
    80005368:	74e2                	ld	s1,56(sp)
    8000536a:	6ae2                	ld	s5,24(sp)
    8000536c:	6ba2                	ld	s7,8(sp)
    8000536e:	6c02                	ld	s8,0(sp)
    80005370:	a039                	j	8000537e <filewrite+0xee>
    int i = 0;
    80005372:	4981                	li	s3,0
    80005374:	a029                	j	8000537e <filewrite+0xee>
    80005376:	74e2                	ld	s1,56(sp)
    80005378:	6ae2                	ld	s5,24(sp)
    8000537a:	6ba2                	ld	s7,8(sp)
    8000537c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000537e:	033a1c63          	bne	s4,s3,800053b6 <filewrite+0x126>
    80005382:	8552                	mv	a0,s4
    80005384:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005386:	60a6                	ld	ra,72(sp)
    80005388:	6406                	ld	s0,64(sp)
    8000538a:	7942                	ld	s2,48(sp)
    8000538c:	7a02                	ld	s4,32(sp)
    8000538e:	6b42                	ld	s6,16(sp)
    80005390:	6161                	addi	sp,sp,80
    80005392:	8082                	ret
    80005394:	fc26                	sd	s1,56(sp)
    80005396:	f44e                	sd	s3,40(sp)
    80005398:	ec56                	sd	s5,24(sp)
    8000539a:	e45e                	sd	s7,8(sp)
    8000539c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000539e:	00003517          	auipc	a0,0x3
    800053a2:	2ea50513          	addi	a0,a0,746 # 80008688 <etext+0x688>
    800053a6:	c3afb0ef          	jal	800007e0 <panic>
    return -1;
    800053aa:	557d                	li	a0,-1
}
    800053ac:	8082                	ret
      return -1;
    800053ae:	557d                	li	a0,-1
    800053b0:	bfd9                	j	80005386 <filewrite+0xf6>
    800053b2:	557d                	li	a0,-1
    800053b4:	bfc9                	j	80005386 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800053b6:	557d                	li	a0,-1
    800053b8:	79a2                	ld	s3,40(sp)
    800053ba:	b7f1                	j	80005386 <filewrite+0xf6>

00000000800053bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800053bc:	7179                	addi	sp,sp,-48
    800053be:	f406                	sd	ra,40(sp)
    800053c0:	f022                	sd	s0,32(sp)
    800053c2:	ec26                	sd	s1,24(sp)
    800053c4:	e052                	sd	s4,0(sp)
    800053c6:	1800                	addi	s0,sp,48
    800053c8:	84aa                	mv	s1,a0
    800053ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800053cc:	0005b023          	sd	zero,0(a1)
    800053d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800053d4:	c3bff0ef          	jal	8000500e <filealloc>
    800053d8:	e088                	sd	a0,0(s1)
    800053da:	c549                	beqz	a0,80005464 <pipealloc+0xa8>
    800053dc:	c33ff0ef          	jal	8000500e <filealloc>
    800053e0:	00aa3023          	sd	a0,0(s4)
    800053e4:	cd25                	beqz	a0,8000545c <pipealloc+0xa0>
    800053e6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800053e8:	8f9fb0ef          	jal	80000ce0 <kalloc>
    800053ec:	892a                	mv	s2,a0
    800053ee:	c12d                	beqz	a0,80005450 <pipealloc+0x94>
    800053f0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800053f2:	4985                	li	s3,1
    800053f4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800053f8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800053fc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005400:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005404:	00003597          	auipc	a1,0x3
    80005408:	29458593          	addi	a1,a1,660 # 80008698 <etext+0x698>
    8000540c:	94ffb0ef          	jal	80000d5a <initlock>
  (*f0)->type = FD_PIPE;
    80005410:	609c                	ld	a5,0(s1)
    80005412:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005416:	609c                	ld	a5,0(s1)
    80005418:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000541c:	609c                	ld	a5,0(s1)
    8000541e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005422:	609c                	ld	a5,0(s1)
    80005424:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005428:	000a3783          	ld	a5,0(s4)
    8000542c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005430:	000a3783          	ld	a5,0(s4)
    80005434:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005438:	000a3783          	ld	a5,0(s4)
    8000543c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005440:	000a3783          	ld	a5,0(s4)
    80005444:	0127b823          	sd	s2,16(a5)
  return 0;
    80005448:	4501                	li	a0,0
    8000544a:	6942                	ld	s2,16(sp)
    8000544c:	69a2                	ld	s3,8(sp)
    8000544e:	a01d                	j	80005474 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005450:	6088                	ld	a0,0(s1)
    80005452:	c119                	beqz	a0,80005458 <pipealloc+0x9c>
    80005454:	6942                	ld	s2,16(sp)
    80005456:	a029                	j	80005460 <pipealloc+0xa4>
    80005458:	6942                	ld	s2,16(sp)
    8000545a:	a029                	j	80005464 <pipealloc+0xa8>
    8000545c:	6088                	ld	a0,0(s1)
    8000545e:	c10d                	beqz	a0,80005480 <pipealloc+0xc4>
    fileclose(*f0);
    80005460:	c53ff0ef          	jal	800050b2 <fileclose>
  if(*f1)
    80005464:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005468:	557d                	li	a0,-1
  if(*f1)
    8000546a:	c789                	beqz	a5,80005474 <pipealloc+0xb8>
    fileclose(*f1);
    8000546c:	853e                	mv	a0,a5
    8000546e:	c45ff0ef          	jal	800050b2 <fileclose>
  return -1;
    80005472:	557d                	li	a0,-1
}
    80005474:	70a2                	ld	ra,40(sp)
    80005476:	7402                	ld	s0,32(sp)
    80005478:	64e2                	ld	s1,24(sp)
    8000547a:	6a02                	ld	s4,0(sp)
    8000547c:	6145                	addi	sp,sp,48
    8000547e:	8082                	ret
  return -1;
    80005480:	557d                	li	a0,-1
    80005482:	bfcd                	j	80005474 <pipealloc+0xb8>

0000000080005484 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005484:	1101                	addi	sp,sp,-32
    80005486:	ec06                	sd	ra,24(sp)
    80005488:	e822                	sd	s0,16(sp)
    8000548a:	e426                	sd	s1,8(sp)
    8000548c:	e04a                	sd	s2,0(sp)
    8000548e:	1000                	addi	s0,sp,32
    80005490:	84aa                	mv	s1,a0
    80005492:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005494:	947fb0ef          	jal	80000dda <acquire>
  if(writable){
    80005498:	02090763          	beqz	s2,800054c6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000549c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800054a0:	21848513          	addi	a0,s1,536
    800054a4:	d12fd0ef          	jal	800029b6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800054a8:	2204b783          	ld	a5,544(s1)
    800054ac:	e785                	bnez	a5,800054d4 <pipeclose+0x50>
    release(&pi->lock);
    800054ae:	8526                	mv	a0,s1
    800054b0:	9c3fb0ef          	jal	80000e72 <release>
    kfree((char*)pi);
    800054b4:	8526                	mv	a0,s1
    800054b6:	ea8fb0ef          	jal	80000b5e <kfree>
  } else
    release(&pi->lock);
}
    800054ba:	60e2                	ld	ra,24(sp)
    800054bc:	6442                	ld	s0,16(sp)
    800054be:	64a2                	ld	s1,8(sp)
    800054c0:	6902                	ld	s2,0(sp)
    800054c2:	6105                	addi	sp,sp,32
    800054c4:	8082                	ret
    pi->readopen = 0;
    800054c6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800054ca:	21c48513          	addi	a0,s1,540
    800054ce:	ce8fd0ef          	jal	800029b6 <wakeup>
    800054d2:	bfd9                	j	800054a8 <pipeclose+0x24>
    release(&pi->lock);
    800054d4:	8526                	mv	a0,s1
    800054d6:	99dfb0ef          	jal	80000e72 <release>
}
    800054da:	b7c5                	j	800054ba <pipeclose+0x36>

00000000800054dc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800054dc:	711d                	addi	sp,sp,-96
    800054de:	ec86                	sd	ra,88(sp)
    800054e0:	e8a2                	sd	s0,80(sp)
    800054e2:	e4a6                	sd	s1,72(sp)
    800054e4:	e0ca                	sd	s2,64(sp)
    800054e6:	fc4e                	sd	s3,56(sp)
    800054e8:	f852                	sd	s4,48(sp)
    800054ea:	f456                	sd	s5,40(sp)
    800054ec:	1080                	addi	s0,sp,96
    800054ee:	84aa                	mv	s1,a0
    800054f0:	8aae                	mv	s5,a1
    800054f2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800054f4:	873fc0ef          	jal	80001d66 <myproc>
    800054f8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800054fa:	8526                	mv	a0,s1
    800054fc:	8dffb0ef          	jal	80000dda <acquire>
  while(i < n){
    80005500:	0b405a63          	blez	s4,800055b4 <pipewrite+0xd8>
    80005504:	f05a                	sd	s6,32(sp)
    80005506:	ec5e                	sd	s7,24(sp)
    80005508:	e862                	sd	s8,16(sp)
  int i = 0;
    8000550a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000550c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000550e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005512:	21c48b93          	addi	s7,s1,540
    80005516:	a81d                	j	8000554c <pipewrite+0x70>
      release(&pi->lock);
    80005518:	8526                	mv	a0,s1
    8000551a:	959fb0ef          	jal	80000e72 <release>
      return -1;
    8000551e:	597d                	li	s2,-1
    80005520:	7b02                	ld	s6,32(sp)
    80005522:	6be2                	ld	s7,24(sp)
    80005524:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005526:	854a                	mv	a0,s2
    80005528:	60e6                	ld	ra,88(sp)
    8000552a:	6446                	ld	s0,80(sp)
    8000552c:	64a6                	ld	s1,72(sp)
    8000552e:	6906                	ld	s2,64(sp)
    80005530:	79e2                	ld	s3,56(sp)
    80005532:	7a42                	ld	s4,48(sp)
    80005534:	7aa2                	ld	s5,40(sp)
    80005536:	6125                	addi	sp,sp,96
    80005538:	8082                	ret
      wakeup(&pi->nread);
    8000553a:	8562                	mv	a0,s8
    8000553c:	c7afd0ef          	jal	800029b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005540:	85a6                	mv	a1,s1
    80005542:	855e                	mv	a0,s7
    80005544:	c26fd0ef          	jal	8000296a <sleep>
  while(i < n){
    80005548:	05495b63          	bge	s2,s4,8000559e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000554c:	2204a783          	lw	a5,544(s1)
    80005550:	d7e1                	beqz	a5,80005518 <pipewrite+0x3c>
    80005552:	854e                	mv	a0,s3
    80005554:	ee0fd0ef          	jal	80002c34 <killed>
    80005558:	f161                	bnez	a0,80005518 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000555a:	2184a783          	lw	a5,536(s1)
    8000555e:	21c4a703          	lw	a4,540(s1)
    80005562:	2007879b          	addiw	a5,a5,512
    80005566:	fcf70ae3          	beq	a4,a5,8000553a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000556a:	4685                	li	a3,1
    8000556c:	01590633          	add	a2,s2,s5
    80005570:	faf40593          	addi	a1,s0,-81
    80005574:	0509b503          	ld	a0,80(s3)
    80005578:	ce2fc0ef          	jal	80001a5a <copyin>
    8000557c:	03650e63          	beq	a0,s6,800055b8 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005580:	21c4a783          	lw	a5,540(s1)
    80005584:	0017871b          	addiw	a4,a5,1
    80005588:	20e4ae23          	sw	a4,540(s1)
    8000558c:	1ff7f793          	andi	a5,a5,511
    80005590:	97a6                	add	a5,a5,s1
    80005592:	faf44703          	lbu	a4,-81(s0)
    80005596:	00e78c23          	sb	a4,24(a5)
      i++;
    8000559a:	2905                	addiw	s2,s2,1
    8000559c:	b775                	j	80005548 <pipewrite+0x6c>
    8000559e:	7b02                	ld	s6,32(sp)
    800055a0:	6be2                	ld	s7,24(sp)
    800055a2:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800055a4:	21848513          	addi	a0,s1,536
    800055a8:	c0efd0ef          	jal	800029b6 <wakeup>
  release(&pi->lock);
    800055ac:	8526                	mv	a0,s1
    800055ae:	8c5fb0ef          	jal	80000e72 <release>
  return i;
    800055b2:	bf95                	j	80005526 <pipewrite+0x4a>
  int i = 0;
    800055b4:	4901                	li	s2,0
    800055b6:	b7fd                	j	800055a4 <pipewrite+0xc8>
    800055b8:	7b02                	ld	s6,32(sp)
    800055ba:	6be2                	ld	s7,24(sp)
    800055bc:	6c42                	ld	s8,16(sp)
    800055be:	b7dd                	j	800055a4 <pipewrite+0xc8>

00000000800055c0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800055c0:	715d                	addi	sp,sp,-80
    800055c2:	e486                	sd	ra,72(sp)
    800055c4:	e0a2                	sd	s0,64(sp)
    800055c6:	fc26                	sd	s1,56(sp)
    800055c8:	f84a                	sd	s2,48(sp)
    800055ca:	f44e                	sd	s3,40(sp)
    800055cc:	f052                	sd	s4,32(sp)
    800055ce:	ec56                	sd	s5,24(sp)
    800055d0:	0880                	addi	s0,sp,80
    800055d2:	84aa                	mv	s1,a0
    800055d4:	892e                	mv	s2,a1
    800055d6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800055d8:	f8efc0ef          	jal	80001d66 <myproc>
    800055dc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800055de:	8526                	mv	a0,s1
    800055e0:	ffafb0ef          	jal	80000dda <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055e4:	2184a703          	lw	a4,536(s1)
    800055e8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055ec:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055f0:	02f71563          	bne	a4,a5,8000561a <piperead+0x5a>
    800055f4:	2244a783          	lw	a5,548(s1)
    800055f8:	cb85                	beqz	a5,80005628 <piperead+0x68>
    if(killed(pr)){
    800055fa:	8552                	mv	a0,s4
    800055fc:	e38fd0ef          	jal	80002c34 <killed>
    80005600:	ed19                	bnez	a0,8000561e <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005602:	85a6                	mv	a1,s1
    80005604:	854e                	mv	a0,s3
    80005606:	b64fd0ef          	jal	8000296a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000560a:	2184a703          	lw	a4,536(s1)
    8000560e:	21c4a783          	lw	a5,540(s1)
    80005612:	fef701e3          	beq	a4,a5,800055f4 <piperead+0x34>
    80005616:	e85a                	sd	s6,16(sp)
    80005618:	a809                	j	8000562a <piperead+0x6a>
    8000561a:	e85a                	sd	s6,16(sp)
    8000561c:	a039                	j	8000562a <piperead+0x6a>
      release(&pi->lock);
    8000561e:	8526                	mv	a0,s1
    80005620:	853fb0ef          	jal	80000e72 <release>
      return -1;
    80005624:	59fd                	li	s3,-1
    80005626:	a8b9                	j	80005684 <piperead+0xc4>
    80005628:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000562a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000562c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000562e:	05505363          	blez	s5,80005674 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80005632:	2184a783          	lw	a5,536(s1)
    80005636:	21c4a703          	lw	a4,540(s1)
    8000563a:	02f70d63          	beq	a4,a5,80005674 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    8000563e:	1ff7f793          	andi	a5,a5,511
    80005642:	97a6                	add	a5,a5,s1
    80005644:	0187c783          	lbu	a5,24(a5)
    80005648:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000564c:	4685                	li	a3,1
    8000564e:	fbf40613          	addi	a2,s0,-65
    80005652:	85ca                	mv	a1,s2
    80005654:	050a3503          	ld	a0,80(s4)
    80005658:	aecfc0ef          	jal	80001944 <copyout>
    8000565c:	03650e63          	beq	a0,s6,80005698 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005660:	2184a783          	lw	a5,536(s1)
    80005664:	2785                	addiw	a5,a5,1
    80005666:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000566a:	2985                	addiw	s3,s3,1
    8000566c:	0905                	addi	s2,s2,1
    8000566e:	fd3a92e3          	bne	s5,s3,80005632 <piperead+0x72>
    80005672:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005674:	21c48513          	addi	a0,s1,540
    80005678:	b3efd0ef          	jal	800029b6 <wakeup>
  release(&pi->lock);
    8000567c:	8526                	mv	a0,s1
    8000567e:	ff4fb0ef          	jal	80000e72 <release>
    80005682:	6b42                	ld	s6,16(sp)
  return i;
}
    80005684:	854e                	mv	a0,s3
    80005686:	60a6                	ld	ra,72(sp)
    80005688:	6406                	ld	s0,64(sp)
    8000568a:	74e2                	ld	s1,56(sp)
    8000568c:	7942                	ld	s2,48(sp)
    8000568e:	79a2                	ld	s3,40(sp)
    80005690:	7a02                	ld	s4,32(sp)
    80005692:	6ae2                	ld	s5,24(sp)
    80005694:	6161                	addi	sp,sp,80
    80005696:	8082                	ret
      if(i == 0)
    80005698:	fc099ee3          	bnez	s3,80005674 <piperead+0xb4>
        i = -1;
    8000569c:	89aa                	mv	s3,a0
    8000569e:	bfd9                	j	80005674 <piperead+0xb4>

00000000800056a0 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800056a0:	1141                	addi	sp,sp,-16
    800056a2:	e422                	sd	s0,8(sp)
    800056a4:	0800                	addi	s0,sp,16
    800056a6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800056a8:	8905                	andi	a0,a0,1
    800056aa:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800056ac:	8b89                	andi	a5,a5,2
    800056ae:	c399                	beqz	a5,800056b4 <flags2perm+0x14>
      perm |= PTE_W;
    800056b0:	00456513          	ori	a0,a0,4
    return perm;
}
    800056b4:	6422                	ld	s0,8(sp)
    800056b6:	0141                	addi	sp,sp,16
    800056b8:	8082                	ret

00000000800056ba <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800056ba:	df010113          	addi	sp,sp,-528
    800056be:	20113423          	sd	ra,520(sp)
    800056c2:	20813023          	sd	s0,512(sp)
    800056c6:	ffa6                	sd	s1,504(sp)
    800056c8:	fbca                	sd	s2,496(sp)
    800056ca:	0c00                	addi	s0,sp,528
    800056cc:	892a                	mv	s2,a0
    800056ce:	dea43c23          	sd	a0,-520(s0)
    800056d2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800056d6:	e90fc0ef          	jal	80001d66 <myproc>
    800056da:	84aa                	mv	s1,a0

  begin_op();
    800056dc:	dcaff0ef          	jal	80004ca6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800056e0:	854a                	mv	a0,s2
    800056e2:	bf0ff0ef          	jal	80004ad2 <namei>
    800056e6:	c931                	beqz	a0,8000573a <kexec+0x80>
    800056e8:	f3d2                	sd	s4,480(sp)
    800056ea:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800056ec:	bd1fe0ef          	jal	800042bc <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800056f0:	04000713          	li	a4,64
    800056f4:	4681                	li	a3,0
    800056f6:	e5040613          	addi	a2,s0,-432
    800056fa:	4581                	li	a1,0
    800056fc:	8552                	mv	a0,s4
    800056fe:	f4ffe0ef          	jal	8000464c <readi>
    80005702:	04000793          	li	a5,64
    80005706:	00f51a63          	bne	a0,a5,8000571a <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000570a:	e5042703          	lw	a4,-432(s0)
    8000570e:	464c47b7          	lui	a5,0x464c4
    80005712:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005716:	02f70663          	beq	a4,a5,80005742 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000571a:	8552                	mv	a0,s4
    8000571c:	dabfe0ef          	jal	800044c6 <iunlockput>
    end_op();
    80005720:	df0ff0ef          	jal	80004d10 <end_op>
  }
  return -1;
    80005724:	557d                	li	a0,-1
    80005726:	7a1e                	ld	s4,480(sp)
}
    80005728:	20813083          	ld	ra,520(sp)
    8000572c:	20013403          	ld	s0,512(sp)
    80005730:	74fe                	ld	s1,504(sp)
    80005732:	795e                	ld	s2,496(sp)
    80005734:	21010113          	addi	sp,sp,528
    80005738:	8082                	ret
    end_op();
    8000573a:	dd6ff0ef          	jal	80004d10 <end_op>
    return -1;
    8000573e:	557d                	li	a0,-1
    80005740:	b7e5                	j	80005728 <kexec+0x6e>
    80005742:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005744:	8526                	mv	a0,s1
    80005746:	9a1fc0ef          	jal	800020e6 <proc_pagetable>
    8000574a:	8b2a                	mv	s6,a0
    8000574c:	2c050b63          	beqz	a0,80005a22 <kexec+0x368>
    80005750:	f7ce                	sd	s3,488(sp)
    80005752:	efd6                	sd	s5,472(sp)
    80005754:	e7de                	sd	s7,456(sp)
    80005756:	e3e2                	sd	s8,448(sp)
    80005758:	ff66                	sd	s9,440(sp)
    8000575a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000575c:	e7042d03          	lw	s10,-400(s0)
    80005760:	e8845783          	lhu	a5,-376(s0)
    80005764:	12078963          	beqz	a5,80005896 <kexec+0x1dc>
    80005768:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000576a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000576c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000576e:	6c85                	lui	s9,0x1
    80005770:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005774:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005778:	6a85                	lui	s5,0x1
    8000577a:	a085                	j	800057da <kexec+0x120>
      panic("loadseg: address should exist");
    8000577c:	00003517          	auipc	a0,0x3
    80005780:	f2450513          	addi	a0,a0,-220 # 800086a0 <etext+0x6a0>
    80005784:	85cfb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80005788:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000578a:	8726                	mv	a4,s1
    8000578c:	012c06bb          	addw	a3,s8,s2
    80005790:	4581                	li	a1,0
    80005792:	8552                	mv	a0,s4
    80005794:	eb9fe0ef          	jal	8000464c <readi>
    80005798:	2501                	sext.w	a0,a0
    8000579a:	24a49a63          	bne	s1,a0,800059ee <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000579e:	012a893b          	addw	s2,s5,s2
    800057a2:	03397363          	bgeu	s2,s3,800057c8 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800057a6:	02091593          	slli	a1,s2,0x20
    800057aa:	9181                	srli	a1,a1,0x20
    800057ac:	95de                	add	a1,a1,s7
    800057ae:	855a                	mv	a0,s6
    800057b0:	a0dfb0ef          	jal	800011bc <walkaddr>
    800057b4:	862a                	mv	a2,a0
    if(pa == 0)
    800057b6:	d179                	beqz	a0,8000577c <kexec+0xc2>
    if(sz - i < PGSIZE)
    800057b8:	412984bb          	subw	s1,s3,s2
    800057bc:	0004879b          	sext.w	a5,s1
    800057c0:	fcfcf4e3          	bgeu	s9,a5,80005788 <kexec+0xce>
    800057c4:	84d6                	mv	s1,s5
    800057c6:	b7c9                	j	80005788 <kexec+0xce>
    sz = sz1;
    800057c8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057cc:	2d85                	addiw	s11,s11,1
    800057ce:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800057d2:	e8845783          	lhu	a5,-376(s0)
    800057d6:	08fdd063          	bge	s11,a5,80005856 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057da:	2d01                	sext.w	s10,s10
    800057dc:	03800713          	li	a4,56
    800057e0:	86ea                	mv	a3,s10
    800057e2:	e1840613          	addi	a2,s0,-488
    800057e6:	4581                	li	a1,0
    800057e8:	8552                	mv	a0,s4
    800057ea:	e63fe0ef          	jal	8000464c <readi>
    800057ee:	03800793          	li	a5,56
    800057f2:	1cf51663          	bne	a0,a5,800059be <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800057f6:	e1842783          	lw	a5,-488(s0)
    800057fa:	4705                	li	a4,1
    800057fc:	fce798e3          	bne	a5,a4,800057cc <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80005800:	e4043483          	ld	s1,-448(s0)
    80005804:	e3843783          	ld	a5,-456(s0)
    80005808:	1af4ef63          	bltu	s1,a5,800059c6 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000580c:	e2843783          	ld	a5,-472(s0)
    80005810:	94be                	add	s1,s1,a5
    80005812:	1af4ee63          	bltu	s1,a5,800059ce <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80005816:	df043703          	ld	a4,-528(s0)
    8000581a:	8ff9                	and	a5,a5,a4
    8000581c:	1a079d63          	bnez	a5,800059d6 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005820:	e1c42503          	lw	a0,-484(s0)
    80005824:	e7dff0ef          	jal	800056a0 <flags2perm>
    80005828:	86aa                	mv	a3,a0
    8000582a:	8626                	mv	a2,s1
    8000582c:	85ca                	mv	a1,s2
    8000582e:	855a                	mv	a0,s6
    80005830:	c65fb0ef          	jal	80001494 <uvmalloc>
    80005834:	e0a43423          	sd	a0,-504(s0)
    80005838:	1a050363          	beqz	a0,800059de <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000583c:	e2843b83          	ld	s7,-472(s0)
    80005840:	e2042c03          	lw	s8,-480(s0)
    80005844:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005848:	00098463          	beqz	s3,80005850 <kexec+0x196>
    8000584c:	4901                	li	s2,0
    8000584e:	bfa1                	j	800057a6 <kexec+0xec>
    sz = sz1;
    80005850:	e0843903          	ld	s2,-504(s0)
    80005854:	bfa5                	j	800057cc <kexec+0x112>
    80005856:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005858:	8552                	mv	a0,s4
    8000585a:	c6dfe0ef          	jal	800044c6 <iunlockput>
  end_op();
    8000585e:	cb2ff0ef          	jal	80004d10 <end_op>
  p = myproc();
    80005862:	d04fc0ef          	jal	80001d66 <myproc>
    80005866:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005868:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000586c:	6985                	lui	s3,0x1
    8000586e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005870:	99ca                	add	s3,s3,s2
    80005872:	77fd                	lui	a5,0xfffff
    80005874:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80005878:	4691                	li	a3,4
    8000587a:	6609                	lui	a2,0x2
    8000587c:	964e                	add	a2,a2,s3
    8000587e:	85ce                	mv	a1,s3
    80005880:	855a                	mv	a0,s6
    80005882:	c13fb0ef          	jal	80001494 <uvmalloc>
    80005886:	892a                	mv	s2,a0
    80005888:	e0a43423          	sd	a0,-504(s0)
    8000588c:	e519                	bnez	a0,8000589a <kexec+0x1e0>
  if(pagetable)
    8000588e:	e1343423          	sd	s3,-504(s0)
    80005892:	4a01                	li	s4,0
    80005894:	aab1                	j	800059f0 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005896:	4901                	li	s2,0
    80005898:	b7c1                	j	80005858 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000589a:	75f9                	lui	a1,0xffffe
    8000589c:	95aa                	add	a1,a1,a0
    8000589e:	855a                	mv	a0,s6
    800058a0:	e67fb0ef          	jal	80001706 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800058a4:	7bfd                	lui	s7,0xfffff
    800058a6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800058a8:	e0043783          	ld	a5,-512(s0)
    800058ac:	6388                	ld	a0,0(a5)
    800058ae:	cd39                	beqz	a0,8000590c <kexec+0x252>
    800058b0:	e9040993          	addi	s3,s0,-368
    800058b4:	f9040c13          	addi	s8,s0,-112
    800058b8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800058ba:	f64fb0ef          	jal	8000101e <strlen>
    800058be:	0015079b          	addiw	a5,a0,1
    800058c2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800058c6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800058ca:	11796e63          	bltu	s2,s7,800059e6 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800058ce:	e0043d03          	ld	s10,-512(s0)
    800058d2:	000d3a03          	ld	s4,0(s10)
    800058d6:	8552                	mv	a0,s4
    800058d8:	f46fb0ef          	jal	8000101e <strlen>
    800058dc:	0015069b          	addiw	a3,a0,1
    800058e0:	8652                	mv	a2,s4
    800058e2:	85ca                	mv	a1,s2
    800058e4:	855a                	mv	a0,s6
    800058e6:	85efc0ef          	jal	80001944 <copyout>
    800058ea:	10054063          	bltz	a0,800059ea <kexec+0x330>
    ustack[argc] = sp;
    800058ee:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800058f2:	0485                	addi	s1,s1,1
    800058f4:	008d0793          	addi	a5,s10,8
    800058f8:	e0f43023          	sd	a5,-512(s0)
    800058fc:	008d3503          	ld	a0,8(s10)
    80005900:	c909                	beqz	a0,80005912 <kexec+0x258>
    if(argc >= MAXARG)
    80005902:	09a1                	addi	s3,s3,8
    80005904:	fb899be3          	bne	s3,s8,800058ba <kexec+0x200>
  ip = 0;
    80005908:	4a01                	li	s4,0
    8000590a:	a0dd                	j	800059f0 <kexec+0x336>
  sp = sz;
    8000590c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005910:	4481                	li	s1,0
  ustack[argc] = 0;
    80005912:	00349793          	slli	a5,s1,0x3
    80005916:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffbbe58>
    8000591a:	97a2                	add	a5,a5,s0
    8000591c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005920:	00148693          	addi	a3,s1,1
    80005924:	068e                	slli	a3,a3,0x3
    80005926:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000592a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000592e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005932:	f5796ee3          	bltu	s2,s7,8000588e <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005936:	e9040613          	addi	a2,s0,-368
    8000593a:	85ca                	mv	a1,s2
    8000593c:	855a                	mv	a0,s6
    8000593e:	806fc0ef          	jal	80001944 <copyout>
    80005942:	0e054263          	bltz	a0,80005a26 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80005946:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000594a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000594e:	df843783          	ld	a5,-520(s0)
    80005952:	0007c703          	lbu	a4,0(a5)
    80005956:	cf11                	beqz	a4,80005972 <kexec+0x2b8>
    80005958:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000595a:	02f00693          	li	a3,47
    8000595e:	a039                	j	8000596c <kexec+0x2b2>
      last = s+1;
    80005960:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005964:	0785                	addi	a5,a5,1
    80005966:	fff7c703          	lbu	a4,-1(a5)
    8000596a:	c701                	beqz	a4,80005972 <kexec+0x2b8>
    if(*s == '/')
    8000596c:	fed71ce3          	bne	a4,a3,80005964 <kexec+0x2aa>
    80005970:	bfc5                	j	80005960 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80005972:	4641                	li	a2,16
    80005974:	df843583          	ld	a1,-520(s0)
    80005978:	158a8513          	addi	a0,s5,344
    8000597c:	e70fb0ef          	jal	80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    80005980:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005984:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005988:	e0843783          	ld	a5,-504(s0)
    8000598c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80005990:	058ab783          	ld	a5,88(s5)
    80005994:	e6843703          	ld	a4,-408(s0)
    80005998:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000599a:	058ab783          	ld	a5,88(s5)
    8000599e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800059a2:	85e6                	mv	a1,s9
    800059a4:	fc6fc0ef          	jal	8000216a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800059a8:	0004851b          	sext.w	a0,s1
    800059ac:	79be                	ld	s3,488(sp)
    800059ae:	7a1e                	ld	s4,480(sp)
    800059b0:	6afe                	ld	s5,472(sp)
    800059b2:	6b5e                	ld	s6,464(sp)
    800059b4:	6bbe                	ld	s7,456(sp)
    800059b6:	6c1e                	ld	s8,448(sp)
    800059b8:	7cfa                	ld	s9,440(sp)
    800059ba:	7d5a                	ld	s10,432(sp)
    800059bc:	b3b5                	j	80005728 <kexec+0x6e>
    800059be:	e1243423          	sd	s2,-504(s0)
    800059c2:	7dba                	ld	s11,424(sp)
    800059c4:	a035                	j	800059f0 <kexec+0x336>
    800059c6:	e1243423          	sd	s2,-504(s0)
    800059ca:	7dba                	ld	s11,424(sp)
    800059cc:	a015                	j	800059f0 <kexec+0x336>
    800059ce:	e1243423          	sd	s2,-504(s0)
    800059d2:	7dba                	ld	s11,424(sp)
    800059d4:	a831                	j	800059f0 <kexec+0x336>
    800059d6:	e1243423          	sd	s2,-504(s0)
    800059da:	7dba                	ld	s11,424(sp)
    800059dc:	a811                	j	800059f0 <kexec+0x336>
    800059de:	e1243423          	sd	s2,-504(s0)
    800059e2:	7dba                	ld	s11,424(sp)
    800059e4:	a031                	j	800059f0 <kexec+0x336>
  ip = 0;
    800059e6:	4a01                	li	s4,0
    800059e8:	a021                	j	800059f0 <kexec+0x336>
    800059ea:	4a01                	li	s4,0
  if(pagetable)
    800059ec:	a011                	j	800059f0 <kexec+0x336>
    800059ee:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800059f0:	e0843583          	ld	a1,-504(s0)
    800059f4:	855a                	mv	a0,s6
    800059f6:	f74fc0ef          	jal	8000216a <proc_freepagetable>
  return -1;
    800059fa:	557d                	li	a0,-1
  if(ip){
    800059fc:	000a1b63          	bnez	s4,80005a12 <kexec+0x358>
    80005a00:	79be                	ld	s3,488(sp)
    80005a02:	7a1e                	ld	s4,480(sp)
    80005a04:	6afe                	ld	s5,472(sp)
    80005a06:	6b5e                	ld	s6,464(sp)
    80005a08:	6bbe                	ld	s7,456(sp)
    80005a0a:	6c1e                	ld	s8,448(sp)
    80005a0c:	7cfa                	ld	s9,440(sp)
    80005a0e:	7d5a                	ld	s10,432(sp)
    80005a10:	bb21                	j	80005728 <kexec+0x6e>
    80005a12:	79be                	ld	s3,488(sp)
    80005a14:	6afe                	ld	s5,472(sp)
    80005a16:	6b5e                	ld	s6,464(sp)
    80005a18:	6bbe                	ld	s7,456(sp)
    80005a1a:	6c1e                	ld	s8,448(sp)
    80005a1c:	7cfa                	ld	s9,440(sp)
    80005a1e:	7d5a                	ld	s10,432(sp)
    80005a20:	b9ed                	j	8000571a <kexec+0x60>
    80005a22:	6b5e                	ld	s6,464(sp)
    80005a24:	b9dd                	j	8000571a <kexec+0x60>
  sz = sz1;
    80005a26:	e0843983          	ld	s3,-504(s0)
    80005a2a:	b595                	j	8000588e <kexec+0x1d4>

0000000080005a2c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a2c:	7179                	addi	sp,sp,-48
    80005a2e:	f406                	sd	ra,40(sp)
    80005a30:	f022                	sd	s0,32(sp)
    80005a32:	ec26                	sd	s1,24(sp)
    80005a34:	e84a                	sd	s2,16(sp)
    80005a36:	1800                	addi	s0,sp,48
    80005a38:	892e                	mv	s2,a1
    80005a3a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005a3c:	fdc40593          	addi	a1,s0,-36
    80005a40:	af3fd0ef          	jal	80003532 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a44:	fdc42703          	lw	a4,-36(s0)
    80005a48:	47bd                	li	a5,15
    80005a4a:	02e7e963          	bltu	a5,a4,80005a7c <argfd+0x50>
    80005a4e:	b18fc0ef          	jal	80001d66 <myproc>
    80005a52:	fdc42703          	lw	a4,-36(s0)
    80005a56:	01a70793          	addi	a5,a4,26
    80005a5a:	078e                	slli	a5,a5,0x3
    80005a5c:	953e                	add	a0,a0,a5
    80005a5e:	611c                	ld	a5,0(a0)
    80005a60:	c385                	beqz	a5,80005a80 <argfd+0x54>
    return -1;
  if(pfd)
    80005a62:	00090463          	beqz	s2,80005a6a <argfd+0x3e>
    *pfd = fd;
    80005a66:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005a6a:	4501                	li	a0,0
  if(pf)
    80005a6c:	c091                	beqz	s1,80005a70 <argfd+0x44>
    *pf = f;
    80005a6e:	e09c                	sd	a5,0(s1)
}
    80005a70:	70a2                	ld	ra,40(sp)
    80005a72:	7402                	ld	s0,32(sp)
    80005a74:	64e2                	ld	s1,24(sp)
    80005a76:	6942                	ld	s2,16(sp)
    80005a78:	6145                	addi	sp,sp,48
    80005a7a:	8082                	ret
    return -1;
    80005a7c:	557d                	li	a0,-1
    80005a7e:	bfcd                	j	80005a70 <argfd+0x44>
    80005a80:	557d                	li	a0,-1
    80005a82:	b7fd                	j	80005a70 <argfd+0x44>

0000000080005a84 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005a84:	1101                	addi	sp,sp,-32
    80005a86:	ec06                	sd	ra,24(sp)
    80005a88:	e822                	sd	s0,16(sp)
    80005a8a:	e426                	sd	s1,8(sp)
    80005a8c:	1000                	addi	s0,sp,32
    80005a8e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005a90:	ad6fc0ef          	jal	80001d66 <myproc>
    80005a94:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005a96:	0d050793          	addi	a5,a0,208
    80005a9a:	4501                	li	a0,0
    80005a9c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005a9e:	6398                	ld	a4,0(a5)
    80005aa0:	cb19                	beqz	a4,80005ab6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005aa2:	2505                	addiw	a0,a0,1
    80005aa4:	07a1                	addi	a5,a5,8
    80005aa6:	fed51ce3          	bne	a0,a3,80005a9e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005aaa:	557d                	li	a0,-1
}
    80005aac:	60e2                	ld	ra,24(sp)
    80005aae:	6442                	ld	s0,16(sp)
    80005ab0:	64a2                	ld	s1,8(sp)
    80005ab2:	6105                	addi	sp,sp,32
    80005ab4:	8082                	ret
      p->ofile[fd] = f;
    80005ab6:	01a50793          	addi	a5,a0,26
    80005aba:	078e                	slli	a5,a5,0x3
    80005abc:	963e                	add	a2,a2,a5
    80005abe:	e204                	sd	s1,0(a2)
      return fd;
    80005ac0:	b7f5                	j	80005aac <fdalloc+0x28>

0000000080005ac2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005ac2:	715d                	addi	sp,sp,-80
    80005ac4:	e486                	sd	ra,72(sp)
    80005ac6:	e0a2                	sd	s0,64(sp)
    80005ac8:	fc26                	sd	s1,56(sp)
    80005aca:	f84a                	sd	s2,48(sp)
    80005acc:	f44e                	sd	s3,40(sp)
    80005ace:	ec56                	sd	s5,24(sp)
    80005ad0:	e85a                	sd	s6,16(sp)
    80005ad2:	0880                	addi	s0,sp,80
    80005ad4:	8b2e                	mv	s6,a1
    80005ad6:	89b2                	mv	s3,a2
    80005ad8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005ada:	fb040593          	addi	a1,s0,-80
    80005ade:	80eff0ef          	jal	80004aec <nameiparent>
    80005ae2:	84aa                	mv	s1,a0
    80005ae4:	10050a63          	beqz	a0,80005bf8 <create+0x136>
    return 0;

  ilock(dp);
    80005ae8:	fd4fe0ef          	jal	800042bc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005aec:	4601                	li	a2,0
    80005aee:	fb040593          	addi	a1,s0,-80
    80005af2:	8526                	mv	a0,s1
    80005af4:	d79fe0ef          	jal	8000486c <dirlookup>
    80005af8:	8aaa                	mv	s5,a0
    80005afa:	c129                	beqz	a0,80005b3c <create+0x7a>
    iunlockput(dp);
    80005afc:	8526                	mv	a0,s1
    80005afe:	9c9fe0ef          	jal	800044c6 <iunlockput>
    ilock(ip);
    80005b02:	8556                	mv	a0,s5
    80005b04:	fb8fe0ef          	jal	800042bc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b08:	4789                	li	a5,2
    80005b0a:	02fb1463          	bne	s6,a5,80005b32 <create+0x70>
    80005b0e:	044ad783          	lhu	a5,68(s5)
    80005b12:	37f9                	addiw	a5,a5,-2
    80005b14:	17c2                	slli	a5,a5,0x30
    80005b16:	93c1                	srli	a5,a5,0x30
    80005b18:	4705                	li	a4,1
    80005b1a:	00f76c63          	bltu	a4,a5,80005b32 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005b1e:	8556                	mv	a0,s5
    80005b20:	60a6                	ld	ra,72(sp)
    80005b22:	6406                	ld	s0,64(sp)
    80005b24:	74e2                	ld	s1,56(sp)
    80005b26:	7942                	ld	s2,48(sp)
    80005b28:	79a2                	ld	s3,40(sp)
    80005b2a:	6ae2                	ld	s5,24(sp)
    80005b2c:	6b42                	ld	s6,16(sp)
    80005b2e:	6161                	addi	sp,sp,80
    80005b30:	8082                	ret
    iunlockput(ip);
    80005b32:	8556                	mv	a0,s5
    80005b34:	993fe0ef          	jal	800044c6 <iunlockput>
    return 0;
    80005b38:	4a81                	li	s5,0
    80005b3a:	b7d5                	j	80005b1e <create+0x5c>
    80005b3c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005b3e:	85da                	mv	a1,s6
    80005b40:	4088                	lw	a0,0(s1)
    80005b42:	e0afe0ef          	jal	8000414c <ialloc>
    80005b46:	8a2a                	mv	s4,a0
    80005b48:	cd15                	beqz	a0,80005b84 <create+0xc2>
  ilock(ip);
    80005b4a:	f72fe0ef          	jal	800042bc <ilock>
  ip->major = major;
    80005b4e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005b52:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005b56:	4905                	li	s2,1
    80005b58:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005b5c:	8552                	mv	a0,s4
    80005b5e:	eaafe0ef          	jal	80004208 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005b62:	032b0763          	beq	s6,s2,80005b90 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b66:	004a2603          	lw	a2,4(s4)
    80005b6a:	fb040593          	addi	a1,s0,-80
    80005b6e:	8526                	mv	a0,s1
    80005b70:	ec9fe0ef          	jal	80004a38 <dirlink>
    80005b74:	06054563          	bltz	a0,80005bde <create+0x11c>
  iunlockput(dp);
    80005b78:	8526                	mv	a0,s1
    80005b7a:	94dfe0ef          	jal	800044c6 <iunlockput>
  return ip;
    80005b7e:	8ad2                	mv	s5,s4
    80005b80:	7a02                	ld	s4,32(sp)
    80005b82:	bf71                	j	80005b1e <create+0x5c>
    iunlockput(dp);
    80005b84:	8526                	mv	a0,s1
    80005b86:	941fe0ef          	jal	800044c6 <iunlockput>
    return 0;
    80005b8a:	8ad2                	mv	s5,s4
    80005b8c:	7a02                	ld	s4,32(sp)
    80005b8e:	bf41                	j	80005b1e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005b90:	004a2603          	lw	a2,4(s4)
    80005b94:	00003597          	auipc	a1,0x3
    80005b98:	b2c58593          	addi	a1,a1,-1236 # 800086c0 <etext+0x6c0>
    80005b9c:	8552                	mv	a0,s4
    80005b9e:	e9bfe0ef          	jal	80004a38 <dirlink>
    80005ba2:	02054e63          	bltz	a0,80005bde <create+0x11c>
    80005ba6:	40d0                	lw	a2,4(s1)
    80005ba8:	00003597          	auipc	a1,0x3
    80005bac:	b2058593          	addi	a1,a1,-1248 # 800086c8 <etext+0x6c8>
    80005bb0:	8552                	mv	a0,s4
    80005bb2:	e87fe0ef          	jal	80004a38 <dirlink>
    80005bb6:	02054463          	bltz	a0,80005bde <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005bba:	004a2603          	lw	a2,4(s4)
    80005bbe:	fb040593          	addi	a1,s0,-80
    80005bc2:	8526                	mv	a0,s1
    80005bc4:	e75fe0ef          	jal	80004a38 <dirlink>
    80005bc8:	00054b63          	bltz	a0,80005bde <create+0x11c>
    dp->nlink++;  // for ".."
    80005bcc:	04a4d783          	lhu	a5,74(s1)
    80005bd0:	2785                	addiw	a5,a5,1
    80005bd2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bd6:	8526                	mv	a0,s1
    80005bd8:	e30fe0ef          	jal	80004208 <iupdate>
    80005bdc:	bf71                	j	80005b78 <create+0xb6>
  ip->nlink = 0;
    80005bde:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005be2:	8552                	mv	a0,s4
    80005be4:	e24fe0ef          	jal	80004208 <iupdate>
  iunlockput(ip);
    80005be8:	8552                	mv	a0,s4
    80005bea:	8ddfe0ef          	jal	800044c6 <iunlockput>
  iunlockput(dp);
    80005bee:	8526                	mv	a0,s1
    80005bf0:	8d7fe0ef          	jal	800044c6 <iunlockput>
  return 0;
    80005bf4:	7a02                	ld	s4,32(sp)
    80005bf6:	b725                	j	80005b1e <create+0x5c>
    return 0;
    80005bf8:	8aaa                	mv	s5,a0
    80005bfa:	b715                	j	80005b1e <create+0x5c>

0000000080005bfc <sys_dup>:
{
    80005bfc:	7179                	addi	sp,sp,-48
    80005bfe:	f406                	sd	ra,40(sp)
    80005c00:	f022                	sd	s0,32(sp)
    80005c02:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c04:	fd840613          	addi	a2,s0,-40
    80005c08:	4581                	li	a1,0
    80005c0a:	4501                	li	a0,0
    80005c0c:	e21ff0ef          	jal	80005a2c <argfd>
    return -1;
    80005c10:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c12:	02054363          	bltz	a0,80005c38 <sys_dup+0x3c>
    80005c16:	ec26                	sd	s1,24(sp)
    80005c18:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005c1a:	fd843903          	ld	s2,-40(s0)
    80005c1e:	854a                	mv	a0,s2
    80005c20:	e65ff0ef          	jal	80005a84 <fdalloc>
    80005c24:	84aa                	mv	s1,a0
    return -1;
    80005c26:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005c28:	00054d63          	bltz	a0,80005c42 <sys_dup+0x46>
  filedup(f);
    80005c2c:	854a                	mv	a0,s2
    80005c2e:	c3eff0ef          	jal	8000506c <filedup>
  return fd;
    80005c32:	87a6                	mv	a5,s1
    80005c34:	64e2                	ld	s1,24(sp)
    80005c36:	6942                	ld	s2,16(sp)
}
    80005c38:	853e                	mv	a0,a5
    80005c3a:	70a2                	ld	ra,40(sp)
    80005c3c:	7402                	ld	s0,32(sp)
    80005c3e:	6145                	addi	sp,sp,48
    80005c40:	8082                	ret
    80005c42:	64e2                	ld	s1,24(sp)
    80005c44:	6942                	ld	s2,16(sp)
    80005c46:	bfcd                	j	80005c38 <sys_dup+0x3c>

0000000080005c48 <sys_read>:
{
    80005c48:	7179                	addi	sp,sp,-48
    80005c4a:	f406                	sd	ra,40(sp)
    80005c4c:	f022                	sd	s0,32(sp)
    80005c4e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c50:	fd840593          	addi	a1,s0,-40
    80005c54:	4505                	li	a0,1
    80005c56:	8f9fd0ef          	jal	8000354e <argaddr>
  argint(2, &n);
    80005c5a:	fe440593          	addi	a1,s0,-28
    80005c5e:	4509                	li	a0,2
    80005c60:	8d3fd0ef          	jal	80003532 <argint>
  if(argfd(0, 0, &f) < 0)
    80005c64:	fe840613          	addi	a2,s0,-24
    80005c68:	4581                	li	a1,0
    80005c6a:	4501                	li	a0,0
    80005c6c:	dc1ff0ef          	jal	80005a2c <argfd>
    80005c70:	87aa                	mv	a5,a0
    return -1;
    80005c72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c74:	0007ca63          	bltz	a5,80005c88 <sys_read+0x40>
  return fileread(f, p, n);
    80005c78:	fe442603          	lw	a2,-28(s0)
    80005c7c:	fd843583          	ld	a1,-40(s0)
    80005c80:	fe843503          	ld	a0,-24(s0)
    80005c84:	d4eff0ef          	jal	800051d2 <fileread>
}
    80005c88:	70a2                	ld	ra,40(sp)
    80005c8a:	7402                	ld	s0,32(sp)
    80005c8c:	6145                	addi	sp,sp,48
    80005c8e:	8082                	ret

0000000080005c90 <sys_write>:
{
    80005c90:	7179                	addi	sp,sp,-48
    80005c92:	f406                	sd	ra,40(sp)
    80005c94:	f022                	sd	s0,32(sp)
    80005c96:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c98:	fd840593          	addi	a1,s0,-40
    80005c9c:	4505                	li	a0,1
    80005c9e:	8b1fd0ef          	jal	8000354e <argaddr>
  argint(2, &n);
    80005ca2:	fe440593          	addi	a1,s0,-28
    80005ca6:	4509                	li	a0,2
    80005ca8:	88bfd0ef          	jal	80003532 <argint>
  if(argfd(0, 0, &f) < 0)
    80005cac:	fe840613          	addi	a2,s0,-24
    80005cb0:	4581                	li	a1,0
    80005cb2:	4501                	li	a0,0
    80005cb4:	d79ff0ef          	jal	80005a2c <argfd>
    80005cb8:	87aa                	mv	a5,a0
    return -1;
    80005cba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005cbc:	0007ca63          	bltz	a5,80005cd0 <sys_write+0x40>
  return filewrite(f, p, n);
    80005cc0:	fe442603          	lw	a2,-28(s0)
    80005cc4:	fd843583          	ld	a1,-40(s0)
    80005cc8:	fe843503          	ld	a0,-24(s0)
    80005ccc:	dc4ff0ef          	jal	80005290 <filewrite>
}
    80005cd0:	70a2                	ld	ra,40(sp)
    80005cd2:	7402                	ld	s0,32(sp)
    80005cd4:	6145                	addi	sp,sp,48
    80005cd6:	8082                	ret

0000000080005cd8 <sys_close>:
{
    80005cd8:	1101                	addi	sp,sp,-32
    80005cda:	ec06                	sd	ra,24(sp)
    80005cdc:	e822                	sd	s0,16(sp)
    80005cde:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005ce0:	fe040613          	addi	a2,s0,-32
    80005ce4:	fec40593          	addi	a1,s0,-20
    80005ce8:	4501                	li	a0,0
    80005cea:	d43ff0ef          	jal	80005a2c <argfd>
    return -1;
    80005cee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005cf0:	02054063          	bltz	a0,80005d10 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005cf4:	872fc0ef          	jal	80001d66 <myproc>
    80005cf8:	fec42783          	lw	a5,-20(s0)
    80005cfc:	07e9                	addi	a5,a5,26
    80005cfe:	078e                	slli	a5,a5,0x3
    80005d00:	953e                	add	a0,a0,a5
    80005d02:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005d06:	fe043503          	ld	a0,-32(s0)
    80005d0a:	ba8ff0ef          	jal	800050b2 <fileclose>
  return 0;
    80005d0e:	4781                	li	a5,0
}
    80005d10:	853e                	mv	a0,a5
    80005d12:	60e2                	ld	ra,24(sp)
    80005d14:	6442                	ld	s0,16(sp)
    80005d16:	6105                	addi	sp,sp,32
    80005d18:	8082                	ret

0000000080005d1a <sys_fstat>:
{
    80005d1a:	1101                	addi	sp,sp,-32
    80005d1c:	ec06                	sd	ra,24(sp)
    80005d1e:	e822                	sd	s0,16(sp)
    80005d20:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005d22:	fe040593          	addi	a1,s0,-32
    80005d26:	4505                	li	a0,1
    80005d28:	827fd0ef          	jal	8000354e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005d2c:	fe840613          	addi	a2,s0,-24
    80005d30:	4581                	li	a1,0
    80005d32:	4501                	li	a0,0
    80005d34:	cf9ff0ef          	jal	80005a2c <argfd>
    80005d38:	87aa                	mv	a5,a0
    return -1;
    80005d3a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d3c:	0007c863          	bltz	a5,80005d4c <sys_fstat+0x32>
  return filestat(f, st);
    80005d40:	fe043583          	ld	a1,-32(s0)
    80005d44:	fe843503          	ld	a0,-24(s0)
    80005d48:	c2cff0ef          	jal	80005174 <filestat>
}
    80005d4c:	60e2                	ld	ra,24(sp)
    80005d4e:	6442                	ld	s0,16(sp)
    80005d50:	6105                	addi	sp,sp,32
    80005d52:	8082                	ret

0000000080005d54 <sys_link>:
{
    80005d54:	7169                	addi	sp,sp,-304
    80005d56:	f606                	sd	ra,296(sp)
    80005d58:	f222                	sd	s0,288(sp)
    80005d5a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d5c:	08000613          	li	a2,128
    80005d60:	ed040593          	addi	a1,s0,-304
    80005d64:	4501                	li	a0,0
    80005d66:	805fd0ef          	jal	8000356a <argstr>
    return -1;
    80005d6a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d6c:	0c054e63          	bltz	a0,80005e48 <sys_link+0xf4>
    80005d70:	08000613          	li	a2,128
    80005d74:	f5040593          	addi	a1,s0,-176
    80005d78:	4505                	li	a0,1
    80005d7a:	ff0fd0ef          	jal	8000356a <argstr>
    return -1;
    80005d7e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d80:	0c054463          	bltz	a0,80005e48 <sys_link+0xf4>
    80005d84:	ee26                	sd	s1,280(sp)
  begin_op();
    80005d86:	f21fe0ef          	jal	80004ca6 <begin_op>
  if((ip = namei(old)) == 0){
    80005d8a:	ed040513          	addi	a0,s0,-304
    80005d8e:	d45fe0ef          	jal	80004ad2 <namei>
    80005d92:	84aa                	mv	s1,a0
    80005d94:	c53d                	beqz	a0,80005e02 <sys_link+0xae>
  ilock(ip);
    80005d96:	d26fe0ef          	jal	800042bc <ilock>
  if(ip->type == T_DIR){
    80005d9a:	04449703          	lh	a4,68(s1)
    80005d9e:	4785                	li	a5,1
    80005da0:	06f70663          	beq	a4,a5,80005e0c <sys_link+0xb8>
    80005da4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005da6:	04a4d783          	lhu	a5,74(s1)
    80005daa:	2785                	addiw	a5,a5,1
    80005dac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005db0:	8526                	mv	a0,s1
    80005db2:	c56fe0ef          	jal	80004208 <iupdate>
  iunlock(ip);
    80005db6:	8526                	mv	a0,s1
    80005db8:	db2fe0ef          	jal	8000436a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005dbc:	fd040593          	addi	a1,s0,-48
    80005dc0:	f5040513          	addi	a0,s0,-176
    80005dc4:	d29fe0ef          	jal	80004aec <nameiparent>
    80005dc8:	892a                	mv	s2,a0
    80005dca:	cd21                	beqz	a0,80005e22 <sys_link+0xce>
  ilock(dp);
    80005dcc:	cf0fe0ef          	jal	800042bc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005dd0:	00092703          	lw	a4,0(s2)
    80005dd4:	409c                	lw	a5,0(s1)
    80005dd6:	04f71363          	bne	a4,a5,80005e1c <sys_link+0xc8>
    80005dda:	40d0                	lw	a2,4(s1)
    80005ddc:	fd040593          	addi	a1,s0,-48
    80005de0:	854a                	mv	a0,s2
    80005de2:	c57fe0ef          	jal	80004a38 <dirlink>
    80005de6:	02054b63          	bltz	a0,80005e1c <sys_link+0xc8>
  iunlockput(dp);
    80005dea:	854a                	mv	a0,s2
    80005dec:	edafe0ef          	jal	800044c6 <iunlockput>
  iput(ip);
    80005df0:	8526                	mv	a0,s1
    80005df2:	e4cfe0ef          	jal	8000443e <iput>
  end_op();
    80005df6:	f1bfe0ef          	jal	80004d10 <end_op>
  return 0;
    80005dfa:	4781                	li	a5,0
    80005dfc:	64f2                	ld	s1,280(sp)
    80005dfe:	6952                	ld	s2,272(sp)
    80005e00:	a0a1                	j	80005e48 <sys_link+0xf4>
    end_op();
    80005e02:	f0ffe0ef          	jal	80004d10 <end_op>
    return -1;
    80005e06:	57fd                	li	a5,-1
    80005e08:	64f2                	ld	s1,280(sp)
    80005e0a:	a83d                	j	80005e48 <sys_link+0xf4>
    iunlockput(ip);
    80005e0c:	8526                	mv	a0,s1
    80005e0e:	eb8fe0ef          	jal	800044c6 <iunlockput>
    end_op();
    80005e12:	efffe0ef          	jal	80004d10 <end_op>
    return -1;
    80005e16:	57fd                	li	a5,-1
    80005e18:	64f2                	ld	s1,280(sp)
    80005e1a:	a03d                	j	80005e48 <sys_link+0xf4>
    iunlockput(dp);
    80005e1c:	854a                	mv	a0,s2
    80005e1e:	ea8fe0ef          	jal	800044c6 <iunlockput>
  ilock(ip);
    80005e22:	8526                	mv	a0,s1
    80005e24:	c98fe0ef          	jal	800042bc <ilock>
  ip->nlink--;
    80005e28:	04a4d783          	lhu	a5,74(s1)
    80005e2c:	37fd                	addiw	a5,a5,-1
    80005e2e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e32:	8526                	mv	a0,s1
    80005e34:	bd4fe0ef          	jal	80004208 <iupdate>
  iunlockput(ip);
    80005e38:	8526                	mv	a0,s1
    80005e3a:	e8cfe0ef          	jal	800044c6 <iunlockput>
  end_op();
    80005e3e:	ed3fe0ef          	jal	80004d10 <end_op>
  return -1;
    80005e42:	57fd                	li	a5,-1
    80005e44:	64f2                	ld	s1,280(sp)
    80005e46:	6952                	ld	s2,272(sp)
}
    80005e48:	853e                	mv	a0,a5
    80005e4a:	70b2                	ld	ra,296(sp)
    80005e4c:	7412                	ld	s0,288(sp)
    80005e4e:	6155                	addi	sp,sp,304
    80005e50:	8082                	ret

0000000080005e52 <sys_unlink>:
{
    80005e52:	7151                	addi	sp,sp,-240
    80005e54:	f586                	sd	ra,232(sp)
    80005e56:	f1a2                	sd	s0,224(sp)
    80005e58:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e5a:	08000613          	li	a2,128
    80005e5e:	f3040593          	addi	a1,s0,-208
    80005e62:	4501                	li	a0,0
    80005e64:	f06fd0ef          	jal	8000356a <argstr>
    80005e68:	16054063          	bltz	a0,80005fc8 <sys_unlink+0x176>
    80005e6c:	eda6                	sd	s1,216(sp)
  begin_op();
    80005e6e:	e39fe0ef          	jal	80004ca6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005e72:	fb040593          	addi	a1,s0,-80
    80005e76:	f3040513          	addi	a0,s0,-208
    80005e7a:	c73fe0ef          	jal	80004aec <nameiparent>
    80005e7e:	84aa                	mv	s1,a0
    80005e80:	c945                	beqz	a0,80005f30 <sys_unlink+0xde>
  ilock(dp);
    80005e82:	c3afe0ef          	jal	800042bc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005e86:	00003597          	auipc	a1,0x3
    80005e8a:	83a58593          	addi	a1,a1,-1990 # 800086c0 <etext+0x6c0>
    80005e8e:	fb040513          	addi	a0,s0,-80
    80005e92:	9c5fe0ef          	jal	80004856 <namecmp>
    80005e96:	10050e63          	beqz	a0,80005fb2 <sys_unlink+0x160>
    80005e9a:	00003597          	auipc	a1,0x3
    80005e9e:	82e58593          	addi	a1,a1,-2002 # 800086c8 <etext+0x6c8>
    80005ea2:	fb040513          	addi	a0,s0,-80
    80005ea6:	9b1fe0ef          	jal	80004856 <namecmp>
    80005eaa:	10050463          	beqz	a0,80005fb2 <sys_unlink+0x160>
    80005eae:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005eb0:	f2c40613          	addi	a2,s0,-212
    80005eb4:	fb040593          	addi	a1,s0,-80
    80005eb8:	8526                	mv	a0,s1
    80005eba:	9b3fe0ef          	jal	8000486c <dirlookup>
    80005ebe:	892a                	mv	s2,a0
    80005ec0:	0e050863          	beqz	a0,80005fb0 <sys_unlink+0x15e>
  ilock(ip);
    80005ec4:	bf8fe0ef          	jal	800042bc <ilock>
  if(ip->nlink < 1)
    80005ec8:	04a91783          	lh	a5,74(s2)
    80005ecc:	06f05763          	blez	a5,80005f3a <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ed0:	04491703          	lh	a4,68(s2)
    80005ed4:	4785                	li	a5,1
    80005ed6:	06f70963          	beq	a4,a5,80005f48 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005eda:	4641                	li	a2,16
    80005edc:	4581                	li	a1,0
    80005ede:	fc040513          	addi	a0,s0,-64
    80005ee2:	fcdfa0ef          	jal	80000eae <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ee6:	4741                	li	a4,16
    80005ee8:	f2c42683          	lw	a3,-212(s0)
    80005eec:	fc040613          	addi	a2,s0,-64
    80005ef0:	4581                	li	a1,0
    80005ef2:	8526                	mv	a0,s1
    80005ef4:	855fe0ef          	jal	80004748 <writei>
    80005ef8:	47c1                	li	a5,16
    80005efa:	08f51b63          	bne	a0,a5,80005f90 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005efe:	04491703          	lh	a4,68(s2)
    80005f02:	4785                	li	a5,1
    80005f04:	08f70d63          	beq	a4,a5,80005f9e <sys_unlink+0x14c>
  iunlockput(dp);
    80005f08:	8526                	mv	a0,s1
    80005f0a:	dbcfe0ef          	jal	800044c6 <iunlockput>
  ip->nlink--;
    80005f0e:	04a95783          	lhu	a5,74(s2)
    80005f12:	37fd                	addiw	a5,a5,-1
    80005f14:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f18:	854a                	mv	a0,s2
    80005f1a:	aeefe0ef          	jal	80004208 <iupdate>
  iunlockput(ip);
    80005f1e:	854a                	mv	a0,s2
    80005f20:	da6fe0ef          	jal	800044c6 <iunlockput>
  end_op();
    80005f24:	dedfe0ef          	jal	80004d10 <end_op>
  return 0;
    80005f28:	4501                	li	a0,0
    80005f2a:	64ee                	ld	s1,216(sp)
    80005f2c:	694e                	ld	s2,208(sp)
    80005f2e:	a849                	j	80005fc0 <sys_unlink+0x16e>
    end_op();
    80005f30:	de1fe0ef          	jal	80004d10 <end_op>
    return -1;
    80005f34:	557d                	li	a0,-1
    80005f36:	64ee                	ld	s1,216(sp)
    80005f38:	a061                	j	80005fc0 <sys_unlink+0x16e>
    80005f3a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005f3c:	00002517          	auipc	a0,0x2
    80005f40:	79450513          	addi	a0,a0,1940 # 800086d0 <etext+0x6d0>
    80005f44:	89dfa0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f48:	04c92703          	lw	a4,76(s2)
    80005f4c:	02000793          	li	a5,32
    80005f50:	f8e7f5e3          	bgeu	a5,a4,80005eda <sys_unlink+0x88>
    80005f54:	e5ce                	sd	s3,200(sp)
    80005f56:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f5a:	4741                	li	a4,16
    80005f5c:	86ce                	mv	a3,s3
    80005f5e:	f1840613          	addi	a2,s0,-232
    80005f62:	4581                	li	a1,0
    80005f64:	854a                	mv	a0,s2
    80005f66:	ee6fe0ef          	jal	8000464c <readi>
    80005f6a:	47c1                	li	a5,16
    80005f6c:	00f51c63          	bne	a0,a5,80005f84 <sys_unlink+0x132>
    if(de.inum != 0)
    80005f70:	f1845783          	lhu	a5,-232(s0)
    80005f74:	efa1                	bnez	a5,80005fcc <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005f76:	29c1                	addiw	s3,s3,16
    80005f78:	04c92783          	lw	a5,76(s2)
    80005f7c:	fcf9efe3          	bltu	s3,a5,80005f5a <sys_unlink+0x108>
    80005f80:	69ae                	ld	s3,200(sp)
    80005f82:	bfa1                	j	80005eda <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005f84:	00002517          	auipc	a0,0x2
    80005f88:	76450513          	addi	a0,a0,1892 # 800086e8 <etext+0x6e8>
    80005f8c:	855fa0ef          	jal	800007e0 <panic>
    80005f90:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005f92:	00002517          	auipc	a0,0x2
    80005f96:	76e50513          	addi	a0,a0,1902 # 80008700 <etext+0x700>
    80005f9a:	847fa0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005f9e:	04a4d783          	lhu	a5,74(s1)
    80005fa2:	37fd                	addiw	a5,a5,-1
    80005fa4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005fa8:	8526                	mv	a0,s1
    80005faa:	a5efe0ef          	jal	80004208 <iupdate>
    80005fae:	bfa9                	j	80005f08 <sys_unlink+0xb6>
    80005fb0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005fb2:	8526                	mv	a0,s1
    80005fb4:	d12fe0ef          	jal	800044c6 <iunlockput>
  end_op();
    80005fb8:	d59fe0ef          	jal	80004d10 <end_op>
  return -1;
    80005fbc:	557d                	li	a0,-1
    80005fbe:	64ee                	ld	s1,216(sp)
}
    80005fc0:	70ae                	ld	ra,232(sp)
    80005fc2:	740e                	ld	s0,224(sp)
    80005fc4:	616d                	addi	sp,sp,240
    80005fc6:	8082                	ret
    return -1;
    80005fc8:	557d                	li	a0,-1
    80005fca:	bfdd                	j	80005fc0 <sys_unlink+0x16e>
    iunlockput(ip);
    80005fcc:	854a                	mv	a0,s2
    80005fce:	cf8fe0ef          	jal	800044c6 <iunlockput>
    goto bad;
    80005fd2:	694e                	ld	s2,208(sp)
    80005fd4:	69ae                	ld	s3,200(sp)
    80005fd6:	bff1                	j	80005fb2 <sys_unlink+0x160>

0000000080005fd8 <sys_open>:

uint64
sys_open(void)
{
    80005fd8:	7131                	addi	sp,sp,-192
    80005fda:	fd06                	sd	ra,184(sp)
    80005fdc:	f922                	sd	s0,176(sp)
    80005fde:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005fe0:	f4c40593          	addi	a1,s0,-180
    80005fe4:	4505                	li	a0,1
    80005fe6:	d4cfd0ef          	jal	80003532 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005fea:	08000613          	li	a2,128
    80005fee:	f5040593          	addi	a1,s0,-176
    80005ff2:	4501                	li	a0,0
    80005ff4:	d76fd0ef          	jal	8000356a <argstr>
    80005ff8:	87aa                	mv	a5,a0
    return -1;
    80005ffa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ffc:	0a07c263          	bltz	a5,800060a0 <sys_open+0xc8>
    80006000:	f526                	sd	s1,168(sp)

  begin_op();
    80006002:	ca5fe0ef          	jal	80004ca6 <begin_op>

  if(omode & O_CREATE){
    80006006:	f4c42783          	lw	a5,-180(s0)
    8000600a:	2007f793          	andi	a5,a5,512
    8000600e:	c3d5                	beqz	a5,800060b2 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80006010:	4681                	li	a3,0
    80006012:	4601                	li	a2,0
    80006014:	4589                	li	a1,2
    80006016:	f5040513          	addi	a0,s0,-176
    8000601a:	aa9ff0ef          	jal	80005ac2 <create>
    8000601e:	84aa                	mv	s1,a0
    if(ip == 0){
    80006020:	c541                	beqz	a0,800060a8 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006022:	04449703          	lh	a4,68(s1)
    80006026:	478d                	li	a5,3
    80006028:	00f71763          	bne	a4,a5,80006036 <sys_open+0x5e>
    8000602c:	0464d703          	lhu	a4,70(s1)
    80006030:	47a5                	li	a5,9
    80006032:	0ae7ed63          	bltu	a5,a4,800060ec <sys_open+0x114>
    80006036:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006038:	fd7fe0ef          	jal	8000500e <filealloc>
    8000603c:	892a                	mv	s2,a0
    8000603e:	c179                	beqz	a0,80006104 <sys_open+0x12c>
    80006040:	ed4e                	sd	s3,152(sp)
    80006042:	a43ff0ef          	jal	80005a84 <fdalloc>
    80006046:	89aa                	mv	s3,a0
    80006048:	0a054a63          	bltz	a0,800060fc <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000604c:	04449703          	lh	a4,68(s1)
    80006050:	478d                	li	a5,3
    80006052:	0cf70263          	beq	a4,a5,80006116 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006056:	4789                	li	a5,2
    80006058:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000605c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80006060:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80006064:	f4c42783          	lw	a5,-180(s0)
    80006068:	0017c713          	xori	a4,a5,1
    8000606c:	8b05                	andi	a4,a4,1
    8000606e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006072:	0037f713          	andi	a4,a5,3
    80006076:	00e03733          	snez	a4,a4
    8000607a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000607e:	4007f793          	andi	a5,a5,1024
    80006082:	c791                	beqz	a5,8000608e <sys_open+0xb6>
    80006084:	04449703          	lh	a4,68(s1)
    80006088:	4789                	li	a5,2
    8000608a:	08f70d63          	beq	a4,a5,80006124 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000608e:	8526                	mv	a0,s1
    80006090:	adafe0ef          	jal	8000436a <iunlock>
  end_op();
    80006094:	c7dfe0ef          	jal	80004d10 <end_op>

  return fd;
    80006098:	854e                	mv	a0,s3
    8000609a:	74aa                	ld	s1,168(sp)
    8000609c:	790a                	ld	s2,160(sp)
    8000609e:	69ea                	ld	s3,152(sp)
}
    800060a0:	70ea                	ld	ra,184(sp)
    800060a2:	744a                	ld	s0,176(sp)
    800060a4:	6129                	addi	sp,sp,192
    800060a6:	8082                	ret
      end_op();
    800060a8:	c69fe0ef          	jal	80004d10 <end_op>
      return -1;
    800060ac:	557d                	li	a0,-1
    800060ae:	74aa                	ld	s1,168(sp)
    800060b0:	bfc5                	j	800060a0 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800060b2:	f5040513          	addi	a0,s0,-176
    800060b6:	a1dfe0ef          	jal	80004ad2 <namei>
    800060ba:	84aa                	mv	s1,a0
    800060bc:	c11d                	beqz	a0,800060e2 <sys_open+0x10a>
    ilock(ip);
    800060be:	9fefe0ef          	jal	800042bc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800060c2:	04449703          	lh	a4,68(s1)
    800060c6:	4785                	li	a5,1
    800060c8:	f4f71de3          	bne	a4,a5,80006022 <sys_open+0x4a>
    800060cc:	f4c42783          	lw	a5,-180(s0)
    800060d0:	d3bd                	beqz	a5,80006036 <sys_open+0x5e>
      iunlockput(ip);
    800060d2:	8526                	mv	a0,s1
    800060d4:	bf2fe0ef          	jal	800044c6 <iunlockput>
      end_op();
    800060d8:	c39fe0ef          	jal	80004d10 <end_op>
      return -1;
    800060dc:	557d                	li	a0,-1
    800060de:	74aa                	ld	s1,168(sp)
    800060e0:	b7c1                	j	800060a0 <sys_open+0xc8>
      end_op();
    800060e2:	c2ffe0ef          	jal	80004d10 <end_op>
      return -1;
    800060e6:	557d                	li	a0,-1
    800060e8:	74aa                	ld	s1,168(sp)
    800060ea:	bf5d                	j	800060a0 <sys_open+0xc8>
    iunlockput(ip);
    800060ec:	8526                	mv	a0,s1
    800060ee:	bd8fe0ef          	jal	800044c6 <iunlockput>
    end_op();
    800060f2:	c1ffe0ef          	jal	80004d10 <end_op>
    return -1;
    800060f6:	557d                	li	a0,-1
    800060f8:	74aa                	ld	s1,168(sp)
    800060fa:	b75d                	j	800060a0 <sys_open+0xc8>
      fileclose(f);
    800060fc:	854a                	mv	a0,s2
    800060fe:	fb5fe0ef          	jal	800050b2 <fileclose>
    80006102:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006104:	8526                	mv	a0,s1
    80006106:	bc0fe0ef          	jal	800044c6 <iunlockput>
    end_op();
    8000610a:	c07fe0ef          	jal	80004d10 <end_op>
    return -1;
    8000610e:	557d                	li	a0,-1
    80006110:	74aa                	ld	s1,168(sp)
    80006112:	790a                	ld	s2,160(sp)
    80006114:	b771                	j	800060a0 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80006116:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000611a:	04649783          	lh	a5,70(s1)
    8000611e:	02f91223          	sh	a5,36(s2)
    80006122:	bf3d                	j	80006060 <sys_open+0x88>
    itrunc(ip);
    80006124:	8526                	mv	a0,s1
    80006126:	a84fe0ef          	jal	800043aa <itrunc>
    8000612a:	b795                	j	8000608e <sys_open+0xb6>

000000008000612c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000612c:	7175                	addi	sp,sp,-144
    8000612e:	e506                	sd	ra,136(sp)
    80006130:	e122                	sd	s0,128(sp)
    80006132:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006134:	b73fe0ef          	jal	80004ca6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006138:	08000613          	li	a2,128
    8000613c:	f7040593          	addi	a1,s0,-144
    80006140:	4501                	li	a0,0
    80006142:	c28fd0ef          	jal	8000356a <argstr>
    80006146:	02054363          	bltz	a0,8000616c <sys_mkdir+0x40>
    8000614a:	4681                	li	a3,0
    8000614c:	4601                	li	a2,0
    8000614e:	4585                	li	a1,1
    80006150:	f7040513          	addi	a0,s0,-144
    80006154:	96fff0ef          	jal	80005ac2 <create>
    80006158:	c911                	beqz	a0,8000616c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000615a:	b6cfe0ef          	jal	800044c6 <iunlockput>
  end_op();
    8000615e:	bb3fe0ef          	jal	80004d10 <end_op>
  return 0;
    80006162:	4501                	li	a0,0
}
    80006164:	60aa                	ld	ra,136(sp)
    80006166:	640a                	ld	s0,128(sp)
    80006168:	6149                	addi	sp,sp,144
    8000616a:	8082                	ret
    end_op();
    8000616c:	ba5fe0ef          	jal	80004d10 <end_op>
    return -1;
    80006170:	557d                	li	a0,-1
    80006172:	bfcd                	j	80006164 <sys_mkdir+0x38>

0000000080006174 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006174:	7135                	addi	sp,sp,-160
    80006176:	ed06                	sd	ra,152(sp)
    80006178:	e922                	sd	s0,144(sp)
    8000617a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000617c:	b2bfe0ef          	jal	80004ca6 <begin_op>
  argint(1, &major);
    80006180:	f6c40593          	addi	a1,s0,-148
    80006184:	4505                	li	a0,1
    80006186:	bacfd0ef          	jal	80003532 <argint>
  argint(2, &minor);
    8000618a:	f6840593          	addi	a1,s0,-152
    8000618e:	4509                	li	a0,2
    80006190:	ba2fd0ef          	jal	80003532 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006194:	08000613          	li	a2,128
    80006198:	f7040593          	addi	a1,s0,-144
    8000619c:	4501                	li	a0,0
    8000619e:	bccfd0ef          	jal	8000356a <argstr>
    800061a2:	02054563          	bltz	a0,800061cc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800061a6:	f6841683          	lh	a3,-152(s0)
    800061aa:	f6c41603          	lh	a2,-148(s0)
    800061ae:	458d                	li	a1,3
    800061b0:	f7040513          	addi	a0,s0,-144
    800061b4:	90fff0ef          	jal	80005ac2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800061b8:	c911                	beqz	a0,800061cc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800061ba:	b0cfe0ef          	jal	800044c6 <iunlockput>
  end_op();
    800061be:	b53fe0ef          	jal	80004d10 <end_op>
  return 0;
    800061c2:	4501                	li	a0,0
}
    800061c4:	60ea                	ld	ra,152(sp)
    800061c6:	644a                	ld	s0,144(sp)
    800061c8:	610d                	addi	sp,sp,160
    800061ca:	8082                	ret
    end_op();
    800061cc:	b45fe0ef          	jal	80004d10 <end_op>
    return -1;
    800061d0:	557d                	li	a0,-1
    800061d2:	bfcd                	j	800061c4 <sys_mknod+0x50>

00000000800061d4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800061d4:	7135                	addi	sp,sp,-160
    800061d6:	ed06                	sd	ra,152(sp)
    800061d8:	e922                	sd	s0,144(sp)
    800061da:	e14a                	sd	s2,128(sp)
    800061dc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800061de:	b89fb0ef          	jal	80001d66 <myproc>
    800061e2:	892a                	mv	s2,a0
  
  begin_op();
    800061e4:	ac3fe0ef          	jal	80004ca6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061e8:	08000613          	li	a2,128
    800061ec:	f6040593          	addi	a1,s0,-160
    800061f0:	4501                	li	a0,0
    800061f2:	b78fd0ef          	jal	8000356a <argstr>
    800061f6:	04054363          	bltz	a0,8000623c <sys_chdir+0x68>
    800061fa:	e526                	sd	s1,136(sp)
    800061fc:	f6040513          	addi	a0,s0,-160
    80006200:	8d3fe0ef          	jal	80004ad2 <namei>
    80006204:	84aa                	mv	s1,a0
    80006206:	c915                	beqz	a0,8000623a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80006208:	8b4fe0ef          	jal	800042bc <ilock>
  if(ip->type != T_DIR){
    8000620c:	04449703          	lh	a4,68(s1)
    80006210:	4785                	li	a5,1
    80006212:	02f71963          	bne	a4,a5,80006244 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006216:	8526                	mv	a0,s1
    80006218:	952fe0ef          	jal	8000436a <iunlock>
  iput(p->cwd);
    8000621c:	15093503          	ld	a0,336(s2)
    80006220:	a1efe0ef          	jal	8000443e <iput>
  end_op();
    80006224:	aedfe0ef          	jal	80004d10 <end_op>
  p->cwd = ip;
    80006228:	14993823          	sd	s1,336(s2)
  return 0;
    8000622c:	4501                	li	a0,0
    8000622e:	64aa                	ld	s1,136(sp)
}
    80006230:	60ea                	ld	ra,152(sp)
    80006232:	644a                	ld	s0,144(sp)
    80006234:	690a                	ld	s2,128(sp)
    80006236:	610d                	addi	sp,sp,160
    80006238:	8082                	ret
    8000623a:	64aa                	ld	s1,136(sp)
    end_op();
    8000623c:	ad5fe0ef          	jal	80004d10 <end_op>
    return -1;
    80006240:	557d                	li	a0,-1
    80006242:	b7fd                	j	80006230 <sys_chdir+0x5c>
    iunlockput(ip);
    80006244:	8526                	mv	a0,s1
    80006246:	a80fe0ef          	jal	800044c6 <iunlockput>
    end_op();
    8000624a:	ac7fe0ef          	jal	80004d10 <end_op>
    return -1;
    8000624e:	557d                	li	a0,-1
    80006250:	64aa                	ld	s1,136(sp)
    80006252:	bff9                	j	80006230 <sys_chdir+0x5c>

0000000080006254 <sys_exec>:

uint64
sys_exec(void)
{
    80006254:	7121                	addi	sp,sp,-448
    80006256:	ff06                	sd	ra,440(sp)
    80006258:	fb22                	sd	s0,432(sp)
    8000625a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000625c:	e4840593          	addi	a1,s0,-440
    80006260:	4505                	li	a0,1
    80006262:	aecfd0ef          	jal	8000354e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006266:	08000613          	li	a2,128
    8000626a:	f5040593          	addi	a1,s0,-176
    8000626e:	4501                	li	a0,0
    80006270:	afafd0ef          	jal	8000356a <argstr>
    80006274:	87aa                	mv	a5,a0
    return -1;
    80006276:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006278:	0c07c463          	bltz	a5,80006340 <sys_exec+0xec>
    8000627c:	f726                	sd	s1,424(sp)
    8000627e:	f34a                	sd	s2,416(sp)
    80006280:	ef4e                	sd	s3,408(sp)
    80006282:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80006284:	10000613          	li	a2,256
    80006288:	4581                	li	a1,0
    8000628a:	e5040513          	addi	a0,s0,-432
    8000628e:	c21fa0ef          	jal	80000eae <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006292:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80006296:	89a6                	mv	s3,s1
    80006298:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000629a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000629e:	00391513          	slli	a0,s2,0x3
    800062a2:	e4040593          	addi	a1,s0,-448
    800062a6:	e4843783          	ld	a5,-440(s0)
    800062aa:	953e                	add	a0,a0,a5
    800062ac:	9fcfd0ef          	jal	800034a8 <fetchaddr>
    800062b0:	02054663          	bltz	a0,800062dc <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800062b4:	e4043783          	ld	a5,-448(s0)
    800062b8:	c3a9                	beqz	a5,800062fa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062ba:	a27fa0ef          	jal	80000ce0 <kalloc>
    800062be:	85aa                	mv	a1,a0
    800062c0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800062c4:	cd01                	beqz	a0,800062dc <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800062c6:	6605                	lui	a2,0x1
    800062c8:	e4043503          	ld	a0,-448(s0)
    800062cc:	a26fd0ef          	jal	800034f2 <fetchstr>
    800062d0:	00054663          	bltz	a0,800062dc <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800062d4:	0905                	addi	s2,s2,1
    800062d6:	09a1                	addi	s3,s3,8
    800062d8:	fd4913e3          	bne	s2,s4,8000629e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062dc:	f5040913          	addi	s2,s0,-176
    800062e0:	6088                	ld	a0,0(s1)
    800062e2:	c931                	beqz	a0,80006336 <sys_exec+0xe2>
    kfree(argv[i]);
    800062e4:	87bfa0ef          	jal	80000b5e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062e8:	04a1                	addi	s1,s1,8
    800062ea:	ff249be3          	bne	s1,s2,800062e0 <sys_exec+0x8c>
  return -1;
    800062ee:	557d                	li	a0,-1
    800062f0:	74ba                	ld	s1,424(sp)
    800062f2:	791a                	ld	s2,416(sp)
    800062f4:	69fa                	ld	s3,408(sp)
    800062f6:	6a5a                	ld	s4,400(sp)
    800062f8:	a0a1                	j	80006340 <sys_exec+0xec>
      argv[i] = 0;
    800062fa:	0009079b          	sext.w	a5,s2
    800062fe:	078e                	slli	a5,a5,0x3
    80006300:	fd078793          	addi	a5,a5,-48
    80006304:	97a2                	add	a5,a5,s0
    80006306:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000630a:	e5040593          	addi	a1,s0,-432
    8000630e:	f5040513          	addi	a0,s0,-176
    80006312:	ba8ff0ef          	jal	800056ba <kexec>
    80006316:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006318:	f5040993          	addi	s3,s0,-176
    8000631c:	6088                	ld	a0,0(s1)
    8000631e:	c511                	beqz	a0,8000632a <sys_exec+0xd6>
    kfree(argv[i]);
    80006320:	83ffa0ef          	jal	80000b5e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006324:	04a1                	addi	s1,s1,8
    80006326:	ff349be3          	bne	s1,s3,8000631c <sys_exec+0xc8>
  return ret;
    8000632a:	854a                	mv	a0,s2
    8000632c:	74ba                	ld	s1,424(sp)
    8000632e:	791a                	ld	s2,416(sp)
    80006330:	69fa                	ld	s3,408(sp)
    80006332:	6a5a                	ld	s4,400(sp)
    80006334:	a031                	j	80006340 <sys_exec+0xec>
  return -1;
    80006336:	557d                	li	a0,-1
    80006338:	74ba                	ld	s1,424(sp)
    8000633a:	791a                	ld	s2,416(sp)
    8000633c:	69fa                	ld	s3,408(sp)
    8000633e:	6a5a                	ld	s4,400(sp)
}
    80006340:	70fa                	ld	ra,440(sp)
    80006342:	745a                	ld	s0,432(sp)
    80006344:	6139                	addi	sp,sp,448
    80006346:	8082                	ret

0000000080006348 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006348:	7139                	addi	sp,sp,-64
    8000634a:	fc06                	sd	ra,56(sp)
    8000634c:	f822                	sd	s0,48(sp)
    8000634e:	f426                	sd	s1,40(sp)
    80006350:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006352:	a15fb0ef          	jal	80001d66 <myproc>
    80006356:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006358:	fd840593          	addi	a1,s0,-40
    8000635c:	4501                	li	a0,0
    8000635e:	9f0fd0ef          	jal	8000354e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006362:	fc840593          	addi	a1,s0,-56
    80006366:	fd040513          	addi	a0,s0,-48
    8000636a:	852ff0ef          	jal	800053bc <pipealloc>
    return -1;
    8000636e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006370:	0a054463          	bltz	a0,80006418 <sys_pipe+0xd0>
  fd0 = -1;
    80006374:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006378:	fd043503          	ld	a0,-48(s0)
    8000637c:	f08ff0ef          	jal	80005a84 <fdalloc>
    80006380:	fca42223          	sw	a0,-60(s0)
    80006384:	08054163          	bltz	a0,80006406 <sys_pipe+0xbe>
    80006388:	fc843503          	ld	a0,-56(s0)
    8000638c:	ef8ff0ef          	jal	80005a84 <fdalloc>
    80006390:	fca42023          	sw	a0,-64(s0)
    80006394:	06054063          	bltz	a0,800063f4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006398:	4691                	li	a3,4
    8000639a:	fc440613          	addi	a2,s0,-60
    8000639e:	fd843583          	ld	a1,-40(s0)
    800063a2:	68a8                	ld	a0,80(s1)
    800063a4:	da0fb0ef          	jal	80001944 <copyout>
    800063a8:	00054e63          	bltz	a0,800063c4 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063ac:	4691                	li	a3,4
    800063ae:	fc040613          	addi	a2,s0,-64
    800063b2:	fd843583          	ld	a1,-40(s0)
    800063b6:	0591                	addi	a1,a1,4
    800063b8:	68a8                	ld	a0,80(s1)
    800063ba:	d8afb0ef          	jal	80001944 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063be:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063c0:	04055c63          	bgez	a0,80006418 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800063c4:	fc442783          	lw	a5,-60(s0)
    800063c8:	07e9                	addi	a5,a5,26
    800063ca:	078e                	slli	a5,a5,0x3
    800063cc:	97a6                	add	a5,a5,s1
    800063ce:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800063d2:	fc042783          	lw	a5,-64(s0)
    800063d6:	07e9                	addi	a5,a5,26
    800063d8:	078e                	slli	a5,a5,0x3
    800063da:	94be                	add	s1,s1,a5
    800063dc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800063e0:	fd043503          	ld	a0,-48(s0)
    800063e4:	ccffe0ef          	jal	800050b2 <fileclose>
    fileclose(wf);
    800063e8:	fc843503          	ld	a0,-56(s0)
    800063ec:	cc7fe0ef          	jal	800050b2 <fileclose>
    return -1;
    800063f0:	57fd                	li	a5,-1
    800063f2:	a01d                	j	80006418 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800063f4:	fc442783          	lw	a5,-60(s0)
    800063f8:	0007c763          	bltz	a5,80006406 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800063fc:	07e9                	addi	a5,a5,26
    800063fe:	078e                	slli	a5,a5,0x3
    80006400:	97a6                	add	a5,a5,s1
    80006402:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006406:	fd043503          	ld	a0,-48(s0)
    8000640a:	ca9fe0ef          	jal	800050b2 <fileclose>
    fileclose(wf);
    8000640e:	fc843503          	ld	a0,-56(s0)
    80006412:	ca1fe0ef          	jal	800050b2 <fileclose>
    return -1;
    80006416:	57fd                	li	a5,-1
}
    80006418:	853e                	mv	a0,a5
    8000641a:	70e2                	ld	ra,56(sp)
    8000641c:	7442                	ld	s0,48(sp)
    8000641e:	74a2                	ld	s1,40(sp)
    80006420:	6121                	addi	sp,sp,64
    80006422:	8082                	ret
	...

0000000080006430 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006430:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006432:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006434:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006436:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006438:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000643a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000643c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000643e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006440:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006442:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006444:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006446:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006448:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000644a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000644c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000644e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80006450:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80006452:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80006454:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80006456:	f63fc0ef          	jal	800033b8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000645a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000645c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000645e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80006460:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80006462:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80006464:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80006466:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80006468:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000646a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000646c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000646e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80006470:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80006472:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80006474:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80006476:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80006478:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000647a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000647c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000647e:	10200073          	sret
	...

000000008000648e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000648e:	1141                	addi	sp,sp,-16
    80006490:	e422                	sd	s0,8(sp)
    80006492:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006494:	0c0007b7          	lui	a5,0xc000
    80006498:	4705                	li	a4,1
    8000649a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000649c:	0c0007b7          	lui	a5,0xc000
    800064a0:	c3d8                	sw	a4,4(a5)
}
    800064a2:	6422                	ld	s0,8(sp)
    800064a4:	0141                	addi	sp,sp,16
    800064a6:	8082                	ret

00000000800064a8 <plicinithart>:

void
plicinithart(void)
{
    800064a8:	1141                	addi	sp,sp,-16
    800064aa:	e406                	sd	ra,8(sp)
    800064ac:	e022                	sd	s0,0(sp)
    800064ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064b0:	88bfb0ef          	jal	80001d3a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800064b4:	0085171b          	slliw	a4,a0,0x8
    800064b8:	0c0027b7          	lui	a5,0xc002
    800064bc:	97ba                	add	a5,a5,a4
    800064be:	40200713          	li	a4,1026
    800064c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064c6:	00d5151b          	slliw	a0,a0,0xd
    800064ca:	0c2017b7          	lui	a5,0xc201
    800064ce:	97aa                	add	a5,a5,a0
    800064d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800064d4:	60a2                	ld	ra,8(sp)
    800064d6:	6402                	ld	s0,0(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064dc:	1141                	addi	sp,sp,-16
    800064de:	e406                	sd	ra,8(sp)
    800064e0:	e022                	sd	s0,0(sp)
    800064e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064e4:	857fb0ef          	jal	80001d3a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064e8:	00d5151b          	slliw	a0,a0,0xd
    800064ec:	0c2017b7          	lui	a5,0xc201
    800064f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800064f2:	43c8                	lw	a0,4(a5)
    800064f4:	60a2                	ld	ra,8(sp)
    800064f6:	6402                	ld	s0,0(sp)
    800064f8:	0141                	addi	sp,sp,16
    800064fa:	8082                	ret

00000000800064fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064fc:	1101                	addi	sp,sp,-32
    800064fe:	ec06                	sd	ra,24(sp)
    80006500:	e822                	sd	s0,16(sp)
    80006502:	e426                	sd	s1,8(sp)
    80006504:	1000                	addi	s0,sp,32
    80006506:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006508:	833fb0ef          	jal	80001d3a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000650c:	00d5151b          	slliw	a0,a0,0xd
    80006510:	0c2017b7          	lui	a5,0xc201
    80006514:	97aa                	add	a5,a5,a0
    80006516:	c3c4                	sw	s1,4(a5)
}
    80006518:	60e2                	ld	ra,24(sp)
    8000651a:	6442                	ld	s0,16(sp)
    8000651c:	64a2                	ld	s1,8(sp)
    8000651e:	6105                	addi	sp,sp,32
    80006520:	8082                	ret

0000000080006522 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006522:	1141                	addi	sp,sp,-16
    80006524:	e406                	sd	ra,8(sp)
    80006526:	e022                	sd	s0,0(sp)
    80006528:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000652a:	479d                	li	a5,7
    8000652c:	04a7ca63          	blt	a5,a0,80006580 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006530:	0003d797          	auipc	a5,0x3d
    80006534:	8b078793          	addi	a5,a5,-1872 # 80042de0 <disk>
    80006538:	97aa                	add	a5,a5,a0
    8000653a:	0187c783          	lbu	a5,24(a5)
    8000653e:	e7b9                	bnez	a5,8000658c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006540:	00451693          	slli	a3,a0,0x4
    80006544:	0003d797          	auipc	a5,0x3d
    80006548:	89c78793          	addi	a5,a5,-1892 # 80042de0 <disk>
    8000654c:	6398                	ld	a4,0(a5)
    8000654e:	9736                	add	a4,a4,a3
    80006550:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006554:	6398                	ld	a4,0(a5)
    80006556:	9736                	add	a4,a4,a3
    80006558:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000655c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006560:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006564:	97aa                	add	a5,a5,a0
    80006566:	4705                	li	a4,1
    80006568:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000656c:	0003d517          	auipc	a0,0x3d
    80006570:	88c50513          	addi	a0,a0,-1908 # 80042df8 <disk+0x18>
    80006574:	c42fc0ef          	jal	800029b6 <wakeup>
}
    80006578:	60a2                	ld	ra,8(sp)
    8000657a:	6402                	ld	s0,0(sp)
    8000657c:	0141                	addi	sp,sp,16
    8000657e:	8082                	ret
    panic("free_desc 1");
    80006580:	00002517          	auipc	a0,0x2
    80006584:	19050513          	addi	a0,a0,400 # 80008710 <etext+0x710>
    80006588:	a58fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000658c:	00002517          	auipc	a0,0x2
    80006590:	19450513          	addi	a0,a0,404 # 80008720 <etext+0x720>
    80006594:	a4cfa0ef          	jal	800007e0 <panic>

0000000080006598 <virtio_disk_init>:
{
    80006598:	1101                	addi	sp,sp,-32
    8000659a:	ec06                	sd	ra,24(sp)
    8000659c:	e822                	sd	s0,16(sp)
    8000659e:	e426                	sd	s1,8(sp)
    800065a0:	e04a                	sd	s2,0(sp)
    800065a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800065a4:	00002597          	auipc	a1,0x2
    800065a8:	18c58593          	addi	a1,a1,396 # 80008730 <etext+0x730>
    800065ac:	0003d517          	auipc	a0,0x3d
    800065b0:	95c50513          	addi	a0,a0,-1700 # 80042f08 <disk+0x128>
    800065b4:	fa6fa0ef          	jal	80000d5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065b8:	100017b7          	lui	a5,0x10001
    800065bc:	4398                	lw	a4,0(a5)
    800065be:	2701                	sext.w	a4,a4
    800065c0:	747277b7          	lui	a5,0x74727
    800065c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065c8:	18f71063          	bne	a4,a5,80006748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065cc:	100017b7          	lui	a5,0x10001
    800065d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800065d2:	439c                	lw	a5,0(a5)
    800065d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065d6:	4709                	li	a4,2
    800065d8:	16e79863          	bne	a5,a4,80006748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065dc:	100017b7          	lui	a5,0x10001
    800065e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800065e2:	439c                	lw	a5,0(a5)
    800065e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065e6:	16e79163          	bne	a5,a4,80006748 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065ea:	100017b7          	lui	a5,0x10001
    800065ee:	47d8                	lw	a4,12(a5)
    800065f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065f2:	554d47b7          	lui	a5,0x554d4
    800065f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065fa:	14f71763          	bne	a4,a5,80006748 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065fe:	100017b7          	lui	a5,0x10001
    80006602:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006606:	4705                	li	a4,1
    80006608:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000660a:	470d                	li	a4,3
    8000660c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000660e:	10001737          	lui	a4,0x10001
    80006612:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006614:	c7ffe737          	lui	a4,0xc7ffe
    80006618:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb627>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000661c:	8ef9                	and	a3,a3,a4
    8000661e:	10001737          	lui	a4,0x10001
    80006622:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006624:	472d                	li	a4,11
    80006626:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006628:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000662c:	439c                	lw	a5,0(a5)
    8000662e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006632:	8ba1                	andi	a5,a5,8
    80006634:	12078063          	beqz	a5,80006754 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006638:	100017b7          	lui	a5,0x10001
    8000663c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006640:	100017b7          	lui	a5,0x10001
    80006644:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006648:	439c                	lw	a5,0(a5)
    8000664a:	2781                	sext.w	a5,a5
    8000664c:	10079a63          	bnez	a5,80006760 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006650:	100017b7          	lui	a5,0x10001
    80006654:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006658:	439c                	lw	a5,0(a5)
    8000665a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000665c:	10078863          	beqz	a5,8000676c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80006660:	471d                	li	a4,7
    80006662:	10f77b63          	bgeu	a4,a5,80006778 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80006666:	e7afa0ef          	jal	80000ce0 <kalloc>
    8000666a:	0003c497          	auipc	s1,0x3c
    8000666e:	77648493          	addi	s1,s1,1910 # 80042de0 <disk>
    80006672:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006674:	e6cfa0ef          	jal	80000ce0 <kalloc>
    80006678:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000667a:	e66fa0ef          	jal	80000ce0 <kalloc>
    8000667e:	87aa                	mv	a5,a0
    80006680:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006682:	6088                	ld	a0,0(s1)
    80006684:	10050063          	beqz	a0,80006784 <virtio_disk_init+0x1ec>
    80006688:	0003c717          	auipc	a4,0x3c
    8000668c:	76073703          	ld	a4,1888(a4) # 80042de8 <disk+0x8>
    80006690:	0e070a63          	beqz	a4,80006784 <virtio_disk_init+0x1ec>
    80006694:	0e078863          	beqz	a5,80006784 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006698:	6605                	lui	a2,0x1
    8000669a:	4581                	li	a1,0
    8000669c:	813fa0ef          	jal	80000eae <memset>
  memset(disk.avail, 0, PGSIZE);
    800066a0:	0003c497          	auipc	s1,0x3c
    800066a4:	74048493          	addi	s1,s1,1856 # 80042de0 <disk>
    800066a8:	6605                	lui	a2,0x1
    800066aa:	4581                	li	a1,0
    800066ac:	6488                	ld	a0,8(s1)
    800066ae:	801fa0ef          	jal	80000eae <memset>
  memset(disk.used, 0, PGSIZE);
    800066b2:	6605                	lui	a2,0x1
    800066b4:	4581                	li	a1,0
    800066b6:	6888                	ld	a0,16(s1)
    800066b8:	ff6fa0ef          	jal	80000eae <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066bc:	100017b7          	lui	a5,0x10001
    800066c0:	4721                	li	a4,8
    800066c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066c4:	4098                	lw	a4,0(s1)
    800066c6:	100017b7          	lui	a5,0x10001
    800066ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066ce:	40d8                	lw	a4,4(s1)
    800066d0:	100017b7          	lui	a5,0x10001
    800066d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800066d8:	649c                	ld	a5,8(s1)
    800066da:	0007869b          	sext.w	a3,a5
    800066de:	10001737          	lui	a4,0x10001
    800066e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066e6:	9781                	srai	a5,a5,0x20
    800066e8:	10001737          	lui	a4,0x10001
    800066ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066f0:	689c                	ld	a5,16(s1)
    800066f2:	0007869b          	sext.w	a3,a5
    800066f6:	10001737          	lui	a4,0x10001
    800066fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066fe:	9781                	srai	a5,a5,0x20
    80006700:	10001737          	lui	a4,0x10001
    80006704:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006708:	10001737          	lui	a4,0x10001
    8000670c:	4785                	li	a5,1
    8000670e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006710:	00f48c23          	sb	a5,24(s1)
    80006714:	00f48ca3          	sb	a5,25(s1)
    80006718:	00f48d23          	sb	a5,26(s1)
    8000671c:	00f48da3          	sb	a5,27(s1)
    80006720:	00f48e23          	sb	a5,28(s1)
    80006724:	00f48ea3          	sb	a5,29(s1)
    80006728:	00f48f23          	sb	a5,30(s1)
    8000672c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006730:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006734:	100017b7          	lui	a5,0x10001
    80006738:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000673c:	60e2                	ld	ra,24(sp)
    8000673e:	6442                	ld	s0,16(sp)
    80006740:	64a2                	ld	s1,8(sp)
    80006742:	6902                	ld	s2,0(sp)
    80006744:	6105                	addi	sp,sp,32
    80006746:	8082                	ret
    panic("could not find virtio disk");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	ff850513          	addi	a0,a0,-8 # 80008740 <etext+0x740>
    80006750:	890fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006754:	00002517          	auipc	a0,0x2
    80006758:	00c50513          	addi	a0,a0,12 # 80008760 <etext+0x760>
    8000675c:	884fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80006760:	00002517          	auipc	a0,0x2
    80006764:	02050513          	addi	a0,a0,32 # 80008780 <etext+0x780>
    80006768:	878fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000676c:	00002517          	auipc	a0,0x2
    80006770:	03450513          	addi	a0,a0,52 # 800087a0 <etext+0x7a0>
    80006774:	86cfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80006778:	00002517          	auipc	a0,0x2
    8000677c:	04850513          	addi	a0,a0,72 # 800087c0 <etext+0x7c0>
    80006780:	860fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80006784:	00002517          	auipc	a0,0x2
    80006788:	05c50513          	addi	a0,a0,92 # 800087e0 <etext+0x7e0>
    8000678c:	854fa0ef          	jal	800007e0 <panic>

0000000080006790 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006790:	7159                	addi	sp,sp,-112
    80006792:	f486                	sd	ra,104(sp)
    80006794:	f0a2                	sd	s0,96(sp)
    80006796:	eca6                	sd	s1,88(sp)
    80006798:	e8ca                	sd	s2,80(sp)
    8000679a:	e4ce                	sd	s3,72(sp)
    8000679c:	e0d2                	sd	s4,64(sp)
    8000679e:	fc56                	sd	s5,56(sp)
    800067a0:	f85a                	sd	s6,48(sp)
    800067a2:	f45e                	sd	s7,40(sp)
    800067a4:	f062                	sd	s8,32(sp)
    800067a6:	ec66                	sd	s9,24(sp)
    800067a8:	1880                	addi	s0,sp,112
    800067aa:	8a2a                	mv	s4,a0
    800067ac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067ae:	00c52c83          	lw	s9,12(a0)
    800067b2:	001c9c9b          	slliw	s9,s9,0x1
    800067b6:	1c82                	slli	s9,s9,0x20
    800067b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800067bc:	0003c517          	auipc	a0,0x3c
    800067c0:	74c50513          	addi	a0,a0,1868 # 80042f08 <disk+0x128>
    800067c4:	e16fa0ef          	jal	80000dda <acquire>
  for(int i = 0; i < 3; i++){
    800067c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800067cc:	0003cb17          	auipc	s6,0x3c
    800067d0:	614b0b13          	addi	s6,s6,1556 # 80042de0 <disk>
  for(int i = 0; i < 3; i++){
    800067d4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067d6:	0003cc17          	auipc	s8,0x3c
    800067da:	732c0c13          	addi	s8,s8,1842 # 80042f08 <disk+0x128>
    800067de:	a8b9                	j	8000683c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800067e0:	00fb0733          	add	a4,s6,a5
    800067e4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800067e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067ea:	0207c563          	bltz	a5,80006814 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800067ee:	2905                	addiw	s2,s2,1
    800067f0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800067f2:	05590963          	beq	s2,s5,80006844 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800067f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800067f8:	0003c717          	auipc	a4,0x3c
    800067fc:	5e870713          	addi	a4,a4,1512 # 80042de0 <disk>
    80006800:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006802:	01874683          	lbu	a3,24(a4)
    80006806:	fee9                	bnez	a3,800067e0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006808:	2785                	addiw	a5,a5,1
    8000680a:	0705                	addi	a4,a4,1
    8000680c:	fe979be3          	bne	a5,s1,80006802 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006810:	57fd                	li	a5,-1
    80006812:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006814:	01205d63          	blez	s2,8000682e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006818:	f9042503          	lw	a0,-112(s0)
    8000681c:	d07ff0ef          	jal	80006522 <free_desc>
      for(int j = 0; j < i; j++)
    80006820:	4785                	li	a5,1
    80006822:	0127d663          	bge	a5,s2,8000682e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006826:	f9442503          	lw	a0,-108(s0)
    8000682a:	cf9ff0ef          	jal	80006522 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000682e:	85e2                	mv	a1,s8
    80006830:	0003c517          	auipc	a0,0x3c
    80006834:	5c850513          	addi	a0,a0,1480 # 80042df8 <disk+0x18>
    80006838:	932fc0ef          	jal	8000296a <sleep>
  for(int i = 0; i < 3; i++){
    8000683c:	f9040613          	addi	a2,s0,-112
    80006840:	894e                	mv	s2,s3
    80006842:	bf55                	j	800067f6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006844:	f9042503          	lw	a0,-112(s0)
    80006848:	00451693          	slli	a3,a0,0x4

  if(write)
    8000684c:	0003c797          	auipc	a5,0x3c
    80006850:	59478793          	addi	a5,a5,1428 # 80042de0 <disk>
    80006854:	00a50713          	addi	a4,a0,10
    80006858:	0712                	slli	a4,a4,0x4
    8000685a:	973e                	add	a4,a4,a5
    8000685c:	01703633          	snez	a2,s7
    80006860:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006862:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006866:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000686a:	6398                	ld	a4,0(a5)
    8000686c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000686e:	0a868613          	addi	a2,a3,168
    80006872:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006874:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006876:	6390                	ld	a2,0(a5)
    80006878:	00d605b3          	add	a1,a2,a3
    8000687c:	4741                	li	a4,16
    8000687e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006880:	4805                	li	a6,1
    80006882:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006886:	f9442703          	lw	a4,-108(s0)
    8000688a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000688e:	0712                	slli	a4,a4,0x4
    80006890:	963a                	add	a2,a2,a4
    80006892:	058a0593          	addi	a1,s4,88
    80006896:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006898:	0007b883          	ld	a7,0(a5)
    8000689c:	9746                	add	a4,a4,a7
    8000689e:	40000613          	li	a2,1024
    800068a2:	c710                	sw	a2,8(a4)
  if(write)
    800068a4:	001bb613          	seqz	a2,s7
    800068a8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068ac:	00166613          	ori	a2,a2,1
    800068b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800068b4:	f9842583          	lw	a1,-104(s0)
    800068b8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800068bc:	00250613          	addi	a2,a0,2
    800068c0:	0612                	slli	a2,a2,0x4
    800068c2:	963e                	add	a2,a2,a5
    800068c4:	577d                	li	a4,-1
    800068c6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068ca:	0592                	slli	a1,a1,0x4
    800068cc:	98ae                	add	a7,a7,a1
    800068ce:	03068713          	addi	a4,a3,48
    800068d2:	973e                	add	a4,a4,a5
    800068d4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800068d8:	6398                	ld	a4,0(a5)
    800068da:	972e                	add	a4,a4,a1
    800068dc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068e0:	4689                	li	a3,2
    800068e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800068e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068ea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800068ee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068f2:	6794                	ld	a3,8(a5)
    800068f4:	0026d703          	lhu	a4,2(a3)
    800068f8:	8b1d                	andi	a4,a4,7
    800068fa:	0706                	slli	a4,a4,0x1
    800068fc:	96ba                	add	a3,a3,a4
    800068fe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006902:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006906:	6798                	ld	a4,8(a5)
    80006908:	00275783          	lhu	a5,2(a4)
    8000690c:	2785                	addiw	a5,a5,1
    8000690e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006912:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006916:	100017b7          	lui	a5,0x10001
    8000691a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000691e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006922:	0003c917          	auipc	s2,0x3c
    80006926:	5e690913          	addi	s2,s2,1510 # 80042f08 <disk+0x128>
  while(b->disk == 1) {
    8000692a:	4485                	li	s1,1
    8000692c:	01079a63          	bne	a5,a6,80006940 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006930:	85ca                	mv	a1,s2
    80006932:	8552                	mv	a0,s4
    80006934:	836fc0ef          	jal	8000296a <sleep>
  while(b->disk == 1) {
    80006938:	004a2783          	lw	a5,4(s4)
    8000693c:	fe978ae3          	beq	a5,s1,80006930 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006940:	f9042903          	lw	s2,-112(s0)
    80006944:	00290713          	addi	a4,s2,2
    80006948:	0712                	slli	a4,a4,0x4
    8000694a:	0003c797          	auipc	a5,0x3c
    8000694e:	49678793          	addi	a5,a5,1174 # 80042de0 <disk>
    80006952:	97ba                	add	a5,a5,a4
    80006954:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006958:	0003c997          	auipc	s3,0x3c
    8000695c:	48898993          	addi	s3,s3,1160 # 80042de0 <disk>
    80006960:	00491713          	slli	a4,s2,0x4
    80006964:	0009b783          	ld	a5,0(s3)
    80006968:	97ba                	add	a5,a5,a4
    8000696a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000696e:	854a                	mv	a0,s2
    80006970:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006974:	bafff0ef          	jal	80006522 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006978:	8885                	andi	s1,s1,1
    8000697a:	f0fd                	bnez	s1,80006960 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000697c:	0003c517          	auipc	a0,0x3c
    80006980:	58c50513          	addi	a0,a0,1420 # 80042f08 <disk+0x128>
    80006984:	ceefa0ef          	jal	80000e72 <release>
}
    80006988:	70a6                	ld	ra,104(sp)
    8000698a:	7406                	ld	s0,96(sp)
    8000698c:	64e6                	ld	s1,88(sp)
    8000698e:	6946                	ld	s2,80(sp)
    80006990:	69a6                	ld	s3,72(sp)
    80006992:	6a06                	ld	s4,64(sp)
    80006994:	7ae2                	ld	s5,56(sp)
    80006996:	7b42                	ld	s6,48(sp)
    80006998:	7ba2                	ld	s7,40(sp)
    8000699a:	7c02                	ld	s8,32(sp)
    8000699c:	6ce2                	ld	s9,24(sp)
    8000699e:	6165                	addi	sp,sp,112
    800069a0:	8082                	ret

00000000800069a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800069a2:	1101                	addi	sp,sp,-32
    800069a4:	ec06                	sd	ra,24(sp)
    800069a6:	e822                	sd	s0,16(sp)
    800069a8:	e426                	sd	s1,8(sp)
    800069aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069ac:	0003c497          	auipc	s1,0x3c
    800069b0:	43448493          	addi	s1,s1,1076 # 80042de0 <disk>
    800069b4:	0003c517          	auipc	a0,0x3c
    800069b8:	55450513          	addi	a0,a0,1364 # 80042f08 <disk+0x128>
    800069bc:	c1efa0ef          	jal	80000dda <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069c0:	100017b7          	lui	a5,0x10001
    800069c4:	53b8                	lw	a4,96(a5)
    800069c6:	8b0d                	andi	a4,a4,3
    800069c8:	100017b7          	lui	a5,0x10001
    800069cc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800069ce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069d2:	689c                	ld	a5,16(s1)
    800069d4:	0204d703          	lhu	a4,32(s1)
    800069d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800069dc:	04f70663          	beq	a4,a5,80006a28 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800069e0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069e4:	6898                	ld	a4,16(s1)
    800069e6:	0204d783          	lhu	a5,32(s1)
    800069ea:	8b9d                	andi	a5,a5,7
    800069ec:	078e                	slli	a5,a5,0x3
    800069ee:	97ba                	add	a5,a5,a4
    800069f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069f2:	00278713          	addi	a4,a5,2
    800069f6:	0712                	slli	a4,a4,0x4
    800069f8:	9726                	add	a4,a4,s1
    800069fa:	01074703          	lbu	a4,16(a4)
    800069fe:	e321                	bnez	a4,80006a3e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a00:	0789                	addi	a5,a5,2
    80006a02:	0792                	slli	a5,a5,0x4
    80006a04:	97a6                	add	a5,a5,s1
    80006a06:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a08:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a0c:	fabfb0ef          	jal	800029b6 <wakeup>

    disk.used_idx += 1;
    80006a10:	0204d783          	lhu	a5,32(s1)
    80006a14:	2785                	addiw	a5,a5,1
    80006a16:	17c2                	slli	a5,a5,0x30
    80006a18:	93c1                	srli	a5,a5,0x30
    80006a1a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a1e:	6898                	ld	a4,16(s1)
    80006a20:	00275703          	lhu	a4,2(a4)
    80006a24:	faf71ee3          	bne	a4,a5,800069e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a28:	0003c517          	auipc	a0,0x3c
    80006a2c:	4e050513          	addi	a0,a0,1248 # 80042f08 <disk+0x128>
    80006a30:	c42fa0ef          	jal	80000e72 <release>
}
    80006a34:	60e2                	ld	ra,24(sp)
    80006a36:	6442                	ld	s0,16(sp)
    80006a38:	64a2                	ld	s1,8(sp)
    80006a3a:	6105                	addi	sp,sp,32
    80006a3c:	8082                	ret
      panic("virtio_disk_intr status");
    80006a3e:	00002517          	auipc	a0,0x2
    80006a42:	dba50513          	addi	a0,a0,-582 # 800087f8 <etext+0x7f8>
    80006a46:	d9bf90ef          	jal	800007e0 <panic>

0000000080006a4a <minheap_init>:
    }
  }
}

// Initialize a min-heap
void minheap_init(struct minheap *heap) {
    80006a4a:	1141                	addi	sp,sp,-16
    80006a4c:	e422                	sd	s0,8(sp)
    80006a4e:	0800                	addi	s0,sp,16
  heap->size = 0;
    80006a50:	20052023          	sw	zero,512(a0)
  heap->capacity = NPROC;
    80006a54:	04000793          	li	a5,64
    80006a58:	20f52223          	sw	a5,516(a0)
  for (int i = 0; i < NPROC; i++) {
    80006a5c:	87aa                	mv	a5,a0
    80006a5e:	20050713          	addi	a4,a0,512
    heap->procs[i] = 0;
    80006a62:	0007b023          	sd	zero,0(a5)
  for (int i = 0; i < NPROC; i++) {
    80006a66:	07a1                	addi	a5,a5,8
    80006a68:	fee79de3          	bne	a5,a4,80006a62 <minheap_init+0x18>
  }
}
    80006a6c:	6422                	ld	s0,8(sp)
    80006a6e:	0141                	addi	sp,sp,16
    80006a70:	8082                	ret

0000000080006a72 <minheap_insert>:

// Insert a process into the heap
int minheap_insert(struct minheap *heap, struct proc *p) {
    80006a72:	1141                	addi	sp,sp,-16
    80006a74:	e422                	sd	s0,8(sp)
    80006a76:	0800                	addi	s0,sp,16
  if (heap->size >= heap->capacity) {
    80006a78:	20052783          	lw	a5,512(a0)
    80006a7c:	20452703          	lw	a4,516(a0)
    80006a80:	04e7da63          	bge	a5,a4,80006ad4 <minheap_insert+0x62>
    return -1;  // Heap is full
  }

  // Add the new process at the end
  heap->procs[heap->size] = p;
    80006a84:	00379713          	slli	a4,a5,0x3
    80006a88:	972a                	add	a4,a4,a0
    80006a8a:	e30c                	sd	a1,0(a4)
  heap->size++;
    80006a8c:	0017871b          	addiw	a4,a5,1
    80006a90:	20e52023          	sw	a4,512(a0)
  while (idx > 0) {
    80006a94:	04f05263          	blez	a5,80006ad8 <minheap_insert+0x66>
    80006a98:	4e09                	li	t3,2
  return (i - 1) / 2;
    80006a9a:	863e                	mv	a2,a5
    80006a9c:	37fd                	addiw	a5,a5,-1
    80006a9e:	01f7d71b          	srliw	a4,a5,0x1f
    80006aa2:	9fb9                	addw	a5,a5,a4
    80006aa4:	4017d79b          	sraiw	a5,a5,0x1
    if (heap->procs[idx]->vruntime < heap->procs[p]->vruntime) {
    80006aa8:	00361693          	slli	a3,a2,0x3
    80006aac:	96aa                	add	a3,a3,a0
    80006aae:	628c                	ld	a1,0(a3)
    80006ab0:	00379713          	slli	a4,a5,0x3
    80006ab4:	972a                	add	a4,a4,a0
    80006ab6:	00073803          	ld	a6,0(a4)
    80006aba:	1705b303          	ld	t1,368(a1)
    80006abe:	17083883          	ld	a7,368(a6)
    80006ac2:	01137d63          	bgeu	t1,a7,80006adc <minheap_insert+0x6a>
  heap->procs[i] = heap->procs[j];
    80006ac6:	0106b023          	sd	a6,0(a3)
  heap->procs[j] = temp;
    80006aca:	e30c                	sd	a1,0(a4)
  while (idx > 0) {
    80006acc:	fcce47e3          	blt	t3,a2,80006a9a <minheap_insert+0x28>

  // Heapify up to maintain heap property
  heapify_up(heap, heap->size - 1);

  return 0;
    80006ad0:	4501                	li	a0,0
    80006ad2:	a031                	j	80006ade <minheap_insert+0x6c>
    return -1;  // Heap is full
    80006ad4:	557d                	li	a0,-1
    80006ad6:	a021                	j	80006ade <minheap_insert+0x6c>
  return 0;
    80006ad8:	4501                	li	a0,0
    80006ada:	a011                	j	80006ade <minheap_insert+0x6c>
    80006adc:	4501                	li	a0,0
}
    80006ade:	6422                	ld	s0,8(sp)
    80006ae0:	0141                	addi	sp,sp,16
    80006ae2:	8082                	ret

0000000080006ae4 <minheap_extract_min>:

// Extract the process with minimum vruntime
struct proc* minheap_extract_min(struct minheap *heap) {
    80006ae4:	1141                	addi	sp,sp,-16
    80006ae6:	e422                	sd	s0,8(sp)
    80006ae8:	0800                	addi	s0,sp,16
  if (heap->size == 0) {
    80006aea:	20052783          	lw	a5,512(a0)
    80006aee:	c7b1                	beqz	a5,80006b3a <minheap_extract_min+0x56>
    80006af0:	862a                	mv	a2,a0
    return 0;  // Heap is empty
  }

  struct proc *min_proc = heap->procs[0];
    80006af2:	6108                	ld	a0,0(a0)

  // Move the last element to the root
  heap->procs[0] = heap->procs[heap->size - 1];
    80006af4:	37fd                	addiw	a5,a5,-1
    80006af6:	0007859b          	sext.w	a1,a5
    80006afa:	00359713          	slli	a4,a1,0x3
    80006afe:	9732                	add	a4,a4,a2
    80006b00:	6318                	ld	a4,0(a4)
    80006b02:	e218                	sd	a4,0(a2)
  heap->size--;
    80006b04:	20f62023          	sw	a5,512(a2)

  // Heapify down from the root
  if (heap->size > 0) {
    80006b08:	00b04563          	bgtz	a1,80006b12 <minheap_extract_min+0x2e>
    heapify_down(heap, 0);
  }

  return min_proc;
}
    80006b0c:	6422                	ld	s0,8(sp)
    80006b0e:	0141                	addi	sp,sp,16
    80006b10:	8082                	ret
    80006b12:	4781                	li	a5,0
    80006b14:	a0b5                	j	80006b80 <minheap_extract_min+0x9c>
        heap->procs[right]->vruntime < heap->procs[smallest]->vruntime) {
    80006b16:	00369813          	slli	a6,a3,0x3
    80006b1a:	9832                	add	a6,a6,a2
    80006b1c:	00083883          	ld	a7,0(a6)
    80006b20:	00371813          	slli	a6,a4,0x3
    80006b24:	9832                	add	a6,a6,a2
    80006b26:	00083803          	ld	a6,0(a6)
    if (right < heap->size && 
    80006b2a:	1708b883          	ld	a7,368(a7)
    80006b2e:	17083803          	ld	a6,368(a6)
    80006b32:	0308e763          	bltu	a7,a6,80006b60 <minheap_extract_min+0x7c>
    80006b36:	86ba                	mv	a3,a4
    80006b38:	a025                	j	80006b60 <minheap_extract_min+0x7c>
    return 0;  // Heap is empty
    80006b3a:	4501                	li	a0,0
    80006b3c:	bfc1                	j	80006b0c <minheap_extract_min+0x28>
    if (right < heap->size && 
    80006b3e:	fcb6d7e3          	bge	a3,a1,80006b0c <minheap_extract_min+0x28>
        heap->procs[right]->vruntime < heap->procs[smallest]->vruntime) {
    80006b42:	00369713          	slli	a4,a3,0x3
    80006b46:	9732                	add	a4,a4,a2
    80006b48:	00073803          	ld	a6,0(a4)
    80006b4c:	00379713          	slli	a4,a5,0x3
    80006b50:	9732                	add	a4,a4,a2
    80006b52:	6318                	ld	a4,0(a4)
    if (right < heap->size && 
    80006b54:	17083803          	ld	a6,368(a6)
    80006b58:	17073703          	ld	a4,368(a4)
    80006b5c:	fae878e3          	bgeu	a6,a4,80006b0c <minheap_extract_min+0x28>
    if (smallest != idx) {
    80006b60:	fad786e3          	beq	a5,a3,80006b0c <minheap_extract_min+0x28>
  struct proc *temp = heap->procs[i];
    80006b64:	078e                	slli	a5,a5,0x3
    80006b66:	97b2                	add	a5,a5,a2
    80006b68:	0007b803          	ld	a6,0(a5)
  heap->procs[i] = heap->procs[j];
    80006b6c:	00369713          	slli	a4,a3,0x3
    80006b70:	9732                	add	a4,a4,a2
    80006b72:	00073883          	ld	a7,0(a4)
    80006b76:	0117b023          	sd	a7,0(a5)
  heap->procs[j] = temp;
    80006b7a:	01073023          	sd	a6,0(a4)
      idx = smallest;
    80006b7e:	87b6                	mv	a5,a3
  return 2 * i + 1;
    80006b80:	0017969b          	slliw	a3,a5,0x1
    80006b84:	0016871b          	addiw	a4,a3,1
  return 2 * i + 2;
    80006b88:	2689                	addiw	a3,a3,2
    if (left < heap->size && 
    80006b8a:	fab75ae3          	bge	a4,a1,80006b3e <minheap_extract_min+0x5a>
        heap->procs[left]->vruntime < heap->procs[smallest]->vruntime) {
    80006b8e:	00371813          	slli	a6,a4,0x3
    80006b92:	9832                	add	a6,a6,a2
    80006b94:	00083883          	ld	a7,0(a6)
    80006b98:	00379813          	slli	a6,a5,0x3
    80006b9c:	9832                	add	a6,a6,a2
    80006b9e:	00083803          	ld	a6,0(a6)
    if (left < heap->size && 
    80006ba2:	1708b883          	ld	a7,368(a7)
    80006ba6:	17083803          	ld	a6,368(a6)
    80006baa:	f908fae3          	bgeu	a7,a6,80006b3e <minheap_extract_min+0x5a>
    if (right < heap->size && 
    80006bae:	f6b6c4e3          	blt	a3,a1,80006b16 <minheap_extract_min+0x32>
    80006bb2:	86ba                	mv	a3,a4
    80006bb4:	b775                	j	80006b60 <minheap_extract_min+0x7c>

0000000080006bb6 <swap_init>:
  return r;
}

void
swap_init(void)
{
    80006bb6:	1141                	addi	sp,sp,-16
    80006bb8:	e406                	sd	ra,8(sp)
    80006bba:	e022                	sd	s0,0(sp)
    80006bbc:	0800                	addi	s0,sp,16
  initlock(&swap_lock, "swap");
    80006bbe:	00002597          	auipc	a1,0x2
    80006bc2:	c5258593          	addi	a1,a1,-942 # 80008810 <etext+0x810>
    80006bc6:	0003c517          	auipc	a0,0x3c
    80006bca:	35a50513          	addi	a0,a0,858 # 80042f20 <swap_lock>
    80006bce:	98cfa0ef          	jal	80000d5a <initlock>
  qhead = qtail = qcount = 0;
    80006bd2:	00002797          	auipc	a5,0x2
    80006bd6:	de07af23          	sw	zero,-514(a5) # 800089d0 <qcount>
    80006bda:	00002797          	auipc	a5,0x2
    80006bde:	de07ad23          	sw	zero,-518(a5) # 800089d4 <qtail>
    80006be2:	00002797          	auipc	a5,0x2
    80006be6:	de07ab23          	sw	zero,-522(a5) # 800089d8 <qhead>
}
    80006bea:	60a2                	ld	ra,8(sp)
    80006bec:	6402                	ld	s0,0(sp)
    80006bee:	0141                	addi	sp,sp,16
    80006bf0:	8082                	ret

0000000080006bf2 <swap_wait_for_free_page>:

// Called by memory allocation path when RAM is full.
// Put requester to sleep and ask swapd to free one page.
void
swap_wait_for_free_page(void)
{
    80006bf2:	1101                	addi	sp,sp,-32
    80006bf4:	ec06                	sd	ra,24(sp)
    80006bf6:	e822                	sd	s0,16(sp)
    80006bf8:	e426                	sd	s1,8(sp)
    80006bfa:	1000                	addi	s0,sp,32
  struct proc *me = myproc();
    80006bfc:	96afb0ef          	jal	80001d66 <myproc>
    80006c00:	84aa                	mv	s1,a0

  acquire(&swap_lock);
    80006c02:	0003c517          	auipc	a0,0x3c
    80006c06:	31e50513          	addi	a0,a0,798 # 80042f20 <swap_lock>
    80006c0a:	9d0fa0ef          	jal	80000dda <acquire>
  if(qcount == SWAPQ_SIZE)
    80006c0e:	00002717          	auipc	a4,0x2
    80006c12:	dc272703          	lw	a4,-574(a4) # 800089d0 <qcount>
    80006c16:	04000793          	li	a5,64
    80006c1a:	02f70e63          	beq	a4,a5,80006c56 <swap_wait_for_free_page+0x64>
  swapq[qtail].requester = p;
    80006c1e:	00002617          	auipc	a2,0x2
    80006c22:	db660613          	addi	a2,a2,-586 # 800089d4 <qtail>
    80006c26:	421c                	lw	a5,0(a2)
    80006c28:	00379593          	slli	a1,a5,0x3
    80006c2c:	0003c697          	auipc	a3,0x3c
    80006c30:	2f468693          	addi	a3,a3,756 # 80042f20 <swap_lock>
    80006c34:	96ae                	add	a3,a3,a1
    80006c36:	ee84                	sd	s1,24(a3)
  qtail = (qtail + 1) % SWAPQ_SIZE;
    80006c38:	2785                	addiw	a5,a5,1
    80006c3a:	41f7d69b          	sraiw	a3,a5,0x1f
    80006c3e:	01a6d69b          	srliw	a3,a3,0x1a
    80006c42:	9fb5                	addw	a5,a5,a3
    80006c44:	03f7f793          	andi	a5,a5,63
    80006c48:	9f95                	subw	a5,a5,a3
    80006c4a:	c21c                	sw	a5,0(a2)
  qcount++;
    80006c4c:	2705                	addiw	a4,a4,1
    80006c4e:	00002797          	auipc	a5,0x2
    80006c52:	d8e7a123          	sw	a4,-638(a5) # 800089d0 <qcount>

  // enqueue a request; if full, still sleep — swapd may free eventually
  swapq_push(me);

  // wake swapd (if sleeping)
  wakeup((void*)&swapq_chan);
    80006c56:	00002517          	auipc	a0,0x2
    80006c5a:	d7650513          	addi	a0,a0,-650 # 800089cc <swapq_chan>
    80006c5e:	d59fb0ef          	jal	800029b6 <wakeup>

  // sleep until swapd frees at least one page
  sleep((void*)&swap_wait_chan, &swap_lock);
    80006c62:	0003c497          	auipc	s1,0x3c
    80006c66:	2be48493          	addi	s1,s1,702 # 80042f20 <swap_lock>
    80006c6a:	85a6                	mv	a1,s1
    80006c6c:	00002517          	auipc	a0,0x2
    80006c70:	d5c50513          	addi	a0,a0,-676 # 800089c8 <swap_wait_chan>
    80006c74:	cf7fb0ef          	jal	8000296a <sleep>

  // lock is reacquired by sleep() before returning; now release it
  release(&swap_lock);
    80006c78:	8526                	mv	a0,s1
    80006c7a:	9f8fa0ef          	jal	80000e72 <release>
}
    80006c7e:	60e2                	ld	ra,24(sp)
    80006c80:	6442                	ld	s0,16(sp)
    80006c82:	64a2                	ld	s1,8(sp)
    80006c84:	6105                	addi	sp,sp,32
    80006c86:	8082                	ret

0000000080006c88 <swapd>:

// The swap-out kernel daemon.
void
swapd(void)
{
    80006c88:	715d                	addi	sp,sp,-80
    80006c8a:	e486                	sd	ra,72(sp)
    80006c8c:	e0a2                	sd	s0,64(sp)
    80006c8e:	fc26                	sd	s1,56(sp)
    80006c90:	f84a                	sd	s2,48(sp)
    80006c92:	f44e                	sd	s3,40(sp)
    80006c94:	f052                	sd	s4,32(sp)
    80006c96:	ec56                	sd	s5,24(sp)
    80006c98:	e85a                	sd	s6,16(sp)
    80006c9a:	e45e                	sd	s7,8(sp)
    80006c9c:	0880                	addi	s0,sp,80
  // optional: print once
  // printf("swapd: started\n");

  for(;;){
    acquire(&swap_lock);
    80006c9e:	0003cb17          	auipc	s6,0x3c
    80006ca2:	282b0b13          	addi	s6,s6,642 # 80042f20 <swap_lock>
    while(qcount == 0){
    80006ca6:	00002b97          	auipc	s7,0x2
    80006caa:	d2ab8b93          	addi	s7,s7,-726 # 800089d0 <qcount>
      if((*pte & PTE_V) && (*pte & PTE_U) && ((*pte & PTE_SWP) == 0)){
    80006cae:	4a45                	li	s4,17
    for(uint64 va = 0; va < p->sz; va += PGSIZE){
    80006cb0:	6985                	lui	s3,0x1
  for(p = proc; p < &proc[NPROC]; p++){
    80006cb2:	00031a97          	auipc	s5,0x31
    80006cb6:	e8ea8a93          	addi	s5,s5,-370 # 80037b40 <tickslock>
    80006cba:	a8bd                	j	80006d38 <swapd+0xb0>
      release(&p->lock);
    80006cbc:	8526                	mv	a0,s1
    80006cbe:	9b4fa0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80006cc2:	1a848493          	addi	s1,s1,424
    80006cc6:	05548d63          	beq	s1,s5,80006d20 <swapd+0x98>
    acquire(&p->lock);
    80006cca:	8526                	mv	a0,s1
    80006ccc:	90efa0ef          	jal	80000dda <acquire>
    if(p->state == UNUSED || p->is_kproc){
    80006cd0:	4c9c                	lw	a5,24(s1)
    80006cd2:	d7ed                	beqz	a5,80006cbc <swapd+0x34>
    80006cd4:	1784a783          	lw	a5,376(s1)
    80006cd8:	f3f5                	bnez	a5,80006cbc <swapd+0x34>
    for(uint64 va = 0; va < p->sz; va += PGSIZE){
    80006cda:	64bc                	ld	a5,72(s1)
    80006cdc:	4901                	li	s2,0
    80006cde:	eb89                	bnez	a5,80006cf0 <swapd+0x68>
    release(&p->lock);
    80006ce0:	8526                	mv	a0,s1
    80006ce2:	990fa0ef          	jal	80000e72 <release>
    80006ce6:	bff1                	j	80006cc2 <swapd+0x3a>
    for(uint64 va = 0; va < p->sz; va += PGSIZE){
    80006ce8:	994e                	add	s2,s2,s3
    80006cea:	64bc                	ld	a5,72(s1)
    80006cec:	fef97ae3          	bgeu	s2,a5,80006ce0 <swapd+0x58>
      pte_t *pte = walk(p->pagetable, va, 0);
    80006cf0:	4601                	li	a2,0
    80006cf2:	85ca                	mv	a1,s2
    80006cf4:	68a8                	ld	a0,80(s1)
    80006cf6:	c2cfa0ef          	jal	80001122 <walk>
      if(pte == 0)
    80006cfa:	d57d                	beqz	a0,80006ce8 <swapd+0x60>
      if((*pte & PTE_V) && (*pte & PTE_U) && ((*pte & PTE_SWP) == 0)){
    80006cfc:	611c                	ld	a5,0(a0)
    80006cfe:	2117f713          	andi	a4,a5,529
    80006d02:	ff4713e3          	bne	a4,s4,80006ce8 <swapd+0x60>
        *pte = (*pte & ~PTE_V) | PTE_SWP;
    80006d06:	dfe7f713          	andi	a4,a5,-514
    80006d0a:	20076713          	ori	a4,a4,512
    80006d0e:	e118                	sd	a4,0(a0)
        uint64 pa = PTE2PA(*pte);
    80006d10:	00a7d513          	srli	a0,a5,0xa
        kfree((void*)pa);
    80006d14:	0532                	slli	a0,a0,0xc
    80006d16:	e49f90ef          	jal	80000b5e <kfree>
        release(&p->lock);
    80006d1a:	8526                	mv	a0,s1
    80006d1c:	956fa0ef          	jal	80000e72 <release>

    // Free exactly one page per request (simple and matches assignment)
    swapout_one_page();

    // wake all processes sleeping due to lack of RAM
    acquire(&swap_lock);
    80006d20:	855a                	mv	a0,s6
    80006d22:	8b8fa0ef          	jal	80000dda <acquire>
    wakeup((void*)&swap_wait_chan);
    80006d26:	00002517          	auipc	a0,0x2
    80006d2a:	ca250513          	addi	a0,a0,-862 # 800089c8 <swap_wait_chan>
    80006d2e:	c89fb0ef          	jal	800029b6 <wakeup>
    release(&swap_lock);
    80006d32:	855a                	mv	a0,s6
    80006d34:	93efa0ef          	jal	80000e72 <release>
    acquire(&swap_lock);
    80006d38:	855a                	mv	a0,s6
    80006d3a:	8a0fa0ef          	jal	80000dda <acquire>
    while(qcount == 0){
    80006d3e:	000ba703          	lw	a4,0(s7)
    80006d42:	ef01                	bnez	a4,80006d5a <swapd+0xd2>
      sleep((void*)&swapq_chan, &swap_lock);
    80006d44:	00002497          	auipc	s1,0x2
    80006d48:	c8848493          	addi	s1,s1,-888 # 800089cc <swapq_chan>
    80006d4c:	85da                	mv	a1,s6
    80006d4e:	8526                	mv	a0,s1
    80006d50:	c1bfb0ef          	jal	8000296a <sleep>
    while(qcount == 0){
    80006d54:	000ba703          	lw	a4,0(s7)
    80006d58:	db75                	beqz	a4,80006d4c <swapd+0xc4>
  qhead = (qhead + 1) % SWAPQ_SIZE;
    80006d5a:	00002617          	auipc	a2,0x2
    80006d5e:	c7e60613          	addi	a2,a2,-898 # 800089d8 <qhead>
    80006d62:	421c                	lw	a5,0(a2)
    80006d64:	2785                	addiw	a5,a5,1
    80006d66:	41f7d69b          	sraiw	a3,a5,0x1f
    80006d6a:	01a6d69b          	srliw	a3,a3,0x1a
    80006d6e:	9fb5                	addw	a5,a5,a3
    80006d70:	03f7f793          	andi	a5,a5,63
    80006d74:	9f95                	subw	a5,a5,a3
    80006d76:	c21c                	sw	a5,0(a2)
  qcount--;
    80006d78:	377d                	addiw	a4,a4,-1
    80006d7a:	00eba023          	sw	a4,0(s7)
    release(&swap_lock);
    80006d7e:	855a                	mv	a0,s6
    80006d80:	8f2fa0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80006d84:	0002a497          	auipc	s1,0x2a
    80006d88:	3bc48493          	addi	s1,s1,956 # 80031140 <proc>
    80006d8c:	bf3d                	j	80006cca <swapd+0x42>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
