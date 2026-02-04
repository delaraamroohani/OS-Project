
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
    80000004:	98010113          	addi	sp,sp,-1664 # 80008980 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbc13f>
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
    80000112:	065020ef          	jal	80002976 <either_copyin>
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
    8000018c:	00010517          	auipc	a0,0x10
    80000190:	7f450513          	addi	a0,a0,2036 # 80010980 <cons>
    80000194:	447000ef          	jal	80000dda <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00010497          	auipc	s1,0x10
    8000019c:	7e848493          	addi	s1,s1,2024 # 80010980 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00011917          	auipc	s2,0x11
    800001a4:	87890913          	addi	s2,s2,-1928 # 80010a18 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	3c3010ef          	jal	80001d7a <myproc>
    800001bc:	64c020ef          	jal	80002808 <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	378020ef          	jal	8000253e <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00010717          	auipc	a4,0x10
    800001dc:	7a870713          	addi	a4,a4,1960 # 80010980 <cons>
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
    8000020a:	722020ef          	jal	8000292c <either_copyout>
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
    80000226:	75e50513          	addi	a0,a0,1886 # 80010980 <cons>
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
    8000024c:	00010717          	auipc	a4,0x10
    80000250:	7cf72623          	sw	a5,1996(a4) # 80010a18 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00010517          	auipc	a0,0x10
    80000266:	71e50513          	addi	a0,a0,1822 # 80010980 <cons>
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
    800002ba:	6ca50513          	addi	a0,a0,1738 # 80010980 <cons>
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
    800002d8:	6e8020ef          	jal	800029c0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00010517          	auipc	a0,0x10
    800002e0:	6a450513          	addi	a0,a0,1700 # 80010980 <cons>
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
    800002fe:	68670713          	addi	a4,a4,1670 # 80010980 <cons>
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
    80000324:	66078793          	addi	a5,a5,1632 # 80010980 <cons>
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
    80000352:	6ca7a783          	lw	a5,1738(a5) # 80010a18 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00010717          	auipc	a4,0x10
    80000368:	61c70713          	addi	a4,a4,1564 # 80010980 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00010497          	auipc	s1,0x10
    80000378:	60c48493          	addi	s1,s1,1548 # 80010980 <cons>
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
    800003ba:	5ca70713          	addi	a4,a4,1482 # 80010980 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00010717          	auipc	a4,0x10
    800003d0:	64f72a23          	sw	a5,1620(a4) # 80010a20 <cons+0xa0>
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
    800003ee:	59678793          	addi	a5,a5,1430 # 80010980 <cons>
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
    80000412:	60c7a723          	sw	a2,1550(a5) # 80010a1c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00010517          	auipc	a0,0x10
    8000041a:	60250513          	addi	a0,a0,1538 # 80010a18 <cons+0x98>
    8000041e:	16c020ef          	jal	8000258a <wakeup>
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
    80000438:	54c50513          	addi	a0,a0,1356 # 80010980 <cons>
    8000043c:	11f000ef          	jal	80000d5a <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00041797          	auipc	a5,0x41
    80000448:	0e478793          	addi	a5,a5,228 # 80041528 <devsw>
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
    80000482:	37a60613          	addi	a2,a2,890 # 800087f8 <digits>
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
    8000051c:	42c7a783          	lw	a5,1068(a5) # 80008944 <panicking>
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
    80000564:	4c850513          	addi	a0,a0,1224 # 80010a28 <pr>
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
    8000072c:	0d0b8b93          	addi	s7,s7,208 # 800087f8 <digits>
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
    800007c0:	1887a783          	lw	a5,392(a5) # 80008944 <panicking>
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
    800007d6:	25650513          	addi	a0,a0,598 # 80010a28 <pr>
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
    800007f4:	1527aa23          	sw	s2,340(a5) # 80008944 <panicking>
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
    80000816:	1327a723          	sw	s2,302(a5) # 80008940 <panicked>
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
    80000830:	1fc50513          	addi	a0,a0,508 # 80010a28 <pr>
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
    80000888:	1bc50513          	addi	a0,a0,444 # 80010a40 <tx_lock>
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
    800008ac:	19850513          	addi	a0,a0,408 # 80010a40 <tx_lock>
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
    800008ca:	08648493          	addi	s1,s1,134 # 8000894c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00010997          	auipc	s3,0x10
    800008d2:	17298993          	addi	s3,s3,370 # 80010a40 <tx_lock>
    800008d6:	00008917          	auipc	s2,0x8
    800008da:	07290913          	addi	s2,s2,114 # 80008948 <tx_chan>
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
    800008ea:	455010ef          	jal	8000253e <sleep>
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
    80000918:	12c50513          	addi	a0,a0,300 # 80010a40 <tx_lock>
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
    8000093c:	00c7a783          	lw	a5,12(a5) # 80008944 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00008797          	auipc	a5,0x8
    80000946:	ffe7a783          	lw	a5,-2(a5) # 80008940 <panicked>
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
    8000096c:	fdc7a783          	lw	a5,-36(a5) # 80008944 <panicking>
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
    800009c8:	07c50513          	addi	a0,a0,124 # 80010a40 <tx_lock>
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
    800009e4:	06050513          	addi	a0,a0,96 # 80010a40 <tx_lock>
    800009e8:	48a000ef          	jal	80000e72 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00008797          	auipc	a5,0x8
    800009f4:	f407ae23          	sw	zero,-164(a5) # 8000894c <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00008517          	auipc	a0,0x8
    800009fc:	f5050513          	addi	a0,a0,-176 # 80008948 <tx_chan>
    80000a00:	38b010ef          	jal	8000258a <wakeup>
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
    80000a32:	c9278793          	addi	a5,a5,-878 # 800426c0 <end>
    80000a36:	04f56163          	bltu	a0,a5,80000a78 <kref_incr+0x5c>
    80000a3a:	47c5                	li	a5,17
    80000a3c:	07ee                	slli	a5,a5,0x1b
    80000a3e:	02f57d63          	bgeu	a0,a5,80000a78 <kref_incr+0x5c>
    panic("kref_incr");
  
  acquire(&pageref.lock);
    80000a42:	00010517          	auipc	a0,0x10
    80000a46:	03650513          	addi	a0,a0,54 # 80010a78 <pageref>
    80000a4a:	390000ef          	jal	80000dda <acquire>
  pageref.count[PA2IDX(pa)]++;
    80000a4e:	800007b7          	lui	a5,0x80000
    80000a52:	97a6                	add	a5,a5,s1
    80000a54:	83b1                	srli	a5,a5,0xc
    80000a56:	00010517          	auipc	a0,0x10
    80000a5a:	02250513          	addi	a0,a0,34 # 80010a78 <pageref>
    80000a5e:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbd944>
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
    80000a9a:	c2a78793          	addi	a5,a5,-982 # 800426c0 <end>
    80000a9e:	04f56463          	bltu	a0,a5,80000ae6 <kref_decr+0x62>
    80000aa2:	47c5                	li	a5,17
    80000aa4:	07ee                	slli	a5,a5,0x1b
    80000aa6:	04f57063          	bgeu	a0,a5,80000ae6 <kref_decr+0x62>
    panic("kref_decr");
  
  acquire(&pageref.lock);
    80000aaa:	00010517          	auipc	a0,0x10
    80000aae:	fce50513          	addi	a0,a0,-50 # 80010a78 <pageref>
    80000ab2:	328000ef          	jal	80000dda <acquire>
  cnt = --pageref.count[PA2IDX(pa)];
    80000ab6:	800007b7          	lui	a5,0x80000
    80000aba:	97a6                	add	a5,a5,s1
    80000abc:	83b1                	srli	a5,a5,0xc
    80000abe:	00010517          	auipc	a0,0x10
    80000ac2:	fba50513          	addi	a0,a0,-70 # 80010a78 <pageref>
    80000ac6:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbd944>
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
    80000b0c:	bb878793          	addi	a5,a5,-1096 # 800426c0 <end>
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
    80000b26:	f5650513          	addi	a0,a0,-170 # 80010a78 <pageref>
    80000b2a:	2b0000ef          	jal	80000dda <acquire>
  cnt = pageref.count[PA2IDX(pa)];
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	f4a50513          	addi	a0,a0,-182 # 80010a78 <pageref>
    80000b36:	800007b7          	lui	a5,0x80000
    80000b3a:	97a6                	add	a5,a5,s1
    80000b3c:	83b1                	srli	a5,a5,0xc
    80000b3e:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbd944>
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
    80000b74:	b5078793          	addi	a5,a5,-1200 # 800426c0 <end>
    80000b78:	08f56263          	bltu	a0,a5,80000bfc <kfree+0x9e>
    80000b7c:	47c5                	li	a5,17
    80000b7e:	07ee                	slli	a5,a5,0x1b
    80000b80:	06f57e63          	bgeu	a0,a5,80000bfc <kfree+0x9e>
    panic("kfree");


// Only free if reference count reaches 0
  acquire(&pageref.lock);
    80000b84:	00010517          	auipc	a0,0x10
    80000b88:	ef450513          	addi	a0,a0,-268 # 80010a78 <pageref>
    80000b8c:	24e000ef          	jal	80000dda <acquire>
  if(pageref.count[PA2IDX(pa)] > 1) {
    80000b90:	800007b7          	lui	a5,0x80000
    80000b94:	97a6                	add	a5,a5,s1
    80000b96:	83b1                	srli	a5,a5,0xc
    80000b98:	00478693          	addi	a3,a5,4 # ffffffff80000004 <end+0xfffffffefffbd944>
    80000b9c:	068a                	slli	a3,a3,0x2
    80000b9e:	00010717          	auipc	a4,0x10
    80000ba2:	eda70713          	addi	a4,a4,-294 # 80010a78 <pageref>
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
    80000bb6:	ec650513          	addi	a0,a0,-314 # 80010a78 <pageref>
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
    80000bd6:	e8690913          	addi	s2,s2,-378 # 80010a58 <kmem>
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
    80000c0e:	e6e50513          	addi	a0,a0,-402 # 80010a78 <pageref>
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
    80000c52:	e2ab8b93          	addi	s7,s7,-470 # 80010a78 <pageref>
    80000c56:	fff80937          	lui	s2,0xfff80
    80000c5a:	197d                	addi	s2,s2,-1 # fffffffffff7ffff <end+0xffffffff7ff3d93f>
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
    80000cac:	db050513          	addi	a0,a0,-592 # 80010a58 <kmem>
    80000cb0:	0aa000ef          	jal	80000d5a <initlock>
  initlock(&pageref.lock, "pageref");
    80000cb4:	00007597          	auipc	a1,0x7
    80000cb8:	3b458593          	addi	a1,a1,948 # 80008068 <etext+0x68>
    80000cbc:	00010517          	auipc	a0,0x10
    80000cc0:	dbc50513          	addi	a0,a0,-580 # 80010a78 <pageref>
    80000cc4:	096000ef          	jal	80000d5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000cc8:	45c5                	li	a1,17
    80000cca:	05ee                	slli	a1,a1,0x1b
    80000ccc:	00042517          	auipc	a0,0x42
    80000cd0:	9f450513          	addi	a0,a0,-1548 # 800426c0 <end>
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
    80000cee:	d6e48493          	addi	s1,s1,-658 # 80010a58 <kmem>
    80000cf2:	8526                	mv	a0,s1
    80000cf4:	0e6000ef          	jal	80000dda <acquire>
  r = kmem.freelist;
    80000cf8:	6c84                	ld	s1,24(s1)
  if(r)
    80000cfa:	c8a9                	beqz	s1,80000d4c <kalloc+0x6c>
    kmem.freelist = r->next;
    80000cfc:	609c                	ld	a5,0(s1)
    80000cfe:	00010517          	auipc	a0,0x10
    80000d02:	d5a50513          	addi	a0,a0,-678 # 80010a58 <kmem>
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
    80000d1a:	d6250513          	addi	a0,a0,-670 # 80010a78 <pageref>
    80000d1e:	0bc000ef          	jal	80000dda <acquire>
    pageref.count[PA2IDX(r)] = 1;
    80000d22:	00010517          	auipc	a0,0x10
    80000d26:	d5650513          	addi	a0,a0,-682 # 80010a78 <pageref>
    80000d2a:	800007b7          	lui	a5,0x80000
    80000d2e:	97a6                	add	a5,a5,s1
    80000d30:	83b1                	srli	a5,a5,0xc
    80000d32:	0791                	addi	a5,a5,4 # ffffffff80000004 <end+0xfffffffefffbd944>
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
    80000d50:	d0c50513          	addi	a0,a0,-756 # 80010a58 <kmem>
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
    80000d84:	7db000ef          	jal	80001d5e <mycpu>
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
    80000db2:	7ad000ef          	jal	80001d5e <mycpu>
    80000db6:	5d3c                	lw	a5,120(a0)
    80000db8:	cb99                	beqz	a5,80000dce <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000dba:	7a5000ef          	jal	80001d5e <mycpu>
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
    80000dce:	791000ef          	jal	80001d5e <mycpu>
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
    80000e02:	75d000ef          	jal	80001d5e <mycpu>
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
    80000e26:	739000ef          	jal	80001d5e <mycpu>
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
    80000f22:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffbc941>
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
    80001050:	4ff000ef          	jal	80001d4e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001054:	00008717          	auipc	a4,0x8
    80001058:	8fc70713          	addi	a4,a4,-1796 # 80008950 <started>
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
    80001068:	4e7000ef          	jal	80001d4e <cpuid>
    8000106c:	85aa                	mv	a1,a0
    8000106e:	00007517          	auipc	a0,0x7
    80001072:	05250513          	addi	a0,a0,82 # 800080c0 <etext+0xc0>
    80001076:	c84ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    8000107a:	080000ef          	jal	800010fa <kvminithart>
    trapinithart();   // install kernel trap vector
    8000107e:	443010ef          	jal	80002cc0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001082:	567040ef          	jal	80005de8 <plicinithart>
  }

  scheduler();        
    80001086:	26c010ef          	jal	800022f2 <scheduler>
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
    800010c2:	3af000ef          	jal	80001c70 <procinit>
    trapinit();      // trap vectors
    800010c6:	3d7010ef          	jal	80002c9c <trapinit>
    trapinithart();  // install kernel trap vector
    800010ca:	3f7010ef          	jal	80002cc0 <trapinithart>
    plicinit();      // set up interrupt controller
    800010ce:	501040ef          	jal	80005dce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800010d2:	517040ef          	jal	80005de8 <plicinithart>
    binit();         // buffer cache
    800010d6:	3dc020ef          	jal	800034b2 <binit>
    iinit();         // inode table
    800010da:	163020ef          	jal	80003a3c <iinit>
    fileinit();      // file table
    800010de:	055030ef          	jal	80004932 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010e2:	5f7040ef          	jal	80005ed8 <virtio_disk_init>
    userinit();      // first user process
    800010e6:	6e9000ef          	jal	80001fce <userinit>
    __sync_synchronize();
    800010ea:	0ff0000f          	fence
    started = 1;
    800010ee:	4785                	li	a5,1
    800010f0:	00008717          	auipc	a4,0x8
    800010f4:	86f72023          	sw	a5,-1952(a4) # 80008950 <started>
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
    80001108:	8547b783          	ld	a5,-1964(a5) # 80008958 <kernel_pagetable>
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
    80001372:	067000ef          	jal	80001bd8 <proc_mapstacks>
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
    80001394:	5ca7b423          	sd	a0,1480(a5) # 80008958 <kernel_pagetable>
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
    80001494:	08b66f63          	bltu	a2,a1,80001532 <uvmalloc+0x9e>
{
    80001498:	7139                	addi	sp,sp,-64
    8000149a:	fc06                	sd	ra,56(sp)
    8000149c:	f822                	sd	s0,48(sp)
    8000149e:	ec4e                	sd	s3,24(sp)
    800014a0:	e852                	sd	s4,16(sp)
    800014a2:	e456                	sd	s5,8(sp)
    800014a4:	0080                	addi	s0,sp,64
    800014a6:	8aaa                	mv	s5,a0
    800014a8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014aa:	6785                	lui	a5,0x1
    800014ac:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014ae:	95be                	add	a1,a1,a5
    800014b0:	77fd                	lui	a5,0xfffff
    800014b2:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014b6:	08c9f063          	bgeu	s3,a2,80001536 <uvmalloc+0xa2>
    800014ba:	f426                	sd	s1,40(sp)
    800014bc:	f04a                	sd	s2,32(sp)
    800014be:	e05a                	sd	s6,0(sp)
    800014c0:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014c6:	81bff0ef          	jal	80000ce0 <kalloc>
    800014ca:	84aa                	mv	s1,a0
    if(mem == 0){
    800014cc:	c515                	beqz	a0,800014f8 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014ce:	6605                	lui	a2,0x1
    800014d0:	4581                	li	a1,0
    800014d2:	9ddff0ef          	jal	80000eae <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014d6:	875a                	mv	a4,s6
    800014d8:	86a6                	mv	a3,s1
    800014da:	6605                	lui	a2,0x1
    800014dc:	85ca                	mv	a1,s2
    800014de:	8556                	mv	a0,s5
    800014e0:	d1bff0ef          	jal	800011fa <mappages>
    800014e4:	e915                	bnez	a0,80001518 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e6:	6785                	lui	a5,0x1
    800014e8:	993e                	add	s2,s2,a5
    800014ea:	fd496ee3          	bltu	s2,s4,800014c6 <uvmalloc+0x32>
  return newsz;
    800014ee:	8552                	mv	a0,s4
    800014f0:	74a2                	ld	s1,40(sp)
    800014f2:	7902                	ld	s2,32(sp)
    800014f4:	6b02                	ld	s6,0(sp)
    800014f6:	a811                	j	8000150a <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800014f8:	864e                	mv	a2,s3
    800014fa:	85ca                	mv	a1,s2
    800014fc:	8556                	mv	a0,s5
    800014fe:	f53ff0ef          	jal	80001450 <uvmdealloc>
      return 0;
    80001502:	4501                	li	a0,0
    80001504:	74a2                	ld	s1,40(sp)
    80001506:	7902                	ld	s2,32(sp)
    80001508:	6b02                	ld	s6,0(sp)
}
    8000150a:	70e2                	ld	ra,56(sp)
    8000150c:	7442                	ld	s0,48(sp)
    8000150e:	69e2                	ld	s3,24(sp)
    80001510:	6a42                	ld	s4,16(sp)
    80001512:	6aa2                	ld	s5,8(sp)
    80001514:	6121                	addi	sp,sp,64
    80001516:	8082                	ret
      kfree(mem);
    80001518:	8526                	mv	a0,s1
    8000151a:	e44ff0ef          	jal	80000b5e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000151e:	864e                	mv	a2,s3
    80001520:	85ca                	mv	a1,s2
    80001522:	8556                	mv	a0,s5
    80001524:	f2dff0ef          	jal	80001450 <uvmdealloc>
      return 0;
    80001528:	4501                	li	a0,0
    8000152a:	74a2                	ld	s1,40(sp)
    8000152c:	7902                	ld	s2,32(sp)
    8000152e:	6b02                	ld	s6,0(sp)
    80001530:	bfe9                	j	8000150a <uvmalloc+0x76>
    return oldsz;
    80001532:	852e                	mv	a0,a1
}
    80001534:	8082                	ret
  return newsz;
    80001536:	8532                	mv	a0,a2
    80001538:	bfc9                	j	8000150a <uvmalloc+0x76>

000000008000153a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000153a:	7179                	addi	sp,sp,-48
    8000153c:	f406                	sd	ra,40(sp)
    8000153e:	f022                	sd	s0,32(sp)
    80001540:	ec26                	sd	s1,24(sp)
    80001542:	e84a                	sd	s2,16(sp)
    80001544:	e44e                	sd	s3,8(sp)
    80001546:	e052                	sd	s4,0(sp)
    80001548:	1800                	addi	s0,sp,48
    8000154a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154c:	84aa                	mv	s1,a0
    8000154e:	6905                	lui	s2,0x1
    80001550:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001552:	4985                	li	s3,1
    80001554:	a819                	j	8000156a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001556:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001558:	00c79513          	slli	a0,a5,0xc
    8000155c:	fdfff0ef          	jal	8000153a <freewalk>
      pagetable[i] = 0;
    80001560:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001564:	04a1                	addi	s1,s1,8
    80001566:	01248f63          	beq	s1,s2,80001584 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000156a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156c:	00f7f713          	andi	a4,a5,15
    80001570:	ff3703e3          	beq	a4,s3,80001556 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001574:	8b85                	andi	a5,a5,1
    80001576:	d7fd                	beqz	a5,80001564 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001578:	00007517          	auipc	a0,0x7
    8000157c:	be850513          	addi	a0,a0,-1048 # 80008160 <etext+0x160>
    80001580:	a60ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001584:	8552                	mv	a0,s4
    80001586:	dd8ff0ef          	jal	80000b5e <kfree>
}
    8000158a:	70a2                	ld	ra,40(sp)
    8000158c:	7402                	ld	s0,32(sp)
    8000158e:	64e2                	ld	s1,24(sp)
    80001590:	6942                	ld	s2,16(sp)
    80001592:	69a2                	ld	s3,8(sp)
    80001594:	6a02                	ld	s4,0(sp)
    80001596:	6145                	addi	sp,sp,48
    80001598:	8082                	ret

000000008000159a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000159a:	1101                	addi	sp,sp,-32
    8000159c:	ec06                	sd	ra,24(sp)
    8000159e:	e822                	sd	s0,16(sp)
    800015a0:	e426                	sd	s1,8(sp)
    800015a2:	1000                	addi	s0,sp,32
    800015a4:	84aa                	mv	s1,a0
  if(sz > 0)
    800015a6:	e989                	bnez	a1,800015b8 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015a8:	8526                	mv	a0,s1
    800015aa:	f91ff0ef          	jal	8000153a <freewalk>
}
    800015ae:	60e2                	ld	ra,24(sp)
    800015b0:	6442                	ld	s0,16(sp)
    800015b2:	64a2                	ld	s1,8(sp)
    800015b4:	6105                	addi	sp,sp,32
    800015b6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015b8:	6785                	lui	a5,0x1
    800015ba:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015bc:	95be                	add	a1,a1,a5
    800015be:	4685                	li	a3,1
    800015c0:	00c5d613          	srli	a2,a1,0xc
    800015c4:	4581                	li	a1,0
    800015c6:	e01ff0ef          	jal	800013c6 <uvmunmap>
    800015ca:	bff9                	j	800015a8 <uvmfree+0xe>

00000000800015cc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015cc:	ce49                	beqz	a2,80001666 <uvmcopy+0x9a>
{
    800015ce:	715d                	addi	sp,sp,-80
    800015d0:	e486                	sd	ra,72(sp)
    800015d2:	e0a2                	sd	s0,64(sp)
    800015d4:	fc26                	sd	s1,56(sp)
    800015d6:	f84a                	sd	s2,48(sp)
    800015d8:	f44e                	sd	s3,40(sp)
    800015da:	f052                	sd	s4,32(sp)
    800015dc:	ec56                	sd	s5,24(sp)
    800015de:	e85a                	sd	s6,16(sp)
    800015e0:	e45e                	sd	s7,8(sp)
    800015e2:	0880                	addi	s0,sp,80
    800015e4:	8aaa                	mv	s5,a0
    800015e6:	8b2e                	mv	s6,a1
    800015e8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015ea:	4481                	li	s1,0
    800015ec:	a029                	j	800015f6 <uvmcopy+0x2a>
    800015ee:	6785                	lui	a5,0x1
    800015f0:	94be                	add	s1,s1,a5
    800015f2:	0544fe63          	bgeu	s1,s4,8000164e <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800015f6:	4601                	li	a2,0
    800015f8:	85a6                	mv	a1,s1
    800015fa:	8556                	mv	a0,s5
    800015fc:	b27ff0ef          	jal	80001122 <walk>
    80001600:	d57d                	beqz	a0,800015ee <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001602:	6118                	ld	a4,0(a0)
    80001604:	00177793          	andi	a5,a4,1
    80001608:	d3fd                	beqz	a5,800015ee <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    8000160a:	00a75593          	srli	a1,a4,0xa
    8000160e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001612:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001616:	ecaff0ef          	jal	80000ce0 <kalloc>
    8000161a:	89aa                	mv	s3,a0
    8000161c:	c105                	beqz	a0,8000163c <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000161e:	6605                	lui	a2,0x1
    80001620:	85de                	mv	a1,s7
    80001622:	8e9ff0ef          	jal	80000f0a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001626:	874a                	mv	a4,s2
    80001628:	86ce                	mv	a3,s3
    8000162a:	6605                	lui	a2,0x1
    8000162c:	85a6                	mv	a1,s1
    8000162e:	855a                	mv	a0,s6
    80001630:	bcbff0ef          	jal	800011fa <mappages>
    80001634:	dd4d                	beqz	a0,800015ee <uvmcopy+0x22>
      kfree(mem);
    80001636:	854e                	mv	a0,s3
    80001638:	d26ff0ef          	jal	80000b5e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000163c:	4685                	li	a3,1
    8000163e:	00c4d613          	srli	a2,s1,0xc
    80001642:	4581                	li	a1,0
    80001644:	855a                	mv	a0,s6
    80001646:	d81ff0ef          	jal	800013c6 <uvmunmap>
  return -1;
    8000164a:	557d                	li	a0,-1
    8000164c:	a011                	j	80001650 <uvmcopy+0x84>
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	60a6                	ld	ra,72(sp)
    80001652:	6406                	ld	s0,64(sp)
    80001654:	74e2                	ld	s1,56(sp)
    80001656:	7942                	ld	s2,48(sp)
    80001658:	79a2                	ld	s3,40(sp)
    8000165a:	7a02                	ld	s4,32(sp)
    8000165c:	6ae2                	ld	s5,24(sp)
    8000165e:	6b42                	ld	s6,16(sp)
    80001660:	6ba2                	ld	s7,8(sp)
    80001662:	6161                	addi	sp,sp,80
    80001664:	8082                	ret
  return 0;
    80001666:	4501                	li	a0,0
}
    80001668:	8082                	ret

000000008000166a <uvmcopy_cow>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    8000166a:	c655                	beqz	a2,80001716 <uvmcopy_cow+0xac>
{
    8000166c:	7139                	addi	sp,sp,-64
    8000166e:	fc06                	sd	ra,56(sp)
    80001670:	f822                	sd	s0,48(sp)
    80001672:	f426                	sd	s1,40(sp)
    80001674:	f04a                	sd	s2,32(sp)
    80001676:	ec4e                	sd	s3,24(sp)
    80001678:	e852                	sd	s4,16(sp)
    8000167a:	e456                	sd	s5,8(sp)
    8000167c:	e05a                	sd	s6,0(sp)
    8000167e:	0080                	addi	s0,sp,64
    80001680:	89aa                	mv	s3,a0
    80001682:	8a2e                	mv	s4,a1
    80001684:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001686:	4481                	li	s1,0
    
    // If the page is writable, mark it as COW and remove write permission
    if(flags & PTE_W) {
      flags = (flags & ~PTE_W) | PTE_COW;
      // Update parent's PTE to also be read-only with COW bit
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001688:	7afd                	lui	s5,0xfffff
    8000168a:	002ada93          	srli	s5,s5,0x2
    8000168e:	a81d                	j	800016c4 <uvmcopy_cow+0x5a>
      flags = (flags & ~PTE_W) | PTE_COW;
    80001690:	2fb77813          	andi	a6,a4,763
    80001694:	10086713          	ori	a4,a6,256
      *pte = PA2PTE(pa) | flags | PTE_V;
    80001698:	0157f7b3          	and	a5,a5,s5
    8000169c:	00f86833          	or	a6,a6,a5
    800016a0:	10186813          	ori	a6,a6,257
    800016a4:	01053023          	sd	a6,0(a0)
    }
    
    // Map same physical page in child's page table
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    800016a8:	86da                	mv	a3,s6
    800016aa:	6605                	lui	a2,0x1
    800016ac:	85a6                	mv	a1,s1
    800016ae:	8552                	mv	a0,s4
    800016b0:	b4bff0ef          	jal	800011fa <mappages>
    800016b4:	ed0d                	bnez	a0,800016ee <uvmcopy_cow+0x84>
      goto err;
    }
    
    // Increment reference count for this physical page
    kref_incr((void*)pa);
    800016b6:	855a                	mv	a0,s6
    800016b8:	b64ff0ef          	jal	80000a1c <kref_incr>
  for(i = 0; i < sz; i += PGSIZE){
    800016bc:	6785                	lui	a5,0x1
    800016be:	94be                	add	s1,s1,a5
    800016c0:	0524f063          	bgeu	s1,s2,80001700 <uvmcopy_cow+0x96>
    if((pte = walk(old, i, 0)) == 0)
    800016c4:	4601                	li	a2,0
    800016c6:	85a6                	mv	a1,s1
    800016c8:	854e                	mv	a0,s3
    800016ca:	a59ff0ef          	jal	80001122 <walk>
    800016ce:	d57d                	beqz	a0,800016bc <uvmcopy_cow+0x52>
    if((*pte & PTE_V) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	0017f713          	andi	a4,a5,1
    800016d6:	d37d                	beqz	a4,800016bc <uvmcopy_cow+0x52>
    pa = PTE2PA(*pte);
    800016d8:	00a7db13          	srli	s6,a5,0xa
    800016dc:	0b32                	slli	s6,s6,0xc
    flags = PTE_FLAGS(*pte);
    800016de:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W) {
    800016e2:	0047f693          	andi	a3,a5,4
    800016e6:	f6cd                	bnez	a3,80001690 <uvmcopy_cow+0x26>
    flags = PTE_FLAGS(*pte);
    800016e8:	3ff77713          	andi	a4,a4,1023
    800016ec:	bf75                	j	800016a8 <uvmcopy_cow+0x3e>
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ee:	4685                	li	a3,1
    800016f0:	00c4d613          	srli	a2,s1,0xc
    800016f4:	4581                	li	a1,0
    800016f6:	8552                	mv	a0,s4
    800016f8:	ccfff0ef          	jal	800013c6 <uvmunmap>
  return -1;
    800016fc:	557d                	li	a0,-1
    800016fe:	a011                	j	80001702 <uvmcopy_cow+0x98>
  return 0;
    80001700:	4501                	li	a0,0
}
    80001702:	70e2                	ld	ra,56(sp)
    80001704:	7442                	ld	s0,48(sp)
    80001706:	74a2                	ld	s1,40(sp)
    80001708:	7902                	ld	s2,32(sp)
    8000170a:	69e2                	ld	s3,24(sp)
    8000170c:	6a42                	ld	s4,16(sp)
    8000170e:	6aa2                	ld	s5,8(sp)
    80001710:	6b02                	ld	s6,0(sp)
    80001712:	6121                	addi	sp,sp,64
    80001714:	8082                	ret
  return 0;
    80001716:	4501                	li	a0,0
}
    80001718:	8082                	ret

000000008000171a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000171a:	1141                	addi	sp,sp,-16
    8000171c:	e406                	sd	ra,8(sp)
    8000171e:	e022                	sd	s0,0(sp)
    80001720:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001722:	4601                	li	a2,0
    80001724:	9ffff0ef          	jal	80001122 <walk>
  if(pte == 0)
    80001728:	c901                	beqz	a0,80001738 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000172a:	611c                	ld	a5,0(a0)
    8000172c:	9bbd                	andi	a5,a5,-17
    8000172e:	e11c                	sd	a5,0(a0)
}
    80001730:	60a2                	ld	ra,8(sp)
    80001732:	6402                	ld	s0,0(sp)
    80001734:	0141                	addi	sp,sp,16
    80001736:	8082                	ret
    panic("uvmclear");
    80001738:	00007517          	auipc	a0,0x7
    8000173c:	a3850513          	addi	a0,a0,-1480 # 80008170 <etext+0x170>
    80001740:	8a0ff0ef          	jal	800007e0 <panic>

0000000080001744 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001744:	c6dd                	beqz	a3,800017f2 <copyinstr+0xae>
{
    80001746:	715d                	addi	sp,sp,-80
    80001748:	e486                	sd	ra,72(sp)
    8000174a:	e0a2                	sd	s0,64(sp)
    8000174c:	fc26                	sd	s1,56(sp)
    8000174e:	f84a                	sd	s2,48(sp)
    80001750:	f44e                	sd	s3,40(sp)
    80001752:	f052                	sd	s4,32(sp)
    80001754:	ec56                	sd	s5,24(sp)
    80001756:	e85a                	sd	s6,16(sp)
    80001758:	e45e                	sd	s7,8(sp)
    8000175a:	0880                	addi	s0,sp,80
    8000175c:	8a2a                	mv	s4,a0
    8000175e:	8b2e                	mv	s6,a1
    80001760:	8bb2                	mv	s7,a2
    80001762:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001764:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001766:	6985                	lui	s3,0x1
    80001768:	a825                	j	800017a0 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000176a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000176e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001770:	37fd                	addiw	a5,a5,-1
    80001772:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001776:	60a6                	ld	ra,72(sp)
    80001778:	6406                	ld	s0,64(sp)
    8000177a:	74e2                	ld	s1,56(sp)
    8000177c:	7942                	ld	s2,48(sp)
    8000177e:	79a2                	ld	s3,40(sp)
    80001780:	7a02                	ld	s4,32(sp)
    80001782:	6ae2                	ld	s5,24(sp)
    80001784:	6b42                	ld	s6,16(sp)
    80001786:	6ba2                	ld	s7,8(sp)
    80001788:	6161                	addi	sp,sp,80
    8000178a:	8082                	ret
    8000178c:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001790:	9742                	add	a4,a4,a6
      --max;
    80001792:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001796:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000179a:	04e58463          	beq	a1,a4,800017e2 <copyinstr+0x9e>
{
    8000179e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800017a0:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017a4:	85a6                	mv	a1,s1
    800017a6:	8552                	mv	a0,s4
    800017a8:	a15ff0ef          	jal	800011bc <walkaddr>
    if(pa0 == 0)
    800017ac:	cd0d                	beqz	a0,800017e6 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017ae:	417486b3          	sub	a3,s1,s7
    800017b2:	96ce                	add	a3,a3,s3
    if(n > max)
    800017b4:	00d97363          	bgeu	s2,a3,800017ba <copyinstr+0x76>
    800017b8:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800017ba:	955e                	add	a0,a0,s7
    800017bc:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800017be:	c695                	beqz	a3,800017ea <copyinstr+0xa6>
    800017c0:	87da                	mv	a5,s6
    800017c2:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017c4:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017c8:	96da                	add	a3,a3,s6
    800017ca:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017cc:	00f60733          	add	a4,a2,a5
    800017d0:	00074703          	lbu	a4,0(a4)
    800017d4:	db59                	beqz	a4,8000176a <copyinstr+0x26>
        *dst = *p;
    800017d6:	00e78023          	sb	a4,0(a5)
      dst++;
    800017da:	0785                	addi	a5,a5,1
    while(n > 0){
    800017dc:	fed797e3          	bne	a5,a3,800017ca <copyinstr+0x86>
    800017e0:	b775                	j	8000178c <copyinstr+0x48>
    800017e2:	4781                	li	a5,0
    800017e4:	b771                	j	80001770 <copyinstr+0x2c>
      return -1;
    800017e6:	557d                	li	a0,-1
    800017e8:	b779                	j	80001776 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017ea:	6b85                	lui	s7,0x1
    800017ec:	9ba6                	add	s7,s7,s1
    800017ee:	87da                	mv	a5,s6
    800017f0:	b77d                	j	8000179e <copyinstr+0x5a>
  int got_null = 0;
    800017f2:	4781                	li	a5,0
  if(got_null){
    800017f4:	37fd                	addiw	a5,a5,-1
    800017f6:	0007851b          	sext.w	a0,a5
}
    800017fa:	8082                	ret

00000000800017fc <cowfault>:
// Handle COW page fault.
// Allocates a new page, copies the content, and updates the page table.
// Returns 0 on success, -1 on failure.
int
cowfault(pagetable_t pagetable, uint64 va)
{
    800017fc:	7179                	addi	sp,sp,-48
    800017fe:	f406                	sd	ra,40(sp)
    80001800:	f022                	sd	s0,32(sp)
    80001802:	1800                	addi	s0,sp,48
  char *mem;

  va = PGROUNDDOWN(va);
  
  // Get the PTE for this virtual address
  pte = walk(pagetable, va, 0);
    80001804:	4601                	li	a2,0
    80001806:	77fd                	lui	a5,0xfffff
    80001808:	8dfd                	and	a1,a1,a5
    8000180a:	919ff0ef          	jal	80001122 <walk>
  if(pte == 0)
    8000180e:	c541                	beqz	a0,80001896 <cowfault+0x9a>
    80001810:	e84a                	sd	s2,16(sp)
    80001812:	e44e                	sd	s3,8(sp)
    80001814:	892a                	mv	s2,a0
    return -1;
  if((*pte & PTE_V) == 0)
    80001816:	00053983          	ld	s3,0(a0)
    return -1;
  if((*pte & PTE_U) == 0)
    8000181a:	0119f713          	andi	a4,s3,17
    8000181e:	47c5                	li	a5,17
    80001820:	06f71d63          	bne	a4,a5,8000189a <cowfault+0x9e>
    return -1;
  
  // Check if this is a COW page
  if((*pte & PTE_COW) == 0)
    80001824:	1009f793          	andi	a5,s3,256
    80001828:	cfad                	beqz	a5,800018a2 <cowfault+0xa6>
    8000182a:	e052                	sd	s4,0(sp)
    return -1;
  
  pa = PTE2PA(*pte);
    8000182c:	00a9da13          	srli	s4,s3,0xa
    80001830:	0a32                	slli	s4,s4,0xc
  flags = PTE_FLAGS(*pte);
  
  // If this is the only reference, just restore write permission
  if(kref_get((void*)pa) == 1) {
    80001832:	8552                	mv	a0,s4
    80001834:	abeff0ef          	jal	80000af2 <kref_get>
    80001838:	4785                	li	a5,1
    8000183a:	04f50163          	beq	a0,a5,8000187c <cowfault+0x80>
    8000183e:	ec26                	sd	s1,24(sp)
    *pte = (*pte | PTE_W) & ~PTE_COW;
    return 0;
  }
  
  // Allocate a new page
  mem = kalloc();
    80001840:	ca0ff0ef          	jal	80000ce0 <kalloc>
    80001844:	84aa                	mv	s1,a0
  if(mem == 0)
    80001846:	c135                	beqz	a0,800018aa <cowfault+0xae>
    return -1;
  
  // Copy the content
  memmove(mem, (char*)pa, PGSIZE);
    80001848:	6605                	lui	a2,0x1
    8000184a:	85d2                	mv	a1,s4
    8000184c:	ebeff0ef          	jal	80000f0a <memmove>
  
  // Update flags: restore write permission, remove COW bit
  flags = (flags | PTE_W) & ~PTE_COW;
  
  // Update the PTE to point to the new page
  *pte = PA2PTE(mem) | flags | PTE_V;
    80001850:	80b1                	srli	s1,s1,0xc
    80001852:	04aa                	slli	s1,s1,0xa
  flags = (flags | PTE_W) & ~PTE_COW;
    80001854:	2fb9f993          	andi	s3,s3,763
  *pte = PA2PTE(mem) | flags | PTE_V;
    80001858:	0134e4b3          	or	s1,s1,s3
    8000185c:	0054e493          	ori	s1,s1,5
    80001860:	00993023          	sd	s1,0(s2)
  
  // Decrement reference count on old page (may free it)
  kfree((void*)pa);
    80001864:	8552                	mv	a0,s4
    80001866:	af8ff0ef          	jal	80000b5e <kfree>
  
  return 0;
    8000186a:	4501                	li	a0,0
    8000186c:	64e2                	ld	s1,24(sp)
    8000186e:	6942                	ld	s2,16(sp)
    80001870:	69a2                	ld	s3,8(sp)
    80001872:	6a02                	ld	s4,0(sp)
}
    80001874:	70a2                	ld	ra,40(sp)
    80001876:	7402                	ld	s0,32(sp)
    80001878:	6145                	addi	sp,sp,48
    8000187a:	8082                	ret
    *pte = (*pte | PTE_W) & ~PTE_COW;
    8000187c:	00093783          	ld	a5,0(s2)
    80001880:	efb7f793          	andi	a5,a5,-261
    80001884:	0047e793          	ori	a5,a5,4
    80001888:	00f93023          	sd	a5,0(s2)
    return 0;
    8000188c:	4501                	li	a0,0
    8000188e:	6942                	ld	s2,16(sp)
    80001890:	69a2                	ld	s3,8(sp)
    80001892:	6a02                	ld	s4,0(sp)
    80001894:	b7c5                	j	80001874 <cowfault+0x78>
    return -1;
    80001896:	557d                	li	a0,-1
    80001898:	bff1                	j	80001874 <cowfault+0x78>
    return -1;
    8000189a:	557d                	li	a0,-1
    8000189c:	6942                	ld	s2,16(sp)
    8000189e:	69a2                	ld	s3,8(sp)
    800018a0:	bfd1                	j	80001874 <cowfault+0x78>
    return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	6942                	ld	s2,16(sp)
    800018a6:	69a2                	ld	s3,8(sp)
    800018a8:	b7f1                	j	80001874 <cowfault+0x78>
    return -1;
    800018aa:	557d                	li	a0,-1
    800018ac:	64e2                	ld	s1,24(sp)
    800018ae:	6942                	ld	s2,16(sp)
    800018b0:	69a2                	ld	s3,8(sp)
    800018b2:	6a02                	ld	s4,0(sp)
    800018b4:	b7c1                	j	80001874 <cowfault+0x78>

00000000800018b6 <ismapped>:

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800018b6:	1141                	addi	sp,sp,-16
    800018b8:	e406                	sd	ra,8(sp)
    800018ba:	e022                	sd	s0,0(sp)
    800018bc:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800018be:	4601                	li	a2,0
    800018c0:	863ff0ef          	jal	80001122 <walk>
  if (pte == 0) {
    800018c4:	c519                	beqz	a0,800018d2 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800018c6:	6108                	ld	a0,0(a0)
    800018c8:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800018ca:	60a2                	ld	ra,8(sp)
    800018cc:	6402                	ld	s0,0(sp)
    800018ce:	0141                	addi	sp,sp,16
    800018d0:	8082                	ret
    return 0;
    800018d2:	4501                	li	a0,0
    800018d4:	bfdd                	j	800018ca <ismapped+0x14>

00000000800018d6 <vmfault>:
{
    800018d6:	7179                	addi	sp,sp,-48
    800018d8:	f406                	sd	ra,40(sp)
    800018da:	f022                	sd	s0,32(sp)
    800018dc:	ec26                	sd	s1,24(sp)
    800018de:	e44e                	sd	s3,8(sp)
    800018e0:	1800                	addi	s0,sp,48
    800018e2:	89aa                	mv	s3,a0
    800018e4:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    800018e6:	494000ef          	jal	80001d7a <myproc>
  if (va >= p->sz)
    800018ea:	653c                	ld	a5,72(a0)
    800018ec:	00f4ea63          	bltu	s1,a5,80001900 <vmfault+0x2a>
    return 0;
    800018f0:	4981                	li	s3,0
}
    800018f2:	854e                	mv	a0,s3
    800018f4:	70a2                	ld	ra,40(sp)
    800018f6:	7402                	ld	s0,32(sp)
    800018f8:	64e2                	ld	s1,24(sp)
    800018fa:	69a2                	ld	s3,8(sp)
    800018fc:	6145                	addi	sp,sp,48
    800018fe:	8082                	ret
    80001900:	e84a                	sd	s2,16(sp)
    80001902:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001904:	77fd                	lui	a5,0xfffff
    80001906:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001908:	85a6                	mv	a1,s1
    8000190a:	854e                	mv	a0,s3
    8000190c:	fabff0ef          	jal	800018b6 <ismapped>
    return 0;
    80001910:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001912:	c119                	beqz	a0,80001918 <vmfault+0x42>
    80001914:	6942                	ld	s2,16(sp)
    80001916:	bff1                	j	800018f2 <vmfault+0x1c>
    80001918:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    8000191a:	bc6ff0ef          	jal	80000ce0 <kalloc>
    8000191e:	8a2a                	mv	s4,a0
  if(mem == 0)
    80001920:	c90d                	beqz	a0,80001952 <vmfault+0x7c>
  mem = (uint64) kalloc();
    80001922:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001924:	6605                	lui	a2,0x1
    80001926:	4581                	li	a1,0
    80001928:	d86ff0ef          	jal	80000eae <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000192c:	4759                	li	a4,22
    8000192e:	86d2                	mv	a3,s4
    80001930:	6605                	lui	a2,0x1
    80001932:	85a6                	mv	a1,s1
    80001934:	05093503          	ld	a0,80(s2)
    80001938:	8c3ff0ef          	jal	800011fa <mappages>
    8000193c:	e501                	bnez	a0,80001944 <vmfault+0x6e>
    8000193e:	6942                	ld	s2,16(sp)
    80001940:	6a02                	ld	s4,0(sp)
    80001942:	bf45                	j	800018f2 <vmfault+0x1c>
    kfree((void *)mem);
    80001944:	8552                	mv	a0,s4
    80001946:	a18ff0ef          	jal	80000b5e <kfree>
    return 0;
    8000194a:	4981                	li	s3,0
    8000194c:	6942                	ld	s2,16(sp)
    8000194e:	6a02                	ld	s4,0(sp)
    80001950:	b74d                	j	800018f2 <vmfault+0x1c>
    80001952:	6942                	ld	s2,16(sp)
    80001954:	6a02                	ld	s4,0(sp)
    80001956:	bf71                	j	800018f2 <vmfault+0x1c>

0000000080001958 <copyout>:
  while(len > 0){
    80001958:	c2f9                	beqz	a3,80001a1e <copyout+0xc6>
{
    8000195a:	711d                	addi	sp,sp,-96
    8000195c:	ec86                	sd	ra,88(sp)
    8000195e:	e8a2                	sd	s0,80(sp)
    80001960:	e0ca                	sd	s2,64(sp)
    80001962:	f456                	sd	s5,40(sp)
    80001964:	f05a                	sd	s6,32(sp)
    80001966:	ec5e                	sd	s7,24(sp)
    80001968:	e862                	sd	s8,16(sp)
    8000196a:	1080                	addi	s0,sp,96
    8000196c:	8c2a                	mv	s8,a0
    8000196e:	8b2e                	mv	s6,a1
    80001970:	8bb2                	mv	s7,a2
    80001972:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001974:	797d                	lui	s2,0xfffff
    80001976:	0125f933          	and	s2,a1,s2
    if(va0 >= MAXVA)
    8000197a:	57fd                	li	a5,-1
    8000197c:	83e9                	srli	a5,a5,0x1a
    8000197e:	0b27e263          	bltu	a5,s2,80001a22 <copyout+0xca>
    80001982:	e4a6                	sd	s1,72(sp)
    80001984:	fc4e                	sd	s3,56(sp)
    80001986:	f852                	sd	s4,48(sp)
    80001988:	e466                	sd	s9,8(sp)
    8000198a:	e06a                	sd	s10,0(sp)
    8000198c:	6d05                	lui	s10,0x1
    8000198e:	8cbe                	mv	s9,a5
    80001990:	a82d                	j	800019ca <copyout+0x72>
      if(cowfault(pagetable, va0) < 0) {
    80001992:	85ca                	mv	a1,s2
    80001994:	8562                	mv	a0,s8
    80001996:	e67ff0ef          	jal	800017fc <cowfault>
    8000199a:	0a054463          	bltz	a0,80001a42 <copyout+0xea>
      pa0 = PTE2PA(*pte);
    8000199e:	0009b483          	ld	s1,0(s3) # 1000 <_entry-0x7ffff000>
    800019a2:	80a9                	srli	s1,s1,0xa
    800019a4:	04b2                	slli	s1,s1,0xc
    800019a6:	a889                	j	800019f8 <copyout+0xa0>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800019a8:	412b0533          	sub	a0,s6,s2
    800019ac:	0009861b          	sext.w	a2,s3
    800019b0:	85de                	mv	a1,s7
    800019b2:	9526                	add	a0,a0,s1
    800019b4:	d56ff0ef          	jal	80000f0a <memmove>
    len -= n;
    800019b8:	413a8ab3          	sub	s5,s5,s3
    src += n;
    800019bc:	9bce                	add	s7,s7,s3
  while(len > 0){
    800019be:	040a8963          	beqz	s5,80001a10 <copyout+0xb8>
    if(va0 >= MAXVA)
    800019c2:	074ce263          	bltu	s9,s4,80001a26 <copyout+0xce>
    800019c6:	8952                	mv	s2,s4
    800019c8:	8b52                	mv	s6,s4
    pa0 = walkaddr(pagetable, va0);
    800019ca:	85ca                	mv	a1,s2
    800019cc:	8562                	mv	a0,s8
    800019ce:	feeff0ef          	jal	800011bc <walkaddr>
    800019d2:	84aa                	mv	s1,a0
    if(pa0 == 0) {
    800019d4:	e901                	bnez	a0,800019e4 <copyout+0x8c>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800019d6:	4601                	li	a2,0
    800019d8:	85ca                	mv	a1,s2
    800019da:	8562                	mv	a0,s8
    800019dc:	efbff0ef          	jal	800018d6 <vmfault>
    800019e0:	84aa                	mv	s1,a0
    800019e2:	c929                	beqz	a0,80001a34 <copyout+0xdc>
    pte = walk(pagetable, va0, 0);
    800019e4:	4601                	li	a2,0
    800019e6:	85ca                	mv	a1,s2
    800019e8:	8562                	mv	a0,s8
    800019ea:	f38ff0ef          	jal	80001122 <walk>
    800019ee:	89aa                	mv	s3,a0
    if((*pte & PTE_COW) != 0) {
    800019f0:	611c                	ld	a5,0(a0)
    800019f2:	1007f793          	andi	a5,a5,256
    800019f6:	ffd1                	bnez	a5,80001992 <copyout+0x3a>
    if((*pte & PTE_W) == 0)
    800019f8:	0009b783          	ld	a5,0(s3)
    800019fc:	8b91                	andi	a5,a5,4
    800019fe:	cba9                	beqz	a5,80001a50 <copyout+0xf8>
    n = PGSIZE - (dstva - va0);
    80001a00:	01a90a33          	add	s4,s2,s10
    80001a04:	416a09b3          	sub	s3,s4,s6
    if(n > len)
    80001a08:	fb3af0e3          	bgeu	s5,s3,800019a8 <copyout+0x50>
    80001a0c:	89d6                	mv	s3,s5
    80001a0e:	bf69                	j	800019a8 <copyout+0x50>
  return 0;
    80001a10:	4501                	li	a0,0
    80001a12:	64a6                	ld	s1,72(sp)
    80001a14:	79e2                	ld	s3,56(sp)
    80001a16:	7a42                	ld	s4,48(sp)
    80001a18:	6ca2                	ld	s9,8(sp)
    80001a1a:	6d02                	ld	s10,0(sp)
    80001a1c:	a081                	j	80001a5c <copyout+0x104>
    80001a1e:	4501                	li	a0,0
}
    80001a20:	8082                	ret
      return -1;
    80001a22:	557d                	li	a0,-1
    80001a24:	a825                	j	80001a5c <copyout+0x104>
    80001a26:	557d                	li	a0,-1
    80001a28:	64a6                	ld	s1,72(sp)
    80001a2a:	79e2                	ld	s3,56(sp)
    80001a2c:	7a42                	ld	s4,48(sp)
    80001a2e:	6ca2                	ld	s9,8(sp)
    80001a30:	6d02                	ld	s10,0(sp)
    80001a32:	a02d                	j	80001a5c <copyout+0x104>
        return -1;
    80001a34:	557d                	li	a0,-1
    80001a36:	64a6                	ld	s1,72(sp)
    80001a38:	79e2                	ld	s3,56(sp)
    80001a3a:	7a42                	ld	s4,48(sp)
    80001a3c:	6ca2                	ld	s9,8(sp)
    80001a3e:	6d02                	ld	s10,0(sp)
    80001a40:	a831                	j	80001a5c <copyout+0x104>
        return -1;
    80001a42:	557d                	li	a0,-1
    80001a44:	64a6                	ld	s1,72(sp)
    80001a46:	79e2                	ld	s3,56(sp)
    80001a48:	7a42                	ld	s4,48(sp)
    80001a4a:	6ca2                	ld	s9,8(sp)
    80001a4c:	6d02                	ld	s10,0(sp)
    80001a4e:	a039                	j	80001a5c <copyout+0x104>
      return -1;
    80001a50:	557d                	li	a0,-1
    80001a52:	64a6                	ld	s1,72(sp)
    80001a54:	79e2                	ld	s3,56(sp)
    80001a56:	7a42                	ld	s4,48(sp)
    80001a58:	6ca2                	ld	s9,8(sp)
    80001a5a:	6d02                	ld	s10,0(sp)
}
    80001a5c:	60e6                	ld	ra,88(sp)
    80001a5e:	6446                	ld	s0,80(sp)
    80001a60:	6906                	ld	s2,64(sp)
    80001a62:	7aa2                	ld	s5,40(sp)
    80001a64:	7b02                	ld	s6,32(sp)
    80001a66:	6be2                	ld	s7,24(sp)
    80001a68:	6c42                	ld	s8,16(sp)
    80001a6a:	6125                	addi	sp,sp,96
    80001a6c:	8082                	ret

0000000080001a6e <copyin>:
  while(len > 0){
    80001a6e:	c6c9                	beqz	a3,80001af8 <copyin+0x8a>
{
    80001a70:	715d                	addi	sp,sp,-80
    80001a72:	e486                	sd	ra,72(sp)
    80001a74:	e0a2                	sd	s0,64(sp)
    80001a76:	fc26                	sd	s1,56(sp)
    80001a78:	f84a                	sd	s2,48(sp)
    80001a7a:	f44e                	sd	s3,40(sp)
    80001a7c:	f052                	sd	s4,32(sp)
    80001a7e:	ec56                	sd	s5,24(sp)
    80001a80:	e85a                	sd	s6,16(sp)
    80001a82:	e45e                	sd	s7,8(sp)
    80001a84:	e062                	sd	s8,0(sp)
    80001a86:	0880                	addi	s0,sp,80
    80001a88:	8baa                	mv	s7,a0
    80001a8a:	8aae                	mv	s5,a1
    80001a8c:	8932                	mv	s2,a2
    80001a8e:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a90:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a92:	6b05                	lui	s6,0x1
    80001a94:	a035                	j	80001ac0 <copyin+0x52>
    80001a96:	412984b3          	sub	s1,s3,s2
    80001a9a:	94da                	add	s1,s1,s6
    if(n > len)
    80001a9c:	009a7363          	bgeu	s4,s1,80001aa2 <copyin+0x34>
    80001aa0:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001aa2:	413905b3          	sub	a1,s2,s3
    80001aa6:	0004861b          	sext.w	a2,s1
    80001aaa:	95aa                	add	a1,a1,a0
    80001aac:	8556                	mv	a0,s5
    80001aae:	c5cff0ef          	jal	80000f0a <memmove>
    len -= n;
    80001ab2:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001ab6:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001ab8:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001abc:	020a0163          	beqz	s4,80001ade <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001ac0:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001ac4:	85ce                	mv	a1,s3
    80001ac6:	855e                	mv	a0,s7
    80001ac8:	ef4ff0ef          	jal	800011bc <walkaddr>
    if(pa0 == 0) {
    80001acc:	f569                	bnez	a0,80001a96 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001ace:	4601                	li	a2,0
    80001ad0:	85ce                	mv	a1,s3
    80001ad2:	855e                	mv	a0,s7
    80001ad4:	e03ff0ef          	jal	800018d6 <vmfault>
    80001ad8:	fd5d                	bnez	a0,80001a96 <copyin+0x28>
        return -1;
    80001ada:	557d                	li	a0,-1
    80001adc:	a011                	j	80001ae0 <copyin+0x72>
  return 0;
    80001ade:	4501                	li	a0,0
}
    80001ae0:	60a6                	ld	ra,72(sp)
    80001ae2:	6406                	ld	s0,64(sp)
    80001ae4:	74e2                	ld	s1,56(sp)
    80001ae6:	7942                	ld	s2,48(sp)
    80001ae8:	79a2                	ld	s3,40(sp)
    80001aea:	7a02                	ld	s4,32(sp)
    80001aec:	6ae2                	ld	s5,24(sp)
    80001aee:	6b42                	ld	s6,16(sp)
    80001af0:	6ba2                	ld	s7,8(sp)
    80001af2:	6c02                	ld	s8,0(sp)
    80001af4:	6161                	addi	sp,sp,80
    80001af6:	8082                	ret
  return 0;
    80001af8:	4501                	li	a0,0
}
    80001afa:	8082                	ret

0000000080001afc <ptree_add_recursive>:
static void
ptree_add_recursive(struct proc *root, struct proc_tree *tree)
{
  struct proc *p;
  
  if (tree->count >= NPROC)
    80001afc:	4198                	lw	a4,0(a1)
    80001afe:	03f00793          	li	a5,63
    80001b02:	00e7d363          	bge	a5,a4,80001b08 <ptree_add_recursive+0xc>
    80001b06:	8082                	ret
{
    80001b08:	7179                	addi	sp,sp,-48
    80001b0a:	f406                	sd	ra,40(sp)
    80001b0c:	f022                	sd	s0,32(sp)
    80001b0e:	ec26                	sd	s1,24(sp)
    80001b10:	e84a                	sd	s2,16(sp)
    80001b12:	e44e                	sd	s3,8(sp)
    80001b14:	e052                	sd	s4,0(sp)
    80001b16:	1800                	addi	s0,sp,48
    80001b18:	892a                	mv	s2,a0
    80001b1a:	8a2e                	mv	s4,a1
    return;

  // Add current process to tree
  acquire(&root->lock);
    80001b1c:	abeff0ef          	jal	80000dda <acquire>
  if (root->state != UNUSED) {
    80001b20:	01892783          	lw	a5,24(s2) # fffffffffffff018 <end+0xffffffff7ffbc958>
    80001b24:	ef89                	bnez	a5,80001b3e <ptree_add_recursive+0x42>
    info->pid = root->pid;
    info->ppid = root->parent ? root->parent->pid : 0;
    info->state = root->state;
    tree->count++;
  }
  release(&root->lock);
    80001b26:	854a                	mv	a0,s2
    80001b28:	b4aff0ef          	jal	80000e72 <release>

  // Find and add all children recursively
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b2c:	0002f497          	auipc	s1,0x2f
    80001b30:	5b448493          	addi	s1,s1,1460 # 800310e0 <proc>
    80001b34:	00035997          	auipc	s3,0x35
    80001b38:	7ac98993          	addi	s3,s3,1964 # 800372e0 <tickslock>
    80001b3c:	a0b5                	j	80001ba8 <ptree_add_recursive+0xac>
    struct proc_info *info = &tree->processes[tree->count];
    80001b3e:	000a2983          	lw	s3,0(s4)
    safestrcpy(info->name, root->name, sizeof(info->name));
    80001b42:	00399493          	slli	s1,s3,0x3
    80001b46:	41348533          	sub	a0,s1,s3
    80001b4a:	050a                	slli	a0,a0,0x2
    80001b4c:	0511                	addi	a0,a0,4
    80001b4e:	4641                	li	a2,16
    80001b50:	15890593          	addi	a1,s2,344
    80001b54:	9552                	add	a0,a0,s4
    80001b56:	c96ff0ef          	jal	80000fec <safestrcpy>
    info->pid = root->pid;
    80001b5a:	03092703          	lw	a4,48(s2)
    80001b5e:	413487b3          	sub	a5,s1,s3
    80001b62:	078a                	slli	a5,a5,0x2
    80001b64:	97d2                	add	a5,a5,s4
    80001b66:	cbd8                	sw	a4,20(a5)
    info->ppid = root->parent ? root->parent->pid : 0;
    80001b68:	03893783          	ld	a5,56(s2)
    80001b6c:	4681                	li	a3,0
    80001b6e:	c391                	beqz	a5,80001b72 <ptree_add_recursive+0x76>
    80001b70:	5b94                	lw	a3,48(a5)
    80001b72:	00399793          	slli	a5,s3,0x3
    80001b76:	41378733          	sub	a4,a5,s3
    80001b7a:	070a                	slli	a4,a4,0x2
    80001b7c:	9752                	add	a4,a4,s4
    80001b7e:	cf14                	sw	a3,24(a4)
    info->state = root->state;
    80001b80:	01892703          	lw	a4,24(s2)
    80001b84:	413787b3          	sub	a5,a5,s3
    80001b88:	078a                	slli	a5,a5,0x2
    80001b8a:	97d2                	add	a5,a5,s4
    80001b8c:	cfd8                	sw	a4,28(a5)
    tree->count++;
    80001b8e:	000a2783          	lw	a5,0(s4)
    80001b92:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffbc941>
    80001b94:	00fa2023          	sw	a5,0(s4)
    80001b98:	b779                	j	80001b26 <ptree_add_recursive+0x2a>
    acquire(&p->lock);
    if (p->parent == root && p->state != UNUSED) {
      release(&p->lock);
      ptree_add_recursive(p, tree);
    } else {
      release(&p->lock);
    80001b9a:	8526                	mv	a0,s1
    80001b9c:	ad6ff0ef          	jal	80000e72 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ba0:	18848493          	addi	s1,s1,392
    80001ba4:	03348263          	beq	s1,s3,80001bc8 <ptree_add_recursive+0xcc>
    acquire(&p->lock);
    80001ba8:	8526                	mv	a0,s1
    80001baa:	a30ff0ef          	jal	80000dda <acquire>
    if (p->parent == root && p->state != UNUSED) {
    80001bae:	7c9c                	ld	a5,56(s1)
    80001bb0:	ff2795e3          	bne	a5,s2,80001b9a <ptree_add_recursive+0x9e>
    80001bb4:	4c9c                	lw	a5,24(s1)
    80001bb6:	d3f5                	beqz	a5,80001b9a <ptree_add_recursive+0x9e>
      release(&p->lock);
    80001bb8:	8526                	mv	a0,s1
    80001bba:	ab8ff0ef          	jal	80000e72 <release>
      ptree_add_recursive(p, tree);
    80001bbe:	85d2                	mv	a1,s4
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	f3bff0ef          	jal	80001afc <ptree_add_recursive>
    80001bc6:	bfe9                	j	80001ba0 <ptree_add_recursive+0xa4>
    }
  }
}
    80001bc8:	70a2                	ld	ra,40(sp)
    80001bca:	7402                	ld	s0,32(sp)
    80001bcc:	64e2                	ld	s1,24(sp)
    80001bce:	6942                	ld	s2,16(sp)
    80001bd0:	69a2                	ld	s3,8(sp)
    80001bd2:	6a02                	ld	s4,0(sp)
    80001bd4:	6145                	addi	sp,sp,48
    80001bd6:	8082                	ret

0000000080001bd8 <proc_mapstacks>:
{
    80001bd8:	7139                	addi	sp,sp,-64
    80001bda:	fc06                	sd	ra,56(sp)
    80001bdc:	f822                	sd	s0,48(sp)
    80001bde:	f426                	sd	s1,40(sp)
    80001be0:	f04a                	sd	s2,32(sp)
    80001be2:	ec4e                	sd	s3,24(sp)
    80001be4:	e852                	sd	s4,16(sp)
    80001be6:	e456                	sd	s5,8(sp)
    80001be8:	e05a                	sd	s6,0(sp)
    80001bea:	0080                	addi	s0,sp,64
    80001bec:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bee:	0002f497          	auipc	s1,0x2f
    80001bf2:	4f248493          	addi	s1,s1,1266 # 800310e0 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001bf6:	8b26                	mv	s6,s1
    80001bf8:	03eb2937          	lui	s2,0x3eb2
    80001bfc:	a1f90913          	addi	s2,s2,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    80001c00:	0932                	slli	s2,s2,0xc
    80001c02:	58d90913          	addi	s2,s2,1421
    80001c06:	0932                	slli	s2,s2,0xc
    80001c08:	0fb90913          	addi	s2,s2,251
    80001c0c:	0936                	slli	s2,s2,0xd
    80001c0e:	8d190913          	addi	s2,s2,-1839
    80001c12:	040009b7          	lui	s3,0x4000
    80001c16:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001c18:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c1a:	00035a97          	auipc	s5,0x35
    80001c1e:	6c6a8a93          	addi	s5,s5,1734 # 800372e0 <tickslock>
    char *pa = kalloc();
    80001c22:	8beff0ef          	jal	80000ce0 <kalloc>
    80001c26:	862a                	mv	a2,a0
    if(pa == 0)
    80001c28:	cd15                	beqz	a0,80001c64 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001c2a:	416485b3          	sub	a1,s1,s6
    80001c2e:	858d                	srai	a1,a1,0x3
    80001c30:	032585b3          	mul	a1,a1,s2
    80001c34:	2585                	addiw	a1,a1,1
    80001c36:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c3a:	4719                	li	a4,6
    80001c3c:	6685                	lui	a3,0x1
    80001c3e:	40b985b3          	sub	a1,s3,a1
    80001c42:	8552                	mv	a0,s4
    80001c44:	e66ff0ef          	jal	800012aa <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c48:	18848493          	addi	s1,s1,392
    80001c4c:	fd549be3          	bne	s1,s5,80001c22 <proc_mapstacks+0x4a>
}
    80001c50:	70e2                	ld	ra,56(sp)
    80001c52:	7442                	ld	s0,48(sp)
    80001c54:	74a2                	ld	s1,40(sp)
    80001c56:	7902                	ld	s2,32(sp)
    80001c58:	69e2                	ld	s3,24(sp)
    80001c5a:	6a42                	ld	s4,16(sp)
    80001c5c:	6aa2                	ld	s5,8(sp)
    80001c5e:	6b02                	ld	s6,0(sp)
    80001c60:	6121                	addi	sp,sp,64
    80001c62:	8082                	ret
      panic("kalloc");
    80001c64:	00006517          	auipc	a0,0x6
    80001c68:	51c50513          	addi	a0,a0,1308 # 80008180 <etext+0x180>
    80001c6c:	b75fe0ef          	jal	800007e0 <panic>

0000000080001c70 <procinit>:
{
    80001c70:	7139                	addi	sp,sp,-64
    80001c72:	fc06                	sd	ra,56(sp)
    80001c74:	f822                	sd	s0,48(sp)
    80001c76:	f426                	sd	s1,40(sp)
    80001c78:	f04a                	sd	s2,32(sp)
    80001c7a:	ec4e                	sd	s3,24(sp)
    80001c7c:	e852                	sd	s4,16(sp)
    80001c7e:	e456                	sd	s5,8(sp)
    80001c80:	e05a                	sd	s6,0(sp)
    80001c82:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80001c84:	00006597          	auipc	a1,0x6
    80001c88:	50458593          	addi	a1,a1,1284 # 80008188 <etext+0x188>
    80001c8c:	0002f517          	auipc	a0,0x2f
    80001c90:	e0450513          	addi	a0,a0,-508 # 80030a90 <pid_lock>
    80001c94:	8c6ff0ef          	jal	80000d5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c98:	00006597          	auipc	a1,0x6
    80001c9c:	4f858593          	addi	a1,a1,1272 # 80008190 <etext+0x190>
    80001ca0:	0002f517          	auipc	a0,0x2f
    80001ca4:	e0850513          	addi	a0,a0,-504 # 80030aa8 <wait_lock>
    80001ca8:	8b2ff0ef          	jal	80000d5a <initlock>
  initlock(&runq_lock, "runqueue");
    80001cac:	00006597          	auipc	a1,0x6
    80001cb0:	4f458593          	addi	a1,a1,1268 # 800081a0 <etext+0x1a0>
    80001cb4:	0002f517          	auipc	a0,0x2f
    80001cb8:	e0c50513          	addi	a0,a0,-500 # 80030ac0 <runq_lock>
    80001cbc:	89eff0ef          	jal	80000d5a <initlock>
  minheap_init(&run_queue);
    80001cc0:	0002f517          	auipc	a0,0x2f
    80001cc4:	e1850513          	addi	a0,a0,-488 # 80030ad8 <run_queue>
    80001cc8:	6c2040ef          	jal	8000638a <minheap_init>
  min_vruntime = 0;
    80001ccc:	00007797          	auipc	a5,0x7
    80001cd0:	c807ba23          	sd	zero,-876(a5) # 80008960 <min_vruntime>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd4:	0002f497          	auipc	s1,0x2f
    80001cd8:	40c48493          	addi	s1,s1,1036 # 800310e0 <proc>
      initlock(&p->lock, "proc");
    80001cdc:	00006b17          	auipc	s6,0x6
    80001ce0:	4d4b0b13          	addi	s6,s6,1236 # 800081b0 <etext+0x1b0>
      p->kstack = KSTACK((int) (p - proc));
    80001ce4:	8aa6                	mv	s5,s1
    80001ce6:	03eb2937          	lui	s2,0x3eb2
    80001cea:	a1f90913          	addi	s2,s2,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    80001cee:	0932                	slli	s2,s2,0xc
    80001cf0:	58d90913          	addi	s2,s2,1421
    80001cf4:	0932                	slli	s2,s2,0xc
    80001cf6:	0fb90913          	addi	s2,s2,251
    80001cfa:	0936                	slli	s2,s2,0xd
    80001cfc:	8d190913          	addi	s2,s2,-1839
    80001d00:	040009b7          	lui	s3,0x4000
    80001d04:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001d06:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d08:	00035a17          	auipc	s4,0x35
    80001d0c:	5d8a0a13          	addi	s4,s4,1496 # 800372e0 <tickslock>
      initlock(&p->lock, "proc");
    80001d10:	85da                	mv	a1,s6
    80001d12:	8526                	mv	a0,s1
    80001d14:	846ff0ef          	jal	80000d5a <initlock>
      p->state = UNUSED;
    80001d18:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001d1c:	415487b3          	sub	a5,s1,s5
    80001d20:	878d                	srai	a5,a5,0x3
    80001d22:	032787b3          	mul	a5,a5,s2
    80001d26:	2785                	addiw	a5,a5,1
    80001d28:	00d7979b          	slliw	a5,a5,0xd
    80001d2c:	40f987b3          	sub	a5,s3,a5
    80001d30:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d32:	18848493          	addi	s1,s1,392
    80001d36:	fd449de3          	bne	s1,s4,80001d10 <procinit+0xa0>
}
    80001d3a:	70e2                	ld	ra,56(sp)
    80001d3c:	7442                	ld	s0,48(sp)
    80001d3e:	74a2                	ld	s1,40(sp)
    80001d40:	7902                	ld	s2,32(sp)
    80001d42:	69e2                	ld	s3,24(sp)
    80001d44:	6a42                	ld	s4,16(sp)
    80001d46:	6aa2                	ld	s5,8(sp)
    80001d48:	6b02                	ld	s6,0(sp)
    80001d4a:	6121                	addi	sp,sp,64
    80001d4c:	8082                	ret

0000000080001d4e <cpuid>:
{
    80001d4e:	1141                	addi	sp,sp,-16
    80001d50:	e422                	sd	s0,8(sp)
    80001d52:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d54:	8512                	mv	a0,tp
}
    80001d56:	2501                	sext.w	a0,a0
    80001d58:	6422                	ld	s0,8(sp)
    80001d5a:	0141                	addi	sp,sp,16
    80001d5c:	8082                	ret

0000000080001d5e <mycpu>:
{
    80001d5e:	1141                	addi	sp,sp,-16
    80001d60:	e422                	sd	s0,8(sp)
    80001d62:	0800                	addi	s0,sp,16
    80001d64:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001d66:	2781                	sext.w	a5,a5
    80001d68:	079e                	slli	a5,a5,0x7
}
    80001d6a:	0002f517          	auipc	a0,0x2f
    80001d6e:	f7650513          	addi	a0,a0,-138 # 80030ce0 <cpus>
    80001d72:	953e                	add	a0,a0,a5
    80001d74:	6422                	ld	s0,8(sp)
    80001d76:	0141                	addi	sp,sp,16
    80001d78:	8082                	ret

0000000080001d7a <myproc>:
{
    80001d7a:	1101                	addi	sp,sp,-32
    80001d7c:	ec06                	sd	ra,24(sp)
    80001d7e:	e822                	sd	s0,16(sp)
    80001d80:	e426                	sd	s1,8(sp)
    80001d82:	1000                	addi	s0,sp,32
  push_off();
    80001d84:	816ff0ef          	jal	80000d9a <push_off>
    80001d88:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001d8a:	2781                	sext.w	a5,a5
    80001d8c:	079e                	slli	a5,a5,0x7
    80001d8e:	0002f717          	auipc	a4,0x2f
    80001d92:	d0270713          	addi	a4,a4,-766 # 80030a90 <pid_lock>
    80001d96:	97ba                	add	a5,a5,a4
    80001d98:	2507b483          	ld	s1,592(a5)
  pop_off();
    80001d9c:	882ff0ef          	jal	80000e1e <pop_off>
}
    80001da0:	8526                	mv	a0,s1
    80001da2:	60e2                	ld	ra,24(sp)
    80001da4:	6442                	ld	s0,16(sp)
    80001da6:	64a2                	ld	s1,8(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret

0000000080001dac <allocpid>:
{
    80001dac:	1101                	addi	sp,sp,-32
    80001dae:	ec06                	sd	ra,24(sp)
    80001db0:	e822                	sd	s0,16(sp)
    80001db2:	e426                	sd	s1,8(sp)
    80001db4:	e04a                	sd	s2,0(sp)
    80001db6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001db8:	0002f917          	auipc	s2,0x2f
    80001dbc:	cd890913          	addi	s2,s2,-808 # 80030a90 <pid_lock>
    80001dc0:	854a                	mv	a0,s2
    80001dc2:	818ff0ef          	jal	80000dda <acquire>
  pid = nextpid;
    80001dc6:	00007797          	auipc	a5,0x7
    80001dca:	b6e78793          	addi	a5,a5,-1170 # 80008934 <nextpid>
    80001dce:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dd0:	0014871b          	addiw	a4,s1,1
    80001dd4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001dd6:	854a                	mv	a0,s2
    80001dd8:	89aff0ef          	jal	80000e72 <release>
}
    80001ddc:	8526                	mv	a0,s1
    80001dde:	60e2                	ld	ra,24(sp)
    80001de0:	6442                	ld	s0,16(sp)
    80001de2:	64a2                	ld	s1,8(sp)
    80001de4:	6902                	ld	s2,0(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret

0000000080001dea <proc_pagetable>:
{
    80001dea:	1101                	addi	sp,sp,-32
    80001dec:	ec06                	sd	ra,24(sp)
    80001dee:	e822                	sd	s0,16(sp)
    80001df0:	e426                	sd	s1,8(sp)
    80001df2:	e04a                	sd	s2,0(sp)
    80001df4:	1000                	addi	s0,sp,32
    80001df6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001df8:	da8ff0ef          	jal	800013a0 <uvmcreate>
    80001dfc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001dfe:	cd05                	beqz	a0,80001e36 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e00:	4729                	li	a4,10
    80001e02:	00005697          	auipc	a3,0x5
    80001e06:	1fe68693          	addi	a3,a3,510 # 80007000 <_trampoline>
    80001e0a:	6605                	lui	a2,0x1
    80001e0c:	040005b7          	lui	a1,0x4000
    80001e10:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e12:	05b2                	slli	a1,a1,0xc
    80001e14:	be6ff0ef          	jal	800011fa <mappages>
    80001e18:	02054663          	bltz	a0,80001e44 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e1c:	4719                	li	a4,6
    80001e1e:	05893683          	ld	a3,88(s2)
    80001e22:	6605                	lui	a2,0x1
    80001e24:	020005b7          	lui	a1,0x2000
    80001e28:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e2a:	05b6                	slli	a1,a1,0xd
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	bccff0ef          	jal	800011fa <mappages>
    80001e32:	00054f63          	bltz	a0,80001e50 <proc_pagetable+0x66>
}
    80001e36:	8526                	mv	a0,s1
    80001e38:	60e2                	ld	ra,24(sp)
    80001e3a:	6442                	ld	s0,16(sp)
    80001e3c:	64a2                	ld	s1,8(sp)
    80001e3e:	6902                	ld	s2,0(sp)
    80001e40:	6105                	addi	sp,sp,32
    80001e42:	8082                	ret
    uvmfree(pagetable, 0);
    80001e44:	4581                	li	a1,0
    80001e46:	8526                	mv	a0,s1
    80001e48:	f52ff0ef          	jal	8000159a <uvmfree>
    return 0;
    80001e4c:	4481                	li	s1,0
    80001e4e:	b7e5                	j	80001e36 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e50:	4681                	li	a3,0
    80001e52:	4605                	li	a2,1
    80001e54:	040005b7          	lui	a1,0x4000
    80001e58:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e5a:	05b2                	slli	a1,a1,0xc
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	d68ff0ef          	jal	800013c6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e62:	4581                	li	a1,0
    80001e64:	8526                	mv	a0,s1
    80001e66:	f34ff0ef          	jal	8000159a <uvmfree>
    return 0;
    80001e6a:	4481                	li	s1,0
    80001e6c:	b7e9                	j	80001e36 <proc_pagetable+0x4c>

0000000080001e6e <proc_freepagetable>:
{
    80001e6e:	1101                	addi	sp,sp,-32
    80001e70:	ec06                	sd	ra,24(sp)
    80001e72:	e822                	sd	s0,16(sp)
    80001e74:	e426                	sd	s1,8(sp)
    80001e76:	e04a                	sd	s2,0(sp)
    80001e78:	1000                	addi	s0,sp,32
    80001e7a:	84aa                	mv	s1,a0
    80001e7c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e7e:	4681                	li	a3,0
    80001e80:	4605                	li	a2,1
    80001e82:	040005b7          	lui	a1,0x4000
    80001e86:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e88:	05b2                	slli	a1,a1,0xc
    80001e8a:	d3cff0ef          	jal	800013c6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e8e:	4681                	li	a3,0
    80001e90:	4605                	li	a2,1
    80001e92:	020005b7          	lui	a1,0x2000
    80001e96:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e98:	05b6                	slli	a1,a1,0xd
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	d2aff0ef          	jal	800013c6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ea0:	85ca                	mv	a1,s2
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	ef6ff0ef          	jal	8000159a <uvmfree>
}
    80001ea8:	60e2                	ld	ra,24(sp)
    80001eaa:	6442                	ld	s0,16(sp)
    80001eac:	64a2                	ld	s1,8(sp)
    80001eae:	6902                	ld	s2,0(sp)
    80001eb0:	6105                	addi	sp,sp,32
    80001eb2:	8082                	ret

0000000080001eb4 <freeproc>:
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	1000                	addi	s0,sp,32
    80001ebe:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ec0:	6d28                	ld	a0,88(a0)
    80001ec2:	c119                	beqz	a0,80001ec8 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001ec4:	c9bfe0ef          	jal	80000b5e <kfree>
  p->trapframe = 0;
    80001ec8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ecc:	68a8                	ld	a0,80(s1)
    80001ece:	c501                	beqz	a0,80001ed6 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ed0:	64ac                	ld	a1,72(s1)
    80001ed2:	f9dff0ef          	jal	80001e6e <proc_freepagetable>
  p->pagetable = 0;
    80001ed6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001eda:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ede:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ee2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ee6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001eea:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001eee:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ef2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ef6:	0004ac23          	sw	zero,24(s1)
  p->is_kproc = 0;
    80001efa:	1604ac23          	sw	zero,376(s1)
  p->kentry = 0;
    80001efe:	1804b023          	sd	zero,384(s1)
}
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6105                	addi	sp,sp,32
    80001f0a:	8082                	ret

0000000080001f0c <allocproc>:
{
    80001f0c:	1101                	addi	sp,sp,-32
    80001f0e:	ec06                	sd	ra,24(sp)
    80001f10:	e822                	sd	s0,16(sp)
    80001f12:	e426                	sd	s1,8(sp)
    80001f14:	e04a                	sd	s2,0(sp)
    80001f16:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f18:	0002f497          	auipc	s1,0x2f
    80001f1c:	1c848493          	addi	s1,s1,456 # 800310e0 <proc>
    80001f20:	00035917          	auipc	s2,0x35
    80001f24:	3c090913          	addi	s2,s2,960 # 800372e0 <tickslock>
    acquire(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	eb1fe0ef          	jal	80000dda <acquire>
    if(p->state == UNUSED) {
    80001f2e:	4c9c                	lw	a5,24(s1)
    80001f30:	cb91                	beqz	a5,80001f44 <allocproc+0x38>
      release(&p->lock);
    80001f32:	8526                	mv	a0,s1
    80001f34:	f3ffe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f38:	18848493          	addi	s1,s1,392
    80001f3c:	ff2496e3          	bne	s1,s2,80001f28 <allocproc+0x1c>
  return 0;
    80001f40:	4481                	li	s1,0
    80001f42:	a8b9                	j	80001fa0 <allocproc+0x94>
  p->pid = allocpid();
    80001f44:	e69ff0ef          	jal	80001dac <allocpid>
    80001f48:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f4a:	4785                	li	a5,1
    80001f4c:	cc9c                	sw	a5,24(s1)
  p->is_kproc = 0;
    80001f4e:	1604ac23          	sw	zero,376(s1)
  p->kentry = 0;
    80001f52:	1804b023          	sd	zero,384(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001f56:	d8bfe0ef          	jal	80000ce0 <kalloc>
    80001f5a:	892a                	mv	s2,a0
    80001f5c:	eca8                	sd	a0,88(s1)
    80001f5e:	c921                	beqz	a0,80001fae <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001f60:	8526                	mv	a0,s1
    80001f62:	e89ff0ef          	jal	80001dea <proc_pagetable>
    80001f66:	892a                	mv	s2,a0
    80001f68:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001f6a:	c931                	beqz	a0,80001fbe <allocproc+0xb2>
  memset(&p->context, 0, sizeof(p->context));
    80001f6c:	07000613          	li	a2,112
    80001f70:	4581                	li	a1,0
    80001f72:	06048513          	addi	a0,s1,96
    80001f76:	f39fe0ef          	jal	80000eae <memset>
  p->context.ra = (uint64)forkret;
    80001f7a:	00001797          	auipc	a5,0x1
    80001f7e:	c0c78793          	addi	a5,a5,-1012 # 80002b86 <forkret>
    80001f82:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f84:	60bc                	ld	a5,64(s1)
    80001f86:	6705                	lui	a4,0x1
    80001f88:	97ba                	add	a5,a5,a4
    80001f8a:	f4bc                	sd	a5,104(s1)
  p->vruntime = min_vruntime;
    80001f8c:	00007797          	auipc	a5,0x7
    80001f90:	9d47b783          	ld	a5,-1580(a5) # 80008960 <min_vruntime>
    80001f94:	16f4b823          	sd	a5,368(s1)
  p->weight = 1024;  // Default weight (nice value 0)
    80001f98:	40000793          	li	a5,1024
    80001f9c:	16f4a423          	sw	a5,360(s1)
}
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	60e2                	ld	ra,24(sp)
    80001fa4:	6442                	ld	s0,16(sp)
    80001fa6:	64a2                	ld	s1,8(sp)
    80001fa8:	6902                	ld	s2,0(sp)
    80001faa:	6105                	addi	sp,sp,32
    80001fac:	8082                	ret
    freeproc(p);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	f05ff0ef          	jal	80001eb4 <freeproc>
    release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	ebdfe0ef          	jal	80000e72 <release>
    return 0;
    80001fba:	84ca                	mv	s1,s2
    80001fbc:	b7d5                	j	80001fa0 <allocproc+0x94>
    freeproc(p);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	ef5ff0ef          	jal	80001eb4 <freeproc>
    release(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	eadfe0ef          	jal	80000e72 <release>
    return 0;
    80001fca:	84ca                	mv	s1,s2
    80001fcc:	bfd1                	j	80001fa0 <allocproc+0x94>

0000000080001fce <userinit>:
{
    80001fce:	1101                	addi	sp,sp,-32
    80001fd0:	ec06                	sd	ra,24(sp)
    80001fd2:	e822                	sd	s0,16(sp)
    80001fd4:	e426                	sd	s1,8(sp)
    80001fd6:	e04a                	sd	s2,0(sp)
    80001fd8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001fda:	f33ff0ef          	jal	80001f0c <allocproc>
    80001fde:	84aa                	mv	s1,a0
  initproc = p;
    80001fe0:	00007797          	auipc	a5,0x7
    80001fe4:	98a7b423          	sd	a0,-1656(a5) # 80008968 <initproc>
  p->cwd = namei("/");
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	1d050513          	addi	a0,a0,464 # 800081b8 <etext+0x1b8>
    80001ff0:	42a020ef          	jal	8000441a <namei>
    80001ff4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ff8:	478d                	li	a5,3
    80001ffa:	cc9c                	sw	a5,24(s1)
  acquire(&runq_lock);
    80001ffc:	0002f917          	auipc	s2,0x2f
    80002000:	ac490913          	addi	s2,s2,-1340 # 80030ac0 <runq_lock>
    80002004:	854a                	mv	a0,s2
    80002006:	dd5fe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    8000200a:	85a6                	mv	a1,s1
    8000200c:	0002f517          	auipc	a0,0x2f
    80002010:	acc50513          	addi	a0,a0,-1332 # 80030ad8 <run_queue>
    80002014:	39e040ef          	jal	800063b2 <minheap_insert>
  release(&runq_lock);
    80002018:	854a                	mv	a0,s2
    8000201a:	e59fe0ef          	jal	80000e72 <release>
  release(&p->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	e53fe0ef          	jal	80000e72 <release>
}
    80002024:	60e2                	ld	ra,24(sp)
    80002026:	6442                	ld	s0,16(sp)
    80002028:	64a2                	ld	s1,8(sp)
    8000202a:	6902                	ld	s2,0(sp)
    8000202c:	6105                	addi	sp,sp,32
    8000202e:	8082                	ret

0000000080002030 <growproc>:
{
    80002030:	1101                	addi	sp,sp,-32
    80002032:	ec06                	sd	ra,24(sp)
    80002034:	e822                	sd	s0,16(sp)
    80002036:	e426                	sd	s1,8(sp)
    80002038:	e04a                	sd	s2,0(sp)
    8000203a:	1000                	addi	s0,sp,32
    8000203c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000203e:	d3dff0ef          	jal	80001d7a <myproc>
    80002042:	892a                	mv	s2,a0
  sz = p->sz;
    80002044:	652c                	ld	a1,72(a0)
  if(n > 0){
    80002046:	02905963          	blez	s1,80002078 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    8000204a:	00b48633          	add	a2,s1,a1
    8000204e:	020007b7          	lui	a5,0x2000
    80002052:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002054:	07b6                	slli	a5,a5,0xd
    80002056:	02c7ea63          	bltu	a5,a2,8000208a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000205a:	4691                	li	a3,4
    8000205c:	6928                	ld	a0,80(a0)
    8000205e:	c36ff0ef          	jal	80001494 <uvmalloc>
    80002062:	85aa                	mv	a1,a0
    80002064:	c50d                	beqz	a0,8000208e <growproc+0x5e>
  p->sz = sz;
    80002066:	04b93423          	sd	a1,72(s2)
  return 0;
    8000206a:	4501                	li	a0,0
}
    8000206c:	60e2                	ld	ra,24(sp)
    8000206e:	6442                	ld	s0,16(sp)
    80002070:	64a2                	ld	s1,8(sp)
    80002072:	6902                	ld	s2,0(sp)
    80002074:	6105                	addi	sp,sp,32
    80002076:	8082                	ret
  } else if(n < 0){
    80002078:	fe04d7e3          	bgez	s1,80002066 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000207c:	00b48633          	add	a2,s1,a1
    80002080:	6928                	ld	a0,80(a0)
    80002082:	bceff0ef          	jal	80001450 <uvmdealloc>
    80002086:	85aa                	mv	a1,a0
    80002088:	bff9                	j	80002066 <growproc+0x36>
      return -1;
    8000208a:	557d                	li	a0,-1
    8000208c:	b7c5                	j	8000206c <growproc+0x3c>
      return -1;
    8000208e:	557d                	li	a0,-1
    80002090:	bff1                	j	8000206c <growproc+0x3c>

0000000080002092 <kfork>:
{
    80002092:	7139                	addi	sp,sp,-64
    80002094:	fc06                	sd	ra,56(sp)
    80002096:	f822                	sd	s0,48(sp)
    80002098:	f04a                	sd	s2,32(sp)
    8000209a:	e456                	sd	s5,8(sp)
    8000209c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000209e:	cddff0ef          	jal	80001d7a <myproc>
    800020a2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020a4:	e69ff0ef          	jal	80001f0c <allocproc>
    800020a8:	10050b63          	beqz	a0,800021be <kfork+0x12c>
    800020ac:	ec4e                	sd	s3,24(sp)
    800020ae:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020b0:	048ab603          	ld	a2,72(s5)
    800020b4:	692c                	ld	a1,80(a0)
    800020b6:	050ab503          	ld	a0,80(s5)
    800020ba:	d12ff0ef          	jal	800015cc <uvmcopy>
    800020be:	04054a63          	bltz	a0,80002112 <kfork+0x80>
    800020c2:	f426                	sd	s1,40(sp)
    800020c4:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800020c6:	048ab783          	ld	a5,72(s5)
    800020ca:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800020ce:	058ab683          	ld	a3,88(s5)
    800020d2:	87b6                	mv	a5,a3
    800020d4:	0589b703          	ld	a4,88(s3)
    800020d8:	12068693          	addi	a3,a3,288
    800020dc:	0007b803          	ld	a6,0(a5)
    800020e0:	6788                	ld	a0,8(a5)
    800020e2:	6b8c                	ld	a1,16(a5)
    800020e4:	6f90                	ld	a2,24(a5)
    800020e6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800020ea:	e708                	sd	a0,8(a4)
    800020ec:	eb0c                	sd	a1,16(a4)
    800020ee:	ef10                	sd	a2,24(a4)
    800020f0:	02078793          	addi	a5,a5,32
    800020f4:	02070713          	addi	a4,a4,32
    800020f8:	fed792e3          	bne	a5,a3,800020dc <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020fc:	0589b783          	ld	a5,88(s3)
    80002100:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002104:	0d0a8493          	addi	s1,s5,208
    80002108:	0d098913          	addi	s2,s3,208
    8000210c:	150a8a13          	addi	s4,s5,336
    80002110:	a831                	j	8000212c <kfork+0x9a>
    freeproc(np);
    80002112:	854e                	mv	a0,s3
    80002114:	da1ff0ef          	jal	80001eb4 <freeproc>
    release(&np->lock);
    80002118:	854e                	mv	a0,s3
    8000211a:	d59fe0ef          	jal	80000e72 <release>
    return -1;
    8000211e:	597d                	li	s2,-1
    80002120:	69e2                	ld	s3,24(sp)
    80002122:	a079                	j	800021b0 <kfork+0x11e>
  for(i = 0; i < NOFILE; i++)
    80002124:	04a1                	addi	s1,s1,8
    80002126:	0921                	addi	s2,s2,8
    80002128:	01448963          	beq	s1,s4,8000213a <kfork+0xa8>
    if(p->ofile[i])
    8000212c:	6088                	ld	a0,0(s1)
    8000212e:	d97d                	beqz	a0,80002124 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002130:	085020ef          	jal	800049b4 <filedup>
    80002134:	00a93023          	sd	a0,0(s2)
    80002138:	b7f5                	j	80002124 <kfork+0x92>
  np->cwd = idup(p->cwd);
    8000213a:	150ab503          	ld	a0,336(s5)
    8000213e:	291010ef          	jal	80003bce <idup>
    80002142:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002146:	4641                	li	a2,16
    80002148:	158a8593          	addi	a1,s5,344
    8000214c:	15898513          	addi	a0,s3,344
    80002150:	e9dfe0ef          	jal	80000fec <safestrcpy>
  pid = np->pid;
    80002154:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002158:	854e                	mv	a0,s3
    8000215a:	d19fe0ef          	jal	80000e72 <release>
  acquire(&wait_lock);
    8000215e:	0002f497          	auipc	s1,0x2f
    80002162:	94a48493          	addi	s1,s1,-1718 # 80030aa8 <wait_lock>
    80002166:	8526                	mv	a0,s1
    80002168:	c73fe0ef          	jal	80000dda <acquire>
  np->parent = p;
    8000216c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002170:	8526                	mv	a0,s1
    80002172:	d01fe0ef          	jal	80000e72 <release>
  acquire(&np->lock);
    80002176:	854e                	mv	a0,s3
    80002178:	c63fe0ef          	jal	80000dda <acquire>
  np->state = RUNNABLE;
    8000217c:	478d                	li	a5,3
    8000217e:	00f9ac23          	sw	a5,24(s3)
  acquire(&runq_lock);
    80002182:	0002f497          	auipc	s1,0x2f
    80002186:	93e48493          	addi	s1,s1,-1730 # 80030ac0 <runq_lock>
    8000218a:	8526                	mv	a0,s1
    8000218c:	c4ffe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, np);
    80002190:	85ce                	mv	a1,s3
    80002192:	0002f517          	auipc	a0,0x2f
    80002196:	94650513          	addi	a0,a0,-1722 # 80030ad8 <run_queue>
    8000219a:	218040ef          	jal	800063b2 <minheap_insert>
  release(&runq_lock);
    8000219e:	8526                	mv	a0,s1
    800021a0:	cd3fe0ef          	jal	80000e72 <release>
  release(&np->lock);
    800021a4:	854e                	mv	a0,s3
    800021a6:	ccdfe0ef          	jal	80000e72 <release>
  return pid;
    800021aa:	74a2                	ld	s1,40(sp)
    800021ac:	69e2                	ld	s3,24(sp)
    800021ae:	6a42                	ld	s4,16(sp)
}
    800021b0:	854a                	mv	a0,s2
    800021b2:	70e2                	ld	ra,56(sp)
    800021b4:	7442                	ld	s0,48(sp)
    800021b6:	7902                	ld	s2,32(sp)
    800021b8:	6aa2                	ld	s5,8(sp)
    800021ba:	6121                	addi	sp,sp,64
    800021bc:	8082                	ret
    return -1;
    800021be:	597d                	li	s2,-1
    800021c0:	bfc5                	j	800021b0 <kfork+0x11e>

00000000800021c2 <kcowfork>:
{
    800021c2:	7139                	addi	sp,sp,-64
    800021c4:	fc06                	sd	ra,56(sp)
    800021c6:	f822                	sd	s0,48(sp)
    800021c8:	f04a                	sd	s2,32(sp)
    800021ca:	e456                	sd	s5,8(sp)
    800021cc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800021ce:	badff0ef          	jal	80001d7a <myproc>
    800021d2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800021d4:	d39ff0ef          	jal	80001f0c <allocproc>
    800021d8:	10050b63          	beqz	a0,800022ee <kcowfork+0x12c>
    800021dc:	ec4e                	sd	s3,24(sp)
    800021de:	89aa                	mv	s3,a0
  if(uvmcopy_cow(p->pagetable, np->pagetable, p->sz) < 0){
    800021e0:	048ab603          	ld	a2,72(s5)
    800021e4:	692c                	ld	a1,80(a0)
    800021e6:	050ab503          	ld	a0,80(s5)
    800021ea:	c80ff0ef          	jal	8000166a <uvmcopy_cow>
    800021ee:	04054a63          	bltz	a0,80002242 <kcowfork+0x80>
    800021f2:	f426                	sd	s1,40(sp)
    800021f4:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800021f6:	048ab783          	ld	a5,72(s5)
    800021fa:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800021fe:	058ab683          	ld	a3,88(s5)
    80002202:	87b6                	mv	a5,a3
    80002204:	0589b703          	ld	a4,88(s3)
    80002208:	12068693          	addi	a3,a3,288
    8000220c:	0007b803          	ld	a6,0(a5)
    80002210:	6788                	ld	a0,8(a5)
    80002212:	6b8c                	ld	a1,16(a5)
    80002214:	6f90                	ld	a2,24(a5)
    80002216:	01073023          	sd	a6,0(a4)
    8000221a:	e708                	sd	a0,8(a4)
    8000221c:	eb0c                	sd	a1,16(a4)
    8000221e:	ef10                	sd	a2,24(a4)
    80002220:	02078793          	addi	a5,a5,32
    80002224:	02070713          	addi	a4,a4,32
    80002228:	fed792e3          	bne	a5,a3,8000220c <kcowfork+0x4a>
  np->trapframe->a0 = 0;
    8000222c:	0589b783          	ld	a5,88(s3)
    80002230:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002234:	0d0a8493          	addi	s1,s5,208
    80002238:	0d098913          	addi	s2,s3,208
    8000223c:	150a8a13          	addi	s4,s5,336
    80002240:	a831                	j	8000225c <kcowfork+0x9a>
    freeproc(np);
    80002242:	854e                	mv	a0,s3
    80002244:	c71ff0ef          	jal	80001eb4 <freeproc>
    release(&np->lock);
    80002248:	854e                	mv	a0,s3
    8000224a:	c29fe0ef          	jal	80000e72 <release>
    return -1;
    8000224e:	597d                	li	s2,-1
    80002250:	69e2                	ld	s3,24(sp)
    80002252:	a079                	j	800022e0 <kcowfork+0x11e>
  for(i = 0; i < NOFILE; i++)
    80002254:	04a1                	addi	s1,s1,8
    80002256:	0921                	addi	s2,s2,8
    80002258:	01448963          	beq	s1,s4,8000226a <kcowfork+0xa8>
    if(p->ofile[i])
    8000225c:	6088                	ld	a0,0(s1)
    8000225e:	d97d                	beqz	a0,80002254 <kcowfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002260:	754020ef          	jal	800049b4 <filedup>
    80002264:	00a93023          	sd	a0,0(s2)
    80002268:	b7f5                	j	80002254 <kcowfork+0x92>
  np->cwd = idup(p->cwd);
    8000226a:	150ab503          	ld	a0,336(s5)
    8000226e:	161010ef          	jal	80003bce <idup>
    80002272:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002276:	4641                	li	a2,16
    80002278:	158a8593          	addi	a1,s5,344
    8000227c:	15898513          	addi	a0,s3,344
    80002280:	d6dfe0ef          	jal	80000fec <safestrcpy>
  pid = np->pid;
    80002284:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002288:	854e                	mv	a0,s3
    8000228a:	be9fe0ef          	jal	80000e72 <release>
  acquire(&wait_lock);
    8000228e:	0002f497          	auipc	s1,0x2f
    80002292:	81a48493          	addi	s1,s1,-2022 # 80030aa8 <wait_lock>
    80002296:	8526                	mv	a0,s1
    80002298:	b43fe0ef          	jal	80000dda <acquire>
  np->parent = p;
    8000229c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	bd1fe0ef          	jal	80000e72 <release>
  acquire(&np->lock);
    800022a6:	854e                	mv	a0,s3
    800022a8:	b33fe0ef          	jal	80000dda <acquire>
  np->state = RUNNABLE;
    800022ac:	478d                	li	a5,3
    800022ae:	00f9ac23          	sw	a5,24(s3)
  acquire(&runq_lock);
    800022b2:	0002f497          	auipc	s1,0x2f
    800022b6:	80e48493          	addi	s1,s1,-2034 # 80030ac0 <runq_lock>
    800022ba:	8526                	mv	a0,s1
    800022bc:	b1ffe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, np);
    800022c0:	85ce                	mv	a1,s3
    800022c2:	0002f517          	auipc	a0,0x2f
    800022c6:	81650513          	addi	a0,a0,-2026 # 80030ad8 <run_queue>
    800022ca:	0e8040ef          	jal	800063b2 <minheap_insert>
  release(&runq_lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	ba3fe0ef          	jal	80000e72 <release>
  release(&np->lock);
    800022d4:	854e                	mv	a0,s3
    800022d6:	b9dfe0ef          	jal	80000e72 <release>
  return pid;
    800022da:	74a2                	ld	s1,40(sp)
    800022dc:	69e2                	ld	s3,24(sp)
    800022de:	6a42                	ld	s4,16(sp)
}
    800022e0:	854a                	mv	a0,s2
    800022e2:	70e2                	ld	ra,56(sp)
    800022e4:	7442                	ld	s0,48(sp)
    800022e6:	7902                	ld	s2,32(sp)
    800022e8:	6aa2                	ld	s5,8(sp)
    800022ea:	6121                	addi	sp,sp,64
    800022ec:	8082                	ret
    return -1;
    800022ee:	597d                	li	s2,-1
    800022f0:	bfc5                	j	800022e0 <kcowfork+0x11e>

00000000800022f2 <scheduler>:
{
    800022f2:	715d                	addi	sp,sp,-80
    800022f4:	e486                	sd	ra,72(sp)
    800022f6:	e0a2                	sd	s0,64(sp)
    800022f8:	fc26                	sd	s1,56(sp)
    800022fa:	f84a                	sd	s2,48(sp)
    800022fc:	f44e                	sd	s3,40(sp)
    800022fe:	f052                	sd	s4,32(sp)
    80002300:	ec56                	sd	s5,24(sp)
    80002302:	e85a                	sd	s6,16(sp)
    80002304:	e45e                	sd	s7,8(sp)
    80002306:	0880                	addi	s0,sp,80
    80002308:	8792                	mv	a5,tp
  int id = r_tp();
    8000230a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000230c:	00779b13          	slli	s6,a5,0x7
    80002310:	0002e717          	auipc	a4,0x2e
    80002314:	78070713          	addi	a4,a4,1920 # 80030a90 <pid_lock>
    80002318:	975a                	add	a4,a4,s6
    8000231a:	24073823          	sd	zero,592(a4)
        swtch(&c->context, &p->context);
    8000231e:	0002f717          	auipc	a4,0x2f
    80002322:	9ca70713          	addi	a4,a4,-1590 # 80030ce8 <cpus+0x8>
    80002326:	9b3a                	add	s6,s6,a4
    acquire(&runq_lock);
    80002328:	0002e917          	auipc	s2,0x2e
    8000232c:	79890913          	addi	s2,s2,1944 # 80030ac0 <runq_lock>
    p = minheap_extract_min(&run_queue);
    80002330:	0002e997          	auipc	s3,0x2e
    80002334:	7a898993          	addi	s3,s3,1960 # 80030ad8 <run_queue>
      if(p->state == RUNNABLE) {
    80002338:	4a0d                	li	s4,3
        p->state = RUNNING;
    8000233a:	4b91                	li	s7,4
        c->proc = p;
    8000233c:	079e                	slli	a5,a5,0x7
    8000233e:	0002ea97          	auipc	s5,0x2e
    80002342:	752a8a93          	addi	s5,s5,1874 # 80030a90 <pid_lock>
    80002346:	9abe                	add	s5,s5,a5
    80002348:	a021                	j	80002350 <scheduler+0x5e>
      release(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	b27fe0ef          	jal	80000e72 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002350:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002354:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002358:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000235c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002360:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002362:	10079073          	csrw	sstatus,a5
    acquire(&runq_lock);
    80002366:	854a                	mv	a0,s2
    80002368:	a73fe0ef          	jal	80000dda <acquire>
    p = minheap_extract_min(&run_queue);
    8000236c:	854e                	mv	a0,s3
    8000236e:	0b6040ef          	jal	80006424 <minheap_extract_min>
    80002372:	84aa                	mv	s1,a0
    release(&runq_lock);
    80002374:	854a                	mv	a0,s2
    80002376:	afdfe0ef          	jal	80000e72 <release>
    if(p != 0) {
    8000237a:	c09d                	beqz	s1,800023a0 <scheduler+0xae>
      acquire(&p->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	a5dfe0ef          	jal	80000dda <acquire>
      if(p->state == RUNNABLE) {
    80002382:	4c9c                	lw	a5,24(s1)
    80002384:	fd4793e3          	bne	a5,s4,8000234a <scheduler+0x58>
        p->state = RUNNING;
    80002388:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000238c:	249ab823          	sd	s1,592(s5)
        swtch(&c->context, &p->context);
    80002390:	06048593          	addi	a1,s1,96
    80002394:	855a                	mv	a0,s6
    80002396:	09d000ef          	jal	80002c32 <swtch>
        c->proc = 0;
    8000239a:	240ab823          	sd	zero,592(s5)
    8000239e:	b775                	j	8000234a <scheduler+0x58>
      asm volatile("wfi");
    800023a0:	10500073          	wfi
    800023a4:	b775                	j	80002350 <scheduler+0x5e>

00000000800023a6 <sched>:
{
    800023a6:	7179                	addi	sp,sp,-48
    800023a8:	f406                	sd	ra,40(sp)
    800023aa:	f022                	sd	s0,32(sp)
    800023ac:	ec26                	sd	s1,24(sp)
    800023ae:	e84a                	sd	s2,16(sp)
    800023b0:	e44e                	sd	s3,8(sp)
    800023b2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023b4:	9c7ff0ef          	jal	80001d7a <myproc>
    800023b8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023ba:	9b7fe0ef          	jal	80000d70 <holding>
    800023be:	c92d                	beqz	a0,80002430 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023c0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023c2:	2781                	sext.w	a5,a5
    800023c4:	079e                	slli	a5,a5,0x7
    800023c6:	0002e717          	auipc	a4,0x2e
    800023ca:	6ca70713          	addi	a4,a4,1738 # 80030a90 <pid_lock>
    800023ce:	97ba                	add	a5,a5,a4
    800023d0:	2c87a703          	lw	a4,712(a5)
    800023d4:	4785                	li	a5,1
    800023d6:	06f71363          	bne	a4,a5,8000243c <sched+0x96>
  if(p->state == RUNNING)
    800023da:	4c98                	lw	a4,24(s1)
    800023dc:	4791                	li	a5,4
    800023de:	06f70563          	beq	a4,a5,80002448 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023e2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023e6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800023e8:	e7b5                	bnez	a5,80002454 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023ea:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023ec:	0002e917          	auipc	s2,0x2e
    800023f0:	6a490913          	addi	s2,s2,1700 # 80030a90 <pid_lock>
    800023f4:	2781                	sext.w	a5,a5
    800023f6:	079e                	slli	a5,a5,0x7
    800023f8:	97ca                	add	a5,a5,s2
    800023fa:	2cc7a983          	lw	s3,716(a5)
    800023fe:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002400:	2781                	sext.w	a5,a5
    80002402:	079e                	slli	a5,a5,0x7
    80002404:	0002f597          	auipc	a1,0x2f
    80002408:	8e458593          	addi	a1,a1,-1820 # 80030ce8 <cpus+0x8>
    8000240c:	95be                	add	a1,a1,a5
    8000240e:	06048513          	addi	a0,s1,96
    80002412:	021000ef          	jal	80002c32 <swtch>
    80002416:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002418:	2781                	sext.w	a5,a5
    8000241a:	079e                	slli	a5,a5,0x7
    8000241c:	993e                	add	s2,s2,a5
    8000241e:	2d392623          	sw	s3,716(s2)
}
    80002422:	70a2                	ld	ra,40(sp)
    80002424:	7402                	ld	s0,32(sp)
    80002426:	64e2                	ld	s1,24(sp)
    80002428:	6942                	ld	s2,16(sp)
    8000242a:	69a2                	ld	s3,8(sp)
    8000242c:	6145                	addi	sp,sp,48
    8000242e:	8082                	ret
    panic("sched p->lock");
    80002430:	00006517          	auipc	a0,0x6
    80002434:	d9050513          	addi	a0,a0,-624 # 800081c0 <etext+0x1c0>
    80002438:	ba8fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    8000243c:	00006517          	auipc	a0,0x6
    80002440:	d9450513          	addi	a0,a0,-620 # 800081d0 <etext+0x1d0>
    80002444:	b9cfe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002448:	00006517          	auipc	a0,0x6
    8000244c:	d9850513          	addi	a0,a0,-616 # 800081e0 <etext+0x1e0>
    80002450:	b90fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80002454:	00006517          	auipc	a0,0x6
    80002458:	d9c50513          	addi	a0,a0,-612 # 800081f0 <etext+0x1f0>
    8000245c:	b84fe0ef          	jal	800007e0 <panic>

0000000080002460 <yield>:
{
    80002460:	1101                	addi	sp,sp,-32
    80002462:	ec06                	sd	ra,24(sp)
    80002464:	e822                	sd	s0,16(sp)
    80002466:	e426                	sd	s1,8(sp)
    80002468:	e04a                	sd	s2,0(sp)
    8000246a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000246c:	90fff0ef          	jal	80001d7a <myproc>
    80002470:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002472:	969fe0ef          	jal	80000dda <acquire>
  p->vruntime += (1024 / p->weight);
    80002476:	1684a783          	lw	a5,360(s1)
    8000247a:	40000713          	li	a4,1024
    8000247e:	02f7473b          	divw	a4,a4,a5
    80002482:	1704b783          	ld	a5,368(s1)
    80002486:	97ba                	add	a5,a5,a4
    80002488:	16f4b823          	sd	a5,368(s1)
  acquire(&runq_lock);
    8000248c:	0002e517          	auipc	a0,0x2e
    80002490:	63450513          	addi	a0,a0,1588 # 80030ac0 <runq_lock>
    80002494:	947fe0ef          	jal	80000dda <acquire>
  if(p->vruntime > min_vruntime)
    80002498:	1704b783          	ld	a5,368(s1)
    8000249c:	00006717          	auipc	a4,0x6
    800024a0:	4c473703          	ld	a4,1220(a4) # 80008960 <min_vruntime>
    800024a4:	00f77663          	bgeu	a4,a5,800024b0 <yield+0x50>
    min_vruntime = p->vruntime;
    800024a8:	00006717          	auipc	a4,0x6
    800024ac:	4af73c23          	sd	a5,1208(a4) # 80008960 <min_vruntime>
  release(&runq_lock);
    800024b0:	0002e917          	auipc	s2,0x2e
    800024b4:	61090913          	addi	s2,s2,1552 # 80030ac0 <runq_lock>
    800024b8:	854a                	mv	a0,s2
    800024ba:	9b9fe0ef          	jal	80000e72 <release>
  p->state = RUNNABLE;
    800024be:	478d                	li	a5,3
    800024c0:	cc9c                	sw	a5,24(s1)
  acquire(&runq_lock);
    800024c2:	854a                	mv	a0,s2
    800024c4:	917fe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    800024c8:	85a6                	mv	a1,s1
    800024ca:	0002e517          	auipc	a0,0x2e
    800024ce:	60e50513          	addi	a0,a0,1550 # 80030ad8 <run_queue>
    800024d2:	6e1030ef          	jal	800063b2 <minheap_insert>
  release(&runq_lock);
    800024d6:	854a                	mv	a0,s2
    800024d8:	99bfe0ef          	jal	80000e72 <release>
  sched();
    800024dc:	ecbff0ef          	jal	800023a6 <sched>
  release(&p->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	991fe0ef          	jal	80000e72 <release>
}
    800024e6:	60e2                	ld	ra,24(sp)
    800024e8:	6442                	ld	s0,16(sp)
    800024ea:	64a2                	ld	s1,8(sp)
    800024ec:	6902                	ld	s2,0(sp)
    800024ee:	6105                	addi	sp,sp,32
    800024f0:	8082                	ret

00000000800024f2 <swapd>:
{
    800024f2:	1101                	addi	sp,sp,-32
    800024f4:	ec06                	sd	ra,24(sp)
    800024f6:	e822                	sd	s0,16(sp)
    800024f8:	e426                	sd	s1,8(sp)
    800024fa:	1000                	addi	s0,sp,32
    printf("swapd: alive\n");
    800024fc:	00006497          	auipc	s1,0x6
    80002500:	d0c48493          	addi	s1,s1,-756 # 80008208 <etext+0x208>
    80002504:	8526                	mv	a0,s1
    80002506:	ff5fd0ef          	jal	800004fa <printf>
    yield();
    8000250a:	f57ff0ef          	jal	80002460 <yield>
  for(;;){
    8000250e:	bfdd                	j	80002504 <swapd+0x12>

0000000080002510 <kproc_start>:
{
    80002510:	1101                	addi	sp,sp,-32
    80002512:	ec06                	sd	ra,24(sp)
    80002514:	e822                	sd	s0,16(sp)
    80002516:	e426                	sd	s1,8(sp)
    80002518:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000251a:	861ff0ef          	jal	80001d7a <myproc>
    8000251e:	84aa                	mv	s1,a0
  release(&p->lock);
    80002520:	953fe0ef          	jal	80000e72 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002524:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002528:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000252c:	10079073          	csrw	sstatus,a5
  if(p->kentry)
    80002530:	1804b783          	ld	a5,384(s1)
    80002534:	c391                	beqz	a5,80002538 <kproc_start+0x28>
    p->kentry();
    80002536:	9782                	jalr	a5
    yield();
    80002538:	f29ff0ef          	jal	80002460 <yield>
  for(;;)
    8000253c:	bff5                	j	80002538 <kproc_start+0x28>

000000008000253e <sleep>:
{
    8000253e:	7179                	addi	sp,sp,-48
    80002540:	f406                	sd	ra,40(sp)
    80002542:	f022                	sd	s0,32(sp)
    80002544:	ec26                	sd	s1,24(sp)
    80002546:	e84a                	sd	s2,16(sp)
    80002548:	e44e                	sd	s3,8(sp)
    8000254a:	1800                	addi	s0,sp,48
    8000254c:	89aa                	mv	s3,a0
    8000254e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002550:	82bff0ef          	jal	80001d7a <myproc>
    80002554:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    80002556:	885fe0ef          	jal	80000dda <acquire>
  release(lk);
    8000255a:	854a                	mv	a0,s2
    8000255c:	917fe0ef          	jal	80000e72 <release>
  p->chan = chan;
    80002560:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002564:	4789                	li	a5,2
    80002566:	cc9c                	sw	a5,24(s1)
  sched();
    80002568:	e3fff0ef          	jal	800023a6 <sched>
  p->chan = 0;
    8000256c:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	901fe0ef          	jal	80000e72 <release>
  acquire(lk);
    80002576:	854a                	mv	a0,s2
    80002578:	863fe0ef          	jal	80000dda <acquire>
}
    8000257c:	70a2                	ld	ra,40(sp)
    8000257e:	7402                	ld	s0,32(sp)
    80002580:	64e2                	ld	s1,24(sp)
    80002582:	6942                	ld	s2,16(sp)
    80002584:	69a2                	ld	s3,8(sp)
    80002586:	6145                	addi	sp,sp,48
    80002588:	8082                	ret

000000008000258a <wakeup>:
{
    8000258a:	715d                	addi	sp,sp,-80
    8000258c:	e486                	sd	ra,72(sp)
    8000258e:	e0a2                	sd	s0,64(sp)
    80002590:	fc26                	sd	s1,56(sp)
    80002592:	f84a                	sd	s2,48(sp)
    80002594:	f44e                	sd	s3,40(sp)
    80002596:	f052                	sd	s4,32(sp)
    80002598:	ec56                	sd	s5,24(sp)
    8000259a:	e85a                	sd	s6,16(sp)
    8000259c:	e45e                	sd	s7,8(sp)
    8000259e:	e062                	sd	s8,0(sp)
    800025a0:	0880                	addi	s0,sp,80
    800025a2:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800025a4:	0002f497          	auipc	s1,0x2f
    800025a8:	b3c48493          	addi	s1,s1,-1220 # 800310e0 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    800025ac:	4989                	li	s3,2
        p->state = RUNNABLE;
    800025ae:	4c0d                	li	s8,3
        if(p->vruntime < min_vruntime)
    800025b0:	00006b97          	auipc	s7,0x6
    800025b4:	3b0b8b93          	addi	s7,s7,944 # 80008960 <min_vruntime>
        acquire(&runq_lock);
    800025b8:	0002ea97          	auipc	s5,0x2e
    800025bc:	508a8a93          	addi	s5,s5,1288 # 80030ac0 <runq_lock>
        minheap_insert(&run_queue, p);
    800025c0:	0002eb17          	auipc	s6,0x2e
    800025c4:	518b0b13          	addi	s6,s6,1304 # 80030ad8 <run_queue>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025c8:	00035917          	auipc	s2,0x35
    800025cc:	d1890913          	addi	s2,s2,-744 # 800372e0 <tickslock>
    800025d0:	a015                	j	800025f4 <wakeup+0x6a>
        acquire(&runq_lock);
    800025d2:	8556                	mv	a0,s5
    800025d4:	807fe0ef          	jal	80000dda <acquire>
        minheap_insert(&run_queue, p);
    800025d8:	85a6                	mv	a1,s1
    800025da:	855a                	mv	a0,s6
    800025dc:	5d7030ef          	jal	800063b2 <minheap_insert>
        release(&runq_lock);
    800025e0:	8556                	mv	a0,s5
    800025e2:	891fe0ef          	jal	80000e72 <release>
      release(&p->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	88bfe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025ec:	18848493          	addi	s1,s1,392
    800025f0:	03248a63          	beq	s1,s2,80002624 <wakeup+0x9a>
    if(p != myproc()){
    800025f4:	f86ff0ef          	jal	80001d7a <myproc>
    800025f8:	fea48ae3          	beq	s1,a0,800025ec <wakeup+0x62>
      acquire(&p->lock);
    800025fc:	8526                	mv	a0,s1
    800025fe:	fdcfe0ef          	jal	80000dda <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002602:	4c9c                	lw	a5,24(s1)
    80002604:	ff3791e3          	bne	a5,s3,800025e6 <wakeup+0x5c>
    80002608:	709c                	ld	a5,32(s1)
    8000260a:	fd479ee3          	bne	a5,s4,800025e6 <wakeup+0x5c>
        p->state = RUNNABLE;
    8000260e:	0184ac23          	sw	s8,24(s1)
        if(p->vruntime < min_vruntime)
    80002612:	000bb783          	ld	a5,0(s7)
    80002616:	1704b703          	ld	a4,368(s1)
    8000261a:	faf77ce3          	bgeu	a4,a5,800025d2 <wakeup+0x48>
          p->vruntime = min_vruntime;
    8000261e:	16f4b823          	sd	a5,368(s1)
    80002622:	bf45                	j	800025d2 <wakeup+0x48>
}
    80002624:	60a6                	ld	ra,72(sp)
    80002626:	6406                	ld	s0,64(sp)
    80002628:	74e2                	ld	s1,56(sp)
    8000262a:	7942                	ld	s2,48(sp)
    8000262c:	79a2                	ld	s3,40(sp)
    8000262e:	7a02                	ld	s4,32(sp)
    80002630:	6ae2                	ld	s5,24(sp)
    80002632:	6b42                	ld	s6,16(sp)
    80002634:	6ba2                	ld	s7,8(sp)
    80002636:	6c02                	ld	s8,0(sp)
    80002638:	6161                	addi	sp,sp,80
    8000263a:	8082                	ret

000000008000263c <reparent>:
{
    8000263c:	7179                	addi	sp,sp,-48
    8000263e:	f406                	sd	ra,40(sp)
    80002640:	f022                	sd	s0,32(sp)
    80002642:	ec26                	sd	s1,24(sp)
    80002644:	e84a                	sd	s2,16(sp)
    80002646:	e44e                	sd	s3,8(sp)
    80002648:	e052                	sd	s4,0(sp)
    8000264a:	1800                	addi	s0,sp,48
    8000264c:	892a                	mv	s2,a0
  if(p->parent != 0 && p->parent != initproc){
    8000264e:	03853a03          	ld	s4,56(a0)
    80002652:	000a0863          	beqz	s4,80002662 <reparent+0x26>
    80002656:	00006797          	auipc	a5,0x6
    8000265a:	3127b783          	ld	a5,786(a5) # 80008968 <initproc>
    8000265e:	00fa1663          	bne	s4,a5,8000266a <reparent+0x2e>
    new_parent = initproc;
    80002662:	00006a17          	auipc	s4,0x6
    80002666:	306a3a03          	ld	s4,774(s4) # 80008968 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000266a:	0002f497          	auipc	s1,0x2f
    8000266e:	a7648493          	addi	s1,s1,-1418 # 800310e0 <proc>
    80002672:	00035997          	auipc	s3,0x35
    80002676:	c6e98993          	addi	s3,s3,-914 # 800372e0 <tickslock>
    8000267a:	a029                	j	80002684 <reparent+0x48>
    8000267c:	18848493          	addi	s1,s1,392
    80002680:	01348b63          	beq	s1,s3,80002696 <reparent+0x5a>
    if(pp->parent == p){
    80002684:	7c9c                	ld	a5,56(s1)
    80002686:	ff279be3          	bne	a5,s2,8000267c <reparent+0x40>
      pp->parent = new_parent;
    8000268a:	0344bc23          	sd	s4,56(s1)
      wakeup(new_parent);
    8000268e:	8552                	mv	a0,s4
    80002690:	efbff0ef          	jal	8000258a <wakeup>
    80002694:	b7e5                	j	8000267c <reparent+0x40>
}
    80002696:	70a2                	ld	ra,40(sp)
    80002698:	7402                	ld	s0,32(sp)
    8000269a:	64e2                	ld	s1,24(sp)
    8000269c:	6942                	ld	s2,16(sp)
    8000269e:	69a2                	ld	s3,8(sp)
    800026a0:	6a02                	ld	s4,0(sp)
    800026a2:	6145                	addi	sp,sp,48
    800026a4:	8082                	ret

00000000800026a6 <kexit>:
{
    800026a6:	7179                	addi	sp,sp,-48
    800026a8:	f406                	sd	ra,40(sp)
    800026aa:	f022                	sd	s0,32(sp)
    800026ac:	ec26                	sd	s1,24(sp)
    800026ae:	e84a                	sd	s2,16(sp)
    800026b0:	e44e                	sd	s3,8(sp)
    800026b2:	e052                	sd	s4,0(sp)
    800026b4:	1800                	addi	s0,sp,48
    800026b6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026b8:	ec2ff0ef          	jal	80001d7a <myproc>
    800026bc:	89aa                	mv	s3,a0
  if(p == initproc)
    800026be:	00006797          	auipc	a5,0x6
    800026c2:	2aa7b783          	ld	a5,682(a5) # 80008968 <initproc>
    800026c6:	0d050493          	addi	s1,a0,208
    800026ca:	15050913          	addi	s2,a0,336
    800026ce:	00a79f63          	bne	a5,a0,800026ec <kexit+0x46>
    panic("init exiting");
    800026d2:	00006517          	auipc	a0,0x6
    800026d6:	b4650513          	addi	a0,a0,-1210 # 80008218 <etext+0x218>
    800026da:	906fe0ef          	jal	800007e0 <panic>
      fileclose(f);
    800026de:	31c020ef          	jal	800049fa <fileclose>
      p->ofile[fd] = 0;
    800026e2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026e6:	04a1                	addi	s1,s1,8
    800026e8:	01248563          	beq	s1,s2,800026f2 <kexit+0x4c>
    if(p->ofile[fd]){
    800026ec:	6088                	ld	a0,0(s1)
    800026ee:	f965                	bnez	a0,800026de <kexit+0x38>
    800026f0:	bfdd                	j	800026e6 <kexit+0x40>
  begin_op();
    800026f2:	6fd010ef          	jal	800045ee <begin_op>
  iput(p->cwd);
    800026f6:	1509b503          	ld	a0,336(s3)
    800026fa:	68c010ef          	jal	80003d86 <iput>
  end_op();
    800026fe:	75b010ef          	jal	80004658 <end_op>
  p->cwd = 0;
    80002702:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002706:	0002e497          	auipc	s1,0x2e
    8000270a:	3a248493          	addi	s1,s1,930 # 80030aa8 <wait_lock>
    8000270e:	8526                	mv	a0,s1
    80002710:	ecafe0ef          	jal	80000dda <acquire>
  reparent(p);
    80002714:	854e                	mv	a0,s3
    80002716:	f27ff0ef          	jal	8000263c <reparent>
  wakeup(p->parent);
    8000271a:	0389b503          	ld	a0,56(s3)
    8000271e:	e6dff0ef          	jal	8000258a <wakeup>
  acquire(&p->lock);
    80002722:	854e                	mv	a0,s3
    80002724:	eb6fe0ef          	jal	80000dda <acquire>
  p->xstate = status;
    80002728:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000272c:	4795                	li	a5,5
    8000272e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002732:	8526                	mv	a0,s1
    80002734:	f3efe0ef          	jal	80000e72 <release>
  sched();
    80002738:	c6fff0ef          	jal	800023a6 <sched>
  panic("zombie exit");
    8000273c:	00006517          	auipc	a0,0x6
    80002740:	aec50513          	addi	a0,a0,-1300 # 80008228 <etext+0x228>
    80002744:	89cfe0ef          	jal	800007e0 <panic>

0000000080002748 <kkill>:
{
    80002748:	7179                	addi	sp,sp,-48
    8000274a:	f406                	sd	ra,40(sp)
    8000274c:	f022                	sd	s0,32(sp)
    8000274e:	ec26                	sd	s1,24(sp)
    80002750:	e84a                	sd	s2,16(sp)
    80002752:	e44e                	sd	s3,8(sp)
    80002754:	1800                	addi	s0,sp,48
    80002756:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002758:	0002f497          	auipc	s1,0x2f
    8000275c:	98848493          	addi	s1,s1,-1656 # 800310e0 <proc>
    80002760:	00035997          	auipc	s3,0x35
    80002764:	b8098993          	addi	s3,s3,-1152 # 800372e0 <tickslock>
    acquire(&p->lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	e70fe0ef          	jal	80000dda <acquire>
    if(p->pid == pid){
    8000276e:	589c                	lw	a5,48(s1)
    80002770:	01278b63          	beq	a5,s2,80002786 <kkill+0x3e>
    release(&p->lock);
    80002774:	8526                	mv	a0,s1
    80002776:	efcfe0ef          	jal	80000e72 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000277a:	18848493          	addi	s1,s1,392
    8000277e:	ff3495e3          	bne	s1,s3,80002768 <kkill+0x20>
  return -1;
    80002782:	557d                	li	a0,-1
    80002784:	a819                	j	8000279a <kkill+0x52>
      p->killed = 1;
    80002786:	4785                	li	a5,1
    80002788:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000278a:	4c98                	lw	a4,24(s1)
    8000278c:	4789                	li	a5,2
    8000278e:	00f70d63          	beq	a4,a5,800027a8 <kkill+0x60>
      release(&p->lock);
    80002792:	8526                	mv	a0,s1
    80002794:	edefe0ef          	jal	80000e72 <release>
      return 0;
    80002798:	4501                	li	a0,0
}
    8000279a:	70a2                	ld	ra,40(sp)
    8000279c:	7402                	ld	s0,32(sp)
    8000279e:	64e2                	ld	s1,24(sp)
    800027a0:	6942                	ld	s2,16(sp)
    800027a2:	69a2                	ld	s3,8(sp)
    800027a4:	6145                	addi	sp,sp,48
    800027a6:	8082                	ret
        p->state = RUNNABLE;
    800027a8:	478d                	li	a5,3
    800027aa:	cc9c                	sw	a5,24(s1)
        if(p->vruntime < min_vruntime)
    800027ac:	00006797          	auipc	a5,0x6
    800027b0:	1b47b783          	ld	a5,436(a5) # 80008960 <min_vruntime>
    800027b4:	1704b703          	ld	a4,368(s1)
    800027b8:	00f77463          	bgeu	a4,a5,800027c0 <kkill+0x78>
          p->vruntime = min_vruntime;
    800027bc:	16f4b823          	sd	a5,368(s1)
        acquire(&runq_lock);
    800027c0:	0002e917          	auipc	s2,0x2e
    800027c4:	30090913          	addi	s2,s2,768 # 80030ac0 <runq_lock>
    800027c8:	854a                	mv	a0,s2
    800027ca:	e10fe0ef          	jal	80000dda <acquire>
        minheap_insert(&run_queue, p);
    800027ce:	85a6                	mv	a1,s1
    800027d0:	0002e517          	auipc	a0,0x2e
    800027d4:	30850513          	addi	a0,a0,776 # 80030ad8 <run_queue>
    800027d8:	3db030ef          	jal	800063b2 <minheap_insert>
        release(&runq_lock);
    800027dc:	854a                	mv	a0,s2
    800027de:	e94fe0ef          	jal	80000e72 <release>
    800027e2:	bf45                	j	80002792 <kkill+0x4a>

00000000800027e4 <setkilled>:
{
    800027e4:	1101                	addi	sp,sp,-32
    800027e6:	ec06                	sd	ra,24(sp)
    800027e8:	e822                	sd	s0,16(sp)
    800027ea:	e426                	sd	s1,8(sp)
    800027ec:	1000                	addi	s0,sp,32
    800027ee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027f0:	deafe0ef          	jal	80000dda <acquire>
  p->killed = 1;
    800027f4:	4785                	li	a5,1
    800027f6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800027f8:	8526                	mv	a0,s1
    800027fa:	e78fe0ef          	jal	80000e72 <release>
}
    800027fe:	60e2                	ld	ra,24(sp)
    80002800:	6442                	ld	s0,16(sp)
    80002802:	64a2                	ld	s1,8(sp)
    80002804:	6105                	addi	sp,sp,32
    80002806:	8082                	ret

0000000080002808 <killed>:
{
    80002808:	1101                	addi	sp,sp,-32
    8000280a:	ec06                	sd	ra,24(sp)
    8000280c:	e822                	sd	s0,16(sp)
    8000280e:	e426                	sd	s1,8(sp)
    80002810:	e04a                	sd	s2,0(sp)
    80002812:	1000                	addi	s0,sp,32
    80002814:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002816:	dc4fe0ef          	jal	80000dda <acquire>
  k = p->killed;
    8000281a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000281e:	8526                	mv	a0,s1
    80002820:	e52fe0ef          	jal	80000e72 <release>
}
    80002824:	854a                	mv	a0,s2
    80002826:	60e2                	ld	ra,24(sp)
    80002828:	6442                	ld	s0,16(sp)
    8000282a:	64a2                	ld	s1,8(sp)
    8000282c:	6902                	ld	s2,0(sp)
    8000282e:	6105                	addi	sp,sp,32
    80002830:	8082                	ret

0000000080002832 <kwait>:
{
    80002832:	715d                	addi	sp,sp,-80
    80002834:	e486                	sd	ra,72(sp)
    80002836:	e0a2                	sd	s0,64(sp)
    80002838:	fc26                	sd	s1,56(sp)
    8000283a:	f84a                	sd	s2,48(sp)
    8000283c:	f44e                	sd	s3,40(sp)
    8000283e:	f052                	sd	s4,32(sp)
    80002840:	ec56                	sd	s5,24(sp)
    80002842:	e85a                	sd	s6,16(sp)
    80002844:	e45e                	sd	s7,8(sp)
    80002846:	e062                	sd	s8,0(sp)
    80002848:	0880                	addi	s0,sp,80
    8000284a:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000284c:	d2eff0ef          	jal	80001d7a <myproc>
    80002850:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002852:	0002e517          	auipc	a0,0x2e
    80002856:	25650513          	addi	a0,a0,598 # 80030aa8 <wait_lock>
    8000285a:	d80fe0ef          	jal	80000dda <acquire>
    havekids = 0;
    8000285e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002860:	4a15                	li	s4,5
        havekids = 1;
    80002862:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002864:	00035997          	auipc	s3,0x35
    80002868:	a7c98993          	addi	s3,s3,-1412 # 800372e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000286c:	0002ec17          	auipc	s8,0x2e
    80002870:	23cc0c13          	addi	s8,s8,572 # 80030aa8 <wait_lock>
    80002874:	a871                	j	80002910 <kwait+0xde>
          pid = pp->pid;
    80002876:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000287a:	000b0c63          	beqz	s6,80002892 <kwait+0x60>
    8000287e:	4691                	li	a3,4
    80002880:	02c48613          	addi	a2,s1,44
    80002884:	85da                	mv	a1,s6
    80002886:	05093503          	ld	a0,80(s2)
    8000288a:	8ceff0ef          	jal	80001958 <copyout>
    8000288e:	02054b63          	bltz	a0,800028c4 <kwait+0x92>
          freeproc(pp);
    80002892:	8526                	mv	a0,s1
    80002894:	e20ff0ef          	jal	80001eb4 <freeproc>
          release(&pp->lock);
    80002898:	8526                	mv	a0,s1
    8000289a:	dd8fe0ef          	jal	80000e72 <release>
          release(&wait_lock);
    8000289e:	0002e517          	auipc	a0,0x2e
    800028a2:	20a50513          	addi	a0,a0,522 # 80030aa8 <wait_lock>
    800028a6:	dccfe0ef          	jal	80000e72 <release>
}
    800028aa:	854e                	mv	a0,s3
    800028ac:	60a6                	ld	ra,72(sp)
    800028ae:	6406                	ld	s0,64(sp)
    800028b0:	74e2                	ld	s1,56(sp)
    800028b2:	7942                	ld	s2,48(sp)
    800028b4:	79a2                	ld	s3,40(sp)
    800028b6:	7a02                	ld	s4,32(sp)
    800028b8:	6ae2                	ld	s5,24(sp)
    800028ba:	6b42                	ld	s6,16(sp)
    800028bc:	6ba2                	ld	s7,8(sp)
    800028be:	6c02                	ld	s8,0(sp)
    800028c0:	6161                	addi	sp,sp,80
    800028c2:	8082                	ret
            release(&pp->lock);
    800028c4:	8526                	mv	a0,s1
    800028c6:	dacfe0ef          	jal	80000e72 <release>
            release(&wait_lock);
    800028ca:	0002e517          	auipc	a0,0x2e
    800028ce:	1de50513          	addi	a0,a0,478 # 80030aa8 <wait_lock>
    800028d2:	da0fe0ef          	jal	80000e72 <release>
            return -1;
    800028d6:	59fd                	li	s3,-1
    800028d8:	bfc9                	j	800028aa <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800028da:	18848493          	addi	s1,s1,392
    800028de:	03348063          	beq	s1,s3,800028fe <kwait+0xcc>
      if(pp->parent == p){
    800028e2:	7c9c                	ld	a5,56(s1)
    800028e4:	ff279be3          	bne	a5,s2,800028da <kwait+0xa8>
        acquire(&pp->lock);
    800028e8:	8526                	mv	a0,s1
    800028ea:	cf0fe0ef          	jal	80000dda <acquire>
        if(pp->state == ZOMBIE){
    800028ee:	4c9c                	lw	a5,24(s1)
    800028f0:	f94783e3          	beq	a5,s4,80002876 <kwait+0x44>
        release(&pp->lock);
    800028f4:	8526                	mv	a0,s1
    800028f6:	d7cfe0ef          	jal	80000e72 <release>
        havekids = 1;
    800028fa:	8756                	mv	a4,s5
    800028fc:	bff9                	j	800028da <kwait+0xa8>
    if(!havekids || killed(p)){
    800028fe:	cf19                	beqz	a4,8000291c <kwait+0xea>
    80002900:	854a                	mv	a0,s2
    80002902:	f07ff0ef          	jal	80002808 <killed>
    80002906:	e919                	bnez	a0,8000291c <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002908:	85e2                	mv	a1,s8
    8000290a:	854a                	mv	a0,s2
    8000290c:	c33ff0ef          	jal	8000253e <sleep>
    havekids = 0;
    80002910:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002912:	0002e497          	auipc	s1,0x2e
    80002916:	7ce48493          	addi	s1,s1,1998 # 800310e0 <proc>
    8000291a:	b7e1                	j	800028e2 <kwait+0xb0>
      release(&wait_lock);
    8000291c:	0002e517          	auipc	a0,0x2e
    80002920:	18c50513          	addi	a0,a0,396 # 80030aa8 <wait_lock>
    80002924:	d4efe0ef          	jal	80000e72 <release>
      return -1;
    80002928:	59fd                	li	s3,-1
    8000292a:	b741                	j	800028aa <kwait+0x78>

000000008000292c <either_copyout>:
{
    8000292c:	7179                	addi	sp,sp,-48
    8000292e:	f406                	sd	ra,40(sp)
    80002930:	f022                	sd	s0,32(sp)
    80002932:	ec26                	sd	s1,24(sp)
    80002934:	e84a                	sd	s2,16(sp)
    80002936:	e44e                	sd	s3,8(sp)
    80002938:	e052                	sd	s4,0(sp)
    8000293a:	1800                	addi	s0,sp,48
    8000293c:	84aa                	mv	s1,a0
    8000293e:	892e                	mv	s2,a1
    80002940:	89b2                	mv	s3,a2
    80002942:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002944:	c36ff0ef          	jal	80001d7a <myproc>
  if(user_dst){
    80002948:	cc99                	beqz	s1,80002966 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000294a:	86d2                	mv	a3,s4
    8000294c:	864e                	mv	a2,s3
    8000294e:	85ca                	mv	a1,s2
    80002950:	6928                	ld	a0,80(a0)
    80002952:	806ff0ef          	jal	80001958 <copyout>
}
    80002956:	70a2                	ld	ra,40(sp)
    80002958:	7402                	ld	s0,32(sp)
    8000295a:	64e2                	ld	s1,24(sp)
    8000295c:	6942                	ld	s2,16(sp)
    8000295e:	69a2                	ld	s3,8(sp)
    80002960:	6a02                	ld	s4,0(sp)
    80002962:	6145                	addi	sp,sp,48
    80002964:	8082                	ret
    memmove((char *)dst, src, len);
    80002966:	000a061b          	sext.w	a2,s4
    8000296a:	85ce                	mv	a1,s3
    8000296c:	854a                	mv	a0,s2
    8000296e:	d9cfe0ef          	jal	80000f0a <memmove>
    return 0;
    80002972:	8526                	mv	a0,s1
    80002974:	b7cd                	j	80002956 <either_copyout+0x2a>

0000000080002976 <either_copyin>:
{
    80002976:	7179                	addi	sp,sp,-48
    80002978:	f406                	sd	ra,40(sp)
    8000297a:	f022                	sd	s0,32(sp)
    8000297c:	ec26                	sd	s1,24(sp)
    8000297e:	e84a                	sd	s2,16(sp)
    80002980:	e44e                	sd	s3,8(sp)
    80002982:	e052                	sd	s4,0(sp)
    80002984:	1800                	addi	s0,sp,48
    80002986:	892a                	mv	s2,a0
    80002988:	84ae                	mv	s1,a1
    8000298a:	89b2                	mv	s3,a2
    8000298c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000298e:	becff0ef          	jal	80001d7a <myproc>
  if(user_src){
    80002992:	cc99                	beqz	s1,800029b0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002994:	86d2                	mv	a3,s4
    80002996:	864e                	mv	a2,s3
    80002998:	85ca                	mv	a1,s2
    8000299a:	6928                	ld	a0,80(a0)
    8000299c:	8d2ff0ef          	jal	80001a6e <copyin>
}
    800029a0:	70a2                	ld	ra,40(sp)
    800029a2:	7402                	ld	s0,32(sp)
    800029a4:	64e2                	ld	s1,24(sp)
    800029a6:	6942                	ld	s2,16(sp)
    800029a8:	69a2                	ld	s3,8(sp)
    800029aa:	6a02                	ld	s4,0(sp)
    800029ac:	6145                	addi	sp,sp,48
    800029ae:	8082                	ret
    memmove(dst, (char*)src, len);
    800029b0:	000a061b          	sext.w	a2,s4
    800029b4:	85ce                	mv	a1,s3
    800029b6:	854a                	mv	a0,s2
    800029b8:	d52fe0ef          	jal	80000f0a <memmove>
    return 0;
    800029bc:	8526                	mv	a0,s1
    800029be:	b7cd                	j	800029a0 <either_copyin+0x2a>

00000000800029c0 <procdump>:
{
    800029c0:	715d                	addi	sp,sp,-80
    800029c2:	e486                	sd	ra,72(sp)
    800029c4:	e0a2                	sd	s0,64(sp)
    800029c6:	fc26                	sd	s1,56(sp)
    800029c8:	f84a                	sd	s2,48(sp)
    800029ca:	f44e                	sd	s3,40(sp)
    800029cc:	f052                	sd	s4,32(sp)
    800029ce:	ec56                	sd	s5,24(sp)
    800029d0:	e85a                	sd	s6,16(sp)
    800029d2:	e45e                	sd	s7,8(sp)
    800029d4:	0880                	addi	s0,sp,80
  printf("\n");
    800029d6:	00005517          	auipc	a0,0x5
    800029da:	6ca50513          	addi	a0,a0,1738 # 800080a0 <etext+0xa0>
    800029de:	b1dfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029e2:	0002f497          	auipc	s1,0x2f
    800029e6:	85648493          	addi	s1,s1,-1962 # 80031238 <proc+0x158>
    800029ea:	00035917          	auipc	s2,0x35
    800029ee:	a4e90913          	addi	s2,s2,-1458 # 80037438 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029f2:	4b15                	li	s6,5
      state = "???";
    800029f4:	00006997          	auipc	s3,0x6
    800029f8:	84498993          	addi	s3,s3,-1980 # 80008238 <etext+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    800029fc:	00006a97          	auipc	s5,0x6
    80002a00:	844a8a93          	addi	s5,s5,-1980 # 80008240 <etext+0x240>
    printf("\n");
    80002a04:	00005a17          	auipc	s4,0x5
    80002a08:	69ca0a13          	addi	s4,s4,1692 # 800080a0 <etext+0xa0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a0c:	00006b97          	auipc	s7,0x6
    80002a10:	e04b8b93          	addi	s7,s7,-508 # 80008810 <states.0>
    80002a14:	a829                	j	80002a2e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002a16:	ed86a583          	lw	a1,-296(a3)
    80002a1a:	8556                	mv	a0,s5
    80002a1c:	adffd0ef          	jal	800004fa <printf>
    printf("\n");
    80002a20:	8552                	mv	a0,s4
    80002a22:	ad9fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a26:	18848493          	addi	s1,s1,392
    80002a2a:	03248263          	beq	s1,s2,80002a4e <procdump+0x8e>
    if(p->state == UNUSED)
    80002a2e:	86a6                	mv	a3,s1
    80002a30:	ec04a783          	lw	a5,-320(s1)
    80002a34:	dbed                	beqz	a5,80002a26 <procdump+0x66>
      state = "???";
    80002a36:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a38:	fcfb6fe3          	bltu	s6,a5,80002a16 <procdump+0x56>
    80002a3c:	02079713          	slli	a4,a5,0x20
    80002a40:	01d75793          	srli	a5,a4,0x1d
    80002a44:	97de                	add	a5,a5,s7
    80002a46:	6390                	ld	a2,0(a5)
    80002a48:	f679                	bnez	a2,80002a16 <procdump+0x56>
      state = "???";
    80002a4a:	864e                	mv	a2,s3
    80002a4c:	b7e9                	j	80002a16 <procdump+0x56>
}
    80002a4e:	60a6                	ld	ra,72(sp)
    80002a50:	6406                	ld	s0,64(sp)
    80002a52:	74e2                	ld	s1,56(sp)
    80002a54:	7942                	ld	s2,48(sp)
    80002a56:	79a2                	ld	s3,40(sp)
    80002a58:	7a02                	ld	s4,32(sp)
    80002a5a:	6ae2                	ld	s5,24(sp)
    80002a5c:	6b42                	ld	s6,16(sp)
    80002a5e:	6ba2                	ld	s7,8(sp)
    80002a60:	6161                	addi	sp,sp,80
    80002a62:	8082                	ret

0000000080002a64 <ptree>:

// System call implementation: build process tree rooted at given pid
int
ptree(int rootpid, struct proc_tree *tree)
{
    80002a64:	7179                	addi	sp,sp,-48
    80002a66:	f406                	sd	ra,40(sp)
    80002a68:	f022                	sd	s0,32(sp)
    80002a6a:	ec26                	sd	s1,24(sp)
    80002a6c:	e84a                	sd	s2,16(sp)
    80002a6e:	e44e                	sd	s3,8(sp)
    80002a70:	e052                	sd	s4,0(sp)
    80002a72:	1800                	addi	s0,sp,48
    80002a74:	892a                	mv	s2,a0
    80002a76:	8a2e                	mv	s4,a1
  struct proc *p;
  struct proc *root = 0;

  // Find the root process
  for (p = proc; p < &proc[NPROC]; p++) {
    80002a78:	0002e497          	auipc	s1,0x2e
    80002a7c:	66848493          	addi	s1,s1,1640 # 800310e0 <proc>
    80002a80:	00035997          	auipc	s3,0x35
    80002a84:	86098993          	addi	s3,s3,-1952 # 800372e0 <tickslock>
    80002a88:	a801                	j	80002a98 <ptree+0x34>
    if (p->pid == rootpid && p->state != UNUSED) {
      root = p;
      release(&p->lock);
      break;
    }
    release(&p->lock);
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	be6fe0ef          	jal	80000e72 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002a90:	18848493          	addi	s1,s1,392
    80002a94:	03348c63          	beq	s1,s3,80002acc <ptree+0x68>
    acquire(&p->lock);
    80002a98:	8526                	mv	a0,s1
    80002a9a:	b40fe0ef          	jal	80000dda <acquire>
    if (p->pid == rootpid && p->state != UNUSED) {
    80002a9e:	589c                	lw	a5,48(s1)
    80002aa0:	ff2795e3          	bne	a5,s2,80002a8a <ptree+0x26>
    80002aa4:	4c9c                	lw	a5,24(s1)
    80002aa6:	d3f5                	beqz	a5,80002a8a <ptree+0x26>
      release(&p->lock);
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	bc8fe0ef          	jal	80000e72 <release>
  if (!root) {
    return -1; // Process not found
  }

  // Initialize tree
  tree->count = 0;
    80002aae:	000a2023          	sw	zero,0(s4)

  // Build the tree recursively
  ptree_add_recursive(root, tree);
    80002ab2:	85d2                	mv	a1,s4
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	846ff0ef          	jal	80001afc <ptree_add_recursive>

  return 0; // Success
    80002aba:	4501                	li	a0,0
}
    80002abc:	70a2                	ld	ra,40(sp)
    80002abe:	7402                	ld	s0,32(sp)
    80002ac0:	64e2                	ld	s1,24(sp)
    80002ac2:	6942                	ld	s2,16(sp)
    80002ac4:	69a2                	ld	s3,8(sp)
    80002ac6:	6a02                	ld	s4,0(sp)
    80002ac8:	6145                	addi	sp,sp,48
    80002aca:	8082                	ret
    return -1; // Process not found
    80002acc:	557d                	li	a0,-1
    80002ace:	b7fd                	j	80002abc <ptree+0x58>

0000000080002ad0 <create_kernel_process>:

void
create_kernel_process(const char *name, void (*entrypoint)(void))
{
    80002ad0:	7179                	addi	sp,sp,-48
    80002ad2:	f406                	sd	ra,40(sp)
    80002ad4:	f022                	sd	s0,32(sp)
    80002ad6:	ec26                	sd	s1,24(sp)
    80002ad8:	e84a                	sd	s2,16(sp)
    80002ada:	e44e                	sd	s3,8(sp)
    80002adc:	1800                	addi	s0,sp,48
    80002ade:	892a                	mv	s2,a0
    80002ae0:	89ae                	mv	s3,a1
  struct proc *p = allocproc();
    80002ae2:	c2aff0ef          	jal	80001f0c <allocproc>
  if(p == 0)
    80002ae6:	c951                	beqz	a0,80002b7a <create_kernel_process+0xaa>
    80002ae8:	84aa                	mv	s1,a0
    panic("create_kernel_process: allocproc failed");

  // Mark as kernel process + store entrypoint
  p->is_kproc = 1;
    80002aea:	4785                	li	a5,1
    80002aec:	16f52c23          	sw	a5,376(a0)
  p->kentry = entrypoint;
    80002af0:	19353023          	sd	s3,384(a0)

  // Give it a name
  safestrcpy(p->name, name, sizeof(p->name));
    80002af4:	4641                	li	a2,16
    80002af6:	85ca                	mv	a1,s2
    80002af8:	15850513          	addi	a0,a0,344
    80002afc:	cf0fe0ef          	jal	80000fec <safestrcpy>

  // IMPORTANT: make it start in kernel at kproc_start, not forkret
  memset(&p->context, 0, sizeof(p->context));
    80002b00:	07000613          	li	a2,112
    80002b04:	4581                	li	a1,0
    80002b06:	06048513          	addi	a0,s1,96
    80002b0a:	ba4fe0ef          	jal	80000eae <memset>
  p->context.ra = (uint64)kproc_start;
    80002b0e:	00000797          	auipc	a5,0x0
    80002b12:	a0278793          	addi	a5,a5,-1534 # 80002510 <kproc_start>
    80002b16:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002b18:	60bc                	ld	a5,64(s1)
    80002b1a:	6705                	lui	a4,0x1
    80002b1c:	97ba                	add	a5,a5,a4
    80002b1e:	f4bc                	sd	a5,104(s1)

  // CFS fields: start at current minimum to avoid unfairness
  acquire(&runq_lock);
    80002b20:	0002e917          	auipc	s2,0x2e
    80002b24:	fa090913          	addi	s2,s2,-96 # 80030ac0 <runq_lock>
    80002b28:	854a                	mv	a0,s2
    80002b2a:	ab0fe0ef          	jal	80000dda <acquire>
  p->vruntime = min_vruntime;
    80002b2e:	00006797          	auipc	a5,0x6
    80002b32:	e327b783          	ld	a5,-462(a5) # 80008960 <min_vruntime>
    80002b36:	16f4b823          	sd	a5,368(s1)
  release(&runq_lock);
    80002b3a:	854a                	mv	a0,s2
    80002b3c:	b36fe0ef          	jal	80000e72 <release>
  p->weight = 1024;
    80002b40:	40000793          	li	a5,1024
    80002b44:	16f4a423          	sw	a5,360(s1)

  // Make runnable + insert into CFS runqueue (your scheduler uses heap)
  p->state = RUNNABLE;
    80002b48:	478d                	li	a5,3
    80002b4a:	cc9c                	sw	a5,24(s1)

  acquire(&runq_lock);
    80002b4c:	854a                	mv	a0,s2
    80002b4e:	a8cfe0ef          	jal	80000dda <acquire>
  minheap_insert(&run_queue, p);
    80002b52:	85a6                	mv	a1,s1
    80002b54:	0002e517          	auipc	a0,0x2e
    80002b58:	f8450513          	addi	a0,a0,-124 # 80030ad8 <run_queue>
    80002b5c:	057030ef          	jal	800063b2 <minheap_insert>
  release(&runq_lock);
    80002b60:	854a                	mv	a0,s2
    80002b62:	b10fe0ef          	jal	80000e72 <release>

  release(&p->lock);
    80002b66:	8526                	mv	a0,s1
    80002b68:	b0afe0ef          	jal	80000e72 <release>
}
    80002b6c:	70a2                	ld	ra,40(sp)
    80002b6e:	7402                	ld	s0,32(sp)
    80002b70:	64e2                	ld	s1,24(sp)
    80002b72:	6942                	ld	s2,16(sp)
    80002b74:	69a2                	ld	s3,8(sp)
    80002b76:	6145                	addi	sp,sp,48
    80002b78:	8082                	ret
    panic("create_kernel_process: allocproc failed");
    80002b7a:	00005517          	auipc	a0,0x5
    80002b7e:	6d650513          	addi	a0,a0,1750 # 80008250 <etext+0x250>
    80002b82:	c5ffd0ef          	jal	800007e0 <panic>

0000000080002b86 <forkret>:
{
    80002b86:	7179                	addi	sp,sp,-48
    80002b88:	f406                	sd	ra,40(sp)
    80002b8a:	f022                	sd	s0,32(sp)
    80002b8c:	ec26                	sd	s1,24(sp)
    80002b8e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002b90:	9eaff0ef          	jal	80001d7a <myproc>
    80002b94:	84aa                	mv	s1,a0
  release(&p->lock);
    80002b96:	adcfe0ef          	jal	80000e72 <release>
  if (first) {
    80002b9a:	00006797          	auipc	a5,0x6
    80002b9e:	d967a783          	lw	a5,-618(a5) # 80008930 <first.1>
    80002ba2:	c7b9                	beqz	a5,80002bf0 <forkret+0x6a>
    fsinit(ROOTDEV);
    80002ba4:	4505                	li	a0,1
    80002ba6:	352010ef          	jal	80003ef8 <fsinit>
    create_kernel_process("swapd", swapd);
    80002baa:	00000597          	auipc	a1,0x0
    80002bae:	94858593          	addi	a1,a1,-1720 # 800024f2 <swapd>
    80002bb2:	00005517          	auipc	a0,0x5
    80002bb6:	6c650513          	addi	a0,a0,1734 # 80008278 <etext+0x278>
    80002bba:	f17ff0ef          	jal	80002ad0 <create_kernel_process>
    first = 0;
    80002bbe:	00006797          	auipc	a5,0x6
    80002bc2:	d607a923          	sw	zero,-654(a5) # 80008930 <first.1>
    __sync_synchronize();
    80002bc6:	0ff0000f          	fence
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80002bca:	00005517          	auipc	a0,0x5
    80002bce:	6b650513          	addi	a0,a0,1718 # 80008280 <etext+0x280>
    80002bd2:	fca43823          	sd	a0,-48(s0)
    80002bd6:	fc043c23          	sd	zero,-40(s0)
    80002bda:	fd040593          	addi	a1,s0,-48
    80002bde:	424020ef          	jal	80005002 <kexec>
    80002be2:	6cbc                	ld	a5,88(s1)
    80002be4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80002be6:	6cbc                	ld	a5,88(s1)
    80002be8:	7bb8                	ld	a4,112(a5)
    80002bea:	57fd                	li	a5,-1
    80002bec:	02f70d63          	beq	a4,a5,80002c26 <forkret+0xa0>
  prepare_return();
    80002bf0:	0e8000ef          	jal	80002cd8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bf4:	68a8                	ld	a0,80(s1)
    80002bf6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002bf8:	04000737          	lui	a4,0x4000
    80002bfc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002bfe:	0732                	slli	a4,a4,0xc
    80002c00:	00004797          	auipc	a5,0x4
    80002c04:	49c78793          	addi	a5,a5,1180 # 8000709c <userret>
    80002c08:	00004697          	auipc	a3,0x4
    80002c0c:	3f868693          	addi	a3,a3,1016 # 80007000 <_trampoline>
    80002c10:	8f95                	sub	a5,a5,a3
    80002c12:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c14:	577d                	li	a4,-1
    80002c16:	177e                	slli	a4,a4,0x3f
    80002c18:	8d59                	or	a0,a0,a4
    80002c1a:	9782                	jalr	a5
}
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret
      panic("exec");
    80002c26:	00005517          	auipc	a0,0x5
    80002c2a:	66250513          	addi	a0,a0,1634 # 80008288 <etext+0x288>
    80002c2e:	bb3fd0ef          	jal	800007e0 <panic>

0000000080002c32 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002c32:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002c36:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002c3a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002c3c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002c3e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002c42:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002c46:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002c4a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002c4e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002c52:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002c56:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002c5a:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002c5e:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002c62:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002c66:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002c6a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002c6e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002c70:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002c72:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002c76:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002c7a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002c7e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002c82:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002c86:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002c8a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002c8e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002c92:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002c96:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002c9a:	8082                	ret

0000000080002c9c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002c9c:	1141                	addi	sp,sp,-16
    80002c9e:	e406                	sd	ra,8(sp)
    80002ca0:	e022                	sd	s0,0(sp)
    80002ca2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ca4:	00005597          	auipc	a1,0x5
    80002ca8:	61c58593          	addi	a1,a1,1564 # 800082c0 <etext+0x2c0>
    80002cac:	00034517          	auipc	a0,0x34
    80002cb0:	63450513          	addi	a0,a0,1588 # 800372e0 <tickslock>
    80002cb4:	8a6fe0ef          	jal	80000d5a <initlock>
}
    80002cb8:	60a2                	ld	ra,8(sp)
    80002cba:	6402                	ld	s0,0(sp)
    80002cbc:	0141                	addi	sp,sp,16
    80002cbe:	8082                	ret

0000000080002cc0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002cc0:	1141                	addi	sp,sp,-16
    80002cc2:	e422                	sd	s0,8(sp)
    80002cc4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cc6:	00003797          	auipc	a5,0x3
    80002cca:	0aa78793          	addi	a5,a5,170 # 80005d70 <kernelvec>
    80002cce:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cd2:	6422                	ld	s0,8(sp)
    80002cd4:	0141                	addi	sp,sp,16
    80002cd6:	8082                	ret

0000000080002cd8 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002cd8:	1141                	addi	sp,sp,-16
    80002cda:	e406                	sd	ra,8(sp)
    80002cdc:	e022                	sd	s0,0(sp)
    80002cde:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ce0:	89aff0ef          	jal	80001d7a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ce4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ce8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cea:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002cee:	04000737          	lui	a4,0x4000
    80002cf2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002cf4:	0732                	slli	a4,a4,0xc
    80002cf6:	00004797          	auipc	a5,0x4
    80002cfa:	30a78793          	addi	a5,a5,778 # 80007000 <_trampoline>
    80002cfe:	00004697          	auipc	a3,0x4
    80002d02:	30268693          	addi	a3,a3,770 # 80007000 <_trampoline>
    80002d06:	8f95                	sub	a5,a5,a3
    80002d08:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d0a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d0e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d10:	18002773          	csrr	a4,satp
    80002d14:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d16:	6d38                	ld	a4,88(a0)
    80002d18:	613c                	ld	a5,64(a0)
    80002d1a:	6685                	lui	a3,0x1
    80002d1c:	97b6                	add	a5,a5,a3
    80002d1e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d20:	6d3c                	ld	a5,88(a0)
    80002d22:	00000717          	auipc	a4,0x0
    80002d26:	0f870713          	addi	a4,a4,248 # 80002e1a <usertrap>
    80002d2a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002d2c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d2e:	8712                	mv	a4,tp
    80002d30:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d32:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d36:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d3a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d3e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d42:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d44:	6f9c                	ld	a5,24(a5)
    80002d46:	14179073          	csrw	sepc,a5
}
    80002d4a:	60a2                	ld	ra,8(sp)
    80002d4c:	6402                	ld	s0,0(sp)
    80002d4e:	0141                	addi	sp,sp,16
    80002d50:	8082                	ret

0000000080002d52 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002d52:	1101                	addi	sp,sp,-32
    80002d54:	ec06                	sd	ra,24(sp)
    80002d56:	e822                	sd	s0,16(sp)
    80002d58:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002d5a:	ff5fe0ef          	jal	80001d4e <cpuid>
    80002d5e:	cd11                	beqz	a0,80002d7a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002d60:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002d64:	000f4737          	lui	a4,0xf4
    80002d68:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002d6c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002d6e:	14d79073          	csrw	stimecmp,a5
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret
    80002d7a:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002d7c:	00034497          	auipc	s1,0x34
    80002d80:	56448493          	addi	s1,s1,1380 # 800372e0 <tickslock>
    80002d84:	8526                	mv	a0,s1
    80002d86:	854fe0ef          	jal	80000dda <acquire>
    ticks++;
    80002d8a:	00006517          	auipc	a0,0x6
    80002d8e:	be650513          	addi	a0,a0,-1050 # 80008970 <ticks>
    80002d92:	411c                	lw	a5,0(a0)
    80002d94:	2785                	addiw	a5,a5,1
    80002d96:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002d98:	ff2ff0ef          	jal	8000258a <wakeup>
    release(&tickslock);
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	8d4fe0ef          	jal	80000e72 <release>
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	bf75                	j	80002d60 <clockintr+0xe>

0000000080002da6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dae:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002db2:	57fd                	li	a5,-1
    80002db4:	17fe                	slli	a5,a5,0x3f
    80002db6:	07a5                	addi	a5,a5,9
    80002db8:	00f70c63          	beq	a4,a5,80002dd0 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002dbc:	57fd                	li	a5,-1
    80002dbe:	17fe                	slli	a5,a5,0x3f
    80002dc0:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002dc2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002dc4:	04f70763          	beq	a4,a5,80002e12 <devintr+0x6c>
  }
}
    80002dc8:	60e2                	ld	ra,24(sp)
    80002dca:	6442                	ld	s0,16(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret
    80002dd0:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002dd2:	04a030ef          	jal	80005e1c <plic_claim>
    80002dd6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002dd8:	47a9                	li	a5,10
    80002dda:	00f50963          	beq	a0,a5,80002dec <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002dde:	4785                	li	a5,1
    80002de0:	00f50963          	beq	a0,a5,80002df2 <devintr+0x4c>
    return 1;
    80002de4:	4505                	li	a0,1
    } else if(irq){
    80002de6:	e889                	bnez	s1,80002df8 <devintr+0x52>
    80002de8:	64a2                	ld	s1,8(sp)
    80002dea:	bff9                	j	80002dc8 <devintr+0x22>
      uartintr();
    80002dec:	bc5fd0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002df0:	a819                	j	80002e06 <devintr+0x60>
      virtio_disk_intr();
    80002df2:	4f0030ef          	jal	800062e2 <virtio_disk_intr>
    if(irq)
    80002df6:	a801                	j	80002e06 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002df8:	85a6                	mv	a1,s1
    80002dfa:	00005517          	auipc	a0,0x5
    80002dfe:	4ce50513          	addi	a0,a0,1230 # 800082c8 <etext+0x2c8>
    80002e02:	ef8fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002e06:	8526                	mv	a0,s1
    80002e08:	034030ef          	jal	80005e3c <plic_complete>
    return 1;
    80002e0c:	4505                	li	a0,1
    80002e0e:	64a2                	ld	s1,8(sp)
    80002e10:	bf65                	j	80002dc8 <devintr+0x22>
    clockintr();
    80002e12:	f41ff0ef          	jal	80002d52 <clockintr>
    return 2;
    80002e16:	4509                	li	a0,2
    80002e18:	bf45                	j	80002dc8 <devintr+0x22>

0000000080002e1a <usertrap>:
{
    80002e1a:	1101                	addi	sp,sp,-32
    80002e1c:	ec06                	sd	ra,24(sp)
    80002e1e:	e822                	sd	s0,16(sp)
    80002e20:	e426                	sd	s1,8(sp)
    80002e22:	e04a                	sd	s2,0(sp)
    80002e24:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e26:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002e2a:	1007f793          	andi	a5,a5,256
    80002e2e:	ebad                	bnez	a5,80002ea0 <usertrap+0x86>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e30:	00003797          	auipc	a5,0x3
    80002e34:	f4078793          	addi	a5,a5,-192 # 80005d70 <kernelvec>
    80002e38:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e3c:	f3ffe0ef          	jal	80001d7a <myproc>
    80002e40:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e42:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e44:	14102773          	csrr	a4,sepc
    80002e48:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e4a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002e4e:	47a1                	li	a5,8
    80002e50:	04f70e63          	beq	a4,a5,80002eac <usertrap+0x92>
  } else if((which_dev = devintr()) != 0){
    80002e54:	f53ff0ef          	jal	80002da6 <devintr>
    80002e58:	892a                	mv	s2,a0
    80002e5a:	10051863          	bnez	a0,80002f6a <usertrap+0x150>
    80002e5e:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15) {
    80002e62:	47bd                	li	a5,15
    80002e64:	08f70863          	beq	a4,a5,80002ef4 <usertrap+0xda>
    80002e68:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13 && vmfault(p->pagetable, r_stval(), 1) != 0) {
    80002e6c:	47b5                	li	a5,13
    80002e6e:	0ef70663          	beq	a4,a5,80002f5a <usertrap+0x140>
    80002e72:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002e76:	5890                	lw	a2,48(s1)
    80002e78:	00005517          	auipc	a0,0x5
    80002e7c:	50050513          	addi	a0,a0,1280 # 80008378 <etext+0x378>
    80002e80:	e7afd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e88:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	51c50513          	addi	a0,a0,1308 # 800083a8 <etext+0x3a8>
    80002e94:	e66fd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002e98:	8526                	mv	a0,s1
    80002e9a:	94bff0ef          	jal	800027e4 <setkilled>
    80002e9e:	a035                	j	80002eca <usertrap+0xb0>
    panic("usertrap: not from user mode");
    80002ea0:	00005517          	auipc	a0,0x5
    80002ea4:	44850513          	addi	a0,a0,1096 # 800082e8 <etext+0x2e8>
    80002ea8:	939fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002eac:	95dff0ef          	jal	80002808 <killed>
    80002eb0:	ed15                	bnez	a0,80002eec <usertrap+0xd2>
    p->trapframe->epc += 4;
    80002eb2:	6cb8                	ld	a4,88(s1)
    80002eb4:	6f1c                	ld	a5,24(a4)
    80002eb6:	0791                	addi	a5,a5,4
    80002eb8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ebe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ec2:	10079073          	csrw	sstatus,a5
    syscall();
    80002ec6:	2a4000ef          	jal	8000316a <syscall>
  if(killed(p))
    80002eca:	8526                	mv	a0,s1
    80002ecc:	93dff0ef          	jal	80002808 <killed>
    80002ed0:	e155                	bnez	a0,80002f74 <usertrap+0x15a>
  prepare_return();
    80002ed2:	e07ff0ef          	jal	80002cd8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ed6:	68a8                	ld	a0,80(s1)
    80002ed8:	8131                	srli	a0,a0,0xc
    80002eda:	57fd                	li	a5,-1
    80002edc:	17fe                	slli	a5,a5,0x3f
    80002ede:	8d5d                	or	a0,a0,a5
}
    80002ee0:	60e2                	ld	ra,24(sp)
    80002ee2:	6442                	ld	s0,16(sp)
    80002ee4:	64a2                	ld	s1,8(sp)
    80002ee6:	6902                	ld	s2,0(sp)
    80002ee8:	6105                	addi	sp,sp,32
    80002eea:	8082                	ret
      kexit(-1);
    80002eec:	557d                	li	a0,-1
    80002eee:	fb8ff0ef          	jal	800026a6 <kexit>
    80002ef2:	b7c1                	j	80002eb2 <usertrap+0x98>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ef4:	14302973          	csrr	s2,stval
    pte_t *pte = walk(p->pagetable, va, 0);
    80002ef8:	4601                	li	a2,0
    80002efa:	85ca                	mv	a1,s2
    80002efc:	68a8                	ld	a0,80(s1)
    80002efe:	a24fe0ef          	jal	80001122 <walk>
    if(pte != 0 && (*pte & PTE_V) && (*pte & PTE_COW)) {
    80002f02:	c901                	beqz	a0,80002f12 <usertrap+0xf8>
    80002f04:	611c                	ld	a5,0(a0)
    80002f06:	1017f793          	andi	a5,a5,257
    80002f0a:	10100713          	li	a4,257
    80002f0e:	02e78463          	beq	a5,a4,80002f36 <usertrap+0x11c>
    } else if(vmfault(p->pagetable, va, 0) == 0) {
    80002f12:	4601                	li	a2,0
    80002f14:	85ca                	mv	a1,s2
    80002f16:	68a8                	ld	a0,80(s1)
    80002f18:	9bffe0ef          	jal	800018d6 <vmfault>
    80002f1c:	f55d                	bnez	a0,80002eca <usertrap+0xb0>
      printf("usertrap(): page fault failed for va=0x%lx pid=%d\n", va, p->pid);
    80002f1e:	5890                	lw	a2,48(s1)
    80002f20:	85ca                	mv	a1,s2
    80002f22:	00005517          	auipc	a0,0x5
    80002f26:	41e50513          	addi	a0,a0,1054 # 80008340 <etext+0x340>
    80002f2a:	dd0fd0ef          	jal	800004fa <printf>
      setkilled(p);
    80002f2e:	8526                	mv	a0,s1
    80002f30:	8b5ff0ef          	jal	800027e4 <setkilled>
    80002f34:	bf59                	j	80002eca <usertrap+0xb0>
      if(cowfault(p->pagetable, va) < 0) {
    80002f36:	85ca                	mv	a1,s2
    80002f38:	68a8                	ld	a0,80(s1)
    80002f3a:	8c3fe0ef          	jal	800017fc <cowfault>
    80002f3e:	f80556e3          	bgez	a0,80002eca <usertrap+0xb0>
        printf("usertrap(): COW fault failed for va=0x%lx pid=%d\n", va, p->pid);
    80002f42:	5890                	lw	a2,48(s1)
    80002f44:	85ca                	mv	a1,s2
    80002f46:	00005517          	auipc	a0,0x5
    80002f4a:	3c250513          	addi	a0,a0,962 # 80008308 <etext+0x308>
    80002f4e:	dacfd0ef          	jal	800004fa <printf>
        setkilled(p);
    80002f52:	8526                	mv	a0,s1
    80002f54:	891ff0ef          	jal	800027e4 <setkilled>
    80002f58:	bf8d                	j	80002eca <usertrap+0xb0>
    80002f5a:	143025f3          	csrr	a1,stval
  } else if(r_scause() == 13 && vmfault(p->pagetable, r_stval(), 1) != 0) {
    80002f5e:	4605                	li	a2,1
    80002f60:	68a8                	ld	a0,80(s1)
    80002f62:	975fe0ef          	jal	800018d6 <vmfault>
    80002f66:	f135                	bnez	a0,80002eca <usertrap+0xb0>
    80002f68:	b729                	j	80002e72 <usertrap+0x58>
  if(killed(p))
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	89dff0ef          	jal	80002808 <killed>
    80002f70:	c511                	beqz	a0,80002f7c <usertrap+0x162>
    80002f72:	a011                	j	80002f76 <usertrap+0x15c>
    80002f74:	4901                	li	s2,0
    kexit(-1);
    80002f76:	557d                	li	a0,-1
    80002f78:	f2eff0ef          	jal	800026a6 <kexit>
  if(which_dev == 2)
    80002f7c:	4789                	li	a5,2
    80002f7e:	f4f91ae3          	bne	s2,a5,80002ed2 <usertrap+0xb8>
    yield();
    80002f82:	cdeff0ef          	jal	80002460 <yield>
    80002f86:	b7b1                	j	80002ed2 <usertrap+0xb8>

0000000080002f88 <kerneltrap>:
{
    80002f88:	7179                	addi	sp,sp,-48
    80002f8a:	f406                	sd	ra,40(sp)
    80002f8c:	f022                	sd	s0,32(sp)
    80002f8e:	ec26                	sd	s1,24(sp)
    80002f90:	e84a                	sd	s2,16(sp)
    80002f92:	e44e                	sd	s3,8(sp)
    80002f94:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f96:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f9a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f9e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002fa2:	1004f793          	andi	a5,s1,256
    80002fa6:	c795                	beqz	a5,80002fd2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fa8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fac:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002fae:	eb85                	bnez	a5,80002fde <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002fb0:	df7ff0ef          	jal	80002da6 <devintr>
    80002fb4:	c91d                	beqz	a0,80002fea <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002fb6:	4789                	li	a5,2
    80002fb8:	04f50a63          	beq	a0,a5,8000300c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fbc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fc0:	10049073          	csrw	sstatus,s1
}
    80002fc4:	70a2                	ld	ra,40(sp)
    80002fc6:	7402                	ld	s0,32(sp)
    80002fc8:	64e2                	ld	s1,24(sp)
    80002fca:	6942                	ld	s2,16(sp)
    80002fcc:	69a2                	ld	s3,8(sp)
    80002fce:	6145                	addi	sp,sp,48
    80002fd0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002fd2:	00005517          	auipc	a0,0x5
    80002fd6:	3fe50513          	addi	a0,a0,1022 # 800083d0 <etext+0x3d0>
    80002fda:	807fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	41a50513          	addi	a0,a0,1050 # 800083f8 <etext+0x3f8>
    80002fe6:	ffafd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fea:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fee:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002ff2:	85ce                	mv	a1,s3
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	42450513          	addi	a0,a0,1060 # 80008418 <etext+0x418>
    80002ffc:	cfefd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003000:	00005517          	auipc	a0,0x5
    80003004:	44050513          	addi	a0,a0,1088 # 80008440 <etext+0x440>
    80003008:	fd8fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000300c:	d6ffe0ef          	jal	80001d7a <myproc>
    80003010:	d555                	beqz	a0,80002fbc <kerneltrap+0x34>
    yield();
    80003012:	c4eff0ef          	jal	80002460 <yield>
    80003016:	b75d                	j	80002fbc <kerneltrap+0x34>

0000000080003018 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003018:	1101                	addi	sp,sp,-32
    8000301a:	ec06                	sd	ra,24(sp)
    8000301c:	e822                	sd	s0,16(sp)
    8000301e:	e426                	sd	s1,8(sp)
    80003020:	1000                	addi	s0,sp,32
    80003022:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003024:	d57fe0ef          	jal	80001d7a <myproc>
  switch (n) {
    80003028:	4795                	li	a5,5
    8000302a:	0497e163          	bltu	a5,s1,8000306c <argraw+0x54>
    8000302e:	048a                	slli	s1,s1,0x2
    80003030:	00006717          	auipc	a4,0x6
    80003034:	81070713          	addi	a4,a4,-2032 # 80008840 <states.0+0x30>
    80003038:	94ba                	add	s1,s1,a4
    8000303a:	409c                	lw	a5,0(s1)
    8000303c:	97ba                	add	a5,a5,a4
    8000303e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003040:	6d3c                	ld	a5,88(a0)
    80003042:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003044:	60e2                	ld	ra,24(sp)
    80003046:	6442                	ld	s0,16(sp)
    80003048:	64a2                	ld	s1,8(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret
    return p->trapframe->a1;
    8000304e:	6d3c                	ld	a5,88(a0)
    80003050:	7fa8                	ld	a0,120(a5)
    80003052:	bfcd                	j	80003044 <argraw+0x2c>
    return p->trapframe->a2;
    80003054:	6d3c                	ld	a5,88(a0)
    80003056:	63c8                	ld	a0,128(a5)
    80003058:	b7f5                	j	80003044 <argraw+0x2c>
    return p->trapframe->a3;
    8000305a:	6d3c                	ld	a5,88(a0)
    8000305c:	67c8                	ld	a0,136(a5)
    8000305e:	b7dd                	j	80003044 <argraw+0x2c>
    return p->trapframe->a4;
    80003060:	6d3c                	ld	a5,88(a0)
    80003062:	6bc8                	ld	a0,144(a5)
    80003064:	b7c5                	j	80003044 <argraw+0x2c>
    return p->trapframe->a5;
    80003066:	6d3c                	ld	a5,88(a0)
    80003068:	6fc8                	ld	a0,152(a5)
    8000306a:	bfe9                	j	80003044 <argraw+0x2c>
  panic("argraw");
    8000306c:	00005517          	auipc	a0,0x5
    80003070:	3e450513          	addi	a0,a0,996 # 80008450 <etext+0x450>
    80003074:	f6cfd0ef          	jal	800007e0 <panic>

0000000080003078 <fetchaddr>:
{
    80003078:	1101                	addi	sp,sp,-32
    8000307a:	ec06                	sd	ra,24(sp)
    8000307c:	e822                	sd	s0,16(sp)
    8000307e:	e426                	sd	s1,8(sp)
    80003080:	e04a                	sd	s2,0(sp)
    80003082:	1000                	addi	s0,sp,32
    80003084:	84aa                	mv	s1,a0
    80003086:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003088:	cf3fe0ef          	jal	80001d7a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000308c:	653c                	ld	a5,72(a0)
    8000308e:	02f4f663          	bgeu	s1,a5,800030ba <fetchaddr+0x42>
    80003092:	00848713          	addi	a4,s1,8
    80003096:	02e7e463          	bltu	a5,a4,800030be <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000309a:	46a1                	li	a3,8
    8000309c:	8626                	mv	a2,s1
    8000309e:	85ca                	mv	a1,s2
    800030a0:	6928                	ld	a0,80(a0)
    800030a2:	9cdfe0ef          	jal	80001a6e <copyin>
    800030a6:	00a03533          	snez	a0,a0
    800030aa:	40a00533          	neg	a0,a0
}
    800030ae:	60e2                	ld	ra,24(sp)
    800030b0:	6442                	ld	s0,16(sp)
    800030b2:	64a2                	ld	s1,8(sp)
    800030b4:	6902                	ld	s2,0(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    return -1;
    800030ba:	557d                	li	a0,-1
    800030bc:	bfcd                	j	800030ae <fetchaddr+0x36>
    800030be:	557d                	li	a0,-1
    800030c0:	b7fd                	j	800030ae <fetchaddr+0x36>

00000000800030c2 <fetchstr>:
{
    800030c2:	7179                	addi	sp,sp,-48
    800030c4:	f406                	sd	ra,40(sp)
    800030c6:	f022                	sd	s0,32(sp)
    800030c8:	ec26                	sd	s1,24(sp)
    800030ca:	e84a                	sd	s2,16(sp)
    800030cc:	e44e                	sd	s3,8(sp)
    800030ce:	1800                	addi	s0,sp,48
    800030d0:	892a                	mv	s2,a0
    800030d2:	84ae                	mv	s1,a1
    800030d4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030d6:	ca5fe0ef          	jal	80001d7a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800030da:	86ce                	mv	a3,s3
    800030dc:	864a                	mv	a2,s2
    800030de:	85a6                	mv	a1,s1
    800030e0:	6928                	ld	a0,80(a0)
    800030e2:	e62fe0ef          	jal	80001744 <copyinstr>
    800030e6:	00054c63          	bltz	a0,800030fe <fetchstr+0x3c>
  return strlen(buf);
    800030ea:	8526                	mv	a0,s1
    800030ec:	f33fd0ef          	jal	8000101e <strlen>
}
    800030f0:	70a2                	ld	ra,40(sp)
    800030f2:	7402                	ld	s0,32(sp)
    800030f4:	64e2                	ld	s1,24(sp)
    800030f6:	6942                	ld	s2,16(sp)
    800030f8:	69a2                	ld	s3,8(sp)
    800030fa:	6145                	addi	sp,sp,48
    800030fc:	8082                	ret
    return -1;
    800030fe:	557d                	li	a0,-1
    80003100:	bfc5                	j	800030f0 <fetchstr+0x2e>

0000000080003102 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003102:	1101                	addi	sp,sp,-32
    80003104:	ec06                	sd	ra,24(sp)
    80003106:	e822                	sd	s0,16(sp)
    80003108:	e426                	sd	s1,8(sp)
    8000310a:	1000                	addi	s0,sp,32
    8000310c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000310e:	f0bff0ef          	jal	80003018 <argraw>
    80003112:	c088                	sw	a0,0(s1)
}
    80003114:	60e2                	ld	ra,24(sp)
    80003116:	6442                	ld	s0,16(sp)
    80003118:	64a2                	ld	s1,8(sp)
    8000311a:	6105                	addi	sp,sp,32
    8000311c:	8082                	ret

000000008000311e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	1000                	addi	s0,sp,32
    80003128:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000312a:	eefff0ef          	jal	80003018 <argraw>
    8000312e:	e088                	sd	a0,0(s1)
}
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret

000000008000313a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000313a:	7179                	addi	sp,sp,-48
    8000313c:	f406                	sd	ra,40(sp)
    8000313e:	f022                	sd	s0,32(sp)
    80003140:	ec26                	sd	s1,24(sp)
    80003142:	e84a                	sd	s2,16(sp)
    80003144:	1800                	addi	s0,sp,48
    80003146:	84ae                	mv	s1,a1
    80003148:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000314a:	fd840593          	addi	a1,s0,-40
    8000314e:	fd1ff0ef          	jal	8000311e <argaddr>
  return fetchstr(addr, buf, max);
    80003152:	864a                	mv	a2,s2
    80003154:	85a6                	mv	a1,s1
    80003156:	fd843503          	ld	a0,-40(s0)
    8000315a:	f69ff0ef          	jal	800030c2 <fetchstr>
}
    8000315e:	70a2                	ld	ra,40(sp)
    80003160:	7402                	ld	s0,32(sp)
    80003162:	64e2                	ld	s1,24(sp)
    80003164:	6942                	ld	s2,16(sp)
    80003166:	6145                	addi	sp,sp,48
    80003168:	8082                	ret

000000008000316a <syscall>:

uint sysclcnt = 0;

void
syscall(void)
{
    8000316a:	1101                	addi	sp,sp,-32
    8000316c:	ec06                	sd	ra,24(sp)
    8000316e:	e822                	sd	s0,16(sp)
    80003170:	e426                	sd	s1,8(sp)
    80003172:	e04a                	sd	s2,0(sp)
    80003174:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003176:	c05fe0ef          	jal	80001d7a <myproc>
    8000317a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000317c:	05853903          	ld	s2,88(a0)
    80003180:	0a893783          	ld	a5,168(s2)
    80003184:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003188:	37fd                	addiw	a5,a5,-1
    8000318a:	4761                	li	a4,24
    8000318c:	02f76663          	bltu	a4,a5,800031b8 <syscall+0x4e>
    80003190:	00369713          	slli	a4,a3,0x3
    80003194:	00005797          	auipc	a5,0x5
    80003198:	6c478793          	addi	a5,a5,1732 # 80008858 <syscalls>
    8000319c:	97ba                	add	a5,a5,a4
    8000319e:	6398                	ld	a4,0(a5)
    800031a0:	cf01                	beqz	a4,800031b8 <syscall+0x4e>
    sysclcnt++;
    800031a2:	00005697          	auipc	a3,0x5
    800031a6:	7d268693          	addi	a3,a3,2002 # 80008974 <sysclcnt>
    800031aa:	429c                	lw	a5,0(a3)
    800031ac:	2785                	addiw	a5,a5,1
    800031ae:	c29c                	sw	a5,0(a3)
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800031b0:	9702                	jalr	a4
    800031b2:	06a93823          	sd	a0,112(s2)
    800031b6:	a829                	j	800031d0 <syscall+0x66>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800031b8:	15848613          	addi	a2,s1,344
    800031bc:	588c                	lw	a1,48(s1)
    800031be:	00005517          	auipc	a0,0x5
    800031c2:	29a50513          	addi	a0,a0,666 # 80008458 <etext+0x458>
    800031c6:	b34fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800031ca:	6cbc                	ld	a5,88(s1)
    800031cc:	577d                	li	a4,-1
    800031ce:	fbb8                	sd	a4,112(a5)
  }
}
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6902                	ld	s2,0(sp)
    800031d8:	6105                	addi	sp,sp,32
    800031da:	8082                	ret

00000000800031dc <sys_exit>:
// Forward declaration
int ptree(int pid, struct proc_tree *tree);

uint64
sys_exit(void)
{
    800031dc:	1101                	addi	sp,sp,-32
    800031de:	ec06                	sd	ra,24(sp)
    800031e0:	e822                	sd	s0,16(sp)
    800031e2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800031e4:	fec40593          	addi	a1,s0,-20
    800031e8:	4501                	li	a0,0
    800031ea:	f19ff0ef          	jal	80003102 <argint>
  kexit(n);
    800031ee:	fec42503          	lw	a0,-20(s0)
    800031f2:	cb4ff0ef          	jal	800026a6 <kexit>
  return 0;  // not reached
}
    800031f6:	4501                	li	a0,0
    800031f8:	60e2                	ld	ra,24(sp)
    800031fa:	6442                	ld	s0,16(sp)
    800031fc:	6105                	addi	sp,sp,32
    800031fe:	8082                	ret

0000000080003200 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003200:	1141                	addi	sp,sp,-16
    80003202:	e406                	sd	ra,8(sp)
    80003204:	e022                	sd	s0,0(sp)
    80003206:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003208:	b73fe0ef          	jal	80001d7a <myproc>
}
    8000320c:	5908                	lw	a0,48(a0)
    8000320e:	60a2                	ld	ra,8(sp)
    80003210:	6402                	ld	s0,0(sp)
    80003212:	0141                	addi	sp,sp,16
    80003214:	8082                	ret

0000000080003216 <sys_fork>:

uint64
sys_fork(void)
{
    80003216:	1141                	addi	sp,sp,-16
    80003218:	e406                	sd	ra,8(sp)
    8000321a:	e022                	sd	s0,0(sp)
    8000321c:	0800                	addi	s0,sp,16
  return kfork();
    8000321e:	e75fe0ef          	jal	80002092 <kfork>
}
    80003222:	60a2                	ld	ra,8(sp)
    80003224:	6402                	ld	s0,0(sp)
    80003226:	0141                	addi	sp,sp,16
    80003228:	8082                	ret

000000008000322a <sys_wait>:

uint64
sys_wait(void)
{
    8000322a:	1101                	addi	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003232:	fe840593          	addi	a1,s0,-24
    80003236:	4501                	li	a0,0
    80003238:	ee7ff0ef          	jal	8000311e <argaddr>
  return kwait(p);
    8000323c:	fe843503          	ld	a0,-24(s0)
    80003240:	df2ff0ef          	jal	80002832 <kwait>
}
    80003244:	60e2                	ld	ra,24(sp)
    80003246:	6442                	ld	s0,16(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000324c:	7179                	addi	sp,sp,-48
    8000324e:	f406                	sd	ra,40(sp)
    80003250:	f022                	sd	s0,32(sp)
    80003252:	ec26                	sd	s1,24(sp)
    80003254:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80003256:	fd840593          	addi	a1,s0,-40
    8000325a:	4501                	li	a0,0
    8000325c:	ea7ff0ef          	jal	80003102 <argint>
  argint(1, &t);
    80003260:	fdc40593          	addi	a1,s0,-36
    80003264:	4505                	li	a0,1
    80003266:	e9dff0ef          	jal	80003102 <argint>
  addr = myproc()->sz;
    8000326a:	b11fe0ef          	jal	80001d7a <myproc>
    8000326e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80003270:	fdc42703          	lw	a4,-36(s0)
    80003274:	4785                	li	a5,1
    80003276:	02f70763          	beq	a4,a5,800032a4 <sys_sbrk+0x58>
    8000327a:	fd842783          	lw	a5,-40(s0)
    8000327e:	0207c363          	bltz	a5,800032a4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80003282:	97a6                	add	a5,a5,s1
    80003284:	0297ee63          	bltu	a5,s1,800032c0 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80003288:	02000737          	lui	a4,0x2000
    8000328c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    8000328e:	0736                	slli	a4,a4,0xd
    80003290:	02f76a63          	bltu	a4,a5,800032c4 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80003294:	ae7fe0ef          	jal	80001d7a <myproc>
    80003298:	fd842703          	lw	a4,-40(s0)
    8000329c:	653c                	ld	a5,72(a0)
    8000329e:	97ba                	add	a5,a5,a4
    800032a0:	e53c                	sd	a5,72(a0)
    800032a2:	a039                	j	800032b0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800032a4:	fd842503          	lw	a0,-40(s0)
    800032a8:	d89fe0ef          	jal	80002030 <growproc>
    800032ac:	00054863          	bltz	a0,800032bc <sys_sbrk+0x70>
  }
  return addr;
}
    800032b0:	8526                	mv	a0,s1
    800032b2:	70a2                	ld	ra,40(sp)
    800032b4:	7402                	ld	s0,32(sp)
    800032b6:	64e2                	ld	s1,24(sp)
    800032b8:	6145                	addi	sp,sp,48
    800032ba:	8082                	ret
      return -1;
    800032bc:	54fd                	li	s1,-1
    800032be:	bfcd                	j	800032b0 <sys_sbrk+0x64>
      return -1;
    800032c0:	54fd                	li	s1,-1
    800032c2:	b7fd                	j	800032b0 <sys_sbrk+0x64>
      return -1;
    800032c4:	54fd                	li	s1,-1
    800032c6:	b7ed                	j	800032b0 <sys_sbrk+0x64>

00000000800032c8 <sys_pause>:

uint64
sys_pause(void)
{
    800032c8:	7139                	addi	sp,sp,-64
    800032ca:	fc06                	sd	ra,56(sp)
    800032cc:	f822                	sd	s0,48(sp)
    800032ce:	f04a                	sd	s2,32(sp)
    800032d0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800032d2:	fcc40593          	addi	a1,s0,-52
    800032d6:	4501                	li	a0,0
    800032d8:	e2bff0ef          	jal	80003102 <argint>
  if(n < 0)
    800032dc:	fcc42783          	lw	a5,-52(s0)
    800032e0:	0607c763          	bltz	a5,8000334e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800032e4:	00034517          	auipc	a0,0x34
    800032e8:	ffc50513          	addi	a0,a0,-4 # 800372e0 <tickslock>
    800032ec:	aeffd0ef          	jal	80000dda <acquire>
  ticks0 = ticks;
    800032f0:	00005917          	auipc	s2,0x5
    800032f4:	68092903          	lw	s2,1664(s2) # 80008970 <ticks>
  while(ticks - ticks0 < n){
    800032f8:	fcc42783          	lw	a5,-52(s0)
    800032fc:	cf8d                	beqz	a5,80003336 <sys_pause+0x6e>
    800032fe:	f426                	sd	s1,40(sp)
    80003300:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003302:	00034997          	auipc	s3,0x34
    80003306:	fde98993          	addi	s3,s3,-34 # 800372e0 <tickslock>
    8000330a:	00005497          	auipc	s1,0x5
    8000330e:	66648493          	addi	s1,s1,1638 # 80008970 <ticks>
    if(killed(myproc())){
    80003312:	a69fe0ef          	jal	80001d7a <myproc>
    80003316:	cf2ff0ef          	jal	80002808 <killed>
    8000331a:	ed0d                	bnez	a0,80003354 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000331c:	85ce                	mv	a1,s3
    8000331e:	8526                	mv	a0,s1
    80003320:	a1eff0ef          	jal	8000253e <sleep>
  while(ticks - ticks0 < n){
    80003324:	409c                	lw	a5,0(s1)
    80003326:	412787bb          	subw	a5,a5,s2
    8000332a:	fcc42703          	lw	a4,-52(s0)
    8000332e:	fee7e2e3          	bltu	a5,a4,80003312 <sys_pause+0x4a>
    80003332:	74a2                	ld	s1,40(sp)
    80003334:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003336:	00034517          	auipc	a0,0x34
    8000333a:	faa50513          	addi	a0,a0,-86 # 800372e0 <tickslock>
    8000333e:	b35fd0ef          	jal	80000e72 <release>
  return 0;
    80003342:	4501                	li	a0,0
}
    80003344:	70e2                	ld	ra,56(sp)
    80003346:	7442                	ld	s0,48(sp)
    80003348:	7902                	ld	s2,32(sp)
    8000334a:	6121                	addi	sp,sp,64
    8000334c:	8082                	ret
    n = 0;
    8000334e:	fc042623          	sw	zero,-52(s0)
    80003352:	bf49                	j	800032e4 <sys_pause+0x1c>
      release(&tickslock);
    80003354:	00034517          	auipc	a0,0x34
    80003358:	f8c50513          	addi	a0,a0,-116 # 800372e0 <tickslock>
    8000335c:	b17fd0ef          	jal	80000e72 <release>
      return -1;
    80003360:	557d                	li	a0,-1
    80003362:	74a2                	ld	s1,40(sp)
    80003364:	69e2                	ld	s3,24(sp)
    80003366:	bff9                	j	80003344 <sys_pause+0x7c>

0000000080003368 <sys_kill>:

uint64
sys_kill(void)
{
    80003368:	1101                	addi	sp,sp,-32
    8000336a:	ec06                	sd	ra,24(sp)
    8000336c:	e822                	sd	s0,16(sp)
    8000336e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003370:	fec40593          	addi	a1,s0,-20
    80003374:	4501                	li	a0,0
    80003376:	d8dff0ef          	jal	80003102 <argint>
  return kkill(pid);
    8000337a:	fec42503          	lw	a0,-20(s0)
    8000337e:	bcaff0ef          	jal	80002748 <kkill>
}
    80003382:	60e2                	ld	ra,24(sp)
    80003384:	6442                	ld	s0,16(sp)
    80003386:	6105                	addi	sp,sp,32
    80003388:	8082                	ret

000000008000338a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003394:	00034517          	auipc	a0,0x34
    80003398:	f4c50513          	addi	a0,a0,-180 # 800372e0 <tickslock>
    8000339c:	a3ffd0ef          	jal	80000dda <acquire>
  xticks = ticks;
    800033a0:	00005497          	auipc	s1,0x5
    800033a4:	5d04a483          	lw	s1,1488(s1) # 80008970 <ticks>
  release(&tickslock);
    800033a8:	00034517          	auipc	a0,0x34
    800033ac:	f3850513          	addi	a0,a0,-200 # 800372e0 <tickslock>
    800033b0:	ac3fd0ef          	jal	80000e72 <release>
  return xticks;
}
    800033b4:	02049513          	slli	a0,s1,0x20
    800033b8:	9101                	srli	a0,a0,0x20
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	64a2                	ld	s1,8(sp)
    800033c0:	6105                	addi	sp,sp,32
    800033c2:	8082                	ret

00000000800033c4 <sys_clcnt>:

uint64
sys_clcnt(void)
{
    800033c4:	1141                	addi	sp,sp,-16
    800033c6:	e422                	sd	s0,8(sp)
    800033c8:	0800                	addi	s0,sp,16
  extern uint sysclcnt;
  return sysclcnt;
}
    800033ca:	00005517          	auipc	a0,0x5
    800033ce:	5aa56503          	lwu	a0,1450(a0) # 80008974 <sysclcnt>
    800033d2:	6422                	ld	s0,8(sp)
    800033d4:	0141                	addi	sp,sp,16
    800033d6:	8082                	ret

00000000800033d8 <sys_ptree>:

uint64
sys_ptree(void)
{
    800033d8:	8c010113          	addi	sp,sp,-1856
    800033dc:	72113c23          	sd	ra,1848(sp)
    800033e0:	72813823          	sd	s0,1840(sp)
    800033e4:	72913423          	sd	s1,1832(sp)
    800033e8:	74010413          	addi	s0,sp,1856
  int pid;
  uint64 tree_addr;
  struct proc_tree tree;
  struct proc *p = myproc();
    800033ec:	98ffe0ef          	jal	80001d7a <myproc>
    800033f0:	84aa                	mv	s1,a0

  argint(0, &pid);
    800033f2:	fdc40593          	addi	a1,s0,-36
    800033f6:	4501                	li	a0,0
    800033f8:	d0bff0ef          	jal	80003102 <argint>
  argaddr(1, &tree_addr);
    800033fc:	fd040593          	addi	a1,s0,-48
    80003400:	4505                	li	a0,1
    80003402:	d1dff0ef          	jal	8000311e <argaddr>

  // Call the kernel ptree function
  int result = ptree(pid, &tree);
    80003406:	8c840593          	addi	a1,s0,-1848
    8000340a:	fdc42503          	lw	a0,-36(s0)
    8000340e:	e56ff0ef          	jal	80002a64 <ptree>
  
  if (result < 0) {
    return -1;
    80003412:	57fd                	li	a5,-1
  if (result < 0) {
    80003414:	00054d63          	bltz	a0,8000342e <sys_ptree+0x56>
  }

  // Copy the result to user space
  if (copyout(p->pagetable, tree_addr, (char *)&tree, sizeof(tree)) < 0) {
    80003418:	70400693          	li	a3,1796
    8000341c:	8c840613          	addi	a2,s0,-1848
    80003420:	fd043583          	ld	a1,-48(s0)
    80003424:	68a8                	ld	a0,80(s1)
    80003426:	d32fe0ef          	jal	80001958 <copyout>
    8000342a:	43f55793          	srai	a5,a0,0x3f
    return -1;
  }

  return 0;
}
    8000342e:	853e                	mv	a0,a5
    80003430:	73813083          	ld	ra,1848(sp)
    80003434:	73013403          	ld	s0,1840(sp)
    80003438:	72813483          	ld	s1,1832(sp)
    8000343c:	74010113          	addi	sp,sp,1856
    80003440:	8082                	ret

0000000080003442 <sys_cowfork>:

// COW fork system call
uint64
sys_cowfork(void)
{
    80003442:	1141                	addi	sp,sp,-16
    80003444:	e406                	sd	ra,8(sp)
    80003446:	e022                	sd	s0,0(sp)
    80003448:	0800                	addi	s0,sp,16
  return kcowfork();
    8000344a:	d79fe0ef          	jal	800021c2 <kcowfork>
}
    8000344e:	60a2                	ld	ra,8(sp)
    80003450:	6402                	ld	s0,0(sp)
    80003452:	0141                	addi	sp,sp,16
    80003454:	8082                	ret

0000000080003456 <sys_physaddr>:

// physaddr system call - returns the physical page number for a virtual address
// If no argument, uses the process's stack pointer area
uint64
sys_physaddr(void)
{
    80003456:	7179                	addi	sp,sp,-48
    80003458:	f406                	sd	ra,40(sp)
    8000345a:	f022                	sd	s0,32(sp)
    8000345c:	ec26                	sd	s1,24(sp)
    8000345e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80003460:	91bfe0ef          	jal	80001d7a <myproc>
    80003464:	84aa                	mv	s1,a0
  uint64 va;
  pte_t *pte;
  uint64 pa;

  // Get virtual address from argument (if provided)
  argaddr(0, &va);
    80003466:	fd840593          	addi	a1,s0,-40
    8000346a:	4501                	li	a0,0
    8000346c:	cb3ff0ef          	jal	8000311e <argaddr>
  
  // If va is 0, use the stack pointer
  if(va == 0)
    80003470:	fd843783          	ld	a5,-40(s0)
    80003474:	e789                	bnez	a5,8000347e <sys_physaddr+0x28>
    va = p->trapframe->sp;
    80003476:	6cbc                	ld	a5,88(s1)
    80003478:	7b9c                	ld	a5,48(a5)
    8000347a:	fcf43c23          	sd	a5,-40(s0)
  
  va = PGROUNDDOWN(va);
    8000347e:	75fd                	lui	a1,0xfffff
    80003480:	fd843783          	ld	a5,-40(s0)
    80003484:	8dfd                	and	a1,a1,a5
    80003486:	fcb43c23          	sd	a1,-40(s0)
  
  pte = walk(p->pagetable, va, 0);
    8000348a:	4601                	li	a2,0
    8000348c:	68a8                	ld	a0,80(s1)
    8000348e:	c95fd0ef          	jal	80001122 <walk>
  if(pte == 0 || (*pte & PTE_V) == 0)
    80003492:	cd11                	beqz	a0,800034ae <sys_physaddr+0x58>
    80003494:	611c                	ld	a5,0(a0)
    80003496:	0017f713          	andi	a4,a5,1
    return -1;
    8000349a:	557d                	li	a0,-1
  if(pte == 0 || (*pte & PTE_V) == 0)
    8000349c:	c701                	beqz	a4,800034a4 <sys_physaddr+0x4e>
  
  pa = PTE2PA(*pte);
    8000349e:	078a                	slli	a5,a5,0x2
  // Return page number (physical address divided by page size)
  return pa / PGSIZE;
    800034a0:	00c7d513          	srli	a0,a5,0xc
    800034a4:	70a2                	ld	ra,40(sp)
    800034a6:	7402                	ld	s0,32(sp)
    800034a8:	64e2                	ld	s1,24(sp)
    800034aa:	6145                	addi	sp,sp,48
    800034ac:	8082                	ret
    return -1;
    800034ae:	557d                	li	a0,-1
    800034b0:	bfd5                	j	800034a4 <sys_physaddr+0x4e>

00000000800034b2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800034b2:	7179                	addi	sp,sp,-48
    800034b4:	f406                	sd	ra,40(sp)
    800034b6:	f022                	sd	s0,32(sp)
    800034b8:	ec26                	sd	s1,24(sp)
    800034ba:	e84a                	sd	s2,16(sp)
    800034bc:	e44e                	sd	s3,8(sp)
    800034be:	e052                	sd	s4,0(sp)
    800034c0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034c2:	00005597          	auipc	a1,0x5
    800034c6:	fb658593          	addi	a1,a1,-74 # 80008478 <etext+0x478>
    800034ca:	00034517          	auipc	a0,0x34
    800034ce:	e2e50513          	addi	a0,a0,-466 # 800372f8 <bcache>
    800034d2:	889fd0ef          	jal	80000d5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034d6:	0003c797          	auipc	a5,0x3c
    800034da:	e2278793          	addi	a5,a5,-478 # 8003f2f8 <bcache+0x8000>
    800034de:	0003c717          	auipc	a4,0x3c
    800034e2:	08270713          	addi	a4,a4,130 # 8003f560 <bcache+0x8268>
    800034e6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ea:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034ee:	00034497          	auipc	s1,0x34
    800034f2:	e2248493          	addi	s1,s1,-478 # 80037310 <bcache+0x18>
    b->next = bcache.head.next;
    800034f6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034f8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034fa:	00005a17          	auipc	s4,0x5
    800034fe:	f86a0a13          	addi	s4,s4,-122 # 80008480 <etext+0x480>
    b->next = bcache.head.next;
    80003502:	2b893783          	ld	a5,696(s2)
    80003506:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003508:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000350c:	85d2                	mv	a1,s4
    8000350e:	01048513          	addi	a0,s1,16
    80003512:	322010ef          	jal	80004834 <initsleeplock>
    bcache.head.next->prev = b;
    80003516:	2b893783          	ld	a5,696(s2)
    8000351a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000351c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003520:	45848493          	addi	s1,s1,1112
    80003524:	fd349fe3          	bne	s1,s3,80003502 <binit+0x50>
  }
}
    80003528:	70a2                	ld	ra,40(sp)
    8000352a:	7402                	ld	s0,32(sp)
    8000352c:	64e2                	ld	s1,24(sp)
    8000352e:	6942                	ld	s2,16(sp)
    80003530:	69a2                	ld	s3,8(sp)
    80003532:	6a02                	ld	s4,0(sp)
    80003534:	6145                	addi	sp,sp,48
    80003536:	8082                	ret

0000000080003538 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003538:	7179                	addi	sp,sp,-48
    8000353a:	f406                	sd	ra,40(sp)
    8000353c:	f022                	sd	s0,32(sp)
    8000353e:	ec26                	sd	s1,24(sp)
    80003540:	e84a                	sd	s2,16(sp)
    80003542:	e44e                	sd	s3,8(sp)
    80003544:	1800                	addi	s0,sp,48
    80003546:	892a                	mv	s2,a0
    80003548:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000354a:	00034517          	auipc	a0,0x34
    8000354e:	dae50513          	addi	a0,a0,-594 # 800372f8 <bcache>
    80003552:	889fd0ef          	jal	80000dda <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003556:	0003c497          	auipc	s1,0x3c
    8000355a:	05a4b483          	ld	s1,90(s1) # 8003f5b0 <bcache+0x82b8>
    8000355e:	0003c797          	auipc	a5,0x3c
    80003562:	00278793          	addi	a5,a5,2 # 8003f560 <bcache+0x8268>
    80003566:	02f48b63          	beq	s1,a5,8000359c <bread+0x64>
    8000356a:	873e                	mv	a4,a5
    8000356c:	a021                	j	80003574 <bread+0x3c>
    8000356e:	68a4                	ld	s1,80(s1)
    80003570:	02e48663          	beq	s1,a4,8000359c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80003574:	449c                	lw	a5,8(s1)
    80003576:	ff279ce3          	bne	a5,s2,8000356e <bread+0x36>
    8000357a:	44dc                	lw	a5,12(s1)
    8000357c:	ff3799e3          	bne	a5,s3,8000356e <bread+0x36>
      b->refcnt++;
    80003580:	40bc                	lw	a5,64(s1)
    80003582:	2785                	addiw	a5,a5,1
    80003584:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003586:	00034517          	auipc	a0,0x34
    8000358a:	d7250513          	addi	a0,a0,-654 # 800372f8 <bcache>
    8000358e:	8e5fd0ef          	jal	80000e72 <release>
      acquiresleep(&b->lock);
    80003592:	01048513          	addi	a0,s1,16
    80003596:	2d4010ef          	jal	8000486a <acquiresleep>
      return b;
    8000359a:	a889                	j	800035ec <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000359c:	0003c497          	auipc	s1,0x3c
    800035a0:	00c4b483          	ld	s1,12(s1) # 8003f5a8 <bcache+0x82b0>
    800035a4:	0003c797          	auipc	a5,0x3c
    800035a8:	fbc78793          	addi	a5,a5,-68 # 8003f560 <bcache+0x8268>
    800035ac:	00f48863          	beq	s1,a5,800035bc <bread+0x84>
    800035b0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035b2:	40bc                	lw	a5,64(s1)
    800035b4:	cb91                	beqz	a5,800035c8 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035b6:	64a4                	ld	s1,72(s1)
    800035b8:	fee49de3          	bne	s1,a4,800035b2 <bread+0x7a>
  panic("bget: no buffers");
    800035bc:	00005517          	auipc	a0,0x5
    800035c0:	ecc50513          	addi	a0,a0,-308 # 80008488 <etext+0x488>
    800035c4:	a1cfd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    800035c8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800035cc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800035d0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035d4:	4785                	li	a5,1
    800035d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035d8:	00034517          	auipc	a0,0x34
    800035dc:	d2050513          	addi	a0,a0,-736 # 800372f8 <bcache>
    800035e0:	893fd0ef          	jal	80000e72 <release>
      acquiresleep(&b->lock);
    800035e4:	01048513          	addi	a0,s1,16
    800035e8:	282010ef          	jal	8000486a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035ec:	409c                	lw	a5,0(s1)
    800035ee:	cb89                	beqz	a5,80003600 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035f0:	8526                	mv	a0,s1
    800035f2:	70a2                	ld	ra,40(sp)
    800035f4:	7402                	ld	s0,32(sp)
    800035f6:	64e2                	ld	s1,24(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	6145                	addi	sp,sp,48
    800035fe:	8082                	ret
    virtio_disk_rw(b, 0);
    80003600:	4581                	li	a1,0
    80003602:	8526                	mv	a0,s1
    80003604:	2cd020ef          	jal	800060d0 <virtio_disk_rw>
    b->valid = 1;
    80003608:	4785                	li	a5,1
    8000360a:	c09c                	sw	a5,0(s1)
  return b;
    8000360c:	b7d5                	j	800035f0 <bread+0xb8>

000000008000360e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000360e:	1101                	addi	sp,sp,-32
    80003610:	ec06                	sd	ra,24(sp)
    80003612:	e822                	sd	s0,16(sp)
    80003614:	e426                	sd	s1,8(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000361a:	0541                	addi	a0,a0,16
    8000361c:	2cc010ef          	jal	800048e8 <holdingsleep>
    80003620:	c911                	beqz	a0,80003634 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003622:	4585                	li	a1,1
    80003624:	8526                	mv	a0,s1
    80003626:	2ab020ef          	jal	800060d0 <virtio_disk_rw>
}
    8000362a:	60e2                	ld	ra,24(sp)
    8000362c:	6442                	ld	s0,16(sp)
    8000362e:	64a2                	ld	s1,8(sp)
    80003630:	6105                	addi	sp,sp,32
    80003632:	8082                	ret
    panic("bwrite");
    80003634:	00005517          	auipc	a0,0x5
    80003638:	e6c50513          	addi	a0,a0,-404 # 800084a0 <etext+0x4a0>
    8000363c:	9a4fd0ef          	jal	800007e0 <panic>

0000000080003640 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	e04a                	sd	s2,0(sp)
    8000364a:	1000                	addi	s0,sp,32
    8000364c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000364e:	01050913          	addi	s2,a0,16
    80003652:	854a                	mv	a0,s2
    80003654:	294010ef          	jal	800048e8 <holdingsleep>
    80003658:	c135                	beqz	a0,800036bc <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    8000365a:	854a                	mv	a0,s2
    8000365c:	254010ef          	jal	800048b0 <releasesleep>

  acquire(&bcache.lock);
    80003660:	00034517          	auipc	a0,0x34
    80003664:	c9850513          	addi	a0,a0,-872 # 800372f8 <bcache>
    80003668:	f72fd0ef          	jal	80000dda <acquire>
  b->refcnt--;
    8000366c:	40bc                	lw	a5,64(s1)
    8000366e:	37fd                	addiw	a5,a5,-1
    80003670:	0007871b          	sext.w	a4,a5
    80003674:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003676:	e71d                	bnez	a4,800036a4 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003678:	68b8                	ld	a4,80(s1)
    8000367a:	64bc                	ld	a5,72(s1)
    8000367c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000367e:	68b8                	ld	a4,80(s1)
    80003680:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003682:	0003c797          	auipc	a5,0x3c
    80003686:	c7678793          	addi	a5,a5,-906 # 8003f2f8 <bcache+0x8000>
    8000368a:	2b87b703          	ld	a4,696(a5)
    8000368e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003690:	0003c717          	auipc	a4,0x3c
    80003694:	ed070713          	addi	a4,a4,-304 # 8003f560 <bcache+0x8268>
    80003698:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000369a:	2b87b703          	ld	a4,696(a5)
    8000369e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036a0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036a4:	00034517          	auipc	a0,0x34
    800036a8:	c5450513          	addi	a0,a0,-940 # 800372f8 <bcache>
    800036ac:	fc6fd0ef          	jal	80000e72 <release>
}
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6902                	ld	s2,0(sp)
    800036b8:	6105                	addi	sp,sp,32
    800036ba:	8082                	ret
    panic("brelse");
    800036bc:	00005517          	auipc	a0,0x5
    800036c0:	dec50513          	addi	a0,a0,-532 # 800084a8 <etext+0x4a8>
    800036c4:	91cfd0ef          	jal	800007e0 <panic>

00000000800036c8 <bpin>:

void
bpin(struct buf *b) {
    800036c8:	1101                	addi	sp,sp,-32
    800036ca:	ec06                	sd	ra,24(sp)
    800036cc:	e822                	sd	s0,16(sp)
    800036ce:	e426                	sd	s1,8(sp)
    800036d0:	1000                	addi	s0,sp,32
    800036d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036d4:	00034517          	auipc	a0,0x34
    800036d8:	c2450513          	addi	a0,a0,-988 # 800372f8 <bcache>
    800036dc:	efefd0ef          	jal	80000dda <acquire>
  b->refcnt++;
    800036e0:	40bc                	lw	a5,64(s1)
    800036e2:	2785                	addiw	a5,a5,1
    800036e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e6:	00034517          	auipc	a0,0x34
    800036ea:	c1250513          	addi	a0,a0,-1006 # 800372f8 <bcache>
    800036ee:	f84fd0ef          	jal	80000e72 <release>
}
    800036f2:	60e2                	ld	ra,24(sp)
    800036f4:	6442                	ld	s0,16(sp)
    800036f6:	64a2                	ld	s1,8(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret

00000000800036fc <bunpin>:

void
bunpin(struct buf *b) {
    800036fc:	1101                	addi	sp,sp,-32
    800036fe:	ec06                	sd	ra,24(sp)
    80003700:	e822                	sd	s0,16(sp)
    80003702:	e426                	sd	s1,8(sp)
    80003704:	1000                	addi	s0,sp,32
    80003706:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003708:	00034517          	auipc	a0,0x34
    8000370c:	bf050513          	addi	a0,a0,-1040 # 800372f8 <bcache>
    80003710:	ecafd0ef          	jal	80000dda <acquire>
  b->refcnt--;
    80003714:	40bc                	lw	a5,64(s1)
    80003716:	37fd                	addiw	a5,a5,-1
    80003718:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000371a:	00034517          	auipc	a0,0x34
    8000371e:	bde50513          	addi	a0,a0,-1058 # 800372f8 <bcache>
    80003722:	f50fd0ef          	jal	80000e72 <release>
}
    80003726:	60e2                	ld	ra,24(sp)
    80003728:	6442                	ld	s0,16(sp)
    8000372a:	64a2                	ld	s1,8(sp)
    8000372c:	6105                	addi	sp,sp,32
    8000372e:	8082                	ret

0000000080003730 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003730:	1101                	addi	sp,sp,-32
    80003732:	ec06                	sd	ra,24(sp)
    80003734:	e822                	sd	s0,16(sp)
    80003736:	e426                	sd	s1,8(sp)
    80003738:	e04a                	sd	s2,0(sp)
    8000373a:	1000                	addi	s0,sp,32
    8000373c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000373e:	00d5d59b          	srliw	a1,a1,0xd
    80003742:	0003c797          	auipc	a5,0x3c
    80003746:	2927a783          	lw	a5,658(a5) # 8003f9d4 <sb+0x1c>
    8000374a:	9dbd                	addw	a1,a1,a5
    8000374c:	dedff0ef          	jal	80003538 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003750:	0074f713          	andi	a4,s1,7
    80003754:	4785                	li	a5,1
    80003756:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000375a:	14ce                	slli	s1,s1,0x33
    8000375c:	90d9                	srli	s1,s1,0x36
    8000375e:	00950733          	add	a4,a0,s1
    80003762:	05874703          	lbu	a4,88(a4)
    80003766:	00e7f6b3          	and	a3,a5,a4
    8000376a:	c29d                	beqz	a3,80003790 <bfree+0x60>
    8000376c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000376e:	94aa                	add	s1,s1,a0
    80003770:	fff7c793          	not	a5,a5
    80003774:	8f7d                	and	a4,a4,a5
    80003776:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000377a:	7f9000ef          	jal	80004772 <log_write>
  brelse(bp);
    8000377e:	854a                	mv	a0,s2
    80003780:	ec1ff0ef          	jal	80003640 <brelse>
}
    80003784:	60e2                	ld	ra,24(sp)
    80003786:	6442                	ld	s0,16(sp)
    80003788:	64a2                	ld	s1,8(sp)
    8000378a:	6902                	ld	s2,0(sp)
    8000378c:	6105                	addi	sp,sp,32
    8000378e:	8082                	ret
    panic("freeing free block");
    80003790:	00005517          	auipc	a0,0x5
    80003794:	d2050513          	addi	a0,a0,-736 # 800084b0 <etext+0x4b0>
    80003798:	848fd0ef          	jal	800007e0 <panic>

000000008000379c <balloc>:
{
    8000379c:	711d                	addi	sp,sp,-96
    8000379e:	ec86                	sd	ra,88(sp)
    800037a0:	e8a2                	sd	s0,80(sp)
    800037a2:	e4a6                	sd	s1,72(sp)
    800037a4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037a6:	0003c797          	auipc	a5,0x3c
    800037aa:	2167a783          	lw	a5,534(a5) # 8003f9bc <sb+0x4>
    800037ae:	0e078f63          	beqz	a5,800038ac <balloc+0x110>
    800037b2:	e0ca                	sd	s2,64(sp)
    800037b4:	fc4e                	sd	s3,56(sp)
    800037b6:	f852                	sd	s4,48(sp)
    800037b8:	f456                	sd	s5,40(sp)
    800037ba:	f05a                	sd	s6,32(sp)
    800037bc:	ec5e                	sd	s7,24(sp)
    800037be:	e862                	sd	s8,16(sp)
    800037c0:	e466                	sd	s9,8(sp)
    800037c2:	8baa                	mv	s7,a0
    800037c4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037c6:	0003cb17          	auipc	s6,0x3c
    800037ca:	1f2b0b13          	addi	s6,s6,498 # 8003f9b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ce:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037d0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037d2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037d4:	6c89                	lui	s9,0x2
    800037d6:	a0b5                	j	80003842 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037d8:	97ca                	add	a5,a5,s2
    800037da:	8e55                	or	a2,a2,a3
    800037dc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800037e0:	854a                	mv	a0,s2
    800037e2:	791000ef          	jal	80004772 <log_write>
        brelse(bp);
    800037e6:	854a                	mv	a0,s2
    800037e8:	e59ff0ef          	jal	80003640 <brelse>
  bp = bread(dev, bno);
    800037ec:	85a6                	mv	a1,s1
    800037ee:	855e                	mv	a0,s7
    800037f0:	d49ff0ef          	jal	80003538 <bread>
    800037f4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037f6:	40000613          	li	a2,1024
    800037fa:	4581                	li	a1,0
    800037fc:	05850513          	addi	a0,a0,88
    80003800:	eaefd0ef          	jal	80000eae <memset>
  log_write(bp);
    80003804:	854a                	mv	a0,s2
    80003806:	76d000ef          	jal	80004772 <log_write>
  brelse(bp);
    8000380a:	854a                	mv	a0,s2
    8000380c:	e35ff0ef          	jal	80003640 <brelse>
}
    80003810:	6906                	ld	s2,64(sp)
    80003812:	79e2                	ld	s3,56(sp)
    80003814:	7a42                	ld	s4,48(sp)
    80003816:	7aa2                	ld	s5,40(sp)
    80003818:	7b02                	ld	s6,32(sp)
    8000381a:	6be2                	ld	s7,24(sp)
    8000381c:	6c42                	ld	s8,16(sp)
    8000381e:	6ca2                	ld	s9,8(sp)
}
    80003820:	8526                	mv	a0,s1
    80003822:	60e6                	ld	ra,88(sp)
    80003824:	6446                	ld	s0,80(sp)
    80003826:	64a6                	ld	s1,72(sp)
    80003828:	6125                	addi	sp,sp,96
    8000382a:	8082                	ret
    brelse(bp);
    8000382c:	854a                	mv	a0,s2
    8000382e:	e13ff0ef          	jal	80003640 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003832:	015c87bb          	addw	a5,s9,s5
    80003836:	00078a9b          	sext.w	s5,a5
    8000383a:	004b2703          	lw	a4,4(s6)
    8000383e:	04eaff63          	bgeu	s5,a4,8000389c <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003842:	41fad79b          	sraiw	a5,s5,0x1f
    80003846:	0137d79b          	srliw	a5,a5,0x13
    8000384a:	015787bb          	addw	a5,a5,s5
    8000384e:	40d7d79b          	sraiw	a5,a5,0xd
    80003852:	01cb2583          	lw	a1,28(s6)
    80003856:	9dbd                	addw	a1,a1,a5
    80003858:	855e                	mv	a0,s7
    8000385a:	cdfff0ef          	jal	80003538 <bread>
    8000385e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003860:	004b2503          	lw	a0,4(s6)
    80003864:	000a849b          	sext.w	s1,s5
    80003868:	8762                	mv	a4,s8
    8000386a:	fca4f1e3          	bgeu	s1,a0,8000382c <balloc+0x90>
      m = 1 << (bi % 8);
    8000386e:	00777693          	andi	a3,a4,7
    80003872:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003876:	41f7579b          	sraiw	a5,a4,0x1f
    8000387a:	01d7d79b          	srliw	a5,a5,0x1d
    8000387e:	9fb9                	addw	a5,a5,a4
    80003880:	4037d79b          	sraiw	a5,a5,0x3
    80003884:	00f90633          	add	a2,s2,a5
    80003888:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    8000388c:	00c6f5b3          	and	a1,a3,a2
    80003890:	d5a1                	beqz	a1,800037d8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003892:	2705                	addiw	a4,a4,1
    80003894:	2485                	addiw	s1,s1,1
    80003896:	fd471ae3          	bne	a4,s4,8000386a <balloc+0xce>
    8000389a:	bf49                	j	8000382c <balloc+0x90>
    8000389c:	6906                	ld	s2,64(sp)
    8000389e:	79e2                	ld	s3,56(sp)
    800038a0:	7a42                	ld	s4,48(sp)
    800038a2:	7aa2                	ld	s5,40(sp)
    800038a4:	7b02                	ld	s6,32(sp)
    800038a6:	6be2                	ld	s7,24(sp)
    800038a8:	6c42                	ld	s8,16(sp)
    800038aa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800038ac:	00005517          	auipc	a0,0x5
    800038b0:	c1c50513          	addi	a0,a0,-996 # 800084c8 <etext+0x4c8>
    800038b4:	c47fc0ef          	jal	800004fa <printf>
  return 0;
    800038b8:	4481                	li	s1,0
    800038ba:	b79d                	j	80003820 <balloc+0x84>

00000000800038bc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038bc:	7179                	addi	sp,sp,-48
    800038be:	f406                	sd	ra,40(sp)
    800038c0:	f022                	sd	s0,32(sp)
    800038c2:	ec26                	sd	s1,24(sp)
    800038c4:	e84a                	sd	s2,16(sp)
    800038c6:	e44e                	sd	s3,8(sp)
    800038c8:	1800                	addi	s0,sp,48
    800038ca:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038cc:	47ad                	li	a5,11
    800038ce:	02b7e663          	bltu	a5,a1,800038fa <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800038d2:	02059793          	slli	a5,a1,0x20
    800038d6:	01e7d593          	srli	a1,a5,0x1e
    800038da:	00b504b3          	add	s1,a0,a1
    800038de:	0504a903          	lw	s2,80(s1)
    800038e2:	06091a63          	bnez	s2,80003956 <bmap+0x9a>
      addr = balloc(ip->dev);
    800038e6:	4108                	lw	a0,0(a0)
    800038e8:	eb5ff0ef          	jal	8000379c <balloc>
    800038ec:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038f0:	06090363          	beqz	s2,80003956 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800038f4:	0524a823          	sw	s2,80(s1)
    800038f8:	a8b9                	j	80003956 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038fa:	ff45849b          	addiw	s1,a1,-12
    800038fe:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003902:	0ff00793          	li	a5,255
    80003906:	06e7ee63          	bltu	a5,a4,80003982 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000390a:	08052903          	lw	s2,128(a0)
    8000390e:	00091d63          	bnez	s2,80003928 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003912:	4108                	lw	a0,0(a0)
    80003914:	e89ff0ef          	jal	8000379c <balloc>
    80003918:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000391c:	02090d63          	beqz	s2,80003956 <bmap+0x9a>
    80003920:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003922:	0929a023          	sw	s2,128(s3)
    80003926:	a011                	j	8000392a <bmap+0x6e>
    80003928:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000392a:	85ca                	mv	a1,s2
    8000392c:	0009a503          	lw	a0,0(s3)
    80003930:	c09ff0ef          	jal	80003538 <bread>
    80003934:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003936:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000393a:	02049713          	slli	a4,s1,0x20
    8000393e:	01e75593          	srli	a1,a4,0x1e
    80003942:	00b784b3          	add	s1,a5,a1
    80003946:	0004a903          	lw	s2,0(s1)
    8000394a:	00090e63          	beqz	s2,80003966 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000394e:	8552                	mv	a0,s4
    80003950:	cf1ff0ef          	jal	80003640 <brelse>
    return addr;
    80003954:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003956:	854a                	mv	a0,s2
    80003958:	70a2                	ld	ra,40(sp)
    8000395a:	7402                	ld	s0,32(sp)
    8000395c:	64e2                	ld	s1,24(sp)
    8000395e:	6942                	ld	s2,16(sp)
    80003960:	69a2                	ld	s3,8(sp)
    80003962:	6145                	addi	sp,sp,48
    80003964:	8082                	ret
      addr = balloc(ip->dev);
    80003966:	0009a503          	lw	a0,0(s3)
    8000396a:	e33ff0ef          	jal	8000379c <balloc>
    8000396e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003972:	fc090ee3          	beqz	s2,8000394e <bmap+0x92>
        a[bn] = addr;
    80003976:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000397a:	8552                	mv	a0,s4
    8000397c:	5f7000ef          	jal	80004772 <log_write>
    80003980:	b7f9                	j	8000394e <bmap+0x92>
    80003982:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003984:	00005517          	auipc	a0,0x5
    80003988:	b5c50513          	addi	a0,a0,-1188 # 800084e0 <etext+0x4e0>
    8000398c:	e55fc0ef          	jal	800007e0 <panic>

0000000080003990 <iget>:
{
    80003990:	7179                	addi	sp,sp,-48
    80003992:	f406                	sd	ra,40(sp)
    80003994:	f022                	sd	s0,32(sp)
    80003996:	ec26                	sd	s1,24(sp)
    80003998:	e84a                	sd	s2,16(sp)
    8000399a:	e44e                	sd	s3,8(sp)
    8000399c:	e052                	sd	s4,0(sp)
    8000399e:	1800                	addi	s0,sp,48
    800039a0:	89aa                	mv	s3,a0
    800039a2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039a4:	0003c517          	auipc	a0,0x3c
    800039a8:	03450513          	addi	a0,a0,52 # 8003f9d8 <itable>
    800039ac:	c2efd0ef          	jal	80000dda <acquire>
  empty = 0;
    800039b0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039b2:	0003c497          	auipc	s1,0x3c
    800039b6:	03e48493          	addi	s1,s1,62 # 8003f9f0 <itable+0x18>
    800039ba:	0003e697          	auipc	a3,0x3e
    800039be:	ac668693          	addi	a3,a3,-1338 # 80041480 <log>
    800039c2:	a039                	j	800039d0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039c4:	02090963          	beqz	s2,800039f6 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039c8:	08848493          	addi	s1,s1,136
    800039cc:	02d48863          	beq	s1,a3,800039fc <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039d0:	449c                	lw	a5,8(s1)
    800039d2:	fef059e3          	blez	a5,800039c4 <iget+0x34>
    800039d6:	4098                	lw	a4,0(s1)
    800039d8:	ff3716e3          	bne	a4,s3,800039c4 <iget+0x34>
    800039dc:	40d8                	lw	a4,4(s1)
    800039de:	ff4713e3          	bne	a4,s4,800039c4 <iget+0x34>
      ip->ref++;
    800039e2:	2785                	addiw	a5,a5,1
    800039e4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039e6:	0003c517          	auipc	a0,0x3c
    800039ea:	ff250513          	addi	a0,a0,-14 # 8003f9d8 <itable>
    800039ee:	c84fd0ef          	jal	80000e72 <release>
      return ip;
    800039f2:	8926                	mv	s2,s1
    800039f4:	a02d                	j	80003a1e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039f6:	fbe9                	bnez	a5,800039c8 <iget+0x38>
      empty = ip;
    800039f8:	8926                	mv	s2,s1
    800039fa:	b7f9                	j	800039c8 <iget+0x38>
  if(empty == 0)
    800039fc:	02090a63          	beqz	s2,80003a30 <iget+0xa0>
  ip->dev = dev;
    80003a00:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a04:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a08:	4785                	li	a5,1
    80003a0a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a0e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a12:	0003c517          	auipc	a0,0x3c
    80003a16:	fc650513          	addi	a0,a0,-58 # 8003f9d8 <itable>
    80003a1a:	c58fd0ef          	jal	80000e72 <release>
}
    80003a1e:	854a                	mv	a0,s2
    80003a20:	70a2                	ld	ra,40(sp)
    80003a22:	7402                	ld	s0,32(sp)
    80003a24:	64e2                	ld	s1,24(sp)
    80003a26:	6942                	ld	s2,16(sp)
    80003a28:	69a2                	ld	s3,8(sp)
    80003a2a:	6a02                	ld	s4,0(sp)
    80003a2c:	6145                	addi	sp,sp,48
    80003a2e:	8082                	ret
    panic("iget: no inodes");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	ac850513          	addi	a0,a0,-1336 # 800084f8 <etext+0x4f8>
    80003a38:	da9fc0ef          	jal	800007e0 <panic>

0000000080003a3c <iinit>:
{
    80003a3c:	7179                	addi	sp,sp,-48
    80003a3e:	f406                	sd	ra,40(sp)
    80003a40:	f022                	sd	s0,32(sp)
    80003a42:	ec26                	sd	s1,24(sp)
    80003a44:	e84a                	sd	s2,16(sp)
    80003a46:	e44e                	sd	s3,8(sp)
    80003a48:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a4a:	00005597          	auipc	a1,0x5
    80003a4e:	abe58593          	addi	a1,a1,-1346 # 80008508 <etext+0x508>
    80003a52:	0003c517          	auipc	a0,0x3c
    80003a56:	f8650513          	addi	a0,a0,-122 # 8003f9d8 <itable>
    80003a5a:	b00fd0ef          	jal	80000d5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a5e:	0003c497          	auipc	s1,0x3c
    80003a62:	fa248493          	addi	s1,s1,-94 # 8003fa00 <itable+0x28>
    80003a66:	0003e997          	auipc	s3,0x3e
    80003a6a:	a2a98993          	addi	s3,s3,-1494 # 80041490 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a6e:	00005917          	auipc	s2,0x5
    80003a72:	aa290913          	addi	s2,s2,-1374 # 80008510 <etext+0x510>
    80003a76:	85ca                	mv	a1,s2
    80003a78:	8526                	mv	a0,s1
    80003a7a:	5bb000ef          	jal	80004834 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a7e:	08848493          	addi	s1,s1,136
    80003a82:	ff349ae3          	bne	s1,s3,80003a76 <iinit+0x3a>
}
    80003a86:	70a2                	ld	ra,40(sp)
    80003a88:	7402                	ld	s0,32(sp)
    80003a8a:	64e2                	ld	s1,24(sp)
    80003a8c:	6942                	ld	s2,16(sp)
    80003a8e:	69a2                	ld	s3,8(sp)
    80003a90:	6145                	addi	sp,sp,48
    80003a92:	8082                	ret

0000000080003a94 <ialloc>:
{
    80003a94:	7139                	addi	sp,sp,-64
    80003a96:	fc06                	sd	ra,56(sp)
    80003a98:	f822                	sd	s0,48(sp)
    80003a9a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a9c:	0003c717          	auipc	a4,0x3c
    80003aa0:	f2872703          	lw	a4,-216(a4) # 8003f9c4 <sb+0xc>
    80003aa4:	4785                	li	a5,1
    80003aa6:	06e7f063          	bgeu	a5,a4,80003b06 <ialloc+0x72>
    80003aaa:	f426                	sd	s1,40(sp)
    80003aac:	f04a                	sd	s2,32(sp)
    80003aae:	ec4e                	sd	s3,24(sp)
    80003ab0:	e852                	sd	s4,16(sp)
    80003ab2:	e456                	sd	s5,8(sp)
    80003ab4:	e05a                	sd	s6,0(sp)
    80003ab6:	8aaa                	mv	s5,a0
    80003ab8:	8b2e                	mv	s6,a1
    80003aba:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003abc:	0003ca17          	auipc	s4,0x3c
    80003ac0:	efca0a13          	addi	s4,s4,-260 # 8003f9b8 <sb>
    80003ac4:	00495593          	srli	a1,s2,0x4
    80003ac8:	018a2783          	lw	a5,24(s4)
    80003acc:	9dbd                	addw	a1,a1,a5
    80003ace:	8556                	mv	a0,s5
    80003ad0:	a69ff0ef          	jal	80003538 <bread>
    80003ad4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ad6:	05850993          	addi	s3,a0,88
    80003ada:	00f97793          	andi	a5,s2,15
    80003ade:	079a                	slli	a5,a5,0x6
    80003ae0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ae2:	00099783          	lh	a5,0(s3)
    80003ae6:	cb9d                	beqz	a5,80003b1c <ialloc+0x88>
    brelse(bp);
    80003ae8:	b59ff0ef          	jal	80003640 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aec:	0905                	addi	s2,s2,1
    80003aee:	00ca2703          	lw	a4,12(s4)
    80003af2:	0009079b          	sext.w	a5,s2
    80003af6:	fce7e7e3          	bltu	a5,a4,80003ac4 <ialloc+0x30>
    80003afa:	74a2                	ld	s1,40(sp)
    80003afc:	7902                	ld	s2,32(sp)
    80003afe:	69e2                	ld	s3,24(sp)
    80003b00:	6a42                	ld	s4,16(sp)
    80003b02:	6aa2                	ld	s5,8(sp)
    80003b04:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003b06:	00005517          	auipc	a0,0x5
    80003b0a:	a1250513          	addi	a0,a0,-1518 # 80008518 <etext+0x518>
    80003b0e:	9edfc0ef          	jal	800004fa <printf>
  return 0;
    80003b12:	4501                	li	a0,0
}
    80003b14:	70e2                	ld	ra,56(sp)
    80003b16:	7442                	ld	s0,48(sp)
    80003b18:	6121                	addi	sp,sp,64
    80003b1a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b1c:	04000613          	li	a2,64
    80003b20:	4581                	li	a1,0
    80003b22:	854e                	mv	a0,s3
    80003b24:	b8afd0ef          	jal	80000eae <memset>
      dip->type = type;
    80003b28:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	445000ef          	jal	80004772 <log_write>
      brelse(bp);
    80003b32:	8526                	mv	a0,s1
    80003b34:	b0dff0ef          	jal	80003640 <brelse>
      return iget(dev, inum);
    80003b38:	0009059b          	sext.w	a1,s2
    80003b3c:	8556                	mv	a0,s5
    80003b3e:	e53ff0ef          	jal	80003990 <iget>
    80003b42:	74a2                	ld	s1,40(sp)
    80003b44:	7902                	ld	s2,32(sp)
    80003b46:	69e2                	ld	s3,24(sp)
    80003b48:	6a42                	ld	s4,16(sp)
    80003b4a:	6aa2                	ld	s5,8(sp)
    80003b4c:	6b02                	ld	s6,0(sp)
    80003b4e:	b7d9                	j	80003b14 <ialloc+0x80>

0000000080003b50 <iupdate>:
{
    80003b50:	1101                	addi	sp,sp,-32
    80003b52:	ec06                	sd	ra,24(sp)
    80003b54:	e822                	sd	s0,16(sp)
    80003b56:	e426                	sd	s1,8(sp)
    80003b58:	e04a                	sd	s2,0(sp)
    80003b5a:	1000                	addi	s0,sp,32
    80003b5c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b5e:	415c                	lw	a5,4(a0)
    80003b60:	0047d79b          	srliw	a5,a5,0x4
    80003b64:	0003c597          	auipc	a1,0x3c
    80003b68:	e6c5a583          	lw	a1,-404(a1) # 8003f9d0 <sb+0x18>
    80003b6c:	9dbd                	addw	a1,a1,a5
    80003b6e:	4108                	lw	a0,0(a0)
    80003b70:	9c9ff0ef          	jal	80003538 <bread>
    80003b74:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b76:	05850793          	addi	a5,a0,88
    80003b7a:	40d8                	lw	a4,4(s1)
    80003b7c:	8b3d                	andi	a4,a4,15
    80003b7e:	071a                	slli	a4,a4,0x6
    80003b80:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b82:	04449703          	lh	a4,68(s1)
    80003b86:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b8a:	04649703          	lh	a4,70(s1)
    80003b8e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b92:	04849703          	lh	a4,72(s1)
    80003b96:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b9a:	04a49703          	lh	a4,74(s1)
    80003b9e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003ba2:	44f8                	lw	a4,76(s1)
    80003ba4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ba6:	03400613          	li	a2,52
    80003baa:	05048593          	addi	a1,s1,80
    80003bae:	00c78513          	addi	a0,a5,12
    80003bb2:	b58fd0ef          	jal	80000f0a <memmove>
  log_write(bp);
    80003bb6:	854a                	mv	a0,s2
    80003bb8:	3bb000ef          	jal	80004772 <log_write>
  brelse(bp);
    80003bbc:	854a                	mv	a0,s2
    80003bbe:	a83ff0ef          	jal	80003640 <brelse>
}
    80003bc2:	60e2                	ld	ra,24(sp)
    80003bc4:	6442                	ld	s0,16(sp)
    80003bc6:	64a2                	ld	s1,8(sp)
    80003bc8:	6902                	ld	s2,0(sp)
    80003bca:	6105                	addi	sp,sp,32
    80003bcc:	8082                	ret

0000000080003bce <idup>:
{
    80003bce:	1101                	addi	sp,sp,-32
    80003bd0:	ec06                	sd	ra,24(sp)
    80003bd2:	e822                	sd	s0,16(sp)
    80003bd4:	e426                	sd	s1,8(sp)
    80003bd6:	1000                	addi	s0,sp,32
    80003bd8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bda:	0003c517          	auipc	a0,0x3c
    80003bde:	dfe50513          	addi	a0,a0,-514 # 8003f9d8 <itable>
    80003be2:	9f8fd0ef          	jal	80000dda <acquire>
  ip->ref++;
    80003be6:	449c                	lw	a5,8(s1)
    80003be8:	2785                	addiw	a5,a5,1
    80003bea:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bec:	0003c517          	auipc	a0,0x3c
    80003bf0:	dec50513          	addi	a0,a0,-532 # 8003f9d8 <itable>
    80003bf4:	a7efd0ef          	jal	80000e72 <release>
}
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	60e2                	ld	ra,24(sp)
    80003bfc:	6442                	ld	s0,16(sp)
    80003bfe:	64a2                	ld	s1,8(sp)
    80003c00:	6105                	addi	sp,sp,32
    80003c02:	8082                	ret

0000000080003c04 <ilock>:
{
    80003c04:	1101                	addi	sp,sp,-32
    80003c06:	ec06                	sd	ra,24(sp)
    80003c08:	e822                	sd	s0,16(sp)
    80003c0a:	e426                	sd	s1,8(sp)
    80003c0c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c0e:	cd19                	beqz	a0,80003c2c <ilock+0x28>
    80003c10:	84aa                	mv	s1,a0
    80003c12:	451c                	lw	a5,8(a0)
    80003c14:	00f05c63          	blez	a5,80003c2c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003c18:	0541                	addi	a0,a0,16
    80003c1a:	451000ef          	jal	8000486a <acquiresleep>
  if(ip->valid == 0){
    80003c1e:	40bc                	lw	a5,64(s1)
    80003c20:	cf89                	beqz	a5,80003c3a <ilock+0x36>
}
    80003c22:	60e2                	ld	ra,24(sp)
    80003c24:	6442                	ld	s0,16(sp)
    80003c26:	64a2                	ld	s1,8(sp)
    80003c28:	6105                	addi	sp,sp,32
    80003c2a:	8082                	ret
    80003c2c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003c2e:	00005517          	auipc	a0,0x5
    80003c32:	90250513          	addi	a0,a0,-1790 # 80008530 <etext+0x530>
    80003c36:	babfc0ef          	jal	800007e0 <panic>
    80003c3a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c3c:	40dc                	lw	a5,4(s1)
    80003c3e:	0047d79b          	srliw	a5,a5,0x4
    80003c42:	0003c597          	auipc	a1,0x3c
    80003c46:	d8e5a583          	lw	a1,-626(a1) # 8003f9d0 <sb+0x18>
    80003c4a:	9dbd                	addw	a1,a1,a5
    80003c4c:	4088                	lw	a0,0(s1)
    80003c4e:	8ebff0ef          	jal	80003538 <bread>
    80003c52:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c54:	05850593          	addi	a1,a0,88
    80003c58:	40dc                	lw	a5,4(s1)
    80003c5a:	8bbd                	andi	a5,a5,15
    80003c5c:	079a                	slli	a5,a5,0x6
    80003c5e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c60:	00059783          	lh	a5,0(a1)
    80003c64:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c68:	00259783          	lh	a5,2(a1)
    80003c6c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c70:	00459783          	lh	a5,4(a1)
    80003c74:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c78:	00659783          	lh	a5,6(a1)
    80003c7c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c80:	459c                	lw	a5,8(a1)
    80003c82:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c84:	03400613          	li	a2,52
    80003c88:	05b1                	addi	a1,a1,12
    80003c8a:	05048513          	addi	a0,s1,80
    80003c8e:	a7cfd0ef          	jal	80000f0a <memmove>
    brelse(bp);
    80003c92:	854a                	mv	a0,s2
    80003c94:	9adff0ef          	jal	80003640 <brelse>
    ip->valid = 1;
    80003c98:	4785                	li	a5,1
    80003c9a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c9c:	04449783          	lh	a5,68(s1)
    80003ca0:	c399                	beqz	a5,80003ca6 <ilock+0xa2>
    80003ca2:	6902                	ld	s2,0(sp)
    80003ca4:	bfbd                	j	80003c22 <ilock+0x1e>
      panic("ilock: no type");
    80003ca6:	00005517          	auipc	a0,0x5
    80003caa:	89250513          	addi	a0,a0,-1902 # 80008538 <etext+0x538>
    80003cae:	b33fc0ef          	jal	800007e0 <panic>

0000000080003cb2 <iunlock>:
{
    80003cb2:	1101                	addi	sp,sp,-32
    80003cb4:	ec06                	sd	ra,24(sp)
    80003cb6:	e822                	sd	s0,16(sp)
    80003cb8:	e426                	sd	s1,8(sp)
    80003cba:	e04a                	sd	s2,0(sp)
    80003cbc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cbe:	c505                	beqz	a0,80003ce6 <iunlock+0x34>
    80003cc0:	84aa                	mv	s1,a0
    80003cc2:	01050913          	addi	s2,a0,16
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	421000ef          	jal	800048e8 <holdingsleep>
    80003ccc:	cd09                	beqz	a0,80003ce6 <iunlock+0x34>
    80003cce:	449c                	lw	a5,8(s1)
    80003cd0:	00f05b63          	blez	a5,80003ce6 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003cd4:	854a                	mv	a0,s2
    80003cd6:	3db000ef          	jal	800048b0 <releasesleep>
}
    80003cda:	60e2                	ld	ra,24(sp)
    80003cdc:	6442                	ld	s0,16(sp)
    80003cde:	64a2                	ld	s1,8(sp)
    80003ce0:	6902                	ld	s2,0(sp)
    80003ce2:	6105                	addi	sp,sp,32
    80003ce4:	8082                	ret
    panic("iunlock");
    80003ce6:	00005517          	auipc	a0,0x5
    80003cea:	86250513          	addi	a0,a0,-1950 # 80008548 <etext+0x548>
    80003cee:	af3fc0ef          	jal	800007e0 <panic>

0000000080003cf2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cf2:	7179                	addi	sp,sp,-48
    80003cf4:	f406                	sd	ra,40(sp)
    80003cf6:	f022                	sd	s0,32(sp)
    80003cf8:	ec26                	sd	s1,24(sp)
    80003cfa:	e84a                	sd	s2,16(sp)
    80003cfc:	e44e                	sd	s3,8(sp)
    80003cfe:	1800                	addi	s0,sp,48
    80003d00:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d02:	05050493          	addi	s1,a0,80
    80003d06:	08050913          	addi	s2,a0,128
    80003d0a:	a021                	j	80003d12 <itrunc+0x20>
    80003d0c:	0491                	addi	s1,s1,4
    80003d0e:	01248b63          	beq	s1,s2,80003d24 <itrunc+0x32>
    if(ip->addrs[i]){
    80003d12:	408c                	lw	a1,0(s1)
    80003d14:	dde5                	beqz	a1,80003d0c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003d16:	0009a503          	lw	a0,0(s3)
    80003d1a:	a17ff0ef          	jal	80003730 <bfree>
      ip->addrs[i] = 0;
    80003d1e:	0004a023          	sw	zero,0(s1)
    80003d22:	b7ed                	j	80003d0c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d24:	0809a583          	lw	a1,128(s3)
    80003d28:	ed89                	bnez	a1,80003d42 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d2a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d2e:	854e                	mv	a0,s3
    80003d30:	e21ff0ef          	jal	80003b50 <iupdate>
}
    80003d34:	70a2                	ld	ra,40(sp)
    80003d36:	7402                	ld	s0,32(sp)
    80003d38:	64e2                	ld	s1,24(sp)
    80003d3a:	6942                	ld	s2,16(sp)
    80003d3c:	69a2                	ld	s3,8(sp)
    80003d3e:	6145                	addi	sp,sp,48
    80003d40:	8082                	ret
    80003d42:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d44:	0009a503          	lw	a0,0(s3)
    80003d48:	ff0ff0ef          	jal	80003538 <bread>
    80003d4c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d4e:	05850493          	addi	s1,a0,88
    80003d52:	45850913          	addi	s2,a0,1112
    80003d56:	a021                	j	80003d5e <itrunc+0x6c>
    80003d58:	0491                	addi	s1,s1,4
    80003d5a:	01248963          	beq	s1,s2,80003d6c <itrunc+0x7a>
      if(a[j])
    80003d5e:	408c                	lw	a1,0(s1)
    80003d60:	dde5                	beqz	a1,80003d58 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003d62:	0009a503          	lw	a0,0(s3)
    80003d66:	9cbff0ef          	jal	80003730 <bfree>
    80003d6a:	b7fd                	j	80003d58 <itrunc+0x66>
    brelse(bp);
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	8d3ff0ef          	jal	80003640 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d72:	0809a583          	lw	a1,128(s3)
    80003d76:	0009a503          	lw	a0,0(s3)
    80003d7a:	9b7ff0ef          	jal	80003730 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d7e:	0809a023          	sw	zero,128(s3)
    80003d82:	6a02                	ld	s4,0(sp)
    80003d84:	b75d                	j	80003d2a <itrunc+0x38>

0000000080003d86 <iput>:
{
    80003d86:	1101                	addi	sp,sp,-32
    80003d88:	ec06                	sd	ra,24(sp)
    80003d8a:	e822                	sd	s0,16(sp)
    80003d8c:	e426                	sd	s1,8(sp)
    80003d8e:	1000                	addi	s0,sp,32
    80003d90:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d92:	0003c517          	auipc	a0,0x3c
    80003d96:	c4650513          	addi	a0,a0,-954 # 8003f9d8 <itable>
    80003d9a:	840fd0ef          	jal	80000dda <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d9e:	4498                	lw	a4,8(s1)
    80003da0:	4785                	li	a5,1
    80003da2:	02f70063          	beq	a4,a5,80003dc2 <iput+0x3c>
  ip->ref--;
    80003da6:	449c                	lw	a5,8(s1)
    80003da8:	37fd                	addiw	a5,a5,-1
    80003daa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dac:	0003c517          	auipc	a0,0x3c
    80003db0:	c2c50513          	addi	a0,a0,-980 # 8003f9d8 <itable>
    80003db4:	8befd0ef          	jal	80000e72 <release>
}
    80003db8:	60e2                	ld	ra,24(sp)
    80003dba:	6442                	ld	s0,16(sp)
    80003dbc:	64a2                	ld	s1,8(sp)
    80003dbe:	6105                	addi	sp,sp,32
    80003dc0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dc2:	40bc                	lw	a5,64(s1)
    80003dc4:	d3ed                	beqz	a5,80003da6 <iput+0x20>
    80003dc6:	04a49783          	lh	a5,74(s1)
    80003dca:	fff1                	bnez	a5,80003da6 <iput+0x20>
    80003dcc:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003dce:	01048913          	addi	s2,s1,16
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	297000ef          	jal	8000486a <acquiresleep>
    release(&itable.lock);
    80003dd8:	0003c517          	auipc	a0,0x3c
    80003ddc:	c0050513          	addi	a0,a0,-1024 # 8003f9d8 <itable>
    80003de0:	892fd0ef          	jal	80000e72 <release>
    itrunc(ip);
    80003de4:	8526                	mv	a0,s1
    80003de6:	f0dff0ef          	jal	80003cf2 <itrunc>
    ip->type = 0;
    80003dea:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dee:	8526                	mv	a0,s1
    80003df0:	d61ff0ef          	jal	80003b50 <iupdate>
    ip->valid = 0;
    80003df4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003df8:	854a                	mv	a0,s2
    80003dfa:	2b7000ef          	jal	800048b0 <releasesleep>
    acquire(&itable.lock);
    80003dfe:	0003c517          	auipc	a0,0x3c
    80003e02:	bda50513          	addi	a0,a0,-1062 # 8003f9d8 <itable>
    80003e06:	fd5fc0ef          	jal	80000dda <acquire>
    80003e0a:	6902                	ld	s2,0(sp)
    80003e0c:	bf69                	j	80003da6 <iput+0x20>

0000000080003e0e <iunlockput>:
{
    80003e0e:	1101                	addi	sp,sp,-32
    80003e10:	ec06                	sd	ra,24(sp)
    80003e12:	e822                	sd	s0,16(sp)
    80003e14:	e426                	sd	s1,8(sp)
    80003e16:	1000                	addi	s0,sp,32
    80003e18:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e1a:	e99ff0ef          	jal	80003cb2 <iunlock>
  iput(ip);
    80003e1e:	8526                	mv	a0,s1
    80003e20:	f67ff0ef          	jal	80003d86 <iput>
}
    80003e24:	60e2                	ld	ra,24(sp)
    80003e26:	6442                	ld	s0,16(sp)
    80003e28:	64a2                	ld	s1,8(sp)
    80003e2a:	6105                	addi	sp,sp,32
    80003e2c:	8082                	ret

0000000080003e2e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e2e:	0003c717          	auipc	a4,0x3c
    80003e32:	b9672703          	lw	a4,-1130(a4) # 8003f9c4 <sb+0xc>
    80003e36:	4785                	li	a5,1
    80003e38:	0ae7ff63          	bgeu	a5,a4,80003ef6 <ireclaim+0xc8>
{
    80003e3c:	7139                	addi	sp,sp,-64
    80003e3e:	fc06                	sd	ra,56(sp)
    80003e40:	f822                	sd	s0,48(sp)
    80003e42:	f426                	sd	s1,40(sp)
    80003e44:	f04a                	sd	s2,32(sp)
    80003e46:	ec4e                	sd	s3,24(sp)
    80003e48:	e852                	sd	s4,16(sp)
    80003e4a:	e456                	sd	s5,8(sp)
    80003e4c:	e05a                	sd	s6,0(sp)
    80003e4e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e50:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003e52:	00050a1b          	sext.w	s4,a0
    80003e56:	0003ca97          	auipc	s5,0x3c
    80003e5a:	b62a8a93          	addi	s5,s5,-1182 # 8003f9b8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003e5e:	00004b17          	auipc	s6,0x4
    80003e62:	6f2b0b13          	addi	s6,s6,1778 # 80008550 <etext+0x550>
    80003e66:	a099                	j	80003eac <ireclaim+0x7e>
    80003e68:	85ce                	mv	a1,s3
    80003e6a:	855a                	mv	a0,s6
    80003e6c:	e8efc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003e70:	85ce                	mv	a1,s3
    80003e72:	8552                	mv	a0,s4
    80003e74:	b1dff0ef          	jal	80003990 <iget>
    80003e78:	89aa                	mv	s3,a0
    brelse(bp);
    80003e7a:	854a                	mv	a0,s2
    80003e7c:	fc4ff0ef          	jal	80003640 <brelse>
    if (ip) {
    80003e80:	00098f63          	beqz	s3,80003e9e <ireclaim+0x70>
      begin_op();
    80003e84:	76a000ef          	jal	800045ee <begin_op>
      ilock(ip);
    80003e88:	854e                	mv	a0,s3
    80003e8a:	d7bff0ef          	jal	80003c04 <ilock>
      iunlock(ip);
    80003e8e:	854e                	mv	a0,s3
    80003e90:	e23ff0ef          	jal	80003cb2 <iunlock>
      iput(ip);
    80003e94:	854e                	mv	a0,s3
    80003e96:	ef1ff0ef          	jal	80003d86 <iput>
      end_op();
    80003e9a:	7be000ef          	jal	80004658 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e9e:	0485                	addi	s1,s1,1
    80003ea0:	00caa703          	lw	a4,12(s5)
    80003ea4:	0004879b          	sext.w	a5,s1
    80003ea8:	02e7fd63          	bgeu	a5,a4,80003ee2 <ireclaim+0xb4>
    80003eac:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003eb0:	0044d593          	srli	a1,s1,0x4
    80003eb4:	018aa783          	lw	a5,24(s5)
    80003eb8:	9dbd                	addw	a1,a1,a5
    80003eba:	8552                	mv	a0,s4
    80003ebc:	e7cff0ef          	jal	80003538 <bread>
    80003ec0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ec2:	05850793          	addi	a5,a0,88
    80003ec6:	00f9f713          	andi	a4,s3,15
    80003eca:	071a                	slli	a4,a4,0x6
    80003ecc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003ece:	00079703          	lh	a4,0(a5)
    80003ed2:	c701                	beqz	a4,80003eda <ireclaim+0xac>
    80003ed4:	00679783          	lh	a5,6(a5)
    80003ed8:	dbc1                	beqz	a5,80003e68 <ireclaim+0x3a>
    brelse(bp);
    80003eda:	854a                	mv	a0,s2
    80003edc:	f64ff0ef          	jal	80003640 <brelse>
    if (ip) {
    80003ee0:	bf7d                	j	80003e9e <ireclaim+0x70>
}
    80003ee2:	70e2                	ld	ra,56(sp)
    80003ee4:	7442                	ld	s0,48(sp)
    80003ee6:	74a2                	ld	s1,40(sp)
    80003ee8:	7902                	ld	s2,32(sp)
    80003eea:	69e2                	ld	s3,24(sp)
    80003eec:	6a42                	ld	s4,16(sp)
    80003eee:	6aa2                	ld	s5,8(sp)
    80003ef0:	6b02                	ld	s6,0(sp)
    80003ef2:	6121                	addi	sp,sp,64
    80003ef4:	8082                	ret
    80003ef6:	8082                	ret

0000000080003ef8 <fsinit>:
fsinit(int dev) {
    80003ef8:	7179                	addi	sp,sp,-48
    80003efa:	f406                	sd	ra,40(sp)
    80003efc:	f022                	sd	s0,32(sp)
    80003efe:	ec26                	sd	s1,24(sp)
    80003f00:	e84a                	sd	s2,16(sp)
    80003f02:	e44e                	sd	s3,8(sp)
    80003f04:	1800                	addi	s0,sp,48
    80003f06:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003f08:	4585                	li	a1,1
    80003f0a:	e2eff0ef          	jal	80003538 <bread>
    80003f0e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f10:	0003c997          	auipc	s3,0x3c
    80003f14:	aa898993          	addi	s3,s3,-1368 # 8003f9b8 <sb>
    80003f18:	02000613          	li	a2,32
    80003f1c:	05850593          	addi	a1,a0,88
    80003f20:	854e                	mv	a0,s3
    80003f22:	fe9fc0ef          	jal	80000f0a <memmove>
  brelse(bp);
    80003f26:	854a                	mv	a0,s2
    80003f28:	f18ff0ef          	jal	80003640 <brelse>
  if(sb.magic != FSMAGIC)
    80003f2c:	0009a703          	lw	a4,0(s3)
    80003f30:	102037b7          	lui	a5,0x10203
    80003f34:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003f38:	02f71363          	bne	a4,a5,80003f5e <fsinit+0x66>
  initlog(dev, &sb);
    80003f3c:	0003c597          	auipc	a1,0x3c
    80003f40:	a7c58593          	addi	a1,a1,-1412 # 8003f9b8 <sb>
    80003f44:	8526                	mv	a0,s1
    80003f46:	62a000ef          	jal	80004570 <initlog>
  ireclaim(dev);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	ee3ff0ef          	jal	80003e2e <ireclaim>
}
    80003f50:	70a2                	ld	ra,40(sp)
    80003f52:	7402                	ld	s0,32(sp)
    80003f54:	64e2                	ld	s1,24(sp)
    80003f56:	6942                	ld	s2,16(sp)
    80003f58:	69a2                	ld	s3,8(sp)
    80003f5a:	6145                	addi	sp,sp,48
    80003f5c:	8082                	ret
    panic("invalid file system");
    80003f5e:	00004517          	auipc	a0,0x4
    80003f62:	61250513          	addi	a0,a0,1554 # 80008570 <etext+0x570>
    80003f66:	87bfc0ef          	jal	800007e0 <panic>

0000000080003f6a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f6a:	1141                	addi	sp,sp,-16
    80003f6c:	e422                	sd	s0,8(sp)
    80003f6e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f70:	411c                	lw	a5,0(a0)
    80003f72:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f74:	415c                	lw	a5,4(a0)
    80003f76:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f78:	04451783          	lh	a5,68(a0)
    80003f7c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f80:	04a51783          	lh	a5,74(a0)
    80003f84:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f88:	04c56783          	lwu	a5,76(a0)
    80003f8c:	e99c                	sd	a5,16(a1)
}
    80003f8e:	6422                	ld	s0,8(sp)
    80003f90:	0141                	addi	sp,sp,16
    80003f92:	8082                	ret

0000000080003f94 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f94:	457c                	lw	a5,76(a0)
    80003f96:	0ed7eb63          	bltu	a5,a3,8000408c <readi+0xf8>
{
    80003f9a:	7159                	addi	sp,sp,-112
    80003f9c:	f486                	sd	ra,104(sp)
    80003f9e:	f0a2                	sd	s0,96(sp)
    80003fa0:	eca6                	sd	s1,88(sp)
    80003fa2:	e0d2                	sd	s4,64(sp)
    80003fa4:	fc56                	sd	s5,56(sp)
    80003fa6:	f85a                	sd	s6,48(sp)
    80003fa8:	f45e                	sd	s7,40(sp)
    80003faa:	1880                	addi	s0,sp,112
    80003fac:	8b2a                	mv	s6,a0
    80003fae:	8bae                	mv	s7,a1
    80003fb0:	8a32                	mv	s4,a2
    80003fb2:	84b6                	mv	s1,a3
    80003fb4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fb6:	9f35                	addw	a4,a4,a3
    return 0;
    80003fb8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fba:	0cd76063          	bltu	a4,a3,8000407a <readi+0xe6>
    80003fbe:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003fc0:	00e7f463          	bgeu	a5,a4,80003fc8 <readi+0x34>
    n = ip->size - off;
    80003fc4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fc8:	080a8f63          	beqz	s5,80004066 <readi+0xd2>
    80003fcc:	e8ca                	sd	s2,80(sp)
    80003fce:	f062                	sd	s8,32(sp)
    80003fd0:	ec66                	sd	s9,24(sp)
    80003fd2:	e86a                	sd	s10,16(sp)
    80003fd4:	e46e                	sd	s11,8(sp)
    80003fd6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fd8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fdc:	5c7d                	li	s8,-1
    80003fde:	a80d                	j	80004010 <readi+0x7c>
    80003fe0:	020d1d93          	slli	s11,s10,0x20
    80003fe4:	020ddd93          	srli	s11,s11,0x20
    80003fe8:	05890613          	addi	a2,s2,88
    80003fec:	86ee                	mv	a3,s11
    80003fee:	963a                	add	a2,a2,a4
    80003ff0:	85d2                	mv	a1,s4
    80003ff2:	855e                	mv	a0,s7
    80003ff4:	939fe0ef          	jal	8000292c <either_copyout>
    80003ff8:	05850763          	beq	a0,s8,80004046 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	e42ff0ef          	jal	80003640 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004002:	013d09bb          	addw	s3,s10,s3
    80004006:	009d04bb          	addw	s1,s10,s1
    8000400a:	9a6e                	add	s4,s4,s11
    8000400c:	0559f763          	bgeu	s3,s5,8000405a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80004010:	00a4d59b          	srliw	a1,s1,0xa
    80004014:	855a                	mv	a0,s6
    80004016:	8a7ff0ef          	jal	800038bc <bmap>
    8000401a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000401e:	c5b1                	beqz	a1,8000406a <readi+0xd6>
    bp = bread(ip->dev, addr);
    80004020:	000b2503          	lw	a0,0(s6)
    80004024:	d14ff0ef          	jal	80003538 <bread>
    80004028:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000402a:	3ff4f713          	andi	a4,s1,1023
    8000402e:	40ec87bb          	subw	a5,s9,a4
    80004032:	413a86bb          	subw	a3,s5,s3
    80004036:	8d3e                	mv	s10,a5
    80004038:	2781                	sext.w	a5,a5
    8000403a:	0006861b          	sext.w	a2,a3
    8000403e:	faf671e3          	bgeu	a2,a5,80003fe0 <readi+0x4c>
    80004042:	8d36                	mv	s10,a3
    80004044:	bf71                	j	80003fe0 <readi+0x4c>
      brelse(bp);
    80004046:	854a                	mv	a0,s2
    80004048:	df8ff0ef          	jal	80003640 <brelse>
      tot = -1;
    8000404c:	59fd                	li	s3,-1
      break;
    8000404e:	6946                	ld	s2,80(sp)
    80004050:	7c02                	ld	s8,32(sp)
    80004052:	6ce2                	ld	s9,24(sp)
    80004054:	6d42                	ld	s10,16(sp)
    80004056:	6da2                	ld	s11,8(sp)
    80004058:	a831                	j	80004074 <readi+0xe0>
    8000405a:	6946                	ld	s2,80(sp)
    8000405c:	7c02                	ld	s8,32(sp)
    8000405e:	6ce2                	ld	s9,24(sp)
    80004060:	6d42                	ld	s10,16(sp)
    80004062:	6da2                	ld	s11,8(sp)
    80004064:	a801                	j	80004074 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004066:	89d6                	mv	s3,s5
    80004068:	a031                	j	80004074 <readi+0xe0>
    8000406a:	6946                	ld	s2,80(sp)
    8000406c:	7c02                	ld	s8,32(sp)
    8000406e:	6ce2                	ld	s9,24(sp)
    80004070:	6d42                	ld	s10,16(sp)
    80004072:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80004074:	0009851b          	sext.w	a0,s3
    80004078:	69a6                	ld	s3,72(sp)
}
    8000407a:	70a6                	ld	ra,104(sp)
    8000407c:	7406                	ld	s0,96(sp)
    8000407e:	64e6                	ld	s1,88(sp)
    80004080:	6a06                	ld	s4,64(sp)
    80004082:	7ae2                	ld	s5,56(sp)
    80004084:	7b42                	ld	s6,48(sp)
    80004086:	7ba2                	ld	s7,40(sp)
    80004088:	6165                	addi	sp,sp,112
    8000408a:	8082                	ret
    return 0;
    8000408c:	4501                	li	a0,0
}
    8000408e:	8082                	ret

0000000080004090 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004090:	457c                	lw	a5,76(a0)
    80004092:	10d7e063          	bltu	a5,a3,80004192 <writei+0x102>
{
    80004096:	7159                	addi	sp,sp,-112
    80004098:	f486                	sd	ra,104(sp)
    8000409a:	f0a2                	sd	s0,96(sp)
    8000409c:	e8ca                	sd	s2,80(sp)
    8000409e:	e0d2                	sd	s4,64(sp)
    800040a0:	fc56                	sd	s5,56(sp)
    800040a2:	f85a                	sd	s6,48(sp)
    800040a4:	f45e                	sd	s7,40(sp)
    800040a6:	1880                	addi	s0,sp,112
    800040a8:	8aaa                	mv	s5,a0
    800040aa:	8bae                	mv	s7,a1
    800040ac:	8a32                	mv	s4,a2
    800040ae:	8936                	mv	s2,a3
    800040b0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040b2:	00e687bb          	addw	a5,a3,a4
    800040b6:	0ed7e063          	bltu	a5,a3,80004196 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040ba:	00043737          	lui	a4,0x43
    800040be:	0cf76e63          	bltu	a4,a5,8000419a <writei+0x10a>
    800040c2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040c4:	0a0b0f63          	beqz	s6,80004182 <writei+0xf2>
    800040c8:	eca6                	sd	s1,88(sp)
    800040ca:	f062                	sd	s8,32(sp)
    800040cc:	ec66                	sd	s9,24(sp)
    800040ce:	e86a                	sd	s10,16(sp)
    800040d0:	e46e                	sd	s11,8(sp)
    800040d2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040d4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040d8:	5c7d                	li	s8,-1
    800040da:	a825                	j	80004112 <writei+0x82>
    800040dc:	020d1d93          	slli	s11,s10,0x20
    800040e0:	020ddd93          	srli	s11,s11,0x20
    800040e4:	05848513          	addi	a0,s1,88
    800040e8:	86ee                	mv	a3,s11
    800040ea:	8652                	mv	a2,s4
    800040ec:	85de                	mv	a1,s7
    800040ee:	953a                	add	a0,a0,a4
    800040f0:	887fe0ef          	jal	80002976 <either_copyin>
    800040f4:	05850a63          	beq	a0,s8,80004148 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040f8:	8526                	mv	a0,s1
    800040fa:	678000ef          	jal	80004772 <log_write>
    brelse(bp);
    800040fe:	8526                	mv	a0,s1
    80004100:	d40ff0ef          	jal	80003640 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004104:	013d09bb          	addw	s3,s10,s3
    80004108:	012d093b          	addw	s2,s10,s2
    8000410c:	9a6e                	add	s4,s4,s11
    8000410e:	0569f063          	bgeu	s3,s6,8000414e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004112:	00a9559b          	srliw	a1,s2,0xa
    80004116:	8556                	mv	a0,s5
    80004118:	fa4ff0ef          	jal	800038bc <bmap>
    8000411c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004120:	c59d                	beqz	a1,8000414e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004122:	000aa503          	lw	a0,0(s5)
    80004126:	c12ff0ef          	jal	80003538 <bread>
    8000412a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000412c:	3ff97713          	andi	a4,s2,1023
    80004130:	40ec87bb          	subw	a5,s9,a4
    80004134:	413b06bb          	subw	a3,s6,s3
    80004138:	8d3e                	mv	s10,a5
    8000413a:	2781                	sext.w	a5,a5
    8000413c:	0006861b          	sext.w	a2,a3
    80004140:	f8f67ee3          	bgeu	a2,a5,800040dc <writei+0x4c>
    80004144:	8d36                	mv	s10,a3
    80004146:	bf59                	j	800040dc <writei+0x4c>
      brelse(bp);
    80004148:	8526                	mv	a0,s1
    8000414a:	cf6ff0ef          	jal	80003640 <brelse>
  }

  if(off > ip->size)
    8000414e:	04caa783          	lw	a5,76(s5)
    80004152:	0327fa63          	bgeu	a5,s2,80004186 <writei+0xf6>
    ip->size = off;
    80004156:	052aa623          	sw	s2,76(s5)
    8000415a:	64e6                	ld	s1,88(sp)
    8000415c:	7c02                	ld	s8,32(sp)
    8000415e:	6ce2                	ld	s9,24(sp)
    80004160:	6d42                	ld	s10,16(sp)
    80004162:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004164:	8556                	mv	a0,s5
    80004166:	9ebff0ef          	jal	80003b50 <iupdate>

  return tot;
    8000416a:	0009851b          	sext.w	a0,s3
    8000416e:	69a6                	ld	s3,72(sp)
}
    80004170:	70a6                	ld	ra,104(sp)
    80004172:	7406                	ld	s0,96(sp)
    80004174:	6946                	ld	s2,80(sp)
    80004176:	6a06                	ld	s4,64(sp)
    80004178:	7ae2                	ld	s5,56(sp)
    8000417a:	7b42                	ld	s6,48(sp)
    8000417c:	7ba2                	ld	s7,40(sp)
    8000417e:	6165                	addi	sp,sp,112
    80004180:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004182:	89da                	mv	s3,s6
    80004184:	b7c5                	j	80004164 <writei+0xd4>
    80004186:	64e6                	ld	s1,88(sp)
    80004188:	7c02                	ld	s8,32(sp)
    8000418a:	6ce2                	ld	s9,24(sp)
    8000418c:	6d42                	ld	s10,16(sp)
    8000418e:	6da2                	ld	s11,8(sp)
    80004190:	bfd1                	j	80004164 <writei+0xd4>
    return -1;
    80004192:	557d                	li	a0,-1
}
    80004194:	8082                	ret
    return -1;
    80004196:	557d                	li	a0,-1
    80004198:	bfe1                	j	80004170 <writei+0xe0>
    return -1;
    8000419a:	557d                	li	a0,-1
    8000419c:	bfd1                	j	80004170 <writei+0xe0>

000000008000419e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000419e:	1141                	addi	sp,sp,-16
    800041a0:	e406                	sd	ra,8(sp)
    800041a2:	e022                	sd	s0,0(sp)
    800041a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041a6:	4639                	li	a2,14
    800041a8:	dd3fc0ef          	jal	80000f7a <strncmp>
}
    800041ac:	60a2                	ld	ra,8(sp)
    800041ae:	6402                	ld	s0,0(sp)
    800041b0:	0141                	addi	sp,sp,16
    800041b2:	8082                	ret

00000000800041b4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041b4:	7139                	addi	sp,sp,-64
    800041b6:	fc06                	sd	ra,56(sp)
    800041b8:	f822                	sd	s0,48(sp)
    800041ba:	f426                	sd	s1,40(sp)
    800041bc:	f04a                	sd	s2,32(sp)
    800041be:	ec4e                	sd	s3,24(sp)
    800041c0:	e852                	sd	s4,16(sp)
    800041c2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041c4:	04451703          	lh	a4,68(a0)
    800041c8:	4785                	li	a5,1
    800041ca:	00f71a63          	bne	a4,a5,800041de <dirlookup+0x2a>
    800041ce:	892a                	mv	s2,a0
    800041d0:	89ae                	mv	s3,a1
    800041d2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d4:	457c                	lw	a5,76(a0)
    800041d6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041d8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041da:	e39d                	bnez	a5,80004200 <dirlookup+0x4c>
    800041dc:	a095                	j	80004240 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800041de:	00004517          	auipc	a0,0x4
    800041e2:	3aa50513          	addi	a0,a0,938 # 80008588 <etext+0x588>
    800041e6:	dfafc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800041ea:	00004517          	auipc	a0,0x4
    800041ee:	3b650513          	addi	a0,a0,950 # 800085a0 <etext+0x5a0>
    800041f2:	deefc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f6:	24c1                	addiw	s1,s1,16
    800041f8:	04c92783          	lw	a5,76(s2)
    800041fc:	04f4f163          	bgeu	s1,a5,8000423e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004200:	4741                	li	a4,16
    80004202:	86a6                	mv	a3,s1
    80004204:	fc040613          	addi	a2,s0,-64
    80004208:	4581                	li	a1,0
    8000420a:	854a                	mv	a0,s2
    8000420c:	d89ff0ef          	jal	80003f94 <readi>
    80004210:	47c1                	li	a5,16
    80004212:	fcf51ce3          	bne	a0,a5,800041ea <dirlookup+0x36>
    if(de.inum == 0)
    80004216:	fc045783          	lhu	a5,-64(s0)
    8000421a:	dff1                	beqz	a5,800041f6 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000421c:	fc240593          	addi	a1,s0,-62
    80004220:	854e                	mv	a0,s3
    80004222:	f7dff0ef          	jal	8000419e <namecmp>
    80004226:	f961                	bnez	a0,800041f6 <dirlookup+0x42>
      if(poff)
    80004228:	000a0463          	beqz	s4,80004230 <dirlookup+0x7c>
        *poff = off;
    8000422c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004230:	fc045583          	lhu	a1,-64(s0)
    80004234:	00092503          	lw	a0,0(s2)
    80004238:	f58ff0ef          	jal	80003990 <iget>
    8000423c:	a011                	j	80004240 <dirlookup+0x8c>
  return 0;
    8000423e:	4501                	li	a0,0
}
    80004240:	70e2                	ld	ra,56(sp)
    80004242:	7442                	ld	s0,48(sp)
    80004244:	74a2                	ld	s1,40(sp)
    80004246:	7902                	ld	s2,32(sp)
    80004248:	69e2                	ld	s3,24(sp)
    8000424a:	6a42                	ld	s4,16(sp)
    8000424c:	6121                	addi	sp,sp,64
    8000424e:	8082                	ret

0000000080004250 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004250:	711d                	addi	sp,sp,-96
    80004252:	ec86                	sd	ra,88(sp)
    80004254:	e8a2                	sd	s0,80(sp)
    80004256:	e4a6                	sd	s1,72(sp)
    80004258:	e0ca                	sd	s2,64(sp)
    8000425a:	fc4e                	sd	s3,56(sp)
    8000425c:	f852                	sd	s4,48(sp)
    8000425e:	f456                	sd	s5,40(sp)
    80004260:	f05a                	sd	s6,32(sp)
    80004262:	ec5e                	sd	s7,24(sp)
    80004264:	e862                	sd	s8,16(sp)
    80004266:	e466                	sd	s9,8(sp)
    80004268:	1080                	addi	s0,sp,96
    8000426a:	84aa                	mv	s1,a0
    8000426c:	8b2e                	mv	s6,a1
    8000426e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004270:	00054703          	lbu	a4,0(a0)
    80004274:	02f00793          	li	a5,47
    80004278:	00f70e63          	beq	a4,a5,80004294 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000427c:	afffd0ef          	jal	80001d7a <myproc>
    80004280:	15053503          	ld	a0,336(a0)
    80004284:	94bff0ef          	jal	80003bce <idup>
    80004288:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000428a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000428e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004290:	4b85                	li	s7,1
    80004292:	a871                	j	8000432e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80004294:	4585                	li	a1,1
    80004296:	4505                	li	a0,1
    80004298:	ef8ff0ef          	jal	80003990 <iget>
    8000429c:	8a2a                	mv	s4,a0
    8000429e:	b7f5                	j	8000428a <namex+0x3a>
      iunlockput(ip);
    800042a0:	8552                	mv	a0,s4
    800042a2:	b6dff0ef          	jal	80003e0e <iunlockput>
      return 0;
    800042a6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042a8:	8552                	mv	a0,s4
    800042aa:	60e6                	ld	ra,88(sp)
    800042ac:	6446                	ld	s0,80(sp)
    800042ae:	64a6                	ld	s1,72(sp)
    800042b0:	6906                	ld	s2,64(sp)
    800042b2:	79e2                	ld	s3,56(sp)
    800042b4:	7a42                	ld	s4,48(sp)
    800042b6:	7aa2                	ld	s5,40(sp)
    800042b8:	7b02                	ld	s6,32(sp)
    800042ba:	6be2                	ld	s7,24(sp)
    800042bc:	6c42                	ld	s8,16(sp)
    800042be:	6ca2                	ld	s9,8(sp)
    800042c0:	6125                	addi	sp,sp,96
    800042c2:	8082                	ret
      iunlock(ip);
    800042c4:	8552                	mv	a0,s4
    800042c6:	9edff0ef          	jal	80003cb2 <iunlock>
      return ip;
    800042ca:	bff9                	j	800042a8 <namex+0x58>
      iunlockput(ip);
    800042cc:	8552                	mv	a0,s4
    800042ce:	b41ff0ef          	jal	80003e0e <iunlockput>
      return 0;
    800042d2:	8a4e                	mv	s4,s3
    800042d4:	bfd1                	j	800042a8 <namex+0x58>
  len = path - s;
    800042d6:	40998633          	sub	a2,s3,s1
    800042da:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042de:	099c5063          	bge	s8,s9,8000435e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800042e2:	4639                	li	a2,14
    800042e4:	85a6                	mv	a1,s1
    800042e6:	8556                	mv	a0,s5
    800042e8:	c23fc0ef          	jal	80000f0a <memmove>
    800042ec:	84ce                	mv	s1,s3
  while(*path == '/')
    800042ee:	0004c783          	lbu	a5,0(s1)
    800042f2:	01279763          	bne	a5,s2,80004300 <namex+0xb0>
    path++;
    800042f6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042f8:	0004c783          	lbu	a5,0(s1)
    800042fc:	ff278de3          	beq	a5,s2,800042f6 <namex+0xa6>
    ilock(ip);
    80004300:	8552                	mv	a0,s4
    80004302:	903ff0ef          	jal	80003c04 <ilock>
    if(ip->type != T_DIR){
    80004306:	044a1783          	lh	a5,68(s4)
    8000430a:	f9779be3          	bne	a5,s7,800042a0 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000430e:	000b0563          	beqz	s6,80004318 <namex+0xc8>
    80004312:	0004c783          	lbu	a5,0(s1)
    80004316:	d7dd                	beqz	a5,800042c4 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004318:	4601                	li	a2,0
    8000431a:	85d6                	mv	a1,s5
    8000431c:	8552                	mv	a0,s4
    8000431e:	e97ff0ef          	jal	800041b4 <dirlookup>
    80004322:	89aa                	mv	s3,a0
    80004324:	d545                	beqz	a0,800042cc <namex+0x7c>
    iunlockput(ip);
    80004326:	8552                	mv	a0,s4
    80004328:	ae7ff0ef          	jal	80003e0e <iunlockput>
    ip = next;
    8000432c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000432e:	0004c783          	lbu	a5,0(s1)
    80004332:	01279763          	bne	a5,s2,80004340 <namex+0xf0>
    path++;
    80004336:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004338:	0004c783          	lbu	a5,0(s1)
    8000433c:	ff278de3          	beq	a5,s2,80004336 <namex+0xe6>
  if(*path == 0)
    80004340:	cb8d                	beqz	a5,80004372 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004342:	0004c783          	lbu	a5,0(s1)
    80004346:	89a6                	mv	s3,s1
  len = path - s;
    80004348:	4c81                	li	s9,0
    8000434a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000434c:	01278963          	beq	a5,s2,8000435e <namex+0x10e>
    80004350:	d3d9                	beqz	a5,800042d6 <namex+0x86>
    path++;
    80004352:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004354:	0009c783          	lbu	a5,0(s3)
    80004358:	ff279ce3          	bne	a5,s2,80004350 <namex+0x100>
    8000435c:	bfad                	j	800042d6 <namex+0x86>
    memmove(name, s, len);
    8000435e:	2601                	sext.w	a2,a2
    80004360:	85a6                	mv	a1,s1
    80004362:	8556                	mv	a0,s5
    80004364:	ba7fc0ef          	jal	80000f0a <memmove>
    name[len] = 0;
    80004368:	9cd6                	add	s9,s9,s5
    8000436a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000436e:	84ce                	mv	s1,s3
    80004370:	bfbd                	j	800042ee <namex+0x9e>
  if(nameiparent){
    80004372:	f20b0be3          	beqz	s6,800042a8 <namex+0x58>
    iput(ip);
    80004376:	8552                	mv	a0,s4
    80004378:	a0fff0ef          	jal	80003d86 <iput>
    return 0;
    8000437c:	4a01                	li	s4,0
    8000437e:	b72d                	j	800042a8 <namex+0x58>

0000000080004380 <dirlink>:
{
    80004380:	7139                	addi	sp,sp,-64
    80004382:	fc06                	sd	ra,56(sp)
    80004384:	f822                	sd	s0,48(sp)
    80004386:	f04a                	sd	s2,32(sp)
    80004388:	ec4e                	sd	s3,24(sp)
    8000438a:	e852                	sd	s4,16(sp)
    8000438c:	0080                	addi	s0,sp,64
    8000438e:	892a                	mv	s2,a0
    80004390:	8a2e                	mv	s4,a1
    80004392:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004394:	4601                	li	a2,0
    80004396:	e1fff0ef          	jal	800041b4 <dirlookup>
    8000439a:	e535                	bnez	a0,80004406 <dirlink+0x86>
    8000439c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000439e:	04c92483          	lw	s1,76(s2)
    800043a2:	c48d                	beqz	s1,800043cc <dirlink+0x4c>
    800043a4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a6:	4741                	li	a4,16
    800043a8:	86a6                	mv	a3,s1
    800043aa:	fc040613          	addi	a2,s0,-64
    800043ae:	4581                	li	a1,0
    800043b0:	854a                	mv	a0,s2
    800043b2:	be3ff0ef          	jal	80003f94 <readi>
    800043b6:	47c1                	li	a5,16
    800043b8:	04f51b63          	bne	a0,a5,8000440e <dirlink+0x8e>
    if(de.inum == 0)
    800043bc:	fc045783          	lhu	a5,-64(s0)
    800043c0:	c791                	beqz	a5,800043cc <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c2:	24c1                	addiw	s1,s1,16
    800043c4:	04c92783          	lw	a5,76(s2)
    800043c8:	fcf4efe3          	bltu	s1,a5,800043a6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800043cc:	4639                	li	a2,14
    800043ce:	85d2                	mv	a1,s4
    800043d0:	fc240513          	addi	a0,s0,-62
    800043d4:	bddfc0ef          	jal	80000fb0 <strncpy>
  de.inum = inum;
    800043d8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043dc:	4741                	li	a4,16
    800043de:	86a6                	mv	a3,s1
    800043e0:	fc040613          	addi	a2,s0,-64
    800043e4:	4581                	li	a1,0
    800043e6:	854a                	mv	a0,s2
    800043e8:	ca9ff0ef          	jal	80004090 <writei>
    800043ec:	1541                	addi	a0,a0,-16
    800043ee:	00a03533          	snez	a0,a0
    800043f2:	40a00533          	neg	a0,a0
    800043f6:	74a2                	ld	s1,40(sp)
}
    800043f8:	70e2                	ld	ra,56(sp)
    800043fa:	7442                	ld	s0,48(sp)
    800043fc:	7902                	ld	s2,32(sp)
    800043fe:	69e2                	ld	s3,24(sp)
    80004400:	6a42                	ld	s4,16(sp)
    80004402:	6121                	addi	sp,sp,64
    80004404:	8082                	ret
    iput(ip);
    80004406:	981ff0ef          	jal	80003d86 <iput>
    return -1;
    8000440a:	557d                	li	a0,-1
    8000440c:	b7f5                	j	800043f8 <dirlink+0x78>
      panic("dirlink read");
    8000440e:	00004517          	auipc	a0,0x4
    80004412:	1a250513          	addi	a0,a0,418 # 800085b0 <etext+0x5b0>
    80004416:	bcafc0ef          	jal	800007e0 <panic>

000000008000441a <namei>:

struct inode*
namei(char *path)
{
    8000441a:	1101                	addi	sp,sp,-32
    8000441c:	ec06                	sd	ra,24(sp)
    8000441e:	e822                	sd	s0,16(sp)
    80004420:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004422:	fe040613          	addi	a2,s0,-32
    80004426:	4581                	li	a1,0
    80004428:	e29ff0ef          	jal	80004250 <namex>
}
    8000442c:	60e2                	ld	ra,24(sp)
    8000442e:	6442                	ld	s0,16(sp)
    80004430:	6105                	addi	sp,sp,32
    80004432:	8082                	ret

0000000080004434 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004434:	1141                	addi	sp,sp,-16
    80004436:	e406                	sd	ra,8(sp)
    80004438:	e022                	sd	s0,0(sp)
    8000443a:	0800                	addi	s0,sp,16
    8000443c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000443e:	4585                	li	a1,1
    80004440:	e11ff0ef          	jal	80004250 <namex>
}
    80004444:	60a2                	ld	ra,8(sp)
    80004446:	6402                	ld	s0,0(sp)
    80004448:	0141                	addi	sp,sp,16
    8000444a:	8082                	ret

000000008000444c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000444c:	1101                	addi	sp,sp,-32
    8000444e:	ec06                	sd	ra,24(sp)
    80004450:	e822                	sd	s0,16(sp)
    80004452:	e426                	sd	s1,8(sp)
    80004454:	e04a                	sd	s2,0(sp)
    80004456:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004458:	0003d917          	auipc	s2,0x3d
    8000445c:	02890913          	addi	s2,s2,40 # 80041480 <log>
    80004460:	01892583          	lw	a1,24(s2)
    80004464:	02492503          	lw	a0,36(s2)
    80004468:	8d0ff0ef          	jal	80003538 <bread>
    8000446c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000446e:	02892603          	lw	a2,40(s2)
    80004472:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004474:	00c05f63          	blez	a2,80004492 <write_head+0x46>
    80004478:	0003d717          	auipc	a4,0x3d
    8000447c:	03470713          	addi	a4,a4,52 # 800414ac <log+0x2c>
    80004480:	87aa                	mv	a5,a0
    80004482:	060a                	slli	a2,a2,0x2
    80004484:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004486:	4314                	lw	a3,0(a4)
    80004488:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000448a:	0711                	addi	a4,a4,4
    8000448c:	0791                	addi	a5,a5,4
    8000448e:	fec79ce3          	bne	a5,a2,80004486 <write_head+0x3a>
  }
  bwrite(buf);
    80004492:	8526                	mv	a0,s1
    80004494:	97aff0ef          	jal	8000360e <bwrite>
  brelse(buf);
    80004498:	8526                	mv	a0,s1
    8000449a:	9a6ff0ef          	jal	80003640 <brelse>
}
    8000449e:	60e2                	ld	ra,24(sp)
    800044a0:	6442                	ld	s0,16(sp)
    800044a2:	64a2                	ld	s1,8(sp)
    800044a4:	6902                	ld	s2,0(sp)
    800044a6:	6105                	addi	sp,sp,32
    800044a8:	8082                	ret

00000000800044aa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044aa:	0003d797          	auipc	a5,0x3d
    800044ae:	ffe7a783          	lw	a5,-2(a5) # 800414a8 <log+0x28>
    800044b2:	0af05e63          	blez	a5,8000456e <install_trans+0xc4>
{
    800044b6:	715d                	addi	sp,sp,-80
    800044b8:	e486                	sd	ra,72(sp)
    800044ba:	e0a2                	sd	s0,64(sp)
    800044bc:	fc26                	sd	s1,56(sp)
    800044be:	f84a                	sd	s2,48(sp)
    800044c0:	f44e                	sd	s3,40(sp)
    800044c2:	f052                	sd	s4,32(sp)
    800044c4:	ec56                	sd	s5,24(sp)
    800044c6:	e85a                	sd	s6,16(sp)
    800044c8:	e45e                	sd	s7,8(sp)
    800044ca:	0880                	addi	s0,sp,80
    800044cc:	8b2a                	mv	s6,a0
    800044ce:	0003da97          	auipc	s5,0x3d
    800044d2:	fdea8a93          	addi	s5,s5,-34 # 800414ac <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044d6:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800044d8:	00004b97          	auipc	s7,0x4
    800044dc:	0e8b8b93          	addi	s7,s7,232 # 800085c0 <etext+0x5c0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044e0:	0003da17          	auipc	s4,0x3d
    800044e4:	fa0a0a13          	addi	s4,s4,-96 # 80041480 <log>
    800044e8:	a025                	j	80004510 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800044ea:	000aa603          	lw	a2,0(s5)
    800044ee:	85ce                	mv	a1,s3
    800044f0:	855e                	mv	a0,s7
    800044f2:	808fc0ef          	jal	800004fa <printf>
    800044f6:	a839                	j	80004514 <install_trans+0x6a>
    brelse(lbuf);
    800044f8:	854a                	mv	a0,s2
    800044fa:	946ff0ef          	jal	80003640 <brelse>
    brelse(dbuf);
    800044fe:	8526                	mv	a0,s1
    80004500:	940ff0ef          	jal	80003640 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004504:	2985                	addiw	s3,s3,1
    80004506:	0a91                	addi	s5,s5,4
    80004508:	028a2783          	lw	a5,40(s4)
    8000450c:	04f9d663          	bge	s3,a5,80004558 <install_trans+0xae>
    if(recovering) {
    80004510:	fc0b1de3          	bnez	s6,800044ea <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004514:	018a2583          	lw	a1,24(s4)
    80004518:	013585bb          	addw	a1,a1,s3
    8000451c:	2585                	addiw	a1,a1,1
    8000451e:	024a2503          	lw	a0,36(s4)
    80004522:	816ff0ef          	jal	80003538 <bread>
    80004526:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004528:	000aa583          	lw	a1,0(s5)
    8000452c:	024a2503          	lw	a0,36(s4)
    80004530:	808ff0ef          	jal	80003538 <bread>
    80004534:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004536:	40000613          	li	a2,1024
    8000453a:	05890593          	addi	a1,s2,88
    8000453e:	05850513          	addi	a0,a0,88
    80004542:	9c9fc0ef          	jal	80000f0a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004546:	8526                	mv	a0,s1
    80004548:	8c6ff0ef          	jal	8000360e <bwrite>
    if(recovering == 0)
    8000454c:	fa0b16e3          	bnez	s6,800044f8 <install_trans+0x4e>
      bunpin(dbuf);
    80004550:	8526                	mv	a0,s1
    80004552:	9aaff0ef          	jal	800036fc <bunpin>
    80004556:	b74d                	j	800044f8 <install_trans+0x4e>
}
    80004558:	60a6                	ld	ra,72(sp)
    8000455a:	6406                	ld	s0,64(sp)
    8000455c:	74e2                	ld	s1,56(sp)
    8000455e:	7942                	ld	s2,48(sp)
    80004560:	79a2                	ld	s3,40(sp)
    80004562:	7a02                	ld	s4,32(sp)
    80004564:	6ae2                	ld	s5,24(sp)
    80004566:	6b42                	ld	s6,16(sp)
    80004568:	6ba2                	ld	s7,8(sp)
    8000456a:	6161                	addi	sp,sp,80
    8000456c:	8082                	ret
    8000456e:	8082                	ret

0000000080004570 <initlog>:
{
    80004570:	7179                	addi	sp,sp,-48
    80004572:	f406                	sd	ra,40(sp)
    80004574:	f022                	sd	s0,32(sp)
    80004576:	ec26                	sd	s1,24(sp)
    80004578:	e84a                	sd	s2,16(sp)
    8000457a:	e44e                	sd	s3,8(sp)
    8000457c:	1800                	addi	s0,sp,48
    8000457e:	892a                	mv	s2,a0
    80004580:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004582:	0003d497          	auipc	s1,0x3d
    80004586:	efe48493          	addi	s1,s1,-258 # 80041480 <log>
    8000458a:	00004597          	auipc	a1,0x4
    8000458e:	05658593          	addi	a1,a1,86 # 800085e0 <etext+0x5e0>
    80004592:	8526                	mv	a0,s1
    80004594:	fc6fc0ef          	jal	80000d5a <initlock>
  log.start = sb->logstart;
    80004598:	0149a583          	lw	a1,20(s3)
    8000459c:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000459e:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045a2:	854a                	mv	a0,s2
    800045a4:	f95fe0ef          	jal	80003538 <bread>
  log.lh.n = lh->n;
    800045a8:	4d30                	lw	a2,88(a0)
    800045aa:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045ac:	00c05f63          	blez	a2,800045ca <initlog+0x5a>
    800045b0:	87aa                	mv	a5,a0
    800045b2:	0003d717          	auipc	a4,0x3d
    800045b6:	efa70713          	addi	a4,a4,-262 # 800414ac <log+0x2c>
    800045ba:	060a                	slli	a2,a2,0x2
    800045bc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800045be:	4ff4                	lw	a3,92(a5)
    800045c0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045c2:	0791                	addi	a5,a5,4
    800045c4:	0711                	addi	a4,a4,4
    800045c6:	fec79ce3          	bne	a5,a2,800045be <initlog+0x4e>
  brelse(buf);
    800045ca:	876ff0ef          	jal	80003640 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800045ce:	4505                	li	a0,1
    800045d0:	edbff0ef          	jal	800044aa <install_trans>
  log.lh.n = 0;
    800045d4:	0003d797          	auipc	a5,0x3d
    800045d8:	ec07aa23          	sw	zero,-300(a5) # 800414a8 <log+0x28>
  write_head(); // clear the log
    800045dc:	e71ff0ef          	jal	8000444c <write_head>
}
    800045e0:	70a2                	ld	ra,40(sp)
    800045e2:	7402                	ld	s0,32(sp)
    800045e4:	64e2                	ld	s1,24(sp)
    800045e6:	6942                	ld	s2,16(sp)
    800045e8:	69a2                	ld	s3,8(sp)
    800045ea:	6145                	addi	sp,sp,48
    800045ec:	8082                	ret

00000000800045ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045ee:	1101                	addi	sp,sp,-32
    800045f0:	ec06                	sd	ra,24(sp)
    800045f2:	e822                	sd	s0,16(sp)
    800045f4:	e426                	sd	s1,8(sp)
    800045f6:	e04a                	sd	s2,0(sp)
    800045f8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045fa:	0003d517          	auipc	a0,0x3d
    800045fe:	e8650513          	addi	a0,a0,-378 # 80041480 <log>
    80004602:	fd8fc0ef          	jal	80000dda <acquire>
  while(1){
    if(log.committing){
    80004606:	0003d497          	auipc	s1,0x3d
    8000460a:	e7a48493          	addi	s1,s1,-390 # 80041480 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000460e:	4979                	li	s2,30
    80004610:	a029                	j	8000461a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004612:	85a6                	mv	a1,s1
    80004614:	8526                	mv	a0,s1
    80004616:	f29fd0ef          	jal	8000253e <sleep>
    if(log.committing){
    8000461a:	509c                	lw	a5,32(s1)
    8000461c:	fbfd                	bnez	a5,80004612 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000461e:	4cd8                	lw	a4,28(s1)
    80004620:	2705                	addiw	a4,a4,1
    80004622:	0027179b          	slliw	a5,a4,0x2
    80004626:	9fb9                	addw	a5,a5,a4
    80004628:	0017979b          	slliw	a5,a5,0x1
    8000462c:	5494                	lw	a3,40(s1)
    8000462e:	9fb5                	addw	a5,a5,a3
    80004630:	00f95763          	bge	s2,a5,8000463e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004634:	85a6                	mv	a1,s1
    80004636:	8526                	mv	a0,s1
    80004638:	f07fd0ef          	jal	8000253e <sleep>
    8000463c:	bff9                	j	8000461a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000463e:	0003d517          	auipc	a0,0x3d
    80004642:	e4250513          	addi	a0,a0,-446 # 80041480 <log>
    80004646:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004648:	82bfc0ef          	jal	80000e72 <release>
      break;
    }
  }
}
    8000464c:	60e2                	ld	ra,24(sp)
    8000464e:	6442                	ld	s0,16(sp)
    80004650:	64a2                	ld	s1,8(sp)
    80004652:	6902                	ld	s2,0(sp)
    80004654:	6105                	addi	sp,sp,32
    80004656:	8082                	ret

0000000080004658 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004658:	7139                	addi	sp,sp,-64
    8000465a:	fc06                	sd	ra,56(sp)
    8000465c:	f822                	sd	s0,48(sp)
    8000465e:	f426                	sd	s1,40(sp)
    80004660:	f04a                	sd	s2,32(sp)
    80004662:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004664:	0003d497          	auipc	s1,0x3d
    80004668:	e1c48493          	addi	s1,s1,-484 # 80041480 <log>
    8000466c:	8526                	mv	a0,s1
    8000466e:	f6cfc0ef          	jal	80000dda <acquire>
  log.outstanding -= 1;
    80004672:	4cdc                	lw	a5,28(s1)
    80004674:	37fd                	addiw	a5,a5,-1
    80004676:	0007891b          	sext.w	s2,a5
    8000467a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000467c:	509c                	lw	a5,32(s1)
    8000467e:	ef9d                	bnez	a5,800046bc <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004680:	04091763          	bnez	s2,800046ce <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004684:	0003d497          	auipc	s1,0x3d
    80004688:	dfc48493          	addi	s1,s1,-516 # 80041480 <log>
    8000468c:	4785                	li	a5,1
    8000468e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004690:	8526                	mv	a0,s1
    80004692:	fe0fc0ef          	jal	80000e72 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004696:	549c                	lw	a5,40(s1)
    80004698:	04f04b63          	bgtz	a5,800046ee <end_op+0x96>
    acquire(&log.lock);
    8000469c:	0003d497          	auipc	s1,0x3d
    800046a0:	de448493          	addi	s1,s1,-540 # 80041480 <log>
    800046a4:	8526                	mv	a0,s1
    800046a6:	f34fc0ef          	jal	80000dda <acquire>
    log.committing = 0;
    800046aa:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800046ae:	8526                	mv	a0,s1
    800046b0:	edbfd0ef          	jal	8000258a <wakeup>
    release(&log.lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	fbcfc0ef          	jal	80000e72 <release>
}
    800046ba:	a025                	j	800046e2 <end_op+0x8a>
    800046bc:	ec4e                	sd	s3,24(sp)
    800046be:	e852                	sd	s4,16(sp)
    800046c0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800046c2:	00004517          	auipc	a0,0x4
    800046c6:	f2650513          	addi	a0,a0,-218 # 800085e8 <etext+0x5e8>
    800046ca:	916fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    800046ce:	0003d497          	auipc	s1,0x3d
    800046d2:	db248493          	addi	s1,s1,-590 # 80041480 <log>
    800046d6:	8526                	mv	a0,s1
    800046d8:	eb3fd0ef          	jal	8000258a <wakeup>
  release(&log.lock);
    800046dc:	8526                	mv	a0,s1
    800046de:	f94fc0ef          	jal	80000e72 <release>
}
    800046e2:	70e2                	ld	ra,56(sp)
    800046e4:	7442                	ld	s0,48(sp)
    800046e6:	74a2                	ld	s1,40(sp)
    800046e8:	7902                	ld	s2,32(sp)
    800046ea:	6121                	addi	sp,sp,64
    800046ec:	8082                	ret
    800046ee:	ec4e                	sd	s3,24(sp)
    800046f0:	e852                	sd	s4,16(sp)
    800046f2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800046f4:	0003da97          	auipc	s5,0x3d
    800046f8:	db8a8a93          	addi	s5,s5,-584 # 800414ac <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046fc:	0003da17          	auipc	s4,0x3d
    80004700:	d84a0a13          	addi	s4,s4,-636 # 80041480 <log>
    80004704:	018a2583          	lw	a1,24(s4)
    80004708:	012585bb          	addw	a1,a1,s2
    8000470c:	2585                	addiw	a1,a1,1
    8000470e:	024a2503          	lw	a0,36(s4)
    80004712:	e27fe0ef          	jal	80003538 <bread>
    80004716:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004718:	000aa583          	lw	a1,0(s5)
    8000471c:	024a2503          	lw	a0,36(s4)
    80004720:	e19fe0ef          	jal	80003538 <bread>
    80004724:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004726:	40000613          	li	a2,1024
    8000472a:	05850593          	addi	a1,a0,88
    8000472e:	05848513          	addi	a0,s1,88
    80004732:	fd8fc0ef          	jal	80000f0a <memmove>
    bwrite(to);  // write the log
    80004736:	8526                	mv	a0,s1
    80004738:	ed7fe0ef          	jal	8000360e <bwrite>
    brelse(from);
    8000473c:	854e                	mv	a0,s3
    8000473e:	f03fe0ef          	jal	80003640 <brelse>
    brelse(to);
    80004742:	8526                	mv	a0,s1
    80004744:	efdfe0ef          	jal	80003640 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004748:	2905                	addiw	s2,s2,1
    8000474a:	0a91                	addi	s5,s5,4
    8000474c:	028a2783          	lw	a5,40(s4)
    80004750:	faf94ae3          	blt	s2,a5,80004704 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004754:	cf9ff0ef          	jal	8000444c <write_head>
    install_trans(0); // Now install writes to home locations
    80004758:	4501                	li	a0,0
    8000475a:	d51ff0ef          	jal	800044aa <install_trans>
    log.lh.n = 0;
    8000475e:	0003d797          	auipc	a5,0x3d
    80004762:	d407a523          	sw	zero,-694(a5) # 800414a8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004766:	ce7ff0ef          	jal	8000444c <write_head>
    8000476a:	69e2                	ld	s3,24(sp)
    8000476c:	6a42                	ld	s4,16(sp)
    8000476e:	6aa2                	ld	s5,8(sp)
    80004770:	b735                	j	8000469c <end_op+0x44>

0000000080004772 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004772:	1101                	addi	sp,sp,-32
    80004774:	ec06                	sd	ra,24(sp)
    80004776:	e822                	sd	s0,16(sp)
    80004778:	e426                	sd	s1,8(sp)
    8000477a:	e04a                	sd	s2,0(sp)
    8000477c:	1000                	addi	s0,sp,32
    8000477e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004780:	0003d917          	auipc	s2,0x3d
    80004784:	d0090913          	addi	s2,s2,-768 # 80041480 <log>
    80004788:	854a                	mv	a0,s2
    8000478a:	e50fc0ef          	jal	80000dda <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000478e:	02892603          	lw	a2,40(s2)
    80004792:	47f5                	li	a5,29
    80004794:	04c7cc63          	blt	a5,a2,800047ec <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004798:	0003d797          	auipc	a5,0x3d
    8000479c:	d047a783          	lw	a5,-764(a5) # 8004149c <log+0x1c>
    800047a0:	04f05c63          	blez	a5,800047f8 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047a4:	4781                	li	a5,0
    800047a6:	04c05f63          	blez	a2,80004804 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047aa:	44cc                	lw	a1,12(s1)
    800047ac:	0003d717          	auipc	a4,0x3d
    800047b0:	d0070713          	addi	a4,a4,-768 # 800414ac <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800047b4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047b6:	4314                	lw	a3,0(a4)
    800047b8:	04b68663          	beq	a3,a1,80004804 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800047bc:	2785                	addiw	a5,a5,1
    800047be:	0711                	addi	a4,a4,4
    800047c0:	fef61be3          	bne	a2,a5,800047b6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047c4:	0621                	addi	a2,a2,8
    800047c6:	060a                	slli	a2,a2,0x2
    800047c8:	0003d797          	auipc	a5,0x3d
    800047cc:	cb878793          	addi	a5,a5,-840 # 80041480 <log>
    800047d0:	97b2                	add	a5,a5,a2
    800047d2:	44d8                	lw	a4,12(s1)
    800047d4:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047d6:	8526                	mv	a0,s1
    800047d8:	ef1fe0ef          	jal	800036c8 <bpin>
    log.lh.n++;
    800047dc:	0003d717          	auipc	a4,0x3d
    800047e0:	ca470713          	addi	a4,a4,-860 # 80041480 <log>
    800047e4:	571c                	lw	a5,40(a4)
    800047e6:	2785                	addiw	a5,a5,1
    800047e8:	d71c                	sw	a5,40(a4)
    800047ea:	a80d                	j	8000481c <log_write+0xaa>
    panic("too big a transaction");
    800047ec:	00004517          	auipc	a0,0x4
    800047f0:	e0c50513          	addi	a0,a0,-500 # 800085f8 <etext+0x5f8>
    800047f4:	fedfb0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800047f8:	00004517          	auipc	a0,0x4
    800047fc:	e1850513          	addi	a0,a0,-488 # 80008610 <etext+0x610>
    80004800:	fe1fb0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004804:	00878693          	addi	a3,a5,8
    80004808:	068a                	slli	a3,a3,0x2
    8000480a:	0003d717          	auipc	a4,0x3d
    8000480e:	c7670713          	addi	a4,a4,-906 # 80041480 <log>
    80004812:	9736                	add	a4,a4,a3
    80004814:	44d4                	lw	a3,12(s1)
    80004816:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004818:	faf60fe3          	beq	a2,a5,800047d6 <log_write+0x64>
  }
  release(&log.lock);
    8000481c:	0003d517          	auipc	a0,0x3d
    80004820:	c6450513          	addi	a0,a0,-924 # 80041480 <log>
    80004824:	e4efc0ef          	jal	80000e72 <release>
}
    80004828:	60e2                	ld	ra,24(sp)
    8000482a:	6442                	ld	s0,16(sp)
    8000482c:	64a2                	ld	s1,8(sp)
    8000482e:	6902                	ld	s2,0(sp)
    80004830:	6105                	addi	sp,sp,32
    80004832:	8082                	ret

0000000080004834 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004834:	1101                	addi	sp,sp,-32
    80004836:	ec06                	sd	ra,24(sp)
    80004838:	e822                	sd	s0,16(sp)
    8000483a:	e426                	sd	s1,8(sp)
    8000483c:	e04a                	sd	s2,0(sp)
    8000483e:	1000                	addi	s0,sp,32
    80004840:	84aa                	mv	s1,a0
    80004842:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004844:	00004597          	auipc	a1,0x4
    80004848:	dec58593          	addi	a1,a1,-532 # 80008630 <etext+0x630>
    8000484c:	0521                	addi	a0,a0,8
    8000484e:	d0cfc0ef          	jal	80000d5a <initlock>
  lk->name = name;
    80004852:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004856:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000485a:	0204a423          	sw	zero,40(s1)
}
    8000485e:	60e2                	ld	ra,24(sp)
    80004860:	6442                	ld	s0,16(sp)
    80004862:	64a2                	ld	s1,8(sp)
    80004864:	6902                	ld	s2,0(sp)
    80004866:	6105                	addi	sp,sp,32
    80004868:	8082                	ret

000000008000486a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000486a:	1101                	addi	sp,sp,-32
    8000486c:	ec06                	sd	ra,24(sp)
    8000486e:	e822                	sd	s0,16(sp)
    80004870:	e426                	sd	s1,8(sp)
    80004872:	e04a                	sd	s2,0(sp)
    80004874:	1000                	addi	s0,sp,32
    80004876:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004878:	00850913          	addi	s2,a0,8
    8000487c:	854a                	mv	a0,s2
    8000487e:	d5cfc0ef          	jal	80000dda <acquire>
  while (lk->locked) {
    80004882:	409c                	lw	a5,0(s1)
    80004884:	c799                	beqz	a5,80004892 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004886:	85ca                	mv	a1,s2
    80004888:	8526                	mv	a0,s1
    8000488a:	cb5fd0ef          	jal	8000253e <sleep>
  while (lk->locked) {
    8000488e:	409c                	lw	a5,0(s1)
    80004890:	fbfd                	bnez	a5,80004886 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004892:	4785                	li	a5,1
    80004894:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004896:	ce4fd0ef          	jal	80001d7a <myproc>
    8000489a:	591c                	lw	a5,48(a0)
    8000489c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000489e:	854a                	mv	a0,s2
    800048a0:	dd2fc0ef          	jal	80000e72 <release>
}
    800048a4:	60e2                	ld	ra,24(sp)
    800048a6:	6442                	ld	s0,16(sp)
    800048a8:	64a2                	ld	s1,8(sp)
    800048aa:	6902                	ld	s2,0(sp)
    800048ac:	6105                	addi	sp,sp,32
    800048ae:	8082                	ret

00000000800048b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048b0:	1101                	addi	sp,sp,-32
    800048b2:	ec06                	sd	ra,24(sp)
    800048b4:	e822                	sd	s0,16(sp)
    800048b6:	e426                	sd	s1,8(sp)
    800048b8:	e04a                	sd	s2,0(sp)
    800048ba:	1000                	addi	s0,sp,32
    800048bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048be:	00850913          	addi	s2,a0,8
    800048c2:	854a                	mv	a0,s2
    800048c4:	d16fc0ef          	jal	80000dda <acquire>
  lk->locked = 0;
    800048c8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048cc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048d0:	8526                	mv	a0,s1
    800048d2:	cb9fd0ef          	jal	8000258a <wakeup>
  release(&lk->lk);
    800048d6:	854a                	mv	a0,s2
    800048d8:	d9afc0ef          	jal	80000e72 <release>
}
    800048dc:	60e2                	ld	ra,24(sp)
    800048de:	6442                	ld	s0,16(sp)
    800048e0:	64a2                	ld	s1,8(sp)
    800048e2:	6902                	ld	s2,0(sp)
    800048e4:	6105                	addi	sp,sp,32
    800048e6:	8082                	ret

00000000800048e8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048e8:	7179                	addi	sp,sp,-48
    800048ea:	f406                	sd	ra,40(sp)
    800048ec:	f022                	sd	s0,32(sp)
    800048ee:	ec26                	sd	s1,24(sp)
    800048f0:	e84a                	sd	s2,16(sp)
    800048f2:	1800                	addi	s0,sp,48
    800048f4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048f6:	00850913          	addi	s2,a0,8
    800048fa:	854a                	mv	a0,s2
    800048fc:	cdefc0ef          	jal	80000dda <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004900:	409c                	lw	a5,0(s1)
    80004902:	ef81                	bnez	a5,8000491a <holdingsleep+0x32>
    80004904:	4481                	li	s1,0
  release(&lk->lk);
    80004906:	854a                	mv	a0,s2
    80004908:	d6afc0ef          	jal	80000e72 <release>
  return r;
}
    8000490c:	8526                	mv	a0,s1
    8000490e:	70a2                	ld	ra,40(sp)
    80004910:	7402                	ld	s0,32(sp)
    80004912:	64e2                	ld	s1,24(sp)
    80004914:	6942                	ld	s2,16(sp)
    80004916:	6145                	addi	sp,sp,48
    80004918:	8082                	ret
    8000491a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000491c:	0284a983          	lw	s3,40(s1)
    80004920:	c5afd0ef          	jal	80001d7a <myproc>
    80004924:	5904                	lw	s1,48(a0)
    80004926:	413484b3          	sub	s1,s1,s3
    8000492a:	0014b493          	seqz	s1,s1
    8000492e:	69a2                	ld	s3,8(sp)
    80004930:	bfd9                	j	80004906 <holdingsleep+0x1e>

0000000080004932 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004932:	1141                	addi	sp,sp,-16
    80004934:	e406                	sd	ra,8(sp)
    80004936:	e022                	sd	s0,0(sp)
    80004938:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000493a:	00004597          	auipc	a1,0x4
    8000493e:	d0658593          	addi	a1,a1,-762 # 80008640 <etext+0x640>
    80004942:	0003d517          	auipc	a0,0x3d
    80004946:	c8650513          	addi	a0,a0,-890 # 800415c8 <ftable>
    8000494a:	c10fc0ef          	jal	80000d5a <initlock>
}
    8000494e:	60a2                	ld	ra,8(sp)
    80004950:	6402                	ld	s0,0(sp)
    80004952:	0141                	addi	sp,sp,16
    80004954:	8082                	ret

0000000080004956 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004956:	1101                	addi	sp,sp,-32
    80004958:	ec06                	sd	ra,24(sp)
    8000495a:	e822                	sd	s0,16(sp)
    8000495c:	e426                	sd	s1,8(sp)
    8000495e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004960:	0003d517          	auipc	a0,0x3d
    80004964:	c6850513          	addi	a0,a0,-920 # 800415c8 <ftable>
    80004968:	c72fc0ef          	jal	80000dda <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000496c:	0003d497          	auipc	s1,0x3d
    80004970:	c7448493          	addi	s1,s1,-908 # 800415e0 <ftable+0x18>
    80004974:	0003e717          	auipc	a4,0x3e
    80004978:	c0c70713          	addi	a4,a4,-1012 # 80042580 <disk>
    if(f->ref == 0){
    8000497c:	40dc                	lw	a5,4(s1)
    8000497e:	cf89                	beqz	a5,80004998 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004980:	02848493          	addi	s1,s1,40
    80004984:	fee49ce3          	bne	s1,a4,8000497c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004988:	0003d517          	auipc	a0,0x3d
    8000498c:	c4050513          	addi	a0,a0,-960 # 800415c8 <ftable>
    80004990:	ce2fc0ef          	jal	80000e72 <release>
  return 0;
    80004994:	4481                	li	s1,0
    80004996:	a809                	j	800049a8 <filealloc+0x52>
      f->ref = 1;
    80004998:	4785                	li	a5,1
    8000499a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000499c:	0003d517          	auipc	a0,0x3d
    800049a0:	c2c50513          	addi	a0,a0,-980 # 800415c8 <ftable>
    800049a4:	ccefc0ef          	jal	80000e72 <release>
}
    800049a8:	8526                	mv	a0,s1
    800049aa:	60e2                	ld	ra,24(sp)
    800049ac:	6442                	ld	s0,16(sp)
    800049ae:	64a2                	ld	s1,8(sp)
    800049b0:	6105                	addi	sp,sp,32
    800049b2:	8082                	ret

00000000800049b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049b4:	1101                	addi	sp,sp,-32
    800049b6:	ec06                	sd	ra,24(sp)
    800049b8:	e822                	sd	s0,16(sp)
    800049ba:	e426                	sd	s1,8(sp)
    800049bc:	1000                	addi	s0,sp,32
    800049be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049c0:	0003d517          	auipc	a0,0x3d
    800049c4:	c0850513          	addi	a0,a0,-1016 # 800415c8 <ftable>
    800049c8:	c12fc0ef          	jal	80000dda <acquire>
  if(f->ref < 1)
    800049cc:	40dc                	lw	a5,4(s1)
    800049ce:	02f05063          	blez	a5,800049ee <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800049d2:	2785                	addiw	a5,a5,1
    800049d4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049d6:	0003d517          	auipc	a0,0x3d
    800049da:	bf250513          	addi	a0,a0,-1038 # 800415c8 <ftable>
    800049de:	c94fc0ef          	jal	80000e72 <release>
  return f;
}
    800049e2:	8526                	mv	a0,s1
    800049e4:	60e2                	ld	ra,24(sp)
    800049e6:	6442                	ld	s0,16(sp)
    800049e8:	64a2                	ld	s1,8(sp)
    800049ea:	6105                	addi	sp,sp,32
    800049ec:	8082                	ret
    panic("filedup");
    800049ee:	00004517          	auipc	a0,0x4
    800049f2:	c5a50513          	addi	a0,a0,-934 # 80008648 <etext+0x648>
    800049f6:	debfb0ef          	jal	800007e0 <panic>

00000000800049fa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049fa:	7139                	addi	sp,sp,-64
    800049fc:	fc06                	sd	ra,56(sp)
    800049fe:	f822                	sd	s0,48(sp)
    80004a00:	f426                	sd	s1,40(sp)
    80004a02:	0080                	addi	s0,sp,64
    80004a04:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a06:	0003d517          	auipc	a0,0x3d
    80004a0a:	bc250513          	addi	a0,a0,-1086 # 800415c8 <ftable>
    80004a0e:	bccfc0ef          	jal	80000dda <acquire>
  if(f->ref < 1)
    80004a12:	40dc                	lw	a5,4(s1)
    80004a14:	04f05a63          	blez	a5,80004a68 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004a18:	37fd                	addiw	a5,a5,-1
    80004a1a:	0007871b          	sext.w	a4,a5
    80004a1e:	c0dc                	sw	a5,4(s1)
    80004a20:	04e04e63          	bgtz	a4,80004a7c <fileclose+0x82>
    80004a24:	f04a                	sd	s2,32(sp)
    80004a26:	ec4e                	sd	s3,24(sp)
    80004a28:	e852                	sd	s4,16(sp)
    80004a2a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a2c:	0004a903          	lw	s2,0(s1)
    80004a30:	0094ca83          	lbu	s5,9(s1)
    80004a34:	0104ba03          	ld	s4,16(s1)
    80004a38:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a3c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a40:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a44:	0003d517          	auipc	a0,0x3d
    80004a48:	b8450513          	addi	a0,a0,-1148 # 800415c8 <ftable>
    80004a4c:	c26fc0ef          	jal	80000e72 <release>

  if(ff.type == FD_PIPE){
    80004a50:	4785                	li	a5,1
    80004a52:	04f90063          	beq	s2,a5,80004a92 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a56:	3979                	addiw	s2,s2,-2
    80004a58:	4785                	li	a5,1
    80004a5a:	0527f563          	bgeu	a5,s2,80004aa4 <fileclose+0xaa>
    80004a5e:	7902                	ld	s2,32(sp)
    80004a60:	69e2                	ld	s3,24(sp)
    80004a62:	6a42                	ld	s4,16(sp)
    80004a64:	6aa2                	ld	s5,8(sp)
    80004a66:	a00d                	j	80004a88 <fileclose+0x8e>
    80004a68:	f04a                	sd	s2,32(sp)
    80004a6a:	ec4e                	sd	s3,24(sp)
    80004a6c:	e852                	sd	s4,16(sp)
    80004a6e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004a70:	00004517          	auipc	a0,0x4
    80004a74:	be050513          	addi	a0,a0,-1056 # 80008650 <etext+0x650>
    80004a78:	d69fb0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004a7c:	0003d517          	auipc	a0,0x3d
    80004a80:	b4c50513          	addi	a0,a0,-1204 # 800415c8 <ftable>
    80004a84:	beefc0ef          	jal	80000e72 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004a88:	70e2                	ld	ra,56(sp)
    80004a8a:	7442                	ld	s0,48(sp)
    80004a8c:	74a2                	ld	s1,40(sp)
    80004a8e:	6121                	addi	sp,sp,64
    80004a90:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a92:	85d6                	mv	a1,s5
    80004a94:	8552                	mv	a0,s4
    80004a96:	336000ef          	jal	80004dcc <pipeclose>
    80004a9a:	7902                	ld	s2,32(sp)
    80004a9c:	69e2                	ld	s3,24(sp)
    80004a9e:	6a42                	ld	s4,16(sp)
    80004aa0:	6aa2                	ld	s5,8(sp)
    80004aa2:	b7dd                	j	80004a88 <fileclose+0x8e>
    begin_op();
    80004aa4:	b4bff0ef          	jal	800045ee <begin_op>
    iput(ff.ip);
    80004aa8:	854e                	mv	a0,s3
    80004aaa:	adcff0ef          	jal	80003d86 <iput>
    end_op();
    80004aae:	babff0ef          	jal	80004658 <end_op>
    80004ab2:	7902                	ld	s2,32(sp)
    80004ab4:	69e2                	ld	s3,24(sp)
    80004ab6:	6a42                	ld	s4,16(sp)
    80004ab8:	6aa2                	ld	s5,8(sp)
    80004aba:	b7f9                	j	80004a88 <fileclose+0x8e>

0000000080004abc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004abc:	715d                	addi	sp,sp,-80
    80004abe:	e486                	sd	ra,72(sp)
    80004ac0:	e0a2                	sd	s0,64(sp)
    80004ac2:	fc26                	sd	s1,56(sp)
    80004ac4:	f44e                	sd	s3,40(sp)
    80004ac6:	0880                	addi	s0,sp,80
    80004ac8:	84aa                	mv	s1,a0
    80004aca:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004acc:	aaefd0ef          	jal	80001d7a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ad0:	409c                	lw	a5,0(s1)
    80004ad2:	37f9                	addiw	a5,a5,-2
    80004ad4:	4705                	li	a4,1
    80004ad6:	04f76063          	bltu	a4,a5,80004b16 <filestat+0x5a>
    80004ada:	f84a                	sd	s2,48(sp)
    80004adc:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ade:	6c88                	ld	a0,24(s1)
    80004ae0:	924ff0ef          	jal	80003c04 <ilock>
    stati(f->ip, &st);
    80004ae4:	fb840593          	addi	a1,s0,-72
    80004ae8:	6c88                	ld	a0,24(s1)
    80004aea:	c80ff0ef          	jal	80003f6a <stati>
    iunlock(f->ip);
    80004aee:	6c88                	ld	a0,24(s1)
    80004af0:	9c2ff0ef          	jal	80003cb2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004af4:	46e1                	li	a3,24
    80004af6:	fb840613          	addi	a2,s0,-72
    80004afa:	85ce                	mv	a1,s3
    80004afc:	05093503          	ld	a0,80(s2)
    80004b00:	e59fc0ef          	jal	80001958 <copyout>
    80004b04:	41f5551b          	sraiw	a0,a0,0x1f
    80004b08:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004b0a:	60a6                	ld	ra,72(sp)
    80004b0c:	6406                	ld	s0,64(sp)
    80004b0e:	74e2                	ld	s1,56(sp)
    80004b10:	79a2                	ld	s3,40(sp)
    80004b12:	6161                	addi	sp,sp,80
    80004b14:	8082                	ret
  return -1;
    80004b16:	557d                	li	a0,-1
    80004b18:	bfcd                	j	80004b0a <filestat+0x4e>

0000000080004b1a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b1a:	7179                	addi	sp,sp,-48
    80004b1c:	f406                	sd	ra,40(sp)
    80004b1e:	f022                	sd	s0,32(sp)
    80004b20:	e84a                	sd	s2,16(sp)
    80004b22:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b24:	00854783          	lbu	a5,8(a0)
    80004b28:	cfd1                	beqz	a5,80004bc4 <fileread+0xaa>
    80004b2a:	ec26                	sd	s1,24(sp)
    80004b2c:	e44e                	sd	s3,8(sp)
    80004b2e:	84aa                	mv	s1,a0
    80004b30:	89ae                	mv	s3,a1
    80004b32:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b34:	411c                	lw	a5,0(a0)
    80004b36:	4705                	li	a4,1
    80004b38:	04e78363          	beq	a5,a4,80004b7e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b3c:	470d                	li	a4,3
    80004b3e:	04e78763          	beq	a5,a4,80004b8c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b42:	4709                	li	a4,2
    80004b44:	06e79a63          	bne	a5,a4,80004bb8 <fileread+0x9e>
    ilock(f->ip);
    80004b48:	6d08                	ld	a0,24(a0)
    80004b4a:	8baff0ef          	jal	80003c04 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b4e:	874a                	mv	a4,s2
    80004b50:	5094                	lw	a3,32(s1)
    80004b52:	864e                	mv	a2,s3
    80004b54:	4585                	li	a1,1
    80004b56:	6c88                	ld	a0,24(s1)
    80004b58:	c3cff0ef          	jal	80003f94 <readi>
    80004b5c:	892a                	mv	s2,a0
    80004b5e:	00a05563          	blez	a0,80004b68 <fileread+0x4e>
      f->off += r;
    80004b62:	509c                	lw	a5,32(s1)
    80004b64:	9fa9                	addw	a5,a5,a0
    80004b66:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b68:	6c88                	ld	a0,24(s1)
    80004b6a:	948ff0ef          	jal	80003cb2 <iunlock>
    80004b6e:	64e2                	ld	s1,24(sp)
    80004b70:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004b72:	854a                	mv	a0,s2
    80004b74:	70a2                	ld	ra,40(sp)
    80004b76:	7402                	ld	s0,32(sp)
    80004b78:	6942                	ld	s2,16(sp)
    80004b7a:	6145                	addi	sp,sp,48
    80004b7c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b7e:	6908                	ld	a0,16(a0)
    80004b80:	388000ef          	jal	80004f08 <piperead>
    80004b84:	892a                	mv	s2,a0
    80004b86:	64e2                	ld	s1,24(sp)
    80004b88:	69a2                	ld	s3,8(sp)
    80004b8a:	b7e5                	j	80004b72 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b8c:	02451783          	lh	a5,36(a0)
    80004b90:	03079693          	slli	a3,a5,0x30
    80004b94:	92c1                	srli	a3,a3,0x30
    80004b96:	4725                	li	a4,9
    80004b98:	02d76863          	bltu	a4,a3,80004bc8 <fileread+0xae>
    80004b9c:	0792                	slli	a5,a5,0x4
    80004b9e:	0003d717          	auipc	a4,0x3d
    80004ba2:	98a70713          	addi	a4,a4,-1654 # 80041528 <devsw>
    80004ba6:	97ba                	add	a5,a5,a4
    80004ba8:	639c                	ld	a5,0(a5)
    80004baa:	c39d                	beqz	a5,80004bd0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004bac:	4505                	li	a0,1
    80004bae:	9782                	jalr	a5
    80004bb0:	892a                	mv	s2,a0
    80004bb2:	64e2                	ld	s1,24(sp)
    80004bb4:	69a2                	ld	s3,8(sp)
    80004bb6:	bf75                	j	80004b72 <fileread+0x58>
    panic("fileread");
    80004bb8:	00004517          	auipc	a0,0x4
    80004bbc:	aa850513          	addi	a0,a0,-1368 # 80008660 <etext+0x660>
    80004bc0:	c21fb0ef          	jal	800007e0 <panic>
    return -1;
    80004bc4:	597d                	li	s2,-1
    80004bc6:	b775                	j	80004b72 <fileread+0x58>
      return -1;
    80004bc8:	597d                	li	s2,-1
    80004bca:	64e2                	ld	s1,24(sp)
    80004bcc:	69a2                	ld	s3,8(sp)
    80004bce:	b755                	j	80004b72 <fileread+0x58>
    80004bd0:	597d                	li	s2,-1
    80004bd2:	64e2                	ld	s1,24(sp)
    80004bd4:	69a2                	ld	s3,8(sp)
    80004bd6:	bf71                	j	80004b72 <fileread+0x58>

0000000080004bd8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004bd8:	00954783          	lbu	a5,9(a0)
    80004bdc:	10078b63          	beqz	a5,80004cf2 <filewrite+0x11a>
{
    80004be0:	715d                	addi	sp,sp,-80
    80004be2:	e486                	sd	ra,72(sp)
    80004be4:	e0a2                	sd	s0,64(sp)
    80004be6:	f84a                	sd	s2,48(sp)
    80004be8:	f052                	sd	s4,32(sp)
    80004bea:	e85a                	sd	s6,16(sp)
    80004bec:	0880                	addi	s0,sp,80
    80004bee:	892a                	mv	s2,a0
    80004bf0:	8b2e                	mv	s6,a1
    80004bf2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf4:	411c                	lw	a5,0(a0)
    80004bf6:	4705                	li	a4,1
    80004bf8:	02e78763          	beq	a5,a4,80004c26 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bfc:	470d                	li	a4,3
    80004bfe:	02e78863          	beq	a5,a4,80004c2e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c02:	4709                	li	a4,2
    80004c04:	0ce79c63          	bne	a5,a4,80004cdc <filewrite+0x104>
    80004c08:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c0a:	0ac05863          	blez	a2,80004cba <filewrite+0xe2>
    80004c0e:	fc26                	sd	s1,56(sp)
    80004c10:	ec56                	sd	s5,24(sp)
    80004c12:	e45e                	sd	s7,8(sp)
    80004c14:	e062                	sd	s8,0(sp)
    int i = 0;
    80004c16:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004c18:	6b85                	lui	s7,0x1
    80004c1a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c1e:	6c05                	lui	s8,0x1
    80004c20:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c24:	a8b5                	j	80004ca0 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004c26:	6908                	ld	a0,16(a0)
    80004c28:	1fc000ef          	jal	80004e24 <pipewrite>
    80004c2c:	a04d                	j	80004cce <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c2e:	02451783          	lh	a5,36(a0)
    80004c32:	03079693          	slli	a3,a5,0x30
    80004c36:	92c1                	srli	a3,a3,0x30
    80004c38:	4725                	li	a4,9
    80004c3a:	0ad76e63          	bltu	a4,a3,80004cf6 <filewrite+0x11e>
    80004c3e:	0792                	slli	a5,a5,0x4
    80004c40:	0003d717          	auipc	a4,0x3d
    80004c44:	8e870713          	addi	a4,a4,-1816 # 80041528 <devsw>
    80004c48:	97ba                	add	a5,a5,a4
    80004c4a:	679c                	ld	a5,8(a5)
    80004c4c:	c7dd                	beqz	a5,80004cfa <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004c4e:	4505                	li	a0,1
    80004c50:	9782                	jalr	a5
    80004c52:	a8b5                	j	80004cce <filewrite+0xf6>
      if(n1 > max)
    80004c54:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004c58:	997ff0ef          	jal	800045ee <begin_op>
      ilock(f->ip);
    80004c5c:	01893503          	ld	a0,24(s2)
    80004c60:	fa5fe0ef          	jal	80003c04 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c64:	8756                	mv	a4,s5
    80004c66:	02092683          	lw	a3,32(s2)
    80004c6a:	01698633          	add	a2,s3,s6
    80004c6e:	4585                	li	a1,1
    80004c70:	01893503          	ld	a0,24(s2)
    80004c74:	c1cff0ef          	jal	80004090 <writei>
    80004c78:	84aa                	mv	s1,a0
    80004c7a:	00a05763          	blez	a0,80004c88 <filewrite+0xb0>
        f->off += r;
    80004c7e:	02092783          	lw	a5,32(s2)
    80004c82:	9fa9                	addw	a5,a5,a0
    80004c84:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c88:	01893503          	ld	a0,24(s2)
    80004c8c:	826ff0ef          	jal	80003cb2 <iunlock>
      end_op();
    80004c90:	9c9ff0ef          	jal	80004658 <end_op>

      if(r != n1){
    80004c94:	029a9563          	bne	s5,s1,80004cbe <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004c98:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c9c:	0149da63          	bge	s3,s4,80004cb0 <filewrite+0xd8>
      int n1 = n - i;
    80004ca0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004ca4:	0004879b          	sext.w	a5,s1
    80004ca8:	fafbd6e3          	bge	s7,a5,80004c54 <filewrite+0x7c>
    80004cac:	84e2                	mv	s1,s8
    80004cae:	b75d                	j	80004c54 <filewrite+0x7c>
    80004cb0:	74e2                	ld	s1,56(sp)
    80004cb2:	6ae2                	ld	s5,24(sp)
    80004cb4:	6ba2                	ld	s7,8(sp)
    80004cb6:	6c02                	ld	s8,0(sp)
    80004cb8:	a039                	j	80004cc6 <filewrite+0xee>
    int i = 0;
    80004cba:	4981                	li	s3,0
    80004cbc:	a029                	j	80004cc6 <filewrite+0xee>
    80004cbe:	74e2                	ld	s1,56(sp)
    80004cc0:	6ae2                	ld	s5,24(sp)
    80004cc2:	6ba2                	ld	s7,8(sp)
    80004cc4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004cc6:	033a1c63          	bne	s4,s3,80004cfe <filewrite+0x126>
    80004cca:	8552                	mv	a0,s4
    80004ccc:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cce:	60a6                	ld	ra,72(sp)
    80004cd0:	6406                	ld	s0,64(sp)
    80004cd2:	7942                	ld	s2,48(sp)
    80004cd4:	7a02                	ld	s4,32(sp)
    80004cd6:	6b42                	ld	s6,16(sp)
    80004cd8:	6161                	addi	sp,sp,80
    80004cda:	8082                	ret
    80004cdc:	fc26                	sd	s1,56(sp)
    80004cde:	f44e                	sd	s3,40(sp)
    80004ce0:	ec56                	sd	s5,24(sp)
    80004ce2:	e45e                	sd	s7,8(sp)
    80004ce4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004ce6:	00004517          	auipc	a0,0x4
    80004cea:	98a50513          	addi	a0,a0,-1654 # 80008670 <etext+0x670>
    80004cee:	af3fb0ef          	jal	800007e0 <panic>
    return -1;
    80004cf2:	557d                	li	a0,-1
}
    80004cf4:	8082                	ret
      return -1;
    80004cf6:	557d                	li	a0,-1
    80004cf8:	bfd9                	j	80004cce <filewrite+0xf6>
    80004cfa:	557d                	li	a0,-1
    80004cfc:	bfc9                	j	80004cce <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004cfe:	557d                	li	a0,-1
    80004d00:	79a2                	ld	s3,40(sp)
    80004d02:	b7f1                	j	80004cce <filewrite+0xf6>

0000000080004d04 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d04:	7179                	addi	sp,sp,-48
    80004d06:	f406                	sd	ra,40(sp)
    80004d08:	f022                	sd	s0,32(sp)
    80004d0a:	ec26                	sd	s1,24(sp)
    80004d0c:	e052                	sd	s4,0(sp)
    80004d0e:	1800                	addi	s0,sp,48
    80004d10:	84aa                	mv	s1,a0
    80004d12:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d14:	0005b023          	sd	zero,0(a1)
    80004d18:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d1c:	c3bff0ef          	jal	80004956 <filealloc>
    80004d20:	e088                	sd	a0,0(s1)
    80004d22:	c549                	beqz	a0,80004dac <pipealloc+0xa8>
    80004d24:	c33ff0ef          	jal	80004956 <filealloc>
    80004d28:	00aa3023          	sd	a0,0(s4)
    80004d2c:	cd25                	beqz	a0,80004da4 <pipealloc+0xa0>
    80004d2e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d30:	fb1fb0ef          	jal	80000ce0 <kalloc>
    80004d34:	892a                	mv	s2,a0
    80004d36:	c12d                	beqz	a0,80004d98 <pipealloc+0x94>
    80004d38:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004d3a:	4985                	li	s3,1
    80004d3c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d40:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d44:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d48:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d4c:	00004597          	auipc	a1,0x4
    80004d50:	93458593          	addi	a1,a1,-1740 # 80008680 <etext+0x680>
    80004d54:	806fc0ef          	jal	80000d5a <initlock>
  (*f0)->type = FD_PIPE;
    80004d58:	609c                	ld	a5,0(s1)
    80004d5a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d5e:	609c                	ld	a5,0(s1)
    80004d60:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d64:	609c                	ld	a5,0(s1)
    80004d66:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d6a:	609c                	ld	a5,0(s1)
    80004d6c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d70:	000a3783          	ld	a5,0(s4)
    80004d74:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d78:	000a3783          	ld	a5,0(s4)
    80004d7c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d80:	000a3783          	ld	a5,0(s4)
    80004d84:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d88:	000a3783          	ld	a5,0(s4)
    80004d8c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d90:	4501                	li	a0,0
    80004d92:	6942                	ld	s2,16(sp)
    80004d94:	69a2                	ld	s3,8(sp)
    80004d96:	a01d                	j	80004dbc <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d98:	6088                	ld	a0,0(s1)
    80004d9a:	c119                	beqz	a0,80004da0 <pipealloc+0x9c>
    80004d9c:	6942                	ld	s2,16(sp)
    80004d9e:	a029                	j	80004da8 <pipealloc+0xa4>
    80004da0:	6942                	ld	s2,16(sp)
    80004da2:	a029                	j	80004dac <pipealloc+0xa8>
    80004da4:	6088                	ld	a0,0(s1)
    80004da6:	c10d                	beqz	a0,80004dc8 <pipealloc+0xc4>
    fileclose(*f0);
    80004da8:	c53ff0ef          	jal	800049fa <fileclose>
  if(*f1)
    80004dac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004db0:	557d                	li	a0,-1
  if(*f1)
    80004db2:	c789                	beqz	a5,80004dbc <pipealloc+0xb8>
    fileclose(*f1);
    80004db4:	853e                	mv	a0,a5
    80004db6:	c45ff0ef          	jal	800049fa <fileclose>
  return -1;
    80004dba:	557d                	li	a0,-1
}
    80004dbc:	70a2                	ld	ra,40(sp)
    80004dbe:	7402                	ld	s0,32(sp)
    80004dc0:	64e2                	ld	s1,24(sp)
    80004dc2:	6a02                	ld	s4,0(sp)
    80004dc4:	6145                	addi	sp,sp,48
    80004dc6:	8082                	ret
  return -1;
    80004dc8:	557d                	li	a0,-1
    80004dca:	bfcd                	j	80004dbc <pipealloc+0xb8>

0000000080004dcc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dcc:	1101                	addi	sp,sp,-32
    80004dce:	ec06                	sd	ra,24(sp)
    80004dd0:	e822                	sd	s0,16(sp)
    80004dd2:	e426                	sd	s1,8(sp)
    80004dd4:	e04a                	sd	s2,0(sp)
    80004dd6:	1000                	addi	s0,sp,32
    80004dd8:	84aa                	mv	s1,a0
    80004dda:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ddc:	ffffb0ef          	jal	80000dda <acquire>
  if(writable){
    80004de0:	02090763          	beqz	s2,80004e0e <pipeclose+0x42>
    pi->writeopen = 0;
    80004de4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004de8:	21848513          	addi	a0,s1,536
    80004dec:	f9efd0ef          	jal	8000258a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004df0:	2204b783          	ld	a5,544(s1)
    80004df4:	e785                	bnez	a5,80004e1c <pipeclose+0x50>
    release(&pi->lock);
    80004df6:	8526                	mv	a0,s1
    80004df8:	87afc0ef          	jal	80000e72 <release>
    kfree((char*)pi);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	d61fb0ef          	jal	80000b5e <kfree>
  } else
    release(&pi->lock);
}
    80004e02:	60e2                	ld	ra,24(sp)
    80004e04:	6442                	ld	s0,16(sp)
    80004e06:	64a2                	ld	s1,8(sp)
    80004e08:	6902                	ld	s2,0(sp)
    80004e0a:	6105                	addi	sp,sp,32
    80004e0c:	8082                	ret
    pi->readopen = 0;
    80004e0e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e12:	21c48513          	addi	a0,s1,540
    80004e16:	f74fd0ef          	jal	8000258a <wakeup>
    80004e1a:	bfd9                	j	80004df0 <pipeclose+0x24>
    release(&pi->lock);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	854fc0ef          	jal	80000e72 <release>
}
    80004e22:	b7c5                	j	80004e02 <pipeclose+0x36>

0000000080004e24 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e24:	711d                	addi	sp,sp,-96
    80004e26:	ec86                	sd	ra,88(sp)
    80004e28:	e8a2                	sd	s0,80(sp)
    80004e2a:	e4a6                	sd	s1,72(sp)
    80004e2c:	e0ca                	sd	s2,64(sp)
    80004e2e:	fc4e                	sd	s3,56(sp)
    80004e30:	f852                	sd	s4,48(sp)
    80004e32:	f456                	sd	s5,40(sp)
    80004e34:	1080                	addi	s0,sp,96
    80004e36:	84aa                	mv	s1,a0
    80004e38:	8aae                	mv	s5,a1
    80004e3a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e3c:	f3ffc0ef          	jal	80001d7a <myproc>
    80004e40:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e42:	8526                	mv	a0,s1
    80004e44:	f97fb0ef          	jal	80000dda <acquire>
  while(i < n){
    80004e48:	0b405a63          	blez	s4,80004efc <pipewrite+0xd8>
    80004e4c:	f05a                	sd	s6,32(sp)
    80004e4e:	ec5e                	sd	s7,24(sp)
    80004e50:	e862                	sd	s8,16(sp)
  int i = 0;
    80004e52:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e54:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e56:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e5a:	21c48b93          	addi	s7,s1,540
    80004e5e:	a81d                	j	80004e94 <pipewrite+0x70>
      release(&pi->lock);
    80004e60:	8526                	mv	a0,s1
    80004e62:	810fc0ef          	jal	80000e72 <release>
      return -1;
    80004e66:	597d                	li	s2,-1
    80004e68:	7b02                	ld	s6,32(sp)
    80004e6a:	6be2                	ld	s7,24(sp)
    80004e6c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e6e:	854a                	mv	a0,s2
    80004e70:	60e6                	ld	ra,88(sp)
    80004e72:	6446                	ld	s0,80(sp)
    80004e74:	64a6                	ld	s1,72(sp)
    80004e76:	6906                	ld	s2,64(sp)
    80004e78:	79e2                	ld	s3,56(sp)
    80004e7a:	7a42                	ld	s4,48(sp)
    80004e7c:	7aa2                	ld	s5,40(sp)
    80004e7e:	6125                	addi	sp,sp,96
    80004e80:	8082                	ret
      wakeup(&pi->nread);
    80004e82:	8562                	mv	a0,s8
    80004e84:	f06fd0ef          	jal	8000258a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e88:	85a6                	mv	a1,s1
    80004e8a:	855e                	mv	a0,s7
    80004e8c:	eb2fd0ef          	jal	8000253e <sleep>
  while(i < n){
    80004e90:	05495b63          	bge	s2,s4,80004ee6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004e94:	2204a783          	lw	a5,544(s1)
    80004e98:	d7e1                	beqz	a5,80004e60 <pipewrite+0x3c>
    80004e9a:	854e                	mv	a0,s3
    80004e9c:	96dfd0ef          	jal	80002808 <killed>
    80004ea0:	f161                	bnez	a0,80004e60 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ea2:	2184a783          	lw	a5,536(s1)
    80004ea6:	21c4a703          	lw	a4,540(s1)
    80004eaa:	2007879b          	addiw	a5,a5,512
    80004eae:	fcf70ae3          	beq	a4,a5,80004e82 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eb2:	4685                	li	a3,1
    80004eb4:	01590633          	add	a2,s2,s5
    80004eb8:	faf40593          	addi	a1,s0,-81
    80004ebc:	0509b503          	ld	a0,80(s3)
    80004ec0:	baffc0ef          	jal	80001a6e <copyin>
    80004ec4:	03650e63          	beq	a0,s6,80004f00 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ec8:	21c4a783          	lw	a5,540(s1)
    80004ecc:	0017871b          	addiw	a4,a5,1
    80004ed0:	20e4ae23          	sw	a4,540(s1)
    80004ed4:	1ff7f793          	andi	a5,a5,511
    80004ed8:	97a6                	add	a5,a5,s1
    80004eda:	faf44703          	lbu	a4,-81(s0)
    80004ede:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ee2:	2905                	addiw	s2,s2,1
    80004ee4:	b775                	j	80004e90 <pipewrite+0x6c>
    80004ee6:	7b02                	ld	s6,32(sp)
    80004ee8:	6be2                	ld	s7,24(sp)
    80004eea:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004eec:	21848513          	addi	a0,s1,536
    80004ef0:	e9afd0ef          	jal	8000258a <wakeup>
  release(&pi->lock);
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	f7dfb0ef          	jal	80000e72 <release>
  return i;
    80004efa:	bf95                	j	80004e6e <pipewrite+0x4a>
  int i = 0;
    80004efc:	4901                	li	s2,0
    80004efe:	b7fd                	j	80004eec <pipewrite+0xc8>
    80004f00:	7b02                	ld	s6,32(sp)
    80004f02:	6be2                	ld	s7,24(sp)
    80004f04:	6c42                	ld	s8,16(sp)
    80004f06:	b7dd                	j	80004eec <pipewrite+0xc8>

0000000080004f08 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f08:	715d                	addi	sp,sp,-80
    80004f0a:	e486                	sd	ra,72(sp)
    80004f0c:	e0a2                	sd	s0,64(sp)
    80004f0e:	fc26                	sd	s1,56(sp)
    80004f10:	f84a                	sd	s2,48(sp)
    80004f12:	f44e                	sd	s3,40(sp)
    80004f14:	f052                	sd	s4,32(sp)
    80004f16:	ec56                	sd	s5,24(sp)
    80004f18:	0880                	addi	s0,sp,80
    80004f1a:	84aa                	mv	s1,a0
    80004f1c:	892e                	mv	s2,a1
    80004f1e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f20:	e5bfc0ef          	jal	80001d7a <myproc>
    80004f24:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f26:	8526                	mv	a0,s1
    80004f28:	eb3fb0ef          	jal	80000dda <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f2c:	2184a703          	lw	a4,536(s1)
    80004f30:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f34:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f38:	02f71563          	bne	a4,a5,80004f62 <piperead+0x5a>
    80004f3c:	2244a783          	lw	a5,548(s1)
    80004f40:	cb85                	beqz	a5,80004f70 <piperead+0x68>
    if(killed(pr)){
    80004f42:	8552                	mv	a0,s4
    80004f44:	8c5fd0ef          	jal	80002808 <killed>
    80004f48:	ed19                	bnez	a0,80004f66 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f4a:	85a6                	mv	a1,s1
    80004f4c:	854e                	mv	a0,s3
    80004f4e:	df0fd0ef          	jal	8000253e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f52:	2184a703          	lw	a4,536(s1)
    80004f56:	21c4a783          	lw	a5,540(s1)
    80004f5a:	fef701e3          	beq	a4,a5,80004f3c <piperead+0x34>
    80004f5e:	e85a                	sd	s6,16(sp)
    80004f60:	a809                	j	80004f72 <piperead+0x6a>
    80004f62:	e85a                	sd	s6,16(sp)
    80004f64:	a039                	j	80004f72 <piperead+0x6a>
      release(&pi->lock);
    80004f66:	8526                	mv	a0,s1
    80004f68:	f0bfb0ef          	jal	80000e72 <release>
      return -1;
    80004f6c:	59fd                	li	s3,-1
    80004f6e:	a8b9                	j	80004fcc <piperead+0xc4>
    80004f70:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f72:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004f74:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f76:	05505363          	blez	s5,80004fbc <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004f7a:	2184a783          	lw	a5,536(s1)
    80004f7e:	21c4a703          	lw	a4,540(s1)
    80004f82:	02f70d63          	beq	a4,a5,80004fbc <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004f86:	1ff7f793          	andi	a5,a5,511
    80004f8a:	97a6                	add	a5,a5,s1
    80004f8c:	0187c783          	lbu	a5,24(a5)
    80004f90:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004f94:	4685                	li	a3,1
    80004f96:	fbf40613          	addi	a2,s0,-65
    80004f9a:	85ca                	mv	a1,s2
    80004f9c:	050a3503          	ld	a0,80(s4)
    80004fa0:	9b9fc0ef          	jal	80001958 <copyout>
    80004fa4:	03650e63          	beq	a0,s6,80004fe0 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004fa8:	2184a783          	lw	a5,536(s1)
    80004fac:	2785                	addiw	a5,a5,1
    80004fae:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fb2:	2985                	addiw	s3,s3,1
    80004fb4:	0905                	addi	s2,s2,1
    80004fb6:	fd3a92e3          	bne	s5,s3,80004f7a <piperead+0x72>
    80004fba:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fbc:	21c48513          	addi	a0,s1,540
    80004fc0:	dcafd0ef          	jal	8000258a <wakeup>
  release(&pi->lock);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	eadfb0ef          	jal	80000e72 <release>
    80004fca:	6b42                	ld	s6,16(sp)
  return i;
}
    80004fcc:	854e                	mv	a0,s3
    80004fce:	60a6                	ld	ra,72(sp)
    80004fd0:	6406                	ld	s0,64(sp)
    80004fd2:	74e2                	ld	s1,56(sp)
    80004fd4:	7942                	ld	s2,48(sp)
    80004fd6:	79a2                	ld	s3,40(sp)
    80004fd8:	7a02                	ld	s4,32(sp)
    80004fda:	6ae2                	ld	s5,24(sp)
    80004fdc:	6161                	addi	sp,sp,80
    80004fde:	8082                	ret
      if(i == 0)
    80004fe0:	fc099ee3          	bnez	s3,80004fbc <piperead+0xb4>
        i = -1;
    80004fe4:	89aa                	mv	s3,a0
    80004fe6:	bfd9                	j	80004fbc <piperead+0xb4>

0000000080004fe8 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004fe8:	1141                	addi	sp,sp,-16
    80004fea:	e422                	sd	s0,8(sp)
    80004fec:	0800                	addi	s0,sp,16
    80004fee:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ff0:	8905                	andi	a0,a0,1
    80004ff2:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004ff4:	8b89                	andi	a5,a5,2
    80004ff6:	c399                	beqz	a5,80004ffc <flags2perm+0x14>
      perm |= PTE_W;
    80004ff8:	00456513          	ori	a0,a0,4
    return perm;
}
    80004ffc:	6422                	ld	s0,8(sp)
    80004ffe:	0141                	addi	sp,sp,16
    80005000:	8082                	ret

0000000080005002 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80005002:	df010113          	addi	sp,sp,-528
    80005006:	20113423          	sd	ra,520(sp)
    8000500a:	20813023          	sd	s0,512(sp)
    8000500e:	ffa6                	sd	s1,504(sp)
    80005010:	fbca                	sd	s2,496(sp)
    80005012:	0c00                	addi	s0,sp,528
    80005014:	892a                	mv	s2,a0
    80005016:	dea43c23          	sd	a0,-520(s0)
    8000501a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000501e:	d5dfc0ef          	jal	80001d7a <myproc>
    80005022:	84aa                	mv	s1,a0

  begin_op();
    80005024:	dcaff0ef          	jal	800045ee <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005028:	854a                	mv	a0,s2
    8000502a:	bf0ff0ef          	jal	8000441a <namei>
    8000502e:	c931                	beqz	a0,80005082 <kexec+0x80>
    80005030:	f3d2                	sd	s4,480(sp)
    80005032:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005034:	bd1fe0ef          	jal	80003c04 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005038:	04000713          	li	a4,64
    8000503c:	4681                	li	a3,0
    8000503e:	e5040613          	addi	a2,s0,-432
    80005042:	4581                	li	a1,0
    80005044:	8552                	mv	a0,s4
    80005046:	f4ffe0ef          	jal	80003f94 <readi>
    8000504a:	04000793          	li	a5,64
    8000504e:	00f51a63          	bne	a0,a5,80005062 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005052:	e5042703          	lw	a4,-432(s0)
    80005056:	464c47b7          	lui	a5,0x464c4
    8000505a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000505e:	02f70663          	beq	a4,a5,8000508a <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005062:	8552                	mv	a0,s4
    80005064:	dabfe0ef          	jal	80003e0e <iunlockput>
    end_op();
    80005068:	df0ff0ef          	jal	80004658 <end_op>
  }
  return -1;
    8000506c:	557d                	li	a0,-1
    8000506e:	7a1e                	ld	s4,480(sp)
}
    80005070:	20813083          	ld	ra,520(sp)
    80005074:	20013403          	ld	s0,512(sp)
    80005078:	74fe                	ld	s1,504(sp)
    8000507a:	795e                	ld	s2,496(sp)
    8000507c:	21010113          	addi	sp,sp,528
    80005080:	8082                	ret
    end_op();
    80005082:	dd6ff0ef          	jal	80004658 <end_op>
    return -1;
    80005086:	557d                	li	a0,-1
    80005088:	b7e5                	j	80005070 <kexec+0x6e>
    8000508a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000508c:	8526                	mv	a0,s1
    8000508e:	d5dfc0ef          	jal	80001dea <proc_pagetable>
    80005092:	8b2a                	mv	s6,a0
    80005094:	2c050b63          	beqz	a0,8000536a <kexec+0x368>
    80005098:	f7ce                	sd	s3,488(sp)
    8000509a:	efd6                	sd	s5,472(sp)
    8000509c:	e7de                	sd	s7,456(sp)
    8000509e:	e3e2                	sd	s8,448(sp)
    800050a0:	ff66                	sd	s9,440(sp)
    800050a2:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a4:	e7042d03          	lw	s10,-400(s0)
    800050a8:	e8845783          	lhu	a5,-376(s0)
    800050ac:	12078963          	beqz	a5,800051de <kexec+0x1dc>
    800050b0:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050b2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050b4:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800050b6:	6c85                	lui	s9,0x1
    800050b8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800050bc:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800050c0:	6a85                	lui	s5,0x1
    800050c2:	a085                	j	80005122 <kexec+0x120>
      panic("loadseg: address should exist");
    800050c4:	00003517          	auipc	a0,0x3
    800050c8:	5c450513          	addi	a0,a0,1476 # 80008688 <etext+0x688>
    800050cc:	f14fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800050d0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050d2:	8726                	mv	a4,s1
    800050d4:	012c06bb          	addw	a3,s8,s2
    800050d8:	4581                	li	a1,0
    800050da:	8552                	mv	a0,s4
    800050dc:	eb9fe0ef          	jal	80003f94 <readi>
    800050e0:	2501                	sext.w	a0,a0
    800050e2:	24a49a63          	bne	s1,a0,80005336 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800050e6:	012a893b          	addw	s2,s5,s2
    800050ea:	03397363          	bgeu	s2,s3,80005110 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800050ee:	02091593          	slli	a1,s2,0x20
    800050f2:	9181                	srli	a1,a1,0x20
    800050f4:	95de                	add	a1,a1,s7
    800050f6:	855a                	mv	a0,s6
    800050f8:	8c4fc0ef          	jal	800011bc <walkaddr>
    800050fc:	862a                	mv	a2,a0
    if(pa == 0)
    800050fe:	d179                	beqz	a0,800050c4 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80005100:	412984bb          	subw	s1,s3,s2
    80005104:	0004879b          	sext.w	a5,s1
    80005108:	fcfcf4e3          	bgeu	s9,a5,800050d0 <kexec+0xce>
    8000510c:	84d6                	mv	s1,s5
    8000510e:	b7c9                	j	800050d0 <kexec+0xce>
    sz = sz1;
    80005110:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005114:	2d85                	addiw	s11,s11,1
    80005116:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000511a:	e8845783          	lhu	a5,-376(s0)
    8000511e:	08fdd063          	bge	s11,a5,8000519e <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005122:	2d01                	sext.w	s10,s10
    80005124:	03800713          	li	a4,56
    80005128:	86ea                	mv	a3,s10
    8000512a:	e1840613          	addi	a2,s0,-488
    8000512e:	4581                	li	a1,0
    80005130:	8552                	mv	a0,s4
    80005132:	e63fe0ef          	jal	80003f94 <readi>
    80005136:	03800793          	li	a5,56
    8000513a:	1cf51663          	bne	a0,a5,80005306 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000513e:	e1842783          	lw	a5,-488(s0)
    80005142:	4705                	li	a4,1
    80005144:	fce798e3          	bne	a5,a4,80005114 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80005148:	e4043483          	ld	s1,-448(s0)
    8000514c:	e3843783          	ld	a5,-456(s0)
    80005150:	1af4ef63          	bltu	s1,a5,8000530e <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005154:	e2843783          	ld	a5,-472(s0)
    80005158:	94be                	add	s1,s1,a5
    8000515a:	1af4ee63          	bltu	s1,a5,80005316 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000515e:	df043703          	ld	a4,-528(s0)
    80005162:	8ff9                	and	a5,a5,a4
    80005164:	1a079d63          	bnez	a5,8000531e <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005168:	e1c42503          	lw	a0,-484(s0)
    8000516c:	e7dff0ef          	jal	80004fe8 <flags2perm>
    80005170:	86aa                	mv	a3,a0
    80005172:	8626                	mv	a2,s1
    80005174:	85ca                	mv	a1,s2
    80005176:	855a                	mv	a0,s6
    80005178:	b1cfc0ef          	jal	80001494 <uvmalloc>
    8000517c:	e0a43423          	sd	a0,-504(s0)
    80005180:	1a050363          	beqz	a0,80005326 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005184:	e2843b83          	ld	s7,-472(s0)
    80005188:	e2042c03          	lw	s8,-480(s0)
    8000518c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005190:	00098463          	beqz	s3,80005198 <kexec+0x196>
    80005194:	4901                	li	s2,0
    80005196:	bfa1                	j	800050ee <kexec+0xec>
    sz = sz1;
    80005198:	e0843903          	ld	s2,-504(s0)
    8000519c:	bfa5                	j	80005114 <kexec+0x112>
    8000519e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800051a0:	8552                	mv	a0,s4
    800051a2:	c6dfe0ef          	jal	80003e0e <iunlockput>
  end_op();
    800051a6:	cb2ff0ef          	jal	80004658 <end_op>
  p = myproc();
    800051aa:	bd1fc0ef          	jal	80001d7a <myproc>
    800051ae:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051b0:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800051b4:	6985                	lui	s3,0x1
    800051b6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800051b8:	99ca                	add	s3,s3,s2
    800051ba:	77fd                	lui	a5,0xfffff
    800051bc:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800051c0:	4691                	li	a3,4
    800051c2:	6609                	lui	a2,0x2
    800051c4:	964e                	add	a2,a2,s3
    800051c6:	85ce                	mv	a1,s3
    800051c8:	855a                	mv	a0,s6
    800051ca:	acafc0ef          	jal	80001494 <uvmalloc>
    800051ce:	892a                	mv	s2,a0
    800051d0:	e0a43423          	sd	a0,-504(s0)
    800051d4:	e519                	bnez	a0,800051e2 <kexec+0x1e0>
  if(pagetable)
    800051d6:	e1343423          	sd	s3,-504(s0)
    800051da:	4a01                	li	s4,0
    800051dc:	aab1                	j	80005338 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051de:	4901                	li	s2,0
    800051e0:	b7c1                	j	800051a0 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800051e2:	75f9                	lui	a1,0xffffe
    800051e4:	95aa                	add	a1,a1,a0
    800051e6:	855a                	mv	a0,s6
    800051e8:	d32fc0ef          	jal	8000171a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800051ec:	7bfd                	lui	s7,0xfffff
    800051ee:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800051f0:	e0043783          	ld	a5,-512(s0)
    800051f4:	6388                	ld	a0,0(a5)
    800051f6:	cd39                	beqz	a0,80005254 <kexec+0x252>
    800051f8:	e9040993          	addi	s3,s0,-368
    800051fc:	f9040c13          	addi	s8,s0,-112
    80005200:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005202:	e1dfb0ef          	jal	8000101e <strlen>
    80005206:	0015079b          	addiw	a5,a0,1
    8000520a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000520e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005212:	11796e63          	bltu	s2,s7,8000532e <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005216:	e0043d03          	ld	s10,-512(s0)
    8000521a:	000d3a03          	ld	s4,0(s10)
    8000521e:	8552                	mv	a0,s4
    80005220:	dfffb0ef          	jal	8000101e <strlen>
    80005224:	0015069b          	addiw	a3,a0,1
    80005228:	8652                	mv	a2,s4
    8000522a:	85ca                	mv	a1,s2
    8000522c:	855a                	mv	a0,s6
    8000522e:	f2afc0ef          	jal	80001958 <copyout>
    80005232:	10054063          	bltz	a0,80005332 <kexec+0x330>
    ustack[argc] = sp;
    80005236:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000523a:	0485                	addi	s1,s1,1
    8000523c:	008d0793          	addi	a5,s10,8
    80005240:	e0f43023          	sd	a5,-512(s0)
    80005244:	008d3503          	ld	a0,8(s10)
    80005248:	c909                	beqz	a0,8000525a <kexec+0x258>
    if(argc >= MAXARG)
    8000524a:	09a1                	addi	s3,s3,8
    8000524c:	fb899be3          	bne	s3,s8,80005202 <kexec+0x200>
  ip = 0;
    80005250:	4a01                	li	s4,0
    80005252:	a0dd                	j	80005338 <kexec+0x336>
  sp = sz;
    80005254:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005258:	4481                	li	s1,0
  ustack[argc] = 0;
    8000525a:	00349793          	slli	a5,s1,0x3
    8000525e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffbc8d0>
    80005262:	97a2                	add	a5,a5,s0
    80005264:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005268:	00148693          	addi	a3,s1,1
    8000526c:	068e                	slli	a3,a3,0x3
    8000526e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005272:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005276:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000527a:	f5796ee3          	bltu	s2,s7,800051d6 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000527e:	e9040613          	addi	a2,s0,-368
    80005282:	85ca                	mv	a1,s2
    80005284:	855a                	mv	a0,s6
    80005286:	ed2fc0ef          	jal	80001958 <copyout>
    8000528a:	0e054263          	bltz	a0,8000536e <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000528e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005292:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005296:	df843783          	ld	a5,-520(s0)
    8000529a:	0007c703          	lbu	a4,0(a5)
    8000529e:	cf11                	beqz	a4,800052ba <kexec+0x2b8>
    800052a0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052a2:	02f00693          	li	a3,47
    800052a6:	a039                	j	800052b4 <kexec+0x2b2>
      last = s+1;
    800052a8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052ac:	0785                	addi	a5,a5,1
    800052ae:	fff7c703          	lbu	a4,-1(a5)
    800052b2:	c701                	beqz	a4,800052ba <kexec+0x2b8>
    if(*s == '/')
    800052b4:	fed71ce3          	bne	a4,a3,800052ac <kexec+0x2aa>
    800052b8:	bfc5                	j	800052a8 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800052ba:	4641                	li	a2,16
    800052bc:	df843583          	ld	a1,-520(s0)
    800052c0:	158a8513          	addi	a0,s5,344
    800052c4:	d29fb0ef          	jal	80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    800052c8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800052cc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800052d0:	e0843783          	ld	a5,-504(s0)
    800052d4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800052d8:	058ab783          	ld	a5,88(s5)
    800052dc:	e6843703          	ld	a4,-408(s0)
    800052e0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052e2:	058ab783          	ld	a5,88(s5)
    800052e6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052ea:	85e6                	mv	a1,s9
    800052ec:	b83fc0ef          	jal	80001e6e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052f0:	0004851b          	sext.w	a0,s1
    800052f4:	79be                	ld	s3,488(sp)
    800052f6:	7a1e                	ld	s4,480(sp)
    800052f8:	6afe                	ld	s5,472(sp)
    800052fa:	6b5e                	ld	s6,464(sp)
    800052fc:	6bbe                	ld	s7,456(sp)
    800052fe:	6c1e                	ld	s8,448(sp)
    80005300:	7cfa                	ld	s9,440(sp)
    80005302:	7d5a                	ld	s10,432(sp)
    80005304:	b3b5                	j	80005070 <kexec+0x6e>
    80005306:	e1243423          	sd	s2,-504(s0)
    8000530a:	7dba                	ld	s11,424(sp)
    8000530c:	a035                	j	80005338 <kexec+0x336>
    8000530e:	e1243423          	sd	s2,-504(s0)
    80005312:	7dba                	ld	s11,424(sp)
    80005314:	a015                	j	80005338 <kexec+0x336>
    80005316:	e1243423          	sd	s2,-504(s0)
    8000531a:	7dba                	ld	s11,424(sp)
    8000531c:	a831                	j	80005338 <kexec+0x336>
    8000531e:	e1243423          	sd	s2,-504(s0)
    80005322:	7dba                	ld	s11,424(sp)
    80005324:	a811                	j	80005338 <kexec+0x336>
    80005326:	e1243423          	sd	s2,-504(s0)
    8000532a:	7dba                	ld	s11,424(sp)
    8000532c:	a031                	j	80005338 <kexec+0x336>
  ip = 0;
    8000532e:	4a01                	li	s4,0
    80005330:	a021                	j	80005338 <kexec+0x336>
    80005332:	4a01                	li	s4,0
  if(pagetable)
    80005334:	a011                	j	80005338 <kexec+0x336>
    80005336:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005338:	e0843583          	ld	a1,-504(s0)
    8000533c:	855a                	mv	a0,s6
    8000533e:	b31fc0ef          	jal	80001e6e <proc_freepagetable>
  return -1;
    80005342:	557d                	li	a0,-1
  if(ip){
    80005344:	000a1b63          	bnez	s4,8000535a <kexec+0x358>
    80005348:	79be                	ld	s3,488(sp)
    8000534a:	7a1e                	ld	s4,480(sp)
    8000534c:	6afe                	ld	s5,472(sp)
    8000534e:	6b5e                	ld	s6,464(sp)
    80005350:	6bbe                	ld	s7,456(sp)
    80005352:	6c1e                	ld	s8,448(sp)
    80005354:	7cfa                	ld	s9,440(sp)
    80005356:	7d5a                	ld	s10,432(sp)
    80005358:	bb21                	j	80005070 <kexec+0x6e>
    8000535a:	79be                	ld	s3,488(sp)
    8000535c:	6afe                	ld	s5,472(sp)
    8000535e:	6b5e                	ld	s6,464(sp)
    80005360:	6bbe                	ld	s7,456(sp)
    80005362:	6c1e                	ld	s8,448(sp)
    80005364:	7cfa                	ld	s9,440(sp)
    80005366:	7d5a                	ld	s10,432(sp)
    80005368:	b9ed                	j	80005062 <kexec+0x60>
    8000536a:	6b5e                	ld	s6,464(sp)
    8000536c:	b9dd                	j	80005062 <kexec+0x60>
  sz = sz1;
    8000536e:	e0843983          	ld	s3,-504(s0)
    80005372:	b595                	j	800051d6 <kexec+0x1d4>

0000000080005374 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005374:	7179                	addi	sp,sp,-48
    80005376:	f406                	sd	ra,40(sp)
    80005378:	f022                	sd	s0,32(sp)
    8000537a:	ec26                	sd	s1,24(sp)
    8000537c:	e84a                	sd	s2,16(sp)
    8000537e:	1800                	addi	s0,sp,48
    80005380:	892e                	mv	s2,a1
    80005382:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005384:	fdc40593          	addi	a1,s0,-36
    80005388:	d7bfd0ef          	jal	80003102 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000538c:	fdc42703          	lw	a4,-36(s0)
    80005390:	47bd                	li	a5,15
    80005392:	02e7e963          	bltu	a5,a4,800053c4 <argfd+0x50>
    80005396:	9e5fc0ef          	jal	80001d7a <myproc>
    8000539a:	fdc42703          	lw	a4,-36(s0)
    8000539e:	01a70793          	addi	a5,a4,26
    800053a2:	078e                	slli	a5,a5,0x3
    800053a4:	953e                	add	a0,a0,a5
    800053a6:	611c                	ld	a5,0(a0)
    800053a8:	c385                	beqz	a5,800053c8 <argfd+0x54>
    return -1;
  if(pfd)
    800053aa:	00090463          	beqz	s2,800053b2 <argfd+0x3e>
    *pfd = fd;
    800053ae:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053b2:	4501                	li	a0,0
  if(pf)
    800053b4:	c091                	beqz	s1,800053b8 <argfd+0x44>
    *pf = f;
    800053b6:	e09c                	sd	a5,0(s1)
}
    800053b8:	70a2                	ld	ra,40(sp)
    800053ba:	7402                	ld	s0,32(sp)
    800053bc:	64e2                	ld	s1,24(sp)
    800053be:	6942                	ld	s2,16(sp)
    800053c0:	6145                	addi	sp,sp,48
    800053c2:	8082                	ret
    return -1;
    800053c4:	557d                	li	a0,-1
    800053c6:	bfcd                	j	800053b8 <argfd+0x44>
    800053c8:	557d                	li	a0,-1
    800053ca:	b7fd                	j	800053b8 <argfd+0x44>

00000000800053cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053cc:	1101                	addi	sp,sp,-32
    800053ce:	ec06                	sd	ra,24(sp)
    800053d0:	e822                	sd	s0,16(sp)
    800053d2:	e426                	sd	s1,8(sp)
    800053d4:	1000                	addi	s0,sp,32
    800053d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053d8:	9a3fc0ef          	jal	80001d7a <myproc>
    800053dc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053de:	0d050793          	addi	a5,a0,208
    800053e2:	4501                	li	a0,0
    800053e4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053e6:	6398                	ld	a4,0(a5)
    800053e8:	cb19                	beqz	a4,800053fe <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800053ea:	2505                	addiw	a0,a0,1
    800053ec:	07a1                	addi	a5,a5,8
    800053ee:	fed51ce3          	bne	a0,a3,800053e6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053f2:	557d                	li	a0,-1
}
    800053f4:	60e2                	ld	ra,24(sp)
    800053f6:	6442                	ld	s0,16(sp)
    800053f8:	64a2                	ld	s1,8(sp)
    800053fa:	6105                	addi	sp,sp,32
    800053fc:	8082                	ret
      p->ofile[fd] = f;
    800053fe:	01a50793          	addi	a5,a0,26
    80005402:	078e                	slli	a5,a5,0x3
    80005404:	963e                	add	a2,a2,a5
    80005406:	e204                	sd	s1,0(a2)
      return fd;
    80005408:	b7f5                	j	800053f4 <fdalloc+0x28>

000000008000540a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000540a:	715d                	addi	sp,sp,-80
    8000540c:	e486                	sd	ra,72(sp)
    8000540e:	e0a2                	sd	s0,64(sp)
    80005410:	fc26                	sd	s1,56(sp)
    80005412:	f84a                	sd	s2,48(sp)
    80005414:	f44e                	sd	s3,40(sp)
    80005416:	ec56                	sd	s5,24(sp)
    80005418:	e85a                	sd	s6,16(sp)
    8000541a:	0880                	addi	s0,sp,80
    8000541c:	8b2e                	mv	s6,a1
    8000541e:	89b2                	mv	s3,a2
    80005420:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005422:	fb040593          	addi	a1,s0,-80
    80005426:	80eff0ef          	jal	80004434 <nameiparent>
    8000542a:	84aa                	mv	s1,a0
    8000542c:	10050a63          	beqz	a0,80005540 <create+0x136>
    return 0;

  ilock(dp);
    80005430:	fd4fe0ef          	jal	80003c04 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005434:	4601                	li	a2,0
    80005436:	fb040593          	addi	a1,s0,-80
    8000543a:	8526                	mv	a0,s1
    8000543c:	d79fe0ef          	jal	800041b4 <dirlookup>
    80005440:	8aaa                	mv	s5,a0
    80005442:	c129                	beqz	a0,80005484 <create+0x7a>
    iunlockput(dp);
    80005444:	8526                	mv	a0,s1
    80005446:	9c9fe0ef          	jal	80003e0e <iunlockput>
    ilock(ip);
    8000544a:	8556                	mv	a0,s5
    8000544c:	fb8fe0ef          	jal	80003c04 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005450:	4789                	li	a5,2
    80005452:	02fb1463          	bne	s6,a5,8000547a <create+0x70>
    80005456:	044ad783          	lhu	a5,68(s5)
    8000545a:	37f9                	addiw	a5,a5,-2
    8000545c:	17c2                	slli	a5,a5,0x30
    8000545e:	93c1                	srli	a5,a5,0x30
    80005460:	4705                	li	a4,1
    80005462:	00f76c63          	bltu	a4,a5,8000547a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005466:	8556                	mv	a0,s5
    80005468:	60a6                	ld	ra,72(sp)
    8000546a:	6406                	ld	s0,64(sp)
    8000546c:	74e2                	ld	s1,56(sp)
    8000546e:	7942                	ld	s2,48(sp)
    80005470:	79a2                	ld	s3,40(sp)
    80005472:	6ae2                	ld	s5,24(sp)
    80005474:	6b42                	ld	s6,16(sp)
    80005476:	6161                	addi	sp,sp,80
    80005478:	8082                	ret
    iunlockput(ip);
    8000547a:	8556                	mv	a0,s5
    8000547c:	993fe0ef          	jal	80003e0e <iunlockput>
    return 0;
    80005480:	4a81                	li	s5,0
    80005482:	b7d5                	j	80005466 <create+0x5c>
    80005484:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005486:	85da                	mv	a1,s6
    80005488:	4088                	lw	a0,0(s1)
    8000548a:	e0afe0ef          	jal	80003a94 <ialloc>
    8000548e:	8a2a                	mv	s4,a0
    80005490:	cd15                	beqz	a0,800054cc <create+0xc2>
  ilock(ip);
    80005492:	f72fe0ef          	jal	80003c04 <ilock>
  ip->major = major;
    80005496:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000549a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000549e:	4905                	li	s2,1
    800054a0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800054a4:	8552                	mv	a0,s4
    800054a6:	eaafe0ef          	jal	80003b50 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054aa:	032b0763          	beq	s6,s2,800054d8 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800054ae:	004a2603          	lw	a2,4(s4)
    800054b2:	fb040593          	addi	a1,s0,-80
    800054b6:	8526                	mv	a0,s1
    800054b8:	ec9fe0ef          	jal	80004380 <dirlink>
    800054bc:	06054563          	bltz	a0,80005526 <create+0x11c>
  iunlockput(dp);
    800054c0:	8526                	mv	a0,s1
    800054c2:	94dfe0ef          	jal	80003e0e <iunlockput>
  return ip;
    800054c6:	8ad2                	mv	s5,s4
    800054c8:	7a02                	ld	s4,32(sp)
    800054ca:	bf71                	j	80005466 <create+0x5c>
    iunlockput(dp);
    800054cc:	8526                	mv	a0,s1
    800054ce:	941fe0ef          	jal	80003e0e <iunlockput>
    return 0;
    800054d2:	8ad2                	mv	s5,s4
    800054d4:	7a02                	ld	s4,32(sp)
    800054d6:	bf41                	j	80005466 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054d8:	004a2603          	lw	a2,4(s4)
    800054dc:	00003597          	auipc	a1,0x3
    800054e0:	1cc58593          	addi	a1,a1,460 # 800086a8 <etext+0x6a8>
    800054e4:	8552                	mv	a0,s4
    800054e6:	e9bfe0ef          	jal	80004380 <dirlink>
    800054ea:	02054e63          	bltz	a0,80005526 <create+0x11c>
    800054ee:	40d0                	lw	a2,4(s1)
    800054f0:	00003597          	auipc	a1,0x3
    800054f4:	1c058593          	addi	a1,a1,448 # 800086b0 <etext+0x6b0>
    800054f8:	8552                	mv	a0,s4
    800054fa:	e87fe0ef          	jal	80004380 <dirlink>
    800054fe:	02054463          	bltz	a0,80005526 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005502:	004a2603          	lw	a2,4(s4)
    80005506:	fb040593          	addi	a1,s0,-80
    8000550a:	8526                	mv	a0,s1
    8000550c:	e75fe0ef          	jal	80004380 <dirlink>
    80005510:	00054b63          	bltz	a0,80005526 <create+0x11c>
    dp->nlink++;  // for ".."
    80005514:	04a4d783          	lhu	a5,74(s1)
    80005518:	2785                	addiw	a5,a5,1
    8000551a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000551e:	8526                	mv	a0,s1
    80005520:	e30fe0ef          	jal	80003b50 <iupdate>
    80005524:	bf71                	j	800054c0 <create+0xb6>
  ip->nlink = 0;
    80005526:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000552a:	8552                	mv	a0,s4
    8000552c:	e24fe0ef          	jal	80003b50 <iupdate>
  iunlockput(ip);
    80005530:	8552                	mv	a0,s4
    80005532:	8ddfe0ef          	jal	80003e0e <iunlockput>
  iunlockput(dp);
    80005536:	8526                	mv	a0,s1
    80005538:	8d7fe0ef          	jal	80003e0e <iunlockput>
  return 0;
    8000553c:	7a02                	ld	s4,32(sp)
    8000553e:	b725                	j	80005466 <create+0x5c>
    return 0;
    80005540:	8aaa                	mv	s5,a0
    80005542:	b715                	j	80005466 <create+0x5c>

0000000080005544 <sys_dup>:
{
    80005544:	7179                	addi	sp,sp,-48
    80005546:	f406                	sd	ra,40(sp)
    80005548:	f022                	sd	s0,32(sp)
    8000554a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000554c:	fd840613          	addi	a2,s0,-40
    80005550:	4581                	li	a1,0
    80005552:	4501                	li	a0,0
    80005554:	e21ff0ef          	jal	80005374 <argfd>
    return -1;
    80005558:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000555a:	02054363          	bltz	a0,80005580 <sys_dup+0x3c>
    8000555e:	ec26                	sd	s1,24(sp)
    80005560:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005562:	fd843903          	ld	s2,-40(s0)
    80005566:	854a                	mv	a0,s2
    80005568:	e65ff0ef          	jal	800053cc <fdalloc>
    8000556c:	84aa                	mv	s1,a0
    return -1;
    8000556e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005570:	00054d63          	bltz	a0,8000558a <sys_dup+0x46>
  filedup(f);
    80005574:	854a                	mv	a0,s2
    80005576:	c3eff0ef          	jal	800049b4 <filedup>
  return fd;
    8000557a:	87a6                	mv	a5,s1
    8000557c:	64e2                	ld	s1,24(sp)
    8000557e:	6942                	ld	s2,16(sp)
}
    80005580:	853e                	mv	a0,a5
    80005582:	70a2                	ld	ra,40(sp)
    80005584:	7402                	ld	s0,32(sp)
    80005586:	6145                	addi	sp,sp,48
    80005588:	8082                	ret
    8000558a:	64e2                	ld	s1,24(sp)
    8000558c:	6942                	ld	s2,16(sp)
    8000558e:	bfcd                	j	80005580 <sys_dup+0x3c>

0000000080005590 <sys_read>:
{
    80005590:	7179                	addi	sp,sp,-48
    80005592:	f406                	sd	ra,40(sp)
    80005594:	f022                	sd	s0,32(sp)
    80005596:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005598:	fd840593          	addi	a1,s0,-40
    8000559c:	4505                	li	a0,1
    8000559e:	b81fd0ef          	jal	8000311e <argaddr>
  argint(2, &n);
    800055a2:	fe440593          	addi	a1,s0,-28
    800055a6:	4509                	li	a0,2
    800055a8:	b5bfd0ef          	jal	80003102 <argint>
  if(argfd(0, 0, &f) < 0)
    800055ac:	fe840613          	addi	a2,s0,-24
    800055b0:	4581                	li	a1,0
    800055b2:	4501                	li	a0,0
    800055b4:	dc1ff0ef          	jal	80005374 <argfd>
    800055b8:	87aa                	mv	a5,a0
    return -1;
    800055ba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055bc:	0007ca63          	bltz	a5,800055d0 <sys_read+0x40>
  return fileread(f, p, n);
    800055c0:	fe442603          	lw	a2,-28(s0)
    800055c4:	fd843583          	ld	a1,-40(s0)
    800055c8:	fe843503          	ld	a0,-24(s0)
    800055cc:	d4eff0ef          	jal	80004b1a <fileread>
}
    800055d0:	70a2                	ld	ra,40(sp)
    800055d2:	7402                	ld	s0,32(sp)
    800055d4:	6145                	addi	sp,sp,48
    800055d6:	8082                	ret

00000000800055d8 <sys_write>:
{
    800055d8:	7179                	addi	sp,sp,-48
    800055da:	f406                	sd	ra,40(sp)
    800055dc:	f022                	sd	s0,32(sp)
    800055de:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055e0:	fd840593          	addi	a1,s0,-40
    800055e4:	4505                	li	a0,1
    800055e6:	b39fd0ef          	jal	8000311e <argaddr>
  argint(2, &n);
    800055ea:	fe440593          	addi	a1,s0,-28
    800055ee:	4509                	li	a0,2
    800055f0:	b13fd0ef          	jal	80003102 <argint>
  if(argfd(0, 0, &f) < 0)
    800055f4:	fe840613          	addi	a2,s0,-24
    800055f8:	4581                	li	a1,0
    800055fa:	4501                	li	a0,0
    800055fc:	d79ff0ef          	jal	80005374 <argfd>
    80005600:	87aa                	mv	a5,a0
    return -1;
    80005602:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005604:	0007ca63          	bltz	a5,80005618 <sys_write+0x40>
  return filewrite(f, p, n);
    80005608:	fe442603          	lw	a2,-28(s0)
    8000560c:	fd843583          	ld	a1,-40(s0)
    80005610:	fe843503          	ld	a0,-24(s0)
    80005614:	dc4ff0ef          	jal	80004bd8 <filewrite>
}
    80005618:	70a2                	ld	ra,40(sp)
    8000561a:	7402                	ld	s0,32(sp)
    8000561c:	6145                	addi	sp,sp,48
    8000561e:	8082                	ret

0000000080005620 <sys_close>:
{
    80005620:	1101                	addi	sp,sp,-32
    80005622:	ec06                	sd	ra,24(sp)
    80005624:	e822                	sd	s0,16(sp)
    80005626:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005628:	fe040613          	addi	a2,s0,-32
    8000562c:	fec40593          	addi	a1,s0,-20
    80005630:	4501                	li	a0,0
    80005632:	d43ff0ef          	jal	80005374 <argfd>
    return -1;
    80005636:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005638:	02054063          	bltz	a0,80005658 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000563c:	f3efc0ef          	jal	80001d7a <myproc>
    80005640:	fec42783          	lw	a5,-20(s0)
    80005644:	07e9                	addi	a5,a5,26
    80005646:	078e                	slli	a5,a5,0x3
    80005648:	953e                	add	a0,a0,a5
    8000564a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000564e:	fe043503          	ld	a0,-32(s0)
    80005652:	ba8ff0ef          	jal	800049fa <fileclose>
  return 0;
    80005656:	4781                	li	a5,0
}
    80005658:	853e                	mv	a0,a5
    8000565a:	60e2                	ld	ra,24(sp)
    8000565c:	6442                	ld	s0,16(sp)
    8000565e:	6105                	addi	sp,sp,32
    80005660:	8082                	ret

0000000080005662 <sys_fstat>:
{
    80005662:	1101                	addi	sp,sp,-32
    80005664:	ec06                	sd	ra,24(sp)
    80005666:	e822                	sd	s0,16(sp)
    80005668:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000566a:	fe040593          	addi	a1,s0,-32
    8000566e:	4505                	li	a0,1
    80005670:	aaffd0ef          	jal	8000311e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005674:	fe840613          	addi	a2,s0,-24
    80005678:	4581                	li	a1,0
    8000567a:	4501                	li	a0,0
    8000567c:	cf9ff0ef          	jal	80005374 <argfd>
    80005680:	87aa                	mv	a5,a0
    return -1;
    80005682:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005684:	0007c863          	bltz	a5,80005694 <sys_fstat+0x32>
  return filestat(f, st);
    80005688:	fe043583          	ld	a1,-32(s0)
    8000568c:	fe843503          	ld	a0,-24(s0)
    80005690:	c2cff0ef          	jal	80004abc <filestat>
}
    80005694:	60e2                	ld	ra,24(sp)
    80005696:	6442                	ld	s0,16(sp)
    80005698:	6105                	addi	sp,sp,32
    8000569a:	8082                	ret

000000008000569c <sys_link>:
{
    8000569c:	7169                	addi	sp,sp,-304
    8000569e:	f606                	sd	ra,296(sp)
    800056a0:	f222                	sd	s0,288(sp)
    800056a2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056a4:	08000613          	li	a2,128
    800056a8:	ed040593          	addi	a1,s0,-304
    800056ac:	4501                	li	a0,0
    800056ae:	a8dfd0ef          	jal	8000313a <argstr>
    return -1;
    800056b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056b4:	0c054e63          	bltz	a0,80005790 <sys_link+0xf4>
    800056b8:	08000613          	li	a2,128
    800056bc:	f5040593          	addi	a1,s0,-176
    800056c0:	4505                	li	a0,1
    800056c2:	a79fd0ef          	jal	8000313a <argstr>
    return -1;
    800056c6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056c8:	0c054463          	bltz	a0,80005790 <sys_link+0xf4>
    800056cc:	ee26                	sd	s1,280(sp)
  begin_op();
    800056ce:	f21fe0ef          	jal	800045ee <begin_op>
  if((ip = namei(old)) == 0){
    800056d2:	ed040513          	addi	a0,s0,-304
    800056d6:	d45fe0ef          	jal	8000441a <namei>
    800056da:	84aa                	mv	s1,a0
    800056dc:	c53d                	beqz	a0,8000574a <sys_link+0xae>
  ilock(ip);
    800056de:	d26fe0ef          	jal	80003c04 <ilock>
  if(ip->type == T_DIR){
    800056e2:	04449703          	lh	a4,68(s1)
    800056e6:	4785                	li	a5,1
    800056e8:	06f70663          	beq	a4,a5,80005754 <sys_link+0xb8>
    800056ec:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800056ee:	04a4d783          	lhu	a5,74(s1)
    800056f2:	2785                	addiw	a5,a5,1
    800056f4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056f8:	8526                	mv	a0,s1
    800056fa:	c56fe0ef          	jal	80003b50 <iupdate>
  iunlock(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	db2fe0ef          	jal	80003cb2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005704:	fd040593          	addi	a1,s0,-48
    80005708:	f5040513          	addi	a0,s0,-176
    8000570c:	d29fe0ef          	jal	80004434 <nameiparent>
    80005710:	892a                	mv	s2,a0
    80005712:	cd21                	beqz	a0,8000576a <sys_link+0xce>
  ilock(dp);
    80005714:	cf0fe0ef          	jal	80003c04 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005718:	00092703          	lw	a4,0(s2)
    8000571c:	409c                	lw	a5,0(s1)
    8000571e:	04f71363          	bne	a4,a5,80005764 <sys_link+0xc8>
    80005722:	40d0                	lw	a2,4(s1)
    80005724:	fd040593          	addi	a1,s0,-48
    80005728:	854a                	mv	a0,s2
    8000572a:	c57fe0ef          	jal	80004380 <dirlink>
    8000572e:	02054b63          	bltz	a0,80005764 <sys_link+0xc8>
  iunlockput(dp);
    80005732:	854a                	mv	a0,s2
    80005734:	edafe0ef          	jal	80003e0e <iunlockput>
  iput(ip);
    80005738:	8526                	mv	a0,s1
    8000573a:	e4cfe0ef          	jal	80003d86 <iput>
  end_op();
    8000573e:	f1bfe0ef          	jal	80004658 <end_op>
  return 0;
    80005742:	4781                	li	a5,0
    80005744:	64f2                	ld	s1,280(sp)
    80005746:	6952                	ld	s2,272(sp)
    80005748:	a0a1                	j	80005790 <sys_link+0xf4>
    end_op();
    8000574a:	f0ffe0ef          	jal	80004658 <end_op>
    return -1;
    8000574e:	57fd                	li	a5,-1
    80005750:	64f2                	ld	s1,280(sp)
    80005752:	a83d                	j	80005790 <sys_link+0xf4>
    iunlockput(ip);
    80005754:	8526                	mv	a0,s1
    80005756:	eb8fe0ef          	jal	80003e0e <iunlockput>
    end_op();
    8000575a:	efffe0ef          	jal	80004658 <end_op>
    return -1;
    8000575e:	57fd                	li	a5,-1
    80005760:	64f2                	ld	s1,280(sp)
    80005762:	a03d                	j	80005790 <sys_link+0xf4>
    iunlockput(dp);
    80005764:	854a                	mv	a0,s2
    80005766:	ea8fe0ef          	jal	80003e0e <iunlockput>
  ilock(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	c98fe0ef          	jal	80003c04 <ilock>
  ip->nlink--;
    80005770:	04a4d783          	lhu	a5,74(s1)
    80005774:	37fd                	addiw	a5,a5,-1
    80005776:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000577a:	8526                	mv	a0,s1
    8000577c:	bd4fe0ef          	jal	80003b50 <iupdate>
  iunlockput(ip);
    80005780:	8526                	mv	a0,s1
    80005782:	e8cfe0ef          	jal	80003e0e <iunlockput>
  end_op();
    80005786:	ed3fe0ef          	jal	80004658 <end_op>
  return -1;
    8000578a:	57fd                	li	a5,-1
    8000578c:	64f2                	ld	s1,280(sp)
    8000578e:	6952                	ld	s2,272(sp)
}
    80005790:	853e                	mv	a0,a5
    80005792:	70b2                	ld	ra,296(sp)
    80005794:	7412                	ld	s0,288(sp)
    80005796:	6155                	addi	sp,sp,304
    80005798:	8082                	ret

000000008000579a <sys_unlink>:
{
    8000579a:	7151                	addi	sp,sp,-240
    8000579c:	f586                	sd	ra,232(sp)
    8000579e:	f1a2                	sd	s0,224(sp)
    800057a0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057a2:	08000613          	li	a2,128
    800057a6:	f3040593          	addi	a1,s0,-208
    800057aa:	4501                	li	a0,0
    800057ac:	98ffd0ef          	jal	8000313a <argstr>
    800057b0:	16054063          	bltz	a0,80005910 <sys_unlink+0x176>
    800057b4:	eda6                	sd	s1,216(sp)
  begin_op();
    800057b6:	e39fe0ef          	jal	800045ee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057ba:	fb040593          	addi	a1,s0,-80
    800057be:	f3040513          	addi	a0,s0,-208
    800057c2:	c73fe0ef          	jal	80004434 <nameiparent>
    800057c6:	84aa                	mv	s1,a0
    800057c8:	c945                	beqz	a0,80005878 <sys_unlink+0xde>
  ilock(dp);
    800057ca:	c3afe0ef          	jal	80003c04 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057ce:	00003597          	auipc	a1,0x3
    800057d2:	eda58593          	addi	a1,a1,-294 # 800086a8 <etext+0x6a8>
    800057d6:	fb040513          	addi	a0,s0,-80
    800057da:	9c5fe0ef          	jal	8000419e <namecmp>
    800057de:	10050e63          	beqz	a0,800058fa <sys_unlink+0x160>
    800057e2:	00003597          	auipc	a1,0x3
    800057e6:	ece58593          	addi	a1,a1,-306 # 800086b0 <etext+0x6b0>
    800057ea:	fb040513          	addi	a0,s0,-80
    800057ee:	9b1fe0ef          	jal	8000419e <namecmp>
    800057f2:	10050463          	beqz	a0,800058fa <sys_unlink+0x160>
    800057f6:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057f8:	f2c40613          	addi	a2,s0,-212
    800057fc:	fb040593          	addi	a1,s0,-80
    80005800:	8526                	mv	a0,s1
    80005802:	9b3fe0ef          	jal	800041b4 <dirlookup>
    80005806:	892a                	mv	s2,a0
    80005808:	0e050863          	beqz	a0,800058f8 <sys_unlink+0x15e>
  ilock(ip);
    8000580c:	bf8fe0ef          	jal	80003c04 <ilock>
  if(ip->nlink < 1)
    80005810:	04a91783          	lh	a5,74(s2)
    80005814:	06f05763          	blez	a5,80005882 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005818:	04491703          	lh	a4,68(s2)
    8000581c:	4785                	li	a5,1
    8000581e:	06f70963          	beq	a4,a5,80005890 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005822:	4641                	li	a2,16
    80005824:	4581                	li	a1,0
    80005826:	fc040513          	addi	a0,s0,-64
    8000582a:	e84fb0ef          	jal	80000eae <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000582e:	4741                	li	a4,16
    80005830:	f2c42683          	lw	a3,-212(s0)
    80005834:	fc040613          	addi	a2,s0,-64
    80005838:	4581                	li	a1,0
    8000583a:	8526                	mv	a0,s1
    8000583c:	855fe0ef          	jal	80004090 <writei>
    80005840:	47c1                	li	a5,16
    80005842:	08f51b63          	bne	a0,a5,800058d8 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005846:	04491703          	lh	a4,68(s2)
    8000584a:	4785                	li	a5,1
    8000584c:	08f70d63          	beq	a4,a5,800058e6 <sys_unlink+0x14c>
  iunlockput(dp);
    80005850:	8526                	mv	a0,s1
    80005852:	dbcfe0ef          	jal	80003e0e <iunlockput>
  ip->nlink--;
    80005856:	04a95783          	lhu	a5,74(s2)
    8000585a:	37fd                	addiw	a5,a5,-1
    8000585c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005860:	854a                	mv	a0,s2
    80005862:	aeefe0ef          	jal	80003b50 <iupdate>
  iunlockput(ip);
    80005866:	854a                	mv	a0,s2
    80005868:	da6fe0ef          	jal	80003e0e <iunlockput>
  end_op();
    8000586c:	dedfe0ef          	jal	80004658 <end_op>
  return 0;
    80005870:	4501                	li	a0,0
    80005872:	64ee                	ld	s1,216(sp)
    80005874:	694e                	ld	s2,208(sp)
    80005876:	a849                	j	80005908 <sys_unlink+0x16e>
    end_op();
    80005878:	de1fe0ef          	jal	80004658 <end_op>
    return -1;
    8000587c:	557d                	li	a0,-1
    8000587e:	64ee                	ld	s1,216(sp)
    80005880:	a061                	j	80005908 <sys_unlink+0x16e>
    80005882:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005884:	00003517          	auipc	a0,0x3
    80005888:	e3450513          	addi	a0,a0,-460 # 800086b8 <etext+0x6b8>
    8000588c:	f55fa0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005890:	04c92703          	lw	a4,76(s2)
    80005894:	02000793          	li	a5,32
    80005898:	f8e7f5e3          	bgeu	a5,a4,80005822 <sys_unlink+0x88>
    8000589c:	e5ce                	sd	s3,200(sp)
    8000589e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a2:	4741                	li	a4,16
    800058a4:	86ce                	mv	a3,s3
    800058a6:	f1840613          	addi	a2,s0,-232
    800058aa:	4581                	li	a1,0
    800058ac:	854a                	mv	a0,s2
    800058ae:	ee6fe0ef          	jal	80003f94 <readi>
    800058b2:	47c1                	li	a5,16
    800058b4:	00f51c63          	bne	a0,a5,800058cc <sys_unlink+0x132>
    if(de.inum != 0)
    800058b8:	f1845783          	lhu	a5,-232(s0)
    800058bc:	efa1                	bnez	a5,80005914 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058be:	29c1                	addiw	s3,s3,16
    800058c0:	04c92783          	lw	a5,76(s2)
    800058c4:	fcf9efe3          	bltu	s3,a5,800058a2 <sys_unlink+0x108>
    800058c8:	69ae                	ld	s3,200(sp)
    800058ca:	bfa1                	j	80005822 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800058cc:	00003517          	auipc	a0,0x3
    800058d0:	e0450513          	addi	a0,a0,-508 # 800086d0 <etext+0x6d0>
    800058d4:	f0dfa0ef          	jal	800007e0 <panic>
    800058d8:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800058da:	00003517          	auipc	a0,0x3
    800058de:	e0e50513          	addi	a0,a0,-498 # 800086e8 <etext+0x6e8>
    800058e2:	efffa0ef          	jal	800007e0 <panic>
    dp->nlink--;
    800058e6:	04a4d783          	lhu	a5,74(s1)
    800058ea:	37fd                	addiw	a5,a5,-1
    800058ec:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058f0:	8526                	mv	a0,s1
    800058f2:	a5efe0ef          	jal	80003b50 <iupdate>
    800058f6:	bfa9                	j	80005850 <sys_unlink+0xb6>
    800058f8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800058fa:	8526                	mv	a0,s1
    800058fc:	d12fe0ef          	jal	80003e0e <iunlockput>
  end_op();
    80005900:	d59fe0ef          	jal	80004658 <end_op>
  return -1;
    80005904:	557d                	li	a0,-1
    80005906:	64ee                	ld	s1,216(sp)
}
    80005908:	70ae                	ld	ra,232(sp)
    8000590a:	740e                	ld	s0,224(sp)
    8000590c:	616d                	addi	sp,sp,240
    8000590e:	8082                	ret
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	bfdd                	j	80005908 <sys_unlink+0x16e>
    iunlockput(ip);
    80005914:	854a                	mv	a0,s2
    80005916:	cf8fe0ef          	jal	80003e0e <iunlockput>
    goto bad;
    8000591a:	694e                	ld	s2,208(sp)
    8000591c:	69ae                	ld	s3,200(sp)
    8000591e:	bff1                	j	800058fa <sys_unlink+0x160>

0000000080005920 <sys_open>:

uint64
sys_open(void)
{
    80005920:	7131                	addi	sp,sp,-192
    80005922:	fd06                	sd	ra,184(sp)
    80005924:	f922                	sd	s0,176(sp)
    80005926:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005928:	f4c40593          	addi	a1,s0,-180
    8000592c:	4505                	li	a0,1
    8000592e:	fd4fd0ef          	jal	80003102 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005932:	08000613          	li	a2,128
    80005936:	f5040593          	addi	a1,s0,-176
    8000593a:	4501                	li	a0,0
    8000593c:	ffefd0ef          	jal	8000313a <argstr>
    80005940:	87aa                	mv	a5,a0
    return -1;
    80005942:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005944:	0a07c263          	bltz	a5,800059e8 <sys_open+0xc8>
    80005948:	f526                	sd	s1,168(sp)

  begin_op();
    8000594a:	ca5fe0ef          	jal	800045ee <begin_op>

  if(omode & O_CREATE){
    8000594e:	f4c42783          	lw	a5,-180(s0)
    80005952:	2007f793          	andi	a5,a5,512
    80005956:	c3d5                	beqz	a5,800059fa <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005958:	4681                	li	a3,0
    8000595a:	4601                	li	a2,0
    8000595c:	4589                	li	a1,2
    8000595e:	f5040513          	addi	a0,s0,-176
    80005962:	aa9ff0ef          	jal	8000540a <create>
    80005966:	84aa                	mv	s1,a0
    if(ip == 0){
    80005968:	c541                	beqz	a0,800059f0 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000596a:	04449703          	lh	a4,68(s1)
    8000596e:	478d                	li	a5,3
    80005970:	00f71763          	bne	a4,a5,8000597e <sys_open+0x5e>
    80005974:	0464d703          	lhu	a4,70(s1)
    80005978:	47a5                	li	a5,9
    8000597a:	0ae7ed63          	bltu	a5,a4,80005a34 <sys_open+0x114>
    8000597e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005980:	fd7fe0ef          	jal	80004956 <filealloc>
    80005984:	892a                	mv	s2,a0
    80005986:	c179                	beqz	a0,80005a4c <sys_open+0x12c>
    80005988:	ed4e                	sd	s3,152(sp)
    8000598a:	a43ff0ef          	jal	800053cc <fdalloc>
    8000598e:	89aa                	mv	s3,a0
    80005990:	0a054a63          	bltz	a0,80005a44 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005994:	04449703          	lh	a4,68(s1)
    80005998:	478d                	li	a5,3
    8000599a:	0cf70263          	beq	a4,a5,80005a5e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000599e:	4789                	li	a5,2
    800059a0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059a4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059a8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059ac:	f4c42783          	lw	a5,-180(s0)
    800059b0:	0017c713          	xori	a4,a5,1
    800059b4:	8b05                	andi	a4,a4,1
    800059b6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059ba:	0037f713          	andi	a4,a5,3
    800059be:	00e03733          	snez	a4,a4
    800059c2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059c6:	4007f793          	andi	a5,a5,1024
    800059ca:	c791                	beqz	a5,800059d6 <sys_open+0xb6>
    800059cc:	04449703          	lh	a4,68(s1)
    800059d0:	4789                	li	a5,2
    800059d2:	08f70d63          	beq	a4,a5,80005a6c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800059d6:	8526                	mv	a0,s1
    800059d8:	adafe0ef          	jal	80003cb2 <iunlock>
  end_op();
    800059dc:	c7dfe0ef          	jal	80004658 <end_op>

  return fd;
    800059e0:	854e                	mv	a0,s3
    800059e2:	74aa                	ld	s1,168(sp)
    800059e4:	790a                	ld	s2,160(sp)
    800059e6:	69ea                	ld	s3,152(sp)
}
    800059e8:	70ea                	ld	ra,184(sp)
    800059ea:	744a                	ld	s0,176(sp)
    800059ec:	6129                	addi	sp,sp,192
    800059ee:	8082                	ret
      end_op();
    800059f0:	c69fe0ef          	jal	80004658 <end_op>
      return -1;
    800059f4:	557d                	li	a0,-1
    800059f6:	74aa                	ld	s1,168(sp)
    800059f8:	bfc5                	j	800059e8 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800059fa:	f5040513          	addi	a0,s0,-176
    800059fe:	a1dfe0ef          	jal	8000441a <namei>
    80005a02:	84aa                	mv	s1,a0
    80005a04:	c11d                	beqz	a0,80005a2a <sys_open+0x10a>
    ilock(ip);
    80005a06:	9fefe0ef          	jal	80003c04 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a0a:	04449703          	lh	a4,68(s1)
    80005a0e:	4785                	li	a5,1
    80005a10:	f4f71de3          	bne	a4,a5,8000596a <sys_open+0x4a>
    80005a14:	f4c42783          	lw	a5,-180(s0)
    80005a18:	d3bd                	beqz	a5,8000597e <sys_open+0x5e>
      iunlockput(ip);
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	bf2fe0ef          	jal	80003e0e <iunlockput>
      end_op();
    80005a20:	c39fe0ef          	jal	80004658 <end_op>
      return -1;
    80005a24:	557d                	li	a0,-1
    80005a26:	74aa                	ld	s1,168(sp)
    80005a28:	b7c1                	j	800059e8 <sys_open+0xc8>
      end_op();
    80005a2a:	c2ffe0ef          	jal	80004658 <end_op>
      return -1;
    80005a2e:	557d                	li	a0,-1
    80005a30:	74aa                	ld	s1,168(sp)
    80005a32:	bf5d                	j	800059e8 <sys_open+0xc8>
    iunlockput(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	bd8fe0ef          	jal	80003e0e <iunlockput>
    end_op();
    80005a3a:	c1ffe0ef          	jal	80004658 <end_op>
    return -1;
    80005a3e:	557d                	li	a0,-1
    80005a40:	74aa                	ld	s1,168(sp)
    80005a42:	b75d                	j	800059e8 <sys_open+0xc8>
      fileclose(f);
    80005a44:	854a                	mv	a0,s2
    80005a46:	fb5fe0ef          	jal	800049fa <fileclose>
    80005a4a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	bc0fe0ef          	jal	80003e0e <iunlockput>
    end_op();
    80005a52:	c07fe0ef          	jal	80004658 <end_op>
    return -1;
    80005a56:	557d                	li	a0,-1
    80005a58:	74aa                	ld	s1,168(sp)
    80005a5a:	790a                	ld	s2,160(sp)
    80005a5c:	b771                	j	800059e8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005a5e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005a62:	04649783          	lh	a5,70(s1)
    80005a66:	02f91223          	sh	a5,36(s2)
    80005a6a:	bf3d                	j	800059a8 <sys_open+0x88>
    itrunc(ip);
    80005a6c:	8526                	mv	a0,s1
    80005a6e:	a84fe0ef          	jal	80003cf2 <itrunc>
    80005a72:	b795                	j	800059d6 <sys_open+0xb6>

0000000080005a74 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a74:	7175                	addi	sp,sp,-144
    80005a76:	e506                	sd	ra,136(sp)
    80005a78:	e122                	sd	s0,128(sp)
    80005a7a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a7c:	b73fe0ef          	jal	800045ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a80:	08000613          	li	a2,128
    80005a84:	f7040593          	addi	a1,s0,-144
    80005a88:	4501                	li	a0,0
    80005a8a:	eb0fd0ef          	jal	8000313a <argstr>
    80005a8e:	02054363          	bltz	a0,80005ab4 <sys_mkdir+0x40>
    80005a92:	4681                	li	a3,0
    80005a94:	4601                	li	a2,0
    80005a96:	4585                	li	a1,1
    80005a98:	f7040513          	addi	a0,s0,-144
    80005a9c:	96fff0ef          	jal	8000540a <create>
    80005aa0:	c911                	beqz	a0,80005ab4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aa2:	b6cfe0ef          	jal	80003e0e <iunlockput>
  end_op();
    80005aa6:	bb3fe0ef          	jal	80004658 <end_op>
  return 0;
    80005aaa:	4501                	li	a0,0
}
    80005aac:	60aa                	ld	ra,136(sp)
    80005aae:	640a                	ld	s0,128(sp)
    80005ab0:	6149                	addi	sp,sp,144
    80005ab2:	8082                	ret
    end_op();
    80005ab4:	ba5fe0ef          	jal	80004658 <end_op>
    return -1;
    80005ab8:	557d                	li	a0,-1
    80005aba:	bfcd                	j	80005aac <sys_mkdir+0x38>

0000000080005abc <sys_mknod>:

uint64
sys_mknod(void)
{
    80005abc:	7135                	addi	sp,sp,-160
    80005abe:	ed06                	sd	ra,152(sp)
    80005ac0:	e922                	sd	s0,144(sp)
    80005ac2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ac4:	b2bfe0ef          	jal	800045ee <begin_op>
  argint(1, &major);
    80005ac8:	f6c40593          	addi	a1,s0,-148
    80005acc:	4505                	li	a0,1
    80005ace:	e34fd0ef          	jal	80003102 <argint>
  argint(2, &minor);
    80005ad2:	f6840593          	addi	a1,s0,-152
    80005ad6:	4509                	li	a0,2
    80005ad8:	e2afd0ef          	jal	80003102 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005adc:	08000613          	li	a2,128
    80005ae0:	f7040593          	addi	a1,s0,-144
    80005ae4:	4501                	li	a0,0
    80005ae6:	e54fd0ef          	jal	8000313a <argstr>
    80005aea:	02054563          	bltz	a0,80005b14 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aee:	f6841683          	lh	a3,-152(s0)
    80005af2:	f6c41603          	lh	a2,-148(s0)
    80005af6:	458d                	li	a1,3
    80005af8:	f7040513          	addi	a0,s0,-144
    80005afc:	90fff0ef          	jal	8000540a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b00:	c911                	beqz	a0,80005b14 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b02:	b0cfe0ef          	jal	80003e0e <iunlockput>
  end_op();
    80005b06:	b53fe0ef          	jal	80004658 <end_op>
  return 0;
    80005b0a:	4501                	li	a0,0
}
    80005b0c:	60ea                	ld	ra,152(sp)
    80005b0e:	644a                	ld	s0,144(sp)
    80005b10:	610d                	addi	sp,sp,160
    80005b12:	8082                	ret
    end_op();
    80005b14:	b45fe0ef          	jal	80004658 <end_op>
    return -1;
    80005b18:	557d                	li	a0,-1
    80005b1a:	bfcd                	j	80005b0c <sys_mknod+0x50>

0000000080005b1c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b1c:	7135                	addi	sp,sp,-160
    80005b1e:	ed06                	sd	ra,152(sp)
    80005b20:	e922                	sd	s0,144(sp)
    80005b22:	e14a                	sd	s2,128(sp)
    80005b24:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b26:	a54fc0ef          	jal	80001d7a <myproc>
    80005b2a:	892a                	mv	s2,a0
  
  begin_op();
    80005b2c:	ac3fe0ef          	jal	800045ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b30:	08000613          	li	a2,128
    80005b34:	f6040593          	addi	a1,s0,-160
    80005b38:	4501                	li	a0,0
    80005b3a:	e00fd0ef          	jal	8000313a <argstr>
    80005b3e:	04054363          	bltz	a0,80005b84 <sys_chdir+0x68>
    80005b42:	e526                	sd	s1,136(sp)
    80005b44:	f6040513          	addi	a0,s0,-160
    80005b48:	8d3fe0ef          	jal	8000441a <namei>
    80005b4c:	84aa                	mv	s1,a0
    80005b4e:	c915                	beqz	a0,80005b82 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b50:	8b4fe0ef          	jal	80003c04 <ilock>
  if(ip->type != T_DIR){
    80005b54:	04449703          	lh	a4,68(s1)
    80005b58:	4785                	li	a5,1
    80005b5a:	02f71963          	bne	a4,a5,80005b8c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b5e:	8526                	mv	a0,s1
    80005b60:	952fe0ef          	jal	80003cb2 <iunlock>
  iput(p->cwd);
    80005b64:	15093503          	ld	a0,336(s2)
    80005b68:	a1efe0ef          	jal	80003d86 <iput>
  end_op();
    80005b6c:	aedfe0ef          	jal	80004658 <end_op>
  p->cwd = ip;
    80005b70:	14993823          	sd	s1,336(s2)
  return 0;
    80005b74:	4501                	li	a0,0
    80005b76:	64aa                	ld	s1,136(sp)
}
    80005b78:	60ea                	ld	ra,152(sp)
    80005b7a:	644a                	ld	s0,144(sp)
    80005b7c:	690a                	ld	s2,128(sp)
    80005b7e:	610d                	addi	sp,sp,160
    80005b80:	8082                	ret
    80005b82:	64aa                	ld	s1,136(sp)
    end_op();
    80005b84:	ad5fe0ef          	jal	80004658 <end_op>
    return -1;
    80005b88:	557d                	li	a0,-1
    80005b8a:	b7fd                	j	80005b78 <sys_chdir+0x5c>
    iunlockput(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	a80fe0ef          	jal	80003e0e <iunlockput>
    end_op();
    80005b92:	ac7fe0ef          	jal	80004658 <end_op>
    return -1;
    80005b96:	557d                	li	a0,-1
    80005b98:	64aa                	ld	s1,136(sp)
    80005b9a:	bff9                	j	80005b78 <sys_chdir+0x5c>

0000000080005b9c <sys_exec>:

uint64
sys_exec(void)
{
    80005b9c:	7121                	addi	sp,sp,-448
    80005b9e:	ff06                	sd	ra,440(sp)
    80005ba0:	fb22                	sd	s0,432(sp)
    80005ba2:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ba4:	e4840593          	addi	a1,s0,-440
    80005ba8:	4505                	li	a0,1
    80005baa:	d74fd0ef          	jal	8000311e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005bae:	08000613          	li	a2,128
    80005bb2:	f5040593          	addi	a1,s0,-176
    80005bb6:	4501                	li	a0,0
    80005bb8:	d82fd0ef          	jal	8000313a <argstr>
    80005bbc:	87aa                	mv	a5,a0
    return -1;
    80005bbe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005bc0:	0c07c463          	bltz	a5,80005c88 <sys_exec+0xec>
    80005bc4:	f726                	sd	s1,424(sp)
    80005bc6:	f34a                	sd	s2,416(sp)
    80005bc8:	ef4e                	sd	s3,408(sp)
    80005bca:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005bcc:	10000613          	li	a2,256
    80005bd0:	4581                	li	a1,0
    80005bd2:	e5040513          	addi	a0,s0,-432
    80005bd6:	ad8fb0ef          	jal	80000eae <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bda:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005bde:	89a6                	mv	s3,s1
    80005be0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005be2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005be6:	00391513          	slli	a0,s2,0x3
    80005bea:	e4040593          	addi	a1,s0,-448
    80005bee:	e4843783          	ld	a5,-440(s0)
    80005bf2:	953e                	add	a0,a0,a5
    80005bf4:	c84fd0ef          	jal	80003078 <fetchaddr>
    80005bf8:	02054663          	bltz	a0,80005c24 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005bfc:	e4043783          	ld	a5,-448(s0)
    80005c00:	c3a9                	beqz	a5,80005c42 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c02:	8defb0ef          	jal	80000ce0 <kalloc>
    80005c06:	85aa                	mv	a1,a0
    80005c08:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c0c:	cd01                	beqz	a0,80005c24 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c0e:	6605                	lui	a2,0x1
    80005c10:	e4043503          	ld	a0,-448(s0)
    80005c14:	caefd0ef          	jal	800030c2 <fetchstr>
    80005c18:	00054663          	bltz	a0,80005c24 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005c1c:	0905                	addi	s2,s2,1
    80005c1e:	09a1                	addi	s3,s3,8
    80005c20:	fd4913e3          	bne	s2,s4,80005be6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c24:	f5040913          	addi	s2,s0,-176
    80005c28:	6088                	ld	a0,0(s1)
    80005c2a:	c931                	beqz	a0,80005c7e <sys_exec+0xe2>
    kfree(argv[i]);
    80005c2c:	f33fa0ef          	jal	80000b5e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c30:	04a1                	addi	s1,s1,8
    80005c32:	ff249be3          	bne	s1,s2,80005c28 <sys_exec+0x8c>
  return -1;
    80005c36:	557d                	li	a0,-1
    80005c38:	74ba                	ld	s1,424(sp)
    80005c3a:	791a                	ld	s2,416(sp)
    80005c3c:	69fa                	ld	s3,408(sp)
    80005c3e:	6a5a                	ld	s4,400(sp)
    80005c40:	a0a1                	j	80005c88 <sys_exec+0xec>
      argv[i] = 0;
    80005c42:	0009079b          	sext.w	a5,s2
    80005c46:	078e                	slli	a5,a5,0x3
    80005c48:	fd078793          	addi	a5,a5,-48
    80005c4c:	97a2                	add	a5,a5,s0
    80005c4e:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005c52:	e5040593          	addi	a1,s0,-432
    80005c56:	f5040513          	addi	a0,s0,-176
    80005c5a:	ba8ff0ef          	jal	80005002 <kexec>
    80005c5e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c60:	f5040993          	addi	s3,s0,-176
    80005c64:	6088                	ld	a0,0(s1)
    80005c66:	c511                	beqz	a0,80005c72 <sys_exec+0xd6>
    kfree(argv[i]);
    80005c68:	ef7fa0ef          	jal	80000b5e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6c:	04a1                	addi	s1,s1,8
    80005c6e:	ff349be3          	bne	s1,s3,80005c64 <sys_exec+0xc8>
  return ret;
    80005c72:	854a                	mv	a0,s2
    80005c74:	74ba                	ld	s1,424(sp)
    80005c76:	791a                	ld	s2,416(sp)
    80005c78:	69fa                	ld	s3,408(sp)
    80005c7a:	6a5a                	ld	s4,400(sp)
    80005c7c:	a031                	j	80005c88 <sys_exec+0xec>
  return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	74ba                	ld	s1,424(sp)
    80005c82:	791a                	ld	s2,416(sp)
    80005c84:	69fa                	ld	s3,408(sp)
    80005c86:	6a5a                	ld	s4,400(sp)
}
    80005c88:	70fa                	ld	ra,440(sp)
    80005c8a:	745a                	ld	s0,432(sp)
    80005c8c:	6139                	addi	sp,sp,448
    80005c8e:	8082                	ret

0000000080005c90 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c90:	7139                	addi	sp,sp,-64
    80005c92:	fc06                	sd	ra,56(sp)
    80005c94:	f822                	sd	s0,48(sp)
    80005c96:	f426                	sd	s1,40(sp)
    80005c98:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c9a:	8e0fc0ef          	jal	80001d7a <myproc>
    80005c9e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ca0:	fd840593          	addi	a1,s0,-40
    80005ca4:	4501                	li	a0,0
    80005ca6:	c78fd0ef          	jal	8000311e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005caa:	fc840593          	addi	a1,s0,-56
    80005cae:	fd040513          	addi	a0,s0,-48
    80005cb2:	852ff0ef          	jal	80004d04 <pipealloc>
    return -1;
    80005cb6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cb8:	0a054463          	bltz	a0,80005d60 <sys_pipe+0xd0>
  fd0 = -1;
    80005cbc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cc0:	fd043503          	ld	a0,-48(s0)
    80005cc4:	f08ff0ef          	jal	800053cc <fdalloc>
    80005cc8:	fca42223          	sw	a0,-60(s0)
    80005ccc:	08054163          	bltz	a0,80005d4e <sys_pipe+0xbe>
    80005cd0:	fc843503          	ld	a0,-56(s0)
    80005cd4:	ef8ff0ef          	jal	800053cc <fdalloc>
    80005cd8:	fca42023          	sw	a0,-64(s0)
    80005cdc:	06054063          	bltz	a0,80005d3c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ce0:	4691                	li	a3,4
    80005ce2:	fc440613          	addi	a2,s0,-60
    80005ce6:	fd843583          	ld	a1,-40(s0)
    80005cea:	68a8                	ld	a0,80(s1)
    80005cec:	c6dfb0ef          	jal	80001958 <copyout>
    80005cf0:	00054e63          	bltz	a0,80005d0c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cf4:	4691                	li	a3,4
    80005cf6:	fc040613          	addi	a2,s0,-64
    80005cfa:	fd843583          	ld	a1,-40(s0)
    80005cfe:	0591                	addi	a1,a1,4
    80005d00:	68a8                	ld	a0,80(s1)
    80005d02:	c57fb0ef          	jal	80001958 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d06:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d08:	04055c63          	bgez	a0,80005d60 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005d0c:	fc442783          	lw	a5,-60(s0)
    80005d10:	07e9                	addi	a5,a5,26
    80005d12:	078e                	slli	a5,a5,0x3
    80005d14:	97a6                	add	a5,a5,s1
    80005d16:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d1a:	fc042783          	lw	a5,-64(s0)
    80005d1e:	07e9                	addi	a5,a5,26
    80005d20:	078e                	slli	a5,a5,0x3
    80005d22:	94be                	add	s1,s1,a5
    80005d24:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d28:	fd043503          	ld	a0,-48(s0)
    80005d2c:	ccffe0ef          	jal	800049fa <fileclose>
    fileclose(wf);
    80005d30:	fc843503          	ld	a0,-56(s0)
    80005d34:	cc7fe0ef          	jal	800049fa <fileclose>
    return -1;
    80005d38:	57fd                	li	a5,-1
    80005d3a:	a01d                	j	80005d60 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005d3c:	fc442783          	lw	a5,-60(s0)
    80005d40:	0007c763          	bltz	a5,80005d4e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005d44:	07e9                	addi	a5,a5,26
    80005d46:	078e                	slli	a5,a5,0x3
    80005d48:	97a6                	add	a5,a5,s1
    80005d4a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d4e:	fd043503          	ld	a0,-48(s0)
    80005d52:	ca9fe0ef          	jal	800049fa <fileclose>
    fileclose(wf);
    80005d56:	fc843503          	ld	a0,-56(s0)
    80005d5a:	ca1fe0ef          	jal	800049fa <fileclose>
    return -1;
    80005d5e:	57fd                	li	a5,-1
}
    80005d60:	853e                	mv	a0,a5
    80005d62:	70e2                	ld	ra,56(sp)
    80005d64:	7442                	ld	s0,48(sp)
    80005d66:	74a2                	ld	s1,40(sp)
    80005d68:	6121                	addi	sp,sp,64
    80005d6a:	8082                	ret
    80005d6c:	0000                	unimp
	...

0000000080005d70 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005d70:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005d72:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005d74:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005d76:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005d78:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005d7a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005d7c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005d7e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005d80:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005d82:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005d84:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005d86:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005d88:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005d8a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005d8c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005d8e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005d90:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005d92:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005d94:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005d96:	9f2fd0ef          	jal	80002f88 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005d9a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005d9c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005d9e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005da0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005da2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005da4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005da6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005da8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005daa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005dac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005dae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005db0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005db2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005db4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005db6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005db8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005dba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005dbc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005dbe:	10200073          	sret
	...

0000000080005dce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dce:	1141                	addi	sp,sp,-16
    80005dd0:	e422                	sd	s0,8(sp)
    80005dd2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005dd4:	0c0007b7          	lui	a5,0xc000
    80005dd8:	4705                	li	a4,1
    80005dda:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ddc:	0c0007b7          	lui	a5,0xc000
    80005de0:	c3d8                	sw	a4,4(a5)
}
    80005de2:	6422                	ld	s0,8(sp)
    80005de4:	0141                	addi	sp,sp,16
    80005de6:	8082                	ret

0000000080005de8 <plicinithart>:

void
plicinithart(void)
{
    80005de8:	1141                	addi	sp,sp,-16
    80005dea:	e406                	sd	ra,8(sp)
    80005dec:	e022                	sd	s0,0(sp)
    80005dee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005df0:	f5ffb0ef          	jal	80001d4e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005df4:	0085171b          	slliw	a4,a0,0x8
    80005df8:	0c0027b7          	lui	a5,0xc002
    80005dfc:	97ba                	add	a5,a5,a4
    80005dfe:	40200713          	li	a4,1026
    80005e02:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e06:	00d5151b          	slliw	a0,a0,0xd
    80005e0a:	0c2017b7          	lui	a5,0xc201
    80005e0e:	97aa                	add	a5,a5,a0
    80005e10:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005e14:	60a2                	ld	ra,8(sp)
    80005e16:	6402                	ld	s0,0(sp)
    80005e18:	0141                	addi	sp,sp,16
    80005e1a:	8082                	ret

0000000080005e1c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e1c:	1141                	addi	sp,sp,-16
    80005e1e:	e406                	sd	ra,8(sp)
    80005e20:	e022                	sd	s0,0(sp)
    80005e22:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e24:	f2bfb0ef          	jal	80001d4e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e28:	00d5151b          	slliw	a0,a0,0xd
    80005e2c:	0c2017b7          	lui	a5,0xc201
    80005e30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e32:	43c8                	lw	a0,4(a5)
    80005e34:	60a2                	ld	ra,8(sp)
    80005e36:	6402                	ld	s0,0(sp)
    80005e38:	0141                	addi	sp,sp,16
    80005e3a:	8082                	ret

0000000080005e3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e3c:	1101                	addi	sp,sp,-32
    80005e3e:	ec06                	sd	ra,24(sp)
    80005e40:	e822                	sd	s0,16(sp)
    80005e42:	e426                	sd	s1,8(sp)
    80005e44:	1000                	addi	s0,sp,32
    80005e46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e48:	f07fb0ef          	jal	80001d4e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e4c:	00d5151b          	slliw	a0,a0,0xd
    80005e50:	0c2017b7          	lui	a5,0xc201
    80005e54:	97aa                	add	a5,a5,a0
    80005e56:	c3c4                	sw	s1,4(a5)
}
    80005e58:	60e2                	ld	ra,24(sp)
    80005e5a:	6442                	ld	s0,16(sp)
    80005e5c:	64a2                	ld	s1,8(sp)
    80005e5e:	6105                	addi	sp,sp,32
    80005e60:	8082                	ret

0000000080005e62 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e62:	1141                	addi	sp,sp,-16
    80005e64:	e406                	sd	ra,8(sp)
    80005e66:	e022                	sd	s0,0(sp)
    80005e68:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e6a:	479d                	li	a5,7
    80005e6c:	04a7ca63          	blt	a5,a0,80005ec0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005e70:	0003c797          	auipc	a5,0x3c
    80005e74:	71078793          	addi	a5,a5,1808 # 80042580 <disk>
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	0187c783          	lbu	a5,24(a5)
    80005e7e:	e7b9                	bnez	a5,80005ecc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e80:	00451693          	slli	a3,a0,0x4
    80005e84:	0003c797          	auipc	a5,0x3c
    80005e88:	6fc78793          	addi	a5,a5,1788 # 80042580 <disk>
    80005e8c:	6398                	ld	a4,0(a5)
    80005e8e:	9736                	add	a4,a4,a3
    80005e90:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e94:	6398                	ld	a4,0(a5)
    80005e96:	9736                	add	a4,a4,a3
    80005e98:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e9c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ea0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ea4:	97aa                	add	a5,a5,a0
    80005ea6:	4705                	li	a4,1
    80005ea8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005eac:	0003c517          	auipc	a0,0x3c
    80005eb0:	6ec50513          	addi	a0,a0,1772 # 80042598 <disk+0x18>
    80005eb4:	ed6fc0ef          	jal	8000258a <wakeup>
}
    80005eb8:	60a2                	ld	ra,8(sp)
    80005eba:	6402                	ld	s0,0(sp)
    80005ebc:	0141                	addi	sp,sp,16
    80005ebe:	8082                	ret
    panic("free_desc 1");
    80005ec0:	00003517          	auipc	a0,0x3
    80005ec4:	83850513          	addi	a0,a0,-1992 # 800086f8 <etext+0x6f8>
    80005ec8:	919fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    80005ecc:	00003517          	auipc	a0,0x3
    80005ed0:	83c50513          	addi	a0,a0,-1988 # 80008708 <etext+0x708>
    80005ed4:	90dfa0ef          	jal	800007e0 <panic>

0000000080005ed8 <virtio_disk_init>:
{
    80005ed8:	1101                	addi	sp,sp,-32
    80005eda:	ec06                	sd	ra,24(sp)
    80005edc:	e822                	sd	s0,16(sp)
    80005ede:	e426                	sd	s1,8(sp)
    80005ee0:	e04a                	sd	s2,0(sp)
    80005ee2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ee4:	00003597          	auipc	a1,0x3
    80005ee8:	83458593          	addi	a1,a1,-1996 # 80008718 <etext+0x718>
    80005eec:	0003c517          	auipc	a0,0x3c
    80005ef0:	7bc50513          	addi	a0,a0,1980 # 800426a8 <disk+0x128>
    80005ef4:	e67fa0ef          	jal	80000d5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ef8:	100017b7          	lui	a5,0x10001
    80005efc:	4398                	lw	a4,0(a5)
    80005efe:	2701                	sext.w	a4,a4
    80005f00:	747277b7          	lui	a5,0x74727
    80005f04:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f08:	18f71063          	bne	a4,a5,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f0c:	100017b7          	lui	a5,0x10001
    80005f10:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005f12:	439c                	lw	a5,0(a5)
    80005f14:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f16:	4709                	li	a4,2
    80005f18:	16e79863          	bne	a5,a4,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f1c:	100017b7          	lui	a5,0x10001
    80005f20:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005f22:	439c                	lw	a5,0(a5)
    80005f24:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f26:	16e79163          	bne	a5,a4,80006088 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f2a:	100017b7          	lui	a5,0x10001
    80005f2e:	47d8                	lw	a4,12(a5)
    80005f30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f32:	554d47b7          	lui	a5,0x554d4
    80005f36:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f3a:	14f71763          	bne	a4,a5,80006088 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f3e:	100017b7          	lui	a5,0x10001
    80005f42:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f46:	4705                	li	a4,1
    80005f48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4a:	470d                	li	a4,3
    80005f4c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f4e:	10001737          	lui	a4,0x10001
    80005f52:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f54:	c7ffe737          	lui	a4,0xc7ffe
    80005f58:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc09f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f5c:	8ef9                	and	a3,a3,a4
    80005f5e:	10001737          	lui	a4,0x10001
    80005f62:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f64:	472d                	li	a4,11
    80005f66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f68:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005f6c:	439c                	lw	a5,0(a5)
    80005f6e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f72:	8ba1                	andi	a5,a5,8
    80005f74:	12078063          	beqz	a5,80006094 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f78:	100017b7          	lui	a5,0x10001
    80005f7c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f80:	100017b7          	lui	a5,0x10001
    80005f84:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005f88:	439c                	lw	a5,0(a5)
    80005f8a:	2781                	sext.w	a5,a5
    80005f8c:	10079a63          	bnez	a5,800060a0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f90:	100017b7          	lui	a5,0x10001
    80005f94:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005f98:	439c                	lw	a5,0(a5)
    80005f9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f9c:	10078863          	beqz	a5,800060ac <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005fa0:	471d                	li	a4,7
    80005fa2:	10f77b63          	bgeu	a4,a5,800060b8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005fa6:	d3bfa0ef          	jal	80000ce0 <kalloc>
    80005faa:	0003c497          	auipc	s1,0x3c
    80005fae:	5d648493          	addi	s1,s1,1494 # 80042580 <disk>
    80005fb2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fb4:	d2dfa0ef          	jal	80000ce0 <kalloc>
    80005fb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fba:	d27fa0ef          	jal	80000ce0 <kalloc>
    80005fbe:	87aa                	mv	a5,a0
    80005fc0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fc2:	6088                	ld	a0,0(s1)
    80005fc4:	10050063          	beqz	a0,800060c4 <virtio_disk_init+0x1ec>
    80005fc8:	0003c717          	auipc	a4,0x3c
    80005fcc:	5c073703          	ld	a4,1472(a4) # 80042588 <disk+0x8>
    80005fd0:	0e070a63          	beqz	a4,800060c4 <virtio_disk_init+0x1ec>
    80005fd4:	0e078863          	beqz	a5,800060c4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005fd8:	6605                	lui	a2,0x1
    80005fda:	4581                	li	a1,0
    80005fdc:	ed3fa0ef          	jal	80000eae <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fe0:	0003c497          	auipc	s1,0x3c
    80005fe4:	5a048493          	addi	s1,s1,1440 # 80042580 <disk>
    80005fe8:	6605                	lui	a2,0x1
    80005fea:	4581                	li	a1,0
    80005fec:	6488                	ld	a0,8(s1)
    80005fee:	ec1fa0ef          	jal	80000eae <memset>
  memset(disk.used, 0, PGSIZE);
    80005ff2:	6605                	lui	a2,0x1
    80005ff4:	4581                	li	a1,0
    80005ff6:	6888                	ld	a0,16(s1)
    80005ff8:	eb7fa0ef          	jal	80000eae <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	4721                	li	a4,8
    80006002:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006004:	4098                	lw	a4,0(s1)
    80006006:	100017b7          	lui	a5,0x10001
    8000600a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000600e:	40d8                	lw	a4,4(s1)
    80006010:	100017b7          	lui	a5,0x10001
    80006014:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006018:	649c                	ld	a5,8(s1)
    8000601a:	0007869b          	sext.w	a3,a5
    8000601e:	10001737          	lui	a4,0x10001
    80006022:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006026:	9781                	srai	a5,a5,0x20
    80006028:	10001737          	lui	a4,0x10001
    8000602c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006030:	689c                	ld	a5,16(s1)
    80006032:	0007869b          	sext.w	a3,a5
    80006036:	10001737          	lui	a4,0x10001
    8000603a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000603e:	9781                	srai	a5,a5,0x20
    80006040:	10001737          	lui	a4,0x10001
    80006044:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006048:	10001737          	lui	a4,0x10001
    8000604c:	4785                	li	a5,1
    8000604e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006050:	00f48c23          	sb	a5,24(s1)
    80006054:	00f48ca3          	sb	a5,25(s1)
    80006058:	00f48d23          	sb	a5,26(s1)
    8000605c:	00f48da3          	sb	a5,27(s1)
    80006060:	00f48e23          	sb	a5,28(s1)
    80006064:	00f48ea3          	sb	a5,29(s1)
    80006068:	00f48f23          	sb	a5,30(s1)
    8000606c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006070:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006074:	100017b7          	lui	a5,0x10001
    80006078:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000607c:	60e2                	ld	ra,24(sp)
    8000607e:	6442                	ld	s0,16(sp)
    80006080:	64a2                	ld	s1,8(sp)
    80006082:	6902                	ld	s2,0(sp)
    80006084:	6105                	addi	sp,sp,32
    80006086:	8082                	ret
    panic("could not find virtio disk");
    80006088:	00002517          	auipc	a0,0x2
    8000608c:	6a050513          	addi	a0,a0,1696 # 80008728 <etext+0x728>
    80006090:	f50fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006094:	00002517          	auipc	a0,0x2
    80006098:	6b450513          	addi	a0,a0,1716 # 80008748 <etext+0x748>
    8000609c:	f44fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800060a0:	00002517          	auipc	a0,0x2
    800060a4:	6c850513          	addi	a0,a0,1736 # 80008768 <etext+0x768>
    800060a8:	f38fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800060ac:	00002517          	auipc	a0,0x2
    800060b0:	6dc50513          	addi	a0,a0,1756 # 80008788 <etext+0x788>
    800060b4:	f2cfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	6f050513          	addi	a0,a0,1776 # 800087a8 <etext+0x7a8>
    800060c0:	f20fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800060c4:	00002517          	auipc	a0,0x2
    800060c8:	70450513          	addi	a0,a0,1796 # 800087c8 <etext+0x7c8>
    800060cc:	f14fa0ef          	jal	800007e0 <panic>

00000000800060d0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060d0:	7159                	addi	sp,sp,-112
    800060d2:	f486                	sd	ra,104(sp)
    800060d4:	f0a2                	sd	s0,96(sp)
    800060d6:	eca6                	sd	s1,88(sp)
    800060d8:	e8ca                	sd	s2,80(sp)
    800060da:	e4ce                	sd	s3,72(sp)
    800060dc:	e0d2                	sd	s4,64(sp)
    800060de:	fc56                	sd	s5,56(sp)
    800060e0:	f85a                	sd	s6,48(sp)
    800060e2:	f45e                	sd	s7,40(sp)
    800060e4:	f062                	sd	s8,32(sp)
    800060e6:	ec66                	sd	s9,24(sp)
    800060e8:	1880                	addi	s0,sp,112
    800060ea:	8a2a                	mv	s4,a0
    800060ec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060ee:	00c52c83          	lw	s9,12(a0)
    800060f2:	001c9c9b          	slliw	s9,s9,0x1
    800060f6:	1c82                	slli	s9,s9,0x20
    800060f8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060fc:	0003c517          	auipc	a0,0x3c
    80006100:	5ac50513          	addi	a0,a0,1452 # 800426a8 <disk+0x128>
    80006104:	cd7fa0ef          	jal	80000dda <acquire>
  for(int i = 0; i < 3; i++){
    80006108:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000610a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000610c:	0003cb17          	auipc	s6,0x3c
    80006110:	474b0b13          	addi	s6,s6,1140 # 80042580 <disk>
  for(int i = 0; i < 3; i++){
    80006114:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006116:	0003cc17          	auipc	s8,0x3c
    8000611a:	592c0c13          	addi	s8,s8,1426 # 800426a8 <disk+0x128>
    8000611e:	a8b9                	j	8000617c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006120:	00fb0733          	add	a4,s6,a5
    80006124:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006128:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000612a:	0207c563          	bltz	a5,80006154 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000612e:	2905                	addiw	s2,s2,1
    80006130:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006132:	05590963          	beq	s2,s5,80006184 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80006136:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006138:	0003c717          	auipc	a4,0x3c
    8000613c:	44870713          	addi	a4,a4,1096 # 80042580 <disk>
    80006140:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006142:	01874683          	lbu	a3,24(a4)
    80006146:	fee9                	bnez	a3,80006120 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006148:	2785                	addiw	a5,a5,1
    8000614a:	0705                	addi	a4,a4,1
    8000614c:	fe979be3          	bne	a5,s1,80006142 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006150:	57fd                	li	a5,-1
    80006152:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006154:	01205d63          	blez	s2,8000616e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006158:	f9042503          	lw	a0,-112(s0)
    8000615c:	d07ff0ef          	jal	80005e62 <free_desc>
      for(int j = 0; j < i; j++)
    80006160:	4785                	li	a5,1
    80006162:	0127d663          	bge	a5,s2,8000616e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006166:	f9442503          	lw	a0,-108(s0)
    8000616a:	cf9ff0ef          	jal	80005e62 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000616e:	85e2                	mv	a1,s8
    80006170:	0003c517          	auipc	a0,0x3c
    80006174:	42850513          	addi	a0,a0,1064 # 80042598 <disk+0x18>
    80006178:	bc6fc0ef          	jal	8000253e <sleep>
  for(int i = 0; i < 3; i++){
    8000617c:	f9040613          	addi	a2,s0,-112
    80006180:	894e                	mv	s2,s3
    80006182:	bf55                	j	80006136 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006184:	f9042503          	lw	a0,-112(s0)
    80006188:	00451693          	slli	a3,a0,0x4

  if(write)
    8000618c:	0003c797          	auipc	a5,0x3c
    80006190:	3f478793          	addi	a5,a5,1012 # 80042580 <disk>
    80006194:	00a50713          	addi	a4,a0,10
    80006198:	0712                	slli	a4,a4,0x4
    8000619a:	973e                	add	a4,a4,a5
    8000619c:	01703633          	snez	a2,s7
    800061a0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800061a6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061aa:	6398                	ld	a4,0(a5)
    800061ac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061ae:	0a868613          	addi	a2,a3,168
    800061b2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061b4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061b6:	6390                	ld	a2,0(a5)
    800061b8:	00d605b3          	add	a1,a2,a3
    800061bc:	4741                	li	a4,16
    800061be:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061c0:	4805                	li	a6,1
    800061c2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800061c6:	f9442703          	lw	a4,-108(s0)
    800061ca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061ce:	0712                	slli	a4,a4,0x4
    800061d0:	963a                	add	a2,a2,a4
    800061d2:	058a0593          	addi	a1,s4,88
    800061d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800061d8:	0007b883          	ld	a7,0(a5)
    800061dc:	9746                	add	a4,a4,a7
    800061de:	40000613          	li	a2,1024
    800061e2:	c710                	sw	a2,8(a4)
  if(write)
    800061e4:	001bb613          	seqz	a2,s7
    800061e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061ec:	00166613          	ori	a2,a2,1
    800061f0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800061f4:	f9842583          	lw	a1,-104(s0)
    800061f8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061fc:	00250613          	addi	a2,a0,2
    80006200:	0612                	slli	a2,a2,0x4
    80006202:	963e                	add	a2,a2,a5
    80006204:	577d                	li	a4,-1
    80006206:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000620a:	0592                	slli	a1,a1,0x4
    8000620c:	98ae                	add	a7,a7,a1
    8000620e:	03068713          	addi	a4,a3,48
    80006212:	973e                	add	a4,a4,a5
    80006214:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006218:	6398                	ld	a4,0(a5)
    8000621a:	972e                	add	a4,a4,a1
    8000621c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006220:	4689                	li	a3,2
    80006222:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006226:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000622a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000622e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006232:	6794                	ld	a3,8(a5)
    80006234:	0026d703          	lhu	a4,2(a3)
    80006238:	8b1d                	andi	a4,a4,7
    8000623a:	0706                	slli	a4,a4,0x1
    8000623c:	96ba                	add	a3,a3,a4
    8000623e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006242:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006246:	6798                	ld	a4,8(a5)
    80006248:	00275783          	lhu	a5,2(a4)
    8000624c:	2785                	addiw	a5,a5,1
    8000624e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006252:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006256:	100017b7          	lui	a5,0x10001
    8000625a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000625e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006262:	0003c917          	auipc	s2,0x3c
    80006266:	44690913          	addi	s2,s2,1094 # 800426a8 <disk+0x128>
  while(b->disk == 1) {
    8000626a:	4485                	li	s1,1
    8000626c:	01079a63          	bne	a5,a6,80006280 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006270:	85ca                	mv	a1,s2
    80006272:	8552                	mv	a0,s4
    80006274:	acafc0ef          	jal	8000253e <sleep>
  while(b->disk == 1) {
    80006278:	004a2783          	lw	a5,4(s4)
    8000627c:	fe978ae3          	beq	a5,s1,80006270 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006280:	f9042903          	lw	s2,-112(s0)
    80006284:	00290713          	addi	a4,s2,2
    80006288:	0712                	slli	a4,a4,0x4
    8000628a:	0003c797          	auipc	a5,0x3c
    8000628e:	2f678793          	addi	a5,a5,758 # 80042580 <disk>
    80006292:	97ba                	add	a5,a5,a4
    80006294:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006298:	0003c997          	auipc	s3,0x3c
    8000629c:	2e898993          	addi	s3,s3,744 # 80042580 <disk>
    800062a0:	00491713          	slli	a4,s2,0x4
    800062a4:	0009b783          	ld	a5,0(s3)
    800062a8:	97ba                	add	a5,a5,a4
    800062aa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062ae:	854a                	mv	a0,s2
    800062b0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062b4:	bafff0ef          	jal	80005e62 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062b8:	8885                	andi	s1,s1,1
    800062ba:	f0fd                	bnez	s1,800062a0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062bc:	0003c517          	auipc	a0,0x3c
    800062c0:	3ec50513          	addi	a0,a0,1004 # 800426a8 <disk+0x128>
    800062c4:	baffa0ef          	jal	80000e72 <release>
}
    800062c8:	70a6                	ld	ra,104(sp)
    800062ca:	7406                	ld	s0,96(sp)
    800062cc:	64e6                	ld	s1,88(sp)
    800062ce:	6946                	ld	s2,80(sp)
    800062d0:	69a6                	ld	s3,72(sp)
    800062d2:	6a06                	ld	s4,64(sp)
    800062d4:	7ae2                	ld	s5,56(sp)
    800062d6:	7b42                	ld	s6,48(sp)
    800062d8:	7ba2                	ld	s7,40(sp)
    800062da:	7c02                	ld	s8,32(sp)
    800062dc:	6ce2                	ld	s9,24(sp)
    800062de:	6165                	addi	sp,sp,112
    800062e0:	8082                	ret

00000000800062e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062e2:	1101                	addi	sp,sp,-32
    800062e4:	ec06                	sd	ra,24(sp)
    800062e6:	e822                	sd	s0,16(sp)
    800062e8:	e426                	sd	s1,8(sp)
    800062ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062ec:	0003c497          	auipc	s1,0x3c
    800062f0:	29448493          	addi	s1,s1,660 # 80042580 <disk>
    800062f4:	0003c517          	auipc	a0,0x3c
    800062f8:	3b450513          	addi	a0,a0,948 # 800426a8 <disk+0x128>
    800062fc:	adffa0ef          	jal	80000dda <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006300:	100017b7          	lui	a5,0x10001
    80006304:	53b8                	lw	a4,96(a5)
    80006306:	8b0d                	andi	a4,a4,3
    80006308:	100017b7          	lui	a5,0x10001
    8000630c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000630e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006312:	689c                	ld	a5,16(s1)
    80006314:	0204d703          	lhu	a4,32(s1)
    80006318:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000631c:	04f70663          	beq	a4,a5,80006368 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006320:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006324:	6898                	ld	a4,16(s1)
    80006326:	0204d783          	lhu	a5,32(s1)
    8000632a:	8b9d                	andi	a5,a5,7
    8000632c:	078e                	slli	a5,a5,0x3
    8000632e:	97ba                	add	a5,a5,a4
    80006330:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006332:	00278713          	addi	a4,a5,2
    80006336:	0712                	slli	a4,a4,0x4
    80006338:	9726                	add	a4,a4,s1
    8000633a:	01074703          	lbu	a4,16(a4)
    8000633e:	e321                	bnez	a4,8000637e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006340:	0789                	addi	a5,a5,2
    80006342:	0792                	slli	a5,a5,0x4
    80006344:	97a6                	add	a5,a5,s1
    80006346:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006348:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000634c:	a3efc0ef          	jal	8000258a <wakeup>

    disk.used_idx += 1;
    80006350:	0204d783          	lhu	a5,32(s1)
    80006354:	2785                	addiw	a5,a5,1
    80006356:	17c2                	slli	a5,a5,0x30
    80006358:	93c1                	srli	a5,a5,0x30
    8000635a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000635e:	6898                	ld	a4,16(s1)
    80006360:	00275703          	lhu	a4,2(a4)
    80006364:	faf71ee3          	bne	a4,a5,80006320 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006368:	0003c517          	auipc	a0,0x3c
    8000636c:	34050513          	addi	a0,a0,832 # 800426a8 <disk+0x128>
    80006370:	b03fa0ef          	jal	80000e72 <release>
}
    80006374:	60e2                	ld	ra,24(sp)
    80006376:	6442                	ld	s0,16(sp)
    80006378:	64a2                	ld	s1,8(sp)
    8000637a:	6105                	addi	sp,sp,32
    8000637c:	8082                	ret
      panic("virtio_disk_intr status");
    8000637e:	00002517          	auipc	a0,0x2
    80006382:	46250513          	addi	a0,a0,1122 # 800087e0 <etext+0x7e0>
    80006386:	c5afa0ef          	jal	800007e0 <panic>

000000008000638a <minheap_init>:
    }
  }
}

// Initialize a min-heap
void minheap_init(struct minheap *heap) {
    8000638a:	1141                	addi	sp,sp,-16
    8000638c:	e422                	sd	s0,8(sp)
    8000638e:	0800                	addi	s0,sp,16
  heap->size = 0;
    80006390:	20052023          	sw	zero,512(a0)
  heap->capacity = NPROC;
    80006394:	04000793          	li	a5,64
    80006398:	20f52223          	sw	a5,516(a0)
  for (int i = 0; i < NPROC; i++) {
    8000639c:	87aa                	mv	a5,a0
    8000639e:	20050713          	addi	a4,a0,512
    heap->procs[i] = 0;
    800063a2:	0007b023          	sd	zero,0(a5)
  for (int i = 0; i < NPROC; i++) {
    800063a6:	07a1                	addi	a5,a5,8
    800063a8:	fee79de3          	bne	a5,a4,800063a2 <minheap_init+0x18>
  }
}
    800063ac:	6422                	ld	s0,8(sp)
    800063ae:	0141                	addi	sp,sp,16
    800063b0:	8082                	ret

00000000800063b2 <minheap_insert>:

// Insert a process into the heap
int minheap_insert(struct minheap *heap, struct proc *p) {
    800063b2:	1141                	addi	sp,sp,-16
    800063b4:	e422                	sd	s0,8(sp)
    800063b6:	0800                	addi	s0,sp,16
  if (heap->size >= heap->capacity) {
    800063b8:	20052783          	lw	a5,512(a0)
    800063bc:	20452703          	lw	a4,516(a0)
    800063c0:	04e7da63          	bge	a5,a4,80006414 <minheap_insert+0x62>
    return -1;  // Heap is full
  }

  // Add the new process at the end
  heap->procs[heap->size] = p;
    800063c4:	00379713          	slli	a4,a5,0x3
    800063c8:	972a                	add	a4,a4,a0
    800063ca:	e30c                	sd	a1,0(a4)
  heap->size++;
    800063cc:	0017871b          	addiw	a4,a5,1
    800063d0:	20e52023          	sw	a4,512(a0)
  while (idx > 0) {
    800063d4:	04f05263          	blez	a5,80006418 <minheap_insert+0x66>
    800063d8:	4e09                	li	t3,2
  return (i - 1) / 2;
    800063da:	863e                	mv	a2,a5
    800063dc:	37fd                	addiw	a5,a5,-1
    800063de:	01f7d71b          	srliw	a4,a5,0x1f
    800063e2:	9fb9                	addw	a5,a5,a4
    800063e4:	4017d79b          	sraiw	a5,a5,0x1
    if (heap->procs[idx]->vruntime < heap->procs[p]->vruntime) {
    800063e8:	00361693          	slli	a3,a2,0x3
    800063ec:	96aa                	add	a3,a3,a0
    800063ee:	628c                	ld	a1,0(a3)
    800063f0:	00379713          	slli	a4,a5,0x3
    800063f4:	972a                	add	a4,a4,a0
    800063f6:	00073803          	ld	a6,0(a4)
    800063fa:	1705b303          	ld	t1,368(a1)
    800063fe:	17083883          	ld	a7,368(a6)
    80006402:	01137d63          	bgeu	t1,a7,8000641c <minheap_insert+0x6a>
  heap->procs[i] = heap->procs[j];
    80006406:	0106b023          	sd	a6,0(a3)
  heap->procs[j] = temp;
    8000640a:	e30c                	sd	a1,0(a4)
  while (idx > 0) {
    8000640c:	fcce47e3          	blt	t3,a2,800063da <minheap_insert+0x28>

  // Heapify up to maintain heap property
  heapify_up(heap, heap->size - 1);

  return 0;
    80006410:	4501                	li	a0,0
    80006412:	a031                	j	8000641e <minheap_insert+0x6c>
    return -1;  // Heap is full
    80006414:	557d                	li	a0,-1
    80006416:	a021                	j	8000641e <minheap_insert+0x6c>
  return 0;
    80006418:	4501                	li	a0,0
    8000641a:	a011                	j	8000641e <minheap_insert+0x6c>
    8000641c:	4501                	li	a0,0
}
    8000641e:	6422                	ld	s0,8(sp)
    80006420:	0141                	addi	sp,sp,16
    80006422:	8082                	ret

0000000080006424 <minheap_extract_min>:

// Extract the process with minimum vruntime
struct proc* minheap_extract_min(struct minheap *heap) {
    80006424:	1141                	addi	sp,sp,-16
    80006426:	e422                	sd	s0,8(sp)
    80006428:	0800                	addi	s0,sp,16
  if (heap->size == 0) {
    8000642a:	20052783          	lw	a5,512(a0)
    8000642e:	c7b1                	beqz	a5,8000647a <minheap_extract_min+0x56>
    80006430:	862a                	mv	a2,a0
    return 0;  // Heap is empty
  }

  struct proc *min_proc = heap->procs[0];
    80006432:	6108                	ld	a0,0(a0)

  // Move the last element to the root
  heap->procs[0] = heap->procs[heap->size - 1];
    80006434:	37fd                	addiw	a5,a5,-1
    80006436:	0007859b          	sext.w	a1,a5
    8000643a:	00359713          	slli	a4,a1,0x3
    8000643e:	9732                	add	a4,a4,a2
    80006440:	6318                	ld	a4,0(a4)
    80006442:	e218                	sd	a4,0(a2)
  heap->size--;
    80006444:	20f62023          	sw	a5,512(a2)

  // Heapify down from the root
  if (heap->size > 0) {
    80006448:	00b04563          	bgtz	a1,80006452 <minheap_extract_min+0x2e>
    heapify_down(heap, 0);
  }

  return min_proc;
}
    8000644c:	6422                	ld	s0,8(sp)
    8000644e:	0141                	addi	sp,sp,16
    80006450:	8082                	ret
    80006452:	4781                	li	a5,0
    80006454:	a0b5                	j	800064c0 <minheap_extract_min+0x9c>
        heap->procs[right]->vruntime < heap->procs[smallest]->vruntime) {
    80006456:	00369813          	slli	a6,a3,0x3
    8000645a:	9832                	add	a6,a6,a2
    8000645c:	00083883          	ld	a7,0(a6)
    80006460:	00371813          	slli	a6,a4,0x3
    80006464:	9832                	add	a6,a6,a2
    80006466:	00083803          	ld	a6,0(a6)
    if (right < heap->size && 
    8000646a:	1708b883          	ld	a7,368(a7)
    8000646e:	17083803          	ld	a6,368(a6)
    80006472:	0308e763          	bltu	a7,a6,800064a0 <minheap_extract_min+0x7c>
    80006476:	86ba                	mv	a3,a4
    80006478:	a025                	j	800064a0 <minheap_extract_min+0x7c>
    return 0;  // Heap is empty
    8000647a:	4501                	li	a0,0
    8000647c:	bfc1                	j	8000644c <minheap_extract_min+0x28>
    if (right < heap->size && 
    8000647e:	fcb6d7e3          	bge	a3,a1,8000644c <minheap_extract_min+0x28>
        heap->procs[right]->vruntime < heap->procs[smallest]->vruntime) {
    80006482:	00369713          	slli	a4,a3,0x3
    80006486:	9732                	add	a4,a4,a2
    80006488:	00073803          	ld	a6,0(a4)
    8000648c:	00379713          	slli	a4,a5,0x3
    80006490:	9732                	add	a4,a4,a2
    80006492:	6318                	ld	a4,0(a4)
    if (right < heap->size && 
    80006494:	17083803          	ld	a6,368(a6)
    80006498:	17073703          	ld	a4,368(a4)
    8000649c:	fae878e3          	bgeu	a6,a4,8000644c <minheap_extract_min+0x28>
    if (smallest != idx) {
    800064a0:	fad786e3          	beq	a5,a3,8000644c <minheap_extract_min+0x28>
  struct proc *temp = heap->procs[i];
    800064a4:	078e                	slli	a5,a5,0x3
    800064a6:	97b2                	add	a5,a5,a2
    800064a8:	0007b803          	ld	a6,0(a5)
  heap->procs[i] = heap->procs[j];
    800064ac:	00369713          	slli	a4,a3,0x3
    800064b0:	9732                	add	a4,a4,a2
    800064b2:	00073883          	ld	a7,0(a4)
    800064b6:	0117b023          	sd	a7,0(a5)
  heap->procs[j] = temp;
    800064ba:	01073023          	sd	a6,0(a4)
      idx = smallest;
    800064be:	87b6                	mv	a5,a3
  return 2 * i + 1;
    800064c0:	0017969b          	slliw	a3,a5,0x1
    800064c4:	0016871b          	addiw	a4,a3,1
  return 2 * i + 2;
    800064c8:	2689                	addiw	a3,a3,2
    if (left < heap->size && 
    800064ca:	fab75ae3          	bge	a4,a1,8000647e <minheap_extract_min+0x5a>
        heap->procs[left]->vruntime < heap->procs[smallest]->vruntime) {
    800064ce:	00371813          	slli	a6,a4,0x3
    800064d2:	9832                	add	a6,a6,a2
    800064d4:	00083883          	ld	a7,0(a6)
    800064d8:	00379813          	slli	a6,a5,0x3
    800064dc:	9832                	add	a6,a6,a2
    800064de:	00083803          	ld	a6,0(a6)
    if (left < heap->size && 
    800064e2:	1708b883          	ld	a7,368(a7)
    800064e6:	17083803          	ld	a6,368(a6)
    800064ea:	f908fae3          	bgeu	a7,a6,8000647e <minheap_extract_min+0x5a>
    if (right < heap->size && 
    800064ee:	f6b6c4e3          	blt	a3,a1,80006456 <minheap_extract_min+0x32>
    800064f2:	86ba                	mv	a3,a4
    800064f4:	b775                	j	800064a0 <minheap_extract_min+0x7c>
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
