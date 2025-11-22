
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	fe013103          	ld	sp,-32(sp) # 80009fe0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	ffe70713          	addi	a4,a4,-2 # 8000a050 <timer_scratch>
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
    80000068:	e0c78793          	addi	a5,a5,-500 # 80005e70 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc73cf>
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
    8000012e:	06650513          	addi	a0,a0,102 # 80012190 <cons>
    80000132:	00001097          	auipc	ra,0x1
    80000136:	a6a080e7          	jalr	-1430(ra) # 80000b9c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000013a:	00012497          	auipc	s1,0x12
    8000013e:	05648493          	addi	s1,s1,86 # 80012190 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000142:	89a6                	mv	s3,s1
    80000144:	00012917          	auipc	s2,0x12
    80000148:	0ec90913          	addi	s2,s2,236 # 80012230 <cons+0xa0>
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
    80000166:	a3c080e7          	jalr	-1476(ra) # 80001b9e <myproc>
    8000016a:	5d1c                	lw	a5,56(a0)
    8000016c:	e7b5                	bnez	a5,800001d8 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000016e:	85ce                	mv	a1,s3
    80000170:	854a                	mv	a0,s2
    80000172:	00002097          	auipc	ra,0x2
    80000176:	1fa080e7          	jalr	506(ra) # 8000236c <sleep>
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
    800001b2:	420080e7          	jalr	1056(ra) # 800025ce <either_copyout>
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
    800001c6:	fce50513          	addi	a0,a0,-50 # 80012190 <cons>
    800001ca:	00001097          	auipc	ra,0x1
    800001ce:	aa2080e7          	jalr	-1374(ra) # 80000c6c <release>

  return target - n;
    800001d2:	414b853b          	subw	a0,s7,s4
    800001d6:	a811                	j	800001ea <consoleread+0xe8>
        release(&cons.lock);
    800001d8:	00012517          	auipc	a0,0x12
    800001dc:	fb850513          	addi	a0,a0,-72 # 80012190 <cons>
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
    80000214:	02f72023          	sw	a5,32(a4) # 80012230 <cons+0xa0>
    80000218:	b76d                	j	800001c2 <consoleread+0xc0>

000000008000021a <consputc>:
  if(panicked){
    8000021a:	0000a797          	auipc	a5,0xa
    8000021e:	de67a783          	lw	a5,-538(a5) # 8000a000 <panicked>
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
    80000284:	f1050513          	addi	a0,a0,-240 # 80012190 <cons>
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
    800002a6:	382080e7          	jalr	898(ra) # 80002624 <either_copyin>
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
    800002c6:	ece50513          	addi	a0,a0,-306 # 80012190 <cons>
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
    800002fc:	e9850513          	addi	a0,a0,-360 # 80012190 <cons>
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
    80000322:	35c080e7          	jalr	860(ra) # 8000267a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000326:	00012517          	auipc	a0,0x12
    8000032a:	e6a50513          	addi	a0,a0,-406 # 80012190 <cons>
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
    8000034e:	e4670713          	addi	a4,a4,-442 # 80012190 <cons>
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
    80000378:	e1c78793          	addi	a5,a5,-484 # 80012190 <cons>
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
    800003a6:	e8e7a783          	lw	a5,-370(a5) # 80012230 <cons+0xa0>
    800003aa:	0807879b          	addiw	a5,a5,128
    800003ae:	f6f61ce3          	bne	a2,a5,80000326 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003b2:	863e                	mv	a2,a5
    800003b4:	a07d                	j	80000462 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	dda70713          	addi	a4,a4,-550 # 80012190 <cons>
    800003be:	0a872783          	lw	a5,168(a4)
    800003c2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c6:	00012497          	auipc	s1,0x12
    800003ca:	dca48493          	addi	s1,s1,-566 # 80012190 <cons>
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
    80000406:	d8e70713          	addi	a4,a4,-626 # 80012190 <cons>
    8000040a:	0a872783          	lw	a5,168(a4)
    8000040e:	0a472703          	lw	a4,164(a4)
    80000412:	f0f70ae3          	beq	a4,a5,80000326 <consoleintr+0x3c>
      cons.e--;
    80000416:	37fd                	addiw	a5,a5,-1
    80000418:	00012717          	auipc	a4,0x12
    8000041c:	e2f72023          	sw	a5,-480(a4) # 80012238 <cons+0xa8>
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
    80000442:	d5278793          	addi	a5,a5,-686 # 80012190 <cons>
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
    80000466:	dcc7a923          	sw	a2,-558(a5) # 80012234 <cons+0xa4>
        wakeup(&cons.r);
    8000046a:	00012517          	auipc	a0,0x12
    8000046e:	dc650513          	addi	a0,a0,-570 # 80012230 <cons+0xa0>
    80000472:	00002097          	auipc	ra,0x2
    80000476:	080080e7          	jalr	128(ra) # 800024f2 <wakeup>
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
    80000490:	d0450513          	addi	a0,a0,-764 # 80012190 <cons>
    80000494:	00000097          	auipc	ra,0x0
    80000498:	632080e7          	jalr	1586(ra) # 80000ac6 <initlock>

  uartinit();
    8000049c:	00000097          	auipc	ra,0x0
    800004a0:	3f6080e7          	jalr	1014(ra) # 80000892 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004a4:	00036797          	auipc	a5,0x36
    800004a8:	d8478793          	addi	a5,a5,-636 # 80036228 <devsw>
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
    8000057a:	ce07a523          	sw	zero,-790(a5) # 80012260 <pr+0x20>
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
    800005c6:	a2f72f23          	sw	a5,-1474(a4) # 8000a000 <panicked>
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
    80000602:	c62c2c03          	lw	s8,-926(s8) # 80012260 <pr+0x20>
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
    80000642:	c0250513          	addi	a0,a0,-1022 # 80012240 <pr>
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
    800007e8:	a5c50513          	addi	a0,a0,-1444 # 80012240 <pr>
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
    8000086e:	9d648493          	addi	s1,s1,-1578 # 80012240 <pr>
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
    8000095e:	ad678793          	addi	a5,a5,-1322 # 80037430 <end>
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
    8000097e:	8ee90913          	addi	s2,s2,-1810 # 80012268 <kmem>
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
    80000a24:	84850513          	addi	a0,a0,-1976 # 80012268 <kmem>
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	09e080e7          	jalr	158(ra) # 80000ac6 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a30:	45c5                	li	a1,17
    80000a32:	05ee                	slli	a1,a1,0x1b
    80000a34:	00037517          	auipc	a0,0x37
    80000a38:	9fc50513          	addi	a0,a0,-1540 # 80037430 <end>
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
    80000a56:	00012497          	auipc	s1,0x12
    80000a5a:	81248493          	addi	s1,s1,-2030 # 80012268 <kmem>
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
    80000a72:	7fa50513          	addi	a0,a0,2042 # 80012268 <kmem>
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
    80000aa4:	7c850513          	addi	a0,a0,1992 # 80012268 <kmem>
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
    80000abc:	7d853503          	ld	a0,2008(a0) # 80012290 <kmem+0x28>
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
    80000adc:	52c7a783          	lw	a5,1324(a5) # 8000a004 <nlock>
    80000ae0:	6709                	lui	a4,0x2
    80000ae2:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000ae6:	02f74063          	blt	a4,a5,80000b06 <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000aea:	00379693          	slli	a3,a5,0x3
    80000aee:	00011717          	auipc	a4,0x11
    80000af2:	7aa70713          	addi	a4,a4,1962 # 80012298 <locks>
    80000af6:	9736                	add	a4,a4,a3
    80000af8:	e308                	sd	a0,0(a4)
  nlock++;
    80000afa:	2785                	addiw	a5,a5,1
    80000afc:	00009717          	auipc	a4,0x9
    80000b00:	50f72423          	sw	a5,1288(a4) # 8000a004 <nlock>
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
    80000b36:	050080e7          	jalr	80(ra) # 80001b82 <mycpu>
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
    80000b6c:	01a080e7          	jalr	26(ra) # 80001b82 <mycpu>
    80000b70:	5d3c                	lw	a5,120(a0)
    80000b72:	cf89                	beqz	a5,80000b8c <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b74:	00001097          	auipc	ra,0x1
    80000b78:	00e080e7          	jalr	14(ra) # 80001b82 <mycpu>
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
    80000b90:	ff6080e7          	jalr	-10(ra) # 80001b82 <mycpu>
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
    80000bfc:	f8a080e7          	jalr	-118(ra) # 80001b82 <mycpu>
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
    80000c20:	f66080e7          	jalr	-154(ra) # 80001b82 <mycpu>
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
    80000d02:	0b6080e7          	jalr	182(ra) # 80002db4 <argint>
    80000d06:	12054463          	bltz	a0,80000e2e <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d0a:	fac42783          	lw	a5,-84(s0)
    80000d0e:	e39d                	bnez	a5,80000d34 <sys_ntas+0x56>
    80000d10:	00011797          	auipc	a5,0x11
    80000d14:	58878793          	addi	a5,a5,1416 # 80012298 <locks>
    80000d18:	00025697          	auipc	a3,0x25
    80000d1c:	e0068693          	addi	a3,a3,-512 # 80025b18 <pid_lock>
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
    80000d48:	554b0b13          	addi	s6,s6,1364 # 80012298 <locks>
    80000d4c:	00025b97          	auipc	s7,0x25
    80000d50:	dccb8b93          	addi	s7,s7,-564 # 80025b18 <pid_lock>
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
    80000dbe:	4de48493          	addi	s1,s1,1246 # 80012298 <locks>
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
    80001066:	b10080e7          	jalr	-1264(ra) # 80001b72 <cpuid>
    userinit();      // first user process

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000106a:	00009717          	auipc	a4,0x9
    8000106e:	f9e70713          	addi	a4,a4,-98 # 8000a008 <started>
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
    80001082:	af4080e7          	jalr	-1292(ra) # 80001b72 <cpuid>
    80001086:	85aa                	mv	a1,a0
    80001088:	00008517          	auipc	a0,0x8
    8000108c:	1d050513          	addi	a0,a0,464 # 80009258 <digits+0xe8>
    80001090:	fffff097          	auipc	ra,0xfffff
    80001094:	53c080e7          	jalr	1340(ra) # 800005cc <printf>
    kvminithart();    // turn on paging
    80001098:	00000097          	auipc	ra,0x0
    8000109c:	1f8080e7          	jalr	504(ra) # 80001290 <kvminithart>
    trapinithart();   // install kernel trap vector
    800010a0:	00002097          	auipc	ra,0x2
    800010a4:	8aa080e7          	jalr	-1878(ra) # 8000294a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800010a8:	00005097          	auipc	ra,0x5
    800010ac:	e08080e7          	jalr	-504(ra) # 80005eb0 <plicinithart>
  }

  scheduler();        
    800010b0:	00001097          	auipc	ra,0x1
    800010b4:	fd4080e7          	jalr	-44(ra) # 80002084 <scheduler>
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
    80001104:	2ce080e7          	jalr	718(ra) # 800013ce <kvminit>
    kvminithart();   // turn on paging
    80001108:	00000097          	auipc	ra,0x0
    8000110c:	188080e7          	jalr	392(ra) # 80001290 <kvminithart>
    procinit();      // process table
    80001110:	00001097          	auipc	ra,0x1
    80001114:	992080e7          	jalr	-1646(ra) # 80001aa2 <procinit>
    trapinit();      // trap vectors
    80001118:	00002097          	auipc	ra,0x2
    8000111c:	80a080e7          	jalr	-2038(ra) # 80002922 <trapinit>
    trapinithart();  // install kernel trap vector
    80001120:	00002097          	auipc	ra,0x2
    80001124:	82a080e7          	jalr	-2006(ra) # 8000294a <trapinithart>
    plicinit();      // set up interrupt controller
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	d72080e7          	jalr	-654(ra) # 80005e9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001130:	00005097          	auipc	ra,0x5
    80001134:	d80080e7          	jalr	-640(ra) # 80005eb0 <plicinithart>
    binit();         // buffer cache
    80001138:	00002097          	auipc	ra,0x2
    8000113c:	f5e080e7          	jalr	-162(ra) # 80003096 <binit>
    iinit();         // inode cache
    80001140:	00002097          	auipc	ra,0x2
    80001144:	5ee080e7          	jalr	1518(ra) # 8000372e <iinit>
    fileinit();      // file table
    80001148:	00003097          	auipc	ra,0x3
    8000114c:	586080e7          	jalr	1414(ra) # 800046ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001150:	00005097          	auipc	ra,0x5
    80001154:	e58080e7          	jalr	-424(ra) # 80005fa8 <virtio_disk_init>
    rcu_init();
    80001158:	00006097          	auipc	ra,0x6
    8000115c:	fe6080e7          	jalr	-26(ra) # 8000713e <rcu_init>
    test_rcu();
    80001160:	00001097          	auipc	ra,0x1
    80001164:	5c8080e7          	jalr	1480(ra) # 80002728 <test_rcu>
    userinit();      // first user process
    80001168:	00001097          	auipc	ra,0x1
    8000116c:	cb6080e7          	jalr	-842(ra) # 80001e1e <userinit>
    __sync_synchronize();
    80001170:	0ff0000f          	fence
    started = 1;
    80001174:	4785                	li	a5,1
    80001176:	00009717          	auipc	a4,0x9
    8000117a:	e8f72923          	sw	a5,-366(a4) # 8000a008 <started>
    8000117e:	bf0d                	j	800010b0 <main+0x56>

0000000080001180 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001180:	7139                	addi	sp,sp,-64
    80001182:	fc06                	sd	ra,56(sp)
    80001184:	f822                	sd	s0,48(sp)
    80001186:	f426                	sd	s1,40(sp)
    80001188:	f04a                	sd	s2,32(sp)
    8000118a:	ec4e                	sd	s3,24(sp)
    8000118c:	e852                	sd	s4,16(sp)
    8000118e:	e456                	sd	s5,8(sp)
    80001190:	e05a                	sd	s6,0(sp)
    80001192:	0080                	addi	s0,sp,64
    80001194:	84aa                	mv	s1,a0
    80001196:	89ae                	mv	s3,a1
    80001198:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000119a:	57fd                	li	a5,-1
    8000119c:	83e9                	srli	a5,a5,0x1a
    8000119e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800011a0:	4b31                	li	s6,12
  if(va >= MAXVA)
    800011a2:	04b7f263          	bgeu	a5,a1,800011e6 <walk+0x66>
    panic("walk");
    800011a6:	00008517          	auipc	a0,0x8
    800011aa:	0ca50513          	addi	a0,a0,202 # 80009270 <digits+0x100>
    800011ae:	fffff097          	auipc	ra,0xfffff
    800011b2:	3bc080e7          	jalr	956(ra) # 8000056a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800011b6:	060a8663          	beqz	s5,80001222 <walk+0xa2>
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	892080e7          	jalr	-1902(ra) # 80000a4c <kalloc>
    800011c2:	84aa                	mv	s1,a0
    800011c4:	c529                	beqz	a0,8000120e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011c6:	6605                	lui	a2,0x1
    800011c8:	4581                	li	a1,0
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	cb6080e7          	jalr	-842(ra) # 80000e80 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011d2:	00c4d793          	srli	a5,s1,0xc
    800011d6:	07aa                	slli	a5,a5,0xa
    800011d8:	0017e793          	ori	a5,a5,1
    800011dc:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011e0:	3a5d                	addiw	s4,s4,-9
    800011e2:	036a0063          	beq	s4,s6,80001202 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011e6:	0149d933          	srl	s2,s3,s4
    800011ea:	1ff97913          	andi	s2,s2,511
    800011ee:	090e                	slli	s2,s2,0x3
    800011f0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011f2:	00093483          	ld	s1,0(s2)
    800011f6:	0014f793          	andi	a5,s1,1
    800011fa:	dfd5                	beqz	a5,800011b6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011fc:	80a9                	srli	s1,s1,0xa
    800011fe:	04b2                	slli	s1,s1,0xc
    80001200:	b7c5                	j	800011e0 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001202:	00c9d513          	srli	a0,s3,0xc
    80001206:	1ff57513          	andi	a0,a0,511
    8000120a:	050e                	slli	a0,a0,0x3
    8000120c:	9526                	add	a0,a0,s1
}
    8000120e:	70e2                	ld	ra,56(sp)
    80001210:	7442                	ld	s0,48(sp)
    80001212:	74a2                	ld	s1,40(sp)
    80001214:	7902                	ld	s2,32(sp)
    80001216:	69e2                	ld	s3,24(sp)
    80001218:	6a42                	ld	s4,16(sp)
    8000121a:	6aa2                	ld	s5,8(sp)
    8000121c:	6b02                	ld	s6,0(sp)
    8000121e:	6121                	addi	sp,sp,64
    80001220:	8082                	ret
        return 0;
    80001222:	4501                	li	a0,0
    80001224:	b7ed                	j	8000120e <walk+0x8e>

0000000080001226 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80001226:	7179                	addi	sp,sp,-48
    80001228:	f406                	sd	ra,40(sp)
    8000122a:	f022                	sd	s0,32(sp)
    8000122c:	ec26                	sd	s1,24(sp)
    8000122e:	e84a                	sd	s2,16(sp)
    80001230:	e44e                	sd	s3,8(sp)
    80001232:	e052                	sd	s4,0(sp)
    80001234:	1800                	addi	s0,sp,48
    80001236:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001238:	84aa                	mv	s1,a0
    8000123a:	6905                	lui	s2,0x1
    8000123c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000123e:	4985                	li	s3,1
    80001240:	a821                	j	80001258 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001242:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001244:	0532                	slli	a0,a0,0xc
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	fe0080e7          	jalr	-32(ra) # 80001226 <freewalk>
      pagetable[i] = 0;
    8000124e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001252:	04a1                	addi	s1,s1,8
    80001254:	03248163          	beq	s1,s2,80001276 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001258:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000125a:	00f57793          	andi	a5,a0,15
    8000125e:	ff3782e3          	beq	a5,s3,80001242 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001262:	8905                	andi	a0,a0,1
    80001264:	d57d                	beqz	a0,80001252 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001266:	00008517          	auipc	a0,0x8
    8000126a:	01250513          	addi	a0,a0,18 # 80009278 <digits+0x108>
    8000126e:	fffff097          	auipc	ra,0xfffff
    80001272:	2fc080e7          	jalr	764(ra) # 8000056a <panic>
    }
  }
  kfree((void*)pagetable);
    80001276:	8552                	mv	a0,s4
    80001278:	fffff097          	auipc	ra,0xfffff
    8000127c:	6ce080e7          	jalr	1742(ra) # 80000946 <kfree>
}
    80001280:	70a2                	ld	ra,40(sp)
    80001282:	7402                	ld	s0,32(sp)
    80001284:	64e2                	ld	s1,24(sp)
    80001286:	6942                	ld	s2,16(sp)
    80001288:	69a2                	ld	s3,8(sp)
    8000128a:	6a02                	ld	s4,0(sp)
    8000128c:	6145                	addi	sp,sp,48
    8000128e:	8082                	ret

0000000080001290 <kvminithart>:
{
    80001290:	1141                	addi	sp,sp,-16
    80001292:	e422                	sd	s0,8(sp)
    80001294:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001296:	00009797          	auipc	a5,0x9
    8000129a:	d7a7b783          	ld	a5,-646(a5) # 8000a010 <kernel_pagetable>
    8000129e:	83b1                	srli	a5,a5,0xc
    800012a0:	577d                	li	a4,-1
    800012a2:	177e                	slli	a4,a4,0x3f
    800012a4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800012a6:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800012aa:	12000073          	sfence.vma
}
    800012ae:	6422                	ld	s0,8(sp)
    800012b0:	0141                	addi	sp,sp,16
    800012b2:	8082                	ret

00000000800012b4 <walkaddr>:
  if(va >= MAXVA)
    800012b4:	57fd                	li	a5,-1
    800012b6:	83e9                	srli	a5,a5,0x1a
    800012b8:	00b7f463          	bgeu	a5,a1,800012c0 <walkaddr+0xc>
    return 0;
    800012bc:	4501                	li	a0,0
}
    800012be:	8082                	ret
{
    800012c0:	1141                	addi	sp,sp,-16
    800012c2:	e406                	sd	ra,8(sp)
    800012c4:	e022                	sd	s0,0(sp)
    800012c6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012c8:	4601                	li	a2,0
    800012ca:	00000097          	auipc	ra,0x0
    800012ce:	eb6080e7          	jalr	-330(ra) # 80001180 <walk>
  if(pte == 0)
    800012d2:	c105                	beqz	a0,800012f2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012d4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012d6:	0117f693          	andi	a3,a5,17
    800012da:	4745                	li	a4,17
    return 0;
    800012dc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012de:	00e68663          	beq	a3,a4,800012ea <walkaddr+0x36>
}
    800012e2:	60a2                	ld	ra,8(sp)
    800012e4:	6402                	ld	s0,0(sp)
    800012e6:	0141                	addi	sp,sp,16
    800012e8:	8082                	ret
  pa = PTE2PA(*pte);
    800012ea:	00a7d513          	srli	a0,a5,0xa
    800012ee:	0532                	slli	a0,a0,0xc
  return pa;
    800012f0:	bfcd                	j	800012e2 <walkaddr+0x2e>
    return 0;
    800012f2:	4501                	li	a0,0
    800012f4:	b7fd                	j	800012e2 <walkaddr+0x2e>

00000000800012f6 <mappages>:
{
    800012f6:	715d                	addi	sp,sp,-80
    800012f8:	e486                	sd	ra,72(sp)
    800012fa:	e0a2                	sd	s0,64(sp)
    800012fc:	fc26                	sd	s1,56(sp)
    800012fe:	f84a                	sd	s2,48(sp)
    80001300:	f44e                	sd	s3,40(sp)
    80001302:	f052                	sd	s4,32(sp)
    80001304:	ec56                	sd	s5,24(sp)
    80001306:	e85a                	sd	s6,16(sp)
    80001308:	e45e                	sd	s7,8(sp)
    8000130a:	0880                	addi	s0,sp,80
  if(size == 0)
    8000130c:	c205                	beqz	a2,8000132c <mappages+0x36>
    8000130e:	8aaa                	mv	s5,a0
    80001310:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001312:	77fd                	lui	a5,0xfffff
    80001314:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001318:	15fd                	addi	a1,a1,-1
    8000131a:	00c589b3          	add	s3,a1,a2
    8000131e:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001322:	8952                	mv	s2,s4
    80001324:	41468a33          	sub	s4,a3,s4
    a += PGSIZE;
    80001328:	6b85                	lui	s7,0x1
    8000132a:	a015                	j	8000134e <mappages+0x58>
    panic("mappages: size");
    8000132c:	00008517          	auipc	a0,0x8
    80001330:	f5c50513          	addi	a0,a0,-164 # 80009288 <digits+0x118>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	236080e7          	jalr	566(ra) # 8000056a <panic>
      panic("mappages: remap");
    8000133c:	00008517          	auipc	a0,0x8
    80001340:	f5c50513          	addi	a0,a0,-164 # 80009298 <digits+0x128>
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	226080e7          	jalr	550(ra) # 8000056a <panic>
    a += PGSIZE;
    8000134c:	995e                	add	s2,s2,s7
  for(;;){
    8000134e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001352:	4605                	li	a2,1
    80001354:	85ca                	mv	a1,s2
    80001356:	8556                	mv	a0,s5
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	e28080e7          	jalr	-472(ra) # 80001180 <walk>
    80001360:	cd19                	beqz	a0,8000137e <mappages+0x88>
    if(*pte & PTE_V)
    80001362:	611c                	ld	a5,0(a0)
    80001364:	8b85                	andi	a5,a5,1
    80001366:	fbf9                	bnez	a5,8000133c <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001368:	80b1                	srli	s1,s1,0xc
    8000136a:	04aa                	slli	s1,s1,0xa
    8000136c:	0164e4b3          	or	s1,s1,s6
    80001370:	0014e493          	ori	s1,s1,1
    80001374:	e104                	sd	s1,0(a0)
    if(a == last)
    80001376:	fd391be3          	bne	s2,s3,8000134c <mappages+0x56>
  return 0;
    8000137a:	4501                	li	a0,0
    8000137c:	a011                	j	80001380 <mappages+0x8a>
      return -1;
    8000137e:	557d                	li	a0,-1
}
    80001380:	60a6                	ld	ra,72(sp)
    80001382:	6406                	ld	s0,64(sp)
    80001384:	74e2                	ld	s1,56(sp)
    80001386:	7942                	ld	s2,48(sp)
    80001388:	79a2                	ld	s3,40(sp)
    8000138a:	7a02                	ld	s4,32(sp)
    8000138c:	6ae2                	ld	s5,24(sp)
    8000138e:	6b42                	ld	s6,16(sp)
    80001390:	6ba2                	ld	s7,8(sp)
    80001392:	6161                	addi	sp,sp,80
    80001394:	8082                	ret

0000000080001396 <kvmmap>:
{
    80001396:	1141                	addi	sp,sp,-16
    80001398:	e406                	sd	ra,8(sp)
    8000139a:	e022                	sd	s0,0(sp)
    8000139c:	0800                	addi	s0,sp,16
    8000139e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800013a0:	86ae                	mv	a3,a1
    800013a2:	85aa                	mv	a1,a0
    800013a4:	00009517          	auipc	a0,0x9
    800013a8:	c6c53503          	ld	a0,-916(a0) # 8000a010 <kernel_pagetable>
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	f4a080e7          	jalr	-182(ra) # 800012f6 <mappages>
    800013b4:	e509                	bnez	a0,800013be <kvmmap+0x28>
}
    800013b6:	60a2                	ld	ra,8(sp)
    800013b8:	6402                	ld	s0,0(sp)
    800013ba:	0141                	addi	sp,sp,16
    800013bc:	8082                	ret
    panic("kvmmap");
    800013be:	00008517          	auipc	a0,0x8
    800013c2:	eea50513          	addi	a0,a0,-278 # 800092a8 <digits+0x138>
    800013c6:	fffff097          	auipc	ra,0xfffff
    800013ca:	1a4080e7          	jalr	420(ra) # 8000056a <panic>

00000000800013ce <kvminit>:
{
    800013ce:	1101                	addi	sp,sp,-32
    800013d0:	ec06                	sd	ra,24(sp)
    800013d2:	e822                	sd	s0,16(sp)
    800013d4:	e426                	sd	s1,8(sp)
    800013d6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	674080e7          	jalr	1652(ra) # 80000a4c <kalloc>
    800013e0:	00009797          	auipc	a5,0x9
    800013e4:	c2a7b823          	sd	a0,-976(a5) # 8000a010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800013e8:	6605                	lui	a2,0x1
    800013ea:	4581                	li	a1,0
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	a94080e7          	jalr	-1388(ra) # 80000e80 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013f4:	4699                	li	a3,6
    800013f6:	6605                	lui	a2,0x1
    800013f8:	100005b7          	lui	a1,0x10000
    800013fc:	10000537          	lui	a0,0x10000
    80001400:	00000097          	auipc	ra,0x0
    80001404:	f96080e7          	jalr	-106(ra) # 80001396 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001408:	4699                	li	a3,6
    8000140a:	6605                	lui	a2,0x1
    8000140c:	100015b7          	lui	a1,0x10001
    80001410:	10001537          	lui	a0,0x10001
    80001414:	00000097          	auipc	ra,0x0
    80001418:	f82080e7          	jalr	-126(ra) # 80001396 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000141c:	4699                	li	a3,6
    8000141e:	00400637          	lui	a2,0x400
    80001422:	0c0005b7          	lui	a1,0xc000
    80001426:	0c000537          	lui	a0,0xc000
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	f6c080e7          	jalr	-148(ra) # 80001396 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001432:	00008497          	auipc	s1,0x8
    80001436:	bce48493          	addi	s1,s1,-1074 # 80009000 <etext>
    8000143a:	46a9                	li	a3,10
    8000143c:	80008617          	auipc	a2,0x80008
    80001440:	bc460613          	addi	a2,a2,-1084 # 9000 <_entry-0x7fff7000>
    80001444:	4585                	li	a1,1
    80001446:	05fe                	slli	a1,a1,0x1f
    80001448:	852e                	mv	a0,a1
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	f4c080e7          	jalr	-180(ra) # 80001396 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001452:	4699                	li	a3,6
    80001454:	4645                	li	a2,17
    80001456:	066e                	slli	a2,a2,0x1b
    80001458:	8e05                	sub	a2,a2,s1
    8000145a:	85a6                	mv	a1,s1
    8000145c:	8526                	mv	a0,s1
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	f38080e7          	jalr	-200(ra) # 80001396 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001466:	46a9                	li	a3,10
    80001468:	6605                	lui	a2,0x1
    8000146a:	00007597          	auipc	a1,0x7
    8000146e:	b9658593          	addi	a1,a1,-1130 # 80008000 <_trampoline>
    80001472:	04000537          	lui	a0,0x4000
    80001476:	157d                	addi	a0,a0,-1
    80001478:	0532                	slli	a0,a0,0xc
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f1c080e7          	jalr	-228(ra) # 80001396 <kvmmap>
}
    80001482:	60e2                	ld	ra,24(sp)
    80001484:	6442                	ld	s0,16(sp)
    80001486:	64a2                	ld	s1,8(sp)
    80001488:	6105                	addi	sp,sp,32
    8000148a:	8082                	ret

000000008000148c <uvmunmap>:
{
    8000148c:	715d                	addi	sp,sp,-80
    8000148e:	e486                	sd	ra,72(sp)
    80001490:	e0a2                	sd	s0,64(sp)
    80001492:	fc26                	sd	s1,56(sp)
    80001494:	f84a                	sd	s2,48(sp)
    80001496:	f44e                	sd	s3,40(sp)
    80001498:	f052                	sd	s4,32(sp)
    8000149a:	ec56                	sd	s5,24(sp)
    8000149c:	e85a                	sd	s6,16(sp)
    8000149e:	e45e                	sd	s7,8(sp)
    800014a0:	0880                	addi	s0,sp,80
    800014a2:	8a2a                	mv	s4,a0
    800014a4:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800014a6:	77fd                	lui	a5,0xfffff
    800014a8:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800014ac:	167d                	addi	a2,a2,-1
    800014ae:	00b609b3          	add	s3,a2,a1
    800014b2:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800014b6:	4b05                	li	s6,1
    a += PGSIZE;
    800014b8:	6b85                	lui	s7,0x1
    800014ba:	a8b1                	j	80001516 <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    800014bc:	00008517          	auipc	a0,0x8
    800014c0:	df450513          	addi	a0,a0,-524 # 800092b0 <digits+0x140>
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	0a6080e7          	jalr	166(ra) # 8000056a <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800014cc:	862a                	mv	a2,a0
    800014ce:	85ca                	mv	a1,s2
    800014d0:	00008517          	auipc	a0,0x8
    800014d4:	df050513          	addi	a0,a0,-528 # 800092c0 <digits+0x150>
    800014d8:	fffff097          	auipc	ra,0xfffff
    800014dc:	0f4080e7          	jalr	244(ra) # 800005cc <printf>
      panic("uvmunmap: not mapped");
    800014e0:	00008517          	auipc	a0,0x8
    800014e4:	df050513          	addi	a0,a0,-528 # 800092d0 <digits+0x160>
    800014e8:	fffff097          	auipc	ra,0xfffff
    800014ec:	082080e7          	jalr	130(ra) # 8000056a <panic>
      panic("uvmunmap: not a leaf");
    800014f0:	00008517          	auipc	a0,0x8
    800014f4:	df850513          	addi	a0,a0,-520 # 800092e8 <digits+0x178>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	072080e7          	jalr	114(ra) # 8000056a <panic>
      pa = PTE2PA(*pte);
    80001500:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001502:	0532                	slli	a0,a0,0xc
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	442080e7          	jalr	1090(ra) # 80000946 <kfree>
    *pte = 0;
    8000150c:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001510:	03390763          	beq	s2,s3,8000153e <uvmunmap+0xb2>
    a += PGSIZE;
    80001514:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001516:	4601                	li	a2,0
    80001518:	85ca                	mv	a1,s2
    8000151a:	8552                	mv	a0,s4
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	c64080e7          	jalr	-924(ra) # 80001180 <walk>
    80001524:	84aa                	mv	s1,a0
    80001526:	d959                	beqz	a0,800014bc <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001528:	6108                	ld	a0,0(a0)
    8000152a:	00157793          	andi	a5,a0,1
    8000152e:	dfd9                	beqz	a5,800014cc <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001530:	3ff57793          	andi	a5,a0,1023
    80001534:	fb678ee3          	beq	a5,s6,800014f0 <uvmunmap+0x64>
    if(do_free){
    80001538:	fc0a8ae3          	beqz	s5,8000150c <uvmunmap+0x80>
    8000153c:	b7d1                	j	80001500 <uvmunmap+0x74>
}
    8000153e:	60a6                	ld	ra,72(sp)
    80001540:	6406                	ld	s0,64(sp)
    80001542:	74e2                	ld	s1,56(sp)
    80001544:	7942                	ld	s2,48(sp)
    80001546:	79a2                	ld	s3,40(sp)
    80001548:	7a02                	ld	s4,32(sp)
    8000154a:	6ae2                	ld	s5,24(sp)
    8000154c:	6b42                	ld	s6,16(sp)
    8000154e:	6ba2                	ld	s7,8(sp)
    80001550:	6161                	addi	sp,sp,80
    80001552:	8082                	ret

0000000080001554 <uvmcreate>:
{
    80001554:	1101                	addi	sp,sp,-32
    80001556:	ec06                	sd	ra,24(sp)
    80001558:	e822                	sd	s0,16(sp)
    8000155a:	e426                	sd	s1,8(sp)
    8000155c:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000155e:	fffff097          	auipc	ra,0xfffff
    80001562:	4ee080e7          	jalr	1262(ra) # 80000a4c <kalloc>
  if(pagetable == 0)
    80001566:	cd11                	beqz	a0,80001582 <uvmcreate+0x2e>
    80001568:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	4581                	li	a1,0
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	912080e7          	jalr	-1774(ra) # 80000e80 <memset>
}
    80001576:	8526                	mv	a0,s1
    80001578:	60e2                	ld	ra,24(sp)
    8000157a:	6442                	ld	s0,16(sp)
    8000157c:	64a2                	ld	s1,8(sp)
    8000157e:	6105                	addi	sp,sp,32
    80001580:	8082                	ret
    panic("uvmcreate: out of memory");
    80001582:	00008517          	auipc	a0,0x8
    80001586:	d7e50513          	addi	a0,a0,-642 # 80009300 <digits+0x190>
    8000158a:	fffff097          	auipc	ra,0xfffff
    8000158e:	fe0080e7          	jalr	-32(ra) # 8000056a <panic>

0000000080001592 <uvminit>:
{
    80001592:	7179                	addi	sp,sp,-48
    80001594:	f406                	sd	ra,40(sp)
    80001596:	f022                	sd	s0,32(sp)
    80001598:	ec26                	sd	s1,24(sp)
    8000159a:	e84a                	sd	s2,16(sp)
    8000159c:	e44e                	sd	s3,8(sp)
    8000159e:	e052                	sd	s4,0(sp)
    800015a0:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800015a2:	6785                	lui	a5,0x1
    800015a4:	04f67863          	bgeu	a2,a5,800015f4 <uvminit+0x62>
    800015a8:	8a2a                	mv	s4,a0
    800015aa:	89ae                	mv	s3,a1
    800015ac:	84b2                	mv	s1,a2
  mem = kalloc();
    800015ae:	fffff097          	auipc	ra,0xfffff
    800015b2:	49e080e7          	jalr	1182(ra) # 80000a4c <kalloc>
    800015b6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	4581                	li	a1,0
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	8c4080e7          	jalr	-1852(ra) # 80000e80 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015c4:	4779                	li	a4,30
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	4581                	li	a1,0
    800015cc:	8552                	mv	a0,s4
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	d28080e7          	jalr	-728(ra) # 800012f6 <mappages>
  memmove(mem, src, sz);
    800015d6:	8626                	mv	a2,s1
    800015d8:	85ce                	mv	a1,s3
    800015da:	854a                	mv	a0,s2
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	904080e7          	jalr	-1788(ra) # 80000ee0 <memmove>
}
    800015e4:	70a2                	ld	ra,40(sp)
    800015e6:	7402                	ld	s0,32(sp)
    800015e8:	64e2                	ld	s1,24(sp)
    800015ea:	6942                	ld	s2,16(sp)
    800015ec:	69a2                	ld	s3,8(sp)
    800015ee:	6a02                	ld	s4,0(sp)
    800015f0:	6145                	addi	sp,sp,48
    800015f2:	8082                	ret
    panic("inituvm: more than a page");
    800015f4:	00008517          	auipc	a0,0x8
    800015f8:	d2c50513          	addi	a0,a0,-724 # 80009320 <digits+0x1b0>
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	f6e080e7          	jalr	-146(ra) # 8000056a <panic>

0000000080001604 <uvmdealloc>:
{
    80001604:	1101                	addi	sp,sp,-32
    80001606:	ec06                	sd	ra,24(sp)
    80001608:	e822                	sd	s0,16(sp)
    8000160a:	e426                	sd	s1,8(sp)
    8000160c:	1000                	addi	s0,sp,32
    return oldsz;
    8000160e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001610:	00b67d63          	bgeu	a2,a1,8000162a <uvmdealloc+0x26>
    80001614:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001616:	6785                	lui	a5,0x1
    80001618:	17fd                	addi	a5,a5,-1
    8000161a:	00f60733          	add	a4,a2,a5
    8000161e:	76fd                	lui	a3,0xfffff
    80001620:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001622:	97ae                	add	a5,a5,a1
    80001624:	8ff5                	and	a5,a5,a3
    80001626:	00f76863          	bltu	a4,a5,80001636 <uvmdealloc+0x32>
}
    8000162a:	8526                	mv	a0,s1
    8000162c:	60e2                	ld	ra,24(sp)
    8000162e:	6442                	ld	s0,16(sp)
    80001630:	64a2                	ld	s1,8(sp)
    80001632:	6105                	addi	sp,sp,32
    80001634:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001636:	4685                	li	a3,1
    80001638:	40e58633          	sub	a2,a1,a4
    8000163c:	85ba                	mv	a1,a4
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	e4e080e7          	jalr	-434(ra) # 8000148c <uvmunmap>
    80001646:	b7d5                	j	8000162a <uvmdealloc+0x26>

0000000080001648 <uvmalloc>:
  if(newsz < oldsz)
    80001648:	0ab66163          	bltu	a2,a1,800016ea <uvmalloc+0xa2>
{
    8000164c:	7139                	addi	sp,sp,-64
    8000164e:	fc06                	sd	ra,56(sp)
    80001650:	f822                	sd	s0,48(sp)
    80001652:	f426                	sd	s1,40(sp)
    80001654:	f04a                	sd	s2,32(sp)
    80001656:	ec4e                	sd	s3,24(sp)
    80001658:	e852                	sd	s4,16(sp)
    8000165a:	e456                	sd	s5,8(sp)
    8000165c:	0080                	addi	s0,sp,64
    8000165e:	8aaa                	mv	s5,a0
    80001660:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001662:	6985                	lui	s3,0x1
    80001664:	19fd                	addi	s3,s3,-1
    80001666:	95ce                	add	a1,a1,s3
    80001668:	79fd                	lui	s3,0xfffff
    8000166a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000166e:	08c9f063          	bgeu	s3,a2,800016ee <uvmalloc+0xa6>
    80001672:	894e                	mv	s2,s3
    mem = kalloc();
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	3d8080e7          	jalr	984(ra) # 80000a4c <kalloc>
    8000167c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000167e:	c51d                	beqz	a0,800016ac <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001680:	6605                	lui	a2,0x1
    80001682:	4581                	li	a1,0
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	7fc080e7          	jalr	2044(ra) # 80000e80 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000168c:	4779                	li	a4,30
    8000168e:	86a6                	mv	a3,s1
    80001690:	6605                	lui	a2,0x1
    80001692:	85ca                	mv	a1,s2
    80001694:	8556                	mv	a0,s5
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	c60080e7          	jalr	-928(ra) # 800012f6 <mappages>
    8000169e:	e905                	bnez	a0,800016ce <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016a0:	6785                	lui	a5,0x1
    800016a2:	993e                	add	s2,s2,a5
    800016a4:	fd4968e3          	bltu	s2,s4,80001674 <uvmalloc+0x2c>
  return newsz;
    800016a8:	8552                	mv	a0,s4
    800016aa:	a809                	j	800016bc <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800016ac:	864e                	mv	a2,s3
    800016ae:	85ca                	mv	a1,s2
    800016b0:	8556                	mv	a0,s5
    800016b2:	00000097          	auipc	ra,0x0
    800016b6:	f52080e7          	jalr	-174(ra) # 80001604 <uvmdealloc>
      return 0;
    800016ba:	4501                	li	a0,0
}
    800016bc:	70e2                	ld	ra,56(sp)
    800016be:	7442                	ld	s0,48(sp)
    800016c0:	74a2                	ld	s1,40(sp)
    800016c2:	7902                	ld	s2,32(sp)
    800016c4:	69e2                	ld	s3,24(sp)
    800016c6:	6a42                	ld	s4,16(sp)
    800016c8:	6aa2                	ld	s5,8(sp)
    800016ca:	6121                	addi	sp,sp,64
    800016cc:	8082                	ret
      kfree(mem);
    800016ce:	8526                	mv	a0,s1
    800016d0:	fffff097          	auipc	ra,0xfffff
    800016d4:	276080e7          	jalr	630(ra) # 80000946 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016d8:	864e                	mv	a2,s3
    800016da:	85ca                	mv	a1,s2
    800016dc:	8556                	mv	a0,s5
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	f26080e7          	jalr	-218(ra) # 80001604 <uvmdealloc>
      return 0;
    800016e6:	4501                	li	a0,0
    800016e8:	bfd1                	j	800016bc <uvmalloc+0x74>
    return oldsz;
    800016ea:	852e                	mv	a0,a1
}
    800016ec:	8082                	ret
  return newsz;
    800016ee:	8532                	mv	a0,a2
    800016f0:	b7f1                	j	800016bc <uvmalloc+0x74>

00000000800016f2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016f2:	1101                	addi	sp,sp,-32
    800016f4:	ec06                	sd	ra,24(sp)
    800016f6:	e822                	sd	s0,16(sp)
    800016f8:	e426                	sd	s1,8(sp)
    800016fa:	1000                	addi	s0,sp,32
    800016fc:	84aa                	mv	s1,a0
    800016fe:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001700:	4685                	li	a3,1
    80001702:	4581                	li	a1,0
    80001704:	00000097          	auipc	ra,0x0
    80001708:	d88080e7          	jalr	-632(ra) # 8000148c <uvmunmap>
  freewalk(pagetable);
    8000170c:	8526                	mv	a0,s1
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	b18080e7          	jalr	-1256(ra) # 80001226 <freewalk>
}
    80001716:	60e2                	ld	ra,24(sp)
    80001718:	6442                	ld	s0,16(sp)
    8000171a:	64a2                	ld	s1,8(sp)
    8000171c:	6105                	addi	sp,sp,32
    8000171e:	8082                	ret

0000000080001720 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001720:	c671                	beqz	a2,800017ec <uvmcopy+0xcc>
{
    80001722:	715d                	addi	sp,sp,-80
    80001724:	e486                	sd	ra,72(sp)
    80001726:	e0a2                	sd	s0,64(sp)
    80001728:	fc26                	sd	s1,56(sp)
    8000172a:	f84a                	sd	s2,48(sp)
    8000172c:	f44e                	sd	s3,40(sp)
    8000172e:	f052                	sd	s4,32(sp)
    80001730:	ec56                	sd	s5,24(sp)
    80001732:	e85a                	sd	s6,16(sp)
    80001734:	e45e                	sd	s7,8(sp)
    80001736:	0880                	addi	s0,sp,80
    80001738:	8b2a                	mv	s6,a0
    8000173a:	8aae                	mv	s5,a1
    8000173c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000173e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001740:	4601                	li	a2,0
    80001742:	85ce                	mv	a1,s3
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	a3a080e7          	jalr	-1478(ra) # 80001180 <walk>
    8000174e:	c531                	beqz	a0,8000179a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001750:	6118                	ld	a4,0(a0)
    80001752:	00177793          	andi	a5,a4,1
    80001756:	cbb1                	beqz	a5,800017aa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001758:	00a75593          	srli	a1,a4,0xa
    8000175c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001760:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001764:	fffff097          	auipc	ra,0xfffff
    80001768:	2e8080e7          	jalr	744(ra) # 80000a4c <kalloc>
    8000176c:	892a                	mv	s2,a0
    8000176e:	c939                	beqz	a0,800017c4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001770:	6605                	lui	a2,0x1
    80001772:	85de                	mv	a1,s7
    80001774:	fffff097          	auipc	ra,0xfffff
    80001778:	76c080e7          	jalr	1900(ra) # 80000ee0 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000177c:	8726                	mv	a4,s1
    8000177e:	86ca                	mv	a3,s2
    80001780:	6605                	lui	a2,0x1
    80001782:	85ce                	mv	a1,s3
    80001784:	8556                	mv	a0,s5
    80001786:	00000097          	auipc	ra,0x0
    8000178a:	b70080e7          	jalr	-1168(ra) # 800012f6 <mappages>
    8000178e:	e515                	bnez	a0,800017ba <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001790:	6785                	lui	a5,0x1
    80001792:	99be                	add	s3,s3,a5
    80001794:	fb49e6e3          	bltu	s3,s4,80001740 <uvmcopy+0x20>
    80001798:	a83d                	j	800017d6 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    8000179a:	00008517          	auipc	a0,0x8
    8000179e:	ba650513          	addi	a0,a0,-1114 # 80009340 <digits+0x1d0>
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	dc8080e7          	jalr	-568(ra) # 8000056a <panic>
      panic("uvmcopy: page not present");
    800017aa:	00008517          	auipc	a0,0x8
    800017ae:	bb650513          	addi	a0,a0,-1098 # 80009360 <digits+0x1f0>
    800017b2:	fffff097          	auipc	ra,0xfffff
    800017b6:	db8080e7          	jalr	-584(ra) # 8000056a <panic>
      kfree(mem);
    800017ba:	854a                	mv	a0,s2
    800017bc:	fffff097          	auipc	ra,0xfffff
    800017c0:	18a080e7          	jalr	394(ra) # 80000946 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800017c4:	4685                	li	a3,1
    800017c6:	864e                	mv	a2,s3
    800017c8:	4581                	li	a1,0
    800017ca:	8556                	mv	a0,s5
    800017cc:	00000097          	auipc	ra,0x0
    800017d0:	cc0080e7          	jalr	-832(ra) # 8000148c <uvmunmap>
  return -1;
    800017d4:	557d                	li	a0,-1
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
  return 0;
    800017ec:	4501                	li	a0,0
}
    800017ee:	8082                	ret

00000000800017f0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017f0:	1141                	addi	sp,sp,-16
    800017f2:	e406                	sd	ra,8(sp)
    800017f4:	e022                	sd	s0,0(sp)
    800017f6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017f8:	4601                	li	a2,0
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	986080e7          	jalr	-1658(ra) # 80001180 <walk>
  if(pte == 0)
    80001802:	c901                	beqz	a0,80001812 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001804:	611c                	ld	a5,0(a0)
    80001806:	9bbd                	andi	a5,a5,-17
    80001808:	e11c                	sd	a5,0(a0)
}
    8000180a:	60a2                	ld	ra,8(sp)
    8000180c:	6402                	ld	s0,0(sp)
    8000180e:	0141                	addi	sp,sp,16
    80001810:	8082                	ret
    panic("uvmclear");
    80001812:	00008517          	auipc	a0,0x8
    80001816:	b6e50513          	addi	a0,a0,-1170 # 80009380 <digits+0x210>
    8000181a:	fffff097          	auipc	ra,0xfffff
    8000181e:	d50080e7          	jalr	-688(ra) # 8000056a <panic>

0000000080001822 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001822:	c6bd                	beqz	a3,80001890 <copyout+0x6e>
{
    80001824:	715d                	addi	sp,sp,-80
    80001826:	e486                	sd	ra,72(sp)
    80001828:	e0a2                	sd	s0,64(sp)
    8000182a:	fc26                	sd	s1,56(sp)
    8000182c:	f84a                	sd	s2,48(sp)
    8000182e:	f44e                	sd	s3,40(sp)
    80001830:	f052                	sd	s4,32(sp)
    80001832:	ec56                	sd	s5,24(sp)
    80001834:	e85a                	sd	s6,16(sp)
    80001836:	e45e                	sd	s7,8(sp)
    80001838:	e062                	sd	s8,0(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8b2a                	mv	s6,a0
    8000183e:	8c2e                	mv	s8,a1
    80001840:	8a32                	mv	s4,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001844:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001846:	6a85                	lui	s5,0x1
    80001848:	a015                	j	8000186c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000184a:	9562                	add	a0,a0,s8
    8000184c:	0004861b          	sext.w	a2,s1
    80001850:	85d2                	mv	a1,s4
    80001852:	41250533          	sub	a0,a0,s2
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	68a080e7          	jalr	1674(ra) # 80000ee0 <memmove>

    len -= n;
    8000185e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001862:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001864:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001868:	02098263          	beqz	s3,8000188c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000186c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001870:	85ca                	mv	a1,s2
    80001872:	855a                	mv	a0,s6
    80001874:	00000097          	auipc	ra,0x0
    80001878:	a40080e7          	jalr	-1472(ra) # 800012b4 <walkaddr>
    if(pa0 == 0)
    8000187c:	cd01                	beqz	a0,80001894 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000187e:	418904b3          	sub	s1,s2,s8
    80001882:	94d6                	add	s1,s1,s5
    if(n > len)
    80001884:	fc99f3e3          	bgeu	s3,s1,8000184a <copyout+0x28>
    80001888:	84ce                	mv	s1,s3
    8000188a:	b7c1                	j	8000184a <copyout+0x28>
  }
  return 0;
    8000188c:	4501                	li	a0,0
    8000188e:	a021                	j	80001896 <copyout+0x74>
    80001890:	4501                	li	a0,0
}
    80001892:	8082                	ret
      return -1;
    80001894:	557d                	li	a0,-1
}
    80001896:	60a6                	ld	ra,72(sp)
    80001898:	6406                	ld	s0,64(sp)
    8000189a:	74e2                	ld	s1,56(sp)
    8000189c:	7942                	ld	s2,48(sp)
    8000189e:	79a2                	ld	s3,40(sp)
    800018a0:	7a02                	ld	s4,32(sp)
    800018a2:	6ae2                	ld	s5,24(sp)
    800018a4:	6b42                	ld	s6,16(sp)
    800018a6:	6ba2                	ld	s7,8(sp)
    800018a8:	6c02                	ld	s8,0(sp)
    800018aa:	6161                	addi	sp,sp,80
    800018ac:	8082                	ret

00000000800018ae <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018ae:	c6bd                	beqz	a3,8000191c <copyin+0x6e>
{
    800018b0:	715d                	addi	sp,sp,-80
    800018b2:	e486                	sd	ra,72(sp)
    800018b4:	e0a2                	sd	s0,64(sp)
    800018b6:	fc26                	sd	s1,56(sp)
    800018b8:	f84a                	sd	s2,48(sp)
    800018ba:	f44e                	sd	s3,40(sp)
    800018bc:	f052                	sd	s4,32(sp)
    800018be:	ec56                	sd	s5,24(sp)
    800018c0:	e85a                	sd	s6,16(sp)
    800018c2:	e45e                	sd	s7,8(sp)
    800018c4:	e062                	sd	s8,0(sp)
    800018c6:	0880                	addi	s0,sp,80
    800018c8:	8b2a                	mv	s6,a0
    800018ca:	8a2e                	mv	s4,a1
    800018cc:	8c32                	mv	s8,a2
    800018ce:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018d0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d2:	6a85                	lui	s5,0x1
    800018d4:	a015                	j	800018f8 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018d6:	9562                	add	a0,a0,s8
    800018d8:	0004861b          	sext.w	a2,s1
    800018dc:	412505b3          	sub	a1,a0,s2
    800018e0:	8552                	mv	a0,s4
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	5fe080e7          	jalr	1534(ra) # 80000ee0 <memmove>

    len -= n;
    800018ea:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ee:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018f0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018f4:	02098263          	beqz	s3,80001918 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800018f8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018fc:	85ca                	mv	a1,s2
    800018fe:	855a                	mv	a0,s6
    80001900:	00000097          	auipc	ra,0x0
    80001904:	9b4080e7          	jalr	-1612(ra) # 800012b4 <walkaddr>
    if(pa0 == 0)
    80001908:	cd01                	beqz	a0,80001920 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000190a:	418904b3          	sub	s1,s2,s8
    8000190e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001910:	fc99f3e3          	bgeu	s3,s1,800018d6 <copyin+0x28>
    80001914:	84ce                	mv	s1,s3
    80001916:	b7c1                	j	800018d6 <copyin+0x28>
  }
  return 0;
    80001918:	4501                	li	a0,0
    8000191a:	a021                	j	80001922 <copyin+0x74>
    8000191c:	4501                	li	a0,0
}
    8000191e:	8082                	ret
      return -1;
    80001920:	557d                	li	a0,-1
}
    80001922:	60a6                	ld	ra,72(sp)
    80001924:	6406                	ld	s0,64(sp)
    80001926:	74e2                	ld	s1,56(sp)
    80001928:	7942                	ld	s2,48(sp)
    8000192a:	79a2                	ld	s3,40(sp)
    8000192c:	7a02                	ld	s4,32(sp)
    8000192e:	6ae2                	ld	s5,24(sp)
    80001930:	6b42                	ld	s6,16(sp)
    80001932:	6ba2                	ld	s7,8(sp)
    80001934:	6c02                	ld	s8,0(sp)
    80001936:	6161                	addi	sp,sp,80
    80001938:	8082                	ret

000000008000193a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000193a:	c6c5                	beqz	a3,800019e2 <copyinstr+0xa8>
{
    8000193c:	715d                	addi	sp,sp,-80
    8000193e:	e486                	sd	ra,72(sp)
    80001940:	e0a2                	sd	s0,64(sp)
    80001942:	fc26                	sd	s1,56(sp)
    80001944:	f84a                	sd	s2,48(sp)
    80001946:	f44e                	sd	s3,40(sp)
    80001948:	f052                	sd	s4,32(sp)
    8000194a:	ec56                	sd	s5,24(sp)
    8000194c:	e85a                	sd	s6,16(sp)
    8000194e:	e45e                	sd	s7,8(sp)
    80001950:	0880                	addi	s0,sp,80
    80001952:	8a2a                	mv	s4,a0
    80001954:	8b2e                	mv	s6,a1
    80001956:	8bb2                	mv	s7,a2
    80001958:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000195a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000195c:	6985                	lui	s3,0x1
    8000195e:	a035                	j	8000198a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001960:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001964:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001966:	0017b793          	seqz	a5,a5
    8000196a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000196e:	60a6                	ld	ra,72(sp)
    80001970:	6406                	ld	s0,64(sp)
    80001972:	74e2                	ld	s1,56(sp)
    80001974:	7942                	ld	s2,48(sp)
    80001976:	79a2                	ld	s3,40(sp)
    80001978:	7a02                	ld	s4,32(sp)
    8000197a:	6ae2                	ld	s5,24(sp)
    8000197c:	6b42                	ld	s6,16(sp)
    8000197e:	6ba2                	ld	s7,8(sp)
    80001980:	6161                	addi	sp,sp,80
    80001982:	8082                	ret
    srcva = va0 + PGSIZE;
    80001984:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001988:	c8a9                	beqz	s1,800019da <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000198a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000198e:	85ca                	mv	a1,s2
    80001990:	8552                	mv	a0,s4
    80001992:	00000097          	auipc	ra,0x0
    80001996:	922080e7          	jalr	-1758(ra) # 800012b4 <walkaddr>
    if(pa0 == 0)
    8000199a:	c131                	beqz	a0,800019de <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000199c:	41790833          	sub	a6,s2,s7
    800019a0:	984e                	add	a6,a6,s3
    if(n > max)
    800019a2:	0104f363          	bgeu	s1,a6,800019a8 <copyinstr+0x6e>
    800019a6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019a8:	955e                	add	a0,a0,s7
    800019aa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800019ae:	fc080be3          	beqz	a6,80001984 <copyinstr+0x4a>
    800019b2:	985a                	add	a6,a6,s6
    800019b4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800019b6:	41650633          	sub	a2,a0,s6
    800019ba:	14fd                	addi	s1,s1,-1
    800019bc:	9b26                	add	s6,s6,s1
    800019be:	00f60733          	add	a4,a2,a5
    800019c2:	00074703          	lbu	a4,0(a4)
    800019c6:	df49                	beqz	a4,80001960 <copyinstr+0x26>
        *dst = *p;
    800019c8:	00e78023          	sb	a4,0(a5)
      --max;
    800019cc:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019d0:	0785                	addi	a5,a5,1
    while(n > 0){
    800019d2:	ff0796e3          	bne	a5,a6,800019be <copyinstr+0x84>
      dst++;
    800019d6:	8b42                	mv	s6,a6
    800019d8:	b775                	j	80001984 <copyinstr+0x4a>
    800019da:	4781                	li	a5,0
    800019dc:	b769                	j	80001966 <copyinstr+0x2c>
      return -1;
    800019de:	557d                	li	a0,-1
    800019e0:	b779                	j	8000196e <copyinstr+0x34>
  int got_null = 0;
    800019e2:	4781                	li	a5,0
  if(got_null){
    800019e4:	0017b793          	seqz	a5,a5
    800019e8:	40f00533          	neg	a0,a5
}
    800019ec:	8082                	ret

00000000800019ee <kwalkaddr>:
kwalkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t* pte;
  uint64 pa;

  if(va>= MAXVA)
    800019ee:	57fd                	li	a5,-1
    800019f0:	83e9                	srli	a5,a5,0x1a
    800019f2:	00b7f463          	bgeu	a5,a1,800019fa <kwalkaddr+0xc>
    return 0;
    800019f6:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_V) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
    800019f8:	8082                	ret
{
    800019fa:	1141                	addi	sp,sp,-16
    800019fc:	e406                	sd	ra,8(sp)
    800019fe:	e022                	sd	s0,0(sp)
    80001a00:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001a02:	4601                	li	a2,0
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	77c080e7          	jalr	1916(ra) # 80001180 <walk>
  if (pte == 0)
    80001a0c:	cd01                	beqz	a0,80001a24 <kwalkaddr+0x36>
  if ((*pte & PTE_V) == 0)
    80001a0e:	611c                	ld	a5,0(a0)
    80001a10:	0017f513          	andi	a0,a5,1
    80001a14:	c501                	beqz	a0,80001a1c <kwalkaddr+0x2e>
  pa = PTE2PA(*pte);
    80001a16:	00a7d513          	srli	a0,a5,0xa
    80001a1a:	0532                	slli	a0,a0,0xc
    80001a1c:	60a2                	ld	ra,8(sp)
    80001a1e:	6402                	ld	s0,0(sp)
    80001a20:	0141                	addi	sp,sp,16
    80001a22:	8082                	ret
    return 0;
    80001a24:	4501                	li	a0,0
    80001a26:	bfdd                	j	80001a1c <kwalkaddr+0x2e>

0000000080001a28 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a28:	1101                	addi	sp,sp,-32
    80001a2a:	ec06                	sd	ra,24(sp)
    80001a2c:	e822                	sd	s0,16(sp)
    80001a2e:	e426                	sd	s1,8(sp)
    80001a30:	1000                	addi	s0,sp,32
    80001a32:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	0ea080e7          	jalr	234(ra) # 80000b1e <holding>
    80001a3c:	c909                	beqz	a0,80001a4e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a3e:	789c                	ld	a5,48(s1)
    80001a40:	00978f63          	beq	a5,s1,80001a5e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret
    panic("wakeup1");
    80001a4e:	00008517          	auipc	a0,0x8
    80001a52:	94250513          	addi	a0,a0,-1726 # 80009390 <digits+0x220>
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	b14080e7          	jalr	-1260(ra) # 8000056a <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a5e:	5098                	lw	a4,32(s1)
    80001a60:	4785                	li	a5,1
    80001a62:	fef711e3          	bne	a4,a5,80001a44 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a66:	4789                	li	a5,2
    80001a68:	d09c                	sw	a5,32(s1)
}
    80001a6a:	bfe9                	j	80001a44 <wakeup1+0x1c>

0000000080001a6c <rcu_free_callback>:
}

// Callback executed after the grace period.
static void
rcu_free_callback(struct rcu_head *head)
{
    80001a6c:	1101                	addi	sp,sp,-32
    80001a6e:	ec06                	sd	ra,24(sp)
    80001a70:	e822                	sd	s0,16(sp)
    80001a72:	e426                	sd	s1,8(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	84aa                	mv	s1,a0
  struct test_data *d = rcu_to_test_data(head);
  printf("[callback] free old value=%d\n", d->value);
    80001a78:	ff852583          	lw	a1,-8(a0)
    80001a7c:	00008517          	auipc	a0,0x8
    80001a80:	91c50513          	addi	a0,a0,-1764 # 80009398 <digits+0x228>
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	b48080e7          	jalr	-1208(ra) # 800005cc <printf>
  kfree((char *)d);
    80001a8c:	ff848513          	addi	a0,s1,-8
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	eb6080e7          	jalr	-330(ra) # 80000946 <kfree>
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <procinit>:
{
    80001aa2:	715d                	addi	sp,sp,-80
    80001aa4:	e486                	sd	ra,72(sp)
    80001aa6:	e0a2                	sd	s0,64(sp)
    80001aa8:	fc26                	sd	s1,56(sp)
    80001aaa:	f84a                	sd	s2,48(sp)
    80001aac:	f44e                	sd	s3,40(sp)
    80001aae:	f052                	sd	s4,32(sp)
    80001ab0:	ec56                	sd	s5,24(sp)
    80001ab2:	e85a                	sd	s6,16(sp)
    80001ab4:	e45e                	sd	s7,8(sp)
    80001ab6:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001ab8:	00008597          	auipc	a1,0x8
    80001abc:	90058593          	addi	a1,a1,-1792 # 800093b8 <digits+0x248>
    80001ac0:	00024517          	auipc	a0,0x24
    80001ac4:	05850513          	addi	a0,a0,88 # 80025b18 <pid_lock>
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	ffe080e7          	jalr	-2(ra) # 80000ac6 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad0:	00024917          	auipc	s2,0x24
    80001ad4:	46890913          	addi	s2,s2,1128 # 80025f38 <proc>
      initlock(&p->lock, "proc");
    80001ad8:	00008b97          	auipc	s7,0x8
    80001adc:	8e8b8b93          	addi	s7,s7,-1816 # 800093c0 <digits+0x250>
      uint64 va = KSTACK((int) (p - proc));
    80001ae0:	8b4a                	mv	s6,s2
    80001ae2:	00007a97          	auipc	s5,0x7
    80001ae6:	51ea8a93          	addi	s5,s5,1310 # 80009000 <etext>
    80001aea:	040009b7          	lui	s3,0x4000
    80001aee:	19fd                	addi	s3,s3,-1
    80001af0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af2:	0002aa17          	auipc	s4,0x2a
    80001af6:	246a0a13          	addi	s4,s4,582 # 8002bd38 <tickslock>
      initlock(&p->lock, "proc");
    80001afa:	85de                	mv	a1,s7
    80001afc:	854a                	mv	a0,s2
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	fc8080e7          	jalr	-56(ra) # 80000ac6 <initlock>
      char *pa = kalloc();
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	f46080e7          	jalr	-186(ra) # 80000a4c <kalloc>
    80001b0e:	85aa                	mv	a1,a0
      if(pa == 0)
    80001b10:	c929                	beqz	a0,80001b62 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001b12:	416904b3          	sub	s1,s2,s6
    80001b16:	848d                	srai	s1,s1,0x3
    80001b18:	000ab783          	ld	a5,0(s5)
    80001b1c:	02f484b3          	mul	s1,s1,a5
    80001b20:	2485                	addiw	s1,s1,1
    80001b22:	00d4949b          	slliw	s1,s1,0xd
    80001b26:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b2a:	4699                	li	a3,6
    80001b2c:	6605                	lui	a2,0x1
    80001b2e:	8526                	mv	a0,s1
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	866080e7          	jalr	-1946(ra) # 80001396 <kvmmap>
      p->kstack = va;
    80001b38:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b3c:	17890913          	addi	s2,s2,376
    80001b40:	fb491de3          	bne	s2,s4,80001afa <procinit+0x58>
  kvminithart();
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	74c080e7          	jalr	1868(ra) # 80001290 <kvminithart>
}
    80001b4c:	60a6                	ld	ra,72(sp)
    80001b4e:	6406                	ld	s0,64(sp)
    80001b50:	74e2                	ld	s1,56(sp)
    80001b52:	7942                	ld	s2,48(sp)
    80001b54:	79a2                	ld	s3,40(sp)
    80001b56:	7a02                	ld	s4,32(sp)
    80001b58:	6ae2                	ld	s5,24(sp)
    80001b5a:	6b42                	ld	s6,16(sp)
    80001b5c:	6ba2                	ld	s7,8(sp)
    80001b5e:	6161                	addi	sp,sp,80
    80001b60:	8082                	ret
        panic("kalloc");
    80001b62:	00008517          	auipc	a0,0x8
    80001b66:	86650513          	addi	a0,a0,-1946 # 800093c8 <digits+0x258>
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	a00080e7          	jalr	-1536(ra) # 8000056a <panic>

0000000080001b72 <cpuid>:
{
    80001b72:	1141                	addi	sp,sp,-16
    80001b74:	e422                	sd	s0,8(sp)
    80001b76:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b78:	8512                	mv	a0,tp
}
    80001b7a:	2501                	sext.w	a0,a0
    80001b7c:	6422                	ld	s0,8(sp)
    80001b7e:	0141                	addi	sp,sp,16
    80001b80:	8082                	ret

0000000080001b82 <mycpu>:
mycpu(void) {
    80001b82:	1141                	addi	sp,sp,-16
    80001b84:	e422                	sd	s0,8(sp)
    80001b86:	0800                	addi	s0,sp,16
    80001b88:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b8a:	2781                	sext.w	a5,a5
    80001b8c:	079e                	slli	a5,a5,0x7
}
    80001b8e:	00024517          	auipc	a0,0x24
    80001b92:	faa50513          	addi	a0,a0,-86 # 80025b38 <cpus>
    80001b96:	953e                	add	a0,a0,a5
    80001b98:	6422                	ld	s0,8(sp)
    80001b9a:	0141                	addi	sp,sp,16
    80001b9c:	8082                	ret

0000000080001b9e <myproc>:
myproc(void) {
    80001b9e:	1101                	addi	sp,sp,-32
    80001ba0:	ec06                	sd	ra,24(sp)
    80001ba2:	e822                	sd	s0,16(sp)
    80001ba4:	e426                	sd	s1,8(sp)
    80001ba6:	1000                	addi	s0,sp,32
  push_off();
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	fa4080e7          	jalr	-92(ra) # 80000b4c <push_off>
    80001bb0:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001bb2:	2781                	sext.w	a5,a5
    80001bb4:	079e                	slli	a5,a5,0x7
    80001bb6:	00024717          	auipc	a4,0x24
    80001bba:	f6270713          	addi	a4,a4,-158 # 80025b18 <pid_lock>
    80001bbe:	97ba                	add	a5,a5,a4
    80001bc0:	7384                	ld	s1,32(a5)
  pop_off();
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	04a080e7          	jalr	74(ra) # 80000c0c <pop_off>
}
    80001bca:	8526                	mv	a0,s1
    80001bcc:	60e2                	ld	ra,24(sp)
    80001bce:	6442                	ld	s0,16(sp)
    80001bd0:	64a2                	ld	s1,8(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <forkret>:
{
    80001bd6:	1141                	addi	sp,sp,-16
    80001bd8:	e406                	sd	ra,8(sp)
    80001bda:	e022                	sd	s0,0(sp)
    80001bdc:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	fc0080e7          	jalr	-64(ra) # 80001b9e <myproc>
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	086080e7          	jalr	134(ra) # 80000c6c <release>
  if (first) {
    80001bee:	00008797          	auipc	a5,0x8
    80001bf2:	3a27a783          	lw	a5,930(a5) # 80009f90 <first.1831>
    80001bf6:	eb89                	bnez	a5,80001c08 <forkret+0x32>
  usertrapret();
    80001bf8:	00001097          	auipc	ra,0x1
    80001bfc:	d6a080e7          	jalr	-662(ra) # 80002962 <usertrapret>
}
    80001c00:	60a2                	ld	ra,8(sp)
    80001c02:	6402                	ld	s0,0(sp)
    80001c04:	0141                	addi	sp,sp,16
    80001c06:	8082                	ret
    first = 0;
    80001c08:	00008797          	auipc	a5,0x8
    80001c0c:	3807a423          	sw	zero,904(a5) # 80009f90 <first.1831>
    fsinit(ROOTDEV);
    80001c10:	4505                	li	a0,1
    80001c12:	00002097          	auipc	ra,0x2
    80001c16:	a9c080e7          	jalr	-1380(ra) # 800036ae <fsinit>
    80001c1a:	bff9                	j	80001bf8 <forkret+0x22>

0000000080001c1c <allocpid>:
allocpid() {
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c28:	00024917          	auipc	s2,0x24
    80001c2c:	ef090913          	addi	s2,s2,-272 # 80025b18 <pid_lock>
    80001c30:	854a                	mv	a0,s2
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	f6a080e7          	jalr	-150(ra) # 80000b9c <acquire>
  pid = nextpid;
    80001c3a:	00008797          	auipc	a5,0x8
    80001c3e:	35a78793          	addi	a5,a5,858 # 80009f94 <nextpid>
    80001c42:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c44:	0014871b          	addiw	a4,s1,1
    80001c48:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c4a:	854a                	mv	a0,s2
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	020080e7          	jalr	32(ra) # 80000c6c <release>
}
    80001c54:	8526                	mv	a0,s1
    80001c56:	60e2                	ld	ra,24(sp)
    80001c58:	6442                	ld	s0,16(sp)
    80001c5a:	64a2                	ld	s1,8(sp)
    80001c5c:	6902                	ld	s2,0(sp)
    80001c5e:	6105                	addi	sp,sp,32
    80001c60:	8082                	ret

0000000080001c62 <proc_pagetable>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	e04a                	sd	s2,0(sp)
    80001c6c:	1000                	addi	s0,sp,32
    80001c6e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	8e4080e7          	jalr	-1820(ra) # 80001554 <uvmcreate>
    80001c78:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c7a:	4729                	li	a4,10
    80001c7c:	00006697          	auipc	a3,0x6
    80001c80:	38468693          	addi	a3,a3,900 # 80008000 <_trampoline>
    80001c84:	6605                	lui	a2,0x1
    80001c86:	040005b7          	lui	a1,0x4000
    80001c8a:	15fd                	addi	a1,a1,-1
    80001c8c:	05b2                	slli	a1,a1,0xc
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	668080e7          	jalr	1640(ra) # 800012f6 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c96:	4719                	li	a4,6
    80001c98:	06093683          	ld	a3,96(s2)
    80001c9c:	6605                	lui	a2,0x1
    80001c9e:	020005b7          	lui	a1,0x2000
    80001ca2:	15fd                	addi	a1,a1,-1
    80001ca4:	05b6                	slli	a1,a1,0xd
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	64e080e7          	jalr	1614(ra) # 800012f6 <mappages>
}
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6902                	ld	s2,0(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret

0000000080001cbe <allocproc>:
{
    80001cbe:	1101                	addi	sp,sp,-32
    80001cc0:	ec06                	sd	ra,24(sp)
    80001cc2:	e822                	sd	s0,16(sp)
    80001cc4:	e426                	sd	s1,8(sp)
    80001cc6:	e04a                	sd	s2,0(sp)
    80001cc8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cca:	00024497          	auipc	s1,0x24
    80001cce:	26e48493          	addi	s1,s1,622 # 80025f38 <proc>
    80001cd2:	0002a917          	auipc	s2,0x2a
    80001cd6:	06690913          	addi	s2,s2,102 # 8002bd38 <tickslock>
    acquire(&p->lock);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	ec0080e7          	jalr	-320(ra) # 80000b9c <acquire>
    if(p->state == UNUSED) {
    80001ce4:	509c                	lw	a5,32(s1)
    80001ce6:	cf81                	beqz	a5,80001cfe <allocproc+0x40>
      release(&p->lock);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	f82080e7          	jalr	-126(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cf2:	17848493          	addi	s1,s1,376
    80001cf6:	ff2492e3          	bne	s1,s2,80001cda <allocproc+0x1c>
  return 0;
    80001cfa:	4481                	li	s1,0
    80001cfc:	a899                	j	80001d52 <allocproc+0x94>
  p->pid = allocpid();
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	f1e080e7          	jalr	-226(ra) # 80001c1c <allocpid>
    80001d06:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d08:	fffff097          	auipc	ra,0xfffff
    80001d0c:	d44080e7          	jalr	-700(ra) # 80000a4c <kalloc>
    80001d10:	892a                	mv	s2,a0
    80001d12:	f0a8                	sd	a0,96(s1)
    80001d14:	c531                	beqz	a0,80001d60 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001d16:	8526                	mv	a0,s1
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	f4a080e7          	jalr	-182(ra) # 80001c62 <proc_pagetable>
    80001d20:	eca8                	sd	a0,88(s1)
  p->trap_va = TRAPFRAME;
    80001d22:	020007b7          	lui	a5,0x2000
    80001d26:	17fd                	addi	a5,a5,-1
    80001d28:	07b6                	slli	a5,a5,0xd
    80001d2a:	16f4b823          	sd	a5,368(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001d2e:	07000613          	li	a2,112
    80001d32:	4581                	li	a1,0
    80001d34:	06848513          	addi	a0,s1,104
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	148080e7          	jalr	328(ra) # 80000e80 <memset>
  p->context.ra = (uint64)forkret;
    80001d40:	00000797          	auipc	a5,0x0
    80001d44:	e9678793          	addi	a5,a5,-362 # 80001bd6 <forkret>
    80001d48:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d4a:	64bc                	ld	a5,72(s1)
    80001d4c:	6705                	lui	a4,0x1
    80001d4e:	97ba                	add	a5,a5,a4
    80001d50:	f8bc                	sd	a5,112(s1)
}
    80001d52:	8526                	mv	a0,s1
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6902                	ld	s2,0(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret
    release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	f0a080e7          	jalr	-246(ra) # 80000c6c <release>
    return 0;
    80001d6a:	84ca                	mv	s1,s2
    80001d6c:	b7dd                	j	80001d52 <allocproc+0x94>

0000000080001d6e <proc_freepagetable>:
{
    80001d6e:	1101                	addi	sp,sp,-32
    80001d70:	ec06                	sd	ra,24(sp)
    80001d72:	e822                	sd	s0,16(sp)
    80001d74:	e426                	sd	s1,8(sp)
    80001d76:	e04a                	sd	s2,0(sp)
    80001d78:	1000                	addi	s0,sp,32
    80001d7a:	84aa                	mv	s1,a0
    80001d7c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d7e:	4681                	li	a3,0
    80001d80:	6605                	lui	a2,0x1
    80001d82:	040005b7          	lui	a1,0x4000
    80001d86:	15fd                	addi	a1,a1,-1
    80001d88:	05b2                	slli	a1,a1,0xc
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	702080e7          	jalr	1794(ra) # 8000148c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d92:	4681                	li	a3,0
    80001d94:	6605                	lui	a2,0x1
    80001d96:	020005b7          	lui	a1,0x2000
    80001d9a:	15fd                	addi	a1,a1,-1
    80001d9c:	05b6                	slli	a1,a1,0xd
    80001d9e:	8526                	mv	a0,s1
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	6ec080e7          	jalr	1772(ra) # 8000148c <uvmunmap>
  if(sz > 0)
    80001da8:	00091863          	bnez	s2,80001db8 <proc_freepagetable+0x4a>
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6902                	ld	s2,0(sp)
    80001db4:	6105                	addi	sp,sp,32
    80001db6:	8082                	ret
    uvmfree(pagetable, sz);
    80001db8:	85ca                	mv	a1,s2
    80001dba:	8526                	mv	a0,s1
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	936080e7          	jalr	-1738(ra) # 800016f2 <uvmfree>
}
    80001dc4:	b7e5                	j	80001dac <proc_freepagetable+0x3e>

0000000080001dc6 <freeproc>:
{
    80001dc6:	1101                	addi	sp,sp,-32
    80001dc8:	ec06                	sd	ra,24(sp)
    80001dca:	e822                	sd	s0,16(sp)
    80001dcc:	e426                	sd	s1,8(sp)
    80001dce:	1000                	addi	s0,sp,32
    80001dd0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001dd2:	7128                	ld	a0,96(a0)
    80001dd4:	c509                	beqz	a0,80001dde <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001dd6:	fffff097          	auipc	ra,0xfffff
    80001dda:	b70080e7          	jalr	-1168(ra) # 80000946 <kfree>
  p->trapframe = 0;
    80001dde:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001de2:	6ca8                	ld	a0,88(s1)
    80001de4:	c511                	beqz	a0,80001df0 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001de6:	68ac                	ld	a1,80(s1)
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	f86080e7          	jalr	-122(ra) # 80001d6e <proc_freepagetable>
  p->pagetable = 0;
    80001df0:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001df4:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001df8:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001dfc:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001e00:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001e04:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001e08:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001e0c:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001e10:	0204a023          	sw	zero,32(s1)
}
    80001e14:	60e2                	ld	ra,24(sp)
    80001e16:	6442                	ld	s0,16(sp)
    80001e18:	64a2                	ld	s1,8(sp)
    80001e1a:	6105                	addi	sp,sp,32
    80001e1c:	8082                	ret

0000000080001e1e <userinit>:
{
    80001e1e:	1101                	addi	sp,sp,-32
    80001e20:	ec06                	sd	ra,24(sp)
    80001e22:	e822                	sd	s0,16(sp)
    80001e24:	e426                	sd	s1,8(sp)
    80001e26:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	e96080e7          	jalr	-362(ra) # 80001cbe <allocproc>
    80001e30:	84aa                	mv	s1,a0
  initproc = p;
    80001e32:	00008797          	auipc	a5,0x8
    80001e36:	1ea7b723          	sd	a0,494(a5) # 8000a020 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e3a:	03400613          	li	a2,52
    80001e3e:	00008597          	auipc	a1,0x8
    80001e42:	16258593          	addi	a1,a1,354 # 80009fa0 <initcode>
    80001e46:	6d28                	ld	a0,88(a0)
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	74a080e7          	jalr	1866(ra) # 80001592 <uvminit>
  p->sz = PGSIZE;
    80001e50:	6785                	lui	a5,0x1
    80001e52:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e54:	70b8                	ld	a4,96(s1)
    80001e56:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e5a:	70b8                	ld	a4,96(s1)
    80001e5c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e5e:	4641                	li	a2,16
    80001e60:	00007597          	auipc	a1,0x7
    80001e64:	57058593          	addi	a1,a1,1392 # 800093d0 <digits+0x260>
    80001e68:	16048513          	addi	a0,s1,352
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	192080e7          	jalr	402(ra) # 80000ffe <safestrcpy>
  p->cwd = namei("/");
    80001e74:	00007517          	auipc	a0,0x7
    80001e78:	56c50513          	addi	a0,a0,1388 # 800093e0 <digits+0x270>
    80001e7c:	00002097          	auipc	ra,0x2
    80001e80:	260080e7          	jalr	608(ra) # 800040dc <namei>
    80001e84:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e88:	4789                	li	a5,2
    80001e8a:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	dde080e7          	jalr	-546(ra) # 80000c6c <release>
}
    80001e96:	60e2                	ld	ra,24(sp)
    80001e98:	6442                	ld	s0,16(sp)
    80001e9a:	64a2                	ld	s1,8(sp)
    80001e9c:	6105                	addi	sp,sp,32
    80001e9e:	8082                	ret

0000000080001ea0 <growproc>:
{
    80001ea0:	1101                	addi	sp,sp,-32
    80001ea2:	ec06                	sd	ra,24(sp)
    80001ea4:	e822                	sd	s0,16(sp)
    80001ea6:	e426                	sd	s1,8(sp)
    80001ea8:	e04a                	sd	s2,0(sp)
    80001eaa:	1000                	addi	s0,sp,32
    80001eac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001eae:	00000097          	auipc	ra,0x0
    80001eb2:	cf0080e7          	jalr	-784(ra) # 80001b9e <myproc>
    80001eb6:	892a                	mv	s2,a0
  sz = p->sz;
    80001eb8:	692c                	ld	a1,80(a0)
    80001eba:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001ebe:	00904f63          	bgtz	s1,80001edc <growproc+0x3c>
  } else if(n < 0){
    80001ec2:	0204cc63          	bltz	s1,80001efa <growproc+0x5a>
  p->sz = sz;
    80001ec6:	1602                	slli	a2,a2,0x20
    80001ec8:	9201                	srli	a2,a2,0x20
    80001eca:	04c93823          	sd	a2,80(s2)
  return 0;
    80001ece:	4501                	li	a0,0
}
    80001ed0:	60e2                	ld	ra,24(sp)
    80001ed2:	6442                	ld	s0,16(sp)
    80001ed4:	64a2                	ld	s1,8(sp)
    80001ed6:	6902                	ld	s2,0(sp)
    80001ed8:	6105                	addi	sp,sp,32
    80001eda:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001edc:	9e25                	addw	a2,a2,s1
    80001ede:	1602                	slli	a2,a2,0x20
    80001ee0:	9201                	srli	a2,a2,0x20
    80001ee2:	1582                	slli	a1,a1,0x20
    80001ee4:	9181                	srli	a1,a1,0x20
    80001ee6:	6d28                	ld	a0,88(a0)
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	760080e7          	jalr	1888(ra) # 80001648 <uvmalloc>
    80001ef0:	0005061b          	sext.w	a2,a0
    80001ef4:	fa69                	bnez	a2,80001ec6 <growproc+0x26>
      return -1;
    80001ef6:	557d                	li	a0,-1
    80001ef8:	bfe1                	j	80001ed0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001efa:	9e25                	addw	a2,a2,s1
    80001efc:	1602                	slli	a2,a2,0x20
    80001efe:	9201                	srli	a2,a2,0x20
    80001f00:	1582                	slli	a1,a1,0x20
    80001f02:	9181                	srli	a1,a1,0x20
    80001f04:	6d28                	ld	a0,88(a0)
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	6fe080e7          	jalr	1790(ra) # 80001604 <uvmdealloc>
    80001f0e:	0005061b          	sext.w	a2,a0
    80001f12:	bf55                	j	80001ec6 <growproc+0x26>

0000000080001f14 <fork>:
{
    80001f14:	7179                	addi	sp,sp,-48
    80001f16:	f406                	sd	ra,40(sp)
    80001f18:	f022                	sd	s0,32(sp)
    80001f1a:	ec26                	sd	s1,24(sp)
    80001f1c:	e84a                	sd	s2,16(sp)
    80001f1e:	e44e                	sd	s3,8(sp)
    80001f20:	e052                	sd	s4,0(sp)
    80001f22:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f24:	00000097          	auipc	ra,0x0
    80001f28:	c7a080e7          	jalr	-902(ra) # 80001b9e <myproc>
    80001f2c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001f2e:	00000097          	auipc	ra,0x0
    80001f32:	d90080e7          	jalr	-624(ra) # 80001cbe <allocproc>
    80001f36:	c175                	beqz	a0,8000201a <fork+0x106>
    80001f38:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f3a:	05093603          	ld	a2,80(s2)
    80001f3e:	6d2c                	ld	a1,88(a0)
    80001f40:	05893503          	ld	a0,88(s2)
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	7dc080e7          	jalr	2012(ra) # 80001720 <uvmcopy>
    80001f4c:	04054863          	bltz	a0,80001f9c <fork+0x88>
  np->sz = p->sz;
    80001f50:	05093783          	ld	a5,80(s2)
    80001f54:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80001f58:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f5c:	06093683          	ld	a3,96(s2)
    80001f60:	87b6                	mv	a5,a3
    80001f62:	0609b703          	ld	a4,96(s3)
    80001f66:	12068693          	addi	a3,a3,288
    80001f6a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f6e:	6788                	ld	a0,8(a5)
    80001f70:	6b8c                	ld	a1,16(a5)
    80001f72:	6f90                	ld	a2,24(a5)
    80001f74:	01073023          	sd	a6,0(a4)
    80001f78:	e708                	sd	a0,8(a4)
    80001f7a:	eb0c                	sd	a1,16(a4)
    80001f7c:	ef10                	sd	a2,24(a4)
    80001f7e:	02078793          	addi	a5,a5,32
    80001f82:	02070713          	addi	a4,a4,32
    80001f86:	fed792e3          	bne	a5,a3,80001f6a <fork+0x56>
  np->trapframe->a0 = 0;
    80001f8a:	0609b783          	ld	a5,96(s3)
    80001f8e:	0607b823          	sd	zero,112(a5)
    80001f92:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001f96:	15800a13          	li	s4,344
    80001f9a:	a03d                	j	80001fc8 <fork+0xb4>
    freeproc(np);
    80001f9c:	854e                	mv	a0,s3
    80001f9e:	00000097          	auipc	ra,0x0
    80001fa2:	e28080e7          	jalr	-472(ra) # 80001dc6 <freeproc>
    release(&np->lock);
    80001fa6:	854e                	mv	a0,s3
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	cc4080e7          	jalr	-828(ra) # 80000c6c <release>
    return -1;
    80001fb0:	54fd                	li	s1,-1
    80001fb2:	a899                	j	80002008 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fb4:	00002097          	auipc	ra,0x2
    80001fb8:	7ac080e7          	jalr	1964(ra) # 80004760 <filedup>
    80001fbc:	009987b3          	add	a5,s3,s1
    80001fc0:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001fc2:	04a1                	addi	s1,s1,8
    80001fc4:	01448763          	beq	s1,s4,80001fd2 <fork+0xbe>
    if(p->ofile[i])
    80001fc8:	009907b3          	add	a5,s2,s1
    80001fcc:	6388                	ld	a0,0(a5)
    80001fce:	f17d                	bnez	a0,80001fb4 <fork+0xa0>
    80001fd0:	bfcd                	j	80001fc2 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001fd2:	15893503          	ld	a0,344(s2)
    80001fd6:	00002097          	auipc	ra,0x2
    80001fda:	912080e7          	jalr	-1774(ra) # 800038e8 <idup>
    80001fde:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fe2:	4641                	li	a2,16
    80001fe4:	16090593          	addi	a1,s2,352
    80001fe8:	16098513          	addi	a0,s3,352
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	012080e7          	jalr	18(ra) # 80000ffe <safestrcpy>
  pid = np->pid;
    80001ff4:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    80001ff8:	4789                	li	a5,2
    80001ffa:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001ffe:	854e                	mv	a0,s3
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	c6c080e7          	jalr	-916(ra) # 80000c6c <release>
}
    80002008:	8526                	mv	a0,s1
    8000200a:	70a2                	ld	ra,40(sp)
    8000200c:	7402                	ld	s0,32(sp)
    8000200e:	64e2                	ld	s1,24(sp)
    80002010:	6942                	ld	s2,16(sp)
    80002012:	69a2                	ld	s3,8(sp)
    80002014:	6a02                	ld	s4,0(sp)
    80002016:	6145                	addi	sp,sp,48
    80002018:	8082                	ret
    return -1;
    8000201a:	54fd                	li	s1,-1
    8000201c:	b7f5                	j	80002008 <fork+0xf4>

000000008000201e <reparent>:
{
    8000201e:	7179                	addi	sp,sp,-48
    80002020:	f406                	sd	ra,40(sp)
    80002022:	f022                	sd	s0,32(sp)
    80002024:	ec26                	sd	s1,24(sp)
    80002026:	e84a                	sd	s2,16(sp)
    80002028:	e44e                	sd	s3,8(sp)
    8000202a:	e052                	sd	s4,0(sp)
    8000202c:	1800                	addi	s0,sp,48
    8000202e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002030:	00024497          	auipc	s1,0x24
    80002034:	f0848493          	addi	s1,s1,-248 # 80025f38 <proc>
      pp->parent = initproc;
    80002038:	00008a17          	auipc	s4,0x8
    8000203c:	fe8a0a13          	addi	s4,s4,-24 # 8000a020 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002040:	0002a997          	auipc	s3,0x2a
    80002044:	cf898993          	addi	s3,s3,-776 # 8002bd38 <tickslock>
    80002048:	a029                	j	80002052 <reparent+0x34>
    8000204a:	17848493          	addi	s1,s1,376
    8000204e:	03348363          	beq	s1,s3,80002074 <reparent+0x56>
    if(pp->parent == p){
    80002052:	749c                	ld	a5,40(s1)
    80002054:	ff279be3          	bne	a5,s2,8000204a <reparent+0x2c>
      acquire(&pp->lock);
    80002058:	8526                	mv	a0,s1
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	b42080e7          	jalr	-1214(ra) # 80000b9c <acquire>
      pp->parent = initproc;
    80002062:	000a3783          	ld	a5,0(s4)
    80002066:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002068:	8526                	mv	a0,s1
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	c02080e7          	jalr	-1022(ra) # 80000c6c <release>
    80002072:	bfe1                	j	8000204a <reparent+0x2c>
}
    80002074:	70a2                	ld	ra,40(sp)
    80002076:	7402                	ld	s0,32(sp)
    80002078:	64e2                	ld	s1,24(sp)
    8000207a:	6942                	ld	s2,16(sp)
    8000207c:	69a2                	ld	s3,8(sp)
    8000207e:	6a02                	ld	s4,0(sp)
    80002080:	6145                	addi	sp,sp,48
    80002082:	8082                	ret

0000000080002084 <scheduler>:
{
    80002084:	715d                	addi	sp,sp,-80
    80002086:	e486                	sd	ra,72(sp)
    80002088:	e0a2                	sd	s0,64(sp)
    8000208a:	fc26                	sd	s1,56(sp)
    8000208c:	f84a                	sd	s2,48(sp)
    8000208e:	f44e                	sd	s3,40(sp)
    80002090:	f052                	sd	s4,32(sp)
    80002092:	ec56                	sd	s5,24(sp)
    80002094:	e85a                	sd	s6,16(sp)
    80002096:	e45e                	sd	s7,8(sp)
    80002098:	e062                	sd	s8,0(sp)
    8000209a:	0880                	addi	s0,sp,80
    8000209c:	8792                	mv	a5,tp
  int id = r_tp();
    8000209e:	2781                	sext.w	a5,a5
  c->proc = 0;
    800020a0:	00779b93          	slli	s7,a5,0x7
    800020a4:	00024717          	auipc	a4,0x24
    800020a8:	a7470713          	addi	a4,a4,-1420 # 80025b18 <pid_lock>
    800020ac:	975e                	add	a4,a4,s7
    800020ae:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    800020b2:	00024717          	auipc	a4,0x24
    800020b6:	a8e70713          	addi	a4,a4,-1394 # 80025b40 <cpus+0x8>
    800020ba:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    800020bc:	4c0d                	li	s8,3
        c->proc = p;
    800020be:	079e                	slli	a5,a5,0x7
    800020c0:	00024917          	auipc	s2,0x24
    800020c4:	a5890913          	addi	s2,s2,-1448 # 80025b18 <pid_lock>
    800020c8:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ca:	0002aa17          	auipc	s4,0x2a
    800020ce:	c6ea0a13          	addi	s4,s4,-914 # 8002bd38 <tickslock>
    800020d2:	a0a9                	j	8000211c <scheduler+0x98>
        p->state = RUNNING;
    800020d4:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800020d8:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    800020dc:	06848593          	addi	a1,s1,104
    800020e0:	855e                	mv	a0,s7
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	73c080e7          	jalr	1852(ra) # 8000281e <swtch>
        c->proc = 0;
    800020ea:	02093023          	sd	zero,32(s2)
        found = 1;
    800020ee:	8ada                	mv	s5,s6
      c->intena = 0;
    800020f0:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b76080e7          	jalr	-1162(ra) # 80000c6c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020fe:	17848493          	addi	s1,s1,376
    80002102:	01448b63          	beq	s1,s4,80002118 <scheduler+0x94>
      acquire(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	a94080e7          	jalr	-1388(ra) # 80000b9c <acquire>
      if(p->state == RUNNABLE) {
    80002110:	509c                	lw	a5,32(s1)
    80002112:	fd379fe3          	bne	a5,s3,800020f0 <scheduler+0x6c>
    80002116:	bf7d                	j	800020d4 <scheduler+0x50>
    if(found == 0){
    80002118:	020a8563          	beqz	s5,80002142 <scheduler+0xbe>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000211c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002120:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002124:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002128:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000212c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000212e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002132:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002134:	00024497          	auipc	s1,0x24
    80002138:	e0448493          	addi	s1,s1,-508 # 80025f38 <proc>
      if(p->state == RUNNABLE) {
    8000213c:	4989                	li	s3,2
        found = 1;
    8000213e:	4b05                	li	s6,1
    80002140:	b7d9                	j	80002106 <scheduler+0x82>
      rcu_poll();
    80002142:	00005097          	auipc	ra,0x5
    80002146:	17a080e7          	jalr	378(ra) # 800072bc <rcu_poll>
      asm volatile("wfi");
    8000214a:	10500073          	wfi
    8000214e:	b7f9                	j	8000211c <scheduler+0x98>

0000000080002150 <sched>:
{
    80002150:	7179                	addi	sp,sp,-48
    80002152:	f406                	sd	ra,40(sp)
    80002154:	f022                	sd	s0,32(sp)
    80002156:	ec26                	sd	s1,24(sp)
    80002158:	e84a                	sd	s2,16(sp)
    8000215a:	e44e                	sd	s3,8(sp)
    8000215c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000215e:	00000097          	auipc	ra,0x0
    80002162:	a40080e7          	jalr	-1472(ra) # 80001b9e <myproc>
    80002166:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	9b6080e7          	jalr	-1610(ra) # 80000b1e <holding>
    80002170:	c93d                	beqz	a0,800021e6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002172:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002174:	2781                	sext.w	a5,a5
    80002176:	079e                	slli	a5,a5,0x7
    80002178:	00024717          	auipc	a4,0x24
    8000217c:	9a070713          	addi	a4,a4,-1632 # 80025b18 <pid_lock>
    80002180:	97ba                	add	a5,a5,a4
    80002182:	0987a703          	lw	a4,152(a5)
    80002186:	4785                	li	a5,1
    80002188:	06f71763          	bne	a4,a5,800021f6 <sched+0xa6>
  if(p->state == RUNNING)
    8000218c:	5098                	lw	a4,32(s1)
    8000218e:	478d                	li	a5,3
    80002190:	06f70b63          	beq	a4,a5,80002206 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002194:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002198:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000219a:	efb5                	bnez	a5,80002216 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000219c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000219e:	00024917          	auipc	s2,0x24
    800021a2:	97a90913          	addi	s2,s2,-1670 # 80025b18 <pid_lock>
    800021a6:	2781                	sext.w	a5,a5
    800021a8:	079e                	slli	a5,a5,0x7
    800021aa:	97ca                	add	a5,a5,s2
    800021ac:	09c7a983          	lw	s3,156(a5)
    800021b0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800021b2:	2781                	sext.w	a5,a5
    800021b4:	079e                	slli	a5,a5,0x7
    800021b6:	00024597          	auipc	a1,0x24
    800021ba:	98a58593          	addi	a1,a1,-1654 # 80025b40 <cpus+0x8>
    800021be:	95be                	add	a1,a1,a5
    800021c0:	06848513          	addi	a0,s1,104
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	65a080e7          	jalr	1626(ra) # 8000281e <swtch>
    800021cc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ce:	2781                	sext.w	a5,a5
    800021d0:	079e                	slli	a5,a5,0x7
    800021d2:	97ca                	add	a5,a5,s2
    800021d4:	0937ae23          	sw	s3,156(a5)
}
    800021d8:	70a2                	ld	ra,40(sp)
    800021da:	7402                	ld	s0,32(sp)
    800021dc:	64e2                	ld	s1,24(sp)
    800021de:	6942                	ld	s2,16(sp)
    800021e0:	69a2                	ld	s3,8(sp)
    800021e2:	6145                	addi	sp,sp,48
    800021e4:	8082                	ret
    panic("sched p->lock");
    800021e6:	00007517          	auipc	a0,0x7
    800021ea:	20250513          	addi	a0,a0,514 # 800093e8 <digits+0x278>
    800021ee:	ffffe097          	auipc	ra,0xffffe
    800021f2:	37c080e7          	jalr	892(ra) # 8000056a <panic>
    panic("sched locks");
    800021f6:	00007517          	auipc	a0,0x7
    800021fa:	20250513          	addi	a0,a0,514 # 800093f8 <digits+0x288>
    800021fe:	ffffe097          	auipc	ra,0xffffe
    80002202:	36c080e7          	jalr	876(ra) # 8000056a <panic>
    panic("sched running");
    80002206:	00007517          	auipc	a0,0x7
    8000220a:	20250513          	addi	a0,a0,514 # 80009408 <digits+0x298>
    8000220e:	ffffe097          	auipc	ra,0xffffe
    80002212:	35c080e7          	jalr	860(ra) # 8000056a <panic>
    panic("sched interruptible");
    80002216:	00007517          	auipc	a0,0x7
    8000221a:	20250513          	addi	a0,a0,514 # 80009418 <digits+0x2a8>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	34c080e7          	jalr	844(ra) # 8000056a <panic>

0000000080002226 <exit>:
{
    80002226:	7179                	addi	sp,sp,-48
    80002228:	f406                	sd	ra,40(sp)
    8000222a:	f022                	sd	s0,32(sp)
    8000222c:	ec26                	sd	s1,24(sp)
    8000222e:	e84a                	sd	s2,16(sp)
    80002230:	e44e                	sd	s3,8(sp)
    80002232:	e052                	sd	s4,0(sp)
    80002234:	1800                	addi	s0,sp,48
    80002236:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	966080e7          	jalr	-1690(ra) # 80001b9e <myproc>
    80002240:	89aa                	mv	s3,a0
  if(p == initproc)
    80002242:	00008797          	auipc	a5,0x8
    80002246:	dde7b783          	ld	a5,-546(a5) # 8000a020 <initproc>
    8000224a:	0d850493          	addi	s1,a0,216
    8000224e:	15850913          	addi	s2,a0,344
    80002252:	02a79363          	bne	a5,a0,80002278 <exit+0x52>
    panic("init exiting");
    80002256:	00007517          	auipc	a0,0x7
    8000225a:	1da50513          	addi	a0,a0,474 # 80009430 <digits+0x2c0>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	30c080e7          	jalr	780(ra) # 8000056a <panic>
      fileclose(f);
    80002266:	00002097          	auipc	ra,0x2
    8000226a:	54c080e7          	jalr	1356(ra) # 800047b2 <fileclose>
      p->ofile[fd] = 0;
    8000226e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002272:	04a1                	addi	s1,s1,8
    80002274:	01248563          	beq	s1,s2,8000227e <exit+0x58>
    if(p->ofile[fd]){
    80002278:	6088                	ld	a0,0(s1)
    8000227a:	f575                	bnez	a0,80002266 <exit+0x40>
    8000227c:	bfdd                	j	80002272 <exit+0x4c>
  begin_op();
    8000227e:	00002097          	auipc	ra,0x2
    80002282:	06a080e7          	jalr	106(ra) # 800042e8 <begin_op>
  iput(p->cwd);
    80002286:	1589b503          	ld	a0,344(s3)
    8000228a:	00002097          	auipc	ra,0x2
    8000228e:	856080e7          	jalr	-1962(ra) # 80003ae0 <iput>
  end_op();
    80002292:	00002097          	auipc	ra,0x2
    80002296:	0d6080e7          	jalr	214(ra) # 80004368 <end_op>
  p->cwd = 0;
    8000229a:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000229e:	00008497          	auipc	s1,0x8
    800022a2:	d8248493          	addi	s1,s1,-638 # 8000a020 <initproc>
    800022a6:	6088                	ld	a0,0(s1)
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	8f4080e7          	jalr	-1804(ra) # 80000b9c <acquire>
  wakeup1(initproc);
    800022b0:	6088                	ld	a0,0(s1)
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	776080e7          	jalr	1910(ra) # 80001a28 <wakeup1>
  release(&initproc->lock);
    800022ba:	6088                	ld	a0,0(s1)
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	9b0080e7          	jalr	-1616(ra) # 80000c6c <release>
  acquire(&p->lock);
    800022c4:	854e                	mv	a0,s3
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	8d6080e7          	jalr	-1834(ra) # 80000b9c <acquire>
  struct proc *original_parent = p->parent;
    800022ce:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800022d2:	854e                	mv	a0,s3
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	998080e7          	jalr	-1640(ra) # 80000c6c <release>
  acquire(&original_parent->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	8be080e7          	jalr	-1858(ra) # 80000b9c <acquire>
  acquire(&p->lock);
    800022e6:	854e                	mv	a0,s3
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	8b4080e7          	jalr	-1868(ra) # 80000b9c <acquire>
  reparent(p);
    800022f0:	854e                	mv	a0,s3
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	d2c080e7          	jalr	-724(ra) # 8000201e <reparent>
  wakeup1(original_parent);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	72c080e7          	jalr	1836(ra) # 80001a28 <wakeup1>
  p->xstate = status;
    80002304:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    80002308:	4791                	li	a5,4
    8000230a:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	95c080e7          	jalr	-1700(ra) # 80000c6c <release>
  sched();
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	e38080e7          	jalr	-456(ra) # 80002150 <sched>
  panic("zombie exit");
    80002320:	00007517          	auipc	a0,0x7
    80002324:	12050513          	addi	a0,a0,288 # 80009440 <digits+0x2d0>
    80002328:	ffffe097          	auipc	ra,0xffffe
    8000232c:	242080e7          	jalr	578(ra) # 8000056a <panic>

0000000080002330 <yield>:
{
    80002330:	1101                	addi	sp,sp,-32
    80002332:	ec06                	sd	ra,24(sp)
    80002334:	e822                	sd	s0,16(sp)
    80002336:	e426                	sd	s1,8(sp)
    80002338:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000233a:	00000097          	auipc	ra,0x0
    8000233e:	864080e7          	jalr	-1948(ra) # 80001b9e <myproc>
    80002342:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	858080e7          	jalr	-1960(ra) # 80000b9c <acquire>
  p->state = RUNNABLE;
    8000234c:	4789                	li	a5,2
    8000234e:	d09c                	sw	a5,32(s1)
  sched();
    80002350:	00000097          	auipc	ra,0x0
    80002354:	e00080e7          	jalr	-512(ra) # 80002150 <sched>
  release(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	912080e7          	jalr	-1774(ra) # 80000c6c <release>
}
    80002362:	60e2                	ld	ra,24(sp)
    80002364:	6442                	ld	s0,16(sp)
    80002366:	64a2                	ld	s1,8(sp)
    80002368:	6105                	addi	sp,sp,32
    8000236a:	8082                	ret

000000008000236c <sleep>:
{
    8000236c:	7179                	addi	sp,sp,-48
    8000236e:	f406                	sd	ra,40(sp)
    80002370:	f022                	sd	s0,32(sp)
    80002372:	ec26                	sd	s1,24(sp)
    80002374:	e84a                	sd	s2,16(sp)
    80002376:	e44e                	sd	s3,8(sp)
    80002378:	1800                	addi	s0,sp,48
    8000237a:	89aa                	mv	s3,a0
    8000237c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000237e:	00000097          	auipc	ra,0x0
    80002382:	820080e7          	jalr	-2016(ra) # 80001b9e <myproc>
    80002386:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002388:	05250663          	beq	a0,s2,800023d4 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	810080e7          	jalr	-2032(ra) # 80000b9c <acquire>
    release(lk);
    80002394:	854a                	mv	a0,s2
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8d6080e7          	jalr	-1834(ra) # 80000c6c <release>
  p->chan = chan;
    8000239e:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    800023a2:	4785                	li	a5,1
    800023a4:	d09c                	sw	a5,32(s1)
  sched();
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	daa080e7          	jalr	-598(ra) # 80002150 <sched>
  p->chan = 0;
    800023ae:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	8b8080e7          	jalr	-1864(ra) # 80000c6c <release>
    acquire(lk);
    800023bc:	854a                	mv	a0,s2
    800023be:	ffffe097          	auipc	ra,0xffffe
    800023c2:	7de080e7          	jalr	2014(ra) # 80000b9c <acquire>
}
    800023c6:	70a2                	ld	ra,40(sp)
    800023c8:	7402                	ld	s0,32(sp)
    800023ca:	64e2                	ld	s1,24(sp)
    800023cc:	6942                	ld	s2,16(sp)
    800023ce:	69a2                	ld	s3,8(sp)
    800023d0:	6145                	addi	sp,sp,48
    800023d2:	8082                	ret
  p->chan = chan;
    800023d4:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023d8:	4785                	li	a5,1
    800023da:	d11c                	sw	a5,32(a0)
  sched();
    800023dc:	00000097          	auipc	ra,0x0
    800023e0:	d74080e7          	jalr	-652(ra) # 80002150 <sched>
  p->chan = 0;
    800023e4:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800023e8:	bff9                	j	800023c6 <sleep+0x5a>

00000000800023ea <wait>:
{
    800023ea:	715d                	addi	sp,sp,-80
    800023ec:	e486                	sd	ra,72(sp)
    800023ee:	e0a2                	sd	s0,64(sp)
    800023f0:	fc26                	sd	s1,56(sp)
    800023f2:	f84a                	sd	s2,48(sp)
    800023f4:	f44e                	sd	s3,40(sp)
    800023f6:	f052                	sd	s4,32(sp)
    800023f8:	ec56                	sd	s5,24(sp)
    800023fa:	e85a                	sd	s6,16(sp)
    800023fc:	e45e                	sd	s7,8(sp)
    800023fe:	e062                	sd	s8,0(sp)
    80002400:	0880                	addi	s0,sp,80
    80002402:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	79a080e7          	jalr	1946(ra) # 80001b9e <myproc>
    8000240c:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000240e:	8c2a                	mv	s8,a0
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	78c080e7          	jalr	1932(ra) # 80000b9c <acquire>
    havekids = 0;
    80002418:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000241a:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000241c:	0002a997          	auipc	s3,0x2a
    80002420:	91c98993          	addi	s3,s3,-1764 # 8002bd38 <tickslock>
        havekids = 1;
    80002424:	4a85                	li	s5,1
    havekids = 0;
    80002426:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002428:	00024497          	auipc	s1,0x24
    8000242c:	b1048493          	addi	s1,s1,-1264 # 80025f38 <proc>
    80002430:	a08d                	j	80002492 <wait+0xa8>
          pid = np->pid;
    80002432:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002436:	000b0e63          	beqz	s6,80002452 <wait+0x68>
    8000243a:	4691                	li	a3,4
    8000243c:	03c48613          	addi	a2,s1,60
    80002440:	85da                	mv	a1,s6
    80002442:	05893503          	ld	a0,88(s2)
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	3dc080e7          	jalr	988(ra) # 80001822 <copyout>
    8000244e:	02054263          	bltz	a0,80002472 <wait+0x88>
          freeproc(np);
    80002452:	8526                	mv	a0,s1
    80002454:	00000097          	auipc	ra,0x0
    80002458:	972080e7          	jalr	-1678(ra) # 80001dc6 <freeproc>
          release(&np->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	80e080e7          	jalr	-2034(ra) # 80000c6c <release>
          release(&p->lock);
    80002466:	854a                	mv	a0,s2
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	804080e7          	jalr	-2044(ra) # 80000c6c <release>
          return pid;
    80002470:	a8a9                	j	800024ca <wait+0xe0>
            release(&np->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	7f8080e7          	jalr	2040(ra) # 80000c6c <release>
            release(&p->lock);
    8000247c:	854a                	mv	a0,s2
    8000247e:	ffffe097          	auipc	ra,0xffffe
    80002482:	7ee080e7          	jalr	2030(ra) # 80000c6c <release>
            return -1;
    80002486:	59fd                	li	s3,-1
    80002488:	a089                	j	800024ca <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000248a:	17848493          	addi	s1,s1,376
    8000248e:	03348463          	beq	s1,s3,800024b6 <wait+0xcc>
      if(np->parent == p){
    80002492:	749c                	ld	a5,40(s1)
    80002494:	ff279be3          	bne	a5,s2,8000248a <wait+0xa0>
        acquire(&np->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	702080e7          	jalr	1794(ra) # 80000b9c <acquire>
        if(np->state == ZOMBIE){
    800024a2:	509c                	lw	a5,32(s1)
    800024a4:	f94787e3          	beq	a5,s4,80002432 <wait+0x48>
        release(&np->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	7c2080e7          	jalr	1986(ra) # 80000c6c <release>
        havekids = 1;
    800024b2:	8756                	mv	a4,s5
    800024b4:	bfd9                	j	8000248a <wait+0xa0>
    if(!havekids || p->killed){
    800024b6:	c701                	beqz	a4,800024be <wait+0xd4>
    800024b8:	03892783          	lw	a5,56(s2)
    800024bc:	c785                	beqz	a5,800024e4 <wait+0xfa>
      release(&p->lock);
    800024be:	854a                	mv	a0,s2
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	7ac080e7          	jalr	1964(ra) # 80000c6c <release>
      return -1;
    800024c8:	59fd                	li	s3,-1
}
    800024ca:	854e                	mv	a0,s3
    800024cc:	60a6                	ld	ra,72(sp)
    800024ce:	6406                	ld	s0,64(sp)
    800024d0:	74e2                	ld	s1,56(sp)
    800024d2:	7942                	ld	s2,48(sp)
    800024d4:	79a2                	ld	s3,40(sp)
    800024d6:	7a02                	ld	s4,32(sp)
    800024d8:	6ae2                	ld	s5,24(sp)
    800024da:	6b42                	ld	s6,16(sp)
    800024dc:	6ba2                	ld	s7,8(sp)
    800024de:	6c02                	ld	s8,0(sp)
    800024e0:	6161                	addi	sp,sp,80
    800024e2:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800024e4:	85e2                	mv	a1,s8
    800024e6:	854a                	mv	a0,s2
    800024e8:	00000097          	auipc	ra,0x0
    800024ec:	e84080e7          	jalr	-380(ra) # 8000236c <sleep>
    havekids = 0;
    800024f0:	bf1d                	j	80002426 <wait+0x3c>

00000000800024f2 <wakeup>:
{
    800024f2:	7139                	addi	sp,sp,-64
    800024f4:	fc06                	sd	ra,56(sp)
    800024f6:	f822                	sd	s0,48(sp)
    800024f8:	f426                	sd	s1,40(sp)
    800024fa:	f04a                	sd	s2,32(sp)
    800024fc:	ec4e                	sd	s3,24(sp)
    800024fe:	e852                	sd	s4,16(sp)
    80002500:	e456                	sd	s5,8(sp)
    80002502:	0080                	addi	s0,sp,64
    80002504:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002506:	00024497          	auipc	s1,0x24
    8000250a:	a3248493          	addi	s1,s1,-1486 # 80025f38 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000250e:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002510:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002512:	0002a917          	auipc	s2,0x2a
    80002516:	82690913          	addi	s2,s2,-2010 # 8002bd38 <tickslock>
    8000251a:	a821                	j	80002532 <wakeup+0x40>
      p->state = RUNNABLE;
    8000251c:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	74a080e7          	jalr	1866(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000252a:	17848493          	addi	s1,s1,376
    8000252e:	01248e63          	beq	s1,s2,8000254a <wakeup+0x58>
    acquire(&p->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	668080e7          	jalr	1640(ra) # 80000b9c <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000253c:	509c                	lw	a5,32(s1)
    8000253e:	ff3791e3          	bne	a5,s3,80002520 <wakeup+0x2e>
    80002542:	789c                	ld	a5,48(s1)
    80002544:	fd479ee3          	bne	a5,s4,80002520 <wakeup+0x2e>
    80002548:	bfd1                	j	8000251c <wakeup+0x2a>
}
    8000254a:	70e2                	ld	ra,56(sp)
    8000254c:	7442                	ld	s0,48(sp)
    8000254e:	74a2                	ld	s1,40(sp)
    80002550:	7902                	ld	s2,32(sp)
    80002552:	69e2                	ld	s3,24(sp)
    80002554:	6a42                	ld	s4,16(sp)
    80002556:	6aa2                	ld	s5,8(sp)
    80002558:	6121                	addi	sp,sp,64
    8000255a:	8082                	ret

000000008000255c <kill>:
{
    8000255c:	7179                	addi	sp,sp,-48
    8000255e:	f406                	sd	ra,40(sp)
    80002560:	f022                	sd	s0,32(sp)
    80002562:	ec26                	sd	s1,24(sp)
    80002564:	e84a                	sd	s2,16(sp)
    80002566:	e44e                	sd	s3,8(sp)
    80002568:	1800                	addi	s0,sp,48
    8000256a:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    8000256c:	00024497          	auipc	s1,0x24
    80002570:	9cc48493          	addi	s1,s1,-1588 # 80025f38 <proc>
    80002574:	00029997          	auipc	s3,0x29
    80002578:	7c498993          	addi	s3,s3,1988 # 8002bd38 <tickslock>
    acquire(&p->lock);
    8000257c:	8526                	mv	a0,s1
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	61e080e7          	jalr	1566(ra) # 80000b9c <acquire>
    if(p->pid == pid){
    80002586:	40bc                	lw	a5,64(s1)
    80002588:	01278d63          	beq	a5,s2,800025a2 <kill+0x46>
    release(&p->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	6de080e7          	jalr	1758(ra) # 80000c6c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002596:	17848493          	addi	s1,s1,376
    8000259a:	ff3491e3          	bne	s1,s3,8000257c <kill+0x20>
  return -1;
    8000259e:	557d                	li	a0,-1
    800025a0:	a829                	j	800025ba <kill+0x5e>
      p->killed = 1;
    800025a2:	4785                	li	a5,1
    800025a4:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800025a6:	5098                	lw	a4,32(s1)
    800025a8:	4785                	li	a5,1
    800025aa:	00f70f63          	beq	a4,a5,800025c8 <kill+0x6c>
      release(&p->lock);
    800025ae:	8526                	mv	a0,s1
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	6bc080e7          	jalr	1724(ra) # 80000c6c <release>
      return 0;
    800025b8:	4501                	li	a0,0
}
    800025ba:	70a2                	ld	ra,40(sp)
    800025bc:	7402                	ld	s0,32(sp)
    800025be:	64e2                	ld	s1,24(sp)
    800025c0:	6942                	ld	s2,16(sp)
    800025c2:	69a2                	ld	s3,8(sp)
    800025c4:	6145                	addi	sp,sp,48
    800025c6:	8082                	ret
        p->state = RUNNABLE;
    800025c8:	4789                	li	a5,2
    800025ca:	d09c                	sw	a5,32(s1)
    800025cc:	b7cd                	j	800025ae <kill+0x52>

00000000800025ce <either_copyout>:
{
    800025ce:	7179                	addi	sp,sp,-48
    800025d0:	f406                	sd	ra,40(sp)
    800025d2:	f022                	sd	s0,32(sp)
    800025d4:	ec26                	sd	s1,24(sp)
    800025d6:	e84a                	sd	s2,16(sp)
    800025d8:	e44e                	sd	s3,8(sp)
    800025da:	e052                	sd	s4,0(sp)
    800025dc:	1800                	addi	s0,sp,48
    800025de:	84aa                	mv	s1,a0
    800025e0:	892e                	mv	s2,a1
    800025e2:	89b2                	mv	s3,a2
    800025e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	5b8080e7          	jalr	1464(ra) # 80001b9e <myproc>
  if(user_dst){
    800025ee:	c08d                	beqz	s1,80002610 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025f0:	86d2                	mv	a3,s4
    800025f2:	864e                	mv	a2,s3
    800025f4:	85ca                	mv	a1,s2
    800025f6:	6d28                	ld	a0,88(a0)
    800025f8:	fffff097          	auipc	ra,0xfffff
    800025fc:	22a080e7          	jalr	554(ra) # 80001822 <copyout>
}
    80002600:	70a2                	ld	ra,40(sp)
    80002602:	7402                	ld	s0,32(sp)
    80002604:	64e2                	ld	s1,24(sp)
    80002606:	6942                	ld	s2,16(sp)
    80002608:	69a2                	ld	s3,8(sp)
    8000260a:	6a02                	ld	s4,0(sp)
    8000260c:	6145                	addi	sp,sp,48
    8000260e:	8082                	ret
    memmove((char *)dst, src, len);
    80002610:	000a061b          	sext.w	a2,s4
    80002614:	85ce                	mv	a1,s3
    80002616:	854a                	mv	a0,s2
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	8c8080e7          	jalr	-1848(ra) # 80000ee0 <memmove>
    return 0;
    80002620:	8526                	mv	a0,s1
    80002622:	bff9                	j	80002600 <either_copyout+0x32>

0000000080002624 <either_copyin>:
{
    80002624:	7179                	addi	sp,sp,-48
    80002626:	f406                	sd	ra,40(sp)
    80002628:	f022                	sd	s0,32(sp)
    8000262a:	ec26                	sd	s1,24(sp)
    8000262c:	e84a                	sd	s2,16(sp)
    8000262e:	e44e                	sd	s3,8(sp)
    80002630:	e052                	sd	s4,0(sp)
    80002632:	1800                	addi	s0,sp,48
    80002634:	892a                	mv	s2,a0
    80002636:	84ae                	mv	s1,a1
    80002638:	89b2                	mv	s3,a2
    8000263a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000263c:	fffff097          	auipc	ra,0xfffff
    80002640:	562080e7          	jalr	1378(ra) # 80001b9e <myproc>
  if(user_src){
    80002644:	c08d                	beqz	s1,80002666 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002646:	86d2                	mv	a3,s4
    80002648:	864e                	mv	a2,s3
    8000264a:	85ca                	mv	a1,s2
    8000264c:	6d28                	ld	a0,88(a0)
    8000264e:	fffff097          	auipc	ra,0xfffff
    80002652:	260080e7          	jalr	608(ra) # 800018ae <copyin>
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6a02                	ld	s4,0(sp)
    80002662:	6145                	addi	sp,sp,48
    80002664:	8082                	ret
    memmove(dst, (char*)src, len);
    80002666:	000a061b          	sext.w	a2,s4
    8000266a:	85ce                	mv	a1,s3
    8000266c:	854a                	mv	a0,s2
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	872080e7          	jalr	-1934(ra) # 80000ee0 <memmove>
    return 0;
    80002676:	8526                	mv	a0,s1
    80002678:	bff9                	j	80002656 <either_copyin+0x32>

000000008000267a <procdump>:
{
    8000267a:	715d                	addi	sp,sp,-80
    8000267c:	e486                	sd	ra,72(sp)
    8000267e:	e0a2                	sd	s0,64(sp)
    80002680:	fc26                	sd	s1,56(sp)
    80002682:	f84a                	sd	s2,48(sp)
    80002684:	f44e                	sd	s3,40(sp)
    80002686:	f052                	sd	s4,32(sp)
    80002688:	ec56                	sd	s5,24(sp)
    8000268a:	e85a                	sd	s6,16(sp)
    8000268c:	e45e                	sd	s7,8(sp)
    8000268e:	0880                	addi	s0,sp,80
  printf("\n");
    80002690:	00007517          	auipc	a0,0x7
    80002694:	b7050513          	addi	a0,a0,-1168 # 80009200 <digits+0x90>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	f34080e7          	jalr	-204(ra) # 800005cc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a0:	00024497          	auipc	s1,0x24
    800026a4:	9f848493          	addi	s1,s1,-1544 # 80026098 <proc+0x160>
    800026a8:	00029917          	auipc	s2,0x29
    800026ac:	7f090913          	addi	s2,s2,2032 # 8002be98 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b0:	4b11                	li	s6,4
      state = "???";
    800026b2:	00007997          	auipc	s3,0x7
    800026b6:	d9e98993          	addi	s3,s3,-610 # 80009450 <digits+0x2e0>
    printf("%d %s %s", p->pid, state, p->name);
    800026ba:	00007a97          	auipc	s5,0x7
    800026be:	d9ea8a93          	addi	s5,s5,-610 # 80009458 <digits+0x2e8>
    printf("\n");
    800026c2:	00007a17          	auipc	s4,0x7
    800026c6:	b3ea0a13          	addi	s4,s4,-1218 # 80009200 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ca:	00007b97          	auipc	s7,0x7
    800026ce:	e56b8b93          	addi	s7,s7,-426 # 80009520 <states.1871>
    800026d2:	a00d                	j	800026f4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026d4:	ee06a583          	lw	a1,-288(a3)
    800026d8:	8556                	mv	a0,s5
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	ef2080e7          	jalr	-270(ra) # 800005cc <printf>
    printf("\n");
    800026e2:	8552                	mv	a0,s4
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	ee8080e7          	jalr	-280(ra) # 800005cc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ec:	17848493          	addi	s1,s1,376
    800026f0:	03248163          	beq	s1,s2,80002712 <procdump+0x98>
    if(p->state == UNUSED)
    800026f4:	86a6                	mv	a3,s1
    800026f6:	ec04a783          	lw	a5,-320(s1)
    800026fa:	dbed                	beqz	a5,800026ec <procdump+0x72>
      state = "???";
    800026fc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026fe:	fcfb6be3          	bltu	s6,a5,800026d4 <procdump+0x5a>
    80002702:	1782                	slli	a5,a5,0x20
    80002704:	9381                	srli	a5,a5,0x20
    80002706:	078e                	slli	a5,a5,0x3
    80002708:	97de                	add	a5,a5,s7
    8000270a:	6390                	ld	a2,0(a5)
    8000270c:	f661                	bnez	a2,800026d4 <procdump+0x5a>
      state = "???";
    8000270e:	864e                	mv	a2,s3
    80002710:	b7d1                	j	800026d4 <procdump+0x5a>
}
    80002712:	60a6                	ld	ra,72(sp)
    80002714:	6406                	ld	s0,64(sp)
    80002716:	74e2                	ld	s1,56(sp)
    80002718:	7942                	ld	s2,48(sp)
    8000271a:	79a2                	ld	s3,40(sp)
    8000271c:	7a02                	ld	s4,32(sp)
    8000271e:	6ae2                	ld	s5,24(sp)
    80002720:	6b42                	ld	s6,16(sp)
    80002722:	6ba2                	ld	s7,8(sp)
    80002724:	6161                	addi	sp,sp,80
    80002726:	8082                	ret

0000000080002728 <test_rcu>:
static struct test_data *global = 0;

// Main RCU test function.
void
test_rcu(void)
{
    80002728:	1101                	addi	sp,sp,-32
    8000272a:	ec06                	sd	ra,24(sp)
    8000272c:	e822                	sd	s0,16(sp)
    8000272e:	e426                	sd	s1,8(sp)
    80002730:	1000                	addi	s0,sp,32
  printf("=== RCU test start ===\n");
    80002732:	00007517          	auipc	a0,0x7
    80002736:	d3650513          	addi	a0,a0,-714 # 80009468 <digits+0x2f8>
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	e92080e7          	jalr	-366(ra) # 800005cc <printf>

  // Create first object and publish it.
  struct test_data *d1 = (struct test_data *)kalloc();
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	30a080e7          	jalr	778(ra) # 80000a4c <kalloc>
  if (d1 == 0) {
    8000274a:	c945                	beqz	a0,800027fa <test_rcu+0xd2>
    printf("kalloc failed\n");
    return;
  }
  d1->value = 100;
    8000274c:	06400793          	li	a5,100
    80002750:	c11c                	sw	a5,0(a0)
  rcu_assign_pointer(global, d1);
    80002752:	0ff0000f          	fence
    80002756:	00008497          	auipc	s1,0x8
    8000275a:	8c248493          	addi	s1,s1,-1854 # 8000a018 <global>
    8000275e:	e088                	sd	a0,0(s1)
  printf("[init] global value=%d\n", global->value);
    80002760:	410c                	lw	a1,0(a0)
    80002762:	00007517          	auipc	a0,0x7
    80002766:	d2e50513          	addi	a0,a0,-722 # 80009490 <digits+0x320>
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	e62080e7          	jalr	-414(ra) # 800005cc <printf>

  // Reader section.
  rcu_read_lock();
    80002772:	00005097          	auipc	ra,0x5
    80002776:	a22080e7          	jalr	-1502(ra) # 80007194 <rcu_read_lock>
  struct test_data *local = rcu_dereference(global);
    8000277a:	0ff0000f          	fence
  printf("[reader] read value=%d\n", local->value);
    8000277e:	609c                	ld	a5,0(s1)
    80002780:	438c                	lw	a1,0(a5)
    80002782:	00007517          	auipc	a0,0x7
    80002786:	d2650513          	addi	a0,a0,-730 # 800094a8 <digits+0x338>
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	e42080e7          	jalr	-446(ra) # 800005cc <printf>
  rcu_read_unlock();
    80002792:	00005097          	auipc	ra,0x5
    80002796:	a3a080e7          	jalr	-1478(ra) # 800071cc <rcu_read_unlock>

  // Writer creates a new version.
  struct test_data *d2 = (struct test_data *)kalloc();
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	2b2080e7          	jalr	690(ra) # 80000a4c <kalloc>
  if (d2 == 0) {
    800027a2:	c52d                	beqz	a0,8000280c <test_rcu+0xe4>
    printf("kalloc failed\n");
    return;
  }
  d2->value = 200;
    800027a4:	0c800793          	li	a5,200
    800027a8:	c11c                	sw	a5,0(a0)

  // Swap pointer and keep the old one.
  struct test_data *old = global;
    800027aa:	00008797          	auipc	a5,0x8
    800027ae:	86e78793          	addi	a5,a5,-1938 # 8000a018 <global>
    800027b2:	6384                	ld	s1,0(a5)
  rcu_assign_pointer(global, d2);
    800027b4:	0ff0000f          	fence
    800027b8:	e388                	sd	a0,0(a5)
  printf("[writer] updated global to %d\n", global->value);
    800027ba:	410c                	lw	a1,0(a0)
    800027bc:	00007517          	auipc	a0,0x7
    800027c0:	d0450513          	addi	a0,a0,-764 # 800094c0 <digits+0x350>
    800027c4:	ffffe097          	auipc	ra,0xffffe
    800027c8:	e08080e7          	jalr	-504(ra) # 800005cc <printf>

  // Schedule deferred free of the old object.
  call_rcu(&old->rcu, rcu_free_callback);
    800027cc:	fffff597          	auipc	a1,0xfffff
    800027d0:	2a058593          	addi	a1,a1,672 # 80001a6c <rcu_free_callback>
    800027d4:	00848513          	addi	a0,s1,8
    800027d8:	00005097          	auipc	ra,0x5
    800027dc:	a2c080e7          	jalr	-1492(ra) # 80007204 <call_rcu>


  printf("=== RCU test done ===\n");
    800027e0:	00007517          	auipc	a0,0x7
    800027e4:	d0050513          	addi	a0,a0,-768 # 800094e0 <digits+0x370>
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	de4080e7          	jalr	-540(ra) # 800005cc <printf>
}
    800027f0:	60e2                	ld	ra,24(sp)
    800027f2:	6442                	ld	s0,16(sp)
    800027f4:	64a2                	ld	s1,8(sp)
    800027f6:	6105                	addi	sp,sp,32
    800027f8:	8082                	ret
    printf("kalloc failed\n");
    800027fa:	00007517          	auipc	a0,0x7
    800027fe:	c8650513          	addi	a0,a0,-890 # 80009480 <digits+0x310>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	dca080e7          	jalr	-566(ra) # 800005cc <printf>
    return;
    8000280a:	b7dd                	j	800027f0 <test_rcu+0xc8>
    printf("kalloc failed\n");
    8000280c:	00007517          	auipc	a0,0x7
    80002810:	c7450513          	addi	a0,a0,-908 # 80009480 <digits+0x310>
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	db8080e7          	jalr	-584(ra) # 800005cc <printf>
    return;
    8000281c:	bfd1                	j	800027f0 <test_rcu+0xc8>

000000008000281e <swtch>:
    8000281e:	00153023          	sd	ra,0(a0)
    80002822:	00253423          	sd	sp,8(a0)
    80002826:	e900                	sd	s0,16(a0)
    80002828:	ed04                	sd	s1,24(a0)
    8000282a:	03253023          	sd	s2,32(a0)
    8000282e:	03353423          	sd	s3,40(a0)
    80002832:	03453823          	sd	s4,48(a0)
    80002836:	03553c23          	sd	s5,56(a0)
    8000283a:	05653023          	sd	s6,64(a0)
    8000283e:	05753423          	sd	s7,72(a0)
    80002842:	05853823          	sd	s8,80(a0)
    80002846:	05953c23          	sd	s9,88(a0)
    8000284a:	07a53023          	sd	s10,96(a0)
    8000284e:	07b53423          	sd	s11,104(a0)
    80002852:	0005b083          	ld	ra,0(a1)
    80002856:	0085b103          	ld	sp,8(a1)
    8000285a:	6980                	ld	s0,16(a1)
    8000285c:	6d84                	ld	s1,24(a1)
    8000285e:	0205b903          	ld	s2,32(a1)
    80002862:	0285b983          	ld	s3,40(a1)
    80002866:	0305ba03          	ld	s4,48(a1)
    8000286a:	0385ba83          	ld	s5,56(a1)
    8000286e:	0405bb03          	ld	s6,64(a1)
    80002872:	0485bb83          	ld	s7,72(a1)
    80002876:	0505bc03          	ld	s8,80(a1)
    8000287a:	0585bc83          	ld	s9,88(a1)
    8000287e:	0605bd03          	ld	s10,96(a1)
    80002882:	0685bd83          	ld	s11,104(a1)
    80002886:	8082                	ret

0000000080002888 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002888:	1141                	addi	sp,sp,-16
    8000288a:	e422                	sd	s0,8(sp)
    8000288c:	0800                	addi	s0,sp,16
    8000288e:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002890:	00151713          	slli	a4,a0,0x1
    80002894:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002896:	04054c63          	bltz	a0,800028ee <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    8000289a:	5685                	li	a3,-31
    8000289c:	8285                	srli	a3,a3,0x1
    8000289e:	8ee9                	and	a3,a3,a0
    800028a0:	caad                	beqz	a3,80002912 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    800028a2:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    800028a4:	00007517          	auipc	a0,0x7
    800028a8:	ca450513          	addi	a0,a0,-860 # 80009548 <states.1871+0x28>
    } else if (code <= 23) {
    800028ac:	06e6f063          	bgeu	a3,a4,8000290c <scause_desc+0x84>
    } else if (code <= 31) {
    800028b0:	fc100693          	li	a3,-63
    800028b4:	8285                	srli	a3,a3,0x1
    800028b6:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800028b8:	00007517          	auipc	a0,0x7
    800028bc:	cb850513          	addi	a0,a0,-840 # 80009570 <states.1871+0x50>
    } else if (code <= 31) {
    800028c0:	c6b1                	beqz	a3,8000290c <scause_desc+0x84>
    } else if (code <= 47) {
    800028c2:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800028c6:	00007517          	auipc	a0,0x7
    800028ca:	c8250513          	addi	a0,a0,-894 # 80009548 <states.1871+0x28>
    } else if (code <= 47) {
    800028ce:	02e6ff63          	bgeu	a3,a4,8000290c <scause_desc+0x84>
    } else if (code <= 63) {
    800028d2:	f8100513          	li	a0,-127
    800028d6:	8105                	srli	a0,a0,0x1
    800028d8:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800028da:	00007517          	auipc	a0,0x7
    800028de:	c9650513          	addi	a0,a0,-874 # 80009570 <states.1871+0x50>
    } else if (code <= 63) {
    800028e2:	c78d                	beqz	a5,8000290c <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800028e4:	00007517          	auipc	a0,0x7
    800028e8:	c6450513          	addi	a0,a0,-924 # 80009548 <states.1871+0x28>
    800028ec:	a005                	j	8000290c <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800028ee:	5505                	li	a0,-31
    800028f0:	8105                	srli	a0,a0,0x1
    800028f2:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800028f4:	00007517          	auipc	a0,0x7
    800028f8:	c9c50513          	addi	a0,a0,-868 # 80009590 <states.1871+0x70>
    if (code < NELEM(intr_desc)) {
    800028fc:	eb81                	bnez	a5,8000290c <scause_desc+0x84>
      return intr_desc[code];
    800028fe:	070e                	slli	a4,a4,0x3
    80002900:	00007797          	auipc	a5,0x7
    80002904:	fa078793          	addi	a5,a5,-96 # 800098a0 <intr_desc.1630>
    80002908:	973e                	add	a4,a4,a5
    8000290a:	6308                	ld	a0,0(a4)
    }
  }
}
    8000290c:	6422                	ld	s0,8(sp)
    8000290e:	0141                	addi	sp,sp,16
    80002910:	8082                	ret
      return nointr_desc[code];
    80002912:	070e                	slli	a4,a4,0x3
    80002914:	00007797          	auipc	a5,0x7
    80002918:	f8c78793          	addi	a5,a5,-116 # 800098a0 <intr_desc.1630>
    8000291c:	973e                	add	a4,a4,a5
    8000291e:	6348                	ld	a0,128(a4)
    80002920:	b7f5                	j	8000290c <scause_desc+0x84>

0000000080002922 <trapinit>:
{
    80002922:	1141                	addi	sp,sp,-16
    80002924:	e406                	sd	ra,8(sp)
    80002926:	e022                	sd	s0,0(sp)
    80002928:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000292a:	00007597          	auipc	a1,0x7
    8000292e:	c8658593          	addi	a1,a1,-890 # 800095b0 <states.1871+0x90>
    80002932:	00029517          	auipc	a0,0x29
    80002936:	40650513          	addi	a0,a0,1030 # 8002bd38 <tickslock>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	18c080e7          	jalr	396(ra) # 80000ac6 <initlock>
}
    80002942:	60a2                	ld	ra,8(sp)
    80002944:	6402                	ld	s0,0(sp)
    80002946:	0141                	addi	sp,sp,16
    80002948:	8082                	ret

000000008000294a <trapinithart>:
{
    8000294a:	1141                	addi	sp,sp,-16
    8000294c:	e422                	sd	s0,8(sp)
    8000294e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002950:	00003797          	auipc	a5,0x3
    80002954:	49078793          	addi	a5,a5,1168 # 80005de0 <kernelvec>
    80002958:	10579073          	csrw	stvec,a5
}
    8000295c:	6422                	ld	s0,8(sp)
    8000295e:	0141                	addi	sp,sp,16
    80002960:	8082                	ret

0000000080002962 <usertrapret>:
{
    80002962:	1141                	addi	sp,sp,-16
    80002964:	e406                	sd	ra,8(sp)
    80002966:	e022                	sd	s0,0(sp)
    80002968:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000296a:	fffff097          	auipc	ra,0xfffff
    8000296e:	234080e7          	jalr	564(ra) # 80001b9e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002972:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002976:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002978:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000297c:	00005617          	auipc	a2,0x5
    80002980:	68460613          	addi	a2,a2,1668 # 80008000 <_trampoline>
    80002984:	00005697          	auipc	a3,0x5
    80002988:	67c68693          	addi	a3,a3,1660 # 80008000 <_trampoline>
    8000298c:	8e91                	sub	a3,a3,a2
    8000298e:	040007b7          	lui	a5,0x4000
    80002992:	17fd                	addi	a5,a5,-1
    80002994:	07b2                	slli	a5,a5,0xc
    80002996:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002998:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000299c:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000299e:	180026f3          	csrr	a3,satp
    800029a2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029a4:	7138                	ld	a4,96(a0)
    800029a6:	6534                	ld	a3,72(a0)
    800029a8:	6585                	lui	a1,0x1
    800029aa:	96ae                	add	a3,a3,a1
    800029ac:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029ae:	7138                	ld	a4,96(a0)
    800029b0:	00000697          	auipc	a3,0x0
    800029b4:	12268693          	addi	a3,a3,290 # 80002ad2 <usertrap>
    800029b8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029ba:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029bc:	8692                	mv	a3,tp
    800029be:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029c4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029c8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029cc:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    800029d0:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d2:	6f18                	ld	a4,24(a4)
    800029d4:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800029d8:	6d2c                	ld	a1,88(a0)
    800029da:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029dc:	00005717          	auipc	a4,0x5
    800029e0:	6b470713          	addi	a4,a4,1716 # 80008090 <userret>
    800029e4:	8f11                	sub	a4,a4,a2
    800029e6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    800029e8:	577d                	li	a4,-1
    800029ea:	177e                	slli	a4,a4,0x3f
    800029ec:	8dd9                	or	a1,a1,a4
    800029ee:	17053503          	ld	a0,368(a0)
    800029f2:	9782                	jalr	a5
}
    800029f4:	60a2                	ld	ra,8(sp)
    800029f6:	6402                	ld	s0,0(sp)
    800029f8:	0141                	addi	sp,sp,16
    800029fa:	8082                	ret

00000000800029fc <clockintr>:
{
    800029fc:	1101                	addi	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	e426                	sd	s1,8(sp)
    80002a04:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a06:	00029497          	auipc	s1,0x29
    80002a0a:	33248493          	addi	s1,s1,818 # 8002bd38 <tickslock>
    80002a0e:	8526                	mv	a0,s1
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	18c080e7          	jalr	396(ra) # 80000b9c <acquire>
  ticks++;
    80002a18:	00007517          	auipc	a0,0x7
    80002a1c:	61050513          	addi	a0,a0,1552 # 8000a028 <ticks>
    80002a20:	411c                	lw	a5,0(a0)
    80002a22:	2785                	addiw	a5,a5,1
    80002a24:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	acc080e7          	jalr	-1332(ra) # 800024f2 <wakeup>
  release(&tickslock);
    80002a2e:	8526                	mv	a0,s1
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	23c080e7          	jalr	572(ra) # 80000c6c <release>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6105                	addi	sp,sp,32
    80002a40:	8082                	ret

0000000080002a42 <devintr>:
{
    80002a42:	1101                	addi	sp,sp,-32
    80002a44:	ec06                	sd	ra,24(sp)
    80002a46:	e822                	sd	s0,16(sp)
    80002a48:	e426                	sd	s1,8(sp)
    80002a4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4c:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002a50:	00074d63          	bltz	a4,80002a6a <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002a54:	57fd                	li	a5,-1
    80002a56:	17fe                	slli	a5,a5,0x3f
    80002a58:	0785                	addi	a5,a5,1
    return 0;
    80002a5a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a5c:	04f70a63          	beq	a4,a5,80002ab0 <devintr+0x6e>
}
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	64a2                	ld	s1,8(sp)
    80002a66:	6105                	addi	sp,sp,32
    80002a68:	8082                	ret
     (scause & 0xff) == 9){
    80002a6a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a6e:	46a5                	li	a3,9
    80002a70:	fed792e3          	bne	a5,a3,80002a54 <devintr+0x12>
    int irq = plic_claim();
    80002a74:	00003097          	auipc	ra,0x3
    80002a78:	474080e7          	jalr	1140(ra) # 80005ee8 <plic_claim>
    80002a7c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a7e:	47a9                	li	a5,10
    80002a80:	00f50863          	beq	a0,a5,80002a90 <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002a84:	4785                	li	a5,1
    80002a86:	02f50063          	beq	a0,a5,80002aa6 <devintr+0x64>
    return 1;
    80002a8a:	4505                	li	a0,1
    if(irq)
    80002a8c:	d8f1                	beqz	s1,80002a60 <devintr+0x1e>
    80002a8e:	a029                	j	80002a98 <devintr+0x56>
      uartintr();
    80002a90:	ffffe097          	auipc	ra,0xffffe
    80002a94:	e8a080e7          	jalr	-374(ra) # 8000091a <uartintr>
      plic_complete(irq);
    80002a98:	8526                	mv	a0,s1
    80002a9a:	00003097          	auipc	ra,0x3
    80002a9e:	472080e7          	jalr	1138(ra) # 80005f0c <plic_complete>
    return 1;
    80002aa2:	4505                	li	a0,1
    80002aa4:	bf75                	j	80002a60 <devintr+0x1e>
      virtio_disk_intr();
    80002aa6:	00004097          	auipc	ra,0x4
    80002aaa:	97a080e7          	jalr	-1670(ra) # 80006420 <virtio_disk_intr>
    80002aae:	b7ed                	j	80002a98 <devintr+0x56>
    if(cpuid() == 0){
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	0c2080e7          	jalr	194(ra) # 80001b72 <cpuid>
    80002ab8:	c901                	beqz	a0,80002ac8 <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aba:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002abe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ac0:	14479073          	csrw	sip,a5
    return 2;
    80002ac4:	4509                	li	a0,2
    80002ac6:	bf69                	j	80002a60 <devintr+0x1e>
      clockintr();
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	f34080e7          	jalr	-204(ra) # 800029fc <clockintr>
    80002ad0:	b7ed                	j	80002aba <devintr+0x78>

0000000080002ad2 <usertrap>:
{
    80002ad2:	7179                	addi	sp,sp,-48
    80002ad4:	f406                	sd	ra,40(sp)
    80002ad6:	f022                	sd	s0,32(sp)
    80002ad8:	ec26                	sd	s1,24(sp)
    80002ada:	e84a                	sd	s2,16(sp)
    80002adc:	e44e                	sd	s3,8(sp)
    80002ade:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ae4:	1007f793          	andi	a5,a5,256
    80002ae8:	e3b5                	bnez	a5,80002b4c <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aea:	00003797          	auipc	a5,0x3
    80002aee:	2f678793          	addi	a5,a5,758 # 80005de0 <kernelvec>
    80002af2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	0a8080e7          	jalr	168(ra) # 80001b9e <myproc>
    80002afe:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b00:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b02:	14102773          	csrr	a4,sepc
    80002b06:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b08:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b0c:	47a1                	li	a5,8
    80002b0e:	04f71d63          	bne	a4,a5,80002b68 <usertrap+0x96>
    if(p->killed)
    80002b12:	5d1c                	lw	a5,56(a0)
    80002b14:	e7a1                	bnez	a5,80002b5c <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002b16:	70b8                	ld	a4,96(s1)
    80002b18:	6f1c                	ld	a5,24(a4)
    80002b1a:	0791                	addi	a5,a5,4
    80002b1c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b22:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b26:	10079073          	csrw	sstatus,a5
    syscall();
    80002b2a:	00000097          	auipc	ra,0x0
    80002b2e:	2fe080e7          	jalr	766(ra) # 80002e28 <syscall>
  if(p->killed)
    80002b32:	5c9c                	lw	a5,56(s1)
    80002b34:	e3cd                	bnez	a5,80002bd6 <usertrap+0x104>
  usertrapret();
    80002b36:	00000097          	auipc	ra,0x0
    80002b3a:	e2c080e7          	jalr	-468(ra) # 80002962 <usertrapret>
}
    80002b3e:	70a2                	ld	ra,40(sp)
    80002b40:	7402                	ld	s0,32(sp)
    80002b42:	64e2                	ld	s1,24(sp)
    80002b44:	6942                	ld	s2,16(sp)
    80002b46:	69a2                	ld	s3,8(sp)
    80002b48:	6145                	addi	sp,sp,48
    80002b4a:	8082                	ret
    panic("usertrap: not from user mode");
    80002b4c:	00007517          	auipc	a0,0x7
    80002b50:	a6c50513          	addi	a0,a0,-1428 # 800095b8 <states.1871+0x98>
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	a16080e7          	jalr	-1514(ra) # 8000056a <panic>
      exit(-1);
    80002b5c:	557d                	li	a0,-1
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	6c8080e7          	jalr	1736(ra) # 80002226 <exit>
    80002b66:	bf45                	j	80002b16 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	eda080e7          	jalr	-294(ra) # 80002a42 <devintr>
    80002b70:	892a                	mv	s2,a0
    80002b72:	c501                	beqz	a0,80002b7a <usertrap+0xa8>
  if(p->killed)
    80002b74:	5c9c                	lw	a5,56(s1)
    80002b76:	cba1                	beqz	a5,80002bc6 <usertrap+0xf4>
    80002b78:	a091                	j	80002bbc <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b7a:	142029f3          	csrr	s3,scause
    80002b7e:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	d06080e7          	jalr	-762(ra) # 80002888 <scause_desc>
    80002b8a:	862a                	mv	a2,a0
    80002b8c:	40b4                	lw	a3,64(s1)
    80002b8e:	85ce                	mv	a1,s3
    80002b90:	00007517          	auipc	a0,0x7
    80002b94:	a4850513          	addi	a0,a0,-1464 # 800095d8 <states.1871+0xb8>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	a34080e7          	jalr	-1484(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ba4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ba8:	00007517          	auipc	a0,0x7
    80002bac:	a6050513          	addi	a0,a0,-1440 # 80009608 <states.1871+0xe8>
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	a1c080e7          	jalr	-1508(ra) # 800005cc <printf>
    p->killed = 1;
    80002bb8:	4785                	li	a5,1
    80002bba:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002bbc:	557d                	li	a0,-1
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	668080e7          	jalr	1640(ra) # 80002226 <exit>
  if(which_dev == 2)
    80002bc6:	4789                	li	a5,2
    80002bc8:	f6f917e3          	bne	s2,a5,80002b36 <usertrap+0x64>
    yield();
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	764080e7          	jalr	1892(ra) # 80002330 <yield>
    80002bd4:	b78d                	j	80002b36 <usertrap+0x64>
  int which_dev = 0;
    80002bd6:	4901                	li	s2,0
    80002bd8:	b7d5                	j	80002bbc <usertrap+0xea>

0000000080002bda <kerneltrap>:
{
    80002bda:	7179                	addi	sp,sp,-48
    80002bdc:	f406                	sd	ra,40(sp)
    80002bde:	f022                	sd	s0,32(sp)
    80002be0:	ec26                	sd	s1,24(sp)
    80002be2:	e84a                	sd	s2,16(sp)
    80002be4:	e44e                	sd	s3,8(sp)
    80002be6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bec:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bf4:	1004f793          	andi	a5,s1,256
    80002bf8:	cb85                	beqz	a5,80002c28 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bfe:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c00:	ef85                	bnez	a5,80002c38 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c02:	00000097          	auipc	ra,0x0
    80002c06:	e40080e7          	jalr	-448(ra) # 80002a42 <devintr>
    80002c0a:	cd1d                	beqz	a0,80002c48 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c0c:	4789                	li	a5,2
    80002c0e:	08f50063          	beq	a0,a5,80002c8e <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c12:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c16:	10049073          	csrw	sstatus,s1
}
    80002c1a:	70a2                	ld	ra,40(sp)
    80002c1c:	7402                	ld	s0,32(sp)
    80002c1e:	64e2                	ld	s1,24(sp)
    80002c20:	6942                	ld	s2,16(sp)
    80002c22:	69a2                	ld	s3,8(sp)
    80002c24:	6145                	addi	sp,sp,48
    80002c26:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c28:	00007517          	auipc	a0,0x7
    80002c2c:	a0050513          	addi	a0,a0,-1536 # 80009628 <states.1871+0x108>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	93a080e7          	jalr	-1734(ra) # 8000056a <panic>
    panic("kerneltrap: interrupts enabled");
    80002c38:	00007517          	auipc	a0,0x7
    80002c3c:	a1850513          	addi	a0,a0,-1512 # 80009650 <states.1871+0x130>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	92a080e7          	jalr	-1750(ra) # 8000056a <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002c48:	854e                	mv	a0,s3
    80002c4a:	00000097          	auipc	ra,0x0
    80002c4e:	c3e080e7          	jalr	-962(ra) # 80002888 <scause_desc>
    80002c52:	862a                	mv	a2,a0
    80002c54:	85ce                	mv	a1,s3
    80002c56:	00007517          	auipc	a0,0x7
    80002c5a:	a1a50513          	addi	a0,a0,-1510 # 80009670 <states.1871+0x150>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	96e080e7          	jalr	-1682(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c66:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c6a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c6e:	00007517          	auipc	a0,0x7
    80002c72:	a1250513          	addi	a0,a0,-1518 # 80009680 <states.1871+0x160>
    80002c76:	ffffe097          	auipc	ra,0xffffe
    80002c7a:	956080e7          	jalr	-1706(ra) # 800005cc <printf>
    panic("kerneltrap");
    80002c7e:	00007517          	auipc	a0,0x7
    80002c82:	a1a50513          	addi	a0,a0,-1510 # 80009698 <states.1871+0x178>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	8e4080e7          	jalr	-1820(ra) # 8000056a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	f10080e7          	jalr	-240(ra) # 80001b9e <myproc>
    80002c96:	dd35                	beqz	a0,80002c12 <kerneltrap+0x38>
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	f06080e7          	jalr	-250(ra) # 80001b9e <myproc>
    80002ca0:	5118                	lw	a4,32(a0)
    80002ca2:	478d                	li	a5,3
    80002ca4:	f6f717e3          	bne	a4,a5,80002c12 <kerneltrap+0x38>
    yield();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	688080e7          	jalr	1672(ra) # 80002330 <yield>
    80002cb0:	b78d                	j	80002c12 <kerneltrap+0x38>

0000000080002cb2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cb2:	1101                	addi	sp,sp,-32
    80002cb4:	ec06                	sd	ra,24(sp)
    80002cb6:	e822                	sd	s0,16(sp)
    80002cb8:	e426                	sd	s1,8(sp)
    80002cba:	1000                	addi	s0,sp,32
    80002cbc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cbe:	fffff097          	auipc	ra,0xfffff
    80002cc2:	ee0080e7          	jalr	-288(ra) # 80001b9e <myproc>
  switch (n) {
    80002cc6:	4795                	li	a5,5
    80002cc8:	0497e163          	bltu	a5,s1,80002d0a <argraw+0x58>
    80002ccc:	048a                	slli	s1,s1,0x2
    80002cce:	00007717          	auipc	a4,0x7
    80002cd2:	cfa70713          	addi	a4,a4,-774 # 800099c8 <nointr_desc.1631+0xa8>
    80002cd6:	94ba                	add	s1,s1,a4
    80002cd8:	409c                	lw	a5,0(s1)
    80002cda:	97ba                	add	a5,a5,a4
    80002cdc:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cde:	713c                	ld	a5,96(a0)
    80002ce0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ce2:	60e2                	ld	ra,24(sp)
    80002ce4:	6442                	ld	s0,16(sp)
    80002ce6:	64a2                	ld	s1,8(sp)
    80002ce8:	6105                	addi	sp,sp,32
    80002cea:	8082                	ret
    return p->trapframe->a1;
    80002cec:	713c                	ld	a5,96(a0)
    80002cee:	7fa8                	ld	a0,120(a5)
    80002cf0:	bfcd                	j	80002ce2 <argraw+0x30>
    return p->trapframe->a2;
    80002cf2:	713c                	ld	a5,96(a0)
    80002cf4:	63c8                	ld	a0,128(a5)
    80002cf6:	b7f5                	j	80002ce2 <argraw+0x30>
    return p->trapframe->a3;
    80002cf8:	713c                	ld	a5,96(a0)
    80002cfa:	67c8                	ld	a0,136(a5)
    80002cfc:	b7dd                	j	80002ce2 <argraw+0x30>
    return p->trapframe->a4;
    80002cfe:	713c                	ld	a5,96(a0)
    80002d00:	6bc8                	ld	a0,144(a5)
    80002d02:	b7c5                	j	80002ce2 <argraw+0x30>
    return p->trapframe->a5;
    80002d04:	713c                	ld	a5,96(a0)
    80002d06:	6fc8                	ld	a0,152(a5)
    80002d08:	bfe9                	j	80002ce2 <argraw+0x30>
  panic("argraw");
    80002d0a:	00007517          	auipc	a0,0x7
    80002d0e:	c9650513          	addi	a0,a0,-874 # 800099a0 <nointr_desc.1631+0x80>
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	858080e7          	jalr	-1960(ra) # 8000056a <panic>

0000000080002d1a <fetchaddr>:
{
    80002d1a:	1101                	addi	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	e426                	sd	s1,8(sp)
    80002d22:	e04a                	sd	s2,0(sp)
    80002d24:	1000                	addi	s0,sp,32
    80002d26:	84aa                	mv	s1,a0
    80002d28:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d2a:	fffff097          	auipc	ra,0xfffff
    80002d2e:	e74080e7          	jalr	-396(ra) # 80001b9e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d32:	693c                	ld	a5,80(a0)
    80002d34:	02f4f863          	bgeu	s1,a5,80002d64 <fetchaddr+0x4a>
    80002d38:	00848713          	addi	a4,s1,8
    80002d3c:	02e7e663          	bltu	a5,a4,80002d68 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d40:	46a1                	li	a3,8
    80002d42:	8626                	mv	a2,s1
    80002d44:	85ca                	mv	a1,s2
    80002d46:	6d28                	ld	a0,88(a0)
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	b66080e7          	jalr	-1178(ra) # 800018ae <copyin>
    80002d50:	00a03533          	snez	a0,a0
    80002d54:	40a00533          	neg	a0,a0
}
    80002d58:	60e2                	ld	ra,24(sp)
    80002d5a:	6442                	ld	s0,16(sp)
    80002d5c:	64a2                	ld	s1,8(sp)
    80002d5e:	6902                	ld	s2,0(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret
    return -1;
    80002d64:	557d                	li	a0,-1
    80002d66:	bfcd                	j	80002d58 <fetchaddr+0x3e>
    80002d68:	557d                	li	a0,-1
    80002d6a:	b7fd                	j	80002d58 <fetchaddr+0x3e>

0000000080002d6c <fetchstr>:
{
    80002d6c:	7179                	addi	sp,sp,-48
    80002d6e:	f406                	sd	ra,40(sp)
    80002d70:	f022                	sd	s0,32(sp)
    80002d72:	ec26                	sd	s1,24(sp)
    80002d74:	e84a                	sd	s2,16(sp)
    80002d76:	e44e                	sd	s3,8(sp)
    80002d78:	1800                	addi	s0,sp,48
    80002d7a:	892a                	mv	s2,a0
    80002d7c:	84ae                	mv	s1,a1
    80002d7e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d80:	fffff097          	auipc	ra,0xfffff
    80002d84:	e1e080e7          	jalr	-482(ra) # 80001b9e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002d88:	86ce                	mv	a3,s3
    80002d8a:	864a                	mv	a2,s2
    80002d8c:	85a6                	mv	a1,s1
    80002d8e:	6d28                	ld	a0,88(a0)
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	baa080e7          	jalr	-1110(ra) # 8000193a <copyinstr>
  if(err < 0)
    80002d98:	00054763          	bltz	a0,80002da6 <fetchstr+0x3a>
  return strlen(buf);
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	292080e7          	jalr	658(ra) # 80001030 <strlen>
}
    80002da6:	70a2                	ld	ra,40(sp)
    80002da8:	7402                	ld	s0,32(sp)
    80002daa:	64e2                	ld	s1,24(sp)
    80002dac:	6942                	ld	s2,16(sp)
    80002dae:	69a2                	ld	s3,8(sp)
    80002db0:	6145                	addi	sp,sp,48
    80002db2:	8082                	ret

0000000080002db4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002db4:	1101                	addi	sp,sp,-32
    80002db6:	ec06                	sd	ra,24(sp)
    80002db8:	e822                	sd	s0,16(sp)
    80002dba:	e426                	sd	s1,8(sp)
    80002dbc:	1000                	addi	s0,sp,32
    80002dbe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	ef2080e7          	jalr	-270(ra) # 80002cb2 <argraw>
    80002dc8:	c088                	sw	a0,0(s1)
  return 0;
}
    80002dca:	4501                	li	a0,0
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret

0000000080002dd6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	1000                	addi	s0,sp,32
    80002de0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	ed0080e7          	jalr	-304(ra) # 80002cb2 <argraw>
    80002dea:	e088                	sd	a0,0(s1)
  return 0;
}
    80002dec:	4501                	li	a0,0
    80002dee:	60e2                	ld	ra,24(sp)
    80002df0:	6442                	ld	s0,16(sp)
    80002df2:	64a2                	ld	s1,8(sp)
    80002df4:	6105                	addi	sp,sp,32
    80002df6:	8082                	ret

0000000080002df8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002df8:	1101                	addi	sp,sp,-32
    80002dfa:	ec06                	sd	ra,24(sp)
    80002dfc:	e822                	sd	s0,16(sp)
    80002dfe:	e426                	sd	s1,8(sp)
    80002e00:	e04a                	sd	s2,0(sp)
    80002e02:	1000                	addi	s0,sp,32
    80002e04:	84ae                	mv	s1,a1
    80002e06:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e08:	00000097          	auipc	ra,0x0
    80002e0c:	eaa080e7          	jalr	-342(ra) # 80002cb2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e10:	864a                	mv	a2,s2
    80002e12:	85a6                	mv	a1,s1
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	f58080e7          	jalr	-168(ra) # 80002d6c <fetchstr>
}
    80002e1c:	60e2                	ld	ra,24(sp)
    80002e1e:	6442                	ld	s0,16(sp)
    80002e20:	64a2                	ld	s1,8(sp)
    80002e22:	6902                	ld	s2,0(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret

0000000080002e28 <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	e04a                	sd	s2,0(sp)
    80002e32:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e34:	fffff097          	auipc	ra,0xfffff
    80002e38:	d6a080e7          	jalr	-662(ra) # 80001b9e <myproc>
    80002e3c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e3e:	06053903          	ld	s2,96(a0)
    80002e42:	0a893783          	ld	a5,168(s2)
    80002e46:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e4a:	37fd                	addiw	a5,a5,-1
    80002e4c:	4759                	li	a4,22
    80002e4e:	00f76f63          	bltu	a4,a5,80002e6c <syscall+0x44>
    80002e52:	00369713          	slli	a4,a3,0x3
    80002e56:	00007797          	auipc	a5,0x7
    80002e5a:	b8a78793          	addi	a5,a5,-1142 # 800099e0 <syscalls>
    80002e5e:	97ba                	add	a5,a5,a4
    80002e60:	639c                	ld	a5,0(a5)
    80002e62:	c789                	beqz	a5,80002e6c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e64:	9782                	jalr	a5
    80002e66:	06a93823          	sd	a0,112(s2)
    80002e6a:	a839                	j	80002e88 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e6c:	16048613          	addi	a2,s1,352
    80002e70:	40ac                	lw	a1,64(s1)
    80002e72:	00007517          	auipc	a0,0x7
    80002e76:	b3650513          	addi	a0,a0,-1226 # 800099a8 <nointr_desc.1631+0x88>
    80002e7a:	ffffd097          	auipc	ra,0xffffd
    80002e7e:	752080e7          	jalr	1874(ra) # 800005cc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e82:	70bc                	ld	a5,96(s1)
    80002e84:	577d                	li	a4,-1
    80002e86:	fbb8                	sd	a4,112(a5)
  }
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6902                	ld	s2,0(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e94:	1101                	addi	sp,sp,-32
    80002e96:	ec06                	sd	ra,24(sp)
    80002e98:	e822                	sd	s0,16(sp)
    80002e9a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002e9c:	fec40593          	addi	a1,s0,-20
    80002ea0:	4501                	li	a0,0
    80002ea2:	00000097          	auipc	ra,0x0
    80002ea6:	f12080e7          	jalr	-238(ra) # 80002db4 <argint>
    return -1;
    80002eaa:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002eac:	00054963          	bltz	a0,80002ebe <sys_exit+0x2a>
  exit(n);
    80002eb0:	fec42503          	lw	a0,-20(s0)
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	372080e7          	jalr	882(ra) # 80002226 <exit>
  return 0;  // not reached
    80002ebc:	4781                	li	a5,0
}
    80002ebe:	853e                	mv	a0,a5
    80002ec0:	60e2                	ld	ra,24(sp)
    80002ec2:	6442                	ld	s0,16(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ec8:	1141                	addi	sp,sp,-16
    80002eca:	e406                	sd	ra,8(sp)
    80002ecc:	e022                	sd	s0,0(sp)
    80002ece:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	cce080e7          	jalr	-818(ra) # 80001b9e <myproc>
}
    80002ed8:	4128                	lw	a0,64(a0)
    80002eda:	60a2                	ld	ra,8(sp)
    80002edc:	6402                	ld	s0,0(sp)
    80002ede:	0141                	addi	sp,sp,16
    80002ee0:	8082                	ret

0000000080002ee2 <sys_fork>:

uint64
sys_fork(void)
{
    80002ee2:	1141                	addi	sp,sp,-16
    80002ee4:	e406                	sd	ra,8(sp)
    80002ee6:	e022                	sd	s0,0(sp)
    80002ee8:	0800                	addi	s0,sp,16
  return fork();
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	02a080e7          	jalr	42(ra) # 80001f14 <fork>
}
    80002ef2:	60a2                	ld	ra,8(sp)
    80002ef4:	6402                	ld	s0,0(sp)
    80002ef6:	0141                	addi	sp,sp,16
    80002ef8:	8082                	ret

0000000080002efa <sys_wait>:

uint64
sys_wait(void)
{
    80002efa:	1101                	addi	sp,sp,-32
    80002efc:	ec06                	sd	ra,24(sp)
    80002efe:	e822                	sd	s0,16(sp)
    80002f00:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f02:	fe840593          	addi	a1,s0,-24
    80002f06:	4501                	li	a0,0
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	ece080e7          	jalr	-306(ra) # 80002dd6 <argaddr>
    80002f10:	87aa                	mv	a5,a0
    return -1;
    80002f12:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f14:	0007c863          	bltz	a5,80002f24 <sys_wait+0x2a>
  return wait(p);
    80002f18:	fe843503          	ld	a0,-24(s0)
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	4ce080e7          	jalr	1230(ra) # 800023ea <wait>
}
    80002f24:	60e2                	ld	ra,24(sp)
    80002f26:	6442                	ld	s0,16(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret

0000000080002f2c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f2c:	7179                	addi	sp,sp,-48
    80002f2e:	f406                	sd	ra,40(sp)
    80002f30:	f022                	sd	s0,32(sp)
    80002f32:	ec26                	sd	s1,24(sp)
    80002f34:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f36:	fdc40593          	addi	a1,s0,-36
    80002f3a:	4501                	li	a0,0
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	e78080e7          	jalr	-392(ra) # 80002db4 <argint>
    80002f44:	87aa                	mv	a5,a0
    return -1;
    80002f46:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002f48:	0207c063          	bltz	a5,80002f68 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	c52080e7          	jalr	-942(ra) # 80001b9e <myproc>
    80002f54:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002f56:	fdc42503          	lw	a0,-36(s0)
    80002f5a:	fffff097          	auipc	ra,0xfffff
    80002f5e:	f46080e7          	jalr	-186(ra) # 80001ea0 <growproc>
    80002f62:	00054863          	bltz	a0,80002f72 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002f66:	8526                	mv	a0,s1
}
    80002f68:	70a2                	ld	ra,40(sp)
    80002f6a:	7402                	ld	s0,32(sp)
    80002f6c:	64e2                	ld	s1,24(sp)
    80002f6e:	6145                	addi	sp,sp,48
    80002f70:	8082                	ret
    return -1;
    80002f72:	557d                	li	a0,-1
    80002f74:	bfd5                	j	80002f68 <sys_sbrk+0x3c>

0000000080002f76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f76:	7139                	addi	sp,sp,-64
    80002f78:	fc06                	sd	ra,56(sp)
    80002f7a:	f822                	sd	s0,48(sp)
    80002f7c:	f426                	sd	s1,40(sp)
    80002f7e:	f04a                	sd	s2,32(sp)
    80002f80:	ec4e                	sd	s3,24(sp)
    80002f82:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002f84:	fcc40593          	addi	a1,s0,-52
    80002f88:	4501                	li	a0,0
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	e2a080e7          	jalr	-470(ra) # 80002db4 <argint>
    return -1;
    80002f92:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f94:	06054563          	bltz	a0,80002ffe <sys_sleep+0x88>
  acquire(&tickslock);
    80002f98:	00029517          	auipc	a0,0x29
    80002f9c:	da050513          	addi	a0,a0,-608 # 8002bd38 <tickslock>
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	bfc080e7          	jalr	-1028(ra) # 80000b9c <acquire>
  ticks0 = ticks;
    80002fa8:	00007917          	auipc	s2,0x7
    80002fac:	08092903          	lw	s2,128(s2) # 8000a028 <ticks>
  while(ticks - ticks0 < n){
    80002fb0:	fcc42783          	lw	a5,-52(s0)
    80002fb4:	cf85                	beqz	a5,80002fec <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fb6:	00029997          	auipc	s3,0x29
    80002fba:	d8298993          	addi	s3,s3,-638 # 8002bd38 <tickslock>
    80002fbe:	00007497          	auipc	s1,0x7
    80002fc2:	06a48493          	addi	s1,s1,106 # 8000a028 <ticks>
    if(myproc()->killed){
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	bd8080e7          	jalr	-1064(ra) # 80001b9e <myproc>
    80002fce:	5d1c                	lw	a5,56(a0)
    80002fd0:	ef9d                	bnez	a5,8000300e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002fd2:	85ce                	mv	a1,s3
    80002fd4:	8526                	mv	a0,s1
    80002fd6:	fffff097          	auipc	ra,0xfffff
    80002fda:	396080e7          	jalr	918(ra) # 8000236c <sleep>
  while(ticks - ticks0 < n){
    80002fde:	409c                	lw	a5,0(s1)
    80002fe0:	412787bb          	subw	a5,a5,s2
    80002fe4:	fcc42703          	lw	a4,-52(s0)
    80002fe8:	fce7efe3          	bltu	a5,a4,80002fc6 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002fec:	00029517          	auipc	a0,0x29
    80002ff0:	d4c50513          	addi	a0,a0,-692 # 8002bd38 <tickslock>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	c78080e7          	jalr	-904(ra) # 80000c6c <release>
  return 0;
    80002ffc:	4781                	li	a5,0
}
    80002ffe:	853e                	mv	a0,a5
    80003000:	70e2                	ld	ra,56(sp)
    80003002:	7442                	ld	s0,48(sp)
    80003004:	74a2                	ld	s1,40(sp)
    80003006:	7902                	ld	s2,32(sp)
    80003008:	69e2                	ld	s3,24(sp)
    8000300a:	6121                	addi	sp,sp,64
    8000300c:	8082                	ret
      release(&tickslock);
    8000300e:	00029517          	auipc	a0,0x29
    80003012:	d2a50513          	addi	a0,a0,-726 # 8002bd38 <tickslock>
    80003016:	ffffe097          	auipc	ra,0xffffe
    8000301a:	c56080e7          	jalr	-938(ra) # 80000c6c <release>
      return -1;
    8000301e:	57fd                	li	a5,-1
    80003020:	bff9                	j	80002ffe <sys_sleep+0x88>

0000000080003022 <sys_kill>:

uint64
sys_kill(void)
{
    80003022:	1101                	addi	sp,sp,-32
    80003024:	ec06                	sd	ra,24(sp)
    80003026:	e822                	sd	s0,16(sp)
    80003028:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000302a:	fec40593          	addi	a1,s0,-20
    8000302e:	4501                	li	a0,0
    80003030:	00000097          	auipc	ra,0x0
    80003034:	d84080e7          	jalr	-636(ra) # 80002db4 <argint>
    80003038:	87aa                	mv	a5,a0
    return -1;
    8000303a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000303c:	0007c863          	bltz	a5,8000304c <sys_kill+0x2a>
  return kill(pid);
    80003040:	fec42503          	lw	a0,-20(s0)
    80003044:	fffff097          	auipc	ra,0xfffff
    80003048:	518080e7          	jalr	1304(ra) # 8000255c <kill>
}
    8000304c:	60e2                	ld	ra,24(sp)
    8000304e:	6442                	ld	s0,16(sp)
    80003050:	6105                	addi	sp,sp,32
    80003052:	8082                	ret

0000000080003054 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003054:	1101                	addi	sp,sp,-32
    80003056:	ec06                	sd	ra,24(sp)
    80003058:	e822                	sd	s0,16(sp)
    8000305a:	e426                	sd	s1,8(sp)
    8000305c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000305e:	00029517          	auipc	a0,0x29
    80003062:	cda50513          	addi	a0,a0,-806 # 8002bd38 <tickslock>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	b36080e7          	jalr	-1226(ra) # 80000b9c <acquire>
  xticks = ticks;
    8000306e:	00007497          	auipc	s1,0x7
    80003072:	fba4a483          	lw	s1,-70(s1) # 8000a028 <ticks>
  release(&tickslock);
    80003076:	00029517          	auipc	a0,0x29
    8000307a:	cc250513          	addi	a0,a0,-830 # 8002bd38 <tickslock>
    8000307e:	ffffe097          	auipc	ra,0xffffe
    80003082:	bee080e7          	jalr	-1042(ra) # 80000c6c <release>
  return xticks;
}
    80003086:	02049513          	slli	a0,s1,0x20
    8000308a:	9101                	srli	a0,a0,0x20
    8000308c:	60e2                	ld	ra,24(sp)
    8000308e:	6442                	ld	s0,16(sp)
    80003090:	64a2                	ld	s1,8(sp)
    80003092:	6105                	addi	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003096:	7179                	addi	sp,sp,-48
    80003098:	f406                	sd	ra,40(sp)
    8000309a:	f022                	sd	s0,32(sp)
    8000309c:	ec26                	sd	s1,24(sp)
    8000309e:	e84a                	sd	s2,16(sp)
    800030a0:	e44e                	sd	s3,8(sp)
    800030a2:	e052                	sd	s4,0(sp)
    800030a4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030a6:	00007597          	auipc	a1,0x7
    800030aa:	9fa58593          	addi	a1,a1,-1542 # 80009aa0 <syscalls+0xc0>
    800030ae:	00029517          	auipc	a0,0x29
    800030b2:	caa50513          	addi	a0,a0,-854 # 8002bd58 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	a10080e7          	jalr	-1520(ra) # 80000ac6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030be:	00031797          	auipc	a5,0x31
    800030c2:	c9a78793          	addi	a5,a5,-870 # 80033d58 <bcache+0x8000>
    800030c6:	00031717          	auipc	a4,0x31
    800030ca:	ff270713          	addi	a4,a4,-14 # 800340b8 <bcache+0x8360>
    800030ce:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    800030d2:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030d6:	00029497          	auipc	s1,0x29
    800030da:	ca248493          	addi	s1,s1,-862 # 8002bd78 <bcache+0x20>
    b->next = bcache.head.next;
    800030de:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030e0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030e2:	00007a17          	auipc	s4,0x7
    800030e6:	9c6a0a13          	addi	s4,s4,-1594 # 80009aa8 <syscalls+0xc8>
    b->next = bcache.head.next;
    800030ea:	3b893783          	ld	a5,952(s2)
    800030ee:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    800030f0:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    800030f4:	85d2                	mv	a1,s4
    800030f6:	01048513          	addi	a0,s1,16
    800030fa:	00001097          	auipc	ra,0x1
    800030fe:	4aa080e7          	jalr	1194(ra) # 800045a4 <initsleeplock>
    bcache.head.next->prev = b;
    80003102:	3b893783          	ld	a5,952(s2)
    80003106:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80003108:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000310c:	46048493          	addi	s1,s1,1120
    80003110:	fd349de3          	bne	s1,s3,800030ea <binit+0x54>
  }
}
    80003114:	70a2                	ld	ra,40(sp)
    80003116:	7402                	ld	s0,32(sp)
    80003118:	64e2                	ld	s1,24(sp)
    8000311a:	6942                	ld	s2,16(sp)
    8000311c:	69a2                	ld	s3,8(sp)
    8000311e:	6a02                	ld	s4,0(sp)
    80003120:	6145                	addi	sp,sp,48
    80003122:	8082                	ret

0000000080003124 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003124:	7179                	addi	sp,sp,-48
    80003126:	f406                	sd	ra,40(sp)
    80003128:	f022                	sd	s0,32(sp)
    8000312a:	ec26                	sd	s1,24(sp)
    8000312c:	e84a                	sd	s2,16(sp)
    8000312e:	e44e                	sd	s3,8(sp)
    80003130:	1800                	addi	s0,sp,48
    80003132:	89aa                	mv	s3,a0
    80003134:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003136:	00029517          	auipc	a0,0x29
    8000313a:	c2250513          	addi	a0,a0,-990 # 8002bd58 <bcache>
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	a5e080e7          	jalr	-1442(ra) # 80000b9c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003146:	00031497          	auipc	s1,0x31
    8000314a:	fca4b483          	ld	s1,-54(s1) # 80034110 <bcache+0x83b8>
    8000314e:	00031797          	auipc	a5,0x31
    80003152:	f6a78793          	addi	a5,a5,-150 # 800340b8 <bcache+0x8360>
    80003156:	02f48f63          	beq	s1,a5,80003194 <bread+0x70>
    8000315a:	873e                	mv	a4,a5
    8000315c:	a021                	j	80003164 <bread+0x40>
    8000315e:	6ca4                	ld	s1,88(s1)
    80003160:	02e48a63          	beq	s1,a4,80003194 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003164:	449c                	lw	a5,8(s1)
    80003166:	ff379ce3          	bne	a5,s3,8000315e <bread+0x3a>
    8000316a:	44dc                	lw	a5,12(s1)
    8000316c:	ff2799e3          	bne	a5,s2,8000315e <bread+0x3a>
      b->refcnt++;
    80003170:	44bc                	lw	a5,72(s1)
    80003172:	2785                	addiw	a5,a5,1
    80003174:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003176:	00029517          	auipc	a0,0x29
    8000317a:	be250513          	addi	a0,a0,-1054 # 8002bd58 <bcache>
    8000317e:	ffffe097          	auipc	ra,0xffffe
    80003182:	aee080e7          	jalr	-1298(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    80003186:	01048513          	addi	a0,s1,16
    8000318a:	00001097          	auipc	ra,0x1
    8000318e:	454080e7          	jalr	1108(ra) # 800045de <acquiresleep>
      return b;
    80003192:	a8b9                	j	800031f0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003194:	00031497          	auipc	s1,0x31
    80003198:	f744b483          	ld	s1,-140(s1) # 80034108 <bcache+0x83b0>
    8000319c:	00031797          	auipc	a5,0x31
    800031a0:	f1c78793          	addi	a5,a5,-228 # 800340b8 <bcache+0x8360>
    800031a4:	00f48863          	beq	s1,a5,800031b4 <bread+0x90>
    800031a8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031aa:	44bc                	lw	a5,72(s1)
    800031ac:	cf81                	beqz	a5,800031c4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031ae:	68a4                	ld	s1,80(s1)
    800031b0:	fee49de3          	bne	s1,a4,800031aa <bread+0x86>
  panic("bget: no buffers");
    800031b4:	00007517          	auipc	a0,0x7
    800031b8:	8fc50513          	addi	a0,a0,-1796 # 80009ab0 <syscalls+0xd0>
    800031bc:	ffffd097          	auipc	ra,0xffffd
    800031c0:	3ae080e7          	jalr	942(ra) # 8000056a <panic>
      b->dev = dev;
    800031c4:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800031c8:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800031cc:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031d0:	4785                	li	a5,1
    800031d2:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800031d4:	00029517          	auipc	a0,0x29
    800031d8:	b8450513          	addi	a0,a0,-1148 # 8002bd58 <bcache>
    800031dc:	ffffe097          	auipc	ra,0xffffe
    800031e0:	a90080e7          	jalr	-1392(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    800031e4:	01048513          	addi	a0,s1,16
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	3f6080e7          	jalr	1014(ra) # 800045de <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031f0:	409c                	lw	a5,0(s1)
    800031f2:	cb89                	beqz	a5,80003204 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031f4:	8526                	mv	a0,s1
    800031f6:	70a2                	ld	ra,40(sp)
    800031f8:	7402                	ld	s0,32(sp)
    800031fa:	64e2                	ld	s1,24(sp)
    800031fc:	6942                	ld	s2,16(sp)
    800031fe:	69a2                	ld	s3,8(sp)
    80003200:	6145                	addi	sp,sp,48
    80003202:	8082                	ret
    virtio_disk_rw(b, 0);
    80003204:	4581                	li	a1,0
    80003206:	8526                	mv	a0,s1
    80003208:	00003097          	auipc	ra,0x3
    8000320c:	f90080e7          	jalr	-112(ra) # 80006198 <virtio_disk_rw>
    b->valid = 1;
    80003210:	4785                	li	a5,1
    80003212:	c09c                	sw	a5,0(s1)
  return b;
    80003214:	b7c5                	j	800031f4 <bread+0xd0>

0000000080003216 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003216:	1101                	addi	sp,sp,-32
    80003218:	ec06                	sd	ra,24(sp)
    8000321a:	e822                	sd	s0,16(sp)
    8000321c:	e426                	sd	s1,8(sp)
    8000321e:	1000                	addi	s0,sp,32
    80003220:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003222:	0541                	addi	a0,a0,16
    80003224:	00001097          	auipc	ra,0x1
    80003228:	454080e7          	jalr	1108(ra) # 80004678 <holdingsleep>
    8000322c:	cd01                	beqz	a0,80003244 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000322e:	4585                	li	a1,1
    80003230:	8526                	mv	a0,s1
    80003232:	00003097          	auipc	ra,0x3
    80003236:	f66080e7          	jalr	-154(ra) # 80006198 <virtio_disk_rw>
}
    8000323a:	60e2                	ld	ra,24(sp)
    8000323c:	6442                	ld	s0,16(sp)
    8000323e:	64a2                	ld	s1,8(sp)
    80003240:	6105                	addi	sp,sp,32
    80003242:	8082                	ret
    panic("bwrite");
    80003244:	00007517          	auipc	a0,0x7
    80003248:	88450513          	addi	a0,a0,-1916 # 80009ac8 <syscalls+0xe8>
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	31e080e7          	jalr	798(ra) # 8000056a <panic>

0000000080003254 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	e04a                	sd	s2,0(sp)
    8000325e:	1000                	addi	s0,sp,32
    80003260:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003262:	01050913          	addi	s2,a0,16
    80003266:	854a                	mv	a0,s2
    80003268:	00001097          	auipc	ra,0x1
    8000326c:	410080e7          	jalr	1040(ra) # 80004678 <holdingsleep>
    80003270:	c92d                	beqz	a0,800032e2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003272:	854a                	mv	a0,s2
    80003274:	00001097          	auipc	ra,0x1
    80003278:	3c0080e7          	jalr	960(ra) # 80004634 <releasesleep>

  acquire(&bcache.lock);
    8000327c:	00029517          	auipc	a0,0x29
    80003280:	adc50513          	addi	a0,a0,-1316 # 8002bd58 <bcache>
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	918080e7          	jalr	-1768(ra) # 80000b9c <acquire>
  b->refcnt--;
    8000328c:	44bc                	lw	a5,72(s1)
    8000328e:	37fd                	addiw	a5,a5,-1
    80003290:	0007871b          	sext.w	a4,a5
    80003294:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003296:	eb05                	bnez	a4,800032c6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003298:	6cbc                	ld	a5,88(s1)
    8000329a:	68b8                	ld	a4,80(s1)
    8000329c:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    8000329e:	68bc                	ld	a5,80(s1)
    800032a0:	6cb8                	ld	a4,88(s1)
    800032a2:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800032a4:	00031797          	auipc	a5,0x31
    800032a8:	ab478793          	addi	a5,a5,-1356 # 80033d58 <bcache+0x8000>
    800032ac:	3b87b703          	ld	a4,952(a5)
    800032b0:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    800032b2:	00031717          	auipc	a4,0x31
    800032b6:	e0670713          	addi	a4,a4,-506 # 800340b8 <bcache+0x8360>
    800032ba:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800032bc:	3b87b703          	ld	a4,952(a5)
    800032c0:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800032c2:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800032c6:	00029517          	auipc	a0,0x29
    800032ca:	a9250513          	addi	a0,a0,-1390 # 8002bd58 <bcache>
    800032ce:	ffffe097          	auipc	ra,0xffffe
    800032d2:	99e080e7          	jalr	-1634(ra) # 80000c6c <release>
}
    800032d6:	60e2                	ld	ra,24(sp)
    800032d8:	6442                	ld	s0,16(sp)
    800032da:	64a2                	ld	s1,8(sp)
    800032dc:	6902                	ld	s2,0(sp)
    800032de:	6105                	addi	sp,sp,32
    800032e0:	8082                	ret
    panic("brelse");
    800032e2:	00006517          	auipc	a0,0x6
    800032e6:	7ee50513          	addi	a0,a0,2030 # 80009ad0 <syscalls+0xf0>
    800032ea:	ffffd097          	auipc	ra,0xffffd
    800032ee:	280080e7          	jalr	640(ra) # 8000056a <panic>

00000000800032f2 <bpin>:

void
bpin(struct buf *b) {
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
    800032fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fe:	00029517          	auipc	a0,0x29
    80003302:	a5a50513          	addi	a0,a0,-1446 # 8002bd58 <bcache>
    80003306:	ffffe097          	auipc	ra,0xffffe
    8000330a:	896080e7          	jalr	-1898(ra) # 80000b9c <acquire>
  b->refcnt++;
    8000330e:	44bc                	lw	a5,72(s1)
    80003310:	2785                	addiw	a5,a5,1
    80003312:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003314:	00029517          	auipc	a0,0x29
    80003318:	a4450513          	addi	a0,a0,-1468 # 8002bd58 <bcache>
    8000331c:	ffffe097          	auipc	ra,0xffffe
    80003320:	950080e7          	jalr	-1712(ra) # 80000c6c <release>
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret

000000008000332e <bunpin>:

void
bunpin(struct buf *b) {
    8000332e:	1101                	addi	sp,sp,-32
    80003330:	ec06                	sd	ra,24(sp)
    80003332:	e822                	sd	s0,16(sp)
    80003334:	e426                	sd	s1,8(sp)
    80003336:	1000                	addi	s0,sp,32
    80003338:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000333a:	00029517          	auipc	a0,0x29
    8000333e:	a1e50513          	addi	a0,a0,-1506 # 8002bd58 <bcache>
    80003342:	ffffe097          	auipc	ra,0xffffe
    80003346:	85a080e7          	jalr	-1958(ra) # 80000b9c <acquire>
  b->refcnt--;
    8000334a:	44bc                	lw	a5,72(s1)
    8000334c:	37fd                	addiw	a5,a5,-1
    8000334e:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003350:	00029517          	auipc	a0,0x29
    80003354:	a0850513          	addi	a0,a0,-1528 # 8002bd58 <bcache>
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	914080e7          	jalr	-1772(ra) # 80000c6c <release>
}
    80003360:	60e2                	ld	ra,24(sp)
    80003362:	6442                	ld	s0,16(sp)
    80003364:	64a2                	ld	s1,8(sp)
    80003366:	6105                	addi	sp,sp,32
    80003368:	8082                	ret

000000008000336a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	e426                	sd	s1,8(sp)
    80003372:	e04a                	sd	s2,0(sp)
    80003374:	1000                	addi	s0,sp,32
    80003376:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003378:	00d5d59b          	srliw	a1,a1,0xd
    8000337c:	00031797          	auipc	a5,0x31
    80003380:	1b87a783          	lw	a5,440(a5) # 80034534 <sb+0x1c>
    80003384:	9dbd                	addw	a1,a1,a5
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	d9e080e7          	jalr	-610(ra) # 80003124 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000338e:	0074f713          	andi	a4,s1,7
    80003392:	4785                	li	a5,1
    80003394:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003398:	14ce                	slli	s1,s1,0x33
    8000339a:	90d9                	srli	s1,s1,0x36
    8000339c:	00950733          	add	a4,a0,s1
    800033a0:	06074703          	lbu	a4,96(a4)
    800033a4:	00e7f6b3          	and	a3,a5,a4
    800033a8:	c69d                	beqz	a3,800033d6 <bfree+0x6c>
    800033aa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033ac:	94aa                	add	s1,s1,a0
    800033ae:	fff7c793          	not	a5,a5
    800033b2:	8ff9                	and	a5,a5,a4
    800033b4:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800033b8:	00001097          	auipc	ra,0x1
    800033bc:	106080e7          	jalr	262(ra) # 800044be <log_write>
  brelse(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	00000097          	auipc	ra,0x0
    800033c6:	e92080e7          	jalr	-366(ra) # 80003254 <brelse>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret
    panic("freeing free block");
    800033d6:	00006517          	auipc	a0,0x6
    800033da:	70250513          	addi	a0,a0,1794 # 80009ad8 <syscalls+0xf8>
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	18c080e7          	jalr	396(ra) # 8000056a <panic>

00000000800033e6 <balloc>:
{
    800033e6:	711d                	addi	sp,sp,-96
    800033e8:	ec86                	sd	ra,88(sp)
    800033ea:	e8a2                	sd	s0,80(sp)
    800033ec:	e4a6                	sd	s1,72(sp)
    800033ee:	e0ca                	sd	s2,64(sp)
    800033f0:	fc4e                	sd	s3,56(sp)
    800033f2:	f852                	sd	s4,48(sp)
    800033f4:	f456                	sd	s5,40(sp)
    800033f6:	f05a                	sd	s6,32(sp)
    800033f8:	ec5e                	sd	s7,24(sp)
    800033fa:	e862                	sd	s8,16(sp)
    800033fc:	e466                	sd	s9,8(sp)
    800033fe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003400:	00031797          	auipc	a5,0x31
    80003404:	11c7a783          	lw	a5,284(a5) # 8003451c <sb+0x4>
    80003408:	cbd1                	beqz	a5,8000349c <balloc+0xb6>
    8000340a:	8baa                	mv	s7,a0
    8000340c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000340e:	00031b17          	auipc	s6,0x31
    80003412:	10ab0b13          	addi	s6,s6,266 # 80034518 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003416:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003418:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000341c:	6c89                	lui	s9,0x2
    8000341e:	a831                	j	8000343a <balloc+0x54>
    brelse(bp);
    80003420:	854a                	mv	a0,s2
    80003422:	00000097          	auipc	ra,0x0
    80003426:	e32080e7          	jalr	-462(ra) # 80003254 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000342a:	015c87bb          	addw	a5,s9,s5
    8000342e:	00078a9b          	sext.w	s5,a5
    80003432:	004b2703          	lw	a4,4(s6)
    80003436:	06eaf363          	bgeu	s5,a4,8000349c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000343a:	41fad79b          	sraiw	a5,s5,0x1f
    8000343e:	0137d79b          	srliw	a5,a5,0x13
    80003442:	015787bb          	addw	a5,a5,s5
    80003446:	40d7d79b          	sraiw	a5,a5,0xd
    8000344a:	01cb2583          	lw	a1,28(s6)
    8000344e:	9dbd                	addw	a1,a1,a5
    80003450:	855e                	mv	a0,s7
    80003452:	00000097          	auipc	ra,0x0
    80003456:	cd2080e7          	jalr	-814(ra) # 80003124 <bread>
    8000345a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345c:	004b2503          	lw	a0,4(s6)
    80003460:	000a849b          	sext.w	s1,s5
    80003464:	8662                	mv	a2,s8
    80003466:	faa4fde3          	bgeu	s1,a0,80003420 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000346a:	41f6579b          	sraiw	a5,a2,0x1f
    8000346e:	01d7d69b          	srliw	a3,a5,0x1d
    80003472:	00c6873b          	addw	a4,a3,a2
    80003476:	00777793          	andi	a5,a4,7
    8000347a:	9f95                	subw	a5,a5,a3
    8000347c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003480:	4037571b          	sraiw	a4,a4,0x3
    80003484:	00e906b3          	add	a3,s2,a4
    80003488:	0606c683          	lbu	a3,96(a3)
    8000348c:	00d7f5b3          	and	a1,a5,a3
    80003490:	cd91                	beqz	a1,800034ac <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003492:	2605                	addiw	a2,a2,1
    80003494:	2485                	addiw	s1,s1,1
    80003496:	fd4618e3          	bne	a2,s4,80003466 <balloc+0x80>
    8000349a:	b759                	j	80003420 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000349c:	00006517          	auipc	a0,0x6
    800034a0:	65450513          	addi	a0,a0,1620 # 80009af0 <syscalls+0x110>
    800034a4:	ffffd097          	auipc	ra,0xffffd
    800034a8:	0c6080e7          	jalr	198(ra) # 8000056a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034ac:	974a                	add	a4,a4,s2
    800034ae:	8fd5                	or	a5,a5,a3
    800034b0:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800034b4:	854a                	mv	a0,s2
    800034b6:	00001097          	auipc	ra,0x1
    800034ba:	008080e7          	jalr	8(ra) # 800044be <log_write>
        brelse(bp);
    800034be:	854a                	mv	a0,s2
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	d94080e7          	jalr	-620(ra) # 80003254 <brelse>
  bp = bread(dev, bno);
    800034c8:	85a6                	mv	a1,s1
    800034ca:	855e                	mv	a0,s7
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	c58080e7          	jalr	-936(ra) # 80003124 <bread>
    800034d4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800034d6:	40000613          	li	a2,1024
    800034da:	4581                	li	a1,0
    800034dc:	06050513          	addi	a0,a0,96
    800034e0:	ffffe097          	auipc	ra,0xffffe
    800034e4:	9a0080e7          	jalr	-1632(ra) # 80000e80 <memset>
  log_write(bp);
    800034e8:	854a                	mv	a0,s2
    800034ea:	00001097          	auipc	ra,0x1
    800034ee:	fd4080e7          	jalr	-44(ra) # 800044be <log_write>
  brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	d60080e7          	jalr	-672(ra) # 80003254 <brelse>
}
    800034fc:	8526                	mv	a0,s1
    800034fe:	60e6                	ld	ra,88(sp)
    80003500:	6446                	ld	s0,80(sp)
    80003502:	64a6                	ld	s1,72(sp)
    80003504:	6906                	ld	s2,64(sp)
    80003506:	79e2                	ld	s3,56(sp)
    80003508:	7a42                	ld	s4,48(sp)
    8000350a:	7aa2                	ld	s5,40(sp)
    8000350c:	7b02                	ld	s6,32(sp)
    8000350e:	6be2                	ld	s7,24(sp)
    80003510:	6c42                	ld	s8,16(sp)
    80003512:	6ca2                	ld	s9,8(sp)
    80003514:	6125                	addi	sp,sp,96
    80003516:	8082                	ret

0000000080003518 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003518:	7179                	addi	sp,sp,-48
    8000351a:	f406                	sd	ra,40(sp)
    8000351c:	f022                	sd	s0,32(sp)
    8000351e:	ec26                	sd	s1,24(sp)
    80003520:	e84a                	sd	s2,16(sp)
    80003522:	e44e                	sd	s3,8(sp)
    80003524:	e052                	sd	s4,0(sp)
    80003526:	1800                	addi	s0,sp,48
    80003528:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000352a:	47ad                	li	a5,11
    8000352c:	04b7fe63          	bgeu	a5,a1,80003588 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003530:	ff45849b          	addiw	s1,a1,-12
    80003534:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003538:	0ff00793          	li	a5,255
    8000353c:	0ae7e363          	bltu	a5,a4,800035e2 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003540:	08852583          	lw	a1,136(a0)
    80003544:	c5ad                	beqz	a1,800035ae <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003546:	00092503          	lw	a0,0(s2)
    8000354a:	00000097          	auipc	ra,0x0
    8000354e:	bda080e7          	jalr	-1062(ra) # 80003124 <bread>
    80003552:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003554:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003558:	02049593          	slli	a1,s1,0x20
    8000355c:	9181                	srli	a1,a1,0x20
    8000355e:	058a                	slli	a1,a1,0x2
    80003560:	00b784b3          	add	s1,a5,a1
    80003564:	0004a983          	lw	s3,0(s1)
    80003568:	04098d63          	beqz	s3,800035c2 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000356c:	8552                	mv	a0,s4
    8000356e:	00000097          	auipc	ra,0x0
    80003572:	ce6080e7          	jalr	-794(ra) # 80003254 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003576:	854e                	mv	a0,s3
    80003578:	70a2                	ld	ra,40(sp)
    8000357a:	7402                	ld	s0,32(sp)
    8000357c:	64e2                	ld	s1,24(sp)
    8000357e:	6942                	ld	s2,16(sp)
    80003580:	69a2                	ld	s3,8(sp)
    80003582:	6a02                	ld	s4,0(sp)
    80003584:	6145                	addi	sp,sp,48
    80003586:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003588:	02059493          	slli	s1,a1,0x20
    8000358c:	9081                	srli	s1,s1,0x20
    8000358e:	048a                	slli	s1,s1,0x2
    80003590:	94aa                	add	s1,s1,a0
    80003592:	0584a983          	lw	s3,88(s1)
    80003596:	fe0990e3          	bnez	s3,80003576 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000359a:	4108                	lw	a0,0(a0)
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	e4a080e7          	jalr	-438(ra) # 800033e6 <balloc>
    800035a4:	0005099b          	sext.w	s3,a0
    800035a8:	0534ac23          	sw	s3,88(s1)
    800035ac:	b7e9                	j	80003576 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800035ae:	4108                	lw	a0,0(a0)
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	e36080e7          	jalr	-458(ra) # 800033e6 <balloc>
    800035b8:	0005059b          	sext.w	a1,a0
    800035bc:	08b92423          	sw	a1,136(s2)
    800035c0:	b759                	j	80003546 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800035c2:	00092503          	lw	a0,0(s2)
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	e20080e7          	jalr	-480(ra) # 800033e6 <balloc>
    800035ce:	0005099b          	sext.w	s3,a0
    800035d2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800035d6:	8552                	mv	a0,s4
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	ee6080e7          	jalr	-282(ra) # 800044be <log_write>
    800035e0:	b771                	j	8000356c <bmap+0x54>
  panic("bmap: out of range");
    800035e2:	00006517          	auipc	a0,0x6
    800035e6:	52650513          	addi	a0,a0,1318 # 80009b08 <syscalls+0x128>
    800035ea:	ffffd097          	auipc	ra,0xffffd
    800035ee:	f80080e7          	jalr	-128(ra) # 8000056a <panic>

00000000800035f2 <iget>:
{
    800035f2:	7179                	addi	sp,sp,-48
    800035f4:	f406                	sd	ra,40(sp)
    800035f6:	f022                	sd	s0,32(sp)
    800035f8:	ec26                	sd	s1,24(sp)
    800035fa:	e84a                	sd	s2,16(sp)
    800035fc:	e44e                	sd	s3,8(sp)
    800035fe:	e052                	sd	s4,0(sp)
    80003600:	1800                	addi	s0,sp,48
    80003602:	89aa                	mv	s3,a0
    80003604:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003606:	00031517          	auipc	a0,0x31
    8000360a:	f3250513          	addi	a0,a0,-206 # 80034538 <icache>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	58e080e7          	jalr	1422(ra) # 80000b9c <acquire>
  empty = 0;
    80003616:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003618:	00031497          	auipc	s1,0x31
    8000361c:	f4048493          	addi	s1,s1,-192 # 80034558 <icache+0x20>
    80003620:	00033697          	auipc	a3,0x33
    80003624:	b5868693          	addi	a3,a3,-1192 # 80036178 <log>
    80003628:	a039                	j	80003636 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000362a:	02090b63          	beqz	s2,80003660 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000362e:	09048493          	addi	s1,s1,144
    80003632:	02d48a63          	beq	s1,a3,80003666 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003636:	449c                	lw	a5,8(s1)
    80003638:	fef059e3          	blez	a5,8000362a <iget+0x38>
    8000363c:	4098                	lw	a4,0(s1)
    8000363e:	ff3716e3          	bne	a4,s3,8000362a <iget+0x38>
    80003642:	40d8                	lw	a4,4(s1)
    80003644:	ff4713e3          	bne	a4,s4,8000362a <iget+0x38>
      ip->ref++;
    80003648:	2785                	addiw	a5,a5,1
    8000364a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000364c:	00031517          	auipc	a0,0x31
    80003650:	eec50513          	addi	a0,a0,-276 # 80034538 <icache>
    80003654:	ffffd097          	auipc	ra,0xffffd
    80003658:	618080e7          	jalr	1560(ra) # 80000c6c <release>
      return ip;
    8000365c:	8926                	mv	s2,s1
    8000365e:	a03d                	j	8000368c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003660:	f7f9                	bnez	a5,8000362e <iget+0x3c>
    80003662:	8926                	mv	s2,s1
    80003664:	b7e9                	j	8000362e <iget+0x3c>
  if(empty == 0)
    80003666:	02090c63          	beqz	s2,8000369e <iget+0xac>
  ip->dev = dev;
    8000366a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000366e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003672:	4785                	li	a5,1
    80003674:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003678:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    8000367c:	00031517          	auipc	a0,0x31
    80003680:	ebc50513          	addi	a0,a0,-324 # 80034538 <icache>
    80003684:	ffffd097          	auipc	ra,0xffffd
    80003688:	5e8080e7          	jalr	1512(ra) # 80000c6c <release>
}
    8000368c:	854a                	mv	a0,s2
    8000368e:	70a2                	ld	ra,40(sp)
    80003690:	7402                	ld	s0,32(sp)
    80003692:	64e2                	ld	s1,24(sp)
    80003694:	6942                	ld	s2,16(sp)
    80003696:	69a2                	ld	s3,8(sp)
    80003698:	6a02                	ld	s4,0(sp)
    8000369a:	6145                	addi	sp,sp,48
    8000369c:	8082                	ret
    panic("iget: no inodes");
    8000369e:	00006517          	auipc	a0,0x6
    800036a2:	48250513          	addi	a0,a0,1154 # 80009b20 <syscalls+0x140>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	ec4080e7          	jalr	-316(ra) # 8000056a <panic>

00000000800036ae <fsinit>:
fsinit(int dev) {
    800036ae:	7179                	addi	sp,sp,-48
    800036b0:	f406                	sd	ra,40(sp)
    800036b2:	f022                	sd	s0,32(sp)
    800036b4:	ec26                	sd	s1,24(sp)
    800036b6:	e84a                	sd	s2,16(sp)
    800036b8:	e44e                	sd	s3,8(sp)
    800036ba:	1800                	addi	s0,sp,48
    800036bc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036be:	4585                	li	a1,1
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	a64080e7          	jalr	-1436(ra) # 80003124 <bread>
    800036c8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036ca:	00031997          	auipc	s3,0x31
    800036ce:	e4e98993          	addi	s3,s3,-434 # 80034518 <sb>
    800036d2:	02000613          	li	a2,32
    800036d6:	06050593          	addi	a1,a0,96
    800036da:	854e                	mv	a0,s3
    800036dc:	ffffe097          	auipc	ra,0xffffe
    800036e0:	804080e7          	jalr	-2044(ra) # 80000ee0 <memmove>
  brelse(bp);
    800036e4:	8526                	mv	a0,s1
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	b6e080e7          	jalr	-1170(ra) # 80003254 <brelse>
  if(sb.magic != FSMAGIC)
    800036ee:	0009a703          	lw	a4,0(s3)
    800036f2:	102037b7          	lui	a5,0x10203
    800036f6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036fa:	02f71263          	bne	a4,a5,8000371e <fsinit+0x70>
  initlog(dev, &sb);
    800036fe:	00031597          	auipc	a1,0x31
    80003702:	e1a58593          	addi	a1,a1,-486 # 80034518 <sb>
    80003706:	854a                	mv	a0,s2
    80003708:	00001097          	auipc	ra,0x1
    8000370c:	b3e080e7          	jalr	-1218(ra) # 80004246 <initlog>
}
    80003710:	70a2                	ld	ra,40(sp)
    80003712:	7402                	ld	s0,32(sp)
    80003714:	64e2                	ld	s1,24(sp)
    80003716:	6942                	ld	s2,16(sp)
    80003718:	69a2                	ld	s3,8(sp)
    8000371a:	6145                	addi	sp,sp,48
    8000371c:	8082                	ret
    panic("invalid file system");
    8000371e:	00006517          	auipc	a0,0x6
    80003722:	41250513          	addi	a0,a0,1042 # 80009b30 <syscalls+0x150>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	e44080e7          	jalr	-444(ra) # 8000056a <panic>

000000008000372e <iinit>:
{
    8000372e:	7179                	addi	sp,sp,-48
    80003730:	f406                	sd	ra,40(sp)
    80003732:	f022                	sd	s0,32(sp)
    80003734:	ec26                	sd	s1,24(sp)
    80003736:	e84a                	sd	s2,16(sp)
    80003738:	e44e                	sd	s3,8(sp)
    8000373a:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000373c:	00006597          	auipc	a1,0x6
    80003740:	40c58593          	addi	a1,a1,1036 # 80009b48 <syscalls+0x168>
    80003744:	00031517          	auipc	a0,0x31
    80003748:	df450513          	addi	a0,a0,-524 # 80034538 <icache>
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	37a080e7          	jalr	890(ra) # 80000ac6 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003754:	00031497          	auipc	s1,0x31
    80003758:	e1448493          	addi	s1,s1,-492 # 80034568 <icache+0x30>
    8000375c:	00033997          	auipc	s3,0x33
    80003760:	a2c98993          	addi	s3,s3,-1492 # 80036188 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003764:	00006917          	auipc	s2,0x6
    80003768:	3ec90913          	addi	s2,s2,1004 # 80009b50 <syscalls+0x170>
    8000376c:	85ca                	mv	a1,s2
    8000376e:	8526                	mv	a0,s1
    80003770:	00001097          	auipc	ra,0x1
    80003774:	e34080e7          	jalr	-460(ra) # 800045a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003778:	09048493          	addi	s1,s1,144
    8000377c:	ff3498e3          	bne	s1,s3,8000376c <iinit+0x3e>
}
    80003780:	70a2                	ld	ra,40(sp)
    80003782:	7402                	ld	s0,32(sp)
    80003784:	64e2                	ld	s1,24(sp)
    80003786:	6942                	ld	s2,16(sp)
    80003788:	69a2                	ld	s3,8(sp)
    8000378a:	6145                	addi	sp,sp,48
    8000378c:	8082                	ret

000000008000378e <ialloc>:
{
    8000378e:	715d                	addi	sp,sp,-80
    80003790:	e486                	sd	ra,72(sp)
    80003792:	e0a2                	sd	s0,64(sp)
    80003794:	fc26                	sd	s1,56(sp)
    80003796:	f84a                	sd	s2,48(sp)
    80003798:	f44e                	sd	s3,40(sp)
    8000379a:	f052                	sd	s4,32(sp)
    8000379c:	ec56                	sd	s5,24(sp)
    8000379e:	e85a                	sd	s6,16(sp)
    800037a0:	e45e                	sd	s7,8(sp)
    800037a2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037a4:	00031717          	auipc	a4,0x31
    800037a8:	d8072703          	lw	a4,-640(a4) # 80034524 <sb+0xc>
    800037ac:	4785                	li	a5,1
    800037ae:	04e7fa63          	bgeu	a5,a4,80003802 <ialloc+0x74>
    800037b2:	8aaa                	mv	s5,a0
    800037b4:	8bae                	mv	s7,a1
    800037b6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037b8:	00031a17          	auipc	s4,0x31
    800037bc:	d60a0a13          	addi	s4,s4,-672 # 80034518 <sb>
    800037c0:	00048b1b          	sext.w	s6,s1
    800037c4:	0044d593          	srli	a1,s1,0x4
    800037c8:	018a2783          	lw	a5,24(s4)
    800037cc:	9dbd                	addw	a1,a1,a5
    800037ce:	8556                	mv	a0,s5
    800037d0:	00000097          	auipc	ra,0x0
    800037d4:	954080e7          	jalr	-1708(ra) # 80003124 <bread>
    800037d8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037da:	06050993          	addi	s3,a0,96
    800037de:	00f4f793          	andi	a5,s1,15
    800037e2:	079a                	slli	a5,a5,0x6
    800037e4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037e6:	00099783          	lh	a5,0(s3)
    800037ea:	c785                	beqz	a5,80003812 <ialloc+0x84>
    brelse(bp);
    800037ec:	00000097          	auipc	ra,0x0
    800037f0:	a68080e7          	jalr	-1432(ra) # 80003254 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037f4:	0485                	addi	s1,s1,1
    800037f6:	00ca2703          	lw	a4,12(s4)
    800037fa:	0004879b          	sext.w	a5,s1
    800037fe:	fce7e1e3          	bltu	a5,a4,800037c0 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003802:	00006517          	auipc	a0,0x6
    80003806:	35650513          	addi	a0,a0,854 # 80009b58 <syscalls+0x178>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	d60080e7          	jalr	-672(ra) # 8000056a <panic>
      memset(dip, 0, sizeof(*dip));
    80003812:	04000613          	li	a2,64
    80003816:	4581                	li	a1,0
    80003818:	854e                	mv	a0,s3
    8000381a:	ffffd097          	auipc	ra,0xffffd
    8000381e:	666080e7          	jalr	1638(ra) # 80000e80 <memset>
      dip->type = type;
    80003822:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003826:	854a                	mv	a0,s2
    80003828:	00001097          	auipc	ra,0x1
    8000382c:	c96080e7          	jalr	-874(ra) # 800044be <log_write>
      brelse(bp);
    80003830:	854a                	mv	a0,s2
    80003832:	00000097          	auipc	ra,0x0
    80003836:	a22080e7          	jalr	-1502(ra) # 80003254 <brelse>
      return iget(dev, inum);
    8000383a:	85da                	mv	a1,s6
    8000383c:	8556                	mv	a0,s5
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	db4080e7          	jalr	-588(ra) # 800035f2 <iget>
}
    80003846:	60a6                	ld	ra,72(sp)
    80003848:	6406                	ld	s0,64(sp)
    8000384a:	74e2                	ld	s1,56(sp)
    8000384c:	7942                	ld	s2,48(sp)
    8000384e:	79a2                	ld	s3,40(sp)
    80003850:	7a02                	ld	s4,32(sp)
    80003852:	6ae2                	ld	s5,24(sp)
    80003854:	6b42                	ld	s6,16(sp)
    80003856:	6ba2                	ld	s7,8(sp)
    80003858:	6161                	addi	sp,sp,80
    8000385a:	8082                	ret

000000008000385c <iupdate>:
{
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	e04a                	sd	s2,0(sp)
    80003866:	1000                	addi	s0,sp,32
    80003868:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000386a:	415c                	lw	a5,4(a0)
    8000386c:	0047d79b          	srliw	a5,a5,0x4
    80003870:	00031597          	auipc	a1,0x31
    80003874:	cc05a583          	lw	a1,-832(a1) # 80034530 <sb+0x18>
    80003878:	9dbd                	addw	a1,a1,a5
    8000387a:	4108                	lw	a0,0(a0)
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	8a8080e7          	jalr	-1880(ra) # 80003124 <bread>
    80003884:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003886:	06050793          	addi	a5,a0,96
    8000388a:	40c8                	lw	a0,4(s1)
    8000388c:	893d                	andi	a0,a0,15
    8000388e:	051a                	slli	a0,a0,0x6
    80003890:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003892:	04c49703          	lh	a4,76(s1)
    80003896:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000389a:	04e49703          	lh	a4,78(s1)
    8000389e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038a2:	05049703          	lh	a4,80(s1)
    800038a6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038aa:	05249703          	lh	a4,82(s1)
    800038ae:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038b2:	48f8                	lw	a4,84(s1)
    800038b4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038b6:	03400613          	li	a2,52
    800038ba:	05848593          	addi	a1,s1,88
    800038be:	0531                	addi	a0,a0,12
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	620080e7          	jalr	1568(ra) # 80000ee0 <memmove>
  log_write(bp);
    800038c8:	854a                	mv	a0,s2
    800038ca:	00001097          	auipc	ra,0x1
    800038ce:	bf4080e7          	jalr	-1036(ra) # 800044be <log_write>
  brelse(bp);
    800038d2:	854a                	mv	a0,s2
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	980080e7          	jalr	-1664(ra) # 80003254 <brelse>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6902                	ld	s2,0(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret

00000000800038e8 <idup>:
{
    800038e8:	1101                	addi	sp,sp,-32
    800038ea:	ec06                	sd	ra,24(sp)
    800038ec:	e822                	sd	s0,16(sp)
    800038ee:	e426                	sd	s1,8(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800038f4:	00031517          	auipc	a0,0x31
    800038f8:	c4450513          	addi	a0,a0,-956 # 80034538 <icache>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	2a0080e7          	jalr	672(ra) # 80000b9c <acquire>
  ip->ref++;
    80003904:	449c                	lw	a5,8(s1)
    80003906:	2785                	addiw	a5,a5,1
    80003908:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000390a:	00031517          	auipc	a0,0x31
    8000390e:	c2e50513          	addi	a0,a0,-978 # 80034538 <icache>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	35a080e7          	jalr	858(ra) # 80000c6c <release>
}
    8000391a:	8526                	mv	a0,s1
    8000391c:	60e2                	ld	ra,24(sp)
    8000391e:	6442                	ld	s0,16(sp)
    80003920:	64a2                	ld	s1,8(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret

0000000080003926 <ilock>:
{
    80003926:	1101                	addi	sp,sp,-32
    80003928:	ec06                	sd	ra,24(sp)
    8000392a:	e822                	sd	s0,16(sp)
    8000392c:	e426                	sd	s1,8(sp)
    8000392e:	e04a                	sd	s2,0(sp)
    80003930:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003932:	c115                	beqz	a0,80003956 <ilock+0x30>
    80003934:	84aa                	mv	s1,a0
    80003936:	451c                	lw	a5,8(a0)
    80003938:	00f05f63          	blez	a5,80003956 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000393c:	0541                	addi	a0,a0,16
    8000393e:	00001097          	auipc	ra,0x1
    80003942:	ca0080e7          	jalr	-864(ra) # 800045de <acquiresleep>
  if(ip->valid == 0){
    80003946:	44bc                	lw	a5,72(s1)
    80003948:	cf99                	beqz	a5,80003966 <ilock+0x40>
}
    8000394a:	60e2                	ld	ra,24(sp)
    8000394c:	6442                	ld	s0,16(sp)
    8000394e:	64a2                	ld	s1,8(sp)
    80003950:	6902                	ld	s2,0(sp)
    80003952:	6105                	addi	sp,sp,32
    80003954:	8082                	ret
    panic("ilock");
    80003956:	00006517          	auipc	a0,0x6
    8000395a:	21a50513          	addi	a0,a0,538 # 80009b70 <syscalls+0x190>
    8000395e:	ffffd097          	auipc	ra,0xffffd
    80003962:	c0c080e7          	jalr	-1012(ra) # 8000056a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003966:	40dc                	lw	a5,4(s1)
    80003968:	0047d79b          	srliw	a5,a5,0x4
    8000396c:	00031597          	auipc	a1,0x31
    80003970:	bc45a583          	lw	a1,-1084(a1) # 80034530 <sb+0x18>
    80003974:	9dbd                	addw	a1,a1,a5
    80003976:	4088                	lw	a0,0(s1)
    80003978:	fffff097          	auipc	ra,0xfffff
    8000397c:	7ac080e7          	jalr	1964(ra) # 80003124 <bread>
    80003980:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003982:	06050593          	addi	a1,a0,96
    80003986:	40dc                	lw	a5,4(s1)
    80003988:	8bbd                	andi	a5,a5,15
    8000398a:	079a                	slli	a5,a5,0x6
    8000398c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000398e:	00059783          	lh	a5,0(a1)
    80003992:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003996:	00259783          	lh	a5,2(a1)
    8000399a:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    8000399e:	00459783          	lh	a5,4(a1)
    800039a2:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800039a6:	00659783          	lh	a5,6(a1)
    800039aa:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    800039ae:	459c                	lw	a5,8(a1)
    800039b0:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039b2:	03400613          	li	a2,52
    800039b6:	05b1                	addi	a1,a1,12
    800039b8:	05848513          	addi	a0,s1,88
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	524080e7          	jalr	1316(ra) # 80000ee0 <memmove>
    brelse(bp);
    800039c4:	854a                	mv	a0,s2
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	88e080e7          	jalr	-1906(ra) # 80003254 <brelse>
    ip->valid = 1;
    800039ce:	4785                	li	a5,1
    800039d0:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    800039d2:	04c49783          	lh	a5,76(s1)
    800039d6:	fbb5                	bnez	a5,8000394a <ilock+0x24>
      panic("ilock: no type");
    800039d8:	00006517          	auipc	a0,0x6
    800039dc:	1a050513          	addi	a0,a0,416 # 80009b78 <syscalls+0x198>
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	b8a080e7          	jalr	-1142(ra) # 8000056a <panic>

00000000800039e8 <iunlock>:
{
    800039e8:	1101                	addi	sp,sp,-32
    800039ea:	ec06                	sd	ra,24(sp)
    800039ec:	e822                	sd	s0,16(sp)
    800039ee:	e426                	sd	s1,8(sp)
    800039f0:	e04a                	sd	s2,0(sp)
    800039f2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039f4:	c905                	beqz	a0,80003a24 <iunlock+0x3c>
    800039f6:	84aa                	mv	s1,a0
    800039f8:	01050913          	addi	s2,a0,16
    800039fc:	854a                	mv	a0,s2
    800039fe:	00001097          	auipc	ra,0x1
    80003a02:	c7a080e7          	jalr	-902(ra) # 80004678 <holdingsleep>
    80003a06:	cd19                	beqz	a0,80003a24 <iunlock+0x3c>
    80003a08:	449c                	lw	a5,8(s1)
    80003a0a:	00f05d63          	blez	a5,80003a24 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a0e:	854a                	mv	a0,s2
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	c24080e7          	jalr	-988(ra) # 80004634 <releasesleep>
}
    80003a18:	60e2                	ld	ra,24(sp)
    80003a1a:	6442                	ld	s0,16(sp)
    80003a1c:	64a2                	ld	s1,8(sp)
    80003a1e:	6902                	ld	s2,0(sp)
    80003a20:	6105                	addi	sp,sp,32
    80003a22:	8082                	ret
    panic("iunlock");
    80003a24:	00006517          	auipc	a0,0x6
    80003a28:	16450513          	addi	a0,a0,356 # 80009b88 <syscalls+0x1a8>
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	b3e080e7          	jalr	-1218(ra) # 8000056a <panic>

0000000080003a34 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a34:	7179                	addi	sp,sp,-48
    80003a36:	f406                	sd	ra,40(sp)
    80003a38:	f022                	sd	s0,32(sp)
    80003a3a:	ec26                	sd	s1,24(sp)
    80003a3c:	e84a                	sd	s2,16(sp)
    80003a3e:	e44e                	sd	s3,8(sp)
    80003a40:	e052                	sd	s4,0(sp)
    80003a42:	1800                	addi	s0,sp,48
    80003a44:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a46:	05850493          	addi	s1,a0,88
    80003a4a:	08850913          	addi	s2,a0,136
    80003a4e:	a021                	j	80003a56 <itrunc+0x22>
    80003a50:	0491                	addi	s1,s1,4
    80003a52:	01248d63          	beq	s1,s2,80003a6c <itrunc+0x38>
    if(ip->addrs[i]){
    80003a56:	408c                	lw	a1,0(s1)
    80003a58:	dde5                	beqz	a1,80003a50 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a5a:	0009a503          	lw	a0,0(s3)
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	90c080e7          	jalr	-1780(ra) # 8000336a <bfree>
      ip->addrs[i] = 0;
    80003a66:	0004a023          	sw	zero,0(s1)
    80003a6a:	b7dd                	j	80003a50 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a6c:	0889a583          	lw	a1,136(s3)
    80003a70:	e185                	bnez	a1,80003a90 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a72:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003a76:	854e                	mv	a0,s3
    80003a78:	00000097          	auipc	ra,0x0
    80003a7c:	de4080e7          	jalr	-540(ra) # 8000385c <iupdate>
}
    80003a80:	70a2                	ld	ra,40(sp)
    80003a82:	7402                	ld	s0,32(sp)
    80003a84:	64e2                	ld	s1,24(sp)
    80003a86:	6942                	ld	s2,16(sp)
    80003a88:	69a2                	ld	s3,8(sp)
    80003a8a:	6a02                	ld	s4,0(sp)
    80003a8c:	6145                	addi	sp,sp,48
    80003a8e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a90:	0009a503          	lw	a0,0(s3)
    80003a94:	fffff097          	auipc	ra,0xfffff
    80003a98:	690080e7          	jalr	1680(ra) # 80003124 <bread>
    80003a9c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a9e:	06050493          	addi	s1,a0,96
    80003aa2:	46050913          	addi	s2,a0,1120
    80003aa6:	a811                	j	80003aba <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003aa8:	0009a503          	lw	a0,0(s3)
    80003aac:	00000097          	auipc	ra,0x0
    80003ab0:	8be080e7          	jalr	-1858(ra) # 8000336a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ab4:	0491                	addi	s1,s1,4
    80003ab6:	01248563          	beq	s1,s2,80003ac0 <itrunc+0x8c>
      if(a[j])
    80003aba:	408c                	lw	a1,0(s1)
    80003abc:	dde5                	beqz	a1,80003ab4 <itrunc+0x80>
    80003abe:	b7ed                	j	80003aa8 <itrunc+0x74>
    brelse(bp);
    80003ac0:	8552                	mv	a0,s4
    80003ac2:	fffff097          	auipc	ra,0xfffff
    80003ac6:	792080e7          	jalr	1938(ra) # 80003254 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003aca:	0889a583          	lw	a1,136(s3)
    80003ace:	0009a503          	lw	a0,0(s3)
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	898080e7          	jalr	-1896(ra) # 8000336a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ada:	0809a423          	sw	zero,136(s3)
    80003ade:	bf51                	j	80003a72 <itrunc+0x3e>

0000000080003ae0 <iput>:
{
    80003ae0:	1101                	addi	sp,sp,-32
    80003ae2:	ec06                	sd	ra,24(sp)
    80003ae4:	e822                	sd	s0,16(sp)
    80003ae6:	e426                	sd	s1,8(sp)
    80003ae8:	e04a                	sd	s2,0(sp)
    80003aea:	1000                	addi	s0,sp,32
    80003aec:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003aee:	00031517          	auipc	a0,0x31
    80003af2:	a4a50513          	addi	a0,a0,-1462 # 80034538 <icache>
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	0a6080e7          	jalr	166(ra) # 80000b9c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003afe:	4498                	lw	a4,8(s1)
    80003b00:	4785                	li	a5,1
    80003b02:	02f70363          	beq	a4,a5,80003b28 <iput+0x48>
  ip->ref--;
    80003b06:	449c                	lw	a5,8(s1)
    80003b08:	37fd                	addiw	a5,a5,-1
    80003b0a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b0c:	00031517          	auipc	a0,0x31
    80003b10:	a2c50513          	addi	a0,a0,-1492 # 80034538 <icache>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	158080e7          	jalr	344(ra) # 80000c6c <release>
}
    80003b1c:	60e2                	ld	ra,24(sp)
    80003b1e:	6442                	ld	s0,16(sp)
    80003b20:	64a2                	ld	s1,8(sp)
    80003b22:	6902                	ld	s2,0(sp)
    80003b24:	6105                	addi	sp,sp,32
    80003b26:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b28:	44bc                	lw	a5,72(s1)
    80003b2a:	dff1                	beqz	a5,80003b06 <iput+0x26>
    80003b2c:	05249783          	lh	a5,82(s1)
    80003b30:	fbf9                	bnez	a5,80003b06 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b32:	01048913          	addi	s2,s1,16
    80003b36:	854a                	mv	a0,s2
    80003b38:	00001097          	auipc	ra,0x1
    80003b3c:	aa6080e7          	jalr	-1370(ra) # 800045de <acquiresleep>
    release(&icache.lock);
    80003b40:	00031517          	auipc	a0,0x31
    80003b44:	9f850513          	addi	a0,a0,-1544 # 80034538 <icache>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	124080e7          	jalr	292(ra) # 80000c6c <release>
    itrunc(ip);
    80003b50:	8526                	mv	a0,s1
    80003b52:	00000097          	auipc	ra,0x0
    80003b56:	ee2080e7          	jalr	-286(ra) # 80003a34 <itrunc>
    ip->type = 0;
    80003b5a:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003b5e:	8526                	mv	a0,s1
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	cfc080e7          	jalr	-772(ra) # 8000385c <iupdate>
    ip->valid = 0;
    80003b68:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003b6c:	854a                	mv	a0,s2
    80003b6e:	00001097          	auipc	ra,0x1
    80003b72:	ac6080e7          	jalr	-1338(ra) # 80004634 <releasesleep>
    acquire(&icache.lock);
    80003b76:	00031517          	auipc	a0,0x31
    80003b7a:	9c250513          	addi	a0,a0,-1598 # 80034538 <icache>
    80003b7e:	ffffd097          	auipc	ra,0xffffd
    80003b82:	01e080e7          	jalr	30(ra) # 80000b9c <acquire>
    80003b86:	b741                	j	80003b06 <iput+0x26>

0000000080003b88 <iunlockput>:
{
    80003b88:	1101                	addi	sp,sp,-32
    80003b8a:	ec06                	sd	ra,24(sp)
    80003b8c:	e822                	sd	s0,16(sp)
    80003b8e:	e426                	sd	s1,8(sp)
    80003b90:	1000                	addi	s0,sp,32
    80003b92:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	e54080e7          	jalr	-428(ra) # 800039e8 <iunlock>
  iput(ip);
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	00000097          	auipc	ra,0x0
    80003ba2:	f42080e7          	jalr	-190(ra) # 80003ae0 <iput>
}
    80003ba6:	60e2                	ld	ra,24(sp)
    80003ba8:	6442                	ld	s0,16(sp)
    80003baa:	64a2                	ld	s1,8(sp)
    80003bac:	6105                	addi	sp,sp,32
    80003bae:	8082                	ret

0000000080003bb0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bb0:	1141                	addi	sp,sp,-16
    80003bb2:	e422                	sd	s0,8(sp)
    80003bb4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bb6:	411c                	lw	a5,0(a0)
    80003bb8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bba:	415c                	lw	a5,4(a0)
    80003bbc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bbe:	04c51783          	lh	a5,76(a0)
    80003bc2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bc6:	05251783          	lh	a5,82(a0)
    80003bca:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bce:	05456783          	lwu	a5,84(a0)
    80003bd2:	e99c                	sd	a5,16(a1)
}
    80003bd4:	6422                	ld	s0,8(sp)
    80003bd6:	0141                	addi	sp,sp,16
    80003bd8:	8082                	ret

0000000080003bda <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bda:	497c                	lw	a5,84(a0)
    80003bdc:	0ed7e963          	bltu	a5,a3,80003cce <readi+0xf4>
{
    80003be0:	7159                	addi	sp,sp,-112
    80003be2:	f486                	sd	ra,104(sp)
    80003be4:	f0a2                	sd	s0,96(sp)
    80003be6:	eca6                	sd	s1,88(sp)
    80003be8:	e8ca                	sd	s2,80(sp)
    80003bea:	e4ce                	sd	s3,72(sp)
    80003bec:	e0d2                	sd	s4,64(sp)
    80003bee:	fc56                	sd	s5,56(sp)
    80003bf0:	f85a                	sd	s6,48(sp)
    80003bf2:	f45e                	sd	s7,40(sp)
    80003bf4:	f062                	sd	s8,32(sp)
    80003bf6:	ec66                	sd	s9,24(sp)
    80003bf8:	e86a                	sd	s10,16(sp)
    80003bfa:	e46e                	sd	s11,8(sp)
    80003bfc:	1880                	addi	s0,sp,112
    80003bfe:	8baa                	mv	s7,a0
    80003c00:	8c2e                	mv	s8,a1
    80003c02:	8ab2                	mv	s5,a2
    80003c04:	84b6                	mv	s1,a3
    80003c06:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c08:	9f35                	addw	a4,a4,a3
    return 0;
    80003c0a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c0c:	0ad76063          	bltu	a4,a3,80003cac <readi+0xd2>
  if(off + n > ip->size)
    80003c10:	00e7f463          	bgeu	a5,a4,80003c18 <readi+0x3e>
    n = ip->size - off;
    80003c14:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c18:	0a0b0963          	beqz	s6,80003cca <readi+0xf0>
    80003c1c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c1e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c22:	5cfd                	li	s9,-1
    80003c24:	a82d                	j	80003c5e <readi+0x84>
    80003c26:	020a1d93          	slli	s11,s4,0x20
    80003c2a:	020ddd93          	srli	s11,s11,0x20
    80003c2e:	06090613          	addi	a2,s2,96
    80003c32:	86ee                	mv	a3,s11
    80003c34:	963a                	add	a2,a2,a4
    80003c36:	85d6                	mv	a1,s5
    80003c38:	8562                	mv	a0,s8
    80003c3a:	fffff097          	auipc	ra,0xfffff
    80003c3e:	994080e7          	jalr	-1644(ra) # 800025ce <either_copyout>
    80003c42:	05950d63          	beq	a0,s9,80003c9c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c46:	854a                	mv	a0,s2
    80003c48:	fffff097          	auipc	ra,0xfffff
    80003c4c:	60c080e7          	jalr	1548(ra) # 80003254 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c50:	013a09bb          	addw	s3,s4,s3
    80003c54:	009a04bb          	addw	s1,s4,s1
    80003c58:	9aee                	add	s5,s5,s11
    80003c5a:	0569f763          	bgeu	s3,s6,80003ca8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c5e:	000ba903          	lw	s2,0(s7)
    80003c62:	00a4d59b          	srliw	a1,s1,0xa
    80003c66:	855e                	mv	a0,s7
    80003c68:	00000097          	auipc	ra,0x0
    80003c6c:	8b0080e7          	jalr	-1872(ra) # 80003518 <bmap>
    80003c70:	0005059b          	sext.w	a1,a0
    80003c74:	854a                	mv	a0,s2
    80003c76:	fffff097          	auipc	ra,0xfffff
    80003c7a:	4ae080e7          	jalr	1198(ra) # 80003124 <bread>
    80003c7e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c80:	3ff4f713          	andi	a4,s1,1023
    80003c84:	40ed07bb          	subw	a5,s10,a4
    80003c88:	413b06bb          	subw	a3,s6,s3
    80003c8c:	8a3e                	mv	s4,a5
    80003c8e:	2781                	sext.w	a5,a5
    80003c90:	0006861b          	sext.w	a2,a3
    80003c94:	f8f679e3          	bgeu	a2,a5,80003c26 <readi+0x4c>
    80003c98:	8a36                	mv	s4,a3
    80003c9a:	b771                	j	80003c26 <readi+0x4c>
      brelse(bp);
    80003c9c:	854a                	mv	a0,s2
    80003c9e:	fffff097          	auipc	ra,0xfffff
    80003ca2:	5b6080e7          	jalr	1462(ra) # 80003254 <brelse>
      tot = -1;
    80003ca6:	59fd                	li	s3,-1
  }
  return tot;
    80003ca8:	0009851b          	sext.w	a0,s3
}
    80003cac:	70a6                	ld	ra,104(sp)
    80003cae:	7406                	ld	s0,96(sp)
    80003cb0:	64e6                	ld	s1,88(sp)
    80003cb2:	6946                	ld	s2,80(sp)
    80003cb4:	69a6                	ld	s3,72(sp)
    80003cb6:	6a06                	ld	s4,64(sp)
    80003cb8:	7ae2                	ld	s5,56(sp)
    80003cba:	7b42                	ld	s6,48(sp)
    80003cbc:	7ba2                	ld	s7,40(sp)
    80003cbe:	7c02                	ld	s8,32(sp)
    80003cc0:	6ce2                	ld	s9,24(sp)
    80003cc2:	6d42                	ld	s10,16(sp)
    80003cc4:	6da2                	ld	s11,8(sp)
    80003cc6:	6165                	addi	sp,sp,112
    80003cc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cca:	89da                	mv	s3,s6
    80003ccc:	bff1                	j	80003ca8 <readi+0xce>
    return 0;
    80003cce:	4501                	li	a0,0
}
    80003cd0:	8082                	ret

0000000080003cd2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cd2:	497c                	lw	a5,84(a0)
    80003cd4:	10d7e863          	bltu	a5,a3,80003de4 <writei+0x112>
{
    80003cd8:	7159                	addi	sp,sp,-112
    80003cda:	f486                	sd	ra,104(sp)
    80003cdc:	f0a2                	sd	s0,96(sp)
    80003cde:	eca6                	sd	s1,88(sp)
    80003ce0:	e8ca                	sd	s2,80(sp)
    80003ce2:	e4ce                	sd	s3,72(sp)
    80003ce4:	e0d2                	sd	s4,64(sp)
    80003ce6:	fc56                	sd	s5,56(sp)
    80003ce8:	f85a                	sd	s6,48(sp)
    80003cea:	f45e                	sd	s7,40(sp)
    80003cec:	f062                	sd	s8,32(sp)
    80003cee:	ec66                	sd	s9,24(sp)
    80003cf0:	e86a                	sd	s10,16(sp)
    80003cf2:	e46e                	sd	s11,8(sp)
    80003cf4:	1880                	addi	s0,sp,112
    80003cf6:	8b2a                	mv	s6,a0
    80003cf8:	8c2e                	mv	s8,a1
    80003cfa:	8ab2                	mv	s5,a2
    80003cfc:	8936                	mv	s2,a3
    80003cfe:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003d00:	00e687bb          	addw	a5,a3,a4
    80003d04:	0ed7e263          	bltu	a5,a3,80003de8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d08:	00043737          	lui	a4,0x43
    80003d0c:	0ef76063          	bltu	a4,a5,80003dec <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d10:	0c0b8863          	beqz	s7,80003de0 <writei+0x10e>
    80003d14:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d16:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d1a:	5cfd                	li	s9,-1
    80003d1c:	a091                	j	80003d60 <writei+0x8e>
    80003d1e:	02099d93          	slli	s11,s3,0x20
    80003d22:	020ddd93          	srli	s11,s11,0x20
    80003d26:	06048513          	addi	a0,s1,96
    80003d2a:	86ee                	mv	a3,s11
    80003d2c:	8656                	mv	a2,s5
    80003d2e:	85e2                	mv	a1,s8
    80003d30:	953a                	add	a0,a0,a4
    80003d32:	fffff097          	auipc	ra,0xfffff
    80003d36:	8f2080e7          	jalr	-1806(ra) # 80002624 <either_copyin>
    80003d3a:	07950263          	beq	a0,s9,80003d9e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	77e080e7          	jalr	1918(ra) # 800044be <log_write>
    brelse(bp);
    80003d48:	8526                	mv	a0,s1
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	50a080e7          	jalr	1290(ra) # 80003254 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d52:	01498a3b          	addw	s4,s3,s4
    80003d56:	0129893b          	addw	s2,s3,s2
    80003d5a:	9aee                	add	s5,s5,s11
    80003d5c:	057a7663          	bgeu	s4,s7,80003da8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d60:	000b2483          	lw	s1,0(s6)
    80003d64:	00a9559b          	srliw	a1,s2,0xa
    80003d68:	855a                	mv	a0,s6
    80003d6a:	fffff097          	auipc	ra,0xfffff
    80003d6e:	7ae080e7          	jalr	1966(ra) # 80003518 <bmap>
    80003d72:	0005059b          	sext.w	a1,a0
    80003d76:	8526                	mv	a0,s1
    80003d78:	fffff097          	auipc	ra,0xfffff
    80003d7c:	3ac080e7          	jalr	940(ra) # 80003124 <bread>
    80003d80:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d82:	3ff97713          	andi	a4,s2,1023
    80003d86:	40ed07bb          	subw	a5,s10,a4
    80003d8a:	414b86bb          	subw	a3,s7,s4
    80003d8e:	89be                	mv	s3,a5
    80003d90:	2781                	sext.w	a5,a5
    80003d92:	0006861b          	sext.w	a2,a3
    80003d96:	f8f674e3          	bgeu	a2,a5,80003d1e <writei+0x4c>
    80003d9a:	89b6                	mv	s3,a3
    80003d9c:	b749                	j	80003d1e <writei+0x4c>
      brelse(bp);
    80003d9e:	8526                	mv	a0,s1
    80003da0:	fffff097          	auipc	ra,0xfffff
    80003da4:	4b4080e7          	jalr	1204(ra) # 80003254 <brelse>
  }

  if(off > ip->size)
    80003da8:	054b2783          	lw	a5,84(s6)
    80003dac:	0127f463          	bgeu	a5,s2,80003db4 <writei+0xe2>
    ip->size = off;
    80003db0:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003db4:	855a                	mv	a0,s6
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	aa6080e7          	jalr	-1370(ra) # 8000385c <iupdate>

  return tot;
    80003dbe:	000a051b          	sext.w	a0,s4
}
    80003dc2:	70a6                	ld	ra,104(sp)
    80003dc4:	7406                	ld	s0,96(sp)
    80003dc6:	64e6                	ld	s1,88(sp)
    80003dc8:	6946                	ld	s2,80(sp)
    80003dca:	69a6                	ld	s3,72(sp)
    80003dcc:	6a06                	ld	s4,64(sp)
    80003dce:	7ae2                	ld	s5,56(sp)
    80003dd0:	7b42                	ld	s6,48(sp)
    80003dd2:	7ba2                	ld	s7,40(sp)
    80003dd4:	7c02                	ld	s8,32(sp)
    80003dd6:	6ce2                	ld	s9,24(sp)
    80003dd8:	6d42                	ld	s10,16(sp)
    80003dda:	6da2                	ld	s11,8(sp)
    80003ddc:	6165                	addi	sp,sp,112
    80003dde:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de0:	8a5e                	mv	s4,s7
    80003de2:	bfc9                	j	80003db4 <writei+0xe2>
    return -1;
    80003de4:	557d                	li	a0,-1
}
    80003de6:	8082                	ret
    return -1;
    80003de8:	557d                	li	a0,-1
    80003dea:	bfe1                	j	80003dc2 <writei+0xf0>
    return -1;
    80003dec:	557d                	li	a0,-1
    80003dee:	bfd1                	j	80003dc2 <writei+0xf0>

0000000080003df0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003df0:	1141                	addi	sp,sp,-16
    80003df2:	e406                	sd	ra,8(sp)
    80003df4:	e022                	sd	s0,0(sp)
    80003df6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003df8:	4639                	li	a2,14
    80003dfa:	ffffd097          	auipc	ra,0xffffd
    80003dfe:	18a080e7          	jalr	394(ra) # 80000f84 <strncmp>
}
    80003e02:	60a2                	ld	ra,8(sp)
    80003e04:	6402                	ld	s0,0(sp)
    80003e06:	0141                	addi	sp,sp,16
    80003e08:	8082                	ret

0000000080003e0a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e0a:	7139                	addi	sp,sp,-64
    80003e0c:	fc06                	sd	ra,56(sp)
    80003e0e:	f822                	sd	s0,48(sp)
    80003e10:	f426                	sd	s1,40(sp)
    80003e12:	f04a                	sd	s2,32(sp)
    80003e14:	ec4e                	sd	s3,24(sp)
    80003e16:	e852                	sd	s4,16(sp)
    80003e18:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e1a:	04c51703          	lh	a4,76(a0)
    80003e1e:	4785                	li	a5,1
    80003e20:	00f71a63          	bne	a4,a5,80003e34 <dirlookup+0x2a>
    80003e24:	892a                	mv	s2,a0
    80003e26:	89ae                	mv	s3,a1
    80003e28:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2a:	497c                	lw	a5,84(a0)
    80003e2c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e2e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e30:	e79d                	bnez	a5,80003e5e <dirlookup+0x54>
    80003e32:	a8a5                	j	80003eaa <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e34:	00006517          	auipc	a0,0x6
    80003e38:	d5c50513          	addi	a0,a0,-676 # 80009b90 <syscalls+0x1b0>
    80003e3c:	ffffc097          	auipc	ra,0xffffc
    80003e40:	72e080e7          	jalr	1838(ra) # 8000056a <panic>
      panic("dirlookup read");
    80003e44:	00006517          	auipc	a0,0x6
    80003e48:	d6450513          	addi	a0,a0,-668 # 80009ba8 <syscalls+0x1c8>
    80003e4c:	ffffc097          	auipc	ra,0xffffc
    80003e50:	71e080e7          	jalr	1822(ra) # 8000056a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e54:	24c1                	addiw	s1,s1,16
    80003e56:	05492783          	lw	a5,84(s2)
    80003e5a:	04f4f763          	bgeu	s1,a5,80003ea8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5e:	4741                	li	a4,16
    80003e60:	86a6                	mv	a3,s1
    80003e62:	fc040613          	addi	a2,s0,-64
    80003e66:	4581                	li	a1,0
    80003e68:	854a                	mv	a0,s2
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	d70080e7          	jalr	-656(ra) # 80003bda <readi>
    80003e72:	47c1                	li	a5,16
    80003e74:	fcf518e3          	bne	a0,a5,80003e44 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e78:	fc045783          	lhu	a5,-64(s0)
    80003e7c:	dfe1                	beqz	a5,80003e54 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e7e:	fc240593          	addi	a1,s0,-62
    80003e82:	854e                	mv	a0,s3
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	f6c080e7          	jalr	-148(ra) # 80003df0 <namecmp>
    80003e8c:	f561                	bnez	a0,80003e54 <dirlookup+0x4a>
      if(poff)
    80003e8e:	000a0463          	beqz	s4,80003e96 <dirlookup+0x8c>
        *poff = off;
    80003e92:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e96:	fc045583          	lhu	a1,-64(s0)
    80003e9a:	00092503          	lw	a0,0(s2)
    80003e9e:	fffff097          	auipc	ra,0xfffff
    80003ea2:	754080e7          	jalr	1876(ra) # 800035f2 <iget>
    80003ea6:	a011                	j	80003eaa <dirlookup+0xa0>
  return 0;
    80003ea8:	4501                	li	a0,0
}
    80003eaa:	70e2                	ld	ra,56(sp)
    80003eac:	7442                	ld	s0,48(sp)
    80003eae:	74a2                	ld	s1,40(sp)
    80003eb0:	7902                	ld	s2,32(sp)
    80003eb2:	69e2                	ld	s3,24(sp)
    80003eb4:	6a42                	ld	s4,16(sp)
    80003eb6:	6121                	addi	sp,sp,64
    80003eb8:	8082                	ret

0000000080003eba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eba:	711d                	addi	sp,sp,-96
    80003ebc:	ec86                	sd	ra,88(sp)
    80003ebe:	e8a2                	sd	s0,80(sp)
    80003ec0:	e4a6                	sd	s1,72(sp)
    80003ec2:	e0ca                	sd	s2,64(sp)
    80003ec4:	fc4e                	sd	s3,56(sp)
    80003ec6:	f852                	sd	s4,48(sp)
    80003ec8:	f456                	sd	s5,40(sp)
    80003eca:	f05a                	sd	s6,32(sp)
    80003ecc:	ec5e                	sd	s7,24(sp)
    80003ece:	e862                	sd	s8,16(sp)
    80003ed0:	e466                	sd	s9,8(sp)
    80003ed2:	1080                	addi	s0,sp,96
    80003ed4:	84aa                	mv	s1,a0
    80003ed6:	8b2e                	mv	s6,a1
    80003ed8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003eda:	00054703          	lbu	a4,0(a0)
    80003ede:	02f00793          	li	a5,47
    80003ee2:	02f70363          	beq	a4,a5,80003f08 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ee6:	ffffe097          	auipc	ra,0xffffe
    80003eea:	cb8080e7          	jalr	-840(ra) # 80001b9e <myproc>
    80003eee:	15853503          	ld	a0,344(a0)
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	9f6080e7          	jalr	-1546(ra) # 800038e8 <idup>
    80003efa:	89aa                	mv	s3,a0
  while(*path == '/')
    80003efc:	02f00913          	li	s2,47
  len = path - s;
    80003f00:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003f02:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f04:	4c05                	li	s8,1
    80003f06:	a865                	j	80003fbe <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f08:	4585                	li	a1,1
    80003f0a:	4505                	li	a0,1
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	6e6080e7          	jalr	1766(ra) # 800035f2 <iget>
    80003f14:	89aa                	mv	s3,a0
    80003f16:	b7dd                	j	80003efc <namex+0x42>
      iunlockput(ip);
    80003f18:	854e                	mv	a0,s3
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	c6e080e7          	jalr	-914(ra) # 80003b88 <iunlockput>
      return 0;
    80003f22:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f24:	854e                	mv	a0,s3
    80003f26:	60e6                	ld	ra,88(sp)
    80003f28:	6446                	ld	s0,80(sp)
    80003f2a:	64a6                	ld	s1,72(sp)
    80003f2c:	6906                	ld	s2,64(sp)
    80003f2e:	79e2                	ld	s3,56(sp)
    80003f30:	7a42                	ld	s4,48(sp)
    80003f32:	7aa2                	ld	s5,40(sp)
    80003f34:	7b02                	ld	s6,32(sp)
    80003f36:	6be2                	ld	s7,24(sp)
    80003f38:	6c42                	ld	s8,16(sp)
    80003f3a:	6ca2                	ld	s9,8(sp)
    80003f3c:	6125                	addi	sp,sp,96
    80003f3e:	8082                	ret
      iunlock(ip);
    80003f40:	854e                	mv	a0,s3
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	aa6080e7          	jalr	-1370(ra) # 800039e8 <iunlock>
      return ip;
    80003f4a:	bfe9                	j	80003f24 <namex+0x6a>
      iunlockput(ip);
    80003f4c:	854e                	mv	a0,s3
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	c3a080e7          	jalr	-966(ra) # 80003b88 <iunlockput>
      return 0;
    80003f56:	89d2                	mv	s3,s4
    80003f58:	b7f1                	j	80003f24 <namex+0x6a>
  len = path - s;
    80003f5a:	40b48633          	sub	a2,s1,a1
    80003f5e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003f62:	094cd463          	bge	s9,s4,80003fea <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003f66:	4639                	li	a2,14
    80003f68:	8556                	mv	a0,s5
    80003f6a:	ffffd097          	auipc	ra,0xffffd
    80003f6e:	f76080e7          	jalr	-138(ra) # 80000ee0 <memmove>
  while(*path == '/')
    80003f72:	0004c783          	lbu	a5,0(s1)
    80003f76:	01279763          	bne	a5,s2,80003f84 <namex+0xca>
    path++;
    80003f7a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f7c:	0004c783          	lbu	a5,0(s1)
    80003f80:	ff278de3          	beq	a5,s2,80003f7a <namex+0xc0>
    ilock(ip);
    80003f84:	854e                	mv	a0,s3
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	9a0080e7          	jalr	-1632(ra) # 80003926 <ilock>
    if(ip->type != T_DIR){
    80003f8e:	04c99783          	lh	a5,76(s3)
    80003f92:	f98793e3          	bne	a5,s8,80003f18 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f96:	000b0563          	beqz	s6,80003fa0 <namex+0xe6>
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	d3cd                	beqz	a5,80003f40 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fa0:	865e                	mv	a2,s7
    80003fa2:	85d6                	mv	a1,s5
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	e64080e7          	jalr	-412(ra) # 80003e0a <dirlookup>
    80003fae:	8a2a                	mv	s4,a0
    80003fb0:	dd51                	beqz	a0,80003f4c <namex+0x92>
    iunlockput(ip);
    80003fb2:	854e                	mv	a0,s3
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	bd4080e7          	jalr	-1068(ra) # 80003b88 <iunlockput>
    ip = next;
    80003fbc:	89d2                	mv	s3,s4
  while(*path == '/')
    80003fbe:	0004c783          	lbu	a5,0(s1)
    80003fc2:	05279763          	bne	a5,s2,80004010 <namex+0x156>
    path++;
    80003fc6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fc8:	0004c783          	lbu	a5,0(s1)
    80003fcc:	ff278de3          	beq	a5,s2,80003fc6 <namex+0x10c>
  if(*path == 0)
    80003fd0:	c79d                	beqz	a5,80003ffe <namex+0x144>
    path++;
    80003fd2:	85a6                	mv	a1,s1
  len = path - s;
    80003fd4:	8a5e                	mv	s4,s7
    80003fd6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fd8:	01278963          	beq	a5,s2,80003fea <namex+0x130>
    80003fdc:	dfbd                	beqz	a5,80003f5a <namex+0xa0>
    path++;
    80003fde:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003fe0:	0004c783          	lbu	a5,0(s1)
    80003fe4:	ff279ce3          	bne	a5,s2,80003fdc <namex+0x122>
    80003fe8:	bf8d                	j	80003f5a <namex+0xa0>
    memmove(name, s, len);
    80003fea:	2601                	sext.w	a2,a2
    80003fec:	8556                	mv	a0,s5
    80003fee:	ffffd097          	auipc	ra,0xffffd
    80003ff2:	ef2080e7          	jalr	-270(ra) # 80000ee0 <memmove>
    name[len] = 0;
    80003ff6:	9a56                	add	s4,s4,s5
    80003ff8:	000a0023          	sb	zero,0(s4)
    80003ffc:	bf9d                	j	80003f72 <namex+0xb8>
  if(nameiparent){
    80003ffe:	f20b03e3          	beqz	s6,80003f24 <namex+0x6a>
    iput(ip);
    80004002:	854e                	mv	a0,s3
    80004004:	00000097          	auipc	ra,0x0
    80004008:	adc080e7          	jalr	-1316(ra) # 80003ae0 <iput>
    return 0;
    8000400c:	4981                	li	s3,0
    8000400e:	bf19                	j	80003f24 <namex+0x6a>
  if(*path == 0)
    80004010:	d7fd                	beqz	a5,80003ffe <namex+0x144>
  while(*path != '/' && *path != 0)
    80004012:	0004c783          	lbu	a5,0(s1)
    80004016:	85a6                	mv	a1,s1
    80004018:	b7d1                	j	80003fdc <namex+0x122>

000000008000401a <dirlink>:
{
    8000401a:	7139                	addi	sp,sp,-64
    8000401c:	fc06                	sd	ra,56(sp)
    8000401e:	f822                	sd	s0,48(sp)
    80004020:	f426                	sd	s1,40(sp)
    80004022:	f04a                	sd	s2,32(sp)
    80004024:	ec4e                	sd	s3,24(sp)
    80004026:	e852                	sd	s4,16(sp)
    80004028:	0080                	addi	s0,sp,64
    8000402a:	892a                	mv	s2,a0
    8000402c:	8a2e                	mv	s4,a1
    8000402e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004030:	4601                	li	a2,0
    80004032:	00000097          	auipc	ra,0x0
    80004036:	dd8080e7          	jalr	-552(ra) # 80003e0a <dirlookup>
    8000403a:	e93d                	bnez	a0,800040b0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000403c:	05492483          	lw	s1,84(s2)
    80004040:	c49d                	beqz	s1,8000406e <dirlink+0x54>
    80004042:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004044:	4741                	li	a4,16
    80004046:	86a6                	mv	a3,s1
    80004048:	fc040613          	addi	a2,s0,-64
    8000404c:	4581                	li	a1,0
    8000404e:	854a                	mv	a0,s2
    80004050:	00000097          	auipc	ra,0x0
    80004054:	b8a080e7          	jalr	-1142(ra) # 80003bda <readi>
    80004058:	47c1                	li	a5,16
    8000405a:	06f51163          	bne	a0,a5,800040bc <dirlink+0xa2>
    if(de.inum == 0)
    8000405e:	fc045783          	lhu	a5,-64(s0)
    80004062:	c791                	beqz	a5,8000406e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004064:	24c1                	addiw	s1,s1,16
    80004066:	05492783          	lw	a5,84(s2)
    8000406a:	fcf4ede3          	bltu	s1,a5,80004044 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000406e:	4639                	li	a2,14
    80004070:	85d2                	mv	a1,s4
    80004072:	fc240513          	addi	a0,s0,-62
    80004076:	ffffd097          	auipc	ra,0xffffd
    8000407a:	f4a080e7          	jalr	-182(ra) # 80000fc0 <strncpy>
  de.inum = inum;
    8000407e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004082:	4741                	li	a4,16
    80004084:	86a6                	mv	a3,s1
    80004086:	fc040613          	addi	a2,s0,-64
    8000408a:	4581                	li	a1,0
    8000408c:	854a                	mv	a0,s2
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	c44080e7          	jalr	-956(ra) # 80003cd2 <writei>
    80004096:	872a                	mv	a4,a0
    80004098:	47c1                	li	a5,16
  return 0;
    8000409a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409c:	02f71863          	bne	a4,a5,800040cc <dirlink+0xb2>
}
    800040a0:	70e2                	ld	ra,56(sp)
    800040a2:	7442                	ld	s0,48(sp)
    800040a4:	74a2                	ld	s1,40(sp)
    800040a6:	7902                	ld	s2,32(sp)
    800040a8:	69e2                	ld	s3,24(sp)
    800040aa:	6a42                	ld	s4,16(sp)
    800040ac:	6121                	addi	sp,sp,64
    800040ae:	8082                	ret
    iput(ip);
    800040b0:	00000097          	auipc	ra,0x0
    800040b4:	a30080e7          	jalr	-1488(ra) # 80003ae0 <iput>
    return -1;
    800040b8:	557d                	li	a0,-1
    800040ba:	b7dd                	j	800040a0 <dirlink+0x86>
      panic("dirlink read");
    800040bc:	00006517          	auipc	a0,0x6
    800040c0:	afc50513          	addi	a0,a0,-1284 # 80009bb8 <syscalls+0x1d8>
    800040c4:	ffffc097          	auipc	ra,0xffffc
    800040c8:	4a6080e7          	jalr	1190(ra) # 8000056a <panic>
    panic("dirlink");
    800040cc:	00006517          	auipc	a0,0x6
    800040d0:	bfc50513          	addi	a0,a0,-1028 # 80009cc8 <syscalls+0x2e8>
    800040d4:	ffffc097          	auipc	ra,0xffffc
    800040d8:	496080e7          	jalr	1174(ra) # 8000056a <panic>

00000000800040dc <namei>:

struct inode*
namei(char *path)
{
    800040dc:	1101                	addi	sp,sp,-32
    800040de:	ec06                	sd	ra,24(sp)
    800040e0:	e822                	sd	s0,16(sp)
    800040e2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040e4:	fe040613          	addi	a2,s0,-32
    800040e8:	4581                	li	a1,0
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	dd0080e7          	jalr	-560(ra) # 80003eba <namex>
}
    800040f2:	60e2                	ld	ra,24(sp)
    800040f4:	6442                	ld	s0,16(sp)
    800040f6:	6105                	addi	sp,sp,32
    800040f8:	8082                	ret

00000000800040fa <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040fa:	1141                	addi	sp,sp,-16
    800040fc:	e406                	sd	ra,8(sp)
    800040fe:	e022                	sd	s0,0(sp)
    80004100:	0800                	addi	s0,sp,16
    80004102:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004104:	4585                	li	a1,1
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	db4080e7          	jalr	-588(ra) # 80003eba <namex>
}
    8000410e:	60a2                	ld	ra,8(sp)
    80004110:	6402                	ld	s0,0(sp)
    80004112:	0141                	addi	sp,sp,16
    80004114:	8082                	ret

0000000080004116 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004116:	1101                	addi	sp,sp,-32
    80004118:	ec06                	sd	ra,24(sp)
    8000411a:	e822                	sd	s0,16(sp)
    8000411c:	e426                	sd	s1,8(sp)
    8000411e:	e04a                	sd	s2,0(sp)
    80004120:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004122:	00032917          	auipc	s2,0x32
    80004126:	05690913          	addi	s2,s2,86 # 80036178 <log>
    8000412a:	02092583          	lw	a1,32(s2)
    8000412e:	03092503          	lw	a0,48(s2)
    80004132:	fffff097          	auipc	ra,0xfffff
    80004136:	ff2080e7          	jalr	-14(ra) # 80003124 <bread>
    8000413a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000413c:	03492683          	lw	a3,52(s2)
    80004140:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004142:	02d05763          	blez	a3,80004170 <write_head+0x5a>
    80004146:	00032797          	auipc	a5,0x32
    8000414a:	06a78793          	addi	a5,a5,106 # 800361b0 <log+0x38>
    8000414e:	06450713          	addi	a4,a0,100
    80004152:	36fd                	addiw	a3,a3,-1
    80004154:	1682                	slli	a3,a3,0x20
    80004156:	9281                	srli	a3,a3,0x20
    80004158:	068a                	slli	a3,a3,0x2
    8000415a:	00032617          	auipc	a2,0x32
    8000415e:	05a60613          	addi	a2,a2,90 # 800361b4 <log+0x3c>
    80004162:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004164:	4390                	lw	a2,0(a5)
    80004166:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004168:	0791                	addi	a5,a5,4
    8000416a:	0711                	addi	a4,a4,4
    8000416c:	fed79ce3          	bne	a5,a3,80004164 <write_head+0x4e>
  }
  bwrite(buf);
    80004170:	8526                	mv	a0,s1
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	0a4080e7          	jalr	164(ra) # 80003216 <bwrite>
  brelse(buf);
    8000417a:	8526                	mv	a0,s1
    8000417c:	fffff097          	auipc	ra,0xfffff
    80004180:	0d8080e7          	jalr	216(ra) # 80003254 <brelse>
}
    80004184:	60e2                	ld	ra,24(sp)
    80004186:	6442                	ld	s0,16(sp)
    80004188:	64a2                	ld	s1,8(sp)
    8000418a:	6902                	ld	s2,0(sp)
    8000418c:	6105                	addi	sp,sp,32
    8000418e:	8082                	ret

0000000080004190 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004190:	00032797          	auipc	a5,0x32
    80004194:	01c7a783          	lw	a5,28(a5) # 800361ac <log+0x34>
    80004198:	0af05663          	blez	a5,80004244 <install_trans+0xb4>
{
    8000419c:	7139                	addi	sp,sp,-64
    8000419e:	fc06                	sd	ra,56(sp)
    800041a0:	f822                	sd	s0,48(sp)
    800041a2:	f426                	sd	s1,40(sp)
    800041a4:	f04a                	sd	s2,32(sp)
    800041a6:	ec4e                	sd	s3,24(sp)
    800041a8:	e852                	sd	s4,16(sp)
    800041aa:	e456                	sd	s5,8(sp)
    800041ac:	0080                	addi	s0,sp,64
    800041ae:	00032a97          	auipc	s5,0x32
    800041b2:	002a8a93          	addi	s5,s5,2 # 800361b0 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041b8:	00032997          	auipc	s3,0x32
    800041bc:	fc098993          	addi	s3,s3,-64 # 80036178 <log>
    800041c0:	0209a583          	lw	a1,32(s3)
    800041c4:	014585bb          	addw	a1,a1,s4
    800041c8:	2585                	addiw	a1,a1,1
    800041ca:	0309a503          	lw	a0,48(s3)
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	f56080e7          	jalr	-170(ra) # 80003124 <bread>
    800041d6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041d8:	000aa583          	lw	a1,0(s5)
    800041dc:	0309a503          	lw	a0,48(s3)
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	f44080e7          	jalr	-188(ra) # 80003124 <bread>
    800041e8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041ea:	40000613          	li	a2,1024
    800041ee:	06090593          	addi	a1,s2,96
    800041f2:	06050513          	addi	a0,a0,96
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	cea080e7          	jalr	-790(ra) # 80000ee0 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041fe:	8526                	mv	a0,s1
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	016080e7          	jalr	22(ra) # 80003216 <bwrite>
    bunpin(dbuf);
    80004208:	8526                	mv	a0,s1
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	124080e7          	jalr	292(ra) # 8000332e <bunpin>
    brelse(lbuf);
    80004212:	854a                	mv	a0,s2
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	040080e7          	jalr	64(ra) # 80003254 <brelse>
    brelse(dbuf);
    8000421c:	8526                	mv	a0,s1
    8000421e:	fffff097          	auipc	ra,0xfffff
    80004222:	036080e7          	jalr	54(ra) # 80003254 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004226:	2a05                	addiw	s4,s4,1
    80004228:	0a91                	addi	s5,s5,4
    8000422a:	0349a783          	lw	a5,52(s3)
    8000422e:	f8fa49e3          	blt	s4,a5,800041c0 <install_trans+0x30>
}
    80004232:	70e2                	ld	ra,56(sp)
    80004234:	7442                	ld	s0,48(sp)
    80004236:	74a2                	ld	s1,40(sp)
    80004238:	7902                	ld	s2,32(sp)
    8000423a:	69e2                	ld	s3,24(sp)
    8000423c:	6a42                	ld	s4,16(sp)
    8000423e:	6aa2                	ld	s5,8(sp)
    80004240:	6121                	addi	sp,sp,64
    80004242:	8082                	ret
    80004244:	8082                	ret

0000000080004246 <initlog>:
{
    80004246:	7179                	addi	sp,sp,-48
    80004248:	f406                	sd	ra,40(sp)
    8000424a:	f022                	sd	s0,32(sp)
    8000424c:	ec26                	sd	s1,24(sp)
    8000424e:	e84a                	sd	s2,16(sp)
    80004250:	e44e                	sd	s3,8(sp)
    80004252:	1800                	addi	s0,sp,48
    80004254:	892a                	mv	s2,a0
    80004256:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004258:	00032497          	auipc	s1,0x32
    8000425c:	f2048493          	addi	s1,s1,-224 # 80036178 <log>
    80004260:	00006597          	auipc	a1,0x6
    80004264:	96858593          	addi	a1,a1,-1688 # 80009bc8 <syscalls+0x1e8>
    80004268:	8526                	mv	a0,s1
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	85c080e7          	jalr	-1956(ra) # 80000ac6 <initlock>
  log.start = sb->logstart;
    80004272:	0149a583          	lw	a1,20(s3)
    80004276:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    80004278:	0109a783          	lw	a5,16(s3)
    8000427c:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    8000427e:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004282:	854a                	mv	a0,s2
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	ea0080e7          	jalr	-352(ra) # 80003124 <bread>
  log.lh.n = lh->n;
    8000428c:	513c                	lw	a5,96(a0)
    8000428e:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004290:	02f05563          	blez	a5,800042ba <initlog+0x74>
    80004294:	06450713          	addi	a4,a0,100
    80004298:	00032697          	auipc	a3,0x32
    8000429c:	f1868693          	addi	a3,a3,-232 # 800361b0 <log+0x38>
    800042a0:	37fd                	addiw	a5,a5,-1
    800042a2:	1782                	slli	a5,a5,0x20
    800042a4:	9381                	srli	a5,a5,0x20
    800042a6:	078a                	slli	a5,a5,0x2
    800042a8:	06850613          	addi	a2,a0,104
    800042ac:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800042ae:	4310                	lw	a2,0(a4)
    800042b0:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800042b2:	0711                	addi	a4,a4,4
    800042b4:	0691                	addi	a3,a3,4
    800042b6:	fef71ce3          	bne	a4,a5,800042ae <initlog+0x68>
  brelse(buf);
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	f9a080e7          	jalr	-102(ra) # 80003254 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	ece080e7          	jalr	-306(ra) # 80004190 <install_trans>
  log.lh.n = 0;
    800042ca:	00032797          	auipc	a5,0x32
    800042ce:	ee07a123          	sw	zero,-286(a5) # 800361ac <log+0x34>
  write_head(); // clear the log
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	e44080e7          	jalr	-444(ra) # 80004116 <write_head>
}
    800042da:	70a2                	ld	ra,40(sp)
    800042dc:	7402                	ld	s0,32(sp)
    800042de:	64e2                	ld	s1,24(sp)
    800042e0:	6942                	ld	s2,16(sp)
    800042e2:	69a2                	ld	s3,8(sp)
    800042e4:	6145                	addi	sp,sp,48
    800042e6:	8082                	ret

00000000800042e8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042e8:	1101                	addi	sp,sp,-32
    800042ea:	ec06                	sd	ra,24(sp)
    800042ec:	e822                	sd	s0,16(sp)
    800042ee:	e426                	sd	s1,8(sp)
    800042f0:	e04a                	sd	s2,0(sp)
    800042f2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042f4:	00032517          	auipc	a0,0x32
    800042f8:	e8450513          	addi	a0,a0,-380 # 80036178 <log>
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	8a0080e7          	jalr	-1888(ra) # 80000b9c <acquire>
  while(1){
    if(log.committing){
    80004304:	00032497          	auipc	s1,0x32
    80004308:	e7448493          	addi	s1,s1,-396 # 80036178 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000430c:	4979                	li	s2,30
    8000430e:	a039                	j	8000431c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004310:	85a6                	mv	a1,s1
    80004312:	8526                	mv	a0,s1
    80004314:	ffffe097          	auipc	ra,0xffffe
    80004318:	058080e7          	jalr	88(ra) # 8000236c <sleep>
    if(log.committing){
    8000431c:	54dc                	lw	a5,44(s1)
    8000431e:	fbed                	bnez	a5,80004310 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004320:	549c                	lw	a5,40(s1)
    80004322:	0017871b          	addiw	a4,a5,1
    80004326:	0007069b          	sext.w	a3,a4
    8000432a:	0027179b          	slliw	a5,a4,0x2
    8000432e:	9fb9                	addw	a5,a5,a4
    80004330:	0017979b          	slliw	a5,a5,0x1
    80004334:	58d8                	lw	a4,52(s1)
    80004336:	9fb9                	addw	a5,a5,a4
    80004338:	00f95963          	bge	s2,a5,8000434a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000433c:	85a6                	mv	a1,s1
    8000433e:	8526                	mv	a0,s1
    80004340:	ffffe097          	auipc	ra,0xffffe
    80004344:	02c080e7          	jalr	44(ra) # 8000236c <sleep>
    80004348:	bfd1                	j	8000431c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000434a:	00032517          	auipc	a0,0x32
    8000434e:	e2e50513          	addi	a0,a0,-466 # 80036178 <log>
    80004352:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004354:	ffffd097          	auipc	ra,0xffffd
    80004358:	918080e7          	jalr	-1768(ra) # 80000c6c <release>
      break;
    }
  }
}
    8000435c:	60e2                	ld	ra,24(sp)
    8000435e:	6442                	ld	s0,16(sp)
    80004360:	64a2                	ld	s1,8(sp)
    80004362:	6902                	ld	s2,0(sp)
    80004364:	6105                	addi	sp,sp,32
    80004366:	8082                	ret

0000000080004368 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004368:	7139                	addi	sp,sp,-64
    8000436a:	fc06                	sd	ra,56(sp)
    8000436c:	f822                	sd	s0,48(sp)
    8000436e:	f426                	sd	s1,40(sp)
    80004370:	f04a                	sd	s2,32(sp)
    80004372:	ec4e                	sd	s3,24(sp)
    80004374:	e852                	sd	s4,16(sp)
    80004376:	e456                	sd	s5,8(sp)
    80004378:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000437a:	00032497          	auipc	s1,0x32
    8000437e:	dfe48493          	addi	s1,s1,-514 # 80036178 <log>
    80004382:	8526                	mv	a0,s1
    80004384:	ffffd097          	auipc	ra,0xffffd
    80004388:	818080e7          	jalr	-2024(ra) # 80000b9c <acquire>
  log.outstanding -= 1;
    8000438c:	549c                	lw	a5,40(s1)
    8000438e:	37fd                	addiw	a5,a5,-1
    80004390:	0007891b          	sext.w	s2,a5
    80004394:	d49c                	sw	a5,40(s1)
  if(log.committing)
    80004396:	54dc                	lw	a5,44(s1)
    80004398:	efb9                	bnez	a5,800043f6 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000439a:	06091663          	bnez	s2,80004406 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000439e:	00032497          	auipc	s1,0x32
    800043a2:	dda48493          	addi	s1,s1,-550 # 80036178 <log>
    800043a6:	4785                	li	a5,1
    800043a8:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043aa:	8526                	mv	a0,s1
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	8c0080e7          	jalr	-1856(ra) # 80000c6c <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    800043b4:	58dc                	lw	a5,52(s1)
    800043b6:	06f04763          	bgtz	a5,80004424 <end_op+0xbc>
    acquire(&log.lock);
    800043ba:	00032497          	auipc	s1,0x32
    800043be:	dbe48493          	addi	s1,s1,-578 # 80036178 <log>
    800043c2:	8526                	mv	a0,s1
    800043c4:	ffffc097          	auipc	ra,0xffffc
    800043c8:	7d8080e7          	jalr	2008(ra) # 80000b9c <acquire>
    log.committing = 0;
    800043cc:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    800043d0:	8526                	mv	a0,s1
    800043d2:	ffffe097          	auipc	ra,0xffffe
    800043d6:	120080e7          	jalr	288(ra) # 800024f2 <wakeup>
    release(&log.lock);
    800043da:	8526                	mv	a0,s1
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	890080e7          	jalr	-1904(ra) # 80000c6c <release>
}
    800043e4:	70e2                	ld	ra,56(sp)
    800043e6:	7442                	ld	s0,48(sp)
    800043e8:	74a2                	ld	s1,40(sp)
    800043ea:	7902                	ld	s2,32(sp)
    800043ec:	69e2                	ld	s3,24(sp)
    800043ee:	6a42                	ld	s4,16(sp)
    800043f0:	6aa2                	ld	s5,8(sp)
    800043f2:	6121                	addi	sp,sp,64
    800043f4:	8082                	ret
    panic("log.committing");
    800043f6:	00005517          	auipc	a0,0x5
    800043fa:	7da50513          	addi	a0,a0,2010 # 80009bd0 <syscalls+0x1f0>
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	16c080e7          	jalr	364(ra) # 8000056a <panic>
    wakeup(&log);
    80004406:	00032497          	auipc	s1,0x32
    8000440a:	d7248493          	addi	s1,s1,-654 # 80036178 <log>
    8000440e:	8526                	mv	a0,s1
    80004410:	ffffe097          	auipc	ra,0xffffe
    80004414:	0e2080e7          	jalr	226(ra) # 800024f2 <wakeup>
  release(&log.lock);
    80004418:	8526                	mv	a0,s1
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	852080e7          	jalr	-1966(ra) # 80000c6c <release>
  if(do_commit){
    80004422:	b7c9                	j	800043e4 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004424:	00032a97          	auipc	s5,0x32
    80004428:	d8ca8a93          	addi	s5,s5,-628 # 800361b0 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000442c:	00032a17          	auipc	s4,0x32
    80004430:	d4ca0a13          	addi	s4,s4,-692 # 80036178 <log>
    80004434:	020a2583          	lw	a1,32(s4)
    80004438:	012585bb          	addw	a1,a1,s2
    8000443c:	2585                	addiw	a1,a1,1
    8000443e:	030a2503          	lw	a0,48(s4)
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	ce2080e7          	jalr	-798(ra) # 80003124 <bread>
    8000444a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000444c:	000aa583          	lw	a1,0(s5)
    80004450:	030a2503          	lw	a0,48(s4)
    80004454:	fffff097          	auipc	ra,0xfffff
    80004458:	cd0080e7          	jalr	-816(ra) # 80003124 <bread>
    8000445c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000445e:	40000613          	li	a2,1024
    80004462:	06050593          	addi	a1,a0,96
    80004466:	06048513          	addi	a0,s1,96
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	a76080e7          	jalr	-1418(ra) # 80000ee0 <memmove>
    bwrite(to);  // write the log
    80004472:	8526                	mv	a0,s1
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	da2080e7          	jalr	-606(ra) # 80003216 <bwrite>
    brelse(from);
    8000447c:	854e                	mv	a0,s3
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	dd6080e7          	jalr	-554(ra) # 80003254 <brelse>
    brelse(to);
    80004486:	8526                	mv	a0,s1
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	dcc080e7          	jalr	-564(ra) # 80003254 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004490:	2905                	addiw	s2,s2,1
    80004492:	0a91                	addi	s5,s5,4
    80004494:	034a2783          	lw	a5,52(s4)
    80004498:	f8f94ee3          	blt	s2,a5,80004434 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	c7a080e7          	jalr	-902(ra) # 80004116 <write_head>
    install_trans(); // Now install writes to home locations
    800044a4:	00000097          	auipc	ra,0x0
    800044a8:	cec080e7          	jalr	-788(ra) # 80004190 <install_trans>
    log.lh.n = 0;
    800044ac:	00032797          	auipc	a5,0x32
    800044b0:	d007a023          	sw	zero,-768(a5) # 800361ac <log+0x34>
    write_head();    // Erase the transaction from the log
    800044b4:	00000097          	auipc	ra,0x0
    800044b8:	c62080e7          	jalr	-926(ra) # 80004116 <write_head>
    800044bc:	bdfd                	j	800043ba <end_op+0x52>

00000000800044be <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044be:	1101                	addi	sp,sp,-32
    800044c0:	ec06                	sd	ra,24(sp)
    800044c2:	e822                	sd	s0,16(sp)
    800044c4:	e426                	sd	s1,8(sp)
    800044c6:	e04a                	sd	s2,0(sp)
    800044c8:	1000                	addi	s0,sp,32
    800044ca:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044cc:	00032917          	auipc	s2,0x32
    800044d0:	cac90913          	addi	s2,s2,-852 # 80036178 <log>
    800044d4:	854a                	mv	a0,s2
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	6c6080e7          	jalr	1734(ra) # 80000b9c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044de:	03492603          	lw	a2,52(s2)
    800044e2:	47f5                	li	a5,29
    800044e4:	06c7c563          	blt	a5,a2,8000454e <log_write+0x90>
    800044e8:	00032797          	auipc	a5,0x32
    800044ec:	cb47a783          	lw	a5,-844(a5) # 8003619c <log+0x24>
    800044f0:	37fd                	addiw	a5,a5,-1
    800044f2:	04f65e63          	bge	a2,a5,8000454e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044f6:	00032797          	auipc	a5,0x32
    800044fa:	caa7a783          	lw	a5,-854(a5) # 800361a0 <log+0x28>
    800044fe:	06f05063          	blez	a5,8000455e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004502:	4781                	li	a5,0
    80004504:	06c05563          	blez	a2,8000456e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004508:	44cc                	lw	a1,12(s1)
    8000450a:	00032717          	auipc	a4,0x32
    8000450e:	ca670713          	addi	a4,a4,-858 # 800361b0 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    80004512:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004514:	4314                	lw	a3,0(a4)
    80004516:	04b68c63          	beq	a3,a1,8000456e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000451a:	2785                	addiw	a5,a5,1
    8000451c:	0711                	addi	a4,a4,4
    8000451e:	fef61be3          	bne	a2,a5,80004514 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004522:	0631                	addi	a2,a2,12
    80004524:	060a                	slli	a2,a2,0x2
    80004526:	00032797          	auipc	a5,0x32
    8000452a:	c5278793          	addi	a5,a5,-942 # 80036178 <log>
    8000452e:	963e                	add	a2,a2,a5
    80004530:	44dc                	lw	a5,12(s1)
    80004532:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004534:	8526                	mv	a0,s1
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	dbc080e7          	jalr	-580(ra) # 800032f2 <bpin>
    log.lh.n++;
    8000453e:	00032717          	auipc	a4,0x32
    80004542:	c3a70713          	addi	a4,a4,-966 # 80036178 <log>
    80004546:	5b5c                	lw	a5,52(a4)
    80004548:	2785                	addiw	a5,a5,1
    8000454a:	db5c                	sw	a5,52(a4)
    8000454c:	a835                	j	80004588 <log_write+0xca>
    panic("too big a transaction");
    8000454e:	00005517          	auipc	a0,0x5
    80004552:	69250513          	addi	a0,a0,1682 # 80009be0 <syscalls+0x200>
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	014080e7          	jalr	20(ra) # 8000056a <panic>
    panic("log_write outside of trans");
    8000455e:	00005517          	auipc	a0,0x5
    80004562:	69a50513          	addi	a0,a0,1690 # 80009bf8 <syscalls+0x218>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	004080e7          	jalr	4(ra) # 8000056a <panic>
  log.lh.block[i] = b->blockno;
    8000456e:	00c78713          	addi	a4,a5,12
    80004572:	00271693          	slli	a3,a4,0x2
    80004576:	00032717          	auipc	a4,0x32
    8000457a:	c0270713          	addi	a4,a4,-1022 # 80036178 <log>
    8000457e:	9736                	add	a4,a4,a3
    80004580:	44d4                	lw	a3,12(s1)
    80004582:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004584:	faf608e3          	beq	a2,a5,80004534 <log_write+0x76>
  }
  release(&log.lock);
    80004588:	00032517          	auipc	a0,0x32
    8000458c:	bf050513          	addi	a0,a0,-1040 # 80036178 <log>
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	6dc080e7          	jalr	1756(ra) # 80000c6c <release>
}
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6902                	ld	s2,0(sp)
    800045a0:	6105                	addi	sp,sp,32
    800045a2:	8082                	ret

00000000800045a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045a4:	1101                	addi	sp,sp,-32
    800045a6:	ec06                	sd	ra,24(sp)
    800045a8:	e822                	sd	s0,16(sp)
    800045aa:	e426                	sd	s1,8(sp)
    800045ac:	e04a                	sd	s2,0(sp)
    800045ae:	1000                	addi	s0,sp,32
    800045b0:	84aa                	mv	s1,a0
    800045b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045b4:	00005597          	auipc	a1,0x5
    800045b8:	66458593          	addi	a1,a1,1636 # 80009c18 <syscalls+0x238>
    800045bc:	0521                	addi	a0,a0,8
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	508080e7          	jalr	1288(ra) # 80000ac6 <initlock>
  lk->name = name;
    800045c6:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800045ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ce:	0204a823          	sw	zero,48(s1)
}
    800045d2:	60e2                	ld	ra,24(sp)
    800045d4:	6442                	ld	s0,16(sp)
    800045d6:	64a2                	ld	s1,8(sp)
    800045d8:	6902                	ld	s2,0(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret

00000000800045de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045de:	1101                	addi	sp,sp,-32
    800045e0:	ec06                	sd	ra,24(sp)
    800045e2:	e822                	sd	s0,16(sp)
    800045e4:	e426                	sd	s1,8(sp)
    800045e6:	e04a                	sd	s2,0(sp)
    800045e8:	1000                	addi	s0,sp,32
    800045ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ec:	00850913          	addi	s2,a0,8
    800045f0:	854a                	mv	a0,s2
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	5aa080e7          	jalr	1450(ra) # 80000b9c <acquire>
  while (lk->locked) {
    800045fa:	409c                	lw	a5,0(s1)
    800045fc:	cb89                	beqz	a5,8000460e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045fe:	85ca                	mv	a1,s2
    80004600:	8526                	mv	a0,s1
    80004602:	ffffe097          	auipc	ra,0xffffe
    80004606:	d6a080e7          	jalr	-662(ra) # 8000236c <sleep>
  while (lk->locked) {
    8000460a:	409c                	lw	a5,0(s1)
    8000460c:	fbed                	bnez	a5,800045fe <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000460e:	4785                	li	a5,1
    80004610:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004612:	ffffd097          	auipc	ra,0xffffd
    80004616:	58c080e7          	jalr	1420(ra) # 80001b9e <myproc>
    8000461a:	413c                	lw	a5,64(a0)
    8000461c:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000461e:	854a                	mv	a0,s2
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	64c080e7          	jalr	1612(ra) # 80000c6c <release>
}
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6902                	ld	s2,0(sp)
    80004630:	6105                	addi	sp,sp,32
    80004632:	8082                	ret

0000000080004634 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004634:	1101                	addi	sp,sp,-32
    80004636:	ec06                	sd	ra,24(sp)
    80004638:	e822                	sd	s0,16(sp)
    8000463a:	e426                	sd	s1,8(sp)
    8000463c:	e04a                	sd	s2,0(sp)
    8000463e:	1000                	addi	s0,sp,32
    80004640:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004642:	00850913          	addi	s2,a0,8
    80004646:	854a                	mv	a0,s2
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	554080e7          	jalr	1364(ra) # 80000b9c <acquire>
  lk->locked = 0;
    80004650:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004654:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004658:	8526                	mv	a0,s1
    8000465a:	ffffe097          	auipc	ra,0xffffe
    8000465e:	e98080e7          	jalr	-360(ra) # 800024f2 <wakeup>
  release(&lk->lk);
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	608080e7          	jalr	1544(ra) # 80000c6c <release>
}
    8000466c:	60e2                	ld	ra,24(sp)
    8000466e:	6442                	ld	s0,16(sp)
    80004670:	64a2                	ld	s1,8(sp)
    80004672:	6902                	ld	s2,0(sp)
    80004674:	6105                	addi	sp,sp,32
    80004676:	8082                	ret

0000000080004678 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004678:	7179                	addi	sp,sp,-48
    8000467a:	f406                	sd	ra,40(sp)
    8000467c:	f022                	sd	s0,32(sp)
    8000467e:	ec26                	sd	s1,24(sp)
    80004680:	e84a                	sd	s2,16(sp)
    80004682:	e44e                	sd	s3,8(sp)
    80004684:	1800                	addi	s0,sp,48
    80004686:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004688:	00850913          	addi	s2,a0,8
    8000468c:	854a                	mv	a0,s2
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	50e080e7          	jalr	1294(ra) # 80000b9c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004696:	409c                	lw	a5,0(s1)
    80004698:	ef99                	bnez	a5,800046b6 <holdingsleep+0x3e>
    8000469a:	4481                	li	s1,0
  release(&lk->lk);
    8000469c:	854a                	mv	a0,s2
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	5ce080e7          	jalr	1486(ra) # 80000c6c <release>
  return r;
}
    800046a6:	8526                	mv	a0,s1
    800046a8:	70a2                	ld	ra,40(sp)
    800046aa:	7402                	ld	s0,32(sp)
    800046ac:	64e2                	ld	s1,24(sp)
    800046ae:	6942                	ld	s2,16(sp)
    800046b0:	69a2                	ld	s3,8(sp)
    800046b2:	6145                	addi	sp,sp,48
    800046b4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b6:	0304a983          	lw	s3,48(s1)
    800046ba:	ffffd097          	auipc	ra,0xffffd
    800046be:	4e4080e7          	jalr	1252(ra) # 80001b9e <myproc>
    800046c2:	4124                	lw	s1,64(a0)
    800046c4:	413484b3          	sub	s1,s1,s3
    800046c8:	0014b493          	seqz	s1,s1
    800046cc:	bfc1                	j	8000469c <holdingsleep+0x24>

00000000800046ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046ce:	1141                	addi	sp,sp,-16
    800046d0:	e406                	sd	ra,8(sp)
    800046d2:	e022                	sd	s0,0(sp)
    800046d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046d6:	00005597          	auipc	a1,0x5
    800046da:	55258593          	addi	a1,a1,1362 # 80009c28 <syscalls+0x248>
    800046de:	00032517          	auipc	a0,0x32
    800046e2:	bea50513          	addi	a0,a0,-1046 # 800362c8 <ftable>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	3e0080e7          	jalr	992(ra) # 80000ac6 <initlock>
}
    800046ee:	60a2                	ld	ra,8(sp)
    800046f0:	6402                	ld	s0,0(sp)
    800046f2:	0141                	addi	sp,sp,16
    800046f4:	8082                	ret

00000000800046f6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046f6:	1101                	addi	sp,sp,-32
    800046f8:	ec06                	sd	ra,24(sp)
    800046fa:	e822                	sd	s0,16(sp)
    800046fc:	e426                	sd	s1,8(sp)
    800046fe:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004700:	00032517          	auipc	a0,0x32
    80004704:	bc850513          	addi	a0,a0,-1080 # 800362c8 <ftable>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	494080e7          	jalr	1172(ra) # 80000b9c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004710:	00032497          	auipc	s1,0x32
    80004714:	bd848493          	addi	s1,s1,-1064 # 800362e8 <ftable+0x20>
    80004718:	00033717          	auipc	a4,0x33
    8000471c:	b7070713          	addi	a4,a4,-1168 # 80037288 <disk>
    if(f->ref == 0){
    80004720:	40dc                	lw	a5,4(s1)
    80004722:	cf99                	beqz	a5,80004740 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004724:	02848493          	addi	s1,s1,40
    80004728:	fee49ce3          	bne	s1,a4,80004720 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000472c:	00032517          	auipc	a0,0x32
    80004730:	b9c50513          	addi	a0,a0,-1124 # 800362c8 <ftable>
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	538080e7          	jalr	1336(ra) # 80000c6c <release>
  return 0;
    8000473c:	4481                	li	s1,0
    8000473e:	a819                	j	80004754 <filealloc+0x5e>
      f->ref = 1;
    80004740:	4785                	li	a5,1
    80004742:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004744:	00032517          	auipc	a0,0x32
    80004748:	b8450513          	addi	a0,a0,-1148 # 800362c8 <ftable>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	520080e7          	jalr	1312(ra) # 80000c6c <release>
}
    80004754:	8526                	mv	a0,s1
    80004756:	60e2                	ld	ra,24(sp)
    80004758:	6442                	ld	s0,16(sp)
    8000475a:	64a2                	ld	s1,8(sp)
    8000475c:	6105                	addi	sp,sp,32
    8000475e:	8082                	ret

0000000080004760 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004760:	1101                	addi	sp,sp,-32
    80004762:	ec06                	sd	ra,24(sp)
    80004764:	e822                	sd	s0,16(sp)
    80004766:	e426                	sd	s1,8(sp)
    80004768:	1000                	addi	s0,sp,32
    8000476a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000476c:	00032517          	auipc	a0,0x32
    80004770:	b5c50513          	addi	a0,a0,-1188 # 800362c8 <ftable>
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	428080e7          	jalr	1064(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    8000477c:	40dc                	lw	a5,4(s1)
    8000477e:	02f05263          	blez	a5,800047a2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004782:	2785                	addiw	a5,a5,1
    80004784:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004786:	00032517          	auipc	a0,0x32
    8000478a:	b4250513          	addi	a0,a0,-1214 # 800362c8 <ftable>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	4de080e7          	jalr	1246(ra) # 80000c6c <release>
  return f;
}
    80004796:	8526                	mv	a0,s1
    80004798:	60e2                	ld	ra,24(sp)
    8000479a:	6442                	ld	s0,16(sp)
    8000479c:	64a2                	ld	s1,8(sp)
    8000479e:	6105                	addi	sp,sp,32
    800047a0:	8082                	ret
    panic("filedup");
    800047a2:	00005517          	auipc	a0,0x5
    800047a6:	48e50513          	addi	a0,a0,1166 # 80009c30 <syscalls+0x250>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	dc0080e7          	jalr	-576(ra) # 8000056a <panic>

00000000800047b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047b2:	7139                	addi	sp,sp,-64
    800047b4:	fc06                	sd	ra,56(sp)
    800047b6:	f822                	sd	s0,48(sp)
    800047b8:	f426                	sd	s1,40(sp)
    800047ba:	f04a                	sd	s2,32(sp)
    800047bc:	ec4e                	sd	s3,24(sp)
    800047be:	e852                	sd	s4,16(sp)
    800047c0:	e456                	sd	s5,8(sp)
    800047c2:	0080                	addi	s0,sp,64
    800047c4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047c6:	00032517          	auipc	a0,0x32
    800047ca:	b0250513          	addi	a0,a0,-1278 # 800362c8 <ftable>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	3ce080e7          	jalr	974(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    800047d6:	40dc                	lw	a5,4(s1)
    800047d8:	06f05163          	blez	a5,8000483a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047dc:	37fd                	addiw	a5,a5,-1
    800047de:	0007871b          	sext.w	a4,a5
    800047e2:	c0dc                	sw	a5,4(s1)
    800047e4:	06e04363          	bgtz	a4,8000484a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047e8:	0004a903          	lw	s2,0(s1)
    800047ec:	0094ca83          	lbu	s5,9(s1)
    800047f0:	0104ba03          	ld	s4,16(s1)
    800047f4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047f8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047fc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004800:	00032517          	auipc	a0,0x32
    80004804:	ac850513          	addi	a0,a0,-1336 # 800362c8 <ftable>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	464080e7          	jalr	1124(ra) # 80000c6c <release>

  if(ff.type == FD_PIPE){
    80004810:	4785                	li	a5,1
    80004812:	04f90d63          	beq	s2,a5,8000486c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004816:	3979                	addiw	s2,s2,-2
    80004818:	4785                	li	a5,1
    8000481a:	0527e063          	bltu	a5,s2,8000485a <fileclose+0xa8>
    begin_op();
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	aca080e7          	jalr	-1334(ra) # 800042e8 <begin_op>
    iput(ff.ip);
    80004826:	854e                	mv	a0,s3
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	2b8080e7          	jalr	696(ra) # 80003ae0 <iput>
    end_op();
    80004830:	00000097          	auipc	ra,0x0
    80004834:	b38080e7          	jalr	-1224(ra) # 80004368 <end_op>
    80004838:	a00d                	j	8000485a <fileclose+0xa8>
    panic("fileclose");
    8000483a:	00005517          	auipc	a0,0x5
    8000483e:	3fe50513          	addi	a0,a0,1022 # 80009c38 <syscalls+0x258>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	d28080e7          	jalr	-728(ra) # 8000056a <panic>
    release(&ftable.lock);
    8000484a:	00032517          	auipc	a0,0x32
    8000484e:	a7e50513          	addi	a0,a0,-1410 # 800362c8 <ftable>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	41a080e7          	jalr	1050(ra) # 80000c6c <release>
  }
}
    8000485a:	70e2                	ld	ra,56(sp)
    8000485c:	7442                	ld	s0,48(sp)
    8000485e:	74a2                	ld	s1,40(sp)
    80004860:	7902                	ld	s2,32(sp)
    80004862:	69e2                	ld	s3,24(sp)
    80004864:	6a42                	ld	s4,16(sp)
    80004866:	6aa2                	ld	s5,8(sp)
    80004868:	6121                	addi	sp,sp,64
    8000486a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000486c:	85d6                	mv	a1,s5
    8000486e:	8552                	mv	a0,s4
    80004870:	00000097          	auipc	ra,0x0
    80004874:	354080e7          	jalr	852(ra) # 80004bc4 <pipeclose>
    80004878:	b7cd                	j	8000485a <fileclose+0xa8>

000000008000487a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000487a:	715d                	addi	sp,sp,-80
    8000487c:	e486                	sd	ra,72(sp)
    8000487e:	e0a2                	sd	s0,64(sp)
    80004880:	fc26                	sd	s1,56(sp)
    80004882:	f84a                	sd	s2,48(sp)
    80004884:	f44e                	sd	s3,40(sp)
    80004886:	0880                	addi	s0,sp,80
    80004888:	84aa                	mv	s1,a0
    8000488a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000488c:	ffffd097          	auipc	ra,0xffffd
    80004890:	312080e7          	jalr	786(ra) # 80001b9e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004894:	409c                	lw	a5,0(s1)
    80004896:	37f9                	addiw	a5,a5,-2
    80004898:	4705                	li	a4,1
    8000489a:	04f76763          	bltu	a4,a5,800048e8 <filestat+0x6e>
    8000489e:	892a                	mv	s2,a0
    ilock(f->ip);
    800048a0:	6c88                	ld	a0,24(s1)
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	084080e7          	jalr	132(ra) # 80003926 <ilock>
    stati(f->ip, &st);
    800048aa:	fb840593          	addi	a1,s0,-72
    800048ae:	6c88                	ld	a0,24(s1)
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	300080e7          	jalr	768(ra) # 80003bb0 <stati>
    iunlock(f->ip);
    800048b8:	6c88                	ld	a0,24(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	12e080e7          	jalr	302(ra) # 800039e8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048c2:	46e1                	li	a3,24
    800048c4:	fb840613          	addi	a2,s0,-72
    800048c8:	85ce                	mv	a1,s3
    800048ca:	05893503          	ld	a0,88(s2)
    800048ce:	ffffd097          	auipc	ra,0xffffd
    800048d2:	f54080e7          	jalr	-172(ra) # 80001822 <copyout>
    800048d6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048da:	60a6                	ld	ra,72(sp)
    800048dc:	6406                	ld	s0,64(sp)
    800048de:	74e2                	ld	s1,56(sp)
    800048e0:	7942                	ld	s2,48(sp)
    800048e2:	79a2                	ld	s3,40(sp)
    800048e4:	6161                	addi	sp,sp,80
    800048e6:	8082                	ret
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	bfc5                	j	800048da <filestat+0x60>

00000000800048ec <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048ec:	7179                	addi	sp,sp,-48
    800048ee:	f406                	sd	ra,40(sp)
    800048f0:	f022                	sd	s0,32(sp)
    800048f2:	ec26                	sd	s1,24(sp)
    800048f4:	e84a                	sd	s2,16(sp)
    800048f6:	e44e                	sd	s3,8(sp)
    800048f8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048fa:	00854783          	lbu	a5,8(a0)
    800048fe:	c7c5                	beqz	a5,800049a6 <fileread+0xba>
    80004900:	84aa                	mv	s1,a0
    80004902:	89ae                	mv	s3,a1
    80004904:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004906:	411c                	lw	a5,0(a0)
    80004908:	4705                	li	a4,1
    8000490a:	04e78963          	beq	a5,a4,8000495c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000490e:	470d                	li	a4,3
    80004910:	04e78d63          	beq	a5,a4,8000496a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004914:	4709                	li	a4,2
    80004916:	08e79063          	bne	a5,a4,80004996 <fileread+0xaa>
    ilock(f->ip);
    8000491a:	6d08                	ld	a0,24(a0)
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	00a080e7          	jalr	10(ra) # 80003926 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004924:	874a                	mv	a4,s2
    80004926:	5094                	lw	a3,32(s1)
    80004928:	864e                	mv	a2,s3
    8000492a:	4585                	li	a1,1
    8000492c:	6c88                	ld	a0,24(s1)
    8000492e:	fffff097          	auipc	ra,0xfffff
    80004932:	2ac080e7          	jalr	684(ra) # 80003bda <readi>
    80004936:	892a                	mv	s2,a0
    80004938:	00a05563          	blez	a0,80004942 <fileread+0x56>
      f->off += r;
    8000493c:	509c                	lw	a5,32(s1)
    8000493e:	9fa9                	addw	a5,a5,a0
    80004940:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004942:	6c88                	ld	a0,24(s1)
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	0a4080e7          	jalr	164(ra) # 800039e8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000494c:	854a                	mv	a0,s2
    8000494e:	70a2                	ld	ra,40(sp)
    80004950:	7402                	ld	s0,32(sp)
    80004952:	64e2                	ld	s1,24(sp)
    80004954:	6942                	ld	s2,16(sp)
    80004956:	69a2                	ld	s3,8(sp)
    80004958:	6145                	addi	sp,sp,48
    8000495a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000495c:	6908                	ld	a0,16(a0)
    8000495e:	00000097          	auipc	ra,0x0
    80004962:	3d0080e7          	jalr	976(ra) # 80004d2e <piperead>
    80004966:	892a                	mv	s2,a0
    80004968:	b7d5                	j	8000494c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000496a:	02451783          	lh	a5,36(a0)
    8000496e:	03079693          	slli	a3,a5,0x30
    80004972:	92c1                	srli	a3,a3,0x30
    80004974:	4725                	li	a4,9
    80004976:	02d76a63          	bltu	a4,a3,800049aa <fileread+0xbe>
    8000497a:	0792                	slli	a5,a5,0x4
    8000497c:	00032717          	auipc	a4,0x32
    80004980:	8ac70713          	addi	a4,a4,-1876 # 80036228 <devsw>
    80004984:	97ba                	add	a5,a5,a4
    80004986:	639c                	ld	a5,0(a5)
    80004988:	c39d                	beqz	a5,800049ae <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    8000498a:	86b2                	mv	a3,a2
    8000498c:	862e                	mv	a2,a1
    8000498e:	4585                	li	a1,1
    80004990:	9782                	jalr	a5
    80004992:	892a                	mv	s2,a0
    80004994:	bf65                	j	8000494c <fileread+0x60>
    panic("fileread");
    80004996:	00005517          	auipc	a0,0x5
    8000499a:	2b250513          	addi	a0,a0,690 # 80009c48 <syscalls+0x268>
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	bcc080e7          	jalr	-1076(ra) # 8000056a <panic>
    return -1;
    800049a6:	597d                	li	s2,-1
    800049a8:	b755                	j	8000494c <fileread+0x60>
      return -1;
    800049aa:	597d                	li	s2,-1
    800049ac:	b745                	j	8000494c <fileread+0x60>
    800049ae:	597d                	li	s2,-1
    800049b0:	bf71                	j	8000494c <fileread+0x60>

00000000800049b2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049b2:	715d                	addi	sp,sp,-80
    800049b4:	e486                	sd	ra,72(sp)
    800049b6:	e0a2                	sd	s0,64(sp)
    800049b8:	fc26                	sd	s1,56(sp)
    800049ba:	f84a                	sd	s2,48(sp)
    800049bc:	f44e                	sd	s3,40(sp)
    800049be:	f052                	sd	s4,32(sp)
    800049c0:	ec56                	sd	s5,24(sp)
    800049c2:	e85a                	sd	s6,16(sp)
    800049c4:	e45e                	sd	s7,8(sp)
    800049c6:	e062                	sd	s8,0(sp)
    800049c8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049ca:	00954783          	lbu	a5,9(a0)
    800049ce:	10078863          	beqz	a5,80004ade <filewrite+0x12c>
    800049d2:	892a                	mv	s2,a0
    800049d4:	8aae                	mv	s5,a1
    800049d6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049d8:	411c                	lw	a5,0(a0)
    800049da:	4705                	li	a4,1
    800049dc:	02e78263          	beq	a5,a4,80004a00 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049e0:	470d                	li	a4,3
    800049e2:	02e78663          	beq	a5,a4,80004a0e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800049e6:	4709                	li	a4,2
    800049e8:	0ee79363          	bne	a5,a4,80004ace <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049ec:	0ac05f63          	blez	a2,80004aaa <filewrite+0xf8>
    int i = 0;
    800049f0:	4981                	li	s3,0
    800049f2:	6b05                	lui	s6,0x1
    800049f4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049f8:	6b85                	lui	s7,0x1
    800049fa:	c00b8b9b          	addiw	s7,s7,-1024
    800049fe:	a871                	j	80004a9a <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    80004a00:	6908                	ld	a0,16(a0)
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	232080e7          	jalr	562(ra) # 80004c34 <pipewrite>
    80004a0a:	8a2a                	mv	s4,a0
    80004a0c:	a055                	j	80004ab0 <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a0e:	02451783          	lh	a5,36(a0)
    80004a12:	03079693          	slli	a3,a5,0x30
    80004a16:	92c1                	srli	a3,a3,0x30
    80004a18:	4725                	li	a4,9
    80004a1a:	0cd76463          	bltu	a4,a3,80004ae2 <filewrite+0x130>
    80004a1e:	0792                	slli	a5,a5,0x4
    80004a20:	00032717          	auipc	a4,0x32
    80004a24:	80870713          	addi	a4,a4,-2040 # 80036228 <devsw>
    80004a28:	97ba                	add	a5,a5,a4
    80004a2a:	679c                	ld	a5,8(a5)
    80004a2c:	cfcd                	beqz	a5,80004ae6 <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004a2e:	86b2                	mv	a3,a2
    80004a30:	862e                	mv	a2,a1
    80004a32:	4585                	li	a1,1
    80004a34:	9782                	jalr	a5
    80004a36:	8a2a                	mv	s4,a0
    80004a38:	a8a5                	j	80004ab0 <filewrite+0xfe>
    80004a3a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a3e:	00000097          	auipc	ra,0x0
    80004a42:	8aa080e7          	jalr	-1878(ra) # 800042e8 <begin_op>
      ilock(f->ip);
    80004a46:	01893503          	ld	a0,24(s2)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	edc080e7          	jalr	-292(ra) # 80003926 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a52:	8762                	mv	a4,s8
    80004a54:	02092683          	lw	a3,32(s2)
    80004a58:	01598633          	add	a2,s3,s5
    80004a5c:	4585                	li	a1,1
    80004a5e:	01893503          	ld	a0,24(s2)
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	270080e7          	jalr	624(ra) # 80003cd2 <writei>
    80004a6a:	84aa                	mv	s1,a0
    80004a6c:	00a05763          	blez	a0,80004a7a <filewrite+0xc8>
        f->off += r;
    80004a70:	02092783          	lw	a5,32(s2)
    80004a74:	9fa9                	addw	a5,a5,a0
    80004a76:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a7a:	01893503          	ld	a0,24(s2)
    80004a7e:	fffff097          	auipc	ra,0xfffff
    80004a82:	f6a080e7          	jalr	-150(ra) # 800039e8 <iunlock>
      end_op();
    80004a86:	00000097          	auipc	ra,0x0
    80004a8a:	8e2080e7          	jalr	-1822(ra) # 80004368 <end_op>

      if(r != n1){
    80004a8e:	009c1f63          	bne	s8,s1,80004aac <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    80004a92:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a96:	0149db63          	bge	s3,s4,80004aac <filewrite+0xfa>
      int n1 = n - i;
    80004a9a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a9e:	84be                	mv	s1,a5
    80004aa0:	2781                	sext.w	a5,a5
    80004aa2:	f8fb5ce3          	bge	s6,a5,80004a3a <filewrite+0x88>
    80004aa6:	84de                	mv	s1,s7
    80004aa8:	bf49                	j	80004a3a <filewrite+0x88>
    int i = 0;
    80004aaa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004aac:	013a1f63          	bne	s4,s3,80004aca <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab0:	8552                	mv	a0,s4
    80004ab2:	60a6                	ld	ra,72(sp)
    80004ab4:	6406                	ld	s0,64(sp)
    80004ab6:	74e2                	ld	s1,56(sp)
    80004ab8:	7942                	ld	s2,48(sp)
    80004aba:	79a2                	ld	s3,40(sp)
    80004abc:	7a02                	ld	s4,32(sp)
    80004abe:	6ae2                	ld	s5,24(sp)
    80004ac0:	6b42                	ld	s6,16(sp)
    80004ac2:	6ba2                	ld	s7,8(sp)
    80004ac4:	6c02                	ld	s8,0(sp)
    80004ac6:	6161                	addi	sp,sp,80
    80004ac8:	8082                	ret
    ret = (i == n ? n : -1);
    80004aca:	5a7d                	li	s4,-1
    80004acc:	b7d5                	j	80004ab0 <filewrite+0xfe>
    panic("filewrite");
    80004ace:	00005517          	auipc	a0,0x5
    80004ad2:	18a50513          	addi	a0,a0,394 # 80009c58 <syscalls+0x278>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	a94080e7          	jalr	-1388(ra) # 8000056a <panic>
    return -1;
    80004ade:	5a7d                	li	s4,-1
    80004ae0:	bfc1                	j	80004ab0 <filewrite+0xfe>
      return -1;
    80004ae2:	5a7d                	li	s4,-1
    80004ae4:	b7f1                	j	80004ab0 <filewrite+0xfe>
    80004ae6:	5a7d                	li	s4,-1
    80004ae8:	b7e1                	j	80004ab0 <filewrite+0xfe>

0000000080004aea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aea:	7179                	addi	sp,sp,-48
    80004aec:	f406                	sd	ra,40(sp)
    80004aee:	f022                	sd	s0,32(sp)
    80004af0:	ec26                	sd	s1,24(sp)
    80004af2:	e84a                	sd	s2,16(sp)
    80004af4:	e44e                	sd	s3,8(sp)
    80004af6:	e052                	sd	s4,0(sp)
    80004af8:	1800                	addi	s0,sp,48
    80004afa:	84aa                	mv	s1,a0
    80004afc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004afe:	0005b023          	sd	zero,0(a1)
    80004b02:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b06:	00000097          	auipc	ra,0x0
    80004b0a:	bf0080e7          	jalr	-1040(ra) # 800046f6 <filealloc>
    80004b0e:	e088                	sd	a0,0(s1)
    80004b10:	c551                	beqz	a0,80004b9c <pipealloc+0xb2>
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	be4080e7          	jalr	-1052(ra) # 800046f6 <filealloc>
    80004b1a:	00aa3023          	sd	a0,0(s4)
    80004b1e:	c92d                	beqz	a0,80004b90 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	f2c080e7          	jalr	-212(ra) # 80000a4c <kalloc>
    80004b28:	892a                	mv	s2,a0
    80004b2a:	c125                	beqz	a0,80004b8a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b2c:	4985                	li	s3,1
    80004b2e:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004b32:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004b36:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004b3a:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004b3e:	00005597          	auipc	a1,0x5
    80004b42:	12a58593          	addi	a1,a1,298 # 80009c68 <syscalls+0x288>
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	f80080e7          	jalr	-128(ra) # 80000ac6 <initlock>
  (*f0)->type = FD_PIPE;
    80004b4e:	609c                	ld	a5,0(s1)
    80004b50:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b86:	4501                	li	a0,0
    80004b88:	a025                	j	80004bb0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b8a:	6088                	ld	a0,0(s1)
    80004b8c:	e501                	bnez	a0,80004b94 <pipealloc+0xaa>
    80004b8e:	a039                	j	80004b9c <pipealloc+0xb2>
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	c51d                	beqz	a0,80004bc0 <pipealloc+0xd6>
    fileclose(*f0);
    80004b94:	00000097          	auipc	ra,0x0
    80004b98:	c1e080e7          	jalr	-994(ra) # 800047b2 <fileclose>
  if(*f1)
    80004b9c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ba0:	557d                	li	a0,-1
  if(*f1)
    80004ba2:	c799                	beqz	a5,80004bb0 <pipealloc+0xc6>
    fileclose(*f1);
    80004ba4:	853e                	mv	a0,a5
    80004ba6:	00000097          	auipc	ra,0x0
    80004baa:	c0c080e7          	jalr	-1012(ra) # 800047b2 <fileclose>
  return -1;
    80004bae:	557d                	li	a0,-1
}
    80004bb0:	70a2                	ld	ra,40(sp)
    80004bb2:	7402                	ld	s0,32(sp)
    80004bb4:	64e2                	ld	s1,24(sp)
    80004bb6:	6942                	ld	s2,16(sp)
    80004bb8:	69a2                	ld	s3,8(sp)
    80004bba:	6a02                	ld	s4,0(sp)
    80004bbc:	6145                	addi	sp,sp,48
    80004bbe:	8082                	ret
  return -1;
    80004bc0:	557d                	li	a0,-1
    80004bc2:	b7fd                	j	80004bb0 <pipealloc+0xc6>

0000000080004bc4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bc4:	1101                	addi	sp,sp,-32
    80004bc6:	ec06                	sd	ra,24(sp)
    80004bc8:	e822                	sd	s0,16(sp)
    80004bca:	e426                	sd	s1,8(sp)
    80004bcc:	e04a                	sd	s2,0(sp)
    80004bce:	1000                	addi	s0,sp,32
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	fc8080e7          	jalr	-56(ra) # 80000b9c <acquire>
  if(writable){
    80004bdc:	02090d63          	beqz	s2,80004c16 <pipeclose+0x52>
    pi->writeopen = 0;
    80004be0:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004be4:	22048513          	addi	a0,s1,544
    80004be8:	ffffe097          	auipc	ra,0xffffe
    80004bec:	90a080e7          	jalr	-1782(ra) # 800024f2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf0:	2284b783          	ld	a5,552(s1)
    80004bf4:	eb95                	bnez	a5,80004c28 <pipeclose+0x64>
    release(&pi->lock);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	074080e7          	jalr	116(ra) # 80000c6c <release>
    kfree((char*)pi);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	d44080e7          	jalr	-700(ra) # 80000946 <kfree>
  } else
    release(&pi->lock);
}
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6902                	ld	s2,0(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret
    pi->readopen = 0;
    80004c16:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004c1a:	22448513          	addi	a0,s1,548
    80004c1e:	ffffe097          	auipc	ra,0xffffe
    80004c22:	8d4080e7          	jalr	-1836(ra) # 800024f2 <wakeup>
    80004c26:	b7e9                	j	80004bf0 <pipeclose+0x2c>
    release(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	042080e7          	jalr	66(ra) # 80000c6c <release>
}
    80004c32:	bfe1                	j	80004c0a <pipeclose+0x46>

0000000080004c34 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c34:	7159                	addi	sp,sp,-112
    80004c36:	f486                	sd	ra,104(sp)
    80004c38:	f0a2                	sd	s0,96(sp)
    80004c3a:	eca6                	sd	s1,88(sp)
    80004c3c:	e8ca                	sd	s2,80(sp)
    80004c3e:	e4ce                	sd	s3,72(sp)
    80004c40:	e0d2                	sd	s4,64(sp)
    80004c42:	fc56                	sd	s5,56(sp)
    80004c44:	f85a                	sd	s6,48(sp)
    80004c46:	f45e                	sd	s7,40(sp)
    80004c48:	f062                	sd	s8,32(sp)
    80004c4a:	ec66                	sd	s9,24(sp)
    80004c4c:	1880                	addi	s0,sp,112
    80004c4e:	84aa                	mv	s1,a0
    80004c50:	8aae                	mv	s5,a1
    80004c52:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c54:	ffffd097          	auipc	ra,0xffffd
    80004c58:	f4a080e7          	jalr	-182(ra) # 80001b9e <myproc>
    80004c5c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c5e:	8526                	mv	a0,s1
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	f3c080e7          	jalr	-196(ra) # 80000b9c <acquire>
  while(i < n){
    80004c68:	0d405163          	blez	s4,80004d2a <pipewrite+0xf6>
    80004c6c:	8ba6                	mv	s7,s1
  int i = 0;
    80004c6e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c70:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c72:	22048c93          	addi	s9,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004c76:	22448c13          	addi	s8,s1,548
    80004c7a:	a08d                	j	80004cdc <pipewrite+0xa8>
      release(&pi->lock);
    80004c7c:	8526                	mv	a0,s1
    80004c7e:	ffffc097          	auipc	ra,0xffffc
    80004c82:	fee080e7          	jalr	-18(ra) # 80000c6c <release>
      return -1;
    80004c86:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c88:	854a                	mv	a0,s2
    80004c8a:	70a6                	ld	ra,104(sp)
    80004c8c:	7406                	ld	s0,96(sp)
    80004c8e:	64e6                	ld	s1,88(sp)
    80004c90:	6946                	ld	s2,80(sp)
    80004c92:	69a6                	ld	s3,72(sp)
    80004c94:	6a06                	ld	s4,64(sp)
    80004c96:	7ae2                	ld	s5,56(sp)
    80004c98:	7b42                	ld	s6,48(sp)
    80004c9a:	7ba2                	ld	s7,40(sp)
    80004c9c:	7c02                	ld	s8,32(sp)
    80004c9e:	6ce2                	ld	s9,24(sp)
    80004ca0:	6165                	addi	sp,sp,112
    80004ca2:	8082                	ret
      wakeup(&pi->nread);
    80004ca4:	8566                	mv	a0,s9
    80004ca6:	ffffe097          	auipc	ra,0xffffe
    80004caa:	84c080e7          	jalr	-1972(ra) # 800024f2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cae:	85de                	mv	a1,s7
    80004cb0:	8562                	mv	a0,s8
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	6ba080e7          	jalr	1722(ra) # 8000236c <sleep>
    80004cba:	a839                	j	80004cd8 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cbc:	2244a783          	lw	a5,548(s1)
    80004cc0:	0017871b          	addiw	a4,a5,1
    80004cc4:	22e4a223          	sw	a4,548(s1)
    80004cc8:	1ff7f793          	andi	a5,a5,511
    80004ccc:	97a6                	add	a5,a5,s1
    80004cce:	f9f44703          	lbu	a4,-97(s0)
    80004cd2:	02e78023          	sb	a4,32(a5)
      i++;
    80004cd6:	2905                	addiw	s2,s2,1
  while(i < n){
    80004cd8:	03495d63          	bge	s2,s4,80004d12 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004cdc:	2284a783          	lw	a5,552(s1)
    80004ce0:	dfd1                	beqz	a5,80004c7c <pipewrite+0x48>
    80004ce2:	0389a783          	lw	a5,56(s3)
    80004ce6:	fbd9                	bnez	a5,80004c7c <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ce8:	2204a783          	lw	a5,544(s1)
    80004cec:	2244a703          	lw	a4,548(s1)
    80004cf0:	2007879b          	addiw	a5,a5,512
    80004cf4:	faf708e3          	beq	a4,a5,80004ca4 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cf8:	4685                	li	a3,1
    80004cfa:	01590633          	add	a2,s2,s5
    80004cfe:	f9f40593          	addi	a1,s0,-97
    80004d02:	0589b503          	ld	a0,88(s3)
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	ba8080e7          	jalr	-1112(ra) # 800018ae <copyin>
    80004d0e:	fb6517e3          	bne	a0,s6,80004cbc <pipewrite+0x88>
  wakeup(&pi->nread);
    80004d12:	22048513          	addi	a0,s1,544
    80004d16:	ffffd097          	auipc	ra,0xffffd
    80004d1a:	7dc080e7          	jalr	2012(ra) # 800024f2 <wakeup>
  release(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	f4c080e7          	jalr	-180(ra) # 80000c6c <release>
  return i;
    80004d28:	b785                	j	80004c88 <pipewrite+0x54>
  int i = 0;
    80004d2a:	4901                	li	s2,0
    80004d2c:	b7dd                	j	80004d12 <pipewrite+0xde>

0000000080004d2e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d2e:	715d                	addi	sp,sp,-80
    80004d30:	e486                	sd	ra,72(sp)
    80004d32:	e0a2                	sd	s0,64(sp)
    80004d34:	fc26                	sd	s1,56(sp)
    80004d36:	f84a                	sd	s2,48(sp)
    80004d38:	f44e                	sd	s3,40(sp)
    80004d3a:	f052                	sd	s4,32(sp)
    80004d3c:	ec56                	sd	s5,24(sp)
    80004d3e:	e85a                	sd	s6,16(sp)
    80004d40:	0880                	addi	s0,sp,80
    80004d42:	84aa                	mv	s1,a0
    80004d44:	892e                	mv	s2,a1
    80004d46:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d48:	ffffd097          	auipc	ra,0xffffd
    80004d4c:	e56080e7          	jalr	-426(ra) # 80001b9e <myproc>
    80004d50:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d52:	8b26                	mv	s6,s1
    80004d54:	8526                	mv	a0,s1
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	e46080e7          	jalr	-442(ra) # 80000b9c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5e:	2204a703          	lw	a4,544(s1)
    80004d62:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d66:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d6a:	02f71463          	bne	a4,a5,80004d92 <piperead+0x64>
    80004d6e:	22c4a783          	lw	a5,556(s1)
    80004d72:	c385                	beqz	a5,80004d92 <piperead+0x64>
    if(pr->killed){
    80004d74:	038a2783          	lw	a5,56(s4)
    80004d78:	ebc1                	bnez	a5,80004e08 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d7a:	85da                	mv	a1,s6
    80004d7c:	854e                	mv	a0,s3
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	5ee080e7          	jalr	1518(ra) # 8000236c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d86:	2204a703          	lw	a4,544(s1)
    80004d8a:	2244a783          	lw	a5,548(s1)
    80004d8e:	fef700e3          	beq	a4,a5,80004d6e <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d92:	09505263          	blez	s5,80004e16 <piperead+0xe8>
    80004d96:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d98:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d9a:	2204a783          	lw	a5,544(s1)
    80004d9e:	2244a703          	lw	a4,548(s1)
    80004da2:	02f70d63          	beq	a4,a5,80004ddc <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004da6:	0017871b          	addiw	a4,a5,1
    80004daa:	22e4a023          	sw	a4,544(s1)
    80004dae:	1ff7f793          	andi	a5,a5,511
    80004db2:	97a6                	add	a5,a5,s1
    80004db4:	0207c783          	lbu	a5,32(a5)
    80004db8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dbc:	4685                	li	a3,1
    80004dbe:	fbf40613          	addi	a2,s0,-65
    80004dc2:	85ca                	mv	a1,s2
    80004dc4:	058a3503          	ld	a0,88(s4)
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	a5a080e7          	jalr	-1446(ra) # 80001822 <copyout>
    80004dd0:	01650663          	beq	a0,s6,80004ddc <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd4:	2985                	addiw	s3,s3,1
    80004dd6:	0905                	addi	s2,s2,1
    80004dd8:	fd3a91e3          	bne	s5,s3,80004d9a <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ddc:	22448513          	addi	a0,s1,548
    80004de0:	ffffd097          	auipc	ra,0xffffd
    80004de4:	712080e7          	jalr	1810(ra) # 800024f2 <wakeup>
  release(&pi->lock);
    80004de8:	8526                	mv	a0,s1
    80004dea:	ffffc097          	auipc	ra,0xffffc
    80004dee:	e82080e7          	jalr	-382(ra) # 80000c6c <release>
  return i;
}
    80004df2:	854e                	mv	a0,s3
    80004df4:	60a6                	ld	ra,72(sp)
    80004df6:	6406                	ld	s0,64(sp)
    80004df8:	74e2                	ld	s1,56(sp)
    80004dfa:	7942                	ld	s2,48(sp)
    80004dfc:	79a2                	ld	s3,40(sp)
    80004dfe:	7a02                	ld	s4,32(sp)
    80004e00:	6ae2                	ld	s5,24(sp)
    80004e02:	6b42                	ld	s6,16(sp)
    80004e04:	6161                	addi	sp,sp,80
    80004e06:	8082                	ret
      release(&pi->lock);
    80004e08:	8526                	mv	a0,s1
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	e62080e7          	jalr	-414(ra) # 80000c6c <release>
      return -1;
    80004e12:	59fd                	li	s3,-1
    80004e14:	bff9                	j	80004df2 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e16:	4981                	li	s3,0
    80004e18:	b7d1                	j	80004ddc <piperead+0xae>

0000000080004e1a <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e1a:	df010113          	addi	sp,sp,-528
    80004e1e:	20113423          	sd	ra,520(sp)
    80004e22:	20813023          	sd	s0,512(sp)
    80004e26:	ffa6                	sd	s1,504(sp)
    80004e28:	fbca                	sd	s2,496(sp)
    80004e2a:	f7ce                	sd	s3,488(sp)
    80004e2c:	f3d2                	sd	s4,480(sp)
    80004e2e:	efd6                	sd	s5,472(sp)
    80004e30:	ebda                	sd	s6,464(sp)
    80004e32:	e7de                	sd	s7,456(sp)
    80004e34:	e3e2                	sd	s8,448(sp)
    80004e36:	ff66                	sd	s9,440(sp)
    80004e38:	fb6a                	sd	s10,432(sp)
    80004e3a:	f76e                	sd	s11,424(sp)
    80004e3c:	0c00                	addi	s0,sp,528
    80004e3e:	84aa                	mv	s1,a0
    80004e40:	dea43c23          	sd	a0,-520(s0)
    80004e44:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e48:	ffffd097          	auipc	ra,0xffffd
    80004e4c:	d56080e7          	jalr	-682(ra) # 80001b9e <myproc>
    80004e50:	892a                	mv	s2,a0

  begin_op();
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	496080e7          	jalr	1174(ra) # 800042e8 <begin_op>

  if((ip = namei(path)) == 0){
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	280080e7          	jalr	640(ra) # 800040dc <namei>
    80004e64:	c92d                	beqz	a0,80004ed6 <exec+0xbc>
    80004e66:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e68:	fffff097          	auipc	ra,0xfffff
    80004e6c:	abe080e7          	jalr	-1346(ra) # 80003926 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e70:	04000713          	li	a4,64
    80004e74:	4681                	li	a3,0
    80004e76:	e5040613          	addi	a2,s0,-432
    80004e7a:	4581                	li	a1,0
    80004e7c:	8526                	mv	a0,s1
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	d5c080e7          	jalr	-676(ra) # 80003bda <readi>
    80004e86:	04000793          	li	a5,64
    80004e8a:	00f51a63          	bne	a0,a5,80004e9e <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e8e:	e5042703          	lw	a4,-432(s0)
    80004e92:	464c47b7          	lui	a5,0x464c4
    80004e96:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e9a:	04f70463          	beq	a4,a5,80004ee2 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	fffff097          	auipc	ra,0xfffff
    80004ea4:	ce8080e7          	jalr	-792(ra) # 80003b88 <iunlockput>
    end_op();
    80004ea8:	fffff097          	auipc	ra,0xfffff
    80004eac:	4c0080e7          	jalr	1216(ra) # 80004368 <end_op>
  }
  return -1;
    80004eb0:	557d                	li	a0,-1
}
    80004eb2:	20813083          	ld	ra,520(sp)
    80004eb6:	20013403          	ld	s0,512(sp)
    80004eba:	74fe                	ld	s1,504(sp)
    80004ebc:	795e                	ld	s2,496(sp)
    80004ebe:	79be                	ld	s3,488(sp)
    80004ec0:	7a1e                	ld	s4,480(sp)
    80004ec2:	6afe                	ld	s5,472(sp)
    80004ec4:	6b5e                	ld	s6,464(sp)
    80004ec6:	6bbe                	ld	s7,456(sp)
    80004ec8:	6c1e                	ld	s8,448(sp)
    80004eca:	7cfa                	ld	s9,440(sp)
    80004ecc:	7d5a                	ld	s10,432(sp)
    80004ece:	7dba                	ld	s11,424(sp)
    80004ed0:	21010113          	addi	sp,sp,528
    80004ed4:	8082                	ret
    end_op();
    80004ed6:	fffff097          	auipc	ra,0xfffff
    80004eda:	492080e7          	jalr	1170(ra) # 80004368 <end_op>
    return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bfc9                	j	80004eb2 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ee2:	854a                	mv	a0,s2
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	d7e080e7          	jalr	-642(ra) # 80001c62 <proc_pagetable>
    80004eec:	8baa                	mv	s7,a0
    80004eee:	d945                	beqz	a0,80004e9e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef0:	e7042983          	lw	s3,-400(s0)
    80004ef4:	e8845783          	lhu	a5,-376(s0)
    80004ef8:	c7ad                	beqz	a5,80004f62 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004efa:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004efc:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004efe:	6c85                	lui	s9,0x1
    80004f00:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f04:	def43823          	sd	a5,-528(s0)
    80004f08:	a42d                	j	80005132 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f0a:	00005517          	auipc	a0,0x5
    80004f0e:	d6650513          	addi	a0,a0,-666 # 80009c70 <syscalls+0x290>
    80004f12:	ffffb097          	auipc	ra,0xffffb
    80004f16:	658080e7          	jalr	1624(ra) # 8000056a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f1a:	8756                	mv	a4,s5
    80004f1c:	012d86bb          	addw	a3,s11,s2
    80004f20:	4581                	li	a1,0
    80004f22:	8526                	mv	a0,s1
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	cb6080e7          	jalr	-842(ra) # 80003bda <readi>
    80004f2c:	2501                	sext.w	a0,a0
    80004f2e:	1aaa9963          	bne	s5,a0,800050e0 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004f32:	6785                	lui	a5,0x1
    80004f34:	0127893b          	addw	s2,a5,s2
    80004f38:	77fd                	lui	a5,0xfffff
    80004f3a:	01478a3b          	addw	s4,a5,s4
    80004f3e:	1f897163          	bgeu	s2,s8,80005120 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004f42:	02091593          	slli	a1,s2,0x20
    80004f46:	9181                	srli	a1,a1,0x20
    80004f48:	95ea                	add	a1,a1,s10
    80004f4a:	855e                	mv	a0,s7
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	368080e7          	jalr	872(ra) # 800012b4 <walkaddr>
    80004f54:	862a                	mv	a2,a0
    if(pa == 0)
    80004f56:	d955                	beqz	a0,80004f0a <exec+0xf0>
      n = PGSIZE;
    80004f58:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004f5a:	fd9a70e3          	bgeu	s4,s9,80004f1a <exec+0x100>
      n = sz - i;
    80004f5e:	8ad2                	mv	s5,s4
    80004f60:	bf6d                	j	80004f1a <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f62:	4901                	li	s2,0
  iunlockput(ip);
    80004f64:	8526                	mv	a0,s1
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	c22080e7          	jalr	-990(ra) # 80003b88 <iunlockput>
  end_op();
    80004f6e:	fffff097          	auipc	ra,0xfffff
    80004f72:	3fa080e7          	jalr	1018(ra) # 80004368 <end_op>
  p = myproc();
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	c28080e7          	jalr	-984(ra) # 80001b9e <myproc>
    80004f7e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f80:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004f84:	6785                	lui	a5,0x1
    80004f86:	17fd                	addi	a5,a5,-1
    80004f88:	993e                	add	s2,s2,a5
    80004f8a:	757d                	lui	a0,0xfffff
    80004f8c:	00a977b3          	and	a5,s2,a0
    80004f90:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f94:	6609                	lui	a2,0x2
    80004f96:	963e                	add	a2,a2,a5
    80004f98:	85be                	mv	a1,a5
    80004f9a:	855e                	mv	a0,s7
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	6ac080e7          	jalr	1708(ra) # 80001648 <uvmalloc>
    80004fa4:	8b2a                	mv	s6,a0
  ip = 0;
    80004fa6:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fa8:	12050c63          	beqz	a0,800050e0 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fac:	75f9                	lui	a1,0xffffe
    80004fae:	95aa                	add	a1,a1,a0
    80004fb0:	855e                	mv	a0,s7
    80004fb2:	ffffd097          	auipc	ra,0xffffd
    80004fb6:	83e080e7          	jalr	-1986(ra) # 800017f0 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fba:	7c7d                	lui	s8,0xfffff
    80004fbc:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fbe:	e0043783          	ld	a5,-512(s0)
    80004fc2:	6388                	ld	a0,0(a5)
    80004fc4:	c535                	beqz	a0,80005030 <exec+0x216>
    80004fc6:	e9040993          	addi	s3,s0,-368
    80004fca:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fce:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	060080e7          	jalr	96(ra) # 80001030 <strlen>
    80004fd8:	2505                	addiw	a0,a0,1
    80004fda:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fde:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fe2:	13896363          	bltu	s2,s8,80005108 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fe6:	e0043d83          	ld	s11,-512(s0)
    80004fea:	000dba03          	ld	s4,0(s11)
    80004fee:	8552                	mv	a0,s4
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	040080e7          	jalr	64(ra) # 80001030 <strlen>
    80004ff8:	0015069b          	addiw	a3,a0,1
    80004ffc:	8652                	mv	a2,s4
    80004ffe:	85ca                	mv	a1,s2
    80005000:	855e                	mv	a0,s7
    80005002:	ffffd097          	auipc	ra,0xffffd
    80005006:	820080e7          	jalr	-2016(ra) # 80001822 <copyout>
    8000500a:	10054363          	bltz	a0,80005110 <exec+0x2f6>
    ustack[argc] = sp;
    8000500e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005012:	0485                	addi	s1,s1,1
    80005014:	008d8793          	addi	a5,s11,8
    80005018:	e0f43023          	sd	a5,-512(s0)
    8000501c:	008db503          	ld	a0,8(s11)
    80005020:	c911                	beqz	a0,80005034 <exec+0x21a>
    if(argc >= MAXARG)
    80005022:	09a1                	addi	s3,s3,8
    80005024:	fb3c96e3          	bne	s9,s3,80004fd0 <exec+0x1b6>
  sz = sz1;
    80005028:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000502c:	4481                	li	s1,0
    8000502e:	a84d                	j	800050e0 <exec+0x2c6>
  sp = sz;
    80005030:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005032:	4481                	li	s1,0
  ustack[argc] = 0;
    80005034:	00349793          	slli	a5,s1,0x3
    80005038:	f9040713          	addi	a4,s0,-112
    8000503c:	97ba                	add	a5,a5,a4
    8000503e:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005042:	00148693          	addi	a3,s1,1
    80005046:	068e                	slli	a3,a3,0x3
    80005048:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000504c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005050:	01897663          	bgeu	s2,s8,8000505c <exec+0x242>
  sz = sz1;
    80005054:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005058:	4481                	li	s1,0
    8000505a:	a059                	j	800050e0 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000505c:	e9040613          	addi	a2,s0,-368
    80005060:	85ca                	mv	a1,s2
    80005062:	855e                	mv	a0,s7
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	7be080e7          	jalr	1982(ra) # 80001822 <copyout>
    8000506c:	0a054663          	bltz	a0,80005118 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005070:	060ab783          	ld	a5,96(s5)
    80005074:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005078:	df843783          	ld	a5,-520(s0)
    8000507c:	0007c703          	lbu	a4,0(a5)
    80005080:	cf11                	beqz	a4,8000509c <exec+0x282>
    80005082:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005084:	02f00693          	li	a3,47
    80005088:	a039                	j	80005096 <exec+0x27c>
      last = s+1;
    8000508a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000508e:	0785                	addi	a5,a5,1
    80005090:	fff7c703          	lbu	a4,-1(a5)
    80005094:	c701                	beqz	a4,8000509c <exec+0x282>
    if(*s == '/')
    80005096:	fed71ce3          	bne	a4,a3,8000508e <exec+0x274>
    8000509a:	bfc5                	j	8000508a <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    8000509c:	4641                	li	a2,16
    8000509e:	df843583          	ld	a1,-520(s0)
    800050a2:	160a8513          	addi	a0,s5,352
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	f58080e7          	jalr	-168(ra) # 80000ffe <safestrcpy>
  oldpagetable = p->pagetable;
    800050ae:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800050b2:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800050b6:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ba:	060ab783          	ld	a5,96(s5)
    800050be:	e6843703          	ld	a4,-408(s0)
    800050c2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050c4:	060ab783          	ld	a5,96(s5)
    800050c8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050cc:	85ea                	mv	a1,s10
    800050ce:	ffffd097          	auipc	ra,0xffffd
    800050d2:	ca0080e7          	jalr	-864(ra) # 80001d6e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050d6:	0004851b          	sext.w	a0,s1
    800050da:	bbe1                	j	80004eb2 <exec+0x98>
    800050dc:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800050e0:	e0843583          	ld	a1,-504(s0)
    800050e4:	855e                	mv	a0,s7
    800050e6:	ffffd097          	auipc	ra,0xffffd
    800050ea:	c88080e7          	jalr	-888(ra) # 80001d6e <proc_freepagetable>
  if(ip){
    800050ee:	da0498e3          	bnez	s1,80004e9e <exec+0x84>
  return -1;
    800050f2:	557d                	li	a0,-1
    800050f4:	bb7d                	j	80004eb2 <exec+0x98>
    800050f6:	e1243423          	sd	s2,-504(s0)
    800050fa:	b7dd                	j	800050e0 <exec+0x2c6>
    800050fc:	e1243423          	sd	s2,-504(s0)
    80005100:	b7c5                	j	800050e0 <exec+0x2c6>
    80005102:	e1243423          	sd	s2,-504(s0)
    80005106:	bfe9                	j	800050e0 <exec+0x2c6>
  sz = sz1;
    80005108:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000510c:	4481                	li	s1,0
    8000510e:	bfc9                	j	800050e0 <exec+0x2c6>
  sz = sz1;
    80005110:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005114:	4481                	li	s1,0
    80005116:	b7e9                	j	800050e0 <exec+0x2c6>
  sz = sz1;
    80005118:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000511c:	4481                	li	s1,0
    8000511e:	b7c9                	j	800050e0 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005120:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005124:	2b05                	addiw	s6,s6,1
    80005126:	0389899b          	addiw	s3,s3,56
    8000512a:	e8845783          	lhu	a5,-376(s0)
    8000512e:	e2fb5be3          	bge	s6,a5,80004f64 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005132:	2981                	sext.w	s3,s3
    80005134:	03800713          	li	a4,56
    80005138:	86ce                	mv	a3,s3
    8000513a:	e1840613          	addi	a2,s0,-488
    8000513e:	4581                	li	a1,0
    80005140:	8526                	mv	a0,s1
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	a98080e7          	jalr	-1384(ra) # 80003bda <readi>
    8000514a:	03800793          	li	a5,56
    8000514e:	f8f517e3          	bne	a0,a5,800050dc <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005152:	e1842783          	lw	a5,-488(s0)
    80005156:	4705                	li	a4,1
    80005158:	fce796e3          	bne	a5,a4,80005124 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    8000515c:	e4043603          	ld	a2,-448(s0)
    80005160:	e3843783          	ld	a5,-456(s0)
    80005164:	f8f669e3          	bltu	a2,a5,800050f6 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005168:	e2843783          	ld	a5,-472(s0)
    8000516c:	963e                	add	a2,a2,a5
    8000516e:	f8f667e3          	bltu	a2,a5,800050fc <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005172:	85ca                	mv	a1,s2
    80005174:	855e                	mv	a0,s7
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	4d2080e7          	jalr	1234(ra) # 80001648 <uvmalloc>
    8000517e:	e0a43423          	sd	a0,-504(s0)
    80005182:	d141                	beqz	a0,80005102 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80005184:	e2843d03          	ld	s10,-472(s0)
    80005188:	df043783          	ld	a5,-528(s0)
    8000518c:	00fd77b3          	and	a5,s10,a5
    80005190:	fba1                	bnez	a5,800050e0 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005192:	e2042d83          	lw	s11,-480(s0)
    80005196:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000519a:	f80c03e3          	beqz	s8,80005120 <exec+0x306>
    8000519e:	8a62                	mv	s4,s8
    800051a0:	4901                	li	s2,0
    800051a2:	b345                	j	80004f42 <exec+0x128>

00000000800051a4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051a4:	7179                	addi	sp,sp,-48
    800051a6:	f406                	sd	ra,40(sp)
    800051a8:	f022                	sd	s0,32(sp)
    800051aa:	ec26                	sd	s1,24(sp)
    800051ac:	e84a                	sd	s2,16(sp)
    800051ae:	1800                	addi	s0,sp,48
    800051b0:	892e                	mv	s2,a1
    800051b2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051b4:	fdc40593          	addi	a1,s0,-36
    800051b8:	ffffe097          	auipc	ra,0xffffe
    800051bc:	bfc080e7          	jalr	-1028(ra) # 80002db4 <argint>
    800051c0:	04054063          	bltz	a0,80005200 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051c4:	fdc42703          	lw	a4,-36(s0)
    800051c8:	47bd                	li	a5,15
    800051ca:	02e7ed63          	bltu	a5,a4,80005204 <argfd+0x60>
    800051ce:	ffffd097          	auipc	ra,0xffffd
    800051d2:	9d0080e7          	jalr	-1584(ra) # 80001b9e <myproc>
    800051d6:	fdc42703          	lw	a4,-36(s0)
    800051da:	01a70793          	addi	a5,a4,26
    800051de:	078e                	slli	a5,a5,0x3
    800051e0:	953e                	add	a0,a0,a5
    800051e2:	651c                	ld	a5,8(a0)
    800051e4:	c395                	beqz	a5,80005208 <argfd+0x64>
    return -1;
  if(pfd)
    800051e6:	00090463          	beqz	s2,800051ee <argfd+0x4a>
    *pfd = fd;
    800051ea:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051ee:	4501                	li	a0,0
  if(pf)
    800051f0:	c091                	beqz	s1,800051f4 <argfd+0x50>
    *pf = f;
    800051f2:	e09c                	sd	a5,0(s1)
}
    800051f4:	70a2                	ld	ra,40(sp)
    800051f6:	7402                	ld	s0,32(sp)
    800051f8:	64e2                	ld	s1,24(sp)
    800051fa:	6942                	ld	s2,16(sp)
    800051fc:	6145                	addi	sp,sp,48
    800051fe:	8082                	ret
    return -1;
    80005200:	557d                	li	a0,-1
    80005202:	bfcd                	j	800051f4 <argfd+0x50>
    return -1;
    80005204:	557d                	li	a0,-1
    80005206:	b7fd                	j	800051f4 <argfd+0x50>
    80005208:	557d                	li	a0,-1
    8000520a:	b7ed                	j	800051f4 <argfd+0x50>

000000008000520c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000520c:	1101                	addi	sp,sp,-32
    8000520e:	ec06                	sd	ra,24(sp)
    80005210:	e822                	sd	s0,16(sp)
    80005212:	e426                	sd	s1,8(sp)
    80005214:	1000                	addi	s0,sp,32
    80005216:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005218:	ffffd097          	auipc	ra,0xffffd
    8000521c:	986080e7          	jalr	-1658(ra) # 80001b9e <myproc>
    80005220:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005222:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffc7ca8>
    80005226:	4501                	li	a0,0
    80005228:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000522a:	6398                	ld	a4,0(a5)
    8000522c:	cb19                	beqz	a4,80005242 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000522e:	2505                	addiw	a0,a0,1
    80005230:	07a1                	addi	a5,a5,8
    80005232:	fed51ce3          	bne	a0,a3,8000522a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005236:	557d                	li	a0,-1
}
    80005238:	60e2                	ld	ra,24(sp)
    8000523a:	6442                	ld	s0,16(sp)
    8000523c:	64a2                	ld	s1,8(sp)
    8000523e:	6105                	addi	sp,sp,32
    80005240:	8082                	ret
      p->ofile[fd] = f;
    80005242:	01a50793          	addi	a5,a0,26
    80005246:	078e                	slli	a5,a5,0x3
    80005248:	963e                	add	a2,a2,a5
    8000524a:	e604                	sd	s1,8(a2)
      return fd;
    8000524c:	b7f5                	j	80005238 <fdalloc+0x2c>

000000008000524e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000524e:	715d                	addi	sp,sp,-80
    80005250:	e486                	sd	ra,72(sp)
    80005252:	e0a2                	sd	s0,64(sp)
    80005254:	fc26                	sd	s1,56(sp)
    80005256:	f84a                	sd	s2,48(sp)
    80005258:	f44e                	sd	s3,40(sp)
    8000525a:	f052                	sd	s4,32(sp)
    8000525c:	ec56                	sd	s5,24(sp)
    8000525e:	0880                	addi	s0,sp,80
    80005260:	89ae                	mv	s3,a1
    80005262:	8ab2                	mv	s5,a2
    80005264:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005266:	fb040593          	addi	a1,s0,-80
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	e90080e7          	jalr	-368(ra) # 800040fa <nameiparent>
    80005272:	892a                	mv	s2,a0
    80005274:	12050f63          	beqz	a0,800053b2 <create+0x164>
    return 0;

  ilock(dp);
    80005278:	ffffe097          	auipc	ra,0xffffe
    8000527c:	6ae080e7          	jalr	1710(ra) # 80003926 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005280:	4601                	li	a2,0
    80005282:	fb040593          	addi	a1,s0,-80
    80005286:	854a                	mv	a0,s2
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	b82080e7          	jalr	-1150(ra) # 80003e0a <dirlookup>
    80005290:	84aa                	mv	s1,a0
    80005292:	c921                	beqz	a0,800052e2 <create+0x94>
    iunlockput(dp);
    80005294:	854a                	mv	a0,s2
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	8f2080e7          	jalr	-1806(ra) # 80003b88 <iunlockput>
    ilock(ip);
    8000529e:	8526                	mv	a0,s1
    800052a0:	ffffe097          	auipc	ra,0xffffe
    800052a4:	686080e7          	jalr	1670(ra) # 80003926 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052a8:	2981                	sext.w	s3,s3
    800052aa:	4789                	li	a5,2
    800052ac:	02f99463          	bne	s3,a5,800052d4 <create+0x86>
    800052b0:	04c4d783          	lhu	a5,76(s1)
    800052b4:	37f9                	addiw	a5,a5,-2
    800052b6:	17c2                	slli	a5,a5,0x30
    800052b8:	93c1                	srli	a5,a5,0x30
    800052ba:	4705                	li	a4,1
    800052bc:	00f76c63          	bltu	a4,a5,800052d4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052c0:	8526                	mv	a0,s1
    800052c2:	60a6                	ld	ra,72(sp)
    800052c4:	6406                	ld	s0,64(sp)
    800052c6:	74e2                	ld	s1,56(sp)
    800052c8:	7942                	ld	s2,48(sp)
    800052ca:	79a2                	ld	s3,40(sp)
    800052cc:	7a02                	ld	s4,32(sp)
    800052ce:	6ae2                	ld	s5,24(sp)
    800052d0:	6161                	addi	sp,sp,80
    800052d2:	8082                	ret
    iunlockput(ip);
    800052d4:	8526                	mv	a0,s1
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	8b2080e7          	jalr	-1870(ra) # 80003b88 <iunlockput>
    return 0;
    800052de:	4481                	li	s1,0
    800052e0:	b7c5                	j	800052c0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052e2:	85ce                	mv	a1,s3
    800052e4:	00092503          	lw	a0,0(s2)
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	4a6080e7          	jalr	1190(ra) # 8000378e <ialloc>
    800052f0:	84aa                	mv	s1,a0
    800052f2:	c529                	beqz	a0,8000533c <create+0xee>
  ilock(ip);
    800052f4:	ffffe097          	auipc	ra,0xffffe
    800052f8:	632080e7          	jalr	1586(ra) # 80003926 <ilock>
  ip->major = major;
    800052fc:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005300:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005304:	4785                	li	a5,1
    80005306:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	550080e7          	jalr	1360(ra) # 8000385c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005314:	2981                	sext.w	s3,s3
    80005316:	4785                	li	a5,1
    80005318:	02f98a63          	beq	s3,a5,8000534c <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000531c:	40d0                	lw	a2,4(s1)
    8000531e:	fb040593          	addi	a1,s0,-80
    80005322:	854a                	mv	a0,s2
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	cf6080e7          	jalr	-778(ra) # 8000401a <dirlink>
    8000532c:	06054b63          	bltz	a0,800053a2 <create+0x154>
  iunlockput(dp);
    80005330:	854a                	mv	a0,s2
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	856080e7          	jalr	-1962(ra) # 80003b88 <iunlockput>
  return ip;
    8000533a:	b759                	j	800052c0 <create+0x72>
    panic("create: ialloc");
    8000533c:	00005517          	auipc	a0,0x5
    80005340:	95450513          	addi	a0,a0,-1708 # 80009c90 <syscalls+0x2b0>
    80005344:	ffffb097          	auipc	ra,0xffffb
    80005348:	226080e7          	jalr	550(ra) # 8000056a <panic>
    dp->nlink++;  // for ".."
    8000534c:	05295783          	lhu	a5,82(s2)
    80005350:	2785                	addiw	a5,a5,1
    80005352:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005356:	854a                	mv	a0,s2
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	504080e7          	jalr	1284(ra) # 8000385c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005360:	40d0                	lw	a2,4(s1)
    80005362:	00005597          	auipc	a1,0x5
    80005366:	93e58593          	addi	a1,a1,-1730 # 80009ca0 <syscalls+0x2c0>
    8000536a:	8526                	mv	a0,s1
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	cae080e7          	jalr	-850(ra) # 8000401a <dirlink>
    80005374:	00054f63          	bltz	a0,80005392 <create+0x144>
    80005378:	00492603          	lw	a2,4(s2)
    8000537c:	00005597          	auipc	a1,0x5
    80005380:	92c58593          	addi	a1,a1,-1748 # 80009ca8 <syscalls+0x2c8>
    80005384:	8526                	mv	a0,s1
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	c94080e7          	jalr	-876(ra) # 8000401a <dirlink>
    8000538e:	f80557e3          	bgez	a0,8000531c <create+0xce>
      panic("create dots");
    80005392:	00005517          	auipc	a0,0x5
    80005396:	91e50513          	addi	a0,a0,-1762 # 80009cb0 <syscalls+0x2d0>
    8000539a:	ffffb097          	auipc	ra,0xffffb
    8000539e:	1d0080e7          	jalr	464(ra) # 8000056a <panic>
    panic("create: dirlink");
    800053a2:	00005517          	auipc	a0,0x5
    800053a6:	91e50513          	addi	a0,a0,-1762 # 80009cc0 <syscalls+0x2e0>
    800053aa:	ffffb097          	auipc	ra,0xffffb
    800053ae:	1c0080e7          	jalr	448(ra) # 8000056a <panic>
    return 0;
    800053b2:	84aa                	mv	s1,a0
    800053b4:	b731                	j	800052c0 <create+0x72>

00000000800053b6 <sys_dup>:
{
    800053b6:	7179                	addi	sp,sp,-48
    800053b8:	f406                	sd	ra,40(sp)
    800053ba:	f022                	sd	s0,32(sp)
    800053bc:	ec26                	sd	s1,24(sp)
    800053be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053c0:	fd840613          	addi	a2,s0,-40
    800053c4:	4581                	li	a1,0
    800053c6:	4501                	li	a0,0
    800053c8:	00000097          	auipc	ra,0x0
    800053cc:	ddc080e7          	jalr	-548(ra) # 800051a4 <argfd>
    return -1;
    800053d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d2:	02054363          	bltz	a0,800053f8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053d6:	fd843503          	ld	a0,-40(s0)
    800053da:	00000097          	auipc	ra,0x0
    800053de:	e32080e7          	jalr	-462(ra) # 8000520c <fdalloc>
    800053e2:	84aa                	mv	s1,a0
    return -1;
    800053e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053e6:	00054963          	bltz	a0,800053f8 <sys_dup+0x42>
  filedup(f);
    800053ea:	fd843503          	ld	a0,-40(s0)
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	372080e7          	jalr	882(ra) # 80004760 <filedup>
  return fd;
    800053f6:	87a6                	mv	a5,s1
}
    800053f8:	853e                	mv	a0,a5
    800053fa:	70a2                	ld	ra,40(sp)
    800053fc:	7402                	ld	s0,32(sp)
    800053fe:	64e2                	ld	s1,24(sp)
    80005400:	6145                	addi	sp,sp,48
    80005402:	8082                	ret

0000000080005404 <sys_read>:
{
    80005404:	7179                	addi	sp,sp,-48
    80005406:	f406                	sd	ra,40(sp)
    80005408:	f022                	sd	s0,32(sp)
    8000540a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540c:	fe840613          	addi	a2,s0,-24
    80005410:	4581                	li	a1,0
    80005412:	4501                	li	a0,0
    80005414:	00000097          	auipc	ra,0x0
    80005418:	d90080e7          	jalr	-624(ra) # 800051a4 <argfd>
    return -1;
    8000541c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	04054163          	bltz	a0,80005460 <sys_read+0x5c>
    80005422:	fe440593          	addi	a1,s0,-28
    80005426:	4509                	li	a0,2
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	98c080e7          	jalr	-1652(ra) # 80002db4 <argint>
    return -1;
    80005430:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005432:	02054763          	bltz	a0,80005460 <sys_read+0x5c>
    80005436:	fd840593          	addi	a1,s0,-40
    8000543a:	4505                	li	a0,1
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	99a080e7          	jalr	-1638(ra) # 80002dd6 <argaddr>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005446:	00054d63          	bltz	a0,80005460 <sys_read+0x5c>
  return fileread(f, p, n);
    8000544a:	fe442603          	lw	a2,-28(s0)
    8000544e:	fd843583          	ld	a1,-40(s0)
    80005452:	fe843503          	ld	a0,-24(s0)
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	496080e7          	jalr	1174(ra) # 800048ec <fileread>
    8000545e:	87aa                	mv	a5,a0
}
    80005460:	853e                	mv	a0,a5
    80005462:	70a2                	ld	ra,40(sp)
    80005464:	7402                	ld	s0,32(sp)
    80005466:	6145                	addi	sp,sp,48
    80005468:	8082                	ret

000000008000546a <sys_write>:
{
    8000546a:	7179                	addi	sp,sp,-48
    8000546c:	f406                	sd	ra,40(sp)
    8000546e:	f022                	sd	s0,32(sp)
    80005470:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005472:	fe840613          	addi	a2,s0,-24
    80005476:	4581                	li	a1,0
    80005478:	4501                	li	a0,0
    8000547a:	00000097          	auipc	ra,0x0
    8000547e:	d2a080e7          	jalr	-726(ra) # 800051a4 <argfd>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	04054163          	bltz	a0,800054c6 <sys_write+0x5c>
    80005488:	fe440593          	addi	a1,s0,-28
    8000548c:	4509                	li	a0,2
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	926080e7          	jalr	-1754(ra) # 80002db4 <argint>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005498:	02054763          	bltz	a0,800054c6 <sys_write+0x5c>
    8000549c:	fd840593          	addi	a1,s0,-40
    800054a0:	4505                	li	a0,1
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	934080e7          	jalr	-1740(ra) # 80002dd6 <argaddr>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ac:	00054d63          	bltz	a0,800054c6 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054b0:	fe442603          	lw	a2,-28(s0)
    800054b4:	fd843583          	ld	a1,-40(s0)
    800054b8:	fe843503          	ld	a0,-24(s0)
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	4f6080e7          	jalr	1270(ra) # 800049b2 <filewrite>
    800054c4:	87aa                	mv	a5,a0
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	70a2                	ld	ra,40(sp)
    800054ca:	7402                	ld	s0,32(sp)
    800054cc:	6145                	addi	sp,sp,48
    800054ce:	8082                	ret

00000000800054d0 <sys_close>:
{
    800054d0:	1101                	addi	sp,sp,-32
    800054d2:	ec06                	sd	ra,24(sp)
    800054d4:	e822                	sd	s0,16(sp)
    800054d6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054d8:	fe040613          	addi	a2,s0,-32
    800054dc:	fec40593          	addi	a1,s0,-20
    800054e0:	4501                	li	a0,0
    800054e2:	00000097          	auipc	ra,0x0
    800054e6:	cc2080e7          	jalr	-830(ra) # 800051a4 <argfd>
    return -1;
    800054ea:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ec:	02054463          	bltz	a0,80005514 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054f0:	ffffc097          	auipc	ra,0xffffc
    800054f4:	6ae080e7          	jalr	1710(ra) # 80001b9e <myproc>
    800054f8:	fec42783          	lw	a5,-20(s0)
    800054fc:	07e9                	addi	a5,a5,26
    800054fe:	078e                	slli	a5,a5,0x3
    80005500:	97aa                	add	a5,a5,a0
    80005502:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005506:	fe043503          	ld	a0,-32(s0)
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	2a8080e7          	jalr	680(ra) # 800047b2 <fileclose>
  return 0;
    80005512:	4781                	li	a5,0
}
    80005514:	853e                	mv	a0,a5
    80005516:	60e2                	ld	ra,24(sp)
    80005518:	6442                	ld	s0,16(sp)
    8000551a:	6105                	addi	sp,sp,32
    8000551c:	8082                	ret

000000008000551e <sys_fstat>:
{
    8000551e:	1101                	addi	sp,sp,-32
    80005520:	ec06                	sd	ra,24(sp)
    80005522:	e822                	sd	s0,16(sp)
    80005524:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005526:	fe840613          	addi	a2,s0,-24
    8000552a:	4581                	li	a1,0
    8000552c:	4501                	li	a0,0
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	c76080e7          	jalr	-906(ra) # 800051a4 <argfd>
    return -1;
    80005536:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005538:	02054563          	bltz	a0,80005562 <sys_fstat+0x44>
    8000553c:	fe040593          	addi	a1,s0,-32
    80005540:	4505                	li	a0,1
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	894080e7          	jalr	-1900(ra) # 80002dd6 <argaddr>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554c:	00054b63          	bltz	a0,80005562 <sys_fstat+0x44>
  return filestat(f, st);
    80005550:	fe043583          	ld	a1,-32(s0)
    80005554:	fe843503          	ld	a0,-24(s0)
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	322080e7          	jalr	802(ra) # 8000487a <filestat>
    80005560:	87aa                	mv	a5,a0
}
    80005562:	853e                	mv	a0,a5
    80005564:	60e2                	ld	ra,24(sp)
    80005566:	6442                	ld	s0,16(sp)
    80005568:	6105                	addi	sp,sp,32
    8000556a:	8082                	ret

000000008000556c <sys_link>:
{
    8000556c:	7169                	addi	sp,sp,-304
    8000556e:	f606                	sd	ra,296(sp)
    80005570:	f222                	sd	s0,288(sp)
    80005572:	ee26                	sd	s1,280(sp)
    80005574:	ea4a                	sd	s2,272(sp)
    80005576:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005578:	08000613          	li	a2,128
    8000557c:	ed040593          	addi	a1,s0,-304
    80005580:	4501                	li	a0,0
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	876080e7          	jalr	-1930(ra) # 80002df8 <argstr>
    return -1;
    8000558a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558c:	10054e63          	bltz	a0,800056a8 <sys_link+0x13c>
    80005590:	08000613          	li	a2,128
    80005594:	f5040593          	addi	a1,s0,-176
    80005598:	4505                	li	a0,1
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	85e080e7          	jalr	-1954(ra) # 80002df8 <argstr>
    return -1;
    800055a2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a4:	10054263          	bltz	a0,800056a8 <sys_link+0x13c>
  begin_op();
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	d40080e7          	jalr	-704(ra) # 800042e8 <begin_op>
  if((ip = namei(old)) == 0){
    800055b0:	ed040513          	addi	a0,s0,-304
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	b28080e7          	jalr	-1240(ra) # 800040dc <namei>
    800055bc:	84aa                	mv	s1,a0
    800055be:	c551                	beqz	a0,8000564a <sys_link+0xde>
  ilock(ip);
    800055c0:	ffffe097          	auipc	ra,0xffffe
    800055c4:	366080e7          	jalr	870(ra) # 80003926 <ilock>
  if(ip->type == T_DIR){
    800055c8:	04c49703          	lh	a4,76(s1)
    800055cc:	4785                	li	a5,1
    800055ce:	08f70463          	beq	a4,a5,80005656 <sys_link+0xea>
  ip->nlink++;
    800055d2:	0524d783          	lhu	a5,82(s1)
    800055d6:	2785                	addiw	a5,a5,1
    800055d8:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	27e080e7          	jalr	638(ra) # 8000385c <iupdate>
  iunlock(ip);
    800055e6:	8526                	mv	a0,s1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	400080e7          	jalr	1024(ra) # 800039e8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f0:	fd040593          	addi	a1,s0,-48
    800055f4:	f5040513          	addi	a0,s0,-176
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	b02080e7          	jalr	-1278(ra) # 800040fa <nameiparent>
    80005600:	892a                	mv	s2,a0
    80005602:	c935                	beqz	a0,80005676 <sys_link+0x10a>
  ilock(dp);
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	322080e7          	jalr	802(ra) # 80003926 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000560c:	00092703          	lw	a4,0(s2)
    80005610:	409c                	lw	a5,0(s1)
    80005612:	04f71d63          	bne	a4,a5,8000566c <sys_link+0x100>
    80005616:	40d0                	lw	a2,4(s1)
    80005618:	fd040593          	addi	a1,s0,-48
    8000561c:	854a                	mv	a0,s2
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	9fc080e7          	jalr	-1540(ra) # 8000401a <dirlink>
    80005626:	04054363          	bltz	a0,8000566c <sys_link+0x100>
  iunlockput(dp);
    8000562a:	854a                	mv	a0,s2
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	55c080e7          	jalr	1372(ra) # 80003b88 <iunlockput>
  iput(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	4aa080e7          	jalr	1194(ra) # 80003ae0 <iput>
  end_op();
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	d2a080e7          	jalr	-726(ra) # 80004368 <end_op>
  return 0;
    80005646:	4781                	li	a5,0
    80005648:	a085                	j	800056a8 <sys_link+0x13c>
    end_op();
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	d1e080e7          	jalr	-738(ra) # 80004368 <end_op>
    return -1;
    80005652:	57fd                	li	a5,-1
    80005654:	a891                	j	800056a8 <sys_link+0x13c>
    iunlockput(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	530080e7          	jalr	1328(ra) # 80003b88 <iunlockput>
    end_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	d08080e7          	jalr	-760(ra) # 80004368 <end_op>
    return -1;
    80005668:	57fd                	li	a5,-1
    8000566a:	a83d                	j	800056a8 <sys_link+0x13c>
    iunlockput(dp);
    8000566c:	854a                	mv	a0,s2
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	51a080e7          	jalr	1306(ra) # 80003b88 <iunlockput>
  ilock(ip);
    80005676:	8526                	mv	a0,s1
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	2ae080e7          	jalr	686(ra) # 80003926 <ilock>
  ip->nlink--;
    80005680:	0524d783          	lhu	a5,82(s1)
    80005684:	37fd                	addiw	a5,a5,-1
    80005686:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000568a:	8526                	mv	a0,s1
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	1d0080e7          	jalr	464(ra) # 8000385c <iupdate>
  iunlockput(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	4f2080e7          	jalr	1266(ra) # 80003b88 <iunlockput>
  end_op();
    8000569e:	fffff097          	auipc	ra,0xfffff
    800056a2:	cca080e7          	jalr	-822(ra) # 80004368 <end_op>
  return -1;
    800056a6:	57fd                	li	a5,-1
}
    800056a8:	853e                	mv	a0,a5
    800056aa:	70b2                	ld	ra,296(sp)
    800056ac:	7412                	ld	s0,288(sp)
    800056ae:	64f2                	ld	s1,280(sp)
    800056b0:	6952                	ld	s2,272(sp)
    800056b2:	6155                	addi	sp,sp,304
    800056b4:	8082                	ret

00000000800056b6 <sys_unlink>:
{
    800056b6:	7151                	addi	sp,sp,-240
    800056b8:	f586                	sd	ra,232(sp)
    800056ba:	f1a2                	sd	s0,224(sp)
    800056bc:	eda6                	sd	s1,216(sp)
    800056be:	e9ca                	sd	s2,208(sp)
    800056c0:	e5ce                	sd	s3,200(sp)
    800056c2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056c4:	08000613          	li	a2,128
    800056c8:	f3040593          	addi	a1,s0,-208
    800056cc:	4501                	li	a0,0
    800056ce:	ffffd097          	auipc	ra,0xffffd
    800056d2:	72a080e7          	jalr	1834(ra) # 80002df8 <argstr>
    800056d6:	18054163          	bltz	a0,80005858 <sys_unlink+0x1a2>
  begin_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	c0e080e7          	jalr	-1010(ra) # 800042e8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056e2:	fb040593          	addi	a1,s0,-80
    800056e6:	f3040513          	addi	a0,s0,-208
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	a10080e7          	jalr	-1520(ra) # 800040fa <nameiparent>
    800056f2:	84aa                	mv	s1,a0
    800056f4:	c979                	beqz	a0,800057ca <sys_unlink+0x114>
  ilock(dp);
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	230080e7          	jalr	560(ra) # 80003926 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056fe:	00004597          	auipc	a1,0x4
    80005702:	5a258593          	addi	a1,a1,1442 # 80009ca0 <syscalls+0x2c0>
    80005706:	fb040513          	addi	a0,s0,-80
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	6e6080e7          	jalr	1766(ra) # 80003df0 <namecmp>
    80005712:	14050a63          	beqz	a0,80005866 <sys_unlink+0x1b0>
    80005716:	00004597          	auipc	a1,0x4
    8000571a:	59258593          	addi	a1,a1,1426 # 80009ca8 <syscalls+0x2c8>
    8000571e:	fb040513          	addi	a0,s0,-80
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	6ce080e7          	jalr	1742(ra) # 80003df0 <namecmp>
    8000572a:	12050e63          	beqz	a0,80005866 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000572e:	f2c40613          	addi	a2,s0,-212
    80005732:	fb040593          	addi	a1,s0,-80
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	6d2080e7          	jalr	1746(ra) # 80003e0a <dirlookup>
    80005740:	892a                	mv	s2,a0
    80005742:	12050263          	beqz	a0,80005866 <sys_unlink+0x1b0>
  ilock(ip);
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	1e0080e7          	jalr	480(ra) # 80003926 <ilock>
  if(ip->nlink < 1)
    8000574e:	05291783          	lh	a5,82(s2)
    80005752:	08f05263          	blez	a5,800057d6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005756:	04c91703          	lh	a4,76(s2)
    8000575a:	4785                	li	a5,1
    8000575c:	08f70563          	beq	a4,a5,800057e6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005760:	4641                	li	a2,16
    80005762:	4581                	li	a1,0
    80005764:	fc040513          	addi	a0,s0,-64
    80005768:	ffffb097          	auipc	ra,0xffffb
    8000576c:	718080e7          	jalr	1816(ra) # 80000e80 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005770:	4741                	li	a4,16
    80005772:	f2c42683          	lw	a3,-212(s0)
    80005776:	fc040613          	addi	a2,s0,-64
    8000577a:	4581                	li	a1,0
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	554080e7          	jalr	1364(ra) # 80003cd2 <writei>
    80005786:	47c1                	li	a5,16
    80005788:	0af51563          	bne	a0,a5,80005832 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000578c:	04c91703          	lh	a4,76(s2)
    80005790:	4785                	li	a5,1
    80005792:	0af70863          	beq	a4,a5,80005842 <sys_unlink+0x18c>
  iunlockput(dp);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	3f0080e7          	jalr	1008(ra) # 80003b88 <iunlockput>
  ip->nlink--;
    800057a0:	05295783          	lhu	a5,82(s2)
    800057a4:	37fd                	addiw	a5,a5,-1
    800057a6:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	0b0080e7          	jalr	176(ra) # 8000385c <iupdate>
  iunlockput(ip);
    800057b4:	854a                	mv	a0,s2
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	3d2080e7          	jalr	978(ra) # 80003b88 <iunlockput>
  end_op();
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	baa080e7          	jalr	-1110(ra) # 80004368 <end_op>
  return 0;
    800057c6:	4501                	li	a0,0
    800057c8:	a84d                	j	8000587a <sys_unlink+0x1c4>
    end_op();
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	b9e080e7          	jalr	-1122(ra) # 80004368 <end_op>
    return -1;
    800057d2:	557d                	li	a0,-1
    800057d4:	a05d                	j	8000587a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057d6:	00004517          	auipc	a0,0x4
    800057da:	4fa50513          	addi	a0,a0,1274 # 80009cd0 <syscalls+0x2f0>
    800057de:	ffffb097          	auipc	ra,0xffffb
    800057e2:	d8c080e7          	jalr	-628(ra) # 8000056a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e6:	05492703          	lw	a4,84(s2)
    800057ea:	02000793          	li	a5,32
    800057ee:	f6e7f9e3          	bgeu	a5,a4,80005760 <sys_unlink+0xaa>
    800057f2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f6:	4741                	li	a4,16
    800057f8:	86ce                	mv	a3,s3
    800057fa:	f1840613          	addi	a2,s0,-232
    800057fe:	4581                	li	a1,0
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	3d8080e7          	jalr	984(ra) # 80003bda <readi>
    8000580a:	47c1                	li	a5,16
    8000580c:	00f51b63          	bne	a0,a5,80005822 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005810:	f1845783          	lhu	a5,-232(s0)
    80005814:	e7a1                	bnez	a5,8000585c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005816:	29c1                	addiw	s3,s3,16
    80005818:	05492783          	lw	a5,84(s2)
    8000581c:	fcf9ede3          	bltu	s3,a5,800057f6 <sys_unlink+0x140>
    80005820:	b781                	j	80005760 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005822:	00004517          	auipc	a0,0x4
    80005826:	4c650513          	addi	a0,a0,1222 # 80009ce8 <syscalls+0x308>
    8000582a:	ffffb097          	auipc	ra,0xffffb
    8000582e:	d40080e7          	jalr	-704(ra) # 8000056a <panic>
    panic("unlink: writei");
    80005832:	00004517          	auipc	a0,0x4
    80005836:	4ce50513          	addi	a0,a0,1230 # 80009d00 <syscalls+0x320>
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	d30080e7          	jalr	-720(ra) # 8000056a <panic>
    dp->nlink--;
    80005842:	0524d783          	lhu	a5,82(s1)
    80005846:	37fd                	addiw	a5,a5,-1
    80005848:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	00e080e7          	jalr	14(ra) # 8000385c <iupdate>
    80005856:	b781                	j	80005796 <sys_unlink+0xe0>
    return -1;
    80005858:	557d                	li	a0,-1
    8000585a:	a005                	j	8000587a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	32a080e7          	jalr	810(ra) # 80003b88 <iunlockput>
  iunlockput(dp);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	320080e7          	jalr	800(ra) # 80003b88 <iunlockput>
  end_op();
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	af8080e7          	jalr	-1288(ra) # 80004368 <end_op>
  return -1;
    80005878:	557d                	li	a0,-1
}
    8000587a:	70ae                	ld	ra,232(sp)
    8000587c:	740e                	ld	s0,224(sp)
    8000587e:	64ee                	ld	s1,216(sp)
    80005880:	694e                	ld	s2,208(sp)
    80005882:	69ae                	ld	s3,200(sp)
    80005884:	616d                	addi	sp,sp,240
    80005886:	8082                	ret

0000000080005888 <sys_open>:

uint64
sys_open(void)
{
    80005888:	7131                	addi	sp,sp,-192
    8000588a:	fd06                	sd	ra,184(sp)
    8000588c:	f922                	sd	s0,176(sp)
    8000588e:	f526                	sd	s1,168(sp)
    80005890:	f14a                	sd	s2,160(sp)
    80005892:	ed4e                	sd	s3,152(sp)
    80005894:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005896:	08000613          	li	a2,128
    8000589a:	f5040593          	addi	a1,s0,-176
    8000589e:	4501                	li	a0,0
    800058a0:	ffffd097          	auipc	ra,0xffffd
    800058a4:	558080e7          	jalr	1368(ra) # 80002df8 <argstr>
    return -1;
    800058a8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058aa:	0c054163          	bltz	a0,8000596c <sys_open+0xe4>
    800058ae:	f4c40593          	addi	a1,s0,-180
    800058b2:	4505                	li	a0,1
    800058b4:	ffffd097          	auipc	ra,0xffffd
    800058b8:	500080e7          	jalr	1280(ra) # 80002db4 <argint>
    800058bc:	0a054863          	bltz	a0,8000596c <sys_open+0xe4>

  begin_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	a28080e7          	jalr	-1496(ra) # 800042e8 <begin_op>

  if(omode & O_CREATE){
    800058c8:	f4c42783          	lw	a5,-180(s0)
    800058cc:	2007f793          	andi	a5,a5,512
    800058d0:	cbdd                	beqz	a5,80005986 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058d2:	4681                	li	a3,0
    800058d4:	4601                	li	a2,0
    800058d6:	4589                	li	a1,2
    800058d8:	f5040513          	addi	a0,s0,-176
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	972080e7          	jalr	-1678(ra) # 8000524e <create>
    800058e4:	892a                	mv	s2,a0
    if(ip == 0){
    800058e6:	c959                	beqz	a0,8000597c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058e8:	04c91703          	lh	a4,76(s2)
    800058ec:	478d                	li	a5,3
    800058ee:	00f71763          	bne	a4,a5,800058fc <sys_open+0x74>
    800058f2:	04e95703          	lhu	a4,78(s2)
    800058f6:	47a5                	li	a5,9
    800058f8:	0ce7ec63          	bltu	a5,a4,800059d0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	dfa080e7          	jalr	-518(ra) # 800046f6 <filealloc>
    80005904:	89aa                	mv	s3,a0
    80005906:	10050663          	beqz	a0,80005a12 <sys_open+0x18a>
    8000590a:	00000097          	auipc	ra,0x0
    8000590e:	902080e7          	jalr	-1790(ra) # 8000520c <fdalloc>
    80005912:	84aa                	mv	s1,a0
    80005914:	0e054a63          	bltz	a0,80005a08 <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005918:	04c91703          	lh	a4,76(s2)
    8000591c:	478d                	li	a5,3
    8000591e:	0cf70463          	beq	a4,a5,800059e6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005922:	4789                	li	a5,2
    80005924:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005928:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    8000592c:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005930:	f4c42783          	lw	a5,-180(s0)
    80005934:	0017c713          	xori	a4,a5,1
    80005938:	8b05                	andi	a4,a4,1
    8000593a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000593e:	0037f713          	andi	a4,a5,3
    80005942:	00e03733          	snez	a4,a4
    80005946:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000594a:	4007f793          	andi	a5,a5,1024
    8000594e:	c791                	beqz	a5,8000595a <sys_open+0xd2>
    80005950:	04c91703          	lh	a4,76(s2)
    80005954:	4789                	li	a5,2
    80005956:	0af70363          	beq	a4,a5,800059fc <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	08c080e7          	jalr	140(ra) # 800039e8 <iunlock>
  end_op();
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	a04080e7          	jalr	-1532(ra) # 80004368 <end_op>

  return fd;
}
    8000596c:	8526                	mv	a0,s1
    8000596e:	70ea                	ld	ra,184(sp)
    80005970:	744a                	ld	s0,176(sp)
    80005972:	74aa                	ld	s1,168(sp)
    80005974:	790a                	ld	s2,160(sp)
    80005976:	69ea                	ld	s3,152(sp)
    80005978:	6129                	addi	sp,sp,192
    8000597a:	8082                	ret
      end_op();
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	9ec080e7          	jalr	-1556(ra) # 80004368 <end_op>
      return -1;
    80005984:	b7e5                	j	8000596c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005986:	f5040513          	addi	a0,s0,-176
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	752080e7          	jalr	1874(ra) # 800040dc <namei>
    80005992:	892a                	mv	s2,a0
    80005994:	c905                	beqz	a0,800059c4 <sys_open+0x13c>
    ilock(ip);
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	f90080e7          	jalr	-112(ra) # 80003926 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000599e:	04c91703          	lh	a4,76(s2)
    800059a2:	4785                	li	a5,1
    800059a4:	f4f712e3          	bne	a4,a5,800058e8 <sys_open+0x60>
    800059a8:	f4c42783          	lw	a5,-180(s0)
    800059ac:	dba1                	beqz	a5,800058fc <sys_open+0x74>
      iunlockput(ip);
    800059ae:	854a                	mv	a0,s2
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	1d8080e7          	jalr	472(ra) # 80003b88 <iunlockput>
      end_op();
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	9b0080e7          	jalr	-1616(ra) # 80004368 <end_op>
      return -1;
    800059c0:	54fd                	li	s1,-1
    800059c2:	b76d                	j	8000596c <sys_open+0xe4>
      end_op();
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	9a4080e7          	jalr	-1628(ra) # 80004368 <end_op>
      return -1;
    800059cc:	54fd                	li	s1,-1
    800059ce:	bf79                	j	8000596c <sys_open+0xe4>
    iunlockput(ip);
    800059d0:	854a                	mv	a0,s2
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	1b6080e7          	jalr	438(ra) # 80003b88 <iunlockput>
    end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	98e080e7          	jalr	-1650(ra) # 80004368 <end_op>
    return -1;
    800059e2:	54fd                	li	s1,-1
    800059e4:	b761                	j	8000596c <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059e6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ea:	04e91783          	lh	a5,78(s2)
    800059ee:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800059f2:	05091783          	lh	a5,80(s2)
    800059f6:	02f99323          	sh	a5,38(s3)
    800059fa:	b73d                	j	80005928 <sys_open+0xa0>
    itrunc(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	036080e7          	jalr	54(ra) # 80003a34 <itrunc>
    80005a06:	bf91                	j	8000595a <sys_open+0xd2>
      fileclose(f);
    80005a08:	854e                	mv	a0,s3
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	da8080e7          	jalr	-600(ra) # 800047b2 <fileclose>
    iunlockput(ip);
    80005a12:	854a                	mv	a0,s2
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	174080e7          	jalr	372(ra) # 80003b88 <iunlockput>
    end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	94c080e7          	jalr	-1716(ra) # 80004368 <end_op>
    return -1;
    80005a24:	54fd                	li	s1,-1
    80005a26:	b799                	j	8000596c <sys_open+0xe4>

0000000080005a28 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a28:	7175                	addi	sp,sp,-144
    80005a2a:	e506                	sd	ra,136(sp)
    80005a2c:	e122                	sd	s0,128(sp)
    80005a2e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	8b8080e7          	jalr	-1864(ra) # 800042e8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a38:	08000613          	li	a2,128
    80005a3c:	f7040593          	addi	a1,s0,-144
    80005a40:	4501                	li	a0,0
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	3b6080e7          	jalr	950(ra) # 80002df8 <argstr>
    80005a4a:	02054963          	bltz	a0,80005a7c <sys_mkdir+0x54>
    80005a4e:	4681                	li	a3,0
    80005a50:	4601                	li	a2,0
    80005a52:	4585                	li	a1,1
    80005a54:	f7040513          	addi	a0,s0,-144
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	7f6080e7          	jalr	2038(ra) # 8000524e <create>
    80005a60:	cd11                	beqz	a0,80005a7c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	126080e7          	jalr	294(ra) # 80003b88 <iunlockput>
  end_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	8fe080e7          	jalr	-1794(ra) # 80004368 <end_op>
  return 0;
    80005a72:	4501                	li	a0,0
}
    80005a74:	60aa                	ld	ra,136(sp)
    80005a76:	640a                	ld	s0,128(sp)
    80005a78:	6149                	addi	sp,sp,144
    80005a7a:	8082                	ret
    end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	8ec080e7          	jalr	-1812(ra) # 80004368 <end_op>
    return -1;
    80005a84:	557d                	li	a0,-1
    80005a86:	b7fd                	j	80005a74 <sys_mkdir+0x4c>

0000000080005a88 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a88:	7135                	addi	sp,sp,-160
    80005a8a:	ed06                	sd	ra,152(sp)
    80005a8c:	e922                	sd	s0,144(sp)
    80005a8e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	858080e7          	jalr	-1960(ra) # 800042e8 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a98:	08000613          	li	a2,128
    80005a9c:	f7040593          	addi	a1,s0,-144
    80005aa0:	4501                	li	a0,0
    80005aa2:	ffffd097          	auipc	ra,0xffffd
    80005aa6:	356080e7          	jalr	854(ra) # 80002df8 <argstr>
    80005aaa:	04054a63          	bltz	a0,80005afe <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005aae:	f6c40593          	addi	a1,s0,-148
    80005ab2:	4505                	li	a0,1
    80005ab4:	ffffd097          	auipc	ra,0xffffd
    80005ab8:	300080e7          	jalr	768(ra) # 80002db4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005abc:	04054163          	bltz	a0,80005afe <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ac0:	f6840593          	addi	a1,s0,-152
    80005ac4:	4509                	li	a0,2
    80005ac6:	ffffd097          	auipc	ra,0xffffd
    80005aca:	2ee080e7          	jalr	750(ra) # 80002db4 <argint>
     argint(1, &major) < 0 ||
    80005ace:	02054863          	bltz	a0,80005afe <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ad2:	f6841683          	lh	a3,-152(s0)
    80005ad6:	f6c41603          	lh	a2,-148(s0)
    80005ada:	458d                	li	a1,3
    80005adc:	f7040513          	addi	a0,s0,-144
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	76e080e7          	jalr	1902(ra) # 8000524e <create>
     argint(2, &minor) < 0 ||
    80005ae8:	c919                	beqz	a0,80005afe <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	09e080e7          	jalr	158(ra) # 80003b88 <iunlockput>
  end_op();
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	876080e7          	jalr	-1930(ra) # 80004368 <end_op>
  return 0;
    80005afa:	4501                	li	a0,0
    80005afc:	a031                	j	80005b08 <sys_mknod+0x80>
    end_op();
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	86a080e7          	jalr	-1942(ra) # 80004368 <end_op>
    return -1;
    80005b06:	557d                	li	a0,-1
}
    80005b08:	60ea                	ld	ra,152(sp)
    80005b0a:	644a                	ld	s0,144(sp)
    80005b0c:	610d                	addi	sp,sp,160
    80005b0e:	8082                	ret

0000000080005b10 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b10:	7135                	addi	sp,sp,-160
    80005b12:	ed06                	sd	ra,152(sp)
    80005b14:	e922                	sd	s0,144(sp)
    80005b16:	e526                	sd	s1,136(sp)
    80005b18:	e14a                	sd	s2,128(sp)
    80005b1a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b1c:	ffffc097          	auipc	ra,0xffffc
    80005b20:	082080e7          	jalr	130(ra) # 80001b9e <myproc>
    80005b24:	892a                	mv	s2,a0
  
  begin_op();
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	7c2080e7          	jalr	1986(ra) # 800042e8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b2e:	08000613          	li	a2,128
    80005b32:	f6040593          	addi	a1,s0,-160
    80005b36:	4501                	li	a0,0
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	2c0080e7          	jalr	704(ra) # 80002df8 <argstr>
    80005b40:	04054b63          	bltz	a0,80005b96 <sys_chdir+0x86>
    80005b44:	f6040513          	addi	a0,s0,-160
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	594080e7          	jalr	1428(ra) # 800040dc <namei>
    80005b50:	84aa                	mv	s1,a0
    80005b52:	c131                	beqz	a0,80005b96 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	dd2080e7          	jalr	-558(ra) # 80003926 <ilock>
  if(ip->type != T_DIR){
    80005b5c:	04c49703          	lh	a4,76(s1)
    80005b60:	4785                	li	a5,1
    80005b62:	04f71063          	bne	a4,a5,80005ba2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	e80080e7          	jalr	-384(ra) # 800039e8 <iunlock>
  iput(p->cwd);
    80005b70:	15893503          	ld	a0,344(s2)
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	f6c080e7          	jalr	-148(ra) # 80003ae0 <iput>
  end_op();
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	7ec080e7          	jalr	2028(ra) # 80004368 <end_op>
  p->cwd = ip;
    80005b84:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b88:	4501                	li	a0,0
}
    80005b8a:	60ea                	ld	ra,152(sp)
    80005b8c:	644a                	ld	s0,144(sp)
    80005b8e:	64aa                	ld	s1,136(sp)
    80005b90:	690a                	ld	s2,128(sp)
    80005b92:	610d                	addi	sp,sp,160
    80005b94:	8082                	ret
    end_op();
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	7d2080e7          	jalr	2002(ra) # 80004368 <end_op>
    return -1;
    80005b9e:	557d                	li	a0,-1
    80005ba0:	b7ed                	j	80005b8a <sys_chdir+0x7a>
    iunlockput(ip);
    80005ba2:	8526                	mv	a0,s1
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	fe4080e7          	jalr	-28(ra) # 80003b88 <iunlockput>
    end_op();
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	7bc080e7          	jalr	1980(ra) # 80004368 <end_op>
    return -1;
    80005bb4:	557d                	li	a0,-1
    80005bb6:	bfd1                	j	80005b8a <sys_chdir+0x7a>

0000000080005bb8 <sys_exec>:

uint64
sys_exec(void)
{
    80005bb8:	7145                	addi	sp,sp,-464
    80005bba:	e786                	sd	ra,456(sp)
    80005bbc:	e3a2                	sd	s0,448(sp)
    80005bbe:	ff26                	sd	s1,440(sp)
    80005bc0:	fb4a                	sd	s2,432(sp)
    80005bc2:	f74e                	sd	s3,424(sp)
    80005bc4:	f352                	sd	s4,416(sp)
    80005bc6:	ef56                	sd	s5,408(sp)
    80005bc8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bca:	08000613          	li	a2,128
    80005bce:	f4040593          	addi	a1,s0,-192
    80005bd2:	4501                	li	a0,0
    80005bd4:	ffffd097          	auipc	ra,0xffffd
    80005bd8:	224080e7          	jalr	548(ra) # 80002df8 <argstr>
    return -1;
    80005bdc:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bde:	0c054a63          	bltz	a0,80005cb2 <sys_exec+0xfa>
    80005be2:	e3840593          	addi	a1,s0,-456
    80005be6:	4505                	li	a0,1
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	1ee080e7          	jalr	494(ra) # 80002dd6 <argaddr>
    80005bf0:	0c054163          	bltz	a0,80005cb2 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bf4:	10000613          	li	a2,256
    80005bf8:	4581                	li	a1,0
    80005bfa:	e4040513          	addi	a0,s0,-448
    80005bfe:	ffffb097          	auipc	ra,0xffffb
    80005c02:	282080e7          	jalr	642(ra) # 80000e80 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c06:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c0a:	89a6                	mv	s3,s1
    80005c0c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c0e:	02000a13          	li	s4,32
    80005c12:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c16:	00391513          	slli	a0,s2,0x3
    80005c1a:	e3040593          	addi	a1,s0,-464
    80005c1e:	e3843783          	ld	a5,-456(s0)
    80005c22:	953e                	add	a0,a0,a5
    80005c24:	ffffd097          	auipc	ra,0xffffd
    80005c28:	0f6080e7          	jalr	246(ra) # 80002d1a <fetchaddr>
    80005c2c:	02054a63          	bltz	a0,80005c60 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c30:	e3043783          	ld	a5,-464(s0)
    80005c34:	c3b9                	beqz	a5,80005c7a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c36:	ffffb097          	auipc	ra,0xffffb
    80005c3a:	e16080e7          	jalr	-490(ra) # 80000a4c <kalloc>
    80005c3e:	85aa                	mv	a1,a0
    80005c40:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c44:	cd11                	beqz	a0,80005c60 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c46:	6605                	lui	a2,0x1
    80005c48:	e3043503          	ld	a0,-464(s0)
    80005c4c:	ffffd097          	auipc	ra,0xffffd
    80005c50:	120080e7          	jalr	288(ra) # 80002d6c <fetchstr>
    80005c54:	00054663          	bltz	a0,80005c60 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c58:	0905                	addi	s2,s2,1
    80005c5a:	09a1                	addi	s3,s3,8
    80005c5c:	fb491be3          	bne	s2,s4,80005c12 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c60:	10048913          	addi	s2,s1,256
    80005c64:	6088                	ld	a0,0(s1)
    80005c66:	c529                	beqz	a0,80005cb0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	cde080e7          	jalr	-802(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c70:	04a1                	addi	s1,s1,8
    80005c72:	ff2499e3          	bne	s1,s2,80005c64 <sys_exec+0xac>
  return -1;
    80005c76:	597d                	li	s2,-1
    80005c78:	a82d                	j	80005cb2 <sys_exec+0xfa>
      argv[i] = 0;
    80005c7a:	0a8e                	slli	s5,s5,0x3
    80005c7c:	fc040793          	addi	a5,s0,-64
    80005c80:	9abe                	add	s5,s5,a5
    80005c82:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c86:	e4040593          	addi	a1,s0,-448
    80005c8a:	f4040513          	addi	a0,s0,-192
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	18c080e7          	jalr	396(ra) # 80004e1a <exec>
    80005c96:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c98:	10048993          	addi	s3,s1,256
    80005c9c:	6088                	ld	a0,0(s1)
    80005c9e:	c911                	beqz	a0,80005cb2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	ca6080e7          	jalr	-858(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca8:	04a1                	addi	s1,s1,8
    80005caa:	ff3499e3          	bne	s1,s3,80005c9c <sys_exec+0xe4>
    80005cae:	a011                	j	80005cb2 <sys_exec+0xfa>
  return -1;
    80005cb0:	597d                	li	s2,-1
}
    80005cb2:	854a                	mv	a0,s2
    80005cb4:	60be                	ld	ra,456(sp)
    80005cb6:	641e                	ld	s0,448(sp)
    80005cb8:	74fa                	ld	s1,440(sp)
    80005cba:	795a                	ld	s2,432(sp)
    80005cbc:	79ba                	ld	s3,424(sp)
    80005cbe:	7a1a                	ld	s4,416(sp)
    80005cc0:	6afa                	ld	s5,408(sp)
    80005cc2:	6179                	addi	sp,sp,464
    80005cc4:	8082                	ret

0000000080005cc6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cc6:	7139                	addi	sp,sp,-64
    80005cc8:	fc06                	sd	ra,56(sp)
    80005cca:	f822                	sd	s0,48(sp)
    80005ccc:	f426                	sd	s1,40(sp)
    80005cce:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cd0:	ffffc097          	auipc	ra,0xffffc
    80005cd4:	ece080e7          	jalr	-306(ra) # 80001b9e <myproc>
    80005cd8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cda:	fd840593          	addi	a1,s0,-40
    80005cde:	4501                	li	a0,0
    80005ce0:	ffffd097          	auipc	ra,0xffffd
    80005ce4:	0f6080e7          	jalr	246(ra) # 80002dd6 <argaddr>
    return -1;
    80005ce8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cea:	0e054063          	bltz	a0,80005dca <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005cee:	fc840593          	addi	a1,s0,-56
    80005cf2:	fd040513          	addi	a0,s0,-48
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	df4080e7          	jalr	-524(ra) # 80004aea <pipealloc>
    return -1;
    80005cfe:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d00:	0c054563          	bltz	a0,80005dca <sys_pipe+0x104>
  fd0 = -1;
    80005d04:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d08:	fd043503          	ld	a0,-48(s0)
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	500080e7          	jalr	1280(ra) # 8000520c <fdalloc>
    80005d14:	fca42223          	sw	a0,-60(s0)
    80005d18:	08054c63          	bltz	a0,80005db0 <sys_pipe+0xea>
    80005d1c:	fc843503          	ld	a0,-56(s0)
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	4ec080e7          	jalr	1260(ra) # 8000520c <fdalloc>
    80005d28:	fca42023          	sw	a0,-64(s0)
    80005d2c:	06054863          	bltz	a0,80005d9c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d30:	4691                	li	a3,4
    80005d32:	fc440613          	addi	a2,s0,-60
    80005d36:	fd843583          	ld	a1,-40(s0)
    80005d3a:	6ca8                	ld	a0,88(s1)
    80005d3c:	ffffc097          	auipc	ra,0xffffc
    80005d40:	ae6080e7          	jalr	-1306(ra) # 80001822 <copyout>
    80005d44:	02054063          	bltz	a0,80005d64 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d48:	4691                	li	a3,4
    80005d4a:	fc040613          	addi	a2,s0,-64
    80005d4e:	fd843583          	ld	a1,-40(s0)
    80005d52:	0591                	addi	a1,a1,4
    80005d54:	6ca8                	ld	a0,88(s1)
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	acc080e7          	jalr	-1332(ra) # 80001822 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d5e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d60:	06055563          	bgez	a0,80005dca <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d64:	fc442783          	lw	a5,-60(s0)
    80005d68:	07e9                	addi	a5,a5,26
    80005d6a:	078e                	slli	a5,a5,0x3
    80005d6c:	97a6                	add	a5,a5,s1
    80005d6e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005d72:	fc042503          	lw	a0,-64(s0)
    80005d76:	0569                	addi	a0,a0,26
    80005d78:	050e                	slli	a0,a0,0x3
    80005d7a:	9526                	add	a0,a0,s1
    80005d7c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005d80:	fd043503          	ld	a0,-48(s0)
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	a2e080e7          	jalr	-1490(ra) # 800047b2 <fileclose>
    fileclose(wf);
    80005d8c:	fc843503          	ld	a0,-56(s0)
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	a22080e7          	jalr	-1502(ra) # 800047b2 <fileclose>
    return -1;
    80005d98:	57fd                	li	a5,-1
    80005d9a:	a805                	j	80005dca <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d9c:	fc442783          	lw	a5,-60(s0)
    80005da0:	0007c863          	bltz	a5,80005db0 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005da4:	01a78513          	addi	a0,a5,26
    80005da8:	050e                	slli	a0,a0,0x3
    80005daa:	9526                	add	a0,a0,s1
    80005dac:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005db0:	fd043503          	ld	a0,-48(s0)
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	9fe080e7          	jalr	-1538(ra) # 800047b2 <fileclose>
    fileclose(wf);
    80005dbc:	fc843503          	ld	a0,-56(s0)
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	9f2080e7          	jalr	-1550(ra) # 800047b2 <fileclose>
    return -1;
    80005dc8:	57fd                	li	a5,-1
}
    80005dca:	853e                	mv	a0,a5
    80005dcc:	70e2                	ld	ra,56(sp)
    80005dce:	7442                	ld	s0,48(sp)
    80005dd0:	74a2                	ld	s1,40(sp)
    80005dd2:	6121                	addi	sp,sp,64
    80005dd4:	8082                	ret
	...

0000000080005de0 <kernelvec>:
    80005de0:	7111                	addi	sp,sp,-256
    80005de2:	e006                	sd	ra,0(sp)
    80005de4:	e40a                	sd	sp,8(sp)
    80005de6:	e80e                	sd	gp,16(sp)
    80005de8:	ec12                	sd	tp,24(sp)
    80005dea:	f016                	sd	t0,32(sp)
    80005dec:	f41a                	sd	t1,40(sp)
    80005dee:	f81e                	sd	t2,48(sp)
    80005df0:	fc22                	sd	s0,56(sp)
    80005df2:	e0a6                	sd	s1,64(sp)
    80005df4:	e4aa                	sd	a0,72(sp)
    80005df6:	e8ae                	sd	a1,80(sp)
    80005df8:	ecb2                	sd	a2,88(sp)
    80005dfa:	f0b6                	sd	a3,96(sp)
    80005dfc:	f4ba                	sd	a4,104(sp)
    80005dfe:	f8be                	sd	a5,112(sp)
    80005e00:	fcc2                	sd	a6,120(sp)
    80005e02:	e146                	sd	a7,128(sp)
    80005e04:	e54a                	sd	s2,136(sp)
    80005e06:	e94e                	sd	s3,144(sp)
    80005e08:	ed52                	sd	s4,152(sp)
    80005e0a:	f156                	sd	s5,160(sp)
    80005e0c:	f55a                	sd	s6,168(sp)
    80005e0e:	f95e                	sd	s7,176(sp)
    80005e10:	fd62                	sd	s8,184(sp)
    80005e12:	e1e6                	sd	s9,192(sp)
    80005e14:	e5ea                	sd	s10,200(sp)
    80005e16:	e9ee                	sd	s11,208(sp)
    80005e18:	edf2                	sd	t3,216(sp)
    80005e1a:	f1f6                	sd	t4,224(sp)
    80005e1c:	f5fa                	sd	t5,232(sp)
    80005e1e:	f9fe                	sd	t6,240(sp)
    80005e20:	dbbfc0ef          	jal	ra,80002bda <kerneltrap>
    80005e24:	6082                	ld	ra,0(sp)
    80005e26:	6122                	ld	sp,8(sp)
    80005e28:	61c2                	ld	gp,16(sp)
    80005e2a:	7282                	ld	t0,32(sp)
    80005e2c:	7322                	ld	t1,40(sp)
    80005e2e:	73c2                	ld	t2,48(sp)
    80005e30:	7462                	ld	s0,56(sp)
    80005e32:	6486                	ld	s1,64(sp)
    80005e34:	6526                	ld	a0,72(sp)
    80005e36:	65c6                	ld	a1,80(sp)
    80005e38:	6666                	ld	a2,88(sp)
    80005e3a:	7686                	ld	a3,96(sp)
    80005e3c:	7726                	ld	a4,104(sp)
    80005e3e:	77c6                	ld	a5,112(sp)
    80005e40:	7866                	ld	a6,120(sp)
    80005e42:	688a                	ld	a7,128(sp)
    80005e44:	692a                	ld	s2,136(sp)
    80005e46:	69ca                	ld	s3,144(sp)
    80005e48:	6a6a                	ld	s4,152(sp)
    80005e4a:	7a8a                	ld	s5,160(sp)
    80005e4c:	7b2a                	ld	s6,168(sp)
    80005e4e:	7bca                	ld	s7,176(sp)
    80005e50:	7c6a                	ld	s8,184(sp)
    80005e52:	6c8e                	ld	s9,192(sp)
    80005e54:	6d2e                	ld	s10,200(sp)
    80005e56:	6dce                	ld	s11,208(sp)
    80005e58:	6e6e                	ld	t3,216(sp)
    80005e5a:	7e8e                	ld	t4,224(sp)
    80005e5c:	7f2e                	ld	t5,232(sp)
    80005e5e:	7fce                	ld	t6,240(sp)
    80005e60:	6111                	addi	sp,sp,256
    80005e62:	10200073          	sret
    80005e66:	00000013          	nop
    80005e6a:	00000013          	nop
    80005e6e:	0001                	nop

0000000080005e70 <timervec>:
    80005e70:	34051573          	csrrw	a0,mscratch,a0
    80005e74:	e10c                	sd	a1,0(a0)
    80005e76:	e510                	sd	a2,8(a0)
    80005e78:	e914                	sd	a3,16(a0)
    80005e7a:	6d0c                	ld	a1,24(a0)
    80005e7c:	7110                	ld	a2,32(a0)
    80005e7e:	6194                	ld	a3,0(a1)
    80005e80:	96b2                	add	a3,a3,a2
    80005e82:	e194                	sd	a3,0(a1)
    80005e84:	4589                	li	a1,2
    80005e86:	14459073          	csrw	sip,a1
    80005e8a:	6914                	ld	a3,16(a0)
    80005e8c:	6510                	ld	a2,8(a0)
    80005e8e:	610c                	ld	a1,0(a0)
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	30200073          	mret
	...

0000000080005e9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e9a:	1141                	addi	sp,sp,-16
    80005e9c:	e422                	sd	s0,8(sp)
    80005e9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ea0:	0c0007b7          	lui	a5,0xc000
    80005ea4:	4705                	li	a4,1
    80005ea6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ea8:	c3d8                	sw	a4,4(a5)
}
    80005eaa:	6422                	ld	s0,8(sp)
    80005eac:	0141                	addi	sp,sp,16
    80005eae:	8082                	ret

0000000080005eb0 <plicinithart>:

void
plicinithart(void)
{
    80005eb0:	1141                	addi	sp,sp,-16
    80005eb2:	e406                	sd	ra,8(sp)
    80005eb4:	e022                	sd	s0,0(sp)
    80005eb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005eb8:	ffffc097          	auipc	ra,0xffffc
    80005ebc:	cba080e7          	jalr	-838(ra) # 80001b72 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ec0:	0085171b          	slliw	a4,a0,0x8
    80005ec4:	0c0027b7          	lui	a5,0xc002
    80005ec8:	97ba                	add	a5,a5,a4
    80005eca:	40200713          	li	a4,1026
    80005ece:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ed2:	00d5151b          	slliw	a0,a0,0xd
    80005ed6:	0c2017b7          	lui	a5,0xc201
    80005eda:	953e                	add	a0,a0,a5
    80005edc:	00052023          	sw	zero,0(a0)
}
    80005ee0:	60a2                	ld	ra,8(sp)
    80005ee2:	6402                	ld	s0,0(sp)
    80005ee4:	0141                	addi	sp,sp,16
    80005ee6:	8082                	ret

0000000080005ee8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ee8:	1141                	addi	sp,sp,-16
    80005eea:	e406                	sd	ra,8(sp)
    80005eec:	e022                	sd	s0,0(sp)
    80005eee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ef0:	ffffc097          	auipc	ra,0xffffc
    80005ef4:	c82080e7          	jalr	-894(ra) # 80001b72 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ef8:	00d5179b          	slliw	a5,a0,0xd
    80005efc:	0c201537          	lui	a0,0xc201
    80005f00:	953e                	add	a0,a0,a5
  return irq;
}
    80005f02:	4148                	lw	a0,4(a0)
    80005f04:	60a2                	ld	ra,8(sp)
    80005f06:	6402                	ld	s0,0(sp)
    80005f08:	0141                	addi	sp,sp,16
    80005f0a:	8082                	ret

0000000080005f0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f0c:	1101                	addi	sp,sp,-32
    80005f0e:	ec06                	sd	ra,24(sp)
    80005f10:	e822                	sd	s0,16(sp)
    80005f12:	e426                	sd	s1,8(sp)
    80005f14:	1000                	addi	s0,sp,32
    80005f16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f18:	ffffc097          	auipc	ra,0xffffc
    80005f1c:	c5a080e7          	jalr	-934(ra) # 80001b72 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f20:	00d5151b          	slliw	a0,a0,0xd
    80005f24:	0c2017b7          	lui	a5,0xc201
    80005f28:	97aa                	add	a5,a5,a0
    80005f2a:	c3c4                	sw	s1,4(a5)
}
    80005f2c:	60e2                	ld	ra,24(sp)
    80005f2e:	6442                	ld	s0,16(sp)
    80005f30:	64a2                	ld	s1,8(sp)
    80005f32:	6105                	addi	sp,sp,32
    80005f34:	8082                	ret

0000000080005f36 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f36:	1141                	addi	sp,sp,-16
    80005f38:	e406                	sd	ra,8(sp)
    80005f3a:	e022                	sd	s0,0(sp)
    80005f3c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f3e:	479d                	li	a5,7
    80005f40:	04a7c463          	blt	a5,a0,80005f88 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f44:	00031797          	auipc	a5,0x31
    80005f48:	34478793          	addi	a5,a5,836 # 80037288 <disk>
    80005f4c:	97aa                	add	a5,a5,a0
    80005f4e:	0187c783          	lbu	a5,24(a5)
    80005f52:	e3b9                	bnez	a5,80005f98 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f54:	00031797          	auipc	a5,0x31
    80005f58:	33478793          	addi	a5,a5,820 # 80037288 <disk>
    80005f5c:	6398                	ld	a4,0(a5)
    80005f5e:	00451693          	slli	a3,a0,0x4
    80005f62:	9736                	add	a4,a4,a3
    80005f64:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005f68:	953e                	add	a0,a0,a5
    80005f6a:	4785                	li	a5,1
    80005f6c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f70:	00031517          	auipc	a0,0x31
    80005f74:	33050513          	addi	a0,a0,816 # 800372a0 <disk+0x18>
    80005f78:	ffffc097          	auipc	ra,0xffffc
    80005f7c:	57a080e7          	jalr	1402(ra) # 800024f2 <wakeup>
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f88:	00004517          	auipc	a0,0x4
    80005f8c:	d8850513          	addi	a0,a0,-632 # 80009d10 <syscalls+0x330>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5da080e7          	jalr	1498(ra) # 8000056a <panic>
    panic("virtio_disk_intr 2");
    80005f98:	00004517          	auipc	a0,0x4
    80005f9c:	d9050513          	addi	a0,a0,-624 # 80009d28 <syscalls+0x348>
    80005fa0:	ffffa097          	auipc	ra,0xffffa
    80005fa4:	5ca080e7          	jalr	1482(ra) # 8000056a <panic>

0000000080005fa8 <virtio_disk_init>:
{
    80005fa8:	1101                	addi	sp,sp,-32
    80005faa:	ec06                	sd	ra,24(sp)
    80005fac:	e822                	sd	s0,16(sp)
    80005fae:	e426                	sd	s1,8(sp)
    80005fb0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fb2:	00031497          	auipc	s1,0x31
    80005fb6:	2d648493          	addi	s1,s1,726 # 80037288 <disk>
    80005fba:	00004597          	auipc	a1,0x4
    80005fbe:	d8658593          	addi	a1,a1,-634 # 80009d40 <syscalls+0x360>
    80005fc2:	00031517          	auipc	a0,0x31
    80005fc6:	3ee50513          	addi	a0,a0,1006 # 800373b0 <disk+0x128>
    80005fca:	ffffb097          	auipc	ra,0xffffb
    80005fce:	afc080e7          	jalr	-1284(ra) # 80000ac6 <initlock>
  disk.desc = kalloc();
    80005fd2:	ffffb097          	auipc	ra,0xffffb
    80005fd6:	a7a080e7          	jalr	-1414(ra) # 80000a4c <kalloc>
    80005fda:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fdc:	ffffb097          	auipc	ra,0xffffb
    80005fe0:	a70080e7          	jalr	-1424(ra) # 80000a4c <kalloc>
    80005fe4:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fe6:	ffffb097          	auipc	ra,0xffffb
    80005fea:	a66080e7          	jalr	-1434(ra) # 80000a4c <kalloc>
    80005fee:	87aa                	mv	a5,a0
    80005ff0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ff2:	6088                	ld	a0,0(s1)
    80005ff4:	14050263          	beqz	a0,80006138 <virtio_disk_init+0x190>
    80005ff8:	00031717          	auipc	a4,0x31
    80005ffc:	29873703          	ld	a4,664(a4) # 80037290 <disk+0x8>
    80006000:	12070c63          	beqz	a4,80006138 <virtio_disk_init+0x190>
    80006004:	12078a63          	beqz	a5,80006138 <virtio_disk_init+0x190>
  memset(disk.desc, 0, PGSIZE);
    80006008:	6605                	lui	a2,0x1
    8000600a:	4581                	li	a1,0
    8000600c:	ffffb097          	auipc	ra,0xffffb
    80006010:	e74080e7          	jalr	-396(ra) # 80000e80 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006014:	00031497          	auipc	s1,0x31
    80006018:	27448493          	addi	s1,s1,628 # 80037288 <disk>
    8000601c:	6605                	lui	a2,0x1
    8000601e:	4581                	li	a1,0
    80006020:	6488                	ld	a0,8(s1)
    80006022:	ffffb097          	auipc	ra,0xffffb
    80006026:	e5e080e7          	jalr	-418(ra) # 80000e80 <memset>
  memset(disk.used, 0, PGSIZE);
    8000602a:	6605                	lui	a2,0x1
    8000602c:	4581                	li	a1,0
    8000602e:	6888                	ld	a0,16(s1)
    80006030:	ffffb097          	auipc	ra,0xffffb
    80006034:	e50080e7          	jalr	-432(ra) # 80000e80 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006038:	100017b7          	lui	a5,0x10001
    8000603c:	4398                	lw	a4,0(a5)
    8000603e:	2701                	sext.w	a4,a4
    80006040:	747277b7          	lui	a5,0x74727
    80006044:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006048:	10f71063          	bne	a4,a5,80006148 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000604c:	100017b7          	lui	a5,0x10001
    80006050:	43dc                	lw	a5,4(a5)
    80006052:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006054:	4709                	li	a4,2
    80006056:	0ee79963          	bne	a5,a4,80006148 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000605a:	100017b7          	lui	a5,0x10001
    8000605e:	479c                	lw	a5,8(a5)
    80006060:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006062:	0ee79363          	bne	a5,a4,80006148 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006066:	100017b7          	lui	a5,0x10001
    8000606a:	47d8                	lw	a4,12(a5)
    8000606c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000606e:	554d47b7          	lui	a5,0x554d4
    80006072:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006076:	0cf71963          	bne	a4,a5,80006148 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607a:	100017b7          	lui	a5,0x10001
    8000607e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006082:	4705                	li	a4,1
    80006084:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006086:	470d                	li	a4,3
    80006088:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000608a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000608c:	c7ffe737          	lui	a4,0xc7ffe
    80006090:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc732f>
    80006094:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006096:	2701                	sext.w	a4,a4
    80006098:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000609a:	472d                	li	a4,11
    8000609c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000609e:	5bb0                	lw	a2,112(a5)
    800060a0:	2601                	sext.w	a2,a2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800060a2:	00867793          	andi	a5,a2,8
    800060a6:	cbcd                	beqz	a5,80006158 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800060a8:	100017b7          	lui	a5,0x10001
    800060ac:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060b0:	43fc                	lw	a5,68(a5)
    800060b2:	2781                	sext.w	a5,a5
    800060b4:	ebd5                	bnez	a5,80006168 <virtio_disk_init+0x1c0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060b6:	100017b7          	lui	a5,0x10001
    800060ba:	5bdc                	lw	a5,52(a5)
    800060bc:	2781                	sext.w	a5,a5
  if(max == 0)
    800060be:	cfcd                	beqz	a5,80006178 <virtio_disk_init+0x1d0>
  if(max < NUM)
    800060c0:	471d                	li	a4,7
    800060c2:	0cf77363          	bgeu	a4,a5,80006188 <virtio_disk_init+0x1e0>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060c6:	10001737          	lui	a4,0x10001
    800060ca:	47a1                	li	a5,8
    800060cc:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    800060ce:	00031797          	auipc	a5,0x31
    800060d2:	1ba78793          	addi	a5,a5,442 # 80037288 <disk>
    800060d6:	4394                	lw	a3,0(a5)
    800060d8:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    800060dc:	43d4                	lw	a3,4(a5)
    800060de:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    800060e2:	6794                	ld	a3,8(a5)
    800060e4:	0006859b          	sext.w	a1,a3
    800060e8:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060ec:	9681                	srai	a3,a3,0x20
    800060ee:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    800060f2:	6b94                	ld	a3,16(a5)
    800060f4:	0006859b          	sext.w	a1,a3
    800060f8:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060fc:	9681                	srai	a3,a3,0x20
    800060fe:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006102:	4585                	li	a1,1
    80006104:	c36c                	sw	a1,68(a4)
    disk.free[i] = 1;
    80006106:	4685                	li	a3,1
    80006108:	00b78c23          	sb	a1,24(a5)
    8000610c:	00d78ca3          	sb	a3,25(a5)
    80006110:	00d78d23          	sb	a3,26(a5)
    80006114:	00d78da3          	sb	a3,27(a5)
    80006118:	00d78e23          	sb	a3,28(a5)
    8000611c:	00d78ea3          	sb	a3,29(a5)
    80006120:	00d78f23          	sb	a3,30(a5)
    80006124:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006128:	00466613          	ori	a2,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612c:	db30                	sw	a2,112(a4)
}
    8000612e:	60e2                	ld	ra,24(sp)
    80006130:	6442                	ld	s0,16(sp)
    80006132:	64a2                	ld	s1,8(sp)
    80006134:	6105                	addi	sp,sp,32
    80006136:	8082                	ret
    panic("virtio disk kalloc");
    80006138:	00004517          	auipc	a0,0x4
    8000613c:	c1850513          	addi	a0,a0,-1000 # 80009d50 <syscalls+0x370>
    80006140:	ffffa097          	auipc	ra,0xffffa
    80006144:	42a080e7          	jalr	1066(ra) # 8000056a <panic>
    panic("could not find virtio disk");
    80006148:	00004517          	auipc	a0,0x4
    8000614c:	c2050513          	addi	a0,a0,-992 # 80009d68 <syscalls+0x388>
    80006150:	ffffa097          	auipc	ra,0xffffa
    80006154:	41a080e7          	jalr	1050(ra) # 8000056a <panic>
    panic("virtio disk FEATURES_OK unset");
    80006158:	00004517          	auipc	a0,0x4
    8000615c:	c3050513          	addi	a0,a0,-976 # 80009d88 <syscalls+0x3a8>
    80006160:	ffffa097          	auipc	ra,0xffffa
    80006164:	40a080e7          	jalr	1034(ra) # 8000056a <panic>
    panic("virtio disk ready not zero");
    80006168:	00004517          	auipc	a0,0x4
    8000616c:	c4050513          	addi	a0,a0,-960 # 80009da8 <syscalls+0x3c8>
    80006170:	ffffa097          	auipc	ra,0xffffa
    80006174:	3fa080e7          	jalr	1018(ra) # 8000056a <panic>
    panic("virtio disk has no queue 0");
    80006178:	00004517          	auipc	a0,0x4
    8000617c:	c5050513          	addi	a0,a0,-944 # 80009dc8 <syscalls+0x3e8>
    80006180:	ffffa097          	auipc	ra,0xffffa
    80006184:	3ea080e7          	jalr	1002(ra) # 8000056a <panic>
    panic("virtio disk max queue too short");
    80006188:	00004517          	auipc	a0,0x4
    8000618c:	c6050513          	addi	a0,a0,-928 # 80009de8 <syscalls+0x408>
    80006190:	ffffa097          	auipc	ra,0xffffa
    80006194:	3da080e7          	jalr	986(ra) # 8000056a <panic>

0000000080006198 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006198:	7159                	addi	sp,sp,-112
    8000619a:	f486                	sd	ra,104(sp)
    8000619c:	f0a2                	sd	s0,96(sp)
    8000619e:	eca6                	sd	s1,88(sp)
    800061a0:	e8ca                	sd	s2,80(sp)
    800061a2:	e4ce                	sd	s3,72(sp)
    800061a4:	e0d2                	sd	s4,64(sp)
    800061a6:	fc56                	sd	s5,56(sp)
    800061a8:	f85a                	sd	s6,48(sp)
    800061aa:	f45e                	sd	s7,40(sp)
    800061ac:	f062                	sd	s8,32(sp)
    800061ae:	ec66                	sd	s9,24(sp)
    800061b0:	e86a                	sd	s10,16(sp)
    800061b2:	1880                	addi	s0,sp,112
    800061b4:	892a                	mv	s2,a0
    800061b6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061b8:	00c52c83          	lw	s9,12(a0)
    800061bc:	001c9c9b          	slliw	s9,s9,0x1
    800061c0:	1c82                	slli	s9,s9,0x20
    800061c2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800061c6:	00031517          	auipc	a0,0x31
    800061ca:	1ea50513          	addi	a0,a0,490 # 800373b0 <disk+0x128>
    800061ce:	ffffb097          	auipc	ra,0xffffb
    800061d2:	9ce080e7          	jalr	-1586(ra) # 80000b9c <acquire>
  for(int i = 0; i < 3; i++){
    800061d6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061d8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800061da:	00031b17          	auipc	s6,0x31
    800061de:	0aeb0b13          	addi	s6,s6,174 # 80037288 <disk>
  for(int i = 0; i < 3; i++){
    800061e2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800061e4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061e6:	00031c17          	auipc	s8,0x31
    800061ea:	1cac0c13          	addi	s8,s8,458 # 800373b0 <disk+0x128>
    800061ee:	a8b5                	j	8000626a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800061f0:	00fb06b3          	add	a3,s6,a5
    800061f4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800061f8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800061fa:	0207c563          	bltz	a5,80006224 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800061fe:	2485                	addiw	s1,s1,1
    80006200:	0711                	addi	a4,a4,4
    80006202:	1f548763          	beq	s1,s5,800063f0 <virtio_disk_rw+0x258>
    idx[i] = alloc_desc();
    80006206:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006208:	00031697          	auipc	a3,0x31
    8000620c:	08068693          	addi	a3,a3,128 # 80037288 <disk>
    80006210:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006212:	0186c583          	lbu	a1,24(a3)
    80006216:	fde9                	bnez	a1,800061f0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006218:	2785                	addiw	a5,a5,1
    8000621a:	0685                	addi	a3,a3,1
    8000621c:	ff779be3          	bne	a5,s7,80006212 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006220:	57fd                	li	a5,-1
    80006222:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006224:	02905a63          	blez	s1,80006258 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006228:	f9042503          	lw	a0,-112(s0)
    8000622c:	00000097          	auipc	ra,0x0
    80006230:	d0a080e7          	jalr	-758(ra) # 80005f36 <free_desc>
      for(int j = 0; j < i; j++)
    80006234:	4785                	li	a5,1
    80006236:	0297d163          	bge	a5,s1,80006258 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000623a:	f9442503          	lw	a0,-108(s0)
    8000623e:	00000097          	auipc	ra,0x0
    80006242:	cf8080e7          	jalr	-776(ra) # 80005f36 <free_desc>
      for(int j = 0; j < i; j++)
    80006246:	4789                	li	a5,2
    80006248:	0097d863          	bge	a5,s1,80006258 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000624c:	f9842503          	lw	a0,-104(s0)
    80006250:	00000097          	auipc	ra,0x0
    80006254:	ce6080e7          	jalr	-794(ra) # 80005f36 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006258:	85e2                	mv	a1,s8
    8000625a:	00031517          	auipc	a0,0x31
    8000625e:	04650513          	addi	a0,a0,70 # 800372a0 <disk+0x18>
    80006262:	ffffc097          	auipc	ra,0xffffc
    80006266:	10a080e7          	jalr	266(ra) # 8000236c <sleep>
  for(int i = 0; i < 3; i++){
    8000626a:	f9040713          	addi	a4,s0,-112
    8000626e:	84ce                	mv	s1,s3
    80006270:	bf59                	j	80006206 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006272:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006276:	00479693          	slli	a3,a5,0x4
    8000627a:	00031797          	auipc	a5,0x31
    8000627e:	00e78793          	addi	a5,a5,14 # 80037288 <disk>
    80006282:	97b6                	add	a5,a5,a3
    80006284:	4685                	li	a3,1
    80006286:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006288:	00031597          	auipc	a1,0x31
    8000628c:	00058593          	mv	a1,a1
    80006290:	00a60793          	addi	a5,a2,10
    80006294:	0792                	slli	a5,a5,0x4
    80006296:	97ae                	add	a5,a5,a1
    80006298:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000629c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062a0:	f6070693          	addi	a3,a4,-160
    800062a4:	619c                	ld	a5,0(a1)
    800062a6:	97b6                	add	a5,a5,a3
    800062a8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062aa:	6188                	ld	a0,0(a1)
    800062ac:	96aa                	add	a3,a3,a0
    800062ae:	47c1                	li	a5,16
    800062b0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    800062b2:	4785                	li	a5,1
    800062b4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062b8:	f9442783          	lw	a5,-108(s0)
    800062bc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062c0:	0792                	slli	a5,a5,0x4
    800062c2:	953e                	add	a0,a0,a5
    800062c4:	06090693          	addi	a3,s2,96
    800062c8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800062ca:	6188                	ld	a0,0(a1)
    800062cc:	97aa                	add	a5,a5,a0
    800062ce:	40000693          	li	a3,1024
    800062d2:	c794                	sw	a3,8(a5)
  if(write)
    800062d4:	0e0d0463          	beqz	s10,800063bc <virtio_disk_rw+0x224>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800062d8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    800062dc:	00c7d683          	lhu	a3,12(a5)
    800062e0:	0016e693          	ori	a3,a3,1
    800062e4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800062e8:	f9842583          	lw	a1,-104(s0)
    800062ec:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0;
    800062f0:	00031697          	auipc	a3,0x31
    800062f4:	f9868693          	addi	a3,a3,-104 # 80037288 <disk>
    800062f8:	00260793          	addi	a5,a2,2
    800062fc:	0792                	slli	a5,a5,0x4
    800062fe:	97b6                	add	a5,a5,a3
    80006300:	00078823          	sb	zero,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006304:	0592                	slli	a1,a1,0x4
    80006306:	952e                	add	a0,a0,a1
    80006308:	f9070713          	addi	a4,a4,-112
    8000630c:	9736                	add	a4,a4,a3
    8000630e:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006310:	6298                	ld	a4,0(a3)
    80006312:	972e                	add	a4,a4,a1
    80006314:	4585                	li	a1,1
    80006316:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    80006318:	4509                	li	a0,2
    8000631a:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    8000631e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006322:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006326:	0127b423          	sd	s2,8(a5)

  // avail->idx tells the device how far to look in avail->ring.
  // avail->ring[...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000632a:	6698                	ld	a4,8(a3)
    8000632c:	00275783          	lhu	a5,2(a4)
    80006330:	8b9d                	andi	a5,a5,7
    80006332:	0786                	slli	a5,a5,0x1
    80006334:	97ba                	add	a5,a5,a4
    80006336:	00c79223          	sh	a2,4(a5)
  __sync_synchronize();
    8000633a:	0ff0000f          	fence
  disk.avail->idx += 1;
    8000633e:	6698                	ld	a4,8(a3)
    80006340:	00275783          	lhu	a5,2(a4)
    80006344:	2785                	addiw	a5,a5,1
    80006346:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000634a:	100017b7          	lui	a5,0x10001
    8000634e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006352:	00492703          	lw	a4,4(s2)
    80006356:	4785                	li	a5,1
    80006358:	02f71163          	bne	a4,a5,8000637a <virtio_disk_rw+0x1e2>
    sleep(b, &disk.vdisk_lock);
    8000635c:	00031997          	auipc	s3,0x31
    80006360:	05498993          	addi	s3,s3,84 # 800373b0 <disk+0x128>
  while(b->disk == 1) {
    80006364:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006366:	85ce                	mv	a1,s3
    80006368:	854a                	mv	a0,s2
    8000636a:	ffffc097          	auipc	ra,0xffffc
    8000636e:	002080e7          	jalr	2(ra) # 8000236c <sleep>
  while(b->disk == 1) {
    80006372:	00492783          	lw	a5,4(s2)
    80006376:	fe9788e3          	beq	a5,s1,80006366 <virtio_disk_rw+0x1ce>
  }

  disk.info[idx[0]].b = 0;
    8000637a:	f9042483          	lw	s1,-112(s0)
    8000637e:	00248793          	addi	a5,s1,2
    80006382:	00479713          	slli	a4,a5,0x4
    80006386:	00031797          	auipc	a5,0x31
    8000638a:	f0278793          	addi	a5,a5,-254 # 80037288 <disk>
    8000638e:	97ba                	add	a5,a5,a4
    80006390:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    80006394:	00031917          	auipc	s2,0x31
    80006398:	ef490913          	addi	s2,s2,-268 # 80037288 <disk>
    free_desc(i);
    8000639c:	8526                	mv	a0,s1
    8000639e:	00000097          	auipc	ra,0x0
    800063a2:	b98080e7          	jalr	-1128(ra) # 80005f36 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800063a6:	0492                	slli	s1,s1,0x4
    800063a8:	00093783          	ld	a5,0(s2)
    800063ac:	94be                	add	s1,s1,a5
    800063ae:	00c4d783          	lhu	a5,12(s1)
    800063b2:	8b85                	andi	a5,a5,1
    800063b4:	cb81                	beqz	a5,800063c4 <virtio_disk_rw+0x22c>
      i = disk.desc[i].next;
    800063b6:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800063ba:	b7cd                	j	8000639c <virtio_disk_rw+0x204>
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    800063bc:	4689                	li	a3,2
    800063be:	00d79623          	sh	a3,12(a5)
    800063c2:	bf29                	j	800062dc <virtio_disk_rw+0x144>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063c4:	00031517          	auipc	a0,0x31
    800063c8:	fec50513          	addi	a0,a0,-20 # 800373b0 <disk+0x128>
    800063cc:	ffffb097          	auipc	ra,0xffffb
    800063d0:	8a0080e7          	jalr	-1888(ra) # 80000c6c <release>
}
    800063d4:	70a6                	ld	ra,104(sp)
    800063d6:	7406                	ld	s0,96(sp)
    800063d8:	64e6                	ld	s1,88(sp)
    800063da:	6946                	ld	s2,80(sp)
    800063dc:	69a6                	ld	s3,72(sp)
    800063de:	6a06                	ld	s4,64(sp)
    800063e0:	7ae2                	ld	s5,56(sp)
    800063e2:	7b42                	ld	s6,48(sp)
    800063e4:	7ba2                	ld	s7,40(sp)
    800063e6:	7c02                	ld	s8,32(sp)
    800063e8:	6ce2                	ld	s9,24(sp)
    800063ea:	6d42                	ld	s10,16(sp)
    800063ec:	6165                	addi	sp,sp,112
    800063ee:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063f0:	f9042603          	lw	a2,-112(s0)
    800063f4:	00a60713          	addi	a4,a2,10
    800063f8:	0712                	slli	a4,a4,0x4
    800063fa:	00031517          	auipc	a0,0x31
    800063fe:	e9650513          	addi	a0,a0,-362 # 80037290 <disk+0x8>
    80006402:	953a                	add	a0,a0,a4
  if(write)
    80006404:	e60d17e3          	bnez	s10,80006272 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006408:	00a60793          	addi	a5,a2,10
    8000640c:	00479693          	slli	a3,a5,0x4
    80006410:	00031797          	auipc	a5,0x31
    80006414:	e7878793          	addi	a5,a5,-392 # 80037288 <disk>
    80006418:	97b6                	add	a5,a5,a3
    8000641a:	0007a423          	sw	zero,8(a5)
    8000641e:	b5ad                	j	80006288 <virtio_disk_rw+0xf0>

0000000080006420 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    80006420:	1101                	addi	sp,sp,-32
    80006422:	ec06                	sd	ra,24(sp)
    80006424:	e822                	sd	s0,16(sp)
    80006426:	e426                	sd	s1,8(sp)
    80006428:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000642a:	00031497          	auipc	s1,0x31
    8000642e:	e5e48493          	addi	s1,s1,-418 # 80037288 <disk>
    80006432:	00031517          	auipc	a0,0x31
    80006436:	f7e50513          	addi	a0,a0,-130 # 800373b0 <disk+0x128>
    8000643a:	ffffa097          	auipc	ra,0xffffa
    8000643e:	762080e7          	jalr	1890(ra) # 80000b9c <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006442:	0204d783          	lhu	a5,32(s1)
    80006446:	6898                	ld	a4,16(s1)
    80006448:	00275683          	lhu	a3,2(a4)
    8000644c:	8ebd                	xor	a3,a3,a5
    8000644e:	8a9d                	andi	a3,a3,7
    80006450:	c2b1                	beqz	a3,80006494 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    80006452:	078e                	slli	a5,a5,0x3
    80006454:	97ba                	add	a5,a5,a4
    80006456:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006458:	00278713          	addi	a4,a5,2
    8000645c:	0712                	slli	a4,a4,0x4
    8000645e:	9726                	add	a4,a4,s1
    80006460:	01074703          	lbu	a4,16(a4)
    80006464:	eb31                	bnez	a4,800064b8 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    80006466:	0789                	addi	a5,a5,2
    80006468:	0792                	slli	a5,a5,0x4
    8000646a:	97a6                	add	a5,a5,s1
    8000646c:	6798                	ld	a4,8(a5)
    8000646e:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006472:	6788                	ld	a0,8(a5)
    80006474:	ffffc097          	auipc	ra,0xffffc
    80006478:	07e080e7          	jalr	126(ra) # 800024f2 <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    8000647c:	0204d783          	lhu	a5,32(s1)
    80006480:	2785                	addiw	a5,a5,1
    80006482:	8b9d                	andi	a5,a5,7
    80006484:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006488:	6898                	ld	a4,16(s1)
    8000648a:	00275683          	lhu	a3,2(a4)
    8000648e:	8a9d                	andi	a3,a3,7
    80006490:	fcf691e3          	bne	a3,a5,80006452 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006494:	10001737          	lui	a4,0x10001
    80006498:	533c                	lw	a5,96(a4)
    8000649a:	8b8d                	andi	a5,a5,3
    8000649c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000649e:	00031517          	auipc	a0,0x31
    800064a2:	f1250513          	addi	a0,a0,-238 # 800373b0 <disk+0x128>
    800064a6:	ffffa097          	auipc	ra,0xffffa
    800064aa:	7c6080e7          	jalr	1990(ra) # 80000c6c <release>
}
    800064ae:	60e2                	ld	ra,24(sp)
    800064b0:	6442                	ld	s0,16(sp)
    800064b2:	64a2                	ld	s1,8(sp)
    800064b4:	6105                	addi	sp,sp,32
    800064b6:	8082                	ret
      panic("virtio_disk_intr status");
    800064b8:	00004517          	auipc	a0,0x4
    800064bc:	95050513          	addi	a0,a0,-1712 # 80009e08 <syscalls+0x428>
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	0aa080e7          	jalr	170(ra) # 8000056a <panic>

00000000800064c8 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800064c8:	1141                	addi	sp,sp,-16
    800064ca:	e422                	sd	s0,8(sp)
    800064cc:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800064ce:	41f5d79b          	sraiw	a5,a1,0x1f
    800064d2:	01d7d79b          	srliw	a5,a5,0x1d
    800064d6:	9dbd                	addw	a1,a1,a5
    800064d8:	0075f713          	andi	a4,a1,7
    800064dc:	9f1d                	subw	a4,a4,a5
    800064de:	4785                	li	a5,1
    800064e0:	00e797bb          	sllw	a5,a5,a4
    800064e4:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800064e8:	4035d59b          	sraiw	a1,a1,0x3
    800064ec:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800064ee:	0005c503          	lbu	a0,0(a1) # 80037288 <disk>
    800064f2:	8d7d                	and	a0,a0,a5
    800064f4:	8d1d                	sub	a0,a0,a5
}
    800064f6:	00153513          	seqz	a0,a0
    800064fa:	6422                	ld	s0,8(sp)
    800064fc:	0141                	addi	sp,sp,16
    800064fe:	8082                	ret

0000000080006500 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006500:	1141                	addi	sp,sp,-16
    80006502:	e422                	sd	s0,8(sp)
    80006504:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006506:	41f5d79b          	sraiw	a5,a1,0x1f
    8000650a:	01d7d79b          	srliw	a5,a5,0x1d
    8000650e:	9dbd                	addw	a1,a1,a5
    80006510:	4035d71b          	sraiw	a4,a1,0x3
    80006514:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006516:	899d                	andi	a1,a1,7
    80006518:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    8000651a:	4785                	li	a5,1
    8000651c:	00b795bb          	sllw	a1,a5,a1
    80006520:	00054783          	lbu	a5,0(a0)
    80006524:	8ddd                	or	a1,a1,a5
    80006526:	00b50023          	sb	a1,0(a0)
}
    8000652a:	6422                	ld	s0,8(sp)
    8000652c:	0141                	addi	sp,sp,16
    8000652e:	8082                	ret

0000000080006530 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006530:	1141                	addi	sp,sp,-16
    80006532:	e422                	sd	s0,8(sp)
    80006534:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006536:	41f5d79b          	sraiw	a5,a1,0x1f
    8000653a:	01d7d79b          	srliw	a5,a5,0x1d
    8000653e:	9dbd                	addw	a1,a1,a5
    80006540:	4035d71b          	sraiw	a4,a1,0x3
    80006544:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006546:	899d                	andi	a1,a1,7
    80006548:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    8000654a:	4785                	li	a5,1
    8000654c:	00b795bb          	sllw	a1,a5,a1
    80006550:	fff5c593          	not	a1,a1
    80006554:	00054783          	lbu	a5,0(a0)
    80006558:	8dfd                	and	a1,a1,a5
    8000655a:	00b50023          	sb	a1,0(a0)
}
    8000655e:	6422                	ld	s0,8(sp)
    80006560:	0141                	addi	sp,sp,16
    80006562:	8082                	ret

0000000080006564 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006564:	715d                	addi	sp,sp,-80
    80006566:	e486                	sd	ra,72(sp)
    80006568:	e0a2                	sd	s0,64(sp)
    8000656a:	fc26                	sd	s1,56(sp)
    8000656c:	f84a                	sd	s2,48(sp)
    8000656e:	f44e                	sd	s3,40(sp)
    80006570:	f052                	sd	s4,32(sp)
    80006572:	ec56                	sd	s5,24(sp)
    80006574:	e85a                	sd	s6,16(sp)
    80006576:	e45e                	sd	s7,8(sp)
    80006578:	0880                	addi	s0,sp,80
    8000657a:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    8000657c:	08b05b63          	blez	a1,80006612 <bd_print_vector+0xae>
    80006580:	89aa                	mv	s3,a0
    80006582:	4481                	li	s1,0
  lb = 0;
    80006584:	4a81                	li	s5,0
  last = 1;
    80006586:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006588:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000658a:	00004b97          	auipc	s7,0x4
    8000658e:	896b8b93          	addi	s7,s7,-1898 # 80009e20 <syscalls+0x440>
    80006592:	a01d                	j	800065b8 <bd_print_vector+0x54>
    80006594:	8626                	mv	a2,s1
    80006596:	85d6                	mv	a1,s5
    80006598:	855e                	mv	a0,s7
    8000659a:	ffffa097          	auipc	ra,0xffffa
    8000659e:	032080e7          	jalr	50(ra) # 800005cc <printf>
    lb = b;
    last = bit_isset(vector, b);
    800065a2:	85a6                	mv	a1,s1
    800065a4:	854e                	mv	a0,s3
    800065a6:	00000097          	auipc	ra,0x0
    800065aa:	f22080e7          	jalr	-222(ra) # 800064c8 <bit_isset>
    800065ae:	892a                	mv	s2,a0
    800065b0:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    800065b2:	2485                	addiw	s1,s1,1
    800065b4:	009a0d63          	beq	s4,s1,800065ce <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    800065b8:	85a6                	mv	a1,s1
    800065ba:	854e                	mv	a0,s3
    800065bc:	00000097          	auipc	ra,0x0
    800065c0:	f0c080e7          	jalr	-244(ra) # 800064c8 <bit_isset>
    800065c4:	ff2507e3          	beq	a0,s2,800065b2 <bd_print_vector+0x4e>
    if(last == 1)
    800065c8:	fd691de3          	bne	s2,s6,800065a2 <bd_print_vector+0x3e>
    800065cc:	b7e1                	j	80006594 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800065ce:	000a8563          	beqz	s5,800065d8 <bd_print_vector+0x74>
    800065d2:	4785                	li	a5,1
    800065d4:	00f91c63          	bne	s2,a5,800065ec <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800065d8:	8652                	mv	a2,s4
    800065da:	85d6                	mv	a1,s5
    800065dc:	00004517          	auipc	a0,0x4
    800065e0:	84450513          	addi	a0,a0,-1980 # 80009e20 <syscalls+0x440>
    800065e4:	ffffa097          	auipc	ra,0xffffa
    800065e8:	fe8080e7          	jalr	-24(ra) # 800005cc <printf>
  }
  printf("\n");
    800065ec:	00003517          	auipc	a0,0x3
    800065f0:	c1450513          	addi	a0,a0,-1004 # 80009200 <digits+0x90>
    800065f4:	ffffa097          	auipc	ra,0xffffa
    800065f8:	fd8080e7          	jalr	-40(ra) # 800005cc <printf>
}
    800065fc:	60a6                	ld	ra,72(sp)
    800065fe:	6406                	ld	s0,64(sp)
    80006600:	74e2                	ld	s1,56(sp)
    80006602:	7942                	ld	s2,48(sp)
    80006604:	79a2                	ld	s3,40(sp)
    80006606:	7a02                	ld	s4,32(sp)
    80006608:	6ae2                	ld	s5,24(sp)
    8000660a:	6b42                	ld	s6,16(sp)
    8000660c:	6ba2                	ld	s7,8(sp)
    8000660e:	6161                	addi	sp,sp,80
    80006610:	8082                	ret
  lb = 0;
    80006612:	4a81                	li	s5,0
    80006614:	b7d1                	j	800065d8 <bd_print_vector+0x74>

0000000080006616 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006616:	00004697          	auipc	a3,0x4
    8000661a:	a2a6a683          	lw	a3,-1494(a3) # 8000a040 <nsizes>
    8000661e:	10d05063          	blez	a3,8000671e <bd_print+0x108>
bd_print() {
    80006622:	711d                	addi	sp,sp,-96
    80006624:	ec86                	sd	ra,88(sp)
    80006626:	e8a2                	sd	s0,80(sp)
    80006628:	e4a6                	sd	s1,72(sp)
    8000662a:	e0ca                	sd	s2,64(sp)
    8000662c:	fc4e                	sd	s3,56(sp)
    8000662e:	f852                	sd	s4,48(sp)
    80006630:	f456                	sd	s5,40(sp)
    80006632:	f05a                	sd	s6,32(sp)
    80006634:	ec5e                	sd	s7,24(sp)
    80006636:	e862                	sd	s8,16(sp)
    80006638:	e466                	sd	s9,8(sp)
    8000663a:	e06a                	sd	s10,0(sp)
    8000663c:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000663e:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006640:	4a85                	li	s5,1
    80006642:	4c41                	li	s8,16
    80006644:	00003b97          	auipc	s7,0x3
    80006648:	7ecb8b93          	addi	s7,s7,2028 # 80009e30 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    8000664c:	00004a17          	auipc	s4,0x4
    80006650:	9eca0a13          	addi	s4,s4,-1556 # 8000a038 <bd_sizes>
    printf("  alloc:");
    80006654:	00004b17          	auipc	s6,0x4
    80006658:	804b0b13          	addi	s6,s6,-2044 # 80009e58 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    8000665c:	00004997          	auipc	s3,0x4
    80006660:	9e498993          	addi	s3,s3,-1564 # 8000a040 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006664:	00004c97          	auipc	s9,0x4
    80006668:	804c8c93          	addi	s9,s9,-2044 # 80009e68 <syscalls+0x488>
    8000666c:	a801                	j	8000667c <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000666e:	0009a683          	lw	a3,0(s3)
    80006672:	0485                	addi	s1,s1,1
    80006674:	0004879b          	sext.w	a5,s1
    80006678:	08d7d563          	bge	a5,a3,80006702 <bd_print+0xec>
    8000667c:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006680:	36fd                	addiw	a3,a3,-1
    80006682:	9e85                	subw	a3,a3,s1
    80006684:	00da96bb          	sllw	a3,s5,a3
    80006688:	009c1633          	sll	a2,s8,s1
    8000668c:	85ca                	mv	a1,s2
    8000668e:	855e                	mv	a0,s7
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	f3c080e7          	jalr	-196(ra) # 800005cc <printf>
    lst_print(&bd_sizes[k].free);
    80006698:	00549d13          	slli	s10,s1,0x5
    8000669c:	000a3503          	ld	a0,0(s4)
    800066a0:	956a                	add	a0,a0,s10
    800066a2:	00001097          	auipc	ra,0x1
    800066a6:	a4e080e7          	jalr	-1458(ra) # 800070f0 <lst_print>
    printf("  alloc:");
    800066aa:	855a                	mv	a0,s6
    800066ac:	ffffa097          	auipc	ra,0xffffa
    800066b0:	f20080e7          	jalr	-224(ra) # 800005cc <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800066b4:	0009a583          	lw	a1,0(s3)
    800066b8:	35fd                	addiw	a1,a1,-1
    800066ba:	412585bb          	subw	a1,a1,s2
    800066be:	000a3783          	ld	a5,0(s4)
    800066c2:	97ea                	add	a5,a5,s10
    800066c4:	00ba95bb          	sllw	a1,s5,a1
    800066c8:	6b88                	ld	a0,16(a5)
    800066ca:	00000097          	auipc	ra,0x0
    800066ce:	e9a080e7          	jalr	-358(ra) # 80006564 <bd_print_vector>
    if(k > 0) {
    800066d2:	f9205ee3          	blez	s2,8000666e <bd_print+0x58>
      printf("  split:");
    800066d6:	8566                	mv	a0,s9
    800066d8:	ffffa097          	auipc	ra,0xffffa
    800066dc:	ef4080e7          	jalr	-268(ra) # 800005cc <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800066e0:	0009a583          	lw	a1,0(s3)
    800066e4:	35fd                	addiw	a1,a1,-1
    800066e6:	412585bb          	subw	a1,a1,s2
    800066ea:	000a3783          	ld	a5,0(s4)
    800066ee:	9d3e                	add	s10,s10,a5
    800066f0:	00ba95bb          	sllw	a1,s5,a1
    800066f4:	018d3503          	ld	a0,24(s10)
    800066f8:	00000097          	auipc	ra,0x0
    800066fc:	e6c080e7          	jalr	-404(ra) # 80006564 <bd_print_vector>
    80006700:	b7bd                	j	8000666e <bd_print+0x58>
    }
  }
}
    80006702:	60e6                	ld	ra,88(sp)
    80006704:	6446                	ld	s0,80(sp)
    80006706:	64a6                	ld	s1,72(sp)
    80006708:	6906                	ld	s2,64(sp)
    8000670a:	79e2                	ld	s3,56(sp)
    8000670c:	7a42                	ld	s4,48(sp)
    8000670e:	7aa2                	ld	s5,40(sp)
    80006710:	7b02                	ld	s6,32(sp)
    80006712:	6be2                	ld	s7,24(sp)
    80006714:	6c42                	ld	s8,16(sp)
    80006716:	6ca2                	ld	s9,8(sp)
    80006718:	6d02                	ld	s10,0(sp)
    8000671a:	6125                	addi	sp,sp,96
    8000671c:	8082                	ret
    8000671e:	8082                	ret

0000000080006720 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006720:	1141                	addi	sp,sp,-16
    80006722:	e422                	sd	s0,8(sp)
    80006724:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006726:	47c1                	li	a5,16
    80006728:	00a7fb63          	bgeu	a5,a0,8000673e <firstk+0x1e>
    8000672c:	872a                	mv	a4,a0
  int k = 0;
    8000672e:	4501                	li	a0,0
    k++;
    80006730:	2505                	addiw	a0,a0,1
    size *= 2;
    80006732:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006734:	fee7eee3          	bltu	a5,a4,80006730 <firstk+0x10>
  }
  return k;
}
    80006738:	6422                	ld	s0,8(sp)
    8000673a:	0141                	addi	sp,sp,16
    8000673c:	8082                	ret
  int k = 0;
    8000673e:	4501                	li	a0,0
    80006740:	bfe5                	j	80006738 <firstk+0x18>

0000000080006742 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006742:	1141                	addi	sp,sp,-16
    80006744:	e422                	sd	s0,8(sp)
    80006746:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006748:	00004797          	auipc	a5,0x4
    8000674c:	8e87b783          	ld	a5,-1816(a5) # 8000a030 <bd_base>
    80006750:	9d9d                	subw	a1,a1,a5
    80006752:	47c1                	li	a5,16
    80006754:	00a79533          	sll	a0,a5,a0
    80006758:	02a5c533          	div	a0,a1,a0
}
    8000675c:	2501                	sext.w	a0,a0
    8000675e:	6422                	ld	s0,8(sp)
    80006760:	0141                	addi	sp,sp,16
    80006762:	8082                	ret

0000000080006764 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006764:	1141                	addi	sp,sp,-16
    80006766:	e422                	sd	s0,8(sp)
    80006768:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000676a:	47c1                	li	a5,16
    8000676c:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006770:	02b787bb          	mulw	a5,a5,a1
}
    80006774:	00004517          	auipc	a0,0x4
    80006778:	8bc53503          	ld	a0,-1860(a0) # 8000a030 <bd_base>
    8000677c:	953e                	add	a0,a0,a5
    8000677e:	6422                	ld	s0,8(sp)
    80006780:	0141                	addi	sp,sp,16
    80006782:	8082                	ret

0000000080006784 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006784:	7159                	addi	sp,sp,-112
    80006786:	f486                	sd	ra,104(sp)
    80006788:	f0a2                	sd	s0,96(sp)
    8000678a:	eca6                	sd	s1,88(sp)
    8000678c:	e8ca                	sd	s2,80(sp)
    8000678e:	e4ce                	sd	s3,72(sp)
    80006790:	e0d2                	sd	s4,64(sp)
    80006792:	fc56                	sd	s5,56(sp)
    80006794:	f85a                	sd	s6,48(sp)
    80006796:	f45e                	sd	s7,40(sp)
    80006798:	f062                	sd	s8,32(sp)
    8000679a:	ec66                	sd	s9,24(sp)
    8000679c:	e86a                	sd	s10,16(sp)
    8000679e:	e46e                	sd	s11,8(sp)
    800067a0:	1880                	addi	s0,sp,112
    800067a2:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800067a4:	00031517          	auipc	a0,0x31
    800067a8:	c2c50513          	addi	a0,a0,-980 # 800373d0 <lock>
    800067ac:	ffffa097          	auipc	ra,0xffffa
    800067b0:	3f0080e7          	jalr	1008(ra) # 80000b9c <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800067b4:	8526                	mv	a0,s1
    800067b6:	00000097          	auipc	ra,0x0
    800067ba:	f6a080e7          	jalr	-150(ra) # 80006720 <firstk>
  for (k = fk; k < nsizes; k++) {
    800067be:	00004797          	auipc	a5,0x4
    800067c2:	8827a783          	lw	a5,-1918(a5) # 8000a040 <nsizes>
    800067c6:	02f55d63          	bge	a0,a5,80006800 <bd_malloc+0x7c>
    800067ca:	8c2a                	mv	s8,a0
    800067cc:	00551913          	slli	s2,a0,0x5
    800067d0:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800067d2:	00004997          	auipc	s3,0x4
    800067d6:	86698993          	addi	s3,s3,-1946 # 8000a038 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800067da:	00004a17          	auipc	s4,0x4
    800067de:	866a0a13          	addi	s4,s4,-1946 # 8000a040 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800067e2:	0009b503          	ld	a0,0(s3)
    800067e6:	954a                	add	a0,a0,s2
    800067e8:	00001097          	auipc	ra,0x1
    800067ec:	88e080e7          	jalr	-1906(ra) # 80007076 <lst_empty>
    800067f0:	c115                	beqz	a0,80006814 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800067f2:	2485                	addiw	s1,s1,1
    800067f4:	02090913          	addi	s2,s2,32
    800067f8:	000a2783          	lw	a5,0(s4)
    800067fc:	fef4c3e3          	blt	s1,a5,800067e2 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006800:	00031517          	auipc	a0,0x31
    80006804:	bd050513          	addi	a0,a0,-1072 # 800373d0 <lock>
    80006808:	ffffa097          	auipc	ra,0xffffa
    8000680c:	464080e7          	jalr	1124(ra) # 80000c6c <release>
    return 0;
    80006810:	4b01                	li	s6,0
    80006812:	a0e1                	j	800068da <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006814:	00004797          	auipc	a5,0x4
    80006818:	82c7a783          	lw	a5,-2004(a5) # 8000a040 <nsizes>
    8000681c:	fef4d2e3          	bge	s1,a5,80006800 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006820:	00549993          	slli	s3,s1,0x5
    80006824:	00004917          	auipc	s2,0x4
    80006828:	81490913          	addi	s2,s2,-2028 # 8000a038 <bd_sizes>
    8000682c:	00093503          	ld	a0,0(s2)
    80006830:	954e                	add	a0,a0,s3
    80006832:	00001097          	auipc	ra,0x1
    80006836:	870080e7          	jalr	-1936(ra) # 800070a2 <lst_pop>
    8000683a:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    8000683c:	00003597          	auipc	a1,0x3
    80006840:	7f45b583          	ld	a1,2036(a1) # 8000a030 <bd_base>
    80006844:	40b505bb          	subw	a1,a0,a1
    80006848:	47c1                	li	a5,16
    8000684a:	009797b3          	sll	a5,a5,s1
    8000684e:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006852:	00093783          	ld	a5,0(s2)
    80006856:	97ce                	add	a5,a5,s3
    80006858:	2581                	sext.w	a1,a1
    8000685a:	6b88                	ld	a0,16(a5)
    8000685c:	00000097          	auipc	ra,0x0
    80006860:	ca4080e7          	jalr	-860(ra) # 80006500 <bit_set>
  for(; k > fk; k--) {
    80006864:	069c5363          	bge	s8,s1,800068ca <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006868:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000686a:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    8000686c:	00003d17          	auipc	s10,0x3
    80006870:	7c4d0d13          	addi	s10,s10,1988 # 8000a030 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006874:	85a6                	mv	a1,s1
    80006876:	34fd                	addiw	s1,s1,-1
    80006878:	009b9ab3          	sll	s5,s7,s1
    8000687c:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006880:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006884:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006888:	412b093b          	subw	s2,s6,s2
    8000688c:	00bb95b3          	sll	a1,s7,a1
    80006890:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006894:	013a07b3          	add	a5,s4,s3
    80006898:	2581                	sext.w	a1,a1
    8000689a:	6f88                	ld	a0,24(a5)
    8000689c:	00000097          	auipc	ra,0x0
    800068a0:	c64080e7          	jalr	-924(ra) # 80006500 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068a4:	1981                	addi	s3,s3,-32
    800068a6:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800068a8:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068ac:	2581                	sext.w	a1,a1
    800068ae:	010a3503          	ld	a0,16(s4)
    800068b2:	00000097          	auipc	ra,0x0
    800068b6:	c4e080e7          	jalr	-946(ra) # 80006500 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    800068ba:	85e6                	mv	a1,s9
    800068bc:	8552                	mv	a0,s4
    800068be:	00001097          	auipc	ra,0x1
    800068c2:	81a080e7          	jalr	-2022(ra) # 800070d8 <lst_push>
  for(; k > fk; k--) {
    800068c6:	fb8497e3          	bne	s1,s8,80006874 <bd_malloc+0xf0>
  }
  release(&lock);
    800068ca:	00031517          	auipc	a0,0x31
    800068ce:	b0650513          	addi	a0,a0,-1274 # 800373d0 <lock>
    800068d2:	ffffa097          	auipc	ra,0xffffa
    800068d6:	39a080e7          	jalr	922(ra) # 80000c6c <release>

  return p;
}
    800068da:	855a                	mv	a0,s6
    800068dc:	70a6                	ld	ra,104(sp)
    800068de:	7406                	ld	s0,96(sp)
    800068e0:	64e6                	ld	s1,88(sp)
    800068e2:	6946                	ld	s2,80(sp)
    800068e4:	69a6                	ld	s3,72(sp)
    800068e6:	6a06                	ld	s4,64(sp)
    800068e8:	7ae2                	ld	s5,56(sp)
    800068ea:	7b42                	ld	s6,48(sp)
    800068ec:	7ba2                	ld	s7,40(sp)
    800068ee:	7c02                	ld	s8,32(sp)
    800068f0:	6ce2                	ld	s9,24(sp)
    800068f2:	6d42                	ld	s10,16(sp)
    800068f4:	6da2                	ld	s11,8(sp)
    800068f6:	6165                	addi	sp,sp,112
    800068f8:	8082                	ret

00000000800068fa <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    800068fa:	7139                	addi	sp,sp,-64
    800068fc:	fc06                	sd	ra,56(sp)
    800068fe:	f822                	sd	s0,48(sp)
    80006900:	f426                	sd	s1,40(sp)
    80006902:	f04a                	sd	s2,32(sp)
    80006904:	ec4e                	sd	s3,24(sp)
    80006906:	e852                	sd	s4,16(sp)
    80006908:	e456                	sd	s5,8(sp)
    8000690a:	e05a                	sd	s6,0(sp)
    8000690c:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    8000690e:	00003a97          	auipc	s5,0x3
    80006912:	732aaa83          	lw	s5,1842(s5) # 8000a040 <nsizes>
  return n / BLK_SIZE(k);
    80006916:	00003a17          	auipc	s4,0x3
    8000691a:	71aa3a03          	ld	s4,1818(s4) # 8000a030 <bd_base>
    8000691e:	41450a3b          	subw	s4,a0,s4
    80006922:	00003497          	auipc	s1,0x3
    80006926:	7164b483          	ld	s1,1814(s1) # 8000a038 <bd_sizes>
    8000692a:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000692e:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006930:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006932:	03595363          	bge	s2,s5,80006958 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006936:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    8000693a:	013b15b3          	sll	a1,s6,s3
    8000693e:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006942:	2581                	sext.w	a1,a1
    80006944:	6088                	ld	a0,0(s1)
    80006946:	00000097          	auipc	ra,0x0
    8000694a:	b82080e7          	jalr	-1150(ra) # 800064c8 <bit_isset>
    8000694e:	02048493          	addi	s1,s1,32
    80006952:	e501                	bnez	a0,8000695a <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006954:	894e                	mv	s2,s3
    80006956:	bff1                	j	80006932 <size+0x38>
      return k;
    }
  }
  return 0;
    80006958:	4901                	li	s2,0
}
    8000695a:	854a                	mv	a0,s2
    8000695c:	70e2                	ld	ra,56(sp)
    8000695e:	7442                	ld	s0,48(sp)
    80006960:	74a2                	ld	s1,40(sp)
    80006962:	7902                	ld	s2,32(sp)
    80006964:	69e2                	ld	s3,24(sp)
    80006966:	6a42                	ld	s4,16(sp)
    80006968:	6aa2                	ld	s5,8(sp)
    8000696a:	6b02                	ld	s6,0(sp)
    8000696c:	6121                	addi	sp,sp,64
    8000696e:	8082                	ret

0000000080006970 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006970:	7159                	addi	sp,sp,-112
    80006972:	f486                	sd	ra,104(sp)
    80006974:	f0a2                	sd	s0,96(sp)
    80006976:	eca6                	sd	s1,88(sp)
    80006978:	e8ca                	sd	s2,80(sp)
    8000697a:	e4ce                	sd	s3,72(sp)
    8000697c:	e0d2                	sd	s4,64(sp)
    8000697e:	fc56                	sd	s5,56(sp)
    80006980:	f85a                	sd	s6,48(sp)
    80006982:	f45e                	sd	s7,40(sp)
    80006984:	f062                	sd	s8,32(sp)
    80006986:	ec66                	sd	s9,24(sp)
    80006988:	e86a                	sd	s10,16(sp)
    8000698a:	e46e                	sd	s11,8(sp)
    8000698c:	1880                	addi	s0,sp,112
    8000698e:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006990:	00031517          	auipc	a0,0x31
    80006994:	a4050513          	addi	a0,a0,-1472 # 800373d0 <lock>
    80006998:	ffffa097          	auipc	ra,0xffffa
    8000699c:	204080e7          	jalr	516(ra) # 80000b9c <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800069a0:	8556                	mv	a0,s5
    800069a2:	00000097          	auipc	ra,0x0
    800069a6:	f58080e7          	jalr	-168(ra) # 800068fa <size>
    800069aa:	84aa                	mv	s1,a0
    800069ac:	00003797          	auipc	a5,0x3
    800069b0:	6947a783          	lw	a5,1684(a5) # 8000a040 <nsizes>
    800069b4:	37fd                	addiw	a5,a5,-1
    800069b6:	0af55d63          	bge	a0,a5,80006a70 <bd_free+0x100>
    800069ba:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    800069be:	00003c17          	auipc	s8,0x3
    800069c2:	672c0c13          	addi	s8,s8,1650 # 8000a030 <bd_base>
  return n / BLK_SIZE(k);
    800069c6:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800069c8:	00003b17          	auipc	s6,0x3
    800069cc:	670b0b13          	addi	s6,s6,1648 # 8000a038 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    800069d0:	00003c97          	auipc	s9,0x3
    800069d4:	670c8c93          	addi	s9,s9,1648 # 8000a040 <nsizes>
    800069d8:	a82d                	j	80006a12 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800069da:	fff58d9b          	addiw	s11,a1,-1
    800069de:	a881                	j	80006a2e <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069e0:	020a0a13          	addi	s4,s4,32
    800069e4:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    800069e6:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    800069ea:	40ba85bb          	subw	a1,s5,a1
    800069ee:	009b97b3          	sll	a5,s7,s1
    800069f2:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069f6:	000b3783          	ld	a5,0(s6)
    800069fa:	97d2                	add	a5,a5,s4
    800069fc:	2581                	sext.w	a1,a1
    800069fe:	6f88                	ld	a0,24(a5)
    80006a00:	00000097          	auipc	ra,0x0
    80006a04:	b30080e7          	jalr	-1232(ra) # 80006530 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a08:	000ca783          	lw	a5,0(s9)
    80006a0c:	37fd                	addiw	a5,a5,-1
    80006a0e:	06f4d163          	bge	s1,a5,80006a70 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80006a12:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006a16:	009b99b3          	sll	s3,s7,s1
    80006a1a:	412a87bb          	subw	a5,s5,s2
    80006a1e:	0337c7b3          	div	a5,a5,s3
    80006a22:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a26:	8b85                	andi	a5,a5,1
    80006a28:	fbcd                	bnez	a5,800069da <bd_free+0x6a>
    80006a2a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006a2e:	000b3d03          	ld	s10,0(s6)
    80006a32:	9d52                	add	s10,s10,s4
    80006a34:	010d3503          	ld	a0,16(s10)
    80006a38:	00000097          	auipc	ra,0x0
    80006a3c:	af8080e7          	jalr	-1288(ra) # 80006530 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006a40:	85ee                	mv	a1,s11
    80006a42:	010d3503          	ld	a0,16(s10)
    80006a46:	00000097          	auipc	ra,0x0
    80006a4a:	a82080e7          	jalr	-1406(ra) # 800064c8 <bit_isset>
    80006a4e:	e10d                	bnez	a0,80006a70 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80006a50:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006a54:	03b989bb          	mulw	s3,s3,s11
    80006a58:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006a5a:	854a                	mv	a0,s2
    80006a5c:	00000097          	auipc	ra,0x0
    80006a60:	630080e7          	jalr	1584(ra) # 8000708c <lst_remove>
    if(buddy % 2 == 0) {
    80006a64:	001d7d13          	andi	s10,s10,1
    80006a68:	f60d1ce3          	bnez	s10,800069e0 <bd_free+0x70>
      p = q;
    80006a6c:	8aca                	mv	s5,s2
    80006a6e:	bf8d                	j	800069e0 <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    80006a70:	0496                	slli	s1,s1,0x5
    80006a72:	85d6                	mv	a1,s5
    80006a74:	00003517          	auipc	a0,0x3
    80006a78:	5c453503          	ld	a0,1476(a0) # 8000a038 <bd_sizes>
    80006a7c:	9526                	add	a0,a0,s1
    80006a7e:	00000097          	auipc	ra,0x0
    80006a82:	65a080e7          	jalr	1626(ra) # 800070d8 <lst_push>
  release(&lock);
    80006a86:	00031517          	auipc	a0,0x31
    80006a8a:	94a50513          	addi	a0,a0,-1718 # 800373d0 <lock>
    80006a8e:	ffffa097          	auipc	ra,0xffffa
    80006a92:	1de080e7          	jalr	478(ra) # 80000c6c <release>
}
    80006a96:	70a6                	ld	ra,104(sp)
    80006a98:	7406                	ld	s0,96(sp)
    80006a9a:	64e6                	ld	s1,88(sp)
    80006a9c:	6946                	ld	s2,80(sp)
    80006a9e:	69a6                	ld	s3,72(sp)
    80006aa0:	6a06                	ld	s4,64(sp)
    80006aa2:	7ae2                	ld	s5,56(sp)
    80006aa4:	7b42                	ld	s6,48(sp)
    80006aa6:	7ba2                	ld	s7,40(sp)
    80006aa8:	7c02                	ld	s8,32(sp)
    80006aaa:	6ce2                	ld	s9,24(sp)
    80006aac:	6d42                	ld	s10,16(sp)
    80006aae:	6da2                	ld	s11,8(sp)
    80006ab0:	6165                	addi	sp,sp,112
    80006ab2:	8082                	ret

0000000080006ab4 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006ab4:	1141                	addi	sp,sp,-16
    80006ab6:	e422                	sd	s0,8(sp)
    80006ab8:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006aba:	00003797          	auipc	a5,0x3
    80006abe:	5767b783          	ld	a5,1398(a5) # 8000a030 <bd_base>
    80006ac2:	8d9d                	sub	a1,a1,a5
    80006ac4:	47c1                	li	a5,16
    80006ac6:	00a797b3          	sll	a5,a5,a0
    80006aca:	02f5c533          	div	a0,a1,a5
    80006ace:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006ad0:	02f5e5b3          	rem	a1,a1,a5
    80006ad4:	c191                	beqz	a1,80006ad8 <blk_index_next+0x24>
      n++;
    80006ad6:	2505                	addiw	a0,a0,1
  return n ;
}
    80006ad8:	6422                	ld	s0,8(sp)
    80006ada:	0141                	addi	sp,sp,16
    80006adc:	8082                	ret

0000000080006ade <log2>:

int
log2(uint64 n) {
    80006ade:	1141                	addi	sp,sp,-16
    80006ae0:	e422                	sd	s0,8(sp)
    80006ae2:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006ae4:	4705                	li	a4,1
    80006ae6:	00a77b63          	bgeu	a4,a0,80006afc <log2+0x1e>
    80006aea:	87aa                	mv	a5,a0
  int k = 0;
    80006aec:	4501                	li	a0,0
    k++;
    80006aee:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006af0:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006af2:	fef76ee3          	bltu	a4,a5,80006aee <log2+0x10>
  }
  return k;
}
    80006af6:	6422                	ld	s0,8(sp)
    80006af8:	0141                	addi	sp,sp,16
    80006afa:	8082                	ret
  int k = 0;
    80006afc:	4501                	li	a0,0
    80006afe:	bfe5                	j	80006af6 <log2+0x18>

0000000080006b00 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006b00:	711d                	addi	sp,sp,-96
    80006b02:	ec86                	sd	ra,88(sp)
    80006b04:	e8a2                	sd	s0,80(sp)
    80006b06:	e4a6                	sd	s1,72(sp)
    80006b08:	e0ca                	sd	s2,64(sp)
    80006b0a:	fc4e                	sd	s3,56(sp)
    80006b0c:	f852                	sd	s4,48(sp)
    80006b0e:	f456                	sd	s5,40(sp)
    80006b10:	f05a                	sd	s6,32(sp)
    80006b12:	ec5e                	sd	s7,24(sp)
    80006b14:	e862                	sd	s8,16(sp)
    80006b16:	e466                	sd	s9,8(sp)
    80006b18:	e06a                	sd	s10,0(sp)
    80006b1a:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006b1c:	00b56933          	or	s2,a0,a1
    80006b20:	00f97913          	andi	s2,s2,15
    80006b24:	04091263          	bnez	s2,80006b68 <bd_mark+0x68>
    80006b28:	8b2a                	mv	s6,a0
    80006b2a:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006b2c:	00003c17          	auipc	s8,0x3
    80006b30:	514c2c03          	lw	s8,1300(s8) # 8000a040 <nsizes>
    80006b34:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006b36:	00003d17          	auipc	s10,0x3
    80006b3a:	4fad0d13          	addi	s10,s10,1274 # 8000a030 <bd_base>
  return n / BLK_SIZE(k);
    80006b3e:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006b40:	00003a97          	auipc	s5,0x3
    80006b44:	4f8a8a93          	addi	s5,s5,1272 # 8000a038 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006b48:	07804563          	bgtz	s8,80006bb2 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006b4c:	60e6                	ld	ra,88(sp)
    80006b4e:	6446                	ld	s0,80(sp)
    80006b50:	64a6                	ld	s1,72(sp)
    80006b52:	6906                	ld	s2,64(sp)
    80006b54:	79e2                	ld	s3,56(sp)
    80006b56:	7a42                	ld	s4,48(sp)
    80006b58:	7aa2                	ld	s5,40(sp)
    80006b5a:	7b02                	ld	s6,32(sp)
    80006b5c:	6be2                	ld	s7,24(sp)
    80006b5e:	6c42                	ld	s8,16(sp)
    80006b60:	6ca2                	ld	s9,8(sp)
    80006b62:	6d02                	ld	s10,0(sp)
    80006b64:	6125                	addi	sp,sp,96
    80006b66:	8082                	ret
    panic("bd_mark");
    80006b68:	00003517          	auipc	a0,0x3
    80006b6c:	31050513          	addi	a0,a0,784 # 80009e78 <syscalls+0x498>
    80006b70:	ffffa097          	auipc	ra,0xffffa
    80006b74:	9fa080e7          	jalr	-1542(ra) # 8000056a <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006b78:	000ab783          	ld	a5,0(s5)
    80006b7c:	97ca                	add	a5,a5,s2
    80006b7e:	85a6                	mv	a1,s1
    80006b80:	6b88                	ld	a0,16(a5)
    80006b82:	00000097          	auipc	ra,0x0
    80006b86:	97e080e7          	jalr	-1666(ra) # 80006500 <bit_set>
    for(; bi < bj; bi++) {
    80006b8a:	2485                	addiw	s1,s1,1
    80006b8c:	009a0e63          	beq	s4,s1,80006ba8 <bd_mark+0xa8>
      if(k > 0) {
    80006b90:	ff3054e3          	blez	s3,80006b78 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006b94:	000ab783          	ld	a5,0(s5)
    80006b98:	97ca                	add	a5,a5,s2
    80006b9a:	85a6                	mv	a1,s1
    80006b9c:	6f88                	ld	a0,24(a5)
    80006b9e:	00000097          	auipc	ra,0x0
    80006ba2:	962080e7          	jalr	-1694(ra) # 80006500 <bit_set>
    80006ba6:	bfc9                	j	80006b78 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006ba8:	2985                	addiw	s3,s3,1
    80006baa:	02090913          	addi	s2,s2,32
    80006bae:	f9898fe3          	beq	s3,s8,80006b4c <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006bb2:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006bb6:	409b04bb          	subw	s1,s6,s1
    80006bba:	013c97b3          	sll	a5,s9,s3
    80006bbe:	02f4c4b3          	div	s1,s1,a5
    80006bc2:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006bc4:	85de                	mv	a1,s7
    80006bc6:	854e                	mv	a0,s3
    80006bc8:	00000097          	auipc	ra,0x0
    80006bcc:	eec080e7          	jalr	-276(ra) # 80006ab4 <blk_index_next>
    80006bd0:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006bd2:	faa4cfe3          	blt	s1,a0,80006b90 <bd_mark+0x90>
    80006bd6:	bfc9                	j	80006ba8 <bd_mark+0xa8>

0000000080006bd8 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006bd8:	7139                	addi	sp,sp,-64
    80006bda:	fc06                	sd	ra,56(sp)
    80006bdc:	f822                	sd	s0,48(sp)
    80006bde:	f426                	sd	s1,40(sp)
    80006be0:	f04a                	sd	s2,32(sp)
    80006be2:	ec4e                	sd	s3,24(sp)
    80006be4:	e852                	sd	s4,16(sp)
    80006be6:	e456                	sd	s5,8(sp)
    80006be8:	e05a                	sd	s6,0(sp)
    80006bea:	0080                	addi	s0,sp,64
    80006bec:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bee:	00058a9b          	sext.w	s5,a1
    80006bf2:	0015f793          	andi	a5,a1,1
    80006bf6:	ebad                	bnez	a5,80006c68 <bd_initfree_pair+0x90>
    80006bf8:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006bfc:	00599493          	slli	s1,s3,0x5
    80006c00:	00003797          	auipc	a5,0x3
    80006c04:	4387b783          	ld	a5,1080(a5) # 8000a038 <bd_sizes>
    80006c08:	94be                	add	s1,s1,a5
    80006c0a:	0104bb03          	ld	s6,16(s1)
    80006c0e:	855a                	mv	a0,s6
    80006c10:	00000097          	auipc	ra,0x0
    80006c14:	8b8080e7          	jalr	-1864(ra) # 800064c8 <bit_isset>
    80006c18:	892a                	mv	s2,a0
    80006c1a:	85d2                	mv	a1,s4
    80006c1c:	855a                	mv	a0,s6
    80006c1e:	00000097          	auipc	ra,0x0
    80006c22:	8aa080e7          	jalr	-1878(ra) # 800064c8 <bit_isset>
  int free = 0;
    80006c26:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c28:	02a90563          	beq	s2,a0,80006c52 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006c2c:	45c1                	li	a1,16
    80006c2e:	013599b3          	sll	s3,a1,s3
    80006c32:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006c36:	02090c63          	beqz	s2,80006c6e <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006c3a:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006c3e:	00003597          	auipc	a1,0x3
    80006c42:	3f25b583          	ld	a1,1010(a1) # 8000a030 <bd_base>
    80006c46:	95ce                	add	a1,a1,s3
    80006c48:	8526                	mv	a0,s1
    80006c4a:	00000097          	auipc	ra,0x0
    80006c4e:	48e080e7          	jalr	1166(ra) # 800070d8 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006c52:	855a                	mv	a0,s6
    80006c54:	70e2                	ld	ra,56(sp)
    80006c56:	7442                	ld	s0,48(sp)
    80006c58:	74a2                	ld	s1,40(sp)
    80006c5a:	7902                	ld	s2,32(sp)
    80006c5c:	69e2                	ld	s3,24(sp)
    80006c5e:	6a42                	ld	s4,16(sp)
    80006c60:	6aa2                	ld	s5,8(sp)
    80006c62:	6b02                	ld	s6,0(sp)
    80006c64:	6121                	addi	sp,sp,64
    80006c66:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c68:	fff58a1b          	addiw	s4,a1,-1
    80006c6c:	bf41                	j	80006bfc <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006c6e:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006c72:	00003597          	auipc	a1,0x3
    80006c76:	3be5b583          	ld	a1,958(a1) # 8000a030 <bd_base>
    80006c7a:	95ce                	add	a1,a1,s3
    80006c7c:	8526                	mv	a0,s1
    80006c7e:	00000097          	auipc	ra,0x0
    80006c82:	45a080e7          	jalr	1114(ra) # 800070d8 <lst_push>
    80006c86:	b7f1                	j	80006c52 <bd_initfree_pair+0x7a>

0000000080006c88 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006c88:	711d                	addi	sp,sp,-96
    80006c8a:	ec86                	sd	ra,88(sp)
    80006c8c:	e8a2                	sd	s0,80(sp)
    80006c8e:	e4a6                	sd	s1,72(sp)
    80006c90:	e0ca                	sd	s2,64(sp)
    80006c92:	fc4e                	sd	s3,56(sp)
    80006c94:	f852                	sd	s4,48(sp)
    80006c96:	f456                	sd	s5,40(sp)
    80006c98:	f05a                	sd	s6,32(sp)
    80006c9a:	ec5e                	sd	s7,24(sp)
    80006c9c:	e862                	sd	s8,16(sp)
    80006c9e:	e466                	sd	s9,8(sp)
    80006ca0:	e06a                	sd	s10,0(sp)
    80006ca2:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006ca4:	00003717          	auipc	a4,0x3
    80006ca8:	39c72703          	lw	a4,924(a4) # 8000a040 <nsizes>
    80006cac:	4785                	li	a5,1
    80006cae:	06e7db63          	bge	a5,a4,80006d24 <bd_initfree+0x9c>
    80006cb2:	8aaa                	mv	s5,a0
    80006cb4:	8b2e                	mv	s6,a1
    80006cb6:	4901                	li	s2,0
  int free = 0;
    80006cb8:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006cba:	00003c97          	auipc	s9,0x3
    80006cbe:	376c8c93          	addi	s9,s9,886 # 8000a030 <bd_base>
  return n / BLK_SIZE(k);
    80006cc2:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006cc4:	00003b97          	auipc	s7,0x3
    80006cc8:	37cb8b93          	addi	s7,s7,892 # 8000a040 <nsizes>
    80006ccc:	a039                	j	80006cda <bd_initfree+0x52>
    80006cce:	2905                	addiw	s2,s2,1
    80006cd0:	000ba783          	lw	a5,0(s7)
    80006cd4:	37fd                	addiw	a5,a5,-1
    80006cd6:	04f95863          	bge	s2,a5,80006d26 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006cda:	85d6                	mv	a1,s5
    80006cdc:	854a                	mv	a0,s2
    80006cde:	00000097          	auipc	ra,0x0
    80006ce2:	dd6080e7          	jalr	-554(ra) # 80006ab4 <blk_index_next>
    80006ce6:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006ce8:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006cec:	409b04bb          	subw	s1,s6,s1
    80006cf0:	012c17b3          	sll	a5,s8,s2
    80006cf4:	02f4c4b3          	div	s1,s1,a5
    80006cf8:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006cfa:	85aa                	mv	a1,a0
    80006cfc:	854a                	mv	a0,s2
    80006cfe:	00000097          	auipc	ra,0x0
    80006d02:	eda080e7          	jalr	-294(ra) # 80006bd8 <bd_initfree_pair>
    80006d06:	01450d3b          	addw	s10,a0,s4
    80006d0a:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006d0e:	fc99d0e3          	bge	s3,s1,80006cce <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006d12:	85a6                	mv	a1,s1
    80006d14:	854a                	mv	a0,s2
    80006d16:	00000097          	auipc	ra,0x0
    80006d1a:	ec2080e7          	jalr	-318(ra) # 80006bd8 <bd_initfree_pair>
    80006d1e:	00ad0a3b          	addw	s4,s10,a0
    80006d22:	b775                	j	80006cce <bd_initfree+0x46>
  int free = 0;
    80006d24:	4a01                	li	s4,0
  }
  return free;
}
    80006d26:	8552                	mv	a0,s4
    80006d28:	60e6                	ld	ra,88(sp)
    80006d2a:	6446                	ld	s0,80(sp)
    80006d2c:	64a6                	ld	s1,72(sp)
    80006d2e:	6906                	ld	s2,64(sp)
    80006d30:	79e2                	ld	s3,56(sp)
    80006d32:	7a42                	ld	s4,48(sp)
    80006d34:	7aa2                	ld	s5,40(sp)
    80006d36:	7b02                	ld	s6,32(sp)
    80006d38:	6be2                	ld	s7,24(sp)
    80006d3a:	6c42                	ld	s8,16(sp)
    80006d3c:	6ca2                	ld	s9,8(sp)
    80006d3e:	6d02                	ld	s10,0(sp)
    80006d40:	6125                	addi	sp,sp,96
    80006d42:	8082                	ret

0000000080006d44 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006d44:	7179                	addi	sp,sp,-48
    80006d46:	f406                	sd	ra,40(sp)
    80006d48:	f022                	sd	s0,32(sp)
    80006d4a:	ec26                	sd	s1,24(sp)
    80006d4c:	e84a                	sd	s2,16(sp)
    80006d4e:	e44e                	sd	s3,8(sp)
    80006d50:	1800                	addi	s0,sp,48
    80006d52:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006d54:	00003997          	auipc	s3,0x3
    80006d58:	2dc98993          	addi	s3,s3,732 # 8000a030 <bd_base>
    80006d5c:	0009b483          	ld	s1,0(s3)
    80006d60:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006d64:	00003797          	auipc	a5,0x3
    80006d68:	2dc7a783          	lw	a5,732(a5) # 8000a040 <nsizes>
    80006d6c:	37fd                	addiw	a5,a5,-1
    80006d6e:	4641                	li	a2,16
    80006d70:	00f61633          	sll	a2,a2,a5
    80006d74:	85a6                	mv	a1,s1
    80006d76:	00003517          	auipc	a0,0x3
    80006d7a:	10a50513          	addi	a0,a0,266 # 80009e80 <syscalls+0x4a0>
    80006d7e:	ffffa097          	auipc	ra,0xffffa
    80006d82:	84e080e7          	jalr	-1970(ra) # 800005cc <printf>
  bd_mark(bd_base, p);
    80006d86:	85ca                	mv	a1,s2
    80006d88:	0009b503          	ld	a0,0(s3)
    80006d8c:	00000097          	auipc	ra,0x0
    80006d90:	d74080e7          	jalr	-652(ra) # 80006b00 <bd_mark>
  return meta;
}
    80006d94:	8526                	mv	a0,s1
    80006d96:	70a2                	ld	ra,40(sp)
    80006d98:	7402                	ld	s0,32(sp)
    80006d9a:	64e2                	ld	s1,24(sp)
    80006d9c:	6942                	ld	s2,16(sp)
    80006d9e:	69a2                	ld	s3,8(sp)
    80006da0:	6145                	addi	sp,sp,48
    80006da2:	8082                	ret

0000000080006da4 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006da4:	1101                	addi	sp,sp,-32
    80006da6:	ec06                	sd	ra,24(sp)
    80006da8:	e822                	sd	s0,16(sp)
    80006daa:	e426                	sd	s1,8(sp)
    80006dac:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006dae:	00003497          	auipc	s1,0x3
    80006db2:	2924a483          	lw	s1,658(s1) # 8000a040 <nsizes>
    80006db6:	fff4879b          	addiw	a5,s1,-1
    80006dba:	44c1                	li	s1,16
    80006dbc:	00f494b3          	sll	s1,s1,a5
    80006dc0:	00003797          	auipc	a5,0x3
    80006dc4:	2707b783          	ld	a5,624(a5) # 8000a030 <bd_base>
    80006dc8:	8d1d                	sub	a0,a0,a5
    80006dca:	40a4853b          	subw	a0,s1,a0
    80006dce:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006dd2:	00905a63          	blez	s1,80006de6 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006dd6:	357d                	addiw	a0,a0,-1
    80006dd8:	41f5549b          	sraiw	s1,a0,0x1f
    80006ddc:	01c4d49b          	srliw	s1,s1,0x1c
    80006de0:	9ca9                	addw	s1,s1,a0
    80006de2:	98c1                	andi	s1,s1,-16
    80006de4:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006de6:	85a6                	mv	a1,s1
    80006de8:	00003517          	auipc	a0,0x3
    80006dec:	0d050513          	addi	a0,a0,208 # 80009eb8 <syscalls+0x4d8>
    80006df0:	ffff9097          	auipc	ra,0xffff9
    80006df4:	7dc080e7          	jalr	2012(ra) # 800005cc <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006df8:	00003717          	auipc	a4,0x3
    80006dfc:	23873703          	ld	a4,568(a4) # 8000a030 <bd_base>
    80006e00:	00003597          	auipc	a1,0x3
    80006e04:	2405a583          	lw	a1,576(a1) # 8000a040 <nsizes>
    80006e08:	fff5879b          	addiw	a5,a1,-1
    80006e0c:	45c1                	li	a1,16
    80006e0e:	00f595b3          	sll	a1,a1,a5
    80006e12:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006e16:	95ba                	add	a1,a1,a4
    80006e18:	953a                	add	a0,a0,a4
    80006e1a:	00000097          	auipc	ra,0x0
    80006e1e:	ce6080e7          	jalr	-794(ra) # 80006b00 <bd_mark>
  return unavailable;
}
    80006e22:	8526                	mv	a0,s1
    80006e24:	60e2                	ld	ra,24(sp)
    80006e26:	6442                	ld	s0,16(sp)
    80006e28:	64a2                	ld	s1,8(sp)
    80006e2a:	6105                	addi	sp,sp,32
    80006e2c:	8082                	ret

0000000080006e2e <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006e2e:	715d                	addi	sp,sp,-80
    80006e30:	e486                	sd	ra,72(sp)
    80006e32:	e0a2                	sd	s0,64(sp)
    80006e34:	fc26                	sd	s1,56(sp)
    80006e36:	f84a                	sd	s2,48(sp)
    80006e38:	f44e                	sd	s3,40(sp)
    80006e3a:	f052                	sd	s4,32(sp)
    80006e3c:	ec56                	sd	s5,24(sp)
    80006e3e:	e85a                	sd	s6,16(sp)
    80006e40:	e45e                	sd	s7,8(sp)
    80006e42:	e062                	sd	s8,0(sp)
    80006e44:	0880                	addi	s0,sp,80
    80006e46:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006e48:	fff50493          	addi	s1,a0,-1
    80006e4c:	98c1                	andi	s1,s1,-16
    80006e4e:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006e50:	00003597          	auipc	a1,0x3
    80006e54:	08858593          	addi	a1,a1,136 # 80009ed8 <syscalls+0x4f8>
    80006e58:	00030517          	auipc	a0,0x30
    80006e5c:	57850513          	addi	a0,a0,1400 # 800373d0 <lock>
    80006e60:	ffffa097          	auipc	ra,0xffffa
    80006e64:	c66080e7          	jalr	-922(ra) # 80000ac6 <initlock>
  bd_base = (void *) p;
    80006e68:	00003797          	auipc	a5,0x3
    80006e6c:	1c97b423          	sd	s1,456(a5) # 8000a030 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e70:	409c0933          	sub	s2,s8,s1
    80006e74:	43f95513          	srai	a0,s2,0x3f
    80006e78:	893d                	andi	a0,a0,15
    80006e7a:	954a                	add	a0,a0,s2
    80006e7c:	8511                	srai	a0,a0,0x4
    80006e7e:	00000097          	auipc	ra,0x0
    80006e82:	c60080e7          	jalr	-928(ra) # 80006ade <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006e86:	47c1                	li	a5,16
    80006e88:	00a797b3          	sll	a5,a5,a0
    80006e8c:	1b27c663          	blt	a5,s2,80007038 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e90:	2505                	addiw	a0,a0,1
    80006e92:	00003797          	auipc	a5,0x3
    80006e96:	1aa7a723          	sw	a0,430(a5) # 8000a040 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006e9a:	00003997          	auipc	s3,0x3
    80006e9e:	1a698993          	addi	s3,s3,422 # 8000a040 <nsizes>
    80006ea2:	0009a603          	lw	a2,0(s3)
    80006ea6:	85ca                	mv	a1,s2
    80006ea8:	00003517          	auipc	a0,0x3
    80006eac:	03850513          	addi	a0,a0,56 # 80009ee0 <syscalls+0x500>
    80006eb0:	ffff9097          	auipc	ra,0xffff9
    80006eb4:	71c080e7          	jalr	1820(ra) # 800005cc <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006eb8:	00003797          	auipc	a5,0x3
    80006ebc:	1897b023          	sd	s1,384(a5) # 8000a038 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006ec0:	0009a603          	lw	a2,0(s3)
    80006ec4:	00561913          	slli	s2,a2,0x5
    80006ec8:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006eca:	0056161b          	slliw	a2,a2,0x5
    80006ece:	4581                	li	a1,0
    80006ed0:	8526                	mv	a0,s1
    80006ed2:	ffffa097          	auipc	ra,0xffffa
    80006ed6:	fae080e7          	jalr	-82(ra) # 80000e80 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006eda:	0009a783          	lw	a5,0(s3)
    80006ede:	06f05a63          	blez	a5,80006f52 <bd_init+0x124>
    80006ee2:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006ee4:	00003a97          	auipc	s5,0x3
    80006ee8:	154a8a93          	addi	s5,s5,340 # 8000a038 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006eec:	00003a17          	auipc	s4,0x3
    80006ef0:	154a0a13          	addi	s4,s4,340 # 8000a040 <nsizes>
    80006ef4:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006ef6:	00599b93          	slli	s7,s3,0x5
    80006efa:	000ab503          	ld	a0,0(s5)
    80006efe:	955e                	add	a0,a0,s7
    80006f00:	00000097          	auipc	ra,0x0
    80006f04:	166080e7          	jalr	358(ra) # 80007066 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f08:	000a2483          	lw	s1,0(s4)
    80006f0c:	34fd                	addiw	s1,s1,-1
    80006f0e:	413484bb          	subw	s1,s1,s3
    80006f12:	009b14bb          	sllw	s1,s6,s1
    80006f16:	fff4879b          	addiw	a5,s1,-1
    80006f1a:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f1e:	01d4d49b          	srliw	s1,s1,0x1d
    80006f22:	9cbd                	addw	s1,s1,a5
    80006f24:	98e1                	andi	s1,s1,-8
    80006f26:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006f28:	000ab783          	ld	a5,0(s5)
    80006f2c:	9bbe                	add	s7,s7,a5
    80006f2e:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006f32:	848d                	srai	s1,s1,0x3
    80006f34:	8626                	mv	a2,s1
    80006f36:	4581                	li	a1,0
    80006f38:	854a                	mv	a0,s2
    80006f3a:	ffffa097          	auipc	ra,0xffffa
    80006f3e:	f46080e7          	jalr	-186(ra) # 80000e80 <memset>
    p += sz;
    80006f42:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006f44:	0985                	addi	s3,s3,1
    80006f46:	000a2703          	lw	a4,0(s4)
    80006f4a:	0009879b          	sext.w	a5,s3
    80006f4e:	fae7c4e3          	blt	a5,a4,80006ef6 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006f52:	00003797          	auipc	a5,0x3
    80006f56:	0ee7a783          	lw	a5,238(a5) # 8000a040 <nsizes>
    80006f5a:	4705                	li	a4,1
    80006f5c:	06f75163          	bge	a4,a5,80006fbe <bd_init+0x190>
    80006f60:	02000a13          	li	s4,32
    80006f64:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f66:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006f68:	00003b17          	auipc	s6,0x3
    80006f6c:	0d0b0b13          	addi	s6,s6,208 # 8000a038 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006f70:	00003a97          	auipc	s5,0x3
    80006f74:	0d0a8a93          	addi	s5,s5,208 # 8000a040 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f78:	37fd                	addiw	a5,a5,-1
    80006f7a:	413787bb          	subw	a5,a5,s3
    80006f7e:	00fb94bb          	sllw	s1,s7,a5
    80006f82:	fff4879b          	addiw	a5,s1,-1
    80006f86:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f8a:	01d4d49b          	srliw	s1,s1,0x1d
    80006f8e:	9cbd                	addw	s1,s1,a5
    80006f90:	98e1                	andi	s1,s1,-8
    80006f92:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006f94:	000b3783          	ld	a5,0(s6)
    80006f98:	97d2                	add	a5,a5,s4
    80006f9a:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006f9e:	848d                	srai	s1,s1,0x3
    80006fa0:	8626                	mv	a2,s1
    80006fa2:	4581                	li	a1,0
    80006fa4:	854a                	mv	a0,s2
    80006fa6:	ffffa097          	auipc	ra,0xffffa
    80006faa:	eda080e7          	jalr	-294(ra) # 80000e80 <memset>
    p += sz;
    80006fae:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006fb0:	2985                	addiw	s3,s3,1
    80006fb2:	000aa783          	lw	a5,0(s5)
    80006fb6:	020a0a13          	addi	s4,s4,32
    80006fba:	faf9cfe3          	blt	s3,a5,80006f78 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006fbe:	197d                	addi	s2,s2,-1
    80006fc0:	ff097913          	andi	s2,s2,-16
    80006fc4:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006fc6:	854a                	mv	a0,s2
    80006fc8:	00000097          	auipc	ra,0x0
    80006fcc:	d7c080e7          	jalr	-644(ra) # 80006d44 <bd_mark_data_structures>
    80006fd0:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006fd2:	85ca                	mv	a1,s2
    80006fd4:	8562                	mv	a0,s8
    80006fd6:	00000097          	auipc	ra,0x0
    80006fda:	dce080e7          	jalr	-562(ra) # 80006da4 <bd_mark_unavailable>
    80006fde:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006fe0:	00003a97          	auipc	s5,0x3
    80006fe4:	060a8a93          	addi	s5,s5,96 # 8000a040 <nsizes>
    80006fe8:	000aa783          	lw	a5,0(s5)
    80006fec:	37fd                	addiw	a5,a5,-1
    80006fee:	44c1                	li	s1,16
    80006ff0:	00f497b3          	sll	a5,s1,a5
    80006ff4:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006ff6:	00003597          	auipc	a1,0x3
    80006ffa:	03a5b583          	ld	a1,58(a1) # 8000a030 <bd_base>
    80006ffe:	95be                	add	a1,a1,a5
    80007000:	854a                	mv	a0,s2
    80007002:	00000097          	auipc	ra,0x0
    80007006:	c86080e7          	jalr	-890(ra) # 80006c88 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    8000700a:	000aa603          	lw	a2,0(s5)
    8000700e:	367d                	addiw	a2,a2,-1
    80007010:	00c49633          	sll	a2,s1,a2
    80007014:	41460633          	sub	a2,a2,s4
    80007018:	41360633          	sub	a2,a2,s3
    8000701c:	02c51463          	bne	a0,a2,80007044 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007020:	60a6                	ld	ra,72(sp)
    80007022:	6406                	ld	s0,64(sp)
    80007024:	74e2                	ld	s1,56(sp)
    80007026:	7942                	ld	s2,48(sp)
    80007028:	79a2                	ld	s3,40(sp)
    8000702a:	7a02                	ld	s4,32(sp)
    8000702c:	6ae2                	ld	s5,24(sp)
    8000702e:	6b42                	ld	s6,16(sp)
    80007030:	6ba2                	ld	s7,8(sp)
    80007032:	6c02                	ld	s8,0(sp)
    80007034:	6161                	addi	sp,sp,80
    80007036:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80007038:	2509                	addiw	a0,a0,2
    8000703a:	00003797          	auipc	a5,0x3
    8000703e:	00a7a323          	sw	a0,6(a5) # 8000a040 <nsizes>
    80007042:	bda1                	j	80006e9a <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007044:	85aa                	mv	a1,a0
    80007046:	00003517          	auipc	a0,0x3
    8000704a:	eda50513          	addi	a0,a0,-294 # 80009f20 <syscalls+0x540>
    8000704e:	ffff9097          	auipc	ra,0xffff9
    80007052:	57e080e7          	jalr	1406(ra) # 800005cc <printf>
    panic("bd_init: free mem");
    80007056:	00003517          	auipc	a0,0x3
    8000705a:	eda50513          	addi	a0,a0,-294 # 80009f30 <syscalls+0x550>
    8000705e:	ffff9097          	auipc	ra,0xffff9
    80007062:	50c080e7          	jalr	1292(ra) # 8000056a <panic>

0000000080007066 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007066:	1141                	addi	sp,sp,-16
    80007068:	e422                	sd	s0,8(sp)
    8000706a:	0800                	addi	s0,sp,16
  lst->next = lst;
    8000706c:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000706e:	e508                	sd	a0,8(a0)
}
    80007070:	6422                	ld	s0,8(sp)
    80007072:	0141                	addi	sp,sp,16
    80007074:	8082                	ret

0000000080007076 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007076:	1141                	addi	sp,sp,-16
    80007078:	e422                	sd	s0,8(sp)
    8000707a:	0800                	addi	s0,sp,16
  return lst->next == lst;
    8000707c:	611c                	ld	a5,0(a0)
    8000707e:	40a78533          	sub	a0,a5,a0
}
    80007082:	00153513          	seqz	a0,a0
    80007086:	6422                	ld	s0,8(sp)
    80007088:	0141                	addi	sp,sp,16
    8000708a:	8082                	ret

000000008000708c <lst_remove>:

void
lst_remove(struct list *e) {
    8000708c:	1141                	addi	sp,sp,-16
    8000708e:	e422                	sd	s0,8(sp)
    80007090:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007092:	6518                	ld	a4,8(a0)
    80007094:	611c                	ld	a5,0(a0)
    80007096:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007098:	6518                	ld	a4,8(a0)
    8000709a:	e798                	sd	a4,8(a5)
}
    8000709c:	6422                	ld	s0,8(sp)
    8000709e:	0141                	addi	sp,sp,16
    800070a0:	8082                	ret

00000000800070a2 <lst_pop>:

void*
lst_pop(struct list *lst) {
    800070a2:	1101                	addi	sp,sp,-32
    800070a4:	ec06                	sd	ra,24(sp)
    800070a6:	e822                	sd	s0,16(sp)
    800070a8:	e426                	sd	s1,8(sp)
    800070aa:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800070ac:	6104                	ld	s1,0(a0)
    800070ae:	00a48d63          	beq	s1,a0,800070c8 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800070b2:	8526                	mv	a0,s1
    800070b4:	00000097          	auipc	ra,0x0
    800070b8:	fd8080e7          	jalr	-40(ra) # 8000708c <lst_remove>
  return (void *)p;
}
    800070bc:	8526                	mv	a0,s1
    800070be:	60e2                	ld	ra,24(sp)
    800070c0:	6442                	ld	s0,16(sp)
    800070c2:	64a2                	ld	s1,8(sp)
    800070c4:	6105                	addi	sp,sp,32
    800070c6:	8082                	ret
    panic("lst_pop");
    800070c8:	00003517          	auipc	a0,0x3
    800070cc:	e8050513          	addi	a0,a0,-384 # 80009f48 <syscalls+0x568>
    800070d0:	ffff9097          	auipc	ra,0xffff9
    800070d4:	49a080e7          	jalr	1178(ra) # 8000056a <panic>

00000000800070d8 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800070d8:	1141                	addi	sp,sp,-16
    800070da:	e422                	sd	s0,8(sp)
    800070dc:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800070de:	611c                	ld	a5,0(a0)
    800070e0:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800070e2:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800070e4:	611c                	ld	a5,0(a0)
    800070e6:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800070e8:	e10c                	sd	a1,0(a0)
}
    800070ea:	6422                	ld	s0,8(sp)
    800070ec:	0141                	addi	sp,sp,16
    800070ee:	8082                	ret

00000000800070f0 <lst_print>:

void
lst_print(struct list *lst)
{
    800070f0:	7179                	addi	sp,sp,-48
    800070f2:	f406                	sd	ra,40(sp)
    800070f4:	f022                	sd	s0,32(sp)
    800070f6:	ec26                	sd	s1,24(sp)
    800070f8:	e84a                	sd	s2,16(sp)
    800070fa:	e44e                	sd	s3,8(sp)
    800070fc:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800070fe:	6104                	ld	s1,0(a0)
    80007100:	02950063          	beq	a0,s1,80007120 <lst_print+0x30>
    80007104:	892a                	mv	s2,a0
    printf(" %p", p);
    80007106:	00003997          	auipc	s3,0x3
    8000710a:	e4a98993          	addi	s3,s3,-438 # 80009f50 <syscalls+0x570>
    8000710e:	85a6                	mv	a1,s1
    80007110:	854e                	mv	a0,s3
    80007112:	ffff9097          	auipc	ra,0xffff9
    80007116:	4ba080e7          	jalr	1210(ra) # 800005cc <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000711a:	6084                	ld	s1,0(s1)
    8000711c:	fe9919e3          	bne	s2,s1,8000710e <lst_print+0x1e>
  }
  printf("\n");
    80007120:	00002517          	auipc	a0,0x2
    80007124:	0e050513          	addi	a0,a0,224 # 80009200 <digits+0x90>
    80007128:	ffff9097          	auipc	ra,0xffff9
    8000712c:	4a4080e7          	jalr	1188(ra) # 800005cc <printf>
}
    80007130:	70a2                	ld	ra,40(sp)
    80007132:	7402                	ld	s0,32(sp)
    80007134:	64e2                	ld	s1,24(sp)
    80007136:	6942                	ld	s2,16(sp)
    80007138:	69a2                	ld	s3,8(sp)
    8000713a:	6145                	addi	sp,sp,48
    8000713c:	8082                	ret

000000008000713e <rcu_init>:
  }
}

void
rcu_init(void)
{
    8000713e:	1101                	addi	sp,sp,-32
    80007140:	ec06                	sd	ra,24(sp)
    80007142:	e822                	sd	s0,16(sp)
    80007144:	e426                	sd	s1,8(sp)
    80007146:	1000                	addi	s0,sp,32
  initlock(&rcu_lock, "rcu");
    80007148:	00030497          	auipc	s1,0x30
    8000714c:	2a848493          	addi	s1,s1,680 # 800373f0 <rcu_lock>
    80007150:	00003597          	auipc	a1,0x3
    80007154:	e0858593          	addi	a1,a1,-504 # 80009f58 <syscalls+0x578>
    80007158:	8526                	mv	a0,s1
    8000715a:	ffffa097          	auipc	ra,0xffffa
    8000715e:	96c080e7          	jalr	-1684(ra) # 80000ac6 <initlock>
  defer_list = 0;
    80007162:	00003797          	auipc	a5,0x3
    80007166:	ee07b323          	sd	zero,-282(a5) # 8000a048 <defer_list>
  for (int i = 0; i < NCPU; i++)
    rcu_readers[i] = 0;
    8000716a:	0204a023          	sw	zero,32(s1)
    8000716e:	0204a223          	sw	zero,36(s1)
    80007172:	0204a423          	sw	zero,40(s1)
    80007176:	0204a623          	sw	zero,44(s1)
    8000717a:	0204a823          	sw	zero,48(s1)
    8000717e:	0204aa23          	sw	zero,52(s1)
    80007182:	0204ac23          	sw	zero,56(s1)
    80007186:	0204ae23          	sw	zero,60(s1)
}
    8000718a:	60e2                	ld	ra,24(sp)
    8000718c:	6442                	ld	s0,16(sp)
    8000718e:	64a2                	ld	s1,8(sp)
    80007190:	6105                	addi	sp,sp,32
    80007192:	8082                	ret

0000000080007194 <rcu_read_lock>:

void
rcu_read_lock(void)
{
    80007194:	1141                	addi	sp,sp,-16
    80007196:	e406                	sd	ra,8(sp)
    80007198:	e022                	sd	s0,0(sp)
    8000719a:	0800                	addi	s0,sp,16
  int id = cpuid();
    8000719c:	ffffb097          	auipc	ra,0xffffb
    800071a0:	9d6080e7          	jalr	-1578(ra) # 80001b72 <cpuid>
  __sync_add_and_fetch(&rcu_readers[id], 1);
    800071a4:	00251793          	slli	a5,a0,0x2
    800071a8:	00030517          	auipc	a0,0x30
    800071ac:	24850513          	addi	a0,a0,584 # 800373f0 <rcu_lock>
    800071b0:	953e                	add	a0,a0,a5
    800071b2:	4785                	li	a5,1
    800071b4:	02050713          	addi	a4,a0,32
    800071b8:	0f50000f          	fence	iorw,ow
    800071bc:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  __sync_synchronize();
    800071c0:	0ff0000f          	fence
}
    800071c4:	60a2                	ld	ra,8(sp)
    800071c6:	6402                	ld	s0,0(sp)
    800071c8:	0141                	addi	sp,sp,16
    800071ca:	8082                	ret

00000000800071cc <rcu_read_unlock>:

void
rcu_read_unlock(void)
{
    800071cc:	1141                	addi	sp,sp,-16
    800071ce:	e406                	sd	ra,8(sp)
    800071d0:	e022                	sd	s0,0(sp)
    800071d2:	0800                	addi	s0,sp,16
  __sync_synchronize();
    800071d4:	0ff0000f          	fence
  int id = cpuid();
    800071d8:	ffffb097          	auipc	ra,0xffffb
    800071dc:	99a080e7          	jalr	-1638(ra) # 80001b72 <cpuid>
  __sync_sub_and_fetch(&rcu_readers[id], 1);
    800071e0:	00251793          	slli	a5,a0,0x2
    800071e4:	00030517          	auipc	a0,0x30
    800071e8:	20c50513          	addi	a0,a0,524 # 800373f0 <rcu_lock>
    800071ec:	953e                	add	a0,a0,a5
    800071ee:	57fd                	li	a5,-1
    800071f0:	02050713          	addi	a4,a0,32
    800071f4:	0f50000f          	fence	iorw,ow
    800071f8:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
}
    800071fc:	60a2                	ld	ra,8(sp)
    800071fe:	6402                	ld	s0,0(sp)
    80007200:	0141                	addi	sp,sp,16
    80007202:	8082                	ret

0000000080007204 <call_rcu>:

void
call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *))
{
    80007204:	1101                	addi	sp,sp,-32
    80007206:	ec06                	sd	ra,24(sp)
    80007208:	e822                	sd	s0,16(sp)
    8000720a:	e426                	sd	s1,8(sp)
    8000720c:	e04a                	sd	s2,0(sp)
    8000720e:	1000                	addi	s0,sp,32
    80007210:	84aa                	mv	s1,a0
  head->func = func;
    80007212:	e10c                	sd	a1,0(a0)

  acquire(&rcu_lock);
    80007214:	00030917          	auipc	s2,0x30
    80007218:	1dc90913          	addi	s2,s2,476 # 800373f0 <rcu_lock>
    8000721c:	854a                	mv	a0,s2
    8000721e:	ffffa097          	auipc	ra,0xffffa
    80007222:	97e080e7          	jalr	-1666(ra) # 80000b9c <acquire>
  head->next = defer_list;
    80007226:	00003797          	auipc	a5,0x3
    8000722a:	e2278793          	addi	a5,a5,-478 # 8000a048 <defer_list>
    8000722e:	6398                	ld	a4,0(a5)
    80007230:	e498                	sd	a4,8(s1)
  defer_list = head;
    80007232:	e384                	sd	s1,0(a5)
  release(&rcu_lock);
    80007234:	854a                	mv	a0,s2
    80007236:	ffffa097          	auipc	ra,0xffffa
    8000723a:	a36080e7          	jalr	-1482(ra) # 80000c6c <release>
}
    8000723e:	60e2                	ld	ra,24(sp)
    80007240:	6442                	ld	s0,16(sp)
    80007242:	64a2                	ld	s1,8(sp)
    80007244:	6902                	ld	s2,0(sp)
    80007246:	6105                	addi	sp,sp,32
    80007248:	8082                	ret

000000008000724a <synchronize_rcu>:

void
synchronize_rcu(void)
{
    8000724a:	1101                	addi	sp,sp,-32
    8000724c:	ec06                	sd	ra,24(sp)
    8000724e:	e822                	sd	s0,16(sp)
    80007250:	e426                	sd	s1,8(sp)
    80007252:	e04a                	sd	s2,0(sp)
    80007254:	1000                	addi	s0,sp,32
  // Wait for a grace period.
  wait_for_readers();
    80007256:	00030697          	auipc	a3,0x30
    8000725a:	1da68693          	addi	a3,a3,474 # 80037430 <end>
    for (int i = 0; i < NCPU; i++) {
    8000725e:	00030797          	auipc	a5,0x30
    80007262:	1b278793          	addi	a5,a5,434 # 80037410 <rcu_readers>
      if (__sync_fetch_and_add(&rcu_readers[i], 0) > 0) {
    80007266:	0f50000f          	fence	iorw,ow
    8000726a:	0407a72f          	amoadd.w.aq	a4,zero,(a5)
    8000726e:	2701                	sext.w	a4,a4
    80007270:	fee047e3          	bgtz	a4,8000725e <synchronize_rcu+0x14>
    for (int i = 0; i < NCPU; i++) {
    80007274:	0791                	addi	a5,a5,4
    80007276:	fed798e3          	bne	a5,a3,80007266 <synchronize_rcu+0x1c>

  // Detach the callback list under the lock.
  acquire(&rcu_lock);
    8000727a:	00030917          	auipc	s2,0x30
    8000727e:	17690913          	addi	s2,s2,374 # 800373f0 <rcu_lock>
    80007282:	854a                	mv	a0,s2
    80007284:	ffffa097          	auipc	ra,0xffffa
    80007288:	918080e7          	jalr	-1768(ra) # 80000b9c <acquire>
  struct rcu_head *h = defer_list;
    8000728c:	00003797          	auipc	a5,0x3
    80007290:	dbc78793          	addi	a5,a5,-580 # 8000a048 <defer_list>
    80007294:	6384                	ld	s1,0(a5)
  defer_list = 0;
    80007296:	0007b023          	sd	zero,0(a5)
  release(&rcu_lock);
    8000729a:	854a                	mv	a0,s2
    8000729c:	ffffa097          	auipc	ra,0xffffa
    800072a0:	9d0080e7          	jalr	-1584(ra) # 80000c6c <release>

  // Run callbacks without holding rcu_lock.
  while (h) {
    800072a4:	c491                	beqz	s1,800072b0 <synchronize_rcu+0x66>
    struct rcu_head *next = h->next;
    800072a6:	8526                	mv	a0,s1
    800072a8:	6484                	ld	s1,8(s1)
    h->func(h);
    800072aa:	611c                	ld	a5,0(a0)
    800072ac:	9782                	jalr	a5
  while (h) {
    800072ae:	fce5                	bnez	s1,800072a6 <synchronize_rcu+0x5c>
    h = next;
  }
}
    800072b0:	60e2                	ld	ra,24(sp)
    800072b2:	6442                	ld	s0,16(sp)
    800072b4:	64a2                	ld	s1,8(sp)
    800072b6:	6902                	ld	s2,0(sp)
    800072b8:	6105                	addi	sp,sp,32
    800072ba:	8082                	ret

00000000800072bc <rcu_poll>:

void
rcu_poll(void)
{
    800072bc:	1101                	addi	sp,sp,-32
    800072be:	ec06                	sd	ra,24(sp)
    800072c0:	e822                	sd	s0,16(sp)
    800072c2:	e426                	sd	s1,8(sp)
    800072c4:	e04a                	sd	s2,0(sp)
    800072c6:	1000                	addi	s0,sp,32
  // Fast check: if there is nothing to reclaim, return immediately.
  acquire(&rcu_lock);
    800072c8:	00030497          	auipc	s1,0x30
    800072cc:	12848493          	addi	s1,s1,296 # 800373f0 <rcu_lock>
    800072d0:	8526                	mv	a0,s1
    800072d2:	ffffa097          	auipc	ra,0xffffa
    800072d6:	8ca080e7          	jalr	-1846(ra) # 80000b9c <acquire>
  int empty = (defer_list == 0);
    800072da:	00003917          	auipc	s2,0x3
    800072de:	d6e93903          	ld	s2,-658(s2) # 8000a048 <defer_list>
  release(&rcu_lock);
    800072e2:	8526                	mv	a0,s1
    800072e4:	ffffa097          	auipc	ra,0xffffa
    800072e8:	988080e7          	jalr	-1656(ra) # 80000c6c <release>

  if (!empty) {
    800072ec:	00090663          	beqz	s2,800072f8 <rcu_poll+0x3c>
    // Wait for a grace period and run all pending callbacks.
    synchronize_rcu();
    800072f0:	00000097          	auipc	ra,0x0
    800072f4:	f5a080e7          	jalr	-166(ra) # 8000724a <synchronize_rcu>
  }
    800072f8:	60e2                	ld	ra,24(sp)
    800072fa:	6442                	ld	s0,16(sp)
    800072fc:	64a2                	ld	s1,8(sp)
    800072fe:	6902                	ld	s2,0(sp)
    80007300:	6105                	addi	sp,sp,32
    80007302:	8082                	ret

0000000080007304 <rcu_hnode_free_cb>:
}

// RCU callback to free a node after a grace period.
static void
rcu_hnode_free_cb(struct rcu_head *head)
{
    80007304:	1141                	addi	sp,sp,-16
    80007306:	e406                	sd	ra,8(sp)
    80007308:	e022                	sd	s0,0(sp)
    8000730a:	0800                	addi	s0,sp,16
  struct rcu_hnode *node = container_of(head, struct rcu_hnode, rcu);
  kfree((void *)node);
    8000730c:	ffff9097          	auipc	ra,0xffff9
    80007310:	63a080e7          	jalr	1594(ra) # 80000946 <kfree>
}
    80007314:	60a2                	ld	ra,8(sp)
    80007316:	6402                	ld	s0,0(sp)
    80007318:	0141                	addi	sp,sp,16
    8000731a:	8082                	ret

000000008000731c <rcu_hash_init>:
{
    8000731c:	7139                	addi	sp,sp,-64
    8000731e:	fc06                	sd	ra,56(sp)
    80007320:	f822                	sd	s0,48(sp)
    80007322:	f426                	sd	s1,40(sp)
    80007324:	f04a                	sd	s2,32(sp)
    80007326:	ec4e                	sd	s3,24(sp)
    80007328:	e852                	sd	s4,16(sp)
    8000732a:	e456                	sd	s5,8(sp)
    8000732c:	0080                	addi	s0,sp,64
    8000732e:	89aa                	mv	s3,a0
  ht->lock = (struct spinlock *)kalloc();
    80007330:	ffff9097          	auipc	ra,0xffff9
    80007334:	71c080e7          	jalr	1820(ra) # 80000a4c <kalloc>
    80007338:	00a9b023          	sd	a0,0(s3)
  if (ht->lock == 0) {
    8000733c:	c131                	beqz	a0,80007380 <rcu_hash_init+0x64>
    8000733e:	00898493          	addi	s1,s3,8
    80007342:	20898a93          	addi	s5,s3,520
    80007346:	4901                	li	s2,0
    initlock(&ht->lock[i], "rcu_ht");
    80007348:	00003a17          	auipc	s4,0x3
    8000734c:	c40a0a13          	addi	s4,s4,-960 # 80009f88 <syscalls+0x5a8>
    80007350:	0009b503          	ld	a0,0(s3)
    80007354:	85d2                	mv	a1,s4
    80007356:	954a                	add	a0,a0,s2
    80007358:	ffff9097          	auipc	ra,0xffff9
    8000735c:	76e080e7          	jalr	1902(ra) # 80000ac6 <initlock>
    ht->bucket[i] = 0;
    80007360:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < RCU_HT_NBUCKET; i++) {
    80007364:	02090913          	addi	s2,s2,32
    80007368:	04a1                	addi	s1,s1,8
    8000736a:	ff5493e3          	bne	s1,s5,80007350 <rcu_hash_init+0x34>
}
    8000736e:	70e2                	ld	ra,56(sp)
    80007370:	7442                	ld	s0,48(sp)
    80007372:	74a2                	ld	s1,40(sp)
    80007374:	7902                	ld	s2,32(sp)
    80007376:	69e2                	ld	s3,24(sp)
    80007378:	6a42                	ld	s4,16(sp)
    8000737a:	6aa2                	ld	s5,8(sp)
    8000737c:	6121                	addi	sp,sp,64
    8000737e:	8082                	ret
    panic("rcu_hash_init: no memory for locks");
    80007380:	00003517          	auipc	a0,0x3
    80007384:	be050513          	addi	a0,a0,-1056 # 80009f60 <syscalls+0x580>
    80007388:	ffff9097          	auipc	ra,0xffff9
    8000738c:	1e2080e7          	jalr	482(ra) # 8000056a <panic>

0000000080007390 <rcu_hash_insert>:

// Insert a new (key, value) if key is not present.
int
rcu_hash_insert(struct rcu_hash_table *ht, uint64 key, uint64 value)
{
    80007390:	7139                	addi	sp,sp,-64
    80007392:	fc06                	sd	ra,56(sp)
    80007394:	f822                	sd	s0,48(sp)
    80007396:	f426                	sd	s1,40(sp)
    80007398:	f04a                	sd	s2,32(sp)
    8000739a:	ec4e                	sd	s3,24(sp)
    8000739c:	e852                	sd	s4,16(sp)
    8000739e:	e456                	sd	s5,8(sp)
    800073a0:	0080                	addi	s0,sp,64
    800073a2:	89aa                	mv	s3,a0
    800073a4:	84ae                	mv	s1,a1
    800073a6:	8a32                	mv	s4,a2
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);
    800073a8:	03f5f913          	andi	s2,a1,63
    800073ac:	00591a93          	slli	s5,s2,0x5
    800073b0:	6108                	ld	a0,0(a0)
    800073b2:	9556                	add	a0,a0,s5
    800073b4:	ffff9097          	auipc	ra,0xffff9
    800073b8:	7e8080e7          	jalr	2024(ra) # 80000b9c <acquire>

  // Reject duplicate keys for simplicity.
  struct rcu_hnode *p = ht->bucket[idx];
    800073bc:	090e                	slli	s2,s2,0x3
    800073be:	994e                	add	s2,s2,s3
    800073c0:	00893783          	ld	a5,8(s2)
  while (p) {
    800073c4:	c791                	beqz	a5,800073d0 <rcu_hash_insert+0x40>
    if (p->key == key) {
    800073c6:	6f98                	ld	a4,24(a5)
    800073c8:	04970463          	beq	a4,s1,80007410 <rcu_hash_insert+0x80>
      release(&ht->lock[idx]);
      return -1;
    }
    p = p->next;
    800073cc:	6b9c                	ld	a5,16(a5)
  while (p) {
    800073ce:	ffe5                	bnez	a5,800073c6 <rcu_hash_insert+0x36>
  }

  struct rcu_hnode *node = (struct rcu_hnode *)kalloc();
    800073d0:	ffff9097          	auipc	ra,0xffff9
    800073d4:	67c080e7          	jalr	1660(ra) # 80000a4c <kalloc>
  if (node == 0) {
    800073d8:	c529                	beqz	a0,80007422 <rcu_hash_insert+0x92>
    release(&ht->lock[idx]);
    return -1;
  }

  node->key = key;
    800073da:	ed04                	sd	s1,24(a0)
  node->value = value;
    800073dc:	03453023          	sd	s4,32(a0)

  // Insert at bucket head.
  node->next = ht->bucket[idx];
    800073e0:	00893783          	ld	a5,8(s2)
    800073e4:	e91c                	sd	a5,16(a0)
  rcu_assign_pointer(ht->bucket[idx], node);
    800073e6:	0ff0000f          	fence
    800073ea:	00a93423          	sd	a0,8(s2)

  release(&ht->lock[idx]);
    800073ee:	0009b503          	ld	a0,0(s3)
    800073f2:	9556                	add	a0,a0,s5
    800073f4:	ffffa097          	auipc	ra,0xffffa
    800073f8:	878080e7          	jalr	-1928(ra) # 80000c6c <release>
  return 0;
    800073fc:	4501                	li	a0,0
}
    800073fe:	70e2                	ld	ra,56(sp)
    80007400:	7442                	ld	s0,48(sp)
    80007402:	74a2                	ld	s1,40(sp)
    80007404:	7902                	ld	s2,32(sp)
    80007406:	69e2                	ld	s3,24(sp)
    80007408:	6a42                	ld	s4,16(sp)
    8000740a:	6aa2                	ld	s5,8(sp)
    8000740c:	6121                	addi	sp,sp,64
    8000740e:	8082                	ret
      release(&ht->lock[idx]);
    80007410:	0009b503          	ld	a0,0(s3)
    80007414:	9556                	add	a0,a0,s5
    80007416:	ffffa097          	auipc	ra,0xffffa
    8000741a:	856080e7          	jalr	-1962(ra) # 80000c6c <release>
      return -1;
    8000741e:	557d                	li	a0,-1
    80007420:	bff9                	j	800073fe <rcu_hash_insert+0x6e>
    release(&ht->lock[idx]);
    80007422:	0009b503          	ld	a0,0(s3)
    80007426:	9556                	add	a0,a0,s5
    80007428:	ffffa097          	auipc	ra,0xffffa
    8000742c:	844080e7          	jalr	-1980(ra) # 80000c6c <release>
    return -1;
    80007430:	557d                	li	a0,-1
    80007432:	b7f1                	j	800073fe <rcu_hash_insert+0x6e>

0000000080007434 <rcu_hash_lookup>:

// Lookup must be called inside an RCU read-side critical section.
int
rcu_hash_lookup(struct rcu_hash_table *ht, uint64 key, uint64 *valuep)
{
    80007434:	7179                	addi	sp,sp,-48
    80007436:	f406                	sd	ra,40(sp)
    80007438:	f022                	sd	s0,32(sp)
    8000743a:	ec26                	sd	s1,24(sp)
    8000743c:	e84a                	sd	s2,16(sp)
    8000743e:	e44e                	sd	s3,8(sp)
    80007440:	1800                	addi	s0,sp,48
    80007442:	892a                	mv	s2,a0
    80007444:	84ae                	mv	s1,a1
    80007446:	89b2                	mv	s3,a2
  int idx = hash_key(key);
  int found = 0;

  rcu_read_lock();
    80007448:	00000097          	auipc	ra,0x0
    8000744c:	d4c080e7          	jalr	-692(ra) # 80007194 <rcu_read_lock>

  struct rcu_hnode *p = rcu_dereference(ht->bucket[idx]);
    80007450:	0ff0000f          	fence
    80007454:	03f4f513          	andi	a0,s1,63
    80007458:	050e                	slli	a0,a0,0x3
    8000745a:	992a                	add	s2,s2,a0
    8000745c:	00893783          	ld	a5,8(s2)
  while (p) {
    80007460:	cb95                	beqz	a5,80007494 <rcu_hash_lookup+0x60>
    if (p->key == key) {
    80007462:	6f98                	ld	a4,24(a5)
    80007464:	02970163          	beq	a4,s1,80007486 <rcu_hash_lookup+0x52>
      if (valuep)
        *valuep = p->value;
      found = 1;
      break;
    }
    p = p->next;
    80007468:	6b9c                	ld	a5,16(a5)
  while (p) {
    8000746a:	ffe5                	bnez	a5,80007462 <rcu_hash_lookup+0x2e>
  int found = 0;
    8000746c:	4481                	li	s1,0
  }

  rcu_read_unlock();
    8000746e:	00000097          	auipc	ra,0x0
    80007472:	d5e080e7          	jalr	-674(ra) # 800071cc <rcu_read_unlock>
  return found;
}
    80007476:	8526                	mv	a0,s1
    80007478:	70a2                	ld	ra,40(sp)
    8000747a:	7402                	ld	s0,32(sp)
    8000747c:	64e2                	ld	s1,24(sp)
    8000747e:	6942                	ld	s2,16(sp)
    80007480:	69a2                	ld	s3,8(sp)
    80007482:	6145                	addi	sp,sp,48
    80007484:	8082                	ret
      found = 1;
    80007486:	4485                	li	s1,1
      if (valuep)
    80007488:	fe0983e3          	beqz	s3,8000746e <rcu_hash_lookup+0x3a>
        *valuep = p->value;
    8000748c:	739c                	ld	a5,32(a5)
    8000748e:	00f9b023          	sd	a5,0(s3)
    80007492:	bff1                	j	8000746e <rcu_hash_lookup+0x3a>
  int found = 0;
    80007494:	4481                	li	s1,0
    80007496:	bfe1                	j	8000746e <rcu_hash_lookup+0x3a>

0000000080007498 <rcu_hash_remove>:

// Remove a key and defer freeing its node via RCU.
int
rcu_hash_remove(struct rcu_hash_table *ht, uint64 key)
{
    80007498:	7179                	addi	sp,sp,-48
    8000749a:	f406                	sd	ra,40(sp)
    8000749c:	f022                	sd	s0,32(sp)
    8000749e:	ec26                	sd	s1,24(sp)
    800074a0:	e84a                	sd	s2,16(sp)
    800074a2:	e44e                	sd	s3,8(sp)
    800074a4:	e052                	sd	s4,0(sp)
    800074a6:	1800                	addi	s0,sp,48
    800074a8:	89aa                	mv	s3,a0
    800074aa:	892e                	mv	s2,a1
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);
    800074ac:	03f5f493          	andi	s1,a1,63
    800074b0:	00549a13          	slli	s4,s1,0x5
    800074b4:	6108                	ld	a0,0(a0)
    800074b6:	9552                	add	a0,a0,s4
    800074b8:	ffff9097          	auipc	ra,0xffff9
    800074bc:	6e4080e7          	jalr	1764(ra) # 80000b9c <acquire>

  struct rcu_hnode *prev = 0;
  struct rcu_hnode *p = ht->bucket[idx];
    800074c0:	048e                	slli	s1,s1,0x3
    800074c2:	009986b3          	add	a3,s3,s1
    800074c6:	6684                	ld	s1,8(a3)

  while (p) {
    800074c8:	c891                	beqz	s1,800074dc <rcu_hash_remove+0x44>
  struct rcu_hnode *prev = 0;
    800074ca:	4701                	li	a4,0
    800074cc:	a011                	j	800074d0 <rcu_hash_remove+0x38>
    if (p->key == key)
      break;
    prev = p;
    p = p->next;
    800074ce:	84be                	mv	s1,a5
    if (p->key == key)
    800074d0:	6c9c                	ld	a5,24(s1)
    800074d2:	03278363          	beq	a5,s2,800074f8 <rcu_hash_remove+0x60>
    p = p->next;
    800074d6:	689c                	ld	a5,16(s1)
  while (p) {
    800074d8:	8726                	mv	a4,s1
    800074da:	fbf5                	bnez	a5,800074ce <rcu_hash_remove+0x36>
  }

  if (p == 0) {
    release(&ht->lock[idx]);
    800074dc:	0009b503          	ld	a0,0(s3)
    800074e0:	9552                	add	a0,a0,s4
    800074e2:	ffff9097          	auipc	ra,0xffff9
    800074e6:	78a080e7          	jalr	1930(ra) # 80000c6c <release>
    return 0;
    800074ea:	4501                	li	a0,0
    800074ec:	a815                	j	80007520 <rcu_hash_remove+0x88>

  // Unlink from the bucket list.
  if (prev)
    prev->next = p->next;
  else
    rcu_assign_pointer(ht->bucket[idx], p->next);
    800074ee:	0ff0000f          	fence
    800074f2:	689c                	ld	a5,16(s1)
    800074f4:	e69c                	sd	a5,8(a3)
    800074f6:	a021                	j	800074fe <rcu_hash_remove+0x66>
  if (prev)
    800074f8:	db7d                	beqz	a4,800074ee <rcu_hash_remove+0x56>
    prev->next = p->next;
    800074fa:	689c                	ld	a5,16(s1)
    800074fc:	eb1c                	sd	a5,16(a4)

  release(&ht->lock[idx]);
    800074fe:	0009b503          	ld	a0,0(s3)
    80007502:	9552                	add	a0,a0,s4
    80007504:	ffff9097          	auipc	ra,0xffff9
    80007508:	768080e7          	jalr	1896(ra) # 80000c6c <release>

  // Actual free happens after a grace period.
  call_rcu(&p->rcu, rcu_hnode_free_cb);
    8000750c:	00000597          	auipc	a1,0x0
    80007510:	df858593          	addi	a1,a1,-520 # 80007304 <rcu_hnode_free_cb>
    80007514:	8526                	mv	a0,s1
    80007516:	00000097          	auipc	ra,0x0
    8000751a:	cee080e7          	jalr	-786(ra) # 80007204 <call_rcu>
  return 1;
    8000751e:	4505                	li	a0,1
}
    80007520:	70a2                	ld	ra,40(sp)
    80007522:	7402                	ld	s0,32(sp)
    80007524:	64e2                	ld	s1,24(sp)
    80007526:	6942                	ld	s2,16(sp)
    80007528:	69a2                	ld	s3,8(sp)
    8000752a:	6a02                	ld	s4,0(sp)
    8000752c:	6145                	addi	sp,sp,48
    8000752e:	8082                	ret
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
