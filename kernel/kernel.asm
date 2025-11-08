
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	fa013103          	ld	sp,-96(sp) # 80009fa0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fce70713          	addi	a4,a4,-50 # 8000a020 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	dcc78793          	addi	a5,a5,-564 # 80005e30 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc741f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	fac78793          	addi	a5,a5,-84 # 8000105a <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    80000102:	7119                	addi	sp,sp,-128
    80000104:	fc86                	sd	ra,120(sp)
    80000106:	f8a2                	sd	s0,112(sp)
    80000108:	f4a6                	sd	s1,104(sp)
    8000010a:	f0ca                	sd	s2,96(sp)
    8000010c:	ecce                	sd	s3,88(sp)
    8000010e:	e8d2                	sd	s4,80(sp)
    80000110:	e4d6                	sd	s5,72(sp)
    80000112:	e0da                	sd	s6,64(sp)
    80000114:	fc5e                	sd	s7,56(sp)
    80000116:	f862                	sd	s8,48(sp)
    80000118:	f466                	sd	s9,40(sp)
    8000011a:	f06a                	sd	s10,32(sp)
    8000011c:	ec6e                	sd	s11,24(sp)
    8000011e:	0100                	addi	s0,sp,128
    80000120:	8b2e                	mv	s6,a1
    80000122:	8ab2                	mv	s5,a2
    80000124:	8a36                	mv	s4,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000126:	00068b9b          	sext.w	s7,a3
  acquire(&cons.lock);
    8000012a:	00012517          	auipc	a0,0x12
    8000012e:	03650513          	addi	a0,a0,54 # 80012160 <cons>
    80000132:	00001097          	auipc	ra,0x1
    80000136:	a6a080e7          	jalr	-1430(ra) # 80000b9c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000013a:	00012497          	auipc	s1,0x12
    8000013e:	02648493          	addi	s1,s1,38 # 80012160 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000142:	89a6                	mv	s3,s1
    80000144:	00012917          	auipc	s2,0x12
    80000148:	0bc90913          	addi	s2,s2,188 # 80012200 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000014c:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000014e:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000150:	4da9                	li	s11,10
  while(n > 0){
    80000152:	07405863          	blez	s4,800001c2 <consoleread+0xc0>
    while(cons.r == cons.w){
    80000156:	0a04a783          	lw	a5,160(s1)
    8000015a:	0a44a703          	lw	a4,164(s1)
    8000015e:	02f71463          	bne	a4,a5,80000186 <consoleread+0x84>
      if(myproc()->killed){
    80000162:	00002097          	auipc	ra,0x2
    80000166:	a34080e7          	jalr	-1484(ra) # 80001b96 <myproc>
    8000016a:	5d1c                	lw	a5,56(a0)
    8000016c:	e7b5                	bnez	a5,800001d8 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000016e:	85ce                	mv	a1,s3
    80000170:	854a                	mv	a0,s2
    80000172:	00002097          	auipc	ra,0x2
    80000176:	1e8080e7          	jalr	488(ra) # 8000235a <sleep>
    while(cons.r == cons.w){
    8000017a:	0a04a783          	lw	a5,160(s1)
    8000017e:	0a44a703          	lw	a4,164(s1)
    80000182:	fef700e3          	beq	a4,a5,80000162 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000186:	0017871b          	addiw	a4,a5,1
    8000018a:	0ae4a023          	sw	a4,160(s1)
    8000018e:	07f7f713          	andi	a4,a5,127
    80000192:	9726                	add	a4,a4,s1
    80000194:	02074703          	lbu	a4,32(a4)
    80000198:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    8000019c:	079c0663          	beq	s8,s9,80000208 <consoleread+0x106>
    cbuf = c;
    800001a0:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a4:	4685                	li	a3,1
    800001a6:	f8f40613          	addi	a2,s0,-113
    800001aa:	85d6                	mv	a1,s5
    800001ac:	855a                	mv	a0,s6
    800001ae:	00002097          	auipc	ra,0x2
    800001b2:	40e080e7          	jalr	1038(ra) # 800025bc <either_copyout>
    800001b6:	01a50663          	beq	a0,s10,800001c2 <consoleread+0xc0>
    dst++;
    800001ba:	0a85                	addi	s5,s5,1
    --n;
    800001bc:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800001be:	f9bc1ae3          	bne	s8,s11,80000152 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001c2:	00012517          	auipc	a0,0x12
    800001c6:	f9e50513          	addi	a0,a0,-98 # 80012160 <cons>
    800001ca:	00001097          	auipc	ra,0x1
    800001ce:	aa2080e7          	jalr	-1374(ra) # 80000c6c <release>

  return target - n;
    800001d2:	414b853b          	subw	a0,s7,s4
    800001d6:	a811                	j	800001ea <consoleread+0xe8>
        release(&cons.lock);
    800001d8:	00012517          	auipc	a0,0x12
    800001dc:	f8850513          	addi	a0,a0,-120 # 80012160 <cons>
    800001e0:	00001097          	auipc	ra,0x1
    800001e4:	a8c080e7          	jalr	-1396(ra) # 80000c6c <release>
        return -1;
    800001e8:	557d                	li	a0,-1
}
    800001ea:	70e6                	ld	ra,120(sp)
    800001ec:	7446                	ld	s0,112(sp)
    800001ee:	74a6                	ld	s1,104(sp)
    800001f0:	7906                	ld	s2,96(sp)
    800001f2:	69e6                	ld	s3,88(sp)
    800001f4:	6a46                	ld	s4,80(sp)
    800001f6:	6aa6                	ld	s5,72(sp)
    800001f8:	6b06                	ld	s6,64(sp)
    800001fa:	7be2                	ld	s7,56(sp)
    800001fc:	7c42                	ld	s8,48(sp)
    800001fe:	7ca2                	ld	s9,40(sp)
    80000200:	7d02                	ld	s10,32(sp)
    80000202:	6de2                	ld	s11,24(sp)
    80000204:	6109                	addi	sp,sp,128
    80000206:	8082                	ret
      if(n < target){
    80000208:	000a071b          	sext.w	a4,s4
    8000020c:	fb777be3          	bgeu	a4,s7,800001c2 <consoleread+0xc0>
        cons.r--;
    80000210:	00012717          	auipc	a4,0x12
    80000214:	fef72823          	sw	a5,-16(a4) # 80012200 <cons+0xa0>
    80000218:	b76d                	j	800001c2 <consoleread+0xc0>

000000008000021a <consputc>:
  if(panicked){
    8000021a:	0000a797          	auipc	a5,0xa
    8000021e:	da67a783          	lw	a5,-602(a5) # 80009fc0 <panicked>
    80000222:	c391                	beqz	a5,80000226 <consputc+0xc>
    for(;;)
    80000224:	a001                	j	80000224 <consputc+0xa>
{
    80000226:	1141                	addi	sp,sp,-16
    80000228:	e406                	sd	ra,8(sp)
    8000022a:	e022                	sd	s0,0(sp)
    8000022c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000022e:	10000793          	li	a5,256
    80000232:	00f50a63          	beq	a0,a5,80000246 <consputc+0x2c>
    uartputc(c);
    80000236:	00000097          	auipc	ra,0x0
    8000023a:	692080e7          	jalr	1682(ra) # 800008c8 <uartputc>
}
    8000023e:	60a2                	ld	ra,8(sp)
    80000240:	6402                	ld	s0,0(sp)
    80000242:	0141                	addi	sp,sp,16
    80000244:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000246:	4521                	li	a0,8
    80000248:	00000097          	auipc	ra,0x0
    8000024c:	680080e7          	jalr	1664(ra) # 800008c8 <uartputc>
    80000250:	02000513          	li	a0,32
    80000254:	00000097          	auipc	ra,0x0
    80000258:	674080e7          	jalr	1652(ra) # 800008c8 <uartputc>
    8000025c:	4521                	li	a0,8
    8000025e:	00000097          	auipc	ra,0x0
    80000262:	66a080e7          	jalr	1642(ra) # 800008c8 <uartputc>
    80000266:	bfe1                	j	8000023e <consputc+0x24>

0000000080000268 <consolewrite>:
{
    80000268:	715d                	addi	sp,sp,-80
    8000026a:	e486                	sd	ra,72(sp)
    8000026c:	e0a2                	sd	s0,64(sp)
    8000026e:	fc26                	sd	s1,56(sp)
    80000270:	f84a                	sd	s2,48(sp)
    80000272:	f44e                	sd	s3,40(sp)
    80000274:	f052                	sd	s4,32(sp)
    80000276:	ec56                	sd	s5,24(sp)
    80000278:	0880                	addi	s0,sp,80
    8000027a:	8a2e                	mv	s4,a1
    8000027c:	84b2                	mv	s1,a2
    8000027e:	89b6                	mv	s3,a3
  acquire(&cons.lock);
    80000280:	00012517          	auipc	a0,0x12
    80000284:	ee050513          	addi	a0,a0,-288 # 80012160 <cons>
    80000288:	00001097          	auipc	ra,0x1
    8000028c:	914080e7          	jalr	-1772(ra) # 80000b9c <acquire>
  for(i = 0; i < n; i++){
    80000290:	05305b63          	blez	s3,800002e6 <consolewrite+0x7e>
    80000294:	4901                	li	s2,0
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000296:	5afd                	li	s5,-1
    80000298:	4685                	li	a3,1
    8000029a:	8626                	mv	a2,s1
    8000029c:	85d2                	mv	a1,s4
    8000029e:	fbf40513          	addi	a0,s0,-65
    800002a2:	00002097          	auipc	ra,0x2
    800002a6:	370080e7          	jalr	880(ra) # 80002612 <either_copyin>
    800002aa:	01550c63          	beq	a0,s5,800002c2 <consolewrite+0x5a>
    consputc(c);
    800002ae:	fbf44503          	lbu	a0,-65(s0)
    800002b2:	00000097          	auipc	ra,0x0
    800002b6:	f68080e7          	jalr	-152(ra) # 8000021a <consputc>
  for(i = 0; i < n; i++){
    800002ba:	2905                	addiw	s2,s2,1
    800002bc:	0485                	addi	s1,s1,1
    800002be:	fd299de3          	bne	s3,s2,80000298 <consolewrite+0x30>
  release(&cons.lock);
    800002c2:	00012517          	auipc	a0,0x12
    800002c6:	e9e50513          	addi	a0,a0,-354 # 80012160 <cons>
    800002ca:	00001097          	auipc	ra,0x1
    800002ce:	9a2080e7          	jalr	-1630(ra) # 80000c6c <release>
}
    800002d2:	854a                	mv	a0,s2
    800002d4:	60a6                	ld	ra,72(sp)
    800002d6:	6406                	ld	s0,64(sp)
    800002d8:	74e2                	ld	s1,56(sp)
    800002da:	7942                	ld	s2,48(sp)
    800002dc:	79a2                	ld	s3,40(sp)
    800002de:	7a02                	ld	s4,32(sp)
    800002e0:	6ae2                	ld	s5,24(sp)
    800002e2:	6161                	addi	sp,sp,80
    800002e4:	8082                	ret
  for(i = 0; i < n; i++){
    800002e6:	4901                	li	s2,0
    800002e8:	bfe9                	j	800002c2 <consolewrite+0x5a>

00000000800002ea <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ea:	1101                	addi	sp,sp,-32
    800002ec:	ec06                	sd	ra,24(sp)
    800002ee:	e822                	sd	s0,16(sp)
    800002f0:	e426                	sd	s1,8(sp)
    800002f2:	e04a                	sd	s2,0(sp)
    800002f4:	1000                	addi	s0,sp,32
    800002f6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002f8:	00012517          	auipc	a0,0x12
    800002fc:	e6850513          	addi	a0,a0,-408 # 80012160 <cons>
    80000300:	00001097          	auipc	ra,0x1
    80000304:	89c080e7          	jalr	-1892(ra) # 80000b9c <acquire>

  switch(c){
    80000308:	47d5                	li	a5,21
    8000030a:	0af48663          	beq	s1,a5,800003b6 <consoleintr+0xcc>
    8000030e:	0297ca63          	blt	a5,s1,80000342 <consoleintr+0x58>
    80000312:	47a1                	li	a5,8
    80000314:	0ef48763          	beq	s1,a5,80000402 <consoleintr+0x118>
    80000318:	47c1                	li	a5,16
    8000031a:	10f49a63          	bne	s1,a5,8000042e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    8000031e:	00002097          	auipc	ra,0x2
    80000322:	34a080e7          	jalr	842(ra) # 80002668 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000326:	00012517          	auipc	a0,0x12
    8000032a:	e3a50513          	addi	a0,a0,-454 # 80012160 <cons>
    8000032e:	00001097          	auipc	ra,0x1
    80000332:	93e080e7          	jalr	-1730(ra) # 80000c6c <release>
}
    80000336:	60e2                	ld	ra,24(sp)
    80000338:	6442                	ld	s0,16(sp)
    8000033a:	64a2                	ld	s1,8(sp)
    8000033c:	6902                	ld	s2,0(sp)
    8000033e:	6105                	addi	sp,sp,32
    80000340:	8082                	ret
  switch(c){
    80000342:	07f00793          	li	a5,127
    80000346:	0af48e63          	beq	s1,a5,80000402 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000034a:	00012717          	auipc	a4,0x12
    8000034e:	e1670713          	addi	a4,a4,-490 # 80012160 <cons>
    80000352:	0a872783          	lw	a5,168(a4)
    80000356:	0a072703          	lw	a4,160(a4)
    8000035a:	9f99                	subw	a5,a5,a4
    8000035c:	07f00713          	li	a4,127
    80000360:	fcf763e3          	bltu	a4,a5,80000326 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000364:	47b5                	li	a5,13
    80000366:	0cf48763          	beq	s1,a5,80000434 <consoleintr+0x14a>
      consputc(c);
    8000036a:	8526                	mv	a0,s1
    8000036c:	00000097          	auipc	ra,0x0
    80000370:	eae080e7          	jalr	-338(ra) # 8000021a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000374:	00012797          	auipc	a5,0x12
    80000378:	dec78793          	addi	a5,a5,-532 # 80012160 <cons>
    8000037c:	0a87a703          	lw	a4,168(a5)
    80000380:	0017069b          	addiw	a3,a4,1
    80000384:	0006861b          	sext.w	a2,a3
    80000388:	0ad7a423          	sw	a3,168(a5)
    8000038c:	07f77713          	andi	a4,a4,127
    80000390:	97ba                	add	a5,a5,a4
    80000392:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000396:	47a9                	li	a5,10
    80000398:	0cf48563          	beq	s1,a5,80000462 <consoleintr+0x178>
    8000039c:	4791                	li	a5,4
    8000039e:	0cf48263          	beq	s1,a5,80000462 <consoleintr+0x178>
    800003a2:	00012797          	auipc	a5,0x12
    800003a6:	e5e7a783          	lw	a5,-418(a5) # 80012200 <cons+0xa0>
    800003aa:	0807879b          	addiw	a5,a5,128
    800003ae:	f6f61ce3          	bne	a2,a5,80000326 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003b2:	863e                	mv	a2,a5
    800003b4:	a07d                	j	80000462 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	daa70713          	addi	a4,a4,-598 # 80012160 <cons>
    800003be:	0a872783          	lw	a5,168(a4)
    800003c2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c6:	00012497          	auipc	s1,0x12
    800003ca:	d9a48493          	addi	s1,s1,-614 # 80012160 <cons>
    while(cons.e != cons.w &&
    800003ce:	4929                	li	s2,10
    800003d0:	f4f70be3          	beq	a4,a5,80000326 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003d4:	37fd                	addiw	a5,a5,-1
    800003d6:	07f7f713          	andi	a4,a5,127
    800003da:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003dc:	02074703          	lbu	a4,32(a4)
    800003e0:	f52703e3          	beq	a4,s2,80000326 <consoleintr+0x3c>
      cons.e--;
    800003e4:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003e8:	10000513          	li	a0,256
    800003ec:	00000097          	auipc	ra,0x0
    800003f0:	e2e080e7          	jalr	-466(ra) # 8000021a <consputc>
    while(cons.e != cons.w &&
    800003f4:	0a84a783          	lw	a5,168(s1)
    800003f8:	0a44a703          	lw	a4,164(s1)
    800003fc:	fcf71ce3          	bne	a4,a5,800003d4 <consoleintr+0xea>
    80000400:	b71d                	j	80000326 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80000402:	00012717          	auipc	a4,0x12
    80000406:	d5e70713          	addi	a4,a4,-674 # 80012160 <cons>
    8000040a:	0a872783          	lw	a5,168(a4)
    8000040e:	0a472703          	lw	a4,164(a4)
    80000412:	f0f70ae3          	beq	a4,a5,80000326 <consoleintr+0x3c>
      cons.e--;
    80000416:	37fd                	addiw	a5,a5,-1
    80000418:	00012717          	auipc	a4,0x12
    8000041c:	def72823          	sw	a5,-528(a4) # 80012208 <cons+0xa8>
      consputc(BACKSPACE);
    80000420:	10000513          	li	a0,256
    80000424:	00000097          	auipc	ra,0x0
    80000428:	df6080e7          	jalr	-522(ra) # 8000021a <consputc>
    8000042c:	bded                	j	80000326 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000042e:	ee048ce3          	beqz	s1,80000326 <consoleintr+0x3c>
    80000432:	bf21                	j	8000034a <consoleintr+0x60>
      consputc(c);
    80000434:	4529                	li	a0,10
    80000436:	00000097          	auipc	ra,0x0
    8000043a:	de4080e7          	jalr	-540(ra) # 8000021a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000043e:	00012797          	auipc	a5,0x12
    80000442:	d2278793          	addi	a5,a5,-734 # 80012160 <cons>
    80000446:	0a87a703          	lw	a4,168(a5)
    8000044a:	0017069b          	addiw	a3,a4,1
    8000044e:	0006861b          	sext.w	a2,a3
    80000452:	0ad7a423          	sw	a3,168(a5)
    80000456:	07f77713          	andi	a4,a4,127
    8000045a:	97ba                	add	a5,a5,a4
    8000045c:	4729                	li	a4,10
    8000045e:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000462:	00012797          	auipc	a5,0x12
    80000466:	dac7a123          	sw	a2,-606(a5) # 80012204 <cons+0xa4>
        wakeup(&cons.r);
    8000046a:	00012517          	auipc	a0,0x12
    8000046e:	d9650513          	addi	a0,a0,-618 # 80012200 <cons+0xa0>
    80000472:	00002097          	auipc	ra,0x2
    80000476:	06e080e7          	jalr	110(ra) # 800024e0 <wakeup>
    8000047a:	b575                	j	80000326 <consoleintr+0x3c>

000000008000047c <consoleinit>:

void
consoleinit(void)
{
    8000047c:	1141                	addi	sp,sp,-16
    8000047e:	e406                	sd	ra,8(sp)
    80000480:	e022                	sd	s0,0(sp)
    80000482:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000484:	00009597          	auipc	a1,0x9
    80000488:	b8c58593          	addi	a1,a1,-1140 # 80009010 <etext+0x10>
    8000048c:	00012517          	auipc	a0,0x12
    80000490:	cd450513          	addi	a0,a0,-812 # 80012160 <cons>
    80000494:	00000097          	auipc	ra,0x0
    80000498:	632080e7          	jalr	1586(ra) # 80000ac6 <initlock>

  uartinit();
    8000049c:	00000097          	auipc	ra,0x0
    800004a0:	3f6080e7          	jalr	1014(ra) # 80000892 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004a4:	00036797          	auipc	a5,0x36
    800004a8:	d5478793          	addi	a5,a5,-684 # 800361f8 <devsw>
    800004ac:	00000717          	auipc	a4,0x0
    800004b0:	c5670713          	addi	a4,a4,-938 # 80000102 <consoleread>
    800004b4:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004b6:	00000717          	auipc	a4,0x0
    800004ba:	db270713          	addi	a4,a4,-590 # 80000268 <consolewrite>
    800004be:	ef98                	sd	a4,24(a5)
}
    800004c0:	60a2                	ld	ra,8(sp)
    800004c2:	6402                	ld	s0,0(sp)
    800004c4:	0141                	addi	sp,sp,16
    800004c6:	8082                	ret

00000000800004c8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004c8:	7179                	addi	sp,sp,-48
    800004ca:	f406                	sd	ra,40(sp)
    800004cc:	f022                	sd	s0,32(sp)
    800004ce:	ec26                	sd	s1,24(sp)
    800004d0:	e84a                	sd	s2,16(sp)
    800004d2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004d4:	c219                	beqz	a2,800004da <printint+0x12>
    800004d6:	08054663          	bltz	a0,80000562 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004da:	2501                	sext.w	a0,a0
    800004dc:	4881                	li	a7,0
    800004de:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004e2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004e4:	2581                	sext.w	a1,a1
    800004e6:	00009617          	auipc	a2,0x9
    800004ea:	c8a60613          	addi	a2,a2,-886 # 80009170 <digits>
    800004ee:	883a                	mv	a6,a4
    800004f0:	2705                	addiw	a4,a4,1
    800004f2:	02b577bb          	remuw	a5,a0,a1
    800004f6:	1782                	slli	a5,a5,0x20
    800004f8:	9381                	srli	a5,a5,0x20
    800004fa:	97b2                	add	a5,a5,a2
    800004fc:	0007c783          	lbu	a5,0(a5)
    80000500:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80000504:	0005079b          	sext.w	a5,a0
    80000508:	02b5553b          	divuw	a0,a0,a1
    8000050c:	0685                	addi	a3,a3,1
    8000050e:	feb7f0e3          	bgeu	a5,a1,800004ee <printint+0x26>

  if(sign)
    80000512:	00088b63          	beqz	a7,80000528 <printint+0x60>
    buf[i++] = '-';
    80000516:	fe040793          	addi	a5,s0,-32
    8000051a:	973e                	add	a4,a4,a5
    8000051c:	02d00793          	li	a5,45
    80000520:	fef70823          	sb	a5,-16(a4)
    80000524:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000528:	02e05763          	blez	a4,80000556 <printint+0x8e>
    8000052c:	fd040793          	addi	a5,s0,-48
    80000530:	00e784b3          	add	s1,a5,a4
    80000534:	fff78913          	addi	s2,a5,-1
    80000538:	993a                	add	s2,s2,a4
    8000053a:	377d                	addiw	a4,a4,-1
    8000053c:	1702                	slli	a4,a4,0x20
    8000053e:	9301                	srli	a4,a4,0x20
    80000540:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000544:	fff4c503          	lbu	a0,-1(s1)
    80000548:	00000097          	auipc	ra,0x0
    8000054c:	cd2080e7          	jalr	-814(ra) # 8000021a <consputc>
  while(--i >= 0)
    80000550:	14fd                	addi	s1,s1,-1
    80000552:	ff2499e3          	bne	s1,s2,80000544 <printint+0x7c>
}
    80000556:	70a2                	ld	ra,40(sp)
    80000558:	7402                	ld	s0,32(sp)
    8000055a:	64e2                	ld	s1,24(sp)
    8000055c:	6942                	ld	s2,16(sp)
    8000055e:	6145                	addi	sp,sp,48
    80000560:	8082                	ret
    x = -xx;
    80000562:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000566:	4885                	li	a7,1
    x = -xx;
    80000568:	bf9d                	j	800004de <printint+0x16>

000000008000056a <panic>:
  }
}

void
panic(char *s)
{
    8000056a:	1101                	addi	sp,sp,-32
    8000056c:	ec06                	sd	ra,24(sp)
    8000056e:	e822                	sd	s0,16(sp)
    80000570:	e426                	sd	s1,8(sp)
    80000572:	1000                	addi	s0,sp,32
    80000574:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000576:	00012797          	auipc	a5,0x12
    8000057a:	ca07ad23          	sw	zero,-838(a5) # 80012230 <pr+0x20>
  printf("PANIC: ");
    8000057e:	00009517          	auipc	a0,0x9
    80000582:	a9a50513          	addi	a0,a0,-1382 # 80009018 <etext+0x18>
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	046080e7          	jalr	70(ra) # 800005cc <printf>
  printf(s);
    8000058e:	8526                	mv	a0,s1
    80000590:	00000097          	auipc	ra,0x0
    80000594:	03c080e7          	jalr	60(ra) # 800005cc <printf>
  printf("\n");
    80000598:	00009517          	auipc	a0,0x9
    8000059c:	c6850513          	addi	a0,a0,-920 # 80009200 <digits+0x90>
    800005a0:	00000097          	auipc	ra,0x0
    800005a4:	02c080e7          	jalr	44(ra) # 800005cc <printf>
  backtrace();
    800005a8:	00000097          	auipc	ra,0x0
    800005ac:	24e080e7          	jalr	590(ra) # 800007f6 <backtrace>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    800005b0:	00009517          	auipc	a0,0x9
    800005b4:	a7050513          	addi	a0,a0,-1424 # 80009020 <etext+0x20>
    800005b8:	00000097          	auipc	ra,0x0
    800005bc:	014080e7          	jalr	20(ra) # 800005cc <printf>
  panicked = 1; // freeze other CPUs
    800005c0:	4785                	li	a5,1
    800005c2:	0000a717          	auipc	a4,0xa
    800005c6:	9ef72f23          	sw	a5,-1538(a4) # 80009fc0 <panicked>
  for(;;)
    800005ca:	a001                	j	800005ca <panic+0x60>

00000000800005cc <printf>:
{
    800005cc:	7131                	addi	sp,sp,-192
    800005ce:	fc86                	sd	ra,120(sp)
    800005d0:	f8a2                	sd	s0,112(sp)
    800005d2:	f4a6                	sd	s1,104(sp)
    800005d4:	f0ca                	sd	s2,96(sp)
    800005d6:	ecce                	sd	s3,88(sp)
    800005d8:	e8d2                	sd	s4,80(sp)
    800005da:	e4d6                	sd	s5,72(sp)
    800005dc:	e0da                	sd	s6,64(sp)
    800005de:	fc5e                	sd	s7,56(sp)
    800005e0:	f862                	sd	s8,48(sp)
    800005e2:	f466                	sd	s9,40(sp)
    800005e4:	f06a                	sd	s10,32(sp)
    800005e6:	ec6e                	sd	s11,24(sp)
    800005e8:	0100                	addi	s0,sp,128
    800005ea:	89aa                	mv	s3,a0
    800005ec:	e40c                	sd	a1,8(s0)
    800005ee:	e810                	sd	a2,16(s0)
    800005f0:	ec14                	sd	a3,24(s0)
    800005f2:	f018                	sd	a4,32(s0)
    800005f4:	f41c                	sd	a5,40(s0)
    800005f6:	03043823          	sd	a6,48(s0)
    800005fa:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005fe:	00012c17          	auipc	s8,0x12
    80000602:	c32c2c03          	lw	s8,-974(s8) # 80012230 <pr+0x20>
  if(locking)
    80000606:	020c1c63          	bnez	s8,8000063e <printf+0x72>
  if (fmt == 0)
    8000060a:	04098363          	beqz	s3,80000650 <printf+0x84>
  va_start(ap, fmt);
    8000060e:	00840793          	addi	a5,s0,8
    80000612:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000616:	0009c503          	lbu	a0,0(s3)
    8000061a:	1a050463          	beqz	a0,800007c2 <printf+0x1f6>
    8000061e:	4481                	li	s1,0
    if(c != '%'){
    80000620:	02500a13          	li	s4,37
    switch(c){
    80000624:	4ad5                	li	s5,21
    80000626:	00009917          	auipc	s2,0x9
    8000062a:	af290913          	addi	s2,s2,-1294 # 80009118 <etext+0x118>
      for(; *s; s++)
    8000062e:	02800d13          	li	s10,40
  consputc('x');
    80000632:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000634:	00009b17          	auipc	s6,0x9
    80000638:	b3cb0b13          	addi	s6,s6,-1220 # 80009170 <digits>
    8000063c:	a82d                	j	80000676 <printf+0xaa>
    acquire(&pr.lock);
    8000063e:	00012517          	auipc	a0,0x12
    80000642:	bd250513          	addi	a0,a0,-1070 # 80012210 <pr>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	556080e7          	jalr	1366(ra) # 80000b9c <acquire>
    8000064e:	bf75                	j	8000060a <printf+0x3e>
    panic("null fmt");
    80000650:	00009517          	auipc	a0,0x9
    80000654:	aa850513          	addi	a0,a0,-1368 # 800090f8 <etext+0xf8>
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f12080e7          	jalr	-238(ra) # 8000056a <panic>
      consputc(c);
    80000660:	00000097          	auipc	ra,0x0
    80000664:	bba080e7          	jalr	-1094(ra) # 8000021a <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000668:	2485                	addiw	s1,s1,1
    8000066a:	009987b3          	add	a5,s3,s1
    8000066e:	0007c503          	lbu	a0,0(a5)
    80000672:	14050863          	beqz	a0,800007c2 <printf+0x1f6>
    if(c != '%'){
    80000676:	ff4515e3          	bne	a0,s4,80000660 <printf+0x94>
    c = fmt[++i] & 0xff;
    8000067a:	2485                	addiw	s1,s1,1
    8000067c:	009987b3          	add	a5,s3,s1
    80000680:	0007c783          	lbu	a5,0(a5)
    80000684:	00078b9b          	sext.w	s7,a5
    if(c == 0)
    80000688:	12078d63          	beqz	a5,800007c2 <printf+0x1f6>
    switch(c){
    8000068c:	11478a63          	beq	a5,s4,800007a0 <printf+0x1d4>
    80000690:	f9d7871b          	addiw	a4,a5,-99
    80000694:	0ff77713          	andi	a4,a4,255
    80000698:	10eaea63          	bltu	s5,a4,800007ac <printf+0x1e0>
    8000069c:	f9d7879b          	addiw	a5,a5,-99
    800006a0:	0ff7f713          	andi	a4,a5,255
    800006a4:	10eae463          	bltu	s5,a4,800007ac <printf+0x1e0>
    800006a8:	00271793          	slli	a5,a4,0x2
    800006ac:	97ca                	add	a5,a5,s2
    800006ae:	439c                	lw	a5,0(a5)
    800006b0:	97ca                	add	a5,a5,s2
    800006b2:	8782                	jr	a5
      consputc(va_arg(ap, int));
    800006b4:	f8843783          	ld	a5,-120(s0)
    800006b8:	00878713          	addi	a4,a5,8
    800006bc:	f8e43423          	sd	a4,-120(s0)
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	b58080e7          	jalr	-1192(ra) # 8000021a <consputc>
      break;
    800006ca:	bf79                	j	80000668 <printf+0x9c>
      printint(va_arg(ap, int), 10, 1);
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	4605                	li	a2,1
    800006da:	45a9                	li	a1,10
    800006dc:	4388                	lw	a0,0(a5)
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	dea080e7          	jalr	-534(ra) # 800004c8 <printint>
      break;
    800006e6:	b749                	j	80000668 <printf+0x9c>
      printint(va_arg(ap, int), 10, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45a9                	li	a1,10
    800006f8:	4388                	lw	a0,0(a5)
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	dce080e7          	jalr	-562(ra) # 800004c8 <printint>
      break;
    80000702:	b79d                	j	80000668 <printf+0x9c>
      printint(va_arg(ap, int), 16, 1);
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4605                	li	a2,1
    80000712:	85e6                	mv	a1,s9
    80000714:	4388                	lw	a0,0(a5)
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	db2080e7          	jalr	-590(ra) # 800004c8 <printint>
      break;
    8000071e:	b7a9                	j	80000668 <printf+0x9c>
      printptr(va_arg(ap, uint64));
    80000720:	f8843783          	ld	a5,-120(s0)
    80000724:	00878713          	addi	a4,a5,8
    80000728:	f8e43423          	sd	a4,-120(s0)
    8000072c:	0007bd83          	ld	s11,0(a5)
  consputc('0');
    80000730:	03000513          	li	a0,48
    80000734:	00000097          	auipc	ra,0x0
    80000738:	ae6080e7          	jalr	-1306(ra) # 8000021a <consputc>
  consputc('x');
    8000073c:	07800513          	li	a0,120
    80000740:	00000097          	auipc	ra,0x0
    80000744:	ada080e7          	jalr	-1318(ra) # 8000021a <consputc>
    80000748:	8be6                	mv	s7,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000074a:	03cdd793          	srli	a5,s11,0x3c
    8000074e:	97da                	add	a5,a5,s6
    80000750:	0007c503          	lbu	a0,0(a5)
    80000754:	00000097          	auipc	ra,0x0
    80000758:	ac6080e7          	jalr	-1338(ra) # 8000021a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000075c:	0d92                	slli	s11,s11,0x4
    8000075e:	3bfd                	addiw	s7,s7,-1
    80000760:	fe0b95e3          	bnez	s7,8000074a <printf+0x17e>
    80000764:	b711                	j	80000668 <printf+0x9c>
      if((s = va_arg(ap, char*)) == 0)
    80000766:	f8843783          	ld	a5,-120(s0)
    8000076a:	00878713          	addi	a4,a5,8
    8000076e:	f8e43423          	sd	a4,-120(s0)
    80000772:	0007bb83          	ld	s7,0(a5)
    80000776:	000b8f63          	beqz	s7,80000794 <printf+0x1c8>
      for(; *s; s++)
    8000077a:	000bc503          	lbu	a0,0(s7)
    8000077e:	ee0505e3          	beqz	a0,80000668 <printf+0x9c>
        consputc(*s);
    80000782:	00000097          	auipc	ra,0x0
    80000786:	a98080e7          	jalr	-1384(ra) # 8000021a <consputc>
      for(; *s; s++)
    8000078a:	0b85                	addi	s7,s7,1
    8000078c:	000bc503          	lbu	a0,0(s7)
    80000790:	f96d                	bnez	a0,80000782 <printf+0x1b6>
    80000792:	bdd9                	j	80000668 <printf+0x9c>
        s = "(null)";
    80000794:	00009b97          	auipc	s7,0x9
    80000798:	95cb8b93          	addi	s7,s7,-1700 # 800090f0 <etext+0xf0>
      for(; *s; s++)
    8000079c:	856a                	mv	a0,s10
    8000079e:	b7d5                	j	80000782 <printf+0x1b6>
      consputc('%');
    800007a0:	8552                	mv	a0,s4
    800007a2:	00000097          	auipc	ra,0x0
    800007a6:	a78080e7          	jalr	-1416(ra) # 8000021a <consputc>
      break;
    800007aa:	bd7d                	j	80000668 <printf+0x9c>
      consputc('%');
    800007ac:	8552                	mv	a0,s4
    800007ae:	00000097          	auipc	ra,0x0
    800007b2:	a6c080e7          	jalr	-1428(ra) # 8000021a <consputc>
      consputc(c);
    800007b6:	855e                	mv	a0,s7
    800007b8:	00000097          	auipc	ra,0x0
    800007bc:	a62080e7          	jalr	-1438(ra) # 8000021a <consputc>
      break;
    800007c0:	b565                	j	80000668 <printf+0x9c>
  if(locking)
    800007c2:	020c1163          	bnez	s8,800007e4 <printf+0x218>
}
    800007c6:	70e6                	ld	ra,120(sp)
    800007c8:	7446                	ld	s0,112(sp)
    800007ca:	74a6                	ld	s1,104(sp)
    800007cc:	7906                	ld	s2,96(sp)
    800007ce:	69e6                	ld	s3,88(sp)
    800007d0:	6a46                	ld	s4,80(sp)
    800007d2:	6aa6                	ld	s5,72(sp)
    800007d4:	6b06                	ld	s6,64(sp)
    800007d6:	7be2                	ld	s7,56(sp)
    800007d8:	7c42                	ld	s8,48(sp)
    800007da:	7ca2                	ld	s9,40(sp)
    800007dc:	7d02                	ld	s10,32(sp)
    800007de:	6de2                	ld	s11,24(sp)
    800007e0:	6129                	addi	sp,sp,192
    800007e2:	8082                	ret
    release(&pr.lock);
    800007e4:	00012517          	auipc	a0,0x12
    800007e8:	a2c50513          	addi	a0,a0,-1492 # 80012210 <pr>
    800007ec:	00000097          	auipc	ra,0x0
    800007f0:	480080e7          	jalr	1152(ra) # 80000c6c <release>
}
    800007f4:	bfc9                	j	800007c6 <printf+0x1fa>

00000000800007f6 <backtrace>:
{
    800007f6:	7179                	addi	sp,sp,-48
    800007f8:	f406                	sd	ra,40(sp)
    800007fa:	f022                	sd	s0,32(sp)
    800007fc:	ec26                	sd	s1,24(sp)
    800007fe:	e84a                	sd	s2,16(sp)
    80000800:	e44e                	sd	s3,8(sp)
    80000802:	e052                	sd	s4,0(sp)
    80000804:	1800                	addi	s0,sp,48
  asm volatile("mv %0, fp" : "=r" (x) );
    80000806:	84a2                	mv	s1,s0
  uint64 ra, low = PGROUNDDOWN(fp) + 16, high = PGROUNDUP(fp);
    80000808:	77fd                	lui	a5,0xfffff
    8000080a:	00f4f9b3          	and	s3,s1,a5
    8000080e:	6905                	lui	s2,0x1
    80000810:	197d                	addi	s2,s2,-1
    80000812:	9926                	add	s2,s2,s1
    80000814:	00f97933          	and	s2,s2,a5
  while(!(fp & 7) && fp >= low && fp < high){
    80000818:	0074f793          	andi	a5,s1,7
    8000081c:	eb95                	bnez	a5,80000850 <backtrace+0x5a>
    8000081e:	09c1                	addi	s3,s3,16
    80000820:	0334e863          	bltu	s1,s3,80000850 <backtrace+0x5a>
    80000824:	0324f663          	bgeu	s1,s2,80000850 <backtrace+0x5a>
    printf("[<%p>]\n", ra);
    80000828:	00009a17          	auipc	s4,0x9
    8000082c:	8e0a0a13          	addi	s4,s4,-1824 # 80009108 <etext+0x108>
    80000830:	ff84b583          	ld	a1,-8(s1)
    80000834:	8552                	mv	a0,s4
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	d96080e7          	jalr	-618(ra) # 800005cc <printf>
    fp = *(uint64*)(fp - 16);
    8000083e:	ff04b483          	ld	s1,-16(s1)
  while(!(fp & 7) && fp >= low && fp < high){
    80000842:	0074f793          	andi	a5,s1,7
    80000846:	e789                	bnez	a5,80000850 <backtrace+0x5a>
    80000848:	0134e463          	bltu	s1,s3,80000850 <backtrace+0x5a>
    8000084c:	ff24e2e3          	bltu	s1,s2,80000830 <backtrace+0x3a>
}
    80000850:	70a2                	ld	ra,40(sp)
    80000852:	7402                	ld	s0,32(sp)
    80000854:	64e2                	ld	s1,24(sp)
    80000856:	6942                	ld	s2,16(sp)
    80000858:	69a2                	ld	s3,8(sp)
    8000085a:	6a02                	ld	s4,0(sp)
    8000085c:	6145                	addi	sp,sp,48
    8000085e:	8082                	ret

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1101                	addi	sp,sp,-32
    80000862:	ec06                	sd	ra,24(sp)
    80000864:	e822                	sd	s0,16(sp)
    80000866:	e426                	sd	s1,8(sp)
    80000868:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000086a:	00012497          	auipc	s1,0x12
    8000086e:	9a648493          	addi	s1,s1,-1626 # 80012210 <pr>
    80000872:	00009597          	auipc	a1,0x9
    80000876:	89e58593          	addi	a1,a1,-1890 # 80009110 <etext+0x110>
    8000087a:	8526                	mv	a0,s1
    8000087c:	00000097          	auipc	ra,0x0
    80000880:	24a080e7          	jalr	586(ra) # 80000ac6 <initlock>
  pr.locking = 1;
    80000884:	4785                	li	a5,1
    80000886:	d09c                	sw	a5,32(s1)
}
    80000888:	60e2                	ld	ra,24(sp)
    8000088a:	6442                	ld	s0,16(sp)
    8000088c:	64a2                	ld	s1,8(sp)
    8000088e:	6105                	addi	sp,sp,32
    80000890:	8082                	ret

0000000080000892 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    80000892:	1141                	addi	sp,sp,-16
    80000894:	e422                	sd	s0,8(sp)
    80000896:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000898:	100007b7          	lui	a5,0x10000
    8000089c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800008a0:	f8000713          	li	a4,-128
    800008a4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a8:	470d                	li	a4,3
    800008aa:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008ae:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800008b2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800008b6:	471d                	li	a4,7
    800008b8:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800008bc:	4705                	li	a4,1
    800008be:	00e780a3          	sb	a4,1(a5)
}
    800008c2:	6422                	ld	s0,8(sp)
    800008c4:	0141                	addi	sp,sp,16
    800008c6:	8082                	ret

00000000800008c8 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800008c8:	1141                	addi	sp,sp,-16
    800008ca:	e422                	sd	s0,8(sp)
    800008cc:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800008ce:	10000737          	lui	a4,0x10000
    800008d2:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008d6:	0ff7f793          	andi	a5,a5,255
    800008da:	0207f793          	andi	a5,a5,32
    800008de:	dbf5                	beqz	a5,800008d2 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800008e0:	0ff57513          	andi	a0,a0,255
    800008e4:	100007b7          	lui	a5,0x10000
    800008e8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800008ec:	6422                	ld	s0,8(sp)
    800008ee:	0141                	addi	sp,sp,16
    800008f0:	8082                	ret

00000000800008f2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800008f2:	1141                	addi	sp,sp,-16
    800008f4:	e422                	sd	s0,8(sp)
    800008f6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800008f8:	100007b7          	lui	a5,0x10000
    800008fc:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000900:	8b85                	andi	a5,a5,1
    80000902:	cb91                	beqz	a5,80000916 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000904:	100007b7          	lui	a5,0x10000
    80000908:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000090c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000910:	6422                	ld	s0,8(sp)
    80000912:	0141                	addi	sp,sp,16
    80000914:	8082                	ret
    return -1;
    80000916:	557d                	li	a0,-1
    80000918:	bfe5                	j	80000910 <uartgetc+0x1e>

000000008000091a <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    8000091a:	1101                	addi	sp,sp,-32
    8000091c:	ec06                	sd	ra,24(sp)
    8000091e:	e822                	sd	s0,16(sp)
    80000920:	e426                	sd	s1,8(sp)
    80000922:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000924:	54fd                	li	s1,-1
    int c = uartgetc();
    80000926:	00000097          	auipc	ra,0x0
    8000092a:	fcc080e7          	jalr	-52(ra) # 800008f2 <uartgetc>
    if(c == -1)
    8000092e:	00950763          	beq	a0,s1,8000093c <uartintr+0x22>
      break;
    consoleintr(c);
    80000932:	00000097          	auipc	ra,0x0
    80000936:	9b8080e7          	jalr	-1608(ra) # 800002ea <consoleintr>
  while(1){
    8000093a:	b7f5                	j	80000926 <uartintr+0xc>
  }
}
    8000093c:	60e2                	ld	ra,24(sp)
    8000093e:	6442                	ld	s0,16(sp)
    80000940:	64a2                	ld	s1,8(sp)
    80000942:	6105                	addi	sp,sp,32
    80000944:	8082                	ret

0000000080000946 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000946:	1101                	addi	sp,sp,-32
    80000948:	ec06                	sd	ra,24(sp)
    8000094a:	e822                	sd	s0,16(sp)
    8000094c:	e426                	sd	s1,8(sp)
    8000094e:	e04a                	sd	s2,0(sp)
    80000950:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000952:	03451793          	slli	a5,a0,0x34
    80000956:	e3a5                	bnez	a5,800009b6 <kfree+0x70>
    80000958:	84aa                	mv	s1,a0
    8000095a:	00037797          	auipc	a5,0x37
    8000095e:	a8678793          	addi	a5,a5,-1402 # 800373e0 <end>
    80000962:	04f56a63          	bltu	a0,a5,800009b6 <kfree+0x70>
    80000966:	47c5                	li	a5,17
    80000968:	07ee                	slli	a5,a5,0x1b
    8000096a:	04f57663          	bgeu	a0,a5,800009b6 <kfree+0x70>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000096e:	6605                	lui	a2,0x1
    80000970:	4585                	li	a1,1
    80000972:	00000097          	auipc	ra,0x0
    80000976:	50e080e7          	jalr	1294(ra) # 80000e80 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000097a:	00012917          	auipc	s2,0x12
    8000097e:	8be90913          	addi	s2,s2,-1858 # 80012238 <kmem>
    80000982:	854a                	mv	a0,s2
    80000984:	00000097          	auipc	ra,0x0
    80000988:	218080e7          	jalr	536(ra) # 80000b9c <acquire>
  r->next = kmem.freelist;
    8000098c:	02093783          	ld	a5,32(s2)
    80000990:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000992:	02993023          	sd	s1,32(s2)
  kmem.nfree++;
    80000996:	02893783          	ld	a5,40(s2)
    8000099a:	0785                	addi	a5,a5,1
    8000099c:	02f93423          	sd	a5,40(s2)
  release(&kmem.lock);
    800009a0:	854a                	mv	a0,s2
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	2ca080e7          	jalr	714(ra) # 80000c6c <release>
}
    800009aa:	60e2                	ld	ra,24(sp)
    800009ac:	6442                	ld	s0,16(sp)
    800009ae:	64a2                	ld	s1,8(sp)
    800009b0:	6902                	ld	s2,0(sp)
    800009b2:	6105                	addi	sp,sp,32
    800009b4:	8082                	ret
    panic("kfree");
    800009b6:	00008517          	auipc	a0,0x8
    800009ba:	7d250513          	addi	a0,a0,2002 # 80009188 <digits+0x18>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	bac080e7          	jalr	-1108(ra) # 8000056a <panic>

00000000800009c6 <freerange>:
{
    800009c6:	7179                	addi	sp,sp,-48
    800009c8:	f406                	sd	ra,40(sp)
    800009ca:	f022                	sd	s0,32(sp)
    800009cc:	ec26                	sd	s1,24(sp)
    800009ce:	e84a                	sd	s2,16(sp)
    800009d0:	e44e                	sd	s3,8(sp)
    800009d2:	e052                	sd	s4,0(sp)
    800009d4:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800009d6:	6785                	lui	a5,0x1
    800009d8:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800009dc:	94aa                	add	s1,s1,a0
    800009de:	757d                	lui	a0,0xfffff
    800009e0:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009e2:	94be                	add	s1,s1,a5
    800009e4:	0095ee63          	bltu	a1,s1,80000a00 <freerange+0x3a>
    800009e8:	892e                	mv	s2,a1
    kfree(p);
    800009ea:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009ec:	6985                	lui	s3,0x1
    kfree(p);
    800009ee:	01448533          	add	a0,s1,s4
    800009f2:	00000097          	auipc	ra,0x0
    800009f6:	f54080e7          	jalr	-172(ra) # 80000946 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009fa:	94ce                	add	s1,s1,s3
    800009fc:	fe9979e3          	bgeu	s2,s1,800009ee <freerange+0x28>
}
    80000a00:	70a2                	ld	ra,40(sp)
    80000a02:	7402                	ld	s0,32(sp)
    80000a04:	64e2                	ld	s1,24(sp)
    80000a06:	6942                	ld	s2,16(sp)
    80000a08:	69a2                	ld	s3,8(sp)
    80000a0a:	6a02                	ld	s4,0(sp)
    80000a0c:	6145                	addi	sp,sp,48
    80000a0e:	8082                	ret

0000000080000a10 <kinit>:
{
    80000a10:	1141                	addi	sp,sp,-16
    80000a12:	e406                	sd	ra,8(sp)
    80000a14:	e022                	sd	s0,0(sp)
    80000a16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a18:	00008597          	auipc	a1,0x8
    80000a1c:	77858593          	addi	a1,a1,1912 # 80009190 <digits+0x20>
    80000a20:	00012517          	auipc	a0,0x12
    80000a24:	81850513          	addi	a0,a0,-2024 # 80012238 <kmem>
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	09e080e7          	jalr	158(ra) # 80000ac6 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a30:	45c5                	li	a1,17
    80000a32:	05ee                	slli	a1,a1,0x1b
    80000a34:	00037517          	auipc	a0,0x37
    80000a38:	9ac50513          	addi	a0,a0,-1620 # 800373e0 <end>
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	f8a080e7          	jalr	-118(ra) # 800009c6 <freerange>
}
    80000a44:	60a2                	ld	ra,8(sp)
    80000a46:	6402                	ld	s0,0(sp)
    80000a48:	0141                	addi	sp,sp,16
    80000a4a:	8082                	ret

0000000080000a4c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a4c:	1101                	addi	sp,sp,-32
    80000a4e:	ec06                	sd	ra,24(sp)
    80000a50:	e822                	sd	s0,16(sp)
    80000a52:	e426                	sd	s1,8(sp)
    80000a54:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000a56:	00011497          	auipc	s1,0x11
    80000a5a:	7e248493          	addi	s1,s1,2018 # 80012238 <kmem>
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	13c080e7          	jalr	316(ra) # 80000b9c <acquire>
  r = kmem.freelist;
    80000a68:	7084                	ld	s1,32(s1)
  if(r){
    80000a6a:	c89d                	beqz	s1,80000aa0 <kalloc+0x54>
    kmem.freelist = r->next;
    80000a6c:	609c                	ld	a5,0(s1)
    80000a6e:	00011517          	auipc	a0,0x11
    80000a72:	7ca50513          	addi	a0,a0,1994 # 80012238 <kmem>
    80000a76:	f11c                	sd	a5,32(a0)
    kmem.nfree--;
    80000a78:	751c                	ld	a5,40(a0)
    80000a7a:	17fd                	addi	a5,a5,-1
    80000a7c:	f51c                	sd	a5,40(a0)
  }
  release(&kmem.lock);
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	1ee080e7          	jalr	494(ra) # 80000c6c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000a86:	6605                	lui	a2,0x1
    80000a88:	4595                	li	a1,5
    80000a8a:	8526                	mv	a0,s1
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	3f4080e7          	jalr	1012(ra) # 80000e80 <memset>
  return (void*)r;
}
    80000a94:	8526                	mv	a0,s1
    80000a96:	60e2                	ld	ra,24(sp)
    80000a98:	6442                	ld	s0,16(sp)
    80000a9a:	64a2                	ld	s1,8(sp)
    80000a9c:	6105                	addi	sp,sp,32
    80000a9e:	8082                	ret
  release(&kmem.lock);
    80000aa0:	00011517          	auipc	a0,0x11
    80000aa4:	79850513          	addi	a0,a0,1944 # 80012238 <kmem>
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	1c4080e7          	jalr	452(ra) # 80000c6c <release>
  if(r)
    80000ab0:	b7d5                	j	80000a94 <kalloc+0x48>

0000000080000ab2 <sys_nfree>:

uint64
sys_nfree(void)
{
    80000ab2:	1141                	addi	sp,sp,-16
    80000ab4:	e422                	sd	s0,8(sp)
    80000ab6:	0800                	addi	s0,sp,16
  return kmem.nfree;
}
    80000ab8:	00011517          	auipc	a0,0x11
    80000abc:	7a853503          	ld	a0,1960(a0) # 80012260 <kmem+0x28>
    80000ac0:	6422                	ld	s0,8(sp)
    80000ac2:	0141                	addi	sp,sp,16
    80000ac4:	8082                	ret

0000000080000ac6 <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000ac6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ac8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000acc:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000ad0:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    80000ad4:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    80000ad8:	00009797          	auipc	a5,0x9
    80000adc:	4ec7a783          	lw	a5,1260(a5) # 80009fc4 <nlock>
    80000ae0:	6709                	lui	a4,0x2
    80000ae2:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000ae6:	02f74063          	blt	a4,a5,80000b06 <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000aea:	00379693          	slli	a3,a5,0x3
    80000aee:	00011717          	auipc	a4,0x11
    80000af2:	77a70713          	addi	a4,a4,1914 # 80012268 <locks>
    80000af6:	9736                	add	a4,a4,a3
    80000af8:	e308                	sd	a0,0(a4)
  nlock++;
    80000afa:	2785                	addiw	a5,a5,1
    80000afc:	00009717          	auipc	a4,0x9
    80000b00:	4cf72423          	sw	a5,1224(a4) # 80009fc4 <nlock>
    80000b04:	8082                	ret
{
    80000b06:	1141                	addi	sp,sp,-16
    80000b08:	e406                	sd	ra,8(sp)
    80000b0a:	e022                	sd	s0,0(sp)
    80000b0c:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b0e:	00008517          	auipc	a0,0x8
    80000b12:	68a50513          	addi	a0,a0,1674 # 80009198 <digits+0x28>
    80000b16:	00000097          	auipc	ra,0x0
    80000b1a:	a54080e7          	jalr	-1452(ra) # 8000056a <panic>

0000000080000b1e <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b1e:	411c                	lw	a5,0(a0)
    80000b20:	e399                	bnez	a5,80000b26 <holding+0x8>
    80000b22:	4501                	li	a0,0
  return r;
}
    80000b24:	8082                	ret
{
    80000b26:	1101                	addi	sp,sp,-32
    80000b28:	ec06                	sd	ra,24(sp)
    80000b2a:	e822                	sd	s0,16(sp)
    80000b2c:	e426                	sd	s1,8(sp)
    80000b2e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b30:	6904                	ld	s1,16(a0)
    80000b32:	00001097          	auipc	ra,0x1
    80000b36:	048080e7          	jalr	72(ra) # 80001b7a <mycpu>
    80000b3a:	40a48533          	sub	a0,s1,a0
    80000b3e:	00153513          	seqz	a0,a0
}
    80000b42:	60e2                	ld	ra,24(sp)
    80000b44:	6442                	ld	s0,16(sp)
    80000b46:	64a2                	ld	s1,8(sp)
    80000b48:	6105                	addi	sp,sp,32
    80000b4a:	8082                	ret

0000000080000b4c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b4c:	1101                	addi	sp,sp,-32
    80000b4e:	ec06                	sd	ra,24(sp)
    80000b50:	e822                	sd	s0,16(sp)
    80000b52:	e426                	sd	s1,8(sp)
    80000b54:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b56:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b5a:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000b5c:	c491                	beqz	s1,80000b68 <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b62:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b64:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000b68:	00001097          	auipc	ra,0x1
    80000b6c:	012080e7          	jalr	18(ra) # 80001b7a <mycpu>
    80000b70:	5d3c                	lw	a5,120(a0)
    80000b72:	cf89                	beqz	a5,80000b8c <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b74:	00001097          	auipc	ra,0x1
    80000b78:	006080e7          	jalr	6(ra) # 80001b7a <mycpu>
    80000b7c:	5d3c                	lw	a5,120(a0)
    80000b7e:	2785                	addiw	a5,a5,1
    80000b80:	dd3c                	sw	a5,120(a0)
}
    80000b82:	60e2                	ld	ra,24(sp)
    80000b84:	6442                	ld	s0,16(sp)
    80000b86:	64a2                	ld	s1,8(sp)
    80000b88:	6105                	addi	sp,sp,32
    80000b8a:	8082                	ret
    mycpu()->intena = old;
    80000b8c:	00001097          	auipc	ra,0x1
    80000b90:	fee080e7          	jalr	-18(ra) # 80001b7a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b94:	009034b3          	snez	s1,s1
    80000b98:	dd64                	sw	s1,124(a0)
    80000b9a:	bfe9                	j	80000b74 <push_off+0x28>

0000000080000b9c <acquire>:
{
    80000b9c:	1101                	addi	sp,sp,-32
    80000b9e:	ec06                	sd	ra,24(sp)
    80000ba0:	e822                	sd	s0,16(sp)
    80000ba2:	e426                	sd	s1,8(sp)
    80000ba4:	1000                	addi	s0,sp,32
    80000ba6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	fa4080e7          	jalr	-92(ra) # 80000b4c <push_off>
  if(holding(lk))
    80000bb0:	8526                	mv	a0,s1
    80000bb2:	00000097          	auipc	ra,0x0
    80000bb6:	f6c080e7          	jalr	-148(ra) # 80000b1e <holding>
    80000bba:	e911                	bnez	a0,80000bce <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000bbc:	4785                	li	a5,1
    80000bbe:	01848713          	addi	a4,s1,24
    80000bc2:	0f50000f          	fence	iorw,ow
    80000bc6:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000bca:	4705                	li	a4,1
    80000bcc:	a839                	j	80000bea <acquire+0x4e>
    panic("acquire");
    80000bce:	00008517          	auipc	a0,0x8
    80000bd2:	5da50513          	addi	a0,a0,1498 # 800091a8 <digits+0x38>
    80000bd6:	00000097          	auipc	ra,0x0
    80000bda:	994080e7          	jalr	-1644(ra) # 8000056a <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000bde:	01c48793          	addi	a5,s1,28
    80000be2:	0f50000f          	fence	iorw,ow
    80000be6:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000bea:	87ba                	mv	a5,a4
    80000bec:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf0:	2781                	sext.w	a5,a5
    80000bf2:	f7f5                	bnez	a5,80000bde <acquire+0x42>
  __sync_synchronize();
    80000bf4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf8:	00001097          	auipc	ra,0x1
    80000bfc:	f82080e7          	jalr	-126(ra) # 80001b7a <mycpu>
    80000c00:	e888                	sd	a0,16(s1)
}
    80000c02:	60e2                	ld	ra,24(sp)
    80000c04:	6442                	ld	s0,16(sp)
    80000c06:	64a2                	ld	s1,8(sp)
    80000c08:	6105                	addi	sp,sp,32
    80000c0a:	8082                	ret

0000000080000c0c <pop_off>:

void
pop_off(void)
{
    80000c0c:	1141                	addi	sp,sp,-16
    80000c0e:	e406                	sd	ra,8(sp)
    80000c10:	e022                	sd	s0,0(sp)
    80000c12:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c18:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c1a:	eb8d                	bnez	a5,80000c4c <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000c1c:	00001097          	auipc	ra,0x1
    80000c20:	f5e080e7          	jalr	-162(ra) # 80001b7a <mycpu>
  if(c->noff < 1)
    80000c24:	5d3c                	lw	a5,120(a0)
    80000c26:	02f05b63          	blez	a5,80000c5c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c2a:	37fd                	addiw	a5,a5,-1
    80000c2c:	0007871b          	sext.w	a4,a5
    80000c30:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c32:	eb09                	bnez	a4,80000c44 <pop_off+0x38>
    80000c34:	5d7c                	lw	a5,124(a0)
    80000c36:	c799                	beqz	a5,80000c44 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c40:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c44:	60a2                	ld	ra,8(sp)
    80000c46:	6402                	ld	s0,0(sp)
    80000c48:	0141                	addi	sp,sp,16
    80000c4a:	8082                	ret
    panic("pop_off - interruptible");
    80000c4c:	00008517          	auipc	a0,0x8
    80000c50:	56450513          	addi	a0,a0,1380 # 800091b0 <digits+0x40>
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	916080e7          	jalr	-1770(ra) # 8000056a <panic>
    panic("pop_off");
    80000c5c:	00008517          	auipc	a0,0x8
    80000c60:	56c50513          	addi	a0,a0,1388 # 800091c8 <digits+0x58>
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	906080e7          	jalr	-1786(ra) # 8000056a <panic>

0000000080000c6c <release>:
{
    80000c6c:	1101                	addi	sp,sp,-32
    80000c6e:	ec06                	sd	ra,24(sp)
    80000c70:	e822                	sd	s0,16(sp)
    80000c72:	e426                	sd	s1,8(sp)
    80000c74:	1000                	addi	s0,sp,32
    80000c76:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	ea6080e7          	jalr	-346(ra) # 80000b1e <holding>
    80000c80:	c115                	beqz	a0,80000ca4 <release+0x38>
  lk->cpu = 0;
    80000c82:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c86:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c8a:	0f50000f          	fence	iorw,ow
    80000c8e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	f7a080e7          	jalr	-134(ra) # 80000c0c <pop_off>
}
    80000c9a:	60e2                	ld	ra,24(sp)
    80000c9c:	6442                	ld	s0,16(sp)
    80000c9e:	64a2                	ld	s1,8(sp)
    80000ca0:	6105                	addi	sp,sp,32
    80000ca2:	8082                	ret
    panic("release");
    80000ca4:	00008517          	auipc	a0,0x8
    80000ca8:	52c50513          	addi	a0,a0,1324 # 800091d0 <digits+0x60>
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	8be080e7          	jalr	-1858(ra) # 8000056a <panic>

0000000080000cb4 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000cb4:	4d14                	lw	a3,24(a0)
    80000cb6:	e291                	bnez	a3,80000cba <print_lock+0x6>
    80000cb8:	8082                	ret
{
    80000cba:	1141                	addi	sp,sp,-16
    80000cbc:	e406                	sd	ra,8(sp)
    80000cbe:	e022                	sd	s0,0(sp)
    80000cc0:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000cc2:	4d50                	lw	a2,28(a0)
    80000cc4:	650c                	ld	a1,8(a0)
    80000cc6:	00008517          	auipc	a0,0x8
    80000cca:	51250513          	addi	a0,a0,1298 # 800091d8 <digits+0x68>
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	8fe080e7          	jalr	-1794(ra) # 800005cc <printf>
}
    80000cd6:	60a2                	ld	ra,8(sp)
    80000cd8:	6402                	ld	s0,0(sp)
    80000cda:	0141                	addi	sp,sp,16
    80000cdc:	8082                	ret

0000000080000cde <sys_ntas>:

uint64
sys_ntas(void)
{
    80000cde:	711d                	addi	sp,sp,-96
    80000ce0:	ec86                	sd	ra,88(sp)
    80000ce2:	e8a2                	sd	s0,80(sp)
    80000ce4:	e4a6                	sd	s1,72(sp)
    80000ce6:	e0ca                	sd	s2,64(sp)
    80000ce8:	fc4e                	sd	s3,56(sp)
    80000cea:	f852                	sd	s4,48(sp)
    80000cec:	f456                	sd	s5,40(sp)
    80000cee:	f05a                	sd	s6,32(sp)
    80000cf0:	ec5e                	sd	s7,24(sp)
    80000cf2:	1080                	addi	s0,sp,96
  int zero = 0;
    80000cf4:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000cf8:	fac40593          	addi	a1,s0,-84
    80000cfc:	4501                	li	a0,0
    80000cfe:	00002097          	auipc	ra,0x2
    80000d02:	07a080e7          	jalr	122(ra) # 80002d78 <argint>
    80000d06:	12054463          	bltz	a0,80000e2e <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d0a:	fac42783          	lw	a5,-84(s0)
    80000d0e:	e39d                	bnez	a5,80000d34 <sys_ntas+0x56>
    80000d10:	00011797          	auipc	a5,0x11
    80000d14:	55878793          	addi	a5,a5,1368 # 80012268 <locks>
    80000d18:	00025697          	auipc	a3,0x25
    80000d1c:	dd068693          	addi	a3,a3,-560 # 80025ae8 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000d20:	6398                	ld	a4,0(a5)
    80000d22:	10070863          	beqz	a4,80000e32 <sys_ntas+0x154>
        break;
      locks[i]->nts = 0;
    80000d26:	00072e23          	sw	zero,28(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000d2a:	07a1                	addi	a5,a5,8
    80000d2c:	fed79ae3          	bne	a5,a3,80000d20 <sys_ntas+0x42>
    }
    return 0;
    80000d30:	4501                	li	a0,0
    80000d32:	a0dd                	j	80000e18 <sys_ntas+0x13a>
  }

  printf("=== lock kmem stats\n");
    80000d34:	00008517          	auipc	a0,0x8
    80000d38:	4d450513          	addi	a0,a0,1236 # 80009208 <digits+0x98>
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	890080e7          	jalr	-1904(ra) # 800005cc <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000d44:	00011b17          	auipc	s6,0x11
    80000d48:	524b0b13          	addi	s6,s6,1316 # 80012268 <locks>
    80000d4c:	00025b97          	auipc	s7,0x25
    80000d50:	d9cb8b93          	addi	s7,s7,-612 # 80025ae8 <pid_lock>
  printf("=== lock kmem stats\n");
    80000d54:	84da                	mv	s1,s6
  int tot = 0;
    80000d56:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d58:	00008917          	auipc	s2,0x8
    80000d5c:	43890913          	addi	s2,s2,1080 # 80009190 <digits+0x20>
    80000d60:	a821                	j	80000d78 <sys_ntas+0x9a>
      tot += locks[i]->nts;
    80000d62:	6088                	ld	a0,0(s1)
    80000d64:	4d5c                	lw	a5,28(a0)
    80000d66:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000d6a:	00000097          	auipc	ra,0x0
    80000d6e:	f4a080e7          	jalr	-182(ra) # 80000cb4 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000d72:	04a1                	addi	s1,s1,8
    80000d74:	03748563          	beq	s1,s7,80000d9e <sys_ntas+0xc0>
    if(locks[i] == 0)
    80000d78:	609c                	ld	a5,0(s1)
    80000d7a:	c395                	beqz	a5,80000d9e <sys_ntas+0xc0>
    if(strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d7c:	0087ba03          	ld	s4,8(a5)
    80000d80:	854a                	mv	a0,s2
    80000d82:	00000097          	auipc	ra,0x0
    80000d86:	2ae080e7          	jalr	686(ra) # 80001030 <strlen>
    80000d8a:	0005061b          	sext.w	a2,a0
    80000d8e:	85ca                	mv	a1,s2
    80000d90:	8552                	mv	a0,s4
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	1f2080e7          	jalr	498(ra) # 80000f84 <strncmp>
    80000d9a:	fd61                	bnez	a0,80000d72 <sys_ntas+0x94>
    80000d9c:	b7d9                	j	80000d62 <sys_ntas+0x84>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000d9e:	00008517          	auipc	a0,0x8
    80000da2:	48250513          	addi	a0,a0,1154 # 80009220 <digits+0xb0>
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	826080e7          	jalr	-2010(ra) # 800005cc <printf>
    80000dae:	4a15                	li	s4,5
  int last = 100000000;
    80000db0:	05f5e537          	lui	a0,0x5f5e
    80000db4:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000db8:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000dba:	00011497          	auipc	s1,0x11
    80000dbe:	4ae48493          	addi	s1,s1,1198 # 80012268 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000dc2:	6909                	lui	s2,0x2
    80000dc4:	71090913          	addi	s2,s2,1808 # 2710 <_entry-0x7fffd8f0>
    80000dc8:	a091                	j	80000e0c <sys_ntas+0x12e>
    80000dca:	2705                	addiw	a4,a4,1
    80000dcc:	06a1                	addi	a3,a3,8
    80000dce:	03270063          	beq	a4,s2,80000dee <sys_ntas+0x110>
      if(locks[i] == 0)
    80000dd2:	629c                	ld	a5,0(a3)
    80000dd4:	cf89                	beqz	a5,80000dee <sys_ntas+0x110>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000dd6:	4fd0                	lw	a2,28(a5)
    80000dd8:	00359793          	slli	a5,a1,0x3
    80000ddc:	97a6                	add	a5,a5,s1
    80000dde:	639c                	ld	a5,0(a5)
    80000de0:	4fdc                	lw	a5,28(a5)
    80000de2:	fec7f4e3          	bgeu	a5,a2,80000dca <sys_ntas+0xec>
    80000de6:	fea672e3          	bgeu	a2,a0,80000dca <sys_ntas+0xec>
    80000dea:	85ba                	mv	a1,a4
    80000dec:	bff9                	j	80000dca <sys_ntas+0xec>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000dee:	058e                	slli	a1,a1,0x3
    80000df0:	00b48bb3          	add	s7,s1,a1
    80000df4:	000bb503          	ld	a0,0(s7)
    80000df8:	00000097          	auipc	ra,0x0
    80000dfc:	ebc080e7          	jalr	-324(ra) # 80000cb4 <print_lock>
    last = locks[top]->nts;
    80000e00:	000bb783          	ld	a5,0(s7)
    80000e04:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000e06:	3a7d                	addiw	s4,s4,-1
    80000e08:	000a0763          	beqz	s4,80000e16 <sys_ntas+0x138>
  int tot = 0;
    80000e0c:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000e0e:	8756                	mv	a4,s5
    int top = 0;
    80000e10:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e12:	2501                	sext.w	a0,a0
    80000e14:	bf7d                	j	80000dd2 <sys_ntas+0xf4>
  }
  return tot;
    80000e16:	854e                	mv	a0,s3
}
    80000e18:	60e6                	ld	ra,88(sp)
    80000e1a:	6446                	ld	s0,80(sp)
    80000e1c:	64a6                	ld	s1,72(sp)
    80000e1e:	6906                	ld	s2,64(sp)
    80000e20:	79e2                	ld	s3,56(sp)
    80000e22:	7a42                	ld	s4,48(sp)
    80000e24:	7aa2                	ld	s5,40(sp)
    80000e26:	7b02                	ld	s6,32(sp)
    80000e28:	6be2                	ld	s7,24(sp)
    80000e2a:	6125                	addi	sp,sp,96
    80000e2c:	8082                	ret
    return -1;
    80000e2e:	557d                	li	a0,-1
    80000e30:	b7e5                	j	80000e18 <sys_ntas+0x13a>
    return 0;
    80000e32:	4501                	li	a0,0
    80000e34:	b7d5                	j	80000e18 <sys_ntas+0x13a>

0000000080000e36 <atoi>:
#include "types.h"

int
atoi(const char *s)
{
    80000e36:	1141                	addi	sp,sp,-16
    80000e38:	e422                	sd	s0,8(sp)
    80000e3a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    80000e3c:	00054603          	lbu	a2,0(a0)
    80000e40:	fd06079b          	addiw	a5,a2,-48
    80000e44:	0ff7f793          	andi	a5,a5,255
    80000e48:	4725                	li	a4,9
    80000e4a:	02f76963          	bltu	a4,a5,80000e7c <atoi+0x46>
    80000e4e:	86aa                	mv	a3,a0
  n = 0;
    80000e50:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    80000e52:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    80000e54:	0685                	addi	a3,a3,1
    80000e56:	0025179b          	slliw	a5,a0,0x2
    80000e5a:	9fa9                	addw	a5,a5,a0
    80000e5c:	0017979b          	slliw	a5,a5,0x1
    80000e60:	9fb1                	addw	a5,a5,a2
    80000e62:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    80000e66:	0006c603          	lbu	a2,0(a3)
    80000e6a:	fd06071b          	addiw	a4,a2,-48
    80000e6e:	0ff77713          	andi	a4,a4,255
    80000e72:	fee5f1e3          	bgeu	a1,a4,80000e54 <atoi+0x1e>
  return n;
}
    80000e76:	6422                	ld	s0,8(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret
  n = 0;
    80000e7c:	4501                	li	a0,0
    80000e7e:	bfe5                	j	80000e76 <atoi+0x40>

0000000080000e80 <memset>:

void*
memset(void *dst, int c, uint n)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e86:	ce09                	beqz	a2,80000ea0 <memset+0x20>
    80000e88:	87aa                	mv	a5,a0
    80000e8a:	fff6071b          	addiw	a4,a2,-1
    80000e8e:	1702                	slli	a4,a4,0x20
    80000e90:	9301                	srli	a4,a4,0x20
    80000e92:	0705                	addi	a4,a4,1
    80000e94:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000e96:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e9a:	0785                	addi	a5,a5,1
    80000e9c:	fee79de3          	bne	a5,a4,80000e96 <memset+0x16>
  }
  return dst;
}
    80000ea0:	6422                	ld	s0,8(sp)
    80000ea2:	0141                	addi	sp,sp,16
    80000ea4:	8082                	ret

0000000080000ea6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000eac:	ca05                	beqz	a2,80000edc <memcmp+0x36>
    80000eae:	fff6069b          	addiw	a3,a2,-1
    80000eb2:	1682                	slli	a3,a3,0x20
    80000eb4:	9281                	srli	a3,a3,0x20
    80000eb6:	0685                	addi	a3,a3,1
    80000eb8:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000eba:	00054783          	lbu	a5,0(a0)
    80000ebe:	0005c703          	lbu	a4,0(a1)
    80000ec2:	00e79863          	bne	a5,a4,80000ed2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ec6:	0505                	addi	a0,a0,1
    80000ec8:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000eca:	fed518e3          	bne	a0,a3,80000eba <memcmp+0x14>
  }

  return 0;
    80000ece:	4501                	li	a0,0
    80000ed0:	a019                	j	80000ed6 <memcmp+0x30>
      return *s1 - *s2;
    80000ed2:	40e7853b          	subw	a0,a5,a4
}
    80000ed6:	6422                	ld	s0,8(sp)
    80000ed8:	0141                	addi	sp,sp,16
    80000eda:	8082                	ret
  return 0;
    80000edc:	4501                	li	a0,0
    80000ede:	bfe5                	j	80000ed6 <memcmp+0x30>

0000000080000ee0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ee0:	1141                	addi	sp,sp,-16
    80000ee2:	e422                	sd	s0,8(sp)
    80000ee4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ee6:	ca0d                	beqz	a2,80000f18 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ee8:	00a5f963          	bgeu	a1,a0,80000efa <memmove+0x1a>
    80000eec:	02061693          	slli	a3,a2,0x20
    80000ef0:	9281                	srli	a3,a3,0x20
    80000ef2:	00d58733          	add	a4,a1,a3
    80000ef6:	02e56463          	bltu	a0,a4,80000f1e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000efa:	fff6079b          	addiw	a5,a2,-1
    80000efe:	1782                	slli	a5,a5,0x20
    80000f00:	9381                	srli	a5,a5,0x20
    80000f02:	0785                	addi	a5,a5,1
    80000f04:	97ae                	add	a5,a5,a1
    80000f06:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f08:	0585                	addi	a1,a1,1
    80000f0a:	0705                	addi	a4,a4,1
    80000f0c:	fff5c683          	lbu	a3,-1(a1)
    80000f10:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f14:	fef59ae3          	bne	a1,a5,80000f08 <memmove+0x28>

  return dst;
}
    80000f18:	6422                	ld	s0,8(sp)
    80000f1a:	0141                	addi	sp,sp,16
    80000f1c:	8082                	ret
    d += n;
    80000f1e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f20:	fff6079b          	addiw	a5,a2,-1
    80000f24:	1782                	slli	a5,a5,0x20
    80000f26:	9381                	srli	a5,a5,0x20
    80000f28:	fff7c793          	not	a5,a5
    80000f2c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f2e:	177d                	addi	a4,a4,-1
    80000f30:	16fd                	addi	a3,a3,-1
    80000f32:	00074603          	lbu	a2,0(a4)
    80000f36:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f3a:	fef71ae3          	bne	a4,a5,80000f2e <memmove+0x4e>
    80000f3e:	bfe9                	j	80000f18 <memmove+0x38>

0000000080000f40 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f40:	1141                	addi	sp,sp,-16
    80000f42:	e406                	sd	ra,8(sp)
    80000f44:	e022                	sd	s0,0(sp)
    80000f46:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f48:	00000097          	auipc	ra,0x0
    80000f4c:	f98080e7          	jalr	-104(ra) # 80000ee0 <memmove>
}
    80000f50:	60a2                	ld	ra,8(sp)
    80000f52:	6402                	ld	s0,0(sp)
    80000f54:	0141                	addi	sp,sp,16
    80000f56:	8082                	ret

0000000080000f58 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    80000f58:	1141                	addi	sp,sp,-16
    80000f5a:	e422                	sd	s0,8(sp)
    80000f5c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    80000f5e:	00054783          	lbu	a5,0(a0)
    80000f62:	cb91                	beqz	a5,80000f76 <strcmp+0x1e>
    80000f64:	0005c703          	lbu	a4,0(a1)
    80000f68:	00f71763          	bne	a4,a5,80000f76 <strcmp+0x1e>
    p++, q++;
    80000f6c:	0505                	addi	a0,a0,1
    80000f6e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    80000f70:	00054783          	lbu	a5,0(a0)
    80000f74:	fbe5                	bnez	a5,80000f64 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    80000f76:	0005c503          	lbu	a0,0(a1)
}
    80000f7a:	40a7853b          	subw	a0,a5,a0
    80000f7e:	6422                	ld	s0,8(sp)
    80000f80:	0141                	addi	sp,sp,16
    80000f82:	8082                	ret

0000000080000f84 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f84:	1141                	addi	sp,sp,-16
    80000f86:	e422                	sd	s0,8(sp)
    80000f88:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f8a:	ce11                	beqz	a2,80000fa6 <strncmp+0x22>
    80000f8c:	00054783          	lbu	a5,0(a0)
    80000f90:	cf89                	beqz	a5,80000faa <strncmp+0x26>
    80000f92:	0005c703          	lbu	a4,0(a1)
    80000f96:	00f71a63          	bne	a4,a5,80000faa <strncmp+0x26>
    n--, p++, q++;
    80000f9a:	367d                	addiw	a2,a2,-1
    80000f9c:	0505                	addi	a0,a0,1
    80000f9e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000fa0:	f675                	bnez	a2,80000f8c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000fa2:	4501                	li	a0,0
    80000fa4:	a809                	j	80000fb6 <strncmp+0x32>
    80000fa6:	4501                	li	a0,0
    80000fa8:	a039                	j	80000fb6 <strncmp+0x32>
  if(n == 0)
    80000faa:	ca09                	beqz	a2,80000fbc <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000fac:	00054503          	lbu	a0,0(a0)
    80000fb0:	0005c783          	lbu	a5,0(a1)
    80000fb4:	9d1d                	subw	a0,a0,a5
}
    80000fb6:	6422                	ld	s0,8(sp)
    80000fb8:	0141                	addi	sp,sp,16
    80000fba:	8082                	ret
    return 0;
    80000fbc:	4501                	li	a0,0
    80000fbe:	bfe5                	j	80000fb6 <strncmp+0x32>

0000000080000fc0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fc0:	1141                	addi	sp,sp,-16
    80000fc2:	e422                	sd	s0,8(sp)
    80000fc4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fc6:	872a                	mv	a4,a0
    80000fc8:	8832                	mv	a6,a2
    80000fca:	367d                	addiw	a2,a2,-1
    80000fcc:	01005963          	blez	a6,80000fde <strncpy+0x1e>
    80000fd0:	0705                	addi	a4,a4,1
    80000fd2:	0005c783          	lbu	a5,0(a1)
    80000fd6:	fef70fa3          	sb	a5,-1(a4)
    80000fda:	0585                	addi	a1,a1,1
    80000fdc:	f7f5                	bnez	a5,80000fc8 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fde:	00c05d63          	blez	a2,80000ff8 <strncpy+0x38>
    80000fe2:	86ba                	mv	a3,a4
    *s++ = 0;
    80000fe4:	0685                	addi	a3,a3,1
    80000fe6:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fea:	fff6c793          	not	a5,a3
    80000fee:	9fb9                	addw	a5,a5,a4
    80000ff0:	010787bb          	addw	a5,a5,a6
    80000ff4:	fef048e3          	bgtz	a5,80000fe4 <strncpy+0x24>
  return os;
}
    80000ff8:	6422                	ld	s0,8(sp)
    80000ffa:	0141                	addi	sp,sp,16
    80000ffc:	8082                	ret

0000000080000ffe <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ffe:	1141                	addi	sp,sp,-16
    80001000:	e422                	sd	s0,8(sp)
    80001002:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001004:	02c05363          	blez	a2,8000102a <safestrcpy+0x2c>
    80001008:	fff6069b          	addiw	a3,a2,-1
    8000100c:	1682                	slli	a3,a3,0x20
    8000100e:	9281                	srli	a3,a3,0x20
    80001010:	96ae                	add	a3,a3,a1
    80001012:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001014:	00d58963          	beq	a1,a3,80001026 <safestrcpy+0x28>
    80001018:	0585                	addi	a1,a1,1
    8000101a:	0785                	addi	a5,a5,1
    8000101c:	fff5c703          	lbu	a4,-1(a1)
    80001020:	fee78fa3          	sb	a4,-1(a5)
    80001024:	fb65                	bnez	a4,80001014 <safestrcpy+0x16>
    ;
  *s = 0;
    80001026:	00078023          	sb	zero,0(a5)
  return os;
}
    8000102a:	6422                	ld	s0,8(sp)
    8000102c:	0141                	addi	sp,sp,16
    8000102e:	8082                	ret

0000000080001030 <strlen>:

int
strlen(const char *s)
{
    80001030:	1141                	addi	sp,sp,-16
    80001032:	e422                	sd	s0,8(sp)
    80001034:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001036:	00054783          	lbu	a5,0(a0)
    8000103a:	cf91                	beqz	a5,80001056 <strlen+0x26>
    8000103c:	0505                	addi	a0,a0,1
    8000103e:	87aa                	mv	a5,a0
    80001040:	4685                	li	a3,1
    80001042:	9e89                	subw	a3,a3,a0
    80001044:	00f6853b          	addw	a0,a3,a5
    80001048:	0785                	addi	a5,a5,1
    8000104a:	fff7c703          	lbu	a4,-1(a5)
    8000104e:	fb7d                	bnez	a4,80001044 <strlen+0x14>
    ;
  return n;
}
    80001050:	6422                	ld	s0,8(sp)
    80001052:	0141                	addi	sp,sp,16
    80001054:	8082                	ret
  for(n = 0; s[n]; n++)
    80001056:	4501                	li	a0,0
    80001058:	bfe5                	j	80001050 <strlen+0x20>

000000008000105a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000105a:	1141                	addi	sp,sp,-16
    8000105c:	e406                	sd	ra,8(sp)
    8000105e:	e022                	sd	s0,0(sp)
    80001060:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001062:	00001097          	auipc	ra,0x1
    80001066:	b08080e7          	jalr	-1272(ra) # 80001b6a <cpuid>
    userinit();      // first user process
    test_rcu();
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000106a:	00009717          	auipc	a4,0x9
    8000106e:	f5e70713          	addi	a4,a4,-162 # 80009fc8 <started>
  if(cpuid() == 0){
    80001072:	c139                	beqz	a0,800010b8 <main+0x5e>
    while(started == 0)
    80001074:	431c                	lw	a5,0(a4)
    80001076:	2781                	sext.w	a5,a5
    80001078:	dff5                	beqz	a5,80001074 <main+0x1a>
      ;
    __sync_synchronize();
    8000107a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000107e:	00001097          	auipc	ra,0x1
    80001082:	aec080e7          	jalr	-1300(ra) # 80001b6a <cpuid>
    80001086:	85aa                	mv	a1,a0
    80001088:	00008517          	auipc	a0,0x8
    8000108c:	1d050513          	addi	a0,a0,464 # 80009258 <digits+0xe8>
    80001090:	fffff097          	auipc	ra,0xfffff
    80001094:	53c080e7          	jalr	1340(ra) # 800005cc <printf>
    kvminithart();    // turn on paging
    80001098:	00000097          	auipc	ra,0x0
    8000109c:	1f0080e7          	jalr	496(ra) # 80001288 <kvminithart>
    trapinithart();   // install kernel trap vector
    800010a0:	00002097          	auipc	ra,0x2
    800010a4:	86e080e7          	jalr	-1938(ra) # 8000290e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010a8:	00005097          	auipc	ra,0x5
    800010ac:	dc8080e7          	jalr	-568(ra) # 80005e70 <plicinithart>
  }

  scheduler();        
    800010b0:	00001097          	auipc	ra,0x1
    800010b4:	fcc080e7          	jalr	-52(ra) # 8000207c <scheduler>
    consoleinit();
    800010b8:	fffff097          	auipc	ra,0xfffff
    800010bc:	3c4080e7          	jalr	964(ra) # 8000047c <consoleinit>
    printfinit();
    800010c0:	fffff097          	auipc	ra,0xfffff
    800010c4:	7a0080e7          	jalr	1952(ra) # 80000860 <printfinit>
    printf("\n");
    800010c8:	00008517          	auipc	a0,0x8
    800010cc:	13850513          	addi	a0,a0,312 # 80009200 <digits+0x90>
    800010d0:	fffff097          	auipc	ra,0xfffff
    800010d4:	4fc080e7          	jalr	1276(ra) # 800005cc <printf>
    printf("xv6 kernel is booting\n");
    800010d8:	00008517          	auipc	a0,0x8
    800010dc:	16850513          	addi	a0,a0,360 # 80009240 <digits+0xd0>
    800010e0:	fffff097          	auipc	ra,0xfffff
    800010e4:	4ec080e7          	jalr	1260(ra) # 800005cc <printf>
    printf("\n");
    800010e8:	00008517          	auipc	a0,0x8
    800010ec:	11850513          	addi	a0,a0,280 # 80009200 <digits+0x90>
    800010f0:	fffff097          	auipc	ra,0xfffff
    800010f4:	4dc080e7          	jalr	1244(ra) # 800005cc <printf>
    kinit();         // physical page allocator
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	918080e7          	jalr	-1768(ra) # 80000a10 <kinit>
    kvminit();       // create kernel page table
    80001100:	00000097          	auipc	ra,0x0
    80001104:	2c6080e7          	jalr	710(ra) # 800013c6 <kvminit>
    kvminithart();   // turn on paging
    80001108:	00000097          	auipc	ra,0x0
    8000110c:	180080e7          	jalr	384(ra) # 80001288 <kvminithart>
    procinit();      // process table
    80001110:	00001097          	auipc	ra,0x1
    80001114:	98a080e7          	jalr	-1654(ra) # 80001a9a <procinit>
    trapinit();      // trap vectors
    80001118:	00001097          	auipc	ra,0x1
    8000111c:	7ce080e7          	jalr	1998(ra) # 800028e6 <trapinit>
    trapinithart();  // install kernel trap vector
    80001120:	00001097          	auipc	ra,0x1
    80001124:	7ee080e7          	jalr	2030(ra) # 8000290e <trapinithart>
    plicinit();      // set up interrupt controller
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	d32080e7          	jalr	-718(ra) # 80005e5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001130:	00005097          	auipc	ra,0x5
    80001134:	d40080e7          	jalr	-704(ra) # 80005e70 <plicinithart>
    binit();         // buffer cache
    80001138:	00002097          	auipc	ra,0x2
    8000113c:	f22080e7          	jalr	-222(ra) # 8000305a <binit>
    iinit();         // inode cache
    80001140:	00002097          	auipc	ra,0x2
    80001144:	5b2080e7          	jalr	1458(ra) # 800036f2 <iinit>
    fileinit();      // file table
    80001148:	00003097          	auipc	ra,0x3
    8000114c:	54a080e7          	jalr	1354(ra) # 80004692 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001150:	00005097          	auipc	ra,0x5
    80001154:	e18080e7          	jalr	-488(ra) # 80005f68 <virtio_disk_init>
    userinit();      // first user process
    80001158:	00001097          	auipc	ra,0x1
    8000115c:	cbe080e7          	jalr	-834(ra) # 80001e16 <userinit>
    test_rcu();
    80001160:	00001097          	auipc	ra,0x1
    80001164:	5b6080e7          	jalr	1462(ra) # 80002716 <test_rcu>
    __sync_synchronize();
    80001168:	0ff0000f          	fence
    started = 1;
    8000116c:	4785                	li	a5,1
    8000116e:	00009717          	auipc	a4,0x9
    80001172:	e4f72d23          	sw	a5,-422(a4) # 80009fc8 <started>
    80001176:	bf2d                	j	800010b0 <main+0x56>

0000000080001178 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001178:	7139                	addi	sp,sp,-64
    8000117a:	fc06                	sd	ra,56(sp)
    8000117c:	f822                	sd	s0,48(sp)
    8000117e:	f426                	sd	s1,40(sp)
    80001180:	f04a                	sd	s2,32(sp)
    80001182:	ec4e                	sd	s3,24(sp)
    80001184:	e852                	sd	s4,16(sp)
    80001186:	e456                	sd	s5,8(sp)
    80001188:	e05a                	sd	s6,0(sp)
    8000118a:	0080                	addi	s0,sp,64
    8000118c:	84aa                	mv	s1,a0
    8000118e:	89ae                	mv	s3,a1
    80001190:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001192:	57fd                	li	a5,-1
    80001194:	83e9                	srli	a5,a5,0x1a
    80001196:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001198:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000119a:	04b7f263          	bgeu	a5,a1,800011de <walk+0x66>
    panic("walk");
    8000119e:	00008517          	auipc	a0,0x8
    800011a2:	0d250513          	addi	a0,a0,210 # 80009270 <digits+0x100>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	3c4080e7          	jalr	964(ra) # 8000056a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011ae:	060a8663          	beqz	s5,8000121a <walk+0xa2>
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	89a080e7          	jalr	-1894(ra) # 80000a4c <kalloc>
    800011ba:	84aa                	mv	s1,a0
    800011bc:	c529                	beqz	a0,80001206 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011be:	6605                	lui	a2,0x1
    800011c0:	4581                	li	a1,0
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	cbe080e7          	jalr	-834(ra) # 80000e80 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011ca:	00c4d793          	srli	a5,s1,0xc
    800011ce:	07aa                	slli	a5,a5,0xa
    800011d0:	0017e793          	ori	a5,a5,1
    800011d4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011d8:	3a5d                	addiw	s4,s4,-9
    800011da:	036a0063          	beq	s4,s6,800011fa <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011de:	0149d933          	srl	s2,s3,s4
    800011e2:	1ff97913          	andi	s2,s2,511
    800011e6:	090e                	slli	s2,s2,0x3
    800011e8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011ea:	00093483          	ld	s1,0(s2)
    800011ee:	0014f793          	andi	a5,s1,1
    800011f2:	dfd5                	beqz	a5,800011ae <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011f4:	80a9                	srli	s1,s1,0xa
    800011f6:	04b2                	slli	s1,s1,0xc
    800011f8:	b7c5                	j	800011d8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011fa:	00c9d513          	srli	a0,s3,0xc
    800011fe:	1ff57513          	andi	a0,a0,511
    80001202:	050e                	slli	a0,a0,0x3
    80001204:	9526                	add	a0,a0,s1
}
    80001206:	70e2                	ld	ra,56(sp)
    80001208:	7442                	ld	s0,48(sp)
    8000120a:	74a2                	ld	s1,40(sp)
    8000120c:	7902                	ld	s2,32(sp)
    8000120e:	69e2                	ld	s3,24(sp)
    80001210:	6a42                	ld	s4,16(sp)
    80001212:	6aa2                	ld	s5,8(sp)
    80001214:	6b02                	ld	s6,0(sp)
    80001216:	6121                	addi	sp,sp,64
    80001218:	8082                	ret
        return 0;
    8000121a:	4501                	li	a0,0
    8000121c:	b7ed                	j	80001206 <walk+0x8e>

000000008000121e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    8000121e:	7179                	addi	sp,sp,-48
    80001220:	f406                	sd	ra,40(sp)
    80001222:	f022                	sd	s0,32(sp)
    80001224:	ec26                	sd	s1,24(sp)
    80001226:	e84a                	sd	s2,16(sp)
    80001228:	e44e                	sd	s3,8(sp)
    8000122a:	e052                	sd	s4,0(sp)
    8000122c:	1800                	addi	s0,sp,48
    8000122e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001230:	84aa                	mv	s1,a0
    80001232:	6905                	lui	s2,0x1
    80001234:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001236:	4985                	li	s3,1
    80001238:	a821                	j	80001250 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000123a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000123c:	0532                	slli	a0,a0,0xc
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	fe0080e7          	jalr	-32(ra) # 8000121e <freewalk>
      pagetable[i] = 0;
    80001246:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000124a:	04a1                	addi	s1,s1,8
    8000124c:	03248163          	beq	s1,s2,8000126e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001250:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001252:	00f57793          	andi	a5,a0,15
    80001256:	ff3782e3          	beq	a5,s3,8000123a <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000125a:	8905                	andi	a0,a0,1
    8000125c:	d57d                	beqz	a0,8000124a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000125e:	00008517          	auipc	a0,0x8
    80001262:	01a50513          	addi	a0,a0,26 # 80009278 <digits+0x108>
    80001266:	fffff097          	auipc	ra,0xfffff
    8000126a:	304080e7          	jalr	772(ra) # 8000056a <panic>
    }
  }
  kfree((void*)pagetable);
    8000126e:	8552                	mv	a0,s4
    80001270:	fffff097          	auipc	ra,0xfffff
    80001274:	6d6080e7          	jalr	1750(ra) # 80000946 <kfree>
}
    80001278:	70a2                	ld	ra,40(sp)
    8000127a:	7402                	ld	s0,32(sp)
    8000127c:	64e2                	ld	s1,24(sp)
    8000127e:	6942                	ld	s2,16(sp)
    80001280:	69a2                	ld	s3,8(sp)
    80001282:	6a02                	ld	s4,0(sp)
    80001284:	6145                	addi	sp,sp,48
    80001286:	8082                	ret

0000000080001288 <kvminithart>:
{
    80001288:	1141                	addi	sp,sp,-16
    8000128a:	e422                	sd	s0,8(sp)
    8000128c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000128e:	00009797          	auipc	a5,0x9
    80001292:	d427b783          	ld	a5,-702(a5) # 80009fd0 <kernel_pagetable>
    80001296:	83b1                	srli	a5,a5,0xc
    80001298:	577d                	li	a4,-1
    8000129a:	177e                	slli	a4,a4,0x3f
    8000129c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000129e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800012a2:	12000073          	sfence.vma
}
    800012a6:	6422                	ld	s0,8(sp)
    800012a8:	0141                	addi	sp,sp,16
    800012aa:	8082                	ret

00000000800012ac <walkaddr>:
  if(va >= MAXVA)
    800012ac:	57fd                	li	a5,-1
    800012ae:	83e9                	srli	a5,a5,0x1a
    800012b0:	00b7f463          	bgeu	a5,a1,800012b8 <walkaddr+0xc>
    return 0;
    800012b4:	4501                	li	a0,0
}
    800012b6:	8082                	ret
{
    800012b8:	1141                	addi	sp,sp,-16
    800012ba:	e406                	sd	ra,8(sp)
    800012bc:	e022                	sd	s0,0(sp)
    800012be:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012c0:	4601                	li	a2,0
    800012c2:	00000097          	auipc	ra,0x0
    800012c6:	eb6080e7          	jalr	-330(ra) # 80001178 <walk>
  if(pte == 0)
    800012ca:	c105                	beqz	a0,800012ea <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012cc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012ce:	0117f693          	andi	a3,a5,17
    800012d2:	4745                	li	a4,17
    return 0;
    800012d4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012d6:	00e68663          	beq	a3,a4,800012e2 <walkaddr+0x36>
}
    800012da:	60a2                	ld	ra,8(sp)
    800012dc:	6402                	ld	s0,0(sp)
    800012de:	0141                	addi	sp,sp,16
    800012e0:	8082                	ret
  pa = PTE2PA(*pte);
    800012e2:	00a7d513          	srli	a0,a5,0xa
    800012e6:	0532                	slli	a0,a0,0xc
  return pa;
    800012e8:	bfcd                	j	800012da <walkaddr+0x2e>
    return 0;
    800012ea:	4501                	li	a0,0
    800012ec:	b7fd                	j	800012da <walkaddr+0x2e>

00000000800012ee <mappages>:
{
    800012ee:	715d                	addi	sp,sp,-80
    800012f0:	e486                	sd	ra,72(sp)
    800012f2:	e0a2                	sd	s0,64(sp)
    800012f4:	fc26                	sd	s1,56(sp)
    800012f6:	f84a                	sd	s2,48(sp)
    800012f8:	f44e                	sd	s3,40(sp)
    800012fa:	f052                	sd	s4,32(sp)
    800012fc:	ec56                	sd	s5,24(sp)
    800012fe:	e85a                	sd	s6,16(sp)
    80001300:	e45e                	sd	s7,8(sp)
    80001302:	0880                	addi	s0,sp,80
  if(size == 0)
    80001304:	c205                	beqz	a2,80001324 <mappages+0x36>
    80001306:	8aaa                	mv	s5,a0
    80001308:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000130a:	77fd                	lui	a5,0xfffff
    8000130c:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001310:	15fd                	addi	a1,a1,-1
    80001312:	00c589b3          	add	s3,a1,a2
    80001316:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    8000131a:	8952                	mv	s2,s4
    8000131c:	41468a33          	sub	s4,a3,s4
    a += PGSIZE;
    80001320:	6b85                	lui	s7,0x1
    80001322:	a015                	j	80001346 <mappages+0x58>
    panic("mappages: size");
    80001324:	00008517          	auipc	a0,0x8
    80001328:	f6450513          	addi	a0,a0,-156 # 80009288 <digits+0x118>
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	23e080e7          	jalr	574(ra) # 8000056a <panic>
      panic("mappages: remap");
    80001334:	00008517          	auipc	a0,0x8
    80001338:	f6450513          	addi	a0,a0,-156 # 80009298 <digits+0x128>
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	22e080e7          	jalr	558(ra) # 8000056a <panic>
    a += PGSIZE;
    80001344:	995e                	add	s2,s2,s7
  for(;;){
    80001346:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000134a:	4605                	li	a2,1
    8000134c:	85ca                	mv	a1,s2
    8000134e:	8556                	mv	a0,s5
    80001350:	00000097          	auipc	ra,0x0
    80001354:	e28080e7          	jalr	-472(ra) # 80001178 <walk>
    80001358:	cd19                	beqz	a0,80001376 <mappages+0x88>
    if(*pte & PTE_V)
    8000135a:	611c                	ld	a5,0(a0)
    8000135c:	8b85                	andi	a5,a5,1
    8000135e:	fbf9                	bnez	a5,80001334 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001360:	80b1                	srli	s1,s1,0xc
    80001362:	04aa                	slli	s1,s1,0xa
    80001364:	0164e4b3          	or	s1,s1,s6
    80001368:	0014e493          	ori	s1,s1,1
    8000136c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000136e:	fd391be3          	bne	s2,s3,80001344 <mappages+0x56>
  return 0;
    80001372:	4501                	li	a0,0
    80001374:	a011                	j	80001378 <mappages+0x8a>
      return -1;
    80001376:	557d                	li	a0,-1
}
    80001378:	60a6                	ld	ra,72(sp)
    8000137a:	6406                	ld	s0,64(sp)
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
    8000138a:	6161                	addi	sp,sp,80
    8000138c:	8082                	ret

000000008000138e <kvmmap>:
{
    8000138e:	1141                	addi	sp,sp,-16
    80001390:	e406                	sd	ra,8(sp)
    80001392:	e022                	sd	s0,0(sp)
    80001394:	0800                	addi	s0,sp,16
    80001396:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001398:	86ae                	mv	a3,a1
    8000139a:	85aa                	mv	a1,a0
    8000139c:	00009517          	auipc	a0,0x9
    800013a0:	c3453503          	ld	a0,-972(a0) # 80009fd0 <kernel_pagetable>
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	f4a080e7          	jalr	-182(ra) # 800012ee <mappages>
    800013ac:	e509                	bnez	a0,800013b6 <kvmmap+0x28>
}
    800013ae:	60a2                	ld	ra,8(sp)
    800013b0:	6402                	ld	s0,0(sp)
    800013b2:	0141                	addi	sp,sp,16
    800013b4:	8082                	ret
    panic("kvmmap");
    800013b6:	00008517          	auipc	a0,0x8
    800013ba:	ef250513          	addi	a0,a0,-270 # 800092a8 <digits+0x138>
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	1ac080e7          	jalr	428(ra) # 8000056a <panic>

00000000800013c6 <kvminit>:
{
    800013c6:	1101                	addi	sp,sp,-32
    800013c8:	ec06                	sd	ra,24(sp)
    800013ca:	e822                	sd	s0,16(sp)
    800013cc:	e426                	sd	s1,8(sp)
    800013ce:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	67c080e7          	jalr	1660(ra) # 80000a4c <kalloc>
    800013d8:	00009797          	auipc	a5,0x9
    800013dc:	bea7bc23          	sd	a0,-1032(a5) # 80009fd0 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800013e0:	6605                	lui	a2,0x1
    800013e2:	4581                	li	a1,0
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	a9c080e7          	jalr	-1380(ra) # 80000e80 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013ec:	4699                	li	a3,6
    800013ee:	6605                	lui	a2,0x1
    800013f0:	100005b7          	lui	a1,0x10000
    800013f4:	10000537          	lui	a0,0x10000
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	f96080e7          	jalr	-106(ra) # 8000138e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001400:	4699                	li	a3,6
    80001402:	6605                	lui	a2,0x1
    80001404:	100015b7          	lui	a1,0x10001
    80001408:	10001537          	lui	a0,0x10001
    8000140c:	00000097          	auipc	ra,0x0
    80001410:	f82080e7          	jalr	-126(ra) # 8000138e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001414:	4699                	li	a3,6
    80001416:	00400637          	lui	a2,0x400
    8000141a:	0c0005b7          	lui	a1,0xc000
    8000141e:	0c000537          	lui	a0,0xc000
    80001422:	00000097          	auipc	ra,0x0
    80001426:	f6c080e7          	jalr	-148(ra) # 8000138e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000142a:	00008497          	auipc	s1,0x8
    8000142e:	bd648493          	addi	s1,s1,-1066 # 80009000 <etext>
    80001432:	46a9                	li	a3,10
    80001434:	80008617          	auipc	a2,0x80008
    80001438:	bcc60613          	addi	a2,a2,-1076 # 9000 <_entry-0x7fff7000>
    8000143c:	4585                	li	a1,1
    8000143e:	05fe                	slli	a1,a1,0x1f
    80001440:	852e                	mv	a0,a1
    80001442:	00000097          	auipc	ra,0x0
    80001446:	f4c080e7          	jalr	-180(ra) # 8000138e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000144a:	4699                	li	a3,6
    8000144c:	4645                	li	a2,17
    8000144e:	066e                	slli	a2,a2,0x1b
    80001450:	8e05                	sub	a2,a2,s1
    80001452:	85a6                	mv	a1,s1
    80001454:	8526                	mv	a0,s1
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	f38080e7          	jalr	-200(ra) # 8000138e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000145e:	46a9                	li	a3,10
    80001460:	6605                	lui	a2,0x1
    80001462:	00007597          	auipc	a1,0x7
    80001466:	b9e58593          	addi	a1,a1,-1122 # 80008000 <_trampoline>
    8000146a:	04000537          	lui	a0,0x4000
    8000146e:	157d                	addi	a0,a0,-1
    80001470:	0532                	slli	a0,a0,0xc
    80001472:	00000097          	auipc	ra,0x0
    80001476:	f1c080e7          	jalr	-228(ra) # 8000138e <kvmmap>
}
    8000147a:	60e2                	ld	ra,24(sp)
    8000147c:	6442                	ld	s0,16(sp)
    8000147e:	64a2                	ld	s1,8(sp)
    80001480:	6105                	addi	sp,sp,32
    80001482:	8082                	ret

0000000080001484 <uvmunmap>:
{
    80001484:	715d                	addi	sp,sp,-80
    80001486:	e486                	sd	ra,72(sp)
    80001488:	e0a2                	sd	s0,64(sp)
    8000148a:	fc26                	sd	s1,56(sp)
    8000148c:	f84a                	sd	s2,48(sp)
    8000148e:	f44e                	sd	s3,40(sp)
    80001490:	f052                	sd	s4,32(sp)
    80001492:	ec56                	sd	s5,24(sp)
    80001494:	e85a                	sd	s6,16(sp)
    80001496:	e45e                	sd	s7,8(sp)
    80001498:	0880                	addi	s0,sp,80
    8000149a:	8a2a                	mv	s4,a0
    8000149c:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    8000149e:	77fd                	lui	a5,0xfffff
    800014a0:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800014a4:	167d                	addi	a2,a2,-1
    800014a6:	00b609b3          	add	s3,a2,a1
    800014aa:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800014ae:	4b05                	li	s6,1
    a += PGSIZE;
    800014b0:	6b85                	lui	s7,0x1
    800014b2:	a8b1                	j	8000150e <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    800014b4:	00008517          	auipc	a0,0x8
    800014b8:	dfc50513          	addi	a0,a0,-516 # 800092b0 <digits+0x140>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	0ae080e7          	jalr	174(ra) # 8000056a <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800014c4:	862a                	mv	a2,a0
    800014c6:	85ca                	mv	a1,s2
    800014c8:	00008517          	auipc	a0,0x8
    800014cc:	df850513          	addi	a0,a0,-520 # 800092c0 <digits+0x150>
    800014d0:	fffff097          	auipc	ra,0xfffff
    800014d4:	0fc080e7          	jalr	252(ra) # 800005cc <printf>
      panic("uvmunmap: not mapped");
    800014d8:	00008517          	auipc	a0,0x8
    800014dc:	df850513          	addi	a0,a0,-520 # 800092d0 <digits+0x160>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	08a080e7          	jalr	138(ra) # 8000056a <panic>
      panic("uvmunmap: not a leaf");
    800014e8:	00008517          	auipc	a0,0x8
    800014ec:	e0050513          	addi	a0,a0,-512 # 800092e8 <digits+0x178>
    800014f0:	fffff097          	auipc	ra,0xfffff
    800014f4:	07a080e7          	jalr	122(ra) # 8000056a <panic>
      pa = PTE2PA(*pte);
    800014f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800014fa:	0532                	slli	a0,a0,0xc
    800014fc:	fffff097          	auipc	ra,0xfffff
    80001500:	44a080e7          	jalr	1098(ra) # 80000946 <kfree>
    *pte = 0;
    80001504:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001508:	03390763          	beq	s2,s3,80001536 <uvmunmap+0xb2>
    a += PGSIZE;
    8000150c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000150e:	4601                	li	a2,0
    80001510:	85ca                	mv	a1,s2
    80001512:	8552                	mv	a0,s4
    80001514:	00000097          	auipc	ra,0x0
    80001518:	c64080e7          	jalr	-924(ra) # 80001178 <walk>
    8000151c:	84aa                	mv	s1,a0
    8000151e:	d959                	beqz	a0,800014b4 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001520:	6108                	ld	a0,0(a0)
    80001522:	00157793          	andi	a5,a0,1
    80001526:	dfd9                	beqz	a5,800014c4 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001528:	3ff57793          	andi	a5,a0,1023
    8000152c:	fb678ee3          	beq	a5,s6,800014e8 <uvmunmap+0x64>
    if(do_free){
    80001530:	fc0a8ae3          	beqz	s5,80001504 <uvmunmap+0x80>
    80001534:	b7d1                	j	800014f8 <uvmunmap+0x74>
}
    80001536:	60a6                	ld	ra,72(sp)
    80001538:	6406                	ld	s0,64(sp)
    8000153a:	74e2                	ld	s1,56(sp)
    8000153c:	7942                	ld	s2,48(sp)
    8000153e:	79a2                	ld	s3,40(sp)
    80001540:	7a02                	ld	s4,32(sp)
    80001542:	6ae2                	ld	s5,24(sp)
    80001544:	6b42                	ld	s6,16(sp)
    80001546:	6ba2                	ld	s7,8(sp)
    80001548:	6161                	addi	sp,sp,80
    8000154a:	8082                	ret

000000008000154c <uvmcreate>:
{
    8000154c:	1101                	addi	sp,sp,-32
    8000154e:	ec06                	sd	ra,24(sp)
    80001550:	e822                	sd	s0,16(sp)
    80001552:	e426                	sd	s1,8(sp)
    80001554:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001556:	fffff097          	auipc	ra,0xfffff
    8000155a:	4f6080e7          	jalr	1270(ra) # 80000a4c <kalloc>
  if(pagetable == 0)
    8000155e:	cd11                	beqz	a0,8000157a <uvmcreate+0x2e>
    80001560:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001562:	6605                	lui	a2,0x1
    80001564:	4581                	li	a1,0
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	91a080e7          	jalr	-1766(ra) # 80000e80 <memset>
}
    8000156e:	8526                	mv	a0,s1
    80001570:	60e2                	ld	ra,24(sp)
    80001572:	6442                	ld	s0,16(sp)
    80001574:	64a2                	ld	s1,8(sp)
    80001576:	6105                	addi	sp,sp,32
    80001578:	8082                	ret
    panic("uvmcreate: out of memory");
    8000157a:	00008517          	auipc	a0,0x8
    8000157e:	d8650513          	addi	a0,a0,-634 # 80009300 <digits+0x190>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fe8080e7          	jalr	-24(ra) # 8000056a <panic>

000000008000158a <uvminit>:
{
    8000158a:	7179                	addi	sp,sp,-48
    8000158c:	f406                	sd	ra,40(sp)
    8000158e:	f022                	sd	s0,32(sp)
    80001590:	ec26                	sd	s1,24(sp)
    80001592:	e84a                	sd	s2,16(sp)
    80001594:	e44e                	sd	s3,8(sp)
    80001596:	e052                	sd	s4,0(sp)
    80001598:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    8000159a:	6785                	lui	a5,0x1
    8000159c:	04f67863          	bgeu	a2,a5,800015ec <uvminit+0x62>
    800015a0:	8a2a                	mv	s4,a0
    800015a2:	89ae                	mv	s3,a1
    800015a4:	84b2                	mv	s1,a2
  mem = kalloc();
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	4a6080e7          	jalr	1190(ra) # 80000a4c <kalloc>
    800015ae:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015b0:	6605                	lui	a2,0x1
    800015b2:	4581                	li	a1,0
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	8cc080e7          	jalr	-1844(ra) # 80000e80 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015bc:	4779                	li	a4,30
    800015be:	86ca                	mv	a3,s2
    800015c0:	6605                	lui	a2,0x1
    800015c2:	4581                	li	a1,0
    800015c4:	8552                	mv	a0,s4
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	d28080e7          	jalr	-728(ra) # 800012ee <mappages>
  memmove(mem, src, sz);
    800015ce:	8626                	mv	a2,s1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	854a                	mv	a0,s2
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	90c080e7          	jalr	-1780(ra) # 80000ee0 <memmove>
}
    800015dc:	70a2                	ld	ra,40(sp)
    800015de:	7402                	ld	s0,32(sp)
    800015e0:	64e2                	ld	s1,24(sp)
    800015e2:	6942                	ld	s2,16(sp)
    800015e4:	69a2                	ld	s3,8(sp)
    800015e6:	6a02                	ld	s4,0(sp)
    800015e8:	6145                	addi	sp,sp,48
    800015ea:	8082                	ret
    panic("inituvm: more than a page");
    800015ec:	00008517          	auipc	a0,0x8
    800015f0:	d3450513          	addi	a0,a0,-716 # 80009320 <digits+0x1b0>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f76080e7          	jalr	-138(ra) # 8000056a <panic>

00000000800015fc <uvmdealloc>:
{
    800015fc:	1101                	addi	sp,sp,-32
    800015fe:	ec06                	sd	ra,24(sp)
    80001600:	e822                	sd	s0,16(sp)
    80001602:	e426                	sd	s1,8(sp)
    80001604:	1000                	addi	s0,sp,32
    return oldsz;
    80001606:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001608:	00b67d63          	bgeu	a2,a1,80001622 <uvmdealloc+0x26>
    8000160c:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000160e:	6785                	lui	a5,0x1
    80001610:	17fd                	addi	a5,a5,-1
    80001612:	00f60733          	add	a4,a2,a5
    80001616:	76fd                	lui	a3,0xfffff
    80001618:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    8000161a:	97ae                	add	a5,a5,a1
    8000161c:	8ff5                	and	a5,a5,a3
    8000161e:	00f76863          	bltu	a4,a5,8000162e <uvmdealloc+0x32>
}
    80001622:	8526                	mv	a0,s1
    80001624:	60e2                	ld	ra,24(sp)
    80001626:	6442                	ld	s0,16(sp)
    80001628:	64a2                	ld	s1,8(sp)
    8000162a:	6105                	addi	sp,sp,32
    8000162c:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    8000162e:	4685                	li	a3,1
    80001630:	40e58633          	sub	a2,a1,a4
    80001634:	85ba                	mv	a1,a4
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	e4e080e7          	jalr	-434(ra) # 80001484 <uvmunmap>
    8000163e:	b7d5                	j	80001622 <uvmdealloc+0x26>

0000000080001640 <uvmalloc>:
  if(newsz < oldsz)
    80001640:	0ab66163          	bltu	a2,a1,800016e2 <uvmalloc+0xa2>
{
    80001644:	7139                	addi	sp,sp,-64
    80001646:	fc06                	sd	ra,56(sp)
    80001648:	f822                	sd	s0,48(sp)
    8000164a:	f426                	sd	s1,40(sp)
    8000164c:	f04a                	sd	s2,32(sp)
    8000164e:	ec4e                	sd	s3,24(sp)
    80001650:	e852                	sd	s4,16(sp)
    80001652:	e456                	sd	s5,8(sp)
    80001654:	0080                	addi	s0,sp,64
    80001656:	8aaa                	mv	s5,a0
    80001658:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000165a:	6985                	lui	s3,0x1
    8000165c:	19fd                	addi	s3,s3,-1
    8000165e:	95ce                	add	a1,a1,s3
    80001660:	79fd                	lui	s3,0xfffff
    80001662:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001666:	08c9f063          	bgeu	s3,a2,800016e6 <uvmalloc+0xa6>
    8000166a:	894e                	mv	s2,s3
    mem = kalloc();
    8000166c:	fffff097          	auipc	ra,0xfffff
    80001670:	3e0080e7          	jalr	992(ra) # 80000a4c <kalloc>
    80001674:	84aa                	mv	s1,a0
    if(mem == 0){
    80001676:	c51d                	beqz	a0,800016a4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001678:	6605                	lui	a2,0x1
    8000167a:	4581                	li	a1,0
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	804080e7          	jalr	-2044(ra) # 80000e80 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001684:	4779                	li	a4,30
    80001686:	86a6                	mv	a3,s1
    80001688:	6605                	lui	a2,0x1
    8000168a:	85ca                	mv	a1,s2
    8000168c:	8556                	mv	a0,s5
    8000168e:	00000097          	auipc	ra,0x0
    80001692:	c60080e7          	jalr	-928(ra) # 800012ee <mappages>
    80001696:	e905                	bnez	a0,800016c6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001698:	6785                	lui	a5,0x1
    8000169a:	993e                	add	s2,s2,a5
    8000169c:	fd4968e3          	bltu	s2,s4,8000166c <uvmalloc+0x2c>
  return newsz;
    800016a0:	8552                	mv	a0,s4
    800016a2:	a809                	j	800016b4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800016a4:	864e                	mv	a2,s3
    800016a6:	85ca                	mv	a1,s2
    800016a8:	8556                	mv	a0,s5
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	f52080e7          	jalr	-174(ra) # 800015fc <uvmdealloc>
      return 0;
    800016b2:	4501                	li	a0,0
}
    800016b4:	70e2                	ld	ra,56(sp)
    800016b6:	7442                	ld	s0,48(sp)
    800016b8:	74a2                	ld	s1,40(sp)
    800016ba:	7902                	ld	s2,32(sp)
    800016bc:	69e2                	ld	s3,24(sp)
    800016be:	6a42                	ld	s4,16(sp)
    800016c0:	6aa2                	ld	s5,8(sp)
    800016c2:	6121                	addi	sp,sp,64
    800016c4:	8082                	ret
      kfree(mem);
    800016c6:	8526                	mv	a0,s1
    800016c8:	fffff097          	auipc	ra,0xfffff
    800016cc:	27e080e7          	jalr	638(ra) # 80000946 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016d0:	864e                	mv	a2,s3
    800016d2:	85ca                	mv	a1,s2
    800016d4:	8556                	mv	a0,s5
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	f26080e7          	jalr	-218(ra) # 800015fc <uvmdealloc>
      return 0;
    800016de:	4501                	li	a0,0
    800016e0:	bfd1                	j	800016b4 <uvmalloc+0x74>
    return oldsz;
    800016e2:	852e                	mv	a0,a1
}
    800016e4:	8082                	ret
  return newsz;
    800016e6:	8532                	mv	a0,a2
    800016e8:	b7f1                	j	800016b4 <uvmalloc+0x74>

00000000800016ea <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016ea:	1101                	addi	sp,sp,-32
    800016ec:	ec06                	sd	ra,24(sp)
    800016ee:	e822                	sd	s0,16(sp)
    800016f0:	e426                	sd	s1,8(sp)
    800016f2:	1000                	addi	s0,sp,32
    800016f4:	84aa                	mv	s1,a0
    800016f6:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    800016f8:	4685                	li	a3,1
    800016fa:	4581                	li	a1,0
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	d88080e7          	jalr	-632(ra) # 80001484 <uvmunmap>
  freewalk(pagetable);
    80001704:	8526                	mv	a0,s1
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	b18080e7          	jalr	-1256(ra) # 8000121e <freewalk>
}
    8000170e:	60e2                	ld	ra,24(sp)
    80001710:	6442                	ld	s0,16(sp)
    80001712:	64a2                	ld	s1,8(sp)
    80001714:	6105                	addi	sp,sp,32
    80001716:	8082                	ret

0000000080001718 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001718:	c671                	beqz	a2,800017e4 <uvmcopy+0xcc>
{
    8000171a:	715d                	addi	sp,sp,-80
    8000171c:	e486                	sd	ra,72(sp)
    8000171e:	e0a2                	sd	s0,64(sp)
    80001720:	fc26                	sd	s1,56(sp)
    80001722:	f84a                	sd	s2,48(sp)
    80001724:	f44e                	sd	s3,40(sp)
    80001726:	f052                	sd	s4,32(sp)
    80001728:	ec56                	sd	s5,24(sp)
    8000172a:	e85a                	sd	s6,16(sp)
    8000172c:	e45e                	sd	s7,8(sp)
    8000172e:	0880                	addi	s0,sp,80
    80001730:	8b2a                	mv	s6,a0
    80001732:	8aae                	mv	s5,a1
    80001734:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001736:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001738:	4601                	li	a2,0
    8000173a:	85ce                	mv	a1,s3
    8000173c:	855a                	mv	a0,s6
    8000173e:	00000097          	auipc	ra,0x0
    80001742:	a3a080e7          	jalr	-1478(ra) # 80001178 <walk>
    80001746:	c531                	beqz	a0,80001792 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001748:	6118                	ld	a4,0(a0)
    8000174a:	00177793          	andi	a5,a4,1
    8000174e:	cbb1                	beqz	a5,800017a2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001750:	00a75593          	srli	a1,a4,0xa
    80001754:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001758:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000175c:	fffff097          	auipc	ra,0xfffff
    80001760:	2f0080e7          	jalr	752(ra) # 80000a4c <kalloc>
    80001764:	892a                	mv	s2,a0
    80001766:	c939                	beqz	a0,800017bc <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001768:	6605                	lui	a2,0x1
    8000176a:	85de                	mv	a1,s7
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	774080e7          	jalr	1908(ra) # 80000ee0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001774:	8726                	mv	a4,s1
    80001776:	86ca                	mv	a3,s2
    80001778:	6605                	lui	a2,0x1
    8000177a:	85ce                	mv	a1,s3
    8000177c:	8556                	mv	a0,s5
    8000177e:	00000097          	auipc	ra,0x0
    80001782:	b70080e7          	jalr	-1168(ra) # 800012ee <mappages>
    80001786:	e515                	bnez	a0,800017b2 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001788:	6785                	lui	a5,0x1
    8000178a:	99be                	add	s3,s3,a5
    8000178c:	fb49e6e3          	bltu	s3,s4,80001738 <uvmcopy+0x20>
    80001790:	a83d                	j	800017ce <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001792:	00008517          	auipc	a0,0x8
    80001796:	bae50513          	addi	a0,a0,-1106 # 80009340 <digits+0x1d0>
    8000179a:	fffff097          	auipc	ra,0xfffff
    8000179e:	dd0080e7          	jalr	-560(ra) # 8000056a <panic>
      panic("uvmcopy: page not present");
    800017a2:	00008517          	auipc	a0,0x8
    800017a6:	bbe50513          	addi	a0,a0,-1090 # 80009360 <digits+0x1f0>
    800017aa:	fffff097          	auipc	ra,0xfffff
    800017ae:	dc0080e7          	jalr	-576(ra) # 8000056a <panic>
      kfree(mem);
    800017b2:	854a                	mv	a0,s2
    800017b4:	fffff097          	auipc	ra,0xfffff
    800017b8:	192080e7          	jalr	402(ra) # 80000946 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800017bc:	4685                	li	a3,1
    800017be:	864e                	mv	a2,s3
    800017c0:	4581                	li	a1,0
    800017c2:	8556                	mv	a0,s5
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	cc0080e7          	jalr	-832(ra) # 80001484 <uvmunmap>
  return -1;
    800017cc:	557d                	li	a0,-1
}
    800017ce:	60a6                	ld	ra,72(sp)
    800017d0:	6406                	ld	s0,64(sp)
    800017d2:	74e2                	ld	s1,56(sp)
    800017d4:	7942                	ld	s2,48(sp)
    800017d6:	79a2                	ld	s3,40(sp)
    800017d8:	7a02                	ld	s4,32(sp)
    800017da:	6ae2                	ld	s5,24(sp)
    800017dc:	6b42                	ld	s6,16(sp)
    800017de:	6ba2                	ld	s7,8(sp)
    800017e0:	6161                	addi	sp,sp,80
    800017e2:	8082                	ret
  return 0;
    800017e4:	4501                	li	a0,0
}
    800017e6:	8082                	ret

00000000800017e8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017e8:	1141                	addi	sp,sp,-16
    800017ea:	e406                	sd	ra,8(sp)
    800017ec:	e022                	sd	s0,0(sp)
    800017ee:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017f0:	4601                	li	a2,0
    800017f2:	00000097          	auipc	ra,0x0
    800017f6:	986080e7          	jalr	-1658(ra) # 80001178 <walk>
  if(pte == 0)
    800017fa:	c901                	beqz	a0,8000180a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017fc:	611c                	ld	a5,0(a0)
    800017fe:	9bbd                	andi	a5,a5,-17
    80001800:	e11c                	sd	a5,0(a0)
}
    80001802:	60a2                	ld	ra,8(sp)
    80001804:	6402                	ld	s0,0(sp)
    80001806:	0141                	addi	sp,sp,16
    80001808:	8082                	ret
    panic("uvmclear");
    8000180a:	00008517          	auipc	a0,0x8
    8000180e:	b7650513          	addi	a0,a0,-1162 # 80009380 <digits+0x210>
    80001812:	fffff097          	auipc	ra,0xfffff
    80001816:	d58080e7          	jalr	-680(ra) # 8000056a <panic>

000000008000181a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000181a:	c6bd                	beqz	a3,80001888 <copyout+0x6e>
{
    8000181c:	715d                	addi	sp,sp,-80
    8000181e:	e486                	sd	ra,72(sp)
    80001820:	e0a2                	sd	s0,64(sp)
    80001822:	fc26                	sd	s1,56(sp)
    80001824:	f84a                	sd	s2,48(sp)
    80001826:	f44e                	sd	s3,40(sp)
    80001828:	f052                	sd	s4,32(sp)
    8000182a:	ec56                	sd	s5,24(sp)
    8000182c:	e85a                	sd	s6,16(sp)
    8000182e:	e45e                	sd	s7,8(sp)
    80001830:	e062                	sd	s8,0(sp)
    80001832:	0880                	addi	s0,sp,80
    80001834:	8b2a                	mv	s6,a0
    80001836:	8c2e                	mv	s8,a1
    80001838:	8a32                	mv	s4,a2
    8000183a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000183c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000183e:	6a85                	lui	s5,0x1
    80001840:	a015                	j	80001864 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001842:	9562                	add	a0,a0,s8
    80001844:	0004861b          	sext.w	a2,s1
    80001848:	85d2                	mv	a1,s4
    8000184a:	41250533          	sub	a0,a0,s2
    8000184e:	fffff097          	auipc	ra,0xfffff
    80001852:	692080e7          	jalr	1682(ra) # 80000ee0 <memmove>

    len -= n;
    80001856:	409989b3          	sub	s3,s3,s1
    src += n;
    8000185a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000185c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001860:	02098263          	beqz	s3,80001884 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001864:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001868:	85ca                	mv	a1,s2
    8000186a:	855a                	mv	a0,s6
    8000186c:	00000097          	auipc	ra,0x0
    80001870:	a40080e7          	jalr	-1472(ra) # 800012ac <walkaddr>
    if(pa0 == 0)
    80001874:	cd01                	beqz	a0,8000188c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001876:	418904b3          	sub	s1,s2,s8
    8000187a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000187c:	fc99f3e3          	bgeu	s3,s1,80001842 <copyout+0x28>
    80001880:	84ce                	mv	s1,s3
    80001882:	b7c1                	j	80001842 <copyout+0x28>
  }
  return 0;
    80001884:	4501                	li	a0,0
    80001886:	a021                	j	8000188e <copyout+0x74>
    80001888:	4501                	li	a0,0
}
    8000188a:	8082                	ret
      return -1;
    8000188c:	557d                	li	a0,-1
}
    8000188e:	60a6                	ld	ra,72(sp)
    80001890:	6406                	ld	s0,64(sp)
    80001892:	74e2                	ld	s1,56(sp)
    80001894:	7942                	ld	s2,48(sp)
    80001896:	79a2                	ld	s3,40(sp)
    80001898:	7a02                	ld	s4,32(sp)
    8000189a:	6ae2                	ld	s5,24(sp)
    8000189c:	6b42                	ld	s6,16(sp)
    8000189e:	6ba2                	ld	s7,8(sp)
    800018a0:	6c02                	ld	s8,0(sp)
    800018a2:	6161                	addi	sp,sp,80
    800018a4:	8082                	ret

00000000800018a6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018a6:	c6bd                	beqz	a3,80001914 <copyin+0x6e>
{
    800018a8:	715d                	addi	sp,sp,-80
    800018aa:	e486                	sd	ra,72(sp)
    800018ac:	e0a2                	sd	s0,64(sp)
    800018ae:	fc26                	sd	s1,56(sp)
    800018b0:	f84a                	sd	s2,48(sp)
    800018b2:	f44e                	sd	s3,40(sp)
    800018b4:	f052                	sd	s4,32(sp)
    800018b6:	ec56                	sd	s5,24(sp)
    800018b8:	e85a                	sd	s6,16(sp)
    800018ba:	e45e                	sd	s7,8(sp)
    800018bc:	e062                	sd	s8,0(sp)
    800018be:	0880                	addi	s0,sp,80
    800018c0:	8b2a                	mv	s6,a0
    800018c2:	8a2e                	mv	s4,a1
    800018c4:	8c32                	mv	s8,a2
    800018c6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018c8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018ca:	6a85                	lui	s5,0x1
    800018cc:	a015                	j	800018f0 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018ce:	9562                	add	a0,a0,s8
    800018d0:	0004861b          	sext.w	a2,s1
    800018d4:	412505b3          	sub	a1,a0,s2
    800018d8:	8552                	mv	a0,s4
    800018da:	fffff097          	auipc	ra,0xfffff
    800018de:	606080e7          	jalr	1542(ra) # 80000ee0 <memmove>

    len -= n;
    800018e2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018e6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018e8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ec:	02098263          	beqz	s3,80001910 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800018f0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018f4:	85ca                	mv	a1,s2
    800018f6:	855a                	mv	a0,s6
    800018f8:	00000097          	auipc	ra,0x0
    800018fc:	9b4080e7          	jalr	-1612(ra) # 800012ac <walkaddr>
    if(pa0 == 0)
    80001900:	cd01                	beqz	a0,80001918 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001902:	418904b3          	sub	s1,s2,s8
    80001906:	94d6                	add	s1,s1,s5
    if(n > len)
    80001908:	fc99f3e3          	bgeu	s3,s1,800018ce <copyin+0x28>
    8000190c:	84ce                	mv	s1,s3
    8000190e:	b7c1                	j	800018ce <copyin+0x28>
  }
  return 0;
    80001910:	4501                	li	a0,0
    80001912:	a021                	j	8000191a <copyin+0x74>
    80001914:	4501                	li	a0,0
}
    80001916:	8082                	ret
      return -1;
    80001918:	557d                	li	a0,-1
}
    8000191a:	60a6                	ld	ra,72(sp)
    8000191c:	6406                	ld	s0,64(sp)
    8000191e:	74e2                	ld	s1,56(sp)
    80001920:	7942                	ld	s2,48(sp)
    80001922:	79a2                	ld	s3,40(sp)
    80001924:	7a02                	ld	s4,32(sp)
    80001926:	6ae2                	ld	s5,24(sp)
    80001928:	6b42                	ld	s6,16(sp)
    8000192a:	6ba2                	ld	s7,8(sp)
    8000192c:	6c02                	ld	s8,0(sp)
    8000192e:	6161                	addi	sp,sp,80
    80001930:	8082                	ret

0000000080001932 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001932:	c6c5                	beqz	a3,800019da <copyinstr+0xa8>
{
    80001934:	715d                	addi	sp,sp,-80
    80001936:	e486                	sd	ra,72(sp)
    80001938:	e0a2                	sd	s0,64(sp)
    8000193a:	fc26                	sd	s1,56(sp)
    8000193c:	f84a                	sd	s2,48(sp)
    8000193e:	f44e                	sd	s3,40(sp)
    80001940:	f052                	sd	s4,32(sp)
    80001942:	ec56                	sd	s5,24(sp)
    80001944:	e85a                	sd	s6,16(sp)
    80001946:	e45e                	sd	s7,8(sp)
    80001948:	0880                	addi	s0,sp,80
    8000194a:	8a2a                	mv	s4,a0
    8000194c:	8b2e                	mv	s6,a1
    8000194e:	8bb2                	mv	s7,a2
    80001950:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001952:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001954:	6985                	lui	s3,0x1
    80001956:	a035                	j	80001982 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001958:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000195c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000195e:	0017b793          	seqz	a5,a5
    80001962:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001966:	60a6                	ld	ra,72(sp)
    80001968:	6406                	ld	s0,64(sp)
    8000196a:	74e2                	ld	s1,56(sp)
    8000196c:	7942                	ld	s2,48(sp)
    8000196e:	79a2                	ld	s3,40(sp)
    80001970:	7a02                	ld	s4,32(sp)
    80001972:	6ae2                	ld	s5,24(sp)
    80001974:	6b42                	ld	s6,16(sp)
    80001976:	6ba2                	ld	s7,8(sp)
    80001978:	6161                	addi	sp,sp,80
    8000197a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000197c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001980:	c8a9                	beqz	s1,800019d2 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001982:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001986:	85ca                	mv	a1,s2
    80001988:	8552                	mv	a0,s4
    8000198a:	00000097          	auipc	ra,0x0
    8000198e:	922080e7          	jalr	-1758(ra) # 800012ac <walkaddr>
    if(pa0 == 0)
    80001992:	c131                	beqz	a0,800019d6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001994:	41790833          	sub	a6,s2,s7
    80001998:	984e                	add	a6,a6,s3
    if(n > max)
    8000199a:	0104f363          	bgeu	s1,a6,800019a0 <copyinstr+0x6e>
    8000199e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019a0:	955e                	add	a0,a0,s7
    800019a2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019a6:	fc080be3          	beqz	a6,8000197c <copyinstr+0x4a>
    800019aa:	985a                	add	a6,a6,s6
    800019ac:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019ae:	41650633          	sub	a2,a0,s6
    800019b2:	14fd                	addi	s1,s1,-1
    800019b4:	9b26                	add	s6,s6,s1
    800019b6:	00f60733          	add	a4,a2,a5
    800019ba:	00074703          	lbu	a4,0(a4)
    800019be:	df49                	beqz	a4,80001958 <copyinstr+0x26>
        *dst = *p;
    800019c0:	00e78023          	sb	a4,0(a5)
      --max;
    800019c4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019c8:	0785                	addi	a5,a5,1
    while(n > 0){
    800019ca:	ff0796e3          	bne	a5,a6,800019b6 <copyinstr+0x84>
      dst++;
    800019ce:	8b42                	mv	s6,a6
    800019d0:	b775                	j	8000197c <copyinstr+0x4a>
    800019d2:	4781                	li	a5,0
    800019d4:	b769                	j	8000195e <copyinstr+0x2c>
      return -1;
    800019d6:	557d                	li	a0,-1
    800019d8:	b779                	j	80001966 <copyinstr+0x34>
  int got_null = 0;
    800019da:	4781                	li	a5,0
  if(got_null){
    800019dc:	0017b793          	seqz	a5,a5
    800019e0:	40f00533          	neg	a0,a5
}
    800019e4:	8082                	ret

00000000800019e6 <kwalkaddr>:
kwalkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t* pte;
  uint64 pa;

  if(va>= MAXVA)
    800019e6:	57fd                	li	a5,-1
    800019e8:	83e9                	srli	a5,a5,0x1a
    800019ea:	00b7f463          	bgeu	a5,a1,800019f2 <kwalkaddr+0xc>
    return 0;
    800019ee:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_V) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
    800019f0:	8082                	ret
{
    800019f2:	1141                	addi	sp,sp,-16
    800019f4:	e406                	sd	ra,8(sp)
    800019f6:	e022                	sd	s0,0(sp)
    800019f8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800019fa:	4601                	li	a2,0
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	77c080e7          	jalr	1916(ra) # 80001178 <walk>
  if (pte == 0)
    80001a04:	cd01                	beqz	a0,80001a1c <kwalkaddr+0x36>
  if ((*pte & PTE_V) == 0)
    80001a06:	611c                	ld	a5,0(a0)
    80001a08:	0017f513          	andi	a0,a5,1
    80001a0c:	c501                	beqz	a0,80001a14 <kwalkaddr+0x2e>
  pa = PTE2PA(*pte);
    80001a0e:	00a7d513          	srli	a0,a5,0xa
    80001a12:	0532                	slli	a0,a0,0xc
    80001a14:	60a2                	ld	ra,8(sp)
    80001a16:	6402                	ld	s0,0(sp)
    80001a18:	0141                	addi	sp,sp,16
    80001a1a:	8082                	ret
    return 0;
    80001a1c:	4501                	li	a0,0
    80001a1e:	bfdd                	j	80001a14 <kwalkaddr+0x2e>

0000000080001a20 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a20:	1101                	addi	sp,sp,-32
    80001a22:	ec06                	sd	ra,24(sp)
    80001a24:	e822                	sd	s0,16(sp)
    80001a26:	e426                	sd	s1,8(sp)
    80001a28:	1000                	addi	s0,sp,32
    80001a2a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	0f2080e7          	jalr	242(ra) # 80000b1e <holding>
    80001a34:	c909                	beqz	a0,80001a46 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a36:	789c                	ld	a5,48(s1)
    80001a38:	00978f63          	beq	a5,s1,80001a56 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a3c:	60e2                	ld	ra,24(sp)
    80001a3e:	6442                	ld	s0,16(sp)
    80001a40:	64a2                	ld	s1,8(sp)
    80001a42:	6105                	addi	sp,sp,32
    80001a44:	8082                	ret
    panic("wakeup1");
    80001a46:	00008517          	auipc	a0,0x8
    80001a4a:	94a50513          	addi	a0,a0,-1718 # 80009390 <digits+0x220>
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	b1c080e7          	jalr	-1252(ra) # 8000056a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a56:	5098                	lw	a4,32(s1)
    80001a58:	4785                	li	a5,1
    80001a5a:	fef711e3          	bne	a4,a5,80001a3c <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a5e:	4789                	li	a5,2
    80001a60:	d09c                	sw	a5,32(s1)
}
    80001a62:	bfe9                	j	80001a3c <wakeup1+0x1c>

0000000080001a64 <rcu_free_callback>:
};

// callback executed after grace period
static void
rcu_free_callback(struct rcu_head *head)
{
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	addi	s0,sp,32
    80001a6e:	84aa                	mv	s1,a0
  struct test_data *d =
      (struct test_data *)((char *)head - offsetof(struct test_data, rcu));
  printf("[callback] free old value=%d\n", d->value);
    80001a70:	ff852583          	lw	a1,-8(a0)
    80001a74:	00008517          	auipc	a0,0x8
    80001a78:	92450513          	addi	a0,a0,-1756 # 80009398 <digits+0x228>
    80001a7c:	fffff097          	auipc	ra,0xfffff
    80001a80:	b50080e7          	jalr	-1200(ra) # 800005cc <printf>
  kfree((char *)d);
    80001a84:	ff848513          	addi	a0,s1,-8
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	ebe080e7          	jalr	-322(ra) # 80000946 <kfree>
}
    80001a90:	60e2                	ld	ra,24(sp)
    80001a92:	6442                	ld	s0,16(sp)
    80001a94:	64a2                	ld	s1,8(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret

0000000080001a9a <procinit>:
{
    80001a9a:	715d                	addi	sp,sp,-80
    80001a9c:	e486                	sd	ra,72(sp)
    80001a9e:	e0a2                	sd	s0,64(sp)
    80001aa0:	fc26                	sd	s1,56(sp)
    80001aa2:	f84a                	sd	s2,48(sp)
    80001aa4:	f44e                	sd	s3,40(sp)
    80001aa6:	f052                	sd	s4,32(sp)
    80001aa8:	ec56                	sd	s5,24(sp)
    80001aaa:	e85a                	sd	s6,16(sp)
    80001aac:	e45e                	sd	s7,8(sp)
    80001aae:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001ab0:	00008597          	auipc	a1,0x8
    80001ab4:	90858593          	addi	a1,a1,-1784 # 800093b8 <digits+0x248>
    80001ab8:	00024517          	auipc	a0,0x24
    80001abc:	03050513          	addi	a0,a0,48 # 80025ae8 <pid_lock>
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	006080e7          	jalr	6(ra) # 80000ac6 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac8:	00024917          	auipc	s2,0x24
    80001acc:	44090913          	addi	s2,s2,1088 # 80025f08 <proc>
      initlock(&p->lock, "proc");
    80001ad0:	00008b97          	auipc	s7,0x8
    80001ad4:	8f0b8b93          	addi	s7,s7,-1808 # 800093c0 <digits+0x250>
      uint64 va = KSTACK((int) (p - proc));
    80001ad8:	8b4a                	mv	s6,s2
    80001ada:	00007a97          	auipc	s5,0x7
    80001ade:	526a8a93          	addi	s5,s5,1318 # 80009000 <etext>
    80001ae2:	040009b7          	lui	s3,0x4000
    80001ae6:	19fd                	addi	s3,s3,-1
    80001ae8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aea:	0002aa17          	auipc	s4,0x2a
    80001aee:	21ea0a13          	addi	s4,s4,542 # 8002bd08 <tickslock>
      initlock(&p->lock, "proc");
    80001af2:	85de                	mv	a1,s7
    80001af4:	854a                	mv	a0,s2
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	fd0080e7          	jalr	-48(ra) # 80000ac6 <initlock>
      char *pa = kalloc();
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	f4e080e7          	jalr	-178(ra) # 80000a4c <kalloc>
    80001b06:	85aa                	mv	a1,a0
      if(pa == 0)
    80001b08:	c929                	beqz	a0,80001b5a <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001b0a:	416904b3          	sub	s1,s2,s6
    80001b0e:	848d                	srai	s1,s1,0x3
    80001b10:	000ab783          	ld	a5,0(s5)
    80001b14:	02f484b3          	mul	s1,s1,a5
    80001b18:	2485                	addiw	s1,s1,1
    80001b1a:	00d4949b          	slliw	s1,s1,0xd
    80001b1e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b22:	4699                	li	a3,6
    80001b24:	6605                	lui	a2,0x1
    80001b26:	8526                	mv	a0,s1
    80001b28:	00000097          	auipc	ra,0x0
    80001b2c:	866080e7          	jalr	-1946(ra) # 8000138e <kvmmap>
      p->kstack = va;
    80001b30:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b34:	17890913          	addi	s2,s2,376
    80001b38:	fb491de3          	bne	s2,s4,80001af2 <procinit+0x58>
  kvminithart();
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	74c080e7          	jalr	1868(ra) # 80001288 <kvminithart>
}
    80001b44:	60a6                	ld	ra,72(sp)
    80001b46:	6406                	ld	s0,64(sp)
    80001b48:	74e2                	ld	s1,56(sp)
    80001b4a:	7942                	ld	s2,48(sp)
    80001b4c:	79a2                	ld	s3,40(sp)
    80001b4e:	7a02                	ld	s4,32(sp)
    80001b50:	6ae2                	ld	s5,24(sp)
    80001b52:	6b42                	ld	s6,16(sp)
    80001b54:	6ba2                	ld	s7,8(sp)
    80001b56:	6161                	addi	sp,sp,80
    80001b58:	8082                	ret
        panic("kalloc");
    80001b5a:	00008517          	auipc	a0,0x8
    80001b5e:	86e50513          	addi	a0,a0,-1938 # 800093c8 <digits+0x258>
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	a08080e7          	jalr	-1528(ra) # 8000056a <panic>

0000000080001b6a <cpuid>:
{
    80001b6a:	1141                	addi	sp,sp,-16
    80001b6c:	e422                	sd	s0,8(sp)
    80001b6e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b70:	8512                	mv	a0,tp
}
    80001b72:	2501                	sext.w	a0,a0
    80001b74:	6422                	ld	s0,8(sp)
    80001b76:	0141                	addi	sp,sp,16
    80001b78:	8082                	ret

0000000080001b7a <mycpu>:
mycpu(void) {
    80001b7a:	1141                	addi	sp,sp,-16
    80001b7c:	e422                	sd	s0,8(sp)
    80001b7e:	0800                	addi	s0,sp,16
    80001b80:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b82:	2781                	sext.w	a5,a5
    80001b84:	079e                	slli	a5,a5,0x7
}
    80001b86:	00024517          	auipc	a0,0x24
    80001b8a:	f8250513          	addi	a0,a0,-126 # 80025b08 <cpus>
    80001b8e:	953e                	add	a0,a0,a5
    80001b90:	6422                	ld	s0,8(sp)
    80001b92:	0141                	addi	sp,sp,16
    80001b94:	8082                	ret

0000000080001b96 <myproc>:
myproc(void) {
    80001b96:	1101                	addi	sp,sp,-32
    80001b98:	ec06                	sd	ra,24(sp)
    80001b9a:	e822                	sd	s0,16(sp)
    80001b9c:	e426                	sd	s1,8(sp)
    80001b9e:	1000                	addi	s0,sp,32
  push_off();
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	fac080e7          	jalr	-84(ra) # 80000b4c <push_off>
    80001ba8:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001baa:	2781                	sext.w	a5,a5
    80001bac:	079e                	slli	a5,a5,0x7
    80001bae:	00024717          	auipc	a4,0x24
    80001bb2:	f3a70713          	addi	a4,a4,-198 # 80025ae8 <pid_lock>
    80001bb6:	97ba                	add	a5,a5,a4
    80001bb8:	7384                	ld	s1,32(a5)
  pop_off();
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	052080e7          	jalr	82(ra) # 80000c0c <pop_off>
}
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	60e2                	ld	ra,24(sp)
    80001bc6:	6442                	ld	s0,16(sp)
    80001bc8:	64a2                	ld	s1,8(sp)
    80001bca:	6105                	addi	sp,sp,32
    80001bcc:	8082                	ret

0000000080001bce <forkret>:
{
    80001bce:	1141                	addi	sp,sp,-16
    80001bd0:	e406                	sd	ra,8(sp)
    80001bd2:	e022                	sd	s0,0(sp)
    80001bd4:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001bd6:	00000097          	auipc	ra,0x0
    80001bda:	fc0080e7          	jalr	-64(ra) # 80001b96 <myproc>
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	08e080e7          	jalr	142(ra) # 80000c6c <release>
  if (first) {
    80001be6:	00008797          	auipc	a5,0x8
    80001bea:	36a7a783          	lw	a5,874(a5) # 80009f50 <first.1790>
    80001bee:	eb89                	bnez	a5,80001c00 <forkret+0x32>
  usertrapret();
    80001bf0:	00001097          	auipc	ra,0x1
    80001bf4:	d36080e7          	jalr	-714(ra) # 80002926 <usertrapret>
}
    80001bf8:	60a2                	ld	ra,8(sp)
    80001bfa:	6402                	ld	s0,0(sp)
    80001bfc:	0141                	addi	sp,sp,16
    80001bfe:	8082                	ret
    first = 0;
    80001c00:	00008797          	auipc	a5,0x8
    80001c04:	3407a823          	sw	zero,848(a5) # 80009f50 <first.1790>
    fsinit(ROOTDEV);
    80001c08:	4505                	li	a0,1
    80001c0a:	00002097          	auipc	ra,0x2
    80001c0e:	a68080e7          	jalr	-1432(ra) # 80003672 <fsinit>
    80001c12:	bff9                	j	80001bf0 <forkret+0x22>

0000000080001c14 <allocpid>:
allocpid() {
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	e04a                	sd	s2,0(sp)
    80001c1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c20:	00024917          	auipc	s2,0x24
    80001c24:	ec890913          	addi	s2,s2,-312 # 80025ae8 <pid_lock>
    80001c28:	854a                	mv	a0,s2
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	f72080e7          	jalr	-142(ra) # 80000b9c <acquire>
  pid = nextpid;
    80001c32:	00008797          	auipc	a5,0x8
    80001c36:	32278793          	addi	a5,a5,802 # 80009f54 <nextpid>
    80001c3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c3c:	0014871b          	addiw	a4,s1,1
    80001c40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c42:	854a                	mv	a0,s2
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	028080e7          	jalr	40(ra) # 80000c6c <release>
}
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	60e2                	ld	ra,24(sp)
    80001c50:	6442                	ld	s0,16(sp)
    80001c52:	64a2                	ld	s1,8(sp)
    80001c54:	6902                	ld	s2,0(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <proc_pagetable>:
{
    80001c5a:	1101                	addi	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	e04a                	sd	s2,0(sp)
    80001c64:	1000                	addi	s0,sp,32
    80001c66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	8e4080e7          	jalr	-1820(ra) # 8000154c <uvmcreate>
    80001c70:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c72:	4729                	li	a4,10
    80001c74:	00006697          	auipc	a3,0x6
    80001c78:	38c68693          	addi	a3,a3,908 # 80008000 <_trampoline>
    80001c7c:	6605                	lui	a2,0x1
    80001c7e:	040005b7          	lui	a1,0x4000
    80001c82:	15fd                	addi	a1,a1,-1
    80001c84:	05b2                	slli	a1,a1,0xc
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	668080e7          	jalr	1640(ra) # 800012ee <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c8e:	4719                	li	a4,6
    80001c90:	06093683          	ld	a3,96(s2)
    80001c94:	6605                	lui	a2,0x1
    80001c96:	020005b7          	lui	a1,0x2000
    80001c9a:	15fd                	addi	a1,a1,-1
    80001c9c:	05b6                	slli	a1,a1,0xd
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	64e080e7          	jalr	1614(ra) # 800012ee <mappages>
}
    80001ca8:	8526                	mv	a0,s1
    80001caa:	60e2                	ld	ra,24(sp)
    80001cac:	6442                	ld	s0,16(sp)
    80001cae:	64a2                	ld	s1,8(sp)
    80001cb0:	6902                	ld	s2,0(sp)
    80001cb2:	6105                	addi	sp,sp,32
    80001cb4:	8082                	ret

0000000080001cb6 <allocproc>:
{
    80001cb6:	1101                	addi	sp,sp,-32
    80001cb8:	ec06                	sd	ra,24(sp)
    80001cba:	e822                	sd	s0,16(sp)
    80001cbc:	e426                	sd	s1,8(sp)
    80001cbe:	e04a                	sd	s2,0(sp)
    80001cc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc2:	00024497          	auipc	s1,0x24
    80001cc6:	24648493          	addi	s1,s1,582 # 80025f08 <proc>
    80001cca:	0002a917          	auipc	s2,0x2a
    80001cce:	03e90913          	addi	s2,s2,62 # 8002bd08 <tickslock>
    acquire(&p->lock);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	ec8080e7          	jalr	-312(ra) # 80000b9c <acquire>
    if(p->state == UNUSED) {
    80001cdc:	509c                	lw	a5,32(s1)
    80001cde:	cf81                	beqz	a5,80001cf6 <allocproc+0x40>
      release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	f8a080e7          	jalr	-118(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cea:	17848493          	addi	s1,s1,376
    80001cee:	ff2492e3          	bne	s1,s2,80001cd2 <allocproc+0x1c>
  return 0;
    80001cf2:	4481                	li	s1,0
    80001cf4:	a899                	j	80001d4a <allocproc+0x94>
  p->pid = allocpid();
    80001cf6:	00000097          	auipc	ra,0x0
    80001cfa:	f1e080e7          	jalr	-226(ra) # 80001c14 <allocpid>
    80001cfe:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	d4c080e7          	jalr	-692(ra) # 80000a4c <kalloc>
    80001d08:	892a                	mv	s2,a0
    80001d0a:	f0a8                	sd	a0,96(s1)
    80001d0c:	c531                	beqz	a0,80001d58 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	f4a080e7          	jalr	-182(ra) # 80001c5a <proc_pagetable>
    80001d18:	eca8                	sd	a0,88(s1)
  p->trap_va = TRAPFRAME;
    80001d1a:	020007b7          	lui	a5,0x2000
    80001d1e:	17fd                	addi	a5,a5,-1
    80001d20:	07b6                	slli	a5,a5,0xd
    80001d22:	16f4b823          	sd	a5,368(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001d26:	07000613          	li	a2,112
    80001d2a:	4581                	li	a1,0
    80001d2c:	06848513          	addi	a0,s1,104
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	150080e7          	jalr	336(ra) # 80000e80 <memset>
  p->context.ra = (uint64)forkret;
    80001d38:	00000797          	auipc	a5,0x0
    80001d3c:	e9678793          	addi	a5,a5,-362 # 80001bce <forkret>
    80001d40:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d42:	64bc                	ld	a5,72(s1)
    80001d44:	6705                	lui	a4,0x1
    80001d46:	97ba                	add	a5,a5,a4
    80001d48:	f8bc                	sd	a5,112(s1)
}
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	60e2                	ld	ra,24(sp)
    80001d4e:	6442                	ld	s0,16(sp)
    80001d50:	64a2                	ld	s1,8(sp)
    80001d52:	6902                	ld	s2,0(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret
    release(&p->lock);
    80001d58:	8526                	mv	a0,s1
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	f12080e7          	jalr	-238(ra) # 80000c6c <release>
    return 0;
    80001d62:	84ca                	mv	s1,s2
    80001d64:	b7dd                	j	80001d4a <allocproc+0x94>

0000000080001d66 <proc_freepagetable>:
{
    80001d66:	1101                	addi	sp,sp,-32
    80001d68:	ec06                	sd	ra,24(sp)
    80001d6a:	e822                	sd	s0,16(sp)
    80001d6c:	e426                	sd	s1,8(sp)
    80001d6e:	e04a                	sd	s2,0(sp)
    80001d70:	1000                	addi	s0,sp,32
    80001d72:	84aa                	mv	s1,a0
    80001d74:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d76:	4681                	li	a3,0
    80001d78:	6605                	lui	a2,0x1
    80001d7a:	040005b7          	lui	a1,0x4000
    80001d7e:	15fd                	addi	a1,a1,-1
    80001d80:	05b2                	slli	a1,a1,0xc
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	702080e7          	jalr	1794(ra) # 80001484 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d8a:	4681                	li	a3,0
    80001d8c:	6605                	lui	a2,0x1
    80001d8e:	020005b7          	lui	a1,0x2000
    80001d92:	15fd                	addi	a1,a1,-1
    80001d94:	05b6                	slli	a1,a1,0xd
    80001d96:	8526                	mv	a0,s1
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	6ec080e7          	jalr	1772(ra) # 80001484 <uvmunmap>
  if(sz > 0)
    80001da0:	00091863          	bnez	s2,80001db0 <proc_freepagetable+0x4a>
}
    80001da4:	60e2                	ld	ra,24(sp)
    80001da6:	6442                	ld	s0,16(sp)
    80001da8:	64a2                	ld	s1,8(sp)
    80001daa:	6902                	ld	s2,0(sp)
    80001dac:	6105                	addi	sp,sp,32
    80001dae:	8082                	ret
    uvmfree(pagetable, sz);
    80001db0:	85ca                	mv	a1,s2
    80001db2:	8526                	mv	a0,s1
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	936080e7          	jalr	-1738(ra) # 800016ea <uvmfree>
}
    80001dbc:	b7e5                	j	80001da4 <proc_freepagetable+0x3e>

0000000080001dbe <freeproc>:
{
    80001dbe:	1101                	addi	sp,sp,-32
    80001dc0:	ec06                	sd	ra,24(sp)
    80001dc2:	e822                	sd	s0,16(sp)
    80001dc4:	e426                	sd	s1,8(sp)
    80001dc6:	1000                	addi	s0,sp,32
    80001dc8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001dca:	7128                	ld	a0,96(a0)
    80001dcc:	c509                	beqz	a0,80001dd6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	b78080e7          	jalr	-1160(ra) # 80000946 <kfree>
  p->trapframe = 0;
    80001dd6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001dda:	6ca8                	ld	a0,88(s1)
    80001ddc:	c511                	beqz	a0,80001de8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001dde:	68ac                	ld	a1,80(s1)
    80001de0:	00000097          	auipc	ra,0x0
    80001de4:	f86080e7          	jalr	-122(ra) # 80001d66 <proc_freepagetable>
  p->pagetable = 0;
    80001de8:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001dec:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001df0:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001df4:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001df8:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dfc:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001e00:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001e04:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001e08:	0204a023          	sw	zero,32(s1)
}
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6105                	addi	sp,sp,32
    80001e14:	8082                	ret

0000000080001e16 <userinit>:
{
    80001e16:	1101                	addi	sp,sp,-32
    80001e18:	ec06                	sd	ra,24(sp)
    80001e1a:	e822                	sd	s0,16(sp)
    80001e1c:	e426                	sd	s1,8(sp)
    80001e1e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	e96080e7          	jalr	-362(ra) # 80001cb6 <allocproc>
    80001e28:	84aa                	mv	s1,a0
  initproc = p;
    80001e2a:	00008797          	auipc	a5,0x8
    80001e2e:	1aa7bb23          	sd	a0,438(a5) # 80009fe0 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e32:	03400613          	li	a2,52
    80001e36:	00008597          	auipc	a1,0x8
    80001e3a:	12a58593          	addi	a1,a1,298 # 80009f60 <initcode>
    80001e3e:	6d28                	ld	a0,88(a0)
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	74a080e7          	jalr	1866(ra) # 8000158a <uvminit>
  p->sz = PGSIZE;
    80001e48:	6785                	lui	a5,0x1
    80001e4a:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e4c:	70b8                	ld	a4,96(s1)
    80001e4e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e52:	70b8                	ld	a4,96(s1)
    80001e54:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e56:	4641                	li	a2,16
    80001e58:	00007597          	auipc	a1,0x7
    80001e5c:	57858593          	addi	a1,a1,1400 # 800093d0 <digits+0x260>
    80001e60:	16048513          	addi	a0,s1,352
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	19a080e7          	jalr	410(ra) # 80000ffe <safestrcpy>
  p->cwd = namei("/");
    80001e6c:	00007517          	auipc	a0,0x7
    80001e70:	57450513          	addi	a0,a0,1396 # 800093e0 <digits+0x270>
    80001e74:	00002097          	auipc	ra,0x2
    80001e78:	22c080e7          	jalr	556(ra) # 800040a0 <namei>
    80001e7c:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e80:	4789                	li	a5,2
    80001e82:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001e84:	8526                	mv	a0,s1
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	de6080e7          	jalr	-538(ra) # 80000c6c <release>
}
    80001e8e:	60e2                	ld	ra,24(sp)
    80001e90:	6442                	ld	s0,16(sp)
    80001e92:	64a2                	ld	s1,8(sp)
    80001e94:	6105                	addi	sp,sp,32
    80001e96:	8082                	ret

0000000080001e98 <growproc>:
{
    80001e98:	1101                	addi	sp,sp,-32
    80001e9a:	ec06                	sd	ra,24(sp)
    80001e9c:	e822                	sd	s0,16(sp)
    80001e9e:	e426                	sd	s1,8(sp)
    80001ea0:	e04a                	sd	s2,0(sp)
    80001ea2:	1000                	addi	s0,sp,32
    80001ea4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	cf0080e7          	jalr	-784(ra) # 80001b96 <myproc>
    80001eae:	892a                	mv	s2,a0
  sz = p->sz;
    80001eb0:	692c                	ld	a1,80(a0)
    80001eb2:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001eb6:	00904f63          	bgtz	s1,80001ed4 <growproc+0x3c>
  } else if(n < 0){
    80001eba:	0204cc63          	bltz	s1,80001ef2 <growproc+0x5a>
  p->sz = sz;
    80001ebe:	1602                	slli	a2,a2,0x20
    80001ec0:	9201                	srli	a2,a2,0x20
    80001ec2:	04c93823          	sd	a2,80(s2)
  return 0;
    80001ec6:	4501                	li	a0,0
}
    80001ec8:	60e2                	ld	ra,24(sp)
    80001eca:	6442                	ld	s0,16(sp)
    80001ecc:	64a2                	ld	s1,8(sp)
    80001ece:	6902                	ld	s2,0(sp)
    80001ed0:	6105                	addi	sp,sp,32
    80001ed2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ed4:	9e25                	addw	a2,a2,s1
    80001ed6:	1602                	slli	a2,a2,0x20
    80001ed8:	9201                	srli	a2,a2,0x20
    80001eda:	1582                	slli	a1,a1,0x20
    80001edc:	9181                	srli	a1,a1,0x20
    80001ede:	6d28                	ld	a0,88(a0)
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	760080e7          	jalr	1888(ra) # 80001640 <uvmalloc>
    80001ee8:	0005061b          	sext.w	a2,a0
    80001eec:	fa69                	bnez	a2,80001ebe <growproc+0x26>
      return -1;
    80001eee:	557d                	li	a0,-1
    80001ef0:	bfe1                	j	80001ec8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ef2:	9e25                	addw	a2,a2,s1
    80001ef4:	1602                	slli	a2,a2,0x20
    80001ef6:	9201                	srli	a2,a2,0x20
    80001ef8:	1582                	slli	a1,a1,0x20
    80001efa:	9181                	srli	a1,a1,0x20
    80001efc:	6d28                	ld	a0,88(a0)
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	6fe080e7          	jalr	1790(ra) # 800015fc <uvmdealloc>
    80001f06:	0005061b          	sext.w	a2,a0
    80001f0a:	bf55                	j	80001ebe <growproc+0x26>

0000000080001f0c <fork>:
{
    80001f0c:	7179                	addi	sp,sp,-48
    80001f0e:	f406                	sd	ra,40(sp)
    80001f10:	f022                	sd	s0,32(sp)
    80001f12:	ec26                	sd	s1,24(sp)
    80001f14:	e84a                	sd	s2,16(sp)
    80001f16:	e44e                	sd	s3,8(sp)
    80001f18:	e052                	sd	s4,0(sp)
    80001f1a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f1c:	00000097          	auipc	ra,0x0
    80001f20:	c7a080e7          	jalr	-902(ra) # 80001b96 <myproc>
    80001f24:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001f26:	00000097          	auipc	ra,0x0
    80001f2a:	d90080e7          	jalr	-624(ra) # 80001cb6 <allocproc>
    80001f2e:	c175                	beqz	a0,80002012 <fork+0x106>
    80001f30:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f32:	05093603          	ld	a2,80(s2)
    80001f36:	6d2c                	ld	a1,88(a0)
    80001f38:	05893503          	ld	a0,88(s2)
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	7dc080e7          	jalr	2012(ra) # 80001718 <uvmcopy>
    80001f44:	04054863          	bltz	a0,80001f94 <fork+0x88>
  np->sz = p->sz;
    80001f48:	05093783          	ld	a5,80(s2)
    80001f4c:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80001f50:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f54:	06093683          	ld	a3,96(s2)
    80001f58:	87b6                	mv	a5,a3
    80001f5a:	0609b703          	ld	a4,96(s3)
    80001f5e:	12068693          	addi	a3,a3,288
    80001f62:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f66:	6788                	ld	a0,8(a5)
    80001f68:	6b8c                	ld	a1,16(a5)
    80001f6a:	6f90                	ld	a2,24(a5)
    80001f6c:	01073023          	sd	a6,0(a4)
    80001f70:	e708                	sd	a0,8(a4)
    80001f72:	eb0c                	sd	a1,16(a4)
    80001f74:	ef10                	sd	a2,24(a4)
    80001f76:	02078793          	addi	a5,a5,32
    80001f7a:	02070713          	addi	a4,a4,32
    80001f7e:	fed792e3          	bne	a5,a3,80001f62 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f82:	0609b783          	ld	a5,96(s3)
    80001f86:	0607b823          	sd	zero,112(a5)
    80001f8a:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001f8e:	15800a13          	li	s4,344
    80001f92:	a03d                	j	80001fc0 <fork+0xb4>
    freeproc(np);
    80001f94:	854e                	mv	a0,s3
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	e28080e7          	jalr	-472(ra) # 80001dbe <freeproc>
    release(&np->lock);
    80001f9e:	854e                	mv	a0,s3
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	ccc080e7          	jalr	-820(ra) # 80000c6c <release>
    return -1;
    80001fa8:	54fd                	li	s1,-1
    80001faa:	a899                	j	80002000 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fac:	00002097          	auipc	ra,0x2
    80001fb0:	778080e7          	jalr	1912(ra) # 80004724 <filedup>
    80001fb4:	009987b3          	add	a5,s3,s1
    80001fb8:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001fba:	04a1                	addi	s1,s1,8
    80001fbc:	01448763          	beq	s1,s4,80001fca <fork+0xbe>
    if(p->ofile[i])
    80001fc0:	009907b3          	add	a5,s2,s1
    80001fc4:	6388                	ld	a0,0(a5)
    80001fc6:	f17d                	bnez	a0,80001fac <fork+0xa0>
    80001fc8:	bfcd                	j	80001fba <fork+0xae>
  np->cwd = idup(p->cwd);
    80001fca:	15893503          	ld	a0,344(s2)
    80001fce:	00002097          	auipc	ra,0x2
    80001fd2:	8de080e7          	jalr	-1826(ra) # 800038ac <idup>
    80001fd6:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fda:	4641                	li	a2,16
    80001fdc:	16090593          	addi	a1,s2,352
    80001fe0:	16098513          	addi	a0,s3,352
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	01a080e7          	jalr	26(ra) # 80000ffe <safestrcpy>
  pid = np->pid;
    80001fec:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    80001ff0:	4789                	li	a5,2
    80001ff2:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001ff6:	854e                	mv	a0,s3
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	c74080e7          	jalr	-908(ra) # 80000c6c <release>
}
    80002000:	8526                	mv	a0,s1
    80002002:	70a2                	ld	ra,40(sp)
    80002004:	7402                	ld	s0,32(sp)
    80002006:	64e2                	ld	s1,24(sp)
    80002008:	6942                	ld	s2,16(sp)
    8000200a:	69a2                	ld	s3,8(sp)
    8000200c:	6a02                	ld	s4,0(sp)
    8000200e:	6145                	addi	sp,sp,48
    80002010:	8082                	ret
    return -1;
    80002012:	54fd                	li	s1,-1
    80002014:	b7f5                	j	80002000 <fork+0xf4>

0000000080002016 <reparent>:
{
    80002016:	7179                	addi	sp,sp,-48
    80002018:	f406                	sd	ra,40(sp)
    8000201a:	f022                	sd	s0,32(sp)
    8000201c:	ec26                	sd	s1,24(sp)
    8000201e:	e84a                	sd	s2,16(sp)
    80002020:	e44e                	sd	s3,8(sp)
    80002022:	e052                	sd	s4,0(sp)
    80002024:	1800                	addi	s0,sp,48
    80002026:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002028:	00024497          	auipc	s1,0x24
    8000202c:	ee048493          	addi	s1,s1,-288 # 80025f08 <proc>
      pp->parent = initproc;
    80002030:	00008a17          	auipc	s4,0x8
    80002034:	fb0a0a13          	addi	s4,s4,-80 # 80009fe0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002038:	0002a997          	auipc	s3,0x2a
    8000203c:	cd098993          	addi	s3,s3,-816 # 8002bd08 <tickslock>
    80002040:	a029                	j	8000204a <reparent+0x34>
    80002042:	17848493          	addi	s1,s1,376
    80002046:	03348363          	beq	s1,s3,8000206c <reparent+0x56>
    if(pp->parent == p){
    8000204a:	749c                	ld	a5,40(s1)
    8000204c:	ff279be3          	bne	a5,s2,80002042 <reparent+0x2c>
      acquire(&pp->lock);
    80002050:	8526                	mv	a0,s1
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	b4a080e7          	jalr	-1206(ra) # 80000b9c <acquire>
      pp->parent = initproc;
    8000205a:	000a3783          	ld	a5,0(s4)
    8000205e:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002060:	8526                	mv	a0,s1
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	c0a080e7          	jalr	-1014(ra) # 80000c6c <release>
    8000206a:	bfe1                	j	80002042 <reparent+0x2c>
}
    8000206c:	70a2                	ld	ra,40(sp)
    8000206e:	7402                	ld	s0,32(sp)
    80002070:	64e2                	ld	s1,24(sp)
    80002072:	6942                	ld	s2,16(sp)
    80002074:	69a2                	ld	s3,8(sp)
    80002076:	6a02                	ld	s4,0(sp)
    80002078:	6145                	addi	sp,sp,48
    8000207a:	8082                	ret

000000008000207c <scheduler>:
{
    8000207c:	715d                	addi	sp,sp,-80
    8000207e:	e486                	sd	ra,72(sp)
    80002080:	e0a2                	sd	s0,64(sp)
    80002082:	fc26                	sd	s1,56(sp)
    80002084:	f84a                	sd	s2,48(sp)
    80002086:	f44e                	sd	s3,40(sp)
    80002088:	f052                	sd	s4,32(sp)
    8000208a:	ec56                	sd	s5,24(sp)
    8000208c:	e85a                	sd	s6,16(sp)
    8000208e:	e45e                	sd	s7,8(sp)
    80002090:	e062                	sd	s8,0(sp)
    80002092:	0880                	addi	s0,sp,80
    80002094:	8792                	mv	a5,tp
  int id = r_tp();
    80002096:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002098:	00779b93          	slli	s7,a5,0x7
    8000209c:	00024717          	auipc	a4,0x24
    800020a0:	a4c70713          	addi	a4,a4,-1460 # 80025ae8 <pid_lock>
    800020a4:	975e                	add	a4,a4,s7
    800020a6:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    800020aa:	00024717          	auipc	a4,0x24
    800020ae:	a6670713          	addi	a4,a4,-1434 # 80025b10 <cpus+0x8>
    800020b2:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    800020b4:	4c0d                	li	s8,3
        c->proc = p;
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	00024917          	auipc	s2,0x24
    800020bc:	a3090913          	addi	s2,s2,-1488 # 80025ae8 <pid_lock>
    800020c0:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020c2:	0002aa17          	auipc	s4,0x2a
    800020c6:	c46a0a13          	addi	s4,s4,-954 # 8002bd08 <tickslock>
    800020ca:	a0b9                	j	80002118 <scheduler+0x9c>
        p->state = RUNNING;
    800020cc:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800020d0:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    800020d4:	06848593          	addi	a1,s1,104
    800020d8:	855e                	mv	a0,s7
    800020da:	00000097          	auipc	ra,0x0
    800020de:	708080e7          	jalr	1800(ra) # 800027e2 <swtch>
        c->proc = 0;
    800020e2:	02093023          	sd	zero,32(s2)
        found = 1;
    800020e6:	8ada                	mv	s5,s6
      c->intena = 0;
    800020e8:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b7e080e7          	jalr	-1154(ra) # 80000c6c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020f6:	17848493          	addi	s1,s1,376
    800020fa:	01448b63          	beq	s1,s4,80002110 <scheduler+0x94>
      acquire(&p->lock);
    800020fe:	8526                	mv	a0,s1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	a9c080e7          	jalr	-1380(ra) # 80000b9c <acquire>
      if(p->state == RUNNABLE) {
    80002108:	509c                	lw	a5,32(s1)
    8000210a:	fd379fe3          	bne	a5,s3,800020e8 <scheduler+0x6c>
    8000210e:	bf7d                	j	800020cc <scheduler+0x50>
    if(found == 0){
    80002110:	000a9463          	bnez	s5,80002118 <scheduler+0x9c>
      asm volatile("wfi");
    80002114:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002118:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000211c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002120:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002124:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002128:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000212a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000212e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002130:	00024497          	auipc	s1,0x24
    80002134:	dd848493          	addi	s1,s1,-552 # 80025f08 <proc>
      if(p->state == RUNNABLE) {
    80002138:	4989                	li	s3,2
        found = 1;
    8000213a:	4b05                	li	s6,1
    8000213c:	b7c9                	j	800020fe <scheduler+0x82>

000000008000213e <sched>:
{
    8000213e:	7179                	addi	sp,sp,-48
    80002140:	f406                	sd	ra,40(sp)
    80002142:	f022                	sd	s0,32(sp)
    80002144:	ec26                	sd	s1,24(sp)
    80002146:	e84a                	sd	s2,16(sp)
    80002148:	e44e                	sd	s3,8(sp)
    8000214a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	a4a080e7          	jalr	-1462(ra) # 80001b96 <myproc>
    80002154:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	9c8080e7          	jalr	-1592(ra) # 80000b1e <holding>
    8000215e:	c93d                	beqz	a0,800021d4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002160:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002162:	2781                	sext.w	a5,a5
    80002164:	079e                	slli	a5,a5,0x7
    80002166:	00024717          	auipc	a4,0x24
    8000216a:	98270713          	addi	a4,a4,-1662 # 80025ae8 <pid_lock>
    8000216e:	97ba                	add	a5,a5,a4
    80002170:	0987a703          	lw	a4,152(a5)
    80002174:	4785                	li	a5,1
    80002176:	06f71763          	bne	a4,a5,800021e4 <sched+0xa6>
  if(p->state == RUNNING)
    8000217a:	5098                	lw	a4,32(s1)
    8000217c:	478d                	li	a5,3
    8000217e:	06f70b63          	beq	a4,a5,800021f4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002182:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002186:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002188:	efb5                	bnez	a5,80002204 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000218a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000218c:	00024917          	auipc	s2,0x24
    80002190:	95c90913          	addi	s2,s2,-1700 # 80025ae8 <pid_lock>
    80002194:	2781                	sext.w	a5,a5
    80002196:	079e                	slli	a5,a5,0x7
    80002198:	97ca                	add	a5,a5,s2
    8000219a:	09c7a983          	lw	s3,156(a5)
    8000219e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800021a0:	2781                	sext.w	a5,a5
    800021a2:	079e                	slli	a5,a5,0x7
    800021a4:	00024597          	auipc	a1,0x24
    800021a8:	96c58593          	addi	a1,a1,-1684 # 80025b10 <cpus+0x8>
    800021ac:	95be                	add	a1,a1,a5
    800021ae:	06848513          	addi	a0,s1,104
    800021b2:	00000097          	auipc	ra,0x0
    800021b6:	630080e7          	jalr	1584(ra) # 800027e2 <swtch>
    800021ba:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021bc:	2781                	sext.w	a5,a5
    800021be:	079e                	slli	a5,a5,0x7
    800021c0:	97ca                	add	a5,a5,s2
    800021c2:	0937ae23          	sw	s3,156(a5)
}
    800021c6:	70a2                	ld	ra,40(sp)
    800021c8:	7402                	ld	s0,32(sp)
    800021ca:	64e2                	ld	s1,24(sp)
    800021cc:	6942                	ld	s2,16(sp)
    800021ce:	69a2                	ld	s3,8(sp)
    800021d0:	6145                	addi	sp,sp,48
    800021d2:	8082                	ret
    panic("sched p->lock");
    800021d4:	00007517          	auipc	a0,0x7
    800021d8:	21450513          	addi	a0,a0,532 # 800093e8 <digits+0x278>
    800021dc:	ffffe097          	auipc	ra,0xffffe
    800021e0:	38e080e7          	jalr	910(ra) # 8000056a <panic>
    panic("sched locks");
    800021e4:	00007517          	auipc	a0,0x7
    800021e8:	21450513          	addi	a0,a0,532 # 800093f8 <digits+0x288>
    800021ec:	ffffe097          	auipc	ra,0xffffe
    800021f0:	37e080e7          	jalr	894(ra) # 8000056a <panic>
    panic("sched running");
    800021f4:	00007517          	auipc	a0,0x7
    800021f8:	21450513          	addi	a0,a0,532 # 80009408 <digits+0x298>
    800021fc:	ffffe097          	auipc	ra,0xffffe
    80002200:	36e080e7          	jalr	878(ra) # 8000056a <panic>
    panic("sched interruptible");
    80002204:	00007517          	auipc	a0,0x7
    80002208:	21450513          	addi	a0,a0,532 # 80009418 <digits+0x2a8>
    8000220c:	ffffe097          	auipc	ra,0xffffe
    80002210:	35e080e7          	jalr	862(ra) # 8000056a <panic>

0000000080002214 <exit>:
{
    80002214:	7179                	addi	sp,sp,-48
    80002216:	f406                	sd	ra,40(sp)
    80002218:	f022                	sd	s0,32(sp)
    8000221a:	ec26                	sd	s1,24(sp)
    8000221c:	e84a                	sd	s2,16(sp)
    8000221e:	e44e                	sd	s3,8(sp)
    80002220:	e052                	sd	s4,0(sp)
    80002222:	1800                	addi	s0,sp,48
    80002224:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	970080e7          	jalr	-1680(ra) # 80001b96 <myproc>
    8000222e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002230:	00008797          	auipc	a5,0x8
    80002234:	db07b783          	ld	a5,-592(a5) # 80009fe0 <initproc>
    80002238:	0d850493          	addi	s1,a0,216
    8000223c:	15850913          	addi	s2,a0,344
    80002240:	02a79363          	bne	a5,a0,80002266 <exit+0x52>
    panic("init exiting");
    80002244:	00007517          	auipc	a0,0x7
    80002248:	1ec50513          	addi	a0,a0,492 # 80009430 <digits+0x2c0>
    8000224c:	ffffe097          	auipc	ra,0xffffe
    80002250:	31e080e7          	jalr	798(ra) # 8000056a <panic>
      fileclose(f);
    80002254:	00002097          	auipc	ra,0x2
    80002258:	522080e7          	jalr	1314(ra) # 80004776 <fileclose>
      p->ofile[fd] = 0;
    8000225c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002260:	04a1                	addi	s1,s1,8
    80002262:	01248563          	beq	s1,s2,8000226c <exit+0x58>
    if(p->ofile[fd]){
    80002266:	6088                	ld	a0,0(s1)
    80002268:	f575                	bnez	a0,80002254 <exit+0x40>
    8000226a:	bfdd                	j	80002260 <exit+0x4c>
  begin_op();
    8000226c:	00002097          	auipc	ra,0x2
    80002270:	040080e7          	jalr	64(ra) # 800042ac <begin_op>
  iput(p->cwd);
    80002274:	1589b503          	ld	a0,344(s3)
    80002278:	00002097          	auipc	ra,0x2
    8000227c:	82c080e7          	jalr	-2004(ra) # 80003aa4 <iput>
  end_op();
    80002280:	00002097          	auipc	ra,0x2
    80002284:	0ac080e7          	jalr	172(ra) # 8000432c <end_op>
  p->cwd = 0;
    80002288:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000228c:	00008497          	auipc	s1,0x8
    80002290:	d5448493          	addi	s1,s1,-684 # 80009fe0 <initproc>
    80002294:	6088                	ld	a0,0(s1)
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	906080e7          	jalr	-1786(ra) # 80000b9c <acquire>
  wakeup1(initproc);
    8000229e:	6088                	ld	a0,0(s1)
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	780080e7          	jalr	1920(ra) # 80001a20 <wakeup1>
  release(&initproc->lock);
    800022a8:	6088                	ld	a0,0(s1)
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	9c2080e7          	jalr	-1598(ra) # 80000c6c <release>
  acquire(&p->lock);
    800022b2:	854e                	mv	a0,s3
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	8e8080e7          	jalr	-1816(ra) # 80000b9c <acquire>
  struct proc *original_parent = p->parent;
    800022bc:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800022c0:	854e                	mv	a0,s3
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9aa080e7          	jalr	-1622(ra) # 80000c6c <release>
  acquire(&original_parent->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	8d0080e7          	jalr	-1840(ra) # 80000b9c <acquire>
  acquire(&p->lock);
    800022d4:	854e                	mv	a0,s3
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	8c6080e7          	jalr	-1850(ra) # 80000b9c <acquire>
  reparent(p);
    800022de:	854e                	mv	a0,s3
    800022e0:	00000097          	auipc	ra,0x0
    800022e4:	d36080e7          	jalr	-714(ra) # 80002016 <reparent>
  wakeup1(original_parent);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	736080e7          	jalr	1846(ra) # 80001a20 <wakeup1>
  p->xstate = status;
    800022f2:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800022f6:	4791                	li	a5,4
    800022f8:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	96e080e7          	jalr	-1682(ra) # 80000c6c <release>
  sched();
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	e38080e7          	jalr	-456(ra) # 8000213e <sched>
  panic("zombie exit");
    8000230e:	00007517          	auipc	a0,0x7
    80002312:	13250513          	addi	a0,a0,306 # 80009440 <digits+0x2d0>
    80002316:	ffffe097          	auipc	ra,0xffffe
    8000231a:	254080e7          	jalr	596(ra) # 8000056a <panic>

000000008000231e <yield>:
{
    8000231e:	1101                	addi	sp,sp,-32
    80002320:	ec06                	sd	ra,24(sp)
    80002322:	e822                	sd	s0,16(sp)
    80002324:	e426                	sd	s1,8(sp)
    80002326:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002328:	00000097          	auipc	ra,0x0
    8000232c:	86e080e7          	jalr	-1938(ra) # 80001b96 <myproc>
    80002330:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	86a080e7          	jalr	-1942(ra) # 80000b9c <acquire>
  p->state = RUNNABLE;
    8000233a:	4789                	li	a5,2
    8000233c:	d09c                	sw	a5,32(s1)
  sched();
    8000233e:	00000097          	auipc	ra,0x0
    80002342:	e00080e7          	jalr	-512(ra) # 8000213e <sched>
  release(&p->lock);
    80002346:	8526                	mv	a0,s1
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	924080e7          	jalr	-1756(ra) # 80000c6c <release>
}
    80002350:	60e2                	ld	ra,24(sp)
    80002352:	6442                	ld	s0,16(sp)
    80002354:	64a2                	ld	s1,8(sp)
    80002356:	6105                	addi	sp,sp,32
    80002358:	8082                	ret

000000008000235a <sleep>:
{
    8000235a:	7179                	addi	sp,sp,-48
    8000235c:	f406                	sd	ra,40(sp)
    8000235e:	f022                	sd	s0,32(sp)
    80002360:	ec26                	sd	s1,24(sp)
    80002362:	e84a                	sd	s2,16(sp)
    80002364:	e44e                	sd	s3,8(sp)
    80002366:	1800                	addi	s0,sp,48
    80002368:	89aa                	mv	s3,a0
    8000236a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000236c:	00000097          	auipc	ra,0x0
    80002370:	82a080e7          	jalr	-2006(ra) # 80001b96 <myproc>
    80002374:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002376:	05250663          	beq	a0,s2,800023c2 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	822080e7          	jalr	-2014(ra) # 80000b9c <acquire>
    release(lk);
    80002382:	854a                	mv	a0,s2
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	8e8080e7          	jalr	-1816(ra) # 80000c6c <release>
  p->chan = chan;
    8000238c:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    80002390:	4785                	li	a5,1
    80002392:	d09c                	sw	a5,32(s1)
  sched();
    80002394:	00000097          	auipc	ra,0x0
    80002398:	daa080e7          	jalr	-598(ra) # 8000213e <sched>
  p->chan = 0;
    8000239c:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800023a0:	8526                	mv	a0,s1
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	8ca080e7          	jalr	-1846(ra) # 80000c6c <release>
    acquire(lk);
    800023aa:	854a                	mv	a0,s2
    800023ac:	ffffe097          	auipc	ra,0xffffe
    800023b0:	7f0080e7          	jalr	2032(ra) # 80000b9c <acquire>
}
    800023b4:	70a2                	ld	ra,40(sp)
    800023b6:	7402                	ld	s0,32(sp)
    800023b8:	64e2                	ld	s1,24(sp)
    800023ba:	6942                	ld	s2,16(sp)
    800023bc:	69a2                	ld	s3,8(sp)
    800023be:	6145                	addi	sp,sp,48
    800023c0:	8082                	ret
  p->chan = chan;
    800023c2:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023c6:	4785                	li	a5,1
    800023c8:	d11c                	sw	a5,32(a0)
  sched();
    800023ca:	00000097          	auipc	ra,0x0
    800023ce:	d74080e7          	jalr	-652(ra) # 8000213e <sched>
  p->chan = 0;
    800023d2:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800023d6:	bff9                	j	800023b4 <sleep+0x5a>

00000000800023d8 <wait>:
{
    800023d8:	715d                	addi	sp,sp,-80
    800023da:	e486                	sd	ra,72(sp)
    800023dc:	e0a2                	sd	s0,64(sp)
    800023de:	fc26                	sd	s1,56(sp)
    800023e0:	f84a                	sd	s2,48(sp)
    800023e2:	f44e                	sd	s3,40(sp)
    800023e4:	f052                	sd	s4,32(sp)
    800023e6:	ec56                	sd	s5,24(sp)
    800023e8:	e85a                	sd	s6,16(sp)
    800023ea:	e45e                	sd	s7,8(sp)
    800023ec:	e062                	sd	s8,0(sp)
    800023ee:	0880                	addi	s0,sp,80
    800023f0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	7a4080e7          	jalr	1956(ra) # 80001b96 <myproc>
    800023fa:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023fc:	8c2a                	mv	s8,a0
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	79e080e7          	jalr	1950(ra) # 80000b9c <acquire>
    havekids = 0;
    80002406:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002408:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000240a:	0002a997          	auipc	s3,0x2a
    8000240e:	8fe98993          	addi	s3,s3,-1794 # 8002bd08 <tickslock>
        havekids = 1;
    80002412:	4a85                	li	s5,1
    havekids = 0;
    80002414:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002416:	00024497          	auipc	s1,0x24
    8000241a:	af248493          	addi	s1,s1,-1294 # 80025f08 <proc>
    8000241e:	a08d                	j	80002480 <wait+0xa8>
          pid = np->pid;
    80002420:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002424:	000b0e63          	beqz	s6,80002440 <wait+0x68>
    80002428:	4691                	li	a3,4
    8000242a:	03c48613          	addi	a2,s1,60
    8000242e:	85da                	mv	a1,s6
    80002430:	05893503          	ld	a0,88(s2)
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	3e6080e7          	jalr	998(ra) # 8000181a <copyout>
    8000243c:	02054263          	bltz	a0,80002460 <wait+0x88>
          freeproc(np);
    80002440:	8526                	mv	a0,s1
    80002442:	00000097          	auipc	ra,0x0
    80002446:	97c080e7          	jalr	-1668(ra) # 80001dbe <freeproc>
          release(&np->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	820080e7          	jalr	-2016(ra) # 80000c6c <release>
          release(&p->lock);
    80002454:	854a                	mv	a0,s2
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	816080e7          	jalr	-2026(ra) # 80000c6c <release>
          return pid;
    8000245e:	a8a9                	j	800024b8 <wait+0xe0>
            release(&np->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	80a080e7          	jalr	-2038(ra) # 80000c6c <release>
            release(&p->lock);
    8000246a:	854a                	mv	a0,s2
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	800080e7          	jalr	-2048(ra) # 80000c6c <release>
            return -1;
    80002474:	59fd                	li	s3,-1
    80002476:	a089                	j	800024b8 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002478:	17848493          	addi	s1,s1,376
    8000247c:	03348463          	beq	s1,s3,800024a4 <wait+0xcc>
      if(np->parent == p){
    80002480:	749c                	ld	a5,40(s1)
    80002482:	ff279be3          	bne	a5,s2,80002478 <wait+0xa0>
        acquire(&np->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	ffffe097          	auipc	ra,0xffffe
    8000248c:	714080e7          	jalr	1812(ra) # 80000b9c <acquire>
        if(np->state == ZOMBIE){
    80002490:	509c                	lw	a5,32(s1)
    80002492:	f94787e3          	beq	a5,s4,80002420 <wait+0x48>
        release(&np->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7d4080e7          	jalr	2004(ra) # 80000c6c <release>
        havekids = 1;
    800024a0:	8756                	mv	a4,s5
    800024a2:	bfd9                	j	80002478 <wait+0xa0>
    if(!havekids || p->killed){
    800024a4:	c701                	beqz	a4,800024ac <wait+0xd4>
    800024a6:	03892783          	lw	a5,56(s2)
    800024aa:	c785                	beqz	a5,800024d2 <wait+0xfa>
      release(&p->lock);
    800024ac:	854a                	mv	a0,s2
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	7be080e7          	jalr	1982(ra) # 80000c6c <release>
      return -1;
    800024b6:	59fd                	li	s3,-1
}
    800024b8:	854e                	mv	a0,s3
    800024ba:	60a6                	ld	ra,72(sp)
    800024bc:	6406                	ld	s0,64(sp)
    800024be:	74e2                	ld	s1,56(sp)
    800024c0:	7942                	ld	s2,48(sp)
    800024c2:	79a2                	ld	s3,40(sp)
    800024c4:	7a02                	ld	s4,32(sp)
    800024c6:	6ae2                	ld	s5,24(sp)
    800024c8:	6b42                	ld	s6,16(sp)
    800024ca:	6ba2                	ld	s7,8(sp)
    800024cc:	6c02                	ld	s8,0(sp)
    800024ce:	6161                	addi	sp,sp,80
    800024d0:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800024d2:	85e2                	mv	a1,s8
    800024d4:	854a                	mv	a0,s2
    800024d6:	00000097          	auipc	ra,0x0
    800024da:	e84080e7          	jalr	-380(ra) # 8000235a <sleep>
    havekids = 0;
    800024de:	bf1d                	j	80002414 <wait+0x3c>

00000000800024e0 <wakeup>:
{
    800024e0:	7139                	addi	sp,sp,-64
    800024e2:	fc06                	sd	ra,56(sp)
    800024e4:	f822                	sd	s0,48(sp)
    800024e6:	f426                	sd	s1,40(sp)
    800024e8:	f04a                	sd	s2,32(sp)
    800024ea:	ec4e                	sd	s3,24(sp)
    800024ec:	e852                	sd	s4,16(sp)
    800024ee:	e456                	sd	s5,8(sp)
    800024f0:	0080                	addi	s0,sp,64
    800024f2:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024f4:	00024497          	auipc	s1,0x24
    800024f8:	a1448493          	addi	s1,s1,-1516 # 80025f08 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024fc:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024fe:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002500:	0002a917          	auipc	s2,0x2a
    80002504:	80890913          	addi	s2,s2,-2040 # 8002bd08 <tickslock>
    80002508:	a821                	j	80002520 <wakeup+0x40>
      p->state = RUNNABLE;
    8000250a:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	75c080e7          	jalr	1884(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002518:	17848493          	addi	s1,s1,376
    8000251c:	01248e63          	beq	s1,s2,80002538 <wakeup+0x58>
    acquire(&p->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	67a080e7          	jalr	1658(ra) # 80000b9c <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000252a:	509c                	lw	a5,32(s1)
    8000252c:	ff3791e3          	bne	a5,s3,8000250e <wakeup+0x2e>
    80002530:	789c                	ld	a5,48(s1)
    80002532:	fd479ee3          	bne	a5,s4,8000250e <wakeup+0x2e>
    80002536:	bfd1                	j	8000250a <wakeup+0x2a>
}
    80002538:	70e2                	ld	ra,56(sp)
    8000253a:	7442                	ld	s0,48(sp)
    8000253c:	74a2                	ld	s1,40(sp)
    8000253e:	7902                	ld	s2,32(sp)
    80002540:	69e2                	ld	s3,24(sp)
    80002542:	6a42                	ld	s4,16(sp)
    80002544:	6aa2                	ld	s5,8(sp)
    80002546:	6121                	addi	sp,sp,64
    80002548:	8082                	ret

000000008000254a <kill>:
{
    8000254a:	7179                	addi	sp,sp,-48
    8000254c:	f406                	sd	ra,40(sp)
    8000254e:	f022                	sd	s0,32(sp)
    80002550:	ec26                	sd	s1,24(sp)
    80002552:	e84a                	sd	s2,16(sp)
    80002554:	e44e                	sd	s3,8(sp)
    80002556:	1800                	addi	s0,sp,48
    80002558:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    8000255a:	00024497          	auipc	s1,0x24
    8000255e:	9ae48493          	addi	s1,s1,-1618 # 80025f08 <proc>
    80002562:	00029997          	auipc	s3,0x29
    80002566:	7a698993          	addi	s3,s3,1958 # 8002bd08 <tickslock>
    acquire(&p->lock);
    8000256a:	8526                	mv	a0,s1
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	630080e7          	jalr	1584(ra) # 80000b9c <acquire>
    if(p->pid == pid){
    80002574:	40bc                	lw	a5,64(s1)
    80002576:	01278d63          	beq	a5,s2,80002590 <kill+0x46>
    release(&p->lock);
    8000257a:	8526                	mv	a0,s1
    8000257c:	ffffe097          	auipc	ra,0xffffe
    80002580:	6f0080e7          	jalr	1776(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002584:	17848493          	addi	s1,s1,376
    80002588:	ff3491e3          	bne	s1,s3,8000256a <kill+0x20>
  return -1;
    8000258c:	557d                	li	a0,-1
    8000258e:	a829                	j	800025a8 <kill+0x5e>
      p->killed = 1;
    80002590:	4785                	li	a5,1
    80002592:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002594:	5098                	lw	a4,32(s1)
    80002596:	4785                	li	a5,1
    80002598:	00f70f63          	beq	a4,a5,800025b6 <kill+0x6c>
      release(&p->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	6ce080e7          	jalr	1742(ra) # 80000c6c <release>
      return 0;
    800025a6:	4501                	li	a0,0
}
    800025a8:	70a2                	ld	ra,40(sp)
    800025aa:	7402                	ld	s0,32(sp)
    800025ac:	64e2                	ld	s1,24(sp)
    800025ae:	6942                	ld	s2,16(sp)
    800025b0:	69a2                	ld	s3,8(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret
        p->state = RUNNABLE;
    800025b6:	4789                	li	a5,2
    800025b8:	d09c                	sw	a5,32(s1)
    800025ba:	b7cd                	j	8000259c <kill+0x52>

00000000800025bc <either_copyout>:
{
    800025bc:	7179                	addi	sp,sp,-48
    800025be:	f406                	sd	ra,40(sp)
    800025c0:	f022                	sd	s0,32(sp)
    800025c2:	ec26                	sd	s1,24(sp)
    800025c4:	e84a                	sd	s2,16(sp)
    800025c6:	e44e                	sd	s3,8(sp)
    800025c8:	e052                	sd	s4,0(sp)
    800025ca:	1800                	addi	s0,sp,48
    800025cc:	84aa                	mv	s1,a0
    800025ce:	892e                	mv	s2,a1
    800025d0:	89b2                	mv	s3,a2
    800025d2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	5c2080e7          	jalr	1474(ra) # 80001b96 <myproc>
  if(user_dst){
    800025dc:	c08d                	beqz	s1,800025fe <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025de:	86d2                	mv	a3,s4
    800025e0:	864e                	mv	a2,s3
    800025e2:	85ca                	mv	a1,s2
    800025e4:	6d28                	ld	a0,88(a0)
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	234080e7          	jalr	564(ra) # 8000181a <copyout>
}
    800025ee:	70a2                	ld	ra,40(sp)
    800025f0:	7402                	ld	s0,32(sp)
    800025f2:	64e2                	ld	s1,24(sp)
    800025f4:	6942                	ld	s2,16(sp)
    800025f6:	69a2                	ld	s3,8(sp)
    800025f8:	6a02                	ld	s4,0(sp)
    800025fa:	6145                	addi	sp,sp,48
    800025fc:	8082                	ret
    memmove((char *)dst, src, len);
    800025fe:	000a061b          	sext.w	a2,s4
    80002602:	85ce                	mv	a1,s3
    80002604:	854a                	mv	a0,s2
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	8da080e7          	jalr	-1830(ra) # 80000ee0 <memmove>
    return 0;
    8000260e:	8526                	mv	a0,s1
    80002610:	bff9                	j	800025ee <either_copyout+0x32>

0000000080002612 <either_copyin>:
{
    80002612:	7179                	addi	sp,sp,-48
    80002614:	f406                	sd	ra,40(sp)
    80002616:	f022                	sd	s0,32(sp)
    80002618:	ec26                	sd	s1,24(sp)
    8000261a:	e84a                	sd	s2,16(sp)
    8000261c:	e44e                	sd	s3,8(sp)
    8000261e:	e052                	sd	s4,0(sp)
    80002620:	1800                	addi	s0,sp,48
    80002622:	892a                	mv	s2,a0
    80002624:	84ae                	mv	s1,a1
    80002626:	89b2                	mv	s3,a2
    80002628:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000262a:	fffff097          	auipc	ra,0xfffff
    8000262e:	56c080e7          	jalr	1388(ra) # 80001b96 <myproc>
  if(user_src){
    80002632:	c08d                	beqz	s1,80002654 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002634:	86d2                	mv	a3,s4
    80002636:	864e                	mv	a2,s3
    80002638:	85ca                	mv	a1,s2
    8000263a:	6d28                	ld	a0,88(a0)
    8000263c:	fffff097          	auipc	ra,0xfffff
    80002640:	26a080e7          	jalr	618(ra) # 800018a6 <copyin>
}
    80002644:	70a2                	ld	ra,40(sp)
    80002646:	7402                	ld	s0,32(sp)
    80002648:	64e2                	ld	s1,24(sp)
    8000264a:	6942                	ld	s2,16(sp)
    8000264c:	69a2                	ld	s3,8(sp)
    8000264e:	6a02                	ld	s4,0(sp)
    80002650:	6145                	addi	sp,sp,48
    80002652:	8082                	ret
    memmove(dst, (char*)src, len);
    80002654:	000a061b          	sext.w	a2,s4
    80002658:	85ce                	mv	a1,s3
    8000265a:	854a                	mv	a0,s2
    8000265c:	fffff097          	auipc	ra,0xfffff
    80002660:	884080e7          	jalr	-1916(ra) # 80000ee0 <memmove>
    return 0;
    80002664:	8526                	mv	a0,s1
    80002666:	bff9                	j	80002644 <either_copyin+0x32>

0000000080002668 <procdump>:
{
    80002668:	715d                	addi	sp,sp,-80
    8000266a:	e486                	sd	ra,72(sp)
    8000266c:	e0a2                	sd	s0,64(sp)
    8000266e:	fc26                	sd	s1,56(sp)
    80002670:	f84a                	sd	s2,48(sp)
    80002672:	f44e                	sd	s3,40(sp)
    80002674:	f052                	sd	s4,32(sp)
    80002676:	ec56                	sd	s5,24(sp)
    80002678:	e85a                	sd	s6,16(sp)
    8000267a:	e45e                	sd	s7,8(sp)
    8000267c:	0880                	addi	s0,sp,80
  printf("\n");
    8000267e:	00007517          	auipc	a0,0x7
    80002682:	b8250513          	addi	a0,a0,-1150 # 80009200 <digits+0x90>
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	f46080e7          	jalr	-186(ra) # 800005cc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000268e:	00024497          	auipc	s1,0x24
    80002692:	9da48493          	addi	s1,s1,-1574 # 80026068 <proc+0x160>
    80002696:	00029917          	auipc	s2,0x29
    8000269a:	7d290913          	addi	s2,s2,2002 # 8002be68 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269e:	4b11                	li	s6,4
      state = "???";
    800026a0:	00007997          	auipc	s3,0x7
    800026a4:	db098993          	addi	s3,s3,-592 # 80009450 <digits+0x2e0>
    printf("%d %s %s", p->pid, state, p->name);
    800026a8:	00007a97          	auipc	s5,0x7
    800026ac:	db0a8a93          	addi	s5,s5,-592 # 80009458 <digits+0x2e8>
    printf("\n");
    800026b0:	00007a17          	auipc	s4,0x7
    800026b4:	b50a0a13          	addi	s4,s4,-1200 # 80009200 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	00007b97          	auipc	s7,0x7
    800026bc:	e58b8b93          	addi	s7,s7,-424 # 80009510 <states.1830>
    800026c0:	a00d                	j	800026e2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026c2:	ee06a583          	lw	a1,-288(a3)
    800026c6:	8556                	mv	a0,s5
    800026c8:	ffffe097          	auipc	ra,0xffffe
    800026cc:	f04080e7          	jalr	-252(ra) # 800005cc <printf>
    printf("\n");
    800026d0:	8552                	mv	a0,s4
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	efa080e7          	jalr	-262(ra) # 800005cc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026da:	17848493          	addi	s1,s1,376
    800026de:	03248163          	beq	s1,s2,80002700 <procdump+0x98>
    if(p->state == UNUSED)
    800026e2:	86a6                	mv	a3,s1
    800026e4:	ec04a783          	lw	a5,-320(s1)
    800026e8:	dbed                	beqz	a5,800026da <procdump+0x72>
      state = "???";
    800026ea:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ec:	fcfb6be3          	bltu	s6,a5,800026c2 <procdump+0x5a>
    800026f0:	1782                	slli	a5,a5,0x20
    800026f2:	9381                	srli	a5,a5,0x20
    800026f4:	078e                	slli	a5,a5,0x3
    800026f6:	97de                	add	a5,a5,s7
    800026f8:	6390                	ld	a2,0(a5)
    800026fa:	f661                	bnez	a2,800026c2 <procdump+0x5a>
      state = "???";
    800026fc:	864e                	mv	a2,s3
    800026fe:	b7d1                	j	800026c2 <procdump+0x5a>
}
    80002700:	60a6                	ld	ra,72(sp)
    80002702:	6406                	ld	s0,64(sp)
    80002704:	74e2                	ld	s1,56(sp)
    80002706:	7942                	ld	s2,48(sp)
    80002708:	79a2                	ld	s3,40(sp)
    8000270a:	7a02                	ld	s4,32(sp)
    8000270c:	6ae2                	ld	s5,24(sp)
    8000270e:	6b42                	ld	s6,16(sp)
    80002710:	6ba2                	ld	s7,8(sp)
    80002712:	6161                	addi	sp,sp,80
    80002714:	8082                	ret

0000000080002716 <test_rcu>:

// main RCU test function
void
test_rcu(void)
{
    80002716:	1101                	addi	sp,sp,-32
    80002718:	ec06                	sd	ra,24(sp)
    8000271a:	e822                	sd	s0,16(sp)
    8000271c:	e426                	sd	s1,8(sp)
    8000271e:	e04a                	sd	s2,0(sp)
    80002720:	1000                	addi	s0,sp,32
  printf("=== RCU test start ===\n");
    80002722:	00007517          	auipc	a0,0x7
    80002726:	d4650513          	addi	a0,a0,-698 # 80009468 <digits+0x2f8>
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	ea2080e7          	jalr	-350(ra) # 800005cc <printf>

  static struct test_data *global = 0;

  // create first object
  struct test_data *d1 = kalloc();
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	31a080e7          	jalr	794(ra) # 80000a4c <kalloc>
  d1->value = 100;
    8000273a:	06400793          	li	a5,100
    8000273e:	c11c                	sw	a5,0(a0)
  global = d1;
    80002740:	00008497          	auipc	s1,0x8
    80002744:	89848493          	addi	s1,s1,-1896 # 80009fd8 <global.1847>
    80002748:	e088                	sd	a0,0(s1)
  printf("[init] global value=%d\n", global->value);
    8000274a:	06400593          	li	a1,100
    8000274e:	00007517          	auipc	a0,0x7
    80002752:	d3250513          	addi	a0,a0,-718 # 80009480 <digits+0x310>
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	e76080e7          	jalr	-394(ra) # 800005cc <printf>

  // reader section
  rcu_read_lock();
    8000275e:	00005097          	auipc	ra,0x5
    80002762:	9d8080e7          	jalr	-1576(ra) # 80007136 <rcu_read_lock>
  struct test_data *local = global;
  printf("[reader] read value=%d\n", local->value);
    80002766:	609c                	ld	a5,0(s1)
    80002768:	438c                	lw	a1,0(a5)
    8000276a:	00007517          	auipc	a0,0x7
    8000276e:	d2e50513          	addi	a0,a0,-722 # 80009498 <digits+0x328>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	e5a080e7          	jalr	-422(ra) # 800005cc <printf>
  rcu_read_unlock();
    8000277a:	00005097          	auipc	ra,0x5
    8000277e:	9de080e7          	jalr	-1570(ra) # 80007158 <rcu_read_unlock>

  // writer creates new version
  struct test_data *d2 = kalloc();
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	2ca080e7          	jalr	714(ra) # 80000a4c <kalloc>
  d2->value = 200;
    8000278a:	0c800793          	li	a5,200
    8000278e:	c11c                	sw	a5,0(a0)
  struct test_data *old = global;
    80002790:	0004b903          	ld	s2,0(s1)
  global = d2;
    80002794:	e088                	sd	a0,0(s1)
  printf("[writer] updated global to %d\n", global->value);
    80002796:	0c800593          	li	a1,200
    8000279a:	00007517          	auipc	a0,0x7
    8000279e:	d1650513          	addi	a0,a0,-746 # 800094b0 <digits+0x340>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	e2a080e7          	jalr	-470(ra) # 800005cc <printf>

  // schedule deferred free
  call_rcu(&old->rcu, rcu_free_callback);
    800027aa:	fffff597          	auipc	a1,0xfffff
    800027ae:	2ba58593          	addi	a1,a1,698 # 80001a64 <rcu_free_callback>
    800027b2:	00890513          	addi	a0,s2,8
    800027b6:	00005097          	auipc	ra,0x5
    800027ba:	9c4080e7          	jalr	-1596(ra) # 8000717a <call_rcu>

  // wait until all readers finish, then run callback
  synchronize_rcu();
    800027be:	00005097          	auipc	ra,0x5
    800027c2:	a02080e7          	jalr	-1534(ra) # 800071c0 <synchronize_rcu>

  printf("=== RCU test done ===\n");
    800027c6:	00007517          	auipc	a0,0x7
    800027ca:	d0a50513          	addi	a0,a0,-758 # 800094d0 <digits+0x360>
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	dfe080e7          	jalr	-514(ra) # 800005cc <printf>
}
    800027d6:	60e2                	ld	ra,24(sp)
    800027d8:	6442                	ld	s0,16(sp)
    800027da:	64a2                	ld	s1,8(sp)
    800027dc:	6902                	ld	s2,0(sp)
    800027de:	6105                	addi	sp,sp,32
    800027e0:	8082                	ret

00000000800027e2 <swtch>:
    800027e2:	00153023          	sd	ra,0(a0)
    800027e6:	00253423          	sd	sp,8(a0)
    800027ea:	e900                	sd	s0,16(a0)
    800027ec:	ed04                	sd	s1,24(a0)
    800027ee:	03253023          	sd	s2,32(a0)
    800027f2:	03353423          	sd	s3,40(a0)
    800027f6:	03453823          	sd	s4,48(a0)
    800027fa:	03553c23          	sd	s5,56(a0)
    800027fe:	05653023          	sd	s6,64(a0)
    80002802:	05753423          	sd	s7,72(a0)
    80002806:	05853823          	sd	s8,80(a0)
    8000280a:	05953c23          	sd	s9,88(a0)
    8000280e:	07a53023          	sd	s10,96(a0)
    80002812:	07b53423          	sd	s11,104(a0)
    80002816:	0005b083          	ld	ra,0(a1)
    8000281a:	0085b103          	ld	sp,8(a1)
    8000281e:	6980                	ld	s0,16(a1)
    80002820:	6d84                	ld	s1,24(a1)
    80002822:	0205b903          	ld	s2,32(a1)
    80002826:	0285b983          	ld	s3,40(a1)
    8000282a:	0305ba03          	ld	s4,48(a1)
    8000282e:	0385ba83          	ld	s5,56(a1)
    80002832:	0405bb03          	ld	s6,64(a1)
    80002836:	0485bb83          	ld	s7,72(a1)
    8000283a:	0505bc03          	ld	s8,80(a1)
    8000283e:	0585bc83          	ld	s9,88(a1)
    80002842:	0605bd03          	ld	s10,96(a1)
    80002846:	0685bd83          	ld	s11,104(a1)
    8000284a:	8082                	ret

000000008000284c <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    8000284c:	1141                	addi	sp,sp,-16
    8000284e:	e422                	sd	s0,8(sp)
    80002850:	0800                	addi	s0,sp,16
    80002852:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002854:	00151713          	slli	a4,a0,0x1
    80002858:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    8000285a:	04054c63          	bltz	a0,800028b2 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    8000285e:	5685                	li	a3,-31
    80002860:	8285                	srli	a3,a3,0x1
    80002862:	8ee9                	and	a3,a3,a0
    80002864:	caad                	beqz	a3,800028d6 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002866:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002868:	00007517          	auipc	a0,0x7
    8000286c:	cd050513          	addi	a0,a0,-816 # 80009538 <states.1830+0x28>
    } else if (code <= 23) {
    80002870:	06e6f063          	bgeu	a3,a4,800028d0 <scause_desc+0x84>
    } else if (code <= 31) {
    80002874:	fc100693          	li	a3,-63
    80002878:	8285                	srli	a3,a3,0x1
    8000287a:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    8000287c:	00007517          	auipc	a0,0x7
    80002880:	ce450513          	addi	a0,a0,-796 # 80009560 <states.1830+0x50>
    } else if (code <= 31) {
    80002884:	c6b1                	beqz	a3,800028d0 <scause_desc+0x84>
    } else if (code <= 47) {
    80002886:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    8000288a:	00007517          	auipc	a0,0x7
    8000288e:	cae50513          	addi	a0,a0,-850 # 80009538 <states.1830+0x28>
    } else if (code <= 47) {
    80002892:	02e6ff63          	bgeu	a3,a4,800028d0 <scause_desc+0x84>
    } else if (code <= 63) {
    80002896:	f8100513          	li	a0,-127
    8000289a:	8105                	srli	a0,a0,0x1
    8000289c:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    8000289e:	00007517          	auipc	a0,0x7
    800028a2:	cc250513          	addi	a0,a0,-830 # 80009560 <states.1830+0x50>
    } else if (code <= 63) {
    800028a6:	c78d                	beqz	a5,800028d0 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800028a8:	00007517          	auipc	a0,0x7
    800028ac:	c9050513          	addi	a0,a0,-880 # 80009538 <states.1830+0x28>
    800028b0:	a005                	j	800028d0 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800028b2:	5505                	li	a0,-31
    800028b4:	8105                	srli	a0,a0,0x1
    800028b6:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800028b8:	00007517          	auipc	a0,0x7
    800028bc:	cc850513          	addi	a0,a0,-824 # 80009580 <states.1830+0x70>
    if (code < NELEM(intr_desc)) {
    800028c0:	eb81                	bnez	a5,800028d0 <scause_desc+0x84>
      return intr_desc[code];
    800028c2:	070e                	slli	a4,a4,0x3
    800028c4:	00007797          	auipc	a5,0x7
    800028c8:	fcc78793          	addi	a5,a5,-52 # 80009890 <intr_desc.1628>
    800028cc:	973e                	add	a4,a4,a5
    800028ce:	6308                	ld	a0,0(a4)
    }
  }
}
    800028d0:	6422                	ld	s0,8(sp)
    800028d2:	0141                	addi	sp,sp,16
    800028d4:	8082                	ret
      return nointr_desc[code];
    800028d6:	070e                	slli	a4,a4,0x3
    800028d8:	00007797          	auipc	a5,0x7
    800028dc:	fb878793          	addi	a5,a5,-72 # 80009890 <intr_desc.1628>
    800028e0:	973e                	add	a4,a4,a5
    800028e2:	6348                	ld	a0,128(a4)
    800028e4:	b7f5                	j	800028d0 <scause_desc+0x84>

00000000800028e6 <trapinit>:
{
    800028e6:	1141                	addi	sp,sp,-16
    800028e8:	e406                	sd	ra,8(sp)
    800028ea:	e022                	sd	s0,0(sp)
    800028ec:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028ee:	00007597          	auipc	a1,0x7
    800028f2:	cb258593          	addi	a1,a1,-846 # 800095a0 <states.1830+0x90>
    800028f6:	00029517          	auipc	a0,0x29
    800028fa:	41250513          	addi	a0,a0,1042 # 8002bd08 <tickslock>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	1c8080e7          	jalr	456(ra) # 80000ac6 <initlock>
}
    80002906:	60a2                	ld	ra,8(sp)
    80002908:	6402                	ld	s0,0(sp)
    8000290a:	0141                	addi	sp,sp,16
    8000290c:	8082                	ret

000000008000290e <trapinithart>:
{
    8000290e:	1141                	addi	sp,sp,-16
    80002910:	e422                	sd	s0,8(sp)
    80002912:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002914:	00003797          	auipc	a5,0x3
    80002918:	48c78793          	addi	a5,a5,1164 # 80005da0 <kernelvec>
    8000291c:	10579073          	csrw	stvec,a5
}
    80002920:	6422                	ld	s0,8(sp)
    80002922:	0141                	addi	sp,sp,16
    80002924:	8082                	ret

0000000080002926 <usertrapret>:
{
    80002926:	1141                	addi	sp,sp,-16
    80002928:	e406                	sd	ra,8(sp)
    8000292a:	e022                	sd	s0,0(sp)
    8000292c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	268080e7          	jalr	616(ra) # 80001b96 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002936:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000293a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293c:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002940:	00005617          	auipc	a2,0x5
    80002944:	6c060613          	addi	a2,a2,1728 # 80008000 <_trampoline>
    80002948:	00005697          	auipc	a3,0x5
    8000294c:	6b868693          	addi	a3,a3,1720 # 80008000 <_trampoline>
    80002950:	8e91                	sub	a3,a3,a2
    80002952:	040007b7          	lui	a5,0x4000
    80002956:	17fd                	addi	a5,a5,-1
    80002958:	07b2                	slli	a5,a5,0xc
    8000295a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000295c:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002960:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002962:	180026f3          	csrr	a3,satp
    80002966:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002968:	7138                	ld	a4,96(a0)
    8000296a:	6534                	ld	a3,72(a0)
    8000296c:	6585                	lui	a1,0x1
    8000296e:	96ae                	add	a3,a3,a1
    80002970:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002972:	7138                	ld	a4,96(a0)
    80002974:	00000697          	auipc	a3,0x0
    80002978:	12268693          	addi	a3,a3,290 # 80002a96 <usertrap>
    8000297c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000297e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002980:	8692                	mv	a3,tp
    80002982:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002984:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002988:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000298c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002990:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    80002994:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002996:	6f18                	ld	a4,24(a4)
    80002998:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    8000299c:	6d2c                	ld	a1,88(a0)
    8000299e:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029a0:	00005717          	auipc	a4,0x5
    800029a4:	6f070713          	addi	a4,a4,1776 # 80008090 <userret>
    800029a8:	8f11                	sub	a4,a4,a2
    800029aa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    800029ac:	577d                	li	a4,-1
    800029ae:	177e                	slli	a4,a4,0x3f
    800029b0:	8dd9                	or	a1,a1,a4
    800029b2:	17053503          	ld	a0,368(a0)
    800029b6:	9782                	jalr	a5
}
    800029b8:	60a2                	ld	ra,8(sp)
    800029ba:	6402                	ld	s0,0(sp)
    800029bc:	0141                	addi	sp,sp,16
    800029be:	8082                	ret

00000000800029c0 <clockintr>:
{
    800029c0:	1101                	addi	sp,sp,-32
    800029c2:	ec06                	sd	ra,24(sp)
    800029c4:	e822                	sd	s0,16(sp)
    800029c6:	e426                	sd	s1,8(sp)
    800029c8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029ca:	00029497          	auipc	s1,0x29
    800029ce:	33e48493          	addi	s1,s1,830 # 8002bd08 <tickslock>
    800029d2:	8526                	mv	a0,s1
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	1c8080e7          	jalr	456(ra) # 80000b9c <acquire>
  ticks++;
    800029dc:	00007517          	auipc	a0,0x7
    800029e0:	60c50513          	addi	a0,a0,1548 # 80009fe8 <ticks>
    800029e4:	411c                	lw	a5,0(a0)
    800029e6:	2785                	addiw	a5,a5,1
    800029e8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029ea:	00000097          	auipc	ra,0x0
    800029ee:	af6080e7          	jalr	-1290(ra) # 800024e0 <wakeup>
  release(&tickslock);
    800029f2:	8526                	mv	a0,s1
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	278080e7          	jalr	632(ra) # 80000c6c <release>
}
    800029fc:	60e2                	ld	ra,24(sp)
    800029fe:	6442                	ld	s0,16(sp)
    80002a00:	64a2                	ld	s1,8(sp)
    80002a02:	6105                	addi	sp,sp,32
    80002a04:	8082                	ret

0000000080002a06 <devintr>:
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a10:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002a14:	00074d63          	bltz	a4,80002a2e <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002a18:	57fd                	li	a5,-1
    80002a1a:	17fe                	slli	a5,a5,0x3f
    80002a1c:	0785                	addi	a5,a5,1
    return 0;
    80002a1e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a20:	04f70a63          	beq	a4,a5,80002a74 <devintr+0x6e>
}
    80002a24:	60e2                	ld	ra,24(sp)
    80002a26:	6442                	ld	s0,16(sp)
    80002a28:	64a2                	ld	s1,8(sp)
    80002a2a:	6105                	addi	sp,sp,32
    80002a2c:	8082                	ret
     (scause & 0xff) == 9){
    80002a2e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a32:	46a5                	li	a3,9
    80002a34:	fed792e3          	bne	a5,a3,80002a18 <devintr+0x12>
    int irq = plic_claim();
    80002a38:	00003097          	auipc	ra,0x3
    80002a3c:	470080e7          	jalr	1136(ra) # 80005ea8 <plic_claim>
    80002a40:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a42:	47a9                	li	a5,10
    80002a44:	00f50863          	beq	a0,a5,80002a54 <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002a48:	4785                	li	a5,1
    80002a4a:	02f50063          	beq	a0,a5,80002a6a <devintr+0x64>
    return 1;
    80002a4e:	4505                	li	a0,1
    if(irq)
    80002a50:	d8f1                	beqz	s1,80002a24 <devintr+0x1e>
    80002a52:	a029                	j	80002a5c <devintr+0x56>
      uartintr();
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	ec6080e7          	jalr	-314(ra) # 8000091a <uartintr>
      plic_complete(irq);
    80002a5c:	8526                	mv	a0,s1
    80002a5e:	00003097          	auipc	ra,0x3
    80002a62:	46e080e7          	jalr	1134(ra) # 80005ecc <plic_complete>
    return 1;
    80002a66:	4505                	li	a0,1
    80002a68:	bf75                	j	80002a24 <devintr+0x1e>
      virtio_disk_intr();
    80002a6a:	00004097          	auipc	ra,0x4
    80002a6e:	976080e7          	jalr	-1674(ra) # 800063e0 <virtio_disk_intr>
    80002a72:	b7ed                	j	80002a5c <devintr+0x56>
    if(cpuid() == 0){
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	0f6080e7          	jalr	246(ra) # 80001b6a <cpuid>
    80002a7c:	c901                	beqz	a0,80002a8c <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a7e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a82:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a84:	14479073          	csrw	sip,a5
    return 2;
    80002a88:	4509                	li	a0,2
    80002a8a:	bf69                	j	80002a24 <devintr+0x1e>
      clockintr();
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	f34080e7          	jalr	-204(ra) # 800029c0 <clockintr>
    80002a94:	b7ed                	j	80002a7e <devintr+0x78>

0000000080002a96 <usertrap>:
{
    80002a96:	7179                	addi	sp,sp,-48
    80002a98:	f406                	sd	ra,40(sp)
    80002a9a:	f022                	sd	s0,32(sp)
    80002a9c:	ec26                	sd	s1,24(sp)
    80002a9e:	e84a                	sd	s2,16(sp)
    80002aa0:	e44e                	sd	s3,8(sp)
    80002aa2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002aa8:	1007f793          	andi	a5,a5,256
    80002aac:	e3b5                	bnez	a5,80002b10 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aae:	00003797          	auipc	a5,0x3
    80002ab2:	2f278793          	addi	a5,a5,754 # 80005da0 <kernelvec>
    80002ab6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	0dc080e7          	jalr	220(ra) # 80001b96 <myproc>
    80002ac2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ac4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ac6:	14102773          	csrr	a4,sepc
    80002aca:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002acc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002ad0:	47a1                	li	a5,8
    80002ad2:	04f71d63          	bne	a4,a5,80002b2c <usertrap+0x96>
    if(p->killed)
    80002ad6:	5d1c                	lw	a5,56(a0)
    80002ad8:	e7a1                	bnez	a5,80002b20 <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002ada:	70b8                	ld	a4,96(s1)
    80002adc:	6f1c                	ld	a5,24(a4)
    80002ade:	0791                	addi	a5,a5,4
    80002ae0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ae6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aea:	10079073          	csrw	sstatus,a5
    syscall();
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	2fe080e7          	jalr	766(ra) # 80002dec <syscall>
  if(p->killed)
    80002af6:	5c9c                	lw	a5,56(s1)
    80002af8:	e3cd                	bnez	a5,80002b9a <usertrap+0x104>
  usertrapret();
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	e2c080e7          	jalr	-468(ra) # 80002926 <usertrapret>
}
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6145                	addi	sp,sp,48
    80002b0e:	8082                	ret
    panic("usertrap: not from user mode");
    80002b10:	00007517          	auipc	a0,0x7
    80002b14:	a9850513          	addi	a0,a0,-1384 # 800095a8 <states.1830+0x98>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a52080e7          	jalr	-1454(ra) # 8000056a <panic>
      exit(-1);
    80002b20:	557d                	li	a0,-1
    80002b22:	fffff097          	auipc	ra,0xfffff
    80002b26:	6f2080e7          	jalr	1778(ra) # 80002214 <exit>
    80002b2a:	bf45                	j	80002ada <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	eda080e7          	jalr	-294(ra) # 80002a06 <devintr>
    80002b34:	892a                	mv	s2,a0
    80002b36:	c501                	beqz	a0,80002b3e <usertrap+0xa8>
  if(p->killed)
    80002b38:	5c9c                	lw	a5,56(s1)
    80002b3a:	cba1                	beqz	a5,80002b8a <usertrap+0xf4>
    80002b3c:	a091                	j	80002b80 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b3e:	142029f3          	csrr	s3,scause
    80002b42:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002b46:	00000097          	auipc	ra,0x0
    80002b4a:	d06080e7          	jalr	-762(ra) # 8000284c <scause_desc>
    80002b4e:	862a                	mv	a2,a0
    80002b50:	40b4                	lw	a3,64(s1)
    80002b52:	85ce                	mv	a1,s3
    80002b54:	00007517          	auipc	a0,0x7
    80002b58:	a7450513          	addi	a0,a0,-1420 # 800095c8 <states.1830+0xb8>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	a70080e7          	jalr	-1424(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b64:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b68:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b6c:	00007517          	auipc	a0,0x7
    80002b70:	a8c50513          	addi	a0,a0,-1396 # 800095f8 <states.1830+0xe8>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	a58080e7          	jalr	-1448(ra) # 800005cc <printf>
    p->killed = 1;
    80002b7c:	4785                	li	a5,1
    80002b7e:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002b80:	557d                	li	a0,-1
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	692080e7          	jalr	1682(ra) # 80002214 <exit>
  if(which_dev == 2)
    80002b8a:	4789                	li	a5,2
    80002b8c:	f6f917e3          	bne	s2,a5,80002afa <usertrap+0x64>
    yield();
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	78e080e7          	jalr	1934(ra) # 8000231e <yield>
    80002b98:	b78d                	j	80002afa <usertrap+0x64>
  int which_dev = 0;
    80002b9a:	4901                	li	s2,0
    80002b9c:	b7d5                	j	80002b80 <usertrap+0xea>

0000000080002b9e <kerneltrap>:
{
    80002b9e:	7179                	addi	sp,sp,-48
    80002ba0:	f406                	sd	ra,40(sp)
    80002ba2:	f022                	sd	s0,32(sp)
    80002ba4:	ec26                	sd	s1,24(sp)
    80002ba6:	e84a                	sd	s2,16(sp)
    80002ba8:	e44e                	sd	s3,8(sp)
    80002baa:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bac:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bb8:	1004f793          	andi	a5,s1,256
    80002bbc:	cb85                	beqz	a5,80002bec <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bc4:	ef85                	bnez	a5,80002bfc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	e40080e7          	jalr	-448(ra) # 80002a06 <devintr>
    80002bce:	cd1d                	beqz	a0,80002c0c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bd0:	4789                	li	a5,2
    80002bd2:	08f50063          	beq	a0,a5,80002c52 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bda:	10049073          	csrw	sstatus,s1
}
    80002bde:	70a2                	ld	ra,40(sp)
    80002be0:	7402                	ld	s0,32(sp)
    80002be2:	64e2                	ld	s1,24(sp)
    80002be4:	6942                	ld	s2,16(sp)
    80002be6:	69a2                	ld	s3,8(sp)
    80002be8:	6145                	addi	sp,sp,48
    80002bea:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bec:	00007517          	auipc	a0,0x7
    80002bf0:	a2c50513          	addi	a0,a0,-1492 # 80009618 <states.1830+0x108>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	976080e7          	jalr	-1674(ra) # 8000056a <panic>
    panic("kerneltrap: interrupts enabled");
    80002bfc:	00007517          	auipc	a0,0x7
    80002c00:	a4450513          	addi	a0,a0,-1468 # 80009640 <states.1830+0x130>
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	966080e7          	jalr	-1690(ra) # 8000056a <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002c0c:	854e                	mv	a0,s3
    80002c0e:	00000097          	auipc	ra,0x0
    80002c12:	c3e080e7          	jalr	-962(ra) # 8000284c <scause_desc>
    80002c16:	862a                	mv	a2,a0
    80002c18:	85ce                	mv	a1,s3
    80002c1a:	00007517          	auipc	a0,0x7
    80002c1e:	a4650513          	addi	a0,a0,-1466 # 80009660 <states.1830+0x150>
    80002c22:	ffffe097          	auipc	ra,0xffffe
    80002c26:	9aa080e7          	jalr	-1622(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c2a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c2e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c32:	00007517          	auipc	a0,0x7
    80002c36:	a3e50513          	addi	a0,a0,-1474 # 80009670 <states.1830+0x160>
    80002c3a:	ffffe097          	auipc	ra,0xffffe
    80002c3e:	992080e7          	jalr	-1646(ra) # 800005cc <printf>
    panic("kerneltrap");
    80002c42:	00007517          	auipc	a0,0x7
    80002c46:	a4650513          	addi	a0,a0,-1466 # 80009688 <states.1830+0x178>
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	920080e7          	jalr	-1760(ra) # 8000056a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	f44080e7          	jalr	-188(ra) # 80001b96 <myproc>
    80002c5a:	dd35                	beqz	a0,80002bd6 <kerneltrap+0x38>
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	f3a080e7          	jalr	-198(ra) # 80001b96 <myproc>
    80002c64:	5118                	lw	a4,32(a0)
    80002c66:	478d                	li	a5,3
    80002c68:	f6f717e3          	bne	a4,a5,80002bd6 <kerneltrap+0x38>
    yield();
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	6b2080e7          	jalr	1714(ra) # 8000231e <yield>
    80002c74:	b78d                	j	80002bd6 <kerneltrap+0x38>

0000000080002c76 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	1000                	addi	s0,sp,32
    80002c80:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	f14080e7          	jalr	-236(ra) # 80001b96 <myproc>
  switch (n) {
    80002c8a:	4795                	li	a5,5
    80002c8c:	0497e163          	bltu	a5,s1,80002cce <argraw+0x58>
    80002c90:	048a                	slli	s1,s1,0x2
    80002c92:	00007717          	auipc	a4,0x7
    80002c96:	d2670713          	addi	a4,a4,-730 # 800099b8 <nointr_desc.1629+0xa8>
    80002c9a:	94ba                	add	s1,s1,a4
    80002c9c:	409c                	lw	a5,0(s1)
    80002c9e:	97ba                	add	a5,a5,a4
    80002ca0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ca2:	713c                	ld	a5,96(a0)
    80002ca4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6105                	addi	sp,sp,32
    80002cae:	8082                	ret
    return p->trapframe->a1;
    80002cb0:	713c                	ld	a5,96(a0)
    80002cb2:	7fa8                	ld	a0,120(a5)
    80002cb4:	bfcd                	j	80002ca6 <argraw+0x30>
    return p->trapframe->a2;
    80002cb6:	713c                	ld	a5,96(a0)
    80002cb8:	63c8                	ld	a0,128(a5)
    80002cba:	b7f5                	j	80002ca6 <argraw+0x30>
    return p->trapframe->a3;
    80002cbc:	713c                	ld	a5,96(a0)
    80002cbe:	67c8                	ld	a0,136(a5)
    80002cc0:	b7dd                	j	80002ca6 <argraw+0x30>
    return p->trapframe->a4;
    80002cc2:	713c                	ld	a5,96(a0)
    80002cc4:	6bc8                	ld	a0,144(a5)
    80002cc6:	b7c5                	j	80002ca6 <argraw+0x30>
    return p->trapframe->a5;
    80002cc8:	713c                	ld	a5,96(a0)
    80002cca:	6fc8                	ld	a0,152(a5)
    80002ccc:	bfe9                	j	80002ca6 <argraw+0x30>
  panic("argraw");
    80002cce:	00007517          	auipc	a0,0x7
    80002cd2:	cc250513          	addi	a0,a0,-830 # 80009990 <nointr_desc.1629+0x80>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	894080e7          	jalr	-1900(ra) # 8000056a <panic>

0000000080002cde <fetchaddr>:
{
    80002cde:	1101                	addi	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	e426                	sd	s1,8(sp)
    80002ce6:	e04a                	sd	s2,0(sp)
    80002ce8:	1000                	addi	s0,sp,32
    80002cea:	84aa                	mv	s1,a0
    80002cec:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	ea8080e7          	jalr	-344(ra) # 80001b96 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002cf6:	693c                	ld	a5,80(a0)
    80002cf8:	02f4f863          	bgeu	s1,a5,80002d28 <fetchaddr+0x4a>
    80002cfc:	00848713          	addi	a4,s1,8
    80002d00:	02e7e663          	bltu	a5,a4,80002d2c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d04:	46a1                	li	a3,8
    80002d06:	8626                	mv	a2,s1
    80002d08:	85ca                	mv	a1,s2
    80002d0a:	6d28                	ld	a0,88(a0)
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	b9a080e7          	jalr	-1126(ra) # 800018a6 <copyin>
    80002d14:	00a03533          	snez	a0,a0
    80002d18:	40a00533          	neg	a0,a0
}
    80002d1c:	60e2                	ld	ra,24(sp)
    80002d1e:	6442                	ld	s0,16(sp)
    80002d20:	64a2                	ld	s1,8(sp)
    80002d22:	6902                	ld	s2,0(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret
    return -1;
    80002d28:	557d                	li	a0,-1
    80002d2a:	bfcd                	j	80002d1c <fetchaddr+0x3e>
    80002d2c:	557d                	li	a0,-1
    80002d2e:	b7fd                	j	80002d1c <fetchaddr+0x3e>

0000000080002d30 <fetchstr>:
{
    80002d30:	7179                	addi	sp,sp,-48
    80002d32:	f406                	sd	ra,40(sp)
    80002d34:	f022                	sd	s0,32(sp)
    80002d36:	ec26                	sd	s1,24(sp)
    80002d38:	e84a                	sd	s2,16(sp)
    80002d3a:	e44e                	sd	s3,8(sp)
    80002d3c:	1800                	addi	s0,sp,48
    80002d3e:	892a                	mv	s2,a0
    80002d40:	84ae                	mv	s1,a1
    80002d42:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d44:	fffff097          	auipc	ra,0xfffff
    80002d48:	e52080e7          	jalr	-430(ra) # 80001b96 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d4c:	86ce                	mv	a3,s3
    80002d4e:	864a                	mv	a2,s2
    80002d50:	85a6                	mv	a1,s1
    80002d52:	6d28                	ld	a0,88(a0)
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	bde080e7          	jalr	-1058(ra) # 80001932 <copyinstr>
  if(err < 0)
    80002d5c:	00054763          	bltz	a0,80002d6a <fetchstr+0x3a>
  return strlen(buf);
    80002d60:	8526                	mv	a0,s1
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	2ce080e7          	jalr	718(ra) # 80001030 <strlen>
}
    80002d6a:	70a2                	ld	ra,40(sp)
    80002d6c:	7402                	ld	s0,32(sp)
    80002d6e:	64e2                	ld	s1,24(sp)
    80002d70:	6942                	ld	s2,16(sp)
    80002d72:	69a2                	ld	s3,8(sp)
    80002d74:	6145                	addi	sp,sp,48
    80002d76:	8082                	ret

0000000080002d78 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	1000                	addi	s0,sp,32
    80002d82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d84:	00000097          	auipc	ra,0x0
    80002d88:	ef2080e7          	jalr	-270(ra) # 80002c76 <argraw>
    80002d8c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d8e:	4501                	li	a0,0
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	ed0080e7          	jalr	-304(ra) # 80002c76 <argraw>
    80002dae:	e088                	sd	a0,0(s1)
  return 0;
}
    80002db0:	4501                	li	a0,0
    80002db2:	60e2                	ld	ra,24(sp)
    80002db4:	6442                	ld	s0,16(sp)
    80002db6:	64a2                	ld	s1,8(sp)
    80002db8:	6105                	addi	sp,sp,32
    80002dba:	8082                	ret

0000000080002dbc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	e04a                	sd	s2,0(sp)
    80002dc6:	1000                	addi	s0,sp,32
    80002dc8:	84ae                	mv	s1,a1
    80002dca:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002dcc:	00000097          	auipc	ra,0x0
    80002dd0:	eaa080e7          	jalr	-342(ra) # 80002c76 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002dd4:	864a                	mv	a2,s2
    80002dd6:	85a6                	mv	a1,s1
    80002dd8:	00000097          	auipc	ra,0x0
    80002ddc:	f58080e7          	jalr	-168(ra) # 80002d30 <fetchstr>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6902                	ld	s2,0(sp)
    80002de8:	6105                	addi	sp,sp,32
    80002dea:	8082                	ret

0000000080002dec <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	e426                	sd	s1,8(sp)
    80002df4:	e04a                	sd	s2,0(sp)
    80002df6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	d9e080e7          	jalr	-610(ra) # 80001b96 <myproc>
    80002e00:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e02:	06053903          	ld	s2,96(a0)
    80002e06:	0a893783          	ld	a5,168(s2)
    80002e0a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e0e:	37fd                	addiw	a5,a5,-1
    80002e10:	4759                	li	a4,22
    80002e12:	00f76f63          	bltu	a4,a5,80002e30 <syscall+0x44>
    80002e16:	00369713          	slli	a4,a3,0x3
    80002e1a:	00007797          	auipc	a5,0x7
    80002e1e:	bb678793          	addi	a5,a5,-1098 # 800099d0 <syscalls>
    80002e22:	97ba                	add	a5,a5,a4
    80002e24:	639c                	ld	a5,0(a5)
    80002e26:	c789                	beqz	a5,80002e30 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e28:	9782                	jalr	a5
    80002e2a:	06a93823          	sd	a0,112(s2)
    80002e2e:	a839                	j	80002e4c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e30:	16048613          	addi	a2,s1,352
    80002e34:	40ac                	lw	a1,64(s1)
    80002e36:	00007517          	auipc	a0,0x7
    80002e3a:	b6250513          	addi	a0,a0,-1182 # 80009998 <nointr_desc.1629+0x88>
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	78e080e7          	jalr	1934(ra) # 800005cc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e46:	70bc                	ld	a5,96(s1)
    80002e48:	577d                	li	a4,-1
    80002e4a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6902                	ld	s2,0(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e60:	fec40593          	addi	a1,s0,-20
    80002e64:	4501                	li	a0,0
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	f12080e7          	jalr	-238(ra) # 80002d78 <argint>
    return -1;
    80002e6e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e70:	00054963          	bltz	a0,80002e82 <sys_exit+0x2a>
  exit(n);
    80002e74:	fec42503          	lw	a0,-20(s0)
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	39c080e7          	jalr	924(ra) # 80002214 <exit>
  return 0;  // not reached
    80002e80:	4781                	li	a5,0
}
    80002e82:	853e                	mv	a0,a5
    80002e84:	60e2                	ld	ra,24(sp)
    80002e86:	6442                	ld	s0,16(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret

0000000080002e8c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e8c:	1141                	addi	sp,sp,-16
    80002e8e:	e406                	sd	ra,8(sp)
    80002e90:	e022                	sd	s0,0(sp)
    80002e92:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e94:	fffff097          	auipc	ra,0xfffff
    80002e98:	d02080e7          	jalr	-766(ra) # 80001b96 <myproc>
}
    80002e9c:	4128                	lw	a0,64(a0)
    80002e9e:	60a2                	ld	ra,8(sp)
    80002ea0:	6402                	ld	s0,0(sp)
    80002ea2:	0141                	addi	sp,sp,16
    80002ea4:	8082                	ret

0000000080002ea6 <sys_fork>:

uint64
sys_fork(void)
{
    80002ea6:	1141                	addi	sp,sp,-16
    80002ea8:	e406                	sd	ra,8(sp)
    80002eaa:	e022                	sd	s0,0(sp)
    80002eac:	0800                	addi	s0,sp,16
  return fork();
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	05e080e7          	jalr	94(ra) # 80001f0c <fork>
}
    80002eb6:	60a2                	ld	ra,8(sp)
    80002eb8:	6402                	ld	s0,0(sp)
    80002eba:	0141                	addi	sp,sp,16
    80002ebc:	8082                	ret

0000000080002ebe <sys_wait>:

uint64
sys_wait(void)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ec6:	fe840593          	addi	a1,s0,-24
    80002eca:	4501                	li	a0,0
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	ece080e7          	jalr	-306(ra) # 80002d9a <argaddr>
    80002ed4:	87aa                	mv	a5,a0
    return -1;
    80002ed6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ed8:	0007c863          	bltz	a5,80002ee8 <sys_wait+0x2a>
  return wait(p);
    80002edc:	fe843503          	ld	a0,-24(s0)
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	4f8080e7          	jalr	1272(ra) # 800023d8 <wait>
}
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	6105                	addi	sp,sp,32
    80002eee:	8082                	ret

0000000080002ef0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ef0:	7179                	addi	sp,sp,-48
    80002ef2:	f406                	sd	ra,40(sp)
    80002ef4:	f022                	sd	s0,32(sp)
    80002ef6:	ec26                	sd	s1,24(sp)
    80002ef8:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002efa:	fdc40593          	addi	a1,s0,-36
    80002efe:	4501                	li	a0,0
    80002f00:	00000097          	auipc	ra,0x0
    80002f04:	e78080e7          	jalr	-392(ra) # 80002d78 <argint>
    80002f08:	87aa                	mv	a5,a0
    return -1;
    80002f0a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f0c:	0207c063          	bltz	a5,80002f2c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	c86080e7          	jalr	-890(ra) # 80001b96 <myproc>
    80002f18:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002f1a:	fdc42503          	lw	a0,-36(s0)
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	f7a080e7          	jalr	-134(ra) # 80001e98 <growproc>
    80002f26:	00054863          	bltz	a0,80002f36 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f2a:	8526                	mv	a0,s1
}
    80002f2c:	70a2                	ld	ra,40(sp)
    80002f2e:	7402                	ld	s0,32(sp)
    80002f30:	64e2                	ld	s1,24(sp)
    80002f32:	6145                	addi	sp,sp,48
    80002f34:	8082                	ret
    return -1;
    80002f36:	557d                	li	a0,-1
    80002f38:	bfd5                	j	80002f2c <sys_sbrk+0x3c>

0000000080002f3a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f3a:	7139                	addi	sp,sp,-64
    80002f3c:	fc06                	sd	ra,56(sp)
    80002f3e:	f822                	sd	s0,48(sp)
    80002f40:	f426                	sd	s1,40(sp)
    80002f42:	f04a                	sd	s2,32(sp)
    80002f44:	ec4e                	sd	s3,24(sp)
    80002f46:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f48:	fcc40593          	addi	a1,s0,-52
    80002f4c:	4501                	li	a0,0
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	e2a080e7          	jalr	-470(ra) # 80002d78 <argint>
    return -1;
    80002f56:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f58:	06054563          	bltz	a0,80002fc2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002f5c:	00029517          	auipc	a0,0x29
    80002f60:	dac50513          	addi	a0,a0,-596 # 8002bd08 <tickslock>
    80002f64:	ffffe097          	auipc	ra,0xffffe
    80002f68:	c38080e7          	jalr	-968(ra) # 80000b9c <acquire>
  ticks0 = ticks;
    80002f6c:	00007917          	auipc	s2,0x7
    80002f70:	07c92903          	lw	s2,124(s2) # 80009fe8 <ticks>
  while(ticks - ticks0 < n){
    80002f74:	fcc42783          	lw	a5,-52(s0)
    80002f78:	cf85                	beqz	a5,80002fb0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f7a:	00029997          	auipc	s3,0x29
    80002f7e:	d8e98993          	addi	s3,s3,-626 # 8002bd08 <tickslock>
    80002f82:	00007497          	auipc	s1,0x7
    80002f86:	06648493          	addi	s1,s1,102 # 80009fe8 <ticks>
    if(myproc()->killed){
    80002f8a:	fffff097          	auipc	ra,0xfffff
    80002f8e:	c0c080e7          	jalr	-1012(ra) # 80001b96 <myproc>
    80002f92:	5d1c                	lw	a5,56(a0)
    80002f94:	ef9d                	bnez	a5,80002fd2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f96:	85ce                	mv	a1,s3
    80002f98:	8526                	mv	a0,s1
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	3c0080e7          	jalr	960(ra) # 8000235a <sleep>
  while(ticks - ticks0 < n){
    80002fa2:	409c                	lw	a5,0(s1)
    80002fa4:	412787bb          	subw	a5,a5,s2
    80002fa8:	fcc42703          	lw	a4,-52(s0)
    80002fac:	fce7efe3          	bltu	a5,a4,80002f8a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fb0:	00029517          	auipc	a0,0x29
    80002fb4:	d5850513          	addi	a0,a0,-680 # 8002bd08 <tickslock>
    80002fb8:	ffffe097          	auipc	ra,0xffffe
    80002fbc:	cb4080e7          	jalr	-844(ra) # 80000c6c <release>
  return 0;
    80002fc0:	4781                	li	a5,0
}
    80002fc2:	853e                	mv	a0,a5
    80002fc4:	70e2                	ld	ra,56(sp)
    80002fc6:	7442                	ld	s0,48(sp)
    80002fc8:	74a2                	ld	s1,40(sp)
    80002fca:	7902                	ld	s2,32(sp)
    80002fcc:	69e2                	ld	s3,24(sp)
    80002fce:	6121                	addi	sp,sp,64
    80002fd0:	8082                	ret
      release(&tickslock);
    80002fd2:	00029517          	auipc	a0,0x29
    80002fd6:	d3650513          	addi	a0,a0,-714 # 8002bd08 <tickslock>
    80002fda:	ffffe097          	auipc	ra,0xffffe
    80002fde:	c92080e7          	jalr	-878(ra) # 80000c6c <release>
      return -1;
    80002fe2:	57fd                	li	a5,-1
    80002fe4:	bff9                	j	80002fc2 <sys_sleep+0x88>

0000000080002fe6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fe6:	1101                	addi	sp,sp,-32
    80002fe8:	ec06                	sd	ra,24(sp)
    80002fea:	e822                	sd	s0,16(sp)
    80002fec:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002fee:	fec40593          	addi	a1,s0,-20
    80002ff2:	4501                	li	a0,0
    80002ff4:	00000097          	auipc	ra,0x0
    80002ff8:	d84080e7          	jalr	-636(ra) # 80002d78 <argint>
    80002ffc:	87aa                	mv	a5,a0
    return -1;
    80002ffe:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003000:	0007c863          	bltz	a5,80003010 <sys_kill+0x2a>
  return kill(pid);
    80003004:	fec42503          	lw	a0,-20(s0)
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	542080e7          	jalr	1346(ra) # 8000254a <kill>
}
    80003010:	60e2                	ld	ra,24(sp)
    80003012:	6442                	ld	s0,16(sp)
    80003014:	6105                	addi	sp,sp,32
    80003016:	8082                	ret

0000000080003018 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003018:	1101                	addi	sp,sp,-32
    8000301a:	ec06                	sd	ra,24(sp)
    8000301c:	e822                	sd	s0,16(sp)
    8000301e:	e426                	sd	s1,8(sp)
    80003020:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003022:	00029517          	auipc	a0,0x29
    80003026:	ce650513          	addi	a0,a0,-794 # 8002bd08 <tickslock>
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	b72080e7          	jalr	-1166(ra) # 80000b9c <acquire>
  xticks = ticks;
    80003032:	00007497          	auipc	s1,0x7
    80003036:	fb64a483          	lw	s1,-74(s1) # 80009fe8 <ticks>
  release(&tickslock);
    8000303a:	00029517          	auipc	a0,0x29
    8000303e:	cce50513          	addi	a0,a0,-818 # 8002bd08 <tickslock>
    80003042:	ffffe097          	auipc	ra,0xffffe
    80003046:	c2a080e7          	jalr	-982(ra) # 80000c6c <release>
  return xticks;
}
    8000304a:	02049513          	slli	a0,s1,0x20
    8000304e:	9101                	srli	a0,a0,0x20
    80003050:	60e2                	ld	ra,24(sp)
    80003052:	6442                	ld	s0,16(sp)
    80003054:	64a2                	ld	s1,8(sp)
    80003056:	6105                	addi	sp,sp,32
    80003058:	8082                	ret

000000008000305a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000305a:	7179                	addi	sp,sp,-48
    8000305c:	f406                	sd	ra,40(sp)
    8000305e:	f022                	sd	s0,32(sp)
    80003060:	ec26                	sd	s1,24(sp)
    80003062:	e84a                	sd	s2,16(sp)
    80003064:	e44e                	sd	s3,8(sp)
    80003066:	e052                	sd	s4,0(sp)
    80003068:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000306a:	00007597          	auipc	a1,0x7
    8000306e:	a2658593          	addi	a1,a1,-1498 # 80009a90 <syscalls+0xc0>
    80003072:	00029517          	auipc	a0,0x29
    80003076:	cb650513          	addi	a0,a0,-842 # 8002bd28 <bcache>
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	a4c080e7          	jalr	-1460(ra) # 80000ac6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003082:	00031797          	auipc	a5,0x31
    80003086:	ca678793          	addi	a5,a5,-858 # 80033d28 <bcache+0x8000>
    8000308a:	00031717          	auipc	a4,0x31
    8000308e:	ffe70713          	addi	a4,a4,-2 # 80034088 <bcache+0x8360>
    80003092:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80003096:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000309a:	00029497          	auipc	s1,0x29
    8000309e:	cae48493          	addi	s1,s1,-850 # 8002bd48 <bcache+0x20>
    b->next = bcache.head.next;
    800030a2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030a4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030a6:	00007a17          	auipc	s4,0x7
    800030aa:	9f2a0a13          	addi	s4,s4,-1550 # 80009a98 <syscalls+0xc8>
    b->next = bcache.head.next;
    800030ae:	3b893783          	ld	a5,952(s2)
    800030b2:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    800030b4:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    800030b8:	85d2                	mv	a1,s4
    800030ba:	01048513          	addi	a0,s1,16
    800030be:	00001097          	auipc	ra,0x1
    800030c2:	4aa080e7          	jalr	1194(ra) # 80004568 <initsleeplock>
    bcache.head.next->prev = b;
    800030c6:	3b893783          	ld	a5,952(s2)
    800030ca:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    800030cc:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030d0:	46048493          	addi	s1,s1,1120
    800030d4:	fd349de3          	bne	s1,s3,800030ae <binit+0x54>
  }
}
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6a02                	ld	s4,0(sp)
    800030e4:	6145                	addi	sp,sp,48
    800030e6:	8082                	ret

00000000800030e8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
    800030f6:	89aa                	mv	s3,a0
    800030f8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800030fa:	00029517          	auipc	a0,0x29
    800030fe:	c2e50513          	addi	a0,a0,-978 # 8002bd28 <bcache>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	a9a080e7          	jalr	-1382(ra) # 80000b9c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000310a:	00031497          	auipc	s1,0x31
    8000310e:	fd64b483          	ld	s1,-42(s1) # 800340e0 <bcache+0x83b8>
    80003112:	00031797          	auipc	a5,0x31
    80003116:	f7678793          	addi	a5,a5,-138 # 80034088 <bcache+0x8360>
    8000311a:	02f48f63          	beq	s1,a5,80003158 <bread+0x70>
    8000311e:	873e                	mv	a4,a5
    80003120:	a021                	j	80003128 <bread+0x40>
    80003122:	6ca4                	ld	s1,88(s1)
    80003124:	02e48a63          	beq	s1,a4,80003158 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003128:	449c                	lw	a5,8(s1)
    8000312a:	ff379ce3          	bne	a5,s3,80003122 <bread+0x3a>
    8000312e:	44dc                	lw	a5,12(s1)
    80003130:	ff2799e3          	bne	a5,s2,80003122 <bread+0x3a>
      b->refcnt++;
    80003134:	44bc                	lw	a5,72(s1)
    80003136:	2785                	addiw	a5,a5,1
    80003138:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000313a:	00029517          	auipc	a0,0x29
    8000313e:	bee50513          	addi	a0,a0,-1042 # 8002bd28 <bcache>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	b2a080e7          	jalr	-1238(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    8000314a:	01048513          	addi	a0,s1,16
    8000314e:	00001097          	auipc	ra,0x1
    80003152:	454080e7          	jalr	1108(ra) # 800045a2 <acquiresleep>
      return b;
    80003156:	a8b9                	j	800031b4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003158:	00031497          	auipc	s1,0x31
    8000315c:	f804b483          	ld	s1,-128(s1) # 800340d8 <bcache+0x83b0>
    80003160:	00031797          	auipc	a5,0x31
    80003164:	f2878793          	addi	a5,a5,-216 # 80034088 <bcache+0x8360>
    80003168:	00f48863          	beq	s1,a5,80003178 <bread+0x90>
    8000316c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000316e:	44bc                	lw	a5,72(s1)
    80003170:	cf81                	beqz	a5,80003188 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003172:	68a4                	ld	s1,80(s1)
    80003174:	fee49de3          	bne	s1,a4,8000316e <bread+0x86>
  panic("bget: no buffers");
    80003178:	00007517          	auipc	a0,0x7
    8000317c:	92850513          	addi	a0,a0,-1752 # 80009aa0 <syscalls+0xd0>
    80003180:	ffffd097          	auipc	ra,0xffffd
    80003184:	3ea080e7          	jalr	1002(ra) # 8000056a <panic>
      b->dev = dev;
    80003188:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000318c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003190:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003194:	4785                	li	a5,1
    80003196:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003198:	00029517          	auipc	a0,0x29
    8000319c:	b9050513          	addi	a0,a0,-1136 # 8002bd28 <bcache>
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	acc080e7          	jalr	-1332(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    800031a8:	01048513          	addi	a0,s1,16
    800031ac:	00001097          	auipc	ra,0x1
    800031b0:	3f6080e7          	jalr	1014(ra) # 800045a2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031b4:	409c                	lw	a5,0(s1)
    800031b6:	cb89                	beqz	a5,800031c8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031b8:	8526                	mv	a0,s1
    800031ba:	70a2                	ld	ra,40(sp)
    800031bc:	7402                	ld	s0,32(sp)
    800031be:	64e2                	ld	s1,24(sp)
    800031c0:	6942                	ld	s2,16(sp)
    800031c2:	69a2                	ld	s3,8(sp)
    800031c4:	6145                	addi	sp,sp,48
    800031c6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031c8:	4581                	li	a1,0
    800031ca:	8526                	mv	a0,s1
    800031cc:	00003097          	auipc	ra,0x3
    800031d0:	f8c080e7          	jalr	-116(ra) # 80006158 <virtio_disk_rw>
    b->valid = 1;
    800031d4:	4785                	li	a5,1
    800031d6:	c09c                	sw	a5,0(s1)
  return b;
    800031d8:	b7c5                	j	800031b8 <bread+0xd0>

00000000800031da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	1000                	addi	s0,sp,32
    800031e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031e6:	0541                	addi	a0,a0,16
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	454080e7          	jalr	1108(ra) # 8000463c <holdingsleep>
    800031f0:	cd01                	beqz	a0,80003208 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031f2:	4585                	li	a1,1
    800031f4:	8526                	mv	a0,s1
    800031f6:	00003097          	auipc	ra,0x3
    800031fa:	f62080e7          	jalr	-158(ra) # 80006158 <virtio_disk_rw>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret
    panic("bwrite");
    80003208:	00007517          	auipc	a0,0x7
    8000320c:	8b050513          	addi	a0,a0,-1872 # 80009ab8 <syscalls+0xe8>
    80003210:	ffffd097          	auipc	ra,0xffffd
    80003214:	35a080e7          	jalr	858(ra) # 8000056a <panic>

0000000080003218 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	e04a                	sd	s2,0(sp)
    80003222:	1000                	addi	s0,sp,32
    80003224:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003226:	01050913          	addi	s2,a0,16
    8000322a:	854a                	mv	a0,s2
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	410080e7          	jalr	1040(ra) # 8000463c <holdingsleep>
    80003234:	c92d                	beqz	a0,800032a6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003236:	854a                	mv	a0,s2
    80003238:	00001097          	auipc	ra,0x1
    8000323c:	3c0080e7          	jalr	960(ra) # 800045f8 <releasesleep>

  acquire(&bcache.lock);
    80003240:	00029517          	auipc	a0,0x29
    80003244:	ae850513          	addi	a0,a0,-1304 # 8002bd28 <bcache>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	954080e7          	jalr	-1708(ra) # 80000b9c <acquire>
  b->refcnt--;
    80003250:	44bc                	lw	a5,72(s1)
    80003252:	37fd                	addiw	a5,a5,-1
    80003254:	0007871b          	sext.w	a4,a5
    80003258:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    8000325a:	eb05                	bnez	a4,8000328a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000325c:	6cbc                	ld	a5,88(s1)
    8000325e:	68b8                	ld	a4,80(s1)
    80003260:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003262:	68bc                	ld	a5,80(s1)
    80003264:	6cb8                	ld	a4,88(s1)
    80003266:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    80003268:	00031797          	auipc	a5,0x31
    8000326c:	ac078793          	addi	a5,a5,-1344 # 80033d28 <bcache+0x8000>
    80003270:	3b87b703          	ld	a4,952(a5)
    80003274:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    80003276:	00031717          	auipc	a4,0x31
    8000327a:	e1270713          	addi	a4,a4,-494 # 80034088 <bcache+0x8360>
    8000327e:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003280:	3b87b703          	ld	a4,952(a5)
    80003284:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    80003286:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    8000328a:	00029517          	auipc	a0,0x29
    8000328e:	a9e50513          	addi	a0,a0,-1378 # 8002bd28 <bcache>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	9da080e7          	jalr	-1574(ra) # 80000c6c <release>
}
    8000329a:	60e2                	ld	ra,24(sp)
    8000329c:	6442                	ld	s0,16(sp)
    8000329e:	64a2                	ld	s1,8(sp)
    800032a0:	6902                	ld	s2,0(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret
    panic("brelse");
    800032a6:	00007517          	auipc	a0,0x7
    800032aa:	81a50513          	addi	a0,a0,-2022 # 80009ac0 <syscalls+0xf0>
    800032ae:	ffffd097          	auipc	ra,0xffffd
    800032b2:	2bc080e7          	jalr	700(ra) # 8000056a <panic>

00000000800032b6 <bpin>:

void
bpin(struct buf *b) {
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	1000                	addi	s0,sp,32
    800032c0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032c2:	00029517          	auipc	a0,0x29
    800032c6:	a6650513          	addi	a0,a0,-1434 # 8002bd28 <bcache>
    800032ca:	ffffe097          	auipc	ra,0xffffe
    800032ce:	8d2080e7          	jalr	-1838(ra) # 80000b9c <acquire>
  b->refcnt++;
    800032d2:	44bc                	lw	a5,72(s1)
    800032d4:	2785                	addiw	a5,a5,1
    800032d6:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800032d8:	00029517          	auipc	a0,0x29
    800032dc:	a5050513          	addi	a0,a0,-1456 # 8002bd28 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	98c080e7          	jalr	-1652(ra) # 80000c6c <release>
}
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <bunpin>:

void
bunpin(struct buf *b) {
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
    800032fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fe:	00029517          	auipc	a0,0x29
    80003302:	a2a50513          	addi	a0,a0,-1494 # 8002bd28 <bcache>
    80003306:	ffffe097          	auipc	ra,0xffffe
    8000330a:	896080e7          	jalr	-1898(ra) # 80000b9c <acquire>
  b->refcnt--;
    8000330e:	44bc                	lw	a5,72(s1)
    80003310:	37fd                	addiw	a5,a5,-1
    80003312:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003314:	00029517          	auipc	a0,0x29
    80003318:	a1450513          	addi	a0,a0,-1516 # 8002bd28 <bcache>
    8000331c:	ffffe097          	auipc	ra,0xffffe
    80003320:	950080e7          	jalr	-1712(ra) # 80000c6c <release>
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret

000000008000332e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000332e:	1101                	addi	sp,sp,-32
    80003330:	ec06                	sd	ra,24(sp)
    80003332:	e822                	sd	s0,16(sp)
    80003334:	e426                	sd	s1,8(sp)
    80003336:	e04a                	sd	s2,0(sp)
    80003338:	1000                	addi	s0,sp,32
    8000333a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000333c:	00d5d59b          	srliw	a1,a1,0xd
    80003340:	00031797          	auipc	a5,0x31
    80003344:	1c47a783          	lw	a5,452(a5) # 80034504 <sb+0x1c>
    80003348:	9dbd                	addw	a1,a1,a5
    8000334a:	00000097          	auipc	ra,0x0
    8000334e:	d9e080e7          	jalr	-610(ra) # 800030e8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003352:	0074f713          	andi	a4,s1,7
    80003356:	4785                	li	a5,1
    80003358:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000335c:	14ce                	slli	s1,s1,0x33
    8000335e:	90d9                	srli	s1,s1,0x36
    80003360:	00950733          	add	a4,a0,s1
    80003364:	06074703          	lbu	a4,96(a4)
    80003368:	00e7f6b3          	and	a3,a5,a4
    8000336c:	c69d                	beqz	a3,8000339a <bfree+0x6c>
    8000336e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003370:	94aa                	add	s1,s1,a0
    80003372:	fff7c793          	not	a5,a5
    80003376:	8ff9                	and	a5,a5,a4
    80003378:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	106080e7          	jalr	262(ra) # 80004482 <log_write>
  brelse(bp);
    80003384:	854a                	mv	a0,s2
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e92080e7          	jalr	-366(ra) # 80003218 <brelse>
}
    8000338e:	60e2                	ld	ra,24(sp)
    80003390:	6442                	ld	s0,16(sp)
    80003392:	64a2                	ld	s1,8(sp)
    80003394:	6902                	ld	s2,0(sp)
    80003396:	6105                	addi	sp,sp,32
    80003398:	8082                	ret
    panic("freeing free block");
    8000339a:	00006517          	auipc	a0,0x6
    8000339e:	72e50513          	addi	a0,a0,1838 # 80009ac8 <syscalls+0xf8>
    800033a2:	ffffd097          	auipc	ra,0xffffd
    800033a6:	1c8080e7          	jalr	456(ra) # 8000056a <panic>

00000000800033aa <balloc>:
{
    800033aa:	711d                	addi	sp,sp,-96
    800033ac:	ec86                	sd	ra,88(sp)
    800033ae:	e8a2                	sd	s0,80(sp)
    800033b0:	e4a6                	sd	s1,72(sp)
    800033b2:	e0ca                	sd	s2,64(sp)
    800033b4:	fc4e                	sd	s3,56(sp)
    800033b6:	f852                	sd	s4,48(sp)
    800033b8:	f456                	sd	s5,40(sp)
    800033ba:	f05a                	sd	s6,32(sp)
    800033bc:	ec5e                	sd	s7,24(sp)
    800033be:	e862                	sd	s8,16(sp)
    800033c0:	e466                	sd	s9,8(sp)
    800033c2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033c4:	00031797          	auipc	a5,0x31
    800033c8:	1287a783          	lw	a5,296(a5) # 800344ec <sb+0x4>
    800033cc:	cbd1                	beqz	a5,80003460 <balloc+0xb6>
    800033ce:	8baa                	mv	s7,a0
    800033d0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033d2:	00031b17          	auipc	s6,0x31
    800033d6:	116b0b13          	addi	s6,s6,278 # 800344e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033da:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033dc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033de:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033e0:	6c89                	lui	s9,0x2
    800033e2:	a831                	j	800033fe <balloc+0x54>
    brelse(bp);
    800033e4:	854a                	mv	a0,s2
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	e32080e7          	jalr	-462(ra) # 80003218 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033ee:	015c87bb          	addw	a5,s9,s5
    800033f2:	00078a9b          	sext.w	s5,a5
    800033f6:	004b2703          	lw	a4,4(s6)
    800033fa:	06eaf363          	bgeu	s5,a4,80003460 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800033fe:	41fad79b          	sraiw	a5,s5,0x1f
    80003402:	0137d79b          	srliw	a5,a5,0x13
    80003406:	015787bb          	addw	a5,a5,s5
    8000340a:	40d7d79b          	sraiw	a5,a5,0xd
    8000340e:	01cb2583          	lw	a1,28(s6)
    80003412:	9dbd                	addw	a1,a1,a5
    80003414:	855e                	mv	a0,s7
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	cd2080e7          	jalr	-814(ra) # 800030e8 <bread>
    8000341e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003420:	004b2503          	lw	a0,4(s6)
    80003424:	000a849b          	sext.w	s1,s5
    80003428:	8662                	mv	a2,s8
    8000342a:	faa4fde3          	bgeu	s1,a0,800033e4 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000342e:	41f6579b          	sraiw	a5,a2,0x1f
    80003432:	01d7d69b          	srliw	a3,a5,0x1d
    80003436:	00c6873b          	addw	a4,a3,a2
    8000343a:	00777793          	andi	a5,a4,7
    8000343e:	9f95                	subw	a5,a5,a3
    80003440:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003444:	4037571b          	sraiw	a4,a4,0x3
    80003448:	00e906b3          	add	a3,s2,a4
    8000344c:	0606c683          	lbu	a3,96(a3)
    80003450:	00d7f5b3          	and	a1,a5,a3
    80003454:	cd91                	beqz	a1,80003470 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003456:	2605                	addiw	a2,a2,1
    80003458:	2485                	addiw	s1,s1,1
    8000345a:	fd4618e3          	bne	a2,s4,8000342a <balloc+0x80>
    8000345e:	b759                	j	800033e4 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003460:	00006517          	auipc	a0,0x6
    80003464:	68050513          	addi	a0,a0,1664 # 80009ae0 <syscalls+0x110>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	102080e7          	jalr	258(ra) # 8000056a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003470:	974a                	add	a4,a4,s2
    80003472:	8fd5                	or	a5,a5,a3
    80003474:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	008080e7          	jalr	8(ra) # 80004482 <log_write>
        brelse(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00000097          	auipc	ra,0x0
    80003488:	d94080e7          	jalr	-620(ra) # 80003218 <brelse>
  bp = bread(dev, bno);
    8000348c:	85a6                	mv	a1,s1
    8000348e:	855e                	mv	a0,s7
    80003490:	00000097          	auipc	ra,0x0
    80003494:	c58080e7          	jalr	-936(ra) # 800030e8 <bread>
    80003498:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000349a:	40000613          	li	a2,1024
    8000349e:	4581                	li	a1,0
    800034a0:	06050513          	addi	a0,a0,96
    800034a4:	ffffe097          	auipc	ra,0xffffe
    800034a8:	9dc080e7          	jalr	-1572(ra) # 80000e80 <memset>
  log_write(bp);
    800034ac:	854a                	mv	a0,s2
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	fd4080e7          	jalr	-44(ra) # 80004482 <log_write>
  brelse(bp);
    800034b6:	854a                	mv	a0,s2
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	d60080e7          	jalr	-672(ra) # 80003218 <brelse>
}
    800034c0:	8526                	mv	a0,s1
    800034c2:	60e6                	ld	ra,88(sp)
    800034c4:	6446                	ld	s0,80(sp)
    800034c6:	64a6                	ld	s1,72(sp)
    800034c8:	6906                	ld	s2,64(sp)
    800034ca:	79e2                	ld	s3,56(sp)
    800034cc:	7a42                	ld	s4,48(sp)
    800034ce:	7aa2                	ld	s5,40(sp)
    800034d0:	7b02                	ld	s6,32(sp)
    800034d2:	6be2                	ld	s7,24(sp)
    800034d4:	6c42                	ld	s8,16(sp)
    800034d6:	6ca2                	ld	s9,8(sp)
    800034d8:	6125                	addi	sp,sp,96
    800034da:	8082                	ret

00000000800034dc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034dc:	7179                	addi	sp,sp,-48
    800034de:	f406                	sd	ra,40(sp)
    800034e0:	f022                	sd	s0,32(sp)
    800034e2:	ec26                	sd	s1,24(sp)
    800034e4:	e84a                	sd	s2,16(sp)
    800034e6:	e44e                	sd	s3,8(sp)
    800034e8:	e052                	sd	s4,0(sp)
    800034ea:	1800                	addi	s0,sp,48
    800034ec:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034ee:	47ad                	li	a5,11
    800034f0:	04b7fe63          	bgeu	a5,a1,8000354c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034f4:	ff45849b          	addiw	s1,a1,-12
    800034f8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034fc:	0ff00793          	li	a5,255
    80003500:	0ae7e363          	bltu	a5,a4,800035a6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003504:	08852583          	lw	a1,136(a0)
    80003508:	c5ad                	beqz	a1,80003572 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000350a:	00092503          	lw	a0,0(s2)
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	bda080e7          	jalr	-1062(ra) # 800030e8 <bread>
    80003516:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003518:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    8000351c:	02049593          	slli	a1,s1,0x20
    80003520:	9181                	srli	a1,a1,0x20
    80003522:	058a                	slli	a1,a1,0x2
    80003524:	00b784b3          	add	s1,a5,a1
    80003528:	0004a983          	lw	s3,0(s1)
    8000352c:	04098d63          	beqz	s3,80003586 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003530:	8552                	mv	a0,s4
    80003532:	00000097          	auipc	ra,0x0
    80003536:	ce6080e7          	jalr	-794(ra) # 80003218 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000353a:	854e                	mv	a0,s3
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6a02                	ld	s4,0(sp)
    80003548:	6145                	addi	sp,sp,48
    8000354a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000354c:	02059493          	slli	s1,a1,0x20
    80003550:	9081                	srli	s1,s1,0x20
    80003552:	048a                	slli	s1,s1,0x2
    80003554:	94aa                	add	s1,s1,a0
    80003556:	0584a983          	lw	s3,88(s1)
    8000355a:	fe0990e3          	bnez	s3,8000353a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000355e:	4108                	lw	a0,0(a0)
    80003560:	00000097          	auipc	ra,0x0
    80003564:	e4a080e7          	jalr	-438(ra) # 800033aa <balloc>
    80003568:	0005099b          	sext.w	s3,a0
    8000356c:	0534ac23          	sw	s3,88(s1)
    80003570:	b7e9                	j	8000353a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003572:	4108                	lw	a0,0(a0)
    80003574:	00000097          	auipc	ra,0x0
    80003578:	e36080e7          	jalr	-458(ra) # 800033aa <balloc>
    8000357c:	0005059b          	sext.w	a1,a0
    80003580:	08b92423          	sw	a1,136(s2)
    80003584:	b759                	j	8000350a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003586:	00092503          	lw	a0,0(s2)
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	e20080e7          	jalr	-480(ra) # 800033aa <balloc>
    80003592:	0005099b          	sext.w	s3,a0
    80003596:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000359a:	8552                	mv	a0,s4
    8000359c:	00001097          	auipc	ra,0x1
    800035a0:	ee6080e7          	jalr	-282(ra) # 80004482 <log_write>
    800035a4:	b771                	j	80003530 <bmap+0x54>
  panic("bmap: out of range");
    800035a6:	00006517          	auipc	a0,0x6
    800035aa:	55250513          	addi	a0,a0,1362 # 80009af8 <syscalls+0x128>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	fbc080e7          	jalr	-68(ra) # 8000056a <panic>

00000000800035b6 <iget>:
{
    800035b6:	7179                	addi	sp,sp,-48
    800035b8:	f406                	sd	ra,40(sp)
    800035ba:	f022                	sd	s0,32(sp)
    800035bc:	ec26                	sd	s1,24(sp)
    800035be:	e84a                	sd	s2,16(sp)
    800035c0:	e44e                	sd	s3,8(sp)
    800035c2:	e052                	sd	s4,0(sp)
    800035c4:	1800                	addi	s0,sp,48
    800035c6:	89aa                	mv	s3,a0
    800035c8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800035ca:	00031517          	auipc	a0,0x31
    800035ce:	f3e50513          	addi	a0,a0,-194 # 80034508 <icache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	5ca080e7          	jalr	1482(ra) # 80000b9c <acquire>
  empty = 0;
    800035da:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035dc:	00031497          	auipc	s1,0x31
    800035e0:	f4c48493          	addi	s1,s1,-180 # 80034528 <icache+0x20>
    800035e4:	00033697          	auipc	a3,0x33
    800035e8:	b6468693          	addi	a3,a3,-1180 # 80036148 <log>
    800035ec:	a039                	j	800035fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035ee:	02090b63          	beqz	s2,80003624 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035f2:	09048493          	addi	s1,s1,144
    800035f6:	02d48a63          	beq	s1,a3,8000362a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035fa:	449c                	lw	a5,8(s1)
    800035fc:	fef059e3          	blez	a5,800035ee <iget+0x38>
    80003600:	4098                	lw	a4,0(s1)
    80003602:	ff3716e3          	bne	a4,s3,800035ee <iget+0x38>
    80003606:	40d8                	lw	a4,4(s1)
    80003608:	ff4713e3          	bne	a4,s4,800035ee <iget+0x38>
      ip->ref++;
    8000360c:	2785                	addiw	a5,a5,1
    8000360e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003610:	00031517          	auipc	a0,0x31
    80003614:	ef850513          	addi	a0,a0,-264 # 80034508 <icache>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	654080e7          	jalr	1620(ra) # 80000c6c <release>
      return ip;
    80003620:	8926                	mv	s2,s1
    80003622:	a03d                	j	80003650 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003624:	f7f9                	bnez	a5,800035f2 <iget+0x3c>
    80003626:	8926                	mv	s2,s1
    80003628:	b7e9                	j	800035f2 <iget+0x3c>
  if(empty == 0)
    8000362a:	02090c63          	beqz	s2,80003662 <iget+0xac>
  ip->dev = dev;
    8000362e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003632:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003636:	4785                	li	a5,1
    80003638:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000363c:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003640:	00031517          	auipc	a0,0x31
    80003644:	ec850513          	addi	a0,a0,-312 # 80034508 <icache>
    80003648:	ffffd097          	auipc	ra,0xffffd
    8000364c:	624080e7          	jalr	1572(ra) # 80000c6c <release>
}
    80003650:	854a                	mv	a0,s2
    80003652:	70a2                	ld	ra,40(sp)
    80003654:	7402                	ld	s0,32(sp)
    80003656:	64e2                	ld	s1,24(sp)
    80003658:	6942                	ld	s2,16(sp)
    8000365a:	69a2                	ld	s3,8(sp)
    8000365c:	6a02                	ld	s4,0(sp)
    8000365e:	6145                	addi	sp,sp,48
    80003660:	8082                	ret
    panic("iget: no inodes");
    80003662:	00006517          	auipc	a0,0x6
    80003666:	4ae50513          	addi	a0,a0,1198 # 80009b10 <syscalls+0x140>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	f00080e7          	jalr	-256(ra) # 8000056a <panic>

0000000080003672 <fsinit>:
fsinit(int dev) {
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	ec26                	sd	s1,24(sp)
    8000367a:	e84a                	sd	s2,16(sp)
    8000367c:	e44e                	sd	s3,8(sp)
    8000367e:	1800                	addi	s0,sp,48
    80003680:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003682:	4585                	li	a1,1
    80003684:	00000097          	auipc	ra,0x0
    80003688:	a64080e7          	jalr	-1436(ra) # 800030e8 <bread>
    8000368c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000368e:	00031997          	auipc	s3,0x31
    80003692:	e5a98993          	addi	s3,s3,-422 # 800344e8 <sb>
    80003696:	02000613          	li	a2,32
    8000369a:	06050593          	addi	a1,a0,96
    8000369e:	854e                	mv	a0,s3
    800036a0:	ffffe097          	auipc	ra,0xffffe
    800036a4:	840080e7          	jalr	-1984(ra) # 80000ee0 <memmove>
  brelse(bp);
    800036a8:	8526                	mv	a0,s1
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	b6e080e7          	jalr	-1170(ra) # 80003218 <brelse>
  if(sb.magic != FSMAGIC)
    800036b2:	0009a703          	lw	a4,0(s3)
    800036b6:	102037b7          	lui	a5,0x10203
    800036ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036be:	02f71263          	bne	a4,a5,800036e2 <fsinit+0x70>
  initlog(dev, &sb);
    800036c2:	00031597          	auipc	a1,0x31
    800036c6:	e2658593          	addi	a1,a1,-474 # 800344e8 <sb>
    800036ca:	854a                	mv	a0,s2
    800036cc:	00001097          	auipc	ra,0x1
    800036d0:	b3e080e7          	jalr	-1218(ra) # 8000420a <initlog>
}
    800036d4:	70a2                	ld	ra,40(sp)
    800036d6:	7402                	ld	s0,32(sp)
    800036d8:	64e2                	ld	s1,24(sp)
    800036da:	6942                	ld	s2,16(sp)
    800036dc:	69a2                	ld	s3,8(sp)
    800036de:	6145                	addi	sp,sp,48
    800036e0:	8082                	ret
    panic("invalid file system");
    800036e2:	00006517          	auipc	a0,0x6
    800036e6:	43e50513          	addi	a0,a0,1086 # 80009b20 <syscalls+0x150>
    800036ea:	ffffd097          	auipc	ra,0xffffd
    800036ee:	e80080e7          	jalr	-384(ra) # 8000056a <panic>

00000000800036f2 <iinit>:
{
    800036f2:	7179                	addi	sp,sp,-48
    800036f4:	f406                	sd	ra,40(sp)
    800036f6:	f022                	sd	s0,32(sp)
    800036f8:	ec26                	sd	s1,24(sp)
    800036fa:	e84a                	sd	s2,16(sp)
    800036fc:	e44e                	sd	s3,8(sp)
    800036fe:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003700:	00006597          	auipc	a1,0x6
    80003704:	43858593          	addi	a1,a1,1080 # 80009b38 <syscalls+0x168>
    80003708:	00031517          	auipc	a0,0x31
    8000370c:	e0050513          	addi	a0,a0,-512 # 80034508 <icache>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	3b6080e7          	jalr	950(ra) # 80000ac6 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003718:	00031497          	auipc	s1,0x31
    8000371c:	e2048493          	addi	s1,s1,-480 # 80034538 <icache+0x30>
    80003720:	00033997          	auipc	s3,0x33
    80003724:	a3898993          	addi	s3,s3,-1480 # 80036158 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003728:	00006917          	auipc	s2,0x6
    8000372c:	41890913          	addi	s2,s2,1048 # 80009b40 <syscalls+0x170>
    80003730:	85ca                	mv	a1,s2
    80003732:	8526                	mv	a0,s1
    80003734:	00001097          	auipc	ra,0x1
    80003738:	e34080e7          	jalr	-460(ra) # 80004568 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000373c:	09048493          	addi	s1,s1,144
    80003740:	ff3498e3          	bne	s1,s3,80003730 <iinit+0x3e>
}
    80003744:	70a2                	ld	ra,40(sp)
    80003746:	7402                	ld	s0,32(sp)
    80003748:	64e2                	ld	s1,24(sp)
    8000374a:	6942                	ld	s2,16(sp)
    8000374c:	69a2                	ld	s3,8(sp)
    8000374e:	6145                	addi	sp,sp,48
    80003750:	8082                	ret

0000000080003752 <ialloc>:
{
    80003752:	715d                	addi	sp,sp,-80
    80003754:	e486                	sd	ra,72(sp)
    80003756:	e0a2                	sd	s0,64(sp)
    80003758:	fc26                	sd	s1,56(sp)
    8000375a:	f84a                	sd	s2,48(sp)
    8000375c:	f44e                	sd	s3,40(sp)
    8000375e:	f052                	sd	s4,32(sp)
    80003760:	ec56                	sd	s5,24(sp)
    80003762:	e85a                	sd	s6,16(sp)
    80003764:	e45e                	sd	s7,8(sp)
    80003766:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003768:	00031717          	auipc	a4,0x31
    8000376c:	d8c72703          	lw	a4,-628(a4) # 800344f4 <sb+0xc>
    80003770:	4785                	li	a5,1
    80003772:	04e7fa63          	bgeu	a5,a4,800037c6 <ialloc+0x74>
    80003776:	8aaa                	mv	s5,a0
    80003778:	8bae                	mv	s7,a1
    8000377a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000377c:	00031a17          	auipc	s4,0x31
    80003780:	d6ca0a13          	addi	s4,s4,-660 # 800344e8 <sb>
    80003784:	00048b1b          	sext.w	s6,s1
    80003788:	0044d593          	srli	a1,s1,0x4
    8000378c:	018a2783          	lw	a5,24(s4)
    80003790:	9dbd                	addw	a1,a1,a5
    80003792:	8556                	mv	a0,s5
    80003794:	00000097          	auipc	ra,0x0
    80003798:	954080e7          	jalr	-1708(ra) # 800030e8 <bread>
    8000379c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000379e:	06050993          	addi	s3,a0,96
    800037a2:	00f4f793          	andi	a5,s1,15
    800037a6:	079a                	slli	a5,a5,0x6
    800037a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037aa:	00099783          	lh	a5,0(s3)
    800037ae:	c785                	beqz	a5,800037d6 <ialloc+0x84>
    brelse(bp);
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	a68080e7          	jalr	-1432(ra) # 80003218 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037b8:	0485                	addi	s1,s1,1
    800037ba:	00ca2703          	lw	a4,12(s4)
    800037be:	0004879b          	sext.w	a5,s1
    800037c2:	fce7e1e3          	bltu	a5,a4,80003784 <ialloc+0x32>
  panic("ialloc: no inodes");
    800037c6:	00006517          	auipc	a0,0x6
    800037ca:	38250513          	addi	a0,a0,898 # 80009b48 <syscalls+0x178>
    800037ce:	ffffd097          	auipc	ra,0xffffd
    800037d2:	d9c080e7          	jalr	-612(ra) # 8000056a <panic>
      memset(dip, 0, sizeof(*dip));
    800037d6:	04000613          	li	a2,64
    800037da:	4581                	li	a1,0
    800037dc:	854e                	mv	a0,s3
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	6a2080e7          	jalr	1698(ra) # 80000e80 <memset>
      dip->type = type;
    800037e6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ea:	854a                	mv	a0,s2
    800037ec:	00001097          	auipc	ra,0x1
    800037f0:	c96080e7          	jalr	-874(ra) # 80004482 <log_write>
      brelse(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	a22080e7          	jalr	-1502(ra) # 80003218 <brelse>
      return iget(dev, inum);
    800037fe:	85da                	mv	a1,s6
    80003800:	8556                	mv	a0,s5
    80003802:	00000097          	auipc	ra,0x0
    80003806:	db4080e7          	jalr	-588(ra) # 800035b6 <iget>
}
    8000380a:	60a6                	ld	ra,72(sp)
    8000380c:	6406                	ld	s0,64(sp)
    8000380e:	74e2                	ld	s1,56(sp)
    80003810:	7942                	ld	s2,48(sp)
    80003812:	79a2                	ld	s3,40(sp)
    80003814:	7a02                	ld	s4,32(sp)
    80003816:	6ae2                	ld	s5,24(sp)
    80003818:	6b42                	ld	s6,16(sp)
    8000381a:	6ba2                	ld	s7,8(sp)
    8000381c:	6161                	addi	sp,sp,80
    8000381e:	8082                	ret

0000000080003820 <iupdate>:
{
    80003820:	1101                	addi	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	e04a                	sd	s2,0(sp)
    8000382a:	1000                	addi	s0,sp,32
    8000382c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000382e:	415c                	lw	a5,4(a0)
    80003830:	0047d79b          	srliw	a5,a5,0x4
    80003834:	00031597          	auipc	a1,0x31
    80003838:	ccc5a583          	lw	a1,-820(a1) # 80034500 <sb+0x18>
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	4108                	lw	a0,0(a0)
    80003840:	00000097          	auipc	ra,0x0
    80003844:	8a8080e7          	jalr	-1880(ra) # 800030e8 <bread>
    80003848:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384a:	06050793          	addi	a5,a0,96
    8000384e:	40c8                	lw	a0,4(s1)
    80003850:	893d                	andi	a0,a0,15
    80003852:	051a                	slli	a0,a0,0x6
    80003854:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003856:	04c49703          	lh	a4,76(s1)
    8000385a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000385e:	04e49703          	lh	a4,78(s1)
    80003862:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003866:	05049703          	lh	a4,80(s1)
    8000386a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000386e:	05249703          	lh	a4,82(s1)
    80003872:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003876:	48f8                	lw	a4,84(s1)
    80003878:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000387a:	03400613          	li	a2,52
    8000387e:	05848593          	addi	a1,s1,88
    80003882:	0531                	addi	a0,a0,12
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	65c080e7          	jalr	1628(ra) # 80000ee0 <memmove>
  log_write(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	bf4080e7          	jalr	-1036(ra) # 80004482 <log_write>
  brelse(bp);
    80003896:	854a                	mv	a0,s2
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	980080e7          	jalr	-1664(ra) # 80003218 <brelse>
}
    800038a0:	60e2                	ld	ra,24(sp)
    800038a2:	6442                	ld	s0,16(sp)
    800038a4:	64a2                	ld	s1,8(sp)
    800038a6:	6902                	ld	s2,0(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <idup>:
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	1000                	addi	s0,sp,32
    800038b6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038b8:	00031517          	auipc	a0,0x31
    800038bc:	c5050513          	addi	a0,a0,-944 # 80034508 <icache>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	2dc080e7          	jalr	732(ra) # 80000b9c <acquire>
  ip->ref++;
    800038c8:	449c                	lw	a5,8(s1)
    800038ca:	2785                	addiw	a5,a5,1
    800038cc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800038ce:	00031517          	auipc	a0,0x31
    800038d2:	c3a50513          	addi	a0,a0,-966 # 80034508 <icache>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	396080e7          	jalr	918(ra) # 80000c6c <release>
}
    800038de:	8526                	mv	a0,s1
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6105                	addi	sp,sp,32
    800038e8:	8082                	ret

00000000800038ea <ilock>:
{
    800038ea:	1101                	addi	sp,sp,-32
    800038ec:	ec06                	sd	ra,24(sp)
    800038ee:	e822                	sd	s0,16(sp)
    800038f0:	e426                	sd	s1,8(sp)
    800038f2:	e04a                	sd	s2,0(sp)
    800038f4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f6:	c115                	beqz	a0,8000391a <ilock+0x30>
    800038f8:	84aa                	mv	s1,a0
    800038fa:	451c                	lw	a5,8(a0)
    800038fc:	00f05f63          	blez	a5,8000391a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003900:	0541                	addi	a0,a0,16
    80003902:	00001097          	auipc	ra,0x1
    80003906:	ca0080e7          	jalr	-864(ra) # 800045a2 <acquiresleep>
  if(ip->valid == 0){
    8000390a:	44bc                	lw	a5,72(s1)
    8000390c:	cf99                	beqz	a5,8000392a <ilock+0x40>
}
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	64a2                	ld	s1,8(sp)
    80003914:	6902                	ld	s2,0(sp)
    80003916:	6105                	addi	sp,sp,32
    80003918:	8082                	ret
    panic("ilock");
    8000391a:	00006517          	auipc	a0,0x6
    8000391e:	24650513          	addi	a0,a0,582 # 80009b60 <syscalls+0x190>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	c48080e7          	jalr	-952(ra) # 8000056a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000392a:	40dc                	lw	a5,4(s1)
    8000392c:	0047d79b          	srliw	a5,a5,0x4
    80003930:	00031597          	auipc	a1,0x31
    80003934:	bd05a583          	lw	a1,-1072(a1) # 80034500 <sb+0x18>
    80003938:	9dbd                	addw	a1,a1,a5
    8000393a:	4088                	lw	a0,0(s1)
    8000393c:	fffff097          	auipc	ra,0xfffff
    80003940:	7ac080e7          	jalr	1964(ra) # 800030e8 <bread>
    80003944:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003946:	06050593          	addi	a1,a0,96
    8000394a:	40dc                	lw	a5,4(s1)
    8000394c:	8bbd                	andi	a5,a5,15
    8000394e:	079a                	slli	a5,a5,0x6
    80003950:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003952:	00059783          	lh	a5,0(a1)
    80003956:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    8000395a:	00259783          	lh	a5,2(a1)
    8000395e:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003962:	00459783          	lh	a5,4(a1)
    80003966:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    8000396a:	00659783          	lh	a5,6(a1)
    8000396e:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003972:	459c                	lw	a5,8(a1)
    80003974:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003976:	03400613          	li	a2,52
    8000397a:	05b1                	addi	a1,a1,12
    8000397c:	05848513          	addi	a0,s1,88
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	560080e7          	jalr	1376(ra) # 80000ee0 <memmove>
    brelse(bp);
    80003988:	854a                	mv	a0,s2
    8000398a:	00000097          	auipc	ra,0x0
    8000398e:	88e080e7          	jalr	-1906(ra) # 80003218 <brelse>
    ip->valid = 1;
    80003992:	4785                	li	a5,1
    80003994:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003996:	04c49783          	lh	a5,76(s1)
    8000399a:	fbb5                	bnez	a5,8000390e <ilock+0x24>
      panic("ilock: no type");
    8000399c:	00006517          	auipc	a0,0x6
    800039a0:	1cc50513          	addi	a0,a0,460 # 80009b68 <syscalls+0x198>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	bc6080e7          	jalr	-1082(ra) # 8000056a <panic>

00000000800039ac <iunlock>:
{
    800039ac:	1101                	addi	sp,sp,-32
    800039ae:	ec06                	sd	ra,24(sp)
    800039b0:	e822                	sd	s0,16(sp)
    800039b2:	e426                	sd	s1,8(sp)
    800039b4:	e04a                	sd	s2,0(sp)
    800039b6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039b8:	c905                	beqz	a0,800039e8 <iunlock+0x3c>
    800039ba:	84aa                	mv	s1,a0
    800039bc:	01050913          	addi	s2,a0,16
    800039c0:	854a                	mv	a0,s2
    800039c2:	00001097          	auipc	ra,0x1
    800039c6:	c7a080e7          	jalr	-902(ra) # 8000463c <holdingsleep>
    800039ca:	cd19                	beqz	a0,800039e8 <iunlock+0x3c>
    800039cc:	449c                	lw	a5,8(s1)
    800039ce:	00f05d63          	blez	a5,800039e8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00001097          	auipc	ra,0x1
    800039d8:	c24080e7          	jalr	-988(ra) # 800045f8 <releasesleep>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6902                	ld	s2,0(sp)
    800039e4:	6105                	addi	sp,sp,32
    800039e6:	8082                	ret
    panic("iunlock");
    800039e8:	00006517          	auipc	a0,0x6
    800039ec:	19050513          	addi	a0,a0,400 # 80009b78 <syscalls+0x1a8>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	b7a080e7          	jalr	-1158(ra) # 8000056a <panic>

00000000800039f8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039f8:	7179                	addi	sp,sp,-48
    800039fa:	f406                	sd	ra,40(sp)
    800039fc:	f022                	sd	s0,32(sp)
    800039fe:	ec26                	sd	s1,24(sp)
    80003a00:	e84a                	sd	s2,16(sp)
    80003a02:	e44e                	sd	s3,8(sp)
    80003a04:	e052                	sd	s4,0(sp)
    80003a06:	1800                	addi	s0,sp,48
    80003a08:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a0a:	05850493          	addi	s1,a0,88
    80003a0e:	08850913          	addi	s2,a0,136
    80003a12:	a021                	j	80003a1a <itrunc+0x22>
    80003a14:	0491                	addi	s1,s1,4
    80003a16:	01248d63          	beq	s1,s2,80003a30 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a1a:	408c                	lw	a1,0(s1)
    80003a1c:	dde5                	beqz	a1,80003a14 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a1e:	0009a503          	lw	a0,0(s3)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	90c080e7          	jalr	-1780(ra) # 8000332e <bfree>
      ip->addrs[i] = 0;
    80003a2a:	0004a023          	sw	zero,0(s1)
    80003a2e:	b7dd                	j	80003a14 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a30:	0889a583          	lw	a1,136(s3)
    80003a34:	e185                	bnez	a1,80003a54 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a36:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003a3a:	854e                	mv	a0,s3
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	de4080e7          	jalr	-540(ra) # 80003820 <iupdate>
}
    80003a44:	70a2                	ld	ra,40(sp)
    80003a46:	7402                	ld	s0,32(sp)
    80003a48:	64e2                	ld	s1,24(sp)
    80003a4a:	6942                	ld	s2,16(sp)
    80003a4c:	69a2                	ld	s3,8(sp)
    80003a4e:	6a02                	ld	s4,0(sp)
    80003a50:	6145                	addi	sp,sp,48
    80003a52:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a54:	0009a503          	lw	a0,0(s3)
    80003a58:	fffff097          	auipc	ra,0xfffff
    80003a5c:	690080e7          	jalr	1680(ra) # 800030e8 <bread>
    80003a60:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a62:	06050493          	addi	s1,a0,96
    80003a66:	46050913          	addi	s2,a0,1120
    80003a6a:	a811                	j	80003a7e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a6c:	0009a503          	lw	a0,0(s3)
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	8be080e7          	jalr	-1858(ra) # 8000332e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a78:	0491                	addi	s1,s1,4
    80003a7a:	01248563          	beq	s1,s2,80003a84 <itrunc+0x8c>
      if(a[j])
    80003a7e:	408c                	lw	a1,0(s1)
    80003a80:	dde5                	beqz	a1,80003a78 <itrunc+0x80>
    80003a82:	b7ed                	j	80003a6c <itrunc+0x74>
    brelse(bp);
    80003a84:	8552                	mv	a0,s4
    80003a86:	fffff097          	auipc	ra,0xfffff
    80003a8a:	792080e7          	jalr	1938(ra) # 80003218 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a8e:	0889a583          	lw	a1,136(s3)
    80003a92:	0009a503          	lw	a0,0(s3)
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	898080e7          	jalr	-1896(ra) # 8000332e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a9e:	0809a423          	sw	zero,136(s3)
    80003aa2:	bf51                	j	80003a36 <itrunc+0x3e>

0000000080003aa4 <iput>:
{
    80003aa4:	1101                	addi	sp,sp,-32
    80003aa6:	ec06                	sd	ra,24(sp)
    80003aa8:	e822                	sd	s0,16(sp)
    80003aaa:	e426                	sd	s1,8(sp)
    80003aac:	e04a                	sd	s2,0(sp)
    80003aae:	1000                	addi	s0,sp,32
    80003ab0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003ab2:	00031517          	auipc	a0,0x31
    80003ab6:	a5650513          	addi	a0,a0,-1450 # 80034508 <icache>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	0e2080e7          	jalr	226(ra) # 80000b9c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ac2:	4498                	lw	a4,8(s1)
    80003ac4:	4785                	li	a5,1
    80003ac6:	02f70363          	beq	a4,a5,80003aec <iput+0x48>
  ip->ref--;
    80003aca:	449c                	lw	a5,8(s1)
    80003acc:	37fd                	addiw	a5,a5,-1
    80003ace:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ad0:	00031517          	auipc	a0,0x31
    80003ad4:	a3850513          	addi	a0,a0,-1480 # 80034508 <icache>
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	194080e7          	jalr	404(ra) # 80000c6c <release>
}
    80003ae0:	60e2                	ld	ra,24(sp)
    80003ae2:	6442                	ld	s0,16(sp)
    80003ae4:	64a2                	ld	s1,8(sp)
    80003ae6:	6902                	ld	s2,0(sp)
    80003ae8:	6105                	addi	sp,sp,32
    80003aea:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aec:	44bc                	lw	a5,72(s1)
    80003aee:	dff1                	beqz	a5,80003aca <iput+0x26>
    80003af0:	05249783          	lh	a5,82(s1)
    80003af4:	fbf9                	bnez	a5,80003aca <iput+0x26>
    acquiresleep(&ip->lock);
    80003af6:	01048913          	addi	s2,s1,16
    80003afa:	854a                	mv	a0,s2
    80003afc:	00001097          	auipc	ra,0x1
    80003b00:	aa6080e7          	jalr	-1370(ra) # 800045a2 <acquiresleep>
    release(&icache.lock);
    80003b04:	00031517          	auipc	a0,0x31
    80003b08:	a0450513          	addi	a0,a0,-1532 # 80034508 <icache>
    80003b0c:	ffffd097          	auipc	ra,0xffffd
    80003b10:	160080e7          	jalr	352(ra) # 80000c6c <release>
    itrunc(ip);
    80003b14:	8526                	mv	a0,s1
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	ee2080e7          	jalr	-286(ra) # 800039f8 <itrunc>
    ip->type = 0;
    80003b1e:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003b22:	8526                	mv	a0,s1
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	cfc080e7          	jalr	-772(ra) # 80003820 <iupdate>
    ip->valid = 0;
    80003b2c:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003b30:	854a                	mv	a0,s2
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	ac6080e7          	jalr	-1338(ra) # 800045f8 <releasesleep>
    acquire(&icache.lock);
    80003b3a:	00031517          	auipc	a0,0x31
    80003b3e:	9ce50513          	addi	a0,a0,-1586 # 80034508 <icache>
    80003b42:	ffffd097          	auipc	ra,0xffffd
    80003b46:	05a080e7          	jalr	90(ra) # 80000b9c <acquire>
    80003b4a:	b741                	j	80003aca <iput+0x26>

0000000080003b4c <iunlockput>:
{
    80003b4c:	1101                	addi	sp,sp,-32
    80003b4e:	ec06                	sd	ra,24(sp)
    80003b50:	e822                	sd	s0,16(sp)
    80003b52:	e426                	sd	s1,8(sp)
    80003b54:	1000                	addi	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	e54080e7          	jalr	-428(ra) # 800039ac <iunlock>
  iput(ip);
    80003b60:	8526                	mv	a0,s1
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	f42080e7          	jalr	-190(ra) # 80003aa4 <iput>
}
    80003b6a:	60e2                	ld	ra,24(sp)
    80003b6c:	6442                	ld	s0,16(sp)
    80003b6e:	64a2                	ld	s1,8(sp)
    80003b70:	6105                	addi	sp,sp,32
    80003b72:	8082                	ret

0000000080003b74 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b74:	1141                	addi	sp,sp,-16
    80003b76:	e422                	sd	s0,8(sp)
    80003b78:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b7a:	411c                	lw	a5,0(a0)
    80003b7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b7e:	415c                	lw	a5,4(a0)
    80003b80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b82:	04c51783          	lh	a5,76(a0)
    80003b86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b8a:	05251783          	lh	a5,82(a0)
    80003b8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b92:	05456783          	lwu	a5,84(a0)
    80003b96:	e99c                	sd	a5,16(a1)
}
    80003b98:	6422                	ld	s0,8(sp)
    80003b9a:	0141                	addi	sp,sp,16
    80003b9c:	8082                	ret

0000000080003b9e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b9e:	497c                	lw	a5,84(a0)
    80003ba0:	0ed7e963          	bltu	a5,a3,80003c92 <readi+0xf4>
{
    80003ba4:	7159                	addi	sp,sp,-112
    80003ba6:	f486                	sd	ra,104(sp)
    80003ba8:	f0a2                	sd	s0,96(sp)
    80003baa:	eca6                	sd	s1,88(sp)
    80003bac:	e8ca                	sd	s2,80(sp)
    80003bae:	e4ce                	sd	s3,72(sp)
    80003bb0:	e0d2                	sd	s4,64(sp)
    80003bb2:	fc56                	sd	s5,56(sp)
    80003bb4:	f85a                	sd	s6,48(sp)
    80003bb6:	f45e                	sd	s7,40(sp)
    80003bb8:	f062                	sd	s8,32(sp)
    80003bba:	ec66                	sd	s9,24(sp)
    80003bbc:	e86a                	sd	s10,16(sp)
    80003bbe:	e46e                	sd	s11,8(sp)
    80003bc0:	1880                	addi	s0,sp,112
    80003bc2:	8baa                	mv	s7,a0
    80003bc4:	8c2e                	mv	s8,a1
    80003bc6:	8ab2                	mv	s5,a2
    80003bc8:	84b6                	mv	s1,a3
    80003bca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bcc:	9f35                	addw	a4,a4,a3
    return 0;
    80003bce:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bd0:	0ad76063          	bltu	a4,a3,80003c70 <readi+0xd2>
  if(off + n > ip->size)
    80003bd4:	00e7f463          	bgeu	a5,a4,80003bdc <readi+0x3e>
    n = ip->size - off;
    80003bd8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bdc:	0a0b0963          	beqz	s6,80003c8e <readi+0xf0>
    80003be0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003be6:	5cfd                	li	s9,-1
    80003be8:	a82d                	j	80003c22 <readi+0x84>
    80003bea:	020a1d93          	slli	s11,s4,0x20
    80003bee:	020ddd93          	srli	s11,s11,0x20
    80003bf2:	06090613          	addi	a2,s2,96
    80003bf6:	86ee                	mv	a3,s11
    80003bf8:	963a                	add	a2,a2,a4
    80003bfa:	85d6                	mv	a1,s5
    80003bfc:	8562                	mv	a0,s8
    80003bfe:	fffff097          	auipc	ra,0xfffff
    80003c02:	9be080e7          	jalr	-1602(ra) # 800025bc <either_copyout>
    80003c06:	05950d63          	beq	a0,s9,80003c60 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c0a:	854a                	mv	a0,s2
    80003c0c:	fffff097          	auipc	ra,0xfffff
    80003c10:	60c080e7          	jalr	1548(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c14:	013a09bb          	addw	s3,s4,s3
    80003c18:	009a04bb          	addw	s1,s4,s1
    80003c1c:	9aee                	add	s5,s5,s11
    80003c1e:	0569f763          	bgeu	s3,s6,80003c6c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c22:	000ba903          	lw	s2,0(s7)
    80003c26:	00a4d59b          	srliw	a1,s1,0xa
    80003c2a:	855e                	mv	a0,s7
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	8b0080e7          	jalr	-1872(ra) # 800034dc <bmap>
    80003c34:	0005059b          	sext.w	a1,a0
    80003c38:	854a                	mv	a0,s2
    80003c3a:	fffff097          	auipc	ra,0xfffff
    80003c3e:	4ae080e7          	jalr	1198(ra) # 800030e8 <bread>
    80003c42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c44:	3ff4f713          	andi	a4,s1,1023
    80003c48:	40ed07bb          	subw	a5,s10,a4
    80003c4c:	413b06bb          	subw	a3,s6,s3
    80003c50:	8a3e                	mv	s4,a5
    80003c52:	2781                	sext.w	a5,a5
    80003c54:	0006861b          	sext.w	a2,a3
    80003c58:	f8f679e3          	bgeu	a2,a5,80003bea <readi+0x4c>
    80003c5c:	8a36                	mv	s4,a3
    80003c5e:	b771                	j	80003bea <readi+0x4c>
      brelse(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	5b6080e7          	jalr	1462(ra) # 80003218 <brelse>
      tot = -1;
    80003c6a:	59fd                	li	s3,-1
  }
  return tot;
    80003c6c:	0009851b          	sext.w	a0,s3
}
    80003c70:	70a6                	ld	ra,104(sp)
    80003c72:	7406                	ld	s0,96(sp)
    80003c74:	64e6                	ld	s1,88(sp)
    80003c76:	6946                	ld	s2,80(sp)
    80003c78:	69a6                	ld	s3,72(sp)
    80003c7a:	6a06                	ld	s4,64(sp)
    80003c7c:	7ae2                	ld	s5,56(sp)
    80003c7e:	7b42                	ld	s6,48(sp)
    80003c80:	7ba2                	ld	s7,40(sp)
    80003c82:	7c02                	ld	s8,32(sp)
    80003c84:	6ce2                	ld	s9,24(sp)
    80003c86:	6d42                	ld	s10,16(sp)
    80003c88:	6da2                	ld	s11,8(sp)
    80003c8a:	6165                	addi	sp,sp,112
    80003c8c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c8e:	89da                	mv	s3,s6
    80003c90:	bff1                	j	80003c6c <readi+0xce>
    return 0;
    80003c92:	4501                	li	a0,0
}
    80003c94:	8082                	ret

0000000080003c96 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c96:	497c                	lw	a5,84(a0)
    80003c98:	10d7e863          	bltu	a5,a3,80003da8 <writei+0x112>
{
    80003c9c:	7159                	addi	sp,sp,-112
    80003c9e:	f486                	sd	ra,104(sp)
    80003ca0:	f0a2                	sd	s0,96(sp)
    80003ca2:	eca6                	sd	s1,88(sp)
    80003ca4:	e8ca                	sd	s2,80(sp)
    80003ca6:	e4ce                	sd	s3,72(sp)
    80003ca8:	e0d2                	sd	s4,64(sp)
    80003caa:	fc56                	sd	s5,56(sp)
    80003cac:	f85a                	sd	s6,48(sp)
    80003cae:	f45e                	sd	s7,40(sp)
    80003cb0:	f062                	sd	s8,32(sp)
    80003cb2:	ec66                	sd	s9,24(sp)
    80003cb4:	e86a                	sd	s10,16(sp)
    80003cb6:	e46e                	sd	s11,8(sp)
    80003cb8:	1880                	addi	s0,sp,112
    80003cba:	8b2a                	mv	s6,a0
    80003cbc:	8c2e                	mv	s8,a1
    80003cbe:	8ab2                	mv	s5,a2
    80003cc0:	8936                	mv	s2,a3
    80003cc2:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003cc4:	00e687bb          	addw	a5,a3,a4
    80003cc8:	0ed7e263          	bltu	a5,a3,80003dac <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ccc:	00043737          	lui	a4,0x43
    80003cd0:	0ef76063          	bltu	a4,a5,80003db0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd4:	0c0b8863          	beqz	s7,80003da4 <writei+0x10e>
    80003cd8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cda:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cde:	5cfd                	li	s9,-1
    80003ce0:	a091                	j	80003d24 <writei+0x8e>
    80003ce2:	02099d93          	slli	s11,s3,0x20
    80003ce6:	020ddd93          	srli	s11,s11,0x20
    80003cea:	06048513          	addi	a0,s1,96
    80003cee:	86ee                	mv	a3,s11
    80003cf0:	8656                	mv	a2,s5
    80003cf2:	85e2                	mv	a1,s8
    80003cf4:	953a                	add	a0,a0,a4
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	91c080e7          	jalr	-1764(ra) # 80002612 <either_copyin>
    80003cfe:	07950263          	beq	a0,s9,80003d62 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d02:	8526                	mv	a0,s1
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	77e080e7          	jalr	1918(ra) # 80004482 <log_write>
    brelse(bp);
    80003d0c:	8526                	mv	a0,s1
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	50a080e7          	jalr	1290(ra) # 80003218 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d16:	01498a3b          	addw	s4,s3,s4
    80003d1a:	0129893b          	addw	s2,s3,s2
    80003d1e:	9aee                	add	s5,s5,s11
    80003d20:	057a7663          	bgeu	s4,s7,80003d6c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d24:	000b2483          	lw	s1,0(s6)
    80003d28:	00a9559b          	srliw	a1,s2,0xa
    80003d2c:	855a                	mv	a0,s6
    80003d2e:	fffff097          	auipc	ra,0xfffff
    80003d32:	7ae080e7          	jalr	1966(ra) # 800034dc <bmap>
    80003d36:	0005059b          	sext.w	a1,a0
    80003d3a:	8526                	mv	a0,s1
    80003d3c:	fffff097          	auipc	ra,0xfffff
    80003d40:	3ac080e7          	jalr	940(ra) # 800030e8 <bread>
    80003d44:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d46:	3ff97713          	andi	a4,s2,1023
    80003d4a:	40ed07bb          	subw	a5,s10,a4
    80003d4e:	414b86bb          	subw	a3,s7,s4
    80003d52:	89be                	mv	s3,a5
    80003d54:	2781                	sext.w	a5,a5
    80003d56:	0006861b          	sext.w	a2,a3
    80003d5a:	f8f674e3          	bgeu	a2,a5,80003ce2 <writei+0x4c>
    80003d5e:	89b6                	mv	s3,a3
    80003d60:	b749                	j	80003ce2 <writei+0x4c>
      brelse(bp);
    80003d62:	8526                	mv	a0,s1
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	4b4080e7          	jalr	1204(ra) # 80003218 <brelse>
  }

  if(off > ip->size)
    80003d6c:	054b2783          	lw	a5,84(s6)
    80003d70:	0127f463          	bgeu	a5,s2,80003d78 <writei+0xe2>
    ip->size = off;
    80003d74:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d78:	855a                	mv	a0,s6
    80003d7a:	00000097          	auipc	ra,0x0
    80003d7e:	aa6080e7          	jalr	-1370(ra) # 80003820 <iupdate>

  return tot;
    80003d82:	000a051b          	sext.w	a0,s4
}
    80003d86:	70a6                	ld	ra,104(sp)
    80003d88:	7406                	ld	s0,96(sp)
    80003d8a:	64e6                	ld	s1,88(sp)
    80003d8c:	6946                	ld	s2,80(sp)
    80003d8e:	69a6                	ld	s3,72(sp)
    80003d90:	6a06                	ld	s4,64(sp)
    80003d92:	7ae2                	ld	s5,56(sp)
    80003d94:	7b42                	ld	s6,48(sp)
    80003d96:	7ba2                	ld	s7,40(sp)
    80003d98:	7c02                	ld	s8,32(sp)
    80003d9a:	6ce2                	ld	s9,24(sp)
    80003d9c:	6d42                	ld	s10,16(sp)
    80003d9e:	6da2                	ld	s11,8(sp)
    80003da0:	6165                	addi	sp,sp,112
    80003da2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da4:	8a5e                	mv	s4,s7
    80003da6:	bfc9                	j	80003d78 <writei+0xe2>
    return -1;
    80003da8:	557d                	li	a0,-1
}
    80003daa:	8082                	ret
    return -1;
    80003dac:	557d                	li	a0,-1
    80003dae:	bfe1                	j	80003d86 <writei+0xf0>
    return -1;
    80003db0:	557d                	li	a0,-1
    80003db2:	bfd1                	j	80003d86 <writei+0xf0>

0000000080003db4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003db4:	1141                	addi	sp,sp,-16
    80003db6:	e406                	sd	ra,8(sp)
    80003db8:	e022                	sd	s0,0(sp)
    80003dba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003dbc:	4639                	li	a2,14
    80003dbe:	ffffd097          	auipc	ra,0xffffd
    80003dc2:	1c6080e7          	jalr	454(ra) # 80000f84 <strncmp>
}
    80003dc6:	60a2                	ld	ra,8(sp)
    80003dc8:	6402                	ld	s0,0(sp)
    80003dca:	0141                	addi	sp,sp,16
    80003dcc:	8082                	ret

0000000080003dce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dce:	7139                	addi	sp,sp,-64
    80003dd0:	fc06                	sd	ra,56(sp)
    80003dd2:	f822                	sd	s0,48(sp)
    80003dd4:	f426                	sd	s1,40(sp)
    80003dd6:	f04a                	sd	s2,32(sp)
    80003dd8:	ec4e                	sd	s3,24(sp)
    80003dda:	e852                	sd	s4,16(sp)
    80003ddc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dde:	04c51703          	lh	a4,76(a0)
    80003de2:	4785                	li	a5,1
    80003de4:	00f71a63          	bne	a4,a5,80003df8 <dirlookup+0x2a>
    80003de8:	892a                	mv	s2,a0
    80003dea:	89ae                	mv	s3,a1
    80003dec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dee:	497c                	lw	a5,84(a0)
    80003df0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003df2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df4:	e79d                	bnez	a5,80003e22 <dirlookup+0x54>
    80003df6:	a8a5                	j	80003e6e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003df8:	00006517          	auipc	a0,0x6
    80003dfc:	d8850513          	addi	a0,a0,-632 # 80009b80 <syscalls+0x1b0>
    80003e00:	ffffc097          	auipc	ra,0xffffc
    80003e04:	76a080e7          	jalr	1898(ra) # 8000056a <panic>
      panic("dirlookup read");
    80003e08:	00006517          	auipc	a0,0x6
    80003e0c:	d9050513          	addi	a0,a0,-624 # 80009b98 <syscalls+0x1c8>
    80003e10:	ffffc097          	auipc	ra,0xffffc
    80003e14:	75a080e7          	jalr	1882(ra) # 8000056a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e18:	24c1                	addiw	s1,s1,16
    80003e1a:	05492783          	lw	a5,84(s2)
    80003e1e:	04f4f763          	bgeu	s1,a5,80003e6c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e22:	4741                	li	a4,16
    80003e24:	86a6                	mv	a3,s1
    80003e26:	fc040613          	addi	a2,s0,-64
    80003e2a:	4581                	li	a1,0
    80003e2c:	854a                	mv	a0,s2
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	d70080e7          	jalr	-656(ra) # 80003b9e <readi>
    80003e36:	47c1                	li	a5,16
    80003e38:	fcf518e3          	bne	a0,a5,80003e08 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e3c:	fc045783          	lhu	a5,-64(s0)
    80003e40:	dfe1                	beqz	a5,80003e18 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e42:	fc240593          	addi	a1,s0,-62
    80003e46:	854e                	mv	a0,s3
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	f6c080e7          	jalr	-148(ra) # 80003db4 <namecmp>
    80003e50:	f561                	bnez	a0,80003e18 <dirlookup+0x4a>
      if(poff)
    80003e52:	000a0463          	beqz	s4,80003e5a <dirlookup+0x8c>
        *poff = off;
    80003e56:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e5a:	fc045583          	lhu	a1,-64(s0)
    80003e5e:	00092503          	lw	a0,0(s2)
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	754080e7          	jalr	1876(ra) # 800035b6 <iget>
    80003e6a:	a011                	j	80003e6e <dirlookup+0xa0>
  return 0;
    80003e6c:	4501                	li	a0,0
}
    80003e6e:	70e2                	ld	ra,56(sp)
    80003e70:	7442                	ld	s0,48(sp)
    80003e72:	74a2                	ld	s1,40(sp)
    80003e74:	7902                	ld	s2,32(sp)
    80003e76:	69e2                	ld	s3,24(sp)
    80003e78:	6a42                	ld	s4,16(sp)
    80003e7a:	6121                	addi	sp,sp,64
    80003e7c:	8082                	ret

0000000080003e7e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e7e:	711d                	addi	sp,sp,-96
    80003e80:	ec86                	sd	ra,88(sp)
    80003e82:	e8a2                	sd	s0,80(sp)
    80003e84:	e4a6                	sd	s1,72(sp)
    80003e86:	e0ca                	sd	s2,64(sp)
    80003e88:	fc4e                	sd	s3,56(sp)
    80003e8a:	f852                	sd	s4,48(sp)
    80003e8c:	f456                	sd	s5,40(sp)
    80003e8e:	f05a                	sd	s6,32(sp)
    80003e90:	ec5e                	sd	s7,24(sp)
    80003e92:	e862                	sd	s8,16(sp)
    80003e94:	e466                	sd	s9,8(sp)
    80003e96:	1080                	addi	s0,sp,96
    80003e98:	84aa                	mv	s1,a0
    80003e9a:	8b2e                	mv	s6,a1
    80003e9c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e9e:	00054703          	lbu	a4,0(a0)
    80003ea2:	02f00793          	li	a5,47
    80003ea6:	02f70363          	beq	a4,a5,80003ecc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eaa:	ffffe097          	auipc	ra,0xffffe
    80003eae:	cec080e7          	jalr	-788(ra) # 80001b96 <myproc>
    80003eb2:	15853503          	ld	a0,344(a0)
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	9f6080e7          	jalr	-1546(ra) # 800038ac <idup>
    80003ebe:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ec0:	02f00913          	li	s2,47
  len = path - s;
    80003ec4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ec6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ec8:	4c05                	li	s8,1
    80003eca:	a865                	j	80003f82 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ecc:	4585                	li	a1,1
    80003ece:	4505                	li	a0,1
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	6e6080e7          	jalr	1766(ra) # 800035b6 <iget>
    80003ed8:	89aa                	mv	s3,a0
    80003eda:	b7dd                	j	80003ec0 <namex+0x42>
      iunlockput(ip);
    80003edc:	854e                	mv	a0,s3
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	c6e080e7          	jalr	-914(ra) # 80003b4c <iunlockput>
      return 0;
    80003ee6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ee8:	854e                	mv	a0,s3
    80003eea:	60e6                	ld	ra,88(sp)
    80003eec:	6446                	ld	s0,80(sp)
    80003eee:	64a6                	ld	s1,72(sp)
    80003ef0:	6906                	ld	s2,64(sp)
    80003ef2:	79e2                	ld	s3,56(sp)
    80003ef4:	7a42                	ld	s4,48(sp)
    80003ef6:	7aa2                	ld	s5,40(sp)
    80003ef8:	7b02                	ld	s6,32(sp)
    80003efa:	6be2                	ld	s7,24(sp)
    80003efc:	6c42                	ld	s8,16(sp)
    80003efe:	6ca2                	ld	s9,8(sp)
    80003f00:	6125                	addi	sp,sp,96
    80003f02:	8082                	ret
      iunlock(ip);
    80003f04:	854e                	mv	a0,s3
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	aa6080e7          	jalr	-1370(ra) # 800039ac <iunlock>
      return ip;
    80003f0e:	bfe9                	j	80003ee8 <namex+0x6a>
      iunlockput(ip);
    80003f10:	854e                	mv	a0,s3
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	c3a080e7          	jalr	-966(ra) # 80003b4c <iunlockput>
      return 0;
    80003f1a:	89d2                	mv	s3,s4
    80003f1c:	b7f1                	j	80003ee8 <namex+0x6a>
  len = path - s;
    80003f1e:	40b48633          	sub	a2,s1,a1
    80003f22:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f26:	094cd463          	bge	s9,s4,80003fae <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f2a:	4639                	li	a2,14
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	ffffd097          	auipc	ra,0xffffd
    80003f32:	fb2080e7          	jalr	-78(ra) # 80000ee0 <memmove>
  while(*path == '/')
    80003f36:	0004c783          	lbu	a5,0(s1)
    80003f3a:	01279763          	bne	a5,s2,80003f48 <namex+0xca>
    path++;
    80003f3e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f40:	0004c783          	lbu	a5,0(s1)
    80003f44:	ff278de3          	beq	a5,s2,80003f3e <namex+0xc0>
    ilock(ip);
    80003f48:	854e                	mv	a0,s3
    80003f4a:	00000097          	auipc	ra,0x0
    80003f4e:	9a0080e7          	jalr	-1632(ra) # 800038ea <ilock>
    if(ip->type != T_DIR){
    80003f52:	04c99783          	lh	a5,76(s3)
    80003f56:	f98793e3          	bne	a5,s8,80003edc <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f5a:	000b0563          	beqz	s6,80003f64 <namex+0xe6>
    80003f5e:	0004c783          	lbu	a5,0(s1)
    80003f62:	d3cd                	beqz	a5,80003f04 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f64:	865e                	mv	a2,s7
    80003f66:	85d6                	mv	a1,s5
    80003f68:	854e                	mv	a0,s3
    80003f6a:	00000097          	auipc	ra,0x0
    80003f6e:	e64080e7          	jalr	-412(ra) # 80003dce <dirlookup>
    80003f72:	8a2a                	mv	s4,a0
    80003f74:	dd51                	beqz	a0,80003f10 <namex+0x92>
    iunlockput(ip);
    80003f76:	854e                	mv	a0,s3
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	bd4080e7          	jalr	-1068(ra) # 80003b4c <iunlockput>
    ip = next;
    80003f80:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f82:	0004c783          	lbu	a5,0(s1)
    80003f86:	05279763          	bne	a5,s2,80003fd4 <namex+0x156>
    path++;
    80003f8a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f8c:	0004c783          	lbu	a5,0(s1)
    80003f90:	ff278de3          	beq	a5,s2,80003f8a <namex+0x10c>
  if(*path == 0)
    80003f94:	c79d                	beqz	a5,80003fc2 <namex+0x144>
    path++;
    80003f96:	85a6                	mv	a1,s1
  len = path - s;
    80003f98:	8a5e                	mv	s4,s7
    80003f9a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f9c:	01278963          	beq	a5,s2,80003fae <namex+0x130>
    80003fa0:	dfbd                	beqz	a5,80003f1e <namex+0xa0>
    path++;
    80003fa2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fa4:	0004c783          	lbu	a5,0(s1)
    80003fa8:	ff279ce3          	bne	a5,s2,80003fa0 <namex+0x122>
    80003fac:	bf8d                	j	80003f1e <namex+0xa0>
    memmove(name, s, len);
    80003fae:	2601                	sext.w	a2,a2
    80003fb0:	8556                	mv	a0,s5
    80003fb2:	ffffd097          	auipc	ra,0xffffd
    80003fb6:	f2e080e7          	jalr	-210(ra) # 80000ee0 <memmove>
    name[len] = 0;
    80003fba:	9a56                	add	s4,s4,s5
    80003fbc:	000a0023          	sb	zero,0(s4)
    80003fc0:	bf9d                	j	80003f36 <namex+0xb8>
  if(nameiparent){
    80003fc2:	f20b03e3          	beqz	s6,80003ee8 <namex+0x6a>
    iput(ip);
    80003fc6:	854e                	mv	a0,s3
    80003fc8:	00000097          	auipc	ra,0x0
    80003fcc:	adc080e7          	jalr	-1316(ra) # 80003aa4 <iput>
    return 0;
    80003fd0:	4981                	li	s3,0
    80003fd2:	bf19                	j	80003ee8 <namex+0x6a>
  if(*path == 0)
    80003fd4:	d7fd                	beqz	a5,80003fc2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003fd6:	0004c783          	lbu	a5,0(s1)
    80003fda:	85a6                	mv	a1,s1
    80003fdc:	b7d1                	j	80003fa0 <namex+0x122>

0000000080003fde <dirlink>:
{
    80003fde:	7139                	addi	sp,sp,-64
    80003fe0:	fc06                	sd	ra,56(sp)
    80003fe2:	f822                	sd	s0,48(sp)
    80003fe4:	f426                	sd	s1,40(sp)
    80003fe6:	f04a                	sd	s2,32(sp)
    80003fe8:	ec4e                	sd	s3,24(sp)
    80003fea:	e852                	sd	s4,16(sp)
    80003fec:	0080                	addi	s0,sp,64
    80003fee:	892a                	mv	s2,a0
    80003ff0:	8a2e                	mv	s4,a1
    80003ff2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ff4:	4601                	li	a2,0
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	dd8080e7          	jalr	-552(ra) # 80003dce <dirlookup>
    80003ffe:	e93d                	bnez	a0,80004074 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004000:	05492483          	lw	s1,84(s2)
    80004004:	c49d                	beqz	s1,80004032 <dirlink+0x54>
    80004006:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004008:	4741                	li	a4,16
    8000400a:	86a6                	mv	a3,s1
    8000400c:	fc040613          	addi	a2,s0,-64
    80004010:	4581                	li	a1,0
    80004012:	854a                	mv	a0,s2
    80004014:	00000097          	auipc	ra,0x0
    80004018:	b8a080e7          	jalr	-1142(ra) # 80003b9e <readi>
    8000401c:	47c1                	li	a5,16
    8000401e:	06f51163          	bne	a0,a5,80004080 <dirlink+0xa2>
    if(de.inum == 0)
    80004022:	fc045783          	lhu	a5,-64(s0)
    80004026:	c791                	beqz	a5,80004032 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004028:	24c1                	addiw	s1,s1,16
    8000402a:	05492783          	lw	a5,84(s2)
    8000402e:	fcf4ede3          	bltu	s1,a5,80004008 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004032:	4639                	li	a2,14
    80004034:	85d2                	mv	a1,s4
    80004036:	fc240513          	addi	a0,s0,-62
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	f86080e7          	jalr	-122(ra) # 80000fc0 <strncpy>
  de.inum = inum;
    80004042:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004046:	4741                	li	a4,16
    80004048:	86a6                	mv	a3,s1
    8000404a:	fc040613          	addi	a2,s0,-64
    8000404e:	4581                	li	a1,0
    80004050:	854a                	mv	a0,s2
    80004052:	00000097          	auipc	ra,0x0
    80004056:	c44080e7          	jalr	-956(ra) # 80003c96 <writei>
    8000405a:	872a                	mv	a4,a0
    8000405c:	47c1                	li	a5,16
  return 0;
    8000405e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004060:	02f71863          	bne	a4,a5,80004090 <dirlink+0xb2>
}
    80004064:	70e2                	ld	ra,56(sp)
    80004066:	7442                	ld	s0,48(sp)
    80004068:	74a2                	ld	s1,40(sp)
    8000406a:	7902                	ld	s2,32(sp)
    8000406c:	69e2                	ld	s3,24(sp)
    8000406e:	6a42                	ld	s4,16(sp)
    80004070:	6121                	addi	sp,sp,64
    80004072:	8082                	ret
    iput(ip);
    80004074:	00000097          	auipc	ra,0x0
    80004078:	a30080e7          	jalr	-1488(ra) # 80003aa4 <iput>
    return -1;
    8000407c:	557d                	li	a0,-1
    8000407e:	b7dd                	j	80004064 <dirlink+0x86>
      panic("dirlink read");
    80004080:	00006517          	auipc	a0,0x6
    80004084:	b2850513          	addi	a0,a0,-1240 # 80009ba8 <syscalls+0x1d8>
    80004088:	ffffc097          	auipc	ra,0xffffc
    8000408c:	4e2080e7          	jalr	1250(ra) # 8000056a <panic>
    panic("dirlink");
    80004090:	00006517          	auipc	a0,0x6
    80004094:	c2850513          	addi	a0,a0,-984 # 80009cb8 <syscalls+0x2e8>
    80004098:	ffffc097          	auipc	ra,0xffffc
    8000409c:	4d2080e7          	jalr	1234(ra) # 8000056a <panic>

00000000800040a0 <namei>:

struct inode*
namei(char *path)
{
    800040a0:	1101                	addi	sp,sp,-32
    800040a2:	ec06                	sd	ra,24(sp)
    800040a4:	e822                	sd	s0,16(sp)
    800040a6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040a8:	fe040613          	addi	a2,s0,-32
    800040ac:	4581                	li	a1,0
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	dd0080e7          	jalr	-560(ra) # 80003e7e <namex>
}
    800040b6:	60e2                	ld	ra,24(sp)
    800040b8:	6442                	ld	s0,16(sp)
    800040ba:	6105                	addi	sp,sp,32
    800040bc:	8082                	ret

00000000800040be <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040be:	1141                	addi	sp,sp,-16
    800040c0:	e406                	sd	ra,8(sp)
    800040c2:	e022                	sd	s0,0(sp)
    800040c4:	0800                	addi	s0,sp,16
    800040c6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040c8:	4585                	li	a1,1
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	db4080e7          	jalr	-588(ra) # 80003e7e <namex>
}
    800040d2:	60a2                	ld	ra,8(sp)
    800040d4:	6402                	ld	s0,0(sp)
    800040d6:	0141                	addi	sp,sp,16
    800040d8:	8082                	ret

00000000800040da <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    800040e4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040e6:	00032917          	auipc	s2,0x32
    800040ea:	06290913          	addi	s2,s2,98 # 80036148 <log>
    800040ee:	02092583          	lw	a1,32(s2)
    800040f2:	03092503          	lw	a0,48(s2)
    800040f6:	fffff097          	auipc	ra,0xfffff
    800040fa:	ff2080e7          	jalr	-14(ra) # 800030e8 <bread>
    800040fe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004100:	03492683          	lw	a3,52(s2)
    80004104:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004106:	02d05763          	blez	a3,80004134 <write_head+0x5a>
    8000410a:	00032797          	auipc	a5,0x32
    8000410e:	07678793          	addi	a5,a5,118 # 80036180 <log+0x38>
    80004112:	06450713          	addi	a4,a0,100
    80004116:	36fd                	addiw	a3,a3,-1
    80004118:	1682                	slli	a3,a3,0x20
    8000411a:	9281                	srli	a3,a3,0x20
    8000411c:	068a                	slli	a3,a3,0x2
    8000411e:	00032617          	auipc	a2,0x32
    80004122:	06660613          	addi	a2,a2,102 # 80036184 <log+0x3c>
    80004126:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004128:	4390                	lw	a2,0(a5)
    8000412a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000412c:	0791                	addi	a5,a5,4
    8000412e:	0711                	addi	a4,a4,4
    80004130:	fed79ce3          	bne	a5,a3,80004128 <write_head+0x4e>
  }
  bwrite(buf);
    80004134:	8526                	mv	a0,s1
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	0a4080e7          	jalr	164(ra) # 800031da <bwrite>
  brelse(buf);
    8000413e:	8526                	mv	a0,s1
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	0d8080e7          	jalr	216(ra) # 80003218 <brelse>
}
    80004148:	60e2                	ld	ra,24(sp)
    8000414a:	6442                	ld	s0,16(sp)
    8000414c:	64a2                	ld	s1,8(sp)
    8000414e:	6902                	ld	s2,0(sp)
    80004150:	6105                	addi	sp,sp,32
    80004152:	8082                	ret

0000000080004154 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004154:	00032797          	auipc	a5,0x32
    80004158:	0287a783          	lw	a5,40(a5) # 8003617c <log+0x34>
    8000415c:	0af05663          	blez	a5,80004208 <install_trans+0xb4>
{
    80004160:	7139                	addi	sp,sp,-64
    80004162:	fc06                	sd	ra,56(sp)
    80004164:	f822                	sd	s0,48(sp)
    80004166:	f426                	sd	s1,40(sp)
    80004168:	f04a                	sd	s2,32(sp)
    8000416a:	ec4e                	sd	s3,24(sp)
    8000416c:	e852                	sd	s4,16(sp)
    8000416e:	e456                	sd	s5,8(sp)
    80004170:	0080                	addi	s0,sp,64
    80004172:	00032a97          	auipc	s5,0x32
    80004176:	00ea8a93          	addi	s5,s5,14 # 80036180 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000417a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000417c:	00032997          	auipc	s3,0x32
    80004180:	fcc98993          	addi	s3,s3,-52 # 80036148 <log>
    80004184:	0209a583          	lw	a1,32(s3)
    80004188:	014585bb          	addw	a1,a1,s4
    8000418c:	2585                	addiw	a1,a1,1
    8000418e:	0309a503          	lw	a0,48(s3)
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	f56080e7          	jalr	-170(ra) # 800030e8 <bread>
    8000419a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000419c:	000aa583          	lw	a1,0(s5)
    800041a0:	0309a503          	lw	a0,48(s3)
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	f44080e7          	jalr	-188(ra) # 800030e8 <bread>
    800041ac:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041ae:	40000613          	li	a2,1024
    800041b2:	06090593          	addi	a1,s2,96
    800041b6:	06050513          	addi	a0,a0,96
    800041ba:	ffffd097          	auipc	ra,0xffffd
    800041be:	d26080e7          	jalr	-730(ra) # 80000ee0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041c2:	8526                	mv	a0,s1
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	016080e7          	jalr	22(ra) # 800031da <bwrite>
    bunpin(dbuf);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	124080e7          	jalr	292(ra) # 800032f2 <bunpin>
    brelse(lbuf);
    800041d6:	854a                	mv	a0,s2
    800041d8:	fffff097          	auipc	ra,0xfffff
    800041dc:	040080e7          	jalr	64(ra) # 80003218 <brelse>
    brelse(dbuf);
    800041e0:	8526                	mv	a0,s1
    800041e2:	fffff097          	auipc	ra,0xfffff
    800041e6:	036080e7          	jalr	54(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ea:	2a05                	addiw	s4,s4,1
    800041ec:	0a91                	addi	s5,s5,4
    800041ee:	0349a783          	lw	a5,52(s3)
    800041f2:	f8fa49e3          	blt	s4,a5,80004184 <install_trans+0x30>
}
    800041f6:	70e2                	ld	ra,56(sp)
    800041f8:	7442                	ld	s0,48(sp)
    800041fa:	74a2                	ld	s1,40(sp)
    800041fc:	7902                	ld	s2,32(sp)
    800041fe:	69e2                	ld	s3,24(sp)
    80004200:	6a42                	ld	s4,16(sp)
    80004202:	6aa2                	ld	s5,8(sp)
    80004204:	6121                	addi	sp,sp,64
    80004206:	8082                	ret
    80004208:	8082                	ret

000000008000420a <initlog>:
{
    8000420a:	7179                	addi	sp,sp,-48
    8000420c:	f406                	sd	ra,40(sp)
    8000420e:	f022                	sd	s0,32(sp)
    80004210:	ec26                	sd	s1,24(sp)
    80004212:	e84a                	sd	s2,16(sp)
    80004214:	e44e                	sd	s3,8(sp)
    80004216:	1800                	addi	s0,sp,48
    80004218:	892a                	mv	s2,a0
    8000421a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000421c:	00032497          	auipc	s1,0x32
    80004220:	f2c48493          	addi	s1,s1,-212 # 80036148 <log>
    80004224:	00006597          	auipc	a1,0x6
    80004228:	99458593          	addi	a1,a1,-1644 # 80009bb8 <syscalls+0x1e8>
    8000422c:	8526                	mv	a0,s1
    8000422e:	ffffd097          	auipc	ra,0xffffd
    80004232:	898080e7          	jalr	-1896(ra) # 80000ac6 <initlock>
  log.start = sb->logstart;
    80004236:	0149a583          	lw	a1,20(s3)
    8000423a:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    8000423c:	0109a783          	lw	a5,16(s3)
    80004240:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80004242:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004246:	854a                	mv	a0,s2
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	ea0080e7          	jalr	-352(ra) # 800030e8 <bread>
  log.lh.n = lh->n;
    80004250:	513c                	lw	a5,96(a0)
    80004252:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004254:	02f05563          	blez	a5,8000427e <initlog+0x74>
    80004258:	06450713          	addi	a4,a0,100
    8000425c:	00032697          	auipc	a3,0x32
    80004260:	f2468693          	addi	a3,a3,-220 # 80036180 <log+0x38>
    80004264:	37fd                	addiw	a5,a5,-1
    80004266:	1782                	slli	a5,a5,0x20
    80004268:	9381                	srli	a5,a5,0x20
    8000426a:	078a                	slli	a5,a5,0x2
    8000426c:	06850613          	addi	a2,a0,104
    80004270:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004272:	4310                	lw	a2,0(a4)
    80004274:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004276:	0711                	addi	a4,a4,4
    80004278:	0691                	addi	a3,a3,4
    8000427a:	fef71ce3          	bne	a4,a5,80004272 <initlog+0x68>
  brelse(buf);
    8000427e:	fffff097          	auipc	ra,0xfffff
    80004282:	f9a080e7          	jalr	-102(ra) # 80003218 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004286:	00000097          	auipc	ra,0x0
    8000428a:	ece080e7          	jalr	-306(ra) # 80004154 <install_trans>
  log.lh.n = 0;
    8000428e:	00032797          	auipc	a5,0x32
    80004292:	ee07a723          	sw	zero,-274(a5) # 8003617c <log+0x34>
  write_head(); // clear the log
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	e44080e7          	jalr	-444(ra) # 800040da <write_head>
}
    8000429e:	70a2                	ld	ra,40(sp)
    800042a0:	7402                	ld	s0,32(sp)
    800042a2:	64e2                	ld	s1,24(sp)
    800042a4:	6942                	ld	s2,16(sp)
    800042a6:	69a2                	ld	s3,8(sp)
    800042a8:	6145                	addi	sp,sp,48
    800042aa:	8082                	ret

00000000800042ac <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042ac:	1101                	addi	sp,sp,-32
    800042ae:	ec06                	sd	ra,24(sp)
    800042b0:	e822                	sd	s0,16(sp)
    800042b2:	e426                	sd	s1,8(sp)
    800042b4:	e04a                	sd	s2,0(sp)
    800042b6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042b8:	00032517          	auipc	a0,0x32
    800042bc:	e9050513          	addi	a0,a0,-368 # 80036148 <log>
    800042c0:	ffffd097          	auipc	ra,0xffffd
    800042c4:	8dc080e7          	jalr	-1828(ra) # 80000b9c <acquire>
  while(1){
    if(log.committing){
    800042c8:	00032497          	auipc	s1,0x32
    800042cc:	e8048493          	addi	s1,s1,-384 # 80036148 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042d0:	4979                	li	s2,30
    800042d2:	a039                	j	800042e0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042d4:	85a6                	mv	a1,s1
    800042d6:	8526                	mv	a0,s1
    800042d8:	ffffe097          	auipc	ra,0xffffe
    800042dc:	082080e7          	jalr	130(ra) # 8000235a <sleep>
    if(log.committing){
    800042e0:	54dc                	lw	a5,44(s1)
    800042e2:	fbed                	bnez	a5,800042d4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042e4:	549c                	lw	a5,40(s1)
    800042e6:	0017871b          	addiw	a4,a5,1
    800042ea:	0007069b          	sext.w	a3,a4
    800042ee:	0027179b          	slliw	a5,a4,0x2
    800042f2:	9fb9                	addw	a5,a5,a4
    800042f4:	0017979b          	slliw	a5,a5,0x1
    800042f8:	58d8                	lw	a4,52(s1)
    800042fa:	9fb9                	addw	a5,a5,a4
    800042fc:	00f95963          	bge	s2,a5,8000430e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004300:	85a6                	mv	a1,s1
    80004302:	8526                	mv	a0,s1
    80004304:	ffffe097          	auipc	ra,0xffffe
    80004308:	056080e7          	jalr	86(ra) # 8000235a <sleep>
    8000430c:	bfd1                	j	800042e0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000430e:	00032517          	auipc	a0,0x32
    80004312:	e3a50513          	addi	a0,a0,-454 # 80036148 <log>
    80004316:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	954080e7          	jalr	-1708(ra) # 80000c6c <release>
      break;
    }
  }
}
    80004320:	60e2                	ld	ra,24(sp)
    80004322:	6442                	ld	s0,16(sp)
    80004324:	64a2                	ld	s1,8(sp)
    80004326:	6902                	ld	s2,0(sp)
    80004328:	6105                	addi	sp,sp,32
    8000432a:	8082                	ret

000000008000432c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000432c:	7139                	addi	sp,sp,-64
    8000432e:	fc06                	sd	ra,56(sp)
    80004330:	f822                	sd	s0,48(sp)
    80004332:	f426                	sd	s1,40(sp)
    80004334:	f04a                	sd	s2,32(sp)
    80004336:	ec4e                	sd	s3,24(sp)
    80004338:	e852                	sd	s4,16(sp)
    8000433a:	e456                	sd	s5,8(sp)
    8000433c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000433e:	00032497          	auipc	s1,0x32
    80004342:	e0a48493          	addi	s1,s1,-502 # 80036148 <log>
    80004346:	8526                	mv	a0,s1
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	854080e7          	jalr	-1964(ra) # 80000b9c <acquire>
  log.outstanding -= 1;
    80004350:	549c                	lw	a5,40(s1)
    80004352:	37fd                	addiw	a5,a5,-1
    80004354:	0007891b          	sext.w	s2,a5
    80004358:	d49c                	sw	a5,40(s1)
  if(log.committing)
    8000435a:	54dc                	lw	a5,44(s1)
    8000435c:	efb9                	bnez	a5,800043ba <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000435e:	06091663          	bnez	s2,800043ca <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004362:	00032497          	auipc	s1,0x32
    80004366:	de648493          	addi	s1,s1,-538 # 80036148 <log>
    8000436a:	4785                	li	a5,1
    8000436c:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000436e:	8526                	mv	a0,s1
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	8fc080e7          	jalr	-1796(ra) # 80000c6c <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    80004378:	58dc                	lw	a5,52(s1)
    8000437a:	06f04763          	bgtz	a5,800043e8 <end_op+0xbc>
    acquire(&log.lock);
    8000437e:	00032497          	auipc	s1,0x32
    80004382:	dca48493          	addi	s1,s1,-566 # 80036148 <log>
    80004386:	8526                	mv	a0,s1
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	814080e7          	jalr	-2028(ra) # 80000b9c <acquire>
    log.committing = 0;
    80004390:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80004394:	8526                	mv	a0,s1
    80004396:	ffffe097          	auipc	ra,0xffffe
    8000439a:	14a080e7          	jalr	330(ra) # 800024e0 <wakeup>
    release(&log.lock);
    8000439e:	8526                	mv	a0,s1
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	8cc080e7          	jalr	-1844(ra) # 80000c6c <release>
}
    800043a8:	70e2                	ld	ra,56(sp)
    800043aa:	7442                	ld	s0,48(sp)
    800043ac:	74a2                	ld	s1,40(sp)
    800043ae:	7902                	ld	s2,32(sp)
    800043b0:	69e2                	ld	s3,24(sp)
    800043b2:	6a42                	ld	s4,16(sp)
    800043b4:	6aa2                	ld	s5,8(sp)
    800043b6:	6121                	addi	sp,sp,64
    800043b8:	8082                	ret
    panic("log.committing");
    800043ba:	00006517          	auipc	a0,0x6
    800043be:	80650513          	addi	a0,a0,-2042 # 80009bc0 <syscalls+0x1f0>
    800043c2:	ffffc097          	auipc	ra,0xffffc
    800043c6:	1a8080e7          	jalr	424(ra) # 8000056a <panic>
    wakeup(&log);
    800043ca:	00032497          	auipc	s1,0x32
    800043ce:	d7e48493          	addi	s1,s1,-642 # 80036148 <log>
    800043d2:	8526                	mv	a0,s1
    800043d4:	ffffe097          	auipc	ra,0xffffe
    800043d8:	10c080e7          	jalr	268(ra) # 800024e0 <wakeup>
  release(&log.lock);
    800043dc:	8526                	mv	a0,s1
    800043de:	ffffd097          	auipc	ra,0xffffd
    800043e2:	88e080e7          	jalr	-1906(ra) # 80000c6c <release>
  if(do_commit){
    800043e6:	b7c9                	j	800043a8 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e8:	00032a97          	auipc	s5,0x32
    800043ec:	d98a8a93          	addi	s5,s5,-616 # 80036180 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043f0:	00032a17          	auipc	s4,0x32
    800043f4:	d58a0a13          	addi	s4,s4,-680 # 80036148 <log>
    800043f8:	020a2583          	lw	a1,32(s4)
    800043fc:	012585bb          	addw	a1,a1,s2
    80004400:	2585                	addiw	a1,a1,1
    80004402:	030a2503          	lw	a0,48(s4)
    80004406:	fffff097          	auipc	ra,0xfffff
    8000440a:	ce2080e7          	jalr	-798(ra) # 800030e8 <bread>
    8000440e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004410:	000aa583          	lw	a1,0(s5)
    80004414:	030a2503          	lw	a0,48(s4)
    80004418:	fffff097          	auipc	ra,0xfffff
    8000441c:	cd0080e7          	jalr	-816(ra) # 800030e8 <bread>
    80004420:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004422:	40000613          	li	a2,1024
    80004426:	06050593          	addi	a1,a0,96
    8000442a:	06048513          	addi	a0,s1,96
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	ab2080e7          	jalr	-1358(ra) # 80000ee0 <memmove>
    bwrite(to);  // write the log
    80004436:	8526                	mv	a0,s1
    80004438:	fffff097          	auipc	ra,0xfffff
    8000443c:	da2080e7          	jalr	-606(ra) # 800031da <bwrite>
    brelse(from);
    80004440:	854e                	mv	a0,s3
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	dd6080e7          	jalr	-554(ra) # 80003218 <brelse>
    brelse(to);
    8000444a:	8526                	mv	a0,s1
    8000444c:	fffff097          	auipc	ra,0xfffff
    80004450:	dcc080e7          	jalr	-564(ra) # 80003218 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004454:	2905                	addiw	s2,s2,1
    80004456:	0a91                	addi	s5,s5,4
    80004458:	034a2783          	lw	a5,52(s4)
    8000445c:	f8f94ee3          	blt	s2,a5,800043f8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004460:	00000097          	auipc	ra,0x0
    80004464:	c7a080e7          	jalr	-902(ra) # 800040da <write_head>
    install_trans(); // Now install writes to home locations
    80004468:	00000097          	auipc	ra,0x0
    8000446c:	cec080e7          	jalr	-788(ra) # 80004154 <install_trans>
    log.lh.n = 0;
    80004470:	00032797          	auipc	a5,0x32
    80004474:	d007a623          	sw	zero,-756(a5) # 8003617c <log+0x34>
    write_head();    // Erase the transaction from the log
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	c62080e7          	jalr	-926(ra) # 800040da <write_head>
    80004480:	bdfd                	j	8000437e <end_op+0x52>

0000000080004482 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004482:	1101                	addi	sp,sp,-32
    80004484:	ec06                	sd	ra,24(sp)
    80004486:	e822                	sd	s0,16(sp)
    80004488:	e426                	sd	s1,8(sp)
    8000448a:	e04a                	sd	s2,0(sp)
    8000448c:	1000                	addi	s0,sp,32
    8000448e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004490:	00032917          	auipc	s2,0x32
    80004494:	cb890913          	addi	s2,s2,-840 # 80036148 <log>
    80004498:	854a                	mv	a0,s2
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	702080e7          	jalr	1794(ra) # 80000b9c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044a2:	03492603          	lw	a2,52(s2)
    800044a6:	47f5                	li	a5,29
    800044a8:	06c7c563          	blt	a5,a2,80004512 <log_write+0x90>
    800044ac:	00032797          	auipc	a5,0x32
    800044b0:	cc07a783          	lw	a5,-832(a5) # 8003616c <log+0x24>
    800044b4:	37fd                	addiw	a5,a5,-1
    800044b6:	04f65e63          	bge	a2,a5,80004512 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ba:	00032797          	auipc	a5,0x32
    800044be:	cb67a783          	lw	a5,-842(a5) # 80036170 <log+0x28>
    800044c2:	06f05063          	blez	a5,80004522 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044c6:	4781                	li	a5,0
    800044c8:	06c05563          	blez	a2,80004532 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044cc:	44cc                	lw	a1,12(s1)
    800044ce:	00032717          	auipc	a4,0x32
    800044d2:	cb270713          	addi	a4,a4,-846 # 80036180 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    800044d6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044d8:	4314                	lw	a3,0(a4)
    800044da:	04b68c63          	beq	a3,a1,80004532 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044de:	2785                	addiw	a5,a5,1
    800044e0:	0711                	addi	a4,a4,4
    800044e2:	fef61be3          	bne	a2,a5,800044d8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044e6:	0631                	addi	a2,a2,12
    800044e8:	060a                	slli	a2,a2,0x2
    800044ea:	00032797          	auipc	a5,0x32
    800044ee:	c5e78793          	addi	a5,a5,-930 # 80036148 <log>
    800044f2:	963e                	add	a2,a2,a5
    800044f4:	44dc                	lw	a5,12(s1)
    800044f6:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044f8:	8526                	mv	a0,s1
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	dbc080e7          	jalr	-580(ra) # 800032b6 <bpin>
    log.lh.n++;
    80004502:	00032717          	auipc	a4,0x32
    80004506:	c4670713          	addi	a4,a4,-954 # 80036148 <log>
    8000450a:	5b5c                	lw	a5,52(a4)
    8000450c:	2785                	addiw	a5,a5,1
    8000450e:	db5c                	sw	a5,52(a4)
    80004510:	a835                	j	8000454c <log_write+0xca>
    panic("too big a transaction");
    80004512:	00005517          	auipc	a0,0x5
    80004516:	6be50513          	addi	a0,a0,1726 # 80009bd0 <syscalls+0x200>
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	050080e7          	jalr	80(ra) # 8000056a <panic>
    panic("log_write outside of trans");
    80004522:	00005517          	auipc	a0,0x5
    80004526:	6c650513          	addi	a0,a0,1734 # 80009be8 <syscalls+0x218>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	040080e7          	jalr	64(ra) # 8000056a <panic>
  log.lh.block[i] = b->blockno;
    80004532:	00c78713          	addi	a4,a5,12
    80004536:	00271693          	slli	a3,a4,0x2
    8000453a:	00032717          	auipc	a4,0x32
    8000453e:	c0e70713          	addi	a4,a4,-1010 # 80036148 <log>
    80004542:	9736                	add	a4,a4,a3
    80004544:	44d4                	lw	a3,12(s1)
    80004546:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004548:	faf608e3          	beq	a2,a5,800044f8 <log_write+0x76>
  }
  release(&log.lock);
    8000454c:	00032517          	auipc	a0,0x32
    80004550:	bfc50513          	addi	a0,a0,-1028 # 80036148 <log>
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	718080e7          	jalr	1816(ra) # 80000c6c <release>
}
    8000455c:	60e2                	ld	ra,24(sp)
    8000455e:	6442                	ld	s0,16(sp)
    80004560:	64a2                	ld	s1,8(sp)
    80004562:	6902                	ld	s2,0(sp)
    80004564:	6105                	addi	sp,sp,32
    80004566:	8082                	ret

0000000080004568 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004568:	1101                	addi	sp,sp,-32
    8000456a:	ec06                	sd	ra,24(sp)
    8000456c:	e822                	sd	s0,16(sp)
    8000456e:	e426                	sd	s1,8(sp)
    80004570:	e04a                	sd	s2,0(sp)
    80004572:	1000                	addi	s0,sp,32
    80004574:	84aa                	mv	s1,a0
    80004576:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004578:	00005597          	auipc	a1,0x5
    8000457c:	69058593          	addi	a1,a1,1680 # 80009c08 <syscalls+0x238>
    80004580:	0521                	addi	a0,a0,8
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	544080e7          	jalr	1348(ra) # 80000ac6 <initlock>
  lk->name = name;
    8000458a:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    8000458e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004592:	0204a823          	sw	zero,48(s1)
}
    80004596:	60e2                	ld	ra,24(sp)
    80004598:	6442                	ld	s0,16(sp)
    8000459a:	64a2                	ld	s1,8(sp)
    8000459c:	6902                	ld	s2,0(sp)
    8000459e:	6105                	addi	sp,sp,32
    800045a0:	8082                	ret

00000000800045a2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045a2:	1101                	addi	sp,sp,-32
    800045a4:	ec06                	sd	ra,24(sp)
    800045a6:	e822                	sd	s0,16(sp)
    800045a8:	e426                	sd	s1,8(sp)
    800045aa:	e04a                	sd	s2,0(sp)
    800045ac:	1000                	addi	s0,sp,32
    800045ae:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045b0:	00850913          	addi	s2,a0,8
    800045b4:	854a                	mv	a0,s2
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	5e6080e7          	jalr	1510(ra) # 80000b9c <acquire>
  while (lk->locked) {
    800045be:	409c                	lw	a5,0(s1)
    800045c0:	cb89                	beqz	a5,800045d2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045c2:	85ca                	mv	a1,s2
    800045c4:	8526                	mv	a0,s1
    800045c6:	ffffe097          	auipc	ra,0xffffe
    800045ca:	d94080e7          	jalr	-620(ra) # 8000235a <sleep>
  while (lk->locked) {
    800045ce:	409c                	lw	a5,0(s1)
    800045d0:	fbed                	bnez	a5,800045c2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045d2:	4785                	li	a5,1
    800045d4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045d6:	ffffd097          	auipc	ra,0xffffd
    800045da:	5c0080e7          	jalr	1472(ra) # 80001b96 <myproc>
    800045de:	413c                	lw	a5,64(a0)
    800045e0:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800045e2:	854a                	mv	a0,s2
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	688080e7          	jalr	1672(ra) # 80000c6c <release>
}
    800045ec:	60e2                	ld	ra,24(sp)
    800045ee:	6442                	ld	s0,16(sp)
    800045f0:	64a2                	ld	s1,8(sp)
    800045f2:	6902                	ld	s2,0(sp)
    800045f4:	6105                	addi	sp,sp,32
    800045f6:	8082                	ret

00000000800045f8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045f8:	1101                	addi	sp,sp,-32
    800045fa:	ec06                	sd	ra,24(sp)
    800045fc:	e822                	sd	s0,16(sp)
    800045fe:	e426                	sd	s1,8(sp)
    80004600:	e04a                	sd	s2,0(sp)
    80004602:	1000                	addi	s0,sp,32
    80004604:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004606:	00850913          	addi	s2,a0,8
    8000460a:	854a                	mv	a0,s2
    8000460c:	ffffc097          	auipc	ra,0xffffc
    80004610:	590080e7          	jalr	1424(ra) # 80000b9c <acquire>
  lk->locked = 0;
    80004614:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004618:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    8000461c:	8526                	mv	a0,s1
    8000461e:	ffffe097          	auipc	ra,0xffffe
    80004622:	ec2080e7          	jalr	-318(ra) # 800024e0 <wakeup>
  release(&lk->lk);
    80004626:	854a                	mv	a0,s2
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	644080e7          	jalr	1604(ra) # 80000c6c <release>
}
    80004630:	60e2                	ld	ra,24(sp)
    80004632:	6442                	ld	s0,16(sp)
    80004634:	64a2                	ld	s1,8(sp)
    80004636:	6902                	ld	s2,0(sp)
    80004638:	6105                	addi	sp,sp,32
    8000463a:	8082                	ret

000000008000463c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000463c:	7179                	addi	sp,sp,-48
    8000463e:	f406                	sd	ra,40(sp)
    80004640:	f022                	sd	s0,32(sp)
    80004642:	ec26                	sd	s1,24(sp)
    80004644:	e84a                	sd	s2,16(sp)
    80004646:	e44e                	sd	s3,8(sp)
    80004648:	1800                	addi	s0,sp,48
    8000464a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000464c:	00850913          	addi	s2,a0,8
    80004650:	854a                	mv	a0,s2
    80004652:	ffffc097          	auipc	ra,0xffffc
    80004656:	54a080e7          	jalr	1354(ra) # 80000b9c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000465a:	409c                	lw	a5,0(s1)
    8000465c:	ef99                	bnez	a5,8000467a <holdingsleep+0x3e>
    8000465e:	4481                	li	s1,0
  release(&lk->lk);
    80004660:	854a                	mv	a0,s2
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	60a080e7          	jalr	1546(ra) # 80000c6c <release>
  return r;
}
    8000466a:	8526                	mv	a0,s1
    8000466c:	70a2                	ld	ra,40(sp)
    8000466e:	7402                	ld	s0,32(sp)
    80004670:	64e2                	ld	s1,24(sp)
    80004672:	6942                	ld	s2,16(sp)
    80004674:	69a2                	ld	s3,8(sp)
    80004676:	6145                	addi	sp,sp,48
    80004678:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000467a:	0304a983          	lw	s3,48(s1)
    8000467e:	ffffd097          	auipc	ra,0xffffd
    80004682:	518080e7          	jalr	1304(ra) # 80001b96 <myproc>
    80004686:	4124                	lw	s1,64(a0)
    80004688:	413484b3          	sub	s1,s1,s3
    8000468c:	0014b493          	seqz	s1,s1
    80004690:	bfc1                	j	80004660 <holdingsleep+0x24>

0000000080004692 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004692:	1141                	addi	sp,sp,-16
    80004694:	e406                	sd	ra,8(sp)
    80004696:	e022                	sd	s0,0(sp)
    80004698:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000469a:	00005597          	auipc	a1,0x5
    8000469e:	57e58593          	addi	a1,a1,1406 # 80009c18 <syscalls+0x248>
    800046a2:	00032517          	auipc	a0,0x32
    800046a6:	bf650513          	addi	a0,a0,-1034 # 80036298 <ftable>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	41c080e7          	jalr	1052(ra) # 80000ac6 <initlock>
}
    800046b2:	60a2                	ld	ra,8(sp)
    800046b4:	6402                	ld	s0,0(sp)
    800046b6:	0141                	addi	sp,sp,16
    800046b8:	8082                	ret

00000000800046ba <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046ba:	1101                	addi	sp,sp,-32
    800046bc:	ec06                	sd	ra,24(sp)
    800046be:	e822                	sd	s0,16(sp)
    800046c0:	e426                	sd	s1,8(sp)
    800046c2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046c4:	00032517          	auipc	a0,0x32
    800046c8:	bd450513          	addi	a0,a0,-1068 # 80036298 <ftable>
    800046cc:	ffffc097          	auipc	ra,0xffffc
    800046d0:	4d0080e7          	jalr	1232(ra) # 80000b9c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d4:	00032497          	auipc	s1,0x32
    800046d8:	be448493          	addi	s1,s1,-1052 # 800362b8 <ftable+0x20>
    800046dc:	00033717          	auipc	a4,0x33
    800046e0:	b7c70713          	addi	a4,a4,-1156 # 80037258 <disk>
    if(f->ref == 0){
    800046e4:	40dc                	lw	a5,4(s1)
    800046e6:	cf99                	beqz	a5,80004704 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046e8:	02848493          	addi	s1,s1,40
    800046ec:	fee49ce3          	bne	s1,a4,800046e4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046f0:	00032517          	auipc	a0,0x32
    800046f4:	ba850513          	addi	a0,a0,-1112 # 80036298 <ftable>
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	574080e7          	jalr	1396(ra) # 80000c6c <release>
  return 0;
    80004700:	4481                	li	s1,0
    80004702:	a819                	j	80004718 <filealloc+0x5e>
      f->ref = 1;
    80004704:	4785                	li	a5,1
    80004706:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004708:	00032517          	auipc	a0,0x32
    8000470c:	b9050513          	addi	a0,a0,-1136 # 80036298 <ftable>
    80004710:	ffffc097          	auipc	ra,0xffffc
    80004714:	55c080e7          	jalr	1372(ra) # 80000c6c <release>
}
    80004718:	8526                	mv	a0,s1
    8000471a:	60e2                	ld	ra,24(sp)
    8000471c:	6442                	ld	s0,16(sp)
    8000471e:	64a2                	ld	s1,8(sp)
    80004720:	6105                	addi	sp,sp,32
    80004722:	8082                	ret

0000000080004724 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004724:	1101                	addi	sp,sp,-32
    80004726:	ec06                	sd	ra,24(sp)
    80004728:	e822                	sd	s0,16(sp)
    8000472a:	e426                	sd	s1,8(sp)
    8000472c:	1000                	addi	s0,sp,32
    8000472e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004730:	00032517          	auipc	a0,0x32
    80004734:	b6850513          	addi	a0,a0,-1176 # 80036298 <ftable>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	464080e7          	jalr	1124(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    80004740:	40dc                	lw	a5,4(s1)
    80004742:	02f05263          	blez	a5,80004766 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004746:	2785                	addiw	a5,a5,1
    80004748:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000474a:	00032517          	auipc	a0,0x32
    8000474e:	b4e50513          	addi	a0,a0,-1202 # 80036298 <ftable>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	51a080e7          	jalr	1306(ra) # 80000c6c <release>
  return f;
}
    8000475a:	8526                	mv	a0,s1
    8000475c:	60e2                	ld	ra,24(sp)
    8000475e:	6442                	ld	s0,16(sp)
    80004760:	64a2                	ld	s1,8(sp)
    80004762:	6105                	addi	sp,sp,32
    80004764:	8082                	ret
    panic("filedup");
    80004766:	00005517          	auipc	a0,0x5
    8000476a:	4ba50513          	addi	a0,a0,1210 # 80009c20 <syscalls+0x250>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	dfc080e7          	jalr	-516(ra) # 8000056a <panic>

0000000080004776 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004776:	7139                	addi	sp,sp,-64
    80004778:	fc06                	sd	ra,56(sp)
    8000477a:	f822                	sd	s0,48(sp)
    8000477c:	f426                	sd	s1,40(sp)
    8000477e:	f04a                	sd	s2,32(sp)
    80004780:	ec4e                	sd	s3,24(sp)
    80004782:	e852                	sd	s4,16(sp)
    80004784:	e456                	sd	s5,8(sp)
    80004786:	0080                	addi	s0,sp,64
    80004788:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000478a:	00032517          	auipc	a0,0x32
    8000478e:	b0e50513          	addi	a0,a0,-1266 # 80036298 <ftable>
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	40a080e7          	jalr	1034(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    8000479a:	40dc                	lw	a5,4(s1)
    8000479c:	06f05163          	blez	a5,800047fe <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047a0:	37fd                	addiw	a5,a5,-1
    800047a2:	0007871b          	sext.w	a4,a5
    800047a6:	c0dc                	sw	a5,4(s1)
    800047a8:	06e04363          	bgtz	a4,8000480e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047ac:	0004a903          	lw	s2,0(s1)
    800047b0:	0094ca83          	lbu	s5,9(s1)
    800047b4:	0104ba03          	ld	s4,16(s1)
    800047b8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047bc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047c0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047c4:	00032517          	auipc	a0,0x32
    800047c8:	ad450513          	addi	a0,a0,-1324 # 80036298 <ftable>
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	4a0080e7          	jalr	1184(ra) # 80000c6c <release>

  if(ff.type == FD_PIPE){
    800047d4:	4785                	li	a5,1
    800047d6:	04f90d63          	beq	s2,a5,80004830 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047da:	3979                	addiw	s2,s2,-2
    800047dc:	4785                	li	a5,1
    800047de:	0527e063          	bltu	a5,s2,8000481e <fileclose+0xa8>
    begin_op();
    800047e2:	00000097          	auipc	ra,0x0
    800047e6:	aca080e7          	jalr	-1334(ra) # 800042ac <begin_op>
    iput(ff.ip);
    800047ea:	854e                	mv	a0,s3
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	2b8080e7          	jalr	696(ra) # 80003aa4 <iput>
    end_op();
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	b38080e7          	jalr	-1224(ra) # 8000432c <end_op>
    800047fc:	a00d                	j	8000481e <fileclose+0xa8>
    panic("fileclose");
    800047fe:	00005517          	auipc	a0,0x5
    80004802:	42a50513          	addi	a0,a0,1066 # 80009c28 <syscalls+0x258>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	d64080e7          	jalr	-668(ra) # 8000056a <panic>
    release(&ftable.lock);
    8000480e:	00032517          	auipc	a0,0x32
    80004812:	a8a50513          	addi	a0,a0,-1398 # 80036298 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	456080e7          	jalr	1110(ra) # 80000c6c <release>
  }
}
    8000481e:	70e2                	ld	ra,56(sp)
    80004820:	7442                	ld	s0,48(sp)
    80004822:	74a2                	ld	s1,40(sp)
    80004824:	7902                	ld	s2,32(sp)
    80004826:	69e2                	ld	s3,24(sp)
    80004828:	6a42                	ld	s4,16(sp)
    8000482a:	6aa2                	ld	s5,8(sp)
    8000482c:	6121                	addi	sp,sp,64
    8000482e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004830:	85d6                	mv	a1,s5
    80004832:	8552                	mv	a0,s4
    80004834:	00000097          	auipc	ra,0x0
    80004838:	354080e7          	jalr	852(ra) # 80004b88 <pipeclose>
    8000483c:	b7cd                	j	8000481e <fileclose+0xa8>

000000008000483e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000483e:	715d                	addi	sp,sp,-80
    80004840:	e486                	sd	ra,72(sp)
    80004842:	e0a2                	sd	s0,64(sp)
    80004844:	fc26                	sd	s1,56(sp)
    80004846:	f84a                	sd	s2,48(sp)
    80004848:	f44e                	sd	s3,40(sp)
    8000484a:	0880                	addi	s0,sp,80
    8000484c:	84aa                	mv	s1,a0
    8000484e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004850:	ffffd097          	auipc	ra,0xffffd
    80004854:	346080e7          	jalr	838(ra) # 80001b96 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004858:	409c                	lw	a5,0(s1)
    8000485a:	37f9                	addiw	a5,a5,-2
    8000485c:	4705                	li	a4,1
    8000485e:	04f76763          	bltu	a4,a5,800048ac <filestat+0x6e>
    80004862:	892a                	mv	s2,a0
    ilock(f->ip);
    80004864:	6c88                	ld	a0,24(s1)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	084080e7          	jalr	132(ra) # 800038ea <ilock>
    stati(f->ip, &st);
    8000486e:	fb840593          	addi	a1,s0,-72
    80004872:	6c88                	ld	a0,24(s1)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	300080e7          	jalr	768(ra) # 80003b74 <stati>
    iunlock(f->ip);
    8000487c:	6c88                	ld	a0,24(s1)
    8000487e:	fffff097          	auipc	ra,0xfffff
    80004882:	12e080e7          	jalr	302(ra) # 800039ac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004886:	46e1                	li	a3,24
    80004888:	fb840613          	addi	a2,s0,-72
    8000488c:	85ce                	mv	a1,s3
    8000488e:	05893503          	ld	a0,88(s2)
    80004892:	ffffd097          	auipc	ra,0xffffd
    80004896:	f88080e7          	jalr	-120(ra) # 8000181a <copyout>
    8000489a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000489e:	60a6                	ld	ra,72(sp)
    800048a0:	6406                	ld	s0,64(sp)
    800048a2:	74e2                	ld	s1,56(sp)
    800048a4:	7942                	ld	s2,48(sp)
    800048a6:	79a2                	ld	s3,40(sp)
    800048a8:	6161                	addi	sp,sp,80
    800048aa:	8082                	ret
  return -1;
    800048ac:	557d                	li	a0,-1
    800048ae:	bfc5                	j	8000489e <filestat+0x60>

00000000800048b0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048b0:	7179                	addi	sp,sp,-48
    800048b2:	f406                	sd	ra,40(sp)
    800048b4:	f022                	sd	s0,32(sp)
    800048b6:	ec26                	sd	s1,24(sp)
    800048b8:	e84a                	sd	s2,16(sp)
    800048ba:	e44e                	sd	s3,8(sp)
    800048bc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048be:	00854783          	lbu	a5,8(a0)
    800048c2:	c7c5                	beqz	a5,8000496a <fileread+0xba>
    800048c4:	84aa                	mv	s1,a0
    800048c6:	89ae                	mv	s3,a1
    800048c8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048ca:	411c                	lw	a5,0(a0)
    800048cc:	4705                	li	a4,1
    800048ce:	04e78963          	beq	a5,a4,80004920 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048d2:	470d                	li	a4,3
    800048d4:	04e78d63          	beq	a5,a4,8000492e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800048d8:	4709                	li	a4,2
    800048da:	08e79063          	bne	a5,a4,8000495a <fileread+0xaa>
    ilock(f->ip);
    800048de:	6d08                	ld	a0,24(a0)
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	00a080e7          	jalr	10(ra) # 800038ea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048e8:	874a                	mv	a4,s2
    800048ea:	5094                	lw	a3,32(s1)
    800048ec:	864e                	mv	a2,s3
    800048ee:	4585                	li	a1,1
    800048f0:	6c88                	ld	a0,24(s1)
    800048f2:	fffff097          	auipc	ra,0xfffff
    800048f6:	2ac080e7          	jalr	684(ra) # 80003b9e <readi>
    800048fa:	892a                	mv	s2,a0
    800048fc:	00a05563          	blez	a0,80004906 <fileread+0x56>
      f->off += r;
    80004900:	509c                	lw	a5,32(s1)
    80004902:	9fa9                	addw	a5,a5,a0
    80004904:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004906:	6c88                	ld	a0,24(s1)
    80004908:	fffff097          	auipc	ra,0xfffff
    8000490c:	0a4080e7          	jalr	164(ra) # 800039ac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004910:	854a                	mv	a0,s2
    80004912:	70a2                	ld	ra,40(sp)
    80004914:	7402                	ld	s0,32(sp)
    80004916:	64e2                	ld	s1,24(sp)
    80004918:	6942                	ld	s2,16(sp)
    8000491a:	69a2                	ld	s3,8(sp)
    8000491c:	6145                	addi	sp,sp,48
    8000491e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004920:	6908                	ld	a0,16(a0)
    80004922:	00000097          	auipc	ra,0x0
    80004926:	3d0080e7          	jalr	976(ra) # 80004cf2 <piperead>
    8000492a:	892a                	mv	s2,a0
    8000492c:	b7d5                	j	80004910 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000492e:	02451783          	lh	a5,36(a0)
    80004932:	03079693          	slli	a3,a5,0x30
    80004936:	92c1                	srli	a3,a3,0x30
    80004938:	4725                	li	a4,9
    8000493a:	02d76a63          	bltu	a4,a3,8000496e <fileread+0xbe>
    8000493e:	0792                	slli	a5,a5,0x4
    80004940:	00032717          	auipc	a4,0x32
    80004944:	8b870713          	addi	a4,a4,-1864 # 800361f8 <devsw>
    80004948:	97ba                	add	a5,a5,a4
    8000494a:	639c                	ld	a5,0(a5)
    8000494c:	c39d                	beqz	a5,80004972 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    8000494e:	86b2                	mv	a3,a2
    80004950:	862e                	mv	a2,a1
    80004952:	4585                	li	a1,1
    80004954:	9782                	jalr	a5
    80004956:	892a                	mv	s2,a0
    80004958:	bf65                	j	80004910 <fileread+0x60>
    panic("fileread");
    8000495a:	00005517          	auipc	a0,0x5
    8000495e:	2de50513          	addi	a0,a0,734 # 80009c38 <syscalls+0x268>
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	c08080e7          	jalr	-1016(ra) # 8000056a <panic>
    return -1;
    8000496a:	597d                	li	s2,-1
    8000496c:	b755                	j	80004910 <fileread+0x60>
      return -1;
    8000496e:	597d                	li	s2,-1
    80004970:	b745                	j	80004910 <fileread+0x60>
    80004972:	597d                	li	s2,-1
    80004974:	bf71                	j	80004910 <fileread+0x60>

0000000080004976 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004976:	715d                	addi	sp,sp,-80
    80004978:	e486                	sd	ra,72(sp)
    8000497a:	e0a2                	sd	s0,64(sp)
    8000497c:	fc26                	sd	s1,56(sp)
    8000497e:	f84a                	sd	s2,48(sp)
    80004980:	f44e                	sd	s3,40(sp)
    80004982:	f052                	sd	s4,32(sp)
    80004984:	ec56                	sd	s5,24(sp)
    80004986:	e85a                	sd	s6,16(sp)
    80004988:	e45e                	sd	s7,8(sp)
    8000498a:	e062                	sd	s8,0(sp)
    8000498c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000498e:	00954783          	lbu	a5,9(a0)
    80004992:	10078863          	beqz	a5,80004aa2 <filewrite+0x12c>
    80004996:	892a                	mv	s2,a0
    80004998:	8aae                	mv	s5,a1
    8000499a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000499c:	411c                	lw	a5,0(a0)
    8000499e:	4705                	li	a4,1
    800049a0:	02e78263          	beq	a5,a4,800049c4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049a4:	470d                	li	a4,3
    800049a6:	02e78663          	beq	a5,a4,800049d2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800049aa:	4709                	li	a4,2
    800049ac:	0ee79363          	bne	a5,a4,80004a92 <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049b0:	0ac05f63          	blez	a2,80004a6e <filewrite+0xf8>
    int i = 0;
    800049b4:	4981                	li	s3,0
    800049b6:	6b05                	lui	s6,0x1
    800049b8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049bc:	6b85                	lui	s7,0x1
    800049be:	c00b8b9b          	addiw	s7,s7,-1024
    800049c2:	a871                	j	80004a5e <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    800049c4:	6908                	ld	a0,16(a0)
    800049c6:	00000097          	auipc	ra,0x0
    800049ca:	232080e7          	jalr	562(ra) # 80004bf8 <pipewrite>
    800049ce:	8a2a                	mv	s4,a0
    800049d0:	a055                	j	80004a74 <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049d2:	02451783          	lh	a5,36(a0)
    800049d6:	03079693          	slli	a3,a5,0x30
    800049da:	92c1                	srli	a3,a3,0x30
    800049dc:	4725                	li	a4,9
    800049de:	0cd76463          	bltu	a4,a3,80004aa6 <filewrite+0x130>
    800049e2:	0792                	slli	a5,a5,0x4
    800049e4:	00032717          	auipc	a4,0x32
    800049e8:	81470713          	addi	a4,a4,-2028 # 800361f8 <devsw>
    800049ec:	97ba                	add	a5,a5,a4
    800049ee:	679c                	ld	a5,8(a5)
    800049f0:	cfcd                	beqz	a5,80004aaa <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    800049f2:	86b2                	mv	a3,a2
    800049f4:	862e                	mv	a2,a1
    800049f6:	4585                	li	a1,1
    800049f8:	9782                	jalr	a5
    800049fa:	8a2a                	mv	s4,a0
    800049fc:	a8a5                	j	80004a74 <filewrite+0xfe>
    800049fe:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	8aa080e7          	jalr	-1878(ra) # 800042ac <begin_op>
      ilock(f->ip);
    80004a0a:	01893503          	ld	a0,24(s2)
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	edc080e7          	jalr	-292(ra) # 800038ea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a16:	8762                	mv	a4,s8
    80004a18:	02092683          	lw	a3,32(s2)
    80004a1c:	01598633          	add	a2,s3,s5
    80004a20:	4585                	li	a1,1
    80004a22:	01893503          	ld	a0,24(s2)
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	270080e7          	jalr	624(ra) # 80003c96 <writei>
    80004a2e:	84aa                	mv	s1,a0
    80004a30:	00a05763          	blez	a0,80004a3e <filewrite+0xc8>
        f->off += r;
    80004a34:	02092783          	lw	a5,32(s2)
    80004a38:	9fa9                	addw	a5,a5,a0
    80004a3a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a3e:	01893503          	ld	a0,24(s2)
    80004a42:	fffff097          	auipc	ra,0xfffff
    80004a46:	f6a080e7          	jalr	-150(ra) # 800039ac <iunlock>
      end_op();
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	8e2080e7          	jalr	-1822(ra) # 8000432c <end_op>

      if(r != n1){
    80004a52:	009c1f63          	bne	s8,s1,80004a70 <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    80004a56:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a5a:	0149db63          	bge	s3,s4,80004a70 <filewrite+0xfa>
      int n1 = n - i;
    80004a5e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a62:	84be                	mv	s1,a5
    80004a64:	2781                	sext.w	a5,a5
    80004a66:	f8fb5ce3          	bge	s6,a5,800049fe <filewrite+0x88>
    80004a6a:	84de                	mv	s1,s7
    80004a6c:	bf49                	j	800049fe <filewrite+0x88>
    int i = 0;
    80004a6e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a70:	013a1f63          	bne	s4,s3,80004a8e <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a74:	8552                	mv	a0,s4
    80004a76:	60a6                	ld	ra,72(sp)
    80004a78:	6406                	ld	s0,64(sp)
    80004a7a:	74e2                	ld	s1,56(sp)
    80004a7c:	7942                	ld	s2,48(sp)
    80004a7e:	79a2                	ld	s3,40(sp)
    80004a80:	7a02                	ld	s4,32(sp)
    80004a82:	6ae2                	ld	s5,24(sp)
    80004a84:	6b42                	ld	s6,16(sp)
    80004a86:	6ba2                	ld	s7,8(sp)
    80004a88:	6c02                	ld	s8,0(sp)
    80004a8a:	6161                	addi	sp,sp,80
    80004a8c:	8082                	ret
    ret = (i == n ? n : -1);
    80004a8e:	5a7d                	li	s4,-1
    80004a90:	b7d5                	j	80004a74 <filewrite+0xfe>
    panic("filewrite");
    80004a92:	00005517          	auipc	a0,0x5
    80004a96:	1b650513          	addi	a0,a0,438 # 80009c48 <syscalls+0x278>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	ad0080e7          	jalr	-1328(ra) # 8000056a <panic>
    return -1;
    80004aa2:	5a7d                	li	s4,-1
    80004aa4:	bfc1                	j	80004a74 <filewrite+0xfe>
      return -1;
    80004aa6:	5a7d                	li	s4,-1
    80004aa8:	b7f1                	j	80004a74 <filewrite+0xfe>
    80004aaa:	5a7d                	li	s4,-1
    80004aac:	b7e1                	j	80004a74 <filewrite+0xfe>

0000000080004aae <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aae:	7179                	addi	sp,sp,-48
    80004ab0:	f406                	sd	ra,40(sp)
    80004ab2:	f022                	sd	s0,32(sp)
    80004ab4:	ec26                	sd	s1,24(sp)
    80004ab6:	e84a                	sd	s2,16(sp)
    80004ab8:	e44e                	sd	s3,8(sp)
    80004aba:	e052                	sd	s4,0(sp)
    80004abc:	1800                	addi	s0,sp,48
    80004abe:	84aa                	mv	s1,a0
    80004ac0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ac2:	0005b023          	sd	zero,0(a1)
    80004ac6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	bf0080e7          	jalr	-1040(ra) # 800046ba <filealloc>
    80004ad2:	e088                	sd	a0,0(s1)
    80004ad4:	c551                	beqz	a0,80004b60 <pipealloc+0xb2>
    80004ad6:	00000097          	auipc	ra,0x0
    80004ada:	be4080e7          	jalr	-1052(ra) # 800046ba <filealloc>
    80004ade:	00aa3023          	sd	a0,0(s4)
    80004ae2:	c92d                	beqz	a0,80004b54 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	f68080e7          	jalr	-152(ra) # 80000a4c <kalloc>
    80004aec:	892a                	mv	s2,a0
    80004aee:	c125                	beqz	a0,80004b4e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004af0:	4985                	li	s3,1
    80004af2:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004af6:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004afa:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004afe:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004b02:	00005597          	auipc	a1,0x5
    80004b06:	15658593          	addi	a1,a1,342 # 80009c58 <syscalls+0x288>
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	fbc080e7          	jalr	-68(ra) # 80000ac6 <initlock>
  (*f0)->type = FD_PIPE;
    80004b12:	609c                	ld	a5,0(s1)
    80004b14:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b18:	609c                	ld	a5,0(s1)
    80004b1a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b1e:	609c                	ld	a5,0(s1)
    80004b20:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b24:	609c                	ld	a5,0(s1)
    80004b26:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b2a:	000a3783          	ld	a5,0(s4)
    80004b2e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b32:	000a3783          	ld	a5,0(s4)
    80004b36:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b3a:	000a3783          	ld	a5,0(s4)
    80004b3e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b42:	000a3783          	ld	a5,0(s4)
    80004b46:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b4a:	4501                	li	a0,0
    80004b4c:	a025                	j	80004b74 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b4e:	6088                	ld	a0,0(s1)
    80004b50:	e501                	bnez	a0,80004b58 <pipealloc+0xaa>
    80004b52:	a039                	j	80004b60 <pipealloc+0xb2>
    80004b54:	6088                	ld	a0,0(s1)
    80004b56:	c51d                	beqz	a0,80004b84 <pipealloc+0xd6>
    fileclose(*f0);
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	c1e080e7          	jalr	-994(ra) # 80004776 <fileclose>
  if(*f1)
    80004b60:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b64:	557d                	li	a0,-1
  if(*f1)
    80004b66:	c799                	beqz	a5,80004b74 <pipealloc+0xc6>
    fileclose(*f1);
    80004b68:	853e                	mv	a0,a5
    80004b6a:	00000097          	auipc	ra,0x0
    80004b6e:	c0c080e7          	jalr	-1012(ra) # 80004776 <fileclose>
  return -1;
    80004b72:	557d                	li	a0,-1
}
    80004b74:	70a2                	ld	ra,40(sp)
    80004b76:	7402                	ld	s0,32(sp)
    80004b78:	64e2                	ld	s1,24(sp)
    80004b7a:	6942                	ld	s2,16(sp)
    80004b7c:	69a2                	ld	s3,8(sp)
    80004b7e:	6a02                	ld	s4,0(sp)
    80004b80:	6145                	addi	sp,sp,48
    80004b82:	8082                	ret
  return -1;
    80004b84:	557d                	li	a0,-1
    80004b86:	b7fd                	j	80004b74 <pipealloc+0xc6>

0000000080004b88 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b88:	1101                	addi	sp,sp,-32
    80004b8a:	ec06                	sd	ra,24(sp)
    80004b8c:	e822                	sd	s0,16(sp)
    80004b8e:	e426                	sd	s1,8(sp)
    80004b90:	e04a                	sd	s2,0(sp)
    80004b92:	1000                	addi	s0,sp,32
    80004b94:	84aa                	mv	s1,a0
    80004b96:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	004080e7          	jalr	4(ra) # 80000b9c <acquire>
  if(writable){
    80004ba0:	02090d63          	beqz	s2,80004bda <pipeclose+0x52>
    pi->writeopen = 0;
    80004ba4:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004ba8:	22048513          	addi	a0,s1,544
    80004bac:	ffffe097          	auipc	ra,0xffffe
    80004bb0:	934080e7          	jalr	-1740(ra) # 800024e0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bb4:	2284b783          	ld	a5,552(s1)
    80004bb8:	eb95                	bnez	a5,80004bec <pipeclose+0x64>
    release(&pi->lock);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	0b0080e7          	jalr	176(ra) # 80000c6c <release>
    kfree((char*)pi);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	d80080e7          	jalr	-640(ra) # 80000946 <kfree>
  } else
    release(&pi->lock);
}
    80004bce:	60e2                	ld	ra,24(sp)
    80004bd0:	6442                	ld	s0,16(sp)
    80004bd2:	64a2                	ld	s1,8(sp)
    80004bd4:	6902                	ld	s2,0(sp)
    80004bd6:	6105                	addi	sp,sp,32
    80004bd8:	8082                	ret
    pi->readopen = 0;
    80004bda:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004bde:	22448513          	addi	a0,s1,548
    80004be2:	ffffe097          	auipc	ra,0xffffe
    80004be6:	8fe080e7          	jalr	-1794(ra) # 800024e0 <wakeup>
    80004bea:	b7e9                	j	80004bb4 <pipeclose+0x2c>
    release(&pi->lock);
    80004bec:	8526                	mv	a0,s1
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	07e080e7          	jalr	126(ra) # 80000c6c <release>
}
    80004bf6:	bfe1                	j	80004bce <pipeclose+0x46>

0000000080004bf8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bf8:	7159                	addi	sp,sp,-112
    80004bfa:	f486                	sd	ra,104(sp)
    80004bfc:	f0a2                	sd	s0,96(sp)
    80004bfe:	eca6                	sd	s1,88(sp)
    80004c00:	e8ca                	sd	s2,80(sp)
    80004c02:	e4ce                	sd	s3,72(sp)
    80004c04:	e0d2                	sd	s4,64(sp)
    80004c06:	fc56                	sd	s5,56(sp)
    80004c08:	f85a                	sd	s6,48(sp)
    80004c0a:	f45e                	sd	s7,40(sp)
    80004c0c:	f062                	sd	s8,32(sp)
    80004c0e:	ec66                	sd	s9,24(sp)
    80004c10:	1880                	addi	s0,sp,112
    80004c12:	84aa                	mv	s1,a0
    80004c14:	8aae                	mv	s5,a1
    80004c16:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c18:	ffffd097          	auipc	ra,0xffffd
    80004c1c:	f7e080e7          	jalr	-130(ra) # 80001b96 <myproc>
    80004c20:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c22:	8526                	mv	a0,s1
    80004c24:	ffffc097          	auipc	ra,0xffffc
    80004c28:	f78080e7          	jalr	-136(ra) # 80000b9c <acquire>
  while(i < n){
    80004c2c:	0d405163          	blez	s4,80004cee <pipewrite+0xf6>
    80004c30:	8ba6                	mv	s7,s1
  int i = 0;
    80004c32:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c34:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c36:	22048c93          	addi	s9,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004c3a:	22448c13          	addi	s8,s1,548
    80004c3e:	a08d                	j	80004ca0 <pipewrite+0xa8>
      release(&pi->lock);
    80004c40:	8526                	mv	a0,s1
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	02a080e7          	jalr	42(ra) # 80000c6c <release>
      return -1;
    80004c4a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c4c:	854a                	mv	a0,s2
    80004c4e:	70a6                	ld	ra,104(sp)
    80004c50:	7406                	ld	s0,96(sp)
    80004c52:	64e6                	ld	s1,88(sp)
    80004c54:	6946                	ld	s2,80(sp)
    80004c56:	69a6                	ld	s3,72(sp)
    80004c58:	6a06                	ld	s4,64(sp)
    80004c5a:	7ae2                	ld	s5,56(sp)
    80004c5c:	7b42                	ld	s6,48(sp)
    80004c5e:	7ba2                	ld	s7,40(sp)
    80004c60:	7c02                	ld	s8,32(sp)
    80004c62:	6ce2                	ld	s9,24(sp)
    80004c64:	6165                	addi	sp,sp,112
    80004c66:	8082                	ret
      wakeup(&pi->nread);
    80004c68:	8566                	mv	a0,s9
    80004c6a:	ffffe097          	auipc	ra,0xffffe
    80004c6e:	876080e7          	jalr	-1930(ra) # 800024e0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c72:	85de                	mv	a1,s7
    80004c74:	8562                	mv	a0,s8
    80004c76:	ffffd097          	auipc	ra,0xffffd
    80004c7a:	6e4080e7          	jalr	1764(ra) # 8000235a <sleep>
    80004c7e:	a839                	j	80004c9c <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c80:	2244a783          	lw	a5,548(s1)
    80004c84:	0017871b          	addiw	a4,a5,1
    80004c88:	22e4a223          	sw	a4,548(s1)
    80004c8c:	1ff7f793          	andi	a5,a5,511
    80004c90:	97a6                	add	a5,a5,s1
    80004c92:	f9f44703          	lbu	a4,-97(s0)
    80004c96:	02e78023          	sb	a4,32(a5)
      i++;
    80004c9a:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c9c:	03495d63          	bge	s2,s4,80004cd6 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004ca0:	2284a783          	lw	a5,552(s1)
    80004ca4:	dfd1                	beqz	a5,80004c40 <pipewrite+0x48>
    80004ca6:	0389a783          	lw	a5,56(s3)
    80004caa:	fbd9                	bnez	a5,80004c40 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cac:	2204a783          	lw	a5,544(s1)
    80004cb0:	2244a703          	lw	a4,548(s1)
    80004cb4:	2007879b          	addiw	a5,a5,512
    80004cb8:	faf708e3          	beq	a4,a5,80004c68 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cbc:	4685                	li	a3,1
    80004cbe:	01590633          	add	a2,s2,s5
    80004cc2:	f9f40593          	addi	a1,s0,-97
    80004cc6:	0589b503          	ld	a0,88(s3)
    80004cca:	ffffd097          	auipc	ra,0xffffd
    80004cce:	bdc080e7          	jalr	-1060(ra) # 800018a6 <copyin>
    80004cd2:	fb6517e3          	bne	a0,s6,80004c80 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004cd6:	22048513          	addi	a0,s1,544
    80004cda:	ffffe097          	auipc	ra,0xffffe
    80004cde:	806080e7          	jalr	-2042(ra) # 800024e0 <wakeup>
  release(&pi->lock);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	f88080e7          	jalr	-120(ra) # 80000c6c <release>
  return i;
    80004cec:	b785                	j	80004c4c <pipewrite+0x54>
  int i = 0;
    80004cee:	4901                	li	s2,0
    80004cf0:	b7dd                	j	80004cd6 <pipewrite+0xde>

0000000080004cf2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cf2:	715d                	addi	sp,sp,-80
    80004cf4:	e486                	sd	ra,72(sp)
    80004cf6:	e0a2                	sd	s0,64(sp)
    80004cf8:	fc26                	sd	s1,56(sp)
    80004cfa:	f84a                	sd	s2,48(sp)
    80004cfc:	f44e                	sd	s3,40(sp)
    80004cfe:	f052                	sd	s4,32(sp)
    80004d00:	ec56                	sd	s5,24(sp)
    80004d02:	e85a                	sd	s6,16(sp)
    80004d04:	0880                	addi	s0,sp,80
    80004d06:	84aa                	mv	s1,a0
    80004d08:	892e                	mv	s2,a1
    80004d0a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d0c:	ffffd097          	auipc	ra,0xffffd
    80004d10:	e8a080e7          	jalr	-374(ra) # 80001b96 <myproc>
    80004d14:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d16:	8b26                	mv	s6,s1
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	e82080e7          	jalr	-382(ra) # 80000b9c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d22:	2204a703          	lw	a4,544(s1)
    80004d26:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d2a:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d2e:	02f71463          	bne	a4,a5,80004d56 <piperead+0x64>
    80004d32:	22c4a783          	lw	a5,556(s1)
    80004d36:	c385                	beqz	a5,80004d56 <piperead+0x64>
    if(pr->killed){
    80004d38:	038a2783          	lw	a5,56(s4)
    80004d3c:	ebc1                	bnez	a5,80004dcc <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d3e:	85da                	mv	a1,s6
    80004d40:	854e                	mv	a0,s3
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	618080e7          	jalr	1560(ra) # 8000235a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4a:	2204a703          	lw	a4,544(s1)
    80004d4e:	2244a783          	lw	a5,548(s1)
    80004d52:	fef700e3          	beq	a4,a5,80004d32 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d56:	09505263          	blez	s5,80004dda <piperead+0xe8>
    80004d5a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d5c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d5e:	2204a783          	lw	a5,544(s1)
    80004d62:	2244a703          	lw	a4,548(s1)
    80004d66:	02f70d63          	beq	a4,a5,80004da0 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d6a:	0017871b          	addiw	a4,a5,1
    80004d6e:	22e4a023          	sw	a4,544(s1)
    80004d72:	1ff7f793          	andi	a5,a5,511
    80004d76:	97a6                	add	a5,a5,s1
    80004d78:	0207c783          	lbu	a5,32(a5)
    80004d7c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d80:	4685                	li	a3,1
    80004d82:	fbf40613          	addi	a2,s0,-65
    80004d86:	85ca                	mv	a1,s2
    80004d88:	058a3503          	ld	a0,88(s4)
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	a8e080e7          	jalr	-1394(ra) # 8000181a <copyout>
    80004d94:	01650663          	beq	a0,s6,80004da0 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d98:	2985                	addiw	s3,s3,1
    80004d9a:	0905                	addi	s2,s2,1
    80004d9c:	fd3a91e3          	bne	s5,s3,80004d5e <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004da0:	22448513          	addi	a0,s1,548
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	73c080e7          	jalr	1852(ra) # 800024e0 <wakeup>
  release(&pi->lock);
    80004dac:	8526                	mv	a0,s1
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	ebe080e7          	jalr	-322(ra) # 80000c6c <release>
  return i;
}
    80004db6:	854e                	mv	a0,s3
    80004db8:	60a6                	ld	ra,72(sp)
    80004dba:	6406                	ld	s0,64(sp)
    80004dbc:	74e2                	ld	s1,56(sp)
    80004dbe:	7942                	ld	s2,48(sp)
    80004dc0:	79a2                	ld	s3,40(sp)
    80004dc2:	7a02                	ld	s4,32(sp)
    80004dc4:	6ae2                	ld	s5,24(sp)
    80004dc6:	6b42                	ld	s6,16(sp)
    80004dc8:	6161                	addi	sp,sp,80
    80004dca:	8082                	ret
      release(&pi->lock);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	e9e080e7          	jalr	-354(ra) # 80000c6c <release>
      return -1;
    80004dd6:	59fd                	li	s3,-1
    80004dd8:	bff9                	j	80004db6 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dda:	4981                	li	s3,0
    80004ddc:	b7d1                	j	80004da0 <piperead+0xae>

0000000080004dde <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004dde:	df010113          	addi	sp,sp,-528
    80004de2:	20113423          	sd	ra,520(sp)
    80004de6:	20813023          	sd	s0,512(sp)
    80004dea:	ffa6                	sd	s1,504(sp)
    80004dec:	fbca                	sd	s2,496(sp)
    80004dee:	f7ce                	sd	s3,488(sp)
    80004df0:	f3d2                	sd	s4,480(sp)
    80004df2:	efd6                	sd	s5,472(sp)
    80004df4:	ebda                	sd	s6,464(sp)
    80004df6:	e7de                	sd	s7,456(sp)
    80004df8:	e3e2                	sd	s8,448(sp)
    80004dfa:	ff66                	sd	s9,440(sp)
    80004dfc:	fb6a                	sd	s10,432(sp)
    80004dfe:	f76e                	sd	s11,424(sp)
    80004e00:	0c00                	addi	s0,sp,528
    80004e02:	84aa                	mv	s1,a0
    80004e04:	dea43c23          	sd	a0,-520(s0)
    80004e08:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e0c:	ffffd097          	auipc	ra,0xffffd
    80004e10:	d8a080e7          	jalr	-630(ra) # 80001b96 <myproc>
    80004e14:	892a                	mv	s2,a0

  begin_op();
    80004e16:	fffff097          	auipc	ra,0xfffff
    80004e1a:	496080e7          	jalr	1174(ra) # 800042ac <begin_op>

  if((ip = namei(path)) == 0){
    80004e1e:	8526                	mv	a0,s1
    80004e20:	fffff097          	auipc	ra,0xfffff
    80004e24:	280080e7          	jalr	640(ra) # 800040a0 <namei>
    80004e28:	c92d                	beqz	a0,80004e9a <exec+0xbc>
    80004e2a:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	abe080e7          	jalr	-1346(ra) # 800038ea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e34:	04000713          	li	a4,64
    80004e38:	4681                	li	a3,0
    80004e3a:	e5040613          	addi	a2,s0,-432
    80004e3e:	4581                	li	a1,0
    80004e40:	8526                	mv	a0,s1
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	d5c080e7          	jalr	-676(ra) # 80003b9e <readi>
    80004e4a:	04000793          	li	a5,64
    80004e4e:	00f51a63          	bne	a0,a5,80004e62 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e52:	e5042703          	lw	a4,-432(s0)
    80004e56:	464c47b7          	lui	a5,0x464c4
    80004e5a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e5e:	04f70463          	beq	a4,a5,80004ea6 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e62:	8526                	mv	a0,s1
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	ce8080e7          	jalr	-792(ra) # 80003b4c <iunlockput>
    end_op();
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	4c0080e7          	jalr	1216(ra) # 8000432c <end_op>
  }
  return -1;
    80004e74:	557d                	li	a0,-1
}
    80004e76:	20813083          	ld	ra,520(sp)
    80004e7a:	20013403          	ld	s0,512(sp)
    80004e7e:	74fe                	ld	s1,504(sp)
    80004e80:	795e                	ld	s2,496(sp)
    80004e82:	79be                	ld	s3,488(sp)
    80004e84:	7a1e                	ld	s4,480(sp)
    80004e86:	6afe                	ld	s5,472(sp)
    80004e88:	6b5e                	ld	s6,464(sp)
    80004e8a:	6bbe                	ld	s7,456(sp)
    80004e8c:	6c1e                	ld	s8,448(sp)
    80004e8e:	7cfa                	ld	s9,440(sp)
    80004e90:	7d5a                	ld	s10,432(sp)
    80004e92:	7dba                	ld	s11,424(sp)
    80004e94:	21010113          	addi	sp,sp,528
    80004e98:	8082                	ret
    end_op();
    80004e9a:	fffff097          	auipc	ra,0xfffff
    80004e9e:	492080e7          	jalr	1170(ra) # 8000432c <end_op>
    return -1;
    80004ea2:	557d                	li	a0,-1
    80004ea4:	bfc9                	j	80004e76 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ea6:	854a                	mv	a0,s2
    80004ea8:	ffffd097          	auipc	ra,0xffffd
    80004eac:	db2080e7          	jalr	-590(ra) # 80001c5a <proc_pagetable>
    80004eb0:	8baa                	mv	s7,a0
    80004eb2:	d945                	beqz	a0,80004e62 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eb4:	e7042983          	lw	s3,-400(s0)
    80004eb8:	e8845783          	lhu	a5,-376(s0)
    80004ebc:	c7ad                	beqz	a5,80004f26 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ebe:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ec0:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004ec2:	6c85                	lui	s9,0x1
    80004ec4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ec8:	def43823          	sd	a5,-528(s0)
    80004ecc:	a42d                	j	800050f6 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ece:	00005517          	auipc	a0,0x5
    80004ed2:	d9250513          	addi	a0,a0,-622 # 80009c60 <syscalls+0x290>
    80004ed6:	ffffb097          	auipc	ra,0xffffb
    80004eda:	694080e7          	jalr	1684(ra) # 8000056a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ede:	8756                	mv	a4,s5
    80004ee0:	012d86bb          	addw	a3,s11,s2
    80004ee4:	4581                	li	a1,0
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	fffff097          	auipc	ra,0xfffff
    80004eec:	cb6080e7          	jalr	-842(ra) # 80003b9e <readi>
    80004ef0:	2501                	sext.w	a0,a0
    80004ef2:	1aaa9963          	bne	s5,a0,800050a4 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004ef6:	6785                	lui	a5,0x1
    80004ef8:	0127893b          	addw	s2,a5,s2
    80004efc:	77fd                	lui	a5,0xfffff
    80004efe:	01478a3b          	addw	s4,a5,s4
    80004f02:	1f897163          	bgeu	s2,s8,800050e4 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004f06:	02091593          	slli	a1,s2,0x20
    80004f0a:	9181                	srli	a1,a1,0x20
    80004f0c:	95ea                	add	a1,a1,s10
    80004f0e:	855e                	mv	a0,s7
    80004f10:	ffffc097          	auipc	ra,0xffffc
    80004f14:	39c080e7          	jalr	924(ra) # 800012ac <walkaddr>
    80004f18:	862a                	mv	a2,a0
    if(pa == 0)
    80004f1a:	d955                	beqz	a0,80004ece <exec+0xf0>
      n = PGSIZE;
    80004f1c:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f1e:	fd9a70e3          	bgeu	s4,s9,80004ede <exec+0x100>
      n = sz - i;
    80004f22:	8ad2                	mv	s5,s4
    80004f24:	bf6d                	j	80004ede <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f26:	4901                	li	s2,0
  iunlockput(ip);
    80004f28:	8526                	mv	a0,s1
    80004f2a:	fffff097          	auipc	ra,0xfffff
    80004f2e:	c22080e7          	jalr	-990(ra) # 80003b4c <iunlockput>
  end_op();
    80004f32:	fffff097          	auipc	ra,0xfffff
    80004f36:	3fa080e7          	jalr	1018(ra) # 8000432c <end_op>
  p = myproc();
    80004f3a:	ffffd097          	auipc	ra,0xffffd
    80004f3e:	c5c080e7          	jalr	-932(ra) # 80001b96 <myproc>
    80004f42:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f44:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004f48:	6785                	lui	a5,0x1
    80004f4a:	17fd                	addi	a5,a5,-1
    80004f4c:	993e                	add	s2,s2,a5
    80004f4e:	757d                	lui	a0,0xfffff
    80004f50:	00a977b3          	and	a5,s2,a0
    80004f54:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f58:	6609                	lui	a2,0x2
    80004f5a:	963e                	add	a2,a2,a5
    80004f5c:	85be                	mv	a1,a5
    80004f5e:	855e                	mv	a0,s7
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	6e0080e7          	jalr	1760(ra) # 80001640 <uvmalloc>
    80004f68:	8b2a                	mv	s6,a0
  ip = 0;
    80004f6a:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f6c:	12050c63          	beqz	a0,800050a4 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f70:	75f9                	lui	a1,0xffffe
    80004f72:	95aa                	add	a1,a1,a0
    80004f74:	855e                	mv	a0,s7
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	872080e7          	jalr	-1934(ra) # 800017e8 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f7e:	7c7d                	lui	s8,0xfffff
    80004f80:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f82:	e0043783          	ld	a5,-512(s0)
    80004f86:	6388                	ld	a0,0(a5)
    80004f88:	c535                	beqz	a0,80004ff4 <exec+0x216>
    80004f8a:	e9040993          	addi	s3,s0,-368
    80004f8e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f92:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	09c080e7          	jalr	156(ra) # 80001030 <strlen>
    80004f9c:	2505                	addiw	a0,a0,1
    80004f9e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fa2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fa6:	13896363          	bltu	s2,s8,800050cc <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004faa:	e0043d83          	ld	s11,-512(s0)
    80004fae:	000dba03          	ld	s4,0(s11)
    80004fb2:	8552                	mv	a0,s4
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	07c080e7          	jalr	124(ra) # 80001030 <strlen>
    80004fbc:	0015069b          	addiw	a3,a0,1
    80004fc0:	8652                	mv	a2,s4
    80004fc2:	85ca                	mv	a1,s2
    80004fc4:	855e                	mv	a0,s7
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	854080e7          	jalr	-1964(ra) # 8000181a <copyout>
    80004fce:	10054363          	bltz	a0,800050d4 <exec+0x2f6>
    ustack[argc] = sp;
    80004fd2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fd6:	0485                	addi	s1,s1,1
    80004fd8:	008d8793          	addi	a5,s11,8
    80004fdc:	e0f43023          	sd	a5,-512(s0)
    80004fe0:	008db503          	ld	a0,8(s11)
    80004fe4:	c911                	beqz	a0,80004ff8 <exec+0x21a>
    if(argc >= MAXARG)
    80004fe6:	09a1                	addi	s3,s3,8
    80004fe8:	fb3c96e3          	bne	s9,s3,80004f94 <exec+0x1b6>
  sz = sz1;
    80004fec:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ff0:	4481                	li	s1,0
    80004ff2:	a84d                	j	800050a4 <exec+0x2c6>
  sp = sz;
    80004ff4:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ff6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ff8:	00349793          	slli	a5,s1,0x3
    80004ffc:	f9040713          	addi	a4,s0,-112
    80005000:	97ba                	add	a5,a5,a4
    80005002:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005006:	00148693          	addi	a3,s1,1
    8000500a:	068e                	slli	a3,a3,0x3
    8000500c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005010:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005014:	01897663          	bgeu	s2,s8,80005020 <exec+0x242>
  sz = sz1;
    80005018:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000501c:	4481                	li	s1,0
    8000501e:	a059                	j	800050a4 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005020:	e9040613          	addi	a2,s0,-368
    80005024:	85ca                	mv	a1,s2
    80005026:	855e                	mv	a0,s7
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	7f2080e7          	jalr	2034(ra) # 8000181a <copyout>
    80005030:	0a054663          	bltz	a0,800050dc <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005034:	060ab783          	ld	a5,96(s5)
    80005038:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000503c:	df843783          	ld	a5,-520(s0)
    80005040:	0007c703          	lbu	a4,0(a5)
    80005044:	cf11                	beqz	a4,80005060 <exec+0x282>
    80005046:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005048:	02f00693          	li	a3,47
    8000504c:	a039                	j	8000505a <exec+0x27c>
      last = s+1;
    8000504e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005052:	0785                	addi	a5,a5,1
    80005054:	fff7c703          	lbu	a4,-1(a5)
    80005058:	c701                	beqz	a4,80005060 <exec+0x282>
    if(*s == '/')
    8000505a:	fed71ce3          	bne	a4,a3,80005052 <exec+0x274>
    8000505e:	bfc5                	j	8000504e <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005060:	4641                	li	a2,16
    80005062:	df843583          	ld	a1,-520(s0)
    80005066:	160a8513          	addi	a0,s5,352
    8000506a:	ffffc097          	auipc	ra,0xffffc
    8000506e:	f94080e7          	jalr	-108(ra) # 80000ffe <safestrcpy>
  oldpagetable = p->pagetable;
    80005072:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005076:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000507a:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000507e:	060ab783          	ld	a5,96(s5)
    80005082:	e6843703          	ld	a4,-408(s0)
    80005086:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005088:	060ab783          	ld	a5,96(s5)
    8000508c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005090:	85ea                	mv	a1,s10
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	cd4080e7          	jalr	-812(ra) # 80001d66 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000509a:	0004851b          	sext.w	a0,s1
    8000509e:	bbe1                	j	80004e76 <exec+0x98>
    800050a0:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050a4:	e0843583          	ld	a1,-504(s0)
    800050a8:	855e                	mv	a0,s7
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	cbc080e7          	jalr	-836(ra) # 80001d66 <proc_freepagetable>
  if(ip){
    800050b2:	da0498e3          	bnez	s1,80004e62 <exec+0x84>
  return -1;
    800050b6:	557d                	li	a0,-1
    800050b8:	bb7d                	j	80004e76 <exec+0x98>
    800050ba:	e1243423          	sd	s2,-504(s0)
    800050be:	b7dd                	j	800050a4 <exec+0x2c6>
    800050c0:	e1243423          	sd	s2,-504(s0)
    800050c4:	b7c5                	j	800050a4 <exec+0x2c6>
    800050c6:	e1243423          	sd	s2,-504(s0)
    800050ca:	bfe9                	j	800050a4 <exec+0x2c6>
  sz = sz1;
    800050cc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050d0:	4481                	li	s1,0
    800050d2:	bfc9                	j	800050a4 <exec+0x2c6>
  sz = sz1;
    800050d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050d8:	4481                	li	s1,0
    800050da:	b7e9                	j	800050a4 <exec+0x2c6>
  sz = sz1;
    800050dc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050e0:	4481                	li	s1,0
    800050e2:	b7c9                	j	800050a4 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050e4:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050e8:	2b05                	addiw	s6,s6,1
    800050ea:	0389899b          	addiw	s3,s3,56
    800050ee:	e8845783          	lhu	a5,-376(s0)
    800050f2:	e2fb5be3          	bge	s6,a5,80004f28 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050f6:	2981                	sext.w	s3,s3
    800050f8:	03800713          	li	a4,56
    800050fc:	86ce                	mv	a3,s3
    800050fe:	e1840613          	addi	a2,s0,-488
    80005102:	4581                	li	a1,0
    80005104:	8526                	mv	a0,s1
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	a98080e7          	jalr	-1384(ra) # 80003b9e <readi>
    8000510e:	03800793          	li	a5,56
    80005112:	f8f517e3          	bne	a0,a5,800050a0 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005116:	e1842783          	lw	a5,-488(s0)
    8000511a:	4705                	li	a4,1
    8000511c:	fce796e3          	bne	a5,a4,800050e8 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005120:	e4043603          	ld	a2,-448(s0)
    80005124:	e3843783          	ld	a5,-456(s0)
    80005128:	f8f669e3          	bltu	a2,a5,800050ba <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000512c:	e2843783          	ld	a5,-472(s0)
    80005130:	963e                	add	a2,a2,a5
    80005132:	f8f667e3          	bltu	a2,a5,800050c0 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005136:	85ca                	mv	a1,s2
    80005138:	855e                	mv	a0,s7
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	506080e7          	jalr	1286(ra) # 80001640 <uvmalloc>
    80005142:	e0a43423          	sd	a0,-504(s0)
    80005146:	d141                	beqz	a0,800050c6 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80005148:	e2843d03          	ld	s10,-472(s0)
    8000514c:	df043783          	ld	a5,-528(s0)
    80005150:	00fd77b3          	and	a5,s10,a5
    80005154:	fba1                	bnez	a5,800050a4 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005156:	e2042d83          	lw	s11,-480(s0)
    8000515a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000515e:	f80c03e3          	beqz	s8,800050e4 <exec+0x306>
    80005162:	8a62                	mv	s4,s8
    80005164:	4901                	li	s2,0
    80005166:	b345                	j	80004f06 <exec+0x128>

0000000080005168 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005168:	7179                	addi	sp,sp,-48
    8000516a:	f406                	sd	ra,40(sp)
    8000516c:	f022                	sd	s0,32(sp)
    8000516e:	ec26                	sd	s1,24(sp)
    80005170:	e84a                	sd	s2,16(sp)
    80005172:	1800                	addi	s0,sp,48
    80005174:	892e                	mv	s2,a1
    80005176:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005178:	fdc40593          	addi	a1,s0,-36
    8000517c:	ffffe097          	auipc	ra,0xffffe
    80005180:	bfc080e7          	jalr	-1028(ra) # 80002d78 <argint>
    80005184:	04054063          	bltz	a0,800051c4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005188:	fdc42703          	lw	a4,-36(s0)
    8000518c:	47bd                	li	a5,15
    8000518e:	02e7ed63          	bltu	a5,a4,800051c8 <argfd+0x60>
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	a04080e7          	jalr	-1532(ra) # 80001b96 <myproc>
    8000519a:	fdc42703          	lw	a4,-36(s0)
    8000519e:	01a70793          	addi	a5,a4,26
    800051a2:	078e                	slli	a5,a5,0x3
    800051a4:	953e                	add	a0,a0,a5
    800051a6:	651c                	ld	a5,8(a0)
    800051a8:	c395                	beqz	a5,800051cc <argfd+0x64>
    return -1;
  if(pfd)
    800051aa:	00090463          	beqz	s2,800051b2 <argfd+0x4a>
    *pfd = fd;
    800051ae:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051b2:	4501                	li	a0,0
  if(pf)
    800051b4:	c091                	beqz	s1,800051b8 <argfd+0x50>
    *pf = f;
    800051b6:	e09c                	sd	a5,0(s1)
}
    800051b8:	70a2                	ld	ra,40(sp)
    800051ba:	7402                	ld	s0,32(sp)
    800051bc:	64e2                	ld	s1,24(sp)
    800051be:	6942                	ld	s2,16(sp)
    800051c0:	6145                	addi	sp,sp,48
    800051c2:	8082                	ret
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	bfcd                	j	800051b8 <argfd+0x50>
    return -1;
    800051c8:	557d                	li	a0,-1
    800051ca:	b7fd                	j	800051b8 <argfd+0x50>
    800051cc:	557d                	li	a0,-1
    800051ce:	b7ed                	j	800051b8 <argfd+0x50>

00000000800051d0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051d0:	1101                	addi	sp,sp,-32
    800051d2:	ec06                	sd	ra,24(sp)
    800051d4:	e822                	sd	s0,16(sp)
    800051d6:	e426                	sd	s1,8(sp)
    800051d8:	1000                	addi	s0,sp,32
    800051da:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051dc:	ffffd097          	auipc	ra,0xffffd
    800051e0:	9ba080e7          	jalr	-1606(ra) # 80001b96 <myproc>
    800051e4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051e6:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffc7cf8>
    800051ea:	4501                	li	a0,0
    800051ec:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051ee:	6398                	ld	a4,0(a5)
    800051f0:	cb19                	beqz	a4,80005206 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051f2:	2505                	addiw	a0,a0,1
    800051f4:	07a1                	addi	a5,a5,8
    800051f6:	fed51ce3          	bne	a0,a3,800051ee <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051fa:	557d                	li	a0,-1
}
    800051fc:	60e2                	ld	ra,24(sp)
    800051fe:	6442                	ld	s0,16(sp)
    80005200:	64a2                	ld	s1,8(sp)
    80005202:	6105                	addi	sp,sp,32
    80005204:	8082                	ret
      p->ofile[fd] = f;
    80005206:	01a50793          	addi	a5,a0,26
    8000520a:	078e                	slli	a5,a5,0x3
    8000520c:	963e                	add	a2,a2,a5
    8000520e:	e604                	sd	s1,8(a2)
      return fd;
    80005210:	b7f5                	j	800051fc <fdalloc+0x2c>

0000000080005212 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005212:	715d                	addi	sp,sp,-80
    80005214:	e486                	sd	ra,72(sp)
    80005216:	e0a2                	sd	s0,64(sp)
    80005218:	fc26                	sd	s1,56(sp)
    8000521a:	f84a                	sd	s2,48(sp)
    8000521c:	f44e                	sd	s3,40(sp)
    8000521e:	f052                	sd	s4,32(sp)
    80005220:	ec56                	sd	s5,24(sp)
    80005222:	0880                	addi	s0,sp,80
    80005224:	89ae                	mv	s3,a1
    80005226:	8ab2                	mv	s5,a2
    80005228:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000522a:	fb040593          	addi	a1,s0,-80
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	e90080e7          	jalr	-368(ra) # 800040be <nameiparent>
    80005236:	892a                	mv	s2,a0
    80005238:	12050f63          	beqz	a0,80005376 <create+0x164>
    return 0;

  ilock(dp);
    8000523c:	ffffe097          	auipc	ra,0xffffe
    80005240:	6ae080e7          	jalr	1710(ra) # 800038ea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005244:	4601                	li	a2,0
    80005246:	fb040593          	addi	a1,s0,-80
    8000524a:	854a                	mv	a0,s2
    8000524c:	fffff097          	auipc	ra,0xfffff
    80005250:	b82080e7          	jalr	-1150(ra) # 80003dce <dirlookup>
    80005254:	84aa                	mv	s1,a0
    80005256:	c921                	beqz	a0,800052a6 <create+0x94>
    iunlockput(dp);
    80005258:	854a                	mv	a0,s2
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	8f2080e7          	jalr	-1806(ra) # 80003b4c <iunlockput>
    ilock(ip);
    80005262:	8526                	mv	a0,s1
    80005264:	ffffe097          	auipc	ra,0xffffe
    80005268:	686080e7          	jalr	1670(ra) # 800038ea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000526c:	2981                	sext.w	s3,s3
    8000526e:	4789                	li	a5,2
    80005270:	02f99463          	bne	s3,a5,80005298 <create+0x86>
    80005274:	04c4d783          	lhu	a5,76(s1)
    80005278:	37f9                	addiw	a5,a5,-2
    8000527a:	17c2                	slli	a5,a5,0x30
    8000527c:	93c1                	srli	a5,a5,0x30
    8000527e:	4705                	li	a4,1
    80005280:	00f76c63          	bltu	a4,a5,80005298 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005284:	8526                	mv	a0,s1
    80005286:	60a6                	ld	ra,72(sp)
    80005288:	6406                	ld	s0,64(sp)
    8000528a:	74e2                	ld	s1,56(sp)
    8000528c:	7942                	ld	s2,48(sp)
    8000528e:	79a2                	ld	s3,40(sp)
    80005290:	7a02                	ld	s4,32(sp)
    80005292:	6ae2                	ld	s5,24(sp)
    80005294:	6161                	addi	sp,sp,80
    80005296:	8082                	ret
    iunlockput(ip);
    80005298:	8526                	mv	a0,s1
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	8b2080e7          	jalr	-1870(ra) # 80003b4c <iunlockput>
    return 0;
    800052a2:	4481                	li	s1,0
    800052a4:	b7c5                	j	80005284 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052a6:	85ce                	mv	a1,s3
    800052a8:	00092503          	lw	a0,0(s2)
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	4a6080e7          	jalr	1190(ra) # 80003752 <ialloc>
    800052b4:	84aa                	mv	s1,a0
    800052b6:	c529                	beqz	a0,80005300 <create+0xee>
  ilock(ip);
    800052b8:	ffffe097          	auipc	ra,0xffffe
    800052bc:	632080e7          	jalr	1586(ra) # 800038ea <ilock>
  ip->major = major;
    800052c0:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800052c4:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800052c8:	4785                	li	a5,1
    800052ca:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800052ce:	8526                	mv	a0,s1
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	550080e7          	jalr	1360(ra) # 80003820 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052d8:	2981                	sext.w	s3,s3
    800052da:	4785                	li	a5,1
    800052dc:	02f98a63          	beq	s3,a5,80005310 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800052e0:	40d0                	lw	a2,4(s1)
    800052e2:	fb040593          	addi	a1,s0,-80
    800052e6:	854a                	mv	a0,s2
    800052e8:	fffff097          	auipc	ra,0xfffff
    800052ec:	cf6080e7          	jalr	-778(ra) # 80003fde <dirlink>
    800052f0:	06054b63          	bltz	a0,80005366 <create+0x154>
  iunlockput(dp);
    800052f4:	854a                	mv	a0,s2
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	856080e7          	jalr	-1962(ra) # 80003b4c <iunlockput>
  return ip;
    800052fe:	b759                	j	80005284 <create+0x72>
    panic("create: ialloc");
    80005300:	00005517          	auipc	a0,0x5
    80005304:	98050513          	addi	a0,a0,-1664 # 80009c80 <syscalls+0x2b0>
    80005308:	ffffb097          	auipc	ra,0xffffb
    8000530c:	262080e7          	jalr	610(ra) # 8000056a <panic>
    dp->nlink++;  // for ".."
    80005310:	05295783          	lhu	a5,82(s2)
    80005314:	2785                	addiw	a5,a5,1
    80005316:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    8000531a:	854a                	mv	a0,s2
    8000531c:	ffffe097          	auipc	ra,0xffffe
    80005320:	504080e7          	jalr	1284(ra) # 80003820 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005324:	40d0                	lw	a2,4(s1)
    80005326:	00005597          	auipc	a1,0x5
    8000532a:	96a58593          	addi	a1,a1,-1686 # 80009c90 <syscalls+0x2c0>
    8000532e:	8526                	mv	a0,s1
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	cae080e7          	jalr	-850(ra) # 80003fde <dirlink>
    80005338:	00054f63          	bltz	a0,80005356 <create+0x144>
    8000533c:	00492603          	lw	a2,4(s2)
    80005340:	00005597          	auipc	a1,0x5
    80005344:	95858593          	addi	a1,a1,-1704 # 80009c98 <syscalls+0x2c8>
    80005348:	8526                	mv	a0,s1
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	c94080e7          	jalr	-876(ra) # 80003fde <dirlink>
    80005352:	f80557e3          	bgez	a0,800052e0 <create+0xce>
      panic("create dots");
    80005356:	00005517          	auipc	a0,0x5
    8000535a:	94a50513          	addi	a0,a0,-1718 # 80009ca0 <syscalls+0x2d0>
    8000535e:	ffffb097          	auipc	ra,0xffffb
    80005362:	20c080e7          	jalr	524(ra) # 8000056a <panic>
    panic("create: dirlink");
    80005366:	00005517          	auipc	a0,0x5
    8000536a:	94a50513          	addi	a0,a0,-1718 # 80009cb0 <syscalls+0x2e0>
    8000536e:	ffffb097          	auipc	ra,0xffffb
    80005372:	1fc080e7          	jalr	508(ra) # 8000056a <panic>
    return 0;
    80005376:	84aa                	mv	s1,a0
    80005378:	b731                	j	80005284 <create+0x72>

000000008000537a <sys_dup>:
{
    8000537a:	7179                	addi	sp,sp,-48
    8000537c:	f406                	sd	ra,40(sp)
    8000537e:	f022                	sd	s0,32(sp)
    80005380:	ec26                	sd	s1,24(sp)
    80005382:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005384:	fd840613          	addi	a2,s0,-40
    80005388:	4581                	li	a1,0
    8000538a:	4501                	li	a0,0
    8000538c:	00000097          	auipc	ra,0x0
    80005390:	ddc080e7          	jalr	-548(ra) # 80005168 <argfd>
    return -1;
    80005394:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005396:	02054363          	bltz	a0,800053bc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000539a:	fd843503          	ld	a0,-40(s0)
    8000539e:	00000097          	auipc	ra,0x0
    800053a2:	e32080e7          	jalr	-462(ra) # 800051d0 <fdalloc>
    800053a6:	84aa                	mv	s1,a0
    return -1;
    800053a8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053aa:	00054963          	bltz	a0,800053bc <sys_dup+0x42>
  filedup(f);
    800053ae:	fd843503          	ld	a0,-40(s0)
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	372080e7          	jalr	882(ra) # 80004724 <filedup>
  return fd;
    800053ba:	87a6                	mv	a5,s1
}
    800053bc:	853e                	mv	a0,a5
    800053be:	70a2                	ld	ra,40(sp)
    800053c0:	7402                	ld	s0,32(sp)
    800053c2:	64e2                	ld	s1,24(sp)
    800053c4:	6145                	addi	sp,sp,48
    800053c6:	8082                	ret

00000000800053c8 <sys_read>:
{
    800053c8:	7179                	addi	sp,sp,-48
    800053ca:	f406                	sd	ra,40(sp)
    800053cc:	f022                	sd	s0,32(sp)
    800053ce:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053d0:	fe840613          	addi	a2,s0,-24
    800053d4:	4581                	li	a1,0
    800053d6:	4501                	li	a0,0
    800053d8:	00000097          	auipc	ra,0x0
    800053dc:	d90080e7          	jalr	-624(ra) # 80005168 <argfd>
    return -1;
    800053e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e2:	04054163          	bltz	a0,80005424 <sys_read+0x5c>
    800053e6:	fe440593          	addi	a1,s0,-28
    800053ea:	4509                	li	a0,2
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	98c080e7          	jalr	-1652(ra) # 80002d78 <argint>
    return -1;
    800053f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f6:	02054763          	bltz	a0,80005424 <sys_read+0x5c>
    800053fa:	fd840593          	addi	a1,s0,-40
    800053fe:	4505                	li	a0,1
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	99a080e7          	jalr	-1638(ra) # 80002d9a <argaddr>
    return -1;
    80005408:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540a:	00054d63          	bltz	a0,80005424 <sys_read+0x5c>
  return fileread(f, p, n);
    8000540e:	fe442603          	lw	a2,-28(s0)
    80005412:	fd843583          	ld	a1,-40(s0)
    80005416:	fe843503          	ld	a0,-24(s0)
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	496080e7          	jalr	1174(ra) # 800048b0 <fileread>
    80005422:	87aa                	mv	a5,a0
}
    80005424:	853e                	mv	a0,a5
    80005426:	70a2                	ld	ra,40(sp)
    80005428:	7402                	ld	s0,32(sp)
    8000542a:	6145                	addi	sp,sp,48
    8000542c:	8082                	ret

000000008000542e <sys_write>:
{
    8000542e:	7179                	addi	sp,sp,-48
    80005430:	f406                	sd	ra,40(sp)
    80005432:	f022                	sd	s0,32(sp)
    80005434:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005436:	fe840613          	addi	a2,s0,-24
    8000543a:	4581                	li	a1,0
    8000543c:	4501                	li	a0,0
    8000543e:	00000097          	auipc	ra,0x0
    80005442:	d2a080e7          	jalr	-726(ra) # 80005168 <argfd>
    return -1;
    80005446:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005448:	04054163          	bltz	a0,8000548a <sys_write+0x5c>
    8000544c:	fe440593          	addi	a1,s0,-28
    80005450:	4509                	li	a0,2
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	926080e7          	jalr	-1754(ra) # 80002d78 <argint>
    return -1;
    8000545a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000545c:	02054763          	bltz	a0,8000548a <sys_write+0x5c>
    80005460:	fd840593          	addi	a1,s0,-40
    80005464:	4505                	li	a0,1
    80005466:	ffffe097          	auipc	ra,0xffffe
    8000546a:	934080e7          	jalr	-1740(ra) # 80002d9a <argaddr>
    return -1;
    8000546e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005470:	00054d63          	bltz	a0,8000548a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005474:	fe442603          	lw	a2,-28(s0)
    80005478:	fd843583          	ld	a1,-40(s0)
    8000547c:	fe843503          	ld	a0,-24(s0)
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	4f6080e7          	jalr	1270(ra) # 80004976 <filewrite>
    80005488:	87aa                	mv	a5,a0
}
    8000548a:	853e                	mv	a0,a5
    8000548c:	70a2                	ld	ra,40(sp)
    8000548e:	7402                	ld	s0,32(sp)
    80005490:	6145                	addi	sp,sp,48
    80005492:	8082                	ret

0000000080005494 <sys_close>:
{
    80005494:	1101                	addi	sp,sp,-32
    80005496:	ec06                	sd	ra,24(sp)
    80005498:	e822                	sd	s0,16(sp)
    8000549a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000549c:	fe040613          	addi	a2,s0,-32
    800054a0:	fec40593          	addi	a1,s0,-20
    800054a4:	4501                	li	a0,0
    800054a6:	00000097          	auipc	ra,0x0
    800054aa:	cc2080e7          	jalr	-830(ra) # 80005168 <argfd>
    return -1;
    800054ae:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054b0:	02054463          	bltz	a0,800054d8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054b4:	ffffc097          	auipc	ra,0xffffc
    800054b8:	6e2080e7          	jalr	1762(ra) # 80001b96 <myproc>
    800054bc:	fec42783          	lw	a5,-20(s0)
    800054c0:	07e9                	addi	a5,a5,26
    800054c2:	078e                	slli	a5,a5,0x3
    800054c4:	97aa                	add	a5,a5,a0
    800054c6:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800054ca:	fe043503          	ld	a0,-32(s0)
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	2a8080e7          	jalr	680(ra) # 80004776 <fileclose>
  return 0;
    800054d6:	4781                	li	a5,0
}
    800054d8:	853e                	mv	a0,a5
    800054da:	60e2                	ld	ra,24(sp)
    800054dc:	6442                	ld	s0,16(sp)
    800054de:	6105                	addi	sp,sp,32
    800054e0:	8082                	ret

00000000800054e2 <sys_fstat>:
{
    800054e2:	1101                	addi	sp,sp,-32
    800054e4:	ec06                	sd	ra,24(sp)
    800054e6:	e822                	sd	s0,16(sp)
    800054e8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054ea:	fe840613          	addi	a2,s0,-24
    800054ee:	4581                	li	a1,0
    800054f0:	4501                	li	a0,0
    800054f2:	00000097          	auipc	ra,0x0
    800054f6:	c76080e7          	jalr	-906(ra) # 80005168 <argfd>
    return -1;
    800054fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054fc:	02054563          	bltz	a0,80005526 <sys_fstat+0x44>
    80005500:	fe040593          	addi	a1,s0,-32
    80005504:	4505                	li	a0,1
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	894080e7          	jalr	-1900(ra) # 80002d9a <argaddr>
    return -1;
    8000550e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005510:	00054b63          	bltz	a0,80005526 <sys_fstat+0x44>
  return filestat(f, st);
    80005514:	fe043583          	ld	a1,-32(s0)
    80005518:	fe843503          	ld	a0,-24(s0)
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	322080e7          	jalr	802(ra) # 8000483e <filestat>
    80005524:	87aa                	mv	a5,a0
}
    80005526:	853e                	mv	a0,a5
    80005528:	60e2                	ld	ra,24(sp)
    8000552a:	6442                	ld	s0,16(sp)
    8000552c:	6105                	addi	sp,sp,32
    8000552e:	8082                	ret

0000000080005530 <sys_link>:
{
    80005530:	7169                	addi	sp,sp,-304
    80005532:	f606                	sd	ra,296(sp)
    80005534:	f222                	sd	s0,288(sp)
    80005536:	ee26                	sd	s1,280(sp)
    80005538:	ea4a                	sd	s2,272(sp)
    8000553a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000553c:	08000613          	li	a2,128
    80005540:	ed040593          	addi	a1,s0,-304
    80005544:	4501                	li	a0,0
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	876080e7          	jalr	-1930(ra) # 80002dbc <argstr>
    return -1;
    8000554e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005550:	10054e63          	bltz	a0,8000566c <sys_link+0x13c>
    80005554:	08000613          	li	a2,128
    80005558:	f5040593          	addi	a1,s0,-176
    8000555c:	4505                	li	a0,1
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	85e080e7          	jalr	-1954(ra) # 80002dbc <argstr>
    return -1;
    80005566:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005568:	10054263          	bltz	a0,8000566c <sys_link+0x13c>
  begin_op();
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	d40080e7          	jalr	-704(ra) # 800042ac <begin_op>
  if((ip = namei(old)) == 0){
    80005574:	ed040513          	addi	a0,s0,-304
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	b28080e7          	jalr	-1240(ra) # 800040a0 <namei>
    80005580:	84aa                	mv	s1,a0
    80005582:	c551                	beqz	a0,8000560e <sys_link+0xde>
  ilock(ip);
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	366080e7          	jalr	870(ra) # 800038ea <ilock>
  if(ip->type == T_DIR){
    8000558c:	04c49703          	lh	a4,76(s1)
    80005590:	4785                	li	a5,1
    80005592:	08f70463          	beq	a4,a5,8000561a <sys_link+0xea>
  ip->nlink++;
    80005596:	0524d783          	lhu	a5,82(s1)
    8000559a:	2785                	addiw	a5,a5,1
    8000559c:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055a0:	8526                	mv	a0,s1
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	27e080e7          	jalr	638(ra) # 80003820 <iupdate>
  iunlock(ip);
    800055aa:	8526                	mv	a0,s1
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	400080e7          	jalr	1024(ra) # 800039ac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055b4:	fd040593          	addi	a1,s0,-48
    800055b8:	f5040513          	addi	a0,s0,-176
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	b02080e7          	jalr	-1278(ra) # 800040be <nameiparent>
    800055c4:	892a                	mv	s2,a0
    800055c6:	c935                	beqz	a0,8000563a <sys_link+0x10a>
  ilock(dp);
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	322080e7          	jalr	802(ra) # 800038ea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055d0:	00092703          	lw	a4,0(s2)
    800055d4:	409c                	lw	a5,0(s1)
    800055d6:	04f71d63          	bne	a4,a5,80005630 <sys_link+0x100>
    800055da:	40d0                	lw	a2,4(s1)
    800055dc:	fd040593          	addi	a1,s0,-48
    800055e0:	854a                	mv	a0,s2
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	9fc080e7          	jalr	-1540(ra) # 80003fde <dirlink>
    800055ea:	04054363          	bltz	a0,80005630 <sys_link+0x100>
  iunlockput(dp);
    800055ee:	854a                	mv	a0,s2
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	55c080e7          	jalr	1372(ra) # 80003b4c <iunlockput>
  iput(ip);
    800055f8:	8526                	mv	a0,s1
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	4aa080e7          	jalr	1194(ra) # 80003aa4 <iput>
  end_op();
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	d2a080e7          	jalr	-726(ra) # 8000432c <end_op>
  return 0;
    8000560a:	4781                	li	a5,0
    8000560c:	a085                	j	8000566c <sys_link+0x13c>
    end_op();
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	d1e080e7          	jalr	-738(ra) # 8000432c <end_op>
    return -1;
    80005616:	57fd                	li	a5,-1
    80005618:	a891                	j	8000566c <sys_link+0x13c>
    iunlockput(ip);
    8000561a:	8526                	mv	a0,s1
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	530080e7          	jalr	1328(ra) # 80003b4c <iunlockput>
    end_op();
    80005624:	fffff097          	auipc	ra,0xfffff
    80005628:	d08080e7          	jalr	-760(ra) # 8000432c <end_op>
    return -1;
    8000562c:	57fd                	li	a5,-1
    8000562e:	a83d                	j	8000566c <sys_link+0x13c>
    iunlockput(dp);
    80005630:	854a                	mv	a0,s2
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	51a080e7          	jalr	1306(ra) # 80003b4c <iunlockput>
  ilock(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	2ae080e7          	jalr	686(ra) # 800038ea <ilock>
  ip->nlink--;
    80005644:	0524d783          	lhu	a5,82(s1)
    80005648:	37fd                	addiw	a5,a5,-1
    8000564a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000564e:	8526                	mv	a0,s1
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	1d0080e7          	jalr	464(ra) # 80003820 <iupdate>
  iunlockput(ip);
    80005658:	8526                	mv	a0,s1
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	4f2080e7          	jalr	1266(ra) # 80003b4c <iunlockput>
  end_op();
    80005662:	fffff097          	auipc	ra,0xfffff
    80005666:	cca080e7          	jalr	-822(ra) # 8000432c <end_op>
  return -1;
    8000566a:	57fd                	li	a5,-1
}
    8000566c:	853e                	mv	a0,a5
    8000566e:	70b2                	ld	ra,296(sp)
    80005670:	7412                	ld	s0,288(sp)
    80005672:	64f2                	ld	s1,280(sp)
    80005674:	6952                	ld	s2,272(sp)
    80005676:	6155                	addi	sp,sp,304
    80005678:	8082                	ret

000000008000567a <sys_unlink>:
{
    8000567a:	7151                	addi	sp,sp,-240
    8000567c:	f586                	sd	ra,232(sp)
    8000567e:	f1a2                	sd	s0,224(sp)
    80005680:	eda6                	sd	s1,216(sp)
    80005682:	e9ca                	sd	s2,208(sp)
    80005684:	e5ce                	sd	s3,200(sp)
    80005686:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005688:	08000613          	li	a2,128
    8000568c:	f3040593          	addi	a1,s0,-208
    80005690:	4501                	li	a0,0
    80005692:	ffffd097          	auipc	ra,0xffffd
    80005696:	72a080e7          	jalr	1834(ra) # 80002dbc <argstr>
    8000569a:	18054163          	bltz	a0,8000581c <sys_unlink+0x1a2>
  begin_op();
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	c0e080e7          	jalr	-1010(ra) # 800042ac <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056a6:	fb040593          	addi	a1,s0,-80
    800056aa:	f3040513          	addi	a0,s0,-208
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	a10080e7          	jalr	-1520(ra) # 800040be <nameiparent>
    800056b6:	84aa                	mv	s1,a0
    800056b8:	c979                	beqz	a0,8000578e <sys_unlink+0x114>
  ilock(dp);
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	230080e7          	jalr	560(ra) # 800038ea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056c2:	00004597          	auipc	a1,0x4
    800056c6:	5ce58593          	addi	a1,a1,1486 # 80009c90 <syscalls+0x2c0>
    800056ca:	fb040513          	addi	a0,s0,-80
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	6e6080e7          	jalr	1766(ra) # 80003db4 <namecmp>
    800056d6:	14050a63          	beqz	a0,8000582a <sys_unlink+0x1b0>
    800056da:	00004597          	auipc	a1,0x4
    800056de:	5be58593          	addi	a1,a1,1470 # 80009c98 <syscalls+0x2c8>
    800056e2:	fb040513          	addi	a0,s0,-80
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	6ce080e7          	jalr	1742(ra) # 80003db4 <namecmp>
    800056ee:	12050e63          	beqz	a0,8000582a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056f2:	f2c40613          	addi	a2,s0,-212
    800056f6:	fb040593          	addi	a1,s0,-80
    800056fa:	8526                	mv	a0,s1
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	6d2080e7          	jalr	1746(ra) # 80003dce <dirlookup>
    80005704:	892a                	mv	s2,a0
    80005706:	12050263          	beqz	a0,8000582a <sys_unlink+0x1b0>
  ilock(ip);
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	1e0080e7          	jalr	480(ra) # 800038ea <ilock>
  if(ip->nlink < 1)
    80005712:	05291783          	lh	a5,82(s2)
    80005716:	08f05263          	blez	a5,8000579a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000571a:	04c91703          	lh	a4,76(s2)
    8000571e:	4785                	li	a5,1
    80005720:	08f70563          	beq	a4,a5,800057aa <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005724:	4641                	li	a2,16
    80005726:	4581                	li	a1,0
    80005728:	fc040513          	addi	a0,s0,-64
    8000572c:	ffffb097          	auipc	ra,0xffffb
    80005730:	754080e7          	jalr	1876(ra) # 80000e80 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005734:	4741                	li	a4,16
    80005736:	f2c42683          	lw	a3,-212(s0)
    8000573a:	fc040613          	addi	a2,s0,-64
    8000573e:	4581                	li	a1,0
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	554080e7          	jalr	1364(ra) # 80003c96 <writei>
    8000574a:	47c1                	li	a5,16
    8000574c:	0af51563          	bne	a0,a5,800057f6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005750:	04c91703          	lh	a4,76(s2)
    80005754:	4785                	li	a5,1
    80005756:	0af70863          	beq	a4,a5,80005806 <sys_unlink+0x18c>
  iunlockput(dp);
    8000575a:	8526                	mv	a0,s1
    8000575c:	ffffe097          	auipc	ra,0xffffe
    80005760:	3f0080e7          	jalr	1008(ra) # 80003b4c <iunlockput>
  ip->nlink--;
    80005764:	05295783          	lhu	a5,82(s2)
    80005768:	37fd                	addiw	a5,a5,-1
    8000576a:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    8000576e:	854a                	mv	a0,s2
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	0b0080e7          	jalr	176(ra) # 80003820 <iupdate>
  iunlockput(ip);
    80005778:	854a                	mv	a0,s2
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	3d2080e7          	jalr	978(ra) # 80003b4c <iunlockput>
  end_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	baa080e7          	jalr	-1110(ra) # 8000432c <end_op>
  return 0;
    8000578a:	4501                	li	a0,0
    8000578c:	a84d                	j	8000583e <sys_unlink+0x1c4>
    end_op();
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	b9e080e7          	jalr	-1122(ra) # 8000432c <end_op>
    return -1;
    80005796:	557d                	li	a0,-1
    80005798:	a05d                	j	8000583e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000579a:	00004517          	auipc	a0,0x4
    8000579e:	52650513          	addi	a0,a0,1318 # 80009cc0 <syscalls+0x2f0>
    800057a2:	ffffb097          	auipc	ra,0xffffb
    800057a6:	dc8080e7          	jalr	-568(ra) # 8000056a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057aa:	05492703          	lw	a4,84(s2)
    800057ae:	02000793          	li	a5,32
    800057b2:	f6e7f9e3          	bgeu	a5,a4,80005724 <sys_unlink+0xaa>
    800057b6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057ba:	4741                	li	a4,16
    800057bc:	86ce                	mv	a3,s3
    800057be:	f1840613          	addi	a2,s0,-232
    800057c2:	4581                	li	a1,0
    800057c4:	854a                	mv	a0,s2
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	3d8080e7          	jalr	984(ra) # 80003b9e <readi>
    800057ce:	47c1                	li	a5,16
    800057d0:	00f51b63          	bne	a0,a5,800057e6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057d4:	f1845783          	lhu	a5,-232(s0)
    800057d8:	e7a1                	bnez	a5,80005820 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057da:	29c1                	addiw	s3,s3,16
    800057dc:	05492783          	lw	a5,84(s2)
    800057e0:	fcf9ede3          	bltu	s3,a5,800057ba <sys_unlink+0x140>
    800057e4:	b781                	j	80005724 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057e6:	00004517          	auipc	a0,0x4
    800057ea:	4f250513          	addi	a0,a0,1266 # 80009cd8 <syscalls+0x308>
    800057ee:	ffffb097          	auipc	ra,0xffffb
    800057f2:	d7c080e7          	jalr	-644(ra) # 8000056a <panic>
    panic("unlink: writei");
    800057f6:	00004517          	auipc	a0,0x4
    800057fa:	4fa50513          	addi	a0,a0,1274 # 80009cf0 <syscalls+0x320>
    800057fe:	ffffb097          	auipc	ra,0xffffb
    80005802:	d6c080e7          	jalr	-660(ra) # 8000056a <panic>
    dp->nlink--;
    80005806:	0524d783          	lhu	a5,82(s1)
    8000580a:	37fd                	addiw	a5,a5,-1
    8000580c:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	00e080e7          	jalr	14(ra) # 80003820 <iupdate>
    8000581a:	b781                	j	8000575a <sys_unlink+0xe0>
    return -1;
    8000581c:	557d                	li	a0,-1
    8000581e:	a005                	j	8000583e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005820:	854a                	mv	a0,s2
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	32a080e7          	jalr	810(ra) # 80003b4c <iunlockput>
  iunlockput(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	320080e7          	jalr	800(ra) # 80003b4c <iunlockput>
  end_op();
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	af8080e7          	jalr	-1288(ra) # 8000432c <end_op>
  return -1;
    8000583c:	557d                	li	a0,-1
}
    8000583e:	70ae                	ld	ra,232(sp)
    80005840:	740e                	ld	s0,224(sp)
    80005842:	64ee                	ld	s1,216(sp)
    80005844:	694e                	ld	s2,208(sp)
    80005846:	69ae                	ld	s3,200(sp)
    80005848:	616d                	addi	sp,sp,240
    8000584a:	8082                	ret

000000008000584c <sys_open>:

uint64
sys_open(void)
{
    8000584c:	7131                	addi	sp,sp,-192
    8000584e:	fd06                	sd	ra,184(sp)
    80005850:	f922                	sd	s0,176(sp)
    80005852:	f526                	sd	s1,168(sp)
    80005854:	f14a                	sd	s2,160(sp)
    80005856:	ed4e                	sd	s3,152(sp)
    80005858:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000585a:	08000613          	li	a2,128
    8000585e:	f5040593          	addi	a1,s0,-176
    80005862:	4501                	li	a0,0
    80005864:	ffffd097          	auipc	ra,0xffffd
    80005868:	558080e7          	jalr	1368(ra) # 80002dbc <argstr>
    return -1;
    8000586c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000586e:	0c054163          	bltz	a0,80005930 <sys_open+0xe4>
    80005872:	f4c40593          	addi	a1,s0,-180
    80005876:	4505                	li	a0,1
    80005878:	ffffd097          	auipc	ra,0xffffd
    8000587c:	500080e7          	jalr	1280(ra) # 80002d78 <argint>
    80005880:	0a054863          	bltz	a0,80005930 <sys_open+0xe4>

  begin_op();
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	a28080e7          	jalr	-1496(ra) # 800042ac <begin_op>

  if(omode & O_CREATE){
    8000588c:	f4c42783          	lw	a5,-180(s0)
    80005890:	2007f793          	andi	a5,a5,512
    80005894:	cbdd                	beqz	a5,8000594a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005896:	4681                	li	a3,0
    80005898:	4601                	li	a2,0
    8000589a:	4589                	li	a1,2
    8000589c:	f5040513          	addi	a0,s0,-176
    800058a0:	00000097          	auipc	ra,0x0
    800058a4:	972080e7          	jalr	-1678(ra) # 80005212 <create>
    800058a8:	892a                	mv	s2,a0
    if(ip == 0){
    800058aa:	c959                	beqz	a0,80005940 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058ac:	04c91703          	lh	a4,76(s2)
    800058b0:	478d                	li	a5,3
    800058b2:	00f71763          	bne	a4,a5,800058c0 <sys_open+0x74>
    800058b6:	04e95703          	lhu	a4,78(s2)
    800058ba:	47a5                	li	a5,9
    800058bc:	0ce7ec63          	bltu	a5,a4,80005994 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	dfa080e7          	jalr	-518(ra) # 800046ba <filealloc>
    800058c8:	89aa                	mv	s3,a0
    800058ca:	10050663          	beqz	a0,800059d6 <sys_open+0x18a>
    800058ce:	00000097          	auipc	ra,0x0
    800058d2:	902080e7          	jalr	-1790(ra) # 800051d0 <fdalloc>
    800058d6:	84aa                	mv	s1,a0
    800058d8:	0e054a63          	bltz	a0,800059cc <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058dc:	04c91703          	lh	a4,76(s2)
    800058e0:	478d                	li	a5,3
    800058e2:	0cf70463          	beq	a4,a5,800059aa <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    800058e6:	4789                	li	a5,2
    800058e8:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    800058ec:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    800058f0:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    800058f4:	f4c42783          	lw	a5,-180(s0)
    800058f8:	0017c713          	xori	a4,a5,1
    800058fc:	8b05                	andi	a4,a4,1
    800058fe:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005902:	0037f713          	andi	a4,a5,3
    80005906:	00e03733          	snez	a4,a4
    8000590a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000590e:	4007f793          	andi	a5,a5,1024
    80005912:	c791                	beqz	a5,8000591e <sys_open+0xd2>
    80005914:	04c91703          	lh	a4,76(s2)
    80005918:	4789                	li	a5,2
    8000591a:	0af70363          	beq	a4,a5,800059c0 <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    8000591e:	854a                	mv	a0,s2
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	08c080e7          	jalr	140(ra) # 800039ac <iunlock>
  end_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	a04080e7          	jalr	-1532(ra) # 8000432c <end_op>

  return fd;
}
    80005930:	8526                	mv	a0,s1
    80005932:	70ea                	ld	ra,184(sp)
    80005934:	744a                	ld	s0,176(sp)
    80005936:	74aa                	ld	s1,168(sp)
    80005938:	790a                	ld	s2,160(sp)
    8000593a:	69ea                	ld	s3,152(sp)
    8000593c:	6129                	addi	sp,sp,192
    8000593e:	8082                	ret
      end_op();
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	9ec080e7          	jalr	-1556(ra) # 8000432c <end_op>
      return -1;
    80005948:	b7e5                	j	80005930 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000594a:	f5040513          	addi	a0,s0,-176
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	752080e7          	jalr	1874(ra) # 800040a0 <namei>
    80005956:	892a                	mv	s2,a0
    80005958:	c905                	beqz	a0,80005988 <sys_open+0x13c>
    ilock(ip);
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	f90080e7          	jalr	-112(ra) # 800038ea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005962:	04c91703          	lh	a4,76(s2)
    80005966:	4785                	li	a5,1
    80005968:	f4f712e3          	bne	a4,a5,800058ac <sys_open+0x60>
    8000596c:	f4c42783          	lw	a5,-180(s0)
    80005970:	dba1                	beqz	a5,800058c0 <sys_open+0x74>
      iunlockput(ip);
    80005972:	854a                	mv	a0,s2
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	1d8080e7          	jalr	472(ra) # 80003b4c <iunlockput>
      end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	9b0080e7          	jalr	-1616(ra) # 8000432c <end_op>
      return -1;
    80005984:	54fd                	li	s1,-1
    80005986:	b76d                	j	80005930 <sys_open+0xe4>
      end_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	9a4080e7          	jalr	-1628(ra) # 8000432c <end_op>
      return -1;
    80005990:	54fd                	li	s1,-1
    80005992:	bf79                	j	80005930 <sys_open+0xe4>
    iunlockput(ip);
    80005994:	854a                	mv	a0,s2
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	1b6080e7          	jalr	438(ra) # 80003b4c <iunlockput>
    end_op();
    8000599e:	fffff097          	auipc	ra,0xfffff
    800059a2:	98e080e7          	jalr	-1650(ra) # 8000432c <end_op>
    return -1;
    800059a6:	54fd                	li	s1,-1
    800059a8:	b761                	j	80005930 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059aa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ae:	04e91783          	lh	a5,78(s2)
    800059b2:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800059b6:	05091783          	lh	a5,80(s2)
    800059ba:	02f99323          	sh	a5,38(s3)
    800059be:	b73d                	j	800058ec <sys_open+0xa0>
    itrunc(ip);
    800059c0:	854a                	mv	a0,s2
    800059c2:	ffffe097          	auipc	ra,0xffffe
    800059c6:	036080e7          	jalr	54(ra) # 800039f8 <itrunc>
    800059ca:	bf91                	j	8000591e <sys_open+0xd2>
      fileclose(f);
    800059cc:	854e                	mv	a0,s3
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	da8080e7          	jalr	-600(ra) # 80004776 <fileclose>
    iunlockput(ip);
    800059d6:	854a                	mv	a0,s2
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	174080e7          	jalr	372(ra) # 80003b4c <iunlockput>
    end_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	94c080e7          	jalr	-1716(ra) # 8000432c <end_op>
    return -1;
    800059e8:	54fd                	li	s1,-1
    800059ea:	b799                	j	80005930 <sys_open+0xe4>

00000000800059ec <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059ec:	7175                	addi	sp,sp,-144
    800059ee:	e506                	sd	ra,136(sp)
    800059f0:	e122                	sd	s0,128(sp)
    800059f2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	8b8080e7          	jalr	-1864(ra) # 800042ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059fc:	08000613          	li	a2,128
    80005a00:	f7040593          	addi	a1,s0,-144
    80005a04:	4501                	li	a0,0
    80005a06:	ffffd097          	auipc	ra,0xffffd
    80005a0a:	3b6080e7          	jalr	950(ra) # 80002dbc <argstr>
    80005a0e:	02054963          	bltz	a0,80005a40 <sys_mkdir+0x54>
    80005a12:	4681                	li	a3,0
    80005a14:	4601                	li	a2,0
    80005a16:	4585                	li	a1,1
    80005a18:	f7040513          	addi	a0,s0,-144
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	7f6080e7          	jalr	2038(ra) # 80005212 <create>
    80005a24:	cd11                	beqz	a0,80005a40 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	126080e7          	jalr	294(ra) # 80003b4c <iunlockput>
  end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	8fe080e7          	jalr	-1794(ra) # 8000432c <end_op>
  return 0;
    80005a36:	4501                	li	a0,0
}
    80005a38:	60aa                	ld	ra,136(sp)
    80005a3a:	640a                	ld	s0,128(sp)
    80005a3c:	6149                	addi	sp,sp,144
    80005a3e:	8082                	ret
    end_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	8ec080e7          	jalr	-1812(ra) # 8000432c <end_op>
    return -1;
    80005a48:	557d                	li	a0,-1
    80005a4a:	b7fd                	j	80005a38 <sys_mkdir+0x4c>

0000000080005a4c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a4c:	7135                	addi	sp,sp,-160
    80005a4e:	ed06                	sd	ra,152(sp)
    80005a50:	e922                	sd	s0,144(sp)
    80005a52:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	858080e7          	jalr	-1960(ra) # 800042ac <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a5c:	08000613          	li	a2,128
    80005a60:	f7040593          	addi	a1,s0,-144
    80005a64:	4501                	li	a0,0
    80005a66:	ffffd097          	auipc	ra,0xffffd
    80005a6a:	356080e7          	jalr	854(ra) # 80002dbc <argstr>
    80005a6e:	04054a63          	bltz	a0,80005ac2 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a72:	f6c40593          	addi	a1,s0,-148
    80005a76:	4505                	li	a0,1
    80005a78:	ffffd097          	auipc	ra,0xffffd
    80005a7c:	300080e7          	jalr	768(ra) # 80002d78 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a80:	04054163          	bltz	a0,80005ac2 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a84:	f6840593          	addi	a1,s0,-152
    80005a88:	4509                	li	a0,2
    80005a8a:	ffffd097          	auipc	ra,0xffffd
    80005a8e:	2ee080e7          	jalr	750(ra) # 80002d78 <argint>
     argint(1, &major) < 0 ||
    80005a92:	02054863          	bltz	a0,80005ac2 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a96:	f6841683          	lh	a3,-152(s0)
    80005a9a:	f6c41603          	lh	a2,-148(s0)
    80005a9e:	458d                	li	a1,3
    80005aa0:	f7040513          	addi	a0,s0,-144
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	76e080e7          	jalr	1902(ra) # 80005212 <create>
     argint(2, &minor) < 0 ||
    80005aac:	c919                	beqz	a0,80005ac2 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	09e080e7          	jalr	158(ra) # 80003b4c <iunlockput>
  end_op();
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	876080e7          	jalr	-1930(ra) # 8000432c <end_op>
  return 0;
    80005abe:	4501                	li	a0,0
    80005ac0:	a031                	j	80005acc <sys_mknod+0x80>
    end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	86a080e7          	jalr	-1942(ra) # 8000432c <end_op>
    return -1;
    80005aca:	557d                	li	a0,-1
}
    80005acc:	60ea                	ld	ra,152(sp)
    80005ace:	644a                	ld	s0,144(sp)
    80005ad0:	610d                	addi	sp,sp,160
    80005ad2:	8082                	ret

0000000080005ad4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ad4:	7135                	addi	sp,sp,-160
    80005ad6:	ed06                	sd	ra,152(sp)
    80005ad8:	e922                	sd	s0,144(sp)
    80005ada:	e526                	sd	s1,136(sp)
    80005adc:	e14a                	sd	s2,128(sp)
    80005ade:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ae0:	ffffc097          	auipc	ra,0xffffc
    80005ae4:	0b6080e7          	jalr	182(ra) # 80001b96 <myproc>
    80005ae8:	892a                	mv	s2,a0
  
  begin_op();
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	7c2080e7          	jalr	1986(ra) # 800042ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005af2:	08000613          	li	a2,128
    80005af6:	f6040593          	addi	a1,s0,-160
    80005afa:	4501                	li	a0,0
    80005afc:	ffffd097          	auipc	ra,0xffffd
    80005b00:	2c0080e7          	jalr	704(ra) # 80002dbc <argstr>
    80005b04:	04054b63          	bltz	a0,80005b5a <sys_chdir+0x86>
    80005b08:	f6040513          	addi	a0,s0,-160
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	594080e7          	jalr	1428(ra) # 800040a0 <namei>
    80005b14:	84aa                	mv	s1,a0
    80005b16:	c131                	beqz	a0,80005b5a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	dd2080e7          	jalr	-558(ra) # 800038ea <ilock>
  if(ip->type != T_DIR){
    80005b20:	04c49703          	lh	a4,76(s1)
    80005b24:	4785                	li	a5,1
    80005b26:	04f71063          	bne	a4,a5,80005b66 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b2a:	8526                	mv	a0,s1
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	e80080e7          	jalr	-384(ra) # 800039ac <iunlock>
  iput(p->cwd);
    80005b34:	15893503          	ld	a0,344(s2)
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	f6c080e7          	jalr	-148(ra) # 80003aa4 <iput>
  end_op();
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	7ec080e7          	jalr	2028(ra) # 8000432c <end_op>
  p->cwd = ip;
    80005b48:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b4c:	4501                	li	a0,0
}
    80005b4e:	60ea                	ld	ra,152(sp)
    80005b50:	644a                	ld	s0,144(sp)
    80005b52:	64aa                	ld	s1,136(sp)
    80005b54:	690a                	ld	s2,128(sp)
    80005b56:	610d                	addi	sp,sp,160
    80005b58:	8082                	ret
    end_op();
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	7d2080e7          	jalr	2002(ra) # 8000432c <end_op>
    return -1;
    80005b62:	557d                	li	a0,-1
    80005b64:	b7ed                	j	80005b4e <sys_chdir+0x7a>
    iunlockput(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	fe4080e7          	jalr	-28(ra) # 80003b4c <iunlockput>
    end_op();
    80005b70:	ffffe097          	auipc	ra,0xffffe
    80005b74:	7bc080e7          	jalr	1980(ra) # 8000432c <end_op>
    return -1;
    80005b78:	557d                	li	a0,-1
    80005b7a:	bfd1                	j	80005b4e <sys_chdir+0x7a>

0000000080005b7c <sys_exec>:

uint64
sys_exec(void)
{
    80005b7c:	7145                	addi	sp,sp,-464
    80005b7e:	e786                	sd	ra,456(sp)
    80005b80:	e3a2                	sd	s0,448(sp)
    80005b82:	ff26                	sd	s1,440(sp)
    80005b84:	fb4a                	sd	s2,432(sp)
    80005b86:	f74e                	sd	s3,424(sp)
    80005b88:	f352                	sd	s4,416(sp)
    80005b8a:	ef56                	sd	s5,408(sp)
    80005b8c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b8e:	08000613          	li	a2,128
    80005b92:	f4040593          	addi	a1,s0,-192
    80005b96:	4501                	li	a0,0
    80005b98:	ffffd097          	auipc	ra,0xffffd
    80005b9c:	224080e7          	jalr	548(ra) # 80002dbc <argstr>
    return -1;
    80005ba0:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ba2:	0c054a63          	bltz	a0,80005c76 <sys_exec+0xfa>
    80005ba6:	e3840593          	addi	a1,s0,-456
    80005baa:	4505                	li	a0,1
    80005bac:	ffffd097          	auipc	ra,0xffffd
    80005bb0:	1ee080e7          	jalr	494(ra) # 80002d9a <argaddr>
    80005bb4:	0c054163          	bltz	a0,80005c76 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bb8:	10000613          	li	a2,256
    80005bbc:	4581                	li	a1,0
    80005bbe:	e4040513          	addi	a0,s0,-448
    80005bc2:	ffffb097          	auipc	ra,0xffffb
    80005bc6:	2be080e7          	jalr	702(ra) # 80000e80 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bca:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005bce:	89a6                	mv	s3,s1
    80005bd0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bd2:	02000a13          	li	s4,32
    80005bd6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bda:	00391513          	slli	a0,s2,0x3
    80005bde:	e3040593          	addi	a1,s0,-464
    80005be2:	e3843783          	ld	a5,-456(s0)
    80005be6:	953e                	add	a0,a0,a5
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	0f6080e7          	jalr	246(ra) # 80002cde <fetchaddr>
    80005bf0:	02054a63          	bltz	a0,80005c24 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005bf4:	e3043783          	ld	a5,-464(s0)
    80005bf8:	c3b9                	beqz	a5,80005c3e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bfa:	ffffb097          	auipc	ra,0xffffb
    80005bfe:	e52080e7          	jalr	-430(ra) # 80000a4c <kalloc>
    80005c02:	85aa                	mv	a1,a0
    80005c04:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c08:	cd11                	beqz	a0,80005c24 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c0a:	6605                	lui	a2,0x1
    80005c0c:	e3043503          	ld	a0,-464(s0)
    80005c10:	ffffd097          	auipc	ra,0xffffd
    80005c14:	120080e7          	jalr	288(ra) # 80002d30 <fetchstr>
    80005c18:	00054663          	bltz	a0,80005c24 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c1c:	0905                	addi	s2,s2,1
    80005c1e:	09a1                	addi	s3,s3,8
    80005c20:	fb491be3          	bne	s2,s4,80005bd6 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c24:	10048913          	addi	s2,s1,256
    80005c28:	6088                	ld	a0,0(s1)
    80005c2a:	c529                	beqz	a0,80005c74 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c2c:	ffffb097          	auipc	ra,0xffffb
    80005c30:	d1a080e7          	jalr	-742(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c34:	04a1                	addi	s1,s1,8
    80005c36:	ff2499e3          	bne	s1,s2,80005c28 <sys_exec+0xac>
  return -1;
    80005c3a:	597d                	li	s2,-1
    80005c3c:	a82d                	j	80005c76 <sys_exec+0xfa>
      argv[i] = 0;
    80005c3e:	0a8e                	slli	s5,s5,0x3
    80005c40:	fc040793          	addi	a5,s0,-64
    80005c44:	9abe                	add	s5,s5,a5
    80005c46:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c4a:	e4040593          	addi	a1,s0,-448
    80005c4e:	f4040513          	addi	a0,s0,-192
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	18c080e7          	jalr	396(ra) # 80004dde <exec>
    80005c5a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c5c:	10048993          	addi	s3,s1,256
    80005c60:	6088                	ld	a0,0(s1)
    80005c62:	c911                	beqz	a0,80005c76 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c64:	ffffb097          	auipc	ra,0xffffb
    80005c68:	ce2080e7          	jalr	-798(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6c:	04a1                	addi	s1,s1,8
    80005c6e:	ff3499e3          	bne	s1,s3,80005c60 <sys_exec+0xe4>
    80005c72:	a011                	j	80005c76 <sys_exec+0xfa>
  return -1;
    80005c74:	597d                	li	s2,-1
}
    80005c76:	854a                	mv	a0,s2
    80005c78:	60be                	ld	ra,456(sp)
    80005c7a:	641e                	ld	s0,448(sp)
    80005c7c:	74fa                	ld	s1,440(sp)
    80005c7e:	795a                	ld	s2,432(sp)
    80005c80:	79ba                	ld	s3,424(sp)
    80005c82:	7a1a                	ld	s4,416(sp)
    80005c84:	6afa                	ld	s5,408(sp)
    80005c86:	6179                	addi	sp,sp,464
    80005c88:	8082                	ret

0000000080005c8a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c8a:	7139                	addi	sp,sp,-64
    80005c8c:	fc06                	sd	ra,56(sp)
    80005c8e:	f822                	sd	s0,48(sp)
    80005c90:	f426                	sd	s1,40(sp)
    80005c92:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c94:	ffffc097          	auipc	ra,0xffffc
    80005c98:	f02080e7          	jalr	-254(ra) # 80001b96 <myproc>
    80005c9c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c9e:	fd840593          	addi	a1,s0,-40
    80005ca2:	4501                	li	a0,0
    80005ca4:	ffffd097          	auipc	ra,0xffffd
    80005ca8:	0f6080e7          	jalr	246(ra) # 80002d9a <argaddr>
    return -1;
    80005cac:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cae:	0e054063          	bltz	a0,80005d8e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005cb2:	fc840593          	addi	a1,s0,-56
    80005cb6:	fd040513          	addi	a0,s0,-48
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	df4080e7          	jalr	-524(ra) # 80004aae <pipealloc>
    return -1;
    80005cc2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cc4:	0c054563          	bltz	a0,80005d8e <sys_pipe+0x104>
  fd0 = -1;
    80005cc8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ccc:	fd043503          	ld	a0,-48(s0)
    80005cd0:	fffff097          	auipc	ra,0xfffff
    80005cd4:	500080e7          	jalr	1280(ra) # 800051d0 <fdalloc>
    80005cd8:	fca42223          	sw	a0,-60(s0)
    80005cdc:	08054c63          	bltz	a0,80005d74 <sys_pipe+0xea>
    80005ce0:	fc843503          	ld	a0,-56(s0)
    80005ce4:	fffff097          	auipc	ra,0xfffff
    80005ce8:	4ec080e7          	jalr	1260(ra) # 800051d0 <fdalloc>
    80005cec:	fca42023          	sw	a0,-64(s0)
    80005cf0:	06054863          	bltz	a0,80005d60 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cf4:	4691                	li	a3,4
    80005cf6:	fc440613          	addi	a2,s0,-60
    80005cfa:	fd843583          	ld	a1,-40(s0)
    80005cfe:	6ca8                	ld	a0,88(s1)
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	b1a080e7          	jalr	-1254(ra) # 8000181a <copyout>
    80005d08:	02054063          	bltz	a0,80005d28 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d0c:	4691                	li	a3,4
    80005d0e:	fc040613          	addi	a2,s0,-64
    80005d12:	fd843583          	ld	a1,-40(s0)
    80005d16:	0591                	addi	a1,a1,4
    80005d18:	6ca8                	ld	a0,88(s1)
    80005d1a:	ffffc097          	auipc	ra,0xffffc
    80005d1e:	b00080e7          	jalr	-1280(ra) # 8000181a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d22:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d24:	06055563          	bgez	a0,80005d8e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d28:	fc442783          	lw	a5,-60(s0)
    80005d2c:	07e9                	addi	a5,a5,26
    80005d2e:	078e                	slli	a5,a5,0x3
    80005d30:	97a6                	add	a5,a5,s1
    80005d32:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005d36:	fc042503          	lw	a0,-64(s0)
    80005d3a:	0569                	addi	a0,a0,26
    80005d3c:	050e                	slli	a0,a0,0x3
    80005d3e:	9526                	add	a0,a0,s1
    80005d40:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005d44:	fd043503          	ld	a0,-48(s0)
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	a2e080e7          	jalr	-1490(ra) # 80004776 <fileclose>
    fileclose(wf);
    80005d50:	fc843503          	ld	a0,-56(s0)
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	a22080e7          	jalr	-1502(ra) # 80004776 <fileclose>
    return -1;
    80005d5c:	57fd                	li	a5,-1
    80005d5e:	a805                	j	80005d8e <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d60:	fc442783          	lw	a5,-60(s0)
    80005d64:	0007c863          	bltz	a5,80005d74 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d68:	01a78513          	addi	a0,a5,26
    80005d6c:	050e                	slli	a0,a0,0x3
    80005d6e:	9526                	add	a0,a0,s1
    80005d70:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005d74:	fd043503          	ld	a0,-48(s0)
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	9fe080e7          	jalr	-1538(ra) # 80004776 <fileclose>
    fileclose(wf);
    80005d80:	fc843503          	ld	a0,-56(s0)
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	9f2080e7          	jalr	-1550(ra) # 80004776 <fileclose>
    return -1;
    80005d8c:	57fd                	li	a5,-1
}
    80005d8e:	853e                	mv	a0,a5
    80005d90:	70e2                	ld	ra,56(sp)
    80005d92:	7442                	ld	s0,48(sp)
    80005d94:	74a2                	ld	s1,40(sp)
    80005d96:	6121                	addi	sp,sp,64
    80005d98:	8082                	ret
    80005d9a:	0000                	unimp
    80005d9c:	0000                	unimp
	...

0000000080005da0 <kernelvec>:
    80005da0:	7111                	addi	sp,sp,-256
    80005da2:	e006                	sd	ra,0(sp)
    80005da4:	e40a                	sd	sp,8(sp)
    80005da6:	e80e                	sd	gp,16(sp)
    80005da8:	ec12                	sd	tp,24(sp)
    80005daa:	f016                	sd	t0,32(sp)
    80005dac:	f41a                	sd	t1,40(sp)
    80005dae:	f81e                	sd	t2,48(sp)
    80005db0:	fc22                	sd	s0,56(sp)
    80005db2:	e0a6                	sd	s1,64(sp)
    80005db4:	e4aa                	sd	a0,72(sp)
    80005db6:	e8ae                	sd	a1,80(sp)
    80005db8:	ecb2                	sd	a2,88(sp)
    80005dba:	f0b6                	sd	a3,96(sp)
    80005dbc:	f4ba                	sd	a4,104(sp)
    80005dbe:	f8be                	sd	a5,112(sp)
    80005dc0:	fcc2                	sd	a6,120(sp)
    80005dc2:	e146                	sd	a7,128(sp)
    80005dc4:	e54a                	sd	s2,136(sp)
    80005dc6:	e94e                	sd	s3,144(sp)
    80005dc8:	ed52                	sd	s4,152(sp)
    80005dca:	f156                	sd	s5,160(sp)
    80005dcc:	f55a                	sd	s6,168(sp)
    80005dce:	f95e                	sd	s7,176(sp)
    80005dd0:	fd62                	sd	s8,184(sp)
    80005dd2:	e1e6                	sd	s9,192(sp)
    80005dd4:	e5ea                	sd	s10,200(sp)
    80005dd6:	e9ee                	sd	s11,208(sp)
    80005dd8:	edf2                	sd	t3,216(sp)
    80005dda:	f1f6                	sd	t4,224(sp)
    80005ddc:	f5fa                	sd	t5,232(sp)
    80005dde:	f9fe                	sd	t6,240(sp)
    80005de0:	dbffc0ef          	jal	ra,80002b9e <kerneltrap>
    80005de4:	6082                	ld	ra,0(sp)
    80005de6:	6122                	ld	sp,8(sp)
    80005de8:	61c2                	ld	gp,16(sp)
    80005dea:	7282                	ld	t0,32(sp)
    80005dec:	7322                	ld	t1,40(sp)
    80005dee:	73c2                	ld	t2,48(sp)
    80005df0:	7462                	ld	s0,56(sp)
    80005df2:	6486                	ld	s1,64(sp)
    80005df4:	6526                	ld	a0,72(sp)
    80005df6:	65c6                	ld	a1,80(sp)
    80005df8:	6666                	ld	a2,88(sp)
    80005dfa:	7686                	ld	a3,96(sp)
    80005dfc:	7726                	ld	a4,104(sp)
    80005dfe:	77c6                	ld	a5,112(sp)
    80005e00:	7866                	ld	a6,120(sp)
    80005e02:	688a                	ld	a7,128(sp)
    80005e04:	692a                	ld	s2,136(sp)
    80005e06:	69ca                	ld	s3,144(sp)
    80005e08:	6a6a                	ld	s4,152(sp)
    80005e0a:	7a8a                	ld	s5,160(sp)
    80005e0c:	7b2a                	ld	s6,168(sp)
    80005e0e:	7bca                	ld	s7,176(sp)
    80005e10:	7c6a                	ld	s8,184(sp)
    80005e12:	6c8e                	ld	s9,192(sp)
    80005e14:	6d2e                	ld	s10,200(sp)
    80005e16:	6dce                	ld	s11,208(sp)
    80005e18:	6e6e                	ld	t3,216(sp)
    80005e1a:	7e8e                	ld	t4,224(sp)
    80005e1c:	7f2e                	ld	t5,232(sp)
    80005e1e:	7fce                	ld	t6,240(sp)
    80005e20:	6111                	addi	sp,sp,256
    80005e22:	10200073          	sret
    80005e26:	00000013          	nop
    80005e2a:	00000013          	nop
    80005e2e:	0001                	nop

0000000080005e30 <timervec>:
    80005e30:	34051573          	csrrw	a0,mscratch,a0
    80005e34:	e10c                	sd	a1,0(a0)
    80005e36:	e510                	sd	a2,8(a0)
    80005e38:	e914                	sd	a3,16(a0)
    80005e3a:	6d0c                	ld	a1,24(a0)
    80005e3c:	7110                	ld	a2,32(a0)
    80005e3e:	6194                	ld	a3,0(a1)
    80005e40:	96b2                	add	a3,a3,a2
    80005e42:	e194                	sd	a3,0(a1)
    80005e44:	4589                	li	a1,2
    80005e46:	14459073          	csrw	sip,a1
    80005e4a:	6914                	ld	a3,16(a0)
    80005e4c:	6510                	ld	a2,8(a0)
    80005e4e:	610c                	ld	a1,0(a0)
    80005e50:	34051573          	csrrw	a0,mscratch,a0
    80005e54:	30200073          	mret
	...

0000000080005e5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e5a:	1141                	addi	sp,sp,-16
    80005e5c:	e422                	sd	s0,8(sp)
    80005e5e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e60:	0c0007b7          	lui	a5,0xc000
    80005e64:	4705                	li	a4,1
    80005e66:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e68:	c3d8                	sw	a4,4(a5)
}
    80005e6a:	6422                	ld	s0,8(sp)
    80005e6c:	0141                	addi	sp,sp,16
    80005e6e:	8082                	ret

0000000080005e70 <plicinithart>:

void
plicinithart(void)
{
    80005e70:	1141                	addi	sp,sp,-16
    80005e72:	e406                	sd	ra,8(sp)
    80005e74:	e022                	sd	s0,0(sp)
    80005e76:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e78:	ffffc097          	auipc	ra,0xffffc
    80005e7c:	cf2080e7          	jalr	-782(ra) # 80001b6a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e80:	0085171b          	slliw	a4,a0,0x8
    80005e84:	0c0027b7          	lui	a5,0xc002
    80005e88:	97ba                	add	a5,a5,a4
    80005e8a:	40200713          	li	a4,1026
    80005e8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e92:	00d5151b          	slliw	a0,a0,0xd
    80005e96:	0c2017b7          	lui	a5,0xc201
    80005e9a:	953e                	add	a0,a0,a5
    80005e9c:	00052023          	sw	zero,0(a0)
}
    80005ea0:	60a2                	ld	ra,8(sp)
    80005ea2:	6402                	ld	s0,0(sp)
    80005ea4:	0141                	addi	sp,sp,16
    80005ea6:	8082                	ret

0000000080005ea8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ea8:	1141                	addi	sp,sp,-16
    80005eaa:	e406                	sd	ra,8(sp)
    80005eac:	e022                	sd	s0,0(sp)
    80005eae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005eb0:	ffffc097          	auipc	ra,0xffffc
    80005eb4:	cba080e7          	jalr	-838(ra) # 80001b6a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005eb8:	00d5179b          	slliw	a5,a0,0xd
    80005ebc:	0c201537          	lui	a0,0xc201
    80005ec0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ec2:	4148                	lw	a0,4(a0)
    80005ec4:	60a2                	ld	ra,8(sp)
    80005ec6:	6402                	ld	s0,0(sp)
    80005ec8:	0141                	addi	sp,sp,16
    80005eca:	8082                	ret

0000000080005ecc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ecc:	1101                	addi	sp,sp,-32
    80005ece:	ec06                	sd	ra,24(sp)
    80005ed0:	e822                	sd	s0,16(sp)
    80005ed2:	e426                	sd	s1,8(sp)
    80005ed4:	1000                	addi	s0,sp,32
    80005ed6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	c92080e7          	jalr	-878(ra) # 80001b6a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ee0:	00d5151b          	slliw	a0,a0,0xd
    80005ee4:	0c2017b7          	lui	a5,0xc201
    80005ee8:	97aa                	add	a5,a5,a0
    80005eea:	c3c4                	sw	s1,4(a5)
}
    80005eec:	60e2                	ld	ra,24(sp)
    80005eee:	6442                	ld	s0,16(sp)
    80005ef0:	64a2                	ld	s1,8(sp)
    80005ef2:	6105                	addi	sp,sp,32
    80005ef4:	8082                	ret

0000000080005ef6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ef6:	1141                	addi	sp,sp,-16
    80005ef8:	e406                	sd	ra,8(sp)
    80005efa:	e022                	sd	s0,0(sp)
    80005efc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005efe:	479d                	li	a5,7
    80005f00:	04a7c463          	blt	a5,a0,80005f48 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f04:	00031797          	auipc	a5,0x31
    80005f08:	35478793          	addi	a5,a5,852 # 80037258 <disk>
    80005f0c:	97aa                	add	a5,a5,a0
    80005f0e:	0187c783          	lbu	a5,24(a5)
    80005f12:	e3b9                	bnez	a5,80005f58 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f14:	00031797          	auipc	a5,0x31
    80005f18:	34478793          	addi	a5,a5,836 # 80037258 <disk>
    80005f1c:	6398                	ld	a4,0(a5)
    80005f1e:	00451693          	slli	a3,a0,0x4
    80005f22:	9736                	add	a4,a4,a3
    80005f24:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005f28:	953e                	add	a0,a0,a5
    80005f2a:	4785                	li	a5,1
    80005f2c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f30:	00031517          	auipc	a0,0x31
    80005f34:	34050513          	addi	a0,a0,832 # 80037270 <disk+0x18>
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	5a8080e7          	jalr	1448(ra) # 800024e0 <wakeup>
}
    80005f40:	60a2                	ld	ra,8(sp)
    80005f42:	6402                	ld	s0,0(sp)
    80005f44:	0141                	addi	sp,sp,16
    80005f46:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f48:	00004517          	auipc	a0,0x4
    80005f4c:	db850513          	addi	a0,a0,-584 # 80009d00 <syscalls+0x330>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	61a080e7          	jalr	1562(ra) # 8000056a <panic>
    panic("virtio_disk_intr 2");
    80005f58:	00004517          	auipc	a0,0x4
    80005f5c:	dc050513          	addi	a0,a0,-576 # 80009d18 <syscalls+0x348>
    80005f60:	ffffa097          	auipc	ra,0xffffa
    80005f64:	60a080e7          	jalr	1546(ra) # 8000056a <panic>

0000000080005f68 <virtio_disk_init>:
{
    80005f68:	1101                	addi	sp,sp,-32
    80005f6a:	ec06                	sd	ra,24(sp)
    80005f6c:	e822                	sd	s0,16(sp)
    80005f6e:	e426                	sd	s1,8(sp)
    80005f70:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f72:	00031497          	auipc	s1,0x31
    80005f76:	2e648493          	addi	s1,s1,742 # 80037258 <disk>
    80005f7a:	00004597          	auipc	a1,0x4
    80005f7e:	db658593          	addi	a1,a1,-586 # 80009d30 <syscalls+0x360>
    80005f82:	00031517          	auipc	a0,0x31
    80005f86:	3fe50513          	addi	a0,a0,1022 # 80037380 <disk+0x128>
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	b3c080e7          	jalr	-1220(ra) # 80000ac6 <initlock>
  disk.desc = kalloc();
    80005f92:	ffffb097          	auipc	ra,0xffffb
    80005f96:	aba080e7          	jalr	-1350(ra) # 80000a4c <kalloc>
    80005f9a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f9c:	ffffb097          	auipc	ra,0xffffb
    80005fa0:	ab0080e7          	jalr	-1360(ra) # 80000a4c <kalloc>
    80005fa4:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fa6:	ffffb097          	auipc	ra,0xffffb
    80005faa:	aa6080e7          	jalr	-1370(ra) # 80000a4c <kalloc>
    80005fae:	87aa                	mv	a5,a0
    80005fb0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fb2:	6088                	ld	a0,0(s1)
    80005fb4:	14050263          	beqz	a0,800060f8 <virtio_disk_init+0x190>
    80005fb8:	00031717          	auipc	a4,0x31
    80005fbc:	2a873703          	ld	a4,680(a4) # 80037260 <disk+0x8>
    80005fc0:	12070c63          	beqz	a4,800060f8 <virtio_disk_init+0x190>
    80005fc4:	12078a63          	beqz	a5,800060f8 <virtio_disk_init+0x190>
  memset(disk.desc, 0, PGSIZE);
    80005fc8:	6605                	lui	a2,0x1
    80005fca:	4581                	li	a1,0
    80005fcc:	ffffb097          	auipc	ra,0xffffb
    80005fd0:	eb4080e7          	jalr	-332(ra) # 80000e80 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fd4:	00031497          	auipc	s1,0x31
    80005fd8:	28448493          	addi	s1,s1,644 # 80037258 <disk>
    80005fdc:	6605                	lui	a2,0x1
    80005fde:	4581                	li	a1,0
    80005fe0:	6488                	ld	a0,8(s1)
    80005fe2:	ffffb097          	auipc	ra,0xffffb
    80005fe6:	e9e080e7          	jalr	-354(ra) # 80000e80 <memset>
  memset(disk.used, 0, PGSIZE);
    80005fea:	6605                	lui	a2,0x1
    80005fec:	4581                	li	a1,0
    80005fee:	6888                	ld	a0,16(s1)
    80005ff0:	ffffb097          	auipc	ra,0xffffb
    80005ff4:	e90080e7          	jalr	-368(ra) # 80000e80 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ff8:	100017b7          	lui	a5,0x10001
    80005ffc:	4398                	lw	a4,0(a5)
    80005ffe:	2701                	sext.w	a4,a4
    80006000:	747277b7          	lui	a5,0x74727
    80006004:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006008:	10f71063          	bne	a4,a5,80006108 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	43dc                	lw	a5,4(a5)
    80006012:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006014:	4709                	li	a4,2
    80006016:	0ee79963          	bne	a5,a4,80006108 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000601a:	100017b7          	lui	a5,0x10001
    8000601e:	479c                	lw	a5,8(a5)
    80006020:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006022:	0ee79363          	bne	a5,a4,80006108 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006026:	100017b7          	lui	a5,0x10001
    8000602a:	47d8                	lw	a4,12(a5)
    8000602c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000602e:	554d47b7          	lui	a5,0x554d4
    80006032:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006036:	0cf71963          	bne	a4,a5,80006108 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000603a:	100017b7          	lui	a5,0x10001
    8000603e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006042:	4705                	li	a4,1
    80006044:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006046:	470d                	li	a4,3
    80006048:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000604a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000604c:	c7ffe737          	lui	a4,0xc7ffe
    80006050:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc737f>
    80006054:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006056:	2701                	sext.w	a4,a4
    80006058:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605a:	472d                	li	a4,11
    8000605c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000605e:	5bb0                	lw	a2,112(a5)
    80006060:	2601                	sext.w	a2,a2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006062:	00867793          	andi	a5,a2,8
    80006066:	cbcd                	beqz	a5,80006118 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006068:	100017b7          	lui	a5,0x10001
    8000606c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006070:	43fc                	lw	a5,68(a5)
    80006072:	2781                	sext.w	a5,a5
    80006074:	ebd5                	bnez	a5,80006128 <virtio_disk_init+0x1c0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006076:	100017b7          	lui	a5,0x10001
    8000607a:	5bdc                	lw	a5,52(a5)
    8000607c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000607e:	cfcd                	beqz	a5,80006138 <virtio_disk_init+0x1d0>
  if(max < NUM)
    80006080:	471d                	li	a4,7
    80006082:	0cf77363          	bgeu	a4,a5,80006148 <virtio_disk_init+0x1e0>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006086:	10001737          	lui	a4,0x10001
    8000608a:	47a1                	li	a5,8
    8000608c:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    8000608e:	00031797          	auipc	a5,0x31
    80006092:	1ca78793          	addi	a5,a5,458 # 80037258 <disk>
    80006096:	4394                	lw	a3,0(a5)
    80006098:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    8000609c:	43d4                	lw	a3,4(a5)
    8000609e:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    800060a2:	6794                	ld	a3,8(a5)
    800060a4:	0006859b          	sext.w	a1,a3
    800060a8:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060ac:	9681                	srai	a3,a3,0x20
    800060ae:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    800060b2:	6b94                	ld	a3,16(a5)
    800060b4:	0006859b          	sext.w	a1,a3
    800060b8:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060bc:	9681                	srai	a3,a3,0x20
    800060be:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800060c2:	4585                	li	a1,1
    800060c4:	c36c                	sw	a1,68(a4)
    disk.free[i] = 1;
    800060c6:	4685                	li	a3,1
    800060c8:	00b78c23          	sb	a1,24(a5)
    800060cc:	00d78ca3          	sb	a3,25(a5)
    800060d0:	00d78d23          	sb	a3,26(a5)
    800060d4:	00d78da3          	sb	a3,27(a5)
    800060d8:	00d78e23          	sb	a3,28(a5)
    800060dc:	00d78ea3          	sb	a3,29(a5)
    800060e0:	00d78f23          	sb	a3,30(a5)
    800060e4:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800060e8:	00466613          	ori	a2,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800060ec:	db30                	sw	a2,112(a4)
}
    800060ee:	60e2                	ld	ra,24(sp)
    800060f0:	6442                	ld	s0,16(sp)
    800060f2:	64a2                	ld	s1,8(sp)
    800060f4:	6105                	addi	sp,sp,32
    800060f6:	8082                	ret
    panic("virtio disk kalloc");
    800060f8:	00004517          	auipc	a0,0x4
    800060fc:	c4850513          	addi	a0,a0,-952 # 80009d40 <syscalls+0x370>
    80006100:	ffffa097          	auipc	ra,0xffffa
    80006104:	46a080e7          	jalr	1130(ra) # 8000056a <panic>
    panic("could not find virtio disk");
    80006108:	00004517          	auipc	a0,0x4
    8000610c:	c5050513          	addi	a0,a0,-944 # 80009d58 <syscalls+0x388>
    80006110:	ffffa097          	auipc	ra,0xffffa
    80006114:	45a080e7          	jalr	1114(ra) # 8000056a <panic>
    panic("virtio disk FEATURES_OK unset");
    80006118:	00004517          	auipc	a0,0x4
    8000611c:	c6050513          	addi	a0,a0,-928 # 80009d78 <syscalls+0x3a8>
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	44a080e7          	jalr	1098(ra) # 8000056a <panic>
    panic("virtio disk ready not zero");
    80006128:	00004517          	auipc	a0,0x4
    8000612c:	c7050513          	addi	a0,a0,-912 # 80009d98 <syscalls+0x3c8>
    80006130:	ffffa097          	auipc	ra,0xffffa
    80006134:	43a080e7          	jalr	1082(ra) # 8000056a <panic>
    panic("virtio disk has no queue 0");
    80006138:	00004517          	auipc	a0,0x4
    8000613c:	c8050513          	addi	a0,a0,-896 # 80009db8 <syscalls+0x3e8>
    80006140:	ffffa097          	auipc	ra,0xffffa
    80006144:	42a080e7          	jalr	1066(ra) # 8000056a <panic>
    panic("virtio disk max queue too short");
    80006148:	00004517          	auipc	a0,0x4
    8000614c:	c9050513          	addi	a0,a0,-880 # 80009dd8 <syscalls+0x408>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	41a080e7          	jalr	1050(ra) # 8000056a <panic>

0000000080006158 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006158:	7159                	addi	sp,sp,-112
    8000615a:	f486                	sd	ra,104(sp)
    8000615c:	f0a2                	sd	s0,96(sp)
    8000615e:	eca6                	sd	s1,88(sp)
    80006160:	e8ca                	sd	s2,80(sp)
    80006162:	e4ce                	sd	s3,72(sp)
    80006164:	e0d2                	sd	s4,64(sp)
    80006166:	fc56                	sd	s5,56(sp)
    80006168:	f85a                	sd	s6,48(sp)
    8000616a:	f45e                	sd	s7,40(sp)
    8000616c:	f062                	sd	s8,32(sp)
    8000616e:	ec66                	sd	s9,24(sp)
    80006170:	e86a                	sd	s10,16(sp)
    80006172:	1880                	addi	s0,sp,112
    80006174:	892a                	mv	s2,a0
    80006176:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006178:	00c52c83          	lw	s9,12(a0)
    8000617c:	001c9c9b          	slliw	s9,s9,0x1
    80006180:	1c82                	slli	s9,s9,0x20
    80006182:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006186:	00031517          	auipc	a0,0x31
    8000618a:	1fa50513          	addi	a0,a0,506 # 80037380 <disk+0x128>
    8000618e:	ffffb097          	auipc	ra,0xffffb
    80006192:	a0e080e7          	jalr	-1522(ra) # 80000b9c <acquire>
  for(int i = 0; i < 3; i++){
    80006196:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006198:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000619a:	00031b17          	auipc	s6,0x31
    8000619e:	0beb0b13          	addi	s6,s6,190 # 80037258 <disk>
  for(int i = 0; i < 3; i++){
    800061a2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800061a4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061a6:	00031c17          	auipc	s8,0x31
    800061aa:	1dac0c13          	addi	s8,s8,474 # 80037380 <disk+0x128>
    800061ae:	a8b5                	j	8000622a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800061b0:	00fb06b3          	add	a3,s6,a5
    800061b4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800061b8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800061ba:	0207c563          	bltz	a5,800061e4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800061be:	2485                	addiw	s1,s1,1
    800061c0:	0711                	addi	a4,a4,4
    800061c2:	1f548763          	beq	s1,s5,800063b0 <virtio_disk_rw+0x258>
    idx[i] = alloc_desc();
    800061c6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800061c8:	00031697          	auipc	a3,0x31
    800061cc:	09068693          	addi	a3,a3,144 # 80037258 <disk>
    800061d0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800061d2:	0186c583          	lbu	a1,24(a3)
    800061d6:	fde9                	bnez	a1,800061b0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800061d8:	2785                	addiw	a5,a5,1
    800061da:	0685                	addi	a3,a3,1
    800061dc:	ff779be3          	bne	a5,s7,800061d2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800061e0:	57fd                	li	a5,-1
    800061e2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061e4:	02905a63          	blez	s1,80006218 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061e8:	f9042503          	lw	a0,-112(s0)
    800061ec:	00000097          	auipc	ra,0x0
    800061f0:	d0a080e7          	jalr	-758(ra) # 80005ef6 <free_desc>
      for(int j = 0; j < i; j++)
    800061f4:	4785                	li	a5,1
    800061f6:	0297d163          	bge	a5,s1,80006218 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061fa:	f9442503          	lw	a0,-108(s0)
    800061fe:	00000097          	auipc	ra,0x0
    80006202:	cf8080e7          	jalr	-776(ra) # 80005ef6 <free_desc>
      for(int j = 0; j < i; j++)
    80006206:	4789                	li	a5,2
    80006208:	0097d863          	bge	a5,s1,80006218 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000620c:	f9842503          	lw	a0,-104(s0)
    80006210:	00000097          	auipc	ra,0x0
    80006214:	ce6080e7          	jalr	-794(ra) # 80005ef6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006218:	85e2                	mv	a1,s8
    8000621a:	00031517          	auipc	a0,0x31
    8000621e:	05650513          	addi	a0,a0,86 # 80037270 <disk+0x18>
    80006222:	ffffc097          	auipc	ra,0xffffc
    80006226:	138080e7          	jalr	312(ra) # 8000235a <sleep>
  for(int i = 0; i < 3; i++){
    8000622a:	f9040713          	addi	a4,s0,-112
    8000622e:	84ce                	mv	s1,s3
    80006230:	bf59                	j	800061c6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006232:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006236:	00479693          	slli	a3,a5,0x4
    8000623a:	00031797          	auipc	a5,0x31
    8000623e:	01e78793          	addi	a5,a5,30 # 80037258 <disk>
    80006242:	97b6                	add	a5,a5,a3
    80006244:	4685                	li	a3,1
    80006246:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006248:	00031597          	auipc	a1,0x31
    8000624c:	01058593          	addi	a1,a1,16 # 80037258 <disk>
    80006250:	00a60793          	addi	a5,a2,10
    80006254:	0792                	slli	a5,a5,0x4
    80006256:	97ae                	add	a5,a5,a1
    80006258:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000625c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006260:	f6070693          	addi	a3,a4,-160
    80006264:	619c                	ld	a5,0(a1)
    80006266:	97b6                	add	a5,a5,a3
    80006268:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000626a:	6188                	ld	a0,0(a1)
    8000626c:	96aa                	add	a3,a3,a0
    8000626e:	47c1                	li	a5,16
    80006270:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    80006272:	4785                	li	a5,1
    80006274:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006278:	f9442783          	lw	a5,-108(s0)
    8000627c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006280:	0792                	slli	a5,a5,0x4
    80006282:	953e                	add	a0,a0,a5
    80006284:	06090693          	addi	a3,s2,96
    80006288:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000628a:	6188                	ld	a0,0(a1)
    8000628c:	97aa                	add	a5,a5,a0
    8000628e:	40000693          	li	a3,1024
    80006292:	c794                	sw	a3,8(a5)
  if(write)
    80006294:	0e0d0463          	beqz	s10,8000637c <virtio_disk_rw+0x224>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006298:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    8000629c:	00c7d683          	lhu	a3,12(a5)
    800062a0:	0016e693          	ori	a3,a3,1
    800062a4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800062a8:	f9842583          	lw	a1,-104(s0)
    800062ac:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0;
    800062b0:	00031697          	auipc	a3,0x31
    800062b4:	fa868693          	addi	a3,a3,-88 # 80037258 <disk>
    800062b8:	00260793          	addi	a5,a2,2
    800062bc:	0792                	slli	a5,a5,0x4
    800062be:	97b6                	add	a5,a5,a3
    800062c0:	00078823          	sb	zero,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062c4:	0592                	slli	a1,a1,0x4
    800062c6:	952e                	add	a0,a0,a1
    800062c8:	f9070713          	addi	a4,a4,-112
    800062cc:	9736                	add	a4,a4,a3
    800062ce:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800062d0:	6298                	ld	a4,0(a3)
    800062d2:	972e                	add	a4,a4,a1
    800062d4:	4585                	li	a1,1
    800062d6:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    800062d8:	4509                	li	a0,2
    800062da:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800062de:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062e2:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062e6:	0127b423          	sd	s2,8(a5)

  // avail->idx tells the device how far to look in avail->ring.
  // avail->ring[...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062ea:	6698                	ld	a4,8(a3)
    800062ec:	00275783          	lhu	a5,2(a4)
    800062f0:	8b9d                	andi	a5,a5,7
    800062f2:	0786                	slli	a5,a5,0x1
    800062f4:	97ba                	add	a5,a5,a4
    800062f6:	00c79223          	sh	a2,4(a5)
  __sync_synchronize();
    800062fa:	0ff0000f          	fence
  disk.avail->idx += 1;
    800062fe:	6698                	ld	a4,8(a3)
    80006300:	00275783          	lhu	a5,2(a4)
    80006304:	2785                	addiw	a5,a5,1
    80006306:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000630a:	100017b7          	lui	a5,0x10001
    8000630e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006312:	00492703          	lw	a4,4(s2)
    80006316:	4785                	li	a5,1
    80006318:	02f71163          	bne	a4,a5,8000633a <virtio_disk_rw+0x1e2>
    sleep(b, &disk.vdisk_lock);
    8000631c:	00031997          	auipc	s3,0x31
    80006320:	06498993          	addi	s3,s3,100 # 80037380 <disk+0x128>
  while(b->disk == 1) {
    80006324:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006326:	85ce                	mv	a1,s3
    80006328:	854a                	mv	a0,s2
    8000632a:	ffffc097          	auipc	ra,0xffffc
    8000632e:	030080e7          	jalr	48(ra) # 8000235a <sleep>
  while(b->disk == 1) {
    80006332:	00492783          	lw	a5,4(s2)
    80006336:	fe9788e3          	beq	a5,s1,80006326 <virtio_disk_rw+0x1ce>
  }

  disk.info[idx[0]].b = 0;
    8000633a:	f9042483          	lw	s1,-112(s0)
    8000633e:	00248793          	addi	a5,s1,2
    80006342:	00479713          	slli	a4,a5,0x4
    80006346:	00031797          	auipc	a5,0x31
    8000634a:	f1278793          	addi	a5,a5,-238 # 80037258 <disk>
    8000634e:	97ba                	add	a5,a5,a4
    80006350:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    80006354:	00031917          	auipc	s2,0x31
    80006358:	f0490913          	addi	s2,s2,-252 # 80037258 <disk>
    free_desc(i);
    8000635c:	8526                	mv	a0,s1
    8000635e:	00000097          	auipc	ra,0x0
    80006362:	b98080e7          	jalr	-1128(ra) # 80005ef6 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    80006366:	0492                	slli	s1,s1,0x4
    80006368:	00093783          	ld	a5,0(s2)
    8000636c:	94be                	add	s1,s1,a5
    8000636e:	00c4d783          	lhu	a5,12(s1)
    80006372:	8b85                	andi	a5,a5,1
    80006374:	cb81                	beqz	a5,80006384 <virtio_disk_rw+0x22c>
      i = disk.desc[i].next;
    80006376:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000637a:	b7cd                	j	8000635c <virtio_disk_rw+0x204>
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    8000637c:	4689                	li	a3,2
    8000637e:	00d79623          	sh	a3,12(a5)
    80006382:	bf29                	j	8000629c <virtio_disk_rw+0x144>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006384:	00031517          	auipc	a0,0x31
    80006388:	ffc50513          	addi	a0,a0,-4 # 80037380 <disk+0x128>
    8000638c:	ffffb097          	auipc	ra,0xffffb
    80006390:	8e0080e7          	jalr	-1824(ra) # 80000c6c <release>
}
    80006394:	70a6                	ld	ra,104(sp)
    80006396:	7406                	ld	s0,96(sp)
    80006398:	64e6                	ld	s1,88(sp)
    8000639a:	6946                	ld	s2,80(sp)
    8000639c:	69a6                	ld	s3,72(sp)
    8000639e:	6a06                	ld	s4,64(sp)
    800063a0:	7ae2                	ld	s5,56(sp)
    800063a2:	7b42                	ld	s6,48(sp)
    800063a4:	7ba2                	ld	s7,40(sp)
    800063a6:	7c02                	ld	s8,32(sp)
    800063a8:	6ce2                	ld	s9,24(sp)
    800063aa:	6d42                	ld	s10,16(sp)
    800063ac:	6165                	addi	sp,sp,112
    800063ae:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063b0:	f9042603          	lw	a2,-112(s0)
    800063b4:	00a60713          	addi	a4,a2,10
    800063b8:	0712                	slli	a4,a4,0x4
    800063ba:	00031517          	auipc	a0,0x31
    800063be:	ea650513          	addi	a0,a0,-346 # 80037260 <disk+0x8>
    800063c2:	953a                	add	a0,a0,a4
  if(write)
    800063c4:	e60d17e3          	bnez	s10,80006232 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800063c8:	00a60793          	addi	a5,a2,10
    800063cc:	00479693          	slli	a3,a5,0x4
    800063d0:	00031797          	auipc	a5,0x31
    800063d4:	e8878793          	addi	a5,a5,-376 # 80037258 <disk>
    800063d8:	97b6                	add	a5,a5,a3
    800063da:	0007a423          	sw	zero,8(a5)
    800063de:	b5ad                	j	80006248 <virtio_disk_rw+0xf0>

00000000800063e0 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    800063e0:	1101                	addi	sp,sp,-32
    800063e2:	ec06                	sd	ra,24(sp)
    800063e4:	e822                	sd	s0,16(sp)
    800063e6:	e426                	sd	s1,8(sp)
    800063e8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063ea:	00031497          	auipc	s1,0x31
    800063ee:	e6e48493          	addi	s1,s1,-402 # 80037258 <disk>
    800063f2:	00031517          	auipc	a0,0x31
    800063f6:	f8e50513          	addi	a0,a0,-114 # 80037380 <disk+0x128>
    800063fa:	ffffa097          	auipc	ra,0xffffa
    800063fe:	7a2080e7          	jalr	1954(ra) # 80000b9c <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006402:	0204d783          	lhu	a5,32(s1)
    80006406:	6898                	ld	a4,16(s1)
    80006408:	00275683          	lhu	a3,2(a4)
    8000640c:	8ebd                	xor	a3,a3,a5
    8000640e:	8a9d                	andi	a3,a3,7
    80006410:	c2b1                	beqz	a3,80006454 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    80006412:	078e                	slli	a5,a5,0x3
    80006414:	97ba                	add	a5,a5,a4
    80006416:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006418:	00278713          	addi	a4,a5,2
    8000641c:	0712                	slli	a4,a4,0x4
    8000641e:	9726                	add	a4,a4,s1
    80006420:	01074703          	lbu	a4,16(a4)
    80006424:	eb31                	bnez	a4,80006478 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    80006426:	0789                	addi	a5,a5,2
    80006428:	0792                	slli	a5,a5,0x4
    8000642a:	97a6                	add	a5,a5,s1
    8000642c:	6798                	ld	a4,8(a5)
    8000642e:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006432:	6788                	ld	a0,8(a5)
    80006434:	ffffc097          	auipc	ra,0xffffc
    80006438:	0ac080e7          	jalr	172(ra) # 800024e0 <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    8000643c:	0204d783          	lhu	a5,32(s1)
    80006440:	2785                	addiw	a5,a5,1
    80006442:	8b9d                	andi	a5,a5,7
    80006444:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006448:	6898                	ld	a4,16(s1)
    8000644a:	00275683          	lhu	a3,2(a4)
    8000644e:	8a9d                	andi	a3,a3,7
    80006450:	fcf691e3          	bne	a3,a5,80006412 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006454:	10001737          	lui	a4,0x10001
    80006458:	533c                	lw	a5,96(a4)
    8000645a:	8b8d                	andi	a5,a5,3
    8000645c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000645e:	00031517          	auipc	a0,0x31
    80006462:	f2250513          	addi	a0,a0,-222 # 80037380 <disk+0x128>
    80006466:	ffffb097          	auipc	ra,0xffffb
    8000646a:	806080e7          	jalr	-2042(ra) # 80000c6c <release>
}
    8000646e:	60e2                	ld	ra,24(sp)
    80006470:	6442                	ld	s0,16(sp)
    80006472:	64a2                	ld	s1,8(sp)
    80006474:	6105                	addi	sp,sp,32
    80006476:	8082                	ret
      panic("virtio_disk_intr status");
    80006478:	00004517          	auipc	a0,0x4
    8000647c:	98050513          	addi	a0,a0,-1664 # 80009df8 <syscalls+0x428>
    80006480:	ffffa097          	auipc	ra,0xffffa
    80006484:	0ea080e7          	jalr	234(ra) # 8000056a <panic>

0000000080006488 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006488:	1141                	addi	sp,sp,-16
    8000648a:	e422                	sd	s0,8(sp)
    8000648c:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000648e:	41f5d79b          	sraiw	a5,a1,0x1f
    80006492:	01d7d79b          	srliw	a5,a5,0x1d
    80006496:	9dbd                	addw	a1,a1,a5
    80006498:	0075f713          	andi	a4,a1,7
    8000649c:	9f1d                	subw	a4,a4,a5
    8000649e:	4785                	li	a5,1
    800064a0:	00e797bb          	sllw	a5,a5,a4
    800064a4:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800064a8:	4035d59b          	sraiw	a1,a1,0x3
    800064ac:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800064ae:	0005c503          	lbu	a0,0(a1)
    800064b2:	8d7d                	and	a0,a0,a5
    800064b4:	8d1d                	sub	a0,a0,a5
}
    800064b6:	00153513          	seqz	a0,a0
    800064ba:	6422                	ld	s0,8(sp)
    800064bc:	0141                	addi	sp,sp,16
    800064be:	8082                	ret

00000000800064c0 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800064c0:	1141                	addi	sp,sp,-16
    800064c2:	e422                	sd	s0,8(sp)
    800064c4:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800064c6:	41f5d79b          	sraiw	a5,a1,0x1f
    800064ca:	01d7d79b          	srliw	a5,a5,0x1d
    800064ce:	9dbd                	addw	a1,a1,a5
    800064d0:	4035d71b          	sraiw	a4,a1,0x3
    800064d4:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800064d6:	899d                	andi	a1,a1,7
    800064d8:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    800064da:	4785                	li	a5,1
    800064dc:	00b795bb          	sllw	a1,a5,a1
    800064e0:	00054783          	lbu	a5,0(a0)
    800064e4:	8ddd                	or	a1,a1,a5
    800064e6:	00b50023          	sb	a1,0(a0)
}
    800064ea:	6422                	ld	s0,8(sp)
    800064ec:	0141                	addi	sp,sp,16
    800064ee:	8082                	ret

00000000800064f0 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800064f0:	1141                	addi	sp,sp,-16
    800064f2:	e422                	sd	s0,8(sp)
    800064f4:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800064f6:	41f5d79b          	sraiw	a5,a1,0x1f
    800064fa:	01d7d79b          	srliw	a5,a5,0x1d
    800064fe:	9dbd                	addw	a1,a1,a5
    80006500:	4035d71b          	sraiw	a4,a1,0x3
    80006504:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006506:	899d                	andi	a1,a1,7
    80006508:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    8000650a:	4785                	li	a5,1
    8000650c:	00b795bb          	sllw	a1,a5,a1
    80006510:	fff5c593          	not	a1,a1
    80006514:	00054783          	lbu	a5,0(a0)
    80006518:	8dfd                	and	a1,a1,a5
    8000651a:	00b50023          	sb	a1,0(a0)
}
    8000651e:	6422                	ld	s0,8(sp)
    80006520:	0141                	addi	sp,sp,16
    80006522:	8082                	ret

0000000080006524 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006524:	715d                	addi	sp,sp,-80
    80006526:	e486                	sd	ra,72(sp)
    80006528:	e0a2                	sd	s0,64(sp)
    8000652a:	fc26                	sd	s1,56(sp)
    8000652c:	f84a                	sd	s2,48(sp)
    8000652e:	f44e                	sd	s3,40(sp)
    80006530:	f052                	sd	s4,32(sp)
    80006532:	ec56                	sd	s5,24(sp)
    80006534:	e85a                	sd	s6,16(sp)
    80006536:	e45e                	sd	s7,8(sp)
    80006538:	0880                	addi	s0,sp,80
    8000653a:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    8000653c:	08b05b63          	blez	a1,800065d2 <bd_print_vector+0xae>
    80006540:	89aa                	mv	s3,a0
    80006542:	4481                	li	s1,0
  lb = 0;
    80006544:	4a81                	li	s5,0
  last = 1;
    80006546:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006548:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000654a:	00004b97          	auipc	s7,0x4
    8000654e:	8c6b8b93          	addi	s7,s7,-1850 # 80009e10 <syscalls+0x440>
    80006552:	a01d                	j	80006578 <bd_print_vector+0x54>
    80006554:	8626                	mv	a2,s1
    80006556:	85d6                	mv	a1,s5
    80006558:	855e                	mv	a0,s7
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	072080e7          	jalr	114(ra) # 800005cc <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006562:	85a6                	mv	a1,s1
    80006564:	854e                	mv	a0,s3
    80006566:	00000097          	auipc	ra,0x0
    8000656a:	f22080e7          	jalr	-222(ra) # 80006488 <bit_isset>
    8000656e:	892a                	mv	s2,a0
    80006570:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006572:	2485                	addiw	s1,s1,1
    80006574:	009a0d63          	beq	s4,s1,8000658e <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006578:	85a6                	mv	a1,s1
    8000657a:	854e                	mv	a0,s3
    8000657c:	00000097          	auipc	ra,0x0
    80006580:	f0c080e7          	jalr	-244(ra) # 80006488 <bit_isset>
    80006584:	ff2507e3          	beq	a0,s2,80006572 <bd_print_vector+0x4e>
    if(last == 1)
    80006588:	fd691de3          	bne	s2,s6,80006562 <bd_print_vector+0x3e>
    8000658c:	b7e1                	j	80006554 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000658e:	000a8563          	beqz	s5,80006598 <bd_print_vector+0x74>
    80006592:	4785                	li	a5,1
    80006594:	00f91c63          	bne	s2,a5,800065ac <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006598:	8652                	mv	a2,s4
    8000659a:	85d6                	mv	a1,s5
    8000659c:	00004517          	auipc	a0,0x4
    800065a0:	87450513          	addi	a0,a0,-1932 # 80009e10 <syscalls+0x440>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	028080e7          	jalr	40(ra) # 800005cc <printf>
  }
  printf("\n");
    800065ac:	00003517          	auipc	a0,0x3
    800065b0:	c5450513          	addi	a0,a0,-940 # 80009200 <digits+0x90>
    800065b4:	ffffa097          	auipc	ra,0xffffa
    800065b8:	018080e7          	jalr	24(ra) # 800005cc <printf>
}
    800065bc:	60a6                	ld	ra,72(sp)
    800065be:	6406                	ld	s0,64(sp)
    800065c0:	74e2                	ld	s1,56(sp)
    800065c2:	7942                	ld	s2,48(sp)
    800065c4:	79a2                	ld	s3,40(sp)
    800065c6:	7a02                	ld	s4,32(sp)
    800065c8:	6ae2                	ld	s5,24(sp)
    800065ca:	6b42                	ld	s6,16(sp)
    800065cc:	6ba2                	ld	s7,8(sp)
    800065ce:	6161                	addi	sp,sp,80
    800065d0:	8082                	ret
  lb = 0;
    800065d2:	4a81                	li	s5,0
    800065d4:	b7d1                	j	80006598 <bd_print_vector+0x74>

00000000800065d6 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800065d6:	00004697          	auipc	a3,0x4
    800065da:	a2a6a683          	lw	a3,-1494(a3) # 8000a000 <nsizes>
    800065de:	10d05063          	blez	a3,800066de <bd_print+0x108>
bd_print() {
    800065e2:	711d                	addi	sp,sp,-96
    800065e4:	ec86                	sd	ra,88(sp)
    800065e6:	e8a2                	sd	s0,80(sp)
    800065e8:	e4a6                	sd	s1,72(sp)
    800065ea:	e0ca                	sd	s2,64(sp)
    800065ec:	fc4e                	sd	s3,56(sp)
    800065ee:	f852                	sd	s4,48(sp)
    800065f0:	f456                	sd	s5,40(sp)
    800065f2:	f05a                	sd	s6,32(sp)
    800065f4:	ec5e                	sd	s7,24(sp)
    800065f6:	e862                	sd	s8,16(sp)
    800065f8:	e466                	sd	s9,8(sp)
    800065fa:	e06a                	sd	s10,0(sp)
    800065fc:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800065fe:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006600:	4a85                	li	s5,1
    80006602:	4c41                	li	s8,16
    80006604:	00004b97          	auipc	s7,0x4
    80006608:	81cb8b93          	addi	s7,s7,-2020 # 80009e20 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    8000660c:	00004a17          	auipc	s4,0x4
    80006610:	9eca0a13          	addi	s4,s4,-1556 # 80009ff8 <bd_sizes>
    printf("  alloc:");
    80006614:	00004b17          	auipc	s6,0x4
    80006618:	834b0b13          	addi	s6,s6,-1996 # 80009e48 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    8000661c:	00004997          	auipc	s3,0x4
    80006620:	9e498993          	addi	s3,s3,-1564 # 8000a000 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006624:	00004c97          	auipc	s9,0x4
    80006628:	834c8c93          	addi	s9,s9,-1996 # 80009e58 <syscalls+0x488>
    8000662c:	a801                	j	8000663c <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000662e:	0009a683          	lw	a3,0(s3)
    80006632:	0485                	addi	s1,s1,1
    80006634:	0004879b          	sext.w	a5,s1
    80006638:	08d7d563          	bge	a5,a3,800066c2 <bd_print+0xec>
    8000663c:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006640:	36fd                	addiw	a3,a3,-1
    80006642:	9e85                	subw	a3,a3,s1
    80006644:	00da96bb          	sllw	a3,s5,a3
    80006648:	009c1633          	sll	a2,s8,s1
    8000664c:	85ca                	mv	a1,s2
    8000664e:	855e                	mv	a0,s7
    80006650:	ffffa097          	auipc	ra,0xffffa
    80006654:	f7c080e7          	jalr	-132(ra) # 800005cc <printf>
    lst_print(&bd_sizes[k].free);
    80006658:	00549d13          	slli	s10,s1,0x5
    8000665c:	000a3503          	ld	a0,0(s4)
    80006660:	956a                	add	a0,a0,s10
    80006662:	00001097          	auipc	ra,0x1
    80006666:	a4e080e7          	jalr	-1458(ra) # 800070b0 <lst_print>
    printf("  alloc:");
    8000666a:	855a                	mv	a0,s6
    8000666c:	ffffa097          	auipc	ra,0xffffa
    80006670:	f60080e7          	jalr	-160(ra) # 800005cc <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006674:	0009a583          	lw	a1,0(s3)
    80006678:	35fd                	addiw	a1,a1,-1
    8000667a:	412585bb          	subw	a1,a1,s2
    8000667e:	000a3783          	ld	a5,0(s4)
    80006682:	97ea                	add	a5,a5,s10
    80006684:	00ba95bb          	sllw	a1,s5,a1
    80006688:	6b88                	ld	a0,16(a5)
    8000668a:	00000097          	auipc	ra,0x0
    8000668e:	e9a080e7          	jalr	-358(ra) # 80006524 <bd_print_vector>
    if(k > 0) {
    80006692:	f9205ee3          	blez	s2,8000662e <bd_print+0x58>
      printf("  split:");
    80006696:	8566                	mv	a0,s9
    80006698:	ffffa097          	auipc	ra,0xffffa
    8000669c:	f34080e7          	jalr	-204(ra) # 800005cc <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800066a0:	0009a583          	lw	a1,0(s3)
    800066a4:	35fd                	addiw	a1,a1,-1
    800066a6:	412585bb          	subw	a1,a1,s2
    800066aa:	000a3783          	ld	a5,0(s4)
    800066ae:	9d3e                	add	s10,s10,a5
    800066b0:	00ba95bb          	sllw	a1,s5,a1
    800066b4:	018d3503          	ld	a0,24(s10)
    800066b8:	00000097          	auipc	ra,0x0
    800066bc:	e6c080e7          	jalr	-404(ra) # 80006524 <bd_print_vector>
    800066c0:	b7bd                	j	8000662e <bd_print+0x58>
    }
  }
}
    800066c2:	60e6                	ld	ra,88(sp)
    800066c4:	6446                	ld	s0,80(sp)
    800066c6:	64a6                	ld	s1,72(sp)
    800066c8:	6906                	ld	s2,64(sp)
    800066ca:	79e2                	ld	s3,56(sp)
    800066cc:	7a42                	ld	s4,48(sp)
    800066ce:	7aa2                	ld	s5,40(sp)
    800066d0:	7b02                	ld	s6,32(sp)
    800066d2:	6be2                	ld	s7,24(sp)
    800066d4:	6c42                	ld	s8,16(sp)
    800066d6:	6ca2                	ld	s9,8(sp)
    800066d8:	6d02                	ld	s10,0(sp)
    800066da:	6125                	addi	sp,sp,96
    800066dc:	8082                	ret
    800066de:	8082                	ret

00000000800066e0 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800066e0:	1141                	addi	sp,sp,-16
    800066e2:	e422                	sd	s0,8(sp)
    800066e4:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800066e6:	47c1                	li	a5,16
    800066e8:	00a7fb63          	bgeu	a5,a0,800066fe <firstk+0x1e>
    800066ec:	872a                	mv	a4,a0
  int k = 0;
    800066ee:	4501                	li	a0,0
    k++;
    800066f0:	2505                	addiw	a0,a0,1
    size *= 2;
    800066f2:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800066f4:	fee7eee3          	bltu	a5,a4,800066f0 <firstk+0x10>
  }
  return k;
}
    800066f8:	6422                	ld	s0,8(sp)
    800066fa:	0141                	addi	sp,sp,16
    800066fc:	8082                	ret
  int k = 0;
    800066fe:	4501                	li	a0,0
    80006700:	bfe5                	j	800066f8 <firstk+0x18>

0000000080006702 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006702:	1141                	addi	sp,sp,-16
    80006704:	e422                	sd	s0,8(sp)
    80006706:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006708:	00004797          	auipc	a5,0x4
    8000670c:	8e87b783          	ld	a5,-1816(a5) # 80009ff0 <bd_base>
    80006710:	9d9d                	subw	a1,a1,a5
    80006712:	47c1                	li	a5,16
    80006714:	00a79533          	sll	a0,a5,a0
    80006718:	02a5c533          	div	a0,a1,a0
}
    8000671c:	2501                	sext.w	a0,a0
    8000671e:	6422                	ld	s0,8(sp)
    80006720:	0141                	addi	sp,sp,16
    80006722:	8082                	ret

0000000080006724 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006724:	1141                	addi	sp,sp,-16
    80006726:	e422                	sd	s0,8(sp)
    80006728:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000672a:	47c1                	li	a5,16
    8000672c:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006730:	02b787bb          	mulw	a5,a5,a1
}
    80006734:	00004517          	auipc	a0,0x4
    80006738:	8bc53503          	ld	a0,-1860(a0) # 80009ff0 <bd_base>
    8000673c:	953e                	add	a0,a0,a5
    8000673e:	6422                	ld	s0,8(sp)
    80006740:	0141                	addi	sp,sp,16
    80006742:	8082                	ret

0000000080006744 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006744:	7159                	addi	sp,sp,-112
    80006746:	f486                	sd	ra,104(sp)
    80006748:	f0a2                	sd	s0,96(sp)
    8000674a:	eca6                	sd	s1,88(sp)
    8000674c:	e8ca                	sd	s2,80(sp)
    8000674e:	e4ce                	sd	s3,72(sp)
    80006750:	e0d2                	sd	s4,64(sp)
    80006752:	fc56                	sd	s5,56(sp)
    80006754:	f85a                	sd	s6,48(sp)
    80006756:	f45e                	sd	s7,40(sp)
    80006758:	f062                	sd	s8,32(sp)
    8000675a:	ec66                	sd	s9,24(sp)
    8000675c:	e86a                	sd	s10,16(sp)
    8000675e:	e46e                	sd	s11,8(sp)
    80006760:	1880                	addi	s0,sp,112
    80006762:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006764:	00031517          	auipc	a0,0x31
    80006768:	c3c50513          	addi	a0,a0,-964 # 800373a0 <lock>
    8000676c:	ffffa097          	auipc	ra,0xffffa
    80006770:	430080e7          	jalr	1072(ra) # 80000b9c <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006774:	8526                	mv	a0,s1
    80006776:	00000097          	auipc	ra,0x0
    8000677a:	f6a080e7          	jalr	-150(ra) # 800066e0 <firstk>
  for (k = fk; k < nsizes; k++) {
    8000677e:	00004797          	auipc	a5,0x4
    80006782:	8827a783          	lw	a5,-1918(a5) # 8000a000 <nsizes>
    80006786:	02f55d63          	bge	a0,a5,800067c0 <bd_malloc+0x7c>
    8000678a:	8c2a                	mv	s8,a0
    8000678c:	00551913          	slli	s2,a0,0x5
    80006790:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006792:	00004997          	auipc	s3,0x4
    80006796:	86698993          	addi	s3,s3,-1946 # 80009ff8 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000679a:	00004a17          	auipc	s4,0x4
    8000679e:	866a0a13          	addi	s4,s4,-1946 # 8000a000 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800067a2:	0009b503          	ld	a0,0(s3)
    800067a6:	954a                	add	a0,a0,s2
    800067a8:	00001097          	auipc	ra,0x1
    800067ac:	88e080e7          	jalr	-1906(ra) # 80007036 <lst_empty>
    800067b0:	c115                	beqz	a0,800067d4 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800067b2:	2485                	addiw	s1,s1,1
    800067b4:	02090913          	addi	s2,s2,32
    800067b8:	000a2783          	lw	a5,0(s4)
    800067bc:	fef4c3e3          	blt	s1,a5,800067a2 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    800067c0:	00031517          	auipc	a0,0x31
    800067c4:	be050513          	addi	a0,a0,-1056 # 800373a0 <lock>
    800067c8:	ffffa097          	auipc	ra,0xffffa
    800067cc:	4a4080e7          	jalr	1188(ra) # 80000c6c <release>
    return 0;
    800067d0:	4b01                	li	s6,0
    800067d2:	a0e1                	j	8000689a <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800067d4:	00004797          	auipc	a5,0x4
    800067d8:	82c7a783          	lw	a5,-2004(a5) # 8000a000 <nsizes>
    800067dc:	fef4d2e3          	bge	s1,a5,800067c0 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800067e0:	00549993          	slli	s3,s1,0x5
    800067e4:	00004917          	auipc	s2,0x4
    800067e8:	81490913          	addi	s2,s2,-2028 # 80009ff8 <bd_sizes>
    800067ec:	00093503          	ld	a0,0(s2)
    800067f0:	954e                	add	a0,a0,s3
    800067f2:	00001097          	auipc	ra,0x1
    800067f6:	870080e7          	jalr	-1936(ra) # 80007062 <lst_pop>
    800067fa:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800067fc:	00003597          	auipc	a1,0x3
    80006800:	7f45b583          	ld	a1,2036(a1) # 80009ff0 <bd_base>
    80006804:	40b505bb          	subw	a1,a0,a1
    80006808:	47c1                	li	a5,16
    8000680a:	009797b3          	sll	a5,a5,s1
    8000680e:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006812:	00093783          	ld	a5,0(s2)
    80006816:	97ce                	add	a5,a5,s3
    80006818:	2581                	sext.w	a1,a1
    8000681a:	6b88                	ld	a0,16(a5)
    8000681c:	00000097          	auipc	ra,0x0
    80006820:	ca4080e7          	jalr	-860(ra) # 800064c0 <bit_set>
  for(; k > fk; k--) {
    80006824:	069c5363          	bge	s8,s1,8000688a <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006828:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000682a:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    8000682c:	00003d17          	auipc	s10,0x3
    80006830:	7c4d0d13          	addi	s10,s10,1988 # 80009ff0 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006834:	85a6                	mv	a1,s1
    80006836:	34fd                	addiw	s1,s1,-1
    80006838:	009b9ab3          	sll	s5,s7,s1
    8000683c:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006840:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006844:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006848:	412b093b          	subw	s2,s6,s2
    8000684c:	00bb95b3          	sll	a1,s7,a1
    80006850:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006854:	013a07b3          	add	a5,s4,s3
    80006858:	2581                	sext.w	a1,a1
    8000685a:	6f88                	ld	a0,24(a5)
    8000685c:	00000097          	auipc	ra,0x0
    80006860:	c64080e7          	jalr	-924(ra) # 800064c0 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006864:	1981                	addi	s3,s3,-32
    80006866:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006868:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000686c:	2581                	sext.w	a1,a1
    8000686e:	010a3503          	ld	a0,16(s4)
    80006872:	00000097          	auipc	ra,0x0
    80006876:	c4e080e7          	jalr	-946(ra) # 800064c0 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000687a:	85e6                	mv	a1,s9
    8000687c:	8552                	mv	a0,s4
    8000687e:	00001097          	auipc	ra,0x1
    80006882:	81a080e7          	jalr	-2022(ra) # 80007098 <lst_push>
  for(; k > fk; k--) {
    80006886:	fb8497e3          	bne	s1,s8,80006834 <bd_malloc+0xf0>
  }
  release(&lock);
    8000688a:	00031517          	auipc	a0,0x31
    8000688e:	b1650513          	addi	a0,a0,-1258 # 800373a0 <lock>
    80006892:	ffffa097          	auipc	ra,0xffffa
    80006896:	3da080e7          	jalr	986(ra) # 80000c6c <release>

  return p;
}
    8000689a:	855a                	mv	a0,s6
    8000689c:	70a6                	ld	ra,104(sp)
    8000689e:	7406                	ld	s0,96(sp)
    800068a0:	64e6                	ld	s1,88(sp)
    800068a2:	6946                	ld	s2,80(sp)
    800068a4:	69a6                	ld	s3,72(sp)
    800068a6:	6a06                	ld	s4,64(sp)
    800068a8:	7ae2                	ld	s5,56(sp)
    800068aa:	7b42                	ld	s6,48(sp)
    800068ac:	7ba2                	ld	s7,40(sp)
    800068ae:	7c02                	ld	s8,32(sp)
    800068b0:	6ce2                	ld	s9,24(sp)
    800068b2:	6d42                	ld	s10,16(sp)
    800068b4:	6da2                	ld	s11,8(sp)
    800068b6:	6165                	addi	sp,sp,112
    800068b8:	8082                	ret

00000000800068ba <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    800068ba:	7139                	addi	sp,sp,-64
    800068bc:	fc06                	sd	ra,56(sp)
    800068be:	f822                	sd	s0,48(sp)
    800068c0:	f426                	sd	s1,40(sp)
    800068c2:	f04a                	sd	s2,32(sp)
    800068c4:	ec4e                	sd	s3,24(sp)
    800068c6:	e852                	sd	s4,16(sp)
    800068c8:	e456                	sd	s5,8(sp)
    800068ca:	e05a                	sd	s6,0(sp)
    800068cc:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    800068ce:	00003a97          	auipc	s5,0x3
    800068d2:	732aaa83          	lw	s5,1842(s5) # 8000a000 <nsizes>
  return n / BLK_SIZE(k);
    800068d6:	00003a17          	auipc	s4,0x3
    800068da:	71aa3a03          	ld	s4,1818(s4) # 80009ff0 <bd_base>
    800068de:	41450a3b          	subw	s4,a0,s4
    800068e2:	00003497          	auipc	s1,0x3
    800068e6:	7164b483          	ld	s1,1814(s1) # 80009ff8 <bd_sizes>
    800068ea:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    800068ee:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    800068f0:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    800068f2:	03595363          	bge	s2,s5,80006918 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800068f6:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800068fa:	013b15b3          	sll	a1,s6,s3
    800068fe:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006902:	2581                	sext.w	a1,a1
    80006904:	6088                	ld	a0,0(s1)
    80006906:	00000097          	auipc	ra,0x0
    8000690a:	b82080e7          	jalr	-1150(ra) # 80006488 <bit_isset>
    8000690e:	02048493          	addi	s1,s1,32
    80006912:	e501                	bnez	a0,8000691a <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006914:	894e                	mv	s2,s3
    80006916:	bff1                	j	800068f2 <size+0x38>
      return k;
    }
  }
  return 0;
    80006918:	4901                	li	s2,0
}
    8000691a:	854a                	mv	a0,s2
    8000691c:	70e2                	ld	ra,56(sp)
    8000691e:	7442                	ld	s0,48(sp)
    80006920:	74a2                	ld	s1,40(sp)
    80006922:	7902                	ld	s2,32(sp)
    80006924:	69e2                	ld	s3,24(sp)
    80006926:	6a42                	ld	s4,16(sp)
    80006928:	6aa2                	ld	s5,8(sp)
    8000692a:	6b02                	ld	s6,0(sp)
    8000692c:	6121                	addi	sp,sp,64
    8000692e:	8082                	ret

0000000080006930 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006930:	7159                	addi	sp,sp,-112
    80006932:	f486                	sd	ra,104(sp)
    80006934:	f0a2                	sd	s0,96(sp)
    80006936:	eca6                	sd	s1,88(sp)
    80006938:	e8ca                	sd	s2,80(sp)
    8000693a:	e4ce                	sd	s3,72(sp)
    8000693c:	e0d2                	sd	s4,64(sp)
    8000693e:	fc56                	sd	s5,56(sp)
    80006940:	f85a                	sd	s6,48(sp)
    80006942:	f45e                	sd	s7,40(sp)
    80006944:	f062                	sd	s8,32(sp)
    80006946:	ec66                	sd	s9,24(sp)
    80006948:	e86a                	sd	s10,16(sp)
    8000694a:	e46e                	sd	s11,8(sp)
    8000694c:	1880                	addi	s0,sp,112
    8000694e:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006950:	00031517          	auipc	a0,0x31
    80006954:	a5050513          	addi	a0,a0,-1456 # 800373a0 <lock>
    80006958:	ffffa097          	auipc	ra,0xffffa
    8000695c:	244080e7          	jalr	580(ra) # 80000b9c <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006960:	8556                	mv	a0,s5
    80006962:	00000097          	auipc	ra,0x0
    80006966:	f58080e7          	jalr	-168(ra) # 800068ba <size>
    8000696a:	84aa                	mv	s1,a0
    8000696c:	00003797          	auipc	a5,0x3
    80006970:	6947a783          	lw	a5,1684(a5) # 8000a000 <nsizes>
    80006974:	37fd                	addiw	a5,a5,-1
    80006976:	0af55d63          	bge	a0,a5,80006a30 <bd_free+0x100>
    8000697a:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    8000697e:	00003c17          	auipc	s8,0x3
    80006982:	672c0c13          	addi	s8,s8,1650 # 80009ff0 <bd_base>
  return n / BLK_SIZE(k);
    80006986:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006988:	00003b17          	auipc	s6,0x3
    8000698c:	670b0b13          	addi	s6,s6,1648 # 80009ff8 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006990:	00003c97          	auipc	s9,0x3
    80006994:	670c8c93          	addi	s9,s9,1648 # 8000a000 <nsizes>
    80006998:	a82d                	j	800069d2 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000699a:	fff58d9b          	addiw	s11,a1,-1
    8000699e:	a881                	j	800069ee <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069a0:	020a0a13          	addi	s4,s4,32
    800069a4:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    800069a6:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    800069aa:	40ba85bb          	subw	a1,s5,a1
    800069ae:	009b97b3          	sll	a5,s7,s1
    800069b2:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069b6:	000b3783          	ld	a5,0(s6)
    800069ba:	97d2                	add	a5,a5,s4
    800069bc:	2581                	sext.w	a1,a1
    800069be:	6f88                	ld	a0,24(a5)
    800069c0:	00000097          	auipc	ra,0x0
    800069c4:	b30080e7          	jalr	-1232(ra) # 800064f0 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    800069c8:	000ca783          	lw	a5,0(s9)
    800069cc:	37fd                	addiw	a5,a5,-1
    800069ce:	06f4d163          	bge	s1,a5,80006a30 <bd_free+0x100>
  int n = p - (char *) bd_base;
    800069d2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    800069d6:	009b99b3          	sll	s3,s7,s1
    800069da:	412a87bb          	subw	a5,s5,s2
    800069de:	0337c7b3          	div	a5,a5,s3
    800069e2:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800069e6:	8b85                	andi	a5,a5,1
    800069e8:	fbcd                	bnez	a5,8000699a <bd_free+0x6a>
    800069ea:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800069ee:	000b3d03          	ld	s10,0(s6)
    800069f2:	9d52                	add	s10,s10,s4
    800069f4:	010d3503          	ld	a0,16(s10)
    800069f8:	00000097          	auipc	ra,0x0
    800069fc:	af8080e7          	jalr	-1288(ra) # 800064f0 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006a00:	85ee                	mv	a1,s11
    80006a02:	010d3503          	ld	a0,16(s10)
    80006a06:	00000097          	auipc	ra,0x0
    80006a0a:	a82080e7          	jalr	-1406(ra) # 80006488 <bit_isset>
    80006a0e:	e10d                	bnez	a0,80006a30 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80006a10:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006a14:	03b989bb          	mulw	s3,s3,s11
    80006a18:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006a1a:	854a                	mv	a0,s2
    80006a1c:	00000097          	auipc	ra,0x0
    80006a20:	630080e7          	jalr	1584(ra) # 8000704c <lst_remove>
    if(buddy % 2 == 0) {
    80006a24:	001d7d13          	andi	s10,s10,1
    80006a28:	f60d1ce3          	bnez	s10,800069a0 <bd_free+0x70>
      p = q;
    80006a2c:	8aca                	mv	s5,s2
    80006a2e:	bf8d                	j	800069a0 <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    80006a30:	0496                	slli	s1,s1,0x5
    80006a32:	85d6                	mv	a1,s5
    80006a34:	00003517          	auipc	a0,0x3
    80006a38:	5c453503          	ld	a0,1476(a0) # 80009ff8 <bd_sizes>
    80006a3c:	9526                	add	a0,a0,s1
    80006a3e:	00000097          	auipc	ra,0x0
    80006a42:	65a080e7          	jalr	1626(ra) # 80007098 <lst_push>
  release(&lock);
    80006a46:	00031517          	auipc	a0,0x31
    80006a4a:	95a50513          	addi	a0,a0,-1702 # 800373a0 <lock>
    80006a4e:	ffffa097          	auipc	ra,0xffffa
    80006a52:	21e080e7          	jalr	542(ra) # 80000c6c <release>
}
    80006a56:	70a6                	ld	ra,104(sp)
    80006a58:	7406                	ld	s0,96(sp)
    80006a5a:	64e6                	ld	s1,88(sp)
    80006a5c:	6946                	ld	s2,80(sp)
    80006a5e:	69a6                	ld	s3,72(sp)
    80006a60:	6a06                	ld	s4,64(sp)
    80006a62:	7ae2                	ld	s5,56(sp)
    80006a64:	7b42                	ld	s6,48(sp)
    80006a66:	7ba2                	ld	s7,40(sp)
    80006a68:	7c02                	ld	s8,32(sp)
    80006a6a:	6ce2                	ld	s9,24(sp)
    80006a6c:	6d42                	ld	s10,16(sp)
    80006a6e:	6da2                	ld	s11,8(sp)
    80006a70:	6165                	addi	sp,sp,112
    80006a72:	8082                	ret

0000000080006a74 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006a74:	1141                	addi	sp,sp,-16
    80006a76:	e422                	sd	s0,8(sp)
    80006a78:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006a7a:	00003797          	auipc	a5,0x3
    80006a7e:	5767b783          	ld	a5,1398(a5) # 80009ff0 <bd_base>
    80006a82:	8d9d                	sub	a1,a1,a5
    80006a84:	47c1                	li	a5,16
    80006a86:	00a797b3          	sll	a5,a5,a0
    80006a8a:	02f5c533          	div	a0,a1,a5
    80006a8e:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006a90:	02f5e5b3          	rem	a1,a1,a5
    80006a94:	c191                	beqz	a1,80006a98 <blk_index_next+0x24>
      n++;
    80006a96:	2505                	addiw	a0,a0,1
  return n ;
}
    80006a98:	6422                	ld	s0,8(sp)
    80006a9a:	0141                	addi	sp,sp,16
    80006a9c:	8082                	ret

0000000080006a9e <log2>:

int
log2(uint64 n) {
    80006a9e:	1141                	addi	sp,sp,-16
    80006aa0:	e422                	sd	s0,8(sp)
    80006aa2:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006aa4:	4705                	li	a4,1
    80006aa6:	00a77b63          	bgeu	a4,a0,80006abc <log2+0x1e>
    80006aaa:	87aa                	mv	a5,a0
  int k = 0;
    80006aac:	4501                	li	a0,0
    k++;
    80006aae:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006ab0:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006ab2:	fef76ee3          	bltu	a4,a5,80006aae <log2+0x10>
  }
  return k;
}
    80006ab6:	6422                	ld	s0,8(sp)
    80006ab8:	0141                	addi	sp,sp,16
    80006aba:	8082                	ret
  int k = 0;
    80006abc:	4501                	li	a0,0
    80006abe:	bfe5                	j	80006ab6 <log2+0x18>

0000000080006ac0 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006ac0:	711d                	addi	sp,sp,-96
    80006ac2:	ec86                	sd	ra,88(sp)
    80006ac4:	e8a2                	sd	s0,80(sp)
    80006ac6:	e4a6                	sd	s1,72(sp)
    80006ac8:	e0ca                	sd	s2,64(sp)
    80006aca:	fc4e                	sd	s3,56(sp)
    80006acc:	f852                	sd	s4,48(sp)
    80006ace:	f456                	sd	s5,40(sp)
    80006ad0:	f05a                	sd	s6,32(sp)
    80006ad2:	ec5e                	sd	s7,24(sp)
    80006ad4:	e862                	sd	s8,16(sp)
    80006ad6:	e466                	sd	s9,8(sp)
    80006ad8:	e06a                	sd	s10,0(sp)
    80006ada:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006adc:	00b56933          	or	s2,a0,a1
    80006ae0:	00f97913          	andi	s2,s2,15
    80006ae4:	04091263          	bnez	s2,80006b28 <bd_mark+0x68>
    80006ae8:	8b2a                	mv	s6,a0
    80006aea:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006aec:	00003c17          	auipc	s8,0x3
    80006af0:	514c2c03          	lw	s8,1300(s8) # 8000a000 <nsizes>
    80006af4:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006af6:	00003d17          	auipc	s10,0x3
    80006afa:	4fad0d13          	addi	s10,s10,1274 # 80009ff0 <bd_base>
  return n / BLK_SIZE(k);
    80006afe:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006b00:	00003a97          	auipc	s5,0x3
    80006b04:	4f8a8a93          	addi	s5,s5,1272 # 80009ff8 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006b08:	07804563          	bgtz	s8,80006b72 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006b0c:	60e6                	ld	ra,88(sp)
    80006b0e:	6446                	ld	s0,80(sp)
    80006b10:	64a6                	ld	s1,72(sp)
    80006b12:	6906                	ld	s2,64(sp)
    80006b14:	79e2                	ld	s3,56(sp)
    80006b16:	7a42                	ld	s4,48(sp)
    80006b18:	7aa2                	ld	s5,40(sp)
    80006b1a:	7b02                	ld	s6,32(sp)
    80006b1c:	6be2                	ld	s7,24(sp)
    80006b1e:	6c42                	ld	s8,16(sp)
    80006b20:	6ca2                	ld	s9,8(sp)
    80006b22:	6d02                	ld	s10,0(sp)
    80006b24:	6125                	addi	sp,sp,96
    80006b26:	8082                	ret
    panic("bd_mark");
    80006b28:	00003517          	auipc	a0,0x3
    80006b2c:	34050513          	addi	a0,a0,832 # 80009e68 <syscalls+0x498>
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	a3a080e7          	jalr	-1478(ra) # 8000056a <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006b38:	000ab783          	ld	a5,0(s5)
    80006b3c:	97ca                	add	a5,a5,s2
    80006b3e:	85a6                	mv	a1,s1
    80006b40:	6b88                	ld	a0,16(a5)
    80006b42:	00000097          	auipc	ra,0x0
    80006b46:	97e080e7          	jalr	-1666(ra) # 800064c0 <bit_set>
    for(; bi < bj; bi++) {
    80006b4a:	2485                	addiw	s1,s1,1
    80006b4c:	009a0e63          	beq	s4,s1,80006b68 <bd_mark+0xa8>
      if(k > 0) {
    80006b50:	ff3054e3          	blez	s3,80006b38 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006b54:	000ab783          	ld	a5,0(s5)
    80006b58:	97ca                	add	a5,a5,s2
    80006b5a:	85a6                	mv	a1,s1
    80006b5c:	6f88                	ld	a0,24(a5)
    80006b5e:	00000097          	auipc	ra,0x0
    80006b62:	962080e7          	jalr	-1694(ra) # 800064c0 <bit_set>
    80006b66:	bfc9                	j	80006b38 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006b68:	2985                	addiw	s3,s3,1
    80006b6a:	02090913          	addi	s2,s2,32
    80006b6e:	f9898fe3          	beq	s3,s8,80006b0c <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006b72:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006b76:	409b04bb          	subw	s1,s6,s1
    80006b7a:	013c97b3          	sll	a5,s9,s3
    80006b7e:	02f4c4b3          	div	s1,s1,a5
    80006b82:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006b84:	85de                	mv	a1,s7
    80006b86:	854e                	mv	a0,s3
    80006b88:	00000097          	auipc	ra,0x0
    80006b8c:	eec080e7          	jalr	-276(ra) # 80006a74 <blk_index_next>
    80006b90:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006b92:	faa4cfe3          	blt	s1,a0,80006b50 <bd_mark+0x90>
    80006b96:	bfc9                	j	80006b68 <bd_mark+0xa8>

0000000080006b98 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006b98:	7139                	addi	sp,sp,-64
    80006b9a:	fc06                	sd	ra,56(sp)
    80006b9c:	f822                	sd	s0,48(sp)
    80006b9e:	f426                	sd	s1,40(sp)
    80006ba0:	f04a                	sd	s2,32(sp)
    80006ba2:	ec4e                	sd	s3,24(sp)
    80006ba4:	e852                	sd	s4,16(sp)
    80006ba6:	e456                	sd	s5,8(sp)
    80006ba8:	e05a                	sd	s6,0(sp)
    80006baa:	0080                	addi	s0,sp,64
    80006bac:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bae:	00058a9b          	sext.w	s5,a1
    80006bb2:	0015f793          	andi	a5,a1,1
    80006bb6:	ebad                	bnez	a5,80006c28 <bd_initfree_pair+0x90>
    80006bb8:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006bbc:	00599493          	slli	s1,s3,0x5
    80006bc0:	00003797          	auipc	a5,0x3
    80006bc4:	4387b783          	ld	a5,1080(a5) # 80009ff8 <bd_sizes>
    80006bc8:	94be                	add	s1,s1,a5
    80006bca:	0104bb03          	ld	s6,16(s1)
    80006bce:	855a                	mv	a0,s6
    80006bd0:	00000097          	auipc	ra,0x0
    80006bd4:	8b8080e7          	jalr	-1864(ra) # 80006488 <bit_isset>
    80006bd8:	892a                	mv	s2,a0
    80006bda:	85d2                	mv	a1,s4
    80006bdc:	855a                	mv	a0,s6
    80006bde:	00000097          	auipc	ra,0x0
    80006be2:	8aa080e7          	jalr	-1878(ra) # 80006488 <bit_isset>
  int free = 0;
    80006be6:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006be8:	02a90563          	beq	s2,a0,80006c12 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006bec:	45c1                	li	a1,16
    80006bee:	013599b3          	sll	s3,a1,s3
    80006bf2:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006bf6:	02090c63          	beqz	s2,80006c2e <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006bfa:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006bfe:	00003597          	auipc	a1,0x3
    80006c02:	3f25b583          	ld	a1,1010(a1) # 80009ff0 <bd_base>
    80006c06:	95ce                	add	a1,a1,s3
    80006c08:	8526                	mv	a0,s1
    80006c0a:	00000097          	auipc	ra,0x0
    80006c0e:	48e080e7          	jalr	1166(ra) # 80007098 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006c12:	855a                	mv	a0,s6
    80006c14:	70e2                	ld	ra,56(sp)
    80006c16:	7442                	ld	s0,48(sp)
    80006c18:	74a2                	ld	s1,40(sp)
    80006c1a:	7902                	ld	s2,32(sp)
    80006c1c:	69e2                	ld	s3,24(sp)
    80006c1e:	6a42                	ld	s4,16(sp)
    80006c20:	6aa2                	ld	s5,8(sp)
    80006c22:	6b02                	ld	s6,0(sp)
    80006c24:	6121                	addi	sp,sp,64
    80006c26:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c28:	fff58a1b          	addiw	s4,a1,-1
    80006c2c:	bf41                	j	80006bbc <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006c2e:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006c32:	00003597          	auipc	a1,0x3
    80006c36:	3be5b583          	ld	a1,958(a1) # 80009ff0 <bd_base>
    80006c3a:	95ce                	add	a1,a1,s3
    80006c3c:	8526                	mv	a0,s1
    80006c3e:	00000097          	auipc	ra,0x0
    80006c42:	45a080e7          	jalr	1114(ra) # 80007098 <lst_push>
    80006c46:	b7f1                	j	80006c12 <bd_initfree_pair+0x7a>

0000000080006c48 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006c48:	711d                	addi	sp,sp,-96
    80006c4a:	ec86                	sd	ra,88(sp)
    80006c4c:	e8a2                	sd	s0,80(sp)
    80006c4e:	e4a6                	sd	s1,72(sp)
    80006c50:	e0ca                	sd	s2,64(sp)
    80006c52:	fc4e                	sd	s3,56(sp)
    80006c54:	f852                	sd	s4,48(sp)
    80006c56:	f456                	sd	s5,40(sp)
    80006c58:	f05a                	sd	s6,32(sp)
    80006c5a:	ec5e                	sd	s7,24(sp)
    80006c5c:	e862                	sd	s8,16(sp)
    80006c5e:	e466                	sd	s9,8(sp)
    80006c60:	e06a                	sd	s10,0(sp)
    80006c62:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006c64:	00003717          	auipc	a4,0x3
    80006c68:	39c72703          	lw	a4,924(a4) # 8000a000 <nsizes>
    80006c6c:	4785                	li	a5,1
    80006c6e:	06e7db63          	bge	a5,a4,80006ce4 <bd_initfree+0x9c>
    80006c72:	8aaa                	mv	s5,a0
    80006c74:	8b2e                	mv	s6,a1
    80006c76:	4901                	li	s2,0
  int free = 0;
    80006c78:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006c7a:	00003c97          	auipc	s9,0x3
    80006c7e:	376c8c93          	addi	s9,s9,886 # 80009ff0 <bd_base>
  return n / BLK_SIZE(k);
    80006c82:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006c84:	00003b97          	auipc	s7,0x3
    80006c88:	37cb8b93          	addi	s7,s7,892 # 8000a000 <nsizes>
    80006c8c:	a039                	j	80006c9a <bd_initfree+0x52>
    80006c8e:	2905                	addiw	s2,s2,1
    80006c90:	000ba783          	lw	a5,0(s7)
    80006c94:	37fd                	addiw	a5,a5,-1
    80006c96:	04f95863          	bge	s2,a5,80006ce6 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006c9a:	85d6                	mv	a1,s5
    80006c9c:	854a                	mv	a0,s2
    80006c9e:	00000097          	auipc	ra,0x0
    80006ca2:	dd6080e7          	jalr	-554(ra) # 80006a74 <blk_index_next>
    80006ca6:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006ca8:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006cac:	409b04bb          	subw	s1,s6,s1
    80006cb0:	012c17b3          	sll	a5,s8,s2
    80006cb4:	02f4c4b3          	div	s1,s1,a5
    80006cb8:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006cba:	85aa                	mv	a1,a0
    80006cbc:	854a                	mv	a0,s2
    80006cbe:	00000097          	auipc	ra,0x0
    80006cc2:	eda080e7          	jalr	-294(ra) # 80006b98 <bd_initfree_pair>
    80006cc6:	01450d3b          	addw	s10,a0,s4
    80006cca:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006cce:	fc99d0e3          	bge	s3,s1,80006c8e <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006cd2:	85a6                	mv	a1,s1
    80006cd4:	854a                	mv	a0,s2
    80006cd6:	00000097          	auipc	ra,0x0
    80006cda:	ec2080e7          	jalr	-318(ra) # 80006b98 <bd_initfree_pair>
    80006cde:	00ad0a3b          	addw	s4,s10,a0
    80006ce2:	b775                	j	80006c8e <bd_initfree+0x46>
  int free = 0;
    80006ce4:	4a01                	li	s4,0
  }
  return free;
}
    80006ce6:	8552                	mv	a0,s4
    80006ce8:	60e6                	ld	ra,88(sp)
    80006cea:	6446                	ld	s0,80(sp)
    80006cec:	64a6                	ld	s1,72(sp)
    80006cee:	6906                	ld	s2,64(sp)
    80006cf0:	79e2                	ld	s3,56(sp)
    80006cf2:	7a42                	ld	s4,48(sp)
    80006cf4:	7aa2                	ld	s5,40(sp)
    80006cf6:	7b02                	ld	s6,32(sp)
    80006cf8:	6be2                	ld	s7,24(sp)
    80006cfa:	6c42                	ld	s8,16(sp)
    80006cfc:	6ca2                	ld	s9,8(sp)
    80006cfe:	6d02                	ld	s10,0(sp)
    80006d00:	6125                	addi	sp,sp,96
    80006d02:	8082                	ret

0000000080006d04 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006d04:	7179                	addi	sp,sp,-48
    80006d06:	f406                	sd	ra,40(sp)
    80006d08:	f022                	sd	s0,32(sp)
    80006d0a:	ec26                	sd	s1,24(sp)
    80006d0c:	e84a                	sd	s2,16(sp)
    80006d0e:	e44e                	sd	s3,8(sp)
    80006d10:	1800                	addi	s0,sp,48
    80006d12:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006d14:	00003997          	auipc	s3,0x3
    80006d18:	2dc98993          	addi	s3,s3,732 # 80009ff0 <bd_base>
    80006d1c:	0009b483          	ld	s1,0(s3)
    80006d20:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006d24:	00003797          	auipc	a5,0x3
    80006d28:	2dc7a783          	lw	a5,732(a5) # 8000a000 <nsizes>
    80006d2c:	37fd                	addiw	a5,a5,-1
    80006d2e:	4641                	li	a2,16
    80006d30:	00f61633          	sll	a2,a2,a5
    80006d34:	85a6                	mv	a1,s1
    80006d36:	00003517          	auipc	a0,0x3
    80006d3a:	13a50513          	addi	a0,a0,314 # 80009e70 <syscalls+0x4a0>
    80006d3e:	ffffa097          	auipc	ra,0xffffa
    80006d42:	88e080e7          	jalr	-1906(ra) # 800005cc <printf>
  bd_mark(bd_base, p);
    80006d46:	85ca                	mv	a1,s2
    80006d48:	0009b503          	ld	a0,0(s3)
    80006d4c:	00000097          	auipc	ra,0x0
    80006d50:	d74080e7          	jalr	-652(ra) # 80006ac0 <bd_mark>
  return meta;
}
    80006d54:	8526                	mv	a0,s1
    80006d56:	70a2                	ld	ra,40(sp)
    80006d58:	7402                	ld	s0,32(sp)
    80006d5a:	64e2                	ld	s1,24(sp)
    80006d5c:	6942                	ld	s2,16(sp)
    80006d5e:	69a2                	ld	s3,8(sp)
    80006d60:	6145                	addi	sp,sp,48
    80006d62:	8082                	ret

0000000080006d64 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006d64:	1101                	addi	sp,sp,-32
    80006d66:	ec06                	sd	ra,24(sp)
    80006d68:	e822                	sd	s0,16(sp)
    80006d6a:	e426                	sd	s1,8(sp)
    80006d6c:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006d6e:	00003497          	auipc	s1,0x3
    80006d72:	2924a483          	lw	s1,658(s1) # 8000a000 <nsizes>
    80006d76:	fff4879b          	addiw	a5,s1,-1
    80006d7a:	44c1                	li	s1,16
    80006d7c:	00f494b3          	sll	s1,s1,a5
    80006d80:	00003797          	auipc	a5,0x3
    80006d84:	2707b783          	ld	a5,624(a5) # 80009ff0 <bd_base>
    80006d88:	8d1d                	sub	a0,a0,a5
    80006d8a:	40a4853b          	subw	a0,s1,a0
    80006d8e:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006d92:	00905a63          	blez	s1,80006da6 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006d96:	357d                	addiw	a0,a0,-1
    80006d98:	41f5549b          	sraiw	s1,a0,0x1f
    80006d9c:	01c4d49b          	srliw	s1,s1,0x1c
    80006da0:	9ca9                	addw	s1,s1,a0
    80006da2:	98c1                	andi	s1,s1,-16
    80006da4:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006da6:	85a6                	mv	a1,s1
    80006da8:	00003517          	auipc	a0,0x3
    80006dac:	10050513          	addi	a0,a0,256 # 80009ea8 <syscalls+0x4d8>
    80006db0:	ffffa097          	auipc	ra,0xffffa
    80006db4:	81c080e7          	jalr	-2020(ra) # 800005cc <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006db8:	00003717          	auipc	a4,0x3
    80006dbc:	23873703          	ld	a4,568(a4) # 80009ff0 <bd_base>
    80006dc0:	00003597          	auipc	a1,0x3
    80006dc4:	2405a583          	lw	a1,576(a1) # 8000a000 <nsizes>
    80006dc8:	fff5879b          	addiw	a5,a1,-1
    80006dcc:	45c1                	li	a1,16
    80006dce:	00f595b3          	sll	a1,a1,a5
    80006dd2:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006dd6:	95ba                	add	a1,a1,a4
    80006dd8:	953a                	add	a0,a0,a4
    80006dda:	00000097          	auipc	ra,0x0
    80006dde:	ce6080e7          	jalr	-794(ra) # 80006ac0 <bd_mark>
  return unavailable;
}
    80006de2:	8526                	mv	a0,s1
    80006de4:	60e2                	ld	ra,24(sp)
    80006de6:	6442                	ld	s0,16(sp)
    80006de8:	64a2                	ld	s1,8(sp)
    80006dea:	6105                	addi	sp,sp,32
    80006dec:	8082                	ret

0000000080006dee <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006dee:	715d                	addi	sp,sp,-80
    80006df0:	e486                	sd	ra,72(sp)
    80006df2:	e0a2                	sd	s0,64(sp)
    80006df4:	fc26                	sd	s1,56(sp)
    80006df6:	f84a                	sd	s2,48(sp)
    80006df8:	f44e                	sd	s3,40(sp)
    80006dfa:	f052                	sd	s4,32(sp)
    80006dfc:	ec56                	sd	s5,24(sp)
    80006dfe:	e85a                	sd	s6,16(sp)
    80006e00:	e45e                	sd	s7,8(sp)
    80006e02:	e062                	sd	s8,0(sp)
    80006e04:	0880                	addi	s0,sp,80
    80006e06:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006e08:	fff50493          	addi	s1,a0,-1
    80006e0c:	98c1                	andi	s1,s1,-16
    80006e0e:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006e10:	00003597          	auipc	a1,0x3
    80006e14:	0b858593          	addi	a1,a1,184 # 80009ec8 <syscalls+0x4f8>
    80006e18:	00030517          	auipc	a0,0x30
    80006e1c:	58850513          	addi	a0,a0,1416 # 800373a0 <lock>
    80006e20:	ffffa097          	auipc	ra,0xffffa
    80006e24:	ca6080e7          	jalr	-858(ra) # 80000ac6 <initlock>
  bd_base = (void *) p;
    80006e28:	00003797          	auipc	a5,0x3
    80006e2c:	1c97b423          	sd	s1,456(a5) # 80009ff0 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e30:	409c0933          	sub	s2,s8,s1
    80006e34:	43f95513          	srai	a0,s2,0x3f
    80006e38:	893d                	andi	a0,a0,15
    80006e3a:	954a                	add	a0,a0,s2
    80006e3c:	8511                	srai	a0,a0,0x4
    80006e3e:	00000097          	auipc	ra,0x0
    80006e42:	c60080e7          	jalr	-928(ra) # 80006a9e <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006e46:	47c1                	li	a5,16
    80006e48:	00a797b3          	sll	a5,a5,a0
    80006e4c:	1b27c663          	blt	a5,s2,80006ff8 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e50:	2505                	addiw	a0,a0,1
    80006e52:	00003797          	auipc	a5,0x3
    80006e56:	1aa7a723          	sw	a0,430(a5) # 8000a000 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006e5a:	00003997          	auipc	s3,0x3
    80006e5e:	1a698993          	addi	s3,s3,422 # 8000a000 <nsizes>
    80006e62:	0009a603          	lw	a2,0(s3)
    80006e66:	85ca                	mv	a1,s2
    80006e68:	00003517          	auipc	a0,0x3
    80006e6c:	06850513          	addi	a0,a0,104 # 80009ed0 <syscalls+0x500>
    80006e70:	ffff9097          	auipc	ra,0xffff9
    80006e74:	75c080e7          	jalr	1884(ra) # 800005cc <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006e78:	00003797          	auipc	a5,0x3
    80006e7c:	1897b023          	sd	s1,384(a5) # 80009ff8 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006e80:	0009a603          	lw	a2,0(s3)
    80006e84:	00561913          	slli	s2,a2,0x5
    80006e88:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006e8a:	0056161b          	slliw	a2,a2,0x5
    80006e8e:	4581                	li	a1,0
    80006e90:	8526                	mv	a0,s1
    80006e92:	ffffa097          	auipc	ra,0xffffa
    80006e96:	fee080e7          	jalr	-18(ra) # 80000e80 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006e9a:	0009a783          	lw	a5,0(s3)
    80006e9e:	06f05a63          	blez	a5,80006f12 <bd_init+0x124>
    80006ea2:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006ea4:	00003a97          	auipc	s5,0x3
    80006ea8:	154a8a93          	addi	s5,s5,340 # 80009ff8 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006eac:	00003a17          	auipc	s4,0x3
    80006eb0:	154a0a13          	addi	s4,s4,340 # 8000a000 <nsizes>
    80006eb4:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006eb6:	00599b93          	slli	s7,s3,0x5
    80006eba:	000ab503          	ld	a0,0(s5)
    80006ebe:	955e                	add	a0,a0,s7
    80006ec0:	00000097          	auipc	ra,0x0
    80006ec4:	166080e7          	jalr	358(ra) # 80007026 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006ec8:	000a2483          	lw	s1,0(s4)
    80006ecc:	34fd                	addiw	s1,s1,-1
    80006ece:	413484bb          	subw	s1,s1,s3
    80006ed2:	009b14bb          	sllw	s1,s6,s1
    80006ed6:	fff4879b          	addiw	a5,s1,-1
    80006eda:	41f7d49b          	sraiw	s1,a5,0x1f
    80006ede:	01d4d49b          	srliw	s1,s1,0x1d
    80006ee2:	9cbd                	addw	s1,s1,a5
    80006ee4:	98e1                	andi	s1,s1,-8
    80006ee6:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006ee8:	000ab783          	ld	a5,0(s5)
    80006eec:	9bbe                	add	s7,s7,a5
    80006eee:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006ef2:	848d                	srai	s1,s1,0x3
    80006ef4:	8626                	mv	a2,s1
    80006ef6:	4581                	li	a1,0
    80006ef8:	854a                	mv	a0,s2
    80006efa:	ffffa097          	auipc	ra,0xffffa
    80006efe:	f86080e7          	jalr	-122(ra) # 80000e80 <memset>
    p += sz;
    80006f02:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006f04:	0985                	addi	s3,s3,1
    80006f06:	000a2703          	lw	a4,0(s4)
    80006f0a:	0009879b          	sext.w	a5,s3
    80006f0e:	fae7c4e3          	blt	a5,a4,80006eb6 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006f12:	00003797          	auipc	a5,0x3
    80006f16:	0ee7a783          	lw	a5,238(a5) # 8000a000 <nsizes>
    80006f1a:	4705                	li	a4,1
    80006f1c:	06f75163          	bge	a4,a5,80006f7e <bd_init+0x190>
    80006f20:	02000a13          	li	s4,32
    80006f24:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f26:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006f28:	00003b17          	auipc	s6,0x3
    80006f2c:	0d0b0b13          	addi	s6,s6,208 # 80009ff8 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006f30:	00003a97          	auipc	s5,0x3
    80006f34:	0d0a8a93          	addi	s5,s5,208 # 8000a000 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f38:	37fd                	addiw	a5,a5,-1
    80006f3a:	413787bb          	subw	a5,a5,s3
    80006f3e:	00fb94bb          	sllw	s1,s7,a5
    80006f42:	fff4879b          	addiw	a5,s1,-1
    80006f46:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f4a:	01d4d49b          	srliw	s1,s1,0x1d
    80006f4e:	9cbd                	addw	s1,s1,a5
    80006f50:	98e1                	andi	s1,s1,-8
    80006f52:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006f54:	000b3783          	ld	a5,0(s6)
    80006f58:	97d2                	add	a5,a5,s4
    80006f5a:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006f5e:	848d                	srai	s1,s1,0x3
    80006f60:	8626                	mv	a2,s1
    80006f62:	4581                	li	a1,0
    80006f64:	854a                	mv	a0,s2
    80006f66:	ffffa097          	auipc	ra,0xffffa
    80006f6a:	f1a080e7          	jalr	-230(ra) # 80000e80 <memset>
    p += sz;
    80006f6e:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006f70:	2985                	addiw	s3,s3,1
    80006f72:	000aa783          	lw	a5,0(s5)
    80006f76:	020a0a13          	addi	s4,s4,32
    80006f7a:	faf9cfe3          	blt	s3,a5,80006f38 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006f7e:	197d                	addi	s2,s2,-1
    80006f80:	ff097913          	andi	s2,s2,-16
    80006f84:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006f86:	854a                	mv	a0,s2
    80006f88:	00000097          	auipc	ra,0x0
    80006f8c:	d7c080e7          	jalr	-644(ra) # 80006d04 <bd_mark_data_structures>
    80006f90:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006f92:	85ca                	mv	a1,s2
    80006f94:	8562                	mv	a0,s8
    80006f96:	00000097          	auipc	ra,0x0
    80006f9a:	dce080e7          	jalr	-562(ra) # 80006d64 <bd_mark_unavailable>
    80006f9e:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006fa0:	00003a97          	auipc	s5,0x3
    80006fa4:	060a8a93          	addi	s5,s5,96 # 8000a000 <nsizes>
    80006fa8:	000aa783          	lw	a5,0(s5)
    80006fac:	37fd                	addiw	a5,a5,-1
    80006fae:	44c1                	li	s1,16
    80006fb0:	00f497b3          	sll	a5,s1,a5
    80006fb4:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006fb6:	00003597          	auipc	a1,0x3
    80006fba:	03a5b583          	ld	a1,58(a1) # 80009ff0 <bd_base>
    80006fbe:	95be                	add	a1,a1,a5
    80006fc0:	854a                	mv	a0,s2
    80006fc2:	00000097          	auipc	ra,0x0
    80006fc6:	c86080e7          	jalr	-890(ra) # 80006c48 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80006fca:	000aa603          	lw	a2,0(s5)
    80006fce:	367d                	addiw	a2,a2,-1
    80006fd0:	00c49633          	sll	a2,s1,a2
    80006fd4:	41460633          	sub	a2,a2,s4
    80006fd8:	41360633          	sub	a2,a2,s3
    80006fdc:	02c51463          	bne	a0,a2,80007004 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80006fe0:	60a6                	ld	ra,72(sp)
    80006fe2:	6406                	ld	s0,64(sp)
    80006fe4:	74e2                	ld	s1,56(sp)
    80006fe6:	7942                	ld	s2,48(sp)
    80006fe8:	79a2                	ld	s3,40(sp)
    80006fea:	7a02                	ld	s4,32(sp)
    80006fec:	6ae2                	ld	s5,24(sp)
    80006fee:	6b42                	ld	s6,16(sp)
    80006ff0:	6ba2                	ld	s7,8(sp)
    80006ff2:	6c02                	ld	s8,0(sp)
    80006ff4:	6161                	addi	sp,sp,80
    80006ff6:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80006ff8:	2509                	addiw	a0,a0,2
    80006ffa:	00003797          	auipc	a5,0x3
    80006ffe:	00a7a323          	sw	a0,6(a5) # 8000a000 <nsizes>
    80007002:	bda1                	j	80006e5a <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007004:	85aa                	mv	a1,a0
    80007006:	00003517          	auipc	a0,0x3
    8000700a:	f0a50513          	addi	a0,a0,-246 # 80009f10 <syscalls+0x540>
    8000700e:	ffff9097          	auipc	ra,0xffff9
    80007012:	5be080e7          	jalr	1470(ra) # 800005cc <printf>
    panic("bd_init: free mem");
    80007016:	00003517          	auipc	a0,0x3
    8000701a:	f0a50513          	addi	a0,a0,-246 # 80009f20 <syscalls+0x550>
    8000701e:	ffff9097          	auipc	ra,0xffff9
    80007022:	54c080e7          	jalr	1356(ra) # 8000056a <panic>

0000000080007026 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007026:	1141                	addi	sp,sp,-16
    80007028:	e422                	sd	s0,8(sp)
    8000702a:	0800                	addi	s0,sp,16
  lst->next = lst;
    8000702c:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000702e:	e508                	sd	a0,8(a0)
}
    80007030:	6422                	ld	s0,8(sp)
    80007032:	0141                	addi	sp,sp,16
    80007034:	8082                	ret

0000000080007036 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007036:	1141                	addi	sp,sp,-16
    80007038:	e422                	sd	s0,8(sp)
    8000703a:	0800                	addi	s0,sp,16
  return lst->next == lst;
    8000703c:	611c                	ld	a5,0(a0)
    8000703e:	40a78533          	sub	a0,a5,a0
}
    80007042:	00153513          	seqz	a0,a0
    80007046:	6422                	ld	s0,8(sp)
    80007048:	0141                	addi	sp,sp,16
    8000704a:	8082                	ret

000000008000704c <lst_remove>:

void
lst_remove(struct list *e) {
    8000704c:	1141                	addi	sp,sp,-16
    8000704e:	e422                	sd	s0,8(sp)
    80007050:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007052:	6518                	ld	a4,8(a0)
    80007054:	611c                	ld	a5,0(a0)
    80007056:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007058:	6518                	ld	a4,8(a0)
    8000705a:	e798                	sd	a4,8(a5)
}
    8000705c:	6422                	ld	s0,8(sp)
    8000705e:	0141                	addi	sp,sp,16
    80007060:	8082                	ret

0000000080007062 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007062:	1101                	addi	sp,sp,-32
    80007064:	ec06                	sd	ra,24(sp)
    80007066:	e822                	sd	s0,16(sp)
    80007068:	e426                	sd	s1,8(sp)
    8000706a:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    8000706c:	6104                	ld	s1,0(a0)
    8000706e:	00a48d63          	beq	s1,a0,80007088 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007072:	8526                	mv	a0,s1
    80007074:	00000097          	auipc	ra,0x0
    80007078:	fd8080e7          	jalr	-40(ra) # 8000704c <lst_remove>
  return (void *)p;
}
    8000707c:	8526                	mv	a0,s1
    8000707e:	60e2                	ld	ra,24(sp)
    80007080:	6442                	ld	s0,16(sp)
    80007082:	64a2                	ld	s1,8(sp)
    80007084:	6105                	addi	sp,sp,32
    80007086:	8082                	ret
    panic("lst_pop");
    80007088:	00003517          	auipc	a0,0x3
    8000708c:	eb050513          	addi	a0,a0,-336 # 80009f38 <syscalls+0x568>
    80007090:	ffff9097          	auipc	ra,0xffff9
    80007094:	4da080e7          	jalr	1242(ra) # 8000056a <panic>

0000000080007098 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007098:	1141                	addi	sp,sp,-16
    8000709a:	e422                	sd	s0,8(sp)
    8000709c:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000709e:	611c                	ld	a5,0(a0)
    800070a0:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800070a2:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800070a4:	611c                	ld	a5,0(a0)
    800070a6:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800070a8:	e10c                	sd	a1,0(a0)
}
    800070aa:	6422                	ld	s0,8(sp)
    800070ac:	0141                	addi	sp,sp,16
    800070ae:	8082                	ret

00000000800070b0 <lst_print>:

void
lst_print(struct list *lst)
{
    800070b0:	7179                	addi	sp,sp,-48
    800070b2:	f406                	sd	ra,40(sp)
    800070b4:	f022                	sd	s0,32(sp)
    800070b6:	ec26                	sd	s1,24(sp)
    800070b8:	e84a                	sd	s2,16(sp)
    800070ba:	e44e                	sd	s3,8(sp)
    800070bc:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800070be:	6104                	ld	s1,0(a0)
    800070c0:	02950063          	beq	a0,s1,800070e0 <lst_print+0x30>
    800070c4:	892a                	mv	s2,a0
    printf(" %p", p);
    800070c6:	00003997          	auipc	s3,0x3
    800070ca:	e7a98993          	addi	s3,s3,-390 # 80009f40 <syscalls+0x570>
    800070ce:	85a6                	mv	a1,s1
    800070d0:	854e                	mv	a0,s3
    800070d2:	ffff9097          	auipc	ra,0xffff9
    800070d6:	4fa080e7          	jalr	1274(ra) # 800005cc <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800070da:	6084                	ld	s1,0(s1)
    800070dc:	fe9919e3          	bne	s2,s1,800070ce <lst_print+0x1e>
  }
  printf("\n");
    800070e0:	00002517          	auipc	a0,0x2
    800070e4:	12050513          	addi	a0,a0,288 # 80009200 <digits+0x90>
    800070e8:	ffff9097          	auipc	ra,0xffff9
    800070ec:	4e4080e7          	jalr	1252(ra) # 800005cc <printf>
}
    800070f0:	70a2                	ld	ra,40(sp)
    800070f2:	7402                	ld	s0,32(sp)
    800070f4:	64e2                	ld	s1,24(sp)
    800070f6:	6942                	ld	s2,16(sp)
    800070f8:	69a2                	ld	s3,8(sp)
    800070fa:	6145                	addi	sp,sp,48
    800070fc:	8082                	ret

00000000800070fe <rcu_init>:
static struct spinlock rcu_lock;
static struct rcu_head *defer_list = 0;

void
rcu_init(void)
{
    800070fe:	1141                	addi	sp,sp,-16
    80007100:	e406                	sd	ra,8(sp)
    80007102:	e022                	sd	s0,0(sp)
    80007104:	0800                	addi	s0,sp,16
  initlock(&rcu_lock, "rcu");
    80007106:	00003597          	auipc	a1,0x3
    8000710a:	e4258593          	addi	a1,a1,-446 # 80009f48 <syscalls+0x578>
    8000710e:	00030517          	auipc	a0,0x30
    80007112:	2b250513          	addi	a0,a0,690 # 800373c0 <rcu_lock>
    80007116:	ffffa097          	auipc	ra,0xffffa
    8000711a:	9b0080e7          	jalr	-1616(ra) # 80000ac6 <initlock>
  rcu_readers = 0;
    8000711e:	00003797          	auipc	a5,0x3
    80007122:	ee07a923          	sw	zero,-270(a5) # 8000a010 <rcu_readers>
  defer_list = 0;
    80007126:	00003797          	auipc	a5,0x3
    8000712a:	ee07b123          	sd	zero,-286(a5) # 8000a008 <defer_list>
}
    8000712e:	60a2                	ld	ra,8(sp)
    80007130:	6402                	ld	s0,0(sp)
    80007132:	0141                	addi	sp,sp,16
    80007134:	8082                	ret

0000000080007136 <rcu_read_lock>:

// Enter RCU read section
void
rcu_read_lock(void)
{
    80007136:	1141                	addi	sp,sp,-16
    80007138:	e422                	sd	s0,8(sp)
    8000713a:	0800                	addi	s0,sp,16
  __sync_add_and_fetch(&rcu_readers, 1);
    8000713c:	00003797          	auipc	a5,0x3
    80007140:	ed478793          	addi	a5,a5,-300 # 8000a010 <rcu_readers>
    80007144:	4705                	li	a4,1
    80007146:	0f50000f          	fence	iorw,ow
    8000714a:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  __sync_synchronize();
    8000714e:	0ff0000f          	fence
}
    80007152:	6422                	ld	s0,8(sp)
    80007154:	0141                	addi	sp,sp,16
    80007156:	8082                	ret

0000000080007158 <rcu_read_unlock>:

// Exit RCU read section
void
rcu_read_unlock(void)
{
    80007158:	1141                	addi	sp,sp,-16
    8000715a:	e422                	sd	s0,8(sp)
    8000715c:	0800                	addi	s0,sp,16
  __sync_synchronize();
    8000715e:	0ff0000f          	fence
  __sync_sub_and_fetch(&rcu_readers, 1);
    80007162:	00003797          	auipc	a5,0x3
    80007166:	eae78793          	addi	a5,a5,-338 # 8000a010 <rcu_readers>
    8000716a:	577d                	li	a4,-1
    8000716c:	0f50000f          	fence	iorw,ow
    80007170:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
}
    80007174:	6422                	ld	s0,8(sp)
    80007176:	0141                	addi	sp,sp,16
    80007178:	8082                	ret

000000008000717a <call_rcu>:

// Register a deferred callback
void
call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *))
{
    8000717a:	1101                	addi	sp,sp,-32
    8000717c:	ec06                	sd	ra,24(sp)
    8000717e:	e822                	sd	s0,16(sp)
    80007180:	e426                	sd	s1,8(sp)
    80007182:	e04a                	sd	s2,0(sp)
    80007184:	1000                	addi	s0,sp,32
    80007186:	84aa                	mv	s1,a0
  head->func = func;
    80007188:	e10c                	sd	a1,0(a0)
  acquire(&rcu_lock);
    8000718a:	00030917          	auipc	s2,0x30
    8000718e:	23690913          	addi	s2,s2,566 # 800373c0 <rcu_lock>
    80007192:	854a                	mv	a0,s2
    80007194:	ffffa097          	auipc	ra,0xffffa
    80007198:	a08080e7          	jalr	-1528(ra) # 80000b9c <acquire>
  head->next = defer_list;
    8000719c:	00003797          	auipc	a5,0x3
    800071a0:	e6c78793          	addi	a5,a5,-404 # 8000a008 <defer_list>
    800071a4:	6398                	ld	a4,0(a5)
    800071a6:	e498                	sd	a4,8(s1)
  defer_list = head;
    800071a8:	e384                	sd	s1,0(a5)
  release(&rcu_lock);
    800071aa:	854a                	mv	a0,s2
    800071ac:	ffffa097          	auipc	ra,0xffffa
    800071b0:	ac0080e7          	jalr	-1344(ra) # 80000c6c <release>
}
    800071b4:	60e2                	ld	ra,24(sp)
    800071b6:	6442                	ld	s0,16(sp)
    800071b8:	64a2                	ld	s1,8(sp)
    800071ba:	6902                	ld	s2,0(sp)
    800071bc:	6105                	addi	sp,sp,32
    800071be:	8082                	ret

00000000800071c0 <synchronize_rcu>:

// Wait until all readers finish, then run callbacks
void
synchronize_rcu(void)
{
    800071c0:	1101                	addi	sp,sp,-32
    800071c2:	ec06                	sd	ra,24(sp)
    800071c4:	e822                	sd	s0,16(sp)
    800071c6:	e426                	sd	s1,8(sp)
    800071c8:	1000                	addi	s0,sp,32
  while (__sync_fetch_and_add(&rcu_readers, 0) > 0)
    800071ca:	00003717          	auipc	a4,0x3
    800071ce:	e4670713          	addi	a4,a4,-442 # 8000a010 <rcu_readers>
    800071d2:	0f50000f          	fence	iorw,ow
    800071d6:	040727af          	amoadd.w.aq	a5,zero,(a4)
    800071da:	2781                	sext.w	a5,a5
    800071dc:	fef04be3          	bgtz	a5,800071d2 <synchronize_rcu+0x12>
    ; // wait for readers

  acquire(&rcu_lock);
    800071e0:	00030517          	auipc	a0,0x30
    800071e4:	1e050513          	addi	a0,a0,480 # 800373c0 <rcu_lock>
    800071e8:	ffffa097          	auipc	ra,0xffffa
    800071ec:	9b4080e7          	jalr	-1612(ra) # 80000b9c <acquire>
  struct rcu_head *h = defer_list;
    800071f0:	00003497          	auipc	s1,0x3
    800071f4:	e184b483          	ld	s1,-488(s1) # 8000a008 <defer_list>
  while (h) {
    800071f8:	c491                	beqz	s1,80007204 <synchronize_rcu+0x44>
    struct rcu_head *next = h->next;
    800071fa:	8526                	mv	a0,s1
    800071fc:	6484                	ld	s1,8(s1)
    h->func(h);
    800071fe:	611c                	ld	a5,0(a0)
    80007200:	9782                	jalr	a5
  while (h) {
    80007202:	fce5                	bnez	s1,800071fa <synchronize_rcu+0x3a>
    h = next;
  }
  defer_list = 0;
    80007204:	00003797          	auipc	a5,0x3
    80007208:	e007b223          	sd	zero,-508(a5) # 8000a008 <defer_list>
  release(&rcu_lock);
    8000720c:	00030517          	auipc	a0,0x30
    80007210:	1b450513          	addi	a0,a0,436 # 800373c0 <rcu_lock>
    80007214:	ffffa097          	auipc	ra,0xffffa
    80007218:	a58080e7          	jalr	-1448(ra) # 80000c6c <release>
}
    8000721c:	60e2                	ld	ra,24(sp)
    8000721e:	6442                	ld	s0,16(sp)
    80007220:	64a2                	ld	s1,8(sp)
    80007222:	6105                	addi	sp,sp,32
    80007224:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
