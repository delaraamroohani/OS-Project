
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
    80000112:	35a020ef          	jal	8000246c <either_copyin>
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
    800001b8:	105010ef          	jal	80001abc <myproc>
    800001bc:	142020ef          	jal	800022fe <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	701010ef          	jal	800020c6 <sleep>
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
    8000020a:	218020ef          	jal	80002422 <either_copyout>
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
    800002d8:	1de020ef          	jal	800024b6 <procdump>
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
    8000041e:	4f5010ef          	jal	80002112 <wakeup>
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
    800008ea:	7dc010ef          	jal	800020c6 <sleep>
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
    80000a00:	712010ef          	jal	80002112 <wakeup>
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
    80000b78:	729000ef          	jal	80001aa0 <mycpu>
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
    80000ba6:	6fb000ef          	jal	80001aa0 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	6f3000ef          	jal	80001aa0 <mycpu>
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
    80000bc2:	6df000ef          	jal	80001aa0 <mycpu>
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
    80000bf6:	6ab000ef          	jal	80001aa0 <mycpu>
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
    80000c1a:	687000ef          	jal	80001aa0 <mycpu>
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
    80000e44:	44d000ef          	jal	80001a90 <cpuid>
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
    80000e5c:	435000ef          	jal	80001a90 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	003010ef          	jal	80002674 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	033040ef          	jal	800056a8 <plicinithart>
  }

  scheduler();        
    80000e7a:	0b4010ef          	jal	80001f2e <scheduler>
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
    80000eb6:	325000ef          	jal	800019da <procinit>
    trapinit();      // trap vectors
    80000eba:	796010ef          	jal	80002650 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	7b6010ef          	jal	80002674 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	7cc040ef          	jal	8000568e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	7e2040ef          	jal	800056a8 <plicinithart>
    binit();         // buffer cache
    80000eca:	6a1010ef          	jal	80002d6a <binit>
    iinit();         // inode table
    80000ece:	426020ef          	jal	800032f4 <iinit>
    fileinit();      // file table
    80000ed2:	318030ef          	jal	800041ea <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	0c3040ef          	jal	80005798 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	6a9000ef          	jal	80001d82 <userinit>
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
    80001166:	7dc000ef          	jal	80001942 <proc_mapstacks>
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
    80001570:	54c000ef          	jal	80001abc <myproc>
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
    80001754:	7115                	addi	sp,sp,-224
    80001756:	ed86                	sd	ra,216(sp)
    80001758:	e9a2                	sd	s0,208(sp)
    8000175a:	e5a6                	sd	s1,200(sp)
    8000175c:	e1ca                	sd	s2,192(sp)
    8000175e:	fd4e                	sd	s3,184(sp)
    80001760:	f952                	sd	s4,176(sp)
    80001762:	f556                	sd	s5,168(sp)
    80001764:	f15a                	sd	s6,160(sp)
    80001766:	ed5e                	sd	s7,152(sp)
    80001768:	e962                	sd	s8,144(sp)
    8000176a:	1180                	addi	s0,sp,224
    8000176c:	892a                	mv	s2,a0
    8000176e:	8a2e                	mv	s4,a1
    80001770:	8b32                	mv	s6,a2
    80001772:	8bb6                	mv	s7,a3
    80001774:	8aba                	mv	s5,a4
    80001776:	89be                	mv	s3,a5
  char line[128];
  int off = 0;
  int i;

  // indentation: 2 spaces per depth
  for (i = 0; i < depth; i++) {
    80001778:	0eb05663          	blez	a1,80001864 <ptree_walk+0x110>
    8000177c:	f3040893          	addi	a7,s0,-208
    80001780:	0015959b          	slliw	a1,a1,0x1
  int off = 0;
    80001784:	4801                	li	a6,0
    if (off + 2 >= (int)sizeof(line)) break;
    line[off++] = ' ';
    80001786:	02000313          	li	t1,32
    if (off + 2 >= (int)sizeof(line)) break;
    8000178a:	07e00793          	li	a5,126
    line[off++] = ' ';
    8000178e:	00688023          	sb	t1,0(a7)
    line[off++] = ' ';
    80001792:	2809                	addiw	a6,a6,2
    80001794:	006880a3          	sb	t1,1(a7)
  for (i = 0; i < depth; i++) {
    80001798:	00b80663          	beq	a6,a1,800017a4 <ptree_walk+0x50>
    if (off + 2 >= (int)sizeof(line)) break;
    8000179c:	0889                	addi	a7,a7,2
    8000179e:	fef818e3          	bne	a6,a5,8000178e <ptree_walk+0x3a>
    800017a2:	85c2                	mv	a1,a6
  }

  // pid
  off += kitoa(node->pid, line + off);
    800017a4:	03092703          	lw	a4,48(s2)
    800017a8:	f3040793          	addi	a5,s0,-208
    800017ac:	00b788b3          	add	a7,a5,a1
  if (x == 0) {
    800017b0:	cf45                	beqz	a4,80001868 <ptree_walk+0x114>
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017b2:	f2040613          	addi	a2,s0,-224
  int ti = 0;
    800017b6:	4781                	li	a5,0
    tmp[ti++] = '0' + (x % 10);
    800017b8:	4829                	li	a6,10
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017ba:	4325                	li	t1,9
    800017bc:	4e3d                	li	t3,15
    800017be:	04e05363          	blez	a4,80001804 <ptree_walk+0xb0>
    tmp[ti++] = '0' + (x % 10);
    800017c2:	853e                	mv	a0,a5
    800017c4:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffde489>
    800017c6:	030766bb          	remw	a3,a4,a6
    800017ca:	0306869b          	addiw	a3,a3,48 # fffffffffffff030 <end+0xffffffff7ffde4b8>
    800017ce:	00d60023          	sb	a3,0(a2) # 1000 <_entry-0x7ffff000>
    x /= 10;
    800017d2:	86ba                	mv	a3,a4
    800017d4:	0307473b          	divw	a4,a4,a6
  while (x > 0 && ti < (int)sizeof(tmp)-1) {
    800017d8:	08d35e63          	bge	t1,a3,80001874 <ptree_walk+0x120>
    800017dc:	0605                	addi	a2,a2,1
    800017de:	ffc792e3          	bne	a5,t3,800017c2 <ptree_walk+0x6e>
    800017e2:	4539                	li	a0,14
    800017e4:	f2040713          	addi	a4,s0,-224
    800017e8:	00a70633          	add	a2,a4,a0
    800017ec:	8746                	mv	a4,a7
    buf[i] = tmp[ti - 1 - i];
    800017ee:	00064683          	lbu	a3,0(a2)
    800017f2:	00d70023          	sb	a3,0(a4)
  for (i = 0; i < ti; i++)
    800017f6:	167d                	addi	a2,a2,-1
    800017f8:	0705                	addi	a4,a4,1
    800017fa:	411706bb          	subw	a3,a4,a7
    800017fe:	36fd                	addiw	a3,a3,-1
    80001800:	fea6c7e3          	blt	a3,a0,800017ee <ptree_walk+0x9a>
  off += kitoa(node->pid, line + off);
    80001804:	9fad                	addw	a5,a5,a1
    80001806:	0007849b          	sext.w	s1,a5
  if (off < (int)sizeof(line) - 1)
    8000180a:	07e00713          	li	a4,126
    8000180e:	00974c63          	blt	a4,s1,80001826 <ptree_walk+0xd2>
    line[off++] = ' ';
    80001812:	fb048713          	addi	a4,s1,-80 # ffffffffffffefb0 <end+0xffffffff7ffde438>
    80001816:	008704b3          	add	s1,a4,s0
    8000181a:	02000713          	li	a4,32
    8000181e:	f8e48023          	sb	a4,-128(s1)
    80001822:	0017849b          	addiw	s1,a5,1

  // name: node->name size in xv6 is 16 typically
  for (i = 0; i < (int)sizeof(node->name) && node->name[i] != '\0'; i++) {
    80001826:	15890713          	addi	a4,s2,344
    8000182a:	f3040793          	addi	a5,s0,-208
    8000182e:	97a6                	add	a5,a5,s1
    80001830:	0104861b          	addiw	a2,s1,16
    if (off >= (int)sizeof(line) - 1) break;
    80001834:	07e00593          	li	a1,126
  for (i = 0; i < (int)sizeof(node->name) && node->name[i] != '\0'; i++) {
    80001838:	00074683          	lbu	a3,0(a4)
    8000183c:	ce9d                	beqz	a3,8000187a <ptree_walk+0x126>
    if (off >= (int)sizeof(line) - 1) break;
    8000183e:	0295ce63          	blt	a1,s1,8000187a <ptree_walk+0x126>
    line[off++] = node->name[i];
    80001842:	2485                	addiw	s1,s1,1
    80001844:	00d78023          	sb	a3,0(a5)
  for (i = 0; i < (int)sizeof(node->name) && node->name[i] != '\0'; i++) {
    80001848:	0705                	addi	a4,a4,1
    8000184a:	0785                	addi	a5,a5,1
    8000184c:	fec496e3          	bne	s1,a2,80001838 <ptree_walk+0xe4>
  }

  // newline
  if (off < (int)sizeof(line))
    line[off++] = '\n';
    80001850:	0016049b          	addiw	s1,a2,1
    80001854:	fb060793          	addi	a5,a2,-80
    80001858:	00878633          	add	a2,a5,s0
    8000185c:	47a9                	li	a5,10
    8000185e:	f8f60023          	sb	a5,-128(a2)
    80001862:	a005                	j	80001882 <ptree_walk+0x12e>
  int off = 0;
    80001864:	4581                	li	a1,0
    80001866:	bf3d                	j	800017a4 <ptree_walk+0x50>
    buf[0] = '0';
    80001868:	03000793          	li	a5,48
    8000186c:	00f88023          	sb	a5,0(a7)
    return 1;
    80001870:	4785                	li	a5,1
    80001872:	bf49                	j	80001804 <ptree_walk+0xb0>
  for (i = 0; i < ti; i++)
    80001874:	f6f048e3          	bgtz	a5,800017e4 <ptree_walk+0x90>
    80001878:	b771                	j	80001804 <ptree_walk+0xb0>
  if (off < (int)sizeof(line))
    8000187a:	07f00793          	li	a5,127
    8000187e:	0497d863          	bge	a5,s1,800018ce <ptree_walk+0x17a>

  // Check remaining user buffer space
  int remaining = bufsize - *writtenp;
    80001882:	0009a583          	lw	a1,0(s3) # 1000 <_entry-0x7ffff000>
    80001886:	40ba8c3b          	subw	s8,s5,a1
    8000188a:	000c069b          	sext.w	a3,s8
  if (remaining <= 0) {
    // buffer exhausted
    return 0;
    8000188e:	4501                	li	a0,0
  if (remaining <= 0) {
    80001890:	02d05363          	blez	a3,800018b6 <ptree_walk+0x162>
  }

  if (off > remaining) {
    80001894:	0296df63          	bge	a3,s1,800018d2 <ptree_walk+0x17e>
    // copy only the portion that fits
    if (copyout(pagetable, dst + *writtenp, line, remaining) < 0)
    80001898:	f3040613          	addi	a2,s0,-208
    8000189c:	95de                	add	a1,a1,s7
    8000189e:	855a                	mv	a0,s6
    800018a0:	d43ff0ef          	jal	800015e2 <copyout>
    800018a4:	08054963          	bltz	a0,80001936 <ptree_walk+0x1e2>
      return -1;
    *writtenp += remaining;
    800018a8:	0009a783          	lw	a5,0(s3)
    800018ac:	00fc0c3b          	addw	s8,s8,a5
    800018b0:	0189a023          	sw	s8,0(s3)
    // buffer is full; stop traversal
    return 0;
    800018b4:	4501                	li	a0,0
        return 0;
    }
  }

  return 0;
}
    800018b6:	60ee                	ld	ra,216(sp)
    800018b8:	644e                	ld	s0,208(sp)
    800018ba:	64ae                	ld	s1,200(sp)
    800018bc:	690e                	ld	s2,192(sp)
    800018be:	79ea                	ld	s3,184(sp)
    800018c0:	7a4a                	ld	s4,176(sp)
    800018c2:	7aaa                	ld	s5,168(sp)
    800018c4:	7b0a                	ld	s6,160(sp)
    800018c6:	6bea                	ld	s7,152(sp)
    800018c8:	6c4a                	ld	s8,144(sp)
    800018ca:	612d                	addi	sp,sp,224
    800018cc:	8082                	ret
    800018ce:	8626                	mv	a2,s1
    800018d0:	b741                	j	80001850 <ptree_walk+0xfc>
    if (copyout(pagetable, dst + *writtenp, line, off) < 0)
    800018d2:	86a6                	mv	a3,s1
    800018d4:	f3040613          	addi	a2,s0,-208
    800018d8:	95de                	add	a1,a1,s7
    800018da:	855a                	mv	a0,s6
    800018dc:	d07ff0ef          	jal	800015e2 <copyout>
    800018e0:	04054d63          	bltz	a0,8000193a <ptree_walk+0x1e6>
    *writtenp += off;
    800018e4:	0009a783          	lw	a5,0(s3)
    800018e8:	9fa5                	addw	a5,a5,s1
    800018ea:	00f9a023          	sw	a5,0(s3)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ee:	0000e497          	auipc	s1,0xe
    800018f2:	4aa48493          	addi	s1,s1,1194 # 8000fd98 <proc>
      if (ptree_walk(p, depth + 1, pagetable, dst, bufsize, writtenp) < 0)
    800018f6:	001a0c1b          	addiw	s8,s4,1
  for (p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00014a17          	auipc	s4,0x14
    800018fe:	e9ea0a13          	addi	s4,s4,-354 # 80015798 <tickslock>
    80001902:	a809                	j	80001914 <ptree_walk+0x1c0>
      if (*writtenp >= bufsize) // buffer full, stop early
    80001904:	0009a783          	lw	a5,0(s3)
    80001908:	0357db63          	bge	a5,s5,8000193e <ptree_walk+0x1ea>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000190c:	16848493          	addi	s1,s1,360
    80001910:	03448163          	beq	s1,s4,80001932 <ptree_walk+0x1de>
    if (p->parent == node) {
    80001914:	7c9c                	ld	a5,56(s1)
    80001916:	ff279be3          	bne	a5,s2,8000190c <ptree_walk+0x1b8>
      if (ptree_walk(p, depth + 1, pagetable, dst, bufsize, writtenp) < 0)
    8000191a:	87ce                	mv	a5,s3
    8000191c:	8756                	mv	a4,s5
    8000191e:	86de                	mv	a3,s7
    80001920:	865a                	mv	a2,s6
    80001922:	85e2                	mv	a1,s8
    80001924:	8526                	mv	a0,s1
    80001926:	e2fff0ef          	jal	80001754 <ptree_walk>
    8000192a:	fc055de3          	bgez	a0,80001904 <ptree_walk+0x1b0>
        return -1;
    8000192e:	557d                	li	a0,-1
    80001930:	b759                	j	800018b6 <ptree_walk+0x162>
  return 0;
    80001932:	4501                	li	a0,0
    80001934:	b749                	j	800018b6 <ptree_walk+0x162>
      return -1;
    80001936:	557d                	li	a0,-1
    80001938:	bfbd                	j	800018b6 <ptree_walk+0x162>
      return -1;
    8000193a:	557d                	li	a0,-1
    8000193c:	bfad                	j	800018b6 <ptree_walk+0x162>
        return 0;
    8000193e:	4501                	li	a0,0
    80001940:	bf9d                	j	800018b6 <ptree_walk+0x162>

0000000080001942 <proc_mapstacks>:
{
    80001942:	7139                	addi	sp,sp,-64
    80001944:	fc06                	sd	ra,56(sp)
    80001946:	f822                	sd	s0,48(sp)
    80001948:	f426                	sd	s1,40(sp)
    8000194a:	f04a                	sd	s2,32(sp)
    8000194c:	ec4e                	sd	s3,24(sp)
    8000194e:	e852                	sd	s4,16(sp)
    80001950:	e456                	sd	s5,8(sp)
    80001952:	e05a                	sd	s6,0(sp)
    80001954:	0080                	addi	s0,sp,64
    80001956:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001958:	0000e497          	auipc	s1,0xe
    8000195c:	44048493          	addi	s1,s1,1088 # 8000fd98 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80001960:	8b26                	mv	s6,s1
    80001962:	04fa5937          	lui	s2,0x4fa5
    80001966:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000196a:	0932                	slli	s2,s2,0xc
    8000196c:	fa590913          	addi	s2,s2,-91
    80001970:	0932                	slli	s2,s2,0xc
    80001972:	fa590913          	addi	s2,s2,-91
    80001976:	0932                	slli	s2,s2,0xc
    80001978:	fa590913          	addi	s2,s2,-91
    8000197c:	040009b7          	lui	s3,0x4000
    80001980:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001982:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001984:	00014a97          	auipc	s5,0x14
    80001988:	e14a8a93          	addi	s5,s5,-492 # 80015798 <tickslock>
    char *pa = kalloc();
    8000198c:	972ff0ef          	jal	80000afe <kalloc>
    80001990:	862a                	mv	a2,a0
    if(pa == 0)
    80001992:	cd15                	beqz	a0,800019ce <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001994:	416485b3          	sub	a1,s1,s6
    80001998:	858d                	srai	a1,a1,0x3
    8000199a:	032585b3          	mul	a1,a1,s2
    8000199e:	2585                	addiw	a1,a1,1
    800019a0:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a4:	4719                	li	a4,6
    800019a6:	6685                	lui	a3,0x1
    800019a8:	40b985b3          	sub	a1,s3,a1
    800019ac:	8552                	mv	a0,s4
    800019ae:	ef0ff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b2:	16848493          	addi	s1,s1,360
    800019b6:	fd549be3          	bne	s1,s5,8000198c <proc_mapstacks+0x4a>
}
    800019ba:	70e2                	ld	ra,56(sp)
    800019bc:	7442                	ld	s0,48(sp)
    800019be:	74a2                	ld	s1,40(sp)
    800019c0:	7902                	ld	s2,32(sp)
    800019c2:	69e2                	ld	s3,24(sp)
    800019c4:	6a42                	ld	s4,16(sp)
    800019c6:	6aa2                	ld	s5,8(sp)
    800019c8:	6b02                	ld	s6,0(sp)
    800019ca:	6121                	addi	sp,sp,64
    800019cc:	8082                	ret
      panic("kalloc");
    800019ce:	00005517          	auipc	a0,0x5
    800019d2:	78a50513          	addi	a0,a0,1930 # 80007158 <etext+0x158>
    800019d6:	e0bfe0ef          	jal	800007e0 <panic>

00000000800019da <procinit>:
{
    800019da:	7139                	addi	sp,sp,-64
    800019dc:	fc06                	sd	ra,56(sp)
    800019de:	f822                	sd	s0,48(sp)
    800019e0:	f426                	sd	s1,40(sp)
    800019e2:	f04a                	sd	s2,32(sp)
    800019e4:	ec4e                	sd	s3,24(sp)
    800019e6:	e852                	sd	s4,16(sp)
    800019e8:	e456                	sd	s5,8(sp)
    800019ea:	e05a                	sd	s6,0(sp)
    800019ec:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800019ee:	00005597          	auipc	a1,0x5
    800019f2:	77258593          	addi	a1,a1,1906 # 80007160 <etext+0x160>
    800019f6:	0000e517          	auipc	a0,0xe
    800019fa:	f7250513          	addi	a0,a0,-142 # 8000f968 <pid_lock>
    800019fe:	950ff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a02:	00005597          	auipc	a1,0x5
    80001a06:	76658593          	addi	a1,a1,1894 # 80007168 <etext+0x168>
    80001a0a:	0000e517          	auipc	a0,0xe
    80001a0e:	f7650513          	addi	a0,a0,-138 # 8000f980 <wait_lock>
    80001a12:	93cff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a16:	0000e497          	auipc	s1,0xe
    80001a1a:	38248493          	addi	s1,s1,898 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    80001a1e:	00005b17          	auipc	s6,0x5
    80001a22:	75ab0b13          	addi	s6,s6,1882 # 80007178 <etext+0x178>
      p->kstack = KSTACK((int) (p - proc));
    80001a26:	8aa6                	mv	s5,s1
    80001a28:	04fa5937          	lui	s2,0x4fa5
    80001a2c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a30:	0932                	slli	s2,s2,0xc
    80001a32:	fa590913          	addi	s2,s2,-91
    80001a36:	0932                	slli	s2,s2,0xc
    80001a38:	fa590913          	addi	s2,s2,-91
    80001a3c:	0932                	slli	s2,s2,0xc
    80001a3e:	fa590913          	addi	s2,s2,-91
    80001a42:	040009b7          	lui	s3,0x4000
    80001a46:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a48:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a4a:	00014a17          	auipc	s4,0x14
    80001a4e:	d4ea0a13          	addi	s4,s4,-690 # 80015798 <tickslock>
      initlock(&p->lock, "proc");
    80001a52:	85da                	mv	a1,s6
    80001a54:	8526                	mv	a0,s1
    80001a56:	8f8ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    80001a5a:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a5e:	415487b3          	sub	a5,s1,s5
    80001a62:	878d                	srai	a5,a5,0x3
    80001a64:	032787b3          	mul	a5,a5,s2
    80001a68:	2785                	addiw	a5,a5,1
    80001a6a:	00d7979b          	slliw	a5,a5,0xd
    80001a6e:	40f987b3          	sub	a5,s3,a5
    80001a72:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a74:	16848493          	addi	s1,s1,360
    80001a78:	fd449de3          	bne	s1,s4,80001a52 <procinit+0x78>
}
    80001a7c:	70e2                	ld	ra,56(sp)
    80001a7e:	7442                	ld	s0,48(sp)
    80001a80:	74a2                	ld	s1,40(sp)
    80001a82:	7902                	ld	s2,32(sp)
    80001a84:	69e2                	ld	s3,24(sp)
    80001a86:	6a42                	ld	s4,16(sp)
    80001a88:	6aa2                	ld	s5,8(sp)
    80001a8a:	6b02                	ld	s6,0(sp)
    80001a8c:	6121                	addi	sp,sp,64
    80001a8e:	8082                	ret

0000000080001a90 <cpuid>:
{
    80001a90:	1141                	addi	sp,sp,-16
    80001a92:	e422                	sd	s0,8(sp)
    80001a94:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a96:	8512                	mv	a0,tp
}
    80001a98:	2501                	sext.w	a0,a0
    80001a9a:	6422                	ld	s0,8(sp)
    80001a9c:	0141                	addi	sp,sp,16
    80001a9e:	8082                	ret

0000000080001aa0 <mycpu>:
{
    80001aa0:	1141                	addi	sp,sp,-16
    80001aa2:	e422                	sd	s0,8(sp)
    80001aa4:	0800                	addi	s0,sp,16
    80001aa6:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001aa8:	2781                	sext.w	a5,a5
    80001aaa:	079e                	slli	a5,a5,0x7
}
    80001aac:	0000e517          	auipc	a0,0xe
    80001ab0:	eec50513          	addi	a0,a0,-276 # 8000f998 <cpus>
    80001ab4:	953e                	add	a0,a0,a5
    80001ab6:	6422                	ld	s0,8(sp)
    80001ab8:	0141                	addi	sp,sp,16
    80001aba:	8082                	ret

0000000080001abc <myproc>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	1000                	addi	s0,sp,32
  push_off();
    80001ac6:	8c8ff0ef          	jal	80000b8e <push_off>
    80001aca:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001acc:	2781                	sext.w	a5,a5
    80001ace:	079e                	slli	a5,a5,0x7
    80001ad0:	0000e717          	auipc	a4,0xe
    80001ad4:	e9870713          	addi	a4,a4,-360 # 8000f968 <pid_lock>
    80001ad8:	97ba                	add	a5,a5,a4
    80001ada:	7b84                	ld	s1,48(a5)
  pop_off();
    80001adc:	936ff0ef          	jal	80000c12 <pop_off>
}
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	60e2                	ld	ra,24(sp)
    80001ae4:	6442                	ld	s0,16(sp)
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	6105                	addi	sp,sp,32
    80001aea:	8082                	ret

0000000080001aec <forkret>:
{
    80001aec:	7179                	addi	sp,sp,-48
    80001aee:	f406                	sd	ra,40(sp)
    80001af0:	f022                	sd	s0,32(sp)
    80001af2:	ec26                	sd	s1,24(sp)
    80001af4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001af6:	fc7ff0ef          	jal	80001abc <myproc>
    80001afa:	84aa                	mv	s1,a0
  release(&p->lock);
    80001afc:	96aff0ef          	jal	80000c66 <release>
  if (first) {
    80001b00:	00006797          	auipc	a5,0x6
    80001b04:	d307a783          	lw	a5,-720(a5) # 80007830 <first.1>
    80001b08:	cf8d                	beqz	a5,80001b42 <forkret+0x56>
    fsinit(ROOTDEV);
    80001b0a:	4505                	li	a0,1
    80001b0c:	4a5010ef          	jal	800037b0 <fsinit>
    first = 0;
    80001b10:	00006797          	auipc	a5,0x6
    80001b14:	d207a023          	sw	zero,-736(a5) # 80007830 <first.1>
    __sync_synchronize();
    80001b18:	0ff0000f          	fence
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b1c:	00005517          	auipc	a0,0x5
    80001b20:	66450513          	addi	a0,a0,1636 # 80007180 <etext+0x180>
    80001b24:	fca43823          	sd	a0,-48(s0)
    80001b28:	fc043c23          	sd	zero,-40(s0)
    80001b2c:	fd040593          	addi	a1,s0,-48
    80001b30:	58b020ef          	jal	800048ba <kexec>
    80001b34:	6cbc                	ld	a5,88(s1)
    80001b36:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b38:	6cbc                	ld	a5,88(s1)
    80001b3a:	7bb8                	ld	a4,112(a5)
    80001b3c:	57fd                	li	a5,-1
    80001b3e:	02f70d63          	beq	a4,a5,80001b78 <forkret+0x8c>
  prepare_return();
    80001b42:	34b000ef          	jal	8000268c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b46:	68a8                	ld	a0,80(s1)
    80001b48:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b4a:	04000737          	lui	a4,0x4000
    80001b4e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	0732                	slli	a4,a4,0xc
    80001b52:	00004797          	auipc	a5,0x4
    80001b56:	54a78793          	addi	a5,a5,1354 # 8000609c <userret>
    80001b5a:	00004697          	auipc	a3,0x4
    80001b5e:	4a668693          	addi	a3,a3,1190 # 80006000 <_trampoline>
    80001b62:	8f95                	sub	a5,a5,a3
    80001b64:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b66:	577d                	li	a4,-1
    80001b68:	177e                	slli	a4,a4,0x3f
    80001b6a:	8d59                	or	a0,a0,a4
    80001b6c:	9782                	jalr	a5
}
    80001b6e:	70a2                	ld	ra,40(sp)
    80001b70:	7402                	ld	s0,32(sp)
    80001b72:	64e2                	ld	s1,24(sp)
    80001b74:	6145                	addi	sp,sp,48
    80001b76:	8082                	ret
      panic("exec");
    80001b78:	00005517          	auipc	a0,0x5
    80001b7c:	61050513          	addi	a0,a0,1552 # 80007188 <etext+0x188>
    80001b80:	c61fe0ef          	jal	800007e0 <panic>

0000000080001b84 <allocpid>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	e04a                	sd	s2,0(sp)
    80001b8e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b90:	0000e917          	auipc	s2,0xe
    80001b94:	dd890913          	addi	s2,s2,-552 # 8000f968 <pid_lock>
    80001b98:	854a                	mv	a0,s2
    80001b9a:	834ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    80001b9e:	00006797          	auipc	a5,0x6
    80001ba2:	c9678793          	addi	a5,a5,-874 # 80007834 <nextpid>
    80001ba6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ba8:	0014871b          	addiw	a4,s1,1
    80001bac:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bae:	854a                	mv	a0,s2
    80001bb0:	8b6ff0ef          	jal	80000c66 <release>
}
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6902                	ld	s2,0(sp)
    80001bbe:	6105                	addi	sp,sp,32
    80001bc0:	8082                	ret

0000000080001bc2 <proc_pagetable>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	e04a                	sd	s2,0(sp)
    80001bcc:	1000                	addi	s0,sp,32
    80001bce:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bd0:	dc4ff0ef          	jal	80001194 <uvmcreate>
    80001bd4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bd6:	cd05                	beqz	a0,80001c0e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bd8:	4729                	li	a4,10
    80001bda:	00004697          	auipc	a3,0x4
    80001bde:	42668693          	addi	a3,a3,1062 # 80006000 <_trampoline>
    80001be2:	6605                	lui	a2,0x1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	c02ff0ef          	jal	80000fee <mappages>
    80001bf0:	02054663          	bltz	a0,80001c1c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bf4:	4719                	li	a4,6
    80001bf6:	05893683          	ld	a3,88(s2)
    80001bfa:	6605                	lui	a2,0x1
    80001bfc:	020005b7          	lui	a1,0x2000
    80001c00:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c02:	05b6                	slli	a1,a1,0xd
    80001c04:	8526                	mv	a0,s1
    80001c06:	be8ff0ef          	jal	80000fee <mappages>
    80001c0a:	00054f63          	bltz	a0,80001c28 <proc_pagetable+0x66>
}
    80001c0e:	8526                	mv	a0,s1
    80001c10:	60e2                	ld	ra,24(sp)
    80001c12:	6442                	ld	s0,16(sp)
    80001c14:	64a2                	ld	s1,8(sp)
    80001c16:	6902                	ld	s2,0(sp)
    80001c18:	6105                	addi	sp,sp,32
    80001c1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c1c:	4581                	li	a1,0
    80001c1e:	8526                	mv	a0,s1
    80001c20:	f6eff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001c24:	4481                	li	s1,0
    80001c26:	b7e5                	j	80001c0e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c28:	4681                	li	a3,0
    80001c2a:	4605                	li	a2,1
    80001c2c:	040005b7          	lui	a1,0x4000
    80001c30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c32:	05b2                	slli	a1,a1,0xc
    80001c34:	8526                	mv	a0,s1
    80001c36:	d84ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001c3a:	4581                	li	a1,0
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	f50ff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	b7e9                	j	80001c0e <proc_pagetable+0x4c>

0000000080001c46 <proc_freepagetable>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	84aa                	mv	s1,a0
    80001c54:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c56:	4681                	li	a3,0
    80001c58:	4605                	li	a2,1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	d58ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c66:	4681                	li	a3,0
    80001c68:	4605                	li	a2,1
    80001c6a:	020005b7          	lui	a1,0x2000
    80001c6e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c70:	05b6                	slli	a1,a1,0xd
    80001c72:	8526                	mv	a0,s1
    80001c74:	d46ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001c78:	85ca                	mv	a1,s2
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	f12ff0ef          	jal	8000138e <uvmfree>
}
    80001c80:	60e2                	ld	ra,24(sp)
    80001c82:	6442                	ld	s0,16(sp)
    80001c84:	64a2                	ld	s1,8(sp)
    80001c86:	6902                	ld	s2,0(sp)
    80001c88:	6105                	addi	sp,sp,32
    80001c8a:	8082                	ret

0000000080001c8c <freeproc>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c98:	6d28                	ld	a0,88(a0)
    80001c9a:	c119                	beqz	a0,80001ca0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c9c:	d81fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ca0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ca4:	68a8                	ld	a0,80(s1)
    80001ca6:	c501                	beqz	a0,80001cae <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ca8:	64ac                	ld	a1,72(s1)
    80001caa:	f9dff0ef          	jal	80001c46 <proc_freepagetable>
  p->pagetable = 0;
    80001cae:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cb2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cb6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cba:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cbe:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cc2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cc6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cca:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cce:	0004ac23          	sw	zero,24(s1)
}
    80001cd2:	60e2                	ld	ra,24(sp)
    80001cd4:	6442                	ld	s0,16(sp)
    80001cd6:	64a2                	ld	s1,8(sp)
    80001cd8:	6105                	addi	sp,sp,32
    80001cda:	8082                	ret

0000000080001cdc <allocproc>:
{
    80001cdc:	1101                	addi	sp,sp,-32
    80001cde:	ec06                	sd	ra,24(sp)
    80001ce0:	e822                	sd	s0,16(sp)
    80001ce2:	e426                	sd	s1,8(sp)
    80001ce4:	e04a                	sd	s2,0(sp)
    80001ce6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ce8:	0000e497          	auipc	s1,0xe
    80001cec:	0b048493          	addi	s1,s1,176 # 8000fd98 <proc>
    80001cf0:	00014917          	auipc	s2,0x14
    80001cf4:	aa890913          	addi	s2,s2,-1368 # 80015798 <tickslock>
    acquire(&p->lock);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	ed5fe0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001cfe:	4c9c                	lw	a5,24(s1)
    80001d00:	cb91                	beqz	a5,80001d14 <allocproc+0x38>
      release(&p->lock);
    80001d02:	8526                	mv	a0,s1
    80001d04:	f63fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d08:	16848493          	addi	s1,s1,360
    80001d0c:	ff2496e3          	bne	s1,s2,80001cf8 <allocproc+0x1c>
  return 0;
    80001d10:	4481                	li	s1,0
    80001d12:	a089                	j	80001d54 <allocproc+0x78>
  p->pid = allocpid();
    80001d14:	e71ff0ef          	jal	80001b84 <allocpid>
    80001d18:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d1a:	4785                	li	a5,1
    80001d1c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d1e:	de1fe0ef          	jal	80000afe <kalloc>
    80001d22:	892a                	mv	s2,a0
    80001d24:	eca8                	sd	a0,88(s1)
    80001d26:	cd15                	beqz	a0,80001d62 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	e99ff0ef          	jal	80001bc2 <proc_pagetable>
    80001d2e:	892a                	mv	s2,a0
    80001d30:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d32:	c121                	beqz	a0,80001d72 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001d34:	07000613          	li	a2,112
    80001d38:	4581                	li	a1,0
    80001d3a:	06048513          	addi	a0,s1,96
    80001d3e:	f65fe0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001d42:	00000797          	auipc	a5,0x0
    80001d46:	daa78793          	addi	a5,a5,-598 # 80001aec <forkret>
    80001d4a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d4c:	60bc                	ld	a5,64(s1)
    80001d4e:	6705                	lui	a4,0x1
    80001d50:	97ba                	add	a5,a5,a4
    80001d52:	f4bc                	sd	a5,104(s1)
}
    80001d54:	8526                	mv	a0,s1
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret
    freeproc(p);
    80001d62:	8526                	mv	a0,s1
    80001d64:	f29ff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	efdfe0ef          	jal	80000c66 <release>
    return 0;
    80001d6e:	84ca                	mv	s1,s2
    80001d70:	b7d5                	j	80001d54 <allocproc+0x78>
    freeproc(p);
    80001d72:	8526                	mv	a0,s1
    80001d74:	f19ff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	eedfe0ef          	jal	80000c66 <release>
    return 0;
    80001d7e:	84ca                	mv	s1,s2
    80001d80:	bfd1                	j	80001d54 <allocproc+0x78>

0000000080001d82 <userinit>:
{
    80001d82:	1101                	addi	sp,sp,-32
    80001d84:	ec06                	sd	ra,24(sp)
    80001d86:	e822                	sd	s0,16(sp)
    80001d88:	e426                	sd	s1,8(sp)
    80001d8a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d8c:	f51ff0ef          	jal	80001cdc <allocproc>
    80001d90:	84aa                	mv	s1,a0
  initproc = p;
    80001d92:	00006797          	auipc	a5,0x6
    80001d96:	aca7b723          	sd	a0,-1330(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001d9a:	00005517          	auipc	a0,0x5
    80001d9e:	3f650513          	addi	a0,a0,1014 # 80007190 <etext+0x190>
    80001da2:	731010ef          	jal	80003cd2 <namei>
    80001da6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001daa:	478d                	li	a5,3
    80001dac:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	eb7fe0ef          	jal	80000c66 <release>
}
    80001db4:	60e2                	ld	ra,24(sp)
    80001db6:	6442                	ld	s0,16(sp)
    80001db8:	64a2                	ld	s1,8(sp)
    80001dba:	6105                	addi	sp,sp,32
    80001dbc:	8082                	ret

0000000080001dbe <growproc>:
{
    80001dbe:	1101                	addi	sp,sp,-32
    80001dc0:	ec06                	sd	ra,24(sp)
    80001dc2:	e822                	sd	s0,16(sp)
    80001dc4:	e426                	sd	s1,8(sp)
    80001dc6:	e04a                	sd	s2,0(sp)
    80001dc8:	1000                	addi	s0,sp,32
    80001dca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dcc:	cf1ff0ef          	jal	80001abc <myproc>
    80001dd0:	892a                	mv	s2,a0
  sz = p->sz;
    80001dd2:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dd4:	02905963          	blez	s1,80001e06 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001dd8:	00b48633          	add	a2,s1,a1
    80001ddc:	020007b7          	lui	a5,0x2000
    80001de0:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001de2:	07b6                	slli	a5,a5,0xd
    80001de4:	02c7ea63          	bltu	a5,a2,80001e18 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001de8:	4691                	li	a3,4
    80001dea:	6928                	ld	a0,80(a0)
    80001dec:	c9cff0ef          	jal	80001288 <uvmalloc>
    80001df0:	85aa                	mv	a1,a0
    80001df2:	c50d                	beqz	a0,80001e1c <growproc+0x5e>
  p->sz = sz;
    80001df4:	04b93423          	sd	a1,72(s2)
  return 0;
    80001df8:	4501                	li	a0,0
}
    80001dfa:	60e2                	ld	ra,24(sp)
    80001dfc:	6442                	ld	s0,16(sp)
    80001dfe:	64a2                	ld	s1,8(sp)
    80001e00:	6902                	ld	s2,0(sp)
    80001e02:	6105                	addi	sp,sp,32
    80001e04:	8082                	ret
  } else if(n < 0){
    80001e06:	fe04d7e3          	bgez	s1,80001df4 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e0a:	00b48633          	add	a2,s1,a1
    80001e0e:	6928                	ld	a0,80(a0)
    80001e10:	c34ff0ef          	jal	80001244 <uvmdealloc>
    80001e14:	85aa                	mv	a1,a0
    80001e16:	bff9                	j	80001df4 <growproc+0x36>
      return -1;
    80001e18:	557d                	li	a0,-1
    80001e1a:	b7c5                	j	80001dfa <growproc+0x3c>
      return -1;
    80001e1c:	557d                	li	a0,-1
    80001e1e:	bff1                	j	80001dfa <growproc+0x3c>

0000000080001e20 <kfork>:
{
    80001e20:	7139                	addi	sp,sp,-64
    80001e22:	fc06                	sd	ra,56(sp)
    80001e24:	f822                	sd	s0,48(sp)
    80001e26:	f04a                	sd	s2,32(sp)
    80001e28:	e456                	sd	s5,8(sp)
    80001e2a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e2c:	c91ff0ef          	jal	80001abc <myproc>
    80001e30:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e32:	eabff0ef          	jal	80001cdc <allocproc>
    80001e36:	0e050a63          	beqz	a0,80001f2a <kfork+0x10a>
    80001e3a:	e852                	sd	s4,16(sp)
    80001e3c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e3e:	048ab603          	ld	a2,72(s5)
    80001e42:	692c                	ld	a1,80(a0)
    80001e44:	050ab503          	ld	a0,80(s5)
    80001e48:	d78ff0ef          	jal	800013c0 <uvmcopy>
    80001e4c:	04054a63          	bltz	a0,80001ea0 <kfork+0x80>
    80001e50:	f426                	sd	s1,40(sp)
    80001e52:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e54:	048ab783          	ld	a5,72(s5)
    80001e58:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e5c:	058ab683          	ld	a3,88(s5)
    80001e60:	87b6                	mv	a5,a3
    80001e62:	058a3703          	ld	a4,88(s4)
    80001e66:	12068693          	addi	a3,a3,288
    80001e6a:	0007b803          	ld	a6,0(a5)
    80001e6e:	6788                	ld	a0,8(a5)
    80001e70:	6b8c                	ld	a1,16(a5)
    80001e72:	6f90                	ld	a2,24(a5)
    80001e74:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001e78:	e708                	sd	a0,8(a4)
    80001e7a:	eb0c                	sd	a1,16(a4)
    80001e7c:	ef10                	sd	a2,24(a4)
    80001e7e:	02078793          	addi	a5,a5,32
    80001e82:	02070713          	addi	a4,a4,32
    80001e86:	fed792e3          	bne	a5,a3,80001e6a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e8a:	058a3783          	ld	a5,88(s4)
    80001e8e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e92:	0d0a8493          	addi	s1,s5,208
    80001e96:	0d0a0913          	addi	s2,s4,208
    80001e9a:	150a8993          	addi	s3,s5,336
    80001e9e:	a831                	j	80001eba <kfork+0x9a>
    freeproc(np);
    80001ea0:	8552                	mv	a0,s4
    80001ea2:	debff0ef          	jal	80001c8c <freeproc>
    release(&np->lock);
    80001ea6:	8552                	mv	a0,s4
    80001ea8:	dbffe0ef          	jal	80000c66 <release>
    return -1;
    80001eac:	597d                	li	s2,-1
    80001eae:	6a42                	ld	s4,16(sp)
    80001eb0:	a0b5                	j	80001f1c <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001eb2:	04a1                	addi	s1,s1,8
    80001eb4:	0921                	addi	s2,s2,8
    80001eb6:	01348963          	beq	s1,s3,80001ec8 <kfork+0xa8>
    if(p->ofile[i])
    80001eba:	6088                	ld	a0,0(s1)
    80001ebc:	d97d                	beqz	a0,80001eb2 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ebe:	3ae020ef          	jal	8000426c <filedup>
    80001ec2:	00a93023          	sd	a0,0(s2)
    80001ec6:	b7f5                	j	80001eb2 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001ec8:	150ab503          	ld	a0,336(s5)
    80001ecc:	5ba010ef          	jal	80003486 <idup>
    80001ed0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed4:	4641                	li	a2,16
    80001ed6:	158a8593          	addi	a1,s5,344
    80001eda:	158a0513          	addi	a0,s4,344
    80001ede:	f03fe0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	d7ffe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001eec:	0000e497          	auipc	s1,0xe
    80001ef0:	a9448493          	addi	s1,s1,-1388 # 8000f980 <wait_lock>
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	cd9fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001efa:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	d67fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001f04:	8552                	mv	a0,s4
    80001f06:	cc9fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001f0a:	478d                	li	a5,3
    80001f0c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	d55fe0ef          	jal	80000c66 <release>
  return pid;
    80001f16:	74a2                	ld	s1,40(sp)
    80001f18:	69e2                	ld	s3,24(sp)
    80001f1a:	6a42                	ld	s4,16(sp)
}
    80001f1c:	854a                	mv	a0,s2
    80001f1e:	70e2                	ld	ra,56(sp)
    80001f20:	7442                	ld	s0,48(sp)
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	6aa2                	ld	s5,8(sp)
    80001f26:	6121                	addi	sp,sp,64
    80001f28:	8082                	ret
    return -1;
    80001f2a:	597d                	li	s2,-1
    80001f2c:	bfc5                	j	80001f1c <kfork+0xfc>

0000000080001f2e <scheduler>:
{
    80001f2e:	715d                	addi	sp,sp,-80
    80001f30:	e486                	sd	ra,72(sp)
    80001f32:	e0a2                	sd	s0,64(sp)
    80001f34:	fc26                	sd	s1,56(sp)
    80001f36:	f84a                	sd	s2,48(sp)
    80001f38:	f44e                	sd	s3,40(sp)
    80001f3a:	f052                	sd	s4,32(sp)
    80001f3c:	ec56                	sd	s5,24(sp)
    80001f3e:	e85a                	sd	s6,16(sp)
    80001f40:	e45e                	sd	s7,8(sp)
    80001f42:	e062                	sd	s8,0(sp)
    80001f44:	0880                	addi	s0,sp,80
    80001f46:	8792                	mv	a5,tp
  int id = r_tp();
    80001f48:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f4a:	00779b13          	slli	s6,a5,0x7
    80001f4e:	0000e717          	auipc	a4,0xe
    80001f52:	a1a70713          	addi	a4,a4,-1510 # 8000f968 <pid_lock>
    80001f56:	975a                	add	a4,a4,s6
    80001f58:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f5c:	0000e717          	auipc	a4,0xe
    80001f60:	a4470713          	addi	a4,a4,-1468 # 8000f9a0 <cpus+0x8>
    80001f64:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f66:	4c11                	li	s8,4
        c->proc = p;
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	0000ea17          	auipc	s4,0xe
    80001f6e:	9fea0a13          	addi	s4,s4,-1538 # 8000f968 <pid_lock>
    80001f72:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f74:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f76:	00014997          	auipc	s3,0x14
    80001f7a:	82298993          	addi	s3,s3,-2014 # 80015798 <tickslock>
    80001f7e:	a83d                	j	80001fbc <scheduler+0x8e>
      release(&p->lock);
    80001f80:	8526                	mv	a0,s1
    80001f82:	ce5fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	16848493          	addi	s1,s1,360
    80001f8a:	03348563          	beq	s1,s3,80001fb4 <scheduler+0x86>
      acquire(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	c3ffe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001f94:	4c9c                	lw	a5,24(s1)
    80001f96:	ff2795e3          	bne	a5,s2,80001f80 <scheduler+0x52>
        p->state = RUNNING;
    80001f9a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f9e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fa2:	06048593          	addi	a1,s1,96
    80001fa6:	855a                	mv	a0,s6
    80001fa8:	63e000ef          	jal	800025e6 <swtch>
        c->proc = 0;
    80001fac:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001fb0:	8ade                	mv	s5,s7
    80001fb2:	b7f9                	j	80001f80 <scheduler+0x52>
    if(found == 0) {
    80001fb4:	000a9463          	bnez	s5,80001fbc <scheduler+0x8e>
      asm volatile("wfi");
    80001fb8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fc4:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fcc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fce:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fd2:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd4:	0000e497          	auipc	s1,0xe
    80001fd8:	dc448493          	addi	s1,s1,-572 # 8000fd98 <proc>
      if(p->state == RUNNABLE) {
    80001fdc:	490d                	li	s2,3
    80001fde:	bf45                	j	80001f8e <scheduler+0x60>

0000000080001fe0 <sched>:
{
    80001fe0:	7179                	addi	sp,sp,-48
    80001fe2:	f406                	sd	ra,40(sp)
    80001fe4:	f022                	sd	s0,32(sp)
    80001fe6:	ec26                	sd	s1,24(sp)
    80001fe8:	e84a                	sd	s2,16(sp)
    80001fea:	e44e                	sd	s3,8(sp)
    80001fec:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fee:	acfff0ef          	jal	80001abc <myproc>
    80001ff2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ff4:	b71fe0ef          	jal	80000b64 <holding>
    80001ff8:	c92d                	beqz	a0,8000206a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ffa:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ffc:	2781                	sext.w	a5,a5
    80001ffe:	079e                	slli	a5,a5,0x7
    80002000:	0000e717          	auipc	a4,0xe
    80002004:	96870713          	addi	a4,a4,-1688 # 8000f968 <pid_lock>
    80002008:	97ba                	add	a5,a5,a4
    8000200a:	0a87a703          	lw	a4,168(a5)
    8000200e:	4785                	li	a5,1
    80002010:	06f71363          	bne	a4,a5,80002076 <sched+0x96>
  if(p->state == RUNNING)
    80002014:	4c98                	lw	a4,24(s1)
    80002016:	4791                	li	a5,4
    80002018:	06f70563          	beq	a4,a5,80002082 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002020:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002022:	e7b5                	bnez	a5,8000208e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002024:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002026:	0000e917          	auipc	s2,0xe
    8000202a:	94290913          	addi	s2,s2,-1726 # 8000f968 <pid_lock>
    8000202e:	2781                	sext.w	a5,a5
    80002030:	079e                	slli	a5,a5,0x7
    80002032:	97ca                	add	a5,a5,s2
    80002034:	0ac7a983          	lw	s3,172(a5)
    80002038:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	079e                	slli	a5,a5,0x7
    8000203e:	0000e597          	auipc	a1,0xe
    80002042:	96258593          	addi	a1,a1,-1694 # 8000f9a0 <cpus+0x8>
    80002046:	95be                	add	a1,a1,a5
    80002048:	06048513          	addi	a0,s1,96
    8000204c:	59a000ef          	jal	800025e6 <swtch>
    80002050:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	slli	a5,a5,0x7
    80002056:	993e                	add	s2,s2,a5
    80002058:	0b392623          	sw	s3,172(s2)
}
    8000205c:	70a2                	ld	ra,40(sp)
    8000205e:	7402                	ld	s0,32(sp)
    80002060:	64e2                	ld	s1,24(sp)
    80002062:	6942                	ld	s2,16(sp)
    80002064:	69a2                	ld	s3,8(sp)
    80002066:	6145                	addi	sp,sp,48
    80002068:	8082                	ret
    panic("sched p->lock");
    8000206a:	00005517          	auipc	a0,0x5
    8000206e:	12e50513          	addi	a0,a0,302 # 80007198 <etext+0x198>
    80002072:	f6efe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80002076:	00005517          	auipc	a0,0x5
    8000207a:	13250513          	addi	a0,a0,306 # 800071a8 <etext+0x1a8>
    8000207e:	f62fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80002082:	00005517          	auipc	a0,0x5
    80002086:	13650513          	addi	a0,a0,310 # 800071b8 <etext+0x1b8>
    8000208a:	f56fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    8000208e:	00005517          	auipc	a0,0x5
    80002092:	13a50513          	addi	a0,a0,314 # 800071c8 <etext+0x1c8>
    80002096:	f4afe0ef          	jal	800007e0 <panic>

000000008000209a <yield>:
{
    8000209a:	1101                	addi	sp,sp,-32
    8000209c:	ec06                	sd	ra,24(sp)
    8000209e:	e822                	sd	s0,16(sp)
    800020a0:	e426                	sd	s1,8(sp)
    800020a2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a4:	a19ff0ef          	jal	80001abc <myproc>
    800020a8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020aa:	b25fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    800020ae:	478d                	li	a5,3
    800020b0:	cc9c                	sw	a5,24(s1)
  sched();
    800020b2:	f2fff0ef          	jal	80001fe0 <sched>
  release(&p->lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	baffe0ef          	jal	80000c66 <release>
}
    800020bc:	60e2                	ld	ra,24(sp)
    800020be:	6442                	ld	s0,16(sp)
    800020c0:	64a2                	ld	s1,8(sp)
    800020c2:	6105                	addi	sp,sp,32
    800020c4:	8082                	ret

00000000800020c6 <sleep>:
{
    800020c6:	7179                	addi	sp,sp,-48
    800020c8:	f406                	sd	ra,40(sp)
    800020ca:	f022                	sd	s0,32(sp)
    800020cc:	ec26                	sd	s1,24(sp)
    800020ce:	e84a                	sd	s2,16(sp)
    800020d0:	e44e                	sd	s3,8(sp)
    800020d2:	1800                	addi	s0,sp,48
    800020d4:	89aa                	mv	s3,a0
    800020d6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020d8:	9e5ff0ef          	jal	80001abc <myproc>
    800020dc:	84aa                	mv	s1,a0
  acquire(&p->lock);  //DOC: sleeplock1
    800020de:	af1fe0ef          	jal	80000bce <acquire>
  release(lk);
    800020e2:	854a                	mv	a0,s2
    800020e4:	b83fe0ef          	jal	80000c66 <release>
  p->chan = chan;
    800020e8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020ec:	4789                	li	a5,2
    800020ee:	cc9c                	sw	a5,24(s1)
  sched();
    800020f0:	ef1ff0ef          	jal	80001fe0 <sched>
  p->chan = 0;
    800020f4:	0204b023          	sd	zero,32(s1)
  release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	b6dfe0ef          	jal	80000c66 <release>
  acquire(lk);
    800020fe:	854a                	mv	a0,s2
    80002100:	acffe0ef          	jal	80000bce <acquire>
}
    80002104:	70a2                	ld	ra,40(sp)
    80002106:	7402                	ld	s0,32(sp)
    80002108:	64e2                	ld	s1,24(sp)
    8000210a:	6942                	ld	s2,16(sp)
    8000210c:	69a2                	ld	s3,8(sp)
    8000210e:	6145                	addi	sp,sp,48
    80002110:	8082                	ret

0000000080002112 <wakeup>:
{
    80002112:	7139                	addi	sp,sp,-64
    80002114:	fc06                	sd	ra,56(sp)
    80002116:	f822                	sd	s0,48(sp)
    80002118:	f426                	sd	s1,40(sp)
    8000211a:	f04a                	sd	s2,32(sp)
    8000211c:	ec4e                	sd	s3,24(sp)
    8000211e:	e852                	sd	s4,16(sp)
    80002120:	e456                	sd	s5,8(sp)
    80002122:	0080                	addi	s0,sp,64
    80002124:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002126:	0000e497          	auipc	s1,0xe
    8000212a:	c7248493          	addi	s1,s1,-910 # 8000fd98 <proc>
      if(p->state == SLEEPING && p->chan == chan) {
    8000212e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002130:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002132:	00013917          	auipc	s2,0x13
    80002136:	66690913          	addi	s2,s2,1638 # 80015798 <tickslock>
    8000213a:	a801                	j	8000214a <wakeup+0x38>
      release(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	b29fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002142:	16848493          	addi	s1,s1,360
    80002146:	03248263          	beq	s1,s2,8000216a <wakeup+0x58>
    if(p != myproc()){
    8000214a:	973ff0ef          	jal	80001abc <myproc>
    8000214e:	fea48ae3          	beq	s1,a0,80002142 <wakeup+0x30>
      acquire(&p->lock);
    80002152:	8526                	mv	a0,s1
    80002154:	a7bfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002158:	4c9c                	lw	a5,24(s1)
    8000215a:	ff3791e3          	bne	a5,s3,8000213c <wakeup+0x2a>
    8000215e:	709c                	ld	a5,32(s1)
    80002160:	fd479ee3          	bne	a5,s4,8000213c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002164:	0154ac23          	sw	s5,24(s1)
    80002168:	bfd1                	j	8000213c <wakeup+0x2a>
}
    8000216a:	70e2                	ld	ra,56(sp)
    8000216c:	7442                	ld	s0,48(sp)
    8000216e:	74a2                	ld	s1,40(sp)
    80002170:	7902                	ld	s2,32(sp)
    80002172:	69e2                	ld	s3,24(sp)
    80002174:	6a42                	ld	s4,16(sp)
    80002176:	6aa2                	ld	s5,8(sp)
    80002178:	6121                	addi	sp,sp,64
    8000217a:	8082                	ret

000000008000217c <reparent>:
{
    8000217c:	7179                	addi	sp,sp,-48
    8000217e:	f406                	sd	ra,40(sp)
    80002180:	f022                	sd	s0,32(sp)
    80002182:	ec26                	sd	s1,24(sp)
    80002184:	e84a                	sd	s2,16(sp)
    80002186:	e44e                	sd	s3,8(sp)
    80002188:	e052                	sd	s4,0(sp)
    8000218a:	1800                	addi	s0,sp,48
    8000218c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218e:	0000e497          	auipc	s1,0xe
    80002192:	c0a48493          	addi	s1,s1,-1014 # 8000fd98 <proc>
      pp->parent = initproc;
    80002196:	00005a17          	auipc	s4,0x5
    8000219a:	6caa0a13          	addi	s4,s4,1738 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000219e:	00013997          	auipc	s3,0x13
    800021a2:	5fa98993          	addi	s3,s3,1530 # 80015798 <tickslock>
    800021a6:	a029                	j	800021b0 <reparent+0x34>
    800021a8:	16848493          	addi	s1,s1,360
    800021ac:	01348b63          	beq	s1,s3,800021c2 <reparent+0x46>
    if(pp->parent == p){
    800021b0:	7c9c                	ld	a5,56(s1)
    800021b2:	ff279be3          	bne	a5,s2,800021a8 <reparent+0x2c>
      pp->parent = initproc;
    800021b6:	000a3503          	ld	a0,0(s4)
    800021ba:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021bc:	f57ff0ef          	jal	80002112 <wakeup>
    800021c0:	b7e5                	j	800021a8 <reparent+0x2c>
}
    800021c2:	70a2                	ld	ra,40(sp)
    800021c4:	7402                	ld	s0,32(sp)
    800021c6:	64e2                	ld	s1,24(sp)
    800021c8:	6942                	ld	s2,16(sp)
    800021ca:	69a2                	ld	s3,8(sp)
    800021cc:	6a02                	ld	s4,0(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret

00000000800021d2 <kexit>:
{
    800021d2:	7179                	addi	sp,sp,-48
    800021d4:	f406                	sd	ra,40(sp)
    800021d6:	f022                	sd	s0,32(sp)
    800021d8:	ec26                	sd	s1,24(sp)
    800021da:	e84a                	sd	s2,16(sp)
    800021dc:	e44e                	sd	s3,8(sp)
    800021de:	e052                	sd	s4,0(sp)
    800021e0:	1800                	addi	s0,sp,48
    800021e2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021e4:	8d9ff0ef          	jal	80001abc <myproc>
    800021e8:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ea:	00005797          	auipc	a5,0x5
    800021ee:	6767b783          	ld	a5,1654(a5) # 80007860 <initproc>
    800021f2:	0d050493          	addi	s1,a0,208
    800021f6:	15050913          	addi	s2,a0,336
    800021fa:	00a79f63          	bne	a5,a0,80002218 <kexit+0x46>
    panic("init exiting");
    800021fe:	00005517          	auipc	a0,0x5
    80002202:	fe250513          	addi	a0,a0,-30 # 800071e0 <etext+0x1e0>
    80002206:	ddafe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000220a:	0a8020ef          	jal	800042b2 <fileclose>
      p->ofile[fd] = 0;
    8000220e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002212:	04a1                	addi	s1,s1,8
    80002214:	01248563          	beq	s1,s2,8000221e <kexit+0x4c>
    if(p->ofile[fd]){
    80002218:	6088                	ld	a0,0(s1)
    8000221a:	f965                	bnez	a0,8000220a <kexit+0x38>
    8000221c:	bfdd                	j	80002212 <kexit+0x40>
  begin_op();
    8000221e:	489010ef          	jal	80003ea6 <begin_op>
  iput(p->cwd);
    80002222:	1509b503          	ld	a0,336(s3)
    80002226:	418010ef          	jal	8000363e <iput>
  end_op();
    8000222a:	4e7010ef          	jal	80003f10 <end_op>
  p->cwd = 0;
    8000222e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002232:	0000d497          	auipc	s1,0xd
    80002236:	74e48493          	addi	s1,s1,1870 # 8000f980 <wait_lock>
    8000223a:	8526                	mv	a0,s1
    8000223c:	993fe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002240:	854e                	mv	a0,s3
    80002242:	f3bff0ef          	jal	8000217c <reparent>
  wakeup(p->parent);
    80002246:	0389b503          	ld	a0,56(s3)
    8000224a:	ec9ff0ef          	jal	80002112 <wakeup>
  acquire(&p->lock);
    8000224e:	854e                	mv	a0,s3
    80002250:	97ffe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002254:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002258:	4795                	li	a5,5
    8000225a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	a07fe0ef          	jal	80000c66 <release>
  sched();
    80002264:	d7dff0ef          	jal	80001fe0 <sched>
  panic("zombie exit");
    80002268:	00005517          	auipc	a0,0x5
    8000226c:	f8850513          	addi	a0,a0,-120 # 800071f0 <etext+0x1f0>
    80002270:	d70fe0ef          	jal	800007e0 <panic>

0000000080002274 <kkill>:
{
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	1800                	addi	s0,sp,48
    80002282:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002284:	0000e497          	auipc	s1,0xe
    80002288:	b1448493          	addi	s1,s1,-1260 # 8000fd98 <proc>
    8000228c:	00013997          	auipc	s3,0x13
    80002290:	50c98993          	addi	s3,s3,1292 # 80015798 <tickslock>
    acquire(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	939fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    8000229a:	589c                	lw	a5,48(s1)
    8000229c:	01278b63          	beq	a5,s2,800022b2 <kkill+0x3e>
    release(&p->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	9c5fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a6:	16848493          	addi	s1,s1,360
    800022aa:	ff3495e3          	bne	s1,s3,80002294 <kkill+0x20>
  return -1;
    800022ae:	557d                	li	a0,-1
    800022b0:	a819                	j	800022c6 <kkill+0x52>
      p->killed = 1;
    800022b2:	4785                	li	a5,1
    800022b4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b6:	4c98                	lw	a4,24(s1)
    800022b8:	4789                	li	a5,2
    800022ba:	00f70d63          	beq	a4,a5,800022d4 <kkill+0x60>
      release(&p->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	9a7fe0ef          	jal	80000c66 <release>
      return 0;
    800022c4:	4501                	li	a0,0
}
    800022c6:	70a2                	ld	ra,40(sp)
    800022c8:	7402                	ld	s0,32(sp)
    800022ca:	64e2                	ld	s1,24(sp)
    800022cc:	6942                	ld	s2,16(sp)
    800022ce:	69a2                	ld	s3,8(sp)
    800022d0:	6145                	addi	sp,sp,48
    800022d2:	8082                	ret
        p->state = RUNNABLE;
    800022d4:	478d                	li	a5,3
    800022d6:	cc9c                	sw	a5,24(s1)
    800022d8:	b7dd                	j	800022be <kkill+0x4a>

00000000800022da <setkilled>:
{
    800022da:	1101                	addi	sp,sp,-32
    800022dc:	ec06                	sd	ra,24(sp)
    800022de:	e822                	sd	s0,16(sp)
    800022e0:	e426                	sd	s1,8(sp)
    800022e2:	1000                	addi	s0,sp,32
    800022e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e6:	8e9fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800022ea:	4785                	li	a5,1
    800022ec:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	977fe0ef          	jal	80000c66 <release>
}
    800022f4:	60e2                	ld	ra,24(sp)
    800022f6:	6442                	ld	s0,16(sp)
    800022f8:	64a2                	ld	s1,8(sp)
    800022fa:	6105                	addi	sp,sp,32
    800022fc:	8082                	ret

00000000800022fe <killed>:
{
    800022fe:	1101                	addi	sp,sp,-32
    80002300:	ec06                	sd	ra,24(sp)
    80002302:	e822                	sd	s0,16(sp)
    80002304:	e426                	sd	s1,8(sp)
    80002306:	e04a                	sd	s2,0(sp)
    80002308:	1000                	addi	s0,sp,32
    8000230a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000230c:	8c3fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002310:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	951fe0ef          	jal	80000c66 <release>
}
    8000231a:	854a                	mv	a0,s2
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6902                	ld	s2,0(sp)
    80002324:	6105                	addi	sp,sp,32
    80002326:	8082                	ret

0000000080002328 <kwait>:
{
    80002328:	715d                	addi	sp,sp,-80
    8000232a:	e486                	sd	ra,72(sp)
    8000232c:	e0a2                	sd	s0,64(sp)
    8000232e:	fc26                	sd	s1,56(sp)
    80002330:	f84a                	sd	s2,48(sp)
    80002332:	f44e                	sd	s3,40(sp)
    80002334:	f052                	sd	s4,32(sp)
    80002336:	ec56                	sd	s5,24(sp)
    80002338:	e85a                	sd	s6,16(sp)
    8000233a:	e45e                	sd	s7,8(sp)
    8000233c:	e062                	sd	s8,0(sp)
    8000233e:	0880                	addi	s0,sp,80
    80002340:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002342:	f7aff0ef          	jal	80001abc <myproc>
    80002346:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002348:	0000d517          	auipc	a0,0xd
    8000234c:	63850513          	addi	a0,a0,1592 # 8000f980 <wait_lock>
    80002350:	87ffe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002354:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002356:	4a15                	li	s4,5
        havekids = 1;
    80002358:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000235a:	00013997          	auipc	s3,0x13
    8000235e:	43e98993          	addi	s3,s3,1086 # 80015798 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002362:	0000dc17          	auipc	s8,0xd
    80002366:	61ec0c13          	addi	s8,s8,1566 # 8000f980 <wait_lock>
    8000236a:	a871                	j	80002406 <kwait+0xde>
          pid = pp->pid;
    8000236c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002370:	000b0c63          	beqz	s6,80002388 <kwait+0x60>
    80002374:	4691                	li	a3,4
    80002376:	02c48613          	addi	a2,s1,44
    8000237a:	85da                	mv	a1,s6
    8000237c:	05093503          	ld	a0,80(s2)
    80002380:	a62ff0ef          	jal	800015e2 <copyout>
    80002384:	02054b63          	bltz	a0,800023ba <kwait+0x92>
          freeproc(pp);
    80002388:	8526                	mv	a0,s1
    8000238a:	903ff0ef          	jal	80001c8c <freeproc>
          release(&pp->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	8d7fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002394:	0000d517          	auipc	a0,0xd
    80002398:	5ec50513          	addi	a0,a0,1516 # 8000f980 <wait_lock>
    8000239c:	8cbfe0ef          	jal	80000c66 <release>
}
    800023a0:	854e                	mv	a0,s3
    800023a2:	60a6                	ld	ra,72(sp)
    800023a4:	6406                	ld	s0,64(sp)
    800023a6:	74e2                	ld	s1,56(sp)
    800023a8:	7942                	ld	s2,48(sp)
    800023aa:	79a2                	ld	s3,40(sp)
    800023ac:	7a02                	ld	s4,32(sp)
    800023ae:	6ae2                	ld	s5,24(sp)
    800023b0:	6b42                	ld	s6,16(sp)
    800023b2:	6ba2                	ld	s7,8(sp)
    800023b4:	6c02                	ld	s8,0(sp)
    800023b6:	6161                	addi	sp,sp,80
    800023b8:	8082                	ret
            release(&pp->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	8abfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800023c0:	0000d517          	auipc	a0,0xd
    800023c4:	5c050513          	addi	a0,a0,1472 # 8000f980 <wait_lock>
    800023c8:	89ffe0ef          	jal	80000c66 <release>
            return -1;
    800023cc:	59fd                	li	s3,-1
    800023ce:	bfc9                	j	800023a0 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d0:	16848493          	addi	s1,s1,360
    800023d4:	03348063          	beq	s1,s3,800023f4 <kwait+0xcc>
      if(pp->parent == p){
    800023d8:	7c9c                	ld	a5,56(s1)
    800023da:	ff279be3          	bne	a5,s2,800023d0 <kwait+0xa8>
        acquire(&pp->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	feefe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800023e4:	4c9c                	lw	a5,24(s1)
    800023e6:	f94783e3          	beq	a5,s4,8000236c <kwait+0x44>
        release(&pp->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	87bfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800023f0:	8756                	mv	a4,s5
    800023f2:	bff9                	j	800023d0 <kwait+0xa8>
    if(!havekids || killed(p)){
    800023f4:	cf19                	beqz	a4,80002412 <kwait+0xea>
    800023f6:	854a                	mv	a0,s2
    800023f8:	f07ff0ef          	jal	800022fe <killed>
    800023fc:	e919                	bnez	a0,80002412 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023fe:	85e2                	mv	a1,s8
    80002400:	854a                	mv	a0,s2
    80002402:	cc5ff0ef          	jal	800020c6 <sleep>
    havekids = 0;
    80002406:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002408:	0000e497          	auipc	s1,0xe
    8000240c:	99048493          	addi	s1,s1,-1648 # 8000fd98 <proc>
    80002410:	b7e1                	j	800023d8 <kwait+0xb0>
      release(&wait_lock);
    80002412:	0000d517          	auipc	a0,0xd
    80002416:	56e50513          	addi	a0,a0,1390 # 8000f980 <wait_lock>
    8000241a:	84dfe0ef          	jal	80000c66 <release>
      return -1;
    8000241e:	59fd                	li	s3,-1
    80002420:	b741                	j	800023a0 <kwait+0x78>

0000000080002422 <either_copyout>:
{
    80002422:	7179                	addi	sp,sp,-48
    80002424:	f406                	sd	ra,40(sp)
    80002426:	f022                	sd	s0,32(sp)
    80002428:	ec26                	sd	s1,24(sp)
    8000242a:	e84a                	sd	s2,16(sp)
    8000242c:	e44e                	sd	s3,8(sp)
    8000242e:	e052                	sd	s4,0(sp)
    80002430:	1800                	addi	s0,sp,48
    80002432:	84aa                	mv	s1,a0
    80002434:	892e                	mv	s2,a1
    80002436:	89b2                	mv	s3,a2
    80002438:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000243a:	e82ff0ef          	jal	80001abc <myproc>
  if(user_dst){
    8000243e:	cc99                	beqz	s1,8000245c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002440:	86d2                	mv	a3,s4
    80002442:	864e                	mv	a2,s3
    80002444:	85ca                	mv	a1,s2
    80002446:	6928                	ld	a0,80(a0)
    80002448:	99aff0ef          	jal	800015e2 <copyout>
}
    8000244c:	70a2                	ld	ra,40(sp)
    8000244e:	7402                	ld	s0,32(sp)
    80002450:	64e2                	ld	s1,24(sp)
    80002452:	6942                	ld	s2,16(sp)
    80002454:	69a2                	ld	s3,8(sp)
    80002456:	6a02                	ld	s4,0(sp)
    80002458:	6145                	addi	sp,sp,48
    8000245a:	8082                	ret
    memmove((char *)dst, src, len);
    8000245c:	000a061b          	sext.w	a2,s4
    80002460:	85ce                	mv	a1,s3
    80002462:	854a                	mv	a0,s2
    80002464:	89bfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002468:	8526                	mv	a0,s1
    8000246a:	b7cd                	j	8000244c <either_copyout+0x2a>

000000008000246c <either_copyin>:
{
    8000246c:	7179                	addi	sp,sp,-48
    8000246e:	f406                	sd	ra,40(sp)
    80002470:	f022                	sd	s0,32(sp)
    80002472:	ec26                	sd	s1,24(sp)
    80002474:	e84a                	sd	s2,16(sp)
    80002476:	e44e                	sd	s3,8(sp)
    80002478:	e052                	sd	s4,0(sp)
    8000247a:	1800                	addi	s0,sp,48
    8000247c:	892a                	mv	s2,a0
    8000247e:	84ae                	mv	s1,a1
    80002480:	89b2                	mv	s3,a2
    80002482:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002484:	e38ff0ef          	jal	80001abc <myproc>
  if(user_src){
    80002488:	cc99                	beqz	s1,800024a6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000248a:	86d2                	mv	a3,s4
    8000248c:	864e                	mv	a2,s3
    8000248e:	85ca                	mv	a1,s2
    80002490:	6928                	ld	a0,80(a0)
    80002492:	a34ff0ef          	jal	800016c6 <copyin>
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6a02                	ld	s4,0(sp)
    800024a2:	6145                	addi	sp,sp,48
    800024a4:	8082                	ret
    memmove(dst, (char*)src, len);
    800024a6:	000a061b          	sext.w	a2,s4
    800024aa:	85ce                	mv	a1,s3
    800024ac:	854a                	mv	a0,s2
    800024ae:	851fe0ef          	jal	80000cfe <memmove>
    return 0;
    800024b2:	8526                	mv	a0,s1
    800024b4:	b7cd                	j	80002496 <either_copyin+0x2a>

00000000800024b6 <procdump>:
{
    800024b6:	715d                	addi	sp,sp,-80
    800024b8:	e486                	sd	ra,72(sp)
    800024ba:	e0a2                	sd	s0,64(sp)
    800024bc:	fc26                	sd	s1,56(sp)
    800024be:	f84a                	sd	s2,48(sp)
    800024c0:	f44e                	sd	s3,40(sp)
    800024c2:	f052                	sd	s4,32(sp)
    800024c4:	ec56                	sd	s5,24(sp)
    800024c6:	e85a                	sd	s6,16(sp)
    800024c8:	e45e                	sd	s7,8(sp)
    800024ca:	0880                	addi	s0,sp,80
  printf("\n");
    800024cc:	00005517          	auipc	a0,0x5
    800024d0:	bac50513          	addi	a0,a0,-1108 # 80007078 <etext+0x78>
    800024d4:	826fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d8:	0000e497          	auipc	s1,0xe
    800024dc:	a1848493          	addi	s1,s1,-1512 # 8000fef0 <proc+0x158>
    800024e0:	00013917          	auipc	s2,0x13
    800024e4:	41090913          	addi	s2,s2,1040 # 800158f0 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e8:	4b15                	li	s6,5
      state = "???";
    800024ea:	00005997          	auipc	s3,0x5
    800024ee:	d1698993          	addi	s3,s3,-746 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800024f2:	00005a97          	auipc	s5,0x5
    800024f6:	d16a8a93          	addi	s5,s5,-746 # 80007208 <etext+0x208>
    printf("\n");
    800024fa:	00005a17          	auipc	s4,0x5
    800024fe:	b7ea0a13          	addi	s4,s4,-1154 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002502:	00005b97          	auipc	s7,0x5
    80002506:	226b8b93          	addi	s7,s7,550 # 80007728 <states.0>
    8000250a:	a829                	j	80002524 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000250c:	ed86a583          	lw	a1,-296(a3)
    80002510:	8556                	mv	a0,s5
    80002512:	fe9fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002516:	8552                	mv	a0,s4
    80002518:	fe3fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000251c:	16848493          	addi	s1,s1,360
    80002520:	03248263          	beq	s1,s2,80002544 <procdump+0x8e>
    if(p->state == UNUSED)
    80002524:	86a6                	mv	a3,s1
    80002526:	ec04a783          	lw	a5,-320(s1)
    8000252a:	dbed                	beqz	a5,8000251c <procdump+0x66>
      state = "???";
    8000252c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000252e:	fcfb6fe3          	bltu	s6,a5,8000250c <procdump+0x56>
    80002532:	02079713          	slli	a4,a5,0x20
    80002536:	01d75793          	srli	a5,a4,0x1d
    8000253a:	97de                	add	a5,a5,s7
    8000253c:	6390                	ld	a2,0(a5)
    8000253e:	f679                	bnez	a2,8000250c <procdump+0x56>
      state = "???";
    80002540:	864e                	mv	a2,s3
    80002542:	b7e9                	j	8000250c <procdump+0x56>
}
    80002544:	60a6                	ld	ra,72(sp)
    80002546:	6406                	ld	s0,64(sp)
    80002548:	74e2                	ld	s1,56(sp)
    8000254a:	7942                	ld	s2,48(sp)
    8000254c:	79a2                	ld	s3,40(sp)
    8000254e:	7a02                	ld	s4,32(sp)
    80002550:	6ae2                	ld	s5,24(sp)
    80002552:	6b42                	ld	s6,16(sp)
    80002554:	6ba2                	ld	s7,8(sp)
    80002556:	6161                	addi	sp,sp,80
    80002558:	8082                	ret

000000008000255a <ptree>:
{
    8000255a:	715d                	addi	sp,sp,-80
    8000255c:	e486                	sd	ra,72(sp)
    8000255e:	e0a2                	sd	s0,64(sp)
    80002560:	fc26                	sd	s1,56(sp)
    80002562:	f84a                	sd	s2,48(sp)
    80002564:	f44e                	sd	s3,40(sp)
    80002566:	f052                	sd	s4,32(sp)
    80002568:	ec56                	sd	s5,24(sp)
    8000256a:	0880                	addi	s0,sp,80
    8000256c:	892a                	mv	s2,a0
    8000256e:	8a2e                	mv	s4,a1
    80002570:	8ab2                	mv	s5,a2
  int written = 0;
    80002572:	fa042e23          	sw	zero,-68(s0)
  for (p = proc; p < &proc[NPROC]; p++) {
    80002576:	0000e497          	auipc	s1,0xe
    8000257a:	82248493          	addi	s1,s1,-2014 # 8000fd98 <proc>
    8000257e:	00013997          	auipc	s3,0x13
    80002582:	21a98993          	addi	s3,s3,538 # 80015798 <tickslock>
    acquire(&p->lock);
    80002586:	8526                	mv	a0,s1
    80002588:	e46fe0ef          	jal	80000bce <acquire>
    if (p->pid == rootpid) {
    8000258c:	589c                	lw	a5,48(s1)
    8000258e:	03278063          	beq	a5,s2,800025ae <ptree+0x54>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002592:	16848493          	addi	s1,s1,360
    80002596:	ff3498e3          	bne	s1,s3,80002586 <ptree+0x2c>
    release(&p->lock);
    8000259a:	00013517          	auipc	a0,0x13
    8000259e:	1fe50513          	addi	a0,a0,510 # 80015798 <tickslock>
    800025a2:	ec4fe0ef          	jal	80000c66 <release>
    return -1; // pid not found
    800025a6:	557d                	li	a0,-1
    800025a8:	a035                	j	800025d4 <ptree+0x7a>
    return -1;
    800025aa:	557d                	li	a0,-1
    800025ac:	a025                	j	800025d4 <ptree+0x7a>
  pagetable_t caller_pg = myproc()->pagetable;
    800025ae:	d0eff0ef          	jal	80001abc <myproc>
  int ret = ptree_walk(root, 0, caller_pg, dst, bufsize, &written);
    800025b2:	fbc40793          	addi	a5,s0,-68
    800025b6:	8756                	mv	a4,s5
    800025b8:	86d2                	mv	a3,s4
    800025ba:	6930                	ld	a2,80(a0)
    800025bc:	4581                	li	a1,0
    800025be:	8526                	mv	a0,s1
    800025c0:	994ff0ef          	jal	80001754 <ptree_walk>
    800025c4:	892a                	mv	s2,a0
  release(&p->lock);
    800025c6:	8526                	mv	a0,s1
    800025c8:	e9efe0ef          	jal	80000c66 <release>
  if (ret < 0)
    800025cc:	fc094fe3          	bltz	s2,800025aa <ptree+0x50>
  return written;
    800025d0:	fbc42503          	lw	a0,-68(s0)
}
    800025d4:	60a6                	ld	ra,72(sp)
    800025d6:	6406                	ld	s0,64(sp)
    800025d8:	74e2                	ld	s1,56(sp)
    800025da:	7942                	ld	s2,48(sp)
    800025dc:	79a2                	ld	s3,40(sp)
    800025de:	7a02                	ld	s4,32(sp)
    800025e0:	6ae2                	ld	s5,24(sp)
    800025e2:	6161                	addi	sp,sp,80
    800025e4:	8082                	ret

00000000800025e6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025e6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025ea:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025ee:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025f0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025f2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025f6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025fa:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025fe:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002602:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002606:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000260a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000260e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002612:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002616:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000261a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000261e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002622:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002624:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002626:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000262a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000262e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002632:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002636:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000263a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000263e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002642:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002646:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000264a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000264e:	8082                	ret

0000000080002650 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002650:	1141                	addi	sp,sp,-16
    80002652:	e406                	sd	ra,8(sp)
    80002654:	e022                	sd	s0,0(sp)
    80002656:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002658:	00005597          	auipc	a1,0x5
    8000265c:	bf058593          	addi	a1,a1,-1040 # 80007248 <etext+0x248>
    80002660:	00013517          	auipc	a0,0x13
    80002664:	13850513          	addi	a0,a0,312 # 80015798 <tickslock>
    80002668:	ce6fe0ef          	jal	80000b4e <initlock>
}
    8000266c:	60a2                	ld	ra,8(sp)
    8000266e:	6402                	ld	s0,0(sp)
    80002670:	0141                	addi	sp,sp,16
    80002672:	8082                	ret

0000000080002674 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002674:	1141                	addi	sp,sp,-16
    80002676:	e422                	sd	s0,8(sp)
    80002678:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000267a:	00003797          	auipc	a5,0x3
    8000267e:	fb678793          	addi	a5,a5,-74 # 80005630 <kernelvec>
    80002682:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002686:	6422                	ld	s0,8(sp)
    80002688:	0141                	addi	sp,sp,16
    8000268a:	8082                	ret

000000008000268c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000268c:	1141                	addi	sp,sp,-16
    8000268e:	e406                	sd	ra,8(sp)
    80002690:	e022                	sd	s0,0(sp)
    80002692:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002694:	c28ff0ef          	jal	80001abc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002698:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000269c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026a2:	04000737          	lui	a4,0x4000
    800026a6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026a8:	0732                	slli	a4,a4,0xc
    800026aa:	00004797          	auipc	a5,0x4
    800026ae:	95678793          	addi	a5,a5,-1706 # 80006000 <_trampoline>
    800026b2:	00004697          	auipc	a3,0x4
    800026b6:	94e68693          	addi	a3,a3,-1714 # 80006000 <_trampoline>
    800026ba:	8f95                	sub	a5,a5,a3
    800026bc:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026be:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026c2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026c4:	18002773          	csrr	a4,satp
    800026c8:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ca:	6d38                	ld	a4,88(a0)
    800026cc:	613c                	ld	a5,64(a0)
    800026ce:	6685                	lui	a3,0x1
    800026d0:	97b6                	add	a5,a5,a3
    800026d2:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026d4:	6d3c                	ld	a5,88(a0)
    800026d6:	00000717          	auipc	a4,0x0
    800026da:	0f870713          	addi	a4,a4,248 # 800027ce <usertrap>
    800026de:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026e0:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026e2:	8712                	mv	a4,tp
    800026e4:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e6:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026ea:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ee:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f2:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026f6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026f8:	6f9c                	ld	a5,24(a5)
    800026fa:	14179073          	csrw	sepc,a5
}
    800026fe:	60a2                	ld	ra,8(sp)
    80002700:	6402                	ld	s0,0(sp)
    80002702:	0141                	addi	sp,sp,16
    80002704:	8082                	ret

0000000080002706 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002706:	1101                	addi	sp,sp,-32
    80002708:	ec06                	sd	ra,24(sp)
    8000270a:	e822                	sd	s0,16(sp)
    8000270c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000270e:	b82ff0ef          	jal	80001a90 <cpuid>
    80002712:	cd11                	beqz	a0,8000272e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002714:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002718:	000f4737          	lui	a4,0xf4
    8000271c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002720:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002722:	14d79073          	csrw	stimecmp,a5
}
    80002726:	60e2                	ld	ra,24(sp)
    80002728:	6442                	ld	s0,16(sp)
    8000272a:	6105                	addi	sp,sp,32
    8000272c:	8082                	ret
    8000272e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002730:	00013497          	auipc	s1,0x13
    80002734:	06848493          	addi	s1,s1,104 # 80015798 <tickslock>
    80002738:	8526                	mv	a0,s1
    8000273a:	c94fe0ef          	jal	80000bce <acquire>
    ticks++;
    8000273e:	00005517          	auipc	a0,0x5
    80002742:	12a50513          	addi	a0,a0,298 # 80007868 <ticks>
    80002746:	411c                	lw	a5,0(a0)
    80002748:	2785                	addiw	a5,a5,1
    8000274a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000274c:	9c7ff0ef          	jal	80002112 <wakeup>
    release(&tickslock);
    80002750:	8526                	mv	a0,s1
    80002752:	d14fe0ef          	jal	80000c66 <release>
    80002756:	64a2                	ld	s1,8(sp)
    80002758:	bf75                	j	80002714 <clockintr+0xe>

000000008000275a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002762:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002766:	57fd                	li	a5,-1
    80002768:	17fe                	slli	a5,a5,0x3f
    8000276a:	07a5                	addi	a5,a5,9
    8000276c:	00f70c63          	beq	a4,a5,80002784 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002770:	57fd                	li	a5,-1
    80002772:	17fe                	slli	a5,a5,0x3f
    80002774:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002776:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002778:	04f70763          	beq	a4,a5,800027c6 <devintr+0x6c>
  }
}
    8000277c:	60e2                	ld	ra,24(sp)
    8000277e:	6442                	ld	s0,16(sp)
    80002780:	6105                	addi	sp,sp,32
    80002782:	8082                	ret
    80002784:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002786:	757020ef          	jal	800056dc <plic_claim>
    8000278a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000278c:	47a9                	li	a5,10
    8000278e:	00f50963          	beq	a0,a5,800027a0 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002792:	4785                	li	a5,1
    80002794:	00f50963          	beq	a0,a5,800027a6 <devintr+0x4c>
    return 1;
    80002798:	4505                	li	a0,1
    } else if(irq){
    8000279a:	e889                	bnez	s1,800027ac <devintr+0x52>
    8000279c:	64a2                	ld	s1,8(sp)
    8000279e:	bff9                	j	8000277c <devintr+0x22>
      uartintr();
    800027a0:	a10fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    800027a4:	a819                	j	800027ba <devintr+0x60>
      virtio_disk_intr();
    800027a6:	3fc030ef          	jal	80005ba2 <virtio_disk_intr>
    if(irq)
    800027aa:	a801                	j	800027ba <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800027ac:	85a6                	mv	a1,s1
    800027ae:	00005517          	auipc	a0,0x5
    800027b2:	aa250513          	addi	a0,a0,-1374 # 80007250 <etext+0x250>
    800027b6:	d45fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800027ba:	8526                	mv	a0,s1
    800027bc:	741020ef          	jal	800056fc <plic_complete>
    return 1;
    800027c0:	4505                	li	a0,1
    800027c2:	64a2                	ld	s1,8(sp)
    800027c4:	bf65                	j	8000277c <devintr+0x22>
    clockintr();
    800027c6:	f41ff0ef          	jal	80002706 <clockintr>
    return 2;
    800027ca:	4509                	li	a0,2
    800027cc:	bf45                	j	8000277c <devintr+0x22>

00000000800027ce <usertrap>:
{
    800027ce:	1101                	addi	sp,sp,-32
    800027d0:	ec06                	sd	ra,24(sp)
    800027d2:	e822                	sd	s0,16(sp)
    800027d4:	e426                	sd	s1,8(sp)
    800027d6:	e04a                	sd	s2,0(sp)
    800027d8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027da:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027de:	1007f793          	andi	a5,a5,256
    800027e2:	eba5                	bnez	a5,80002852 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e4:	00003797          	auipc	a5,0x3
    800027e8:	e4c78793          	addi	a5,a5,-436 # 80005630 <kernelvec>
    800027ec:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027f0:	accff0ef          	jal	80001abc <myproc>
    800027f4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027f6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027f8:	14102773          	csrr	a4,sepc
    800027fc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027fe:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002802:	47a1                	li	a5,8
    80002804:	04f70d63          	beq	a4,a5,8000285e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002808:	f53ff0ef          	jal	8000275a <devintr>
    8000280c:	892a                	mv	s2,a0
    8000280e:	e945                	bnez	a0,800028be <usertrap+0xf0>
    80002810:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002814:	47bd                	li	a5,15
    80002816:	08f70863          	beq	a4,a5,800028a6 <usertrap+0xd8>
    8000281a:	14202773          	csrr	a4,scause
    8000281e:	47b5                	li	a5,13
    80002820:	08f70363          	beq	a4,a5,800028a6 <usertrap+0xd8>
    80002824:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002828:	5890                	lw	a2,48(s1)
    8000282a:	00005517          	auipc	a0,0x5
    8000282e:	a6650513          	addi	a0,a0,-1434 # 80007290 <etext+0x290>
    80002832:	cc9fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002836:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000283a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	a8250513          	addi	a0,a0,-1406 # 800072c0 <etext+0x2c0>
    80002846:	cb5fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000284a:	8526                	mv	a0,s1
    8000284c:	a8fff0ef          	jal	800022da <setkilled>
    80002850:	a035                	j	8000287c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002852:	00005517          	auipc	a0,0x5
    80002856:	a1e50513          	addi	a0,a0,-1506 # 80007270 <etext+0x270>
    8000285a:	f87fd0ef          	jal	800007e0 <panic>
    if(killed(p))
    8000285e:	aa1ff0ef          	jal	800022fe <killed>
    80002862:	ed15                	bnez	a0,8000289e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002864:	6cb8                	ld	a4,88(s1)
    80002866:	6f1c                	ld	a5,24(a4)
    80002868:	0791                	addi	a5,a5,4
    8000286a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000286c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002870:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002874:	10079073          	csrw	sstatus,a5
    syscall();
    80002878:	246000ef          	jal	80002abe <syscall>
  if(killed(p))
    8000287c:	8526                	mv	a0,s1
    8000287e:	a81ff0ef          	jal	800022fe <killed>
    80002882:	e139                	bnez	a0,800028c8 <usertrap+0xfa>
  prepare_return();
    80002884:	e09ff0ef          	jal	8000268c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002888:	68a8                	ld	a0,80(s1)
    8000288a:	8131                	srli	a0,a0,0xc
    8000288c:	57fd                	li	a5,-1
    8000288e:	17fe                	slli	a5,a5,0x3f
    80002890:	8d5d                	or	a0,a0,a5
}
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6902                	ld	s2,0(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret
      kexit(-1);
    8000289e:	557d                	li	a0,-1
    800028a0:	933ff0ef          	jal	800021d2 <kexit>
    800028a4:	b7c1                	j	80002864 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028a6:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028aa:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800028ae:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800028b0:	00163613          	seqz	a2,a2
    800028b4:	68a8                	ld	a0,80(s1)
    800028b6:	cabfe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800028ba:	f169                	bnez	a0,8000287c <usertrap+0xae>
    800028bc:	b7a5                	j	80002824 <usertrap+0x56>
  if(killed(p))
    800028be:	8526                	mv	a0,s1
    800028c0:	a3fff0ef          	jal	800022fe <killed>
    800028c4:	c511                	beqz	a0,800028d0 <usertrap+0x102>
    800028c6:	a011                	j	800028ca <usertrap+0xfc>
    800028c8:	4901                	li	s2,0
    kexit(-1);
    800028ca:	557d                	li	a0,-1
    800028cc:	907ff0ef          	jal	800021d2 <kexit>
  if(which_dev == 2)
    800028d0:	4789                	li	a5,2
    800028d2:	faf919e3          	bne	s2,a5,80002884 <usertrap+0xb6>
    yield();
    800028d6:	fc4ff0ef          	jal	8000209a <yield>
    800028da:	b76d                	j	80002884 <usertrap+0xb6>

00000000800028dc <kerneltrap>:
{
    800028dc:	7179                	addi	sp,sp,-48
    800028de:	f406                	sd	ra,40(sp)
    800028e0:	f022                	sd	s0,32(sp)
    800028e2:	ec26                	sd	s1,24(sp)
    800028e4:	e84a                	sd	s2,16(sp)
    800028e6:	e44e                	sd	s3,8(sp)
    800028e8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028f6:	1004f793          	andi	a5,s1,256
    800028fa:	c795                	beqz	a5,80002926 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002900:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002902:	eb85                	bnez	a5,80002932 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002904:	e57ff0ef          	jal	8000275a <devintr>
    80002908:	c91d                	beqz	a0,8000293e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000290a:	4789                	li	a5,2
    8000290c:	04f50a63          	beq	a0,a5,80002960 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002910:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002914:	10049073          	csrw	sstatus,s1
}
    80002918:	70a2                	ld	ra,40(sp)
    8000291a:	7402                	ld	s0,32(sp)
    8000291c:	64e2                	ld	s1,24(sp)
    8000291e:	6942                	ld	s2,16(sp)
    80002920:	69a2                	ld	s3,8(sp)
    80002922:	6145                	addi	sp,sp,48
    80002924:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002926:	00005517          	auipc	a0,0x5
    8000292a:	9c250513          	addi	a0,a0,-1598 # 800072e8 <etext+0x2e8>
    8000292e:	eb3fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002932:	00005517          	auipc	a0,0x5
    80002936:	9de50513          	addi	a0,a0,-1570 # 80007310 <etext+0x310>
    8000293a:	ea7fd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000293e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002942:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002946:	85ce                	mv	a1,s3
    80002948:	00005517          	auipc	a0,0x5
    8000294c:	9e850513          	addi	a0,a0,-1560 # 80007330 <etext+0x330>
    80002950:	babfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002954:	00005517          	auipc	a0,0x5
    80002958:	a0450513          	addi	a0,a0,-1532 # 80007358 <etext+0x358>
    8000295c:	e85fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002960:	95cff0ef          	jal	80001abc <myproc>
    80002964:	d555                	beqz	a0,80002910 <kerneltrap+0x34>
    yield();
    80002966:	f34ff0ef          	jal	8000209a <yield>
    8000296a:	b75d                	j	80002910 <kerneltrap+0x34>

000000008000296c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	e426                	sd	s1,8(sp)
    80002974:	1000                	addi	s0,sp,32
    80002976:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002978:	944ff0ef          	jal	80001abc <myproc>
  switch (n) {
    8000297c:	4795                	li	a5,5
    8000297e:	0497e163          	bltu	a5,s1,800029c0 <argraw+0x54>
    80002982:	048a                	slli	s1,s1,0x2
    80002984:	00005717          	auipc	a4,0x5
    80002988:	dd470713          	addi	a4,a4,-556 # 80007758 <states.0+0x30>
    8000298c:	94ba                	add	s1,s1,a4
    8000298e:	409c                	lw	a5,0(s1)
    80002990:	97ba                	add	a5,a5,a4
    80002992:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002994:	6d3c                	ld	a5,88(a0)
    80002996:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002998:	60e2                	ld	ra,24(sp)
    8000299a:	6442                	ld	s0,16(sp)
    8000299c:	64a2                	ld	s1,8(sp)
    8000299e:	6105                	addi	sp,sp,32
    800029a0:	8082                	ret
    return p->trapframe->a1;
    800029a2:	6d3c                	ld	a5,88(a0)
    800029a4:	7fa8                	ld	a0,120(a5)
    800029a6:	bfcd                	j	80002998 <argraw+0x2c>
    return p->trapframe->a2;
    800029a8:	6d3c                	ld	a5,88(a0)
    800029aa:	63c8                	ld	a0,128(a5)
    800029ac:	b7f5                	j	80002998 <argraw+0x2c>
    return p->trapframe->a3;
    800029ae:	6d3c                	ld	a5,88(a0)
    800029b0:	67c8                	ld	a0,136(a5)
    800029b2:	b7dd                	j	80002998 <argraw+0x2c>
    return p->trapframe->a4;
    800029b4:	6d3c                	ld	a5,88(a0)
    800029b6:	6bc8                	ld	a0,144(a5)
    800029b8:	b7c5                	j	80002998 <argraw+0x2c>
    return p->trapframe->a5;
    800029ba:	6d3c                	ld	a5,88(a0)
    800029bc:	6fc8                	ld	a0,152(a5)
    800029be:	bfe9                	j	80002998 <argraw+0x2c>
  panic("argraw");
    800029c0:	00005517          	auipc	a0,0x5
    800029c4:	9a850513          	addi	a0,a0,-1624 # 80007368 <etext+0x368>
    800029c8:	e19fd0ef          	jal	800007e0 <panic>

00000000800029cc <fetchaddr>:
{
    800029cc:	1101                	addi	sp,sp,-32
    800029ce:	ec06                	sd	ra,24(sp)
    800029d0:	e822                	sd	s0,16(sp)
    800029d2:	e426                	sd	s1,8(sp)
    800029d4:	e04a                	sd	s2,0(sp)
    800029d6:	1000                	addi	s0,sp,32
    800029d8:	84aa                	mv	s1,a0
    800029da:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029dc:	8e0ff0ef          	jal	80001abc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029e0:	653c                	ld	a5,72(a0)
    800029e2:	02f4f663          	bgeu	s1,a5,80002a0e <fetchaddr+0x42>
    800029e6:	00848713          	addi	a4,s1,8
    800029ea:	02e7e463          	bltu	a5,a4,80002a12 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029ee:	46a1                	li	a3,8
    800029f0:	8626                	mv	a2,s1
    800029f2:	85ca                	mv	a1,s2
    800029f4:	6928                	ld	a0,80(a0)
    800029f6:	cd1fe0ef          	jal	800016c6 <copyin>
    800029fa:	00a03533          	snez	a0,a0
    800029fe:	40a00533          	neg	a0,a0
}
    80002a02:	60e2                	ld	ra,24(sp)
    80002a04:	6442                	ld	s0,16(sp)
    80002a06:	64a2                	ld	s1,8(sp)
    80002a08:	6902                	ld	s2,0(sp)
    80002a0a:	6105                	addi	sp,sp,32
    80002a0c:	8082                	ret
    return -1;
    80002a0e:	557d                	li	a0,-1
    80002a10:	bfcd                	j	80002a02 <fetchaddr+0x36>
    80002a12:	557d                	li	a0,-1
    80002a14:	b7fd                	j	80002a02 <fetchaddr+0x36>

0000000080002a16 <fetchstr>:
{
    80002a16:	7179                	addi	sp,sp,-48
    80002a18:	f406                	sd	ra,40(sp)
    80002a1a:	f022                	sd	s0,32(sp)
    80002a1c:	ec26                	sd	s1,24(sp)
    80002a1e:	e84a                	sd	s2,16(sp)
    80002a20:	e44e                	sd	s3,8(sp)
    80002a22:	1800                	addi	s0,sp,48
    80002a24:	892a                	mv	s2,a0
    80002a26:	84ae                	mv	s1,a1
    80002a28:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a2a:	892ff0ef          	jal	80001abc <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a2e:	86ce                	mv	a3,s3
    80002a30:	864a                	mv	a2,s2
    80002a32:	85a6                	mv	a1,s1
    80002a34:	6928                	ld	a0,80(a0)
    80002a36:	a53fe0ef          	jal	80001488 <copyinstr>
    80002a3a:	00054c63          	bltz	a0,80002a52 <fetchstr+0x3c>
  return strlen(buf);
    80002a3e:	8526                	mv	a0,s1
    80002a40:	bd2fe0ef          	jal	80000e12 <strlen>
}
    80002a44:	70a2                	ld	ra,40(sp)
    80002a46:	7402                	ld	s0,32(sp)
    80002a48:	64e2                	ld	s1,24(sp)
    80002a4a:	6942                	ld	s2,16(sp)
    80002a4c:	69a2                	ld	s3,8(sp)
    80002a4e:	6145                	addi	sp,sp,48
    80002a50:	8082                	ret
    return -1;
    80002a52:	557d                	li	a0,-1
    80002a54:	bfc5                	j	80002a44 <fetchstr+0x2e>

0000000080002a56 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a56:	1101                	addi	sp,sp,-32
    80002a58:	ec06                	sd	ra,24(sp)
    80002a5a:	e822                	sd	s0,16(sp)
    80002a5c:	e426                	sd	s1,8(sp)
    80002a5e:	1000                	addi	s0,sp,32
    80002a60:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a62:	f0bff0ef          	jal	8000296c <argraw>
    80002a66:	c088                	sw	a0,0(s1)
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6105                	addi	sp,sp,32
    80002a70:	8082                	ret

0000000080002a72 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	e426                	sd	s1,8(sp)
    80002a7a:	1000                	addi	s0,sp,32
    80002a7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a7e:	eefff0ef          	jal	8000296c <argraw>
    80002a82:	e088                	sd	a0,0(s1)
}
    80002a84:	60e2                	ld	ra,24(sp)
    80002a86:	6442                	ld	s0,16(sp)
    80002a88:	64a2                	ld	s1,8(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret

0000000080002a8e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a8e:	7179                	addi	sp,sp,-48
    80002a90:	f406                	sd	ra,40(sp)
    80002a92:	f022                	sd	s0,32(sp)
    80002a94:	ec26                	sd	s1,24(sp)
    80002a96:	e84a                	sd	s2,16(sp)
    80002a98:	1800                	addi	s0,sp,48
    80002a9a:	84ae                	mv	s1,a1
    80002a9c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a9e:	fd840593          	addi	a1,s0,-40
    80002aa2:	fd1ff0ef          	jal	80002a72 <argaddr>
  return fetchstr(addr, buf, max);
    80002aa6:	864a                	mv	a2,s2
    80002aa8:	85a6                	mv	a1,s1
    80002aaa:	fd843503          	ld	a0,-40(s0)
    80002aae:	f69ff0ef          	jal	80002a16 <fetchstr>
}
    80002ab2:	70a2                	ld	ra,40(sp)
    80002ab4:	7402                	ld	s0,32(sp)
    80002ab6:	64e2                	ld	s1,24(sp)
    80002ab8:	6942                	ld	s2,16(sp)
    80002aba:	6145                	addi	sp,sp,48
    80002abc:	8082                	ret

0000000080002abe <syscall>:

uint sysclcnt = 0;

void
syscall(void)
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	e04a                	sd	s2,0(sp)
    80002ac8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002aca:	ff3fe0ef          	jal	80001abc <myproc>
    80002ace:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ad0:	05853903          	ld	s2,88(a0)
    80002ad4:	0a893783          	ld	a5,168(s2)
    80002ad8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002adc:	37fd                	addiw	a5,a5,-1
    80002ade:	4759                	li	a4,22
    80002ae0:	02f76663          	bltu	a4,a5,80002b0c <syscall+0x4e>
    80002ae4:	00369713          	slli	a4,a3,0x3
    80002ae8:	00005797          	auipc	a5,0x5
    80002aec:	c8878793          	addi	a5,a5,-888 # 80007770 <syscalls>
    80002af0:	97ba                	add	a5,a5,a4
    80002af2:	6398                	ld	a4,0(a5)
    80002af4:	cf01                	beqz	a4,80002b0c <syscall+0x4e>
    sysclcnt++;
    80002af6:	00005697          	auipc	a3,0x5
    80002afa:	d7668693          	addi	a3,a3,-650 # 8000786c <sysclcnt>
    80002afe:	429c                	lw	a5,0(a3)
    80002b00:	2785                	addiw	a5,a5,1
    80002b02:	c29c                	sw	a5,0(a3)
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b04:	9702                	jalr	a4
    80002b06:	06a93823          	sd	a0,112(s2)
    80002b0a:	a829                	j	80002b24 <syscall+0x66>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b0c:	15848613          	addi	a2,s1,344
    80002b10:	588c                	lw	a1,48(s1)
    80002b12:	00005517          	auipc	a0,0x5
    80002b16:	85e50513          	addi	a0,a0,-1954 # 80007370 <etext+0x370>
    80002b1a:	9e1fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b1e:	6cbc                	ld	a5,88(s1)
    80002b20:	577d                	li	a4,-1
    80002b22:	fbb8                	sd	a4,112(a5)
  }
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	64a2                	ld	s1,8(sp)
    80002b2a:	6902                	ld	s2,0(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret

0000000080002b30 <sys_exit>:
extern int ptree(int pid, uint64 dst, int bufsize);


uint64
sys_exit(void)
{
    80002b30:	1101                	addi	sp,sp,-32
    80002b32:	ec06                	sd	ra,24(sp)
    80002b34:	e822                	sd	s0,16(sp)
    80002b36:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b38:	fec40593          	addi	a1,s0,-20
    80002b3c:	4501                	li	a0,0
    80002b3e:	f19ff0ef          	jal	80002a56 <argint>
  kexit(n);
    80002b42:	fec42503          	lw	a0,-20(s0)
    80002b46:	e8cff0ef          	jal	800021d2 <kexit>
  return 0;  // not reached
}
    80002b4a:	4501                	li	a0,0
    80002b4c:	60e2                	ld	ra,24(sp)
    80002b4e:	6442                	ld	s0,16(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret

0000000080002b54 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b54:	1141                	addi	sp,sp,-16
    80002b56:	e406                	sd	ra,8(sp)
    80002b58:	e022                	sd	s0,0(sp)
    80002b5a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b5c:	f61fe0ef          	jal	80001abc <myproc>
}
    80002b60:	5908                	lw	a0,48(a0)
    80002b62:	60a2                	ld	ra,8(sp)
    80002b64:	6402                	ld	s0,0(sp)
    80002b66:	0141                	addi	sp,sp,16
    80002b68:	8082                	ret

0000000080002b6a <sys_fork>:

uint64
sys_fork(void)
{
    80002b6a:	1141                	addi	sp,sp,-16
    80002b6c:	e406                	sd	ra,8(sp)
    80002b6e:	e022                	sd	s0,0(sp)
    80002b70:	0800                	addi	s0,sp,16
  return kfork();
    80002b72:	aaeff0ef          	jal	80001e20 <kfork>
}
    80002b76:	60a2                	ld	ra,8(sp)
    80002b78:	6402                	ld	s0,0(sp)
    80002b7a:	0141                	addi	sp,sp,16
    80002b7c:	8082                	ret

0000000080002b7e <sys_wait>:

uint64
sys_wait(void)
{
    80002b7e:	1101                	addi	sp,sp,-32
    80002b80:	ec06                	sd	ra,24(sp)
    80002b82:	e822                	sd	s0,16(sp)
    80002b84:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b86:	fe840593          	addi	a1,s0,-24
    80002b8a:	4501                	li	a0,0
    80002b8c:	ee7ff0ef          	jal	80002a72 <argaddr>
  return kwait(p);
    80002b90:	fe843503          	ld	a0,-24(s0)
    80002b94:	f94ff0ef          	jal	80002328 <kwait>
}
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	6105                	addi	sp,sp,32
    80002b9e:	8082                	ret

0000000080002ba0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002baa:	fd840593          	addi	a1,s0,-40
    80002bae:	4501                	li	a0,0
    80002bb0:	ea7ff0ef          	jal	80002a56 <argint>
  argint(1, &t);
    80002bb4:	fdc40593          	addi	a1,s0,-36
    80002bb8:	4505                	li	a0,1
    80002bba:	e9dff0ef          	jal	80002a56 <argint>
  addr = myproc()->sz;
    80002bbe:	efffe0ef          	jal	80001abc <myproc>
    80002bc2:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bc4:	fdc42703          	lw	a4,-36(s0)
    80002bc8:	4785                	li	a5,1
    80002bca:	02f70763          	beq	a4,a5,80002bf8 <sys_sbrk+0x58>
    80002bce:	fd842783          	lw	a5,-40(s0)
    80002bd2:	0207c363          	bltz	a5,80002bf8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bd6:	97a6                	add	a5,a5,s1
    80002bd8:	0297ee63          	bltu	a5,s1,80002c14 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002bdc:	02000737          	lui	a4,0x2000
    80002be0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002be2:	0736                	slli	a4,a4,0xd
    80002be4:	02f76a63          	bltu	a4,a5,80002c18 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002be8:	ed5fe0ef          	jal	80001abc <myproc>
    80002bec:	fd842703          	lw	a4,-40(s0)
    80002bf0:	653c                	ld	a5,72(a0)
    80002bf2:	97ba                	add	a5,a5,a4
    80002bf4:	e53c                	sd	a5,72(a0)
    80002bf6:	a039                	j	80002c04 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002bf8:	fd842503          	lw	a0,-40(s0)
    80002bfc:	9c2ff0ef          	jal	80001dbe <growproc>
    80002c00:	00054863          	bltz	a0,80002c10 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c04:	8526                	mv	a0,s1
    80002c06:	70a2                	ld	ra,40(sp)
    80002c08:	7402                	ld	s0,32(sp)
    80002c0a:	64e2                	ld	s1,24(sp)
    80002c0c:	6145                	addi	sp,sp,48
    80002c0e:	8082                	ret
      return -1;
    80002c10:	54fd                	li	s1,-1
    80002c12:	bfcd                	j	80002c04 <sys_sbrk+0x64>
      return -1;
    80002c14:	54fd                	li	s1,-1
    80002c16:	b7fd                	j	80002c04 <sys_sbrk+0x64>
      return -1;
    80002c18:	54fd                	li	s1,-1
    80002c1a:	b7ed                	j	80002c04 <sys_sbrk+0x64>

0000000080002c1c <sys_pause>:

uint64
sys_pause(void)
{
    80002c1c:	7139                	addi	sp,sp,-64
    80002c1e:	fc06                	sd	ra,56(sp)
    80002c20:	f822                	sd	s0,48(sp)
    80002c22:	f04a                	sd	s2,32(sp)
    80002c24:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c26:	fcc40593          	addi	a1,s0,-52
    80002c2a:	4501                	li	a0,0
    80002c2c:	e2bff0ef          	jal	80002a56 <argint>
  if(n < 0)
    80002c30:	fcc42783          	lw	a5,-52(s0)
    80002c34:	0607c763          	bltz	a5,80002ca2 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c38:	00013517          	auipc	a0,0x13
    80002c3c:	b6050513          	addi	a0,a0,-1184 # 80015798 <tickslock>
    80002c40:	f8ffd0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    80002c44:	00005917          	auipc	s2,0x5
    80002c48:	c2492903          	lw	s2,-988(s2) # 80007868 <ticks>
  while(ticks - ticks0 < n){
    80002c4c:	fcc42783          	lw	a5,-52(s0)
    80002c50:	cf8d                	beqz	a5,80002c8a <sys_pause+0x6e>
    80002c52:	f426                	sd	s1,40(sp)
    80002c54:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c56:	00013997          	auipc	s3,0x13
    80002c5a:	b4298993          	addi	s3,s3,-1214 # 80015798 <tickslock>
    80002c5e:	00005497          	auipc	s1,0x5
    80002c62:	c0a48493          	addi	s1,s1,-1014 # 80007868 <ticks>
    if(killed(myproc())){
    80002c66:	e57fe0ef          	jal	80001abc <myproc>
    80002c6a:	e94ff0ef          	jal	800022fe <killed>
    80002c6e:	ed0d                	bnez	a0,80002ca8 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c70:	85ce                	mv	a1,s3
    80002c72:	8526                	mv	a0,s1
    80002c74:	c52ff0ef          	jal	800020c6 <sleep>
  while(ticks - ticks0 < n){
    80002c78:	409c                	lw	a5,0(s1)
    80002c7a:	412787bb          	subw	a5,a5,s2
    80002c7e:	fcc42703          	lw	a4,-52(s0)
    80002c82:	fee7e2e3          	bltu	a5,a4,80002c66 <sys_pause+0x4a>
    80002c86:	74a2                	ld	s1,40(sp)
    80002c88:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c8a:	00013517          	auipc	a0,0x13
    80002c8e:	b0e50513          	addi	a0,a0,-1266 # 80015798 <tickslock>
    80002c92:	fd5fd0ef          	jal	80000c66 <release>
  return 0;
    80002c96:	4501                	li	a0,0
}
    80002c98:	70e2                	ld	ra,56(sp)
    80002c9a:	7442                	ld	s0,48(sp)
    80002c9c:	7902                	ld	s2,32(sp)
    80002c9e:	6121                	addi	sp,sp,64
    80002ca0:	8082                	ret
    n = 0;
    80002ca2:	fc042623          	sw	zero,-52(s0)
    80002ca6:	bf49                	j	80002c38 <sys_pause+0x1c>
      release(&tickslock);
    80002ca8:	00013517          	auipc	a0,0x13
    80002cac:	af050513          	addi	a0,a0,-1296 # 80015798 <tickslock>
    80002cb0:	fb7fd0ef          	jal	80000c66 <release>
      return -1;
    80002cb4:	557d                	li	a0,-1
    80002cb6:	74a2                	ld	s1,40(sp)
    80002cb8:	69e2                	ld	s3,24(sp)
    80002cba:	bff9                	j	80002c98 <sys_pause+0x7c>

0000000080002cbc <sys_kill>:

uint64
sys_kill(void)
{
    80002cbc:	1101                	addi	sp,sp,-32
    80002cbe:	ec06                	sd	ra,24(sp)
    80002cc0:	e822                	sd	s0,16(sp)
    80002cc2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cc4:	fec40593          	addi	a1,s0,-20
    80002cc8:	4501                	li	a0,0
    80002cca:	d8dff0ef          	jal	80002a56 <argint>
  return kkill(pid);
    80002cce:	fec42503          	lw	a0,-20(s0)
    80002cd2:	da2ff0ef          	jal	80002274 <kkill>
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret

0000000080002cde <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cde:	1101                	addi	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	e426                	sd	s1,8(sp)
    80002ce6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ce8:	00013517          	auipc	a0,0x13
    80002cec:	ab050513          	addi	a0,a0,-1360 # 80015798 <tickslock>
    80002cf0:	edffd0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002cf4:	00005497          	auipc	s1,0x5
    80002cf8:	b744a483          	lw	s1,-1164(s1) # 80007868 <ticks>
  release(&tickslock);
    80002cfc:	00013517          	auipc	a0,0x13
    80002d00:	a9c50513          	addi	a0,a0,-1380 # 80015798 <tickslock>
    80002d04:	f63fd0ef          	jal	80000c66 <release>
  return xticks;
}
    80002d08:	02049513          	slli	a0,s1,0x20
    80002d0c:	9101                	srli	a0,a0,0x20
    80002d0e:	60e2                	ld	ra,24(sp)
    80002d10:	6442                	ld	s0,16(sp)
    80002d12:	64a2                	ld	s1,8(sp)
    80002d14:	6105                	addi	sp,sp,32
    80002d16:	8082                	ret

0000000080002d18 <sys_clcnt>:

uint64
sys_clcnt(void)
{
    80002d18:	1141                	addi	sp,sp,-16
    80002d1a:	e422                	sd	s0,8(sp)
    80002d1c:	0800                	addi	s0,sp,16
  extern uint sysclcnt;
  return sysclcnt;
}
    80002d1e:	00005517          	auipc	a0,0x5
    80002d22:	b4e56503          	lwu	a0,-1202(a0) # 8000786c <sysclcnt>
    80002d26:	6422                	ld	s0,8(sp)
    80002d28:	0141                	addi	sp,sp,16
    80002d2a:	8082                	ret

0000000080002d2c <sys_ptree>:

uint64
sys_ptree(void)
{
    80002d2c:	7179                	addi	sp,sp,-48
    80002d2e:	f406                	sd	ra,40(sp)
    80002d30:	f022                	sd	s0,32(sp)
    80002d32:	1800                	addi	s0,sp,48
  int pid;
  uint64 user_dst;
  int bufsize;

  argint(0, &pid);
    80002d34:	fec40593          	addi	a1,s0,-20
    80002d38:	4501                	li	a0,0
    80002d3a:	d1dff0ef          	jal	80002a56 <argint>
  argaddr(1, &user_dst);
    80002d3e:	fe040593          	addi	a1,s0,-32
    80002d42:	4505                	li	a0,1
    80002d44:	d2fff0ef          	jal	80002a72 <argaddr>
  argint(2, &bufsize);
    80002d48:	fdc40593          	addi	a1,s0,-36
    80002d4c:	4509                	li	a0,2
    80002d4e:	d09ff0ef          	jal	80002a56 <argint>

  return ptree(pid, user_dst, bufsize);
    80002d52:	fdc42603          	lw	a2,-36(s0)
    80002d56:	fe043583          	ld	a1,-32(s0)
    80002d5a:	fec42503          	lw	a0,-20(s0)
    80002d5e:	ffcff0ef          	jal	8000255a <ptree>
    80002d62:	70a2                	ld	ra,40(sp)
    80002d64:	7402                	ld	s0,32(sp)
    80002d66:	6145                	addi	sp,sp,48
    80002d68:	8082                	ret

0000000080002d6a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d6a:	7179                	addi	sp,sp,-48
    80002d6c:	f406                	sd	ra,40(sp)
    80002d6e:	f022                	sd	s0,32(sp)
    80002d70:	ec26                	sd	s1,24(sp)
    80002d72:	e84a                	sd	s2,16(sp)
    80002d74:	e44e                	sd	s3,8(sp)
    80002d76:	e052                	sd	s4,0(sp)
    80002d78:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d7a:	00004597          	auipc	a1,0x4
    80002d7e:	61658593          	addi	a1,a1,1558 # 80007390 <etext+0x390>
    80002d82:	00013517          	auipc	a0,0x13
    80002d86:	a2e50513          	addi	a0,a0,-1490 # 800157b0 <bcache>
    80002d8a:	dc5fd0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d8e:	0001b797          	auipc	a5,0x1b
    80002d92:	a2278793          	addi	a5,a5,-1502 # 8001d7b0 <bcache+0x8000>
    80002d96:	0001b717          	auipc	a4,0x1b
    80002d9a:	c8270713          	addi	a4,a4,-894 # 8001da18 <bcache+0x8268>
    80002d9e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002da2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002da6:	00013497          	auipc	s1,0x13
    80002daa:	a2248493          	addi	s1,s1,-1502 # 800157c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002dae:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002db0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002db2:	00004a17          	auipc	s4,0x4
    80002db6:	5e6a0a13          	addi	s4,s4,1510 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002dba:	2b893783          	ld	a5,696(s2)
    80002dbe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dc0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dc4:	85d2                	mv	a1,s4
    80002dc6:	01048513          	addi	a0,s1,16
    80002dca:	322010ef          	jal	800040ec <initsleeplock>
    bcache.head.next->prev = b;
    80002dce:	2b893783          	ld	a5,696(s2)
    80002dd2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dd4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dd8:	45848493          	addi	s1,s1,1112
    80002ddc:	fd349fe3          	bne	s1,s3,80002dba <binit+0x50>
  }
}
    80002de0:	70a2                	ld	ra,40(sp)
    80002de2:	7402                	ld	s0,32(sp)
    80002de4:	64e2                	ld	s1,24(sp)
    80002de6:	6942                	ld	s2,16(sp)
    80002de8:	69a2                	ld	s3,8(sp)
    80002dea:	6a02                	ld	s4,0(sp)
    80002dec:	6145                	addi	sp,sp,48
    80002dee:	8082                	ret

0000000080002df0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002df0:	7179                	addi	sp,sp,-48
    80002df2:	f406                	sd	ra,40(sp)
    80002df4:	f022                	sd	s0,32(sp)
    80002df6:	ec26                	sd	s1,24(sp)
    80002df8:	e84a                	sd	s2,16(sp)
    80002dfa:	e44e                	sd	s3,8(sp)
    80002dfc:	1800                	addi	s0,sp,48
    80002dfe:	892a                	mv	s2,a0
    80002e00:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e02:	00013517          	auipc	a0,0x13
    80002e06:	9ae50513          	addi	a0,a0,-1618 # 800157b0 <bcache>
    80002e0a:	dc5fd0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e0e:	0001b497          	auipc	s1,0x1b
    80002e12:	c5a4b483          	ld	s1,-934(s1) # 8001da68 <bcache+0x82b8>
    80002e16:	0001b797          	auipc	a5,0x1b
    80002e1a:	c0278793          	addi	a5,a5,-1022 # 8001da18 <bcache+0x8268>
    80002e1e:	02f48b63          	beq	s1,a5,80002e54 <bread+0x64>
    80002e22:	873e                	mv	a4,a5
    80002e24:	a021                	j	80002e2c <bread+0x3c>
    80002e26:	68a4                	ld	s1,80(s1)
    80002e28:	02e48663          	beq	s1,a4,80002e54 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e2c:	449c                	lw	a5,8(s1)
    80002e2e:	ff279ce3          	bne	a5,s2,80002e26 <bread+0x36>
    80002e32:	44dc                	lw	a5,12(s1)
    80002e34:	ff3799e3          	bne	a5,s3,80002e26 <bread+0x36>
      b->refcnt++;
    80002e38:	40bc                	lw	a5,64(s1)
    80002e3a:	2785                	addiw	a5,a5,1
    80002e3c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e3e:	00013517          	auipc	a0,0x13
    80002e42:	97250513          	addi	a0,a0,-1678 # 800157b0 <bcache>
    80002e46:	e21fd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e4a:	01048513          	addi	a0,s1,16
    80002e4e:	2d4010ef          	jal	80004122 <acquiresleep>
      return b;
    80002e52:	a889                	j	80002ea4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e54:	0001b497          	auipc	s1,0x1b
    80002e58:	c0c4b483          	ld	s1,-1012(s1) # 8001da60 <bcache+0x82b0>
    80002e5c:	0001b797          	auipc	a5,0x1b
    80002e60:	bbc78793          	addi	a5,a5,-1092 # 8001da18 <bcache+0x8268>
    80002e64:	00f48863          	beq	s1,a5,80002e74 <bread+0x84>
    80002e68:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e6a:	40bc                	lw	a5,64(s1)
    80002e6c:	cb91                	beqz	a5,80002e80 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e6e:	64a4                	ld	s1,72(s1)
    80002e70:	fee49de3          	bne	s1,a4,80002e6a <bread+0x7a>
  panic("bget: no buffers");
    80002e74:	00004517          	auipc	a0,0x4
    80002e78:	52c50513          	addi	a0,a0,1324 # 800073a0 <etext+0x3a0>
    80002e7c:	965fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002e80:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e84:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e88:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e8c:	4785                	li	a5,1
    80002e8e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e90:	00013517          	auipc	a0,0x13
    80002e94:	92050513          	addi	a0,a0,-1760 # 800157b0 <bcache>
    80002e98:	dcffd0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002e9c:	01048513          	addi	a0,s1,16
    80002ea0:	282010ef          	jal	80004122 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ea4:	409c                	lw	a5,0(s1)
    80002ea6:	cb89                	beqz	a5,80002eb8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ea8:	8526                	mv	a0,s1
    80002eaa:	70a2                	ld	ra,40(sp)
    80002eac:	7402                	ld	s0,32(sp)
    80002eae:	64e2                	ld	s1,24(sp)
    80002eb0:	6942                	ld	s2,16(sp)
    80002eb2:	69a2                	ld	s3,8(sp)
    80002eb4:	6145                	addi	sp,sp,48
    80002eb6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002eb8:	4581                	li	a1,0
    80002eba:	8526                	mv	a0,s1
    80002ebc:	2d5020ef          	jal	80005990 <virtio_disk_rw>
    b->valid = 1;
    80002ec0:	4785                	li	a5,1
    80002ec2:	c09c                	sw	a5,0(s1)
  return b;
    80002ec4:	b7d5                	j	80002ea8 <bread+0xb8>

0000000080002ec6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ec6:	1101                	addi	sp,sp,-32
    80002ec8:	ec06                	sd	ra,24(sp)
    80002eca:	e822                	sd	s0,16(sp)
    80002ecc:	e426                	sd	s1,8(sp)
    80002ece:	1000                	addi	s0,sp,32
    80002ed0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ed2:	0541                	addi	a0,a0,16
    80002ed4:	2cc010ef          	jal	800041a0 <holdingsleep>
    80002ed8:	c911                	beqz	a0,80002eec <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002eda:	4585                	li	a1,1
    80002edc:	8526                	mv	a0,s1
    80002ede:	2b3020ef          	jal	80005990 <virtio_disk_rw>
}
    80002ee2:	60e2                	ld	ra,24(sp)
    80002ee4:	6442                	ld	s0,16(sp)
    80002ee6:	64a2                	ld	s1,8(sp)
    80002ee8:	6105                	addi	sp,sp,32
    80002eea:	8082                	ret
    panic("bwrite");
    80002eec:	00004517          	auipc	a0,0x4
    80002ef0:	4cc50513          	addi	a0,a0,1228 # 800073b8 <etext+0x3b8>
    80002ef4:	8edfd0ef          	jal	800007e0 <panic>

0000000080002ef8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ef8:	1101                	addi	sp,sp,-32
    80002efa:	ec06                	sd	ra,24(sp)
    80002efc:	e822                	sd	s0,16(sp)
    80002efe:	e426                	sd	s1,8(sp)
    80002f00:	e04a                	sd	s2,0(sp)
    80002f02:	1000                	addi	s0,sp,32
    80002f04:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f06:	01050913          	addi	s2,a0,16
    80002f0a:	854a                	mv	a0,s2
    80002f0c:	294010ef          	jal	800041a0 <holdingsleep>
    80002f10:	c135                	beqz	a0,80002f74 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f12:	854a                	mv	a0,s2
    80002f14:	254010ef          	jal	80004168 <releasesleep>

  acquire(&bcache.lock);
    80002f18:	00013517          	auipc	a0,0x13
    80002f1c:	89850513          	addi	a0,a0,-1896 # 800157b0 <bcache>
    80002f20:	caffd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002f24:	40bc                	lw	a5,64(s1)
    80002f26:	37fd                	addiw	a5,a5,-1
    80002f28:	0007871b          	sext.w	a4,a5
    80002f2c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f2e:	e71d                	bnez	a4,80002f5c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f30:	68b8                	ld	a4,80(s1)
    80002f32:	64bc                	ld	a5,72(s1)
    80002f34:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f36:	68b8                	ld	a4,80(s1)
    80002f38:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f3a:	0001b797          	auipc	a5,0x1b
    80002f3e:	87678793          	addi	a5,a5,-1930 # 8001d7b0 <bcache+0x8000>
    80002f42:	2b87b703          	ld	a4,696(a5)
    80002f46:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f48:	0001b717          	auipc	a4,0x1b
    80002f4c:	ad070713          	addi	a4,a4,-1328 # 8001da18 <bcache+0x8268>
    80002f50:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f52:	2b87b703          	ld	a4,696(a5)
    80002f56:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f58:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f5c:	00013517          	auipc	a0,0x13
    80002f60:	85450513          	addi	a0,a0,-1964 # 800157b0 <bcache>
    80002f64:	d03fd0ef          	jal	80000c66 <release>
}
    80002f68:	60e2                	ld	ra,24(sp)
    80002f6a:	6442                	ld	s0,16(sp)
    80002f6c:	64a2                	ld	s1,8(sp)
    80002f6e:	6902                	ld	s2,0(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret
    panic("brelse");
    80002f74:	00004517          	auipc	a0,0x4
    80002f78:	44c50513          	addi	a0,a0,1100 # 800073c0 <etext+0x3c0>
    80002f7c:	865fd0ef          	jal	800007e0 <panic>

0000000080002f80 <bpin>:

void
bpin(struct buf *b) {
    80002f80:	1101                	addi	sp,sp,-32
    80002f82:	ec06                	sd	ra,24(sp)
    80002f84:	e822                	sd	s0,16(sp)
    80002f86:	e426                	sd	s1,8(sp)
    80002f88:	1000                	addi	s0,sp,32
    80002f8a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f8c:	00013517          	auipc	a0,0x13
    80002f90:	82450513          	addi	a0,a0,-2012 # 800157b0 <bcache>
    80002f94:	c3bfd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002f98:	40bc                	lw	a5,64(s1)
    80002f9a:	2785                	addiw	a5,a5,1
    80002f9c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f9e:	00013517          	auipc	a0,0x13
    80002fa2:	81250513          	addi	a0,a0,-2030 # 800157b0 <bcache>
    80002fa6:	cc1fd0ef          	jal	80000c66 <release>
}
    80002faa:	60e2                	ld	ra,24(sp)
    80002fac:	6442                	ld	s0,16(sp)
    80002fae:	64a2                	ld	s1,8(sp)
    80002fb0:	6105                	addi	sp,sp,32
    80002fb2:	8082                	ret

0000000080002fb4 <bunpin>:

void
bunpin(struct buf *b) {
    80002fb4:	1101                	addi	sp,sp,-32
    80002fb6:	ec06                	sd	ra,24(sp)
    80002fb8:	e822                	sd	s0,16(sp)
    80002fba:	e426                	sd	s1,8(sp)
    80002fbc:	1000                	addi	s0,sp,32
    80002fbe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fc0:	00012517          	auipc	a0,0x12
    80002fc4:	7f050513          	addi	a0,a0,2032 # 800157b0 <bcache>
    80002fc8:	c07fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002fcc:	40bc                	lw	a5,64(s1)
    80002fce:	37fd                	addiw	a5,a5,-1
    80002fd0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fd2:	00012517          	auipc	a0,0x12
    80002fd6:	7de50513          	addi	a0,a0,2014 # 800157b0 <bcache>
    80002fda:	c8dfd0ef          	jal	80000c66 <release>
}
    80002fde:	60e2                	ld	ra,24(sp)
    80002fe0:	6442                	ld	s0,16(sp)
    80002fe2:	64a2                	ld	s1,8(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret

0000000080002fe8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	e04a                	sd	s2,0(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ff6:	00d5d59b          	srliw	a1,a1,0xd
    80002ffa:	0001b797          	auipc	a5,0x1b
    80002ffe:	e927a783          	lw	a5,-366(a5) # 8001de8c <sb+0x1c>
    80003002:	9dbd                	addw	a1,a1,a5
    80003004:	dedff0ef          	jal	80002df0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003008:	0074f713          	andi	a4,s1,7
    8000300c:	4785                	li	a5,1
    8000300e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003012:	14ce                	slli	s1,s1,0x33
    80003014:	90d9                	srli	s1,s1,0x36
    80003016:	00950733          	add	a4,a0,s1
    8000301a:	05874703          	lbu	a4,88(a4)
    8000301e:	00e7f6b3          	and	a3,a5,a4
    80003022:	c29d                	beqz	a3,80003048 <bfree+0x60>
    80003024:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003026:	94aa                	add	s1,s1,a0
    80003028:	fff7c793          	not	a5,a5
    8000302c:	8f7d                	and	a4,a4,a5
    8000302e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003032:	7f9000ef          	jal	8000402a <log_write>
  brelse(bp);
    80003036:	854a                	mv	a0,s2
    80003038:	ec1ff0ef          	jal	80002ef8 <brelse>
}
    8000303c:	60e2                	ld	ra,24(sp)
    8000303e:	6442                	ld	s0,16(sp)
    80003040:	64a2                	ld	s1,8(sp)
    80003042:	6902                	ld	s2,0(sp)
    80003044:	6105                	addi	sp,sp,32
    80003046:	8082                	ret
    panic("freeing free block");
    80003048:	00004517          	auipc	a0,0x4
    8000304c:	38050513          	addi	a0,a0,896 # 800073c8 <etext+0x3c8>
    80003050:	f90fd0ef          	jal	800007e0 <panic>

0000000080003054 <balloc>:
{
    80003054:	711d                	addi	sp,sp,-96
    80003056:	ec86                	sd	ra,88(sp)
    80003058:	e8a2                	sd	s0,80(sp)
    8000305a:	e4a6                	sd	s1,72(sp)
    8000305c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000305e:	0001b797          	auipc	a5,0x1b
    80003062:	e167a783          	lw	a5,-490(a5) # 8001de74 <sb+0x4>
    80003066:	0e078f63          	beqz	a5,80003164 <balloc+0x110>
    8000306a:	e0ca                	sd	s2,64(sp)
    8000306c:	fc4e                	sd	s3,56(sp)
    8000306e:	f852                	sd	s4,48(sp)
    80003070:	f456                	sd	s5,40(sp)
    80003072:	f05a                	sd	s6,32(sp)
    80003074:	ec5e                	sd	s7,24(sp)
    80003076:	e862                	sd	s8,16(sp)
    80003078:	e466                	sd	s9,8(sp)
    8000307a:	8baa                	mv	s7,a0
    8000307c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000307e:	0001bb17          	auipc	s6,0x1b
    80003082:	df2b0b13          	addi	s6,s6,-526 # 8001de70 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003086:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003088:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000308a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000308c:	6c89                	lui	s9,0x2
    8000308e:	a0b5                	j	800030fa <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003090:	97ca                	add	a5,a5,s2
    80003092:	8e55                	or	a2,a2,a3
    80003094:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003098:	854a                	mv	a0,s2
    8000309a:	791000ef          	jal	8000402a <log_write>
        brelse(bp);
    8000309e:	854a                	mv	a0,s2
    800030a0:	e59ff0ef          	jal	80002ef8 <brelse>
  bp = bread(dev, bno);
    800030a4:	85a6                	mv	a1,s1
    800030a6:	855e                	mv	a0,s7
    800030a8:	d49ff0ef          	jal	80002df0 <bread>
    800030ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800030ae:	40000613          	li	a2,1024
    800030b2:	4581                	li	a1,0
    800030b4:	05850513          	addi	a0,a0,88
    800030b8:	bebfd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    800030bc:	854a                	mv	a0,s2
    800030be:	76d000ef          	jal	8000402a <log_write>
  brelse(bp);
    800030c2:	854a                	mv	a0,s2
    800030c4:	e35ff0ef          	jal	80002ef8 <brelse>
}
    800030c8:	6906                	ld	s2,64(sp)
    800030ca:	79e2                	ld	s3,56(sp)
    800030cc:	7a42                	ld	s4,48(sp)
    800030ce:	7aa2                	ld	s5,40(sp)
    800030d0:	7b02                	ld	s6,32(sp)
    800030d2:	6be2                	ld	s7,24(sp)
    800030d4:	6c42                	ld	s8,16(sp)
    800030d6:	6ca2                	ld	s9,8(sp)
}
    800030d8:	8526                	mv	a0,s1
    800030da:	60e6                	ld	ra,88(sp)
    800030dc:	6446                	ld	s0,80(sp)
    800030de:	64a6                	ld	s1,72(sp)
    800030e0:	6125                	addi	sp,sp,96
    800030e2:	8082                	ret
    brelse(bp);
    800030e4:	854a                	mv	a0,s2
    800030e6:	e13ff0ef          	jal	80002ef8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030ea:	015c87bb          	addw	a5,s9,s5
    800030ee:	00078a9b          	sext.w	s5,a5
    800030f2:	004b2703          	lw	a4,4(s6)
    800030f6:	04eaff63          	bgeu	s5,a4,80003154 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800030fa:	41fad79b          	sraiw	a5,s5,0x1f
    800030fe:	0137d79b          	srliw	a5,a5,0x13
    80003102:	015787bb          	addw	a5,a5,s5
    80003106:	40d7d79b          	sraiw	a5,a5,0xd
    8000310a:	01cb2583          	lw	a1,28(s6)
    8000310e:	9dbd                	addw	a1,a1,a5
    80003110:	855e                	mv	a0,s7
    80003112:	cdfff0ef          	jal	80002df0 <bread>
    80003116:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003118:	004b2503          	lw	a0,4(s6)
    8000311c:	000a849b          	sext.w	s1,s5
    80003120:	8762                	mv	a4,s8
    80003122:	fca4f1e3          	bgeu	s1,a0,800030e4 <balloc+0x90>
      m = 1 << (bi % 8);
    80003126:	00777693          	andi	a3,a4,7
    8000312a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000312e:	41f7579b          	sraiw	a5,a4,0x1f
    80003132:	01d7d79b          	srliw	a5,a5,0x1d
    80003136:	9fb9                	addw	a5,a5,a4
    80003138:	4037d79b          	sraiw	a5,a5,0x3
    8000313c:	00f90633          	add	a2,s2,a5
    80003140:	05864603          	lbu	a2,88(a2)
    80003144:	00c6f5b3          	and	a1,a3,a2
    80003148:	d5a1                	beqz	a1,80003090 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000314a:	2705                	addiw	a4,a4,1
    8000314c:	2485                	addiw	s1,s1,1
    8000314e:	fd471ae3          	bne	a4,s4,80003122 <balloc+0xce>
    80003152:	bf49                	j	800030e4 <balloc+0x90>
    80003154:	6906                	ld	s2,64(sp)
    80003156:	79e2                	ld	s3,56(sp)
    80003158:	7a42                	ld	s4,48(sp)
    8000315a:	7aa2                	ld	s5,40(sp)
    8000315c:	7b02                	ld	s6,32(sp)
    8000315e:	6be2                	ld	s7,24(sp)
    80003160:	6c42                	ld	s8,16(sp)
    80003162:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003164:	00004517          	auipc	a0,0x4
    80003168:	27c50513          	addi	a0,a0,636 # 800073e0 <etext+0x3e0>
    8000316c:	b8efd0ef          	jal	800004fa <printf>
  return 0;
    80003170:	4481                	li	s1,0
    80003172:	b79d                	j	800030d8 <balloc+0x84>

0000000080003174 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003174:	7179                	addi	sp,sp,-48
    80003176:	f406                	sd	ra,40(sp)
    80003178:	f022                	sd	s0,32(sp)
    8000317a:	ec26                	sd	s1,24(sp)
    8000317c:	e84a                	sd	s2,16(sp)
    8000317e:	e44e                	sd	s3,8(sp)
    80003180:	1800                	addi	s0,sp,48
    80003182:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003184:	47ad                	li	a5,11
    80003186:	02b7e663          	bltu	a5,a1,800031b2 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000318a:	02059793          	slli	a5,a1,0x20
    8000318e:	01e7d593          	srli	a1,a5,0x1e
    80003192:	00b504b3          	add	s1,a0,a1
    80003196:	0504a903          	lw	s2,80(s1)
    8000319a:	06091a63          	bnez	s2,8000320e <bmap+0x9a>
      addr = balloc(ip->dev);
    8000319e:	4108                	lw	a0,0(a0)
    800031a0:	eb5ff0ef          	jal	80003054 <balloc>
    800031a4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031a8:	06090363          	beqz	s2,8000320e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800031ac:	0524a823          	sw	s2,80(s1)
    800031b0:	a8b9                	j	8000320e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031b2:	ff45849b          	addiw	s1,a1,-12
    800031b6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800031ba:	0ff00793          	li	a5,255
    800031be:	06e7ee63          	bltu	a5,a4,8000323a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800031c2:	08052903          	lw	s2,128(a0)
    800031c6:	00091d63          	bnez	s2,800031e0 <bmap+0x6c>
      addr = balloc(ip->dev);
    800031ca:	4108                	lw	a0,0(a0)
    800031cc:	e89ff0ef          	jal	80003054 <balloc>
    800031d0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800031d4:	02090d63          	beqz	s2,8000320e <bmap+0x9a>
    800031d8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800031da:	0929a023          	sw	s2,128(s3)
    800031de:	a011                	j	800031e2 <bmap+0x6e>
    800031e0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800031e2:	85ca                	mv	a1,s2
    800031e4:	0009a503          	lw	a0,0(s3)
    800031e8:	c09ff0ef          	jal	80002df0 <bread>
    800031ec:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031ee:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031f2:	02049713          	slli	a4,s1,0x20
    800031f6:	01e75593          	srli	a1,a4,0x1e
    800031fa:	00b784b3          	add	s1,a5,a1
    800031fe:	0004a903          	lw	s2,0(s1)
    80003202:	00090e63          	beqz	s2,8000321e <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003206:	8552                	mv	a0,s4
    80003208:	cf1ff0ef          	jal	80002ef8 <brelse>
    return addr;
    8000320c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000320e:	854a                	mv	a0,s2
    80003210:	70a2                	ld	ra,40(sp)
    80003212:	7402                	ld	s0,32(sp)
    80003214:	64e2                	ld	s1,24(sp)
    80003216:	6942                	ld	s2,16(sp)
    80003218:	69a2                	ld	s3,8(sp)
    8000321a:	6145                	addi	sp,sp,48
    8000321c:	8082                	ret
      addr = balloc(ip->dev);
    8000321e:	0009a503          	lw	a0,0(s3)
    80003222:	e33ff0ef          	jal	80003054 <balloc>
    80003226:	0005091b          	sext.w	s2,a0
      if(addr){
    8000322a:	fc090ee3          	beqz	s2,80003206 <bmap+0x92>
        a[bn] = addr;
    8000322e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003232:	8552                	mv	a0,s4
    80003234:	5f7000ef          	jal	8000402a <log_write>
    80003238:	b7f9                	j	80003206 <bmap+0x92>
    8000323a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000323c:	00004517          	auipc	a0,0x4
    80003240:	1bc50513          	addi	a0,a0,444 # 800073f8 <etext+0x3f8>
    80003244:	d9cfd0ef          	jal	800007e0 <panic>

0000000080003248 <iget>:
{
    80003248:	7179                	addi	sp,sp,-48
    8000324a:	f406                	sd	ra,40(sp)
    8000324c:	f022                	sd	s0,32(sp)
    8000324e:	ec26                	sd	s1,24(sp)
    80003250:	e84a                	sd	s2,16(sp)
    80003252:	e44e                	sd	s3,8(sp)
    80003254:	e052                	sd	s4,0(sp)
    80003256:	1800                	addi	s0,sp,48
    80003258:	89aa                	mv	s3,a0
    8000325a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000325c:	0001b517          	auipc	a0,0x1b
    80003260:	c3450513          	addi	a0,a0,-972 # 8001de90 <itable>
    80003264:	96bfd0ef          	jal	80000bce <acquire>
  empty = 0;
    80003268:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000326a:	0001b497          	auipc	s1,0x1b
    8000326e:	c3e48493          	addi	s1,s1,-962 # 8001dea8 <itable+0x18>
    80003272:	0001c697          	auipc	a3,0x1c
    80003276:	6c668693          	addi	a3,a3,1734 # 8001f938 <log>
    8000327a:	a039                	j	80003288 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000327c:	02090963          	beqz	s2,800032ae <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003280:	08848493          	addi	s1,s1,136
    80003284:	02d48863          	beq	s1,a3,800032b4 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003288:	449c                	lw	a5,8(s1)
    8000328a:	fef059e3          	blez	a5,8000327c <iget+0x34>
    8000328e:	4098                	lw	a4,0(s1)
    80003290:	ff3716e3          	bne	a4,s3,8000327c <iget+0x34>
    80003294:	40d8                	lw	a4,4(s1)
    80003296:	ff4713e3          	bne	a4,s4,8000327c <iget+0x34>
      ip->ref++;
    8000329a:	2785                	addiw	a5,a5,1
    8000329c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000329e:	0001b517          	auipc	a0,0x1b
    800032a2:	bf250513          	addi	a0,a0,-1038 # 8001de90 <itable>
    800032a6:	9c1fd0ef          	jal	80000c66 <release>
      return ip;
    800032aa:	8926                	mv	s2,s1
    800032ac:	a02d                	j	800032d6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032ae:	fbe9                	bnez	a5,80003280 <iget+0x38>
      empty = ip;
    800032b0:	8926                	mv	s2,s1
    800032b2:	b7f9                	j	80003280 <iget+0x38>
  if(empty == 0)
    800032b4:	02090a63          	beqz	s2,800032e8 <iget+0xa0>
  ip->dev = dev;
    800032b8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800032bc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800032c0:	4785                	li	a5,1
    800032c2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800032c6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800032ca:	0001b517          	auipc	a0,0x1b
    800032ce:	bc650513          	addi	a0,a0,-1082 # 8001de90 <itable>
    800032d2:	995fd0ef          	jal	80000c66 <release>
}
    800032d6:	854a                	mv	a0,s2
    800032d8:	70a2                	ld	ra,40(sp)
    800032da:	7402                	ld	s0,32(sp)
    800032dc:	64e2                	ld	s1,24(sp)
    800032de:	6942                	ld	s2,16(sp)
    800032e0:	69a2                	ld	s3,8(sp)
    800032e2:	6a02                	ld	s4,0(sp)
    800032e4:	6145                	addi	sp,sp,48
    800032e6:	8082                	ret
    panic("iget: no inodes");
    800032e8:	00004517          	auipc	a0,0x4
    800032ec:	12850513          	addi	a0,a0,296 # 80007410 <etext+0x410>
    800032f0:	cf0fd0ef          	jal	800007e0 <panic>

00000000800032f4 <iinit>:
{
    800032f4:	7179                	addi	sp,sp,-48
    800032f6:	f406                	sd	ra,40(sp)
    800032f8:	f022                	sd	s0,32(sp)
    800032fa:	ec26                	sd	s1,24(sp)
    800032fc:	e84a                	sd	s2,16(sp)
    800032fe:	e44e                	sd	s3,8(sp)
    80003300:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003302:	00004597          	auipc	a1,0x4
    80003306:	11e58593          	addi	a1,a1,286 # 80007420 <etext+0x420>
    8000330a:	0001b517          	auipc	a0,0x1b
    8000330e:	b8650513          	addi	a0,a0,-1146 # 8001de90 <itable>
    80003312:	83dfd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003316:	0001b497          	auipc	s1,0x1b
    8000331a:	ba248493          	addi	s1,s1,-1118 # 8001deb8 <itable+0x28>
    8000331e:	0001c997          	auipc	s3,0x1c
    80003322:	62a98993          	addi	s3,s3,1578 # 8001f948 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003326:	00004917          	auipc	s2,0x4
    8000332a:	10290913          	addi	s2,s2,258 # 80007428 <etext+0x428>
    8000332e:	85ca                	mv	a1,s2
    80003330:	8526                	mv	a0,s1
    80003332:	5bb000ef          	jal	800040ec <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003336:	08848493          	addi	s1,s1,136
    8000333a:	ff349ae3          	bne	s1,s3,8000332e <iinit+0x3a>
}
    8000333e:	70a2                	ld	ra,40(sp)
    80003340:	7402                	ld	s0,32(sp)
    80003342:	64e2                	ld	s1,24(sp)
    80003344:	6942                	ld	s2,16(sp)
    80003346:	69a2                	ld	s3,8(sp)
    80003348:	6145                	addi	sp,sp,48
    8000334a:	8082                	ret

000000008000334c <ialloc>:
{
    8000334c:	7139                	addi	sp,sp,-64
    8000334e:	fc06                	sd	ra,56(sp)
    80003350:	f822                	sd	s0,48(sp)
    80003352:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003354:	0001b717          	auipc	a4,0x1b
    80003358:	b2872703          	lw	a4,-1240(a4) # 8001de7c <sb+0xc>
    8000335c:	4785                	li	a5,1
    8000335e:	06e7f063          	bgeu	a5,a4,800033be <ialloc+0x72>
    80003362:	f426                	sd	s1,40(sp)
    80003364:	f04a                	sd	s2,32(sp)
    80003366:	ec4e                	sd	s3,24(sp)
    80003368:	e852                	sd	s4,16(sp)
    8000336a:	e456                	sd	s5,8(sp)
    8000336c:	e05a                	sd	s6,0(sp)
    8000336e:	8aaa                	mv	s5,a0
    80003370:	8b2e                	mv	s6,a1
    80003372:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003374:	0001ba17          	auipc	s4,0x1b
    80003378:	afca0a13          	addi	s4,s4,-1284 # 8001de70 <sb>
    8000337c:	00495593          	srli	a1,s2,0x4
    80003380:	018a2783          	lw	a5,24(s4)
    80003384:	9dbd                	addw	a1,a1,a5
    80003386:	8556                	mv	a0,s5
    80003388:	a69ff0ef          	jal	80002df0 <bread>
    8000338c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000338e:	05850993          	addi	s3,a0,88
    80003392:	00f97793          	andi	a5,s2,15
    80003396:	079a                	slli	a5,a5,0x6
    80003398:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000339a:	00099783          	lh	a5,0(s3)
    8000339e:	cb9d                	beqz	a5,800033d4 <ialloc+0x88>
    brelse(bp);
    800033a0:	b59ff0ef          	jal	80002ef8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033a4:	0905                	addi	s2,s2,1
    800033a6:	00ca2703          	lw	a4,12(s4)
    800033aa:	0009079b          	sext.w	a5,s2
    800033ae:	fce7e7e3          	bltu	a5,a4,8000337c <ialloc+0x30>
    800033b2:	74a2                	ld	s1,40(sp)
    800033b4:	7902                	ld	s2,32(sp)
    800033b6:	69e2                	ld	s3,24(sp)
    800033b8:	6a42                	ld	s4,16(sp)
    800033ba:	6aa2                	ld	s5,8(sp)
    800033bc:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033be:	00004517          	auipc	a0,0x4
    800033c2:	07250513          	addi	a0,a0,114 # 80007430 <etext+0x430>
    800033c6:	934fd0ef          	jal	800004fa <printf>
  return 0;
    800033ca:	4501                	li	a0,0
}
    800033cc:	70e2                	ld	ra,56(sp)
    800033ce:	7442                	ld	s0,48(sp)
    800033d0:	6121                	addi	sp,sp,64
    800033d2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033d4:	04000613          	li	a2,64
    800033d8:	4581                	li	a1,0
    800033da:	854e                	mv	a0,s3
    800033dc:	8c7fd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    800033e0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033e4:	8526                	mv	a0,s1
    800033e6:	445000ef          	jal	8000402a <log_write>
      brelse(bp);
    800033ea:	8526                	mv	a0,s1
    800033ec:	b0dff0ef          	jal	80002ef8 <brelse>
      return iget(dev, inum);
    800033f0:	0009059b          	sext.w	a1,s2
    800033f4:	8556                	mv	a0,s5
    800033f6:	e53ff0ef          	jal	80003248 <iget>
    800033fa:	74a2                	ld	s1,40(sp)
    800033fc:	7902                	ld	s2,32(sp)
    800033fe:	69e2                	ld	s3,24(sp)
    80003400:	6a42                	ld	s4,16(sp)
    80003402:	6aa2                	ld	s5,8(sp)
    80003404:	6b02                	ld	s6,0(sp)
    80003406:	b7d9                	j	800033cc <ialloc+0x80>

0000000080003408 <iupdate>:
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	e04a                	sd	s2,0(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003416:	415c                	lw	a5,4(a0)
    80003418:	0047d79b          	srliw	a5,a5,0x4
    8000341c:	0001b597          	auipc	a1,0x1b
    80003420:	a6c5a583          	lw	a1,-1428(a1) # 8001de88 <sb+0x18>
    80003424:	9dbd                	addw	a1,a1,a5
    80003426:	4108                	lw	a0,0(a0)
    80003428:	9c9ff0ef          	jal	80002df0 <bread>
    8000342c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000342e:	05850793          	addi	a5,a0,88
    80003432:	40d8                	lw	a4,4(s1)
    80003434:	8b3d                	andi	a4,a4,15
    80003436:	071a                	slli	a4,a4,0x6
    80003438:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000343a:	04449703          	lh	a4,68(s1)
    8000343e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003442:	04649703          	lh	a4,70(s1)
    80003446:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000344a:	04849703          	lh	a4,72(s1)
    8000344e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003452:	04a49703          	lh	a4,74(s1)
    80003456:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000345a:	44f8                	lw	a4,76(s1)
    8000345c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000345e:	03400613          	li	a2,52
    80003462:	05048593          	addi	a1,s1,80
    80003466:	00c78513          	addi	a0,a5,12
    8000346a:	895fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	3bb000ef          	jal	8000402a <log_write>
  brelse(bp);
    80003474:	854a                	mv	a0,s2
    80003476:	a83ff0ef          	jal	80002ef8 <brelse>
}
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6902                	ld	s2,0(sp)
    80003482:	6105                	addi	sp,sp,32
    80003484:	8082                	ret

0000000080003486 <idup>:
{
    80003486:	1101                	addi	sp,sp,-32
    80003488:	ec06                	sd	ra,24(sp)
    8000348a:	e822                	sd	s0,16(sp)
    8000348c:	e426                	sd	s1,8(sp)
    8000348e:	1000                	addi	s0,sp,32
    80003490:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003492:	0001b517          	auipc	a0,0x1b
    80003496:	9fe50513          	addi	a0,a0,-1538 # 8001de90 <itable>
    8000349a:	f34fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    8000349e:	449c                	lw	a5,8(s1)
    800034a0:	2785                	addiw	a5,a5,1
    800034a2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034a4:	0001b517          	auipc	a0,0x1b
    800034a8:	9ec50513          	addi	a0,a0,-1556 # 8001de90 <itable>
    800034ac:	fbafd0ef          	jal	80000c66 <release>
}
    800034b0:	8526                	mv	a0,s1
    800034b2:	60e2                	ld	ra,24(sp)
    800034b4:	6442                	ld	s0,16(sp)
    800034b6:	64a2                	ld	s1,8(sp)
    800034b8:	6105                	addi	sp,sp,32
    800034ba:	8082                	ret

00000000800034bc <ilock>:
{
    800034bc:	1101                	addi	sp,sp,-32
    800034be:	ec06                	sd	ra,24(sp)
    800034c0:	e822                	sd	s0,16(sp)
    800034c2:	e426                	sd	s1,8(sp)
    800034c4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034c6:	cd19                	beqz	a0,800034e4 <ilock+0x28>
    800034c8:	84aa                	mv	s1,a0
    800034ca:	451c                	lw	a5,8(a0)
    800034cc:	00f05c63          	blez	a5,800034e4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800034d0:	0541                	addi	a0,a0,16
    800034d2:	451000ef          	jal	80004122 <acquiresleep>
  if(ip->valid == 0){
    800034d6:	40bc                	lw	a5,64(s1)
    800034d8:	cf89                	beqz	a5,800034f2 <ilock+0x36>
}
    800034da:	60e2                	ld	ra,24(sp)
    800034dc:	6442                	ld	s0,16(sp)
    800034de:	64a2                	ld	s1,8(sp)
    800034e0:	6105                	addi	sp,sp,32
    800034e2:	8082                	ret
    800034e4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034e6:	00004517          	auipc	a0,0x4
    800034ea:	f6250513          	addi	a0,a0,-158 # 80007448 <etext+0x448>
    800034ee:	af2fd0ef          	jal	800007e0 <panic>
    800034f2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034f4:	40dc                	lw	a5,4(s1)
    800034f6:	0047d79b          	srliw	a5,a5,0x4
    800034fa:	0001b597          	auipc	a1,0x1b
    800034fe:	98e5a583          	lw	a1,-1650(a1) # 8001de88 <sb+0x18>
    80003502:	9dbd                	addw	a1,a1,a5
    80003504:	4088                	lw	a0,0(s1)
    80003506:	8ebff0ef          	jal	80002df0 <bread>
    8000350a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000350c:	05850593          	addi	a1,a0,88
    80003510:	40dc                	lw	a5,4(s1)
    80003512:	8bbd                	andi	a5,a5,15
    80003514:	079a                	slli	a5,a5,0x6
    80003516:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003518:	00059783          	lh	a5,0(a1)
    8000351c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003520:	00259783          	lh	a5,2(a1)
    80003524:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003528:	00459783          	lh	a5,4(a1)
    8000352c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003530:	00659783          	lh	a5,6(a1)
    80003534:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003538:	459c                	lw	a5,8(a1)
    8000353a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000353c:	03400613          	li	a2,52
    80003540:	05b1                	addi	a1,a1,12
    80003542:	05048513          	addi	a0,s1,80
    80003546:	fb8fd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    8000354a:	854a                	mv	a0,s2
    8000354c:	9adff0ef          	jal	80002ef8 <brelse>
    ip->valid = 1;
    80003550:	4785                	li	a5,1
    80003552:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003554:	04449783          	lh	a5,68(s1)
    80003558:	c399                	beqz	a5,8000355e <ilock+0xa2>
    8000355a:	6902                	ld	s2,0(sp)
    8000355c:	bfbd                	j	800034da <ilock+0x1e>
      panic("ilock: no type");
    8000355e:	00004517          	auipc	a0,0x4
    80003562:	ef250513          	addi	a0,a0,-270 # 80007450 <etext+0x450>
    80003566:	a7afd0ef          	jal	800007e0 <panic>

000000008000356a <iunlock>:
{
    8000356a:	1101                	addi	sp,sp,-32
    8000356c:	ec06                	sd	ra,24(sp)
    8000356e:	e822                	sd	s0,16(sp)
    80003570:	e426                	sd	s1,8(sp)
    80003572:	e04a                	sd	s2,0(sp)
    80003574:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003576:	c505                	beqz	a0,8000359e <iunlock+0x34>
    80003578:	84aa                	mv	s1,a0
    8000357a:	01050913          	addi	s2,a0,16
    8000357e:	854a                	mv	a0,s2
    80003580:	421000ef          	jal	800041a0 <holdingsleep>
    80003584:	cd09                	beqz	a0,8000359e <iunlock+0x34>
    80003586:	449c                	lw	a5,8(s1)
    80003588:	00f05b63          	blez	a5,8000359e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000358c:	854a                	mv	a0,s2
    8000358e:	3db000ef          	jal	80004168 <releasesleep>
}
    80003592:	60e2                	ld	ra,24(sp)
    80003594:	6442                	ld	s0,16(sp)
    80003596:	64a2                	ld	s1,8(sp)
    80003598:	6902                	ld	s2,0(sp)
    8000359a:	6105                	addi	sp,sp,32
    8000359c:	8082                	ret
    panic("iunlock");
    8000359e:	00004517          	auipc	a0,0x4
    800035a2:	ec250513          	addi	a0,a0,-318 # 80007460 <etext+0x460>
    800035a6:	a3afd0ef          	jal	800007e0 <panic>

00000000800035aa <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035aa:	7179                	addi	sp,sp,-48
    800035ac:	f406                	sd	ra,40(sp)
    800035ae:	f022                	sd	s0,32(sp)
    800035b0:	ec26                	sd	s1,24(sp)
    800035b2:	e84a                	sd	s2,16(sp)
    800035b4:	e44e                	sd	s3,8(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035ba:	05050493          	addi	s1,a0,80
    800035be:	08050913          	addi	s2,a0,128
    800035c2:	a021                	j	800035ca <itrunc+0x20>
    800035c4:	0491                	addi	s1,s1,4
    800035c6:	01248b63          	beq	s1,s2,800035dc <itrunc+0x32>
    if(ip->addrs[i]){
    800035ca:	408c                	lw	a1,0(s1)
    800035cc:	dde5                	beqz	a1,800035c4 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035ce:	0009a503          	lw	a0,0(s3)
    800035d2:	a17ff0ef          	jal	80002fe8 <bfree>
      ip->addrs[i] = 0;
    800035d6:	0004a023          	sw	zero,0(s1)
    800035da:	b7ed                	j	800035c4 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035dc:	0809a583          	lw	a1,128(s3)
    800035e0:	ed89                	bnez	a1,800035fa <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035e2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035e6:	854e                	mv	a0,s3
    800035e8:	e21ff0ef          	jal	80003408 <iupdate>
}
    800035ec:	70a2                	ld	ra,40(sp)
    800035ee:	7402                	ld	s0,32(sp)
    800035f0:	64e2                	ld	s1,24(sp)
    800035f2:	6942                	ld	s2,16(sp)
    800035f4:	69a2                	ld	s3,8(sp)
    800035f6:	6145                	addi	sp,sp,48
    800035f8:	8082                	ret
    800035fa:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035fc:	0009a503          	lw	a0,0(s3)
    80003600:	ff0ff0ef          	jal	80002df0 <bread>
    80003604:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003606:	05850493          	addi	s1,a0,88
    8000360a:	45850913          	addi	s2,a0,1112
    8000360e:	a021                	j	80003616 <itrunc+0x6c>
    80003610:	0491                	addi	s1,s1,4
    80003612:	01248963          	beq	s1,s2,80003624 <itrunc+0x7a>
      if(a[j])
    80003616:	408c                	lw	a1,0(s1)
    80003618:	dde5                	beqz	a1,80003610 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000361a:	0009a503          	lw	a0,0(s3)
    8000361e:	9cbff0ef          	jal	80002fe8 <bfree>
    80003622:	b7fd                	j	80003610 <itrunc+0x66>
    brelse(bp);
    80003624:	8552                	mv	a0,s4
    80003626:	8d3ff0ef          	jal	80002ef8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000362a:	0809a583          	lw	a1,128(s3)
    8000362e:	0009a503          	lw	a0,0(s3)
    80003632:	9b7ff0ef          	jal	80002fe8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003636:	0809a023          	sw	zero,128(s3)
    8000363a:	6a02                	ld	s4,0(sp)
    8000363c:	b75d                	j	800035e2 <itrunc+0x38>

000000008000363e <iput>:
{
    8000363e:	1101                	addi	sp,sp,-32
    80003640:	ec06                	sd	ra,24(sp)
    80003642:	e822                	sd	s0,16(sp)
    80003644:	e426                	sd	s1,8(sp)
    80003646:	1000                	addi	s0,sp,32
    80003648:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000364a:	0001b517          	auipc	a0,0x1b
    8000364e:	84650513          	addi	a0,a0,-1978 # 8001de90 <itable>
    80003652:	d7cfd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003656:	4498                	lw	a4,8(s1)
    80003658:	4785                	li	a5,1
    8000365a:	02f70063          	beq	a4,a5,8000367a <iput+0x3c>
  ip->ref--;
    8000365e:	449c                	lw	a5,8(s1)
    80003660:	37fd                	addiw	a5,a5,-1
    80003662:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003664:	0001b517          	auipc	a0,0x1b
    80003668:	82c50513          	addi	a0,a0,-2004 # 8001de90 <itable>
    8000366c:	dfafd0ef          	jal	80000c66 <release>
}
    80003670:	60e2                	ld	ra,24(sp)
    80003672:	6442                	ld	s0,16(sp)
    80003674:	64a2                	ld	s1,8(sp)
    80003676:	6105                	addi	sp,sp,32
    80003678:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000367a:	40bc                	lw	a5,64(s1)
    8000367c:	d3ed                	beqz	a5,8000365e <iput+0x20>
    8000367e:	04a49783          	lh	a5,74(s1)
    80003682:	fff1                	bnez	a5,8000365e <iput+0x20>
    80003684:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003686:	01048913          	addi	s2,s1,16
    8000368a:	854a                	mv	a0,s2
    8000368c:	297000ef          	jal	80004122 <acquiresleep>
    release(&itable.lock);
    80003690:	0001b517          	auipc	a0,0x1b
    80003694:	80050513          	addi	a0,a0,-2048 # 8001de90 <itable>
    80003698:	dcefd0ef          	jal	80000c66 <release>
    itrunc(ip);
    8000369c:	8526                	mv	a0,s1
    8000369e:	f0dff0ef          	jal	800035aa <itrunc>
    ip->type = 0;
    800036a2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036a6:	8526                	mv	a0,s1
    800036a8:	d61ff0ef          	jal	80003408 <iupdate>
    ip->valid = 0;
    800036ac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036b0:	854a                	mv	a0,s2
    800036b2:	2b7000ef          	jal	80004168 <releasesleep>
    acquire(&itable.lock);
    800036b6:	0001a517          	auipc	a0,0x1a
    800036ba:	7da50513          	addi	a0,a0,2010 # 8001de90 <itable>
    800036be:	d10fd0ef          	jal	80000bce <acquire>
    800036c2:	6902                	ld	s2,0(sp)
    800036c4:	bf69                	j	8000365e <iput+0x20>

00000000800036c6 <iunlockput>:
{
    800036c6:	1101                	addi	sp,sp,-32
    800036c8:	ec06                	sd	ra,24(sp)
    800036ca:	e822                	sd	s0,16(sp)
    800036cc:	e426                	sd	s1,8(sp)
    800036ce:	1000                	addi	s0,sp,32
    800036d0:	84aa                	mv	s1,a0
  iunlock(ip);
    800036d2:	e99ff0ef          	jal	8000356a <iunlock>
  iput(ip);
    800036d6:	8526                	mv	a0,s1
    800036d8:	f67ff0ef          	jal	8000363e <iput>
}
    800036dc:	60e2                	ld	ra,24(sp)
    800036de:	6442                	ld	s0,16(sp)
    800036e0:	64a2                	ld	s1,8(sp)
    800036e2:	6105                	addi	sp,sp,32
    800036e4:	8082                	ret

00000000800036e6 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036e6:	0001a717          	auipc	a4,0x1a
    800036ea:	79672703          	lw	a4,1942(a4) # 8001de7c <sb+0xc>
    800036ee:	4785                	li	a5,1
    800036f0:	0ae7ff63          	bgeu	a5,a4,800037ae <ireclaim+0xc8>
{
    800036f4:	7139                	addi	sp,sp,-64
    800036f6:	fc06                	sd	ra,56(sp)
    800036f8:	f822                	sd	s0,48(sp)
    800036fa:	f426                	sd	s1,40(sp)
    800036fc:	f04a                	sd	s2,32(sp)
    800036fe:	ec4e                	sd	s3,24(sp)
    80003700:	e852                	sd	s4,16(sp)
    80003702:	e456                	sd	s5,8(sp)
    80003704:	e05a                	sd	s6,0(sp)
    80003706:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003708:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000370a:	00050a1b          	sext.w	s4,a0
    8000370e:	0001aa97          	auipc	s5,0x1a
    80003712:	762a8a93          	addi	s5,s5,1890 # 8001de70 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003716:	00004b17          	auipc	s6,0x4
    8000371a:	d52b0b13          	addi	s6,s6,-686 # 80007468 <etext+0x468>
    8000371e:	a099                	j	80003764 <ireclaim+0x7e>
    80003720:	85ce                	mv	a1,s3
    80003722:	855a                	mv	a0,s6
    80003724:	dd7fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003728:	85ce                	mv	a1,s3
    8000372a:	8552                	mv	a0,s4
    8000372c:	b1dff0ef          	jal	80003248 <iget>
    80003730:	89aa                	mv	s3,a0
    brelse(bp);
    80003732:	854a                	mv	a0,s2
    80003734:	fc4ff0ef          	jal	80002ef8 <brelse>
    if (ip) {
    80003738:	00098f63          	beqz	s3,80003756 <ireclaim+0x70>
      begin_op();
    8000373c:	76a000ef          	jal	80003ea6 <begin_op>
      ilock(ip);
    80003740:	854e                	mv	a0,s3
    80003742:	d7bff0ef          	jal	800034bc <ilock>
      iunlock(ip);
    80003746:	854e                	mv	a0,s3
    80003748:	e23ff0ef          	jal	8000356a <iunlock>
      iput(ip);
    8000374c:	854e                	mv	a0,s3
    8000374e:	ef1ff0ef          	jal	8000363e <iput>
      end_op();
    80003752:	7be000ef          	jal	80003f10 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003756:	0485                	addi	s1,s1,1
    80003758:	00caa703          	lw	a4,12(s5)
    8000375c:	0004879b          	sext.w	a5,s1
    80003760:	02e7fd63          	bgeu	a5,a4,8000379a <ireclaim+0xb4>
    80003764:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003768:	0044d593          	srli	a1,s1,0x4
    8000376c:	018aa783          	lw	a5,24(s5)
    80003770:	9dbd                	addw	a1,a1,a5
    80003772:	8552                	mv	a0,s4
    80003774:	e7cff0ef          	jal	80002df0 <bread>
    80003778:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000377a:	05850793          	addi	a5,a0,88
    8000377e:	00f9f713          	andi	a4,s3,15
    80003782:	071a                	slli	a4,a4,0x6
    80003784:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003786:	00079703          	lh	a4,0(a5)
    8000378a:	c701                	beqz	a4,80003792 <ireclaim+0xac>
    8000378c:	00679783          	lh	a5,6(a5)
    80003790:	dbc1                	beqz	a5,80003720 <ireclaim+0x3a>
    brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	f64ff0ef          	jal	80002ef8 <brelse>
    if (ip) {
    80003798:	bf7d                	j	80003756 <ireclaim+0x70>
}
    8000379a:	70e2                	ld	ra,56(sp)
    8000379c:	7442                	ld	s0,48(sp)
    8000379e:	74a2                	ld	s1,40(sp)
    800037a0:	7902                	ld	s2,32(sp)
    800037a2:	69e2                	ld	s3,24(sp)
    800037a4:	6a42                	ld	s4,16(sp)
    800037a6:	6aa2                	ld	s5,8(sp)
    800037a8:	6b02                	ld	s6,0(sp)
    800037aa:	6121                	addi	sp,sp,64
    800037ac:	8082                	ret
    800037ae:	8082                	ret

00000000800037b0 <fsinit>:
fsinit(int dev) {
    800037b0:	7179                	addi	sp,sp,-48
    800037b2:	f406                	sd	ra,40(sp)
    800037b4:	f022                	sd	s0,32(sp)
    800037b6:	ec26                	sd	s1,24(sp)
    800037b8:	e84a                	sd	s2,16(sp)
    800037ba:	e44e                	sd	s3,8(sp)
    800037bc:	1800                	addi	s0,sp,48
    800037be:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    800037c0:	4585                	li	a1,1
    800037c2:	e2eff0ef          	jal	80002df0 <bread>
    800037c6:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037c8:	0001a997          	auipc	s3,0x1a
    800037cc:	6a898993          	addi	s3,s3,1704 # 8001de70 <sb>
    800037d0:	02000613          	li	a2,32
    800037d4:	05850593          	addi	a1,a0,88
    800037d8:	854e                	mv	a0,s3
    800037da:	d24fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    800037de:	854a                	mv	a0,s2
    800037e0:	f18ff0ef          	jal	80002ef8 <brelse>
  if(sb.magic != FSMAGIC)
    800037e4:	0009a703          	lw	a4,0(s3)
    800037e8:	102037b7          	lui	a5,0x10203
    800037ec:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037f0:	02f71363          	bne	a4,a5,80003816 <fsinit+0x66>
  initlog(dev, &sb);
    800037f4:	0001a597          	auipc	a1,0x1a
    800037f8:	67c58593          	addi	a1,a1,1660 # 8001de70 <sb>
    800037fc:	8526                	mv	a0,s1
    800037fe:	62a000ef          	jal	80003e28 <initlog>
  ireclaim(dev);
    80003802:	8526                	mv	a0,s1
    80003804:	ee3ff0ef          	jal	800036e6 <ireclaim>
}
    80003808:	70a2                	ld	ra,40(sp)
    8000380a:	7402                	ld	s0,32(sp)
    8000380c:	64e2                	ld	s1,24(sp)
    8000380e:	6942                	ld	s2,16(sp)
    80003810:	69a2                	ld	s3,8(sp)
    80003812:	6145                	addi	sp,sp,48
    80003814:	8082                	ret
    panic("invalid file system");
    80003816:	00004517          	auipc	a0,0x4
    8000381a:	c7250513          	addi	a0,a0,-910 # 80007488 <etext+0x488>
    8000381e:	fc3fc0ef          	jal	800007e0 <panic>

0000000080003822 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003822:	1141                	addi	sp,sp,-16
    80003824:	e422                	sd	s0,8(sp)
    80003826:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003828:	411c                	lw	a5,0(a0)
    8000382a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000382c:	415c                	lw	a5,4(a0)
    8000382e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003830:	04451783          	lh	a5,68(a0)
    80003834:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003838:	04a51783          	lh	a5,74(a0)
    8000383c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003840:	04c56783          	lwu	a5,76(a0)
    80003844:	e99c                	sd	a5,16(a1)
}
    80003846:	6422                	ld	s0,8(sp)
    80003848:	0141                	addi	sp,sp,16
    8000384a:	8082                	ret

000000008000384c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000384c:	457c                	lw	a5,76(a0)
    8000384e:	0ed7eb63          	bltu	a5,a3,80003944 <readi+0xf8>
{
    80003852:	7159                	addi	sp,sp,-112
    80003854:	f486                	sd	ra,104(sp)
    80003856:	f0a2                	sd	s0,96(sp)
    80003858:	eca6                	sd	s1,88(sp)
    8000385a:	e0d2                	sd	s4,64(sp)
    8000385c:	fc56                	sd	s5,56(sp)
    8000385e:	f85a                	sd	s6,48(sp)
    80003860:	f45e                	sd	s7,40(sp)
    80003862:	1880                	addi	s0,sp,112
    80003864:	8b2a                	mv	s6,a0
    80003866:	8bae                	mv	s7,a1
    80003868:	8a32                	mv	s4,a2
    8000386a:	84b6                	mv	s1,a3
    8000386c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000386e:	9f35                	addw	a4,a4,a3
    return 0;
    80003870:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003872:	0cd76063          	bltu	a4,a3,80003932 <readi+0xe6>
    80003876:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003878:	00e7f463          	bgeu	a5,a4,80003880 <readi+0x34>
    n = ip->size - off;
    8000387c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003880:	080a8f63          	beqz	s5,8000391e <readi+0xd2>
    80003884:	e8ca                	sd	s2,80(sp)
    80003886:	f062                	sd	s8,32(sp)
    80003888:	ec66                	sd	s9,24(sp)
    8000388a:	e86a                	sd	s10,16(sp)
    8000388c:	e46e                	sd	s11,8(sp)
    8000388e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003890:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003894:	5c7d                	li	s8,-1
    80003896:	a80d                	j	800038c8 <readi+0x7c>
    80003898:	020d1d93          	slli	s11,s10,0x20
    8000389c:	020ddd93          	srli	s11,s11,0x20
    800038a0:	05890613          	addi	a2,s2,88
    800038a4:	86ee                	mv	a3,s11
    800038a6:	963a                	add	a2,a2,a4
    800038a8:	85d2                	mv	a1,s4
    800038aa:	855e                	mv	a0,s7
    800038ac:	b77fe0ef          	jal	80002422 <either_copyout>
    800038b0:	05850763          	beq	a0,s8,800038fe <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	e42ff0ef          	jal	80002ef8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038ba:	013d09bb          	addw	s3,s10,s3
    800038be:	009d04bb          	addw	s1,s10,s1
    800038c2:	9a6e                	add	s4,s4,s11
    800038c4:	0559f763          	bgeu	s3,s5,80003912 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800038c8:	00a4d59b          	srliw	a1,s1,0xa
    800038cc:	855a                	mv	a0,s6
    800038ce:	8a7ff0ef          	jal	80003174 <bmap>
    800038d2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800038d6:	c5b1                	beqz	a1,80003922 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800038d8:	000b2503          	lw	a0,0(s6)
    800038dc:	d14ff0ef          	jal	80002df0 <bread>
    800038e0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038e2:	3ff4f713          	andi	a4,s1,1023
    800038e6:	40ec87bb          	subw	a5,s9,a4
    800038ea:	413a86bb          	subw	a3,s5,s3
    800038ee:	8d3e                	mv	s10,a5
    800038f0:	2781                	sext.w	a5,a5
    800038f2:	0006861b          	sext.w	a2,a3
    800038f6:	faf671e3          	bgeu	a2,a5,80003898 <readi+0x4c>
    800038fa:	8d36                	mv	s10,a3
    800038fc:	bf71                	j	80003898 <readi+0x4c>
      brelse(bp);
    800038fe:	854a                	mv	a0,s2
    80003900:	df8ff0ef          	jal	80002ef8 <brelse>
      tot = -1;
    80003904:	59fd                	li	s3,-1
      break;
    80003906:	6946                	ld	s2,80(sp)
    80003908:	7c02                	ld	s8,32(sp)
    8000390a:	6ce2                	ld	s9,24(sp)
    8000390c:	6d42                	ld	s10,16(sp)
    8000390e:	6da2                	ld	s11,8(sp)
    80003910:	a831                	j	8000392c <readi+0xe0>
    80003912:	6946                	ld	s2,80(sp)
    80003914:	7c02                	ld	s8,32(sp)
    80003916:	6ce2                	ld	s9,24(sp)
    80003918:	6d42                	ld	s10,16(sp)
    8000391a:	6da2                	ld	s11,8(sp)
    8000391c:	a801                	j	8000392c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000391e:	89d6                	mv	s3,s5
    80003920:	a031                	j	8000392c <readi+0xe0>
    80003922:	6946                	ld	s2,80(sp)
    80003924:	7c02                	ld	s8,32(sp)
    80003926:	6ce2                	ld	s9,24(sp)
    80003928:	6d42                	ld	s10,16(sp)
    8000392a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000392c:	0009851b          	sext.w	a0,s3
    80003930:	69a6                	ld	s3,72(sp)
}
    80003932:	70a6                	ld	ra,104(sp)
    80003934:	7406                	ld	s0,96(sp)
    80003936:	64e6                	ld	s1,88(sp)
    80003938:	6a06                	ld	s4,64(sp)
    8000393a:	7ae2                	ld	s5,56(sp)
    8000393c:	7b42                	ld	s6,48(sp)
    8000393e:	7ba2                	ld	s7,40(sp)
    80003940:	6165                	addi	sp,sp,112
    80003942:	8082                	ret
    return 0;
    80003944:	4501                	li	a0,0
}
    80003946:	8082                	ret

0000000080003948 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003948:	457c                	lw	a5,76(a0)
    8000394a:	10d7e063          	bltu	a5,a3,80003a4a <writei+0x102>
{
    8000394e:	7159                	addi	sp,sp,-112
    80003950:	f486                	sd	ra,104(sp)
    80003952:	f0a2                	sd	s0,96(sp)
    80003954:	e8ca                	sd	s2,80(sp)
    80003956:	e0d2                	sd	s4,64(sp)
    80003958:	fc56                	sd	s5,56(sp)
    8000395a:	f85a                	sd	s6,48(sp)
    8000395c:	f45e                	sd	s7,40(sp)
    8000395e:	1880                	addi	s0,sp,112
    80003960:	8aaa                	mv	s5,a0
    80003962:	8bae                	mv	s7,a1
    80003964:	8a32                	mv	s4,a2
    80003966:	8936                	mv	s2,a3
    80003968:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000396a:	00e687bb          	addw	a5,a3,a4
    8000396e:	0ed7e063          	bltu	a5,a3,80003a4e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003972:	00043737          	lui	a4,0x43
    80003976:	0cf76e63          	bltu	a4,a5,80003a52 <writei+0x10a>
    8000397a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000397c:	0a0b0f63          	beqz	s6,80003a3a <writei+0xf2>
    80003980:	eca6                	sd	s1,88(sp)
    80003982:	f062                	sd	s8,32(sp)
    80003984:	ec66                	sd	s9,24(sp)
    80003986:	e86a                	sd	s10,16(sp)
    80003988:	e46e                	sd	s11,8(sp)
    8000398a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000398c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003990:	5c7d                	li	s8,-1
    80003992:	a825                	j	800039ca <writei+0x82>
    80003994:	020d1d93          	slli	s11,s10,0x20
    80003998:	020ddd93          	srli	s11,s11,0x20
    8000399c:	05848513          	addi	a0,s1,88
    800039a0:	86ee                	mv	a3,s11
    800039a2:	8652                	mv	a2,s4
    800039a4:	85de                	mv	a1,s7
    800039a6:	953a                	add	a0,a0,a4
    800039a8:	ac5fe0ef          	jal	8000246c <either_copyin>
    800039ac:	05850a63          	beq	a0,s8,80003a00 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039b0:	8526                	mv	a0,s1
    800039b2:	678000ef          	jal	8000402a <log_write>
    brelse(bp);
    800039b6:	8526                	mv	a0,s1
    800039b8:	d40ff0ef          	jal	80002ef8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039bc:	013d09bb          	addw	s3,s10,s3
    800039c0:	012d093b          	addw	s2,s10,s2
    800039c4:	9a6e                	add	s4,s4,s11
    800039c6:	0569f063          	bgeu	s3,s6,80003a06 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800039ca:	00a9559b          	srliw	a1,s2,0xa
    800039ce:	8556                	mv	a0,s5
    800039d0:	fa4ff0ef          	jal	80003174 <bmap>
    800039d4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039d8:	c59d                	beqz	a1,80003a06 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800039da:	000aa503          	lw	a0,0(s5)
    800039de:	c12ff0ef          	jal	80002df0 <bread>
    800039e2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e4:	3ff97713          	andi	a4,s2,1023
    800039e8:	40ec87bb          	subw	a5,s9,a4
    800039ec:	413b06bb          	subw	a3,s6,s3
    800039f0:	8d3e                	mv	s10,a5
    800039f2:	2781                	sext.w	a5,a5
    800039f4:	0006861b          	sext.w	a2,a3
    800039f8:	f8f67ee3          	bgeu	a2,a5,80003994 <writei+0x4c>
    800039fc:	8d36                	mv	s10,a3
    800039fe:	bf59                	j	80003994 <writei+0x4c>
      brelse(bp);
    80003a00:	8526                	mv	a0,s1
    80003a02:	cf6ff0ef          	jal	80002ef8 <brelse>
  }

  if(off > ip->size)
    80003a06:	04caa783          	lw	a5,76(s5)
    80003a0a:	0327fa63          	bgeu	a5,s2,80003a3e <writei+0xf6>
    ip->size = off;
    80003a0e:	052aa623          	sw	s2,76(s5)
    80003a12:	64e6                	ld	s1,88(sp)
    80003a14:	7c02                	ld	s8,32(sp)
    80003a16:	6ce2                	ld	s9,24(sp)
    80003a18:	6d42                	ld	s10,16(sp)
    80003a1a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a1c:	8556                	mv	a0,s5
    80003a1e:	9ebff0ef          	jal	80003408 <iupdate>

  return tot;
    80003a22:	0009851b          	sext.w	a0,s3
    80003a26:	69a6                	ld	s3,72(sp)
}
    80003a28:	70a6                	ld	ra,104(sp)
    80003a2a:	7406                	ld	s0,96(sp)
    80003a2c:	6946                	ld	s2,80(sp)
    80003a2e:	6a06                	ld	s4,64(sp)
    80003a30:	7ae2                	ld	s5,56(sp)
    80003a32:	7b42                	ld	s6,48(sp)
    80003a34:	7ba2                	ld	s7,40(sp)
    80003a36:	6165                	addi	sp,sp,112
    80003a38:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a3a:	89da                	mv	s3,s6
    80003a3c:	b7c5                	j	80003a1c <writei+0xd4>
    80003a3e:	64e6                	ld	s1,88(sp)
    80003a40:	7c02                	ld	s8,32(sp)
    80003a42:	6ce2                	ld	s9,24(sp)
    80003a44:	6d42                	ld	s10,16(sp)
    80003a46:	6da2                	ld	s11,8(sp)
    80003a48:	bfd1                	j	80003a1c <writei+0xd4>
    return -1;
    80003a4a:	557d                	li	a0,-1
}
    80003a4c:	8082                	ret
    return -1;
    80003a4e:	557d                	li	a0,-1
    80003a50:	bfe1                	j	80003a28 <writei+0xe0>
    return -1;
    80003a52:	557d                	li	a0,-1
    80003a54:	bfd1                	j	80003a28 <writei+0xe0>

0000000080003a56 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a56:	1141                	addi	sp,sp,-16
    80003a58:	e406                	sd	ra,8(sp)
    80003a5a:	e022                	sd	s0,0(sp)
    80003a5c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a5e:	4639                	li	a2,14
    80003a60:	b0efd0ef          	jal	80000d6e <strncmp>
}
    80003a64:	60a2                	ld	ra,8(sp)
    80003a66:	6402                	ld	s0,0(sp)
    80003a68:	0141                	addi	sp,sp,16
    80003a6a:	8082                	ret

0000000080003a6c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a6c:	7139                	addi	sp,sp,-64
    80003a6e:	fc06                	sd	ra,56(sp)
    80003a70:	f822                	sd	s0,48(sp)
    80003a72:	f426                	sd	s1,40(sp)
    80003a74:	f04a                	sd	s2,32(sp)
    80003a76:	ec4e                	sd	s3,24(sp)
    80003a78:	e852                	sd	s4,16(sp)
    80003a7a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a7c:	04451703          	lh	a4,68(a0)
    80003a80:	4785                	li	a5,1
    80003a82:	00f71a63          	bne	a4,a5,80003a96 <dirlookup+0x2a>
    80003a86:	892a                	mv	s2,a0
    80003a88:	89ae                	mv	s3,a1
    80003a8a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a8c:	457c                	lw	a5,76(a0)
    80003a8e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a90:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a92:	e39d                	bnez	a5,80003ab8 <dirlookup+0x4c>
    80003a94:	a095                	j	80003af8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a96:	00004517          	auipc	a0,0x4
    80003a9a:	a0a50513          	addi	a0,a0,-1526 # 800074a0 <etext+0x4a0>
    80003a9e:	d43fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80003aa2:	00004517          	auipc	a0,0x4
    80003aa6:	a1650513          	addi	a0,a0,-1514 # 800074b8 <etext+0x4b8>
    80003aaa:	d37fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aae:	24c1                	addiw	s1,s1,16
    80003ab0:	04c92783          	lw	a5,76(s2)
    80003ab4:	04f4f163          	bgeu	s1,a5,80003af6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ab8:	4741                	li	a4,16
    80003aba:	86a6                	mv	a3,s1
    80003abc:	fc040613          	addi	a2,s0,-64
    80003ac0:	4581                	li	a1,0
    80003ac2:	854a                	mv	a0,s2
    80003ac4:	d89ff0ef          	jal	8000384c <readi>
    80003ac8:	47c1                	li	a5,16
    80003aca:	fcf51ce3          	bne	a0,a5,80003aa2 <dirlookup+0x36>
    if(de.inum == 0)
    80003ace:	fc045783          	lhu	a5,-64(s0)
    80003ad2:	dff1                	beqz	a5,80003aae <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003ad4:	fc240593          	addi	a1,s0,-62
    80003ad8:	854e                	mv	a0,s3
    80003ada:	f7dff0ef          	jal	80003a56 <namecmp>
    80003ade:	f961                	bnez	a0,80003aae <dirlookup+0x42>
      if(poff)
    80003ae0:	000a0463          	beqz	s4,80003ae8 <dirlookup+0x7c>
        *poff = off;
    80003ae4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ae8:	fc045583          	lhu	a1,-64(s0)
    80003aec:	00092503          	lw	a0,0(s2)
    80003af0:	f58ff0ef          	jal	80003248 <iget>
    80003af4:	a011                	j	80003af8 <dirlookup+0x8c>
  return 0;
    80003af6:	4501                	li	a0,0
}
    80003af8:	70e2                	ld	ra,56(sp)
    80003afa:	7442                	ld	s0,48(sp)
    80003afc:	74a2                	ld	s1,40(sp)
    80003afe:	7902                	ld	s2,32(sp)
    80003b00:	69e2                	ld	s3,24(sp)
    80003b02:	6a42                	ld	s4,16(sp)
    80003b04:	6121                	addi	sp,sp,64
    80003b06:	8082                	ret

0000000080003b08 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b08:	711d                	addi	sp,sp,-96
    80003b0a:	ec86                	sd	ra,88(sp)
    80003b0c:	e8a2                	sd	s0,80(sp)
    80003b0e:	e4a6                	sd	s1,72(sp)
    80003b10:	e0ca                	sd	s2,64(sp)
    80003b12:	fc4e                	sd	s3,56(sp)
    80003b14:	f852                	sd	s4,48(sp)
    80003b16:	f456                	sd	s5,40(sp)
    80003b18:	f05a                	sd	s6,32(sp)
    80003b1a:	ec5e                	sd	s7,24(sp)
    80003b1c:	e862                	sd	s8,16(sp)
    80003b1e:	e466                	sd	s9,8(sp)
    80003b20:	1080                	addi	s0,sp,96
    80003b22:	84aa                	mv	s1,a0
    80003b24:	8b2e                	mv	s6,a1
    80003b26:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b28:	00054703          	lbu	a4,0(a0)
    80003b2c:	02f00793          	li	a5,47
    80003b30:	00f70e63          	beq	a4,a5,80003b4c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b34:	f89fd0ef          	jal	80001abc <myproc>
    80003b38:	15053503          	ld	a0,336(a0)
    80003b3c:	94bff0ef          	jal	80003486 <idup>
    80003b40:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b42:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003b46:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b48:	4b85                	li	s7,1
    80003b4a:	a871                	j	80003be6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003b4c:	4585                	li	a1,1
    80003b4e:	4505                	li	a0,1
    80003b50:	ef8ff0ef          	jal	80003248 <iget>
    80003b54:	8a2a                	mv	s4,a0
    80003b56:	b7f5                	j	80003b42 <namex+0x3a>
      iunlockput(ip);
    80003b58:	8552                	mv	a0,s4
    80003b5a:	b6dff0ef          	jal	800036c6 <iunlockput>
      return 0;
    80003b5e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b60:	8552                	mv	a0,s4
    80003b62:	60e6                	ld	ra,88(sp)
    80003b64:	6446                	ld	s0,80(sp)
    80003b66:	64a6                	ld	s1,72(sp)
    80003b68:	6906                	ld	s2,64(sp)
    80003b6a:	79e2                	ld	s3,56(sp)
    80003b6c:	7a42                	ld	s4,48(sp)
    80003b6e:	7aa2                	ld	s5,40(sp)
    80003b70:	7b02                	ld	s6,32(sp)
    80003b72:	6be2                	ld	s7,24(sp)
    80003b74:	6c42                	ld	s8,16(sp)
    80003b76:	6ca2                	ld	s9,8(sp)
    80003b78:	6125                	addi	sp,sp,96
    80003b7a:	8082                	ret
      iunlock(ip);
    80003b7c:	8552                	mv	a0,s4
    80003b7e:	9edff0ef          	jal	8000356a <iunlock>
      return ip;
    80003b82:	bff9                	j	80003b60 <namex+0x58>
      iunlockput(ip);
    80003b84:	8552                	mv	a0,s4
    80003b86:	b41ff0ef          	jal	800036c6 <iunlockput>
      return 0;
    80003b8a:	8a4e                	mv	s4,s3
    80003b8c:	bfd1                	j	80003b60 <namex+0x58>
  len = path - s;
    80003b8e:	40998633          	sub	a2,s3,s1
    80003b92:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b96:	099c5063          	bge	s8,s9,80003c16 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b9a:	4639                	li	a2,14
    80003b9c:	85a6                	mv	a1,s1
    80003b9e:	8556                	mv	a0,s5
    80003ba0:	95efd0ef          	jal	80000cfe <memmove>
    80003ba4:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ba6:	0004c783          	lbu	a5,0(s1)
    80003baa:	01279763          	bne	a5,s2,80003bb8 <namex+0xb0>
    path++;
    80003bae:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bb0:	0004c783          	lbu	a5,0(s1)
    80003bb4:	ff278de3          	beq	a5,s2,80003bae <namex+0xa6>
    ilock(ip);
    80003bb8:	8552                	mv	a0,s4
    80003bba:	903ff0ef          	jal	800034bc <ilock>
    if(ip->type != T_DIR){
    80003bbe:	044a1783          	lh	a5,68(s4)
    80003bc2:	f9779be3          	bne	a5,s7,80003b58 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003bc6:	000b0563          	beqz	s6,80003bd0 <namex+0xc8>
    80003bca:	0004c783          	lbu	a5,0(s1)
    80003bce:	d7dd                	beqz	a5,80003b7c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003bd0:	4601                	li	a2,0
    80003bd2:	85d6                	mv	a1,s5
    80003bd4:	8552                	mv	a0,s4
    80003bd6:	e97ff0ef          	jal	80003a6c <dirlookup>
    80003bda:	89aa                	mv	s3,a0
    80003bdc:	d545                	beqz	a0,80003b84 <namex+0x7c>
    iunlockput(ip);
    80003bde:	8552                	mv	a0,s4
    80003be0:	ae7ff0ef          	jal	800036c6 <iunlockput>
    ip = next;
    80003be4:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003be6:	0004c783          	lbu	a5,0(s1)
    80003bea:	01279763          	bne	a5,s2,80003bf8 <namex+0xf0>
    path++;
    80003bee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bf0:	0004c783          	lbu	a5,0(s1)
    80003bf4:	ff278de3          	beq	a5,s2,80003bee <namex+0xe6>
  if(*path == 0)
    80003bf8:	cb8d                	beqz	a5,80003c2a <namex+0x122>
  while(*path != '/' && *path != 0)
    80003bfa:	0004c783          	lbu	a5,0(s1)
    80003bfe:	89a6                	mv	s3,s1
  len = path - s;
    80003c00:	4c81                	li	s9,0
    80003c02:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003c04:	01278963          	beq	a5,s2,80003c16 <namex+0x10e>
    80003c08:	d3d9                	beqz	a5,80003b8e <namex+0x86>
    path++;
    80003c0a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003c0c:	0009c783          	lbu	a5,0(s3)
    80003c10:	ff279ce3          	bne	a5,s2,80003c08 <namex+0x100>
    80003c14:	bfad                	j	80003b8e <namex+0x86>
    memmove(name, s, len);
    80003c16:	2601                	sext.w	a2,a2
    80003c18:	85a6                	mv	a1,s1
    80003c1a:	8556                	mv	a0,s5
    80003c1c:	8e2fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    80003c20:	9cd6                	add	s9,s9,s5
    80003c22:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003c26:	84ce                	mv	s1,s3
    80003c28:	bfbd                	j	80003ba6 <namex+0x9e>
  if(nameiparent){
    80003c2a:	f20b0be3          	beqz	s6,80003b60 <namex+0x58>
    iput(ip);
    80003c2e:	8552                	mv	a0,s4
    80003c30:	a0fff0ef          	jal	8000363e <iput>
    return 0;
    80003c34:	4a01                	li	s4,0
    80003c36:	b72d                	j	80003b60 <namex+0x58>

0000000080003c38 <dirlink>:
{
    80003c38:	7139                	addi	sp,sp,-64
    80003c3a:	fc06                	sd	ra,56(sp)
    80003c3c:	f822                	sd	s0,48(sp)
    80003c3e:	f04a                	sd	s2,32(sp)
    80003c40:	ec4e                	sd	s3,24(sp)
    80003c42:	e852                	sd	s4,16(sp)
    80003c44:	0080                	addi	s0,sp,64
    80003c46:	892a                	mv	s2,a0
    80003c48:	8a2e                	mv	s4,a1
    80003c4a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c4c:	4601                	li	a2,0
    80003c4e:	e1fff0ef          	jal	80003a6c <dirlookup>
    80003c52:	e535                	bnez	a0,80003cbe <dirlink+0x86>
    80003c54:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c56:	04c92483          	lw	s1,76(s2)
    80003c5a:	c48d                	beqz	s1,80003c84 <dirlink+0x4c>
    80003c5c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c5e:	4741                	li	a4,16
    80003c60:	86a6                	mv	a3,s1
    80003c62:	fc040613          	addi	a2,s0,-64
    80003c66:	4581                	li	a1,0
    80003c68:	854a                	mv	a0,s2
    80003c6a:	be3ff0ef          	jal	8000384c <readi>
    80003c6e:	47c1                	li	a5,16
    80003c70:	04f51b63          	bne	a0,a5,80003cc6 <dirlink+0x8e>
    if(de.inum == 0)
    80003c74:	fc045783          	lhu	a5,-64(s0)
    80003c78:	c791                	beqz	a5,80003c84 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c7a:	24c1                	addiw	s1,s1,16
    80003c7c:	04c92783          	lw	a5,76(s2)
    80003c80:	fcf4efe3          	bltu	s1,a5,80003c5e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c84:	4639                	li	a2,14
    80003c86:	85d2                	mv	a1,s4
    80003c88:	fc240513          	addi	a0,s0,-62
    80003c8c:	918fd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    80003c90:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c94:	4741                	li	a4,16
    80003c96:	86a6                	mv	a3,s1
    80003c98:	fc040613          	addi	a2,s0,-64
    80003c9c:	4581                	li	a1,0
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	ca9ff0ef          	jal	80003948 <writei>
    80003ca4:	1541                	addi	a0,a0,-16
    80003ca6:	00a03533          	snez	a0,a0
    80003caa:	40a00533          	neg	a0,a0
    80003cae:	74a2                	ld	s1,40(sp)
}
    80003cb0:	70e2                	ld	ra,56(sp)
    80003cb2:	7442                	ld	s0,48(sp)
    80003cb4:	7902                	ld	s2,32(sp)
    80003cb6:	69e2                	ld	s3,24(sp)
    80003cb8:	6a42                	ld	s4,16(sp)
    80003cba:	6121                	addi	sp,sp,64
    80003cbc:	8082                	ret
    iput(ip);
    80003cbe:	981ff0ef          	jal	8000363e <iput>
    return -1;
    80003cc2:	557d                	li	a0,-1
    80003cc4:	b7f5                	j	80003cb0 <dirlink+0x78>
      panic("dirlink read");
    80003cc6:	00004517          	auipc	a0,0x4
    80003cca:	80250513          	addi	a0,a0,-2046 # 800074c8 <etext+0x4c8>
    80003cce:	b13fc0ef          	jal	800007e0 <panic>

0000000080003cd2 <namei>:

struct inode*
namei(char *path)
{
    80003cd2:	1101                	addi	sp,sp,-32
    80003cd4:	ec06                	sd	ra,24(sp)
    80003cd6:	e822                	sd	s0,16(sp)
    80003cd8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cda:	fe040613          	addi	a2,s0,-32
    80003cde:	4581                	li	a1,0
    80003ce0:	e29ff0ef          	jal	80003b08 <namex>
}
    80003ce4:	60e2                	ld	ra,24(sp)
    80003ce6:	6442                	ld	s0,16(sp)
    80003ce8:	6105                	addi	sp,sp,32
    80003cea:	8082                	ret

0000000080003cec <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cec:	1141                	addi	sp,sp,-16
    80003cee:	e406                	sd	ra,8(sp)
    80003cf0:	e022                	sd	s0,0(sp)
    80003cf2:	0800                	addi	s0,sp,16
    80003cf4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cf6:	4585                	li	a1,1
    80003cf8:	e11ff0ef          	jal	80003b08 <namex>
}
    80003cfc:	60a2                	ld	ra,8(sp)
    80003cfe:	6402                	ld	s0,0(sp)
    80003d00:	0141                	addi	sp,sp,16
    80003d02:	8082                	ret

0000000080003d04 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d04:	1101                	addi	sp,sp,-32
    80003d06:	ec06                	sd	ra,24(sp)
    80003d08:	e822                	sd	s0,16(sp)
    80003d0a:	e426                	sd	s1,8(sp)
    80003d0c:	e04a                	sd	s2,0(sp)
    80003d0e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d10:	0001c917          	auipc	s2,0x1c
    80003d14:	c2890913          	addi	s2,s2,-984 # 8001f938 <log>
    80003d18:	01892583          	lw	a1,24(s2)
    80003d1c:	02492503          	lw	a0,36(s2)
    80003d20:	8d0ff0ef          	jal	80002df0 <bread>
    80003d24:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d26:	02892603          	lw	a2,40(s2)
    80003d2a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d2c:	00c05f63          	blez	a2,80003d4a <write_head+0x46>
    80003d30:	0001c717          	auipc	a4,0x1c
    80003d34:	c3470713          	addi	a4,a4,-972 # 8001f964 <log+0x2c>
    80003d38:	87aa                	mv	a5,a0
    80003d3a:	060a                	slli	a2,a2,0x2
    80003d3c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d3e:	4314                	lw	a3,0(a4)
    80003d40:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d42:	0711                	addi	a4,a4,4
    80003d44:	0791                	addi	a5,a5,4
    80003d46:	fec79ce3          	bne	a5,a2,80003d3e <write_head+0x3a>
  }
  bwrite(buf);
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	97aff0ef          	jal	80002ec6 <bwrite>
  brelse(buf);
    80003d50:	8526                	mv	a0,s1
    80003d52:	9a6ff0ef          	jal	80002ef8 <brelse>
}
    80003d56:	60e2                	ld	ra,24(sp)
    80003d58:	6442                	ld	s0,16(sp)
    80003d5a:	64a2                	ld	s1,8(sp)
    80003d5c:	6902                	ld	s2,0(sp)
    80003d5e:	6105                	addi	sp,sp,32
    80003d60:	8082                	ret

0000000080003d62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d62:	0001c797          	auipc	a5,0x1c
    80003d66:	bfe7a783          	lw	a5,-1026(a5) # 8001f960 <log+0x28>
    80003d6a:	0af05e63          	blez	a5,80003e26 <install_trans+0xc4>
{
    80003d6e:	715d                	addi	sp,sp,-80
    80003d70:	e486                	sd	ra,72(sp)
    80003d72:	e0a2                	sd	s0,64(sp)
    80003d74:	fc26                	sd	s1,56(sp)
    80003d76:	f84a                	sd	s2,48(sp)
    80003d78:	f44e                	sd	s3,40(sp)
    80003d7a:	f052                	sd	s4,32(sp)
    80003d7c:	ec56                	sd	s5,24(sp)
    80003d7e:	e85a                	sd	s6,16(sp)
    80003d80:	e45e                	sd	s7,8(sp)
    80003d82:	0880                	addi	s0,sp,80
    80003d84:	8b2a                	mv	s6,a0
    80003d86:	0001ca97          	auipc	s5,0x1c
    80003d8a:	bdea8a93          	addi	s5,s5,-1058 # 8001f964 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d8e:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d90:	00003b97          	auipc	s7,0x3
    80003d94:	748b8b93          	addi	s7,s7,1864 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d98:	0001ca17          	auipc	s4,0x1c
    80003d9c:	ba0a0a13          	addi	s4,s4,-1120 # 8001f938 <log>
    80003da0:	a025                	j	80003dc8 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003da2:	000aa603          	lw	a2,0(s5)
    80003da6:	85ce                	mv	a1,s3
    80003da8:	855e                	mv	a0,s7
    80003daa:	f50fc0ef          	jal	800004fa <printf>
    80003dae:	a839                	j	80003dcc <install_trans+0x6a>
    brelse(lbuf);
    80003db0:	854a                	mv	a0,s2
    80003db2:	946ff0ef          	jal	80002ef8 <brelse>
    brelse(dbuf);
    80003db6:	8526                	mv	a0,s1
    80003db8:	940ff0ef          	jal	80002ef8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dbc:	2985                	addiw	s3,s3,1
    80003dbe:	0a91                	addi	s5,s5,4
    80003dc0:	028a2783          	lw	a5,40(s4)
    80003dc4:	04f9d663          	bge	s3,a5,80003e10 <install_trans+0xae>
    if(recovering) {
    80003dc8:	fc0b1de3          	bnez	s6,80003da2 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003dcc:	018a2583          	lw	a1,24(s4)
    80003dd0:	013585bb          	addw	a1,a1,s3
    80003dd4:	2585                	addiw	a1,a1,1
    80003dd6:	024a2503          	lw	a0,36(s4)
    80003dda:	816ff0ef          	jal	80002df0 <bread>
    80003dde:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003de0:	000aa583          	lw	a1,0(s5)
    80003de4:	024a2503          	lw	a0,36(s4)
    80003de8:	808ff0ef          	jal	80002df0 <bread>
    80003dec:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003dee:	40000613          	li	a2,1024
    80003df2:	05890593          	addi	a1,s2,88
    80003df6:	05850513          	addi	a0,a0,88
    80003dfa:	f05fc0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003dfe:	8526                	mv	a0,s1
    80003e00:	8c6ff0ef          	jal	80002ec6 <bwrite>
    if(recovering == 0)
    80003e04:	fa0b16e3          	bnez	s6,80003db0 <install_trans+0x4e>
      bunpin(dbuf);
    80003e08:	8526                	mv	a0,s1
    80003e0a:	9aaff0ef          	jal	80002fb4 <bunpin>
    80003e0e:	b74d                	j	80003db0 <install_trans+0x4e>
}
    80003e10:	60a6                	ld	ra,72(sp)
    80003e12:	6406                	ld	s0,64(sp)
    80003e14:	74e2                	ld	s1,56(sp)
    80003e16:	7942                	ld	s2,48(sp)
    80003e18:	79a2                	ld	s3,40(sp)
    80003e1a:	7a02                	ld	s4,32(sp)
    80003e1c:	6ae2                	ld	s5,24(sp)
    80003e1e:	6b42                	ld	s6,16(sp)
    80003e20:	6ba2                	ld	s7,8(sp)
    80003e22:	6161                	addi	sp,sp,80
    80003e24:	8082                	ret
    80003e26:	8082                	ret

0000000080003e28 <initlog>:
{
    80003e28:	7179                	addi	sp,sp,-48
    80003e2a:	f406                	sd	ra,40(sp)
    80003e2c:	f022                	sd	s0,32(sp)
    80003e2e:	ec26                	sd	s1,24(sp)
    80003e30:	e84a                	sd	s2,16(sp)
    80003e32:	e44e                	sd	s3,8(sp)
    80003e34:	1800                	addi	s0,sp,48
    80003e36:	892a                	mv	s2,a0
    80003e38:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e3a:	0001c497          	auipc	s1,0x1c
    80003e3e:	afe48493          	addi	s1,s1,-1282 # 8001f938 <log>
    80003e42:	00003597          	auipc	a1,0x3
    80003e46:	6b658593          	addi	a1,a1,1718 # 800074f8 <etext+0x4f8>
    80003e4a:	8526                	mv	a0,s1
    80003e4c:	d03fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003e50:	0149a583          	lw	a1,20(s3)
    80003e54:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003e56:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	f95fe0ef          	jal	80002df0 <bread>
  log.lh.n = lh->n;
    80003e60:	4d30                	lw	a2,88(a0)
    80003e62:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003e64:	00c05f63          	blez	a2,80003e82 <initlog+0x5a>
    80003e68:	87aa                	mv	a5,a0
    80003e6a:	0001c717          	auipc	a4,0x1c
    80003e6e:	afa70713          	addi	a4,a4,-1286 # 8001f964 <log+0x2c>
    80003e72:	060a                	slli	a2,a2,0x2
    80003e74:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e76:	4ff4                	lw	a3,92(a5)
    80003e78:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e7a:	0791                	addi	a5,a5,4
    80003e7c:	0711                	addi	a4,a4,4
    80003e7e:	fec79ce3          	bne	a5,a2,80003e76 <initlog+0x4e>
  brelse(buf);
    80003e82:	876ff0ef          	jal	80002ef8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e86:	4505                	li	a0,1
    80003e88:	edbff0ef          	jal	80003d62 <install_trans>
  log.lh.n = 0;
    80003e8c:	0001c797          	auipc	a5,0x1c
    80003e90:	ac07aa23          	sw	zero,-1324(a5) # 8001f960 <log+0x28>
  write_head(); // clear the log
    80003e94:	e71ff0ef          	jal	80003d04 <write_head>
}
    80003e98:	70a2                	ld	ra,40(sp)
    80003e9a:	7402                	ld	s0,32(sp)
    80003e9c:	64e2                	ld	s1,24(sp)
    80003e9e:	6942                	ld	s2,16(sp)
    80003ea0:	69a2                	ld	s3,8(sp)
    80003ea2:	6145                	addi	sp,sp,48
    80003ea4:	8082                	ret

0000000080003ea6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ea6:	1101                	addi	sp,sp,-32
    80003ea8:	ec06                	sd	ra,24(sp)
    80003eaa:	e822                	sd	s0,16(sp)
    80003eac:	e426                	sd	s1,8(sp)
    80003eae:	e04a                	sd	s2,0(sp)
    80003eb0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eb2:	0001c517          	auipc	a0,0x1c
    80003eb6:	a8650513          	addi	a0,a0,-1402 # 8001f938 <log>
    80003eba:	d15fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003ebe:	0001c497          	auipc	s1,0x1c
    80003ec2:	a7a48493          	addi	s1,s1,-1414 # 8001f938 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ec6:	4979                	li	s2,30
    80003ec8:	a029                	j	80003ed2 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003eca:	85a6                	mv	a1,s1
    80003ecc:	8526                	mv	a0,s1
    80003ece:	9f8fe0ef          	jal	800020c6 <sleep>
    if(log.committing){
    80003ed2:	509c                	lw	a5,32(s1)
    80003ed4:	fbfd                	bnez	a5,80003eca <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ed6:	4cd8                	lw	a4,28(s1)
    80003ed8:	2705                	addiw	a4,a4,1
    80003eda:	0027179b          	slliw	a5,a4,0x2
    80003ede:	9fb9                	addw	a5,a5,a4
    80003ee0:	0017979b          	slliw	a5,a5,0x1
    80003ee4:	5494                	lw	a3,40(s1)
    80003ee6:	9fb5                	addw	a5,a5,a3
    80003ee8:	00f95763          	bge	s2,a5,80003ef6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003eec:	85a6                	mv	a1,s1
    80003eee:	8526                	mv	a0,s1
    80003ef0:	9d6fe0ef          	jal	800020c6 <sleep>
    80003ef4:	bff9                	j	80003ed2 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ef6:	0001c517          	auipc	a0,0x1c
    80003efa:	a4250513          	addi	a0,a0,-1470 # 8001f938 <log>
    80003efe:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003f00:	d67fc0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003f04:	60e2                	ld	ra,24(sp)
    80003f06:	6442                	ld	s0,16(sp)
    80003f08:	64a2                	ld	s1,8(sp)
    80003f0a:	6902                	ld	s2,0(sp)
    80003f0c:	6105                	addi	sp,sp,32
    80003f0e:	8082                	ret

0000000080003f10 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f10:	7139                	addi	sp,sp,-64
    80003f12:	fc06                	sd	ra,56(sp)
    80003f14:	f822                	sd	s0,48(sp)
    80003f16:	f426                	sd	s1,40(sp)
    80003f18:	f04a                	sd	s2,32(sp)
    80003f1a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f1c:	0001c497          	auipc	s1,0x1c
    80003f20:	a1c48493          	addi	s1,s1,-1508 # 8001f938 <log>
    80003f24:	8526                	mv	a0,s1
    80003f26:	ca9fc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003f2a:	4cdc                	lw	a5,28(s1)
    80003f2c:	37fd                	addiw	a5,a5,-1
    80003f2e:	0007891b          	sext.w	s2,a5
    80003f32:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f34:	509c                	lw	a5,32(s1)
    80003f36:	ef9d                	bnez	a5,80003f74 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f38:	04091763          	bnez	s2,80003f86 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003f3c:	0001c497          	auipc	s1,0x1c
    80003f40:	9fc48493          	addi	s1,s1,-1540 # 8001f938 <log>
    80003f44:	4785                	li	a5,1
    80003f46:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f48:	8526                	mv	a0,s1
    80003f4a:	d1dfc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f4e:	549c                	lw	a5,40(s1)
    80003f50:	04f04b63          	bgtz	a5,80003fa6 <end_op+0x96>
    acquire(&log.lock);
    80003f54:	0001c497          	auipc	s1,0x1c
    80003f58:	9e448493          	addi	s1,s1,-1564 # 8001f938 <log>
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	c71fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003f62:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003f66:	8526                	mv	a0,s1
    80003f68:	9aafe0ef          	jal	80002112 <wakeup>
    release(&log.lock);
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	cf9fc0ef          	jal	80000c66 <release>
}
    80003f72:	a025                	j	80003f9a <end_op+0x8a>
    80003f74:	ec4e                	sd	s3,24(sp)
    80003f76:	e852                	sd	s4,16(sp)
    80003f78:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f7a:	00003517          	auipc	a0,0x3
    80003f7e:	58650513          	addi	a0,a0,1414 # 80007500 <etext+0x500>
    80003f82:	85ffc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003f86:	0001c497          	auipc	s1,0x1c
    80003f8a:	9b248493          	addi	s1,s1,-1614 # 8001f938 <log>
    80003f8e:	8526                	mv	a0,s1
    80003f90:	982fe0ef          	jal	80002112 <wakeup>
  release(&log.lock);
    80003f94:	8526                	mv	a0,s1
    80003f96:	cd1fc0ef          	jal	80000c66 <release>
}
    80003f9a:	70e2                	ld	ra,56(sp)
    80003f9c:	7442                	ld	s0,48(sp)
    80003f9e:	74a2                	ld	s1,40(sp)
    80003fa0:	7902                	ld	s2,32(sp)
    80003fa2:	6121                	addi	sp,sp,64
    80003fa4:	8082                	ret
    80003fa6:	ec4e                	sd	s3,24(sp)
    80003fa8:	e852                	sd	s4,16(sp)
    80003faa:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fac:	0001ca97          	auipc	s5,0x1c
    80003fb0:	9b8a8a93          	addi	s5,s5,-1608 # 8001f964 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003fb4:	0001ca17          	auipc	s4,0x1c
    80003fb8:	984a0a13          	addi	s4,s4,-1660 # 8001f938 <log>
    80003fbc:	018a2583          	lw	a1,24(s4)
    80003fc0:	012585bb          	addw	a1,a1,s2
    80003fc4:	2585                	addiw	a1,a1,1
    80003fc6:	024a2503          	lw	a0,36(s4)
    80003fca:	e27fe0ef          	jal	80002df0 <bread>
    80003fce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fd0:	000aa583          	lw	a1,0(s5)
    80003fd4:	024a2503          	lw	a0,36(s4)
    80003fd8:	e19fe0ef          	jal	80002df0 <bread>
    80003fdc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fde:	40000613          	li	a2,1024
    80003fe2:	05850593          	addi	a1,a0,88
    80003fe6:	05848513          	addi	a0,s1,88
    80003fea:	d15fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003fee:	8526                	mv	a0,s1
    80003ff0:	ed7fe0ef          	jal	80002ec6 <bwrite>
    brelse(from);
    80003ff4:	854e                	mv	a0,s3
    80003ff6:	f03fe0ef          	jal	80002ef8 <brelse>
    brelse(to);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	efdfe0ef          	jal	80002ef8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004000:	2905                	addiw	s2,s2,1
    80004002:	0a91                	addi	s5,s5,4
    80004004:	028a2783          	lw	a5,40(s4)
    80004008:	faf94ae3          	blt	s2,a5,80003fbc <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000400c:	cf9ff0ef          	jal	80003d04 <write_head>
    install_trans(0); // Now install writes to home locations
    80004010:	4501                	li	a0,0
    80004012:	d51ff0ef          	jal	80003d62 <install_trans>
    log.lh.n = 0;
    80004016:	0001c797          	auipc	a5,0x1c
    8000401a:	9407a523          	sw	zero,-1718(a5) # 8001f960 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000401e:	ce7ff0ef          	jal	80003d04 <write_head>
    80004022:	69e2                	ld	s3,24(sp)
    80004024:	6a42                	ld	s4,16(sp)
    80004026:	6aa2                	ld	s5,8(sp)
    80004028:	b735                	j	80003f54 <end_op+0x44>

000000008000402a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000402a:	1101                	addi	sp,sp,-32
    8000402c:	ec06                	sd	ra,24(sp)
    8000402e:	e822                	sd	s0,16(sp)
    80004030:	e426                	sd	s1,8(sp)
    80004032:	e04a                	sd	s2,0(sp)
    80004034:	1000                	addi	s0,sp,32
    80004036:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004038:	0001c917          	auipc	s2,0x1c
    8000403c:	90090913          	addi	s2,s2,-1792 # 8001f938 <log>
    80004040:	854a                	mv	a0,s2
    80004042:	b8dfc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004046:	02892603          	lw	a2,40(s2)
    8000404a:	47f5                	li	a5,29
    8000404c:	04c7cc63          	blt	a5,a2,800040a4 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004050:	0001c797          	auipc	a5,0x1c
    80004054:	9047a783          	lw	a5,-1788(a5) # 8001f954 <log+0x1c>
    80004058:	04f05c63          	blez	a5,800040b0 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000405c:	4781                	li	a5,0
    8000405e:	04c05f63          	blez	a2,800040bc <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004062:	44cc                	lw	a1,12(s1)
    80004064:	0001c717          	auipc	a4,0x1c
    80004068:	90070713          	addi	a4,a4,-1792 # 8001f964 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000406c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000406e:	4314                	lw	a3,0(a4)
    80004070:	04b68663          	beq	a3,a1,800040bc <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004074:	2785                	addiw	a5,a5,1
    80004076:	0711                	addi	a4,a4,4
    80004078:	fef61be3          	bne	a2,a5,8000406e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000407c:	0621                	addi	a2,a2,8
    8000407e:	060a                	slli	a2,a2,0x2
    80004080:	0001c797          	auipc	a5,0x1c
    80004084:	8b878793          	addi	a5,a5,-1864 # 8001f938 <log>
    80004088:	97b2                	add	a5,a5,a2
    8000408a:	44d8                	lw	a4,12(s1)
    8000408c:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000408e:	8526                	mv	a0,s1
    80004090:	ef1fe0ef          	jal	80002f80 <bpin>
    log.lh.n++;
    80004094:	0001c717          	auipc	a4,0x1c
    80004098:	8a470713          	addi	a4,a4,-1884 # 8001f938 <log>
    8000409c:	571c                	lw	a5,40(a4)
    8000409e:	2785                	addiw	a5,a5,1
    800040a0:	d71c                	sw	a5,40(a4)
    800040a2:	a80d                	j	800040d4 <log_write+0xaa>
    panic("too big a transaction");
    800040a4:	00003517          	auipc	a0,0x3
    800040a8:	46c50513          	addi	a0,a0,1132 # 80007510 <etext+0x510>
    800040ac:	f34fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    800040b0:	00003517          	auipc	a0,0x3
    800040b4:	47850513          	addi	a0,a0,1144 # 80007528 <etext+0x528>
    800040b8:	f28fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    800040bc:	00878693          	addi	a3,a5,8
    800040c0:	068a                	slli	a3,a3,0x2
    800040c2:	0001c717          	auipc	a4,0x1c
    800040c6:	87670713          	addi	a4,a4,-1930 # 8001f938 <log>
    800040ca:	9736                	add	a4,a4,a3
    800040cc:	44d4                	lw	a3,12(s1)
    800040ce:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800040d0:	faf60fe3          	beq	a2,a5,8000408e <log_write+0x64>
  }
  release(&log.lock);
    800040d4:	0001c517          	auipc	a0,0x1c
    800040d8:	86450513          	addi	a0,a0,-1948 # 8001f938 <log>
    800040dc:	b8bfc0ef          	jal	80000c66 <release>
}
    800040e0:	60e2                	ld	ra,24(sp)
    800040e2:	6442                	ld	s0,16(sp)
    800040e4:	64a2                	ld	s1,8(sp)
    800040e6:	6902                	ld	s2,0(sp)
    800040e8:	6105                	addi	sp,sp,32
    800040ea:	8082                	ret

00000000800040ec <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040ec:	1101                	addi	sp,sp,-32
    800040ee:	ec06                	sd	ra,24(sp)
    800040f0:	e822                	sd	s0,16(sp)
    800040f2:	e426                	sd	s1,8(sp)
    800040f4:	e04a                	sd	s2,0(sp)
    800040f6:	1000                	addi	s0,sp,32
    800040f8:	84aa                	mv	s1,a0
    800040fa:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040fc:	00003597          	auipc	a1,0x3
    80004100:	44c58593          	addi	a1,a1,1100 # 80007548 <etext+0x548>
    80004104:	0521                	addi	a0,a0,8
    80004106:	a49fc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    8000410a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000410e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004112:	0204a423          	sw	zero,40(s1)
}
    80004116:	60e2                	ld	ra,24(sp)
    80004118:	6442                	ld	s0,16(sp)
    8000411a:	64a2                	ld	s1,8(sp)
    8000411c:	6902                	ld	s2,0(sp)
    8000411e:	6105                	addi	sp,sp,32
    80004120:	8082                	ret

0000000080004122 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004122:	1101                	addi	sp,sp,-32
    80004124:	ec06                	sd	ra,24(sp)
    80004126:	e822                	sd	s0,16(sp)
    80004128:	e426                	sd	s1,8(sp)
    8000412a:	e04a                	sd	s2,0(sp)
    8000412c:	1000                	addi	s0,sp,32
    8000412e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004130:	00850913          	addi	s2,a0,8
    80004134:	854a                	mv	a0,s2
    80004136:	a99fc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    8000413a:	409c                	lw	a5,0(s1)
    8000413c:	c799                	beqz	a5,8000414a <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    8000413e:	85ca                	mv	a1,s2
    80004140:	8526                	mv	a0,s1
    80004142:	f85fd0ef          	jal	800020c6 <sleep>
  while (lk->locked) {
    80004146:	409c                	lw	a5,0(s1)
    80004148:	fbfd                	bnez	a5,8000413e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000414a:	4785                	li	a5,1
    8000414c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000414e:	96ffd0ef          	jal	80001abc <myproc>
    80004152:	591c                	lw	a5,48(a0)
    80004154:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004156:	854a                	mv	a0,s2
    80004158:	b0ffc0ef          	jal	80000c66 <release>
}
    8000415c:	60e2                	ld	ra,24(sp)
    8000415e:	6442                	ld	s0,16(sp)
    80004160:	64a2                	ld	s1,8(sp)
    80004162:	6902                	ld	s2,0(sp)
    80004164:	6105                	addi	sp,sp,32
    80004166:	8082                	ret

0000000080004168 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004168:	1101                	addi	sp,sp,-32
    8000416a:	ec06                	sd	ra,24(sp)
    8000416c:	e822                	sd	s0,16(sp)
    8000416e:	e426                	sd	s1,8(sp)
    80004170:	e04a                	sd	s2,0(sp)
    80004172:	1000                	addi	s0,sp,32
    80004174:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004176:	00850913          	addi	s2,a0,8
    8000417a:	854a                	mv	a0,s2
    8000417c:	a53fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80004180:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004184:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004188:	8526                	mv	a0,s1
    8000418a:	f89fd0ef          	jal	80002112 <wakeup>
  release(&lk->lk);
    8000418e:	854a                	mv	a0,s2
    80004190:	ad7fc0ef          	jal	80000c66 <release>
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6902                	ld	s2,0(sp)
    8000419c:	6105                	addi	sp,sp,32
    8000419e:	8082                	ret

00000000800041a0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800041a0:	7179                	addi	sp,sp,-48
    800041a2:	f406                	sd	ra,40(sp)
    800041a4:	f022                	sd	s0,32(sp)
    800041a6:	ec26                	sd	s1,24(sp)
    800041a8:	e84a                	sd	s2,16(sp)
    800041aa:	1800                	addi	s0,sp,48
    800041ac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800041ae:	00850913          	addi	s2,a0,8
    800041b2:	854a                	mv	a0,s2
    800041b4:	a1bfc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041b8:	409c                	lw	a5,0(s1)
    800041ba:	ef81                	bnez	a5,800041d2 <holdingsleep+0x32>
    800041bc:	4481                	li	s1,0
  release(&lk->lk);
    800041be:	854a                	mv	a0,s2
    800041c0:	aa7fc0ef          	jal	80000c66 <release>
  return r;
}
    800041c4:	8526                	mv	a0,s1
    800041c6:	70a2                	ld	ra,40(sp)
    800041c8:	7402                	ld	s0,32(sp)
    800041ca:	64e2                	ld	s1,24(sp)
    800041cc:	6942                	ld	s2,16(sp)
    800041ce:	6145                	addi	sp,sp,48
    800041d0:	8082                	ret
    800041d2:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041d4:	0284a983          	lw	s3,40(s1)
    800041d8:	8e5fd0ef          	jal	80001abc <myproc>
    800041dc:	5904                	lw	s1,48(a0)
    800041de:	413484b3          	sub	s1,s1,s3
    800041e2:	0014b493          	seqz	s1,s1
    800041e6:	69a2                	ld	s3,8(sp)
    800041e8:	bfd9                	j	800041be <holdingsleep+0x1e>

00000000800041ea <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041ea:	1141                	addi	sp,sp,-16
    800041ec:	e406                	sd	ra,8(sp)
    800041ee:	e022                	sd	s0,0(sp)
    800041f0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041f2:	00003597          	auipc	a1,0x3
    800041f6:	36658593          	addi	a1,a1,870 # 80007558 <etext+0x558>
    800041fa:	0001c517          	auipc	a0,0x1c
    800041fe:	88650513          	addi	a0,a0,-1914 # 8001fa80 <ftable>
    80004202:	94dfc0ef          	jal	80000b4e <initlock>
}
    80004206:	60a2                	ld	ra,8(sp)
    80004208:	6402                	ld	s0,0(sp)
    8000420a:	0141                	addi	sp,sp,16
    8000420c:	8082                	ret

000000008000420e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000420e:	1101                	addi	sp,sp,-32
    80004210:	ec06                	sd	ra,24(sp)
    80004212:	e822                	sd	s0,16(sp)
    80004214:	e426                	sd	s1,8(sp)
    80004216:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004218:	0001c517          	auipc	a0,0x1c
    8000421c:	86850513          	addi	a0,a0,-1944 # 8001fa80 <ftable>
    80004220:	9affc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004224:	0001c497          	auipc	s1,0x1c
    80004228:	87448493          	addi	s1,s1,-1932 # 8001fa98 <ftable+0x18>
    8000422c:	0001d717          	auipc	a4,0x1d
    80004230:	80c70713          	addi	a4,a4,-2036 # 80020a38 <disk>
    if(f->ref == 0){
    80004234:	40dc                	lw	a5,4(s1)
    80004236:	cf89                	beqz	a5,80004250 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004238:	02848493          	addi	s1,s1,40
    8000423c:	fee49ce3          	bne	s1,a4,80004234 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004240:	0001c517          	auipc	a0,0x1c
    80004244:	84050513          	addi	a0,a0,-1984 # 8001fa80 <ftable>
    80004248:	a1ffc0ef          	jal	80000c66 <release>
  return 0;
    8000424c:	4481                	li	s1,0
    8000424e:	a809                	j	80004260 <filealloc+0x52>
      f->ref = 1;
    80004250:	4785                	li	a5,1
    80004252:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004254:	0001c517          	auipc	a0,0x1c
    80004258:	82c50513          	addi	a0,a0,-2004 # 8001fa80 <ftable>
    8000425c:	a0bfc0ef          	jal	80000c66 <release>
}
    80004260:	8526                	mv	a0,s1
    80004262:	60e2                	ld	ra,24(sp)
    80004264:	6442                	ld	s0,16(sp)
    80004266:	64a2                	ld	s1,8(sp)
    80004268:	6105                	addi	sp,sp,32
    8000426a:	8082                	ret

000000008000426c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000426c:	1101                	addi	sp,sp,-32
    8000426e:	ec06                	sd	ra,24(sp)
    80004270:	e822                	sd	s0,16(sp)
    80004272:	e426                	sd	s1,8(sp)
    80004274:	1000                	addi	s0,sp,32
    80004276:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004278:	0001c517          	auipc	a0,0x1c
    8000427c:	80850513          	addi	a0,a0,-2040 # 8001fa80 <ftable>
    80004280:	94ffc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004284:	40dc                	lw	a5,4(s1)
    80004286:	02f05063          	blez	a5,800042a6 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000428a:	2785                	addiw	a5,a5,1
    8000428c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000428e:	0001b517          	auipc	a0,0x1b
    80004292:	7f250513          	addi	a0,a0,2034 # 8001fa80 <ftable>
    80004296:	9d1fc0ef          	jal	80000c66 <release>
  return f;
}
    8000429a:	8526                	mv	a0,s1
    8000429c:	60e2                	ld	ra,24(sp)
    8000429e:	6442                	ld	s0,16(sp)
    800042a0:	64a2                	ld	s1,8(sp)
    800042a2:	6105                	addi	sp,sp,32
    800042a4:	8082                	ret
    panic("filedup");
    800042a6:	00003517          	auipc	a0,0x3
    800042aa:	2ba50513          	addi	a0,a0,698 # 80007560 <etext+0x560>
    800042ae:	d32fc0ef          	jal	800007e0 <panic>

00000000800042b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042b2:	7139                	addi	sp,sp,-64
    800042b4:	fc06                	sd	ra,56(sp)
    800042b6:	f822                	sd	s0,48(sp)
    800042b8:	f426                	sd	s1,40(sp)
    800042ba:	0080                	addi	s0,sp,64
    800042bc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042be:	0001b517          	auipc	a0,0x1b
    800042c2:	7c250513          	addi	a0,a0,1986 # 8001fa80 <ftable>
    800042c6:	909fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    800042ca:	40dc                	lw	a5,4(s1)
    800042cc:	04f05a63          	blez	a5,80004320 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800042d0:	37fd                	addiw	a5,a5,-1
    800042d2:	0007871b          	sext.w	a4,a5
    800042d6:	c0dc                	sw	a5,4(s1)
    800042d8:	04e04e63          	bgtz	a4,80004334 <fileclose+0x82>
    800042dc:	f04a                	sd	s2,32(sp)
    800042de:	ec4e                	sd	s3,24(sp)
    800042e0:	e852                	sd	s4,16(sp)
    800042e2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042e4:	0004a903          	lw	s2,0(s1)
    800042e8:	0094ca83          	lbu	s5,9(s1)
    800042ec:	0104ba03          	ld	s4,16(s1)
    800042f0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800042f4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042f8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042fc:	0001b517          	auipc	a0,0x1b
    80004300:	78450513          	addi	a0,a0,1924 # 8001fa80 <ftable>
    80004304:	963fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004308:	4785                	li	a5,1
    8000430a:	04f90063          	beq	s2,a5,8000434a <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000430e:	3979                	addiw	s2,s2,-2
    80004310:	4785                	li	a5,1
    80004312:	0527f563          	bgeu	a5,s2,8000435c <fileclose+0xaa>
    80004316:	7902                	ld	s2,32(sp)
    80004318:	69e2                	ld	s3,24(sp)
    8000431a:	6a42                	ld	s4,16(sp)
    8000431c:	6aa2                	ld	s5,8(sp)
    8000431e:	a00d                	j	80004340 <fileclose+0x8e>
    80004320:	f04a                	sd	s2,32(sp)
    80004322:	ec4e                	sd	s3,24(sp)
    80004324:	e852                	sd	s4,16(sp)
    80004326:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004328:	00003517          	auipc	a0,0x3
    8000432c:	24050513          	addi	a0,a0,576 # 80007568 <etext+0x568>
    80004330:	cb0fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004334:	0001b517          	auipc	a0,0x1b
    80004338:	74c50513          	addi	a0,a0,1868 # 8001fa80 <ftable>
    8000433c:	92bfc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004340:	70e2                	ld	ra,56(sp)
    80004342:	7442                	ld	s0,48(sp)
    80004344:	74a2                	ld	s1,40(sp)
    80004346:	6121                	addi	sp,sp,64
    80004348:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000434a:	85d6                	mv	a1,s5
    8000434c:	8552                	mv	a0,s4
    8000434e:	336000ef          	jal	80004684 <pipeclose>
    80004352:	7902                	ld	s2,32(sp)
    80004354:	69e2                	ld	s3,24(sp)
    80004356:	6a42                	ld	s4,16(sp)
    80004358:	6aa2                	ld	s5,8(sp)
    8000435a:	b7dd                	j	80004340 <fileclose+0x8e>
    begin_op();
    8000435c:	b4bff0ef          	jal	80003ea6 <begin_op>
    iput(ff.ip);
    80004360:	854e                	mv	a0,s3
    80004362:	adcff0ef          	jal	8000363e <iput>
    end_op();
    80004366:	babff0ef          	jal	80003f10 <end_op>
    8000436a:	7902                	ld	s2,32(sp)
    8000436c:	69e2                	ld	s3,24(sp)
    8000436e:	6a42                	ld	s4,16(sp)
    80004370:	6aa2                	ld	s5,8(sp)
    80004372:	b7f9                	j	80004340 <fileclose+0x8e>

0000000080004374 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004374:	715d                	addi	sp,sp,-80
    80004376:	e486                	sd	ra,72(sp)
    80004378:	e0a2                	sd	s0,64(sp)
    8000437a:	fc26                	sd	s1,56(sp)
    8000437c:	f44e                	sd	s3,40(sp)
    8000437e:	0880                	addi	s0,sp,80
    80004380:	84aa                	mv	s1,a0
    80004382:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004384:	f38fd0ef          	jal	80001abc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004388:	409c                	lw	a5,0(s1)
    8000438a:	37f9                	addiw	a5,a5,-2
    8000438c:	4705                	li	a4,1
    8000438e:	04f76063          	bltu	a4,a5,800043ce <filestat+0x5a>
    80004392:	f84a                	sd	s2,48(sp)
    80004394:	892a                	mv	s2,a0
    ilock(f->ip);
    80004396:	6c88                	ld	a0,24(s1)
    80004398:	924ff0ef          	jal	800034bc <ilock>
    stati(f->ip, &st);
    8000439c:	fb840593          	addi	a1,s0,-72
    800043a0:	6c88                	ld	a0,24(s1)
    800043a2:	c80ff0ef          	jal	80003822 <stati>
    iunlock(f->ip);
    800043a6:	6c88                	ld	a0,24(s1)
    800043a8:	9c2ff0ef          	jal	8000356a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800043ac:	46e1                	li	a3,24
    800043ae:	fb840613          	addi	a2,s0,-72
    800043b2:	85ce                	mv	a1,s3
    800043b4:	05093503          	ld	a0,80(s2)
    800043b8:	a2afd0ef          	jal	800015e2 <copyout>
    800043bc:	41f5551b          	sraiw	a0,a0,0x1f
    800043c0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043c2:	60a6                	ld	ra,72(sp)
    800043c4:	6406                	ld	s0,64(sp)
    800043c6:	74e2                	ld	s1,56(sp)
    800043c8:	79a2                	ld	s3,40(sp)
    800043ca:	6161                	addi	sp,sp,80
    800043cc:	8082                	ret
  return -1;
    800043ce:	557d                	li	a0,-1
    800043d0:	bfcd                	j	800043c2 <filestat+0x4e>

00000000800043d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043d2:	7179                	addi	sp,sp,-48
    800043d4:	f406                	sd	ra,40(sp)
    800043d6:	f022                	sd	s0,32(sp)
    800043d8:	e84a                	sd	s2,16(sp)
    800043da:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800043dc:	00854783          	lbu	a5,8(a0)
    800043e0:	cfd1                	beqz	a5,8000447c <fileread+0xaa>
    800043e2:	ec26                	sd	s1,24(sp)
    800043e4:	e44e                	sd	s3,8(sp)
    800043e6:	84aa                	mv	s1,a0
    800043e8:	89ae                	mv	s3,a1
    800043ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800043ec:	411c                	lw	a5,0(a0)
    800043ee:	4705                	li	a4,1
    800043f0:	04e78363          	beq	a5,a4,80004436 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043f4:	470d                	li	a4,3
    800043f6:	04e78763          	beq	a5,a4,80004444 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800043fa:	4709                	li	a4,2
    800043fc:	06e79a63          	bne	a5,a4,80004470 <fileread+0x9e>
    ilock(f->ip);
    80004400:	6d08                	ld	a0,24(a0)
    80004402:	8baff0ef          	jal	800034bc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004406:	874a                	mv	a4,s2
    80004408:	5094                	lw	a3,32(s1)
    8000440a:	864e                	mv	a2,s3
    8000440c:	4585                	li	a1,1
    8000440e:	6c88                	ld	a0,24(s1)
    80004410:	c3cff0ef          	jal	8000384c <readi>
    80004414:	892a                	mv	s2,a0
    80004416:	00a05563          	blez	a0,80004420 <fileread+0x4e>
      f->off += r;
    8000441a:	509c                	lw	a5,32(s1)
    8000441c:	9fa9                	addw	a5,a5,a0
    8000441e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004420:	6c88                	ld	a0,24(s1)
    80004422:	948ff0ef          	jal	8000356a <iunlock>
    80004426:	64e2                	ld	s1,24(sp)
    80004428:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000442a:	854a                	mv	a0,s2
    8000442c:	70a2                	ld	ra,40(sp)
    8000442e:	7402                	ld	s0,32(sp)
    80004430:	6942                	ld	s2,16(sp)
    80004432:	6145                	addi	sp,sp,48
    80004434:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004436:	6908                	ld	a0,16(a0)
    80004438:	388000ef          	jal	800047c0 <piperead>
    8000443c:	892a                	mv	s2,a0
    8000443e:	64e2                	ld	s1,24(sp)
    80004440:	69a2                	ld	s3,8(sp)
    80004442:	b7e5                	j	8000442a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004444:	02451783          	lh	a5,36(a0)
    80004448:	03079693          	slli	a3,a5,0x30
    8000444c:	92c1                	srli	a3,a3,0x30
    8000444e:	4725                	li	a4,9
    80004450:	02d76863          	bltu	a4,a3,80004480 <fileread+0xae>
    80004454:	0792                	slli	a5,a5,0x4
    80004456:	0001b717          	auipc	a4,0x1b
    8000445a:	58a70713          	addi	a4,a4,1418 # 8001f9e0 <devsw>
    8000445e:	97ba                	add	a5,a5,a4
    80004460:	639c                	ld	a5,0(a5)
    80004462:	c39d                	beqz	a5,80004488 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004464:	4505                	li	a0,1
    80004466:	9782                	jalr	a5
    80004468:	892a                	mv	s2,a0
    8000446a:	64e2                	ld	s1,24(sp)
    8000446c:	69a2                	ld	s3,8(sp)
    8000446e:	bf75                	j	8000442a <fileread+0x58>
    panic("fileread");
    80004470:	00003517          	auipc	a0,0x3
    80004474:	10850513          	addi	a0,a0,264 # 80007578 <etext+0x578>
    80004478:	b68fc0ef          	jal	800007e0 <panic>
    return -1;
    8000447c:	597d                	li	s2,-1
    8000447e:	b775                	j	8000442a <fileread+0x58>
      return -1;
    80004480:	597d                	li	s2,-1
    80004482:	64e2                	ld	s1,24(sp)
    80004484:	69a2                	ld	s3,8(sp)
    80004486:	b755                	j	8000442a <fileread+0x58>
    80004488:	597d                	li	s2,-1
    8000448a:	64e2                	ld	s1,24(sp)
    8000448c:	69a2                	ld	s3,8(sp)
    8000448e:	bf71                	j	8000442a <fileread+0x58>

0000000080004490 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004490:	00954783          	lbu	a5,9(a0)
    80004494:	10078b63          	beqz	a5,800045aa <filewrite+0x11a>
{
    80004498:	715d                	addi	sp,sp,-80
    8000449a:	e486                	sd	ra,72(sp)
    8000449c:	e0a2                	sd	s0,64(sp)
    8000449e:	f84a                	sd	s2,48(sp)
    800044a0:	f052                	sd	s4,32(sp)
    800044a2:	e85a                	sd	s6,16(sp)
    800044a4:	0880                	addi	s0,sp,80
    800044a6:	892a                	mv	s2,a0
    800044a8:	8b2e                	mv	s6,a1
    800044aa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800044ac:	411c                	lw	a5,0(a0)
    800044ae:	4705                	li	a4,1
    800044b0:	02e78763          	beq	a5,a4,800044de <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044b4:	470d                	li	a4,3
    800044b6:	02e78863          	beq	a5,a4,800044e6 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044ba:	4709                	li	a4,2
    800044bc:	0ce79c63          	bne	a5,a4,80004594 <filewrite+0x104>
    800044c0:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044c2:	0ac05863          	blez	a2,80004572 <filewrite+0xe2>
    800044c6:	fc26                	sd	s1,56(sp)
    800044c8:	ec56                	sd	s5,24(sp)
    800044ca:	e45e                	sd	s7,8(sp)
    800044cc:	e062                	sd	s8,0(sp)
    int i = 0;
    800044ce:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800044d0:	6b85                	lui	s7,0x1
    800044d2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044d6:	6c05                	lui	s8,0x1
    800044d8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800044dc:	a8b5                	j	80004558 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800044de:	6908                	ld	a0,16(a0)
    800044e0:	1fc000ef          	jal	800046dc <pipewrite>
    800044e4:	a04d                	j	80004586 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044e6:	02451783          	lh	a5,36(a0)
    800044ea:	03079693          	slli	a3,a5,0x30
    800044ee:	92c1                	srli	a3,a3,0x30
    800044f0:	4725                	li	a4,9
    800044f2:	0ad76e63          	bltu	a4,a3,800045ae <filewrite+0x11e>
    800044f6:	0792                	slli	a5,a5,0x4
    800044f8:	0001b717          	auipc	a4,0x1b
    800044fc:	4e870713          	addi	a4,a4,1256 # 8001f9e0 <devsw>
    80004500:	97ba                	add	a5,a5,a4
    80004502:	679c                	ld	a5,8(a5)
    80004504:	c7dd                	beqz	a5,800045b2 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004506:	4505                	li	a0,1
    80004508:	9782                	jalr	a5
    8000450a:	a8b5                	j	80004586 <filewrite+0xf6>
      if(n1 > max)
    8000450c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004510:	997ff0ef          	jal	80003ea6 <begin_op>
      ilock(f->ip);
    80004514:	01893503          	ld	a0,24(s2)
    80004518:	fa5fe0ef          	jal	800034bc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000451c:	8756                	mv	a4,s5
    8000451e:	02092683          	lw	a3,32(s2)
    80004522:	01698633          	add	a2,s3,s6
    80004526:	4585                	li	a1,1
    80004528:	01893503          	ld	a0,24(s2)
    8000452c:	c1cff0ef          	jal	80003948 <writei>
    80004530:	84aa                	mv	s1,a0
    80004532:	00a05763          	blez	a0,80004540 <filewrite+0xb0>
        f->off += r;
    80004536:	02092783          	lw	a5,32(s2)
    8000453a:	9fa9                	addw	a5,a5,a0
    8000453c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004540:	01893503          	ld	a0,24(s2)
    80004544:	826ff0ef          	jal	8000356a <iunlock>
      end_op();
    80004548:	9c9ff0ef          	jal	80003f10 <end_op>

      if(r != n1){
    8000454c:	029a9563          	bne	s5,s1,80004576 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004550:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004554:	0149da63          	bge	s3,s4,80004568 <filewrite+0xd8>
      int n1 = n - i;
    80004558:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000455c:	0004879b          	sext.w	a5,s1
    80004560:	fafbd6e3          	bge	s7,a5,8000450c <filewrite+0x7c>
    80004564:	84e2                	mv	s1,s8
    80004566:	b75d                	j	8000450c <filewrite+0x7c>
    80004568:	74e2                	ld	s1,56(sp)
    8000456a:	6ae2                	ld	s5,24(sp)
    8000456c:	6ba2                	ld	s7,8(sp)
    8000456e:	6c02                	ld	s8,0(sp)
    80004570:	a039                	j	8000457e <filewrite+0xee>
    int i = 0;
    80004572:	4981                	li	s3,0
    80004574:	a029                	j	8000457e <filewrite+0xee>
    80004576:	74e2                	ld	s1,56(sp)
    80004578:	6ae2                	ld	s5,24(sp)
    8000457a:	6ba2                	ld	s7,8(sp)
    8000457c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000457e:	033a1c63          	bne	s4,s3,800045b6 <filewrite+0x126>
    80004582:	8552                	mv	a0,s4
    80004584:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004586:	60a6                	ld	ra,72(sp)
    80004588:	6406                	ld	s0,64(sp)
    8000458a:	7942                	ld	s2,48(sp)
    8000458c:	7a02                	ld	s4,32(sp)
    8000458e:	6b42                	ld	s6,16(sp)
    80004590:	6161                	addi	sp,sp,80
    80004592:	8082                	ret
    80004594:	fc26                	sd	s1,56(sp)
    80004596:	f44e                	sd	s3,40(sp)
    80004598:	ec56                	sd	s5,24(sp)
    8000459a:	e45e                	sd	s7,8(sp)
    8000459c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000459e:	00003517          	auipc	a0,0x3
    800045a2:	fea50513          	addi	a0,a0,-22 # 80007588 <etext+0x588>
    800045a6:	a3afc0ef          	jal	800007e0 <panic>
    return -1;
    800045aa:	557d                	li	a0,-1
}
    800045ac:	8082                	ret
      return -1;
    800045ae:	557d                	li	a0,-1
    800045b0:	bfd9                	j	80004586 <filewrite+0xf6>
    800045b2:	557d                	li	a0,-1
    800045b4:	bfc9                	j	80004586 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800045b6:	557d                	li	a0,-1
    800045b8:	79a2                	ld	s3,40(sp)
    800045ba:	b7f1                	j	80004586 <filewrite+0xf6>

00000000800045bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045bc:	7179                	addi	sp,sp,-48
    800045be:	f406                	sd	ra,40(sp)
    800045c0:	f022                	sd	s0,32(sp)
    800045c2:	ec26                	sd	s1,24(sp)
    800045c4:	e052                	sd	s4,0(sp)
    800045c6:	1800                	addi	s0,sp,48
    800045c8:	84aa                	mv	s1,a0
    800045ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045cc:	0005b023          	sd	zero,0(a1)
    800045d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045d4:	c3bff0ef          	jal	8000420e <filealloc>
    800045d8:	e088                	sd	a0,0(s1)
    800045da:	c549                	beqz	a0,80004664 <pipealloc+0xa8>
    800045dc:	c33ff0ef          	jal	8000420e <filealloc>
    800045e0:	00aa3023          	sd	a0,0(s4)
    800045e4:	cd25                	beqz	a0,8000465c <pipealloc+0xa0>
    800045e6:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045e8:	d16fc0ef          	jal	80000afe <kalloc>
    800045ec:	892a                	mv	s2,a0
    800045ee:	c12d                	beqz	a0,80004650 <pipealloc+0x94>
    800045f0:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800045f2:	4985                	li	s3,1
    800045f4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800045f8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800045fc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004600:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004604:	00003597          	auipc	a1,0x3
    80004608:	f9458593          	addi	a1,a1,-108 # 80007598 <etext+0x598>
    8000460c:	d42fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004610:	609c                	ld	a5,0(s1)
    80004612:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004616:	609c                	ld	a5,0(s1)
    80004618:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000461c:	609c                	ld	a5,0(s1)
    8000461e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004622:	609c                	ld	a5,0(s1)
    80004624:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004628:	000a3783          	ld	a5,0(s4)
    8000462c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004630:	000a3783          	ld	a5,0(s4)
    80004634:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004638:	000a3783          	ld	a5,0(s4)
    8000463c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004640:	000a3783          	ld	a5,0(s4)
    80004644:	0127b823          	sd	s2,16(a5)
  return 0;
    80004648:	4501                	li	a0,0
    8000464a:	6942                	ld	s2,16(sp)
    8000464c:	69a2                	ld	s3,8(sp)
    8000464e:	a01d                	j	80004674 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004650:	6088                	ld	a0,0(s1)
    80004652:	c119                	beqz	a0,80004658 <pipealloc+0x9c>
    80004654:	6942                	ld	s2,16(sp)
    80004656:	a029                	j	80004660 <pipealloc+0xa4>
    80004658:	6942                	ld	s2,16(sp)
    8000465a:	a029                	j	80004664 <pipealloc+0xa8>
    8000465c:	6088                	ld	a0,0(s1)
    8000465e:	c10d                	beqz	a0,80004680 <pipealloc+0xc4>
    fileclose(*f0);
    80004660:	c53ff0ef          	jal	800042b2 <fileclose>
  if(*f1)
    80004664:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004668:	557d                	li	a0,-1
  if(*f1)
    8000466a:	c789                	beqz	a5,80004674 <pipealloc+0xb8>
    fileclose(*f1);
    8000466c:	853e                	mv	a0,a5
    8000466e:	c45ff0ef          	jal	800042b2 <fileclose>
  return -1;
    80004672:	557d                	li	a0,-1
}
    80004674:	70a2                	ld	ra,40(sp)
    80004676:	7402                	ld	s0,32(sp)
    80004678:	64e2                	ld	s1,24(sp)
    8000467a:	6a02                	ld	s4,0(sp)
    8000467c:	6145                	addi	sp,sp,48
    8000467e:	8082                	ret
  return -1;
    80004680:	557d                	li	a0,-1
    80004682:	bfcd                	j	80004674 <pipealloc+0xb8>

0000000080004684 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004684:	1101                	addi	sp,sp,-32
    80004686:	ec06                	sd	ra,24(sp)
    80004688:	e822                	sd	s0,16(sp)
    8000468a:	e426                	sd	s1,8(sp)
    8000468c:	e04a                	sd	s2,0(sp)
    8000468e:	1000                	addi	s0,sp,32
    80004690:	84aa                	mv	s1,a0
    80004692:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004694:	d3afc0ef          	jal	80000bce <acquire>
  if(writable){
    80004698:	02090763          	beqz	s2,800046c6 <pipeclose+0x42>
    pi->writeopen = 0;
    8000469c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046a0:	21848513          	addi	a0,s1,536
    800046a4:	a6ffd0ef          	jal	80002112 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800046a8:	2204b783          	ld	a5,544(s1)
    800046ac:	e785                	bnez	a5,800046d4 <pipeclose+0x50>
    release(&pi->lock);
    800046ae:	8526                	mv	a0,s1
    800046b0:	db6fc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    800046b4:	8526                	mv	a0,s1
    800046b6:	b66fc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    800046ba:	60e2                	ld	ra,24(sp)
    800046bc:	6442                	ld	s0,16(sp)
    800046be:	64a2                	ld	s1,8(sp)
    800046c0:	6902                	ld	s2,0(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret
    pi->readopen = 0;
    800046c6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046ca:	21c48513          	addi	a0,s1,540
    800046ce:	a45fd0ef          	jal	80002112 <wakeup>
    800046d2:	bfd9                	j	800046a8 <pipeclose+0x24>
    release(&pi->lock);
    800046d4:	8526                	mv	a0,s1
    800046d6:	d90fc0ef          	jal	80000c66 <release>
}
    800046da:	b7c5                	j	800046ba <pipeclose+0x36>

00000000800046dc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046dc:	711d                	addi	sp,sp,-96
    800046de:	ec86                	sd	ra,88(sp)
    800046e0:	e8a2                	sd	s0,80(sp)
    800046e2:	e4a6                	sd	s1,72(sp)
    800046e4:	e0ca                	sd	s2,64(sp)
    800046e6:	fc4e                	sd	s3,56(sp)
    800046e8:	f852                	sd	s4,48(sp)
    800046ea:	f456                	sd	s5,40(sp)
    800046ec:	1080                	addi	s0,sp,96
    800046ee:	84aa                	mv	s1,a0
    800046f0:	8aae                	mv	s5,a1
    800046f2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046f4:	bc8fd0ef          	jal	80001abc <myproc>
    800046f8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800046fa:	8526                	mv	a0,s1
    800046fc:	cd2fc0ef          	jal	80000bce <acquire>
  while(i < n){
    80004700:	0b405a63          	blez	s4,800047b4 <pipewrite+0xd8>
    80004704:	f05a                	sd	s6,32(sp)
    80004706:	ec5e                	sd	s7,24(sp)
    80004708:	e862                	sd	s8,16(sp)
  int i = 0;
    8000470a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000470c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000470e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004712:	21c48b93          	addi	s7,s1,540
    80004716:	a81d                	j	8000474c <pipewrite+0x70>
      release(&pi->lock);
    80004718:	8526                	mv	a0,s1
    8000471a:	d4cfc0ef          	jal	80000c66 <release>
      return -1;
    8000471e:	597d                	li	s2,-1
    80004720:	7b02                	ld	s6,32(sp)
    80004722:	6be2                	ld	s7,24(sp)
    80004724:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004726:	854a                	mv	a0,s2
    80004728:	60e6                	ld	ra,88(sp)
    8000472a:	6446                	ld	s0,80(sp)
    8000472c:	64a6                	ld	s1,72(sp)
    8000472e:	6906                	ld	s2,64(sp)
    80004730:	79e2                	ld	s3,56(sp)
    80004732:	7a42                	ld	s4,48(sp)
    80004734:	7aa2                	ld	s5,40(sp)
    80004736:	6125                	addi	sp,sp,96
    80004738:	8082                	ret
      wakeup(&pi->nread);
    8000473a:	8562                	mv	a0,s8
    8000473c:	9d7fd0ef          	jal	80002112 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004740:	85a6                	mv	a1,s1
    80004742:	855e                	mv	a0,s7
    80004744:	983fd0ef          	jal	800020c6 <sleep>
  while(i < n){
    80004748:	05495b63          	bge	s2,s4,8000479e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000474c:	2204a783          	lw	a5,544(s1)
    80004750:	d7e1                	beqz	a5,80004718 <pipewrite+0x3c>
    80004752:	854e                	mv	a0,s3
    80004754:	babfd0ef          	jal	800022fe <killed>
    80004758:	f161                	bnez	a0,80004718 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000475a:	2184a783          	lw	a5,536(s1)
    8000475e:	21c4a703          	lw	a4,540(s1)
    80004762:	2007879b          	addiw	a5,a5,512
    80004766:	fcf70ae3          	beq	a4,a5,8000473a <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000476a:	4685                	li	a3,1
    8000476c:	01590633          	add	a2,s2,s5
    80004770:	faf40593          	addi	a1,s0,-81
    80004774:	0509b503          	ld	a0,80(s3)
    80004778:	f4ffc0ef          	jal	800016c6 <copyin>
    8000477c:	03650e63          	beq	a0,s6,800047b8 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004780:	21c4a783          	lw	a5,540(s1)
    80004784:	0017871b          	addiw	a4,a5,1
    80004788:	20e4ae23          	sw	a4,540(s1)
    8000478c:	1ff7f793          	andi	a5,a5,511
    80004790:	97a6                	add	a5,a5,s1
    80004792:	faf44703          	lbu	a4,-81(s0)
    80004796:	00e78c23          	sb	a4,24(a5)
      i++;
    8000479a:	2905                	addiw	s2,s2,1
    8000479c:	b775                	j	80004748 <pipewrite+0x6c>
    8000479e:	7b02                	ld	s6,32(sp)
    800047a0:	6be2                	ld	s7,24(sp)
    800047a2:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800047a4:	21848513          	addi	a0,s1,536
    800047a8:	96bfd0ef          	jal	80002112 <wakeup>
  release(&pi->lock);
    800047ac:	8526                	mv	a0,s1
    800047ae:	cb8fc0ef          	jal	80000c66 <release>
  return i;
    800047b2:	bf95                	j	80004726 <pipewrite+0x4a>
  int i = 0;
    800047b4:	4901                	li	s2,0
    800047b6:	b7fd                	j	800047a4 <pipewrite+0xc8>
    800047b8:	7b02                	ld	s6,32(sp)
    800047ba:	6be2                	ld	s7,24(sp)
    800047bc:	6c42                	ld	s8,16(sp)
    800047be:	b7dd                	j	800047a4 <pipewrite+0xc8>

00000000800047c0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047c0:	715d                	addi	sp,sp,-80
    800047c2:	e486                	sd	ra,72(sp)
    800047c4:	e0a2                	sd	s0,64(sp)
    800047c6:	fc26                	sd	s1,56(sp)
    800047c8:	f84a                	sd	s2,48(sp)
    800047ca:	f44e                	sd	s3,40(sp)
    800047cc:	f052                	sd	s4,32(sp)
    800047ce:	ec56                	sd	s5,24(sp)
    800047d0:	0880                	addi	s0,sp,80
    800047d2:	84aa                	mv	s1,a0
    800047d4:	892e                	mv	s2,a1
    800047d6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047d8:	ae4fd0ef          	jal	80001abc <myproc>
    800047dc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800047de:	8526                	mv	a0,s1
    800047e0:	beefc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047e4:	2184a703          	lw	a4,536(s1)
    800047e8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800047ec:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047f0:	02f71563          	bne	a4,a5,8000481a <piperead+0x5a>
    800047f4:	2244a783          	lw	a5,548(s1)
    800047f8:	cb85                	beqz	a5,80004828 <piperead+0x68>
    if(killed(pr)){
    800047fa:	8552                	mv	a0,s4
    800047fc:	b03fd0ef          	jal	800022fe <killed>
    80004800:	ed19                	bnez	a0,8000481e <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004802:	85a6                	mv	a1,s1
    80004804:	854e                	mv	a0,s3
    80004806:	8c1fd0ef          	jal	800020c6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000480a:	2184a703          	lw	a4,536(s1)
    8000480e:	21c4a783          	lw	a5,540(s1)
    80004812:	fef701e3          	beq	a4,a5,800047f4 <piperead+0x34>
    80004816:	e85a                	sd	s6,16(sp)
    80004818:	a809                	j	8000482a <piperead+0x6a>
    8000481a:	e85a                	sd	s6,16(sp)
    8000481c:	a039                	j	8000482a <piperead+0x6a>
      release(&pi->lock);
    8000481e:	8526                	mv	a0,s1
    80004820:	c46fc0ef          	jal	80000c66 <release>
      return -1;
    80004824:	59fd                	li	s3,-1
    80004826:	a8b9                	j	80004884 <piperead+0xc4>
    80004828:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000482a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000482c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000482e:	05505363          	blez	s5,80004874 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004832:	2184a783          	lw	a5,536(s1)
    80004836:	21c4a703          	lw	a4,540(s1)
    8000483a:	02f70d63          	beq	a4,a5,80004874 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    8000483e:	1ff7f793          	andi	a5,a5,511
    80004842:	97a6                	add	a5,a5,s1
    80004844:	0187c783          	lbu	a5,24(a5)
    80004848:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000484c:	4685                	li	a3,1
    8000484e:	fbf40613          	addi	a2,s0,-65
    80004852:	85ca                	mv	a1,s2
    80004854:	050a3503          	ld	a0,80(s4)
    80004858:	d8bfc0ef          	jal	800015e2 <copyout>
    8000485c:	03650e63          	beq	a0,s6,80004898 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004860:	2184a783          	lw	a5,536(s1)
    80004864:	2785                	addiw	a5,a5,1
    80004866:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000486a:	2985                	addiw	s3,s3,1
    8000486c:	0905                	addi	s2,s2,1
    8000486e:	fd3a92e3          	bne	s5,s3,80004832 <piperead+0x72>
    80004872:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004874:	21c48513          	addi	a0,s1,540
    80004878:	89bfd0ef          	jal	80002112 <wakeup>
  release(&pi->lock);
    8000487c:	8526                	mv	a0,s1
    8000487e:	be8fc0ef          	jal	80000c66 <release>
    80004882:	6b42                	ld	s6,16(sp)
  return i;
}
    80004884:	854e                	mv	a0,s3
    80004886:	60a6                	ld	ra,72(sp)
    80004888:	6406                	ld	s0,64(sp)
    8000488a:	74e2                	ld	s1,56(sp)
    8000488c:	7942                	ld	s2,48(sp)
    8000488e:	79a2                	ld	s3,40(sp)
    80004890:	7a02                	ld	s4,32(sp)
    80004892:	6ae2                	ld	s5,24(sp)
    80004894:	6161                	addi	sp,sp,80
    80004896:	8082                	ret
      if(i == 0)
    80004898:	fc099ee3          	bnez	s3,80004874 <piperead+0xb4>
        i = -1;
    8000489c:	89aa                	mv	s3,a0
    8000489e:	bfd9                	j	80004874 <piperead+0xb4>

00000000800048a0 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800048a0:	1141                	addi	sp,sp,-16
    800048a2:	e422                	sd	s0,8(sp)
    800048a4:	0800                	addi	s0,sp,16
    800048a6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800048a8:	8905                	andi	a0,a0,1
    800048aa:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800048ac:	8b89                	andi	a5,a5,2
    800048ae:	c399                	beqz	a5,800048b4 <flags2perm+0x14>
      perm |= PTE_W;
    800048b0:	00456513          	ori	a0,a0,4
    return perm;
}
    800048b4:	6422                	ld	s0,8(sp)
    800048b6:	0141                	addi	sp,sp,16
    800048b8:	8082                	ret

00000000800048ba <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048ba:	df010113          	addi	sp,sp,-528
    800048be:	20113423          	sd	ra,520(sp)
    800048c2:	20813023          	sd	s0,512(sp)
    800048c6:	ffa6                	sd	s1,504(sp)
    800048c8:	fbca                	sd	s2,496(sp)
    800048ca:	0c00                	addi	s0,sp,528
    800048cc:	892a                	mv	s2,a0
    800048ce:	dea43c23          	sd	a0,-520(s0)
    800048d2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048d6:	9e6fd0ef          	jal	80001abc <myproc>
    800048da:	84aa                	mv	s1,a0

  begin_op();
    800048dc:	dcaff0ef          	jal	80003ea6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048e0:	854a                	mv	a0,s2
    800048e2:	bf0ff0ef          	jal	80003cd2 <namei>
    800048e6:	c931                	beqz	a0,8000493a <kexec+0x80>
    800048e8:	f3d2                	sd	s4,480(sp)
    800048ea:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048ec:	bd1fe0ef          	jal	800034bc <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048f0:	04000713          	li	a4,64
    800048f4:	4681                	li	a3,0
    800048f6:	e5040613          	addi	a2,s0,-432
    800048fa:	4581                	li	a1,0
    800048fc:	8552                	mv	a0,s4
    800048fe:	f4ffe0ef          	jal	8000384c <readi>
    80004902:	04000793          	li	a5,64
    80004906:	00f51a63          	bne	a0,a5,8000491a <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000490a:	e5042703          	lw	a4,-432(s0)
    8000490e:	464c47b7          	lui	a5,0x464c4
    80004912:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004916:	02f70663          	beq	a4,a5,80004942 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000491a:	8552                	mv	a0,s4
    8000491c:	dabfe0ef          	jal	800036c6 <iunlockput>
    end_op();
    80004920:	df0ff0ef          	jal	80003f10 <end_op>
  }
  return -1;
    80004924:	557d                	li	a0,-1
    80004926:	7a1e                	ld	s4,480(sp)
}
    80004928:	20813083          	ld	ra,520(sp)
    8000492c:	20013403          	ld	s0,512(sp)
    80004930:	74fe                	ld	s1,504(sp)
    80004932:	795e                	ld	s2,496(sp)
    80004934:	21010113          	addi	sp,sp,528
    80004938:	8082                	ret
    end_op();
    8000493a:	dd6ff0ef          	jal	80003f10 <end_op>
    return -1;
    8000493e:	557d                	li	a0,-1
    80004940:	b7e5                	j	80004928 <kexec+0x6e>
    80004942:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004944:	8526                	mv	a0,s1
    80004946:	a7cfd0ef          	jal	80001bc2 <proc_pagetable>
    8000494a:	8b2a                	mv	s6,a0
    8000494c:	2c050b63          	beqz	a0,80004c22 <kexec+0x368>
    80004950:	f7ce                	sd	s3,488(sp)
    80004952:	efd6                	sd	s5,472(sp)
    80004954:	e7de                	sd	s7,456(sp)
    80004956:	e3e2                	sd	s8,448(sp)
    80004958:	ff66                	sd	s9,440(sp)
    8000495a:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000495c:	e7042d03          	lw	s10,-400(s0)
    80004960:	e8845783          	lhu	a5,-376(s0)
    80004964:	12078963          	beqz	a5,80004a96 <kexec+0x1dc>
    80004968:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000496a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000496c:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000496e:	6c85                	lui	s9,0x1
    80004970:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004974:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004978:	6a85                	lui	s5,0x1
    8000497a:	a085                	j	800049da <kexec+0x120>
      panic("loadseg: address should exist");
    8000497c:	00003517          	auipc	a0,0x3
    80004980:	c2450513          	addi	a0,a0,-988 # 800075a0 <etext+0x5a0>
    80004984:	e5dfb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004988:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000498a:	8726                	mv	a4,s1
    8000498c:	012c06bb          	addw	a3,s8,s2
    80004990:	4581                	li	a1,0
    80004992:	8552                	mv	a0,s4
    80004994:	eb9fe0ef          	jal	8000384c <readi>
    80004998:	2501                	sext.w	a0,a0
    8000499a:	24a49a63          	bne	s1,a0,80004bee <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000499e:	012a893b          	addw	s2,s5,s2
    800049a2:	03397363          	bgeu	s2,s3,800049c8 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800049a6:	02091593          	slli	a1,s2,0x20
    800049aa:	9181                	srli	a1,a1,0x20
    800049ac:	95de                	add	a1,a1,s7
    800049ae:	855a                	mv	a0,s6
    800049b0:	e00fc0ef          	jal	80000fb0 <walkaddr>
    800049b4:	862a                	mv	a2,a0
    if(pa == 0)
    800049b6:	d179                	beqz	a0,8000497c <kexec+0xc2>
    if(sz - i < PGSIZE)
    800049b8:	412984bb          	subw	s1,s3,s2
    800049bc:	0004879b          	sext.w	a5,s1
    800049c0:	fcfcf4e3          	bgeu	s9,a5,80004988 <kexec+0xce>
    800049c4:	84d6                	mv	s1,s5
    800049c6:	b7c9                	j	80004988 <kexec+0xce>
    sz = sz1;
    800049c8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049cc:	2d85                	addiw	s11,s11,1
    800049ce:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800049d2:	e8845783          	lhu	a5,-376(s0)
    800049d6:	08fdd063          	bge	s11,a5,80004a56 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049da:	2d01                	sext.w	s10,s10
    800049dc:	03800713          	li	a4,56
    800049e0:	86ea                	mv	a3,s10
    800049e2:	e1840613          	addi	a2,s0,-488
    800049e6:	4581                	li	a1,0
    800049e8:	8552                	mv	a0,s4
    800049ea:	e63fe0ef          	jal	8000384c <readi>
    800049ee:	03800793          	li	a5,56
    800049f2:	1cf51663          	bne	a0,a5,80004bbe <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800049f6:	e1842783          	lw	a5,-488(s0)
    800049fa:	4705                	li	a4,1
    800049fc:	fce798e3          	bne	a5,a4,800049cc <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004a00:	e4043483          	ld	s1,-448(s0)
    80004a04:	e3843783          	ld	a5,-456(s0)
    80004a08:	1af4ef63          	bltu	s1,a5,80004bc6 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a0c:	e2843783          	ld	a5,-472(s0)
    80004a10:	94be                	add	s1,s1,a5
    80004a12:	1af4ee63          	bltu	s1,a5,80004bce <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004a16:	df043703          	ld	a4,-528(s0)
    80004a1a:	8ff9                	and	a5,a5,a4
    80004a1c:	1a079d63          	bnez	a5,80004bd6 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a20:	e1c42503          	lw	a0,-484(s0)
    80004a24:	e7dff0ef          	jal	800048a0 <flags2perm>
    80004a28:	86aa                	mv	a3,a0
    80004a2a:	8626                	mv	a2,s1
    80004a2c:	85ca                	mv	a1,s2
    80004a2e:	855a                	mv	a0,s6
    80004a30:	859fc0ef          	jal	80001288 <uvmalloc>
    80004a34:	e0a43423          	sd	a0,-504(s0)
    80004a38:	1a050363          	beqz	a0,80004bde <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a3c:	e2843b83          	ld	s7,-472(s0)
    80004a40:	e2042c03          	lw	s8,-480(s0)
    80004a44:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a48:	00098463          	beqz	s3,80004a50 <kexec+0x196>
    80004a4c:	4901                	li	s2,0
    80004a4e:	bfa1                	j	800049a6 <kexec+0xec>
    sz = sz1;
    80004a50:	e0843903          	ld	s2,-504(s0)
    80004a54:	bfa5                	j	800049cc <kexec+0x112>
    80004a56:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004a58:	8552                	mv	a0,s4
    80004a5a:	c6dfe0ef          	jal	800036c6 <iunlockput>
  end_op();
    80004a5e:	cb2ff0ef          	jal	80003f10 <end_op>
  p = myproc();
    80004a62:	85afd0ef          	jal	80001abc <myproc>
    80004a66:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a68:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004a6c:	6985                	lui	s3,0x1
    80004a6e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a70:	99ca                	add	s3,s3,s2
    80004a72:	77fd                	lui	a5,0xfffff
    80004a74:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a78:	4691                	li	a3,4
    80004a7a:	6609                	lui	a2,0x2
    80004a7c:	964e                	add	a2,a2,s3
    80004a7e:	85ce                	mv	a1,s3
    80004a80:	855a                	mv	a0,s6
    80004a82:	807fc0ef          	jal	80001288 <uvmalloc>
    80004a86:	892a                	mv	s2,a0
    80004a88:	e0a43423          	sd	a0,-504(s0)
    80004a8c:	e519                	bnez	a0,80004a9a <kexec+0x1e0>
  if(pagetable)
    80004a8e:	e1343423          	sd	s3,-504(s0)
    80004a92:	4a01                	li	s4,0
    80004a94:	aab1                	j	80004bf0 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a96:	4901                	li	s2,0
    80004a98:	b7c1                	j	80004a58 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a9a:	75f9                	lui	a1,0xffffe
    80004a9c:	95aa                	add	a1,a1,a0
    80004a9e:	855a                	mv	a0,s6
    80004aa0:	9bffc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004aa4:	7bfd                	lui	s7,0xfffff
    80004aa6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004aa8:	e0043783          	ld	a5,-512(s0)
    80004aac:	6388                	ld	a0,0(a5)
    80004aae:	cd39                	beqz	a0,80004b0c <kexec+0x252>
    80004ab0:	e9040993          	addi	s3,s0,-368
    80004ab4:	f9040c13          	addi	s8,s0,-112
    80004ab8:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004aba:	b58fc0ef          	jal	80000e12 <strlen>
    80004abe:	0015079b          	addiw	a5,a0,1
    80004ac2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ac6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004aca:	11796e63          	bltu	s2,s7,80004be6 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ace:	e0043d03          	ld	s10,-512(s0)
    80004ad2:	000d3a03          	ld	s4,0(s10)
    80004ad6:	8552                	mv	a0,s4
    80004ad8:	b3afc0ef          	jal	80000e12 <strlen>
    80004adc:	0015069b          	addiw	a3,a0,1
    80004ae0:	8652                	mv	a2,s4
    80004ae2:	85ca                	mv	a1,s2
    80004ae4:	855a                	mv	a0,s6
    80004ae6:	afdfc0ef          	jal	800015e2 <copyout>
    80004aea:	10054063          	bltz	a0,80004bea <kexec+0x330>
    ustack[argc] = sp;
    80004aee:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004af2:	0485                	addi	s1,s1,1
    80004af4:	008d0793          	addi	a5,s10,8
    80004af8:	e0f43023          	sd	a5,-512(s0)
    80004afc:	008d3503          	ld	a0,8(s10)
    80004b00:	c909                	beqz	a0,80004b12 <kexec+0x258>
    if(argc >= MAXARG)
    80004b02:	09a1                	addi	s3,s3,8
    80004b04:	fb899be3          	bne	s3,s8,80004aba <kexec+0x200>
  ip = 0;
    80004b08:	4a01                	li	s4,0
    80004b0a:	a0dd                	j	80004bf0 <kexec+0x336>
  sp = sz;
    80004b0c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004b10:	4481                	li	s1,0
  ustack[argc] = 0;
    80004b12:	00349793          	slli	a5,s1,0x3
    80004b16:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde418>
    80004b1a:	97a2                	add	a5,a5,s0
    80004b1c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b20:	00148693          	addi	a3,s1,1
    80004b24:	068e                	slli	a3,a3,0x3
    80004b26:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b2a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b2e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004b32:	f5796ee3          	bltu	s2,s7,80004a8e <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b36:	e9040613          	addi	a2,s0,-368
    80004b3a:	85ca                	mv	a1,s2
    80004b3c:	855a                	mv	a0,s6
    80004b3e:	aa5fc0ef          	jal	800015e2 <copyout>
    80004b42:	0e054263          	bltz	a0,80004c26 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004b46:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b4a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b4e:	df843783          	ld	a5,-520(s0)
    80004b52:	0007c703          	lbu	a4,0(a5)
    80004b56:	cf11                	beqz	a4,80004b72 <kexec+0x2b8>
    80004b58:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b5a:	02f00693          	li	a3,47
    80004b5e:	a039                	j	80004b6c <kexec+0x2b2>
      last = s+1;
    80004b60:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004b64:	0785                	addi	a5,a5,1
    80004b66:	fff7c703          	lbu	a4,-1(a5)
    80004b6a:	c701                	beqz	a4,80004b72 <kexec+0x2b8>
    if(*s == '/')
    80004b6c:	fed71ce3          	bne	a4,a3,80004b64 <kexec+0x2aa>
    80004b70:	bfc5                	j	80004b60 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b72:	4641                	li	a2,16
    80004b74:	df843583          	ld	a1,-520(s0)
    80004b78:	158a8513          	addi	a0,s5,344
    80004b7c:	a64fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b80:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b84:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b88:	e0843783          	ld	a5,-504(s0)
    80004b8c:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b90:	058ab783          	ld	a5,88(s5)
    80004b94:	e6843703          	ld	a4,-408(s0)
    80004b98:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b9a:	058ab783          	ld	a5,88(s5)
    80004b9e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ba2:	85e6                	mv	a1,s9
    80004ba4:	8a2fd0ef          	jal	80001c46 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ba8:	0004851b          	sext.w	a0,s1
    80004bac:	79be                	ld	s3,488(sp)
    80004bae:	7a1e                	ld	s4,480(sp)
    80004bb0:	6afe                	ld	s5,472(sp)
    80004bb2:	6b5e                	ld	s6,464(sp)
    80004bb4:	6bbe                	ld	s7,456(sp)
    80004bb6:	6c1e                	ld	s8,448(sp)
    80004bb8:	7cfa                	ld	s9,440(sp)
    80004bba:	7d5a                	ld	s10,432(sp)
    80004bbc:	b3b5                	j	80004928 <kexec+0x6e>
    80004bbe:	e1243423          	sd	s2,-504(s0)
    80004bc2:	7dba                	ld	s11,424(sp)
    80004bc4:	a035                	j	80004bf0 <kexec+0x336>
    80004bc6:	e1243423          	sd	s2,-504(s0)
    80004bca:	7dba                	ld	s11,424(sp)
    80004bcc:	a015                	j	80004bf0 <kexec+0x336>
    80004bce:	e1243423          	sd	s2,-504(s0)
    80004bd2:	7dba                	ld	s11,424(sp)
    80004bd4:	a831                	j	80004bf0 <kexec+0x336>
    80004bd6:	e1243423          	sd	s2,-504(s0)
    80004bda:	7dba                	ld	s11,424(sp)
    80004bdc:	a811                	j	80004bf0 <kexec+0x336>
    80004bde:	e1243423          	sd	s2,-504(s0)
    80004be2:	7dba                	ld	s11,424(sp)
    80004be4:	a031                	j	80004bf0 <kexec+0x336>
  ip = 0;
    80004be6:	4a01                	li	s4,0
    80004be8:	a021                	j	80004bf0 <kexec+0x336>
    80004bea:	4a01                	li	s4,0
  if(pagetable)
    80004bec:	a011                	j	80004bf0 <kexec+0x336>
    80004bee:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004bf0:	e0843583          	ld	a1,-504(s0)
    80004bf4:	855a                	mv	a0,s6
    80004bf6:	850fd0ef          	jal	80001c46 <proc_freepagetable>
  return -1;
    80004bfa:	557d                	li	a0,-1
  if(ip){
    80004bfc:	000a1b63          	bnez	s4,80004c12 <kexec+0x358>
    80004c00:	79be                	ld	s3,488(sp)
    80004c02:	7a1e                	ld	s4,480(sp)
    80004c04:	6afe                	ld	s5,472(sp)
    80004c06:	6b5e                	ld	s6,464(sp)
    80004c08:	6bbe                	ld	s7,456(sp)
    80004c0a:	6c1e                	ld	s8,448(sp)
    80004c0c:	7cfa                	ld	s9,440(sp)
    80004c0e:	7d5a                	ld	s10,432(sp)
    80004c10:	bb21                	j	80004928 <kexec+0x6e>
    80004c12:	79be                	ld	s3,488(sp)
    80004c14:	6afe                	ld	s5,472(sp)
    80004c16:	6b5e                	ld	s6,464(sp)
    80004c18:	6bbe                	ld	s7,456(sp)
    80004c1a:	6c1e                	ld	s8,448(sp)
    80004c1c:	7cfa                	ld	s9,440(sp)
    80004c1e:	7d5a                	ld	s10,432(sp)
    80004c20:	b9ed                	j	8000491a <kexec+0x60>
    80004c22:	6b5e                	ld	s6,464(sp)
    80004c24:	b9dd                	j	8000491a <kexec+0x60>
  sz = sz1;
    80004c26:	e0843983          	ld	s3,-504(s0)
    80004c2a:	b595                	j	80004a8e <kexec+0x1d4>

0000000080004c2c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c2c:	7179                	addi	sp,sp,-48
    80004c2e:	f406                	sd	ra,40(sp)
    80004c30:	f022                	sd	s0,32(sp)
    80004c32:	ec26                	sd	s1,24(sp)
    80004c34:	e84a                	sd	s2,16(sp)
    80004c36:	1800                	addi	s0,sp,48
    80004c38:	892e                	mv	s2,a1
    80004c3a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c3c:	fdc40593          	addi	a1,s0,-36
    80004c40:	e17fd0ef          	jal	80002a56 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c44:	fdc42703          	lw	a4,-36(s0)
    80004c48:	47bd                	li	a5,15
    80004c4a:	02e7e963          	bltu	a5,a4,80004c7c <argfd+0x50>
    80004c4e:	e6ffc0ef          	jal	80001abc <myproc>
    80004c52:	fdc42703          	lw	a4,-36(s0)
    80004c56:	01a70793          	addi	a5,a4,26
    80004c5a:	078e                	slli	a5,a5,0x3
    80004c5c:	953e                	add	a0,a0,a5
    80004c5e:	611c                	ld	a5,0(a0)
    80004c60:	c385                	beqz	a5,80004c80 <argfd+0x54>
    return -1;
  if(pfd)
    80004c62:	00090463          	beqz	s2,80004c6a <argfd+0x3e>
    *pfd = fd;
    80004c66:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c6a:	4501                	li	a0,0
  if(pf)
    80004c6c:	c091                	beqz	s1,80004c70 <argfd+0x44>
    *pf = f;
    80004c6e:	e09c                	sd	a5,0(s1)
}
    80004c70:	70a2                	ld	ra,40(sp)
    80004c72:	7402                	ld	s0,32(sp)
    80004c74:	64e2                	ld	s1,24(sp)
    80004c76:	6942                	ld	s2,16(sp)
    80004c78:	6145                	addi	sp,sp,48
    80004c7a:	8082                	ret
    return -1;
    80004c7c:	557d                	li	a0,-1
    80004c7e:	bfcd                	j	80004c70 <argfd+0x44>
    80004c80:	557d                	li	a0,-1
    80004c82:	b7fd                	j	80004c70 <argfd+0x44>

0000000080004c84 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c84:	1101                	addi	sp,sp,-32
    80004c86:	ec06                	sd	ra,24(sp)
    80004c88:	e822                	sd	s0,16(sp)
    80004c8a:	e426                	sd	s1,8(sp)
    80004c8c:	1000                	addi	s0,sp,32
    80004c8e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c90:	e2dfc0ef          	jal	80001abc <myproc>
    80004c94:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c96:	0d050793          	addi	a5,a0,208
    80004c9a:	4501                	li	a0,0
    80004c9c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c9e:	6398                	ld	a4,0(a5)
    80004ca0:	cb19                	beqz	a4,80004cb6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ca2:	2505                	addiw	a0,a0,1
    80004ca4:	07a1                	addi	a5,a5,8
    80004ca6:	fed51ce3          	bne	a0,a3,80004c9e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004caa:	557d                	li	a0,-1
}
    80004cac:	60e2                	ld	ra,24(sp)
    80004cae:	6442                	ld	s0,16(sp)
    80004cb0:	64a2                	ld	s1,8(sp)
    80004cb2:	6105                	addi	sp,sp,32
    80004cb4:	8082                	ret
      p->ofile[fd] = f;
    80004cb6:	01a50793          	addi	a5,a0,26
    80004cba:	078e                	slli	a5,a5,0x3
    80004cbc:	963e                	add	a2,a2,a5
    80004cbe:	e204                	sd	s1,0(a2)
      return fd;
    80004cc0:	b7f5                	j	80004cac <fdalloc+0x28>

0000000080004cc2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004cc2:	715d                	addi	sp,sp,-80
    80004cc4:	e486                	sd	ra,72(sp)
    80004cc6:	e0a2                	sd	s0,64(sp)
    80004cc8:	fc26                	sd	s1,56(sp)
    80004cca:	f84a                	sd	s2,48(sp)
    80004ccc:	f44e                	sd	s3,40(sp)
    80004cce:	ec56                	sd	s5,24(sp)
    80004cd0:	e85a                	sd	s6,16(sp)
    80004cd2:	0880                	addi	s0,sp,80
    80004cd4:	8b2e                	mv	s6,a1
    80004cd6:	89b2                	mv	s3,a2
    80004cd8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004cda:	fb040593          	addi	a1,s0,-80
    80004cde:	80eff0ef          	jal	80003cec <nameiparent>
    80004ce2:	84aa                	mv	s1,a0
    80004ce4:	10050a63          	beqz	a0,80004df8 <create+0x136>
    return 0;

  ilock(dp);
    80004ce8:	fd4fe0ef          	jal	800034bc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cec:	4601                	li	a2,0
    80004cee:	fb040593          	addi	a1,s0,-80
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	d79fe0ef          	jal	80003a6c <dirlookup>
    80004cf8:	8aaa                	mv	s5,a0
    80004cfa:	c129                	beqz	a0,80004d3c <create+0x7a>
    iunlockput(dp);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	9c9fe0ef          	jal	800036c6 <iunlockput>
    ilock(ip);
    80004d02:	8556                	mv	a0,s5
    80004d04:	fb8fe0ef          	jal	800034bc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d08:	4789                	li	a5,2
    80004d0a:	02fb1463          	bne	s6,a5,80004d32 <create+0x70>
    80004d0e:	044ad783          	lhu	a5,68(s5)
    80004d12:	37f9                	addiw	a5,a5,-2
    80004d14:	17c2                	slli	a5,a5,0x30
    80004d16:	93c1                	srli	a5,a5,0x30
    80004d18:	4705                	li	a4,1
    80004d1a:	00f76c63          	bltu	a4,a5,80004d32 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d1e:	8556                	mv	a0,s5
    80004d20:	60a6                	ld	ra,72(sp)
    80004d22:	6406                	ld	s0,64(sp)
    80004d24:	74e2                	ld	s1,56(sp)
    80004d26:	7942                	ld	s2,48(sp)
    80004d28:	79a2                	ld	s3,40(sp)
    80004d2a:	6ae2                	ld	s5,24(sp)
    80004d2c:	6b42                	ld	s6,16(sp)
    80004d2e:	6161                	addi	sp,sp,80
    80004d30:	8082                	ret
    iunlockput(ip);
    80004d32:	8556                	mv	a0,s5
    80004d34:	993fe0ef          	jal	800036c6 <iunlockput>
    return 0;
    80004d38:	4a81                	li	s5,0
    80004d3a:	b7d5                	j	80004d1e <create+0x5c>
    80004d3c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d3e:	85da                	mv	a1,s6
    80004d40:	4088                	lw	a0,0(s1)
    80004d42:	e0afe0ef          	jal	8000334c <ialloc>
    80004d46:	8a2a                	mv	s4,a0
    80004d48:	cd15                	beqz	a0,80004d84 <create+0xc2>
  ilock(ip);
    80004d4a:	f72fe0ef          	jal	800034bc <ilock>
  ip->major = major;
    80004d4e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004d52:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004d56:	4905                	li	s2,1
    80004d58:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004d5c:	8552                	mv	a0,s4
    80004d5e:	eaafe0ef          	jal	80003408 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d62:	032b0763          	beq	s6,s2,80004d90 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d66:	004a2603          	lw	a2,4(s4)
    80004d6a:	fb040593          	addi	a1,s0,-80
    80004d6e:	8526                	mv	a0,s1
    80004d70:	ec9fe0ef          	jal	80003c38 <dirlink>
    80004d74:	06054563          	bltz	a0,80004dde <create+0x11c>
  iunlockput(dp);
    80004d78:	8526                	mv	a0,s1
    80004d7a:	94dfe0ef          	jal	800036c6 <iunlockput>
  return ip;
    80004d7e:	8ad2                	mv	s5,s4
    80004d80:	7a02                	ld	s4,32(sp)
    80004d82:	bf71                	j	80004d1e <create+0x5c>
    iunlockput(dp);
    80004d84:	8526                	mv	a0,s1
    80004d86:	941fe0ef          	jal	800036c6 <iunlockput>
    return 0;
    80004d8a:	8ad2                	mv	s5,s4
    80004d8c:	7a02                	ld	s4,32(sp)
    80004d8e:	bf41                	j	80004d1e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d90:	004a2603          	lw	a2,4(s4)
    80004d94:	00003597          	auipc	a1,0x3
    80004d98:	82c58593          	addi	a1,a1,-2004 # 800075c0 <etext+0x5c0>
    80004d9c:	8552                	mv	a0,s4
    80004d9e:	e9bfe0ef          	jal	80003c38 <dirlink>
    80004da2:	02054e63          	bltz	a0,80004dde <create+0x11c>
    80004da6:	40d0                	lw	a2,4(s1)
    80004da8:	00003597          	auipc	a1,0x3
    80004dac:	82058593          	addi	a1,a1,-2016 # 800075c8 <etext+0x5c8>
    80004db0:	8552                	mv	a0,s4
    80004db2:	e87fe0ef          	jal	80003c38 <dirlink>
    80004db6:	02054463          	bltz	a0,80004dde <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004dba:	004a2603          	lw	a2,4(s4)
    80004dbe:	fb040593          	addi	a1,s0,-80
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	e75fe0ef          	jal	80003c38 <dirlink>
    80004dc8:	00054b63          	bltz	a0,80004dde <create+0x11c>
    dp->nlink++;  // for ".."
    80004dcc:	04a4d783          	lhu	a5,74(s1)
    80004dd0:	2785                	addiw	a5,a5,1
    80004dd2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	e30fe0ef          	jal	80003408 <iupdate>
    80004ddc:	bf71                	j	80004d78 <create+0xb6>
  ip->nlink = 0;
    80004dde:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004de2:	8552                	mv	a0,s4
    80004de4:	e24fe0ef          	jal	80003408 <iupdate>
  iunlockput(ip);
    80004de8:	8552                	mv	a0,s4
    80004dea:	8ddfe0ef          	jal	800036c6 <iunlockput>
  iunlockput(dp);
    80004dee:	8526                	mv	a0,s1
    80004df0:	8d7fe0ef          	jal	800036c6 <iunlockput>
  return 0;
    80004df4:	7a02                	ld	s4,32(sp)
    80004df6:	b725                	j	80004d1e <create+0x5c>
    return 0;
    80004df8:	8aaa                	mv	s5,a0
    80004dfa:	b715                	j	80004d1e <create+0x5c>

0000000080004dfc <sys_dup>:
{
    80004dfc:	7179                	addi	sp,sp,-48
    80004dfe:	f406                	sd	ra,40(sp)
    80004e00:	f022                	sd	s0,32(sp)
    80004e02:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e04:	fd840613          	addi	a2,s0,-40
    80004e08:	4581                	li	a1,0
    80004e0a:	4501                	li	a0,0
    80004e0c:	e21ff0ef          	jal	80004c2c <argfd>
    return -1;
    80004e10:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e12:	02054363          	bltz	a0,80004e38 <sys_dup+0x3c>
    80004e16:	ec26                	sd	s1,24(sp)
    80004e18:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e1a:	fd843903          	ld	s2,-40(s0)
    80004e1e:	854a                	mv	a0,s2
    80004e20:	e65ff0ef          	jal	80004c84 <fdalloc>
    80004e24:	84aa                	mv	s1,a0
    return -1;
    80004e26:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e28:	00054d63          	bltz	a0,80004e42 <sys_dup+0x46>
  filedup(f);
    80004e2c:	854a                	mv	a0,s2
    80004e2e:	c3eff0ef          	jal	8000426c <filedup>
  return fd;
    80004e32:	87a6                	mv	a5,s1
    80004e34:	64e2                	ld	s1,24(sp)
    80004e36:	6942                	ld	s2,16(sp)
}
    80004e38:	853e                	mv	a0,a5
    80004e3a:	70a2                	ld	ra,40(sp)
    80004e3c:	7402                	ld	s0,32(sp)
    80004e3e:	6145                	addi	sp,sp,48
    80004e40:	8082                	ret
    80004e42:	64e2                	ld	s1,24(sp)
    80004e44:	6942                	ld	s2,16(sp)
    80004e46:	bfcd                	j	80004e38 <sys_dup+0x3c>

0000000080004e48 <sys_read>:
{
    80004e48:	7179                	addi	sp,sp,-48
    80004e4a:	f406                	sd	ra,40(sp)
    80004e4c:	f022                	sd	s0,32(sp)
    80004e4e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e50:	fd840593          	addi	a1,s0,-40
    80004e54:	4505                	li	a0,1
    80004e56:	c1dfd0ef          	jal	80002a72 <argaddr>
  argint(2, &n);
    80004e5a:	fe440593          	addi	a1,s0,-28
    80004e5e:	4509                	li	a0,2
    80004e60:	bf7fd0ef          	jal	80002a56 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e64:	fe840613          	addi	a2,s0,-24
    80004e68:	4581                	li	a1,0
    80004e6a:	4501                	li	a0,0
    80004e6c:	dc1ff0ef          	jal	80004c2c <argfd>
    80004e70:	87aa                	mv	a5,a0
    return -1;
    80004e72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e74:	0007ca63          	bltz	a5,80004e88 <sys_read+0x40>
  return fileread(f, p, n);
    80004e78:	fe442603          	lw	a2,-28(s0)
    80004e7c:	fd843583          	ld	a1,-40(s0)
    80004e80:	fe843503          	ld	a0,-24(s0)
    80004e84:	d4eff0ef          	jal	800043d2 <fileread>
}
    80004e88:	70a2                	ld	ra,40(sp)
    80004e8a:	7402                	ld	s0,32(sp)
    80004e8c:	6145                	addi	sp,sp,48
    80004e8e:	8082                	ret

0000000080004e90 <sys_write>:
{
    80004e90:	7179                	addi	sp,sp,-48
    80004e92:	f406                	sd	ra,40(sp)
    80004e94:	f022                	sd	s0,32(sp)
    80004e96:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e98:	fd840593          	addi	a1,s0,-40
    80004e9c:	4505                	li	a0,1
    80004e9e:	bd5fd0ef          	jal	80002a72 <argaddr>
  argint(2, &n);
    80004ea2:	fe440593          	addi	a1,s0,-28
    80004ea6:	4509                	li	a0,2
    80004ea8:	baffd0ef          	jal	80002a56 <argint>
  if(argfd(0, 0, &f) < 0)
    80004eac:	fe840613          	addi	a2,s0,-24
    80004eb0:	4581                	li	a1,0
    80004eb2:	4501                	li	a0,0
    80004eb4:	d79ff0ef          	jal	80004c2c <argfd>
    80004eb8:	87aa                	mv	a5,a0
    return -1;
    80004eba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ebc:	0007ca63          	bltz	a5,80004ed0 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ec0:	fe442603          	lw	a2,-28(s0)
    80004ec4:	fd843583          	ld	a1,-40(s0)
    80004ec8:	fe843503          	ld	a0,-24(s0)
    80004ecc:	dc4ff0ef          	jal	80004490 <filewrite>
}
    80004ed0:	70a2                	ld	ra,40(sp)
    80004ed2:	7402                	ld	s0,32(sp)
    80004ed4:	6145                	addi	sp,sp,48
    80004ed6:	8082                	ret

0000000080004ed8 <sys_close>:
{
    80004ed8:	1101                	addi	sp,sp,-32
    80004eda:	ec06                	sd	ra,24(sp)
    80004edc:	e822                	sd	s0,16(sp)
    80004ede:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ee0:	fe040613          	addi	a2,s0,-32
    80004ee4:	fec40593          	addi	a1,s0,-20
    80004ee8:	4501                	li	a0,0
    80004eea:	d43ff0ef          	jal	80004c2c <argfd>
    return -1;
    80004eee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ef0:	02054063          	bltz	a0,80004f10 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ef4:	bc9fc0ef          	jal	80001abc <myproc>
    80004ef8:	fec42783          	lw	a5,-20(s0)
    80004efc:	07e9                	addi	a5,a5,26
    80004efe:	078e                	slli	a5,a5,0x3
    80004f00:	953e                	add	a0,a0,a5
    80004f02:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f06:	fe043503          	ld	a0,-32(s0)
    80004f0a:	ba8ff0ef          	jal	800042b2 <fileclose>
  return 0;
    80004f0e:	4781                	li	a5,0
}
    80004f10:	853e                	mv	a0,a5
    80004f12:	60e2                	ld	ra,24(sp)
    80004f14:	6442                	ld	s0,16(sp)
    80004f16:	6105                	addi	sp,sp,32
    80004f18:	8082                	ret

0000000080004f1a <sys_fstat>:
{
    80004f1a:	1101                	addi	sp,sp,-32
    80004f1c:	ec06                	sd	ra,24(sp)
    80004f1e:	e822                	sd	s0,16(sp)
    80004f20:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f22:	fe040593          	addi	a1,s0,-32
    80004f26:	4505                	li	a0,1
    80004f28:	b4bfd0ef          	jal	80002a72 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f2c:	fe840613          	addi	a2,s0,-24
    80004f30:	4581                	li	a1,0
    80004f32:	4501                	li	a0,0
    80004f34:	cf9ff0ef          	jal	80004c2c <argfd>
    80004f38:	87aa                	mv	a5,a0
    return -1;
    80004f3a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f3c:	0007c863          	bltz	a5,80004f4c <sys_fstat+0x32>
  return filestat(f, st);
    80004f40:	fe043583          	ld	a1,-32(s0)
    80004f44:	fe843503          	ld	a0,-24(s0)
    80004f48:	c2cff0ef          	jal	80004374 <filestat>
}
    80004f4c:	60e2                	ld	ra,24(sp)
    80004f4e:	6442                	ld	s0,16(sp)
    80004f50:	6105                	addi	sp,sp,32
    80004f52:	8082                	ret

0000000080004f54 <sys_link>:
{
    80004f54:	7169                	addi	sp,sp,-304
    80004f56:	f606                	sd	ra,296(sp)
    80004f58:	f222                	sd	s0,288(sp)
    80004f5a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f5c:	08000613          	li	a2,128
    80004f60:	ed040593          	addi	a1,s0,-304
    80004f64:	4501                	li	a0,0
    80004f66:	b29fd0ef          	jal	80002a8e <argstr>
    return -1;
    80004f6a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f6c:	0c054e63          	bltz	a0,80005048 <sys_link+0xf4>
    80004f70:	08000613          	li	a2,128
    80004f74:	f5040593          	addi	a1,s0,-176
    80004f78:	4505                	li	a0,1
    80004f7a:	b15fd0ef          	jal	80002a8e <argstr>
    return -1;
    80004f7e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f80:	0c054463          	bltz	a0,80005048 <sys_link+0xf4>
    80004f84:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f86:	f21fe0ef          	jal	80003ea6 <begin_op>
  if((ip = namei(old)) == 0){
    80004f8a:	ed040513          	addi	a0,s0,-304
    80004f8e:	d45fe0ef          	jal	80003cd2 <namei>
    80004f92:	84aa                	mv	s1,a0
    80004f94:	c53d                	beqz	a0,80005002 <sys_link+0xae>
  ilock(ip);
    80004f96:	d26fe0ef          	jal	800034bc <ilock>
  if(ip->type == T_DIR){
    80004f9a:	04449703          	lh	a4,68(s1)
    80004f9e:	4785                	li	a5,1
    80004fa0:	06f70663          	beq	a4,a5,8000500c <sys_link+0xb8>
    80004fa4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004fa6:	04a4d783          	lhu	a5,74(s1)
    80004faa:	2785                	addiw	a5,a5,1
    80004fac:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	c56fe0ef          	jal	80003408 <iupdate>
  iunlock(ip);
    80004fb6:	8526                	mv	a0,s1
    80004fb8:	db2fe0ef          	jal	8000356a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004fbc:	fd040593          	addi	a1,s0,-48
    80004fc0:	f5040513          	addi	a0,s0,-176
    80004fc4:	d29fe0ef          	jal	80003cec <nameiparent>
    80004fc8:	892a                	mv	s2,a0
    80004fca:	cd21                	beqz	a0,80005022 <sys_link+0xce>
  ilock(dp);
    80004fcc:	cf0fe0ef          	jal	800034bc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004fd0:	00092703          	lw	a4,0(s2)
    80004fd4:	409c                	lw	a5,0(s1)
    80004fd6:	04f71363          	bne	a4,a5,8000501c <sys_link+0xc8>
    80004fda:	40d0                	lw	a2,4(s1)
    80004fdc:	fd040593          	addi	a1,s0,-48
    80004fe0:	854a                	mv	a0,s2
    80004fe2:	c57fe0ef          	jal	80003c38 <dirlink>
    80004fe6:	02054b63          	bltz	a0,8000501c <sys_link+0xc8>
  iunlockput(dp);
    80004fea:	854a                	mv	a0,s2
    80004fec:	edafe0ef          	jal	800036c6 <iunlockput>
  iput(ip);
    80004ff0:	8526                	mv	a0,s1
    80004ff2:	e4cfe0ef          	jal	8000363e <iput>
  end_op();
    80004ff6:	f1bfe0ef          	jal	80003f10 <end_op>
  return 0;
    80004ffa:	4781                	li	a5,0
    80004ffc:	64f2                	ld	s1,280(sp)
    80004ffe:	6952                	ld	s2,272(sp)
    80005000:	a0a1                	j	80005048 <sys_link+0xf4>
    end_op();
    80005002:	f0ffe0ef          	jal	80003f10 <end_op>
    return -1;
    80005006:	57fd                	li	a5,-1
    80005008:	64f2                	ld	s1,280(sp)
    8000500a:	a83d                	j	80005048 <sys_link+0xf4>
    iunlockput(ip);
    8000500c:	8526                	mv	a0,s1
    8000500e:	eb8fe0ef          	jal	800036c6 <iunlockput>
    end_op();
    80005012:	efffe0ef          	jal	80003f10 <end_op>
    return -1;
    80005016:	57fd                	li	a5,-1
    80005018:	64f2                	ld	s1,280(sp)
    8000501a:	a03d                	j	80005048 <sys_link+0xf4>
    iunlockput(dp);
    8000501c:	854a                	mv	a0,s2
    8000501e:	ea8fe0ef          	jal	800036c6 <iunlockput>
  ilock(ip);
    80005022:	8526                	mv	a0,s1
    80005024:	c98fe0ef          	jal	800034bc <ilock>
  ip->nlink--;
    80005028:	04a4d783          	lhu	a5,74(s1)
    8000502c:	37fd                	addiw	a5,a5,-1
    8000502e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005032:	8526                	mv	a0,s1
    80005034:	bd4fe0ef          	jal	80003408 <iupdate>
  iunlockput(ip);
    80005038:	8526                	mv	a0,s1
    8000503a:	e8cfe0ef          	jal	800036c6 <iunlockput>
  end_op();
    8000503e:	ed3fe0ef          	jal	80003f10 <end_op>
  return -1;
    80005042:	57fd                	li	a5,-1
    80005044:	64f2                	ld	s1,280(sp)
    80005046:	6952                	ld	s2,272(sp)
}
    80005048:	853e                	mv	a0,a5
    8000504a:	70b2                	ld	ra,296(sp)
    8000504c:	7412                	ld	s0,288(sp)
    8000504e:	6155                	addi	sp,sp,304
    80005050:	8082                	ret

0000000080005052 <sys_unlink>:
{
    80005052:	7151                	addi	sp,sp,-240
    80005054:	f586                	sd	ra,232(sp)
    80005056:	f1a2                	sd	s0,224(sp)
    80005058:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000505a:	08000613          	li	a2,128
    8000505e:	f3040593          	addi	a1,s0,-208
    80005062:	4501                	li	a0,0
    80005064:	a2bfd0ef          	jal	80002a8e <argstr>
    80005068:	16054063          	bltz	a0,800051c8 <sys_unlink+0x176>
    8000506c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000506e:	e39fe0ef          	jal	80003ea6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005072:	fb040593          	addi	a1,s0,-80
    80005076:	f3040513          	addi	a0,s0,-208
    8000507a:	c73fe0ef          	jal	80003cec <nameiparent>
    8000507e:	84aa                	mv	s1,a0
    80005080:	c945                	beqz	a0,80005130 <sys_unlink+0xde>
  ilock(dp);
    80005082:	c3afe0ef          	jal	800034bc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005086:	00002597          	auipc	a1,0x2
    8000508a:	53a58593          	addi	a1,a1,1338 # 800075c0 <etext+0x5c0>
    8000508e:	fb040513          	addi	a0,s0,-80
    80005092:	9c5fe0ef          	jal	80003a56 <namecmp>
    80005096:	10050e63          	beqz	a0,800051b2 <sys_unlink+0x160>
    8000509a:	00002597          	auipc	a1,0x2
    8000509e:	52e58593          	addi	a1,a1,1326 # 800075c8 <etext+0x5c8>
    800050a2:	fb040513          	addi	a0,s0,-80
    800050a6:	9b1fe0ef          	jal	80003a56 <namecmp>
    800050aa:	10050463          	beqz	a0,800051b2 <sys_unlink+0x160>
    800050ae:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800050b0:	f2c40613          	addi	a2,s0,-212
    800050b4:	fb040593          	addi	a1,s0,-80
    800050b8:	8526                	mv	a0,s1
    800050ba:	9b3fe0ef          	jal	80003a6c <dirlookup>
    800050be:	892a                	mv	s2,a0
    800050c0:	0e050863          	beqz	a0,800051b0 <sys_unlink+0x15e>
  ilock(ip);
    800050c4:	bf8fe0ef          	jal	800034bc <ilock>
  if(ip->nlink < 1)
    800050c8:	04a91783          	lh	a5,74(s2)
    800050cc:	06f05763          	blez	a5,8000513a <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800050d0:	04491703          	lh	a4,68(s2)
    800050d4:	4785                	li	a5,1
    800050d6:	06f70963          	beq	a4,a5,80005148 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800050da:	4641                	li	a2,16
    800050dc:	4581                	li	a1,0
    800050de:	fc040513          	addi	a0,s0,-64
    800050e2:	bc1fb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050e6:	4741                	li	a4,16
    800050e8:	f2c42683          	lw	a3,-212(s0)
    800050ec:	fc040613          	addi	a2,s0,-64
    800050f0:	4581                	li	a1,0
    800050f2:	8526                	mv	a0,s1
    800050f4:	855fe0ef          	jal	80003948 <writei>
    800050f8:	47c1                	li	a5,16
    800050fa:	08f51b63          	bne	a0,a5,80005190 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    800050fe:	04491703          	lh	a4,68(s2)
    80005102:	4785                	li	a5,1
    80005104:	08f70d63          	beq	a4,a5,8000519e <sys_unlink+0x14c>
  iunlockput(dp);
    80005108:	8526                	mv	a0,s1
    8000510a:	dbcfe0ef          	jal	800036c6 <iunlockput>
  ip->nlink--;
    8000510e:	04a95783          	lhu	a5,74(s2)
    80005112:	37fd                	addiw	a5,a5,-1
    80005114:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005118:	854a                	mv	a0,s2
    8000511a:	aeefe0ef          	jal	80003408 <iupdate>
  iunlockput(ip);
    8000511e:	854a                	mv	a0,s2
    80005120:	da6fe0ef          	jal	800036c6 <iunlockput>
  end_op();
    80005124:	dedfe0ef          	jal	80003f10 <end_op>
  return 0;
    80005128:	4501                	li	a0,0
    8000512a:	64ee                	ld	s1,216(sp)
    8000512c:	694e                	ld	s2,208(sp)
    8000512e:	a849                	j	800051c0 <sys_unlink+0x16e>
    end_op();
    80005130:	de1fe0ef          	jal	80003f10 <end_op>
    return -1;
    80005134:	557d                	li	a0,-1
    80005136:	64ee                	ld	s1,216(sp)
    80005138:	a061                	j	800051c0 <sys_unlink+0x16e>
    8000513a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000513c:	00002517          	auipc	a0,0x2
    80005140:	49450513          	addi	a0,a0,1172 # 800075d0 <etext+0x5d0>
    80005144:	e9cfb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005148:	04c92703          	lw	a4,76(s2)
    8000514c:	02000793          	li	a5,32
    80005150:	f8e7f5e3          	bgeu	a5,a4,800050da <sys_unlink+0x88>
    80005154:	e5ce                	sd	s3,200(sp)
    80005156:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000515a:	4741                	li	a4,16
    8000515c:	86ce                	mv	a3,s3
    8000515e:	f1840613          	addi	a2,s0,-232
    80005162:	4581                	li	a1,0
    80005164:	854a                	mv	a0,s2
    80005166:	ee6fe0ef          	jal	8000384c <readi>
    8000516a:	47c1                	li	a5,16
    8000516c:	00f51c63          	bne	a0,a5,80005184 <sys_unlink+0x132>
    if(de.inum != 0)
    80005170:	f1845783          	lhu	a5,-232(s0)
    80005174:	efa1                	bnez	a5,800051cc <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005176:	29c1                	addiw	s3,s3,16
    80005178:	04c92783          	lw	a5,76(s2)
    8000517c:	fcf9efe3          	bltu	s3,a5,8000515a <sys_unlink+0x108>
    80005180:	69ae                	ld	s3,200(sp)
    80005182:	bfa1                	j	800050da <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005184:	00002517          	auipc	a0,0x2
    80005188:	46450513          	addi	a0,a0,1124 # 800075e8 <etext+0x5e8>
    8000518c:	e54fb0ef          	jal	800007e0 <panic>
    80005190:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005192:	00002517          	auipc	a0,0x2
    80005196:	46e50513          	addi	a0,a0,1134 # 80007600 <etext+0x600>
    8000519a:	e46fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    8000519e:	04a4d783          	lhu	a5,74(s1)
    800051a2:	37fd                	addiw	a5,a5,-1
    800051a4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051a8:	8526                	mv	a0,s1
    800051aa:	a5efe0ef          	jal	80003408 <iupdate>
    800051ae:	bfa9                	j	80005108 <sys_unlink+0xb6>
    800051b0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800051b2:	8526                	mv	a0,s1
    800051b4:	d12fe0ef          	jal	800036c6 <iunlockput>
  end_op();
    800051b8:	d59fe0ef          	jal	80003f10 <end_op>
  return -1;
    800051bc:	557d                	li	a0,-1
    800051be:	64ee                	ld	s1,216(sp)
}
    800051c0:	70ae                	ld	ra,232(sp)
    800051c2:	740e                	ld	s0,224(sp)
    800051c4:	616d                	addi	sp,sp,240
    800051c6:	8082                	ret
    return -1;
    800051c8:	557d                	li	a0,-1
    800051ca:	bfdd                	j	800051c0 <sys_unlink+0x16e>
    iunlockput(ip);
    800051cc:	854a                	mv	a0,s2
    800051ce:	cf8fe0ef          	jal	800036c6 <iunlockput>
    goto bad;
    800051d2:	694e                	ld	s2,208(sp)
    800051d4:	69ae                	ld	s3,200(sp)
    800051d6:	bff1                	j	800051b2 <sys_unlink+0x160>

00000000800051d8 <sys_open>:

uint64
sys_open(void)
{
    800051d8:	7131                	addi	sp,sp,-192
    800051da:	fd06                	sd	ra,184(sp)
    800051dc:	f922                	sd	s0,176(sp)
    800051de:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051e0:	f4c40593          	addi	a1,s0,-180
    800051e4:	4505                	li	a0,1
    800051e6:	871fd0ef          	jal	80002a56 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051ea:	08000613          	li	a2,128
    800051ee:	f5040593          	addi	a1,s0,-176
    800051f2:	4501                	li	a0,0
    800051f4:	89bfd0ef          	jal	80002a8e <argstr>
    800051f8:	87aa                	mv	a5,a0
    return -1;
    800051fa:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051fc:	0a07c263          	bltz	a5,800052a0 <sys_open+0xc8>
    80005200:	f526                	sd	s1,168(sp)

  begin_op();
    80005202:	ca5fe0ef          	jal	80003ea6 <begin_op>

  if(omode & O_CREATE){
    80005206:	f4c42783          	lw	a5,-180(s0)
    8000520a:	2007f793          	andi	a5,a5,512
    8000520e:	c3d5                	beqz	a5,800052b2 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005210:	4681                	li	a3,0
    80005212:	4601                	li	a2,0
    80005214:	4589                	li	a1,2
    80005216:	f5040513          	addi	a0,s0,-176
    8000521a:	aa9ff0ef          	jal	80004cc2 <create>
    8000521e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005220:	c541                	beqz	a0,800052a8 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005222:	04449703          	lh	a4,68(s1)
    80005226:	478d                	li	a5,3
    80005228:	00f71763          	bne	a4,a5,80005236 <sys_open+0x5e>
    8000522c:	0464d703          	lhu	a4,70(s1)
    80005230:	47a5                	li	a5,9
    80005232:	0ae7ed63          	bltu	a5,a4,800052ec <sys_open+0x114>
    80005236:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005238:	fd7fe0ef          	jal	8000420e <filealloc>
    8000523c:	892a                	mv	s2,a0
    8000523e:	c179                	beqz	a0,80005304 <sys_open+0x12c>
    80005240:	ed4e                	sd	s3,152(sp)
    80005242:	a43ff0ef          	jal	80004c84 <fdalloc>
    80005246:	89aa                	mv	s3,a0
    80005248:	0a054a63          	bltz	a0,800052fc <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000524c:	04449703          	lh	a4,68(s1)
    80005250:	478d                	li	a5,3
    80005252:	0cf70263          	beq	a4,a5,80005316 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005256:	4789                	li	a5,2
    80005258:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000525c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005260:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005264:	f4c42783          	lw	a5,-180(s0)
    80005268:	0017c713          	xori	a4,a5,1
    8000526c:	8b05                	andi	a4,a4,1
    8000526e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005272:	0037f713          	andi	a4,a5,3
    80005276:	00e03733          	snez	a4,a4
    8000527a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000527e:	4007f793          	andi	a5,a5,1024
    80005282:	c791                	beqz	a5,8000528e <sys_open+0xb6>
    80005284:	04449703          	lh	a4,68(s1)
    80005288:	4789                	li	a5,2
    8000528a:	08f70d63          	beq	a4,a5,80005324 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000528e:	8526                	mv	a0,s1
    80005290:	adafe0ef          	jal	8000356a <iunlock>
  end_op();
    80005294:	c7dfe0ef          	jal	80003f10 <end_op>

  return fd;
    80005298:	854e                	mv	a0,s3
    8000529a:	74aa                	ld	s1,168(sp)
    8000529c:	790a                	ld	s2,160(sp)
    8000529e:	69ea                	ld	s3,152(sp)
}
    800052a0:	70ea                	ld	ra,184(sp)
    800052a2:	744a                	ld	s0,176(sp)
    800052a4:	6129                	addi	sp,sp,192
    800052a6:	8082                	ret
      end_op();
    800052a8:	c69fe0ef          	jal	80003f10 <end_op>
      return -1;
    800052ac:	557d                	li	a0,-1
    800052ae:	74aa                	ld	s1,168(sp)
    800052b0:	bfc5                	j	800052a0 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800052b2:	f5040513          	addi	a0,s0,-176
    800052b6:	a1dfe0ef          	jal	80003cd2 <namei>
    800052ba:	84aa                	mv	s1,a0
    800052bc:	c11d                	beqz	a0,800052e2 <sys_open+0x10a>
    ilock(ip);
    800052be:	9fefe0ef          	jal	800034bc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800052c2:	04449703          	lh	a4,68(s1)
    800052c6:	4785                	li	a5,1
    800052c8:	f4f71de3          	bne	a4,a5,80005222 <sys_open+0x4a>
    800052cc:	f4c42783          	lw	a5,-180(s0)
    800052d0:	d3bd                	beqz	a5,80005236 <sys_open+0x5e>
      iunlockput(ip);
    800052d2:	8526                	mv	a0,s1
    800052d4:	bf2fe0ef          	jal	800036c6 <iunlockput>
      end_op();
    800052d8:	c39fe0ef          	jal	80003f10 <end_op>
      return -1;
    800052dc:	557d                	li	a0,-1
    800052de:	74aa                	ld	s1,168(sp)
    800052e0:	b7c1                	j	800052a0 <sys_open+0xc8>
      end_op();
    800052e2:	c2ffe0ef          	jal	80003f10 <end_op>
      return -1;
    800052e6:	557d                	li	a0,-1
    800052e8:	74aa                	ld	s1,168(sp)
    800052ea:	bf5d                	j	800052a0 <sys_open+0xc8>
    iunlockput(ip);
    800052ec:	8526                	mv	a0,s1
    800052ee:	bd8fe0ef          	jal	800036c6 <iunlockput>
    end_op();
    800052f2:	c1ffe0ef          	jal	80003f10 <end_op>
    return -1;
    800052f6:	557d                	li	a0,-1
    800052f8:	74aa                	ld	s1,168(sp)
    800052fa:	b75d                	j	800052a0 <sys_open+0xc8>
      fileclose(f);
    800052fc:	854a                	mv	a0,s2
    800052fe:	fb5fe0ef          	jal	800042b2 <fileclose>
    80005302:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005304:	8526                	mv	a0,s1
    80005306:	bc0fe0ef          	jal	800036c6 <iunlockput>
    end_op();
    8000530a:	c07fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000530e:	557d                	li	a0,-1
    80005310:	74aa                	ld	s1,168(sp)
    80005312:	790a                	ld	s2,160(sp)
    80005314:	b771                	j	800052a0 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005316:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000531a:	04649783          	lh	a5,70(s1)
    8000531e:	02f91223          	sh	a5,36(s2)
    80005322:	bf3d                	j	80005260 <sys_open+0x88>
    itrunc(ip);
    80005324:	8526                	mv	a0,s1
    80005326:	a84fe0ef          	jal	800035aa <itrunc>
    8000532a:	b795                	j	8000528e <sys_open+0xb6>

000000008000532c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000532c:	7175                	addi	sp,sp,-144
    8000532e:	e506                	sd	ra,136(sp)
    80005330:	e122                	sd	s0,128(sp)
    80005332:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005334:	b73fe0ef          	jal	80003ea6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005338:	08000613          	li	a2,128
    8000533c:	f7040593          	addi	a1,s0,-144
    80005340:	4501                	li	a0,0
    80005342:	f4cfd0ef          	jal	80002a8e <argstr>
    80005346:	02054363          	bltz	a0,8000536c <sys_mkdir+0x40>
    8000534a:	4681                	li	a3,0
    8000534c:	4601                	li	a2,0
    8000534e:	4585                	li	a1,1
    80005350:	f7040513          	addi	a0,s0,-144
    80005354:	96fff0ef          	jal	80004cc2 <create>
    80005358:	c911                	beqz	a0,8000536c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000535a:	b6cfe0ef          	jal	800036c6 <iunlockput>
  end_op();
    8000535e:	bb3fe0ef          	jal	80003f10 <end_op>
  return 0;
    80005362:	4501                	li	a0,0
}
    80005364:	60aa                	ld	ra,136(sp)
    80005366:	640a                	ld	s0,128(sp)
    80005368:	6149                	addi	sp,sp,144
    8000536a:	8082                	ret
    end_op();
    8000536c:	ba5fe0ef          	jal	80003f10 <end_op>
    return -1;
    80005370:	557d                	li	a0,-1
    80005372:	bfcd                	j	80005364 <sys_mkdir+0x38>

0000000080005374 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005374:	7135                	addi	sp,sp,-160
    80005376:	ed06                	sd	ra,152(sp)
    80005378:	e922                	sd	s0,144(sp)
    8000537a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000537c:	b2bfe0ef          	jal	80003ea6 <begin_op>
  argint(1, &major);
    80005380:	f6c40593          	addi	a1,s0,-148
    80005384:	4505                	li	a0,1
    80005386:	ed0fd0ef          	jal	80002a56 <argint>
  argint(2, &minor);
    8000538a:	f6840593          	addi	a1,s0,-152
    8000538e:	4509                	li	a0,2
    80005390:	ec6fd0ef          	jal	80002a56 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005394:	08000613          	li	a2,128
    80005398:	f7040593          	addi	a1,s0,-144
    8000539c:	4501                	li	a0,0
    8000539e:	ef0fd0ef          	jal	80002a8e <argstr>
    800053a2:	02054563          	bltz	a0,800053cc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800053a6:	f6841683          	lh	a3,-152(s0)
    800053aa:	f6c41603          	lh	a2,-148(s0)
    800053ae:	458d                	li	a1,3
    800053b0:	f7040513          	addi	a0,s0,-144
    800053b4:	90fff0ef          	jal	80004cc2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053b8:	c911                	beqz	a0,800053cc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ba:	b0cfe0ef          	jal	800036c6 <iunlockput>
  end_op();
    800053be:	b53fe0ef          	jal	80003f10 <end_op>
  return 0;
    800053c2:	4501                	li	a0,0
}
    800053c4:	60ea                	ld	ra,152(sp)
    800053c6:	644a                	ld	s0,144(sp)
    800053c8:	610d                	addi	sp,sp,160
    800053ca:	8082                	ret
    end_op();
    800053cc:	b45fe0ef          	jal	80003f10 <end_op>
    return -1;
    800053d0:	557d                	li	a0,-1
    800053d2:	bfcd                	j	800053c4 <sys_mknod+0x50>

00000000800053d4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800053d4:	7135                	addi	sp,sp,-160
    800053d6:	ed06                	sd	ra,152(sp)
    800053d8:	e922                	sd	s0,144(sp)
    800053da:	e14a                	sd	s2,128(sp)
    800053dc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053de:	edefc0ef          	jal	80001abc <myproc>
    800053e2:	892a                	mv	s2,a0
  
  begin_op();
    800053e4:	ac3fe0ef          	jal	80003ea6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053e8:	08000613          	li	a2,128
    800053ec:	f6040593          	addi	a1,s0,-160
    800053f0:	4501                	li	a0,0
    800053f2:	e9cfd0ef          	jal	80002a8e <argstr>
    800053f6:	04054363          	bltz	a0,8000543c <sys_chdir+0x68>
    800053fa:	e526                	sd	s1,136(sp)
    800053fc:	f6040513          	addi	a0,s0,-160
    80005400:	8d3fe0ef          	jal	80003cd2 <namei>
    80005404:	84aa                	mv	s1,a0
    80005406:	c915                	beqz	a0,8000543a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005408:	8b4fe0ef          	jal	800034bc <ilock>
  if(ip->type != T_DIR){
    8000540c:	04449703          	lh	a4,68(s1)
    80005410:	4785                	li	a5,1
    80005412:	02f71963          	bne	a4,a5,80005444 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005416:	8526                	mv	a0,s1
    80005418:	952fe0ef          	jal	8000356a <iunlock>
  iput(p->cwd);
    8000541c:	15093503          	ld	a0,336(s2)
    80005420:	a1efe0ef          	jal	8000363e <iput>
  end_op();
    80005424:	aedfe0ef          	jal	80003f10 <end_op>
  p->cwd = ip;
    80005428:	14993823          	sd	s1,336(s2)
  return 0;
    8000542c:	4501                	li	a0,0
    8000542e:	64aa                	ld	s1,136(sp)
}
    80005430:	60ea                	ld	ra,152(sp)
    80005432:	644a                	ld	s0,144(sp)
    80005434:	690a                	ld	s2,128(sp)
    80005436:	610d                	addi	sp,sp,160
    80005438:	8082                	ret
    8000543a:	64aa                	ld	s1,136(sp)
    end_op();
    8000543c:	ad5fe0ef          	jal	80003f10 <end_op>
    return -1;
    80005440:	557d                	li	a0,-1
    80005442:	b7fd                	j	80005430 <sys_chdir+0x5c>
    iunlockput(ip);
    80005444:	8526                	mv	a0,s1
    80005446:	a80fe0ef          	jal	800036c6 <iunlockput>
    end_op();
    8000544a:	ac7fe0ef          	jal	80003f10 <end_op>
    return -1;
    8000544e:	557d                	li	a0,-1
    80005450:	64aa                	ld	s1,136(sp)
    80005452:	bff9                	j	80005430 <sys_chdir+0x5c>

0000000080005454 <sys_exec>:

uint64
sys_exec(void)
{
    80005454:	7121                	addi	sp,sp,-448
    80005456:	ff06                	sd	ra,440(sp)
    80005458:	fb22                	sd	s0,432(sp)
    8000545a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000545c:	e4840593          	addi	a1,s0,-440
    80005460:	4505                	li	a0,1
    80005462:	e10fd0ef          	jal	80002a72 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005466:	08000613          	li	a2,128
    8000546a:	f5040593          	addi	a1,s0,-176
    8000546e:	4501                	li	a0,0
    80005470:	e1efd0ef          	jal	80002a8e <argstr>
    80005474:	87aa                	mv	a5,a0
    return -1;
    80005476:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005478:	0c07c463          	bltz	a5,80005540 <sys_exec+0xec>
    8000547c:	f726                	sd	s1,424(sp)
    8000547e:	f34a                	sd	s2,416(sp)
    80005480:	ef4e                	sd	s3,408(sp)
    80005482:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005484:	10000613          	li	a2,256
    80005488:	4581                	li	a1,0
    8000548a:	e5040513          	addi	a0,s0,-432
    8000548e:	815fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005492:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005496:	89a6                	mv	s3,s1
    80005498:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000549a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000549e:	00391513          	slli	a0,s2,0x3
    800054a2:	e4040593          	addi	a1,s0,-448
    800054a6:	e4843783          	ld	a5,-440(s0)
    800054aa:	953e                	add	a0,a0,a5
    800054ac:	d20fd0ef          	jal	800029cc <fetchaddr>
    800054b0:	02054663          	bltz	a0,800054dc <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800054b4:	e4043783          	ld	a5,-448(s0)
    800054b8:	c3a9                	beqz	a5,800054fa <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800054ba:	e44fb0ef          	jal	80000afe <kalloc>
    800054be:	85aa                	mv	a1,a0
    800054c0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800054c4:	cd01                	beqz	a0,800054dc <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054c6:	6605                	lui	a2,0x1
    800054c8:	e4043503          	ld	a0,-448(s0)
    800054cc:	d4afd0ef          	jal	80002a16 <fetchstr>
    800054d0:	00054663          	bltz	a0,800054dc <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800054d4:	0905                	addi	s2,s2,1
    800054d6:	09a1                	addi	s3,s3,8
    800054d8:	fd4913e3          	bne	s2,s4,8000549e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054dc:	f5040913          	addi	s2,s0,-176
    800054e0:	6088                	ld	a0,0(s1)
    800054e2:	c931                	beqz	a0,80005536 <sys_exec+0xe2>
    kfree(argv[i]);
    800054e4:	d38fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054e8:	04a1                	addi	s1,s1,8
    800054ea:	ff249be3          	bne	s1,s2,800054e0 <sys_exec+0x8c>
  return -1;
    800054ee:	557d                	li	a0,-1
    800054f0:	74ba                	ld	s1,424(sp)
    800054f2:	791a                	ld	s2,416(sp)
    800054f4:	69fa                	ld	s3,408(sp)
    800054f6:	6a5a                	ld	s4,400(sp)
    800054f8:	a0a1                	j	80005540 <sys_exec+0xec>
      argv[i] = 0;
    800054fa:	0009079b          	sext.w	a5,s2
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	fd078793          	addi	a5,a5,-48
    80005504:	97a2                	add	a5,a5,s0
    80005506:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000550a:	e5040593          	addi	a1,s0,-432
    8000550e:	f5040513          	addi	a0,s0,-176
    80005512:	ba8ff0ef          	jal	800048ba <kexec>
    80005516:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005518:	f5040993          	addi	s3,s0,-176
    8000551c:	6088                	ld	a0,0(s1)
    8000551e:	c511                	beqz	a0,8000552a <sys_exec+0xd6>
    kfree(argv[i]);
    80005520:	cfcfb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005524:	04a1                	addi	s1,s1,8
    80005526:	ff349be3          	bne	s1,s3,8000551c <sys_exec+0xc8>
  return ret;
    8000552a:	854a                	mv	a0,s2
    8000552c:	74ba                	ld	s1,424(sp)
    8000552e:	791a                	ld	s2,416(sp)
    80005530:	69fa                	ld	s3,408(sp)
    80005532:	6a5a                	ld	s4,400(sp)
    80005534:	a031                	j	80005540 <sys_exec+0xec>
  return -1;
    80005536:	557d                	li	a0,-1
    80005538:	74ba                	ld	s1,424(sp)
    8000553a:	791a                	ld	s2,416(sp)
    8000553c:	69fa                	ld	s3,408(sp)
    8000553e:	6a5a                	ld	s4,400(sp)
}
    80005540:	70fa                	ld	ra,440(sp)
    80005542:	745a                	ld	s0,432(sp)
    80005544:	6139                	addi	sp,sp,448
    80005546:	8082                	ret

0000000080005548 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005548:	7139                	addi	sp,sp,-64
    8000554a:	fc06                	sd	ra,56(sp)
    8000554c:	f822                	sd	s0,48(sp)
    8000554e:	f426                	sd	s1,40(sp)
    80005550:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005552:	d6afc0ef          	jal	80001abc <myproc>
    80005556:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005558:	fd840593          	addi	a1,s0,-40
    8000555c:	4501                	li	a0,0
    8000555e:	d14fd0ef          	jal	80002a72 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005562:	fc840593          	addi	a1,s0,-56
    80005566:	fd040513          	addi	a0,s0,-48
    8000556a:	852ff0ef          	jal	800045bc <pipealloc>
    return -1;
    8000556e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005570:	0a054463          	bltz	a0,80005618 <sys_pipe+0xd0>
  fd0 = -1;
    80005574:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005578:	fd043503          	ld	a0,-48(s0)
    8000557c:	f08ff0ef          	jal	80004c84 <fdalloc>
    80005580:	fca42223          	sw	a0,-60(s0)
    80005584:	08054163          	bltz	a0,80005606 <sys_pipe+0xbe>
    80005588:	fc843503          	ld	a0,-56(s0)
    8000558c:	ef8ff0ef          	jal	80004c84 <fdalloc>
    80005590:	fca42023          	sw	a0,-64(s0)
    80005594:	06054063          	bltz	a0,800055f4 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005598:	4691                	li	a3,4
    8000559a:	fc440613          	addi	a2,s0,-60
    8000559e:	fd843583          	ld	a1,-40(s0)
    800055a2:	68a8                	ld	a0,80(s1)
    800055a4:	83efc0ef          	jal	800015e2 <copyout>
    800055a8:	00054e63          	bltz	a0,800055c4 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800055ac:	4691                	li	a3,4
    800055ae:	fc040613          	addi	a2,s0,-64
    800055b2:	fd843583          	ld	a1,-40(s0)
    800055b6:	0591                	addi	a1,a1,4
    800055b8:	68a8                	ld	a0,80(s1)
    800055ba:	828fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055be:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055c0:	04055c63          	bgez	a0,80005618 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800055c4:	fc442783          	lw	a5,-60(s0)
    800055c8:	07e9                	addi	a5,a5,26
    800055ca:	078e                	slli	a5,a5,0x3
    800055cc:	97a6                	add	a5,a5,s1
    800055ce:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055d2:	fc042783          	lw	a5,-64(s0)
    800055d6:	07e9                	addi	a5,a5,26
    800055d8:	078e                	slli	a5,a5,0x3
    800055da:	94be                	add	s1,s1,a5
    800055dc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800055e0:	fd043503          	ld	a0,-48(s0)
    800055e4:	ccffe0ef          	jal	800042b2 <fileclose>
    fileclose(wf);
    800055e8:	fc843503          	ld	a0,-56(s0)
    800055ec:	cc7fe0ef          	jal	800042b2 <fileclose>
    return -1;
    800055f0:	57fd                	li	a5,-1
    800055f2:	a01d                	j	80005618 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800055f4:	fc442783          	lw	a5,-60(s0)
    800055f8:	0007c763          	bltz	a5,80005606 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800055fc:	07e9                	addi	a5,a5,26
    800055fe:	078e                	slli	a5,a5,0x3
    80005600:	97a6                	add	a5,a5,s1
    80005602:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005606:	fd043503          	ld	a0,-48(s0)
    8000560a:	ca9fe0ef          	jal	800042b2 <fileclose>
    fileclose(wf);
    8000560e:	fc843503          	ld	a0,-56(s0)
    80005612:	ca1fe0ef          	jal	800042b2 <fileclose>
    return -1;
    80005616:	57fd                	li	a5,-1
}
    80005618:	853e                	mv	a0,a5
    8000561a:	70e2                	ld	ra,56(sp)
    8000561c:	7442                	ld	s0,48(sp)
    8000561e:	74a2                	ld	s1,40(sp)
    80005620:	6121                	addi	sp,sp,64
    80005622:	8082                	ret
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
    80005656:	a86fd0ef          	jal	800028dc <kerneltrap>

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
    800056b0:	be0fc0ef          	jal	80001a90 <cpuid>
  
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
    800056e4:	bacfc0ef          	jal	80001a90 <cpuid>
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
    80005708:	b88fc0ef          	jal	80001a90 <cpuid>
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
    80005774:	99ffc0ef          	jal	80002112 <wakeup>
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
    80005a38:	e8efc0ef          	jal	800020c6 <sleep>
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
    80005b34:	d92fc0ef          	jal	800020c6 <sleep>
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
    80005c0c:	d06fc0ef          	jal	80002112 <wakeup>

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
