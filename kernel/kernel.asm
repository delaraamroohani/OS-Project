
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
    80000112:	368020ef          	jal	8000247a <either_copyin>
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
    800001b8:	113010ef          	jal	80001aca <myproc>
    800001bc:	150020ef          	jal	8000230c <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	70f010ef          	jal	800020d4 <sleep>
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
    8000020a:	226020ef          	jal	80002430 <either_copyout>
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
    800002d8:	1ec020ef          	jal	800024c4 <procdump>
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
    8000041e:	503010ef          	jal	80002120 <wakeup>
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
    800008ea:	7ea010ef          	jal	800020d4 <sleep>
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
    80000a00:	720010ef          	jal	80002120 <wakeup>
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
    80000b78:	737000ef          	jal	80001aae <mycpu>
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
    80000ba6:	709000ef          	jal	80001aae <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	701000ef          	jal	80001aae <mycpu>
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
    80000bc2:	6ed000ef          	jal	80001aae <mycpu>
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
    80000bf6:	6b9000ef          	jal	80001aae <mycpu>
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
    80000c1a:	695000ef          	jal	80001aae <mycpu>
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
    80000e44:	45b000ef          	jal	80001a9e <cpuid>
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
    80000e5c:	443000ef          	jal	80001a9e <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	009010ef          	jal	8000267a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	033040ef          	jal	800056a8 <plicinithart>
  }

  scheduler();        
    80000e7a:	0c2010ef          	jal	80001f3c <scheduler>
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
    80000eb6:	333000ef          	jal	800019e8 <procinit>
    trapinit();      // trap vectors
    80000eba:	79c010ef          	jal	80002656 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	7bc010ef          	jal	8000267a <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	7cc040ef          	jal	8000568e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	7e2040ef          	jal	800056a8 <plicinithart>
    binit();         // buffer cache
    80000eca:	6a7010ef          	jal	80002d70 <binit>
    iinit();         // inode table
    80000ece:	42c020ef          	jal	800032fa <iinit>
    fileinit();      // file table
    80000ed2:	31e030ef          	jal	800041f0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	0c3040ef          	jal	80005798 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	6b7000ef          	jal	80001d90 <userinit>
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
    80001166:	7ea000ef          	jal	80001950 <proc_mapstacks>
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
    80001570:	55a000ef          	jal	80001aca <myproc>
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

0000000080001754 <ptree_walk>:
 * Returns 0 on success (or when buffer filled), -1 on copyout error.
 */
static int
ptree_walk(struct proc *node, int depth, pagetable_t pagetable, uint64 dst,
           int bufsize, int *writtenp)
{
    80001754:	710d                	addi	sp,sp,-352
    80001756:	ee86                	sd	ra,344(sp)
    80001758:	eaa2                	sd	s0,336(sp)
    8000175a:	e6a6                	sd	s1,328(sp)
    8000175c:	e2ca                	sd	s2,320(sp)
    8000175e:	fe4e                	sd	s3,312(sp)
    80001760:	fa52                	sd	s4,304(sp)
    80001762:	f656                	sd	s5,296(sp)
    80001764:	f25a                	sd	s6,288(sp)
    80001766:	ee5e                	sd	s7,280(sp)
    80001768:	ea62                	sd	s8,272(sp)
    8000176a:	1280                	addi	s0,sp,352
    8000176c:	892a                	mv	s2,a0
    8000176e:	8aae                	mv	s5,a1
    80001770:	8b32                	mv	s6,a2
    80001772:	8bb6                	mv	s7,a3
    80001774:	8a3a                	mv	s4,a4
    80001776:	89be                	mv	s3,a5
  int off = 0;
  int i;
  int node_pid;

  // Acquire lock to safely read node's pid
  acquire(&node->lock);
    80001778:	c56ff0ef          	jal	80000bce <acquire>
  node_pid = node->pid;
    8000177c:	03092483          	lw	s1,48(s2)
  release(&node->lock);
    80001780:	854a                	mv	a0,s2
    80001782:	ce4ff0ef          	jal	80000c66 <release>

  // indentation: 2 spaces per depth
  for (i = 0; i < depth; i++) {
    80001786:	0f505d63          	blez	s5,80001880 <ptree_walk+0x12c>
    8000178a:	eb040893          	addi	a7,s0,-336
    8000178e:	001a979b          	slliw	a5,s5,0x1
  int off = 0;
    80001792:	4801                	li	a6,0
    if (off + 2 >= (int)sizeof(line)) break;
    line[off++] = ' ';
    80001794:	02000313          	li	t1,32
    if (off + 2 >= (int)sizeof(line)) break;
    80001798:	0fe00713          	li	a4,254
    line[off++] = ' ';
    8000179c:	00688023          	sb	t1,0(a7)
    line[off++] = ' ';
    800017a0:	2809                	addiw	a6,a6,2
    800017a2:	006880a3          	sb	t1,1(a7)
  for (i = 0; i < depth; i++) {
    800017a6:	00f80663          	beq	a6,a5,800017b2 <ptree_walk+0x5e>
    if (off + 2 >= (int)sizeof(line)) break;
    800017aa:	0889                	addi	a7,a7,2
    800017ac:	fee818e3          	bne	a6,a4,8000179c <ptree_walk+0x48>
    800017b0:	87c2                	mv	a5,a6
  }

  // pid
  int pid_len = kitoa(node_pid, line + off);
    800017b2:	eb040713          	addi	a4,s0,-336
    800017b6:	00f708b3          	add	a7,a4,a5
  if (x == 0) {
    800017ba:	c4e9                	beqz	s1,80001884 <ptree_walk+0x130>
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017bc:	ea040613          	addi	a2,s0,-352
  int ti = 0;
    800017c0:	4701                	li	a4,0
    tmp[ti++] = '0' + (x % 10);
    800017c2:	4529                	li	a0,10
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017c4:	4325                	li	t1,9
    800017c6:	4e3d                	li	t3,15
    800017c8:	0c905363          	blez	s1,8000188e <ptree_walk+0x13a>
    tmp[ti++] = '0' + (x % 10);
    800017cc:	85ba                	mv	a1,a4
    800017ce:	0017081b          	addiw	a6,a4,1
    800017d2:	0008071b          	sext.w	a4,a6
    800017d6:	02a4e6bb          	remw	a3,s1,a0
    800017da:	0306869b          	addiw	a3,a3,48 # fffffffffffff030 <end+0xffffffff7ffde4b8>
    800017de:	00d60023          	sb	a3,0(a2) # 1000 <_entry-0x7ffff000>
    x /= 10;
    800017e2:	86a6                	mv	a3,s1
    800017e4:	02a4c4bb          	divw	s1,s1,a0
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017e8:	0cd35963          	bge	t1,a3,800018ba <ptree_walk+0x166>
    800017ec:	0605                	addi	a2,a2,1
    800017ee:	fdc71fe3          	bne	a4,t3,800017cc <ptree_walk+0x78>
    800017f2:	45b9                	li	a1,14
    800017f4:	ea040713          	addi	a4,s0,-352
    800017f8:	00b70633          	add	a2,a4,a1
    800017fc:	8746                	mv	a4,a7
    buf[i] = tmp[ti - 1 - i];
    800017fe:	00064683          	lbu	a3,0(a2)
    80001802:	00d70023          	sb	a3,0(a4)
  for (i = 0; i < ti; i++)
    80001806:	167d                	addi	a2,a2,-1
    80001808:	0705                	addi	a4,a4,1
    8000180a:	411706bb          	subw	a3,a4,a7
    8000180e:	36fd                	addiw	a3,a3,-1
    80001810:	feb6c7e3          	blt	a3,a1,800017fe <ptree_walk+0xaa>
  off += pid_len;
    80001814:	00f807bb          	addw	a5,a6,a5
  if (off > (int)sizeof(line)) off = (int)sizeof(line);
    80001818:	10000693          	li	a3,256
    8000181c:	10000713          	li	a4,256
    80001820:	06f6d863          	bge	a3,a5,80001890 <ptree_walk+0x13c>

  // Ensure off doesn't exceed buffer size
  if (off > (int)sizeof(line)) off = (int)sizeof(line);

  // Check remaining user buffer space
  int remaining = bufsize - *writtenp;
    80001824:	0009a583          	lw	a1,0(s3) # 1000 <_entry-0x7ffff000>
    80001828:	40ba0c3b          	subw	s8,s4,a1
    8000182c:	000c069b          	sext.w	a3,s8
  if (remaining <= 0) {
    // buffer exhausted
    return 0;
    80001830:	4501                	li	a0,0
  if (remaining <= 0) {
    80001832:	02d05b63          	blez	a3,80001868 <ptree_walk+0x114>
  if (off > (int)sizeof(line)) off = (int)sizeof(line);
    80001836:	84ba                	mv	s1,a4
    80001838:	10000793          	li	a5,256
    8000183c:	00e7d463          	bge	a5,a4,80001844 <ptree_walk+0xf0>
    80001840:	10000493          	li	s1,256
    80001844:	2481                	sext.w	s1,s1
  }

  if (off > remaining) {
    80001846:	0896d363          	bge	a3,s1,800018cc <ptree_walk+0x178>
    // copy only the portion that fits
    if (copyout(pagetable, dst + *writtenp, line, remaining) < 0)
    8000184a:	eb040613          	addi	a2,s0,-336
    8000184e:	95de                	add	a1,a1,s7
    80001850:	855a                	mv	a0,s6
    80001852:	d91ff0ef          	jal	800015e2 <copyout>
    80001856:	0e054563          	bltz	a0,80001940 <ptree_walk+0x1ec>
      return -1;
    *writtenp += remaining;
    8000185a:	0009a783          	lw	a5,0(s3)
    8000185e:	00fc0c3b          	addw	s8,s8,a5
    80001862:	0189a023          	sw	s8,0(s3)
    // buffer is full; stop traversal
    return 0;
    80001866:	4501                	li	a0,0
      release(&p->lock);
    }
  }

  return 0;
}
    80001868:	60f6                	ld	ra,344(sp)
    8000186a:	6456                	ld	s0,336(sp)
    8000186c:	64b6                	ld	s1,328(sp)
    8000186e:	6916                	ld	s2,320(sp)
    80001870:	79f2                	ld	s3,312(sp)
    80001872:	7a52                	ld	s4,304(sp)
    80001874:	7ab2                	ld	s5,296(sp)
    80001876:	7b12                	ld	s6,288(sp)
    80001878:	6bf2                	ld	s7,280(sp)
    8000187a:	6c52                	ld	s8,272(sp)
    8000187c:	6135                	addi	sp,sp,352
    8000187e:	8082                	ret
  int off = 0;
    80001880:	4781                	li	a5,0
    80001882:	bf05                	j	800017b2 <ptree_walk+0x5e>
    buf[0] = '0';
    80001884:	03000713          	li	a4,48
    80001888:	00e88023          	sb	a4,0(a7)
    return 1;
    8000188c:	4705                	li	a4,1
  off += pid_len;
    8000188e:	9fb9                	addw	a5,a5,a4
  if (off < (int)sizeof(line) - 1)
    80001890:	0fe00713          	li	a4,254
    80001894:	02f74663          	blt	a4,a5,800018c0 <ptree_walk+0x16c>
    line[off++] = ' ';
    80001898:	fb078713          	addi	a4,a5,-80 # ffffffffffffefb0 <end+0xffffffff7ffde438>
    8000189c:	9722                	add	a4,a4,s0
    8000189e:	02000693          	li	a3,32
    800018a2:	f0d70023          	sb	a3,-256(a4)
    800018a6:	2785                	addiw	a5,a5,1
    line[off++] = '\n';
    800018a8:	0017871b          	addiw	a4,a5,1
    800018ac:	fb078793          	addi	a5,a5,-80
    800018b0:	97a2                	add	a5,a5,s0
    800018b2:	46a9                	li	a3,10
    800018b4:	f0d78023          	sb	a3,-256(a5)
    800018b8:	b7b5                	j	80001824 <ptree_walk+0xd0>
  for (i = 0; i < ti; i++)
    800018ba:	f2e04de3          	bgtz	a4,800017f4 <ptree_walk+0xa0>
    800018be:	bfc1                	j	8000188e <ptree_walk+0x13a>
  if (off < (int)sizeof(line))
    800018c0:	0ff00713          	li	a4,255
    800018c4:	fef752e3          	bge	a4,a5,800018a8 <ptree_walk+0x154>
    800018c8:	873e                	mv	a4,a5
    800018ca:	bfa9                	j	80001824 <ptree_walk+0xd0>
    if (copyout(pagetable, dst + *writtenp, line, off) < 0)
    800018cc:	86a6                	mv	a3,s1
    800018ce:	eb040613          	addi	a2,s0,-336
    800018d2:	95de                	add	a1,a1,s7
    800018d4:	855a                	mv	a0,s6
    800018d6:	d0dff0ef          	jal	800015e2 <copyout>
    800018da:	06054563          	bltz	a0,80001944 <ptree_walk+0x1f0>
    *writtenp += off;
    800018de:	0009a783          	lw	a5,0(s3)
    800018e2:	9fa5                	addw	a5,a5,s1
    800018e4:	00f9a023          	sw	a5,0(s3)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018e8:	0000e497          	auipc	s1,0xe
    800018ec:	4b048493          	addi	s1,s1,1200 # 8000fd98 <proc>
      if (ptree_walk(p, depth + 1, pagetable, dst, bufsize, writtenp) < 0)
    800018f0:	001a8c1b          	addiw	s8,s5,1 # fffffffffffff001 <end+0xffffffff7ffde489>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018f4:	00014a97          	auipc	s5,0x14
    800018f8:	ea4a8a93          	addi	s5,s5,-348 # 80015798 <tickslock>
    800018fc:	a035                	j	80001928 <ptree_walk+0x1d4>
      release(&p->lock);
    800018fe:	8526                	mv	a0,s1
    80001900:	b66ff0ef          	jal	80000c66 <release>
      if (ptree_walk(p, depth + 1, pagetable, dst, bufsize, writtenp) < 0)
    80001904:	87ce                	mv	a5,s3
    80001906:	8752                	mv	a4,s4
    80001908:	86de                	mv	a3,s7
    8000190a:	865a                	mv	a2,s6
    8000190c:	85e2                	mv	a1,s8
    8000190e:	8526                	mv	a0,s1
    80001910:	e45ff0ef          	jal	80001754 <ptree_walk>
    80001914:	02054a63          	bltz	a0,80001948 <ptree_walk+0x1f4>
      if (*writtenp >= bufsize) // buffer full, stop early
    80001918:	0009a783          	lw	a5,0(s3)
    8000191c:	0347d863          	bge	a5,s4,8000194c <ptree_walk+0x1f8>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001920:	16848493          	addi	s1,s1,360
    80001924:	01548c63          	beq	s1,s5,8000193c <ptree_walk+0x1e8>
    acquire(&p->lock);
    80001928:	8526                	mv	a0,s1
    8000192a:	aa4ff0ef          	jal	80000bce <acquire>
    if (p->parent == node) {
    8000192e:	7c9c                	ld	a5,56(s1)
    80001930:	fd2787e3          	beq	a5,s2,800018fe <ptree_walk+0x1aa>
      release(&p->lock);
    80001934:	8526                	mv	a0,s1
    80001936:	b30ff0ef          	jal	80000c66 <release>
    8000193a:	b7dd                	j	80001920 <ptree_walk+0x1cc>
  return 0;
    8000193c:	4501                	li	a0,0
    8000193e:	b72d                	j	80001868 <ptree_walk+0x114>
      return -1;
    80001940:	557d                	li	a0,-1
    80001942:	b71d                	j	80001868 <ptree_walk+0x114>
      return -1;
    80001944:	557d                	li	a0,-1
    80001946:	b70d                	j	80001868 <ptree_walk+0x114>
        return -1;
    80001948:	557d                	li	a0,-1
    8000194a:	bf39                	j	80001868 <ptree_walk+0x114>
        return 0;
    8000194c:	4501                	li	a0,0
    8000194e:	bf29                	j	80001868 <ptree_walk+0x114>

0000000080001950 <proc_mapstacks>:
{
    80001950:	7139                	addi	sp,sp,-64
    80001952:	fc06                	sd	ra,56(sp)
    80001954:	f822                	sd	s0,48(sp)
    80001956:	f426                	sd	s1,40(sp)
    80001958:	f04a                	sd	s2,32(sp)
    8000195a:	ec4e                	sd	s3,24(sp)
    8000195c:	e852                	sd	s4,16(sp)
    8000195e:	e456                	sd	s5,8(sp)
    80001960:	e05a                	sd	s6,0(sp)
    80001962:	0080                	addi	s0,sp,64
    80001964:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001966:	0000e497          	auipc	s1,0xe
    8000196a:	43248493          	addi	s1,s1,1074 # 8000fd98 <proc>
    uint64 va = KSTACK((int) (p - proc));
    8000196e:	8b26                	mv	s6,s1
    80001970:	04fa5937          	lui	s2,0x4fa5
    80001974:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001978:	0932                	slli	s2,s2,0xc
    8000197a:	fa590913          	addi	s2,s2,-91
    8000197e:	0932                	slli	s2,s2,0xc
    80001980:	fa590913          	addi	s2,s2,-91
    80001984:	0932                	slli	s2,s2,0xc
    80001986:	fa590913          	addi	s2,s2,-91
    8000198a:	040009b7          	lui	s3,0x4000
    8000198e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001990:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001992:	00014a97          	auipc	s5,0x14
    80001996:	e06a8a93          	addi	s5,s5,-506 # 80015798 <tickslock>
    char *pa = kalloc();
    8000199a:	964ff0ef          	jal	80000afe <kalloc>
    8000199e:	862a                	mv	a2,a0
    if(pa == 0)
    800019a0:	cd15                	beqz	a0,800019dc <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800019a2:	416485b3          	sub	a1,s1,s6
    800019a6:	858d                	srai	a1,a1,0x3
    800019a8:	032585b3          	mul	a1,a1,s2
    800019ac:	2585                	addiw	a1,a1,1
    800019ae:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b2:	4719                	li	a4,6
    800019b4:	6685                	lui	a3,0x1
    800019b6:	40b985b3          	sub	a1,s3,a1
    800019ba:	8552                	mv	a0,s4
    800019bc:	ee2ff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c0:	16848493          	addi	s1,s1,360
    800019c4:	fd549be3          	bne	s1,s5,8000199a <proc_mapstacks+0x4a>
}
    800019c8:	70e2                	ld	ra,56(sp)
    800019ca:	7442                	ld	s0,48(sp)
    800019cc:	74a2                	ld	s1,40(sp)
    800019ce:	7902                	ld	s2,32(sp)
    800019d0:	69e2                	ld	s3,24(sp)
    800019d2:	6a42                	ld	s4,16(sp)
    800019d4:	6aa2                	ld	s5,8(sp)
    800019d6:	6b02                	ld	s6,0(sp)
    800019d8:	6121                	addi	sp,sp,64
    800019da:	8082                	ret
      panic("kalloc");
    800019dc:	00005517          	auipc	a0,0x5
    800019e0:	77c50513          	addi	a0,a0,1916 # 80007158 <etext+0x158>
    800019e4:	dfdfe0ef          	jal	800007e0 <panic>

00000000800019e8 <procinit>:
{
    800019e8:	7139                	addi	sp,sp,-64
    800019ea:	fc06                	sd	ra,56(sp)
    800019ec:	f822                	sd	s0,48(sp)
    800019ee:	f426                	sd	s1,40(sp)
    800019f0:	f04a                	sd	s2,32(sp)
    800019f2:	ec4e                	sd	s3,24(sp)
    800019f4:	e852                	sd	s4,16(sp)
    800019f6:	e456                	sd	s5,8(sp)
    800019f8:	e05a                	sd	s6,0(sp)
    800019fa:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800019fc:	00005597          	auipc	a1,0x5
    80001a00:	76458593          	addi	a1,a1,1892 # 80007160 <etext+0x160>
    80001a04:	0000e517          	auipc	a0,0xe
    80001a08:	f6450513          	addi	a0,a0,-156 # 8000f968 <pid_lock>
    80001a0c:	942ff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a10:	00005597          	auipc	a1,0x5
    80001a14:	75858593          	addi	a1,a1,1880 # 80007168 <etext+0x168>
    80001a18:	0000e517          	auipc	a0,0xe
    80001a1c:	f6850513          	addi	a0,a0,-152 # 8000f980 <wait_lock>
    80001a20:	92eff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a24:	0000e497          	auipc	s1,0xe
    80001a28:	37448493          	addi	s1,s1,884 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    80001a2c:	00005b17          	auipc	s6,0x5
    80001a30:	74cb0b13          	addi	s6,s6,1868 # 80007178 <etext+0x178>
      p->kstack = KSTACK((int) (p - proc));
    80001a34:	8aa6                	mv	s5,s1
    80001a36:	04fa5937          	lui	s2,0x4fa5
    80001a3a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a3e:	0932                	slli	s2,s2,0xc
    80001a40:	fa590913          	addi	s2,s2,-91
    80001a44:	0932                	slli	s2,s2,0xc
    80001a46:	fa590913          	addi	s2,s2,-91
    80001a4a:	0932                	slli	s2,s2,0xc
    80001a4c:	fa590913          	addi	s2,s2,-91
    80001a50:	040009b7          	lui	s3,0x4000
    80001a54:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a56:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a58:	00014a17          	auipc	s4,0x14
    80001a5c:	d40a0a13          	addi	s4,s4,-704 # 80015798 <tickslock>
      initlock(&p->lock, "proc");
    80001a60:	85da                	mv	a1,s6
    80001a62:	8526                	mv	a0,s1
    80001a64:	8eaff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001a68:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a6c:	415487b3          	sub	a5,s1,s5
    80001a70:	878d                	srai	a5,a5,0x3
    80001a72:	032787b3          	mul	a5,a5,s2
    80001a76:	2785                	addiw	a5,a5,1
    80001a78:	00d7979b          	slliw	a5,a5,0xd
    80001a7c:	40f987b3          	sub	a5,s3,a5
    80001a80:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a82:	16848493          	addi	s1,s1,360
    80001a86:	fd449de3          	bne	s1,s4,80001a60 <procinit+0x78>
}
    80001a8a:	70e2                	ld	ra,56(sp)
    80001a8c:	7442                	ld	s0,48(sp)
    80001a8e:	74a2                	ld	s1,40(sp)
    80001a90:	7902                	ld	s2,32(sp)
    80001a92:	69e2                	ld	s3,24(sp)
    80001a94:	6a42                	ld	s4,16(sp)
    80001a96:	6aa2                	ld	s5,8(sp)
    80001a98:	6b02                	ld	s6,0(sp)
    80001a9a:	6121                	addi	sp,sp,64
    80001a9c:	8082                	ret

0000000080001a9e <cpuid>:
{
    80001a9e:	1141                	addi	sp,sp,-16
    80001aa0:	e422                	sd	s0,8(sp)
    80001aa2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aa4:	8512                	mv	a0,tp
}
    80001aa6:	2501                	sext.w	a0,a0
    80001aa8:	6422                	ld	s0,8(sp)
    80001aaa:	0141                	addi	sp,sp,16
    80001aac:	8082                	ret

0000000080001aae <mycpu>:
{
    80001aae:	1141                	addi	sp,sp,-16
    80001ab0:	e422                	sd	s0,8(sp)
    80001ab2:	0800                	addi	s0,sp,16
    80001ab4:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001ab6:	2781                	sext.w	a5,a5
    80001ab8:	079e                	slli	a5,a5,0x7
}
    80001aba:	0000e517          	auipc	a0,0xe
    80001abe:	ede50513          	addi	a0,a0,-290 # 8000f998 <cpus>
    80001ac2:	953e                	add	a0,a0,a5
    80001ac4:	6422                	ld	s0,8(sp)
    80001ac6:	0141                	addi	sp,sp,16
    80001ac8:	8082                	ret

0000000080001aca <myproc>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	1000                	addi	s0,sp,32
  push_off();
    80001ad4:	8baff0ef          	jal	80000b8e <push_off>
    80001ad8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ada:	2781                	sext.w	a5,a5
    80001adc:	079e                	slli	a5,a5,0x7
    80001ade:	0000e717          	auipc	a4,0xe
    80001ae2:	e8a70713          	addi	a4,a4,-374 # 8000f968 <pid_lock>
    80001ae6:	97ba                	add	a5,a5,a4
    80001ae8:	7b84                	ld	s1,48(a5)
  pop_off();
    80001aea:	928ff0ef          	jal	80000c12 <pop_off>
}
    80001aee:	8526                	mv	a0,s1
    80001af0:	60e2                	ld	ra,24(sp)
    80001af2:	6442                	ld	s0,16(sp)
    80001af4:	64a2                	ld	s1,8(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret

0000000080001afa <forkret>:
{
    80001afa:	7179                	addi	sp,sp,-48
    80001afc:	f406                	sd	ra,40(sp)
    80001afe:	f022                	sd	s0,32(sp)
    80001b00:	ec26                	sd	s1,24(sp)
    80001b02:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001b04:	fc7ff0ef          	jal	80001aca <myproc>
    80001b08:	84aa                	mv	s1,a0
  release(&p->lock);
    80001b0a:	95cff0ef          	jal	80000c66 <release>
  if (first) {
    80001b0e:	00006797          	auipc	a5,0x6
    80001b12:	d227a783          	lw	a5,-734(a5) # 80007830 <first.1>
    80001b16:	cf8d                	beqz	a5,80001b50 <forkret+0x56>
    fsinit(ROOTDEV);
    80001b18:	4505                	li	a0,1
    80001b1a:	49d010ef          	jal	800037b6 <fsinit>
    first = 0;
    80001b1e:	00006797          	auipc	a5,0x6
    80001b22:	d007a923          	sw	zero,-750(a5) # 80007830 <first.1>
    __sync_synchronize();
    80001b26:	0ff0000f          	fence
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b2a:	00005517          	auipc	a0,0x5
    80001b2e:	65650513          	addi	a0,a0,1622 # 80007180 <etext+0x180>
    80001b32:	fca43823          	sd	a0,-48(s0)
    80001b36:	fc043c23          	sd	zero,-40(s0)
    80001b3a:	fd040593          	addi	a1,s0,-48
    80001b3e:	583020ef          	jal	800048c0 <kexec>
    80001b42:	6cbc                	ld	a5,88(s1)
    80001b44:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b46:	6cbc                	ld	a5,88(s1)
    80001b48:	7bb8                	ld	a4,112(a5)
    80001b4a:	57fd                	li	a5,-1
    80001b4c:	02f70d63          	beq	a4,a5,80001b86 <forkret+0x8c>
  prepare_return();
    80001b50:	343000ef          	jal	80002692 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b54:	68a8                	ld	a0,80(s1)
    80001b56:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b58:	04000737          	lui	a4,0x4000
    80001b5c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b5e:	0732                	slli	a4,a4,0xc
    80001b60:	00004797          	auipc	a5,0x4
    80001b64:	53c78793          	addi	a5,a5,1340 # 8000609c <userret>
    80001b68:	00004697          	auipc	a3,0x4
    80001b6c:	49868693          	addi	a3,a3,1176 # 80006000 <_trampoline>
    80001b70:	8f95                	sub	a5,a5,a3
    80001b72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b74:	577d                	li	a4,-1
    80001b76:	177e                	slli	a4,a4,0x3f
    80001b78:	8d59                	or	a0,a0,a4
    80001b7a:	9782                	jalr	a5
}
    80001b7c:	70a2                	ld	ra,40(sp)
    80001b7e:	7402                	ld	s0,32(sp)
    80001b80:	64e2                	ld	s1,24(sp)
    80001b82:	6145                	addi	sp,sp,48
    80001b84:	8082                	ret
      panic("exec");
    80001b86:	00005517          	auipc	a0,0x5
    80001b8a:	60250513          	addi	a0,a0,1538 # 80007188 <etext+0x188>
    80001b8e:	c53fe0ef          	jal	800007e0 <panic>

0000000080001b92 <allocpid>:
{
    80001b92:	1101                	addi	sp,sp,-32
    80001b94:	ec06                	sd	ra,24(sp)
    80001b96:	e822                	sd	s0,16(sp)
    80001b98:	e426                	sd	s1,8(sp)
    80001b9a:	e04a                	sd	s2,0(sp)
    80001b9c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b9e:	0000e917          	auipc	s2,0xe
    80001ba2:	dca90913          	addi	s2,s2,-566 # 8000f968 <pid_lock>
    80001ba6:	854a                	mv	a0,s2
    80001ba8:	826ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001bac:	00006797          	auipc	a5,0x6
    80001bb0:	c8878793          	addi	a5,a5,-888 # 80007834 <nextpid>
    80001bb4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bb6:	0014871b          	addiw	a4,s1,1
    80001bba:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bbc:	854a                	mv	a0,s2
    80001bbe:	8a8ff0ef          	jal	80000c66 <release>
}
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	60e2                	ld	ra,24(sp)
    80001bc6:	6442                	ld	s0,16(sp)
    80001bc8:	64a2                	ld	s1,8(sp)
    80001bca:	6902                	ld	s2,0(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <proc_pagetable>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bde:	db6ff0ef          	jal	80001194 <uvmcreate>
    80001be2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001be4:	cd05                	beqz	a0,80001c1c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001be6:	4729                	li	a4,10
    80001be8:	00004697          	auipc	a3,0x4
    80001bec:	41868693          	addi	a3,a3,1048 # 80006000 <_trampoline>
    80001bf0:	6605                	lui	a2,0x1
    80001bf2:	040005b7          	lui	a1,0x4000
    80001bf6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bf8:	05b2                	slli	a1,a1,0xc
    80001bfa:	bf4ff0ef          	jal	80000fee <mappages>
    80001bfe:	02054663          	bltz	a0,80001c2a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c02:	4719                	li	a4,6
    80001c04:	05893683          	ld	a3,88(s2)
    80001c08:	6605                	lui	a2,0x1
    80001c0a:	020005b7          	lui	a1,0x2000
    80001c0e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c10:	05b6                	slli	a1,a1,0xd
    80001c12:	8526                	mv	a0,s1
    80001c14:	bdaff0ef          	jal	80000fee <mappages>
    80001c18:	00054f63          	bltz	a0,80001c36 <proc_pagetable+0x66>
}
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	60e2                	ld	ra,24(sp)
    80001c20:	6442                	ld	s0,16(sp)
    80001c22:	64a2                	ld	s1,8(sp)
    80001c24:	6902                	ld	s2,0(sp)
    80001c26:	6105                	addi	sp,sp,32
    80001c28:	8082                	ret
    uvmfree(pagetable, 0);
    80001c2a:	4581                	li	a1,0
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	f60ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001c32:	4481                	li	s1,0
    80001c34:	b7e5                	j	80001c1c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c36:	4681                	li	a3,0
    80001c38:	4605                	li	a2,1
    80001c3a:	040005b7          	lui	a1,0x4000
    80001c3e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c40:	05b2                	slli	a1,a1,0xc
    80001c42:	8526                	mv	a0,s1
    80001c44:	d76ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001c48:	4581                	li	a1,0
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	f42ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001c50:	4481                	li	s1,0
    80001c52:	b7e9                	j	80001c1c <proc_pagetable+0x4c>

0000000080001c54 <proc_freepagetable>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
    80001c60:	84aa                	mv	s1,a0
    80001c62:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c64:	4681                	li	a3,0
    80001c66:	4605                	li	a2,1
    80001c68:	040005b7          	lui	a1,0x4000
    80001c6c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c6e:	05b2                	slli	a1,a1,0xc
    80001c70:	d4aff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c74:	4681                	li	a3,0
    80001c76:	4605                	li	a2,1
    80001c78:	020005b7          	lui	a1,0x2000
    80001c7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c7e:	05b6                	slli	a1,a1,0xd
    80001c80:	8526                	mv	a0,s1
    80001c82:	d38ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001c86:	85ca                	mv	a1,s2
    80001c88:	8526                	mv	a0,s1
    80001c8a:	f04ff0ef          	jal	8000138e <uvmfree>
}
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6902                	ld	s2,0(sp)
    80001c96:	6105                	addi	sp,sp,32
    80001c98:	8082                	ret

0000000080001c9a <freeproc>:
{
    80001c9a:	1101                	addi	sp,sp,-32
    80001c9c:	ec06                	sd	ra,24(sp)
    80001c9e:	e822                	sd	s0,16(sp)
    80001ca0:	e426                	sd	s1,8(sp)
    80001ca2:	1000                	addi	s0,sp,32
    80001ca4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ca6:	6d28                	ld	a0,88(a0)
    80001ca8:	c119                	beqz	a0,80001cae <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001caa:	d73fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001cae:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cb2:	68a8                	ld	a0,80(s1)
    80001cb4:	c501                	beqz	a0,80001cbc <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001cb6:	64ac                	ld	a1,72(s1)
    80001cb8:	f9dff0ef          	jal	80001c54 <proc_freepagetable>
  p->pagetable = 0;
    80001cbc:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cc0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cc4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cc8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ccc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cd0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cd4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cd8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cdc:	0004ac23          	sw	zero,24(s1)
}
    80001ce0:	60e2                	ld	ra,24(sp)
    80001ce2:	6442                	ld	s0,16(sp)
    80001ce4:	64a2                	ld	s1,8(sp)
    80001ce6:	6105                	addi	sp,sp,32
    80001ce8:	8082                	ret

0000000080001cea <allocproc>:
{
    80001cea:	1101                	addi	sp,sp,-32
    80001cec:	ec06                	sd	ra,24(sp)
    80001cee:	e822                	sd	s0,16(sp)
    80001cf0:	e426                	sd	s1,8(sp)
    80001cf2:	e04a                	sd	s2,0(sp)
    80001cf4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cf6:	0000e497          	auipc	s1,0xe
    80001cfa:	0a248493          	addi	s1,s1,162 # 8000fd98 <proc>
    80001cfe:	00014917          	auipc	s2,0x14
    80001d02:	a9a90913          	addi	s2,s2,-1382 # 80015798 <tickslock>
    acquire(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	ec7fe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001d0c:	4c9c                	lw	a5,24(s1)
    80001d0e:	cb91                	beqz	a5,80001d22 <allocproc+0x38>
      release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	f55fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d16:	16848493          	addi	s1,s1,360
    80001d1a:	ff2496e3          	bne	s1,s2,80001d06 <allocproc+0x1c>
  return 0;
    80001d1e:	4481                	li	s1,0
    80001d20:	a089                	j	80001d62 <allocproc+0x78>
  p->pid = allocpid();
    80001d22:	e71ff0ef          	jal	80001b92 <allocpid>
    80001d26:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d28:	4785                	li	a5,1
    80001d2a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d2c:	dd3fe0ef          	jal	80000afe <kalloc>
    80001d30:	892a                	mv	s2,a0
    80001d32:	eca8                	sd	a0,88(s1)
    80001d34:	cd15                	beqz	a0,80001d70 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001d36:	8526                	mv	a0,s1
    80001d38:	e99ff0ef          	jal	80001bd0 <proc_pagetable>
    80001d3c:	892a                	mv	s2,a0
    80001d3e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d40:	c121                	beqz	a0,80001d80 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001d42:	07000613          	li	a2,112
    80001d46:	4581                	li	a1,0
    80001d48:	06048513          	addi	a0,s1,96
    80001d4c:	f57fe0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001d50:	00000797          	auipc	a5,0x0
    80001d54:	daa78793          	addi	a5,a5,-598 # 80001afa <forkret>
    80001d58:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d5a:	60bc                	ld	a5,64(s1)
    80001d5c:	6705                	lui	a4,0x1
    80001d5e:	97ba                	add	a5,a5,a4
    80001d60:	f4bc                	sd	a5,104(s1)
}
    80001d62:	8526                	mv	a0,s1
    80001d64:	60e2                	ld	ra,24(sp)
    80001d66:	6442                	ld	s0,16(sp)
    80001d68:	64a2                	ld	s1,8(sp)
    80001d6a:	6902                	ld	s2,0(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret
    freeproc(p);
    80001d70:	8526                	mv	a0,s1
    80001d72:	f29ff0ef          	jal	80001c9a <freeproc>
    release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	eeffe0ef          	jal	80000c66 <release>
    return 0;
    80001d7c:	84ca                	mv	s1,s2
    80001d7e:	b7d5                	j	80001d62 <allocproc+0x78>
    freeproc(p);
    80001d80:	8526                	mv	a0,s1
    80001d82:	f19ff0ef          	jal	80001c9a <freeproc>
    release(&p->lock);
    80001d86:	8526                	mv	a0,s1
    80001d88:	edffe0ef          	jal	80000c66 <release>
    return 0;
    80001d8c:	84ca                	mv	s1,s2
    80001d8e:	bfd1                	j	80001d62 <allocproc+0x78>

0000000080001d90 <userinit>:
{
    80001d90:	1101                	addi	sp,sp,-32
    80001d92:	ec06                	sd	ra,24(sp)
    80001d94:	e822                	sd	s0,16(sp)
    80001d96:	e426                	sd	s1,8(sp)
    80001d98:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d9a:	f51ff0ef          	jal	80001cea <allocproc>
    80001d9e:	84aa                	mv	s1,a0
  initproc = p;
    80001da0:	00006797          	auipc	a5,0x6
    80001da4:	aca7b023          	sd	a0,-1344(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001da8:	00005517          	auipc	a0,0x5
    80001dac:	3e850513          	addi	a0,a0,1000 # 80007190 <etext+0x190>
    80001db0:	729010ef          	jal	80003cd8 <namei>
    80001db4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001db8:	478d                	li	a5,3
    80001dba:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	ea9fe0ef          	jal	80000c66 <release>
}
    80001dc2:	60e2                	ld	ra,24(sp)
    80001dc4:	6442                	ld	s0,16(sp)
    80001dc6:	64a2                	ld	s1,8(sp)
    80001dc8:	6105                	addi	sp,sp,32
    80001dca:	8082                	ret

0000000080001dcc <growproc>:
{
    80001dcc:	1101                	addi	sp,sp,-32
    80001dce:	ec06                	sd	ra,24(sp)
    80001dd0:	e822                	sd	s0,16(sp)
    80001dd2:	e426                	sd	s1,8(sp)
    80001dd4:	e04a                	sd	s2,0(sp)
    80001dd6:	1000                	addi	s0,sp,32
    80001dd8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dda:	cf1ff0ef          	jal	80001aca <myproc>
    80001dde:	892a                	mv	s2,a0
  sz = p->sz;
    80001de0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001de2:	02905963          	blez	s1,80001e14 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001de6:	00b48633          	add	a2,s1,a1
    80001dea:	020007b7          	lui	a5,0x2000
    80001dee:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001df0:	07b6                	slli	a5,a5,0xd
    80001df2:	02c7ea63          	bltu	a5,a2,80001e26 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001df6:	4691                	li	a3,4
    80001df8:	6928                	ld	a0,80(a0)
    80001dfa:	c8eff0ef          	jal	80001288 <uvmalloc>
    80001dfe:	85aa                	mv	a1,a0
    80001e00:	c50d                	beqz	a0,80001e2a <growproc+0x5e>
  p->sz = sz;
    80001e02:	04b93423          	sd	a1,72(s2)
  return 0;
    80001e06:	4501                	li	a0,0
}
    80001e08:	60e2                	ld	ra,24(sp)
    80001e0a:	6442                	ld	s0,16(sp)
    80001e0c:	64a2                	ld	s1,8(sp)
    80001e0e:	6902                	ld	s2,0(sp)
    80001e10:	6105                	addi	sp,sp,32
    80001e12:	8082                	ret
  } else if(n < 0){
    80001e14:	fe04d7e3          	bgez	s1,80001e02 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e18:	00b48633          	add	a2,s1,a1
    80001e1c:	6928                	ld	a0,80(a0)
    80001e1e:	c26ff0ef          	jal	80001244 <uvmdealloc>
    80001e22:	85aa                	mv	a1,a0
    80001e24:	bff9                	j	80001e02 <growproc+0x36>
      return -1;
    80001e26:	557d                	li	a0,-1
    80001e28:	b7c5                	j	80001e08 <growproc+0x3c>
      return -1;
    80001e2a:	557d                	li	a0,-1
    80001e2c:	bff1                	j	80001e08 <growproc+0x3c>

0000000080001e2e <kfork>:
{
    80001e2e:	7139                	addi	sp,sp,-64
    80001e30:	fc06                	sd	ra,56(sp)
    80001e32:	f822                	sd	s0,48(sp)
    80001e34:	f04a                	sd	s2,32(sp)
    80001e36:	e456                	sd	s5,8(sp)
    80001e38:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e3a:	c91ff0ef          	jal	80001aca <myproc>
    80001e3e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e40:	eabff0ef          	jal	80001cea <allocproc>
    80001e44:	0e050a63          	beqz	a0,80001f38 <kfork+0x10a>
    80001e48:	e852                	sd	s4,16(sp)
    80001e4a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e4c:	048ab603          	ld	a2,72(s5)
    80001e50:	692c                	ld	a1,80(a0)
    80001e52:	050ab503          	ld	a0,80(s5)
    80001e56:	d6aff0ef          	jal	800013c0 <uvmcopy>
    80001e5a:	04054a63          	bltz	a0,80001eae <kfork+0x80>
    80001e5e:	f426                	sd	s1,40(sp)
    80001e60:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e62:	048ab783          	ld	a5,72(s5)
    80001e66:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e6a:	058ab683          	ld	a3,88(s5)
    80001e6e:	87b6                	mv	a5,a3
    80001e70:	058a3703          	ld	a4,88(s4)
    80001e74:	12068693          	addi	a3,a3,288
    80001e78:	0007b803          	ld	a6,0(a5)
    80001e7c:	6788                	ld	a0,8(a5)
    80001e7e:	6b8c                	ld	a1,16(a5)
    80001e80:	6f90                	ld	a2,24(a5)
    80001e82:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001e86:	e708                	sd	a0,8(a4)
    80001e88:	eb0c                	sd	a1,16(a4)
    80001e8a:	ef10                	sd	a2,24(a4)
    80001e8c:	02078793          	addi	a5,a5,32
    80001e90:	02070713          	addi	a4,a4,32
    80001e94:	fed792e3          	bne	a5,a3,80001e78 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e98:	058a3783          	ld	a5,88(s4)
    80001e9c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea0:	0d0a8493          	addi	s1,s5,208
    80001ea4:	0d0a0913          	addi	s2,s4,208
    80001ea8:	150a8993          	addi	s3,s5,336
    80001eac:	a831                	j	80001ec8 <kfork+0x9a>
    freeproc(np);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	debff0ef          	jal	80001c9a <freeproc>
    release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	db1fe0ef          	jal	80000c66 <release>
    return -1;
    80001eba:	597d                	li	s2,-1
    80001ebc:	6a42                	ld	s4,16(sp)
    80001ebe:	a0b5                	j	80001f2a <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ec0:	04a1                	addi	s1,s1,8
    80001ec2:	0921                	addi	s2,s2,8
    80001ec4:	01348963          	beq	s1,s3,80001ed6 <kfork+0xa8>
    if(p->ofile[i])
    80001ec8:	6088                	ld	a0,0(s1)
    80001eca:	d97d                	beqz	a0,80001ec0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ecc:	3a6020ef          	jal	80004272 <filedup>
    80001ed0:	00a93023          	sd	a0,0(s2)
    80001ed4:	b7f5                	j	80001ec0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001ed6:	150ab503          	ld	a0,336(s5)
    80001eda:	5b2010ef          	jal	8000348c <idup>
    80001ede:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee2:	4641                	li	a2,16
    80001ee4:	158a8593          	addi	a1,s5,344
    80001ee8:	158a0513          	addi	a0,s4,344
    80001eec:	ef5fe0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001ef0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ef4:	8552                	mv	a0,s4
    80001ef6:	d71fe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001efa:	0000e497          	auipc	s1,0xe
    80001efe:	a8648493          	addi	s1,s1,-1402 # 8000f980 <wait_lock>
    80001f02:	8526                	mv	a0,s1
    80001f04:	ccbfe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001f08:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	d59fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001f12:	8552                	mv	a0,s4
    80001f14:	cbbfe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001f18:	478d                	li	a5,3
    80001f1a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f1e:	8552                	mv	a0,s4
    80001f20:	d47fe0ef          	jal	80000c66 <release>
  return pid;
    80001f24:	74a2                	ld	s1,40(sp)
    80001f26:	69e2                	ld	s3,24(sp)
    80001f28:	6a42                	ld	s4,16(sp)
}
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	70e2                	ld	ra,56(sp)
    80001f2e:	7442                	ld	s0,48(sp)
    80001f30:	7902                	ld	s2,32(sp)
    80001f32:	6aa2                	ld	s5,8(sp)
    80001f34:	6121                	addi	sp,sp,64
    80001f36:	8082                	ret
    return -1;
    80001f38:	597d                	li	s2,-1
    80001f3a:	bfc5                	j	80001f2a <kfork+0xfc>

0000000080001f3c <scheduler>:
{
    80001f3c:	715d                	addi	sp,sp,-80
    80001f3e:	e486                	sd	ra,72(sp)
    80001f40:	e0a2                	sd	s0,64(sp)
    80001f42:	fc26                	sd	s1,56(sp)
    80001f44:	f84a                	sd	s2,48(sp)
    80001f46:	f44e                	sd	s3,40(sp)
    80001f48:	f052                	sd	s4,32(sp)
    80001f4a:	ec56                	sd	s5,24(sp)
    80001f4c:	e85a                	sd	s6,16(sp)
    80001f4e:	e45e                	sd	s7,8(sp)
    80001f50:	e062                	sd	s8,0(sp)
    80001f52:	0880                	addi	s0,sp,80
    80001f54:	8792                	mv	a5,tp
  int id = r_tp();
    80001f56:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f58:	00779b13          	slli	s6,a5,0x7
    80001f5c:	0000e717          	auipc	a4,0xe
    80001f60:	a0c70713          	addi	a4,a4,-1524 # 8000f968 <pid_lock>
    80001f64:	975a                	add	a4,a4,s6
    80001f66:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6a:	0000e717          	auipc	a4,0xe
    80001f6e:	a3670713          	addi	a4,a4,-1482 # 8000f9a0 <cpus+0x8>
    80001f72:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f74:	4c11                	li	s8,4
        c->proc = p;
    80001f76:	079e                	slli	a5,a5,0x7
    80001f78:	0000ea17          	auipc	s4,0xe
    80001f7c:	9f0a0a13          	addi	s4,s4,-1552 # 8000f968 <pid_lock>
    80001f80:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f82:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f84:	00014997          	auipc	s3,0x14
    80001f88:	81498993          	addi	s3,s3,-2028 # 80015798 <tickslock>
    80001f8c:	a83d                	j	80001fca <scheduler+0x8e>
      release(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	cd7fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f94:	16848493          	addi	s1,s1,360
    80001f98:	03348563          	beq	s1,s3,80001fc2 <scheduler+0x86>
      acquire(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	c31fe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001fa2:	4c9c                	lw	a5,24(s1)
    80001fa4:	ff2795e3          	bne	a5,s2,80001f8e <scheduler+0x52>
        p->state = RUNNING;
    80001fa8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fac:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb0:	06048593          	addi	a1,s1,96
    80001fb4:	855a                	mv	a0,s6
    80001fb6:	636000ef          	jal	800025ec <swtch>
        c->proc = 0;
    80001fba:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001fbe:	8ade                	mv	s5,s7
    80001fc0:	b7f9                	j	80001f8e <scheduler+0x52>
    if(found == 0) {
    80001fc2:	000a9463          	bnez	s5,80001fca <scheduler+0x8e>
      asm volatile("wfi");
    80001fc6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fda:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fdc:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fe0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe2:	0000e497          	auipc	s1,0xe
    80001fe6:	db648493          	addi	s1,s1,-586 # 8000fd98 <proc>
      if(p->state == RUNNABLE) {
    80001fea:	490d                	li	s2,3
    80001fec:	bf45                	j	80001f9c <scheduler+0x60>

0000000080001fee <sched>:
{
    80001fee:	7179                	addi	sp,sp,-48
    80001ff0:	f406                	sd	ra,40(sp)
    80001ff2:	f022                	sd	s0,32(sp)
    80001ff4:	ec26                	sd	s1,24(sp)
    80001ff6:	e84a                	sd	s2,16(sp)
    80001ff8:	e44e                	sd	s3,8(sp)
    80001ffa:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ffc:	acfff0ef          	jal	80001aca <myproc>
    80002000:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002002:	b63fe0ef          	jal	80000b64 <holding>
    80002006:	c92d                	beqz	a0,80002078 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002008:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000200a:	2781                	sext.w	a5,a5
    8000200c:	079e                	slli	a5,a5,0x7
    8000200e:	0000e717          	auipc	a4,0xe
    80002012:	95a70713          	addi	a4,a4,-1702 # 8000f968 <pid_lock>
    80002016:	97ba                	add	a5,a5,a4
    80002018:	0a87a703          	lw	a4,168(a5)
    8000201c:	4785                	li	a5,1
    8000201e:	06f71363          	bne	a4,a5,80002084 <sched+0x96>
  if(p->state == RUNNING)
    80002022:	4c98                	lw	a4,24(s1)
    80002024:	4791                	li	a5,4
    80002026:	06f70563          	beq	a4,a5,80002090 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000202e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002030:	e7b5                	bnez	a5,8000209c <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002032:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002034:	0000e917          	auipc	s2,0xe
    80002038:	93490913          	addi	s2,s2,-1740 # 8000f968 <pid_lock>
    8000203c:	2781                	sext.w	a5,a5
    8000203e:	079e                	slli	a5,a5,0x7
    80002040:	97ca                	add	a5,a5,s2
    80002042:	0ac7a983          	lw	s3,172(a5)
    80002046:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002048:	2781                	sext.w	a5,a5
    8000204a:	079e                	slli	a5,a5,0x7
    8000204c:	0000e597          	auipc	a1,0xe
    80002050:	95458593          	addi	a1,a1,-1708 # 8000f9a0 <cpus+0x8>
    80002054:	95be                	add	a1,a1,a5
    80002056:	06048513          	addi	a0,s1,96
    8000205a:	592000ef          	jal	800025ec <swtch>
    8000205e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	slli	a5,a5,0x7
    80002064:	993e                	add	s2,s2,a5
    80002066:	0b392623          	sw	s3,172(s2)
}
    8000206a:	70a2                	ld	ra,40(sp)
    8000206c:	7402                	ld	s0,32(sp)
    8000206e:	64e2                	ld	s1,24(sp)
    80002070:	6942                	ld	s2,16(sp)
    80002072:	69a2                	ld	s3,8(sp)
    80002074:	6145                	addi	sp,sp,48
    80002076:	8082                	ret
    panic("sched p->lock");
    80002078:	00005517          	auipc	a0,0x5
    8000207c:	12050513          	addi	a0,a0,288 # 80007198 <etext+0x198>
    80002080:	f60fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002084:	00005517          	auipc	a0,0x5
    80002088:	12450513          	addi	a0,a0,292 # 800071a8 <etext+0x1a8>
    8000208c:	f54fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002090:	00005517          	auipc	a0,0x5
    80002094:	12850513          	addi	a0,a0,296 # 800071b8 <etext+0x1b8>
    80002098:	f48fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    8000209c:	00005517          	auipc	a0,0x5
    800020a0:	12c50513          	addi	a0,a0,300 # 800071c8 <etext+0x1c8>
    800020a4:	f3cfe0ef          	jal	800007e0 <panic>

00000000800020a8 <yield>:
{
    800020a8:	1101                	addi	sp,sp,-32
    800020aa:	ec06                	sd	ra,24(sp)
    800020ac:	e822                	sd	s0,16(sp)
    800020ae:	e426                	sd	s1,8(sp)
    800020b0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020b2:	a19ff0ef          	jal	80001aca <myproc>
    800020b6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020b8:	b17fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
  sched();
    800020c0:	f2fff0ef          	jal	80001fee <sched>
  release(&p->lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	ba1fe0ef          	jal	80000c66 <release>
}
    800020ca:	60e2                	ld	ra,24(sp)
    800020cc:	6442                	ld	s0,16(sp)
    800020ce:	64a2                	ld	s1,8(sp)
    800020d0:	6105                	addi	sp,sp,32
    800020d2:	8082                	ret

00000000800020d4 <sleep>:
{
    800020d4:	7179                	addi	sp,sp,-48
    800020d6:	f406                	sd	ra,40(sp)
    800020d8:	f022                	sd	s0,32(sp)
    800020da:	ec26                	sd	s1,24(sp)
    800020dc:	e84a                	sd	s2,16(sp)
    800020de:	e44e                	sd	s3,8(sp)
    800020e0:	1800                	addi	s0,sp,48
    800020e2:	89aa                	mv	s3,a0
    800020e4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e6:	9e5ff0ef          	jal	80001aca <myproc>
    800020ea:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    800020ec:	ae3fe0ef          	jal	80000bce <acquire>
  release(lk);
    800020f0:	854a                	mv	a0,s2
    800020f2:	b75fe0ef          	jal	80000c66 <release>
  p->chan = chan;
    800020f6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020fa:	4789                	li	a5,2
    800020fc:	cc9c                	sw	a5,24(s1)
  sched();
    800020fe:	ef1ff0ef          	jal	80001fee <sched>
  p->chan = 0;
    80002102:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	b5ffe0ef          	jal	80000c66 <release>
  acquire(lk);
    8000210c:	854a                	mv	a0,s2
    8000210e:	ac1fe0ef          	jal	80000bce <acquire>
}
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6942                	ld	s2,16(sp)
    8000211a:	69a2                	ld	s3,8(sp)
    8000211c:	6145                	addi	sp,sp,48
    8000211e:	8082                	ret

0000000080002120 <wakeup>:
{
    80002120:	7139                	addi	sp,sp,-64
    80002122:	fc06                	sd	ra,56(sp)
    80002124:	f822                	sd	s0,48(sp)
    80002126:	f426                	sd	s1,40(sp)
    80002128:	f04a                	sd	s2,32(sp)
    8000212a:	ec4e                	sd	s3,24(sp)
    8000212c:	e852                	sd	s4,16(sp)
    8000212e:	e456                	sd	s5,8(sp)
    80002130:	0080                	addi	s0,sp,64
    80002132:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002134:	0000e497          	auipc	s1,0xe
    80002138:	c6448493          	addi	s1,s1,-924 # 8000fd98 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    8000213c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000213e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002140:	00013917          	auipc	s2,0x13
    80002144:	65890913          	addi	s2,s2,1624 # 80015798 <tickslock>
    80002148:	a801                	j	80002158 <wakeup+0x38>
      release(&p->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	b1bfe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002150:	16848493          	addi	s1,s1,360
    80002154:	03248263          	beq	s1,s2,80002178 <wakeup+0x58>
    if(p != myproc()){
    80002158:	973ff0ef          	jal	80001aca <myproc>
    8000215c:	fea48ae3          	beq	s1,a0,80002150 <wakeup+0x30>
      acquire(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	a6dfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002166:	4c9c                	lw	a5,24(s1)
    80002168:	ff3791e3          	bne	a5,s3,8000214a <wakeup+0x2a>
    8000216c:	709c                	ld	a5,32(s1)
    8000216e:	fd479ee3          	bne	a5,s4,8000214a <wakeup+0x2a>
        p->state = RUNNABLE;
    80002172:	0154ac23          	sw	s5,24(s1)
    80002176:	bfd1                	j	8000214a <wakeup+0x2a>
}
    80002178:	70e2                	ld	ra,56(sp)
    8000217a:	7442                	ld	s0,48(sp)
    8000217c:	74a2                	ld	s1,40(sp)
    8000217e:	7902                	ld	s2,32(sp)
    80002180:	69e2                	ld	s3,24(sp)
    80002182:	6a42                	ld	s4,16(sp)
    80002184:	6aa2                	ld	s5,8(sp)
    80002186:	6121                	addi	sp,sp,64
    80002188:	8082                	ret

000000008000218a <reparent>:
{
    8000218a:	7179                	addi	sp,sp,-48
    8000218c:	f406                	sd	ra,40(sp)
    8000218e:	f022                	sd	s0,32(sp)
    80002190:	ec26                	sd	s1,24(sp)
    80002192:	e84a                	sd	s2,16(sp)
    80002194:	e44e                	sd	s3,8(sp)
    80002196:	e052                	sd	s4,0(sp)
    80002198:	1800                	addi	s0,sp,48
    8000219a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000219c:	0000e497          	auipc	s1,0xe
    800021a0:	bfc48493          	addi	s1,s1,-1028 # 8000fd98 <proc>
      pp->parent = initproc;
    800021a4:	00005a17          	auipc	s4,0x5
    800021a8:	6bca0a13          	addi	s4,s4,1724 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ac:	00013997          	auipc	s3,0x13
    800021b0:	5ec98993          	addi	s3,s3,1516 # 80015798 <tickslock>
    800021b4:	a029                	j	800021be <reparent+0x34>
    800021b6:	16848493          	addi	s1,s1,360
    800021ba:	01348b63          	beq	s1,s3,800021d0 <reparent+0x46>
    if(pp->parent == p){
    800021be:	7c9c                	ld	a5,56(s1)
    800021c0:	ff279be3          	bne	a5,s2,800021b6 <reparent+0x2c>
      pp->parent = initproc;
    800021c4:	000a3503          	ld	a0,0(s4)
    800021c8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021ca:	f57ff0ef          	jal	80002120 <wakeup>
    800021ce:	b7e5                	j	800021b6 <reparent+0x2c>
}
    800021d0:	70a2                	ld	ra,40(sp)
    800021d2:	7402                	ld	s0,32(sp)
    800021d4:	64e2                	ld	s1,24(sp)
    800021d6:	6942                	ld	s2,16(sp)
    800021d8:	69a2                	ld	s3,8(sp)
    800021da:	6a02                	ld	s4,0(sp)
    800021dc:	6145                	addi	sp,sp,48
    800021de:	8082                	ret

00000000800021e0 <kexit>:
{
    800021e0:	7179                	addi	sp,sp,-48
    800021e2:	f406                	sd	ra,40(sp)
    800021e4:	f022                	sd	s0,32(sp)
    800021e6:	ec26                	sd	s1,24(sp)
    800021e8:	e84a                	sd	s2,16(sp)
    800021ea:	e44e                	sd	s3,8(sp)
    800021ec:	e052                	sd	s4,0(sp)
    800021ee:	1800                	addi	s0,sp,48
    800021f0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021f2:	8d9ff0ef          	jal	80001aca <myproc>
    800021f6:	89aa                	mv	s3,a0
  if(p == initproc)
    800021f8:	00005797          	auipc	a5,0x5
    800021fc:	6687b783          	ld	a5,1640(a5) # 80007860 <initproc>
    80002200:	0d050493          	addi	s1,a0,208
    80002204:	15050913          	addi	s2,a0,336
    80002208:	00a79f63          	bne	a5,a0,80002226 <kexit+0x46>
    panic("init exiting");
    8000220c:	00005517          	auipc	a0,0x5
    80002210:	fd450513          	addi	a0,a0,-44 # 800071e0 <etext+0x1e0>
    80002214:	dccfe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002218:	0a0020ef          	jal	800042b8 <fileclose>
      p->ofile[fd] = 0;
    8000221c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002220:	04a1                	addi	s1,s1,8
    80002222:	01248563          	beq	s1,s2,8000222c <kexit+0x4c>
    if(p->ofile[fd]){
    80002226:	6088                	ld	a0,0(s1)
    80002228:	f965                	bnez	a0,80002218 <kexit+0x38>
    8000222a:	bfdd                	j	80002220 <kexit+0x40>
  begin_op();
    8000222c:	481010ef          	jal	80003eac <begin_op>
  iput(p->cwd);
    80002230:	1509b503          	ld	a0,336(s3)
    80002234:	410010ef          	jal	80003644 <iput>
  end_op();
    80002238:	4df010ef          	jal	80003f16 <end_op>
  p->cwd = 0;
    8000223c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002240:	0000d497          	auipc	s1,0xd
    80002244:	74048493          	addi	s1,s1,1856 # 8000f980 <wait_lock>
    80002248:	8526                	mv	a0,s1
    8000224a:	985fe0ef          	jal	80000bce <acquire>
  reparent(p);
    8000224e:	854e                	mv	a0,s3
    80002250:	f3bff0ef          	jal	8000218a <reparent>
  wakeup(p->parent);
    80002254:	0389b503          	ld	a0,56(s3)
    80002258:	ec9ff0ef          	jal	80002120 <wakeup>
  acquire(&p->lock);
    8000225c:	854e                	mv	a0,s3
    8000225e:	971fe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002262:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002266:	4795                	li	a5,5
    80002268:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000226c:	8526                	mv	a0,s1
    8000226e:	9f9fe0ef          	jal	80000c66 <release>
  sched();
    80002272:	d7dff0ef          	jal	80001fee <sched>
  panic("zombie exit");
    80002276:	00005517          	auipc	a0,0x5
    8000227a:	f7a50513          	addi	a0,a0,-134 # 800071f0 <etext+0x1f0>
    8000227e:	d62fe0ef          	jal	800007e0 <panic>

0000000080002282 <kkill>:
{
    80002282:	7179                	addi	sp,sp,-48
    80002284:	f406                	sd	ra,40(sp)
    80002286:	f022                	sd	s0,32(sp)
    80002288:	ec26                	sd	s1,24(sp)
    8000228a:	e84a                	sd	s2,16(sp)
    8000228c:	e44e                	sd	s3,8(sp)
    8000228e:	1800                	addi	s0,sp,48
    80002290:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002292:	0000e497          	auipc	s1,0xe
    80002296:	b0648493          	addi	s1,s1,-1274 # 8000fd98 <proc>
    8000229a:	00013997          	auipc	s3,0x13
    8000229e:	4fe98993          	addi	s3,s3,1278 # 80015798 <tickslock>
    acquire(&p->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	92bfe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    800022a8:	589c                	lw	a5,48(s1)
    800022aa:	01278b63          	beq	a5,s2,800022c0 <kkill+0x3e>
    release(&p->lock);
    800022ae:	8526                	mv	a0,s1
    800022b0:	9b7fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b4:	16848493          	addi	s1,s1,360
    800022b8:	ff3495e3          	bne	s1,s3,800022a2 <kkill+0x20>
  return -1;
    800022bc:	557d                	li	a0,-1
    800022be:	a819                	j	800022d4 <kkill+0x52>
      p->killed = 1;
    800022c0:	4785                	li	a5,1
    800022c2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022c4:	4c98                	lw	a4,24(s1)
    800022c6:	4789                	li	a5,2
    800022c8:	00f70d63          	beq	a4,a5,800022e2 <kkill+0x60>
      release(&p->lock);
    800022cc:	8526                	mv	a0,s1
    800022ce:	999fe0ef          	jal	80000c66 <release>
      return 0;
    800022d2:	4501                	li	a0,0
}
    800022d4:	70a2                	ld	ra,40(sp)
    800022d6:	7402                	ld	s0,32(sp)
    800022d8:	64e2                	ld	s1,24(sp)
    800022da:	6942                	ld	s2,16(sp)
    800022dc:	69a2                	ld	s3,8(sp)
    800022de:	6145                	addi	sp,sp,48
    800022e0:	8082                	ret
        p->state = RUNNABLE;
    800022e2:	478d                	li	a5,3
    800022e4:	cc9c                	sw	a5,24(s1)
    800022e6:	b7dd                	j	800022cc <kkill+0x4a>

00000000800022e8 <setkilled>:
{
    800022e8:	1101                	addi	sp,sp,-32
    800022ea:	ec06                	sd	ra,24(sp)
    800022ec:	e822                	sd	s0,16(sp)
    800022ee:	e426                	sd	s1,8(sp)
    800022f0:	1000                	addi	s0,sp,32
    800022f2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f4:	8dbfe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800022f8:	4785                	li	a5,1
    800022fa:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	969fe0ef          	jal	80000c66 <release>
}
    80002302:	60e2                	ld	ra,24(sp)
    80002304:	6442                	ld	s0,16(sp)
    80002306:	64a2                	ld	s1,8(sp)
    80002308:	6105                	addi	sp,sp,32
    8000230a:	8082                	ret

000000008000230c <killed>:
{
    8000230c:	1101                	addi	sp,sp,-32
    8000230e:	ec06                	sd	ra,24(sp)
    80002310:	e822                	sd	s0,16(sp)
    80002312:	e426                	sd	s1,8(sp)
    80002314:	e04a                	sd	s2,0(sp)
    80002316:	1000                	addi	s0,sp,32
    80002318:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000231a:	8b5fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    8000231e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	943fe0ef          	jal	80000c66 <release>
}
    80002328:	854a                	mv	a0,s2
    8000232a:	60e2                	ld	ra,24(sp)
    8000232c:	6442                	ld	s0,16(sp)
    8000232e:	64a2                	ld	s1,8(sp)
    80002330:	6902                	ld	s2,0(sp)
    80002332:	6105                	addi	sp,sp,32
    80002334:	8082                	ret

0000000080002336 <kwait>:
{
    80002336:	715d                	addi	sp,sp,-80
    80002338:	e486                	sd	ra,72(sp)
    8000233a:	e0a2                	sd	s0,64(sp)
    8000233c:	fc26                	sd	s1,56(sp)
    8000233e:	f84a                	sd	s2,48(sp)
    80002340:	f44e                	sd	s3,40(sp)
    80002342:	f052                	sd	s4,32(sp)
    80002344:	ec56                	sd	s5,24(sp)
    80002346:	e85a                	sd	s6,16(sp)
    80002348:	e45e                	sd	s7,8(sp)
    8000234a:	e062                	sd	s8,0(sp)
    8000234c:	0880                	addi	s0,sp,80
    8000234e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002350:	f7aff0ef          	jal	80001aca <myproc>
    80002354:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002356:	0000d517          	auipc	a0,0xd
    8000235a:	62a50513          	addi	a0,a0,1578 # 8000f980 <wait_lock>
    8000235e:	871fe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002362:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002364:	4a15                	li	s4,5
        havekids = 1;
    80002366:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002368:	00013997          	auipc	s3,0x13
    8000236c:	43098993          	addi	s3,s3,1072 # 80015798 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002370:	0000dc17          	auipc	s8,0xd
    80002374:	610c0c13          	addi	s8,s8,1552 # 8000f980 <wait_lock>
    80002378:	a871                	j	80002414 <kwait+0xde>
          pid = pp->pid;
    8000237a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000237e:	000b0c63          	beqz	s6,80002396 <kwait+0x60>
    80002382:	4691                	li	a3,4
    80002384:	02c48613          	addi	a2,s1,44
    80002388:	85da                	mv	a1,s6
    8000238a:	05093503          	ld	a0,80(s2)
    8000238e:	a54ff0ef          	jal	800015e2 <copyout>
    80002392:	02054b63          	bltz	a0,800023c8 <kwait+0x92>
          freeproc(pp);
    80002396:	8526                	mv	a0,s1
    80002398:	903ff0ef          	jal	80001c9a <freeproc>
          release(&pp->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	8c9fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    800023a2:	0000d517          	auipc	a0,0xd
    800023a6:	5de50513          	addi	a0,a0,1502 # 8000f980 <wait_lock>
    800023aa:	8bdfe0ef          	jal	80000c66 <release>
}
    800023ae:	854e                	mv	a0,s3
    800023b0:	60a6                	ld	ra,72(sp)
    800023b2:	6406                	ld	s0,64(sp)
    800023b4:	74e2                	ld	s1,56(sp)
    800023b6:	7942                	ld	s2,48(sp)
    800023b8:	79a2                	ld	s3,40(sp)
    800023ba:	7a02                	ld	s4,32(sp)
    800023bc:	6ae2                	ld	s5,24(sp)
    800023be:	6b42                	ld	s6,16(sp)
    800023c0:	6ba2                	ld	s7,8(sp)
    800023c2:	6c02                	ld	s8,0(sp)
    800023c4:	6161                	addi	sp,sp,80
    800023c6:	8082                	ret
            release(&pp->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	89dfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800023ce:	0000d517          	auipc	a0,0xd
    800023d2:	5b250513          	addi	a0,a0,1458 # 8000f980 <wait_lock>
    800023d6:	891fe0ef          	jal	80000c66 <release>
            return -1;
    800023da:	59fd                	li	s3,-1
    800023dc:	bfc9                	j	800023ae <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023de:	16848493          	addi	s1,s1,360
    800023e2:	03348063          	beq	s1,s3,80002402 <kwait+0xcc>
      if(pp->parent == p){
    800023e6:	7c9c                	ld	a5,56(s1)
    800023e8:	ff279be3          	bne	a5,s2,800023de <kwait+0xa8>
        acquire(&pp->lock);
    800023ec:	8526                	mv	a0,s1
    800023ee:	fe0fe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800023f2:	4c9c                	lw	a5,24(s1)
    800023f4:	f94783e3          	beq	a5,s4,8000237a <kwait+0x44>
        release(&pp->lock);
    800023f8:	8526                	mv	a0,s1
    800023fa:	86dfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800023fe:	8756                	mv	a4,s5
    80002400:	bff9                	j	800023de <kwait+0xa8>
    if(!havekids || killed(p)){
    80002402:	cf19                	beqz	a4,80002420 <kwait+0xea>
    80002404:	854a                	mv	a0,s2
    80002406:	f07ff0ef          	jal	8000230c <killed>
    8000240a:	e919                	bnez	a0,80002420 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000240c:	85e2                	mv	a1,s8
    8000240e:	854a                	mv	a0,s2
    80002410:	cc5ff0ef          	jal	800020d4 <sleep>
    havekids = 0;
    80002414:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002416:	0000e497          	auipc	s1,0xe
    8000241a:	98248493          	addi	s1,s1,-1662 # 8000fd98 <proc>
    8000241e:	b7e1                	j	800023e6 <kwait+0xb0>
      release(&wait_lock);
    80002420:	0000d517          	auipc	a0,0xd
    80002424:	56050513          	addi	a0,a0,1376 # 8000f980 <wait_lock>
    80002428:	83ffe0ef          	jal	80000c66 <release>
      return -1;
    8000242c:	59fd                	li	s3,-1
    8000242e:	b741                	j	800023ae <kwait+0x78>

0000000080002430 <either_copyout>:
{
    80002430:	7179                	addi	sp,sp,-48
    80002432:	f406                	sd	ra,40(sp)
    80002434:	f022                	sd	s0,32(sp)
    80002436:	ec26                	sd	s1,24(sp)
    80002438:	e84a                	sd	s2,16(sp)
    8000243a:	e44e                	sd	s3,8(sp)
    8000243c:	e052                	sd	s4,0(sp)
    8000243e:	1800                	addi	s0,sp,48
    80002440:	84aa                	mv	s1,a0
    80002442:	892e                	mv	s2,a1
    80002444:	89b2                	mv	s3,a2
    80002446:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002448:	e82ff0ef          	jal	80001aca <myproc>
  if(user_dst){
    8000244c:	cc99                	beqz	s1,8000246a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000244e:	86d2                	mv	a3,s4
    80002450:	864e                	mv	a2,s3
    80002452:	85ca                	mv	a1,s2
    80002454:	6928                	ld	a0,80(a0)
    80002456:	98cff0ef          	jal	800015e2 <copyout>
}
    8000245a:	70a2                	ld	ra,40(sp)
    8000245c:	7402                	ld	s0,32(sp)
    8000245e:	64e2                	ld	s1,24(sp)
    80002460:	6942                	ld	s2,16(sp)
    80002462:	69a2                	ld	s3,8(sp)
    80002464:	6a02                	ld	s4,0(sp)
    80002466:	6145                	addi	sp,sp,48
    80002468:	8082                	ret
    memmove((char *)dst, src, len);
    8000246a:	000a061b          	sext.w	a2,s4
    8000246e:	85ce                	mv	a1,s3
    80002470:	854a                	mv	a0,s2
    80002472:	88dfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002476:	8526                	mv	a0,s1
    80002478:	b7cd                	j	8000245a <either_copyout+0x2a>

000000008000247a <either_copyin>:
{
    8000247a:	7179                	addi	sp,sp,-48
    8000247c:	f406                	sd	ra,40(sp)
    8000247e:	f022                	sd	s0,32(sp)
    80002480:	ec26                	sd	s1,24(sp)
    80002482:	e84a                	sd	s2,16(sp)
    80002484:	e44e                	sd	s3,8(sp)
    80002486:	e052                	sd	s4,0(sp)
    80002488:	1800                	addi	s0,sp,48
    8000248a:	892a                	mv	s2,a0
    8000248c:	84ae                	mv	s1,a1
    8000248e:	89b2                	mv	s3,a2
    80002490:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002492:	e38ff0ef          	jal	80001aca <myproc>
  if(user_src){
    80002496:	cc99                	beqz	s1,800024b4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002498:	86d2                	mv	a3,s4
    8000249a:	864e                	mv	a2,s3
    8000249c:	85ca                	mv	a1,s2
    8000249e:	6928                	ld	a0,80(a0)
    800024a0:	a26ff0ef          	jal	800016c6 <copyin>
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6a02                	ld	s4,0(sp)
    800024b0:	6145                	addi	sp,sp,48
    800024b2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024b4:	000a061b          	sext.w	a2,s4
    800024b8:	85ce                	mv	a1,s3
    800024ba:	854a                	mv	a0,s2
    800024bc:	843fe0ef          	jal	80000cfe <memmove>
    return 0;
    800024c0:	8526                	mv	a0,s1
    800024c2:	b7cd                	j	800024a4 <either_copyin+0x2a>

00000000800024c4 <procdump>:
{
    800024c4:	715d                	addi	sp,sp,-80
    800024c6:	e486                	sd	ra,72(sp)
    800024c8:	e0a2                	sd	s0,64(sp)
    800024ca:	fc26                	sd	s1,56(sp)
    800024cc:	f84a                	sd	s2,48(sp)
    800024ce:	f44e                	sd	s3,40(sp)
    800024d0:	f052                	sd	s4,32(sp)
    800024d2:	ec56                	sd	s5,24(sp)
    800024d4:	e85a                	sd	s6,16(sp)
    800024d6:	e45e                	sd	s7,8(sp)
    800024d8:	0880                	addi	s0,sp,80
  printf("\n");
    800024da:	00005517          	auipc	a0,0x5
    800024de:	b9e50513          	addi	a0,a0,-1122 # 80007078 <etext+0x78>
    800024e2:	818fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024e6:	0000e497          	auipc	s1,0xe
    800024ea:	a0a48493          	addi	s1,s1,-1526 # 8000fef0 <proc+0x158>
    800024ee:	00013917          	auipc	s2,0x13
    800024f2:	40290913          	addi	s2,s2,1026 # 800158f0 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f6:	4b15                	li	s6,5
      state = "???";
    800024f8:	00005997          	auipc	s3,0x5
    800024fc:	d0898993          	addi	s3,s3,-760 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002500:	00005a97          	auipc	s5,0x5
    80002504:	d08a8a93          	addi	s5,s5,-760 # 80007208 <etext+0x208>
    printf("\n");
    80002508:	00005a17          	auipc	s4,0x5
    8000250c:	b70a0a13          	addi	s4,s4,-1168 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002510:	00005b97          	auipc	s7,0x5
    80002514:	218b8b93          	addi	s7,s7,536 # 80007728 <states.0>
    80002518:	a829                	j	80002532 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000251a:	ed86a583          	lw	a1,-296(a3)
    8000251e:	8556                	mv	a0,s5
    80002520:	fdbfd0ef          	jal	800004fa <printf>
    printf("\n");
    80002524:	8552                	mv	a0,s4
    80002526:	fd5fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252a:	16848493          	addi	s1,s1,360
    8000252e:	03248263          	beq	s1,s2,80002552 <procdump+0x8e>
    if(p->state == UNUSED)
    80002532:	86a6                	mv	a3,s1
    80002534:	ec04a783          	lw	a5,-320(s1)
    80002538:	dbed                	beqz	a5,8000252a <procdump+0x66>
      state = "???";
    8000253a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253c:	fcfb6fe3          	bltu	s6,a5,8000251a <procdump+0x56>
    80002540:	02079713          	slli	a4,a5,0x20
    80002544:	01d75793          	srli	a5,a4,0x1d
    80002548:	97de                	add	a5,a5,s7
    8000254a:	6390                	ld	a2,0(a5)
    8000254c:	f679                	bnez	a2,8000251a <procdump+0x56>
      state = "???";
    8000254e:	864e                	mv	a2,s3
    80002550:	b7e9                	j	8000251a <procdump+0x56>
}
    80002552:	60a6                	ld	ra,72(sp)
    80002554:	6406                	ld	s0,64(sp)
    80002556:	74e2                	ld	s1,56(sp)
    80002558:	7942                	ld	s2,48(sp)
    8000255a:	79a2                	ld	s3,40(sp)
    8000255c:	7a02                	ld	s4,32(sp)
    8000255e:	6ae2                	ld	s5,24(sp)
    80002560:	6b42                	ld	s6,16(sp)
    80002562:	6ba2                	ld	s7,8(sp)
    80002564:	6161                	addi	sp,sp,80
    80002566:	8082                	ret

0000000080002568 <ptree>:
{
    80002568:	715d                	addi	sp,sp,-80
    8000256a:	e486                	sd	ra,72(sp)
    8000256c:	e0a2                	sd	s0,64(sp)
    8000256e:	fc26                	sd	s1,56(sp)
    80002570:	f84a                	sd	s2,48(sp)
    80002572:	f44e                	sd	s3,40(sp)
    80002574:	f052                	sd	s4,32(sp)
    80002576:	ec56                	sd	s5,24(sp)
    80002578:	0880                	addi	s0,sp,80
    8000257a:	892a                	mv	s2,a0
    8000257c:	8a2e                	mv	s4,a1
    8000257e:	8ab2                	mv	s5,a2
  int written = 0;
    80002580:	fa042e23          	sw	zero,-68(s0)
  for (p = proc; p < &proc[NPROC]; p++) {
    80002584:	0000e497          	auipc	s1,0xe
    80002588:	81448493          	addi	s1,s1,-2028 # 8000fd98 <proc>
    8000258c:	00013997          	auipc	s3,0x13
    80002590:	20c98993          	addi	s3,s3,524 # 80015798 <tickslock>
    acquire(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	e38fe0ef          	jal	80000bce <acquire>
    if (p->pid == rootpid) {
    8000259a:	589c                	lw	a5,48(s1)
    8000259c:	01278b63          	beq	a5,s2,800025b2 <ptree+0x4a>
    release(&p->lock);
    800025a0:	8526                	mv	a0,s1
    800025a2:	ec4fe0ef          	jal	80000c66 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800025a6:	16848493          	addi	s1,s1,360
    800025aa:	ff3495e3          	bne	s1,s3,80002594 <ptree+0x2c>
    return -1; // pid not found
    800025ae:	557d                	li	a0,-1
    800025b0:	a01d                	j	800025d6 <ptree+0x6e>
      release(&p->lock);
    800025b2:	8526                	mv	a0,s1
    800025b4:	eb2fe0ef          	jal	80000c66 <release>
  pagetable_t caller_pg = myproc()->pagetable;
    800025b8:	d12ff0ef          	jal	80001aca <myproc>
  int ret = ptree_walk(root, 0, caller_pg, dst, bufsize, &written);
    800025bc:	fbc40793          	addi	a5,s0,-68
    800025c0:	8756                	mv	a4,s5
    800025c2:	86d2                	mv	a3,s4
    800025c4:	6930                	ld	a2,80(a0)
    800025c6:	4581                	li	a1,0
    800025c8:	8526                	mv	a0,s1
    800025ca:	98aff0ef          	jal	80001754 <ptree_walk>
  if (ret < 0)
    800025ce:	00054d63          	bltz	a0,800025e8 <ptree+0x80>
  return written;
    800025d2:	fbc42503          	lw	a0,-68(s0)
}
    800025d6:	60a6                	ld	ra,72(sp)
    800025d8:	6406                	ld	s0,64(sp)
    800025da:	74e2                	ld	s1,56(sp)
    800025dc:	7942                	ld	s2,48(sp)
    800025de:	79a2                	ld	s3,40(sp)
    800025e0:	7a02                	ld	s4,32(sp)
    800025e2:	6ae2                	ld	s5,24(sp)
    800025e4:	6161                	addi	sp,sp,80
    800025e6:	8082                	ret
    return -1;
    800025e8:	557d                	li	a0,-1
    800025ea:	b7f5                	j	800025d6 <ptree+0x6e>

00000000800025ec <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025ec:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025f0:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025f4:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025f6:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025f8:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025fc:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002600:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002604:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002608:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000260c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002610:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002614:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002618:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000261c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002620:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002624:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002628:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000262a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000262c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002630:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002634:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002638:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000263c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002640:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002644:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002648:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000264c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002650:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002654:	8082                	ret

0000000080002656 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002656:	1141                	addi	sp,sp,-16
    80002658:	e406                	sd	ra,8(sp)
    8000265a:	e022                	sd	s0,0(sp)
    8000265c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000265e:	00005597          	auipc	a1,0x5
    80002662:	bea58593          	addi	a1,a1,-1046 # 80007248 <etext+0x248>
    80002666:	00013517          	auipc	a0,0x13
    8000266a:	13250513          	addi	a0,a0,306 # 80015798 <tickslock>
    8000266e:	ce0fe0ef          	jal	80000b4e <initlock>
}
    80002672:	60a2                	ld	ra,8(sp)
    80002674:	6402                	ld	s0,0(sp)
    80002676:	0141                	addi	sp,sp,16
    80002678:	8082                	ret

000000008000267a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000267a:	1141                	addi	sp,sp,-16
    8000267c:	e422                	sd	s0,8(sp)
    8000267e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002680:	00003797          	auipc	a5,0x3
    80002684:	fb078793          	addi	a5,a5,-80 # 80005630 <kernelvec>
    80002688:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000268c:	6422                	ld	s0,8(sp)
    8000268e:	0141                	addi	sp,sp,16
    80002690:	8082                	ret

0000000080002692 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002692:	1141                	addi	sp,sp,-16
    80002694:	e406                	sd	ra,8(sp)
    80002696:	e022                	sd	s0,0(sp)
    80002698:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000269a:	c30ff0ef          	jal	80001aca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000269e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026a8:	04000737          	lui	a4,0x4000
    800026ac:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026ae:	0732                	slli	a4,a4,0xc
    800026b0:	00004797          	auipc	a5,0x4
    800026b4:	95078793          	addi	a5,a5,-1712 # 80006000 <_trampoline>
    800026b8:	00004697          	auipc	a3,0x4
    800026bc:	94868693          	addi	a3,a3,-1720 # 80006000 <_trampoline>
    800026c0:	8f95                	sub	a5,a5,a3
    800026c2:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026c4:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026c8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ca:	18002773          	csrr	a4,satp
    800026ce:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026d0:	6d38                	ld	a4,88(a0)
    800026d2:	613c                	ld	a5,64(a0)
    800026d4:	6685                	lui	a3,0x1
    800026d6:	97b6                	add	a5,a5,a3
    800026d8:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026da:	6d3c                	ld	a5,88(a0)
    800026dc:	00000717          	auipc	a4,0x0
    800026e0:	0f870713          	addi	a4,a4,248 # 800027d4 <usertrap>
    800026e4:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026e6:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026e8:	8712                	mv	a4,tp
    800026ea:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ec:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026f0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026f4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026fc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026fe:	6f9c                	ld	a5,24(a5)
    80002700:	14179073          	csrw	sepc,a5
}
    80002704:	60a2                	ld	ra,8(sp)
    80002706:	6402                	ld	s0,0(sp)
    80002708:	0141                	addi	sp,sp,16
    8000270a:	8082                	ret

000000008000270c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000270c:	1101                	addi	sp,sp,-32
    8000270e:	ec06                	sd	ra,24(sp)
    80002710:	e822                	sd	s0,16(sp)
    80002712:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002714:	b8aff0ef          	jal	80001a9e <cpuid>
    80002718:	cd11                	beqz	a0,80002734 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000271a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000271e:	000f4737          	lui	a4,0xf4
    80002722:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002726:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002728:	14d79073          	csrw	stimecmp,a5
}
    8000272c:	60e2                	ld	ra,24(sp)
    8000272e:	6442                	ld	s0,16(sp)
    80002730:	6105                	addi	sp,sp,32
    80002732:	8082                	ret
    80002734:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002736:	00013497          	auipc	s1,0x13
    8000273a:	06248493          	addi	s1,s1,98 # 80015798 <tickslock>
    8000273e:	8526                	mv	a0,s1
    80002740:	c8efe0ef          	jal	80000bce <acquire>
    ticks++;
    80002744:	00005517          	auipc	a0,0x5
    80002748:	12450513          	addi	a0,a0,292 # 80007868 <ticks>
    8000274c:	411c                	lw	a5,0(a0)
    8000274e:	2785                	addiw	a5,a5,1
    80002750:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002752:	9cfff0ef          	jal	80002120 <wakeup>
    release(&tickslock);
    80002756:	8526                	mv	a0,s1
    80002758:	d0efe0ef          	jal	80000c66 <release>
    8000275c:	64a2                	ld	s1,8(sp)
    8000275e:	bf75                	j	8000271a <clockintr+0xe>

0000000080002760 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002760:	1101                	addi	sp,sp,-32
    80002762:	ec06                	sd	ra,24(sp)
    80002764:	e822                	sd	s0,16(sp)
    80002766:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002768:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000276c:	57fd                	li	a5,-1
    8000276e:	17fe                	slli	a5,a5,0x3f
    80002770:	07a5                	addi	a5,a5,9
    80002772:	00f70c63          	beq	a4,a5,8000278a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002776:	57fd                	li	a5,-1
    80002778:	17fe                	slli	a5,a5,0x3f
    8000277a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000277c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000277e:	04f70763          	beq	a4,a5,800027cc <devintr+0x6c>
  }
}
    80002782:	60e2                	ld	ra,24(sp)
    80002784:	6442                	ld	s0,16(sp)
    80002786:	6105                	addi	sp,sp,32
    80002788:	8082                	ret
    8000278a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000278c:	751020ef          	jal	800056dc <plic_claim>
    80002790:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002792:	47a9                	li	a5,10
    80002794:	00f50963          	beq	a0,a5,800027a6 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002798:	4785                	li	a5,1
    8000279a:	00f50963          	beq	a0,a5,800027ac <devintr+0x4c>
    return 1;
    8000279e:	4505                	li	a0,1
    } else if(irq){
    800027a0:	e889                	bnez	s1,800027b2 <devintr+0x52>
    800027a2:	64a2                	ld	s1,8(sp)
    800027a4:	bff9                	j	80002782 <devintr+0x22>
      uartintr();
    800027a6:	a0afe0ef          	jal	800009b0 <uartintr>
    if(irq)
    800027aa:	a819                	j	800027c0 <devintr+0x60>
      virtio_disk_intr();
    800027ac:	3f6030ef          	jal	80005ba2 <virtio_disk_intr>
    if(irq)
    800027b0:	a801                	j	800027c0 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800027b2:	85a6                	mv	a1,s1
    800027b4:	00005517          	auipc	a0,0x5
    800027b8:	a9c50513          	addi	a0,a0,-1380 # 80007250 <etext+0x250>
    800027bc:	d3ffd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800027c0:	8526                	mv	a0,s1
    800027c2:	73b020ef          	jal	800056fc <plic_complete>
    return 1;
    800027c6:	4505                	li	a0,1
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	bf65                	j	80002782 <devintr+0x22>
    clockintr();
    800027cc:	f41ff0ef          	jal	8000270c <clockintr>
    return 2;
    800027d0:	4509                	li	a0,2
    800027d2:	bf45                	j	80002782 <devintr+0x22>

00000000800027d4 <usertrap>:
{
    800027d4:	1101                	addi	sp,sp,-32
    800027d6:	ec06                	sd	ra,24(sp)
    800027d8:	e822                	sd	s0,16(sp)
    800027da:	e426                	sd	s1,8(sp)
    800027dc:	e04a                	sd	s2,0(sp)
    800027de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027e4:	1007f793          	andi	a5,a5,256
    800027e8:	eba5                	bnez	a5,80002858 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ea:	00003797          	auipc	a5,0x3
    800027ee:	e4678793          	addi	a5,a5,-442 # 80005630 <kernelvec>
    800027f2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027f6:	ad4ff0ef          	jal	80001aca <myproc>
    800027fa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027fc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027fe:	14102773          	csrr	a4,sepc
    80002802:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002804:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002808:	47a1                	li	a5,8
    8000280a:	04f70d63          	beq	a4,a5,80002864 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000280e:	f53ff0ef          	jal	80002760 <devintr>
    80002812:	892a                	mv	s2,a0
    80002814:	e945                	bnez	a0,800028c4 <usertrap+0xf0>
    80002816:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000281a:	47bd                	li	a5,15
    8000281c:	08f70863          	beq	a4,a5,800028ac <usertrap+0xd8>
    80002820:	14202773          	csrr	a4,scause
    80002824:	47b5                	li	a5,13
    80002826:	08f70363          	beq	a4,a5,800028ac <usertrap+0xd8>
    8000282a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000282e:	5890                	lw	a2,48(s1)
    80002830:	00005517          	auipc	a0,0x5
    80002834:	a6050513          	addi	a0,a0,-1440 # 80007290 <etext+0x290>
    80002838:	cc3fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000283c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002840:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002844:	00005517          	auipc	a0,0x5
    80002848:	a7c50513          	addi	a0,a0,-1412 # 800072c0 <etext+0x2c0>
    8000284c:	caffd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002850:	8526                	mv	a0,s1
    80002852:	a97ff0ef          	jal	800022e8 <setkilled>
    80002856:	a035                	j	80002882 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002858:	00005517          	auipc	a0,0x5
    8000285c:	a1850513          	addi	a0,a0,-1512 # 80007270 <etext+0x270>
    80002860:	f81fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002864:	aa9ff0ef          	jal	8000230c <killed>
    80002868:	ed15                	bnez	a0,800028a4 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000286a:	6cb8                	ld	a4,88(s1)
    8000286c:	6f1c                	ld	a5,24(a4)
    8000286e:	0791                	addi	a5,a5,4
    80002870:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002872:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002876:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000287a:	10079073          	csrw	sstatus,a5
    syscall();
    8000287e:	246000ef          	jal	80002ac4 <syscall>
  if(killed(p))
    80002882:	8526                	mv	a0,s1
    80002884:	a89ff0ef          	jal	8000230c <killed>
    80002888:	e139                	bnez	a0,800028ce <usertrap+0xfa>
  prepare_return();
    8000288a:	e09ff0ef          	jal	80002692 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000288e:	68a8                	ld	a0,80(s1)
    80002890:	8131                	srli	a0,a0,0xc
    80002892:	57fd                	li	a5,-1
    80002894:	17fe                	slli	a5,a5,0x3f
    80002896:	8d5d                	or	a0,a0,a5
}
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6902                	ld	s2,0(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret
      kexit(-1);
    800028a4:	557d                	li	a0,-1
    800028a6:	93bff0ef          	jal	800021e0 <kexit>
    800028aa:	b7c1                	j	8000286a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ac:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b0:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800028b4:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800028b6:	00163613          	seqz	a2,a2
    800028ba:	68a8                	ld	a0,80(s1)
    800028bc:	ca5fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800028c0:	f169                	bnez	a0,80002882 <usertrap+0xae>
    800028c2:	b7a5                	j	8000282a <usertrap+0x56>
  if(killed(p))
    800028c4:	8526                	mv	a0,s1
    800028c6:	a47ff0ef          	jal	8000230c <killed>
    800028ca:	c511                	beqz	a0,800028d6 <usertrap+0x102>
    800028cc:	a011                	j	800028d0 <usertrap+0xfc>
    800028ce:	4901                	li	s2,0
    kexit(-1);
    800028d0:	557d                	li	a0,-1
    800028d2:	90fff0ef          	jal	800021e0 <kexit>
  if(which_dev == 2)
    800028d6:	4789                	li	a5,2
    800028d8:	faf919e3          	bne	s2,a5,8000288a <usertrap+0xb6>
    yield();
    800028dc:	fccff0ef          	jal	800020a8 <yield>
    800028e0:	b76d                	j	8000288a <usertrap+0xb6>

00000000800028e2 <kerneltrap>:
{
    800028e2:	7179                	addi	sp,sp,-48
    800028e4:	f406                	sd	ra,40(sp)
    800028e6:	f022                	sd	s0,32(sp)
    800028e8:	ec26                	sd	s1,24(sp)
    800028ea:	e84a                	sd	s2,16(sp)
    800028ec:	e44e                	sd	s3,8(sp)
    800028ee:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028f0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028fc:	1004f793          	andi	a5,s1,256
    80002900:	c795                	beqz	a5,8000292c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002906:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002908:	eb85                	bnez	a5,80002938 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000290a:	e57ff0ef          	jal	80002760 <devintr>
    8000290e:	c91d                	beqz	a0,80002944 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002910:	4789                	li	a5,2
    80002912:	04f50a63          	beq	a0,a5,80002966 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002916:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000291a:	10049073          	csrw	sstatus,s1
}
    8000291e:	70a2                	ld	ra,40(sp)
    80002920:	7402                	ld	s0,32(sp)
    80002922:	64e2                	ld	s1,24(sp)
    80002924:	6942                	ld	s2,16(sp)
    80002926:	69a2                	ld	s3,8(sp)
    80002928:	6145                	addi	sp,sp,48
    8000292a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000292c:	00005517          	auipc	a0,0x5
    80002930:	9bc50513          	addi	a0,a0,-1604 # 800072e8 <etext+0x2e8>
    80002934:	eadfd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002938:	00005517          	auipc	a0,0x5
    8000293c:	9d850513          	addi	a0,a0,-1576 # 80007310 <etext+0x310>
    80002940:	ea1fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002944:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002948:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000294c:	85ce                	mv	a1,s3
    8000294e:	00005517          	auipc	a0,0x5
    80002952:	9e250513          	addi	a0,a0,-1566 # 80007330 <etext+0x330>
    80002956:	ba5fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    8000295a:	00005517          	auipc	a0,0x5
    8000295e:	9fe50513          	addi	a0,a0,-1538 # 80007358 <etext+0x358>
    80002962:	e7ffd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002966:	964ff0ef          	jal	80001aca <myproc>
    8000296a:	d555                	beqz	a0,80002916 <kerneltrap+0x34>
    yield();
    8000296c:	f3cff0ef          	jal	800020a8 <yield>
    80002970:	b75d                	j	80002916 <kerneltrap+0x34>

0000000080002972 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002972:	1101                	addi	sp,sp,-32
    80002974:	ec06                	sd	ra,24(sp)
    80002976:	e822                	sd	s0,16(sp)
    80002978:	e426                	sd	s1,8(sp)
    8000297a:	1000                	addi	s0,sp,32
    8000297c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000297e:	94cff0ef          	jal	80001aca <myproc>
  switch (n) {
    80002982:	4795                	li	a5,5
    80002984:	0497e163          	bltu	a5,s1,800029c6 <argraw+0x54>
    80002988:	048a                	slli	s1,s1,0x2
    8000298a:	00005717          	auipc	a4,0x5
    8000298e:	dce70713          	addi	a4,a4,-562 # 80007758 <states.0+0x30>
    80002992:	94ba                	add	s1,s1,a4
    80002994:	409c                	lw	a5,0(s1)
    80002996:	97ba                	add	a5,a5,a4
    80002998:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000299a:	6d3c                	ld	a5,88(a0)
    8000299c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000299e:	60e2                	ld	ra,24(sp)
    800029a0:	6442                	ld	s0,16(sp)
    800029a2:	64a2                	ld	s1,8(sp)
    800029a4:	6105                	addi	sp,sp,32
    800029a6:	8082                	ret
    return p->trapframe->a1;
    800029a8:	6d3c                	ld	a5,88(a0)
    800029aa:	7fa8                	ld	a0,120(a5)
    800029ac:	bfcd                	j	8000299e <argraw+0x2c>
    return p->trapframe->a2;
    800029ae:	6d3c                	ld	a5,88(a0)
    800029b0:	63c8                	ld	a0,128(a5)
    800029b2:	b7f5                	j	8000299e <argraw+0x2c>
    return p->trapframe->a3;
    800029b4:	6d3c                	ld	a5,88(a0)
    800029b6:	67c8                	ld	a0,136(a5)
    800029b8:	b7dd                	j	8000299e <argraw+0x2c>
    return p->trapframe->a4;
    800029ba:	6d3c                	ld	a5,88(a0)
    800029bc:	6bc8                	ld	a0,144(a5)
    800029be:	b7c5                	j	8000299e <argraw+0x2c>
    return p->trapframe->a5;
    800029c0:	6d3c                	ld	a5,88(a0)
    800029c2:	6fc8                	ld	a0,152(a5)
    800029c4:	bfe9                	j	8000299e <argraw+0x2c>
  panic("argraw");
    800029c6:	00005517          	auipc	a0,0x5
    800029ca:	9a250513          	addi	a0,a0,-1630 # 80007368 <etext+0x368>
    800029ce:	e13fd0ef          	jal	800007e0 <panic>

00000000800029d2 <fetchaddr>:
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	e426                	sd	s1,8(sp)
    800029da:	e04a                	sd	s2,0(sp)
    800029dc:	1000                	addi	s0,sp,32
    800029de:	84aa                	mv	s1,a0
    800029e0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029e2:	8e8ff0ef          	jal	80001aca <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029e6:	653c                	ld	a5,72(a0)
    800029e8:	02f4f663          	bgeu	s1,a5,80002a14 <fetchaddr+0x42>
    800029ec:	00848713          	addi	a4,s1,8
    800029f0:	02e7e463          	bltu	a5,a4,80002a18 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029f4:	46a1                	li	a3,8
    800029f6:	8626                	mv	a2,s1
    800029f8:	85ca                	mv	a1,s2
    800029fa:	6928                	ld	a0,80(a0)
    800029fc:	ccbfe0ef          	jal	800016c6 <copyin>
    80002a00:	00a03533          	snez	a0,a0
    80002a04:	40a00533          	neg	a0,a0
}
    80002a08:	60e2                	ld	ra,24(sp)
    80002a0a:	6442                	ld	s0,16(sp)
    80002a0c:	64a2                	ld	s1,8(sp)
    80002a0e:	6902                	ld	s2,0(sp)
    80002a10:	6105                	addi	sp,sp,32
    80002a12:	8082                	ret
    return -1;
    80002a14:	557d                	li	a0,-1
    80002a16:	bfcd                	j	80002a08 <fetchaddr+0x36>
    80002a18:	557d                	li	a0,-1
    80002a1a:	b7fd                	j	80002a08 <fetchaddr+0x36>

0000000080002a1c <fetchstr>:
{
    80002a1c:	7179                	addi	sp,sp,-48
    80002a1e:	f406                	sd	ra,40(sp)
    80002a20:	f022                	sd	s0,32(sp)
    80002a22:	ec26                	sd	s1,24(sp)
    80002a24:	e84a                	sd	s2,16(sp)
    80002a26:	e44e                	sd	s3,8(sp)
    80002a28:	1800                	addi	s0,sp,48
    80002a2a:	892a                	mv	s2,a0
    80002a2c:	84ae                	mv	s1,a1
    80002a2e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a30:	89aff0ef          	jal	80001aca <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a34:	86ce                	mv	a3,s3
    80002a36:	864a                	mv	a2,s2
    80002a38:	85a6                	mv	a1,s1
    80002a3a:	6928                	ld	a0,80(a0)
    80002a3c:	a4dfe0ef          	jal	80001488 <copyinstr>
    80002a40:	00054c63          	bltz	a0,80002a58 <fetchstr+0x3c>
  return strlen(buf);
    80002a44:	8526                	mv	a0,s1
    80002a46:	bccfe0ef          	jal	80000e12 <strlen>
}
    80002a4a:	70a2                	ld	ra,40(sp)
    80002a4c:	7402                	ld	s0,32(sp)
    80002a4e:	64e2                	ld	s1,24(sp)
    80002a50:	6942                	ld	s2,16(sp)
    80002a52:	69a2                	ld	s3,8(sp)
    80002a54:	6145                	addi	sp,sp,48
    80002a56:	8082                	ret
    return -1;
    80002a58:	557d                	li	a0,-1
    80002a5a:	bfc5                	j	80002a4a <fetchstr+0x2e>

0000000080002a5c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	e426                	sd	s1,8(sp)
    80002a64:	1000                	addi	s0,sp,32
    80002a66:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a68:	f0bff0ef          	jal	80002972 <argraw>
    80002a6c:	c088                	sw	a0,0(s1)
}
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6105                	addi	sp,sp,32
    80002a76:	8082                	ret

0000000080002a78 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
    80002a82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a84:	eefff0ef          	jal	80002972 <argraw>
    80002a88:	e088                	sd	a0,0(s1)
}
    80002a8a:	60e2                	ld	ra,24(sp)
    80002a8c:	6442                	ld	s0,16(sp)
    80002a8e:	64a2                	ld	s1,8(sp)
    80002a90:	6105                	addi	sp,sp,32
    80002a92:	8082                	ret

0000000080002a94 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a94:	7179                	addi	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	e84a                	sd	s2,16(sp)
    80002a9e:	1800                	addi	s0,sp,48
    80002aa0:	84ae                	mv	s1,a1
    80002aa2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002aa4:	fd840593          	addi	a1,s0,-40
    80002aa8:	fd1ff0ef          	jal	80002a78 <argaddr>
  return fetchstr(addr, buf, max);
    80002aac:	864a                	mv	a2,s2
    80002aae:	85a6                	mv	a1,s1
    80002ab0:	fd843503          	ld	a0,-40(s0)
    80002ab4:	f69ff0ef          	jal	80002a1c <fetchstr>
}
    80002ab8:	70a2                	ld	ra,40(sp)
    80002aba:	7402                	ld	s0,32(sp)
    80002abc:	64e2                	ld	s1,24(sp)
    80002abe:	6942                	ld	s2,16(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret

0000000080002ac4 <syscall>:

uint sysclcnt = 0;

void
syscall(void)
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ad0:	ffbfe0ef          	jal	80001aca <myproc>
    80002ad4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ad6:	05853903          	ld	s2,88(a0)
    80002ada:	0a893783          	ld	a5,168(s2)
    80002ade:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ae2:	37fd                	addiw	a5,a5,-1
    80002ae4:	4759                	li	a4,22
    80002ae6:	02f76663          	bltu	a4,a5,80002b12 <syscall+0x4e>
    80002aea:	00369713          	slli	a4,a3,0x3
    80002aee:	00005797          	auipc	a5,0x5
    80002af2:	c8278793          	addi	a5,a5,-894 # 80007770 <syscalls>
    80002af6:	97ba                	add	a5,a5,a4
    80002af8:	6398                	ld	a4,0(a5)
    80002afa:	cf01                	beqz	a4,80002b12 <syscall+0x4e>
    sysclcnt++;
    80002afc:	00005697          	auipc	a3,0x5
    80002b00:	d7068693          	addi	a3,a3,-656 # 8000786c <sysclcnt>
    80002b04:	429c                	lw	a5,0(a3)
    80002b06:	2785                	addiw	a5,a5,1
    80002b08:	c29c                	sw	a5,0(a3)
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b0a:	9702                	jalr	a4
    80002b0c:	06a93823          	sd	a0,112(s2)
    80002b10:	a829                	j	80002b2a <syscall+0x66>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b12:	15848613          	addi	a2,s1,344
    80002b16:	588c                	lw	a1,48(s1)
    80002b18:	00005517          	auipc	a0,0x5
    80002b1c:	85850513          	addi	a0,a0,-1960 # 80007370 <etext+0x370>
    80002b20:	9dbfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b24:	6cbc                	ld	a5,88(s1)
    80002b26:	577d                	li	a4,-1
    80002b28:	fbb8                	sd	a4,112(a5)
  }
}
    80002b2a:	60e2                	ld	ra,24(sp)
    80002b2c:	6442                	ld	s0,16(sp)
    80002b2e:	64a2                	ld	s1,8(sp)
    80002b30:	6902                	ld	s2,0(sp)
    80002b32:	6105                	addi	sp,sp,32
    80002b34:	8082                	ret

0000000080002b36 <sys_exit>:
extern int ptree(int pid, uint64 dst, int bufsize);


uint64
sys_exit(void)
{
    80002b36:	1101                	addi	sp,sp,-32
    80002b38:	ec06                	sd	ra,24(sp)
    80002b3a:	e822                	sd	s0,16(sp)
    80002b3c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b3e:	fec40593          	addi	a1,s0,-20
    80002b42:	4501                	li	a0,0
    80002b44:	f19ff0ef          	jal	80002a5c <argint>
  kexit(n);
    80002b48:	fec42503          	lw	a0,-20(s0)
    80002b4c:	e94ff0ef          	jal	800021e0 <kexit>
  return 0;  // not reached
}
    80002b50:	4501                	li	a0,0
    80002b52:	60e2                	ld	ra,24(sp)
    80002b54:	6442                	ld	s0,16(sp)
    80002b56:	6105                	addi	sp,sp,32
    80002b58:	8082                	ret

0000000080002b5a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b5a:	1141                	addi	sp,sp,-16
    80002b5c:	e406                	sd	ra,8(sp)
    80002b5e:	e022                	sd	s0,0(sp)
    80002b60:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b62:	f69fe0ef          	jal	80001aca <myproc>
}
    80002b66:	5908                	lw	a0,48(a0)
    80002b68:	60a2                	ld	ra,8(sp)
    80002b6a:	6402                	ld	s0,0(sp)
    80002b6c:	0141                	addi	sp,sp,16
    80002b6e:	8082                	ret

0000000080002b70 <sys_fork>:

uint64
sys_fork(void)
{
    80002b70:	1141                	addi	sp,sp,-16
    80002b72:	e406                	sd	ra,8(sp)
    80002b74:	e022                	sd	s0,0(sp)
    80002b76:	0800                	addi	s0,sp,16
  return kfork();
    80002b78:	ab6ff0ef          	jal	80001e2e <kfork>
}
    80002b7c:	60a2                	ld	ra,8(sp)
    80002b7e:	6402                	ld	s0,0(sp)
    80002b80:	0141                	addi	sp,sp,16
    80002b82:	8082                	ret

0000000080002b84 <sys_wait>:

uint64
sys_wait(void)
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b8c:	fe840593          	addi	a1,s0,-24
    80002b90:	4501                	li	a0,0
    80002b92:	ee7ff0ef          	jal	80002a78 <argaddr>
  return kwait(p);
    80002b96:	fe843503          	ld	a0,-24(s0)
    80002b9a:	f9cff0ef          	jal	80002336 <kwait>
}
    80002b9e:	60e2                	ld	ra,24(sp)
    80002ba0:	6442                	ld	s0,16(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret

0000000080002ba6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ba6:	7179                	addi	sp,sp,-48
    80002ba8:	f406                	sd	ra,40(sp)
    80002baa:	f022                	sd	s0,32(sp)
    80002bac:	ec26                	sd	s1,24(sp)
    80002bae:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bb0:	fd840593          	addi	a1,s0,-40
    80002bb4:	4501                	li	a0,0
    80002bb6:	ea7ff0ef          	jal	80002a5c <argint>
  argint(1, &t);
    80002bba:	fdc40593          	addi	a1,s0,-36
    80002bbe:	4505                	li	a0,1
    80002bc0:	e9dff0ef          	jal	80002a5c <argint>
  addr = myproc()->sz;
    80002bc4:	f07fe0ef          	jal	80001aca <myproc>
    80002bc8:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bca:	fdc42703          	lw	a4,-36(s0)
    80002bce:	4785                	li	a5,1
    80002bd0:	02f70763          	beq	a4,a5,80002bfe <sys_sbrk+0x58>
    80002bd4:	fd842783          	lw	a5,-40(s0)
    80002bd8:	0207c363          	bltz	a5,80002bfe <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bdc:	97a6                	add	a5,a5,s1
    80002bde:	0297ee63          	bltu	a5,s1,80002c1a <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002be2:	02000737          	lui	a4,0x2000
    80002be6:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002be8:	0736                	slli	a4,a4,0xd
    80002bea:	02f76a63          	bltu	a4,a5,80002c1e <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002bee:	eddfe0ef          	jal	80001aca <myproc>
    80002bf2:	fd842703          	lw	a4,-40(s0)
    80002bf6:	653c                	ld	a5,72(a0)
    80002bf8:	97ba                	add	a5,a5,a4
    80002bfa:	e53c                	sd	a5,72(a0)
    80002bfc:	a039                	j	80002c0a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002bfe:	fd842503          	lw	a0,-40(s0)
    80002c02:	9caff0ef          	jal	80001dcc <growproc>
    80002c06:	00054863          	bltz	a0,80002c16 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	70a2                	ld	ra,40(sp)
    80002c0e:	7402                	ld	s0,32(sp)
    80002c10:	64e2                	ld	s1,24(sp)
    80002c12:	6145                	addi	sp,sp,48
    80002c14:	8082                	ret
      return -1;
    80002c16:	54fd                	li	s1,-1
    80002c18:	bfcd                	j	80002c0a <sys_sbrk+0x64>
      return -1;
    80002c1a:	54fd                	li	s1,-1
    80002c1c:	b7fd                	j	80002c0a <sys_sbrk+0x64>
      return -1;
    80002c1e:	54fd                	li	s1,-1
    80002c20:	b7ed                	j	80002c0a <sys_sbrk+0x64>

0000000080002c22 <sys_pause>:

uint64
sys_pause(void)
{
    80002c22:	7139                	addi	sp,sp,-64
    80002c24:	fc06                	sd	ra,56(sp)
    80002c26:	f822                	sd	s0,48(sp)
    80002c28:	f04a                	sd	s2,32(sp)
    80002c2a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c2c:	fcc40593          	addi	a1,s0,-52
    80002c30:	4501                	li	a0,0
    80002c32:	e2bff0ef          	jal	80002a5c <argint>
  if(n < 0)
    80002c36:	fcc42783          	lw	a5,-52(s0)
    80002c3a:	0607c763          	bltz	a5,80002ca8 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c3e:	00013517          	auipc	a0,0x13
    80002c42:	b5a50513          	addi	a0,a0,-1190 # 80015798 <tickslock>
    80002c46:	f89fd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002c4a:	00005917          	auipc	s2,0x5
    80002c4e:	c1e92903          	lw	s2,-994(s2) # 80007868 <ticks>
  while(ticks - ticks0 < n){
    80002c52:	fcc42783          	lw	a5,-52(s0)
    80002c56:	cf8d                	beqz	a5,80002c90 <sys_pause+0x6e>
    80002c58:	f426                	sd	s1,40(sp)
    80002c5a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c5c:	00013997          	auipc	s3,0x13
    80002c60:	b3c98993          	addi	s3,s3,-1220 # 80015798 <tickslock>
    80002c64:	00005497          	auipc	s1,0x5
    80002c68:	c0448493          	addi	s1,s1,-1020 # 80007868 <ticks>
    if(killed(myproc())){
    80002c6c:	e5ffe0ef          	jal	80001aca <myproc>
    80002c70:	e9cff0ef          	jal	8000230c <killed>
    80002c74:	ed0d                	bnez	a0,80002cae <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c76:	85ce                	mv	a1,s3
    80002c78:	8526                	mv	a0,s1
    80002c7a:	c5aff0ef          	jal	800020d4 <sleep>
  while(ticks - ticks0 < n){
    80002c7e:	409c                	lw	a5,0(s1)
    80002c80:	412787bb          	subw	a5,a5,s2
    80002c84:	fcc42703          	lw	a4,-52(s0)
    80002c88:	fee7e2e3          	bltu	a5,a4,80002c6c <sys_pause+0x4a>
    80002c8c:	74a2                	ld	s1,40(sp)
    80002c8e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c90:	00013517          	auipc	a0,0x13
    80002c94:	b0850513          	addi	a0,a0,-1272 # 80015798 <tickslock>
    80002c98:	fcffd0ef          	jal	80000c66 <release>
  return 0;
    80002c9c:	4501                	li	a0,0
}
    80002c9e:	70e2                	ld	ra,56(sp)
    80002ca0:	7442                	ld	s0,48(sp)
    80002ca2:	7902                	ld	s2,32(sp)
    80002ca4:	6121                	addi	sp,sp,64
    80002ca6:	8082                	ret
    n = 0;
    80002ca8:	fc042623          	sw	zero,-52(s0)
    80002cac:	bf49                	j	80002c3e <sys_pause+0x1c>
      release(&tickslock);
    80002cae:	00013517          	auipc	a0,0x13
    80002cb2:	aea50513          	addi	a0,a0,-1302 # 80015798 <tickslock>
    80002cb6:	fb1fd0ef          	jal	80000c66 <release>
      return -1;
    80002cba:	557d                	li	a0,-1
    80002cbc:	74a2                	ld	s1,40(sp)
    80002cbe:	69e2                	ld	s3,24(sp)
    80002cc0:	bff9                	j	80002c9e <sys_pause+0x7c>

0000000080002cc2 <sys_kill>:

uint64
sys_kill(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cca:	fec40593          	addi	a1,s0,-20
    80002cce:	4501                	li	a0,0
    80002cd0:	d8dff0ef          	jal	80002a5c <argint>
  return kkill(pid);
    80002cd4:	fec42503          	lw	a0,-20(s0)
    80002cd8:	daaff0ef          	jal	80002282 <kkill>
}
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ce4:	1101                	addi	sp,sp,-32
    80002ce6:	ec06                	sd	ra,24(sp)
    80002ce8:	e822                	sd	s0,16(sp)
    80002cea:	e426                	sd	s1,8(sp)
    80002cec:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cee:	00013517          	auipc	a0,0x13
    80002cf2:	aaa50513          	addi	a0,a0,-1366 # 80015798 <tickslock>
    80002cf6:	ed9fd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002cfa:	00005497          	auipc	s1,0x5
    80002cfe:	b6e4a483          	lw	s1,-1170(s1) # 80007868 <ticks>
  release(&tickslock);
    80002d02:	00013517          	auipc	a0,0x13
    80002d06:	a9650513          	addi	a0,a0,-1386 # 80015798 <tickslock>
    80002d0a:	f5dfd0ef          	jal	80000c66 <release>
  return xticks;
}
    80002d0e:	02049513          	slli	a0,s1,0x20
    80002d12:	9101                	srli	a0,a0,0x20
    80002d14:	60e2                	ld	ra,24(sp)
    80002d16:	6442                	ld	s0,16(sp)
    80002d18:	64a2                	ld	s1,8(sp)
    80002d1a:	6105                	addi	sp,sp,32
    80002d1c:	8082                	ret

0000000080002d1e <sys_clcnt>:

uint64
sys_clcnt(void)
{
    80002d1e:	1141                	addi	sp,sp,-16
    80002d20:	e422                	sd	s0,8(sp)
    80002d22:	0800                	addi	s0,sp,16
  extern uint sysclcnt;
  return sysclcnt;
}
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	b4856503          	lwu	a0,-1208(a0) # 8000786c <sysclcnt>
    80002d2c:	6422                	ld	s0,8(sp)
    80002d2e:	0141                	addi	sp,sp,16
    80002d30:	8082                	ret

0000000080002d32 <sys_ptree>:

uint64
sys_ptree(void)
{
    80002d32:	7179                	addi	sp,sp,-48
    80002d34:	f406                	sd	ra,40(sp)
    80002d36:	f022                	sd	s0,32(sp)
    80002d38:	1800                	addi	s0,sp,48
  int pid;
  uint64 user_dst;
  int bufsize;

  argint(0, &pid);
    80002d3a:	fec40593          	addi	a1,s0,-20
    80002d3e:	4501                	li	a0,0
    80002d40:	d1dff0ef          	jal	80002a5c <argint>
  argaddr(1, &user_dst);
    80002d44:	fe040593          	addi	a1,s0,-32
    80002d48:	4505                	li	a0,1
    80002d4a:	d2fff0ef          	jal	80002a78 <argaddr>
  argint(2, &bufsize);
    80002d4e:	fdc40593          	addi	a1,s0,-36
    80002d52:	4509                	li	a0,2
    80002d54:	d09ff0ef          	jal	80002a5c <argint>

  return ptree(pid, user_dst, bufsize);
    80002d58:	fdc42603          	lw	a2,-36(s0)
    80002d5c:	fe043583          	ld	a1,-32(s0)
    80002d60:	fec42503          	lw	a0,-20(s0)
    80002d64:	805ff0ef          	jal	80002568 <ptree>
    80002d68:	70a2                	ld	ra,40(sp)
    80002d6a:	7402                	ld	s0,32(sp)
    80002d6c:	6145                	addi	sp,sp,48
    80002d6e:	8082                	ret

0000000080002d70 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d70:	7179                	addi	sp,sp,-48
    80002d72:	f406                	sd	ra,40(sp)
    80002d74:	f022                	sd	s0,32(sp)
    80002d76:	ec26                	sd	s1,24(sp)
    80002d78:	e84a                	sd	s2,16(sp)
    80002d7a:	e44e                	sd	s3,8(sp)
    80002d7c:	e052                	sd	s4,0(sp)
    80002d7e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d80:	00004597          	auipc	a1,0x4
    80002d84:	61058593          	addi	a1,a1,1552 # 80007390 <etext+0x390>
    80002d88:	00013517          	auipc	a0,0x13
    80002d8c:	a2850513          	addi	a0,a0,-1496 # 800157b0 <bcache>
    80002d90:	dbffd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d94:	0001b797          	auipc	a5,0x1b
    80002d98:	a1c78793          	addi	a5,a5,-1508 # 8001d7b0 <bcache+0x8000>
    80002d9c:	0001b717          	auipc	a4,0x1b
    80002da0:	c7c70713          	addi	a4,a4,-900 # 8001da18 <bcache+0x8268>
    80002da4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002da8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dac:	00013497          	auipc	s1,0x13
    80002db0:	a1c48493          	addi	s1,s1,-1508 # 800157c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002db4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002db6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002db8:	00004a17          	auipc	s4,0x4
    80002dbc:	5e0a0a13          	addi	s4,s4,1504 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002dc0:	2b893783          	ld	a5,696(s2)
    80002dc4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dc6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dca:	85d2                	mv	a1,s4
    80002dcc:	01048513          	addi	a0,s1,16
    80002dd0:	322010ef          	jal	800040f2 <initsleeplock>
    bcache.head.next->prev = b;
    80002dd4:	2b893783          	ld	a5,696(s2)
    80002dd8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dda:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dde:	45848493          	addi	s1,s1,1112
    80002de2:	fd349fe3          	bne	s1,s3,80002dc0 <binit+0x50>
  }
}
    80002de6:	70a2                	ld	ra,40(sp)
    80002de8:	7402                	ld	s0,32(sp)
    80002dea:	64e2                	ld	s1,24(sp)
    80002dec:	6942                	ld	s2,16(sp)
    80002dee:	69a2                	ld	s3,8(sp)
    80002df0:	6a02                	ld	s4,0(sp)
    80002df2:	6145                	addi	sp,sp,48
    80002df4:	8082                	ret

0000000080002df6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002df6:	7179                	addi	sp,sp,-48
    80002df8:	f406                	sd	ra,40(sp)
    80002dfa:	f022                	sd	s0,32(sp)
    80002dfc:	ec26                	sd	s1,24(sp)
    80002dfe:	e84a                	sd	s2,16(sp)
    80002e00:	e44e                	sd	s3,8(sp)
    80002e02:	1800                	addi	s0,sp,48
    80002e04:	892a                	mv	s2,a0
    80002e06:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e08:	00013517          	auipc	a0,0x13
    80002e0c:	9a850513          	addi	a0,a0,-1624 # 800157b0 <bcache>
    80002e10:	dbffd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e14:	0001b497          	auipc	s1,0x1b
    80002e18:	c544b483          	ld	s1,-940(s1) # 8001da68 <bcache+0x82b8>
    80002e1c:	0001b797          	auipc	a5,0x1b
    80002e20:	bfc78793          	addi	a5,a5,-1028 # 8001da18 <bcache+0x8268>
    80002e24:	02f48b63          	beq	s1,a5,80002e5a <bread+0x64>
    80002e28:	873e                	mv	a4,a5
    80002e2a:	a021                	j	80002e32 <bread+0x3c>
    80002e2c:	68a4                	ld	s1,80(s1)
    80002e2e:	02e48663          	beq	s1,a4,80002e5a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e32:	449c                	lw	a5,8(s1)
    80002e34:	ff279ce3          	bne	a5,s2,80002e2c <bread+0x36>
    80002e38:	44dc                	lw	a5,12(s1)
    80002e3a:	ff3799e3          	bne	a5,s3,80002e2c <bread+0x36>
      b->refcnt++;
    80002e3e:	40bc                	lw	a5,64(s1)
    80002e40:	2785                	addiw	a5,a5,1
    80002e42:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e44:	00013517          	auipc	a0,0x13
    80002e48:	96c50513          	addi	a0,a0,-1684 # 800157b0 <bcache>
    80002e4c:	e1bfd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e50:	01048513          	addi	a0,s1,16
    80002e54:	2d4010ef          	jal	80004128 <acquiresleep>
      return b;
    80002e58:	a889                	j	80002eaa <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e5a:	0001b497          	auipc	s1,0x1b
    80002e5e:	c064b483          	ld	s1,-1018(s1) # 8001da60 <bcache+0x82b0>
    80002e62:	0001b797          	auipc	a5,0x1b
    80002e66:	bb678793          	addi	a5,a5,-1098 # 8001da18 <bcache+0x8268>
    80002e6a:	00f48863          	beq	s1,a5,80002e7a <bread+0x84>
    80002e6e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e70:	40bc                	lw	a5,64(s1)
    80002e72:	cb91                	beqz	a5,80002e86 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e74:	64a4                	ld	s1,72(s1)
    80002e76:	fee49de3          	bne	s1,a4,80002e70 <bread+0x7a>
  panic("bget: no buffers");
    80002e7a:	00004517          	auipc	a0,0x4
    80002e7e:	52650513          	addi	a0,a0,1318 # 800073a0 <etext+0x3a0>
    80002e82:	95ffd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002e86:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e8a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e8e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e92:	4785                	li	a5,1
    80002e94:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e96:	00013517          	auipc	a0,0x13
    80002e9a:	91a50513          	addi	a0,a0,-1766 # 800157b0 <bcache>
    80002e9e:	dc9fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002ea2:	01048513          	addi	a0,s1,16
    80002ea6:	282010ef          	jal	80004128 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002eaa:	409c                	lw	a5,0(s1)
    80002eac:	cb89                	beqz	a5,80002ebe <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002eae:	8526                	mv	a0,s1
    80002eb0:	70a2                	ld	ra,40(sp)
    80002eb2:	7402                	ld	s0,32(sp)
    80002eb4:	64e2                	ld	s1,24(sp)
    80002eb6:	6942                	ld	s2,16(sp)
    80002eb8:	69a2                	ld	s3,8(sp)
    80002eba:	6145                	addi	sp,sp,48
    80002ebc:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ebe:	4581                	li	a1,0
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	2cf020ef          	jal	80005990 <virtio_disk_rw>
    b->valid = 1;
    80002ec6:	4785                	li	a5,1
    80002ec8:	c09c                	sw	a5,0(s1)
  return b;
    80002eca:	b7d5                	j	80002eae <bread+0xb8>

0000000080002ecc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	e426                	sd	s1,8(sp)
    80002ed4:	1000                	addi	s0,sp,32
    80002ed6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ed8:	0541                	addi	a0,a0,16
    80002eda:	2cc010ef          	jal	800041a6 <holdingsleep>
    80002ede:	c911                	beqz	a0,80002ef2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002ee0:	4585                	li	a1,1
    80002ee2:	8526                	mv	a0,s1
    80002ee4:	2ad020ef          	jal	80005990 <virtio_disk_rw>
}
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	64a2                	ld	s1,8(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret
    panic("bwrite");
    80002ef2:	00004517          	auipc	a0,0x4
    80002ef6:	4c650513          	addi	a0,a0,1222 # 800073b8 <etext+0x3b8>
    80002efa:	8e7fd0ef          	jal	800007e0 <panic>

0000000080002efe <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002efe:	1101                	addi	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	e426                	sd	s1,8(sp)
    80002f06:	e04a                	sd	s2,0(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f0c:	01050913          	addi	s2,a0,16
    80002f10:	854a                	mv	a0,s2
    80002f12:	294010ef          	jal	800041a6 <holdingsleep>
    80002f16:	c135                	beqz	a0,80002f7a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f18:	854a                	mv	a0,s2
    80002f1a:	254010ef          	jal	8000416e <releasesleep>

  acquire(&bcache.lock);
    80002f1e:	00013517          	auipc	a0,0x13
    80002f22:	89250513          	addi	a0,a0,-1902 # 800157b0 <bcache>
    80002f26:	ca9fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f2a:	40bc                	lw	a5,64(s1)
    80002f2c:	37fd                	addiw	a5,a5,-1
    80002f2e:	0007871b          	sext.w	a4,a5
    80002f32:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f34:	e71d                	bnez	a4,80002f62 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f36:	68b8                	ld	a4,80(s1)
    80002f38:	64bc                	ld	a5,72(s1)
    80002f3a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f3c:	68b8                	ld	a4,80(s1)
    80002f3e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f40:	0001b797          	auipc	a5,0x1b
    80002f44:	87078793          	addi	a5,a5,-1936 # 8001d7b0 <bcache+0x8000>
    80002f48:	2b87b703          	ld	a4,696(a5)
    80002f4c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f4e:	0001b717          	auipc	a4,0x1b
    80002f52:	aca70713          	addi	a4,a4,-1334 # 8001da18 <bcache+0x8268>
    80002f56:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f58:	2b87b703          	ld	a4,696(a5)
    80002f5c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f5e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f62:	00013517          	auipc	a0,0x13
    80002f66:	84e50513          	addi	a0,a0,-1970 # 800157b0 <bcache>
    80002f6a:	cfdfd0ef          	jal	80000c66 <release>
}
    80002f6e:	60e2                	ld	ra,24(sp)
    80002f70:	6442                	ld	s0,16(sp)
    80002f72:	64a2                	ld	s1,8(sp)
    80002f74:	6902                	ld	s2,0(sp)
    80002f76:	6105                	addi	sp,sp,32
    80002f78:	8082                	ret
    panic("brelse");
    80002f7a:	00004517          	auipc	a0,0x4
    80002f7e:	44650513          	addi	a0,a0,1094 # 800073c0 <etext+0x3c0>
    80002f82:	85ffd0ef          	jal	800007e0 <panic>

0000000080002f86 <bpin>:

void
bpin(struct buf *b) {
    80002f86:	1101                	addi	sp,sp,-32
    80002f88:	ec06                	sd	ra,24(sp)
    80002f8a:	e822                	sd	s0,16(sp)
    80002f8c:	e426                	sd	s1,8(sp)
    80002f8e:	1000                	addi	s0,sp,32
    80002f90:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f92:	00013517          	auipc	a0,0x13
    80002f96:	81e50513          	addi	a0,a0,-2018 # 800157b0 <bcache>
    80002f9a:	c35fd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002f9e:	40bc                	lw	a5,64(s1)
    80002fa0:	2785                	addiw	a5,a5,1
    80002fa2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fa4:	00013517          	auipc	a0,0x13
    80002fa8:	80c50513          	addi	a0,a0,-2036 # 800157b0 <bcache>
    80002fac:	cbbfd0ef          	jal	80000c66 <release>
}
    80002fb0:	60e2                	ld	ra,24(sp)
    80002fb2:	6442                	ld	s0,16(sp)
    80002fb4:	64a2                	ld	s1,8(sp)
    80002fb6:	6105                	addi	sp,sp,32
    80002fb8:	8082                	ret

0000000080002fba <bunpin>:

void
bunpin(struct buf *b) {
    80002fba:	1101                	addi	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	e426                	sd	s1,8(sp)
    80002fc2:	1000                	addi	s0,sp,32
    80002fc4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fc6:	00012517          	auipc	a0,0x12
    80002fca:	7ea50513          	addi	a0,a0,2026 # 800157b0 <bcache>
    80002fce:	c01fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002fd2:	40bc                	lw	a5,64(s1)
    80002fd4:	37fd                	addiw	a5,a5,-1
    80002fd6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fd8:	00012517          	auipc	a0,0x12
    80002fdc:	7d850513          	addi	a0,a0,2008 # 800157b0 <bcache>
    80002fe0:	c87fd0ef          	jal	80000c66 <release>
}
    80002fe4:	60e2                	ld	ra,24(sp)
    80002fe6:	6442                	ld	s0,16(sp)
    80002fe8:	64a2                	ld	s1,8(sp)
    80002fea:	6105                	addi	sp,sp,32
    80002fec:	8082                	ret

0000000080002fee <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	e04a                	sd	s2,0(sp)
    80002ff8:	1000                	addi	s0,sp,32
    80002ffa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ffc:	00d5d59b          	srliw	a1,a1,0xd
    80003000:	0001b797          	auipc	a5,0x1b
    80003004:	e8c7a783          	lw	a5,-372(a5) # 8001de8c <sb+0x1c>
    80003008:	9dbd                	addw	a1,a1,a5
    8000300a:	dedff0ef          	jal	80002df6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000300e:	0074f713          	andi	a4,s1,7
    80003012:	4785                	li	a5,1
    80003014:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003018:	14ce                	slli	s1,s1,0x33
    8000301a:	90d9                	srli	s1,s1,0x36
    8000301c:	00950733          	add	a4,a0,s1
    80003020:	05874703          	lbu	a4,88(a4)
    80003024:	00e7f6b3          	and	a3,a5,a4
    80003028:	c29d                	beqz	a3,8000304e <bfree+0x60>
    8000302a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000302c:	94aa                	add	s1,s1,a0
    8000302e:	fff7c793          	not	a5,a5
    80003032:	8f7d                	and	a4,a4,a5
    80003034:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003038:	7f9000ef          	jal	80004030 <log_write>
  brelse(bp);
    8000303c:	854a                	mv	a0,s2
    8000303e:	ec1ff0ef          	jal	80002efe <brelse>
}
    80003042:	60e2                	ld	ra,24(sp)
    80003044:	6442                	ld	s0,16(sp)
    80003046:	64a2                	ld	s1,8(sp)
    80003048:	6902                	ld	s2,0(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret
    panic("freeing free block");
    8000304e:	00004517          	auipc	a0,0x4
    80003052:	37a50513          	addi	a0,a0,890 # 800073c8 <etext+0x3c8>
    80003056:	f8afd0ef          	jal	800007e0 <panic>

000000008000305a <balloc>:
{
    8000305a:	711d                	addi	sp,sp,-96
    8000305c:	ec86                	sd	ra,88(sp)
    8000305e:	e8a2                	sd	s0,80(sp)
    80003060:	e4a6                	sd	s1,72(sp)
    80003062:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003064:	0001b797          	auipc	a5,0x1b
    80003068:	e107a783          	lw	a5,-496(a5) # 8001de74 <sb+0x4>
    8000306c:	0e078f63          	beqz	a5,8000316a <balloc+0x110>
    80003070:	e0ca                	sd	s2,64(sp)
    80003072:	fc4e                	sd	s3,56(sp)
    80003074:	f852                	sd	s4,48(sp)
    80003076:	f456                	sd	s5,40(sp)
    80003078:	f05a                	sd	s6,32(sp)
    8000307a:	ec5e                	sd	s7,24(sp)
    8000307c:	e862                	sd	s8,16(sp)
    8000307e:	e466                	sd	s9,8(sp)
    80003080:	8baa                	mv	s7,a0
    80003082:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003084:	0001bb17          	auipc	s6,0x1b
    80003088:	decb0b13          	addi	s6,s6,-532 # 8001de70 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000308c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000308e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003090:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003092:	6c89                	lui	s9,0x2
    80003094:	a0b5                	j	80003100 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003096:	97ca                	add	a5,a5,s2
    80003098:	8e55                	or	a2,a2,a3
    8000309a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000309e:	854a                	mv	a0,s2
    800030a0:	791000ef          	jal	80004030 <log_write>
        brelse(bp);
    800030a4:	854a                	mv	a0,s2
    800030a6:	e59ff0ef          	jal	80002efe <brelse>
  bp = bread(dev, bno);
    800030aa:	85a6                	mv	a1,s1
    800030ac:	855e                	mv	a0,s7
    800030ae:	d49ff0ef          	jal	80002df6 <bread>
    800030b2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030b4:	40000613          	li	a2,1024
    800030b8:	4581                	li	a1,0
    800030ba:	05850513          	addi	a0,a0,88
    800030be:	be5fd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    800030c2:	854a                	mv	a0,s2
    800030c4:	76d000ef          	jal	80004030 <log_write>
  brelse(bp);
    800030c8:	854a                	mv	a0,s2
    800030ca:	e35ff0ef          	jal	80002efe <brelse>
}
    800030ce:	6906                	ld	s2,64(sp)
    800030d0:	79e2                	ld	s3,56(sp)
    800030d2:	7a42                	ld	s4,48(sp)
    800030d4:	7aa2                	ld	s5,40(sp)
    800030d6:	7b02                	ld	s6,32(sp)
    800030d8:	6be2                	ld	s7,24(sp)
    800030da:	6c42                	ld	s8,16(sp)
    800030dc:	6ca2                	ld	s9,8(sp)
}
    800030de:	8526                	mv	a0,s1
    800030e0:	60e6                	ld	ra,88(sp)
    800030e2:	6446                	ld	s0,80(sp)
    800030e4:	64a6                	ld	s1,72(sp)
    800030e6:	6125                	addi	sp,sp,96
    800030e8:	8082                	ret
    brelse(bp);
    800030ea:	854a                	mv	a0,s2
    800030ec:	e13ff0ef          	jal	80002efe <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030f0:	015c87bb          	addw	a5,s9,s5
    800030f4:	00078a9b          	sext.w	s5,a5
    800030f8:	004b2703          	lw	a4,4(s6)
    800030fc:	04eaff63          	bgeu	s5,a4,8000315a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003100:	41fad79b          	sraiw	a5,s5,0x1f
    80003104:	0137d79b          	srliw	a5,a5,0x13
    80003108:	015787bb          	addw	a5,a5,s5
    8000310c:	40d7d79b          	sraiw	a5,a5,0xd
    80003110:	01cb2583          	lw	a1,28(s6)
    80003114:	9dbd                	addw	a1,a1,a5
    80003116:	855e                	mv	a0,s7
    80003118:	cdfff0ef          	jal	80002df6 <bread>
    8000311c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000311e:	004b2503          	lw	a0,4(s6)
    80003122:	000a849b          	sext.w	s1,s5
    80003126:	8762                	mv	a4,s8
    80003128:	fca4f1e3          	bgeu	s1,a0,800030ea <balloc+0x90>
      m = 1 << (bi % 8);
    8000312c:	00777693          	andi	a3,a4,7
    80003130:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003134:	41f7579b          	sraiw	a5,a4,0x1f
    80003138:	01d7d79b          	srliw	a5,a5,0x1d
    8000313c:	9fb9                	addw	a5,a5,a4
    8000313e:	4037d79b          	sraiw	a5,a5,0x3
    80003142:	00f90633          	add	a2,s2,a5
    80003146:	05864603          	lbu	a2,88(a2)
    8000314a:	00c6f5b3          	and	a1,a3,a2
    8000314e:	d5a1                	beqz	a1,80003096 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003150:	2705                	addiw	a4,a4,1
    80003152:	2485                	addiw	s1,s1,1
    80003154:	fd471ae3          	bne	a4,s4,80003128 <balloc+0xce>
    80003158:	bf49                	j	800030ea <balloc+0x90>
    8000315a:	6906                	ld	s2,64(sp)
    8000315c:	79e2                	ld	s3,56(sp)
    8000315e:	7a42                	ld	s4,48(sp)
    80003160:	7aa2                	ld	s5,40(sp)
    80003162:	7b02                	ld	s6,32(sp)
    80003164:	6be2                	ld	s7,24(sp)
    80003166:	6c42                	ld	s8,16(sp)
    80003168:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000316a:	00004517          	auipc	a0,0x4
    8000316e:	27650513          	addi	a0,a0,630 # 800073e0 <etext+0x3e0>
    80003172:	b88fd0ef          	jal	800004fa <printf>
  return 0;
    80003176:	4481                	li	s1,0
    80003178:	b79d                	j	800030de <balloc+0x84>

000000008000317a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000317a:	7179                	addi	sp,sp,-48
    8000317c:	f406                	sd	ra,40(sp)
    8000317e:	f022                	sd	s0,32(sp)
    80003180:	ec26                	sd	s1,24(sp)
    80003182:	e84a                	sd	s2,16(sp)
    80003184:	e44e                	sd	s3,8(sp)
    80003186:	1800                	addi	s0,sp,48
    80003188:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000318a:	47ad                	li	a5,11
    8000318c:	02b7e663          	bltu	a5,a1,800031b8 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003190:	02059793          	slli	a5,a1,0x20
    80003194:	01e7d593          	srli	a1,a5,0x1e
    80003198:	00b504b3          	add	s1,a0,a1
    8000319c:	0504a903          	lw	s2,80(s1)
    800031a0:	06091a63          	bnez	s2,80003214 <bmap+0x9a>
      addr = balloc(ip->dev);
    800031a4:	4108                	lw	a0,0(a0)
    800031a6:	eb5ff0ef          	jal	8000305a <balloc>
    800031aa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031ae:	06090363          	beqz	s2,80003214 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800031b2:	0524a823          	sw	s2,80(s1)
    800031b6:	a8b9                	j	80003214 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031b8:	ff45849b          	addiw	s1,a1,-12
    800031bc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031c0:	0ff00793          	li	a5,255
    800031c4:	06e7ee63          	bltu	a5,a4,80003240 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800031c8:	08052903          	lw	s2,128(a0)
    800031cc:	00091d63          	bnez	s2,800031e6 <bmap+0x6c>
      addr = balloc(ip->dev);
    800031d0:	4108                	lw	a0,0(a0)
    800031d2:	e89ff0ef          	jal	8000305a <balloc>
    800031d6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031da:	02090d63          	beqz	s2,80003214 <bmap+0x9a>
    800031de:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800031e0:	0929a023          	sw	s2,128(s3)
    800031e4:	a011                	j	800031e8 <bmap+0x6e>
    800031e6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800031e8:	85ca                	mv	a1,s2
    800031ea:	0009a503          	lw	a0,0(s3)
    800031ee:	c09ff0ef          	jal	80002df6 <bread>
    800031f2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031f4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031f8:	02049713          	slli	a4,s1,0x20
    800031fc:	01e75593          	srli	a1,a4,0x1e
    80003200:	00b784b3          	add	s1,a5,a1
    80003204:	0004a903          	lw	s2,0(s1)
    80003208:	00090e63          	beqz	s2,80003224 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000320c:	8552                	mv	a0,s4
    8000320e:	cf1ff0ef          	jal	80002efe <brelse>
    return addr;
    80003212:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003214:	854a                	mv	a0,s2
    80003216:	70a2                	ld	ra,40(sp)
    80003218:	7402                	ld	s0,32(sp)
    8000321a:	64e2                	ld	s1,24(sp)
    8000321c:	6942                	ld	s2,16(sp)
    8000321e:	69a2                	ld	s3,8(sp)
    80003220:	6145                	addi	sp,sp,48
    80003222:	8082                	ret
      addr = balloc(ip->dev);
    80003224:	0009a503          	lw	a0,0(s3)
    80003228:	e33ff0ef          	jal	8000305a <balloc>
    8000322c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003230:	fc090ee3          	beqz	s2,8000320c <bmap+0x92>
        a[bn] = addr;
    80003234:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003238:	8552                	mv	a0,s4
    8000323a:	5f7000ef          	jal	80004030 <log_write>
    8000323e:	b7f9                	j	8000320c <bmap+0x92>
    80003240:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003242:	00004517          	auipc	a0,0x4
    80003246:	1b650513          	addi	a0,a0,438 # 800073f8 <etext+0x3f8>
    8000324a:	d96fd0ef          	jal	800007e0 <panic>

000000008000324e <iget>:
{
    8000324e:	7179                	addi	sp,sp,-48
    80003250:	f406                	sd	ra,40(sp)
    80003252:	f022                	sd	s0,32(sp)
    80003254:	ec26                	sd	s1,24(sp)
    80003256:	e84a                	sd	s2,16(sp)
    80003258:	e44e                	sd	s3,8(sp)
    8000325a:	e052                	sd	s4,0(sp)
    8000325c:	1800                	addi	s0,sp,48
    8000325e:	89aa                	mv	s3,a0
    80003260:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003262:	0001b517          	auipc	a0,0x1b
    80003266:	c2e50513          	addi	a0,a0,-978 # 8001de90 <itable>
    8000326a:	965fd0ef          	jal	80000bce <acquire>
  empty = 0;
    8000326e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003270:	0001b497          	auipc	s1,0x1b
    80003274:	c3848493          	addi	s1,s1,-968 # 8001dea8 <itable+0x18>
    80003278:	0001c697          	auipc	a3,0x1c
    8000327c:	6c068693          	addi	a3,a3,1728 # 8001f938 <log>
    80003280:	a039                	j	8000328e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003282:	02090963          	beqz	s2,800032b4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003286:	08848493          	addi	s1,s1,136
    8000328a:	02d48863          	beq	s1,a3,800032ba <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000328e:	449c                	lw	a5,8(s1)
    80003290:	fef059e3          	blez	a5,80003282 <iget+0x34>
    80003294:	4098                	lw	a4,0(s1)
    80003296:	ff3716e3          	bne	a4,s3,80003282 <iget+0x34>
    8000329a:	40d8                	lw	a4,4(s1)
    8000329c:	ff4713e3          	bne	a4,s4,80003282 <iget+0x34>
      ip->ref++;
    800032a0:	2785                	addiw	a5,a5,1
    800032a2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800032a4:	0001b517          	auipc	a0,0x1b
    800032a8:	bec50513          	addi	a0,a0,-1044 # 8001de90 <itable>
    800032ac:	9bbfd0ef          	jal	80000c66 <release>
      return ip;
    800032b0:	8926                	mv	s2,s1
    800032b2:	a02d                	j	800032dc <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032b4:	fbe9                	bnez	a5,80003286 <iget+0x38>
      empty = ip;
    800032b6:	8926                	mv	s2,s1
    800032b8:	b7f9                	j	80003286 <iget+0x38>
  if(empty == 0)
    800032ba:	02090a63          	beqz	s2,800032ee <iget+0xa0>
  ip->dev = dev;
    800032be:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800032c2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800032c6:	4785                	li	a5,1
    800032c8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800032cc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800032d0:	0001b517          	auipc	a0,0x1b
    800032d4:	bc050513          	addi	a0,a0,-1088 # 8001de90 <itable>
    800032d8:	98ffd0ef          	jal	80000c66 <release>
}
    800032dc:	854a                	mv	a0,s2
    800032de:	70a2                	ld	ra,40(sp)
    800032e0:	7402                	ld	s0,32(sp)
    800032e2:	64e2                	ld	s1,24(sp)
    800032e4:	6942                	ld	s2,16(sp)
    800032e6:	69a2                	ld	s3,8(sp)
    800032e8:	6a02                	ld	s4,0(sp)
    800032ea:	6145                	addi	sp,sp,48
    800032ec:	8082                	ret
    panic("iget: no inodes");
    800032ee:	00004517          	auipc	a0,0x4
    800032f2:	12250513          	addi	a0,a0,290 # 80007410 <etext+0x410>
    800032f6:	ceafd0ef          	jal	800007e0 <panic>

00000000800032fa <iinit>:
{
    800032fa:	7179                	addi	sp,sp,-48
    800032fc:	f406                	sd	ra,40(sp)
    800032fe:	f022                	sd	s0,32(sp)
    80003300:	ec26                	sd	s1,24(sp)
    80003302:	e84a                	sd	s2,16(sp)
    80003304:	e44e                	sd	s3,8(sp)
    80003306:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003308:	00004597          	auipc	a1,0x4
    8000330c:	11858593          	addi	a1,a1,280 # 80007420 <etext+0x420>
    80003310:	0001b517          	auipc	a0,0x1b
    80003314:	b8050513          	addi	a0,a0,-1152 # 8001de90 <itable>
    80003318:	837fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000331c:	0001b497          	auipc	s1,0x1b
    80003320:	b9c48493          	addi	s1,s1,-1124 # 8001deb8 <itable+0x28>
    80003324:	0001c997          	auipc	s3,0x1c
    80003328:	62498993          	addi	s3,s3,1572 # 8001f948 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000332c:	00004917          	auipc	s2,0x4
    80003330:	0fc90913          	addi	s2,s2,252 # 80007428 <etext+0x428>
    80003334:	85ca                	mv	a1,s2
    80003336:	8526                	mv	a0,s1
    80003338:	5bb000ef          	jal	800040f2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000333c:	08848493          	addi	s1,s1,136
    80003340:	ff349ae3          	bne	s1,s3,80003334 <iinit+0x3a>
}
    80003344:	70a2                	ld	ra,40(sp)
    80003346:	7402                	ld	s0,32(sp)
    80003348:	64e2                	ld	s1,24(sp)
    8000334a:	6942                	ld	s2,16(sp)
    8000334c:	69a2                	ld	s3,8(sp)
    8000334e:	6145                	addi	sp,sp,48
    80003350:	8082                	ret

0000000080003352 <ialloc>:
{
    80003352:	7139                	addi	sp,sp,-64
    80003354:	fc06                	sd	ra,56(sp)
    80003356:	f822                	sd	s0,48(sp)
    80003358:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000335a:	0001b717          	auipc	a4,0x1b
    8000335e:	b2272703          	lw	a4,-1246(a4) # 8001de7c <sb+0xc>
    80003362:	4785                	li	a5,1
    80003364:	06e7f063          	bgeu	a5,a4,800033c4 <ialloc+0x72>
    80003368:	f426                	sd	s1,40(sp)
    8000336a:	f04a                	sd	s2,32(sp)
    8000336c:	ec4e                	sd	s3,24(sp)
    8000336e:	e852                	sd	s4,16(sp)
    80003370:	e456                	sd	s5,8(sp)
    80003372:	e05a                	sd	s6,0(sp)
    80003374:	8aaa                	mv	s5,a0
    80003376:	8b2e                	mv	s6,a1
    80003378:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000337a:	0001ba17          	auipc	s4,0x1b
    8000337e:	af6a0a13          	addi	s4,s4,-1290 # 8001de70 <sb>
    80003382:	00495593          	srli	a1,s2,0x4
    80003386:	018a2783          	lw	a5,24(s4)
    8000338a:	9dbd                	addw	a1,a1,a5
    8000338c:	8556                	mv	a0,s5
    8000338e:	a69ff0ef          	jal	80002df6 <bread>
    80003392:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003394:	05850993          	addi	s3,a0,88
    80003398:	00f97793          	andi	a5,s2,15
    8000339c:	079a                	slli	a5,a5,0x6
    8000339e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800033a0:	00099783          	lh	a5,0(s3)
    800033a4:	cb9d                	beqz	a5,800033da <ialloc+0x88>
    brelse(bp);
    800033a6:	b59ff0ef          	jal	80002efe <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033aa:	0905                	addi	s2,s2,1
    800033ac:	00ca2703          	lw	a4,12(s4)
    800033b0:	0009079b          	sext.w	a5,s2
    800033b4:	fce7e7e3          	bltu	a5,a4,80003382 <ialloc+0x30>
    800033b8:	74a2                	ld	s1,40(sp)
    800033ba:	7902                	ld	s2,32(sp)
    800033bc:	69e2                	ld	s3,24(sp)
    800033be:	6a42                	ld	s4,16(sp)
    800033c0:	6aa2                	ld	s5,8(sp)
    800033c2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033c4:	00004517          	auipc	a0,0x4
    800033c8:	06c50513          	addi	a0,a0,108 # 80007430 <etext+0x430>
    800033cc:	92efd0ef          	jal	800004fa <printf>
  return 0;
    800033d0:	4501                	li	a0,0
}
    800033d2:	70e2                	ld	ra,56(sp)
    800033d4:	7442                	ld	s0,48(sp)
    800033d6:	6121                	addi	sp,sp,64
    800033d8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033da:	04000613          	li	a2,64
    800033de:	4581                	li	a1,0
    800033e0:	854e                	mv	a0,s3
    800033e2:	8c1fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800033e6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033ea:	8526                	mv	a0,s1
    800033ec:	445000ef          	jal	80004030 <log_write>
      brelse(bp);
    800033f0:	8526                	mv	a0,s1
    800033f2:	b0dff0ef          	jal	80002efe <brelse>
      return iget(dev, inum);
    800033f6:	0009059b          	sext.w	a1,s2
    800033fa:	8556                	mv	a0,s5
    800033fc:	e53ff0ef          	jal	8000324e <iget>
    80003400:	74a2                	ld	s1,40(sp)
    80003402:	7902                	ld	s2,32(sp)
    80003404:	69e2                	ld	s3,24(sp)
    80003406:	6a42                	ld	s4,16(sp)
    80003408:	6aa2                	ld	s5,8(sp)
    8000340a:	6b02                	ld	s6,0(sp)
    8000340c:	b7d9                	j	800033d2 <ialloc+0x80>

000000008000340e <iupdate>:
{
    8000340e:	1101                	addi	sp,sp,-32
    80003410:	ec06                	sd	ra,24(sp)
    80003412:	e822                	sd	s0,16(sp)
    80003414:	e426                	sd	s1,8(sp)
    80003416:	e04a                	sd	s2,0(sp)
    80003418:	1000                	addi	s0,sp,32
    8000341a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000341c:	415c                	lw	a5,4(a0)
    8000341e:	0047d79b          	srliw	a5,a5,0x4
    80003422:	0001b597          	auipc	a1,0x1b
    80003426:	a665a583          	lw	a1,-1434(a1) # 8001de88 <sb+0x18>
    8000342a:	9dbd                	addw	a1,a1,a5
    8000342c:	4108                	lw	a0,0(a0)
    8000342e:	9c9ff0ef          	jal	80002df6 <bread>
    80003432:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003434:	05850793          	addi	a5,a0,88
    80003438:	40d8                	lw	a4,4(s1)
    8000343a:	8b3d                	andi	a4,a4,15
    8000343c:	071a                	slli	a4,a4,0x6
    8000343e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003440:	04449703          	lh	a4,68(s1)
    80003444:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003448:	04649703          	lh	a4,70(s1)
    8000344c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003450:	04849703          	lh	a4,72(s1)
    80003454:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003458:	04a49703          	lh	a4,74(s1)
    8000345c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003460:	44f8                	lw	a4,76(s1)
    80003462:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003464:	03400613          	li	a2,52
    80003468:	05048593          	addi	a1,s1,80
    8000346c:	00c78513          	addi	a0,a5,12
    80003470:	88ffd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    80003474:	854a                	mv	a0,s2
    80003476:	3bb000ef          	jal	80004030 <log_write>
  brelse(bp);
    8000347a:	854a                	mv	a0,s2
    8000347c:	a83ff0ef          	jal	80002efe <brelse>
}
    80003480:	60e2                	ld	ra,24(sp)
    80003482:	6442                	ld	s0,16(sp)
    80003484:	64a2                	ld	s1,8(sp)
    80003486:	6902                	ld	s2,0(sp)
    80003488:	6105                	addi	sp,sp,32
    8000348a:	8082                	ret

000000008000348c <idup>:
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	1000                	addi	s0,sp,32
    80003496:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003498:	0001b517          	auipc	a0,0x1b
    8000349c:	9f850513          	addi	a0,a0,-1544 # 8001de90 <itable>
    800034a0:	f2efd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800034a4:	449c                	lw	a5,8(s1)
    800034a6:	2785                	addiw	a5,a5,1
    800034a8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034aa:	0001b517          	auipc	a0,0x1b
    800034ae:	9e650513          	addi	a0,a0,-1562 # 8001de90 <itable>
    800034b2:	fb4fd0ef          	jal	80000c66 <release>
}
    800034b6:	8526                	mv	a0,s1
    800034b8:	60e2                	ld	ra,24(sp)
    800034ba:	6442                	ld	s0,16(sp)
    800034bc:	64a2                	ld	s1,8(sp)
    800034be:	6105                	addi	sp,sp,32
    800034c0:	8082                	ret

00000000800034c2 <ilock>:
{
    800034c2:	1101                	addi	sp,sp,-32
    800034c4:	ec06                	sd	ra,24(sp)
    800034c6:	e822                	sd	s0,16(sp)
    800034c8:	e426                	sd	s1,8(sp)
    800034ca:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034cc:	cd19                	beqz	a0,800034ea <ilock+0x28>
    800034ce:	84aa                	mv	s1,a0
    800034d0:	451c                	lw	a5,8(a0)
    800034d2:	00f05c63          	blez	a5,800034ea <ilock+0x28>
  acquiresleep(&ip->lock);
    800034d6:	0541                	addi	a0,a0,16
    800034d8:	451000ef          	jal	80004128 <acquiresleep>
  if(ip->valid == 0){
    800034dc:	40bc                	lw	a5,64(s1)
    800034de:	cf89                	beqz	a5,800034f8 <ilock+0x36>
}
    800034e0:	60e2                	ld	ra,24(sp)
    800034e2:	6442                	ld	s0,16(sp)
    800034e4:	64a2                	ld	s1,8(sp)
    800034e6:	6105                	addi	sp,sp,32
    800034e8:	8082                	ret
    800034ea:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034ec:	00004517          	auipc	a0,0x4
    800034f0:	f5c50513          	addi	a0,a0,-164 # 80007448 <etext+0x448>
    800034f4:	aecfd0ef          	jal	800007e0 <panic>
    800034f8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034fa:	40dc                	lw	a5,4(s1)
    800034fc:	0047d79b          	srliw	a5,a5,0x4
    80003500:	0001b597          	auipc	a1,0x1b
    80003504:	9885a583          	lw	a1,-1656(a1) # 8001de88 <sb+0x18>
    80003508:	9dbd                	addw	a1,a1,a5
    8000350a:	4088                	lw	a0,0(s1)
    8000350c:	8ebff0ef          	jal	80002df6 <bread>
    80003510:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003512:	05850593          	addi	a1,a0,88
    80003516:	40dc                	lw	a5,4(s1)
    80003518:	8bbd                	andi	a5,a5,15
    8000351a:	079a                	slli	a5,a5,0x6
    8000351c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000351e:	00059783          	lh	a5,0(a1)
    80003522:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003526:	00259783          	lh	a5,2(a1)
    8000352a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000352e:	00459783          	lh	a5,4(a1)
    80003532:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003536:	00659783          	lh	a5,6(a1)
    8000353a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000353e:	459c                	lw	a5,8(a1)
    80003540:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003542:	03400613          	li	a2,52
    80003546:	05b1                	addi	a1,a1,12
    80003548:	05048513          	addi	a0,s1,80
    8000354c:	fb2fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    80003550:	854a                	mv	a0,s2
    80003552:	9adff0ef          	jal	80002efe <brelse>
    ip->valid = 1;
    80003556:	4785                	li	a5,1
    80003558:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000355a:	04449783          	lh	a5,68(s1)
    8000355e:	c399                	beqz	a5,80003564 <ilock+0xa2>
    80003560:	6902                	ld	s2,0(sp)
    80003562:	bfbd                	j	800034e0 <ilock+0x1e>
      panic("ilock: no type");
    80003564:	00004517          	auipc	a0,0x4
    80003568:	eec50513          	addi	a0,a0,-276 # 80007450 <etext+0x450>
    8000356c:	a74fd0ef          	jal	800007e0 <panic>

0000000080003570 <iunlock>:
{
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	e04a                	sd	s2,0(sp)
    8000357a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000357c:	c505                	beqz	a0,800035a4 <iunlock+0x34>
    8000357e:	84aa                	mv	s1,a0
    80003580:	01050913          	addi	s2,a0,16
    80003584:	854a                	mv	a0,s2
    80003586:	421000ef          	jal	800041a6 <holdingsleep>
    8000358a:	cd09                	beqz	a0,800035a4 <iunlock+0x34>
    8000358c:	449c                	lw	a5,8(s1)
    8000358e:	00f05b63          	blez	a5,800035a4 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003592:	854a                	mv	a0,s2
    80003594:	3db000ef          	jal	8000416e <releasesleep>
}
    80003598:	60e2                	ld	ra,24(sp)
    8000359a:	6442                	ld	s0,16(sp)
    8000359c:	64a2                	ld	s1,8(sp)
    8000359e:	6902                	ld	s2,0(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret
    panic("iunlock");
    800035a4:	00004517          	auipc	a0,0x4
    800035a8:	ebc50513          	addi	a0,a0,-324 # 80007460 <etext+0x460>
    800035ac:	a34fd0ef          	jal	800007e0 <panic>

00000000800035b0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035b0:	7179                	addi	sp,sp,-48
    800035b2:	f406                	sd	ra,40(sp)
    800035b4:	f022                	sd	s0,32(sp)
    800035b6:	ec26                	sd	s1,24(sp)
    800035b8:	e84a                	sd	s2,16(sp)
    800035ba:	e44e                	sd	s3,8(sp)
    800035bc:	1800                	addi	s0,sp,48
    800035be:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035c0:	05050493          	addi	s1,a0,80
    800035c4:	08050913          	addi	s2,a0,128
    800035c8:	a021                	j	800035d0 <itrunc+0x20>
    800035ca:	0491                	addi	s1,s1,4
    800035cc:	01248b63          	beq	s1,s2,800035e2 <itrunc+0x32>
    if(ip->addrs[i]){
    800035d0:	408c                	lw	a1,0(s1)
    800035d2:	dde5                	beqz	a1,800035ca <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035d4:	0009a503          	lw	a0,0(s3)
    800035d8:	a17ff0ef          	jal	80002fee <bfree>
      ip->addrs[i] = 0;
    800035dc:	0004a023          	sw	zero,0(s1)
    800035e0:	b7ed                	j	800035ca <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035e2:	0809a583          	lw	a1,128(s3)
    800035e6:	ed89                	bnez	a1,80003600 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035e8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035ec:	854e                	mv	a0,s3
    800035ee:	e21ff0ef          	jal	8000340e <iupdate>
}
    800035f2:	70a2                	ld	ra,40(sp)
    800035f4:	7402                	ld	s0,32(sp)
    800035f6:	64e2                	ld	s1,24(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	6145                	addi	sp,sp,48
    800035fe:	8082                	ret
    80003600:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003602:	0009a503          	lw	a0,0(s3)
    80003606:	ff0ff0ef          	jal	80002df6 <bread>
    8000360a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000360c:	05850493          	addi	s1,a0,88
    80003610:	45850913          	addi	s2,a0,1112
    80003614:	a021                	j	8000361c <itrunc+0x6c>
    80003616:	0491                	addi	s1,s1,4
    80003618:	01248963          	beq	s1,s2,8000362a <itrunc+0x7a>
      if(a[j])
    8000361c:	408c                	lw	a1,0(s1)
    8000361e:	dde5                	beqz	a1,80003616 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003620:	0009a503          	lw	a0,0(s3)
    80003624:	9cbff0ef          	jal	80002fee <bfree>
    80003628:	b7fd                	j	80003616 <itrunc+0x66>
    brelse(bp);
    8000362a:	8552                	mv	a0,s4
    8000362c:	8d3ff0ef          	jal	80002efe <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003630:	0809a583          	lw	a1,128(s3)
    80003634:	0009a503          	lw	a0,0(s3)
    80003638:	9b7ff0ef          	jal	80002fee <bfree>
    ip->addrs[NDIRECT] = 0;
    8000363c:	0809a023          	sw	zero,128(s3)
    80003640:	6a02                	ld	s4,0(sp)
    80003642:	b75d                	j	800035e8 <itrunc+0x38>

0000000080003644 <iput>:
{
    80003644:	1101                	addi	sp,sp,-32
    80003646:	ec06                	sd	ra,24(sp)
    80003648:	e822                	sd	s0,16(sp)
    8000364a:	e426                	sd	s1,8(sp)
    8000364c:	1000                	addi	s0,sp,32
    8000364e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003650:	0001b517          	auipc	a0,0x1b
    80003654:	84050513          	addi	a0,a0,-1984 # 8001de90 <itable>
    80003658:	d76fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000365c:	4498                	lw	a4,8(s1)
    8000365e:	4785                	li	a5,1
    80003660:	02f70063          	beq	a4,a5,80003680 <iput+0x3c>
  ip->ref--;
    80003664:	449c                	lw	a5,8(s1)
    80003666:	37fd                	addiw	a5,a5,-1
    80003668:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000366a:	0001b517          	auipc	a0,0x1b
    8000366e:	82650513          	addi	a0,a0,-2010 # 8001de90 <itable>
    80003672:	df4fd0ef          	jal	80000c66 <release>
}
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	64a2                	ld	s1,8(sp)
    8000367c:	6105                	addi	sp,sp,32
    8000367e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003680:	40bc                	lw	a5,64(s1)
    80003682:	d3ed                	beqz	a5,80003664 <iput+0x20>
    80003684:	04a49783          	lh	a5,74(s1)
    80003688:	fff1                	bnez	a5,80003664 <iput+0x20>
    8000368a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000368c:	01048913          	addi	s2,s1,16
    80003690:	854a                	mv	a0,s2
    80003692:	297000ef          	jal	80004128 <acquiresleep>
    release(&itable.lock);
    80003696:	0001a517          	auipc	a0,0x1a
    8000369a:	7fa50513          	addi	a0,a0,2042 # 8001de90 <itable>
    8000369e:	dc8fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800036a2:	8526                	mv	a0,s1
    800036a4:	f0dff0ef          	jal	800035b0 <itrunc>
    ip->type = 0;
    800036a8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036ac:	8526                	mv	a0,s1
    800036ae:	d61ff0ef          	jal	8000340e <iupdate>
    ip->valid = 0;
    800036b2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036b6:	854a                	mv	a0,s2
    800036b8:	2b7000ef          	jal	8000416e <releasesleep>
    acquire(&itable.lock);
    800036bc:	0001a517          	auipc	a0,0x1a
    800036c0:	7d450513          	addi	a0,a0,2004 # 8001de90 <itable>
    800036c4:	d0afd0ef          	jal	80000bce <acquire>
    800036c8:	6902                	ld	s2,0(sp)
    800036ca:	bf69                	j	80003664 <iput+0x20>

00000000800036cc <iunlockput>:
{
    800036cc:	1101                	addi	sp,sp,-32
    800036ce:	ec06                	sd	ra,24(sp)
    800036d0:	e822                	sd	s0,16(sp)
    800036d2:	e426                	sd	s1,8(sp)
    800036d4:	1000                	addi	s0,sp,32
    800036d6:	84aa                	mv	s1,a0
  iunlock(ip);
    800036d8:	e99ff0ef          	jal	80003570 <iunlock>
  iput(ip);
    800036dc:	8526                	mv	a0,s1
    800036de:	f67ff0ef          	jal	80003644 <iput>
}
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	64a2                	ld	s1,8(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036ec:	0001a717          	auipc	a4,0x1a
    800036f0:	79072703          	lw	a4,1936(a4) # 8001de7c <sb+0xc>
    800036f4:	4785                	li	a5,1
    800036f6:	0ae7ff63          	bgeu	a5,a4,800037b4 <ireclaim+0xc8>
{
    800036fa:	7139                	addi	sp,sp,-64
    800036fc:	fc06                	sd	ra,56(sp)
    800036fe:	f822                	sd	s0,48(sp)
    80003700:	f426                	sd	s1,40(sp)
    80003702:	f04a                	sd	s2,32(sp)
    80003704:	ec4e                	sd	s3,24(sp)
    80003706:	e852                	sd	s4,16(sp)
    80003708:	e456                	sd	s5,8(sp)
    8000370a:	e05a                	sd	s6,0(sp)
    8000370c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000370e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003710:	00050a1b          	sext.w	s4,a0
    80003714:	0001aa97          	auipc	s5,0x1a
    80003718:	75ca8a93          	addi	s5,s5,1884 # 8001de70 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000371c:	00004b17          	auipc	s6,0x4
    80003720:	d4cb0b13          	addi	s6,s6,-692 # 80007468 <etext+0x468>
    80003724:	a099                	j	8000376a <ireclaim+0x7e>
    80003726:	85ce                	mv	a1,s3
    80003728:	855a                	mv	a0,s6
    8000372a:	dd1fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000372e:	85ce                	mv	a1,s3
    80003730:	8552                	mv	a0,s4
    80003732:	b1dff0ef          	jal	8000324e <iget>
    80003736:	89aa                	mv	s3,a0
    brelse(bp);
    80003738:	854a                	mv	a0,s2
    8000373a:	fc4ff0ef          	jal	80002efe <brelse>
    if (ip) {
    8000373e:	00098f63          	beqz	s3,8000375c <ireclaim+0x70>
      begin_op();
    80003742:	76a000ef          	jal	80003eac <begin_op>
      ilock(ip);
    80003746:	854e                	mv	a0,s3
    80003748:	d7bff0ef          	jal	800034c2 <ilock>
      iunlock(ip);
    8000374c:	854e                	mv	a0,s3
    8000374e:	e23ff0ef          	jal	80003570 <iunlock>
      iput(ip);
    80003752:	854e                	mv	a0,s3
    80003754:	ef1ff0ef          	jal	80003644 <iput>
      end_op();
    80003758:	7be000ef          	jal	80003f16 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000375c:	0485                	addi	s1,s1,1
    8000375e:	00caa703          	lw	a4,12(s5)
    80003762:	0004879b          	sext.w	a5,s1
    80003766:	02e7fd63          	bgeu	a5,a4,800037a0 <ireclaim+0xb4>
    8000376a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000376e:	0044d593          	srli	a1,s1,0x4
    80003772:	018aa783          	lw	a5,24(s5)
    80003776:	9dbd                	addw	a1,a1,a5
    80003778:	8552                	mv	a0,s4
    8000377a:	e7cff0ef          	jal	80002df6 <bread>
    8000377e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003780:	05850793          	addi	a5,a0,88
    80003784:	00f9f713          	andi	a4,s3,15
    80003788:	071a                	slli	a4,a4,0x6
    8000378a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    8000378c:	00079703          	lh	a4,0(a5)
    80003790:	c701                	beqz	a4,80003798 <ireclaim+0xac>
    80003792:	00679783          	lh	a5,6(a5)
    80003796:	dbc1                	beqz	a5,80003726 <ireclaim+0x3a>
    brelse(bp);
    80003798:	854a                	mv	a0,s2
    8000379a:	f64ff0ef          	jal	80002efe <brelse>
    if (ip) {
    8000379e:	bf7d                	j	8000375c <ireclaim+0x70>
}
    800037a0:	70e2                	ld	ra,56(sp)
    800037a2:	7442                	ld	s0,48(sp)
    800037a4:	74a2                	ld	s1,40(sp)
    800037a6:	7902                	ld	s2,32(sp)
    800037a8:	69e2                	ld	s3,24(sp)
    800037aa:	6a42                	ld	s4,16(sp)
    800037ac:	6aa2                	ld	s5,8(sp)
    800037ae:	6b02                	ld	s6,0(sp)
    800037b0:	6121                	addi	sp,sp,64
    800037b2:	8082                	ret
    800037b4:	8082                	ret

00000000800037b6 <fsinit>:
fsinit(int dev) {
    800037b6:	7179                	addi	sp,sp,-48
    800037b8:	f406                	sd	ra,40(sp)
    800037ba:	f022                	sd	s0,32(sp)
    800037bc:	ec26                	sd	s1,24(sp)
    800037be:	e84a                	sd	s2,16(sp)
    800037c0:	e44e                	sd	s3,8(sp)
    800037c2:	1800                	addi	s0,sp,48
    800037c4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800037c6:	4585                	li	a1,1
    800037c8:	e2eff0ef          	jal	80002df6 <bread>
    800037cc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ce:	0001a997          	auipc	s3,0x1a
    800037d2:	6a298993          	addi	s3,s3,1698 # 8001de70 <sb>
    800037d6:	02000613          	li	a2,32
    800037da:	05850593          	addi	a1,a0,88
    800037de:	854e                	mv	a0,s3
    800037e0:	d1efd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800037e4:	854a                	mv	a0,s2
    800037e6:	f18ff0ef          	jal	80002efe <brelse>
  if(sb.magic != FSMAGIC)
    800037ea:	0009a703          	lw	a4,0(s3)
    800037ee:	102037b7          	lui	a5,0x10203
    800037f2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037f6:	02f71363          	bne	a4,a5,8000381c <fsinit+0x66>
  initlog(dev, &sb);
    800037fa:	0001a597          	auipc	a1,0x1a
    800037fe:	67658593          	addi	a1,a1,1654 # 8001de70 <sb>
    80003802:	8526                	mv	a0,s1
    80003804:	62a000ef          	jal	80003e2e <initlog>
  ireclaim(dev);
    80003808:	8526                	mv	a0,s1
    8000380a:	ee3ff0ef          	jal	800036ec <ireclaim>
}
    8000380e:	70a2                	ld	ra,40(sp)
    80003810:	7402                	ld	s0,32(sp)
    80003812:	64e2                	ld	s1,24(sp)
    80003814:	6942                	ld	s2,16(sp)
    80003816:	69a2                	ld	s3,8(sp)
    80003818:	6145                	addi	sp,sp,48
    8000381a:	8082                	ret
    panic("invalid file system");
    8000381c:	00004517          	auipc	a0,0x4
    80003820:	c6c50513          	addi	a0,a0,-916 # 80007488 <etext+0x488>
    80003824:	fbdfc0ef          	jal	800007e0 <panic>

0000000080003828 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003828:	1141                	addi	sp,sp,-16
    8000382a:	e422                	sd	s0,8(sp)
    8000382c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000382e:	411c                	lw	a5,0(a0)
    80003830:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003832:	415c                	lw	a5,4(a0)
    80003834:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003836:	04451783          	lh	a5,68(a0)
    8000383a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000383e:	04a51783          	lh	a5,74(a0)
    80003842:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003846:	04c56783          	lwu	a5,76(a0)
    8000384a:	e99c                	sd	a5,16(a1)
}
    8000384c:	6422                	ld	s0,8(sp)
    8000384e:	0141                	addi	sp,sp,16
    80003850:	8082                	ret

0000000080003852 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003852:	457c                	lw	a5,76(a0)
    80003854:	0ed7eb63          	bltu	a5,a3,8000394a <readi+0xf8>
{
    80003858:	7159                	addi	sp,sp,-112
    8000385a:	f486                	sd	ra,104(sp)
    8000385c:	f0a2                	sd	s0,96(sp)
    8000385e:	eca6                	sd	s1,88(sp)
    80003860:	e0d2                	sd	s4,64(sp)
    80003862:	fc56                	sd	s5,56(sp)
    80003864:	f85a                	sd	s6,48(sp)
    80003866:	f45e                	sd	s7,40(sp)
    80003868:	1880                	addi	s0,sp,112
    8000386a:	8b2a                	mv	s6,a0
    8000386c:	8bae                	mv	s7,a1
    8000386e:	8a32                	mv	s4,a2
    80003870:	84b6                	mv	s1,a3
    80003872:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003874:	9f35                	addw	a4,a4,a3
    return 0;
    80003876:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003878:	0cd76063          	bltu	a4,a3,80003938 <readi+0xe6>
    8000387c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000387e:	00e7f463          	bgeu	a5,a4,80003886 <readi+0x34>
    n = ip->size - off;
    80003882:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003886:	080a8f63          	beqz	s5,80003924 <readi+0xd2>
    8000388a:	e8ca                	sd	s2,80(sp)
    8000388c:	f062                	sd	s8,32(sp)
    8000388e:	ec66                	sd	s9,24(sp)
    80003890:	e86a                	sd	s10,16(sp)
    80003892:	e46e                	sd	s11,8(sp)
    80003894:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003896:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000389a:	5c7d                	li	s8,-1
    8000389c:	a80d                	j	800038ce <readi+0x7c>
    8000389e:	020d1d93          	slli	s11,s10,0x20
    800038a2:	020ddd93          	srli	s11,s11,0x20
    800038a6:	05890613          	addi	a2,s2,88
    800038aa:	86ee                	mv	a3,s11
    800038ac:	963a                	add	a2,a2,a4
    800038ae:	85d2                	mv	a1,s4
    800038b0:	855e                	mv	a0,s7
    800038b2:	b7ffe0ef          	jal	80002430 <either_copyout>
    800038b6:	05850763          	beq	a0,s8,80003904 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038ba:	854a                	mv	a0,s2
    800038bc:	e42ff0ef          	jal	80002efe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038c0:	013d09bb          	addw	s3,s10,s3
    800038c4:	009d04bb          	addw	s1,s10,s1
    800038c8:	9a6e                	add	s4,s4,s11
    800038ca:	0559f763          	bgeu	s3,s5,80003918 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800038ce:	00a4d59b          	srliw	a1,s1,0xa
    800038d2:	855a                	mv	a0,s6
    800038d4:	8a7ff0ef          	jal	8000317a <bmap>
    800038d8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038dc:	c5b1                	beqz	a1,80003928 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038de:	000b2503          	lw	a0,0(s6)
    800038e2:	d14ff0ef          	jal	80002df6 <bread>
    800038e6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038e8:	3ff4f713          	andi	a4,s1,1023
    800038ec:	40ec87bb          	subw	a5,s9,a4
    800038f0:	413a86bb          	subw	a3,s5,s3
    800038f4:	8d3e                	mv	s10,a5
    800038f6:	2781                	sext.w	a5,a5
    800038f8:	0006861b          	sext.w	a2,a3
    800038fc:	faf671e3          	bgeu	a2,a5,8000389e <readi+0x4c>
    80003900:	8d36                	mv	s10,a3
    80003902:	bf71                	j	8000389e <readi+0x4c>
      brelse(bp);
    80003904:	854a                	mv	a0,s2
    80003906:	df8ff0ef          	jal	80002efe <brelse>
      tot = -1;
    8000390a:	59fd                	li	s3,-1
      break;
    8000390c:	6946                	ld	s2,80(sp)
    8000390e:	7c02                	ld	s8,32(sp)
    80003910:	6ce2                	ld	s9,24(sp)
    80003912:	6d42                	ld	s10,16(sp)
    80003914:	6da2                	ld	s11,8(sp)
    80003916:	a831                	j	80003932 <readi+0xe0>
    80003918:	6946                	ld	s2,80(sp)
    8000391a:	7c02                	ld	s8,32(sp)
    8000391c:	6ce2                	ld	s9,24(sp)
    8000391e:	6d42                	ld	s10,16(sp)
    80003920:	6da2                	ld	s11,8(sp)
    80003922:	a801                	j	80003932 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003924:	89d6                	mv	s3,s5
    80003926:	a031                	j	80003932 <readi+0xe0>
    80003928:	6946                	ld	s2,80(sp)
    8000392a:	7c02                	ld	s8,32(sp)
    8000392c:	6ce2                	ld	s9,24(sp)
    8000392e:	6d42                	ld	s10,16(sp)
    80003930:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003932:	0009851b          	sext.w	a0,s3
    80003936:	69a6                	ld	s3,72(sp)
}
    80003938:	70a6                	ld	ra,104(sp)
    8000393a:	7406                	ld	s0,96(sp)
    8000393c:	64e6                	ld	s1,88(sp)
    8000393e:	6a06                	ld	s4,64(sp)
    80003940:	7ae2                	ld	s5,56(sp)
    80003942:	7b42                	ld	s6,48(sp)
    80003944:	7ba2                	ld	s7,40(sp)
    80003946:	6165                	addi	sp,sp,112
    80003948:	8082                	ret
    return 0;
    8000394a:	4501                	li	a0,0
}
    8000394c:	8082                	ret

000000008000394e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000394e:	457c                	lw	a5,76(a0)
    80003950:	10d7e063          	bltu	a5,a3,80003a50 <writei+0x102>
{
    80003954:	7159                	addi	sp,sp,-112
    80003956:	f486                	sd	ra,104(sp)
    80003958:	f0a2                	sd	s0,96(sp)
    8000395a:	e8ca                	sd	s2,80(sp)
    8000395c:	e0d2                	sd	s4,64(sp)
    8000395e:	fc56                	sd	s5,56(sp)
    80003960:	f85a                	sd	s6,48(sp)
    80003962:	f45e                	sd	s7,40(sp)
    80003964:	1880                	addi	s0,sp,112
    80003966:	8aaa                	mv	s5,a0
    80003968:	8bae                	mv	s7,a1
    8000396a:	8a32                	mv	s4,a2
    8000396c:	8936                	mv	s2,a3
    8000396e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003970:	00e687bb          	addw	a5,a3,a4
    80003974:	0ed7e063          	bltu	a5,a3,80003a54 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003978:	00043737          	lui	a4,0x43
    8000397c:	0cf76e63          	bltu	a4,a5,80003a58 <writei+0x10a>
    80003980:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003982:	0a0b0f63          	beqz	s6,80003a40 <writei+0xf2>
    80003986:	eca6                	sd	s1,88(sp)
    80003988:	f062                	sd	s8,32(sp)
    8000398a:	ec66                	sd	s9,24(sp)
    8000398c:	e86a                	sd	s10,16(sp)
    8000398e:	e46e                	sd	s11,8(sp)
    80003990:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003992:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003996:	5c7d                	li	s8,-1
    80003998:	a825                	j	800039d0 <writei+0x82>
    8000399a:	020d1d93          	slli	s11,s10,0x20
    8000399e:	020ddd93          	srli	s11,s11,0x20
    800039a2:	05848513          	addi	a0,s1,88
    800039a6:	86ee                	mv	a3,s11
    800039a8:	8652                	mv	a2,s4
    800039aa:	85de                	mv	a1,s7
    800039ac:	953a                	add	a0,a0,a4
    800039ae:	acdfe0ef          	jal	8000247a <either_copyin>
    800039b2:	05850a63          	beq	a0,s8,80003a06 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039b6:	8526                	mv	a0,s1
    800039b8:	678000ef          	jal	80004030 <log_write>
    brelse(bp);
    800039bc:	8526                	mv	a0,s1
    800039be:	d40ff0ef          	jal	80002efe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039c2:	013d09bb          	addw	s3,s10,s3
    800039c6:	012d093b          	addw	s2,s10,s2
    800039ca:	9a6e                	add	s4,s4,s11
    800039cc:	0569f063          	bgeu	s3,s6,80003a0c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039d0:	00a9559b          	srliw	a1,s2,0xa
    800039d4:	8556                	mv	a0,s5
    800039d6:	fa4ff0ef          	jal	8000317a <bmap>
    800039da:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039de:	c59d                	beqz	a1,80003a0c <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039e0:	000aa503          	lw	a0,0(s5)
    800039e4:	c12ff0ef          	jal	80002df6 <bread>
    800039e8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ea:	3ff97713          	andi	a4,s2,1023
    800039ee:	40ec87bb          	subw	a5,s9,a4
    800039f2:	413b06bb          	subw	a3,s6,s3
    800039f6:	8d3e                	mv	s10,a5
    800039f8:	2781                	sext.w	a5,a5
    800039fa:	0006861b          	sext.w	a2,a3
    800039fe:	f8f67ee3          	bgeu	a2,a5,8000399a <writei+0x4c>
    80003a02:	8d36                	mv	s10,a3
    80003a04:	bf59                	j	8000399a <writei+0x4c>
      brelse(bp);
    80003a06:	8526                	mv	a0,s1
    80003a08:	cf6ff0ef          	jal	80002efe <brelse>
  }

  if(off > ip->size)
    80003a0c:	04caa783          	lw	a5,76(s5)
    80003a10:	0327fa63          	bgeu	a5,s2,80003a44 <writei+0xf6>
    ip->size = off;
    80003a14:	052aa623          	sw	s2,76(s5)
    80003a18:	64e6                	ld	s1,88(sp)
    80003a1a:	7c02                	ld	s8,32(sp)
    80003a1c:	6ce2                	ld	s9,24(sp)
    80003a1e:	6d42                	ld	s10,16(sp)
    80003a20:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a22:	8556                	mv	a0,s5
    80003a24:	9ebff0ef          	jal	8000340e <iupdate>

  return tot;
    80003a28:	0009851b          	sext.w	a0,s3
    80003a2c:	69a6                	ld	s3,72(sp)
}
    80003a2e:	70a6                	ld	ra,104(sp)
    80003a30:	7406                	ld	s0,96(sp)
    80003a32:	6946                	ld	s2,80(sp)
    80003a34:	6a06                	ld	s4,64(sp)
    80003a36:	7ae2                	ld	s5,56(sp)
    80003a38:	7b42                	ld	s6,48(sp)
    80003a3a:	7ba2                	ld	s7,40(sp)
    80003a3c:	6165                	addi	sp,sp,112
    80003a3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a40:	89da                	mv	s3,s6
    80003a42:	b7c5                	j	80003a22 <writei+0xd4>
    80003a44:	64e6                	ld	s1,88(sp)
    80003a46:	7c02                	ld	s8,32(sp)
    80003a48:	6ce2                	ld	s9,24(sp)
    80003a4a:	6d42                	ld	s10,16(sp)
    80003a4c:	6da2                	ld	s11,8(sp)
    80003a4e:	bfd1                	j	80003a22 <writei+0xd4>
    return -1;
    80003a50:	557d                	li	a0,-1
}
    80003a52:	8082                	ret
    return -1;
    80003a54:	557d                	li	a0,-1
    80003a56:	bfe1                	j	80003a2e <writei+0xe0>
    return -1;
    80003a58:	557d                	li	a0,-1
    80003a5a:	bfd1                	j	80003a2e <writei+0xe0>

0000000080003a5c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a5c:	1141                	addi	sp,sp,-16
    80003a5e:	e406                	sd	ra,8(sp)
    80003a60:	e022                	sd	s0,0(sp)
    80003a62:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a64:	4639                	li	a2,14
    80003a66:	b08fd0ef          	jal	80000d6e <strncmp>
}
    80003a6a:	60a2                	ld	ra,8(sp)
    80003a6c:	6402                	ld	s0,0(sp)
    80003a6e:	0141                	addi	sp,sp,16
    80003a70:	8082                	ret

0000000080003a72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a72:	7139                	addi	sp,sp,-64
    80003a74:	fc06                	sd	ra,56(sp)
    80003a76:	f822                	sd	s0,48(sp)
    80003a78:	f426                	sd	s1,40(sp)
    80003a7a:	f04a                	sd	s2,32(sp)
    80003a7c:	ec4e                	sd	s3,24(sp)
    80003a7e:	e852                	sd	s4,16(sp)
    80003a80:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a82:	04451703          	lh	a4,68(a0)
    80003a86:	4785                	li	a5,1
    80003a88:	00f71a63          	bne	a4,a5,80003a9c <dirlookup+0x2a>
    80003a8c:	892a                	mv	s2,a0
    80003a8e:	89ae                	mv	s3,a1
    80003a90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a92:	457c                	lw	a5,76(a0)
    80003a94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a98:	e39d                	bnez	a5,80003abe <dirlookup+0x4c>
    80003a9a:	a095                	j	80003afe <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a9c:	00004517          	auipc	a0,0x4
    80003aa0:	a0450513          	addi	a0,a0,-1532 # 800074a0 <etext+0x4a0>
    80003aa4:	d3dfc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003aa8:	00004517          	auipc	a0,0x4
    80003aac:	a1050513          	addi	a0,a0,-1520 # 800074b8 <etext+0x4b8>
    80003ab0:	d31fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ab4:	24c1                	addiw	s1,s1,16
    80003ab6:	04c92783          	lw	a5,76(s2)
    80003aba:	04f4f163          	bgeu	s1,a5,80003afc <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003abe:	4741                	li	a4,16
    80003ac0:	86a6                	mv	a3,s1
    80003ac2:	fc040613          	addi	a2,s0,-64
    80003ac6:	4581                	li	a1,0
    80003ac8:	854a                	mv	a0,s2
    80003aca:	d89ff0ef          	jal	80003852 <readi>
    80003ace:	47c1                	li	a5,16
    80003ad0:	fcf51ce3          	bne	a0,a5,80003aa8 <dirlookup+0x36>
    if(de.inum == 0)
    80003ad4:	fc045783          	lhu	a5,-64(s0)
    80003ad8:	dff1                	beqz	a5,80003ab4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003ada:	fc240593          	addi	a1,s0,-62
    80003ade:	854e                	mv	a0,s3
    80003ae0:	f7dff0ef          	jal	80003a5c <namecmp>
    80003ae4:	f961                	bnez	a0,80003ab4 <dirlookup+0x42>
      if(poff)
    80003ae6:	000a0463          	beqz	s4,80003aee <dirlookup+0x7c>
        *poff = off;
    80003aea:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003aee:	fc045583          	lhu	a1,-64(s0)
    80003af2:	00092503          	lw	a0,0(s2)
    80003af6:	f58ff0ef          	jal	8000324e <iget>
    80003afa:	a011                	j	80003afe <dirlookup+0x8c>
  return 0;
    80003afc:	4501                	li	a0,0
}
    80003afe:	70e2                	ld	ra,56(sp)
    80003b00:	7442                	ld	s0,48(sp)
    80003b02:	74a2                	ld	s1,40(sp)
    80003b04:	7902                	ld	s2,32(sp)
    80003b06:	69e2                	ld	s3,24(sp)
    80003b08:	6a42                	ld	s4,16(sp)
    80003b0a:	6121                	addi	sp,sp,64
    80003b0c:	8082                	ret

0000000080003b0e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b0e:	711d                	addi	sp,sp,-96
    80003b10:	ec86                	sd	ra,88(sp)
    80003b12:	e8a2                	sd	s0,80(sp)
    80003b14:	e4a6                	sd	s1,72(sp)
    80003b16:	e0ca                	sd	s2,64(sp)
    80003b18:	fc4e                	sd	s3,56(sp)
    80003b1a:	f852                	sd	s4,48(sp)
    80003b1c:	f456                	sd	s5,40(sp)
    80003b1e:	f05a                	sd	s6,32(sp)
    80003b20:	ec5e                	sd	s7,24(sp)
    80003b22:	e862                	sd	s8,16(sp)
    80003b24:	e466                	sd	s9,8(sp)
    80003b26:	1080                	addi	s0,sp,96
    80003b28:	84aa                	mv	s1,a0
    80003b2a:	8b2e                	mv	s6,a1
    80003b2c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b2e:	00054703          	lbu	a4,0(a0)
    80003b32:	02f00793          	li	a5,47
    80003b36:	00f70e63          	beq	a4,a5,80003b52 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b3a:	f91fd0ef          	jal	80001aca <myproc>
    80003b3e:	15053503          	ld	a0,336(a0)
    80003b42:	94bff0ef          	jal	8000348c <idup>
    80003b46:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b48:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b4c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b4e:	4b85                	li	s7,1
    80003b50:	a871                	j	80003bec <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b52:	4585                	li	a1,1
    80003b54:	4505                	li	a0,1
    80003b56:	ef8ff0ef          	jal	8000324e <iget>
    80003b5a:	8a2a                	mv	s4,a0
    80003b5c:	b7f5                	j	80003b48 <namex+0x3a>
      iunlockput(ip);
    80003b5e:	8552                	mv	a0,s4
    80003b60:	b6dff0ef          	jal	800036cc <iunlockput>
      return 0;
    80003b64:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b66:	8552                	mv	a0,s4
    80003b68:	60e6                	ld	ra,88(sp)
    80003b6a:	6446                	ld	s0,80(sp)
    80003b6c:	64a6                	ld	s1,72(sp)
    80003b6e:	6906                	ld	s2,64(sp)
    80003b70:	79e2                	ld	s3,56(sp)
    80003b72:	7a42                	ld	s4,48(sp)
    80003b74:	7aa2                	ld	s5,40(sp)
    80003b76:	7b02                	ld	s6,32(sp)
    80003b78:	6be2                	ld	s7,24(sp)
    80003b7a:	6c42                	ld	s8,16(sp)
    80003b7c:	6ca2                	ld	s9,8(sp)
    80003b7e:	6125                	addi	sp,sp,96
    80003b80:	8082                	ret
      iunlock(ip);
    80003b82:	8552                	mv	a0,s4
    80003b84:	9edff0ef          	jal	80003570 <iunlock>
      return ip;
    80003b88:	bff9                	j	80003b66 <namex+0x58>
      iunlockput(ip);
    80003b8a:	8552                	mv	a0,s4
    80003b8c:	b41ff0ef          	jal	800036cc <iunlockput>
      return 0;
    80003b90:	8a4e                	mv	s4,s3
    80003b92:	bfd1                	j	80003b66 <namex+0x58>
  len = path - s;
    80003b94:	40998633          	sub	a2,s3,s1
    80003b98:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b9c:	099c5063          	bge	s8,s9,80003c1c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003ba0:	4639                	li	a2,14
    80003ba2:	85a6                	mv	a1,s1
    80003ba4:	8556                	mv	a0,s5
    80003ba6:	958fd0ef          	jal	80000cfe <memmove>
    80003baa:	84ce                	mv	s1,s3
  while(*path == '/')
    80003bac:	0004c783          	lbu	a5,0(s1)
    80003bb0:	01279763          	bne	a5,s2,80003bbe <namex+0xb0>
    path++;
    80003bb4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bb6:	0004c783          	lbu	a5,0(s1)
    80003bba:	ff278de3          	beq	a5,s2,80003bb4 <namex+0xa6>
    ilock(ip);
    80003bbe:	8552                	mv	a0,s4
    80003bc0:	903ff0ef          	jal	800034c2 <ilock>
    if(ip->type != T_DIR){
    80003bc4:	044a1783          	lh	a5,68(s4)
    80003bc8:	f9779be3          	bne	a5,s7,80003b5e <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003bcc:	000b0563          	beqz	s6,80003bd6 <namex+0xc8>
    80003bd0:	0004c783          	lbu	a5,0(s1)
    80003bd4:	d7dd                	beqz	a5,80003b82 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003bd6:	4601                	li	a2,0
    80003bd8:	85d6                	mv	a1,s5
    80003bda:	8552                	mv	a0,s4
    80003bdc:	e97ff0ef          	jal	80003a72 <dirlookup>
    80003be0:	89aa                	mv	s3,a0
    80003be2:	d545                	beqz	a0,80003b8a <namex+0x7c>
    iunlockput(ip);
    80003be4:	8552                	mv	a0,s4
    80003be6:	ae7ff0ef          	jal	800036cc <iunlockput>
    ip = next;
    80003bea:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003bec:	0004c783          	lbu	a5,0(s1)
    80003bf0:	01279763          	bne	a5,s2,80003bfe <namex+0xf0>
    path++;
    80003bf4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bf6:	0004c783          	lbu	a5,0(s1)
    80003bfa:	ff278de3          	beq	a5,s2,80003bf4 <namex+0xe6>
  if(*path == 0)
    80003bfe:	cb8d                	beqz	a5,80003c30 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003c00:	0004c783          	lbu	a5,0(s1)
    80003c04:	89a6                	mv	s3,s1
  len = path - s;
    80003c06:	4c81                	li	s9,0
    80003c08:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c0a:	01278963          	beq	a5,s2,80003c1c <namex+0x10e>
    80003c0e:	d3d9                	beqz	a5,80003b94 <namex+0x86>
    path++;
    80003c10:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c12:	0009c783          	lbu	a5,0(s3)
    80003c16:	ff279ce3          	bne	a5,s2,80003c0e <namex+0x100>
    80003c1a:	bfad                	j	80003b94 <namex+0x86>
    memmove(name, s, len);
    80003c1c:	2601                	sext.w	a2,a2
    80003c1e:	85a6                	mv	a1,s1
    80003c20:	8556                	mv	a0,s5
    80003c22:	8dcfd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003c26:	9cd6                	add	s9,s9,s5
    80003c28:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c2c:	84ce                	mv	s1,s3
    80003c2e:	bfbd                	j	80003bac <namex+0x9e>
  if(nameiparent){
    80003c30:	f20b0be3          	beqz	s6,80003b66 <namex+0x58>
    iput(ip);
    80003c34:	8552                	mv	a0,s4
    80003c36:	a0fff0ef          	jal	80003644 <iput>
    return 0;
    80003c3a:	4a01                	li	s4,0
    80003c3c:	b72d                	j	80003b66 <namex+0x58>

0000000080003c3e <dirlink>:
{
    80003c3e:	7139                	addi	sp,sp,-64
    80003c40:	fc06                	sd	ra,56(sp)
    80003c42:	f822                	sd	s0,48(sp)
    80003c44:	f04a                	sd	s2,32(sp)
    80003c46:	ec4e                	sd	s3,24(sp)
    80003c48:	e852                	sd	s4,16(sp)
    80003c4a:	0080                	addi	s0,sp,64
    80003c4c:	892a                	mv	s2,a0
    80003c4e:	8a2e                	mv	s4,a1
    80003c50:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c52:	4601                	li	a2,0
    80003c54:	e1fff0ef          	jal	80003a72 <dirlookup>
    80003c58:	e535                	bnez	a0,80003cc4 <dirlink+0x86>
    80003c5a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c5c:	04c92483          	lw	s1,76(s2)
    80003c60:	c48d                	beqz	s1,80003c8a <dirlink+0x4c>
    80003c62:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c64:	4741                	li	a4,16
    80003c66:	86a6                	mv	a3,s1
    80003c68:	fc040613          	addi	a2,s0,-64
    80003c6c:	4581                	li	a1,0
    80003c6e:	854a                	mv	a0,s2
    80003c70:	be3ff0ef          	jal	80003852 <readi>
    80003c74:	47c1                	li	a5,16
    80003c76:	04f51b63          	bne	a0,a5,80003ccc <dirlink+0x8e>
    if(de.inum == 0)
    80003c7a:	fc045783          	lhu	a5,-64(s0)
    80003c7e:	c791                	beqz	a5,80003c8a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c80:	24c1                	addiw	s1,s1,16
    80003c82:	04c92783          	lw	a5,76(s2)
    80003c86:	fcf4efe3          	bltu	s1,a5,80003c64 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c8a:	4639                	li	a2,14
    80003c8c:	85d2                	mv	a1,s4
    80003c8e:	fc240513          	addi	a0,s0,-62
    80003c92:	912fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003c96:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c9a:	4741                	li	a4,16
    80003c9c:	86a6                	mv	a3,s1
    80003c9e:	fc040613          	addi	a2,s0,-64
    80003ca2:	4581                	li	a1,0
    80003ca4:	854a                	mv	a0,s2
    80003ca6:	ca9ff0ef          	jal	8000394e <writei>
    80003caa:	1541                	addi	a0,a0,-16
    80003cac:	00a03533          	snez	a0,a0
    80003cb0:	40a00533          	neg	a0,a0
    80003cb4:	74a2                	ld	s1,40(sp)
}
    80003cb6:	70e2                	ld	ra,56(sp)
    80003cb8:	7442                	ld	s0,48(sp)
    80003cba:	7902                	ld	s2,32(sp)
    80003cbc:	69e2                	ld	s3,24(sp)
    80003cbe:	6a42                	ld	s4,16(sp)
    80003cc0:	6121                	addi	sp,sp,64
    80003cc2:	8082                	ret
    iput(ip);
    80003cc4:	981ff0ef          	jal	80003644 <iput>
    return -1;
    80003cc8:	557d                	li	a0,-1
    80003cca:	b7f5                	j	80003cb6 <dirlink+0x78>
      panic("dirlink read");
    80003ccc:	00003517          	auipc	a0,0x3
    80003cd0:	7fc50513          	addi	a0,a0,2044 # 800074c8 <etext+0x4c8>
    80003cd4:	b0dfc0ef          	jal	800007e0 <panic>

0000000080003cd8 <namei>:

struct inode*
namei(char *path)
{
    80003cd8:	1101                	addi	sp,sp,-32
    80003cda:	ec06                	sd	ra,24(sp)
    80003cdc:	e822                	sd	s0,16(sp)
    80003cde:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ce0:	fe040613          	addi	a2,s0,-32
    80003ce4:	4581                	li	a1,0
    80003ce6:	e29ff0ef          	jal	80003b0e <namex>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	6105                	addi	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cf2:	1141                	addi	sp,sp,-16
    80003cf4:	e406                	sd	ra,8(sp)
    80003cf6:	e022                	sd	s0,0(sp)
    80003cf8:	0800                	addi	s0,sp,16
    80003cfa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cfc:	4585                	li	a1,1
    80003cfe:	e11ff0ef          	jal	80003b0e <namex>
}
    80003d02:	60a2                	ld	ra,8(sp)
    80003d04:	6402                	ld	s0,0(sp)
    80003d06:	0141                	addi	sp,sp,16
    80003d08:	8082                	ret

0000000080003d0a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d0a:	1101                	addi	sp,sp,-32
    80003d0c:	ec06                	sd	ra,24(sp)
    80003d0e:	e822                	sd	s0,16(sp)
    80003d10:	e426                	sd	s1,8(sp)
    80003d12:	e04a                	sd	s2,0(sp)
    80003d14:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d16:	0001c917          	auipc	s2,0x1c
    80003d1a:	c2290913          	addi	s2,s2,-990 # 8001f938 <log>
    80003d1e:	01892583          	lw	a1,24(s2)
    80003d22:	02492503          	lw	a0,36(s2)
    80003d26:	8d0ff0ef          	jal	80002df6 <bread>
    80003d2a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d2c:	02892603          	lw	a2,40(s2)
    80003d30:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d32:	00c05f63          	blez	a2,80003d50 <write_head+0x46>
    80003d36:	0001c717          	auipc	a4,0x1c
    80003d3a:	c2e70713          	addi	a4,a4,-978 # 8001f964 <log+0x2c>
    80003d3e:	87aa                	mv	a5,a0
    80003d40:	060a                	slli	a2,a2,0x2
    80003d42:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d44:	4314                	lw	a3,0(a4)
    80003d46:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d48:	0711                	addi	a4,a4,4
    80003d4a:	0791                	addi	a5,a5,4
    80003d4c:	fec79ce3          	bne	a5,a2,80003d44 <write_head+0x3a>
  }
  bwrite(buf);
    80003d50:	8526                	mv	a0,s1
    80003d52:	97aff0ef          	jal	80002ecc <bwrite>
  brelse(buf);
    80003d56:	8526                	mv	a0,s1
    80003d58:	9a6ff0ef          	jal	80002efe <brelse>
}
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6902                	ld	s2,0(sp)
    80003d64:	6105                	addi	sp,sp,32
    80003d66:	8082                	ret

0000000080003d68 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d68:	0001c797          	auipc	a5,0x1c
    80003d6c:	bf87a783          	lw	a5,-1032(a5) # 8001f960 <log+0x28>
    80003d70:	0af05e63          	blez	a5,80003e2c <install_trans+0xc4>
{
    80003d74:	715d                	addi	sp,sp,-80
    80003d76:	e486                	sd	ra,72(sp)
    80003d78:	e0a2                	sd	s0,64(sp)
    80003d7a:	fc26                	sd	s1,56(sp)
    80003d7c:	f84a                	sd	s2,48(sp)
    80003d7e:	f44e                	sd	s3,40(sp)
    80003d80:	f052                	sd	s4,32(sp)
    80003d82:	ec56                	sd	s5,24(sp)
    80003d84:	e85a                	sd	s6,16(sp)
    80003d86:	e45e                	sd	s7,8(sp)
    80003d88:	0880                	addi	s0,sp,80
    80003d8a:	8b2a                	mv	s6,a0
    80003d8c:	0001ca97          	auipc	s5,0x1c
    80003d90:	bd8a8a93          	addi	s5,s5,-1064 # 8001f964 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d94:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d96:	00003b97          	auipc	s7,0x3
    80003d9a:	742b8b93          	addi	s7,s7,1858 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d9e:	0001ca17          	auipc	s4,0x1c
    80003da2:	b9aa0a13          	addi	s4,s4,-1126 # 8001f938 <log>
    80003da6:	a025                	j	80003dce <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003da8:	000aa603          	lw	a2,0(s5)
    80003dac:	85ce                	mv	a1,s3
    80003dae:	855e                	mv	a0,s7
    80003db0:	f4afc0ef          	jal	800004fa <printf>
    80003db4:	a839                	j	80003dd2 <install_trans+0x6a>
    brelse(lbuf);
    80003db6:	854a                	mv	a0,s2
    80003db8:	946ff0ef          	jal	80002efe <brelse>
    brelse(dbuf);
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	940ff0ef          	jal	80002efe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dc2:	2985                	addiw	s3,s3,1
    80003dc4:	0a91                	addi	s5,s5,4
    80003dc6:	028a2783          	lw	a5,40(s4)
    80003dca:	04f9d663          	bge	s3,a5,80003e16 <install_trans+0xae>
    if(recovering) {
    80003dce:	fc0b1de3          	bnez	s6,80003da8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003dd2:	018a2583          	lw	a1,24(s4)
    80003dd6:	013585bb          	addw	a1,a1,s3
    80003dda:	2585                	addiw	a1,a1,1
    80003ddc:	024a2503          	lw	a0,36(s4)
    80003de0:	816ff0ef          	jal	80002df6 <bread>
    80003de4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003de6:	000aa583          	lw	a1,0(s5)
    80003dea:	024a2503          	lw	a0,36(s4)
    80003dee:	808ff0ef          	jal	80002df6 <bread>
    80003df2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003df4:	40000613          	li	a2,1024
    80003df8:	05890593          	addi	a1,s2,88
    80003dfc:	05850513          	addi	a0,a0,88
    80003e00:	efffc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e04:	8526                	mv	a0,s1
    80003e06:	8c6ff0ef          	jal	80002ecc <bwrite>
    if(recovering == 0)
    80003e0a:	fa0b16e3          	bnez	s6,80003db6 <install_trans+0x4e>
      bunpin(dbuf);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	9aaff0ef          	jal	80002fba <bunpin>
    80003e14:	b74d                	j	80003db6 <install_trans+0x4e>
}
    80003e16:	60a6                	ld	ra,72(sp)
    80003e18:	6406                	ld	s0,64(sp)
    80003e1a:	74e2                	ld	s1,56(sp)
    80003e1c:	7942                	ld	s2,48(sp)
    80003e1e:	79a2                	ld	s3,40(sp)
    80003e20:	7a02                	ld	s4,32(sp)
    80003e22:	6ae2                	ld	s5,24(sp)
    80003e24:	6b42                	ld	s6,16(sp)
    80003e26:	6ba2                	ld	s7,8(sp)
    80003e28:	6161                	addi	sp,sp,80
    80003e2a:	8082                	ret
    80003e2c:	8082                	ret

0000000080003e2e <initlog>:
{
    80003e2e:	7179                	addi	sp,sp,-48
    80003e30:	f406                	sd	ra,40(sp)
    80003e32:	f022                	sd	s0,32(sp)
    80003e34:	ec26                	sd	s1,24(sp)
    80003e36:	e84a                	sd	s2,16(sp)
    80003e38:	e44e                	sd	s3,8(sp)
    80003e3a:	1800                	addi	s0,sp,48
    80003e3c:	892a                	mv	s2,a0
    80003e3e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e40:	0001c497          	auipc	s1,0x1c
    80003e44:	af848493          	addi	s1,s1,-1288 # 8001f938 <log>
    80003e48:	00003597          	auipc	a1,0x3
    80003e4c:	6b058593          	addi	a1,a1,1712 # 800074f8 <etext+0x4f8>
    80003e50:	8526                	mv	a0,s1
    80003e52:	cfdfc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003e56:	0149a583          	lw	a1,20(s3)
    80003e5a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e5c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e60:	854a                	mv	a0,s2
    80003e62:	f95fe0ef          	jal	80002df6 <bread>
  log.lh.n = lh->n;
    80003e66:	4d30                	lw	a2,88(a0)
    80003e68:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e6a:	00c05f63          	blez	a2,80003e88 <initlog+0x5a>
    80003e6e:	87aa                	mv	a5,a0
    80003e70:	0001c717          	auipc	a4,0x1c
    80003e74:	af470713          	addi	a4,a4,-1292 # 8001f964 <log+0x2c>
    80003e78:	060a                	slli	a2,a2,0x2
    80003e7a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e7c:	4ff4                	lw	a3,92(a5)
    80003e7e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e80:	0791                	addi	a5,a5,4
    80003e82:	0711                	addi	a4,a4,4
    80003e84:	fec79ce3          	bne	a5,a2,80003e7c <initlog+0x4e>
  brelse(buf);
    80003e88:	876ff0ef          	jal	80002efe <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e8c:	4505                	li	a0,1
    80003e8e:	edbff0ef          	jal	80003d68 <install_trans>
  log.lh.n = 0;
    80003e92:	0001c797          	auipc	a5,0x1c
    80003e96:	ac07a723          	sw	zero,-1330(a5) # 8001f960 <log+0x28>
  write_head(); // clear the log
    80003e9a:	e71ff0ef          	jal	80003d0a <write_head>
}
    80003e9e:	70a2                	ld	ra,40(sp)
    80003ea0:	7402                	ld	s0,32(sp)
    80003ea2:	64e2                	ld	s1,24(sp)
    80003ea4:	6942                	ld	s2,16(sp)
    80003ea6:	69a2                	ld	s3,8(sp)
    80003ea8:	6145                	addi	sp,sp,48
    80003eaa:	8082                	ret

0000000080003eac <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003eac:	1101                	addi	sp,sp,-32
    80003eae:	ec06                	sd	ra,24(sp)
    80003eb0:	e822                	sd	s0,16(sp)
    80003eb2:	e426                	sd	s1,8(sp)
    80003eb4:	e04a                	sd	s2,0(sp)
    80003eb6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eb8:	0001c517          	auipc	a0,0x1c
    80003ebc:	a8050513          	addi	a0,a0,-1408 # 8001f938 <log>
    80003ec0:	d0ffc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003ec4:	0001c497          	auipc	s1,0x1c
    80003ec8:	a7448493          	addi	s1,s1,-1420 # 8001f938 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ecc:	4979                	li	s2,30
    80003ece:	a029                	j	80003ed8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ed0:	85a6                	mv	a1,s1
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	a00fe0ef          	jal	800020d4 <sleep>
    if(log.committing){
    80003ed8:	509c                	lw	a5,32(s1)
    80003eda:	fbfd                	bnez	a5,80003ed0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003edc:	4cd8                	lw	a4,28(s1)
    80003ede:	2705                	addiw	a4,a4,1
    80003ee0:	0027179b          	slliw	a5,a4,0x2
    80003ee4:	9fb9                	addw	a5,a5,a4
    80003ee6:	0017979b          	slliw	a5,a5,0x1
    80003eea:	5494                	lw	a3,40(s1)
    80003eec:	9fb5                	addw	a5,a5,a3
    80003eee:	00f95763          	bge	s2,a5,80003efc <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ef2:	85a6                	mv	a1,s1
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	9defe0ef          	jal	800020d4 <sleep>
    80003efa:	bff9                	j	80003ed8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003efc:	0001c517          	auipc	a0,0x1c
    80003f00:	a3c50513          	addi	a0,a0,-1476 # 8001f938 <log>
    80003f04:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003f06:	d61fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003f0a:	60e2                	ld	ra,24(sp)
    80003f0c:	6442                	ld	s0,16(sp)
    80003f0e:	64a2                	ld	s1,8(sp)
    80003f10:	6902                	ld	s2,0(sp)
    80003f12:	6105                	addi	sp,sp,32
    80003f14:	8082                	ret

0000000080003f16 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f16:	7139                	addi	sp,sp,-64
    80003f18:	fc06                	sd	ra,56(sp)
    80003f1a:	f822                	sd	s0,48(sp)
    80003f1c:	f426                	sd	s1,40(sp)
    80003f1e:	f04a                	sd	s2,32(sp)
    80003f20:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f22:	0001c497          	auipc	s1,0x1c
    80003f26:	a1648493          	addi	s1,s1,-1514 # 8001f938 <log>
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	ca3fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003f30:	4cdc                	lw	a5,28(s1)
    80003f32:	37fd                	addiw	a5,a5,-1
    80003f34:	0007891b          	sext.w	s2,a5
    80003f38:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f3a:	509c                	lw	a5,32(s1)
    80003f3c:	ef9d                	bnez	a5,80003f7a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f3e:	04091763          	bnez	s2,80003f8c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003f42:	0001c497          	auipc	s1,0x1c
    80003f46:	9f648493          	addi	s1,s1,-1546 # 8001f938 <log>
    80003f4a:	4785                	li	a5,1
    80003f4c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f4e:	8526                	mv	a0,s1
    80003f50:	d17fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f54:	549c                	lw	a5,40(s1)
    80003f56:	04f04b63          	bgtz	a5,80003fac <end_op+0x96>
    acquire(&log.lock);
    80003f5a:	0001c497          	auipc	s1,0x1c
    80003f5e:	9de48493          	addi	s1,s1,-1570 # 8001f938 <log>
    80003f62:	8526                	mv	a0,s1
    80003f64:	c6bfc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003f68:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	9b2fe0ef          	jal	80002120 <wakeup>
    release(&log.lock);
    80003f72:	8526                	mv	a0,s1
    80003f74:	cf3fc0ef          	jal	80000c66 <release>
}
    80003f78:	a025                	j	80003fa0 <end_op+0x8a>
    80003f7a:	ec4e                	sd	s3,24(sp)
    80003f7c:	e852                	sd	s4,16(sp)
    80003f7e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f80:	00003517          	auipc	a0,0x3
    80003f84:	58050513          	addi	a0,a0,1408 # 80007500 <etext+0x500>
    80003f88:	859fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003f8c:	0001c497          	auipc	s1,0x1c
    80003f90:	9ac48493          	addi	s1,s1,-1620 # 8001f938 <log>
    80003f94:	8526                	mv	a0,s1
    80003f96:	98afe0ef          	jal	80002120 <wakeup>
  release(&log.lock);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	ccbfc0ef          	jal	80000c66 <release>
}
    80003fa0:	70e2                	ld	ra,56(sp)
    80003fa2:	7442                	ld	s0,48(sp)
    80003fa4:	74a2                	ld	s1,40(sp)
    80003fa6:	7902                	ld	s2,32(sp)
    80003fa8:	6121                	addi	sp,sp,64
    80003faa:	8082                	ret
    80003fac:	ec4e                	sd	s3,24(sp)
    80003fae:	e852                	sd	s4,16(sp)
    80003fb0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb2:	0001ca97          	auipc	s5,0x1c
    80003fb6:	9b2a8a93          	addi	s5,s5,-1614 # 8001f964 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003fba:	0001ca17          	auipc	s4,0x1c
    80003fbe:	97ea0a13          	addi	s4,s4,-1666 # 8001f938 <log>
    80003fc2:	018a2583          	lw	a1,24(s4)
    80003fc6:	012585bb          	addw	a1,a1,s2
    80003fca:	2585                	addiw	a1,a1,1
    80003fcc:	024a2503          	lw	a0,36(s4)
    80003fd0:	e27fe0ef          	jal	80002df6 <bread>
    80003fd4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fd6:	000aa583          	lw	a1,0(s5)
    80003fda:	024a2503          	lw	a0,36(s4)
    80003fde:	e19fe0ef          	jal	80002df6 <bread>
    80003fe2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fe4:	40000613          	li	a2,1024
    80003fe8:	05850593          	addi	a1,a0,88
    80003fec:	05848513          	addi	a0,s1,88
    80003ff0:	d0ffc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	ed7fe0ef          	jal	80002ecc <bwrite>
    brelse(from);
    80003ffa:	854e                	mv	a0,s3
    80003ffc:	f03fe0ef          	jal	80002efe <brelse>
    brelse(to);
    80004000:	8526                	mv	a0,s1
    80004002:	efdfe0ef          	jal	80002efe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004006:	2905                	addiw	s2,s2,1
    80004008:	0a91                	addi	s5,s5,4
    8000400a:	028a2783          	lw	a5,40(s4)
    8000400e:	faf94ae3          	blt	s2,a5,80003fc2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004012:	cf9ff0ef          	jal	80003d0a <write_head>
    install_trans(0); // Now install writes to home locations
    80004016:	4501                	li	a0,0
    80004018:	d51ff0ef          	jal	80003d68 <install_trans>
    log.lh.n = 0;
    8000401c:	0001c797          	auipc	a5,0x1c
    80004020:	9407a223          	sw	zero,-1724(a5) # 8001f960 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004024:	ce7ff0ef          	jal	80003d0a <write_head>
    80004028:	69e2                	ld	s3,24(sp)
    8000402a:	6a42                	ld	s4,16(sp)
    8000402c:	6aa2                	ld	s5,8(sp)
    8000402e:	b735                	j	80003f5a <end_op+0x44>

0000000080004030 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004030:	1101                	addi	sp,sp,-32
    80004032:	ec06                	sd	ra,24(sp)
    80004034:	e822                	sd	s0,16(sp)
    80004036:	e426                	sd	s1,8(sp)
    80004038:	e04a                	sd	s2,0(sp)
    8000403a:	1000                	addi	s0,sp,32
    8000403c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000403e:	0001c917          	auipc	s2,0x1c
    80004042:	8fa90913          	addi	s2,s2,-1798 # 8001f938 <log>
    80004046:	854a                	mv	a0,s2
    80004048:	b87fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000404c:	02892603          	lw	a2,40(s2)
    80004050:	47f5                	li	a5,29
    80004052:	04c7cc63          	blt	a5,a2,800040aa <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004056:	0001c797          	auipc	a5,0x1c
    8000405a:	8fe7a783          	lw	a5,-1794(a5) # 8001f954 <log+0x1c>
    8000405e:	04f05c63          	blez	a5,800040b6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004062:	4781                	li	a5,0
    80004064:	04c05f63          	blez	a2,800040c2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004068:	44cc                	lw	a1,12(s1)
    8000406a:	0001c717          	auipc	a4,0x1c
    8000406e:	8fa70713          	addi	a4,a4,-1798 # 8001f964 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004072:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004074:	4314                	lw	a3,0(a4)
    80004076:	04b68663          	beq	a3,a1,800040c2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000407a:	2785                	addiw	a5,a5,1
    8000407c:	0711                	addi	a4,a4,4
    8000407e:	fef61be3          	bne	a2,a5,80004074 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004082:	0621                	addi	a2,a2,8
    80004084:	060a                	slli	a2,a2,0x2
    80004086:	0001c797          	auipc	a5,0x1c
    8000408a:	8b278793          	addi	a5,a5,-1870 # 8001f938 <log>
    8000408e:	97b2                	add	a5,a5,a2
    80004090:	44d8                	lw	a4,12(s1)
    80004092:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004094:	8526                	mv	a0,s1
    80004096:	ef1fe0ef          	jal	80002f86 <bpin>
    log.lh.n++;
    8000409a:	0001c717          	auipc	a4,0x1c
    8000409e:	89e70713          	addi	a4,a4,-1890 # 8001f938 <log>
    800040a2:	571c                	lw	a5,40(a4)
    800040a4:	2785                	addiw	a5,a5,1
    800040a6:	d71c                	sw	a5,40(a4)
    800040a8:	a80d                	j	800040da <log_write+0xaa>
    panic("too big a transaction");
    800040aa:	00003517          	auipc	a0,0x3
    800040ae:	46650513          	addi	a0,a0,1126 # 80007510 <etext+0x510>
    800040b2:	f2efc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800040b6:	00003517          	auipc	a0,0x3
    800040ba:	47250513          	addi	a0,a0,1138 # 80007528 <etext+0x528>
    800040be:	f22fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    800040c2:	00878693          	addi	a3,a5,8
    800040c6:	068a                	slli	a3,a3,0x2
    800040c8:	0001c717          	auipc	a4,0x1c
    800040cc:	87070713          	addi	a4,a4,-1936 # 8001f938 <log>
    800040d0:	9736                	add	a4,a4,a3
    800040d2:	44d4                	lw	a3,12(s1)
    800040d4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800040d6:	faf60fe3          	beq	a2,a5,80004094 <log_write+0x64>
  }
  release(&log.lock);
    800040da:	0001c517          	auipc	a0,0x1c
    800040de:	85e50513          	addi	a0,a0,-1954 # 8001f938 <log>
    800040e2:	b85fc0ef          	jal	80000c66 <release>
}
    800040e6:	60e2                	ld	ra,24(sp)
    800040e8:	6442                	ld	s0,16(sp)
    800040ea:	64a2                	ld	s1,8(sp)
    800040ec:	6902                	ld	s2,0(sp)
    800040ee:	6105                	addi	sp,sp,32
    800040f0:	8082                	ret

00000000800040f2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040f2:	1101                	addi	sp,sp,-32
    800040f4:	ec06                	sd	ra,24(sp)
    800040f6:	e822                	sd	s0,16(sp)
    800040f8:	e426                	sd	s1,8(sp)
    800040fa:	e04a                	sd	s2,0(sp)
    800040fc:	1000                	addi	s0,sp,32
    800040fe:	84aa                	mv	s1,a0
    80004100:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004102:	00003597          	auipc	a1,0x3
    80004106:	44658593          	addi	a1,a1,1094 # 80007548 <etext+0x548>
    8000410a:	0521                	addi	a0,a0,8
    8000410c:	a43fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80004110:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004114:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004118:	0204a423          	sw	zero,40(s1)
}
    8000411c:	60e2                	ld	ra,24(sp)
    8000411e:	6442                	ld	s0,16(sp)
    80004120:	64a2                	ld	s1,8(sp)
    80004122:	6902                	ld	s2,0(sp)
    80004124:	6105                	addi	sp,sp,32
    80004126:	8082                	ret

0000000080004128 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	e426                	sd	s1,8(sp)
    80004130:	e04a                	sd	s2,0(sp)
    80004132:	1000                	addi	s0,sp,32
    80004134:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004136:	00850913          	addi	s2,a0,8
    8000413a:	854a                	mv	a0,s2
    8000413c:	a93fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80004140:	409c                	lw	a5,0(s1)
    80004142:	c799                	beqz	a5,80004150 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004144:	85ca                	mv	a1,s2
    80004146:	8526                	mv	a0,s1
    80004148:	f8dfd0ef          	jal	800020d4 <sleep>
  while (lk->locked) {
    8000414c:	409c                	lw	a5,0(s1)
    8000414e:	fbfd                	bnez	a5,80004144 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004150:	4785                	li	a5,1
    80004152:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004154:	977fd0ef          	jal	80001aca <myproc>
    80004158:	591c                	lw	a5,48(a0)
    8000415a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000415c:	854a                	mv	a0,s2
    8000415e:	b09fc0ef          	jal	80000c66 <release>
}
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	64a2                	ld	s1,8(sp)
    80004168:	6902                	ld	s2,0(sp)
    8000416a:	6105                	addi	sp,sp,32
    8000416c:	8082                	ret

000000008000416e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000416e:	1101                	addi	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	e04a                	sd	s2,0(sp)
    80004178:	1000                	addi	s0,sp,32
    8000417a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000417c:	00850913          	addi	s2,a0,8
    80004180:	854a                	mv	a0,s2
    80004182:	a4dfc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004186:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000418a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000418e:	8526                	mv	a0,s1
    80004190:	f91fd0ef          	jal	80002120 <wakeup>
  release(&lk->lk);
    80004194:	854a                	mv	a0,s2
    80004196:	ad1fc0ef          	jal	80000c66 <release>
}
    8000419a:	60e2                	ld	ra,24(sp)
    8000419c:	6442                	ld	s0,16(sp)
    8000419e:	64a2                	ld	s1,8(sp)
    800041a0:	6902                	ld	s2,0(sp)
    800041a2:	6105                	addi	sp,sp,32
    800041a4:	8082                	ret

00000000800041a6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041a6:	7179                	addi	sp,sp,-48
    800041a8:	f406                	sd	ra,40(sp)
    800041aa:	f022                	sd	s0,32(sp)
    800041ac:	ec26                	sd	s1,24(sp)
    800041ae:	e84a                	sd	s2,16(sp)
    800041b0:	1800                	addi	s0,sp,48
    800041b2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800041b4:	00850913          	addi	s2,a0,8
    800041b8:	854a                	mv	a0,s2
    800041ba:	a15fc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041be:	409c                	lw	a5,0(s1)
    800041c0:	ef81                	bnez	a5,800041d8 <holdingsleep+0x32>
    800041c2:	4481                	li	s1,0
  release(&lk->lk);
    800041c4:	854a                	mv	a0,s2
    800041c6:	aa1fc0ef          	jal	80000c66 <release>
  return r;
}
    800041ca:	8526                	mv	a0,s1
    800041cc:	70a2                	ld	ra,40(sp)
    800041ce:	7402                	ld	s0,32(sp)
    800041d0:	64e2                	ld	s1,24(sp)
    800041d2:	6942                	ld	s2,16(sp)
    800041d4:	6145                	addi	sp,sp,48
    800041d6:	8082                	ret
    800041d8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041da:	0284a983          	lw	s3,40(s1)
    800041de:	8edfd0ef          	jal	80001aca <myproc>
    800041e2:	5904                	lw	s1,48(a0)
    800041e4:	413484b3          	sub	s1,s1,s3
    800041e8:	0014b493          	seqz	s1,s1
    800041ec:	69a2                	ld	s3,8(sp)
    800041ee:	bfd9                	j	800041c4 <holdingsleep+0x1e>

00000000800041f0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041f0:	1141                	addi	sp,sp,-16
    800041f2:	e406                	sd	ra,8(sp)
    800041f4:	e022                	sd	s0,0(sp)
    800041f6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041f8:	00003597          	auipc	a1,0x3
    800041fc:	36058593          	addi	a1,a1,864 # 80007558 <etext+0x558>
    80004200:	0001c517          	auipc	a0,0x1c
    80004204:	88050513          	addi	a0,a0,-1920 # 8001fa80 <ftable>
    80004208:	947fc0ef          	jal	80000b4e <initlock>
}
    8000420c:	60a2                	ld	ra,8(sp)
    8000420e:	6402                	ld	s0,0(sp)
    80004210:	0141                	addi	sp,sp,16
    80004212:	8082                	ret

0000000080004214 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004214:	1101                	addi	sp,sp,-32
    80004216:	ec06                	sd	ra,24(sp)
    80004218:	e822                	sd	s0,16(sp)
    8000421a:	e426                	sd	s1,8(sp)
    8000421c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000421e:	0001c517          	auipc	a0,0x1c
    80004222:	86250513          	addi	a0,a0,-1950 # 8001fa80 <ftable>
    80004226:	9a9fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000422a:	0001c497          	auipc	s1,0x1c
    8000422e:	86e48493          	addi	s1,s1,-1938 # 8001fa98 <ftable+0x18>
    80004232:	0001d717          	auipc	a4,0x1d
    80004236:	80670713          	addi	a4,a4,-2042 # 80020a38 <disk>
    if(f->ref == 0){
    8000423a:	40dc                	lw	a5,4(s1)
    8000423c:	cf89                	beqz	a5,80004256 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000423e:	02848493          	addi	s1,s1,40
    80004242:	fee49ce3          	bne	s1,a4,8000423a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004246:	0001c517          	auipc	a0,0x1c
    8000424a:	83a50513          	addi	a0,a0,-1990 # 8001fa80 <ftable>
    8000424e:	a19fc0ef          	jal	80000c66 <release>
  return 0;
    80004252:	4481                	li	s1,0
    80004254:	a809                	j	80004266 <filealloc+0x52>
      f->ref = 1;
    80004256:	4785                	li	a5,1
    80004258:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000425a:	0001c517          	auipc	a0,0x1c
    8000425e:	82650513          	addi	a0,a0,-2010 # 8001fa80 <ftable>
    80004262:	a05fc0ef          	jal	80000c66 <release>
}
    80004266:	8526                	mv	a0,s1
    80004268:	60e2                	ld	ra,24(sp)
    8000426a:	6442                	ld	s0,16(sp)
    8000426c:	64a2                	ld	s1,8(sp)
    8000426e:	6105                	addi	sp,sp,32
    80004270:	8082                	ret

0000000080004272 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004272:	1101                	addi	sp,sp,-32
    80004274:	ec06                	sd	ra,24(sp)
    80004276:	e822                	sd	s0,16(sp)
    80004278:	e426                	sd	s1,8(sp)
    8000427a:	1000                	addi	s0,sp,32
    8000427c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000427e:	0001c517          	auipc	a0,0x1c
    80004282:	80250513          	addi	a0,a0,-2046 # 8001fa80 <ftable>
    80004286:	949fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    8000428a:	40dc                	lw	a5,4(s1)
    8000428c:	02f05063          	blez	a5,800042ac <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004290:	2785                	addiw	a5,a5,1
    80004292:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004294:	0001b517          	auipc	a0,0x1b
    80004298:	7ec50513          	addi	a0,a0,2028 # 8001fa80 <ftable>
    8000429c:	9cbfc0ef          	jal	80000c66 <release>
  return f;
}
    800042a0:	8526                	mv	a0,s1
    800042a2:	60e2                	ld	ra,24(sp)
    800042a4:	6442                	ld	s0,16(sp)
    800042a6:	64a2                	ld	s1,8(sp)
    800042a8:	6105                	addi	sp,sp,32
    800042aa:	8082                	ret
    panic("filedup");
    800042ac:	00003517          	auipc	a0,0x3
    800042b0:	2b450513          	addi	a0,a0,692 # 80007560 <etext+0x560>
    800042b4:	d2cfc0ef          	jal	800007e0 <panic>

00000000800042b8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042b8:	7139                	addi	sp,sp,-64
    800042ba:	fc06                	sd	ra,56(sp)
    800042bc:	f822                	sd	s0,48(sp)
    800042be:	f426                	sd	s1,40(sp)
    800042c0:	0080                	addi	s0,sp,64
    800042c2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042c4:	0001b517          	auipc	a0,0x1b
    800042c8:	7bc50513          	addi	a0,a0,1980 # 8001fa80 <ftable>
    800042cc:	903fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800042d0:	40dc                	lw	a5,4(s1)
    800042d2:	04f05a63          	blez	a5,80004326 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800042d6:	37fd                	addiw	a5,a5,-1
    800042d8:	0007871b          	sext.w	a4,a5
    800042dc:	c0dc                	sw	a5,4(s1)
    800042de:	04e04e63          	bgtz	a4,8000433a <fileclose+0x82>
    800042e2:	f04a                	sd	s2,32(sp)
    800042e4:	ec4e                	sd	s3,24(sp)
    800042e6:	e852                	sd	s4,16(sp)
    800042e8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042ea:	0004a903          	lw	s2,0(s1)
    800042ee:	0094ca83          	lbu	s5,9(s1)
    800042f2:	0104ba03          	ld	s4,16(s1)
    800042f6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042fa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042fe:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004302:	0001b517          	auipc	a0,0x1b
    80004306:	77e50513          	addi	a0,a0,1918 # 8001fa80 <ftable>
    8000430a:	95dfc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    8000430e:	4785                	li	a5,1
    80004310:	04f90063          	beq	s2,a5,80004350 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004314:	3979                	addiw	s2,s2,-2
    80004316:	4785                	li	a5,1
    80004318:	0527f563          	bgeu	a5,s2,80004362 <fileclose+0xaa>
    8000431c:	7902                	ld	s2,32(sp)
    8000431e:	69e2                	ld	s3,24(sp)
    80004320:	6a42                	ld	s4,16(sp)
    80004322:	6aa2                	ld	s5,8(sp)
    80004324:	a00d                	j	80004346 <fileclose+0x8e>
    80004326:	f04a                	sd	s2,32(sp)
    80004328:	ec4e                	sd	s3,24(sp)
    8000432a:	e852                	sd	s4,16(sp)
    8000432c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000432e:	00003517          	auipc	a0,0x3
    80004332:	23a50513          	addi	a0,a0,570 # 80007568 <etext+0x568>
    80004336:	caafc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    8000433a:	0001b517          	auipc	a0,0x1b
    8000433e:	74650513          	addi	a0,a0,1862 # 8001fa80 <ftable>
    80004342:	925fc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004346:	70e2                	ld	ra,56(sp)
    80004348:	7442                	ld	s0,48(sp)
    8000434a:	74a2                	ld	s1,40(sp)
    8000434c:	6121                	addi	sp,sp,64
    8000434e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004350:	85d6                	mv	a1,s5
    80004352:	8552                	mv	a0,s4
    80004354:	336000ef          	jal	8000468a <pipeclose>
    80004358:	7902                	ld	s2,32(sp)
    8000435a:	69e2                	ld	s3,24(sp)
    8000435c:	6a42                	ld	s4,16(sp)
    8000435e:	6aa2                	ld	s5,8(sp)
    80004360:	b7dd                	j	80004346 <fileclose+0x8e>
    begin_op();
    80004362:	b4bff0ef          	jal	80003eac <begin_op>
    iput(ff.ip);
    80004366:	854e                	mv	a0,s3
    80004368:	adcff0ef          	jal	80003644 <iput>
    end_op();
    8000436c:	babff0ef          	jal	80003f16 <end_op>
    80004370:	7902                	ld	s2,32(sp)
    80004372:	69e2                	ld	s3,24(sp)
    80004374:	6a42                	ld	s4,16(sp)
    80004376:	6aa2                	ld	s5,8(sp)
    80004378:	b7f9                	j	80004346 <fileclose+0x8e>

000000008000437a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000437a:	715d                	addi	sp,sp,-80
    8000437c:	e486                	sd	ra,72(sp)
    8000437e:	e0a2                	sd	s0,64(sp)
    80004380:	fc26                	sd	s1,56(sp)
    80004382:	f44e                	sd	s3,40(sp)
    80004384:	0880                	addi	s0,sp,80
    80004386:	84aa                	mv	s1,a0
    80004388:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000438a:	f40fd0ef          	jal	80001aca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000438e:	409c                	lw	a5,0(s1)
    80004390:	37f9                	addiw	a5,a5,-2
    80004392:	4705                	li	a4,1
    80004394:	04f76063          	bltu	a4,a5,800043d4 <filestat+0x5a>
    80004398:	f84a                	sd	s2,48(sp)
    8000439a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000439c:	6c88                	ld	a0,24(s1)
    8000439e:	924ff0ef          	jal	800034c2 <ilock>
    stati(f->ip, &st);
    800043a2:	fb840593          	addi	a1,s0,-72
    800043a6:	6c88                	ld	a0,24(s1)
    800043a8:	c80ff0ef          	jal	80003828 <stati>
    iunlock(f->ip);
    800043ac:	6c88                	ld	a0,24(s1)
    800043ae:	9c2ff0ef          	jal	80003570 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800043b2:	46e1                	li	a3,24
    800043b4:	fb840613          	addi	a2,s0,-72
    800043b8:	85ce                	mv	a1,s3
    800043ba:	05093503          	ld	a0,80(s2)
    800043be:	a24fd0ef          	jal	800015e2 <copyout>
    800043c2:	41f5551b          	sraiw	a0,a0,0x1f
    800043c6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043c8:	60a6                	ld	ra,72(sp)
    800043ca:	6406                	ld	s0,64(sp)
    800043cc:	74e2                	ld	s1,56(sp)
    800043ce:	79a2                	ld	s3,40(sp)
    800043d0:	6161                	addi	sp,sp,80
    800043d2:	8082                	ret
  return -1;
    800043d4:	557d                	li	a0,-1
    800043d6:	bfcd                	j	800043c8 <filestat+0x4e>

00000000800043d8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043d8:	7179                	addi	sp,sp,-48
    800043da:	f406                	sd	ra,40(sp)
    800043dc:	f022                	sd	s0,32(sp)
    800043de:	e84a                	sd	s2,16(sp)
    800043e0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800043e2:	00854783          	lbu	a5,8(a0)
    800043e6:	cfd1                	beqz	a5,80004482 <fileread+0xaa>
    800043e8:	ec26                	sd	s1,24(sp)
    800043ea:	e44e                	sd	s3,8(sp)
    800043ec:	84aa                	mv	s1,a0
    800043ee:	89ae                	mv	s3,a1
    800043f0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800043f2:	411c                	lw	a5,0(a0)
    800043f4:	4705                	li	a4,1
    800043f6:	04e78363          	beq	a5,a4,8000443c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043fa:	470d                	li	a4,3
    800043fc:	04e78763          	beq	a5,a4,8000444a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004400:	4709                	li	a4,2
    80004402:	06e79a63          	bne	a5,a4,80004476 <fileread+0x9e>
    ilock(f->ip);
    80004406:	6d08                	ld	a0,24(a0)
    80004408:	8baff0ef          	jal	800034c2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000440c:	874a                	mv	a4,s2
    8000440e:	5094                	lw	a3,32(s1)
    80004410:	864e                	mv	a2,s3
    80004412:	4585                	li	a1,1
    80004414:	6c88                	ld	a0,24(s1)
    80004416:	c3cff0ef          	jal	80003852 <readi>
    8000441a:	892a                	mv	s2,a0
    8000441c:	00a05563          	blez	a0,80004426 <fileread+0x4e>
      f->off += r;
    80004420:	509c                	lw	a5,32(s1)
    80004422:	9fa9                	addw	a5,a5,a0
    80004424:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004426:	6c88                	ld	a0,24(s1)
    80004428:	948ff0ef          	jal	80003570 <iunlock>
    8000442c:	64e2                	ld	s1,24(sp)
    8000442e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004430:	854a                	mv	a0,s2
    80004432:	70a2                	ld	ra,40(sp)
    80004434:	7402                	ld	s0,32(sp)
    80004436:	6942                	ld	s2,16(sp)
    80004438:	6145                	addi	sp,sp,48
    8000443a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000443c:	6908                	ld	a0,16(a0)
    8000443e:	388000ef          	jal	800047c6 <piperead>
    80004442:	892a                	mv	s2,a0
    80004444:	64e2                	ld	s1,24(sp)
    80004446:	69a2                	ld	s3,8(sp)
    80004448:	b7e5                	j	80004430 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000444a:	02451783          	lh	a5,36(a0)
    8000444e:	03079693          	slli	a3,a5,0x30
    80004452:	92c1                	srli	a3,a3,0x30
    80004454:	4725                	li	a4,9
    80004456:	02d76863          	bltu	a4,a3,80004486 <fileread+0xae>
    8000445a:	0792                	slli	a5,a5,0x4
    8000445c:	0001b717          	auipc	a4,0x1b
    80004460:	58470713          	addi	a4,a4,1412 # 8001f9e0 <devsw>
    80004464:	97ba                	add	a5,a5,a4
    80004466:	639c                	ld	a5,0(a5)
    80004468:	c39d                	beqz	a5,8000448e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000446a:	4505                	li	a0,1
    8000446c:	9782                	jalr	a5
    8000446e:	892a                	mv	s2,a0
    80004470:	64e2                	ld	s1,24(sp)
    80004472:	69a2                	ld	s3,8(sp)
    80004474:	bf75                	j	80004430 <fileread+0x58>
    panic("fileread");
    80004476:	00003517          	auipc	a0,0x3
    8000447a:	10250513          	addi	a0,a0,258 # 80007578 <etext+0x578>
    8000447e:	b62fc0ef          	jal	800007e0 <panic>
    return -1;
    80004482:	597d                	li	s2,-1
    80004484:	b775                	j	80004430 <fileread+0x58>
      return -1;
    80004486:	597d                	li	s2,-1
    80004488:	64e2                	ld	s1,24(sp)
    8000448a:	69a2                	ld	s3,8(sp)
    8000448c:	b755                	j	80004430 <fileread+0x58>
    8000448e:	597d                	li	s2,-1
    80004490:	64e2                	ld	s1,24(sp)
    80004492:	69a2                	ld	s3,8(sp)
    80004494:	bf71                	j	80004430 <fileread+0x58>

0000000080004496 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004496:	00954783          	lbu	a5,9(a0)
    8000449a:	10078b63          	beqz	a5,800045b0 <filewrite+0x11a>
{
    8000449e:	715d                	addi	sp,sp,-80
    800044a0:	e486                	sd	ra,72(sp)
    800044a2:	e0a2                	sd	s0,64(sp)
    800044a4:	f84a                	sd	s2,48(sp)
    800044a6:	f052                	sd	s4,32(sp)
    800044a8:	e85a                	sd	s6,16(sp)
    800044aa:	0880                	addi	s0,sp,80
    800044ac:	892a                	mv	s2,a0
    800044ae:	8b2e                	mv	s6,a1
    800044b0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800044b2:	411c                	lw	a5,0(a0)
    800044b4:	4705                	li	a4,1
    800044b6:	02e78763          	beq	a5,a4,800044e4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044ba:	470d                	li	a4,3
    800044bc:	02e78863          	beq	a5,a4,800044ec <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044c0:	4709                	li	a4,2
    800044c2:	0ce79c63          	bne	a5,a4,8000459a <filewrite+0x104>
    800044c6:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044c8:	0ac05863          	blez	a2,80004578 <filewrite+0xe2>
    800044cc:	fc26                	sd	s1,56(sp)
    800044ce:	ec56                	sd	s5,24(sp)
    800044d0:	e45e                	sd	s7,8(sp)
    800044d2:	e062                	sd	s8,0(sp)
    int i = 0;
    800044d4:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800044d6:	6b85                	lui	s7,0x1
    800044d8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044dc:	6c05                	lui	s8,0x1
    800044de:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800044e2:	a8b5                	j	8000455e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800044e4:	6908                	ld	a0,16(a0)
    800044e6:	1fc000ef          	jal	800046e2 <pipewrite>
    800044ea:	a04d                	j	8000458c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044ec:	02451783          	lh	a5,36(a0)
    800044f0:	03079693          	slli	a3,a5,0x30
    800044f4:	92c1                	srli	a3,a3,0x30
    800044f6:	4725                	li	a4,9
    800044f8:	0ad76e63          	bltu	a4,a3,800045b4 <filewrite+0x11e>
    800044fc:	0792                	slli	a5,a5,0x4
    800044fe:	0001b717          	auipc	a4,0x1b
    80004502:	4e270713          	addi	a4,a4,1250 # 8001f9e0 <devsw>
    80004506:	97ba                	add	a5,a5,a4
    80004508:	679c                	ld	a5,8(a5)
    8000450a:	c7dd                	beqz	a5,800045b8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000450c:	4505                	li	a0,1
    8000450e:	9782                	jalr	a5
    80004510:	a8b5                	j	8000458c <filewrite+0xf6>
      if(n1 > max)
    80004512:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004516:	997ff0ef          	jal	80003eac <begin_op>
      ilock(f->ip);
    8000451a:	01893503          	ld	a0,24(s2)
    8000451e:	fa5fe0ef          	jal	800034c2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004522:	8756                	mv	a4,s5
    80004524:	02092683          	lw	a3,32(s2)
    80004528:	01698633          	add	a2,s3,s6
    8000452c:	4585                	li	a1,1
    8000452e:	01893503          	ld	a0,24(s2)
    80004532:	c1cff0ef          	jal	8000394e <writei>
    80004536:	84aa                	mv	s1,a0
    80004538:	00a05763          	blez	a0,80004546 <filewrite+0xb0>
        f->off += r;
    8000453c:	02092783          	lw	a5,32(s2)
    80004540:	9fa9                	addw	a5,a5,a0
    80004542:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004546:	01893503          	ld	a0,24(s2)
    8000454a:	826ff0ef          	jal	80003570 <iunlock>
      end_op();
    8000454e:	9c9ff0ef          	jal	80003f16 <end_op>

      if(r != n1){
    80004552:	029a9563          	bne	s5,s1,8000457c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004556:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000455a:	0149da63          	bge	s3,s4,8000456e <filewrite+0xd8>
      int n1 = n - i;
    8000455e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004562:	0004879b          	sext.w	a5,s1
    80004566:	fafbd6e3          	bge	s7,a5,80004512 <filewrite+0x7c>
    8000456a:	84e2                	mv	s1,s8
    8000456c:	b75d                	j	80004512 <filewrite+0x7c>
    8000456e:	74e2                	ld	s1,56(sp)
    80004570:	6ae2                	ld	s5,24(sp)
    80004572:	6ba2                	ld	s7,8(sp)
    80004574:	6c02                	ld	s8,0(sp)
    80004576:	a039                	j	80004584 <filewrite+0xee>
    int i = 0;
    80004578:	4981                	li	s3,0
    8000457a:	a029                	j	80004584 <filewrite+0xee>
    8000457c:	74e2                	ld	s1,56(sp)
    8000457e:	6ae2                	ld	s5,24(sp)
    80004580:	6ba2                	ld	s7,8(sp)
    80004582:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004584:	033a1c63          	bne	s4,s3,800045bc <filewrite+0x126>
    80004588:	8552                	mv	a0,s4
    8000458a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000458c:	60a6                	ld	ra,72(sp)
    8000458e:	6406                	ld	s0,64(sp)
    80004590:	7942                	ld	s2,48(sp)
    80004592:	7a02                	ld	s4,32(sp)
    80004594:	6b42                	ld	s6,16(sp)
    80004596:	6161                	addi	sp,sp,80
    80004598:	8082                	ret
    8000459a:	fc26                	sd	s1,56(sp)
    8000459c:	f44e                	sd	s3,40(sp)
    8000459e:	ec56                	sd	s5,24(sp)
    800045a0:	e45e                	sd	s7,8(sp)
    800045a2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800045a4:	00003517          	auipc	a0,0x3
    800045a8:	fe450513          	addi	a0,a0,-28 # 80007588 <etext+0x588>
    800045ac:	a34fc0ef          	jal	800007e0 <panic>
    return -1;
    800045b0:	557d                	li	a0,-1
}
    800045b2:	8082                	ret
      return -1;
    800045b4:	557d                	li	a0,-1
    800045b6:	bfd9                	j	8000458c <filewrite+0xf6>
    800045b8:	557d                	li	a0,-1
    800045ba:	bfc9                	j	8000458c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800045bc:	557d                	li	a0,-1
    800045be:	79a2                	ld	s3,40(sp)
    800045c0:	b7f1                	j	8000458c <filewrite+0xf6>

00000000800045c2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045c2:	7179                	addi	sp,sp,-48
    800045c4:	f406                	sd	ra,40(sp)
    800045c6:	f022                	sd	s0,32(sp)
    800045c8:	ec26                	sd	s1,24(sp)
    800045ca:	e052                	sd	s4,0(sp)
    800045cc:	1800                	addi	s0,sp,48
    800045ce:	84aa                	mv	s1,a0
    800045d0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045d2:	0005b023          	sd	zero,0(a1)
    800045d6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045da:	c3bff0ef          	jal	80004214 <filealloc>
    800045de:	e088                	sd	a0,0(s1)
    800045e0:	c549                	beqz	a0,8000466a <pipealloc+0xa8>
    800045e2:	c33ff0ef          	jal	80004214 <filealloc>
    800045e6:	00aa3023          	sd	a0,0(s4)
    800045ea:	cd25                	beqz	a0,80004662 <pipealloc+0xa0>
    800045ec:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045ee:	d10fc0ef          	jal	80000afe <kalloc>
    800045f2:	892a                	mv	s2,a0
    800045f4:	c12d                	beqz	a0,80004656 <pipealloc+0x94>
    800045f6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045f8:	4985                	li	s3,1
    800045fa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045fe:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004602:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004606:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000460a:	00003597          	auipc	a1,0x3
    8000460e:	f8e58593          	addi	a1,a1,-114 # 80007598 <etext+0x598>
    80004612:	d3cfc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004616:	609c                	ld	a5,0(s1)
    80004618:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000461c:	609c                	ld	a5,0(s1)
    8000461e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004622:	609c                	ld	a5,0(s1)
    80004624:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004628:	609c                	ld	a5,0(s1)
    8000462a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000462e:	000a3783          	ld	a5,0(s4)
    80004632:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004636:	000a3783          	ld	a5,0(s4)
    8000463a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000463e:	000a3783          	ld	a5,0(s4)
    80004642:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004646:	000a3783          	ld	a5,0(s4)
    8000464a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000464e:	4501                	li	a0,0
    80004650:	6942                	ld	s2,16(sp)
    80004652:	69a2                	ld	s3,8(sp)
    80004654:	a01d                	j	8000467a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004656:	6088                	ld	a0,0(s1)
    80004658:	c119                	beqz	a0,8000465e <pipealloc+0x9c>
    8000465a:	6942                	ld	s2,16(sp)
    8000465c:	a029                	j	80004666 <pipealloc+0xa4>
    8000465e:	6942                	ld	s2,16(sp)
    80004660:	a029                	j	8000466a <pipealloc+0xa8>
    80004662:	6088                	ld	a0,0(s1)
    80004664:	c10d                	beqz	a0,80004686 <pipealloc+0xc4>
    fileclose(*f0);
    80004666:	c53ff0ef          	jal	800042b8 <fileclose>
  if(*f1)
    8000466a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000466e:	557d                	li	a0,-1
  if(*f1)
    80004670:	c789                	beqz	a5,8000467a <pipealloc+0xb8>
    fileclose(*f1);
    80004672:	853e                	mv	a0,a5
    80004674:	c45ff0ef          	jal	800042b8 <fileclose>
  return -1;
    80004678:	557d                	li	a0,-1
}
    8000467a:	70a2                	ld	ra,40(sp)
    8000467c:	7402                	ld	s0,32(sp)
    8000467e:	64e2                	ld	s1,24(sp)
    80004680:	6a02                	ld	s4,0(sp)
    80004682:	6145                	addi	sp,sp,48
    80004684:	8082                	ret
  return -1;
    80004686:	557d                	li	a0,-1
    80004688:	bfcd                	j	8000467a <pipealloc+0xb8>

000000008000468a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000468a:	1101                	addi	sp,sp,-32
    8000468c:	ec06                	sd	ra,24(sp)
    8000468e:	e822                	sd	s0,16(sp)
    80004690:	e426                	sd	s1,8(sp)
    80004692:	e04a                	sd	s2,0(sp)
    80004694:	1000                	addi	s0,sp,32
    80004696:	84aa                	mv	s1,a0
    80004698:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000469a:	d34fc0ef          	jal	80000bce <acquire>
  if(writable){
    8000469e:	02090763          	beqz	s2,800046cc <pipeclose+0x42>
    pi->writeopen = 0;
    800046a2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046a6:	21848513          	addi	a0,s1,536
    800046aa:	a77fd0ef          	jal	80002120 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800046ae:	2204b783          	ld	a5,544(s1)
    800046b2:	e785                	bnez	a5,800046da <pipeclose+0x50>
    release(&pi->lock);
    800046b4:	8526                	mv	a0,s1
    800046b6:	db0fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800046ba:	8526                	mv	a0,s1
    800046bc:	b60fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800046c0:	60e2                	ld	ra,24(sp)
    800046c2:	6442                	ld	s0,16(sp)
    800046c4:	64a2                	ld	s1,8(sp)
    800046c6:	6902                	ld	s2,0(sp)
    800046c8:	6105                	addi	sp,sp,32
    800046ca:	8082                	ret
    pi->readopen = 0;
    800046cc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046d0:	21c48513          	addi	a0,s1,540
    800046d4:	a4dfd0ef          	jal	80002120 <wakeup>
    800046d8:	bfd9                	j	800046ae <pipeclose+0x24>
    release(&pi->lock);
    800046da:	8526                	mv	a0,s1
    800046dc:	d8afc0ef          	jal	80000c66 <release>
}
    800046e0:	b7c5                	j	800046c0 <pipeclose+0x36>

00000000800046e2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046e2:	711d                	addi	sp,sp,-96
    800046e4:	ec86                	sd	ra,88(sp)
    800046e6:	e8a2                	sd	s0,80(sp)
    800046e8:	e4a6                	sd	s1,72(sp)
    800046ea:	e0ca                	sd	s2,64(sp)
    800046ec:	fc4e                	sd	s3,56(sp)
    800046ee:	f852                	sd	s4,48(sp)
    800046f0:	f456                	sd	s5,40(sp)
    800046f2:	1080                	addi	s0,sp,96
    800046f4:	84aa                	mv	s1,a0
    800046f6:	8aae                	mv	s5,a1
    800046f8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046fa:	bd0fd0ef          	jal	80001aca <myproc>
    800046fe:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004700:	8526                	mv	a0,s1
    80004702:	cccfc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004706:	0b405a63          	blez	s4,800047ba <pipewrite+0xd8>
    8000470a:	f05a                	sd	s6,32(sp)
    8000470c:	ec5e                	sd	s7,24(sp)
    8000470e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004710:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004712:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004714:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004718:	21c48b93          	addi	s7,s1,540
    8000471c:	a81d                	j	80004752 <pipewrite+0x70>
      release(&pi->lock);
    8000471e:	8526                	mv	a0,s1
    80004720:	d46fc0ef          	jal	80000c66 <release>
      return -1;
    80004724:	597d                	li	s2,-1
    80004726:	7b02                	ld	s6,32(sp)
    80004728:	6be2                	ld	s7,24(sp)
    8000472a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000472c:	854a                	mv	a0,s2
    8000472e:	60e6                	ld	ra,88(sp)
    80004730:	6446                	ld	s0,80(sp)
    80004732:	64a6                	ld	s1,72(sp)
    80004734:	6906                	ld	s2,64(sp)
    80004736:	79e2                	ld	s3,56(sp)
    80004738:	7a42                	ld	s4,48(sp)
    8000473a:	7aa2                	ld	s5,40(sp)
    8000473c:	6125                	addi	sp,sp,96
    8000473e:	8082                	ret
      wakeup(&pi->nread);
    80004740:	8562                	mv	a0,s8
    80004742:	9dffd0ef          	jal	80002120 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004746:	85a6                	mv	a1,s1
    80004748:	855e                	mv	a0,s7
    8000474a:	98bfd0ef          	jal	800020d4 <sleep>
  while(i < n){
    8000474e:	05495b63          	bge	s2,s4,800047a4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004752:	2204a783          	lw	a5,544(s1)
    80004756:	d7e1                	beqz	a5,8000471e <pipewrite+0x3c>
    80004758:	854e                	mv	a0,s3
    8000475a:	bb3fd0ef          	jal	8000230c <killed>
    8000475e:	f161                	bnez	a0,8000471e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004760:	2184a783          	lw	a5,536(s1)
    80004764:	21c4a703          	lw	a4,540(s1)
    80004768:	2007879b          	addiw	a5,a5,512
    8000476c:	fcf70ae3          	beq	a4,a5,80004740 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004770:	4685                	li	a3,1
    80004772:	01590633          	add	a2,s2,s5
    80004776:	faf40593          	addi	a1,s0,-81
    8000477a:	0509b503          	ld	a0,80(s3)
    8000477e:	f49fc0ef          	jal	800016c6 <copyin>
    80004782:	03650e63          	beq	a0,s6,800047be <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004786:	21c4a783          	lw	a5,540(s1)
    8000478a:	0017871b          	addiw	a4,a5,1
    8000478e:	20e4ae23          	sw	a4,540(s1)
    80004792:	1ff7f793          	andi	a5,a5,511
    80004796:	97a6                	add	a5,a5,s1
    80004798:	faf44703          	lbu	a4,-81(s0)
    8000479c:	00e78c23          	sb	a4,24(a5)
      i++;
    800047a0:	2905                	addiw	s2,s2,1
    800047a2:	b775                	j	8000474e <pipewrite+0x6c>
    800047a4:	7b02                	ld	s6,32(sp)
    800047a6:	6be2                	ld	s7,24(sp)
    800047a8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800047aa:	21848513          	addi	a0,s1,536
    800047ae:	973fd0ef          	jal	80002120 <wakeup>
  release(&pi->lock);
    800047b2:	8526                	mv	a0,s1
    800047b4:	cb2fc0ef          	jal	80000c66 <release>
  return i;
    800047b8:	bf95                	j	8000472c <pipewrite+0x4a>
  int i = 0;
    800047ba:	4901                	li	s2,0
    800047bc:	b7fd                	j	800047aa <pipewrite+0xc8>
    800047be:	7b02                	ld	s6,32(sp)
    800047c0:	6be2                	ld	s7,24(sp)
    800047c2:	6c42                	ld	s8,16(sp)
    800047c4:	b7dd                	j	800047aa <pipewrite+0xc8>

00000000800047c6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047c6:	715d                	addi	sp,sp,-80
    800047c8:	e486                	sd	ra,72(sp)
    800047ca:	e0a2                	sd	s0,64(sp)
    800047cc:	fc26                	sd	s1,56(sp)
    800047ce:	f84a                	sd	s2,48(sp)
    800047d0:	f44e                	sd	s3,40(sp)
    800047d2:	f052                	sd	s4,32(sp)
    800047d4:	ec56                	sd	s5,24(sp)
    800047d6:	0880                	addi	s0,sp,80
    800047d8:	84aa                	mv	s1,a0
    800047da:	892e                	mv	s2,a1
    800047dc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047de:	aecfd0ef          	jal	80001aca <myproc>
    800047e2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047e4:	8526                	mv	a0,s1
    800047e6:	be8fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047ea:	2184a703          	lw	a4,536(s1)
    800047ee:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047f2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047f6:	02f71563          	bne	a4,a5,80004820 <piperead+0x5a>
    800047fa:	2244a783          	lw	a5,548(s1)
    800047fe:	cb85                	beqz	a5,8000482e <piperead+0x68>
    if(killed(pr)){
    80004800:	8552                	mv	a0,s4
    80004802:	b0bfd0ef          	jal	8000230c <killed>
    80004806:	ed19                	bnez	a0,80004824 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004808:	85a6                	mv	a1,s1
    8000480a:	854e                	mv	a0,s3
    8000480c:	8c9fd0ef          	jal	800020d4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004810:	2184a703          	lw	a4,536(s1)
    80004814:	21c4a783          	lw	a5,540(s1)
    80004818:	fef701e3          	beq	a4,a5,800047fa <piperead+0x34>
    8000481c:	e85a                	sd	s6,16(sp)
    8000481e:	a809                	j	80004830 <piperead+0x6a>
    80004820:	e85a                	sd	s6,16(sp)
    80004822:	a039                	j	80004830 <piperead+0x6a>
      release(&pi->lock);
    80004824:	8526                	mv	a0,s1
    80004826:	c40fc0ef          	jal	80000c66 <release>
      return -1;
    8000482a:	59fd                	li	s3,-1
    8000482c:	a8b9                	j	8000488a <piperead+0xc4>
    8000482e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004830:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004832:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004834:	05505363          	blez	s5,8000487a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004838:	2184a783          	lw	a5,536(s1)
    8000483c:	21c4a703          	lw	a4,540(s1)
    80004840:	02f70d63          	beq	a4,a5,8000487a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004844:	1ff7f793          	andi	a5,a5,511
    80004848:	97a6                	add	a5,a5,s1
    8000484a:	0187c783          	lbu	a5,24(a5)
    8000484e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004852:	4685                	li	a3,1
    80004854:	fbf40613          	addi	a2,s0,-65
    80004858:	85ca                	mv	a1,s2
    8000485a:	050a3503          	ld	a0,80(s4)
    8000485e:	d85fc0ef          	jal	800015e2 <copyout>
    80004862:	03650e63          	beq	a0,s6,8000489e <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004866:	2184a783          	lw	a5,536(s1)
    8000486a:	2785                	addiw	a5,a5,1
    8000486c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004870:	2985                	addiw	s3,s3,1
    80004872:	0905                	addi	s2,s2,1
    80004874:	fd3a92e3          	bne	s5,s3,80004838 <piperead+0x72>
    80004878:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000487a:	21c48513          	addi	a0,s1,540
    8000487e:	8a3fd0ef          	jal	80002120 <wakeup>
  release(&pi->lock);
    80004882:	8526                	mv	a0,s1
    80004884:	be2fc0ef          	jal	80000c66 <release>
    80004888:	6b42                	ld	s6,16(sp)
  return i;
}
    8000488a:	854e                	mv	a0,s3
    8000488c:	60a6                	ld	ra,72(sp)
    8000488e:	6406                	ld	s0,64(sp)
    80004890:	74e2                	ld	s1,56(sp)
    80004892:	7942                	ld	s2,48(sp)
    80004894:	79a2                	ld	s3,40(sp)
    80004896:	7a02                	ld	s4,32(sp)
    80004898:	6ae2                	ld	s5,24(sp)
    8000489a:	6161                	addi	sp,sp,80
    8000489c:	8082                	ret
      if(i == 0)
    8000489e:	fc099ee3          	bnez	s3,8000487a <piperead+0xb4>
        i = -1;
    800048a2:	89aa                	mv	s3,a0
    800048a4:	bfd9                	j	8000487a <piperead+0xb4>

00000000800048a6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800048a6:	1141                	addi	sp,sp,-16
    800048a8:	e422                	sd	s0,8(sp)
    800048aa:	0800                	addi	s0,sp,16
    800048ac:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800048ae:	8905                	andi	a0,a0,1
    800048b0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800048b2:	8b89                	andi	a5,a5,2
    800048b4:	c399                	beqz	a5,800048ba <flags2perm+0x14>
      perm |= PTE_W;
    800048b6:	00456513          	ori	a0,a0,4
    return perm;
}
    800048ba:	6422                	ld	s0,8(sp)
    800048bc:	0141                	addi	sp,sp,16
    800048be:	8082                	ret

00000000800048c0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048c0:	df010113          	addi	sp,sp,-528
    800048c4:	20113423          	sd	ra,520(sp)
    800048c8:	20813023          	sd	s0,512(sp)
    800048cc:	ffa6                	sd	s1,504(sp)
    800048ce:	fbca                	sd	s2,496(sp)
    800048d0:	0c00                	addi	s0,sp,528
    800048d2:	892a                	mv	s2,a0
    800048d4:	dea43c23          	sd	a0,-520(s0)
    800048d8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048dc:	9eefd0ef          	jal	80001aca <myproc>
    800048e0:	84aa                	mv	s1,a0

  begin_op();
    800048e2:	dcaff0ef          	jal	80003eac <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048e6:	854a                	mv	a0,s2
    800048e8:	bf0ff0ef          	jal	80003cd8 <namei>
    800048ec:	c931                	beqz	a0,80004940 <kexec+0x80>
    800048ee:	f3d2                	sd	s4,480(sp)
    800048f0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048f2:	bd1fe0ef          	jal	800034c2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048f6:	04000713          	li	a4,64
    800048fa:	4681                	li	a3,0
    800048fc:	e5040613          	addi	a2,s0,-432
    80004900:	4581                	li	a1,0
    80004902:	8552                	mv	a0,s4
    80004904:	f4ffe0ef          	jal	80003852 <readi>
    80004908:	04000793          	li	a5,64
    8000490c:	00f51a63          	bne	a0,a5,80004920 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004910:	e5042703          	lw	a4,-432(s0)
    80004914:	464c47b7          	lui	a5,0x464c4
    80004918:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000491c:	02f70663          	beq	a4,a5,80004948 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004920:	8552                	mv	a0,s4
    80004922:	dabfe0ef          	jal	800036cc <iunlockput>
    end_op();
    80004926:	df0ff0ef          	jal	80003f16 <end_op>
  }
  return -1;
    8000492a:	557d                	li	a0,-1
    8000492c:	7a1e                	ld	s4,480(sp)
}
    8000492e:	20813083          	ld	ra,520(sp)
    80004932:	20013403          	ld	s0,512(sp)
    80004936:	74fe                	ld	s1,504(sp)
    80004938:	795e                	ld	s2,496(sp)
    8000493a:	21010113          	addi	sp,sp,528
    8000493e:	8082                	ret
    end_op();
    80004940:	dd6ff0ef          	jal	80003f16 <end_op>
    return -1;
    80004944:	557d                	li	a0,-1
    80004946:	b7e5                	j	8000492e <kexec+0x6e>
    80004948:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000494a:	8526                	mv	a0,s1
    8000494c:	a84fd0ef          	jal	80001bd0 <proc_pagetable>
    80004950:	8b2a                	mv	s6,a0
    80004952:	2c050b63          	beqz	a0,80004c28 <kexec+0x368>
    80004956:	f7ce                	sd	s3,488(sp)
    80004958:	efd6                	sd	s5,472(sp)
    8000495a:	e7de                	sd	s7,456(sp)
    8000495c:	e3e2                	sd	s8,448(sp)
    8000495e:	ff66                	sd	s9,440(sp)
    80004960:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004962:	e7042d03          	lw	s10,-400(s0)
    80004966:	e8845783          	lhu	a5,-376(s0)
    8000496a:	12078963          	beqz	a5,80004a9c <kexec+0x1dc>
    8000496e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004970:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004972:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004974:	6c85                	lui	s9,0x1
    80004976:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000497a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000497e:	6a85                	lui	s5,0x1
    80004980:	a085                	j	800049e0 <kexec+0x120>
      panic("loadseg: address should exist");
    80004982:	00003517          	auipc	a0,0x3
    80004986:	c1e50513          	addi	a0,a0,-994 # 800075a0 <etext+0x5a0>
    8000498a:	e57fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    8000498e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004990:	8726                	mv	a4,s1
    80004992:	012c06bb          	addw	a3,s8,s2
    80004996:	4581                	li	a1,0
    80004998:	8552                	mv	a0,s4
    8000499a:	eb9fe0ef          	jal	80003852 <readi>
    8000499e:	2501                	sext.w	a0,a0
    800049a0:	24a49a63          	bne	s1,a0,80004bf4 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800049a4:	012a893b          	addw	s2,s5,s2
    800049a8:	03397363          	bgeu	s2,s3,800049ce <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800049ac:	02091593          	slli	a1,s2,0x20
    800049b0:	9181                	srli	a1,a1,0x20
    800049b2:	95de                	add	a1,a1,s7
    800049b4:	855a                	mv	a0,s6
    800049b6:	dfafc0ef          	jal	80000fb0 <walkaddr>
    800049ba:	862a                	mv	a2,a0
    if(pa == 0)
    800049bc:	d179                	beqz	a0,80004982 <kexec+0xc2>
    if(sz - i < PGSIZE)
    800049be:	412984bb          	subw	s1,s3,s2
    800049c2:	0004879b          	sext.w	a5,s1
    800049c6:	fcfcf4e3          	bgeu	s9,a5,8000498e <kexec+0xce>
    800049ca:	84d6                	mv	s1,s5
    800049cc:	b7c9                	j	8000498e <kexec+0xce>
    sz = sz1;
    800049ce:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049d2:	2d85                	addiw	s11,s11,1
    800049d4:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800049d8:	e8845783          	lhu	a5,-376(s0)
    800049dc:	08fdd063          	bge	s11,a5,80004a5c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049e0:	2d01                	sext.w	s10,s10
    800049e2:	03800713          	li	a4,56
    800049e6:	86ea                	mv	a3,s10
    800049e8:	e1840613          	addi	a2,s0,-488
    800049ec:	4581                	li	a1,0
    800049ee:	8552                	mv	a0,s4
    800049f0:	e63fe0ef          	jal	80003852 <readi>
    800049f4:	03800793          	li	a5,56
    800049f8:	1cf51663          	bne	a0,a5,80004bc4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800049fc:	e1842783          	lw	a5,-488(s0)
    80004a00:	4705                	li	a4,1
    80004a02:	fce798e3          	bne	a5,a4,800049d2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004a06:	e4043483          	ld	s1,-448(s0)
    80004a0a:	e3843783          	ld	a5,-456(s0)
    80004a0e:	1af4ef63          	bltu	s1,a5,80004bcc <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a12:	e2843783          	ld	a5,-472(s0)
    80004a16:	94be                	add	s1,s1,a5
    80004a18:	1af4ee63          	bltu	s1,a5,80004bd4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a1c:	df043703          	ld	a4,-528(s0)
    80004a20:	8ff9                	and	a5,a5,a4
    80004a22:	1a079d63          	bnez	a5,80004bdc <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a26:	e1c42503          	lw	a0,-484(s0)
    80004a2a:	e7dff0ef          	jal	800048a6 <flags2perm>
    80004a2e:	86aa                	mv	a3,a0
    80004a30:	8626                	mv	a2,s1
    80004a32:	85ca                	mv	a1,s2
    80004a34:	855a                	mv	a0,s6
    80004a36:	853fc0ef          	jal	80001288 <uvmalloc>
    80004a3a:	e0a43423          	sd	a0,-504(s0)
    80004a3e:	1a050363          	beqz	a0,80004be4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a42:	e2843b83          	ld	s7,-472(s0)
    80004a46:	e2042c03          	lw	s8,-480(s0)
    80004a4a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a4e:	00098463          	beqz	s3,80004a56 <kexec+0x196>
    80004a52:	4901                	li	s2,0
    80004a54:	bfa1                	j	800049ac <kexec+0xec>
    sz = sz1;
    80004a56:	e0843903          	ld	s2,-504(s0)
    80004a5a:	bfa5                	j	800049d2 <kexec+0x112>
    80004a5c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a5e:	8552                	mv	a0,s4
    80004a60:	c6dfe0ef          	jal	800036cc <iunlockput>
  end_op();
    80004a64:	cb2ff0ef          	jal	80003f16 <end_op>
  p = myproc();
    80004a68:	862fd0ef          	jal	80001aca <myproc>
    80004a6c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a6e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a72:	6985                	lui	s3,0x1
    80004a74:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a76:	99ca                	add	s3,s3,s2
    80004a78:	77fd                	lui	a5,0xfffff
    80004a7a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a7e:	4691                	li	a3,4
    80004a80:	6609                	lui	a2,0x2
    80004a82:	964e                	add	a2,a2,s3
    80004a84:	85ce                	mv	a1,s3
    80004a86:	855a                	mv	a0,s6
    80004a88:	801fc0ef          	jal	80001288 <uvmalloc>
    80004a8c:	892a                	mv	s2,a0
    80004a8e:	e0a43423          	sd	a0,-504(s0)
    80004a92:	e519                	bnez	a0,80004aa0 <kexec+0x1e0>
  if(pagetable)
    80004a94:	e1343423          	sd	s3,-504(s0)
    80004a98:	4a01                	li	s4,0
    80004a9a:	aab1                	j	80004bf6 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a9c:	4901                	li	s2,0
    80004a9e:	b7c1                	j	80004a5e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004aa0:	75f9                	lui	a1,0xffffe
    80004aa2:	95aa                	add	a1,a1,a0
    80004aa4:	855a                	mv	a0,s6
    80004aa6:	9b9fc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004aaa:	7bfd                	lui	s7,0xfffff
    80004aac:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004aae:	e0043783          	ld	a5,-512(s0)
    80004ab2:	6388                	ld	a0,0(a5)
    80004ab4:	cd39                	beqz	a0,80004b12 <kexec+0x252>
    80004ab6:	e9040993          	addi	s3,s0,-368
    80004aba:	f9040c13          	addi	s8,s0,-112
    80004abe:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ac0:	b52fc0ef          	jal	80000e12 <strlen>
    80004ac4:	0015079b          	addiw	a5,a0,1
    80004ac8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004acc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ad0:	11796e63          	bltu	s2,s7,80004bec <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ad4:	e0043d03          	ld	s10,-512(s0)
    80004ad8:	000d3a03          	ld	s4,0(s10)
    80004adc:	8552                	mv	a0,s4
    80004ade:	b34fc0ef          	jal	80000e12 <strlen>
    80004ae2:	0015069b          	addiw	a3,a0,1
    80004ae6:	8652                	mv	a2,s4
    80004ae8:	85ca                	mv	a1,s2
    80004aea:	855a                	mv	a0,s6
    80004aec:	af7fc0ef          	jal	800015e2 <copyout>
    80004af0:	10054063          	bltz	a0,80004bf0 <kexec+0x330>
    ustack[argc] = sp;
    80004af4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004af8:	0485                	addi	s1,s1,1
    80004afa:	008d0793          	addi	a5,s10,8
    80004afe:	e0f43023          	sd	a5,-512(s0)
    80004b02:	008d3503          	ld	a0,8(s10)
    80004b06:	c909                	beqz	a0,80004b18 <kexec+0x258>
    if(argc >= MAXARG)
    80004b08:	09a1                	addi	s3,s3,8
    80004b0a:	fb899be3          	bne	s3,s8,80004ac0 <kexec+0x200>
  ip = 0;
    80004b0e:	4a01                	li	s4,0
    80004b10:	a0dd                	j	80004bf6 <kexec+0x336>
  sp = sz;
    80004b12:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b16:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b18:	00349793          	slli	a5,s1,0x3
    80004b1c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde418>
    80004b20:	97a2                	add	a5,a5,s0
    80004b22:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b26:	00148693          	addi	a3,s1,1
    80004b2a:	068e                	slli	a3,a3,0x3
    80004b2c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b30:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b34:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b38:	f5796ee3          	bltu	s2,s7,80004a94 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b3c:	e9040613          	addi	a2,s0,-368
    80004b40:	85ca                	mv	a1,s2
    80004b42:	855a                	mv	a0,s6
    80004b44:	a9ffc0ef          	jal	800015e2 <copyout>
    80004b48:	0e054263          	bltz	a0,80004c2c <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004b4c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b50:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b54:	df843783          	ld	a5,-520(s0)
    80004b58:	0007c703          	lbu	a4,0(a5)
    80004b5c:	cf11                	beqz	a4,80004b78 <kexec+0x2b8>
    80004b5e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b60:	02f00693          	li	a3,47
    80004b64:	a039                	j	80004b72 <kexec+0x2b2>
      last = s+1;
    80004b66:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004b6a:	0785                	addi	a5,a5,1
    80004b6c:	fff7c703          	lbu	a4,-1(a5)
    80004b70:	c701                	beqz	a4,80004b78 <kexec+0x2b8>
    if(*s == '/')
    80004b72:	fed71ce3          	bne	a4,a3,80004b6a <kexec+0x2aa>
    80004b76:	bfc5                	j	80004b66 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b78:	4641                	li	a2,16
    80004b7a:	df843583          	ld	a1,-520(s0)
    80004b7e:	158a8513          	addi	a0,s5,344
    80004b82:	a5efc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b86:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b8a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b8e:	e0843783          	ld	a5,-504(s0)
    80004b92:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b96:	058ab783          	ld	a5,88(s5)
    80004b9a:	e6843703          	ld	a4,-408(s0)
    80004b9e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ba0:	058ab783          	ld	a5,88(s5)
    80004ba4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ba8:	85e6                	mv	a1,s9
    80004baa:	8aafd0ef          	jal	80001c54 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004bae:	0004851b          	sext.w	a0,s1
    80004bb2:	79be                	ld	s3,488(sp)
    80004bb4:	7a1e                	ld	s4,480(sp)
    80004bb6:	6afe                	ld	s5,472(sp)
    80004bb8:	6b5e                	ld	s6,464(sp)
    80004bba:	6bbe                	ld	s7,456(sp)
    80004bbc:	6c1e                	ld	s8,448(sp)
    80004bbe:	7cfa                	ld	s9,440(sp)
    80004bc0:	7d5a                	ld	s10,432(sp)
    80004bc2:	b3b5                	j	8000492e <kexec+0x6e>
    80004bc4:	e1243423          	sd	s2,-504(s0)
    80004bc8:	7dba                	ld	s11,424(sp)
    80004bca:	a035                	j	80004bf6 <kexec+0x336>
    80004bcc:	e1243423          	sd	s2,-504(s0)
    80004bd0:	7dba                	ld	s11,424(sp)
    80004bd2:	a015                	j	80004bf6 <kexec+0x336>
    80004bd4:	e1243423          	sd	s2,-504(s0)
    80004bd8:	7dba                	ld	s11,424(sp)
    80004bda:	a831                	j	80004bf6 <kexec+0x336>
    80004bdc:	e1243423          	sd	s2,-504(s0)
    80004be0:	7dba                	ld	s11,424(sp)
    80004be2:	a811                	j	80004bf6 <kexec+0x336>
    80004be4:	e1243423          	sd	s2,-504(s0)
    80004be8:	7dba                	ld	s11,424(sp)
    80004bea:	a031                	j	80004bf6 <kexec+0x336>
  ip = 0;
    80004bec:	4a01                	li	s4,0
    80004bee:	a021                	j	80004bf6 <kexec+0x336>
    80004bf0:	4a01                	li	s4,0
  if(pagetable)
    80004bf2:	a011                	j	80004bf6 <kexec+0x336>
    80004bf4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004bf6:	e0843583          	ld	a1,-504(s0)
    80004bfa:	855a                	mv	a0,s6
    80004bfc:	858fd0ef          	jal	80001c54 <proc_freepagetable>
  return -1;
    80004c00:	557d                	li	a0,-1
  if(ip){
    80004c02:	000a1b63          	bnez	s4,80004c18 <kexec+0x358>
    80004c06:	79be                	ld	s3,488(sp)
    80004c08:	7a1e                	ld	s4,480(sp)
    80004c0a:	6afe                	ld	s5,472(sp)
    80004c0c:	6b5e                	ld	s6,464(sp)
    80004c0e:	6bbe                	ld	s7,456(sp)
    80004c10:	6c1e                	ld	s8,448(sp)
    80004c12:	7cfa                	ld	s9,440(sp)
    80004c14:	7d5a                	ld	s10,432(sp)
    80004c16:	bb21                	j	8000492e <kexec+0x6e>
    80004c18:	79be                	ld	s3,488(sp)
    80004c1a:	6afe                	ld	s5,472(sp)
    80004c1c:	6b5e                	ld	s6,464(sp)
    80004c1e:	6bbe                	ld	s7,456(sp)
    80004c20:	6c1e                	ld	s8,448(sp)
    80004c22:	7cfa                	ld	s9,440(sp)
    80004c24:	7d5a                	ld	s10,432(sp)
    80004c26:	b9ed                	j	80004920 <kexec+0x60>
    80004c28:	6b5e                	ld	s6,464(sp)
    80004c2a:	b9dd                	j	80004920 <kexec+0x60>
  sz = sz1;
    80004c2c:	e0843983          	ld	s3,-504(s0)
    80004c30:	b595                	j	80004a94 <kexec+0x1d4>

0000000080004c32 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c32:	7179                	addi	sp,sp,-48
    80004c34:	f406                	sd	ra,40(sp)
    80004c36:	f022                	sd	s0,32(sp)
    80004c38:	ec26                	sd	s1,24(sp)
    80004c3a:	e84a                	sd	s2,16(sp)
    80004c3c:	1800                	addi	s0,sp,48
    80004c3e:	892e                	mv	s2,a1
    80004c40:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c42:	fdc40593          	addi	a1,s0,-36
    80004c46:	e17fd0ef          	jal	80002a5c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c4a:	fdc42703          	lw	a4,-36(s0)
    80004c4e:	47bd                	li	a5,15
    80004c50:	02e7e963          	bltu	a5,a4,80004c82 <argfd+0x50>
    80004c54:	e77fc0ef          	jal	80001aca <myproc>
    80004c58:	fdc42703          	lw	a4,-36(s0)
    80004c5c:	01a70793          	addi	a5,a4,26
    80004c60:	078e                	slli	a5,a5,0x3
    80004c62:	953e                	add	a0,a0,a5
    80004c64:	611c                	ld	a5,0(a0)
    80004c66:	c385                	beqz	a5,80004c86 <argfd+0x54>
    return -1;
  if(pfd)
    80004c68:	00090463          	beqz	s2,80004c70 <argfd+0x3e>
    *pfd = fd;
    80004c6c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c70:	4501                	li	a0,0
  if(pf)
    80004c72:	c091                	beqz	s1,80004c76 <argfd+0x44>
    *pf = f;
    80004c74:	e09c                	sd	a5,0(s1)
}
    80004c76:	70a2                	ld	ra,40(sp)
    80004c78:	7402                	ld	s0,32(sp)
    80004c7a:	64e2                	ld	s1,24(sp)
    80004c7c:	6942                	ld	s2,16(sp)
    80004c7e:	6145                	addi	sp,sp,48
    80004c80:	8082                	ret
    return -1;
    80004c82:	557d                	li	a0,-1
    80004c84:	bfcd                	j	80004c76 <argfd+0x44>
    80004c86:	557d                	li	a0,-1
    80004c88:	b7fd                	j	80004c76 <argfd+0x44>

0000000080004c8a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c8a:	1101                	addi	sp,sp,-32
    80004c8c:	ec06                	sd	ra,24(sp)
    80004c8e:	e822                	sd	s0,16(sp)
    80004c90:	e426                	sd	s1,8(sp)
    80004c92:	1000                	addi	s0,sp,32
    80004c94:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c96:	e35fc0ef          	jal	80001aca <myproc>
    80004c9a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c9c:	0d050793          	addi	a5,a0,208
    80004ca0:	4501                	li	a0,0
    80004ca2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ca4:	6398                	ld	a4,0(a5)
    80004ca6:	cb19                	beqz	a4,80004cbc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ca8:	2505                	addiw	a0,a0,1
    80004caa:	07a1                	addi	a5,a5,8
    80004cac:	fed51ce3          	bne	a0,a3,80004ca4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004cb0:	557d                	li	a0,-1
}
    80004cb2:	60e2                	ld	ra,24(sp)
    80004cb4:	6442                	ld	s0,16(sp)
    80004cb6:	64a2                	ld	s1,8(sp)
    80004cb8:	6105                	addi	sp,sp,32
    80004cba:	8082                	ret
      p->ofile[fd] = f;
    80004cbc:	01a50793          	addi	a5,a0,26
    80004cc0:	078e                	slli	a5,a5,0x3
    80004cc2:	963e                	add	a2,a2,a5
    80004cc4:	e204                	sd	s1,0(a2)
      return fd;
    80004cc6:	b7f5                	j	80004cb2 <fdalloc+0x28>

0000000080004cc8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004cc8:	715d                	addi	sp,sp,-80
    80004cca:	e486                	sd	ra,72(sp)
    80004ccc:	e0a2                	sd	s0,64(sp)
    80004cce:	fc26                	sd	s1,56(sp)
    80004cd0:	f84a                	sd	s2,48(sp)
    80004cd2:	f44e                	sd	s3,40(sp)
    80004cd4:	ec56                	sd	s5,24(sp)
    80004cd6:	e85a                	sd	s6,16(sp)
    80004cd8:	0880                	addi	s0,sp,80
    80004cda:	8b2e                	mv	s6,a1
    80004cdc:	89b2                	mv	s3,a2
    80004cde:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ce0:	fb040593          	addi	a1,s0,-80
    80004ce4:	80eff0ef          	jal	80003cf2 <nameiparent>
    80004ce8:	84aa                	mv	s1,a0
    80004cea:	10050a63          	beqz	a0,80004dfe <create+0x136>
    return 0;

  ilock(dp);
    80004cee:	fd4fe0ef          	jal	800034c2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cf2:	4601                	li	a2,0
    80004cf4:	fb040593          	addi	a1,s0,-80
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	d79fe0ef          	jal	80003a72 <dirlookup>
    80004cfe:	8aaa                	mv	s5,a0
    80004d00:	c129                	beqz	a0,80004d42 <create+0x7a>
    iunlockput(dp);
    80004d02:	8526                	mv	a0,s1
    80004d04:	9c9fe0ef          	jal	800036cc <iunlockput>
    ilock(ip);
    80004d08:	8556                	mv	a0,s5
    80004d0a:	fb8fe0ef          	jal	800034c2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d0e:	4789                	li	a5,2
    80004d10:	02fb1463          	bne	s6,a5,80004d38 <create+0x70>
    80004d14:	044ad783          	lhu	a5,68(s5)
    80004d18:	37f9                	addiw	a5,a5,-2
    80004d1a:	17c2                	slli	a5,a5,0x30
    80004d1c:	93c1                	srli	a5,a5,0x30
    80004d1e:	4705                	li	a4,1
    80004d20:	00f76c63          	bltu	a4,a5,80004d38 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d24:	8556                	mv	a0,s5
    80004d26:	60a6                	ld	ra,72(sp)
    80004d28:	6406                	ld	s0,64(sp)
    80004d2a:	74e2                	ld	s1,56(sp)
    80004d2c:	7942                	ld	s2,48(sp)
    80004d2e:	79a2                	ld	s3,40(sp)
    80004d30:	6ae2                	ld	s5,24(sp)
    80004d32:	6b42                	ld	s6,16(sp)
    80004d34:	6161                	addi	sp,sp,80
    80004d36:	8082                	ret
    iunlockput(ip);
    80004d38:	8556                	mv	a0,s5
    80004d3a:	993fe0ef          	jal	800036cc <iunlockput>
    return 0;
    80004d3e:	4a81                	li	s5,0
    80004d40:	b7d5                	j	80004d24 <create+0x5c>
    80004d42:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d44:	85da                	mv	a1,s6
    80004d46:	4088                	lw	a0,0(s1)
    80004d48:	e0afe0ef          	jal	80003352 <ialloc>
    80004d4c:	8a2a                	mv	s4,a0
    80004d4e:	cd15                	beqz	a0,80004d8a <create+0xc2>
  ilock(ip);
    80004d50:	f72fe0ef          	jal	800034c2 <ilock>
  ip->major = major;
    80004d54:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d58:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d5c:	4905                	li	s2,1
    80004d5e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d62:	8552                	mv	a0,s4
    80004d64:	eaafe0ef          	jal	8000340e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d68:	032b0763          	beq	s6,s2,80004d96 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d6c:	004a2603          	lw	a2,4(s4)
    80004d70:	fb040593          	addi	a1,s0,-80
    80004d74:	8526                	mv	a0,s1
    80004d76:	ec9fe0ef          	jal	80003c3e <dirlink>
    80004d7a:	06054563          	bltz	a0,80004de4 <create+0x11c>
  iunlockput(dp);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	94dfe0ef          	jal	800036cc <iunlockput>
  return ip;
    80004d84:	8ad2                	mv	s5,s4
    80004d86:	7a02                	ld	s4,32(sp)
    80004d88:	bf71                	j	80004d24 <create+0x5c>
    iunlockput(dp);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	941fe0ef          	jal	800036cc <iunlockput>
    return 0;
    80004d90:	8ad2                	mv	s5,s4
    80004d92:	7a02                	ld	s4,32(sp)
    80004d94:	bf41                	j	80004d24 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d96:	004a2603          	lw	a2,4(s4)
    80004d9a:	00003597          	auipc	a1,0x3
    80004d9e:	82658593          	addi	a1,a1,-2010 # 800075c0 <etext+0x5c0>
    80004da2:	8552                	mv	a0,s4
    80004da4:	e9bfe0ef          	jal	80003c3e <dirlink>
    80004da8:	02054e63          	bltz	a0,80004de4 <create+0x11c>
    80004dac:	40d0                	lw	a2,4(s1)
    80004dae:	00003597          	auipc	a1,0x3
    80004db2:	81a58593          	addi	a1,a1,-2022 # 800075c8 <etext+0x5c8>
    80004db6:	8552                	mv	a0,s4
    80004db8:	e87fe0ef          	jal	80003c3e <dirlink>
    80004dbc:	02054463          	bltz	a0,80004de4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004dc0:	004a2603          	lw	a2,4(s4)
    80004dc4:	fb040593          	addi	a1,s0,-80
    80004dc8:	8526                	mv	a0,s1
    80004dca:	e75fe0ef          	jal	80003c3e <dirlink>
    80004dce:	00054b63          	bltz	a0,80004de4 <create+0x11c>
    dp->nlink++;  // for ".."
    80004dd2:	04a4d783          	lhu	a5,74(s1)
    80004dd6:	2785                	addiw	a5,a5,1
    80004dd8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	e30fe0ef          	jal	8000340e <iupdate>
    80004de2:	bf71                	j	80004d7e <create+0xb6>
  ip->nlink = 0;
    80004de4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004de8:	8552                	mv	a0,s4
    80004dea:	e24fe0ef          	jal	8000340e <iupdate>
  iunlockput(ip);
    80004dee:	8552                	mv	a0,s4
    80004df0:	8ddfe0ef          	jal	800036cc <iunlockput>
  iunlockput(dp);
    80004df4:	8526                	mv	a0,s1
    80004df6:	8d7fe0ef          	jal	800036cc <iunlockput>
  return 0;
    80004dfa:	7a02                	ld	s4,32(sp)
    80004dfc:	b725                	j	80004d24 <create+0x5c>
    return 0;
    80004dfe:	8aaa                	mv	s5,a0
    80004e00:	b715                	j	80004d24 <create+0x5c>

0000000080004e02 <sys_dup>:
{
    80004e02:	7179                	addi	sp,sp,-48
    80004e04:	f406                	sd	ra,40(sp)
    80004e06:	f022                	sd	s0,32(sp)
    80004e08:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e0a:	fd840613          	addi	a2,s0,-40
    80004e0e:	4581                	li	a1,0
    80004e10:	4501                	li	a0,0
    80004e12:	e21ff0ef          	jal	80004c32 <argfd>
    return -1;
    80004e16:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e18:	02054363          	bltz	a0,80004e3e <sys_dup+0x3c>
    80004e1c:	ec26                	sd	s1,24(sp)
    80004e1e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e20:	fd843903          	ld	s2,-40(s0)
    80004e24:	854a                	mv	a0,s2
    80004e26:	e65ff0ef          	jal	80004c8a <fdalloc>
    80004e2a:	84aa                	mv	s1,a0
    return -1;
    80004e2c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e2e:	00054d63          	bltz	a0,80004e48 <sys_dup+0x46>
  filedup(f);
    80004e32:	854a                	mv	a0,s2
    80004e34:	c3eff0ef          	jal	80004272 <filedup>
  return fd;
    80004e38:	87a6                	mv	a5,s1
    80004e3a:	64e2                	ld	s1,24(sp)
    80004e3c:	6942                	ld	s2,16(sp)
}
    80004e3e:	853e                	mv	a0,a5
    80004e40:	70a2                	ld	ra,40(sp)
    80004e42:	7402                	ld	s0,32(sp)
    80004e44:	6145                	addi	sp,sp,48
    80004e46:	8082                	ret
    80004e48:	64e2                	ld	s1,24(sp)
    80004e4a:	6942                	ld	s2,16(sp)
    80004e4c:	bfcd                	j	80004e3e <sys_dup+0x3c>

0000000080004e4e <sys_read>:
{
    80004e4e:	7179                	addi	sp,sp,-48
    80004e50:	f406                	sd	ra,40(sp)
    80004e52:	f022                	sd	s0,32(sp)
    80004e54:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e56:	fd840593          	addi	a1,s0,-40
    80004e5a:	4505                	li	a0,1
    80004e5c:	c1dfd0ef          	jal	80002a78 <argaddr>
  argint(2, &n);
    80004e60:	fe440593          	addi	a1,s0,-28
    80004e64:	4509                	li	a0,2
    80004e66:	bf7fd0ef          	jal	80002a5c <argint>
  if(argfd(0, 0, &f) < 0)
    80004e6a:	fe840613          	addi	a2,s0,-24
    80004e6e:	4581                	li	a1,0
    80004e70:	4501                	li	a0,0
    80004e72:	dc1ff0ef          	jal	80004c32 <argfd>
    80004e76:	87aa                	mv	a5,a0
    return -1;
    80004e78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e7a:	0007ca63          	bltz	a5,80004e8e <sys_read+0x40>
  return fileread(f, p, n);
    80004e7e:	fe442603          	lw	a2,-28(s0)
    80004e82:	fd843583          	ld	a1,-40(s0)
    80004e86:	fe843503          	ld	a0,-24(s0)
    80004e8a:	d4eff0ef          	jal	800043d8 <fileread>
}
    80004e8e:	70a2                	ld	ra,40(sp)
    80004e90:	7402                	ld	s0,32(sp)
    80004e92:	6145                	addi	sp,sp,48
    80004e94:	8082                	ret

0000000080004e96 <sys_write>:
{
    80004e96:	7179                	addi	sp,sp,-48
    80004e98:	f406                	sd	ra,40(sp)
    80004e9a:	f022                	sd	s0,32(sp)
    80004e9c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e9e:	fd840593          	addi	a1,s0,-40
    80004ea2:	4505                	li	a0,1
    80004ea4:	bd5fd0ef          	jal	80002a78 <argaddr>
  argint(2, &n);
    80004ea8:	fe440593          	addi	a1,s0,-28
    80004eac:	4509                	li	a0,2
    80004eae:	baffd0ef          	jal	80002a5c <argint>
  if(argfd(0, 0, &f) < 0)
    80004eb2:	fe840613          	addi	a2,s0,-24
    80004eb6:	4581                	li	a1,0
    80004eb8:	4501                	li	a0,0
    80004eba:	d79ff0ef          	jal	80004c32 <argfd>
    80004ebe:	87aa                	mv	a5,a0
    return -1;
    80004ec0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ec2:	0007ca63          	bltz	a5,80004ed6 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ec6:	fe442603          	lw	a2,-28(s0)
    80004eca:	fd843583          	ld	a1,-40(s0)
    80004ece:	fe843503          	ld	a0,-24(s0)
    80004ed2:	dc4ff0ef          	jal	80004496 <filewrite>
}
    80004ed6:	70a2                	ld	ra,40(sp)
    80004ed8:	7402                	ld	s0,32(sp)
    80004eda:	6145                	addi	sp,sp,48
    80004edc:	8082                	ret

0000000080004ede <sys_close>:
{
    80004ede:	1101                	addi	sp,sp,-32
    80004ee0:	ec06                	sd	ra,24(sp)
    80004ee2:	e822                	sd	s0,16(sp)
    80004ee4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ee6:	fe040613          	addi	a2,s0,-32
    80004eea:	fec40593          	addi	a1,s0,-20
    80004eee:	4501                	li	a0,0
    80004ef0:	d43ff0ef          	jal	80004c32 <argfd>
    return -1;
    80004ef4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ef6:	02054063          	bltz	a0,80004f16 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004efa:	bd1fc0ef          	jal	80001aca <myproc>
    80004efe:	fec42783          	lw	a5,-20(s0)
    80004f02:	07e9                	addi	a5,a5,26
    80004f04:	078e                	slli	a5,a5,0x3
    80004f06:	953e                	add	a0,a0,a5
    80004f08:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f0c:	fe043503          	ld	a0,-32(s0)
    80004f10:	ba8ff0ef          	jal	800042b8 <fileclose>
  return 0;
    80004f14:	4781                	li	a5,0
}
    80004f16:	853e                	mv	a0,a5
    80004f18:	60e2                	ld	ra,24(sp)
    80004f1a:	6442                	ld	s0,16(sp)
    80004f1c:	6105                	addi	sp,sp,32
    80004f1e:	8082                	ret

0000000080004f20 <sys_fstat>:
{
    80004f20:	1101                	addi	sp,sp,-32
    80004f22:	ec06                	sd	ra,24(sp)
    80004f24:	e822                	sd	s0,16(sp)
    80004f26:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f28:	fe040593          	addi	a1,s0,-32
    80004f2c:	4505                	li	a0,1
    80004f2e:	b4bfd0ef          	jal	80002a78 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f32:	fe840613          	addi	a2,s0,-24
    80004f36:	4581                	li	a1,0
    80004f38:	4501                	li	a0,0
    80004f3a:	cf9ff0ef          	jal	80004c32 <argfd>
    80004f3e:	87aa                	mv	a5,a0
    return -1;
    80004f40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f42:	0007c863          	bltz	a5,80004f52 <sys_fstat+0x32>
  return filestat(f, st);
    80004f46:	fe043583          	ld	a1,-32(s0)
    80004f4a:	fe843503          	ld	a0,-24(s0)
    80004f4e:	c2cff0ef          	jal	8000437a <filestat>
}
    80004f52:	60e2                	ld	ra,24(sp)
    80004f54:	6442                	ld	s0,16(sp)
    80004f56:	6105                	addi	sp,sp,32
    80004f58:	8082                	ret

0000000080004f5a <sys_link>:
{
    80004f5a:	7169                	addi	sp,sp,-304
    80004f5c:	f606                	sd	ra,296(sp)
    80004f5e:	f222                	sd	s0,288(sp)
    80004f60:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f62:	08000613          	li	a2,128
    80004f66:	ed040593          	addi	a1,s0,-304
    80004f6a:	4501                	li	a0,0
    80004f6c:	b29fd0ef          	jal	80002a94 <argstr>
    return -1;
    80004f70:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f72:	0c054e63          	bltz	a0,8000504e <sys_link+0xf4>
    80004f76:	08000613          	li	a2,128
    80004f7a:	f5040593          	addi	a1,s0,-176
    80004f7e:	4505                	li	a0,1
    80004f80:	b15fd0ef          	jal	80002a94 <argstr>
    return -1;
    80004f84:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f86:	0c054463          	bltz	a0,8000504e <sys_link+0xf4>
    80004f8a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f8c:	f21fe0ef          	jal	80003eac <begin_op>
  if((ip = namei(old)) == 0){
    80004f90:	ed040513          	addi	a0,s0,-304
    80004f94:	d45fe0ef          	jal	80003cd8 <namei>
    80004f98:	84aa                	mv	s1,a0
    80004f9a:	c53d                	beqz	a0,80005008 <sys_link+0xae>
  ilock(ip);
    80004f9c:	d26fe0ef          	jal	800034c2 <ilock>
  if(ip->type == T_DIR){
    80004fa0:	04449703          	lh	a4,68(s1)
    80004fa4:	4785                	li	a5,1
    80004fa6:	06f70663          	beq	a4,a5,80005012 <sys_link+0xb8>
    80004faa:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004fac:	04a4d783          	lhu	a5,74(s1)
    80004fb0:	2785                	addiw	a5,a5,1
    80004fb2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	c56fe0ef          	jal	8000340e <iupdate>
  iunlock(ip);
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	db2fe0ef          	jal	80003570 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004fc2:	fd040593          	addi	a1,s0,-48
    80004fc6:	f5040513          	addi	a0,s0,-176
    80004fca:	d29fe0ef          	jal	80003cf2 <nameiparent>
    80004fce:	892a                	mv	s2,a0
    80004fd0:	cd21                	beqz	a0,80005028 <sys_link+0xce>
  ilock(dp);
    80004fd2:	cf0fe0ef          	jal	800034c2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004fd6:	00092703          	lw	a4,0(s2)
    80004fda:	409c                	lw	a5,0(s1)
    80004fdc:	04f71363          	bne	a4,a5,80005022 <sys_link+0xc8>
    80004fe0:	40d0                	lw	a2,4(s1)
    80004fe2:	fd040593          	addi	a1,s0,-48
    80004fe6:	854a                	mv	a0,s2
    80004fe8:	c57fe0ef          	jal	80003c3e <dirlink>
    80004fec:	02054b63          	bltz	a0,80005022 <sys_link+0xc8>
  iunlockput(dp);
    80004ff0:	854a                	mv	a0,s2
    80004ff2:	edafe0ef          	jal	800036cc <iunlockput>
  iput(ip);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	e4cfe0ef          	jal	80003644 <iput>
  end_op();
    80004ffc:	f1bfe0ef          	jal	80003f16 <end_op>
  return 0;
    80005000:	4781                	li	a5,0
    80005002:	64f2                	ld	s1,280(sp)
    80005004:	6952                	ld	s2,272(sp)
    80005006:	a0a1                	j	8000504e <sys_link+0xf4>
    end_op();
    80005008:	f0ffe0ef          	jal	80003f16 <end_op>
    return -1;
    8000500c:	57fd                	li	a5,-1
    8000500e:	64f2                	ld	s1,280(sp)
    80005010:	a83d                	j	8000504e <sys_link+0xf4>
    iunlockput(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	eb8fe0ef          	jal	800036cc <iunlockput>
    end_op();
    80005018:	efffe0ef          	jal	80003f16 <end_op>
    return -1;
    8000501c:	57fd                	li	a5,-1
    8000501e:	64f2                	ld	s1,280(sp)
    80005020:	a03d                	j	8000504e <sys_link+0xf4>
    iunlockput(dp);
    80005022:	854a                	mv	a0,s2
    80005024:	ea8fe0ef          	jal	800036cc <iunlockput>
  ilock(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	c98fe0ef          	jal	800034c2 <ilock>
  ip->nlink--;
    8000502e:	04a4d783          	lhu	a5,74(s1)
    80005032:	37fd                	addiw	a5,a5,-1
    80005034:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005038:	8526                	mv	a0,s1
    8000503a:	bd4fe0ef          	jal	8000340e <iupdate>
  iunlockput(ip);
    8000503e:	8526                	mv	a0,s1
    80005040:	e8cfe0ef          	jal	800036cc <iunlockput>
  end_op();
    80005044:	ed3fe0ef          	jal	80003f16 <end_op>
  return -1;
    80005048:	57fd                	li	a5,-1
    8000504a:	64f2                	ld	s1,280(sp)
    8000504c:	6952                	ld	s2,272(sp)
}
    8000504e:	853e                	mv	a0,a5
    80005050:	70b2                	ld	ra,296(sp)
    80005052:	7412                	ld	s0,288(sp)
    80005054:	6155                	addi	sp,sp,304
    80005056:	8082                	ret

0000000080005058 <sys_unlink>:
{
    80005058:	7151                	addi	sp,sp,-240
    8000505a:	f586                	sd	ra,232(sp)
    8000505c:	f1a2                	sd	s0,224(sp)
    8000505e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005060:	08000613          	li	a2,128
    80005064:	f3040593          	addi	a1,s0,-208
    80005068:	4501                	li	a0,0
    8000506a:	a2bfd0ef          	jal	80002a94 <argstr>
    8000506e:	16054063          	bltz	a0,800051ce <sys_unlink+0x176>
    80005072:	eda6                	sd	s1,216(sp)
  begin_op();
    80005074:	e39fe0ef          	jal	80003eac <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005078:	fb040593          	addi	a1,s0,-80
    8000507c:	f3040513          	addi	a0,s0,-208
    80005080:	c73fe0ef          	jal	80003cf2 <nameiparent>
    80005084:	84aa                	mv	s1,a0
    80005086:	c945                	beqz	a0,80005136 <sys_unlink+0xde>
  ilock(dp);
    80005088:	c3afe0ef          	jal	800034c2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000508c:	00002597          	auipc	a1,0x2
    80005090:	53458593          	addi	a1,a1,1332 # 800075c0 <etext+0x5c0>
    80005094:	fb040513          	addi	a0,s0,-80
    80005098:	9c5fe0ef          	jal	80003a5c <namecmp>
    8000509c:	10050e63          	beqz	a0,800051b8 <sys_unlink+0x160>
    800050a0:	00002597          	auipc	a1,0x2
    800050a4:	52858593          	addi	a1,a1,1320 # 800075c8 <etext+0x5c8>
    800050a8:	fb040513          	addi	a0,s0,-80
    800050ac:	9b1fe0ef          	jal	80003a5c <namecmp>
    800050b0:	10050463          	beqz	a0,800051b8 <sys_unlink+0x160>
    800050b4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800050b6:	f2c40613          	addi	a2,s0,-212
    800050ba:	fb040593          	addi	a1,s0,-80
    800050be:	8526                	mv	a0,s1
    800050c0:	9b3fe0ef          	jal	80003a72 <dirlookup>
    800050c4:	892a                	mv	s2,a0
    800050c6:	0e050863          	beqz	a0,800051b6 <sys_unlink+0x15e>
  ilock(ip);
    800050ca:	bf8fe0ef          	jal	800034c2 <ilock>
  if(ip->nlink < 1)
    800050ce:	04a91783          	lh	a5,74(s2)
    800050d2:	06f05763          	blez	a5,80005140 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800050d6:	04491703          	lh	a4,68(s2)
    800050da:	4785                	li	a5,1
    800050dc:	06f70963          	beq	a4,a5,8000514e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800050e0:	4641                	li	a2,16
    800050e2:	4581                	li	a1,0
    800050e4:	fc040513          	addi	a0,s0,-64
    800050e8:	bbbfb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050ec:	4741                	li	a4,16
    800050ee:	f2c42683          	lw	a3,-212(s0)
    800050f2:	fc040613          	addi	a2,s0,-64
    800050f6:	4581                	li	a1,0
    800050f8:	8526                	mv	a0,s1
    800050fa:	855fe0ef          	jal	8000394e <writei>
    800050fe:	47c1                	li	a5,16
    80005100:	08f51b63          	bne	a0,a5,80005196 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005104:	04491703          	lh	a4,68(s2)
    80005108:	4785                	li	a5,1
    8000510a:	08f70d63          	beq	a4,a5,800051a4 <sys_unlink+0x14c>
  iunlockput(dp);
    8000510e:	8526                	mv	a0,s1
    80005110:	dbcfe0ef          	jal	800036cc <iunlockput>
  ip->nlink--;
    80005114:	04a95783          	lhu	a5,74(s2)
    80005118:	37fd                	addiw	a5,a5,-1
    8000511a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000511e:	854a                	mv	a0,s2
    80005120:	aeefe0ef          	jal	8000340e <iupdate>
  iunlockput(ip);
    80005124:	854a                	mv	a0,s2
    80005126:	da6fe0ef          	jal	800036cc <iunlockput>
  end_op();
    8000512a:	dedfe0ef          	jal	80003f16 <end_op>
  return 0;
    8000512e:	4501                	li	a0,0
    80005130:	64ee                	ld	s1,216(sp)
    80005132:	694e                	ld	s2,208(sp)
    80005134:	a849                	j	800051c6 <sys_unlink+0x16e>
    end_op();
    80005136:	de1fe0ef          	jal	80003f16 <end_op>
    return -1;
    8000513a:	557d                	li	a0,-1
    8000513c:	64ee                	ld	s1,216(sp)
    8000513e:	a061                	j	800051c6 <sys_unlink+0x16e>
    80005140:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005142:	00002517          	auipc	a0,0x2
    80005146:	48e50513          	addi	a0,a0,1166 # 800075d0 <etext+0x5d0>
    8000514a:	e96fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000514e:	04c92703          	lw	a4,76(s2)
    80005152:	02000793          	li	a5,32
    80005156:	f8e7f5e3          	bgeu	a5,a4,800050e0 <sys_unlink+0x88>
    8000515a:	e5ce                	sd	s3,200(sp)
    8000515c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005160:	4741                	li	a4,16
    80005162:	86ce                	mv	a3,s3
    80005164:	f1840613          	addi	a2,s0,-232
    80005168:	4581                	li	a1,0
    8000516a:	854a                	mv	a0,s2
    8000516c:	ee6fe0ef          	jal	80003852 <readi>
    80005170:	47c1                	li	a5,16
    80005172:	00f51c63          	bne	a0,a5,8000518a <sys_unlink+0x132>
    if(de.inum != 0)
    80005176:	f1845783          	lhu	a5,-232(s0)
    8000517a:	efa1                	bnez	a5,800051d2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000517c:	29c1                	addiw	s3,s3,16
    8000517e:	04c92783          	lw	a5,76(s2)
    80005182:	fcf9efe3          	bltu	s3,a5,80005160 <sys_unlink+0x108>
    80005186:	69ae                	ld	s3,200(sp)
    80005188:	bfa1                	j	800050e0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000518a:	00002517          	auipc	a0,0x2
    8000518e:	45e50513          	addi	a0,a0,1118 # 800075e8 <etext+0x5e8>
    80005192:	e4efb0ef          	jal	800007e0 <panic>
    80005196:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005198:	00002517          	auipc	a0,0x2
    8000519c:	46850513          	addi	a0,a0,1128 # 80007600 <etext+0x600>
    800051a0:	e40fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    800051a4:	04a4d783          	lhu	a5,74(s1)
    800051a8:	37fd                	addiw	a5,a5,-1
    800051aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051ae:	8526                	mv	a0,s1
    800051b0:	a5efe0ef          	jal	8000340e <iupdate>
    800051b4:	bfa9                	j	8000510e <sys_unlink+0xb6>
    800051b6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051b8:	8526                	mv	a0,s1
    800051ba:	d12fe0ef          	jal	800036cc <iunlockput>
  end_op();
    800051be:	d59fe0ef          	jal	80003f16 <end_op>
  return -1;
    800051c2:	557d                	li	a0,-1
    800051c4:	64ee                	ld	s1,216(sp)
}
    800051c6:	70ae                	ld	ra,232(sp)
    800051c8:	740e                	ld	s0,224(sp)
    800051ca:	616d                	addi	sp,sp,240
    800051cc:	8082                	ret
    return -1;
    800051ce:	557d                	li	a0,-1
    800051d0:	bfdd                	j	800051c6 <sys_unlink+0x16e>
    iunlockput(ip);
    800051d2:	854a                	mv	a0,s2
    800051d4:	cf8fe0ef          	jal	800036cc <iunlockput>
    goto bad;
    800051d8:	694e                	ld	s2,208(sp)
    800051da:	69ae                	ld	s3,200(sp)
    800051dc:	bff1                	j	800051b8 <sys_unlink+0x160>

00000000800051de <sys_open>:

uint64
sys_open(void)
{
    800051de:	7131                	addi	sp,sp,-192
    800051e0:	fd06                	sd	ra,184(sp)
    800051e2:	f922                	sd	s0,176(sp)
    800051e4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051e6:	f4c40593          	addi	a1,s0,-180
    800051ea:	4505                	li	a0,1
    800051ec:	871fd0ef          	jal	80002a5c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051f0:	08000613          	li	a2,128
    800051f4:	f5040593          	addi	a1,s0,-176
    800051f8:	4501                	li	a0,0
    800051fa:	89bfd0ef          	jal	80002a94 <argstr>
    800051fe:	87aa                	mv	a5,a0
    return -1;
    80005200:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005202:	0a07c263          	bltz	a5,800052a6 <sys_open+0xc8>
    80005206:	f526                	sd	s1,168(sp)

  begin_op();
    80005208:	ca5fe0ef          	jal	80003eac <begin_op>

  if(omode & O_CREATE){
    8000520c:	f4c42783          	lw	a5,-180(s0)
    80005210:	2007f793          	andi	a5,a5,512
    80005214:	c3d5                	beqz	a5,800052b8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005216:	4681                	li	a3,0
    80005218:	4601                	li	a2,0
    8000521a:	4589                	li	a1,2
    8000521c:	f5040513          	addi	a0,s0,-176
    80005220:	aa9ff0ef          	jal	80004cc8 <create>
    80005224:	84aa                	mv	s1,a0
    if(ip == 0){
    80005226:	c541                	beqz	a0,800052ae <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005228:	04449703          	lh	a4,68(s1)
    8000522c:	478d                	li	a5,3
    8000522e:	00f71763          	bne	a4,a5,8000523c <sys_open+0x5e>
    80005232:	0464d703          	lhu	a4,70(s1)
    80005236:	47a5                	li	a5,9
    80005238:	0ae7ed63          	bltu	a5,a4,800052f2 <sys_open+0x114>
    8000523c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000523e:	fd7fe0ef          	jal	80004214 <filealloc>
    80005242:	892a                	mv	s2,a0
    80005244:	c179                	beqz	a0,8000530a <sys_open+0x12c>
    80005246:	ed4e                	sd	s3,152(sp)
    80005248:	a43ff0ef          	jal	80004c8a <fdalloc>
    8000524c:	89aa                	mv	s3,a0
    8000524e:	0a054a63          	bltz	a0,80005302 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005252:	04449703          	lh	a4,68(s1)
    80005256:	478d                	li	a5,3
    80005258:	0cf70263          	beq	a4,a5,8000531c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000525c:	4789                	li	a5,2
    8000525e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005262:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005266:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000526a:	f4c42783          	lw	a5,-180(s0)
    8000526e:	0017c713          	xori	a4,a5,1
    80005272:	8b05                	andi	a4,a4,1
    80005274:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005278:	0037f713          	andi	a4,a5,3
    8000527c:	00e03733          	snez	a4,a4
    80005280:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005284:	4007f793          	andi	a5,a5,1024
    80005288:	c791                	beqz	a5,80005294 <sys_open+0xb6>
    8000528a:	04449703          	lh	a4,68(s1)
    8000528e:	4789                	li	a5,2
    80005290:	08f70d63          	beq	a4,a5,8000532a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005294:	8526                	mv	a0,s1
    80005296:	adafe0ef          	jal	80003570 <iunlock>
  end_op();
    8000529a:	c7dfe0ef          	jal	80003f16 <end_op>

  return fd;
    8000529e:	854e                	mv	a0,s3
    800052a0:	74aa                	ld	s1,168(sp)
    800052a2:	790a                	ld	s2,160(sp)
    800052a4:	69ea                	ld	s3,152(sp)
}
    800052a6:	70ea                	ld	ra,184(sp)
    800052a8:	744a                	ld	s0,176(sp)
    800052aa:	6129                	addi	sp,sp,192
    800052ac:	8082                	ret
      end_op();
    800052ae:	c69fe0ef          	jal	80003f16 <end_op>
      return -1;
    800052b2:	557d                	li	a0,-1
    800052b4:	74aa                	ld	s1,168(sp)
    800052b6:	bfc5                	j	800052a6 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800052b8:	f5040513          	addi	a0,s0,-176
    800052bc:	a1dfe0ef          	jal	80003cd8 <namei>
    800052c0:	84aa                	mv	s1,a0
    800052c2:	c11d                	beqz	a0,800052e8 <sys_open+0x10a>
    ilock(ip);
    800052c4:	9fefe0ef          	jal	800034c2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800052c8:	04449703          	lh	a4,68(s1)
    800052cc:	4785                	li	a5,1
    800052ce:	f4f71de3          	bne	a4,a5,80005228 <sys_open+0x4a>
    800052d2:	f4c42783          	lw	a5,-180(s0)
    800052d6:	d3bd                	beqz	a5,8000523c <sys_open+0x5e>
      iunlockput(ip);
    800052d8:	8526                	mv	a0,s1
    800052da:	bf2fe0ef          	jal	800036cc <iunlockput>
      end_op();
    800052de:	c39fe0ef          	jal	80003f16 <end_op>
      return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	74aa                	ld	s1,168(sp)
    800052e6:	b7c1                	j	800052a6 <sys_open+0xc8>
      end_op();
    800052e8:	c2ffe0ef          	jal	80003f16 <end_op>
      return -1;
    800052ec:	557d                	li	a0,-1
    800052ee:	74aa                	ld	s1,168(sp)
    800052f0:	bf5d                	j	800052a6 <sys_open+0xc8>
    iunlockput(ip);
    800052f2:	8526                	mv	a0,s1
    800052f4:	bd8fe0ef          	jal	800036cc <iunlockput>
    end_op();
    800052f8:	c1ffe0ef          	jal	80003f16 <end_op>
    return -1;
    800052fc:	557d                	li	a0,-1
    800052fe:	74aa                	ld	s1,168(sp)
    80005300:	b75d                	j	800052a6 <sys_open+0xc8>
      fileclose(f);
    80005302:	854a                	mv	a0,s2
    80005304:	fb5fe0ef          	jal	800042b8 <fileclose>
    80005308:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	bc0fe0ef          	jal	800036cc <iunlockput>
    end_op();
    80005310:	c07fe0ef          	jal	80003f16 <end_op>
    return -1;
    80005314:	557d                	li	a0,-1
    80005316:	74aa                	ld	s1,168(sp)
    80005318:	790a                	ld	s2,160(sp)
    8000531a:	b771                	j	800052a6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000531c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005320:	04649783          	lh	a5,70(s1)
    80005324:	02f91223          	sh	a5,36(s2)
    80005328:	bf3d                	j	80005266 <sys_open+0x88>
    itrunc(ip);
    8000532a:	8526                	mv	a0,s1
    8000532c:	a84fe0ef          	jal	800035b0 <itrunc>
    80005330:	b795                	j	80005294 <sys_open+0xb6>

0000000080005332 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005332:	7175                	addi	sp,sp,-144
    80005334:	e506                	sd	ra,136(sp)
    80005336:	e122                	sd	s0,128(sp)
    80005338:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000533a:	b73fe0ef          	jal	80003eac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000533e:	08000613          	li	a2,128
    80005342:	f7040593          	addi	a1,s0,-144
    80005346:	4501                	li	a0,0
    80005348:	f4cfd0ef          	jal	80002a94 <argstr>
    8000534c:	02054363          	bltz	a0,80005372 <sys_mkdir+0x40>
    80005350:	4681                	li	a3,0
    80005352:	4601                	li	a2,0
    80005354:	4585                	li	a1,1
    80005356:	f7040513          	addi	a0,s0,-144
    8000535a:	96fff0ef          	jal	80004cc8 <create>
    8000535e:	c911                	beqz	a0,80005372 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005360:	b6cfe0ef          	jal	800036cc <iunlockput>
  end_op();
    80005364:	bb3fe0ef          	jal	80003f16 <end_op>
  return 0;
    80005368:	4501                	li	a0,0
}
    8000536a:	60aa                	ld	ra,136(sp)
    8000536c:	640a                	ld	s0,128(sp)
    8000536e:	6149                	addi	sp,sp,144
    80005370:	8082                	ret
    end_op();
    80005372:	ba5fe0ef          	jal	80003f16 <end_op>
    return -1;
    80005376:	557d                	li	a0,-1
    80005378:	bfcd                	j	8000536a <sys_mkdir+0x38>

000000008000537a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000537a:	7135                	addi	sp,sp,-160
    8000537c:	ed06                	sd	ra,152(sp)
    8000537e:	e922                	sd	s0,144(sp)
    80005380:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005382:	b2bfe0ef          	jal	80003eac <begin_op>
  argint(1, &major);
    80005386:	f6c40593          	addi	a1,s0,-148
    8000538a:	4505                	li	a0,1
    8000538c:	ed0fd0ef          	jal	80002a5c <argint>
  argint(2, &minor);
    80005390:	f6840593          	addi	a1,s0,-152
    80005394:	4509                	li	a0,2
    80005396:	ec6fd0ef          	jal	80002a5c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000539a:	08000613          	li	a2,128
    8000539e:	f7040593          	addi	a1,s0,-144
    800053a2:	4501                	li	a0,0
    800053a4:	ef0fd0ef          	jal	80002a94 <argstr>
    800053a8:	02054563          	bltz	a0,800053d2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800053ac:	f6841683          	lh	a3,-152(s0)
    800053b0:	f6c41603          	lh	a2,-148(s0)
    800053b4:	458d                	li	a1,3
    800053b6:	f7040513          	addi	a0,s0,-144
    800053ba:	90fff0ef          	jal	80004cc8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053be:	c911                	beqz	a0,800053d2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053c0:	b0cfe0ef          	jal	800036cc <iunlockput>
  end_op();
    800053c4:	b53fe0ef          	jal	80003f16 <end_op>
  return 0;
    800053c8:	4501                	li	a0,0
}
    800053ca:	60ea                	ld	ra,152(sp)
    800053cc:	644a                	ld	s0,144(sp)
    800053ce:	610d                	addi	sp,sp,160
    800053d0:	8082                	ret
    end_op();
    800053d2:	b45fe0ef          	jal	80003f16 <end_op>
    return -1;
    800053d6:	557d                	li	a0,-1
    800053d8:	bfcd                	j	800053ca <sys_mknod+0x50>

00000000800053da <sys_chdir>:

uint64
sys_chdir(void)
{
    800053da:	7135                	addi	sp,sp,-160
    800053dc:	ed06                	sd	ra,152(sp)
    800053de:	e922                	sd	s0,144(sp)
    800053e0:	e14a                	sd	s2,128(sp)
    800053e2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053e4:	ee6fc0ef          	jal	80001aca <myproc>
    800053e8:	892a                	mv	s2,a0
  
  begin_op();
    800053ea:	ac3fe0ef          	jal	80003eac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053ee:	08000613          	li	a2,128
    800053f2:	f6040593          	addi	a1,s0,-160
    800053f6:	4501                	li	a0,0
    800053f8:	e9cfd0ef          	jal	80002a94 <argstr>
    800053fc:	04054363          	bltz	a0,80005442 <sys_chdir+0x68>
    80005400:	e526                	sd	s1,136(sp)
    80005402:	f6040513          	addi	a0,s0,-160
    80005406:	8d3fe0ef          	jal	80003cd8 <namei>
    8000540a:	84aa                	mv	s1,a0
    8000540c:	c915                	beqz	a0,80005440 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000540e:	8b4fe0ef          	jal	800034c2 <ilock>
  if(ip->type != T_DIR){
    80005412:	04449703          	lh	a4,68(s1)
    80005416:	4785                	li	a5,1
    80005418:	02f71963          	bne	a4,a5,8000544a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000541c:	8526                	mv	a0,s1
    8000541e:	952fe0ef          	jal	80003570 <iunlock>
  iput(p->cwd);
    80005422:	15093503          	ld	a0,336(s2)
    80005426:	a1efe0ef          	jal	80003644 <iput>
  end_op();
    8000542a:	aedfe0ef          	jal	80003f16 <end_op>
  p->cwd = ip;
    8000542e:	14993823          	sd	s1,336(s2)
  return 0;
    80005432:	4501                	li	a0,0
    80005434:	64aa                	ld	s1,136(sp)
}
    80005436:	60ea                	ld	ra,152(sp)
    80005438:	644a                	ld	s0,144(sp)
    8000543a:	690a                	ld	s2,128(sp)
    8000543c:	610d                	addi	sp,sp,160
    8000543e:	8082                	ret
    80005440:	64aa                	ld	s1,136(sp)
    end_op();
    80005442:	ad5fe0ef          	jal	80003f16 <end_op>
    return -1;
    80005446:	557d                	li	a0,-1
    80005448:	b7fd                	j	80005436 <sys_chdir+0x5c>
    iunlockput(ip);
    8000544a:	8526                	mv	a0,s1
    8000544c:	a80fe0ef          	jal	800036cc <iunlockput>
    end_op();
    80005450:	ac7fe0ef          	jal	80003f16 <end_op>
    return -1;
    80005454:	557d                	li	a0,-1
    80005456:	64aa                	ld	s1,136(sp)
    80005458:	bff9                	j	80005436 <sys_chdir+0x5c>

000000008000545a <sys_exec>:

uint64
sys_exec(void)
{
    8000545a:	7121                	addi	sp,sp,-448
    8000545c:	ff06                	sd	ra,440(sp)
    8000545e:	fb22                	sd	s0,432(sp)
    80005460:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005462:	e4840593          	addi	a1,s0,-440
    80005466:	4505                	li	a0,1
    80005468:	e10fd0ef          	jal	80002a78 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000546c:	08000613          	li	a2,128
    80005470:	f5040593          	addi	a1,s0,-176
    80005474:	4501                	li	a0,0
    80005476:	e1efd0ef          	jal	80002a94 <argstr>
    8000547a:	87aa                	mv	a5,a0
    return -1;
    8000547c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000547e:	0c07c463          	bltz	a5,80005546 <sys_exec+0xec>
    80005482:	f726                	sd	s1,424(sp)
    80005484:	f34a                	sd	s2,416(sp)
    80005486:	ef4e                	sd	s3,408(sp)
    80005488:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000548a:	10000613          	li	a2,256
    8000548e:	4581                	li	a1,0
    80005490:	e5040513          	addi	a0,s0,-432
    80005494:	80ffb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005498:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000549c:	89a6                	mv	s3,s1
    8000549e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800054a0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800054a4:	00391513          	slli	a0,s2,0x3
    800054a8:	e4040593          	addi	a1,s0,-448
    800054ac:	e4843783          	ld	a5,-440(s0)
    800054b0:	953e                	add	a0,a0,a5
    800054b2:	d20fd0ef          	jal	800029d2 <fetchaddr>
    800054b6:	02054663          	bltz	a0,800054e2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800054ba:	e4043783          	ld	a5,-448(s0)
    800054be:	c3a9                	beqz	a5,80005500 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800054c0:	e3efb0ef          	jal	80000afe <kalloc>
    800054c4:	85aa                	mv	a1,a0
    800054c6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800054ca:	cd01                	beqz	a0,800054e2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054cc:	6605                	lui	a2,0x1
    800054ce:	e4043503          	ld	a0,-448(s0)
    800054d2:	d4afd0ef          	jal	80002a1c <fetchstr>
    800054d6:	00054663          	bltz	a0,800054e2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800054da:	0905                	addi	s2,s2,1
    800054dc:	09a1                	addi	s3,s3,8
    800054de:	fd4913e3          	bne	s2,s4,800054a4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054e2:	f5040913          	addi	s2,s0,-176
    800054e6:	6088                	ld	a0,0(s1)
    800054e8:	c931                	beqz	a0,8000553c <sys_exec+0xe2>
    kfree(argv[i]);
    800054ea:	d32fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ee:	04a1                	addi	s1,s1,8
    800054f0:	ff249be3          	bne	s1,s2,800054e6 <sys_exec+0x8c>
  return -1;
    800054f4:	557d                	li	a0,-1
    800054f6:	74ba                	ld	s1,424(sp)
    800054f8:	791a                	ld	s2,416(sp)
    800054fa:	69fa                	ld	s3,408(sp)
    800054fc:	6a5a                	ld	s4,400(sp)
    800054fe:	a0a1                	j	80005546 <sys_exec+0xec>
      argv[i] = 0;
    80005500:	0009079b          	sext.w	a5,s2
    80005504:	078e                	slli	a5,a5,0x3
    80005506:	fd078793          	addi	a5,a5,-48
    8000550a:	97a2                	add	a5,a5,s0
    8000550c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005510:	e5040593          	addi	a1,s0,-432
    80005514:	f5040513          	addi	a0,s0,-176
    80005518:	ba8ff0ef          	jal	800048c0 <kexec>
    8000551c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000551e:	f5040993          	addi	s3,s0,-176
    80005522:	6088                	ld	a0,0(s1)
    80005524:	c511                	beqz	a0,80005530 <sys_exec+0xd6>
    kfree(argv[i]);
    80005526:	cf6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000552a:	04a1                	addi	s1,s1,8
    8000552c:	ff349be3          	bne	s1,s3,80005522 <sys_exec+0xc8>
  return ret;
    80005530:	854a                	mv	a0,s2
    80005532:	74ba                	ld	s1,424(sp)
    80005534:	791a                	ld	s2,416(sp)
    80005536:	69fa                	ld	s3,408(sp)
    80005538:	6a5a                	ld	s4,400(sp)
    8000553a:	a031                	j	80005546 <sys_exec+0xec>
  return -1;
    8000553c:	557d                	li	a0,-1
    8000553e:	74ba                	ld	s1,424(sp)
    80005540:	791a                	ld	s2,416(sp)
    80005542:	69fa                	ld	s3,408(sp)
    80005544:	6a5a                	ld	s4,400(sp)
}
    80005546:	70fa                	ld	ra,440(sp)
    80005548:	745a                	ld	s0,432(sp)
    8000554a:	6139                	addi	sp,sp,448
    8000554c:	8082                	ret

000000008000554e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000554e:	7139                	addi	sp,sp,-64
    80005550:	fc06                	sd	ra,56(sp)
    80005552:	f822                	sd	s0,48(sp)
    80005554:	f426                	sd	s1,40(sp)
    80005556:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005558:	d72fc0ef          	jal	80001aca <myproc>
    8000555c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000555e:	fd840593          	addi	a1,s0,-40
    80005562:	4501                	li	a0,0
    80005564:	d14fd0ef          	jal	80002a78 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005568:	fc840593          	addi	a1,s0,-56
    8000556c:	fd040513          	addi	a0,s0,-48
    80005570:	852ff0ef          	jal	800045c2 <pipealloc>
    return -1;
    80005574:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005576:	0a054463          	bltz	a0,8000561e <sys_pipe+0xd0>
  fd0 = -1;
    8000557a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000557e:	fd043503          	ld	a0,-48(s0)
    80005582:	f08ff0ef          	jal	80004c8a <fdalloc>
    80005586:	fca42223          	sw	a0,-60(s0)
    8000558a:	08054163          	bltz	a0,8000560c <sys_pipe+0xbe>
    8000558e:	fc843503          	ld	a0,-56(s0)
    80005592:	ef8ff0ef          	jal	80004c8a <fdalloc>
    80005596:	fca42023          	sw	a0,-64(s0)
    8000559a:	06054063          	bltz	a0,800055fa <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000559e:	4691                	li	a3,4
    800055a0:	fc440613          	addi	a2,s0,-60
    800055a4:	fd843583          	ld	a1,-40(s0)
    800055a8:	68a8                	ld	a0,80(s1)
    800055aa:	838fc0ef          	jal	800015e2 <copyout>
    800055ae:	00054e63          	bltz	a0,800055ca <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800055b2:	4691                	li	a3,4
    800055b4:	fc040613          	addi	a2,s0,-64
    800055b8:	fd843583          	ld	a1,-40(s0)
    800055bc:	0591                	addi	a1,a1,4
    800055be:	68a8                	ld	a0,80(s1)
    800055c0:	822fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055c4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055c6:	04055c63          	bgez	a0,8000561e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800055ca:	fc442783          	lw	a5,-60(s0)
    800055ce:	07e9                	addi	a5,a5,26
    800055d0:	078e                	slli	a5,a5,0x3
    800055d2:	97a6                	add	a5,a5,s1
    800055d4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055d8:	fc042783          	lw	a5,-64(s0)
    800055dc:	07e9                	addi	a5,a5,26
    800055de:	078e                	slli	a5,a5,0x3
    800055e0:	94be                	add	s1,s1,a5
    800055e2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055e6:	fd043503          	ld	a0,-48(s0)
    800055ea:	ccffe0ef          	jal	800042b8 <fileclose>
    fileclose(wf);
    800055ee:	fc843503          	ld	a0,-56(s0)
    800055f2:	cc7fe0ef          	jal	800042b8 <fileclose>
    return -1;
    800055f6:	57fd                	li	a5,-1
    800055f8:	a01d                	j	8000561e <sys_pipe+0xd0>
    if(fd0 >= 0)
    800055fa:	fc442783          	lw	a5,-60(s0)
    800055fe:	0007c763          	bltz	a5,8000560c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005602:	07e9                	addi	a5,a5,26
    80005604:	078e                	slli	a5,a5,0x3
    80005606:	97a6                	add	a5,a5,s1
    80005608:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000560c:	fd043503          	ld	a0,-48(s0)
    80005610:	ca9fe0ef          	jal	800042b8 <fileclose>
    fileclose(wf);
    80005614:	fc843503          	ld	a0,-56(s0)
    80005618:	ca1fe0ef          	jal	800042b8 <fileclose>
    return -1;
    8000561c:	57fd                	li	a5,-1
}
    8000561e:	853e                	mv	a0,a5
    80005620:	70e2                	ld	ra,56(sp)
    80005622:	7442                	ld	s0,48(sp)
    80005624:	74a2                	ld	s1,40(sp)
    80005626:	6121                	addi	sp,sp,64
    80005628:	8082                	ret
    8000562a:	0000                	unimp
    8000562c:	0000                	unimp
	...

0000000080005630 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005630:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005632:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005634:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005636:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005638:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000563a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000563c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000563e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005640:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005642:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005644:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005646:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005648:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000564a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000564c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000564e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005650:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005652:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005654:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005656:	a8cfd0ef          	jal	800028e2 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000565a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000565c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000565e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005660:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005662:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005664:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005666:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005668:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000566a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000566c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000566e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005670:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005672:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005674:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005676:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005678:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000567a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000567c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000567e:	10200073          	sret
	...

000000008000568e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000568e:	1141                	addi	sp,sp,-16
    80005690:	e422                	sd	s0,8(sp)
    80005692:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005694:	0c0007b7          	lui	a5,0xc000
    80005698:	4705                	li	a4,1
    8000569a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000569c:	0c0007b7          	lui	a5,0xc000
    800056a0:	c3d8                	sw	a4,4(a5)
}
    800056a2:	6422                	ld	s0,8(sp)
    800056a4:	0141                	addi	sp,sp,16
    800056a6:	8082                	ret

00000000800056a8 <plicinithart>:

void
plicinithart(void)
{
    800056a8:	1141                	addi	sp,sp,-16
    800056aa:	e406                	sd	ra,8(sp)
    800056ac:	e022                	sd	s0,0(sp)
    800056ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056b0:	beefc0ef          	jal	80001a9e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800056b4:	0085171b          	slliw	a4,a0,0x8
    800056b8:	0c0027b7          	lui	a5,0xc002
    800056bc:	97ba                	add	a5,a5,a4
    800056be:	40200713          	li	a4,1026
    800056c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800056c6:	00d5151b          	slliw	a0,a0,0xd
    800056ca:	0c2017b7          	lui	a5,0xc201
    800056ce:	97aa                	add	a5,a5,a0
    800056d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800056d4:	60a2                	ld	ra,8(sp)
    800056d6:	6402                	ld	s0,0(sp)
    800056d8:	0141                	addi	sp,sp,16
    800056da:	8082                	ret

00000000800056dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056dc:	1141                	addi	sp,sp,-16
    800056de:	e406                	sd	ra,8(sp)
    800056e0:	e022                	sd	s0,0(sp)
    800056e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056e4:	bbafc0ef          	jal	80001a9e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800056e8:	00d5151b          	slliw	a0,a0,0xd
    800056ec:	0c2017b7          	lui	a5,0xc201
    800056f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056f2:	43c8                	lw	a0,4(a5)
    800056f4:	60a2                	ld	ra,8(sp)
    800056f6:	6402                	ld	s0,0(sp)
    800056f8:	0141                	addi	sp,sp,16
    800056fa:	8082                	ret

00000000800056fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056fc:	1101                	addi	sp,sp,-32
    800056fe:	ec06                	sd	ra,24(sp)
    80005700:	e822                	sd	s0,16(sp)
    80005702:	e426                	sd	s1,8(sp)
    80005704:	1000                	addi	s0,sp,32
    80005706:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005708:	b96fc0ef          	jal	80001a9e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000570c:	00d5151b          	slliw	a0,a0,0xd
    80005710:	0c2017b7          	lui	a5,0xc201
    80005714:	97aa                	add	a5,a5,a0
    80005716:	c3c4                	sw	s1,4(a5)
}
    80005718:	60e2                	ld	ra,24(sp)
    8000571a:	6442                	ld	s0,16(sp)
    8000571c:	64a2                	ld	s1,8(sp)
    8000571e:	6105                	addi	sp,sp,32
    80005720:	8082                	ret

0000000080005722 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005722:	1141                	addi	sp,sp,-16
    80005724:	e406                	sd	ra,8(sp)
    80005726:	e022                	sd	s0,0(sp)
    80005728:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000572a:	479d                	li	a5,7
    8000572c:	04a7ca63          	blt	a5,a0,80005780 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005730:	0001b797          	auipc	a5,0x1b
    80005734:	30878793          	addi	a5,a5,776 # 80020a38 <disk>
    80005738:	97aa                	add	a5,a5,a0
    8000573a:	0187c783          	lbu	a5,24(a5)
    8000573e:	e7b9                	bnez	a5,8000578c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005740:	00451693          	slli	a3,a0,0x4
    80005744:	0001b797          	auipc	a5,0x1b
    80005748:	2f478793          	addi	a5,a5,756 # 80020a38 <disk>
    8000574c:	6398                	ld	a4,0(a5)
    8000574e:	9736                	add	a4,a4,a3
    80005750:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005754:	6398                	ld	a4,0(a5)
    80005756:	9736                	add	a4,a4,a3
    80005758:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000575c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005760:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005764:	97aa                	add	a5,a5,a0
    80005766:	4705                	li	a4,1
    80005768:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000576c:	0001b517          	auipc	a0,0x1b
    80005770:	2e450513          	addi	a0,a0,740 # 80020a50 <disk+0x18>
    80005774:	9adfc0ef          	jal	80002120 <wakeup>
}
    80005778:	60a2                	ld	ra,8(sp)
    8000577a:	6402                	ld	s0,0(sp)
    8000577c:	0141                	addi	sp,sp,16
    8000577e:	8082                	ret
    panic("free_desc 1");
    80005780:	00002517          	auipc	a0,0x2
    80005784:	e9050513          	addi	a0,a0,-368 # 80007610 <etext+0x610>
    80005788:	858fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    8000578c:	00002517          	auipc	a0,0x2
    80005790:	e9450513          	addi	a0,a0,-364 # 80007620 <etext+0x620>
    80005794:	84cfb0ef          	jal	800007e0 <panic>

0000000080005798 <virtio_disk_init>:
{
    80005798:	1101                	addi	sp,sp,-32
    8000579a:	ec06                	sd	ra,24(sp)
    8000579c:	e822                	sd	s0,16(sp)
    8000579e:	e426                	sd	s1,8(sp)
    800057a0:	e04a                	sd	s2,0(sp)
    800057a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800057a4:	00002597          	auipc	a1,0x2
    800057a8:	e8c58593          	addi	a1,a1,-372 # 80007630 <etext+0x630>
    800057ac:	0001b517          	auipc	a0,0x1b
    800057b0:	3b450513          	addi	a0,a0,948 # 80020b60 <disk+0x128>
    800057b4:	b9afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057b8:	100017b7          	lui	a5,0x10001
    800057bc:	4398                	lw	a4,0(a5)
    800057be:	2701                	sext.w	a4,a4
    800057c0:	747277b7          	lui	a5,0x74727
    800057c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057c8:	18f71063          	bne	a4,a5,80005948 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057cc:	100017b7          	lui	a5,0x10001
    800057d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800057d2:	439c                	lw	a5,0(a5)
    800057d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057d6:	4709                	li	a4,2
    800057d8:	16e79863          	bne	a5,a4,80005948 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057dc:	100017b7          	lui	a5,0x10001
    800057e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800057e2:	439c                	lw	a5,0(a5)
    800057e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057e6:	16e79163          	bne	a5,a4,80005948 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800057ea:	100017b7          	lui	a5,0x10001
    800057ee:	47d8                	lw	a4,12(a5)
    800057f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057f2:	554d47b7          	lui	a5,0x554d4
    800057f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057fa:	14f71763          	bne	a4,a5,80005948 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057fe:	100017b7          	lui	a5,0x10001
    80005802:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005806:	4705                	li	a4,1
    80005808:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000580a:	470d                	li	a4,3
    8000580c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000580e:	10001737          	lui	a4,0x10001
    80005812:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005814:	c7ffe737          	lui	a4,0xc7ffe
    80005818:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbe7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000581c:	8ef9                	and	a3,a3,a4
    8000581e:	10001737          	lui	a4,0x10001
    80005822:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005824:	472d                	li	a4,11
    80005826:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005828:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000582c:	439c                	lw	a5,0(a5)
    8000582e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005832:	8ba1                	andi	a5,a5,8
    80005834:	12078063          	beqz	a5,80005954 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005838:	100017b7          	lui	a5,0x10001
    8000583c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005840:	100017b7          	lui	a5,0x10001
    80005844:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005848:	439c                	lw	a5,0(a5)
    8000584a:	2781                	sext.w	a5,a5
    8000584c:	10079a63          	bnez	a5,80005960 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005850:	100017b7          	lui	a5,0x10001
    80005854:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005858:	439c                	lw	a5,0(a5)
    8000585a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000585c:	10078863          	beqz	a5,8000596c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005860:	471d                	li	a4,7
    80005862:	10f77b63          	bgeu	a4,a5,80005978 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005866:	a98fb0ef          	jal	80000afe <kalloc>
    8000586a:	0001b497          	auipc	s1,0x1b
    8000586e:	1ce48493          	addi	s1,s1,462 # 80020a38 <disk>
    80005872:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005874:	a8afb0ef          	jal	80000afe <kalloc>
    80005878:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000587a:	a84fb0ef          	jal	80000afe <kalloc>
    8000587e:	87aa                	mv	a5,a0
    80005880:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005882:	6088                	ld	a0,0(s1)
    80005884:	10050063          	beqz	a0,80005984 <virtio_disk_init+0x1ec>
    80005888:	0001b717          	auipc	a4,0x1b
    8000588c:	1b873703          	ld	a4,440(a4) # 80020a40 <disk+0x8>
    80005890:	0e070a63          	beqz	a4,80005984 <virtio_disk_init+0x1ec>
    80005894:	0e078863          	beqz	a5,80005984 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005898:	6605                	lui	a2,0x1
    8000589a:	4581                	li	a1,0
    8000589c:	c06fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800058a0:	0001b497          	auipc	s1,0x1b
    800058a4:	19848493          	addi	s1,s1,408 # 80020a38 <disk>
    800058a8:	6605                	lui	a2,0x1
    800058aa:	4581                	li	a1,0
    800058ac:	6488                	ld	a0,8(s1)
    800058ae:	bf4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    800058b2:	6605                	lui	a2,0x1
    800058b4:	4581                	li	a1,0
    800058b6:	6888                	ld	a0,16(s1)
    800058b8:	beafb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800058bc:	100017b7          	lui	a5,0x10001
    800058c0:	4721                	li	a4,8
    800058c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058c4:	4098                	lw	a4,0(s1)
    800058c6:	100017b7          	lui	a5,0x10001
    800058ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058ce:	40d8                	lw	a4,4(s1)
    800058d0:	100017b7          	lui	a5,0x10001
    800058d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058d8:	649c                	ld	a5,8(s1)
    800058da:	0007869b          	sext.w	a3,a5
    800058de:	10001737          	lui	a4,0x10001
    800058e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058e6:	9781                	srai	a5,a5,0x20
    800058e8:	10001737          	lui	a4,0x10001
    800058ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058f0:	689c                	ld	a5,16(s1)
    800058f2:	0007869b          	sext.w	a3,a5
    800058f6:	10001737          	lui	a4,0x10001
    800058fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058fe:	9781                	srai	a5,a5,0x20
    80005900:	10001737          	lui	a4,0x10001
    80005904:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005908:	10001737          	lui	a4,0x10001
    8000590c:	4785                	li	a5,1
    8000590e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005910:	00f48c23          	sb	a5,24(s1)
    80005914:	00f48ca3          	sb	a5,25(s1)
    80005918:	00f48d23          	sb	a5,26(s1)
    8000591c:	00f48da3          	sb	a5,27(s1)
    80005920:	00f48e23          	sb	a5,28(s1)
    80005924:	00f48ea3          	sb	a5,29(s1)
    80005928:	00f48f23          	sb	a5,30(s1)
    8000592c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005930:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005934:	100017b7          	lui	a5,0x10001
    80005938:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000593c:	60e2                	ld	ra,24(sp)
    8000593e:	6442                	ld	s0,16(sp)
    80005940:	64a2                	ld	s1,8(sp)
    80005942:	6902                	ld	s2,0(sp)
    80005944:	6105                	addi	sp,sp,32
    80005946:	8082                	ret
    panic("could not find virtio disk");
    80005948:	00002517          	auipc	a0,0x2
    8000594c:	cf850513          	addi	a0,a0,-776 # 80007640 <etext+0x640>
    80005950:	e91fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005954:	00002517          	auipc	a0,0x2
    80005958:	d0c50513          	addi	a0,a0,-756 # 80007660 <etext+0x660>
    8000595c:	e85fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005960:	00002517          	auipc	a0,0x2
    80005964:	d2050513          	addi	a0,a0,-736 # 80007680 <etext+0x680>
    80005968:	e79fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    8000596c:	00002517          	auipc	a0,0x2
    80005970:	d3450513          	addi	a0,a0,-716 # 800076a0 <etext+0x6a0>
    80005974:	e6dfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005978:	00002517          	auipc	a0,0x2
    8000597c:	d4850513          	addi	a0,a0,-696 # 800076c0 <etext+0x6c0>
    80005980:	e61fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005984:	00002517          	auipc	a0,0x2
    80005988:	d5c50513          	addi	a0,a0,-676 # 800076e0 <etext+0x6e0>
    8000598c:	e55fa0ef          	jal	800007e0 <panic>

0000000080005990 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005990:	7159                	addi	sp,sp,-112
    80005992:	f486                	sd	ra,104(sp)
    80005994:	f0a2                	sd	s0,96(sp)
    80005996:	eca6                	sd	s1,88(sp)
    80005998:	e8ca                	sd	s2,80(sp)
    8000599a:	e4ce                	sd	s3,72(sp)
    8000599c:	e0d2                	sd	s4,64(sp)
    8000599e:	fc56                	sd	s5,56(sp)
    800059a0:	f85a                	sd	s6,48(sp)
    800059a2:	f45e                	sd	s7,40(sp)
    800059a4:	f062                	sd	s8,32(sp)
    800059a6:	ec66                	sd	s9,24(sp)
    800059a8:	1880                	addi	s0,sp,112
    800059aa:	8a2a                	mv	s4,a0
    800059ac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059ae:	00c52c83          	lw	s9,12(a0)
    800059b2:	001c9c9b          	slliw	s9,s9,0x1
    800059b6:	1c82                	slli	s9,s9,0x20
    800059b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800059bc:	0001b517          	auipc	a0,0x1b
    800059c0:	1a450513          	addi	a0,a0,420 # 80020b60 <disk+0x128>
    800059c4:	a0afb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800059c8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800059ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800059cc:	0001bb17          	auipc	s6,0x1b
    800059d0:	06cb0b13          	addi	s6,s6,108 # 80020a38 <disk>
  for(int i = 0; i < 3; i++){
    800059d4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059d6:	0001bc17          	auipc	s8,0x1b
    800059da:	18ac0c13          	addi	s8,s8,394 # 80020b60 <disk+0x128>
    800059de:	a8b9                	j	80005a3c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800059e0:	00fb0733          	add	a4,s6,a5
    800059e4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800059e8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800059ea:	0207c563          	bltz	a5,80005a14 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800059ee:	2905                	addiw	s2,s2,1
    800059f0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059f2:	05590963          	beq	s2,s5,80005a44 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800059f6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800059f8:	0001b717          	auipc	a4,0x1b
    800059fc:	04070713          	addi	a4,a4,64 # 80020a38 <disk>
    80005a00:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005a02:	01874683          	lbu	a3,24(a4)
    80005a06:	fee9                	bnez	a3,800059e0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005a08:	2785                	addiw	a5,a5,1
    80005a0a:	0705                	addi	a4,a4,1
    80005a0c:	fe979be3          	bne	a5,s1,80005a02 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005a10:	57fd                	li	a5,-1
    80005a12:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005a14:	01205d63          	blez	s2,80005a2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a18:	f9042503          	lw	a0,-112(s0)
    80005a1c:	d07ff0ef          	jal	80005722 <free_desc>
      for(int j = 0; j < i; j++)
    80005a20:	4785                	li	a5,1
    80005a22:	0127d663          	bge	a5,s2,80005a2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005a26:	f9442503          	lw	a0,-108(s0)
    80005a2a:	cf9ff0ef          	jal	80005722 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a2e:	85e2                	mv	a1,s8
    80005a30:	0001b517          	auipc	a0,0x1b
    80005a34:	02050513          	addi	a0,a0,32 # 80020a50 <disk+0x18>
    80005a38:	e9cfc0ef          	jal	800020d4 <sleep>
  for(int i = 0; i < 3; i++){
    80005a3c:	f9040613          	addi	a2,s0,-112
    80005a40:	894e                	mv	s2,s3
    80005a42:	bf55                	j	800059f6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a44:	f9042503          	lw	a0,-112(s0)
    80005a48:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a4c:	0001b797          	auipc	a5,0x1b
    80005a50:	fec78793          	addi	a5,a5,-20 # 80020a38 <disk>
    80005a54:	00a50713          	addi	a4,a0,10
    80005a58:	0712                	slli	a4,a4,0x4
    80005a5a:	973e                	add	a4,a4,a5
    80005a5c:	01703633          	snez	a2,s7
    80005a60:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a62:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a66:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a6a:	6398                	ld	a4,0(a5)
    80005a6c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a6e:	0a868613          	addi	a2,a3,168
    80005a72:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a74:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a76:	6390                	ld	a2,0(a5)
    80005a78:	00d605b3          	add	a1,a2,a3
    80005a7c:	4741                	li	a4,16
    80005a7e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a80:	4805                	li	a6,1
    80005a82:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a86:	f9442703          	lw	a4,-108(s0)
    80005a8a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a8e:	0712                	slli	a4,a4,0x4
    80005a90:	963a                	add	a2,a2,a4
    80005a92:	058a0593          	addi	a1,s4,88
    80005a96:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a98:	0007b883          	ld	a7,0(a5)
    80005a9c:	9746                	add	a4,a4,a7
    80005a9e:	40000613          	li	a2,1024
    80005aa2:	c710                	sw	a2,8(a4)
  if(write)
    80005aa4:	001bb613          	seqz	a2,s7
    80005aa8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005aac:	00166613          	ori	a2,a2,1
    80005ab0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005ab4:	f9842583          	lw	a1,-104(s0)
    80005ab8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005abc:	00250613          	addi	a2,a0,2
    80005ac0:	0612                	slli	a2,a2,0x4
    80005ac2:	963e                	add	a2,a2,a5
    80005ac4:	577d                	li	a4,-1
    80005ac6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005aca:	0592                	slli	a1,a1,0x4
    80005acc:	98ae                	add	a7,a7,a1
    80005ace:	03068713          	addi	a4,a3,48
    80005ad2:	973e                	add	a4,a4,a5
    80005ad4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005ad8:	6398                	ld	a4,0(a5)
    80005ada:	972e                	add	a4,a4,a1
    80005adc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ae0:	4689                	li	a3,2
    80005ae2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ae6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005aea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005aee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005af2:	6794                	ld	a3,8(a5)
    80005af4:	0026d703          	lhu	a4,2(a3)
    80005af8:	8b1d                	andi	a4,a4,7
    80005afa:	0706                	slli	a4,a4,0x1
    80005afc:	96ba                	add	a3,a3,a4
    80005afe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b02:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b06:	6798                	ld	a4,8(a5)
    80005b08:	00275783          	lhu	a5,2(a4)
    80005b0c:	2785                	addiw	a5,a5,1
    80005b0e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b12:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b16:	100017b7          	lui	a5,0x10001
    80005b1a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b1e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005b22:	0001b917          	auipc	s2,0x1b
    80005b26:	03e90913          	addi	s2,s2,62 # 80020b60 <disk+0x128>
  while(b->disk == 1) {
    80005b2a:	4485                	li	s1,1
    80005b2c:	01079a63          	bne	a5,a6,80005b40 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b30:	85ca                	mv	a1,s2
    80005b32:	8552                	mv	a0,s4
    80005b34:	da0fc0ef          	jal	800020d4 <sleep>
  while(b->disk == 1) {
    80005b38:	004a2783          	lw	a5,4(s4)
    80005b3c:	fe978ae3          	beq	a5,s1,80005b30 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b40:	f9042903          	lw	s2,-112(s0)
    80005b44:	00290713          	addi	a4,s2,2
    80005b48:	0712                	slli	a4,a4,0x4
    80005b4a:	0001b797          	auipc	a5,0x1b
    80005b4e:	eee78793          	addi	a5,a5,-274 # 80020a38 <disk>
    80005b52:	97ba                	add	a5,a5,a4
    80005b54:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b58:	0001b997          	auipc	s3,0x1b
    80005b5c:	ee098993          	addi	s3,s3,-288 # 80020a38 <disk>
    80005b60:	00491713          	slli	a4,s2,0x4
    80005b64:	0009b783          	ld	a5,0(s3)
    80005b68:	97ba                	add	a5,a5,a4
    80005b6a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b6e:	854a                	mv	a0,s2
    80005b70:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b74:	bafff0ef          	jal	80005722 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b78:	8885                	andi	s1,s1,1
    80005b7a:	f0fd                	bnez	s1,80005b60 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b7c:	0001b517          	auipc	a0,0x1b
    80005b80:	fe450513          	addi	a0,a0,-28 # 80020b60 <disk+0x128>
    80005b84:	8e2fb0ef          	jal	80000c66 <release>
}
    80005b88:	70a6                	ld	ra,104(sp)
    80005b8a:	7406                	ld	s0,96(sp)
    80005b8c:	64e6                	ld	s1,88(sp)
    80005b8e:	6946                	ld	s2,80(sp)
    80005b90:	69a6                	ld	s3,72(sp)
    80005b92:	6a06                	ld	s4,64(sp)
    80005b94:	7ae2                	ld	s5,56(sp)
    80005b96:	7b42                	ld	s6,48(sp)
    80005b98:	7ba2                	ld	s7,40(sp)
    80005b9a:	7c02                	ld	s8,32(sp)
    80005b9c:	6ce2                	ld	s9,24(sp)
    80005b9e:	6165                	addi	sp,sp,112
    80005ba0:	8082                	ret

0000000080005ba2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ba2:	1101                	addi	sp,sp,-32
    80005ba4:	ec06                	sd	ra,24(sp)
    80005ba6:	e822                	sd	s0,16(sp)
    80005ba8:	e426                	sd	s1,8(sp)
    80005baa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bac:	0001b497          	auipc	s1,0x1b
    80005bb0:	e8c48493          	addi	s1,s1,-372 # 80020a38 <disk>
    80005bb4:	0001b517          	auipc	a0,0x1b
    80005bb8:	fac50513          	addi	a0,a0,-84 # 80020b60 <disk+0x128>
    80005bbc:	812fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005bc0:	100017b7          	lui	a5,0x10001
    80005bc4:	53b8                	lw	a4,96(a5)
    80005bc6:	8b0d                	andi	a4,a4,3
    80005bc8:	100017b7          	lui	a5,0x10001
    80005bcc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005bce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005bd2:	689c                	ld	a5,16(s1)
    80005bd4:	0204d703          	lhu	a4,32(s1)
    80005bd8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005bdc:	04f70663          	beq	a4,a5,80005c28 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005be0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005be4:	6898                	ld	a4,16(s1)
    80005be6:	0204d783          	lhu	a5,32(s1)
    80005bea:	8b9d                	andi	a5,a5,7
    80005bec:	078e                	slli	a5,a5,0x3
    80005bee:	97ba                	add	a5,a5,a4
    80005bf0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005bf2:	00278713          	addi	a4,a5,2
    80005bf6:	0712                	slli	a4,a4,0x4
    80005bf8:	9726                	add	a4,a4,s1
    80005bfa:	01074703          	lbu	a4,16(a4)
    80005bfe:	e321                	bnez	a4,80005c3e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c00:	0789                	addi	a5,a5,2
    80005c02:	0792                	slli	a5,a5,0x4
    80005c04:	97a6                	add	a5,a5,s1
    80005c06:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c08:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c0c:	d14fc0ef          	jal	80002120 <wakeup>

    disk.used_idx += 1;
    80005c10:	0204d783          	lhu	a5,32(s1)
    80005c14:	2785                	addiw	a5,a5,1
    80005c16:	17c2                	slli	a5,a5,0x30
    80005c18:	93c1                	srli	a5,a5,0x30
    80005c1a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c1e:	6898                	ld	a4,16(s1)
    80005c20:	00275703          	lhu	a4,2(a4)
    80005c24:	faf71ee3          	bne	a4,a5,80005be0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c28:	0001b517          	auipc	a0,0x1b
    80005c2c:	f3850513          	addi	a0,a0,-200 # 80020b60 <disk+0x128>
    80005c30:	836fb0ef          	jal	80000c66 <release>
}
    80005c34:	60e2                	ld	ra,24(sp)
    80005c36:	6442                	ld	s0,16(sp)
    80005c38:	64a2                	ld	s1,8(sp)
    80005c3a:	6105                	addi	sp,sp,32
    80005c3c:	8082                	ret
      panic("virtio_disk_intr status");
    80005c3e:	00002517          	auipc	a0,0x2
    80005c42:	aba50513          	addi	a0,a0,-1350 # 800076f8 <etext+0x6f8>
    80005c46:	b9bfa0ef          	jal	800007e0 <panic>
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
