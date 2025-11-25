
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	42013103          	ld	sp,1056(sp) # 8000a420 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	45e70713          	addi	a4,a4,1118 # 8000a4b0 <timer_scratch>
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
    80000068:	d5c78793          	addi	a5,a5,-676 # 80005dc0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc6f47>
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
    8000012e:	4c650513          	addi	a0,a0,1222 # 800125f0 <cons>
    80000132:	00001097          	auipc	ra,0x1
    80000136:	a6a080e7          	jalr	-1430(ra) # 80000b9c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000013a:	00012497          	auipc	s1,0x12
    8000013e:	4b648493          	addi	s1,s1,1206 # 800125f0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000142:	89a6                	mv	s3,s1
    80000144:	00012917          	auipc	s2,0x12
    80000148:	54c90913          	addi	s2,s2,1356 # 80012690 <cons+0xa0>
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
    80000166:	a06080e7          	jalr	-1530(ra) # 80001b68 <myproc>
    8000016a:	5d1c                	lw	a5,56(a0)
    8000016c:	e7b5                	bnez	a5,800001d8 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000016e:	85ce                	mv	a1,s3
    80000170:	854a                	mv	a0,s2
    80000172:	00002097          	auipc	ra,0x2
    80000176:	1c4080e7          	jalr	452(ra) # 80002336 <sleep>
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
    800001b2:	3ea080e7          	jalr	1002(ra) # 80002598 <either_copyout>
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
    800001c6:	42e50513          	addi	a0,a0,1070 # 800125f0 <cons>
    800001ca:	00001097          	auipc	ra,0x1
    800001ce:	aa2080e7          	jalr	-1374(ra) # 80000c6c <release>

  return target - n;
    800001d2:	414b853b          	subw	a0,s7,s4
    800001d6:	a811                	j	800001ea <consoleread+0xe8>
        release(&cons.lock);
    800001d8:	00012517          	auipc	a0,0x12
    800001dc:	41850513          	addi	a0,a0,1048 # 800125f0 <cons>
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
    80000214:	48f72023          	sw	a5,1152(a4) # 80012690 <cons+0xa0>
    80000218:	b76d                	j	800001c2 <consoleread+0xc0>

000000008000021a <consputc>:
  if(panicked){
    8000021a:	0000a797          	auipc	a5,0xa
    8000021e:	2267a783          	lw	a5,550(a5) # 8000a440 <panicked>
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
    80000284:	37050513          	addi	a0,a0,880 # 800125f0 <cons>
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
    800002a6:	34c080e7          	jalr	844(ra) # 800025ee <either_copyin>
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
    800002c6:	32e50513          	addi	a0,a0,814 # 800125f0 <cons>
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
    800002fc:	2f850513          	addi	a0,a0,760 # 800125f0 <cons>
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
    80000322:	326080e7          	jalr	806(ra) # 80002644 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000326:	00012517          	auipc	a0,0x12
    8000032a:	2ca50513          	addi	a0,a0,714 # 800125f0 <cons>
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
    8000034e:	2a670713          	addi	a4,a4,678 # 800125f0 <cons>
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
    80000378:	27c78793          	addi	a5,a5,636 # 800125f0 <cons>
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
    800003a6:	2ee7a783          	lw	a5,750(a5) # 80012690 <cons+0xa0>
    800003aa:	0807879b          	addiw	a5,a5,128
    800003ae:	f6f61ce3          	bne	a2,a5,80000326 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003b2:	863e                	mv	a2,a5
    800003b4:	a07d                	j	80000462 <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	23a70713          	addi	a4,a4,570 # 800125f0 <cons>
    800003be:	0a872783          	lw	a5,168(a4)
    800003c2:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c6:	00012497          	auipc	s1,0x12
    800003ca:	22a48493          	addi	s1,s1,554 # 800125f0 <cons>
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
    80000406:	1ee70713          	addi	a4,a4,494 # 800125f0 <cons>
    8000040a:	0a872783          	lw	a5,168(a4)
    8000040e:	0a472703          	lw	a4,164(a4)
    80000412:	f0f70ae3          	beq	a4,a5,80000326 <consoleintr+0x3c>
      cons.e--;
    80000416:	37fd                	addiw	a5,a5,-1
    80000418:	00012717          	auipc	a4,0x12
    8000041c:	28f72023          	sw	a5,640(a4) # 80012698 <cons+0xa8>
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
    80000442:	1b278793          	addi	a5,a5,434 # 800125f0 <cons>
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
    80000466:	22c7a923          	sw	a2,562(a5) # 80012694 <cons+0xa4>
        wakeup(&cons.r);
    8000046a:	00012517          	auipc	a0,0x12
    8000046e:	22650513          	addi	a0,a0,550 # 80012690 <cons+0xa0>
    80000472:	00002097          	auipc	ra,0x2
    80000476:	04a080e7          	jalr	74(ra) # 800024bc <wakeup>
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
    80000490:	16450513          	addi	a0,a0,356 # 800125f0 <cons>
    80000494:	00000097          	auipc	ra,0x0
    80000498:	632080e7          	jalr	1586(ra) # 80000ac6 <initlock>

  uartinit();
    8000049c:	00000097          	auipc	ra,0x0
    800004a0:	3f6080e7          	jalr	1014(ra) # 80000892 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004a4:	00036797          	auipc	a5,0x36
    800004a8:	1e478793          	addi	a5,a5,484 # 80036688 <devsw>
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
    8000057a:	1407a523          	sw	zero,330(a5) # 800126c0 <pr+0x20>
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
    800005c6:	e6f72f23          	sw	a5,-386(a4) # 8000a440 <panicked>
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
    80000602:	0c2c2c03          	lw	s8,194(s8) # 800126c0 <pr+0x20>
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
    80000642:	06250513          	addi	a0,a0,98 # 800126a0 <pr>
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
    800007e8:	ebc50513          	addi	a0,a0,-324 # 800126a0 <pr>
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
    8000086e:	e3648493          	addi	s1,s1,-458 # 800126a0 <pr>
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
    8000095e:	f5e78793          	addi	a5,a5,-162 # 800378b8 <end>
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
    8000097e:	d4e90913          	addi	s2,s2,-690 # 800126c8 <kmem>
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
    80000a24:	ca850513          	addi	a0,a0,-856 # 800126c8 <kmem>
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	09e080e7          	jalr	158(ra) # 80000ac6 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a30:	45c5                	li	a1,17
    80000a32:	05ee                	slli	a1,a1,0x1b
    80000a34:	00037517          	auipc	a0,0x37
    80000a38:	e8450513          	addi	a0,a0,-380 # 800378b8 <end>
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
    80000a5a:	c7248493          	addi	s1,s1,-910 # 800126c8 <kmem>
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	13c080e7          	jalr	316(ra) # 80000b9c <acquire>
  r = kmem.freelist;
    80000a68:	7084                	ld	s1,32(s1)
  if(r){
    80000a6a:	c89d                	beqz	s1,80000aa0 <kalloc+0x54>
    kmem.freelist = r->next;
    80000a6c:	609c                	ld	a5,0(s1)
    80000a6e:	00012517          	auipc	a0,0x12
    80000a72:	c5a50513          	addi	a0,a0,-934 # 800126c8 <kmem>
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
    80000aa0:	00012517          	auipc	a0,0x12
    80000aa4:	c2850513          	addi	a0,a0,-984 # 800126c8 <kmem>
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
    80000ab8:	00012517          	auipc	a0,0x12
    80000abc:	c3853503          	ld	a0,-968(a0) # 800126f0 <kmem+0x28>
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
    80000ad8:	0000a797          	auipc	a5,0xa
    80000adc:	96c7a783          	lw	a5,-1684(a5) # 8000a444 <nlock>
    80000ae0:	6709                	lui	a4,0x2
    80000ae2:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000ae6:	02f74063          	blt	a4,a5,80000b06 <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000aea:	00379693          	slli	a3,a5,0x3
    80000aee:	00012717          	auipc	a4,0x12
    80000af2:	c0a70713          	addi	a4,a4,-1014 # 800126f8 <locks>
    80000af6:	9736                	add	a4,a4,a3
    80000af8:	e308                	sd	a0,0(a4)
  nlock++;
    80000afa:	2785                	addiw	a5,a5,1
    80000afc:	0000a717          	auipc	a4,0xa
    80000b00:	94f72423          	sw	a5,-1720(a4) # 8000a444 <nlock>
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
    80000b36:	01a080e7          	jalr	26(ra) # 80001b4c <mycpu>
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
    80000b6c:	fe4080e7          	jalr	-28(ra) # 80001b4c <mycpu>
    80000b70:	5d3c                	lw	a5,120(a0)
    80000b72:	cf89                	beqz	a5,80000b8c <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b74:	00001097          	auipc	ra,0x1
    80000b78:	fd8080e7          	jalr	-40(ra) # 80001b4c <mycpu>
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
    80000b90:	fc0080e7          	jalr	-64(ra) # 80001b4c <mycpu>
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
    80000bfc:	f54080e7          	jalr	-172(ra) # 80001b4c <mycpu>
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
    80000c20:	f30080e7          	jalr	-208(ra) # 80001b4c <mycpu>
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
    80000d02:	f8a080e7          	jalr	-118(ra) # 80002c88 <argint>
    80000d06:	12054463          	bltz	a0,80000e2e <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d0a:	fac42783          	lw	a5,-84(s0)
    80000d0e:	e39d                	bnez	a5,80000d34 <sys_ntas+0x56>
    80000d10:	00012797          	auipc	a5,0x12
    80000d14:	9e878793          	addi	a5,a5,-1560 # 800126f8 <locks>
    80000d18:	00025697          	auipc	a3,0x25
    80000d1c:	26068693          	addi	a3,a3,608 # 80025f78 <pid_lock>
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
    80000d44:	00012b17          	auipc	s6,0x12
    80000d48:	9b4b0b13          	addi	s6,s6,-1612 # 800126f8 <locks>
    80000d4c:	00025b97          	auipc	s7,0x25
    80000d50:	22cb8b93          	addi	s7,s7,556 # 80025f78 <pid_lock>
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
    80000dba:	00012497          	auipc	s1,0x12
    80000dbe:	93e48493          	addi	s1,s1,-1730 # 800126f8 <locks>
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
extern void rcu_worker(void);
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void main()
{
    8000105a:	1141                	addi	sp,sp,-16
    8000105c:	e406                	sd	ra,8(sp)
    8000105e:	e022                	sd	s0,0(sp)
    80001060:	0800                	addi	s0,sp,16
  if (cpuid() == 0)
    80001062:	00001097          	auipc	ra,0x1
    80001066:	ada080e7          	jalr	-1318(ra) # 80001b3c <cpuid>
    __sync_synchronize();
    started = 1;
  }
  else
  {
    while (started == 0)
    8000106a:	00009717          	auipc	a4,0x9
    8000106e:	3de70713          	addi	a4,a4,990 # 8000a448 <started>
  if (cpuid() == 0)
    80001072:	c139                	beqz	a0,800010b8 <main+0x5e>
    while (started == 0)
    80001074:	431c                	lw	a5,0(a4)
    80001076:	2781                	sext.w	a5,a5
    80001078:	dff5                	beqz	a5,80001074 <main+0x1a>
      ;
    __sync_synchronize();
    8000107a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000107e:	00001097          	auipc	ra,0x1
    80001082:	abe080e7          	jalr	-1346(ra) # 80001b3c <cpuid>
    80001086:	85aa                	mv	a1,a0
    80001088:	00008517          	auipc	a0,0x8
    8000108c:	1d050513          	addi	a0,a0,464 # 80009258 <digits+0xe8>
    80001090:	fffff097          	auipc	ra,0xfffff
    80001094:	53c080e7          	jalr	1340(ra) # 800005cc <printf>
    kvminithart();  // turn on paging
    80001098:	00000097          	auipc	ra,0x0
    8000109c:	1f8080e7          	jalr	504(ra) # 80001290 <kvminithart>
    trapinithart(); // install kernel trap vector
    800010a0:	00001097          	auipc	ra,0x1
    800010a4:	77e080e7          	jalr	1918(ra) # 8000281e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    800010a8:	00005097          	auipc	ra,0x5
    800010ac:	d58080e7          	jalr	-680(ra) # 80005e00 <plicinithart>
  }

  scheduler();
    800010b0:	00001097          	auipc	ra,0x1
    800010b4:	f9e080e7          	jalr	-98(ra) # 8000204e <scheduler>
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
    kinit();            // physical page allocator
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	918080e7          	jalr	-1768(ra) # 80000a10 <kinit>
    kvminit();          // create kernel page table
    80001100:	00000097          	auipc	ra,0x0
    80001104:	2ce080e7          	jalr	718(ra) # 800013ce <kvminit>
    kvminithart();      // turn on paging
    80001108:	00000097          	auipc	ra,0x0
    8000110c:	188080e7          	jalr	392(ra) # 80001290 <kvminithart>
    procinit();         // process table
    80001110:	00001097          	auipc	ra,0x1
    80001114:	95c080e7          	jalr	-1700(ra) # 80001a6c <procinit>
    trapinit();         // trap vectors
    80001118:	00001097          	auipc	ra,0x1
    8000111c:	6de080e7          	jalr	1758(ra) # 800027f6 <trapinit>
    trapinithart();     // install kernel trap vector
    80001120:	00001097          	auipc	ra,0x1
    80001124:	6fe080e7          	jalr	1790(ra) # 8000281e <trapinithart>
    plicinit();         // set up interrupt controller
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	cc2080e7          	jalr	-830(ra) # 80005dea <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80001130:	00005097          	auipc	ra,0x5
    80001134:	cd0080e7          	jalr	-816(ra) # 80005e00 <plicinithart>
    binit();            // buffer cache
    80001138:	00002097          	auipc	ra,0x2
    8000113c:	eb4080e7          	jalr	-332(ra) # 80002fec <binit>
    iinit();            // inode cache
    80001140:	00002097          	auipc	ra,0x2
    80001144:	544080e7          	jalr	1348(ra) # 80003684 <iinit>
    fileinit();         // file table
    80001148:	00003097          	auipc	ra,0x3
    8000114c:	4dc080e7          	jalr	1244(ra) # 80004624 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001150:	00005097          	auipc	ra,0x5
    80001154:	da8080e7          	jalr	-600(ra) # 80005ef8 <virtio_disk_init>
    rcu_init();
    80001158:	00006097          	auipc	ra,0x6
    8000115c:	f36080e7          	jalr	-202(ra) # 8000708e <rcu_init>
    test_rcu();
    80001160:	00006097          	auipc	ra,0x6
    80001164:	478080e7          	jalr	1144(ra) # 800075d8 <test_rcu>
    userinit(); // first user process
    80001168:	00001097          	auipc	ra,0x1
    8000116c:	c80080e7          	jalr	-896(ra) # 80001de8 <userinit>
    __sync_synchronize();
    80001170:	0ff0000f          	fence
    started = 1;
    80001174:	4785                	li	a5,1
    80001176:	00009717          	auipc	a4,0x9
    8000117a:	2cf72923          	sw	a5,722(a4) # 8000a448 <started>
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
    8000129a:	1ba7b783          	ld	a5,442(a5) # 8000a450 <kernel_pagetable>
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
    800013a8:	0ac53503          	ld	a0,172(a0) # 8000a450 <kernel_pagetable>
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
    800013e4:	06a7b823          	sd	a0,112(a5) # 8000a450 <kernel_pagetable>
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
  if (!holding(&p->lock))
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	0ea080e7          	jalr	234(ra) # 80000b1e <holding>
    80001a3c:	c909                	beqz	a0,80001a4e <wakeup1+0x26>
    panic("wakeup1");
  if (p->chan == p && p->state == SLEEPING)
    80001a3e:	789c                	ld	a5,48(s1)
    80001a40:	00978f63          	beq	a5,s1,80001a5e <wakeup1+0x36>
  {
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
  if (p->chan == p && p->state == SLEEPING)
    80001a5e:	5098                	lw	a4,32(s1)
    80001a60:	4785                	li	a5,1
    80001a62:	fef711e3          	bne	a4,a5,80001a44 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a66:	4789                	li	a5,2
    80001a68:	d09c                	sw	a5,32(s1)
}
    80001a6a:	bfe9                	j	80001a44 <wakeup1+0x1c>

0000000080001a6c <procinit>:
{
    80001a6c:	715d                	addi	sp,sp,-80
    80001a6e:	e486                	sd	ra,72(sp)
    80001a70:	e0a2                	sd	s0,64(sp)
    80001a72:	fc26                	sd	s1,56(sp)
    80001a74:	f84a                	sd	s2,48(sp)
    80001a76:	f44e                	sd	s3,40(sp)
    80001a78:	f052                	sd	s4,32(sp)
    80001a7a:	ec56                	sd	s5,24(sp)
    80001a7c:	e85a                	sd	s6,16(sp)
    80001a7e:	e45e                	sd	s7,8(sp)
    80001a80:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a82:	00008597          	auipc	a1,0x8
    80001a86:	91658593          	addi	a1,a1,-1770 # 80009398 <digits+0x228>
    80001a8a:	00024517          	auipc	a0,0x24
    80001a8e:	4ee50513          	addi	a0,a0,1262 # 80025f78 <pid_lock>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	034080e7          	jalr	52(ra) # 80000ac6 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a9a:	00025917          	auipc	s2,0x25
    80001a9e:	8fe90913          	addi	s2,s2,-1794 # 80026398 <proc>
    initlock(&p->lock, "proc");
    80001aa2:	00008b97          	auipc	s7,0x8
    80001aa6:	8feb8b93          	addi	s7,s7,-1794 # 800093a0 <digits+0x230>
    uint64 va = KSTACK((int)(p - proc));
    80001aaa:	8b4a                	mv	s6,s2
    80001aac:	00007a97          	auipc	s5,0x7
    80001ab0:	554a8a93          	addi	s5,s5,1364 # 80009000 <etext>
    80001ab4:	040009b7          	lui	s3,0x4000
    80001ab8:	19fd                	addi	s3,s3,-1
    80001aba:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001abc:	0002aa17          	auipc	s4,0x2a
    80001ac0:	6dca0a13          	addi	s4,s4,1756 # 8002c198 <tickslock>
    initlock(&p->lock, "proc");
    80001ac4:	85de                	mv	a1,s7
    80001ac6:	854a                	mv	a0,s2
    80001ac8:	fffff097          	auipc	ra,0xfffff
    80001acc:	ffe080e7          	jalr	-2(ra) # 80000ac6 <initlock>
    char *pa = kalloc();
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	f7c080e7          	jalr	-132(ra) # 80000a4c <kalloc>
    80001ad8:	85aa                	mv	a1,a0
    if (pa == 0)
    80001ada:	c929                	beqz	a0,80001b2c <procinit+0xc0>
    uint64 va = KSTACK((int)(p - proc));
    80001adc:	416904b3          	sub	s1,s2,s6
    80001ae0:	848d                	srai	s1,s1,0x3
    80001ae2:	000ab783          	ld	a5,0(s5)
    80001ae6:	02f484b3          	mul	s1,s1,a5
    80001aea:	2485                	addiw	s1,s1,1
    80001aec:	00d4949b          	slliw	s1,s1,0xd
    80001af0:	409984b3          	sub	s1,s3,s1
    kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001af4:	4699                	li	a3,6
    80001af6:	6605                	lui	a2,0x1
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	89c080e7          	jalr	-1892(ra) # 80001396 <kvmmap>
    p->kstack = va;
    80001b02:	04993423          	sd	s1,72(s2)
  for (p = proc; p < &proc[NPROC]; p++)
    80001b06:	17890913          	addi	s2,s2,376
    80001b0a:	fb491de3          	bne	s2,s4,80001ac4 <procinit+0x58>
  kvminithart();
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	782080e7          	jalr	1922(ra) # 80001290 <kvminithart>
}
    80001b16:	60a6                	ld	ra,72(sp)
    80001b18:	6406                	ld	s0,64(sp)
    80001b1a:	74e2                	ld	s1,56(sp)
    80001b1c:	7942                	ld	s2,48(sp)
    80001b1e:	79a2                	ld	s3,40(sp)
    80001b20:	7a02                	ld	s4,32(sp)
    80001b22:	6ae2                	ld	s5,24(sp)
    80001b24:	6b42                	ld	s6,16(sp)
    80001b26:	6ba2                	ld	s7,8(sp)
    80001b28:	6161                	addi	sp,sp,80
    80001b2a:	8082                	ret
      panic("kalloc");
    80001b2c:	00008517          	auipc	a0,0x8
    80001b30:	87c50513          	addi	a0,a0,-1924 # 800093a8 <digits+0x238>
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	a36080e7          	jalr	-1482(ra) # 8000056a <panic>

0000000080001b3c <cpuid>:
{
    80001b3c:	1141                	addi	sp,sp,-16
    80001b3e:	e422                	sd	s0,8(sp)
    80001b40:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b42:	8512                	mv	a0,tp
}
    80001b44:	2501                	sext.w	a0,a0
    80001b46:	6422                	ld	s0,8(sp)
    80001b48:	0141                	addi	sp,sp,16
    80001b4a:	8082                	ret

0000000080001b4c <mycpu>:
{
    80001b4c:	1141                	addi	sp,sp,-16
    80001b4e:	e422                	sd	s0,8(sp)
    80001b50:	0800                	addi	s0,sp,16
    80001b52:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b54:	2781                	sext.w	a5,a5
    80001b56:	079e                	slli	a5,a5,0x7
}
    80001b58:	00024517          	auipc	a0,0x24
    80001b5c:	44050513          	addi	a0,a0,1088 # 80025f98 <cpus>
    80001b60:	953e                	add	a0,a0,a5
    80001b62:	6422                	ld	s0,8(sp)
    80001b64:	0141                	addi	sp,sp,16
    80001b66:	8082                	ret

0000000080001b68 <myproc>:
{
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	addi	s0,sp,32
  push_off();
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	fda080e7          	jalr	-38(ra) # 80000b4c <push_off>
    80001b7a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b7c:	2781                	sext.w	a5,a5
    80001b7e:	079e                	slli	a5,a5,0x7
    80001b80:	00024717          	auipc	a4,0x24
    80001b84:	3f870713          	addi	a4,a4,1016 # 80025f78 <pid_lock>
    80001b88:	97ba                	add	a5,a5,a4
    80001b8a:	7384                	ld	s1,32(a5)
  pop_off();
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	080080e7          	jalr	128(ra) # 80000c0c <pop_off>
}
    80001b94:	8526                	mv	a0,s1
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <forkret>:
{
    80001ba0:	1141                	addi	sp,sp,-16
    80001ba2:	e406                	sd	ra,8(sp)
    80001ba4:	e022                	sd	s0,0(sp)
    80001ba6:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001ba8:	00000097          	auipc	ra,0x0
    80001bac:	fc0080e7          	jalr	-64(ra) # 80001b68 <myproc>
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	0bc080e7          	jalr	188(ra) # 80000c6c <release>
  if (first)
    80001bb8:	00009797          	auipc	a5,0x9
    80001bbc:	8187a783          	lw	a5,-2024(a5) # 8000a3d0 <first.1841>
    80001bc0:	eb89                	bnez	a5,80001bd2 <forkret+0x32>
  usertrapret();
    80001bc2:	00001097          	auipc	ra,0x1
    80001bc6:	c74080e7          	jalr	-908(ra) # 80002836 <usertrapret>
}
    80001bca:	60a2                	ld	ra,8(sp)
    80001bcc:	6402                	ld	s0,0(sp)
    80001bce:	0141                	addi	sp,sp,16
    80001bd0:	8082                	ret
    first = 0;
    80001bd2:	00008797          	auipc	a5,0x8
    80001bd6:	7e07af23          	sw	zero,2046(a5) # 8000a3d0 <first.1841>
    fsinit(ROOTDEV);
    80001bda:	4505                	li	a0,1
    80001bdc:	00002097          	auipc	ra,0x2
    80001be0:	a28080e7          	jalr	-1496(ra) # 80003604 <fsinit>
    80001be4:	bff9                	j	80001bc2 <forkret+0x22>

0000000080001be6 <allocpid>:
{
    80001be6:	1101                	addi	sp,sp,-32
    80001be8:	ec06                	sd	ra,24(sp)
    80001bea:	e822                	sd	s0,16(sp)
    80001bec:	e426                	sd	s1,8(sp)
    80001bee:	e04a                	sd	s2,0(sp)
    80001bf0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bf2:	00024917          	auipc	s2,0x24
    80001bf6:	38690913          	addi	s2,s2,902 # 80025f78 <pid_lock>
    80001bfa:	854a                	mv	a0,s2
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	fa0080e7          	jalr	-96(ra) # 80000b9c <acquire>
  pid = nextpid;
    80001c04:	00008797          	auipc	a5,0x8
    80001c08:	7d078793          	addi	a5,a5,2000 # 8000a3d4 <nextpid>
    80001c0c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c0e:	0014871b          	addiw	a4,s1,1
    80001c12:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c14:	854a                	mv	a0,s2
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	056080e7          	jalr	86(ra) # 80000c6c <release>
}
    80001c1e:	8526                	mv	a0,s1
    80001c20:	60e2                	ld	ra,24(sp)
    80001c22:	6442                	ld	s0,16(sp)
    80001c24:	64a2                	ld	s1,8(sp)
    80001c26:	6902                	ld	s2,0(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret

0000000080001c2c <proc_pagetable>:
{
    80001c2c:	1101                	addi	sp,sp,-32
    80001c2e:	ec06                	sd	ra,24(sp)
    80001c30:	e822                	sd	s0,16(sp)
    80001c32:	e426                	sd	s1,8(sp)
    80001c34:	e04a                	sd	s2,0(sp)
    80001c36:	1000                	addi	s0,sp,32
    80001c38:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	91a080e7          	jalr	-1766(ra) # 80001554 <uvmcreate>
    80001c42:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c44:	4729                	li	a4,10
    80001c46:	00006697          	auipc	a3,0x6
    80001c4a:	3ba68693          	addi	a3,a3,954 # 80008000 <_trampoline>
    80001c4e:	6605                	lui	a2,0x1
    80001c50:	040005b7          	lui	a1,0x4000
    80001c54:	15fd                	addi	a1,a1,-1
    80001c56:	05b2                	slli	a1,a1,0xc
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	69e080e7          	jalr	1694(ra) # 800012f6 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c60:	4719                	li	a4,6
    80001c62:	06093683          	ld	a3,96(s2)
    80001c66:	6605                	lui	a2,0x1
    80001c68:	020005b7          	lui	a1,0x2000
    80001c6c:	15fd                	addi	a1,a1,-1
    80001c6e:	05b6                	slli	a1,a1,0xd
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	684080e7          	jalr	1668(ra) # 800012f6 <mappages>
}
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	60e2                	ld	ra,24(sp)
    80001c7e:	6442                	ld	s0,16(sp)
    80001c80:	64a2                	ld	s1,8(sp)
    80001c82:	6902                	ld	s2,0(sp)
    80001c84:	6105                	addi	sp,sp,32
    80001c86:	8082                	ret

0000000080001c88 <allocproc>:
{
    80001c88:	1101                	addi	sp,sp,-32
    80001c8a:	ec06                	sd	ra,24(sp)
    80001c8c:	e822                	sd	s0,16(sp)
    80001c8e:	e426                	sd	s1,8(sp)
    80001c90:	e04a                	sd	s2,0(sp)
    80001c92:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c94:	00024497          	auipc	s1,0x24
    80001c98:	70448493          	addi	s1,s1,1796 # 80026398 <proc>
    80001c9c:	0002a917          	auipc	s2,0x2a
    80001ca0:	4fc90913          	addi	s2,s2,1276 # 8002c198 <tickslock>
    acquire(&p->lock);
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	ef6080e7          	jalr	-266(ra) # 80000b9c <acquire>
    if (p->state == UNUSED)
    80001cae:	509c                	lw	a5,32(s1)
    80001cb0:	cf81                	beqz	a5,80001cc8 <allocproc+0x40>
      release(&p->lock);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	fb8080e7          	jalr	-72(ra) # 80000c6c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001cbc:	17848493          	addi	s1,s1,376
    80001cc0:	ff2492e3          	bne	s1,s2,80001ca4 <allocproc+0x1c>
  return 0;
    80001cc4:	4481                	li	s1,0
    80001cc6:	a899                	j	80001d1c <allocproc+0x94>
  p->pid = allocpid();
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	f1e080e7          	jalr	-226(ra) # 80001be6 <allocpid>
    80001cd0:	c0a8                	sw	a0,64(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	d7a080e7          	jalr	-646(ra) # 80000a4c <kalloc>
    80001cda:	892a                	mv	s2,a0
    80001cdc:	f0a8                	sd	a0,96(s1)
    80001cde:	c531                	beqz	a0,80001d2a <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	f4a080e7          	jalr	-182(ra) # 80001c2c <proc_pagetable>
    80001cea:	eca8                	sd	a0,88(s1)
  p->trap_va = TRAPFRAME;
    80001cec:	020007b7          	lui	a5,0x2000
    80001cf0:	17fd                	addi	a5,a5,-1
    80001cf2:	07b6                	slli	a5,a5,0xd
    80001cf4:	16f4b823          	sd	a5,368(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001cf8:	07000613          	li	a2,112
    80001cfc:	4581                	li	a1,0
    80001cfe:	06848513          	addi	a0,s1,104
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	17e080e7          	jalr	382(ra) # 80000e80 <memset>
  p->context.ra = (uint64)forkret;
    80001d0a:	00000797          	auipc	a5,0x0
    80001d0e:	e9678793          	addi	a5,a5,-362 # 80001ba0 <forkret>
    80001d12:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d14:	64bc                	ld	a5,72(s1)
    80001d16:	6705                	lui	a4,0x1
    80001d18:	97ba                	add	a5,a5,a4
    80001d1a:	f8bc                	sd	a5,112(s1)
}
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	60e2                	ld	ra,24(sp)
    80001d20:	6442                	ld	s0,16(sp)
    80001d22:	64a2                	ld	s1,8(sp)
    80001d24:	6902                	ld	s2,0(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret
    release(&p->lock);
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	f40080e7          	jalr	-192(ra) # 80000c6c <release>
    return 0;
    80001d34:	84ca                	mv	s1,s2
    80001d36:	b7dd                	j	80001d1c <allocproc+0x94>

0000000080001d38 <proc_freepagetable>:
{
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
    80001d44:	84aa                	mv	s1,a0
    80001d46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d48:	4681                	li	a3,0
    80001d4a:	6605                	lui	a2,0x1
    80001d4c:	040005b7          	lui	a1,0x4000
    80001d50:	15fd                	addi	a1,a1,-1
    80001d52:	05b2                	slli	a1,a1,0xc
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	738080e7          	jalr	1848(ra) # 8000148c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d5c:	4681                	li	a3,0
    80001d5e:	6605                	lui	a2,0x1
    80001d60:	020005b7          	lui	a1,0x2000
    80001d64:	15fd                	addi	a1,a1,-1
    80001d66:	05b6                	slli	a1,a1,0xd
    80001d68:	8526                	mv	a0,s1
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	722080e7          	jalr	1826(ra) # 8000148c <uvmunmap>
  if (sz > 0)
    80001d72:	00091863          	bnez	s2,80001d82 <proc_freepagetable+0x4a>
}
    80001d76:	60e2                	ld	ra,24(sp)
    80001d78:	6442                	ld	s0,16(sp)
    80001d7a:	64a2                	ld	s1,8(sp)
    80001d7c:	6902                	ld	s2,0(sp)
    80001d7e:	6105                	addi	sp,sp,32
    80001d80:	8082                	ret
    uvmfree(pagetable, sz);
    80001d82:	85ca                	mv	a1,s2
    80001d84:	8526                	mv	a0,s1
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	96c080e7          	jalr	-1684(ra) # 800016f2 <uvmfree>
}
    80001d8e:	b7e5                	j	80001d76 <proc_freepagetable+0x3e>

0000000080001d90 <freeproc>:
{
    80001d90:	1101                	addi	sp,sp,-32
    80001d92:	ec06                	sd	ra,24(sp)
    80001d94:	e822                	sd	s0,16(sp)
    80001d96:	e426                	sd	s1,8(sp)
    80001d98:	1000                	addi	s0,sp,32
    80001d9a:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001d9c:	7128                	ld	a0,96(a0)
    80001d9e:	c509                	beqz	a0,80001da8 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001da0:	fffff097          	auipc	ra,0xfffff
    80001da4:	ba6080e7          	jalr	-1114(ra) # 80000946 <kfree>
  p->trapframe = 0;
    80001da8:	0604b023          	sd	zero,96(s1)
  if (p->pagetable)
    80001dac:	6ca8                	ld	a0,88(s1)
    80001dae:	c511                	beqz	a0,80001dba <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001db0:	68ac                	ld	a1,80(s1)
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	f86080e7          	jalr	-122(ra) # 80001d38 <proc_freepagetable>
  p->pagetable = 0;
    80001dba:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001dbe:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001dc2:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001dc6:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001dca:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dce:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001dd2:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001dd6:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001dda:	0204a023          	sw	zero,32(s1)
}
    80001dde:	60e2                	ld	ra,24(sp)
    80001de0:	6442                	ld	s0,16(sp)
    80001de2:	64a2                	ld	s1,8(sp)
    80001de4:	6105                	addi	sp,sp,32
    80001de6:	8082                	ret

0000000080001de8 <userinit>:
{
    80001de8:	1101                	addi	sp,sp,-32
    80001dea:	ec06                	sd	ra,24(sp)
    80001dec:	e822                	sd	s0,16(sp)
    80001dee:	e426                	sd	s1,8(sp)
    80001df0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	e96080e7          	jalr	-362(ra) # 80001c88 <allocproc>
    80001dfa:	84aa                	mv	s1,a0
  initproc = p;
    80001dfc:	00008797          	auipc	a5,0x8
    80001e00:	64a7be23          	sd	a0,1628(a5) # 8000a458 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e04:	03400613          	li	a2,52
    80001e08:	00008597          	auipc	a1,0x8
    80001e0c:	5d858593          	addi	a1,a1,1496 # 8000a3e0 <initcode>
    80001e10:	6d28                	ld	a0,88(a0)
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	780080e7          	jalr	1920(ra) # 80001592 <uvminit>
  p->sz = PGSIZE;
    80001e1a:	6785                	lui	a5,0x1
    80001e1c:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e1e:	70b8                	ld	a4,96(s1)
    80001e20:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001e24:	70b8                	ld	a4,96(s1)
    80001e26:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e28:	4641                	li	a2,16
    80001e2a:	00007597          	auipc	a1,0x7
    80001e2e:	58658593          	addi	a1,a1,1414 # 800093b0 <digits+0x240>
    80001e32:	16048513          	addi	a0,s1,352
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	1c8080e7          	jalr	456(ra) # 80000ffe <safestrcpy>
  p->cwd = namei("/");
    80001e3e:	00007517          	auipc	a0,0x7
    80001e42:	58250513          	addi	a0,a0,1410 # 800093c0 <digits+0x250>
    80001e46:	00002097          	auipc	ra,0x2
    80001e4a:	1ec080e7          	jalr	492(ra) # 80004032 <namei>
    80001e4e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e52:	4789                	li	a5,2
    80001e54:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	e14080e7          	jalr	-492(ra) # 80000c6c <release>
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret

0000000080001e6a <growproc>:
{
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	e04a                	sd	s2,0(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	cf0080e7          	jalr	-784(ra) # 80001b68 <myproc>
    80001e80:	892a                	mv	s2,a0
  sz = p->sz;
    80001e82:	692c                	ld	a1,80(a0)
    80001e84:	0005861b          	sext.w	a2,a1
  if (n > 0)
    80001e88:	00904f63          	bgtz	s1,80001ea6 <growproc+0x3c>
  else if (n < 0)
    80001e8c:	0204cc63          	bltz	s1,80001ec4 <growproc+0x5a>
  p->sz = sz;
    80001e90:	1602                	slli	a2,a2,0x20
    80001e92:	9201                	srli	a2,a2,0x20
    80001e94:	04c93823          	sd	a2,80(s2)
  return 0;
    80001e98:	4501                	li	a0,0
}
    80001e9a:	60e2                	ld	ra,24(sp)
    80001e9c:	6442                	ld	s0,16(sp)
    80001e9e:	64a2                	ld	s1,8(sp)
    80001ea0:	6902                	ld	s2,0(sp)
    80001ea2:	6105                	addi	sp,sp,32
    80001ea4:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001ea6:	9e25                	addw	a2,a2,s1
    80001ea8:	1602                	slli	a2,a2,0x20
    80001eaa:	9201                	srli	a2,a2,0x20
    80001eac:	1582                	slli	a1,a1,0x20
    80001eae:	9181                	srli	a1,a1,0x20
    80001eb0:	6d28                	ld	a0,88(a0)
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	796080e7          	jalr	1942(ra) # 80001648 <uvmalloc>
    80001eba:	0005061b          	sext.w	a2,a0
    80001ebe:	fa69                	bnez	a2,80001e90 <growproc+0x26>
      return -1;
    80001ec0:	557d                	li	a0,-1
    80001ec2:	bfe1                	j	80001e9a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ec4:	9e25                	addw	a2,a2,s1
    80001ec6:	1602                	slli	a2,a2,0x20
    80001ec8:	9201                	srli	a2,a2,0x20
    80001eca:	1582                	slli	a1,a1,0x20
    80001ecc:	9181                	srli	a1,a1,0x20
    80001ece:	6d28                	ld	a0,88(a0)
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	734080e7          	jalr	1844(ra) # 80001604 <uvmdealloc>
    80001ed8:	0005061b          	sext.w	a2,a0
    80001edc:	bf55                	j	80001e90 <growproc+0x26>

0000000080001ede <fork>:
{
    80001ede:	7179                	addi	sp,sp,-48
    80001ee0:	f406                	sd	ra,40(sp)
    80001ee2:	f022                	sd	s0,32(sp)
    80001ee4:	ec26                	sd	s1,24(sp)
    80001ee6:	e84a                	sd	s2,16(sp)
    80001ee8:	e44e                	sd	s3,8(sp)
    80001eea:	e052                	sd	s4,0(sp)
    80001eec:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001eee:	00000097          	auipc	ra,0x0
    80001ef2:	c7a080e7          	jalr	-902(ra) # 80001b68 <myproc>
    80001ef6:	892a                	mv	s2,a0
  if ((np = allocproc()) == 0)
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	d90080e7          	jalr	-624(ra) # 80001c88 <allocproc>
    80001f00:	c175                	beqz	a0,80001fe4 <fork+0x106>
    80001f02:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f04:	05093603          	ld	a2,80(s2)
    80001f08:	6d2c                	ld	a1,88(a0)
    80001f0a:	05893503          	ld	a0,88(s2)
    80001f0e:	00000097          	auipc	ra,0x0
    80001f12:	812080e7          	jalr	-2030(ra) # 80001720 <uvmcopy>
    80001f16:	04054863          	bltz	a0,80001f66 <fork+0x88>
  np->sz = p->sz;
    80001f1a:	05093783          	ld	a5,80(s2)
    80001f1e:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    80001f22:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f26:	06093683          	ld	a3,96(s2)
    80001f2a:	87b6                	mv	a5,a3
    80001f2c:	0609b703          	ld	a4,96(s3)
    80001f30:	12068693          	addi	a3,a3,288
    80001f34:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f38:	6788                	ld	a0,8(a5)
    80001f3a:	6b8c                	ld	a1,16(a5)
    80001f3c:	6f90                	ld	a2,24(a5)
    80001f3e:	01073023          	sd	a6,0(a4)
    80001f42:	e708                	sd	a0,8(a4)
    80001f44:	eb0c                	sd	a1,16(a4)
    80001f46:	ef10                	sd	a2,24(a4)
    80001f48:	02078793          	addi	a5,a5,32
    80001f4c:	02070713          	addi	a4,a4,32
    80001f50:	fed792e3          	bne	a5,a3,80001f34 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f54:	0609b783          	ld	a5,96(s3)
    80001f58:	0607b823          	sd	zero,112(a5)
    80001f5c:	0d800493          	li	s1,216
  for (i = 0; i < NOFILE; i++)
    80001f60:	15800a13          	li	s4,344
    80001f64:	a03d                	j	80001f92 <fork+0xb4>
    freeproc(np);
    80001f66:	854e                	mv	a0,s3
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	e28080e7          	jalr	-472(ra) # 80001d90 <freeproc>
    release(&np->lock);
    80001f70:	854e                	mv	a0,s3
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	cfa080e7          	jalr	-774(ra) # 80000c6c <release>
    return -1;
    80001f7a:	54fd                	li	s1,-1
    80001f7c:	a899                	j	80001fd2 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f7e:	00002097          	auipc	ra,0x2
    80001f82:	738080e7          	jalr	1848(ra) # 800046b6 <filedup>
    80001f86:	009987b3          	add	a5,s3,s1
    80001f8a:	e388                	sd	a0,0(a5)
  for (i = 0; i < NOFILE; i++)
    80001f8c:	04a1                	addi	s1,s1,8
    80001f8e:	01448763          	beq	s1,s4,80001f9c <fork+0xbe>
    if (p->ofile[i])
    80001f92:	009907b3          	add	a5,s2,s1
    80001f96:	6388                	ld	a0,0(a5)
    80001f98:	f17d                	bnez	a0,80001f7e <fork+0xa0>
    80001f9a:	bfcd                	j	80001f8c <fork+0xae>
  np->cwd = idup(p->cwd);
    80001f9c:	15893503          	ld	a0,344(s2)
    80001fa0:	00002097          	auipc	ra,0x2
    80001fa4:	89e080e7          	jalr	-1890(ra) # 8000383e <idup>
    80001fa8:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fac:	4641                	li	a2,16
    80001fae:	16090593          	addi	a1,s2,352
    80001fb2:	16098513          	addi	a0,s3,352
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	048080e7          	jalr	72(ra) # 80000ffe <safestrcpy>
  pid = np->pid;
    80001fbe:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    80001fc2:	4789                	li	a5,2
    80001fc4:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    80001fc8:	854e                	mv	a0,s3
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	ca2080e7          	jalr	-862(ra) # 80000c6c <release>
}
    80001fd2:	8526                	mv	a0,s1
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6a02                	ld	s4,0(sp)
    80001fe0:	6145                	addi	sp,sp,48
    80001fe2:	8082                	ret
    return -1;
    80001fe4:	54fd                	li	s1,-1
    80001fe6:	b7f5                	j	80001fd2 <fork+0xf4>

0000000080001fe8 <reparent>:
{
    80001fe8:	7179                	addi	sp,sp,-48
    80001fea:	f406                	sd	ra,40(sp)
    80001fec:	f022                	sd	s0,32(sp)
    80001fee:	ec26                	sd	s1,24(sp)
    80001ff0:	e84a                	sd	s2,16(sp)
    80001ff2:	e44e                	sd	s3,8(sp)
    80001ff4:	e052                	sd	s4,0(sp)
    80001ff6:	1800                	addi	s0,sp,48
    80001ff8:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80001ffa:	00024497          	auipc	s1,0x24
    80001ffe:	39e48493          	addi	s1,s1,926 # 80026398 <proc>
      pp->parent = initproc;
    80002002:	00008a17          	auipc	s4,0x8
    80002006:	456a0a13          	addi	s4,s4,1110 # 8000a458 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000200a:	0002a997          	auipc	s3,0x2a
    8000200e:	18e98993          	addi	s3,s3,398 # 8002c198 <tickslock>
    80002012:	a029                	j	8000201c <reparent+0x34>
    80002014:	17848493          	addi	s1,s1,376
    80002018:	03348363          	beq	s1,s3,8000203e <reparent+0x56>
    if (pp->parent == p)
    8000201c:	749c                	ld	a5,40(s1)
    8000201e:	ff279be3          	bne	a5,s2,80002014 <reparent+0x2c>
      acquire(&pp->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	b78080e7          	jalr	-1160(ra) # 80000b9c <acquire>
      pp->parent = initproc;
    8000202c:	000a3783          	ld	a5,0(s4)
    80002030:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002032:	8526                	mv	a0,s1
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c38080e7          	jalr	-968(ra) # 80000c6c <release>
    8000203c:	bfe1                	j	80002014 <reparent+0x2c>
}
    8000203e:	70a2                	ld	ra,40(sp)
    80002040:	7402                	ld	s0,32(sp)
    80002042:	64e2                	ld	s1,24(sp)
    80002044:	6942                	ld	s2,16(sp)
    80002046:	69a2                	ld	s3,8(sp)
    80002048:	6a02                	ld	s4,0(sp)
    8000204a:	6145                	addi	sp,sp,48
    8000204c:	8082                	ret

000000008000204e <scheduler>:
{
    8000204e:	715d                	addi	sp,sp,-80
    80002050:	e486                	sd	ra,72(sp)
    80002052:	e0a2                	sd	s0,64(sp)
    80002054:	fc26                	sd	s1,56(sp)
    80002056:	f84a                	sd	s2,48(sp)
    80002058:	f44e                	sd	s3,40(sp)
    8000205a:	f052                	sd	s4,32(sp)
    8000205c:	ec56                	sd	s5,24(sp)
    8000205e:	e85a                	sd	s6,16(sp)
    80002060:	e45e                	sd	s7,8(sp)
    80002062:	e062                	sd	s8,0(sp)
    80002064:	0880                	addi	s0,sp,80
    80002066:	8792                	mv	a5,tp
  int id = r_tp();
    80002068:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000206a:	00779b93          	slli	s7,a5,0x7
    8000206e:	00024717          	auipc	a4,0x24
    80002072:	f0a70713          	addi	a4,a4,-246 # 80025f78 <pid_lock>
    80002076:	975e                	add	a4,a4,s7
    80002078:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    8000207c:	00024717          	auipc	a4,0x24
    80002080:	f2470713          	addi	a4,a4,-220 # 80025fa0 <cpus+0x8>
    80002084:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    80002086:	4c0d                	li	s8,3
        c->proc = p;
    80002088:	079e                	slli	a5,a5,0x7
    8000208a:	00024917          	auipc	s2,0x24
    8000208e:	eee90913          	addi	s2,s2,-274 # 80025f78 <pid_lock>
    80002092:	993e                	add	s2,s2,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002094:	0002aa17          	auipc	s4,0x2a
    80002098:	104a0a13          	addi	s4,s4,260 # 8002c198 <tickslock>
    8000209c:	a0a9                	j	800020e6 <scheduler+0x98>
        p->state = RUNNING;
    8000209e:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800020a2:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    800020a6:	06848593          	addi	a1,s1,104
    800020aa:	855e                	mv	a0,s7
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	646080e7          	jalr	1606(ra) # 800026f2 <swtch>
        c->proc = 0;
    800020b4:	02093023          	sd	zero,32(s2)
        found = 1;
    800020b8:	8ada                	mv	s5,s6
      c->intena = 0;
    800020ba:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	bac080e7          	jalr	-1108(ra) # 80000c6c <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020c8:	17848493          	addi	s1,s1,376
    800020cc:	01448b63          	beq	s1,s4,800020e2 <scheduler+0x94>
      acquire(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	aca080e7          	jalr	-1334(ra) # 80000b9c <acquire>
      if (p->state == RUNNABLE)
    800020da:	509c                	lw	a5,32(s1)
    800020dc:	fd379fe3          	bne	a5,s3,800020ba <scheduler+0x6c>
    800020e0:	bf7d                	j	8000209e <scheduler+0x50>
    if (found == 0)
    800020e2:	020a8563          	beqz	s5,8000210c <scheduler+0xbe>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020ee:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800020f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020f8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020fc:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++)
    800020fe:	00024497          	auipc	s1,0x24
    80002102:	29a48493          	addi	s1,s1,666 # 80026398 <proc>
      if (p->state == RUNNABLE)
    80002106:	4989                	li	s3,2
        found = 1;
    80002108:	4b05                	li	s6,1
    8000210a:	b7d9                	j	800020d0 <scheduler+0x82>
      rcu_poll();
    8000210c:	00005097          	auipc	ra,0x5
    80002110:	100080e7          	jalr	256(ra) # 8000720c <rcu_poll>
      asm volatile("wfi");
    80002114:	10500073          	wfi
    80002118:	b7f9                	j	800020e6 <scheduler+0x98>

000000008000211a <sched>:
{
    8000211a:	7179                	addi	sp,sp,-48
    8000211c:	f406                	sd	ra,40(sp)
    8000211e:	f022                	sd	s0,32(sp)
    80002120:	ec26                	sd	s1,24(sp)
    80002122:	e84a                	sd	s2,16(sp)
    80002124:	e44e                	sd	s3,8(sp)
    80002126:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002128:	00000097          	auipc	ra,0x0
    8000212c:	a40080e7          	jalr	-1472(ra) # 80001b68 <myproc>
    80002130:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	9ec080e7          	jalr	-1556(ra) # 80000b1e <holding>
    8000213a:	c93d                	beqz	a0,800021b0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000213c:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000213e:	2781                	sext.w	a5,a5
    80002140:	079e                	slli	a5,a5,0x7
    80002142:	00024717          	auipc	a4,0x24
    80002146:	e3670713          	addi	a4,a4,-458 # 80025f78 <pid_lock>
    8000214a:	97ba                	add	a5,a5,a4
    8000214c:	0987a703          	lw	a4,152(a5)
    80002150:	4785                	li	a5,1
    80002152:	06f71763          	bne	a4,a5,800021c0 <sched+0xa6>
  if (p->state == RUNNING)
    80002156:	5098                	lw	a4,32(s1)
    80002158:	478d                	li	a5,3
    8000215a:	06f70b63          	beq	a4,a5,800021d0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000215e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002162:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002164:	efb5                	bnez	a5,800021e0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002166:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002168:	00024917          	auipc	s2,0x24
    8000216c:	e1090913          	addi	s2,s2,-496 # 80025f78 <pid_lock>
    80002170:	2781                	sext.w	a5,a5
    80002172:	079e                	slli	a5,a5,0x7
    80002174:	97ca                	add	a5,a5,s2
    80002176:	09c7a983          	lw	s3,156(a5)
    8000217a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000217c:	2781                	sext.w	a5,a5
    8000217e:	079e                	slli	a5,a5,0x7
    80002180:	00024597          	auipc	a1,0x24
    80002184:	e2058593          	addi	a1,a1,-480 # 80025fa0 <cpus+0x8>
    80002188:	95be                	add	a1,a1,a5
    8000218a:	06848513          	addi	a0,s1,104
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	564080e7          	jalr	1380(ra) # 800026f2 <swtch>
    80002196:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002198:	2781                	sext.w	a5,a5
    8000219a:	079e                	slli	a5,a5,0x7
    8000219c:	97ca                	add	a5,a5,s2
    8000219e:	0937ae23          	sw	s3,156(a5)
}
    800021a2:	70a2                	ld	ra,40(sp)
    800021a4:	7402                	ld	s0,32(sp)
    800021a6:	64e2                	ld	s1,24(sp)
    800021a8:	6942                	ld	s2,16(sp)
    800021aa:	69a2                	ld	s3,8(sp)
    800021ac:	6145                	addi	sp,sp,48
    800021ae:	8082                	ret
    panic("sched p->lock");
    800021b0:	00007517          	auipc	a0,0x7
    800021b4:	21850513          	addi	a0,a0,536 # 800093c8 <digits+0x258>
    800021b8:	ffffe097          	auipc	ra,0xffffe
    800021bc:	3b2080e7          	jalr	946(ra) # 8000056a <panic>
    panic("sched locks");
    800021c0:	00007517          	auipc	a0,0x7
    800021c4:	21850513          	addi	a0,a0,536 # 800093d8 <digits+0x268>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	3a2080e7          	jalr	930(ra) # 8000056a <panic>
    panic("sched running");
    800021d0:	00007517          	auipc	a0,0x7
    800021d4:	21850513          	addi	a0,a0,536 # 800093e8 <digits+0x278>
    800021d8:	ffffe097          	auipc	ra,0xffffe
    800021dc:	392080e7          	jalr	914(ra) # 8000056a <panic>
    panic("sched interruptible");
    800021e0:	00007517          	auipc	a0,0x7
    800021e4:	21850513          	addi	a0,a0,536 # 800093f8 <digits+0x288>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	382080e7          	jalr	898(ra) # 8000056a <panic>

00000000800021f0 <exit>:
{
    800021f0:	7179                	addi	sp,sp,-48
    800021f2:	f406                	sd	ra,40(sp)
    800021f4:	f022                	sd	s0,32(sp)
    800021f6:	ec26                	sd	s1,24(sp)
    800021f8:	e84a                	sd	s2,16(sp)
    800021fa:	e44e                	sd	s3,8(sp)
    800021fc:	e052                	sd	s4,0(sp)
    800021fe:	1800                	addi	s0,sp,48
    80002200:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002202:	00000097          	auipc	ra,0x0
    80002206:	966080e7          	jalr	-1690(ra) # 80001b68 <myproc>
    8000220a:	89aa                	mv	s3,a0
  if (p == initproc)
    8000220c:	00008797          	auipc	a5,0x8
    80002210:	24c7b783          	ld	a5,588(a5) # 8000a458 <initproc>
    80002214:	0d850493          	addi	s1,a0,216
    80002218:	15850913          	addi	s2,a0,344
    8000221c:	02a79363          	bne	a5,a0,80002242 <exit+0x52>
    panic("init exiting");
    80002220:	00007517          	auipc	a0,0x7
    80002224:	1f050513          	addi	a0,a0,496 # 80009410 <digits+0x2a0>
    80002228:	ffffe097          	auipc	ra,0xffffe
    8000222c:	342080e7          	jalr	834(ra) # 8000056a <panic>
      fileclose(f);
    80002230:	00002097          	auipc	ra,0x2
    80002234:	4d8080e7          	jalr	1240(ra) # 80004708 <fileclose>
      p->ofile[fd] = 0;
    80002238:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    8000223c:	04a1                	addi	s1,s1,8
    8000223e:	01248563          	beq	s1,s2,80002248 <exit+0x58>
    if (p->ofile[fd])
    80002242:	6088                	ld	a0,0(s1)
    80002244:	f575                	bnez	a0,80002230 <exit+0x40>
    80002246:	bfdd                	j	8000223c <exit+0x4c>
  begin_op();
    80002248:	00002097          	auipc	ra,0x2
    8000224c:	ff6080e7          	jalr	-10(ra) # 8000423e <begin_op>
  iput(p->cwd);
    80002250:	1589b503          	ld	a0,344(s3)
    80002254:	00001097          	auipc	ra,0x1
    80002258:	7e2080e7          	jalr	2018(ra) # 80003a36 <iput>
  end_op();
    8000225c:	00002097          	auipc	ra,0x2
    80002260:	062080e7          	jalr	98(ra) # 800042be <end_op>
  p->cwd = 0;
    80002264:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002268:	00008497          	auipc	s1,0x8
    8000226c:	1f048493          	addi	s1,s1,496 # 8000a458 <initproc>
    80002270:	6088                	ld	a0,0(s1)
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	92a080e7          	jalr	-1750(ra) # 80000b9c <acquire>
  wakeup1(initproc);
    8000227a:	6088                	ld	a0,0(s1)
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	7ac080e7          	jalr	1964(ra) # 80001a28 <wakeup1>
  release(&initproc->lock);
    80002284:	6088                	ld	a0,0(s1)
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	9e6080e7          	jalr	-1562(ra) # 80000c6c <release>
  acquire(&p->lock);
    8000228e:	854e                	mv	a0,s3
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	90c080e7          	jalr	-1780(ra) # 80000b9c <acquire>
  struct proc *original_parent = p->parent;
    80002298:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    8000229c:	854e                	mv	a0,s3
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	9ce080e7          	jalr	-1586(ra) # 80000c6c <release>
  acquire(&original_parent->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	8f4080e7          	jalr	-1804(ra) # 80000b9c <acquire>
  acquire(&p->lock);
    800022b0:	854e                	mv	a0,s3
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	8ea080e7          	jalr	-1814(ra) # 80000b9c <acquire>
  reparent(p);
    800022ba:	854e                	mv	a0,s3
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	d2c080e7          	jalr	-724(ra) # 80001fe8 <reparent>
  wakeup1(original_parent);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	762080e7          	jalr	1890(ra) # 80001a28 <wakeup1>
  p->xstate = status;
    800022ce:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800022d2:	4791                	li	a5,4
    800022d4:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	992080e7          	jalr	-1646(ra) # 80000c6c <release>
  sched();
    800022e2:	00000097          	auipc	ra,0x0
    800022e6:	e38080e7          	jalr	-456(ra) # 8000211a <sched>
  panic("zombie exit");
    800022ea:	00007517          	auipc	a0,0x7
    800022ee:	13650513          	addi	a0,a0,310 # 80009420 <digits+0x2b0>
    800022f2:	ffffe097          	auipc	ra,0xffffe
    800022f6:	278080e7          	jalr	632(ra) # 8000056a <panic>

00000000800022fa <yield>:
{
    800022fa:	1101                	addi	sp,sp,-32
    800022fc:	ec06                	sd	ra,24(sp)
    800022fe:	e822                	sd	s0,16(sp)
    80002300:	e426                	sd	s1,8(sp)
    80002302:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002304:	00000097          	auipc	ra,0x0
    80002308:	864080e7          	jalr	-1948(ra) # 80001b68 <myproc>
    8000230c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	88e080e7          	jalr	-1906(ra) # 80000b9c <acquire>
  p->state = RUNNABLE;
    80002316:	4789                	li	a5,2
    80002318:	d09c                	sw	a5,32(s1)
  sched();
    8000231a:	00000097          	auipc	ra,0x0
    8000231e:	e00080e7          	jalr	-512(ra) # 8000211a <sched>
  release(&p->lock);
    80002322:	8526                	mv	a0,s1
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	948080e7          	jalr	-1720(ra) # 80000c6c <release>
}
    8000232c:	60e2                	ld	ra,24(sp)
    8000232e:	6442                	ld	s0,16(sp)
    80002330:	64a2                	ld	s1,8(sp)
    80002332:	6105                	addi	sp,sp,32
    80002334:	8082                	ret

0000000080002336 <sleep>:
{
    80002336:	7179                	addi	sp,sp,-48
    80002338:	f406                	sd	ra,40(sp)
    8000233a:	f022                	sd	s0,32(sp)
    8000233c:	ec26                	sd	s1,24(sp)
    8000233e:	e84a                	sd	s2,16(sp)
    80002340:	e44e                	sd	s3,8(sp)
    80002342:	1800                	addi	s0,sp,48
    80002344:	89aa                	mv	s3,a0
    80002346:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	820080e7          	jalr	-2016(ra) # 80001b68 <myproc>
    80002350:	84aa                	mv	s1,a0
  if (lk != &p->lock)
    80002352:	05250663          	beq	a0,s2,8000239e <sleep+0x68>
    acquire(&p->lock); // DOC: sleeplock1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	846080e7          	jalr	-1978(ra) # 80000b9c <acquire>
    release(lk);
    8000235e:	854a                	mv	a0,s2
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	90c080e7          	jalr	-1780(ra) # 80000c6c <release>
  p->chan = chan;
    80002368:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000236c:	4785                	li	a5,1
    8000236e:	d09c                	sw	a5,32(s1)
  sched();
    80002370:	00000097          	auipc	ra,0x0
    80002374:	daa080e7          	jalr	-598(ra) # 8000211a <sched>
  p->chan = 0;
    80002378:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000237c:	8526                	mv	a0,s1
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	8ee080e7          	jalr	-1810(ra) # 80000c6c <release>
    acquire(lk);
    80002386:	854a                	mv	a0,s2
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	814080e7          	jalr	-2028(ra) # 80000b9c <acquire>
}
    80002390:	70a2                	ld	ra,40(sp)
    80002392:	7402                	ld	s0,32(sp)
    80002394:	64e2                	ld	s1,24(sp)
    80002396:	6942                	ld	s2,16(sp)
    80002398:	69a2                	ld	s3,8(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
  p->chan = chan;
    8000239e:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023a2:	4785                	li	a5,1
    800023a4:	d11c                	sw	a5,32(a0)
  sched();
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	d74080e7          	jalr	-652(ra) # 8000211a <sched>
  p->chan = 0;
    800023ae:	0204b823          	sd	zero,48(s1)
  if (lk != &p->lock)
    800023b2:	bff9                	j	80002390 <sleep+0x5a>

00000000800023b4 <wait>:
{
    800023b4:	715d                	addi	sp,sp,-80
    800023b6:	e486                	sd	ra,72(sp)
    800023b8:	e0a2                	sd	s0,64(sp)
    800023ba:	fc26                	sd	s1,56(sp)
    800023bc:	f84a                	sd	s2,48(sp)
    800023be:	f44e                	sd	s3,40(sp)
    800023c0:	f052                	sd	s4,32(sp)
    800023c2:	ec56                	sd	s5,24(sp)
    800023c4:	e85a                	sd	s6,16(sp)
    800023c6:	e45e                	sd	s7,8(sp)
    800023c8:	e062                	sd	s8,0(sp)
    800023ca:	0880                	addi	s0,sp,80
    800023cc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	79a080e7          	jalr	1946(ra) # 80001b68 <myproc>
    800023d6:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023d8:	8c2a                	mv	s8,a0
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	7c2080e7          	jalr	1986(ra) # 80000b9c <acquire>
    havekids = 0;
    800023e2:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800023e4:	4a11                	li	s4,4
    for (np = proc; np < &proc[NPROC]; np++)
    800023e6:	0002a997          	auipc	s3,0x2a
    800023ea:	db298993          	addi	s3,s3,-590 # 8002c198 <tickslock>
        havekids = 1;
    800023ee:	4a85                	li	s5,1
    havekids = 0;
    800023f0:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800023f2:	00024497          	auipc	s1,0x24
    800023f6:	fa648493          	addi	s1,s1,-90 # 80026398 <proc>
    800023fa:	a08d                	j	8000245c <wait+0xa8>
          pid = np->pid;
    800023fc:	0404a983          	lw	s3,64(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002400:	000b0e63          	beqz	s6,8000241c <wait+0x68>
    80002404:	4691                	li	a3,4
    80002406:	03c48613          	addi	a2,s1,60
    8000240a:	85da                	mv	a1,s6
    8000240c:	05893503          	ld	a0,88(s2)
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	412080e7          	jalr	1042(ra) # 80001822 <copyout>
    80002418:	02054263          	bltz	a0,8000243c <wait+0x88>
          freeproc(np);
    8000241c:	8526                	mv	a0,s1
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	972080e7          	jalr	-1678(ra) # 80001d90 <freeproc>
          release(&np->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	844080e7          	jalr	-1980(ra) # 80000c6c <release>
          release(&p->lock);
    80002430:	854a                	mv	a0,s2
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	83a080e7          	jalr	-1990(ra) # 80000c6c <release>
          return pid;
    8000243a:	a8a9                	j	80002494 <wait+0xe0>
            release(&np->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	82e080e7          	jalr	-2002(ra) # 80000c6c <release>
            release(&p->lock);
    80002446:	854a                	mv	a0,s2
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	824080e7          	jalr	-2012(ra) # 80000c6c <release>
            return -1;
    80002450:	59fd                	li	s3,-1
    80002452:	a089                	j	80002494 <wait+0xe0>
    for (np = proc; np < &proc[NPROC]; np++)
    80002454:	17848493          	addi	s1,s1,376
    80002458:	03348463          	beq	s1,s3,80002480 <wait+0xcc>
      if (np->parent == p)
    8000245c:	749c                	ld	a5,40(s1)
    8000245e:	ff279be3          	bne	a5,s2,80002454 <wait+0xa0>
        acquire(&np->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	738080e7          	jalr	1848(ra) # 80000b9c <acquire>
        if (np->state == ZOMBIE)
    8000246c:	509c                	lw	a5,32(s1)
    8000246e:	f94787e3          	beq	a5,s4,800023fc <wait+0x48>
        release(&np->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	7f8080e7          	jalr	2040(ra) # 80000c6c <release>
        havekids = 1;
    8000247c:	8756                	mv	a4,s5
    8000247e:	bfd9                	j	80002454 <wait+0xa0>
    if (!havekids || p->killed)
    80002480:	c701                	beqz	a4,80002488 <wait+0xd4>
    80002482:	03892783          	lw	a5,56(s2)
    80002486:	c785                	beqz	a5,800024ae <wait+0xfa>
      release(&p->lock);
    80002488:	854a                	mv	a0,s2
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	7e2080e7          	jalr	2018(ra) # 80000c6c <release>
      return -1;
    80002492:	59fd                	li	s3,-1
}
    80002494:	854e                	mv	a0,s3
    80002496:	60a6                	ld	ra,72(sp)
    80002498:	6406                	ld	s0,64(sp)
    8000249a:	74e2                	ld	s1,56(sp)
    8000249c:	7942                	ld	s2,48(sp)
    8000249e:	79a2                	ld	s3,40(sp)
    800024a0:	7a02                	ld	s4,32(sp)
    800024a2:	6ae2                	ld	s5,24(sp)
    800024a4:	6b42                	ld	s6,16(sp)
    800024a6:	6ba2                	ld	s7,8(sp)
    800024a8:	6c02                	ld	s8,0(sp)
    800024aa:	6161                	addi	sp,sp,80
    800024ac:	8082                	ret
    sleep(p, &p->lock); // DOC: wait-sleep
    800024ae:	85e2                	mv	a1,s8
    800024b0:	854a                	mv	a0,s2
    800024b2:	00000097          	auipc	ra,0x0
    800024b6:	e84080e7          	jalr	-380(ra) # 80002336 <sleep>
    havekids = 0;
    800024ba:	bf1d                	j	800023f0 <wait+0x3c>

00000000800024bc <wakeup>:
{
    800024bc:	7139                	addi	sp,sp,-64
    800024be:	fc06                	sd	ra,56(sp)
    800024c0:	f822                	sd	s0,48(sp)
    800024c2:	f426                	sd	s1,40(sp)
    800024c4:	f04a                	sd	s2,32(sp)
    800024c6:	ec4e                	sd	s3,24(sp)
    800024c8:	e852                	sd	s4,16(sp)
    800024ca:	e456                	sd	s5,8(sp)
    800024cc:	0080                	addi	s0,sp,64
    800024ce:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    800024d0:	00024497          	auipc	s1,0x24
    800024d4:	ec848493          	addi	s1,s1,-312 # 80026398 <proc>
    if (p->state == SLEEPING && p->chan == chan)
    800024d8:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024da:	4a89                	li	s5,2
  for (p = proc; p < &proc[NPROC]; p++)
    800024dc:	0002a917          	auipc	s2,0x2a
    800024e0:	cbc90913          	addi	s2,s2,-836 # 8002c198 <tickslock>
    800024e4:	a821                	j	800024fc <wakeup+0x40>
      p->state = RUNNABLE;
    800024e6:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	780080e7          	jalr	1920(ra) # 80000c6c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024f4:	17848493          	addi	s1,s1,376
    800024f8:	01248e63          	beq	s1,s2,80002514 <wakeup+0x58>
    acquire(&p->lock);
    800024fc:	8526                	mv	a0,s1
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	69e080e7          	jalr	1694(ra) # 80000b9c <acquire>
    if (p->state == SLEEPING && p->chan == chan)
    80002506:	509c                	lw	a5,32(s1)
    80002508:	ff3791e3          	bne	a5,s3,800024ea <wakeup+0x2e>
    8000250c:	789c                	ld	a5,48(s1)
    8000250e:	fd479ee3          	bne	a5,s4,800024ea <wakeup+0x2e>
    80002512:	bfd1                	j	800024e6 <wakeup+0x2a>
}
    80002514:	70e2                	ld	ra,56(sp)
    80002516:	7442                	ld	s0,48(sp)
    80002518:	74a2                	ld	s1,40(sp)
    8000251a:	7902                	ld	s2,32(sp)
    8000251c:	69e2                	ld	s3,24(sp)
    8000251e:	6a42                	ld	s4,16(sp)
    80002520:	6aa2                	ld	s5,8(sp)
    80002522:	6121                	addi	sp,sp,64
    80002524:	8082                	ret

0000000080002526 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002526:	7179                	addi	sp,sp,-48
    80002528:	f406                	sd	ra,40(sp)
    8000252a:	f022                	sd	s0,32(sp)
    8000252c:	ec26                	sd	s1,24(sp)
    8000252e:	e84a                	sd	s2,16(sp)
    80002530:	e44e                	sd	s3,8(sp)
    80002532:	1800                	addi	s0,sp,48
    80002534:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002536:	00024497          	auipc	s1,0x24
    8000253a:	e6248493          	addi	s1,s1,-414 # 80026398 <proc>
    8000253e:	0002a997          	auipc	s3,0x2a
    80002542:	c5a98993          	addi	s3,s3,-934 # 8002c198 <tickslock>
  {
    acquire(&p->lock);
    80002546:	8526                	mv	a0,s1
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	654080e7          	jalr	1620(ra) # 80000b9c <acquire>
    if (p->pid == pid)
    80002550:	40bc                	lw	a5,64(s1)
    80002552:	01278d63          	beq	a5,s2,8000256c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002556:	8526                	mv	a0,s1
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	714080e7          	jalr	1812(ra) # 80000c6c <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002560:	17848493          	addi	s1,s1,376
    80002564:	ff3491e3          	bne	s1,s3,80002546 <kill+0x20>
  }
  return -1;
    80002568:	557d                	li	a0,-1
    8000256a:	a829                	j	80002584 <kill+0x5e>
      p->killed = 1;
    8000256c:	4785                	li	a5,1
    8000256e:	dc9c                	sw	a5,56(s1)
      if (p->state == SLEEPING)
    80002570:	5098                	lw	a4,32(s1)
    80002572:	4785                	li	a5,1
    80002574:	00f70f63          	beq	a4,a5,80002592 <kill+0x6c>
      release(&p->lock);
    80002578:	8526                	mv	a0,s1
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	6f2080e7          	jalr	1778(ra) # 80000c6c <release>
      return 0;
    80002582:	4501                	li	a0,0
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6145                	addi	sp,sp,48
    80002590:	8082                	ret
        p->state = RUNNABLE;
    80002592:	4789                	li	a5,2
    80002594:	d09c                	sw	a5,32(s1)
    80002596:	b7cd                	j	80002578 <kill+0x52>

0000000080002598 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002598:	7179                	addi	sp,sp,-48
    8000259a:	f406                	sd	ra,40(sp)
    8000259c:	f022                	sd	s0,32(sp)
    8000259e:	ec26                	sd	s1,24(sp)
    800025a0:	e84a                	sd	s2,16(sp)
    800025a2:	e44e                	sd	s3,8(sp)
    800025a4:	e052                	sd	s4,0(sp)
    800025a6:	1800                	addi	s0,sp,48
    800025a8:	84aa                	mv	s1,a0
    800025aa:	892e                	mv	s2,a1
    800025ac:	89b2                	mv	s3,a2
    800025ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025b0:	fffff097          	auipc	ra,0xfffff
    800025b4:	5b8080e7          	jalr	1464(ra) # 80001b68 <myproc>
  if (user_dst)
    800025b8:	c08d                	beqz	s1,800025da <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025ba:	86d2                	mv	a3,s4
    800025bc:	864e                	mv	a2,s3
    800025be:	85ca                	mv	a1,s2
    800025c0:	6d28                	ld	a0,88(a0)
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	260080e7          	jalr	608(ra) # 80001822 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025ca:	70a2                	ld	ra,40(sp)
    800025cc:	7402                	ld	s0,32(sp)
    800025ce:	64e2                	ld	s1,24(sp)
    800025d0:	6942                	ld	s2,16(sp)
    800025d2:	69a2                	ld	s3,8(sp)
    800025d4:	6a02                	ld	s4,0(sp)
    800025d6:	6145                	addi	sp,sp,48
    800025d8:	8082                	ret
    memmove((char *)dst, src, len);
    800025da:	000a061b          	sext.w	a2,s4
    800025de:	85ce                	mv	a1,s3
    800025e0:	854a                	mv	a0,s2
    800025e2:	fffff097          	auipc	ra,0xfffff
    800025e6:	8fe080e7          	jalr	-1794(ra) # 80000ee0 <memmove>
    return 0;
    800025ea:	8526                	mv	a0,s1
    800025ec:	bff9                	j	800025ca <either_copyout+0x32>

00000000800025ee <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ee:	7179                	addi	sp,sp,-48
    800025f0:	f406                	sd	ra,40(sp)
    800025f2:	f022                	sd	s0,32(sp)
    800025f4:	ec26                	sd	s1,24(sp)
    800025f6:	e84a                	sd	s2,16(sp)
    800025f8:	e44e                	sd	s3,8(sp)
    800025fa:	e052                	sd	s4,0(sp)
    800025fc:	1800                	addi	s0,sp,48
    800025fe:	892a                	mv	s2,a0
    80002600:	84ae                	mv	s1,a1
    80002602:	89b2                	mv	s3,a2
    80002604:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	562080e7          	jalr	1378(ra) # 80001b68 <myproc>
  if (user_src)
    8000260e:	c08d                	beqz	s1,80002630 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002610:	86d2                	mv	a3,s4
    80002612:	864e                	mv	a2,s3
    80002614:	85ca                	mv	a1,s2
    80002616:	6d28                	ld	a0,88(a0)
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	296080e7          	jalr	662(ra) # 800018ae <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002620:	70a2                	ld	ra,40(sp)
    80002622:	7402                	ld	s0,32(sp)
    80002624:	64e2                	ld	s1,24(sp)
    80002626:	6942                	ld	s2,16(sp)
    80002628:	69a2                	ld	s3,8(sp)
    8000262a:	6a02                	ld	s4,0(sp)
    8000262c:	6145                	addi	sp,sp,48
    8000262e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002630:	000a061b          	sext.w	a2,s4
    80002634:	85ce                	mv	a1,s3
    80002636:	854a                	mv	a0,s2
    80002638:	fffff097          	auipc	ra,0xfffff
    8000263c:	8a8080e7          	jalr	-1880(ra) # 80000ee0 <memmove>
    return 0;
    80002640:	8526                	mv	a0,s1
    80002642:	bff9                	j	80002620 <either_copyin+0x32>

0000000080002644 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002644:	715d                	addi	sp,sp,-80
    80002646:	e486                	sd	ra,72(sp)
    80002648:	e0a2                	sd	s0,64(sp)
    8000264a:	fc26                	sd	s1,56(sp)
    8000264c:	f84a                	sd	s2,48(sp)
    8000264e:	f44e                	sd	s3,40(sp)
    80002650:	f052                	sd	s4,32(sp)
    80002652:	ec56                	sd	s5,24(sp)
    80002654:	e85a                	sd	s6,16(sp)
    80002656:	e45e                	sd	s7,8(sp)
    80002658:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000265a:	00007517          	auipc	a0,0x7
    8000265e:	ba650513          	addi	a0,a0,-1114 # 80009200 <digits+0x90>
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	f6a080e7          	jalr	-150(ra) # 800005cc <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000266a:	00024497          	auipc	s1,0x24
    8000266e:	e8e48493          	addi	s1,s1,-370 # 800264f8 <proc+0x160>
    80002672:	0002a917          	auipc	s2,0x2a
    80002676:	c8690913          	addi	s2,s2,-890 # 8002c2f8 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000267a:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000267c:	00007997          	auipc	s3,0x7
    80002680:	db498993          	addi	s3,s3,-588 # 80009430 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    80002684:	00007a97          	auipc	s5,0x7
    80002688:	db4a8a93          	addi	s5,s5,-588 # 80009438 <digits+0x2c8>
    printf("\n");
    8000268c:	00007a17          	auipc	s4,0x7
    80002690:	b74a0a13          	addi	s4,s4,-1164 # 80009200 <digits+0x90>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002694:	00007b97          	auipc	s7,0x7
    80002698:	ddcb8b93          	addi	s7,s7,-548 # 80009470 <states.1881>
    8000269c:	a00d                	j	800026be <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000269e:	ee06a583          	lw	a1,-288(a3)
    800026a2:	8556                	mv	a0,s5
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	f28080e7          	jalr	-216(ra) # 800005cc <printf>
    printf("\n");
    800026ac:	8552                	mv	a0,s4
    800026ae:	ffffe097          	auipc	ra,0xffffe
    800026b2:	f1e080e7          	jalr	-226(ra) # 800005cc <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026b6:	17848493          	addi	s1,s1,376
    800026ba:	03248163          	beq	s1,s2,800026dc <procdump+0x98>
    if (p->state == UNUSED)
    800026be:	86a6                	mv	a3,s1
    800026c0:	ec04a783          	lw	a5,-320(s1)
    800026c4:	dbed                	beqz	a5,800026b6 <procdump+0x72>
      state = "???";
    800026c6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c8:	fcfb6be3          	bltu	s6,a5,8000269e <procdump+0x5a>
    800026cc:	1782                	slli	a5,a5,0x20
    800026ce:	9381                	srli	a5,a5,0x20
    800026d0:	078e                	slli	a5,a5,0x3
    800026d2:	97de                	add	a5,a5,s7
    800026d4:	6390                	ld	a2,0(a5)
    800026d6:	f661                	bnez	a2,8000269e <procdump+0x5a>
      state = "???";
    800026d8:	864e                	mv	a2,s3
    800026da:	b7d1                	j	8000269e <procdump+0x5a>
  }
}
    800026dc:	60a6                	ld	ra,72(sp)
    800026de:	6406                	ld	s0,64(sp)
    800026e0:	74e2                	ld	s1,56(sp)
    800026e2:	7942                	ld	s2,48(sp)
    800026e4:	79a2                	ld	s3,40(sp)
    800026e6:	7a02                	ld	s4,32(sp)
    800026e8:	6ae2                	ld	s5,24(sp)
    800026ea:	6b42                	ld	s6,16(sp)
    800026ec:	6ba2                	ld	s7,8(sp)
    800026ee:	6161                	addi	sp,sp,80
    800026f0:	8082                	ret

00000000800026f2 <swtch>:
    800026f2:	00153023          	sd	ra,0(a0)
    800026f6:	00253423          	sd	sp,8(a0)
    800026fa:	e900                	sd	s0,16(a0)
    800026fc:	ed04                	sd	s1,24(a0)
    800026fe:	03253023          	sd	s2,32(a0)
    80002702:	03353423          	sd	s3,40(a0)
    80002706:	03453823          	sd	s4,48(a0)
    8000270a:	03553c23          	sd	s5,56(a0)
    8000270e:	05653023          	sd	s6,64(a0)
    80002712:	05753423          	sd	s7,72(a0)
    80002716:	05853823          	sd	s8,80(a0)
    8000271a:	05953c23          	sd	s9,88(a0)
    8000271e:	07a53023          	sd	s10,96(a0)
    80002722:	07b53423          	sd	s11,104(a0)
    80002726:	0005b083          	ld	ra,0(a1)
    8000272a:	0085b103          	ld	sp,8(a1)
    8000272e:	6980                	ld	s0,16(a1)
    80002730:	6d84                	ld	s1,24(a1)
    80002732:	0205b903          	ld	s2,32(a1)
    80002736:	0285b983          	ld	s3,40(a1)
    8000273a:	0305ba03          	ld	s4,48(a1)
    8000273e:	0385ba83          	ld	s5,56(a1)
    80002742:	0405bb03          	ld	s6,64(a1)
    80002746:	0485bb83          	ld	s7,72(a1)
    8000274a:	0505bc03          	ld	s8,80(a1)
    8000274e:	0585bc83          	ld	s9,88(a1)
    80002752:	0605bd03          	ld	s10,96(a1)
    80002756:	0685bd83          	ld	s11,104(a1)
    8000275a:	8082                	ret

000000008000275c <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    8000275c:	1141                	addi	sp,sp,-16
    8000275e:	e422                	sd	s0,8(sp)
    80002760:	0800                	addi	s0,sp,16
    80002762:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002764:	00151713          	slli	a4,a0,0x1
    80002768:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    8000276a:	04054c63          	bltz	a0,800027c2 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    8000276e:	5685                	li	a3,-31
    80002770:	8285                	srli	a3,a3,0x1
    80002772:	8ee9                	and	a3,a3,a0
    80002774:	caad                	beqz	a3,800027e6 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002776:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002778:	00007517          	auipc	a0,0x7
    8000277c:	d2050513          	addi	a0,a0,-736 # 80009498 <states.1881+0x28>
    } else if (code <= 23) {
    80002780:	06e6f063          	bgeu	a3,a4,800027e0 <scause_desc+0x84>
    } else if (code <= 31) {
    80002784:	fc100693          	li	a3,-63
    80002788:	8285                	srli	a3,a3,0x1
    8000278a:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    8000278c:	00007517          	auipc	a0,0x7
    80002790:	d3450513          	addi	a0,a0,-716 # 800094c0 <states.1881+0x50>
    } else if (code <= 31) {
    80002794:	c6b1                	beqz	a3,800027e0 <scause_desc+0x84>
    } else if (code <= 47) {
    80002796:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    8000279a:	00007517          	auipc	a0,0x7
    8000279e:	cfe50513          	addi	a0,a0,-770 # 80009498 <states.1881+0x28>
    } else if (code <= 47) {
    800027a2:	02e6ff63          	bgeu	a3,a4,800027e0 <scause_desc+0x84>
    } else if (code <= 63) {
    800027a6:	f8100513          	li	a0,-127
    800027aa:	8105                	srli	a0,a0,0x1
    800027ac:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800027ae:	00007517          	auipc	a0,0x7
    800027b2:	d1250513          	addi	a0,a0,-750 # 800094c0 <states.1881+0x50>
    } else if (code <= 63) {
    800027b6:	c78d                	beqz	a5,800027e0 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800027b8:	00007517          	auipc	a0,0x7
    800027bc:	ce050513          	addi	a0,a0,-800 # 80009498 <states.1881+0x28>
    800027c0:	a005                	j	800027e0 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800027c2:	5505                	li	a0,-31
    800027c4:	8105                	srli	a0,a0,0x1
    800027c6:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800027c8:	00007517          	auipc	a0,0x7
    800027cc:	d1850513          	addi	a0,a0,-744 # 800094e0 <states.1881+0x70>
    if (code < NELEM(intr_desc)) {
    800027d0:	eb81                	bnez	a5,800027e0 <scause_desc+0x84>
      return intr_desc[code];
    800027d2:	070e                	slli	a4,a4,0x3
    800027d4:	00007797          	auipc	a5,0x7
    800027d8:	01c78793          	addi	a5,a5,28 # 800097f0 <intr_desc.1640>
    800027dc:	973e                	add	a4,a4,a5
    800027de:	6308                	ld	a0,0(a4)
    }
  }
}
    800027e0:	6422                	ld	s0,8(sp)
    800027e2:	0141                	addi	sp,sp,16
    800027e4:	8082                	ret
      return nointr_desc[code];
    800027e6:	070e                	slli	a4,a4,0x3
    800027e8:	00007797          	auipc	a5,0x7
    800027ec:	00878793          	addi	a5,a5,8 # 800097f0 <intr_desc.1640>
    800027f0:	973e                	add	a4,a4,a5
    800027f2:	6348                	ld	a0,128(a4)
    800027f4:	b7f5                	j	800027e0 <scause_desc+0x84>

00000000800027f6 <trapinit>:
{
    800027f6:	1141                	addi	sp,sp,-16
    800027f8:	e406                	sd	ra,8(sp)
    800027fa:	e022                	sd	s0,0(sp)
    800027fc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027fe:	00007597          	auipc	a1,0x7
    80002802:	d0258593          	addi	a1,a1,-766 # 80009500 <states.1881+0x90>
    80002806:	0002a517          	auipc	a0,0x2a
    8000280a:	99250513          	addi	a0,a0,-1646 # 8002c198 <tickslock>
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	2b8080e7          	jalr	696(ra) # 80000ac6 <initlock>
}
    80002816:	60a2                	ld	ra,8(sp)
    80002818:	6402                	ld	s0,0(sp)
    8000281a:	0141                	addi	sp,sp,16
    8000281c:	8082                	ret

000000008000281e <trapinithart>:
{
    8000281e:	1141                	addi	sp,sp,-16
    80002820:	e422                	sd	s0,8(sp)
    80002822:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002824:	00003797          	auipc	a5,0x3
    80002828:	50c78793          	addi	a5,a5,1292 # 80005d30 <kernelvec>
    8000282c:	10579073          	csrw	stvec,a5
}
    80002830:	6422                	ld	s0,8(sp)
    80002832:	0141                	addi	sp,sp,16
    80002834:	8082                	ret

0000000080002836 <usertrapret>:
{
    80002836:	1141                	addi	sp,sp,-16
    80002838:	e406                	sd	ra,8(sp)
    8000283a:	e022                	sd	s0,0(sp)
    8000283c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000283e:	fffff097          	auipc	ra,0xfffff
    80002842:	32a080e7          	jalr	810(ra) # 80001b68 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002846:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000284a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000284c:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002850:	00005617          	auipc	a2,0x5
    80002854:	7b060613          	addi	a2,a2,1968 # 80008000 <_trampoline>
    80002858:	00005697          	auipc	a3,0x5
    8000285c:	7a868693          	addi	a3,a3,1960 # 80008000 <_trampoline>
    80002860:	8e91                	sub	a3,a3,a2
    80002862:	040007b7          	lui	a5,0x4000
    80002866:	17fd                	addi	a5,a5,-1
    80002868:	07b2                	slli	a5,a5,0xc
    8000286a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000286c:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002870:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002872:	180026f3          	csrr	a3,satp
    80002876:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002878:	7138                	ld	a4,96(a0)
    8000287a:	6534                	ld	a3,72(a0)
    8000287c:	6585                	lui	a1,0x1
    8000287e:	96ae                	add	a3,a3,a1
    80002880:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002882:	7138                	ld	a4,96(a0)
    80002884:	00000697          	auipc	a3,0x0
    80002888:	12268693          	addi	a3,a3,290 # 800029a6 <usertrap>
    8000288c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000288e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002890:	8692                	mv	a3,tp
    80002892:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002894:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002898:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000289c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a0:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    800028a4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028a6:	6f18                	ld	a4,24(a4)
    800028a8:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800028ac:	6d2c                	ld	a1,88(a0)
    800028ae:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028b0:	00005717          	auipc	a4,0x5
    800028b4:	7e070713          	addi	a4,a4,2016 # 80008090 <userret>
    800028b8:	8f11                	sub	a4,a4,a2
    800028ba:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    800028bc:	577d                	li	a4,-1
    800028be:	177e                	slli	a4,a4,0x3f
    800028c0:	8dd9                	or	a1,a1,a4
    800028c2:	17053503          	ld	a0,368(a0)
    800028c6:	9782                	jalr	a5
}
    800028c8:	60a2                	ld	ra,8(sp)
    800028ca:	6402                	ld	s0,0(sp)
    800028cc:	0141                	addi	sp,sp,16
    800028ce:	8082                	ret

00000000800028d0 <clockintr>:
{
    800028d0:	1101                	addi	sp,sp,-32
    800028d2:	ec06                	sd	ra,24(sp)
    800028d4:	e822                	sd	s0,16(sp)
    800028d6:	e426                	sd	s1,8(sp)
    800028d8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800028da:	0002a497          	auipc	s1,0x2a
    800028de:	8be48493          	addi	s1,s1,-1858 # 8002c198 <tickslock>
    800028e2:	8526                	mv	a0,s1
    800028e4:	ffffe097          	auipc	ra,0xffffe
    800028e8:	2b8080e7          	jalr	696(ra) # 80000b9c <acquire>
  ticks++;
    800028ec:	00008517          	auipc	a0,0x8
    800028f0:	b7450513          	addi	a0,a0,-1164 # 8000a460 <ticks>
    800028f4:	411c                	lw	a5,0(a0)
    800028f6:	2785                	addiw	a5,a5,1
    800028f8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800028fa:	00000097          	auipc	ra,0x0
    800028fe:	bc2080e7          	jalr	-1086(ra) # 800024bc <wakeup>
  release(&tickslock);
    80002902:	8526                	mv	a0,s1
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	368080e7          	jalr	872(ra) # 80000c6c <release>
}
    8000290c:	60e2                	ld	ra,24(sp)
    8000290e:	6442                	ld	s0,16(sp)
    80002910:	64a2                	ld	s1,8(sp)
    80002912:	6105                	addi	sp,sp,32
    80002914:	8082                	ret

0000000080002916 <devintr>:
{
    80002916:	1101                	addi	sp,sp,-32
    80002918:	ec06                	sd	ra,24(sp)
    8000291a:	e822                	sd	s0,16(sp)
    8000291c:	e426                	sd	s1,8(sp)
    8000291e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002920:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002924:	00074d63          	bltz	a4,8000293e <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002928:	57fd                	li	a5,-1
    8000292a:	17fe                	slli	a5,a5,0x3f
    8000292c:	0785                	addi	a5,a5,1
    return 0;
    8000292e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002930:	04f70a63          	beq	a4,a5,80002984 <devintr+0x6e>
}
    80002934:	60e2                	ld	ra,24(sp)
    80002936:	6442                	ld	s0,16(sp)
    80002938:	64a2                	ld	s1,8(sp)
    8000293a:	6105                	addi	sp,sp,32
    8000293c:	8082                	ret
     (scause & 0xff) == 9){
    8000293e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002942:	46a5                	li	a3,9
    80002944:	fed792e3          	bne	a5,a3,80002928 <devintr+0x12>
    int irq = plic_claim();
    80002948:	00003097          	auipc	ra,0x3
    8000294c:	4f0080e7          	jalr	1264(ra) # 80005e38 <plic_claim>
    80002950:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002952:	47a9                	li	a5,10
    80002954:	00f50863          	beq	a0,a5,80002964 <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002958:	4785                	li	a5,1
    8000295a:	02f50063          	beq	a0,a5,8000297a <devintr+0x64>
    return 1;
    8000295e:	4505                	li	a0,1
    if(irq)
    80002960:	d8f1                	beqz	s1,80002934 <devintr+0x1e>
    80002962:	a029                	j	8000296c <devintr+0x56>
      uartintr();
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	fb6080e7          	jalr	-74(ra) # 8000091a <uartintr>
      plic_complete(irq);
    8000296c:	8526                	mv	a0,s1
    8000296e:	00003097          	auipc	ra,0x3
    80002972:	4ee080e7          	jalr	1262(ra) # 80005e5c <plic_complete>
    return 1;
    80002976:	4505                	li	a0,1
    80002978:	bf75                	j	80002934 <devintr+0x1e>
      virtio_disk_intr();
    8000297a:	00004097          	auipc	ra,0x4
    8000297e:	9f6080e7          	jalr	-1546(ra) # 80006370 <virtio_disk_intr>
    80002982:	b7ed                	j	8000296c <devintr+0x56>
    if(cpuid() == 0){
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	1b8080e7          	jalr	440(ra) # 80001b3c <cpuid>
    8000298c:	c901                	beqz	a0,8000299c <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000298e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002992:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002994:	14479073          	csrw	sip,a5
    return 2;
    80002998:	4509                	li	a0,2
    8000299a:	bf69                	j	80002934 <devintr+0x1e>
      clockintr();
    8000299c:	00000097          	auipc	ra,0x0
    800029a0:	f34080e7          	jalr	-204(ra) # 800028d0 <clockintr>
    800029a4:	b7ed                	j	8000298e <devintr+0x78>

00000000800029a6 <usertrap>:
{
    800029a6:	7179                	addi	sp,sp,-48
    800029a8:	f406                	sd	ra,40(sp)
    800029aa:	f022                	sd	s0,32(sp)
    800029ac:	ec26                	sd	s1,24(sp)
    800029ae:	e84a                	sd	s2,16(sp)
    800029b0:	e44e                	sd	s3,8(sp)
    800029b2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029b8:	1007f793          	andi	a5,a5,256
    800029bc:	e3b5                	bnez	a5,80002a20 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029be:	00003797          	auipc	a5,0x3
    800029c2:	37278793          	addi	a5,a5,882 # 80005d30 <kernelvec>
    800029c6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	19e080e7          	jalr	414(ra) # 80001b68 <myproc>
    800029d2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029d4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d6:	14102773          	csrr	a4,sepc
    800029da:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029dc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029e0:	47a1                	li	a5,8
    800029e2:	04f71d63          	bne	a4,a5,80002a3c <usertrap+0x96>
    if(p->killed)
    800029e6:	5d1c                	lw	a5,56(a0)
    800029e8:	e7a1                	bnez	a5,80002a30 <usertrap+0x8a>
    p->trapframe->epc += 4;
    800029ea:	70b8                	ld	a4,96(s1)
    800029ec:	6f1c                	ld	a5,24(a4)
    800029ee:	0791                	addi	a5,a5,4
    800029f0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fa:	10079073          	csrw	sstatus,a5
    syscall();
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	2fe080e7          	jalr	766(ra) # 80002cfc <syscall>
  if(p->killed)
    80002a06:	5c9c                	lw	a5,56(s1)
    80002a08:	e3cd                	bnez	a5,80002aaa <usertrap+0x104>
  usertrapret();
    80002a0a:	00000097          	auipc	ra,0x0
    80002a0e:	e2c080e7          	jalr	-468(ra) # 80002836 <usertrapret>
}
    80002a12:	70a2                	ld	ra,40(sp)
    80002a14:	7402                	ld	s0,32(sp)
    80002a16:	64e2                	ld	s1,24(sp)
    80002a18:	6942                	ld	s2,16(sp)
    80002a1a:	69a2                	ld	s3,8(sp)
    80002a1c:	6145                	addi	sp,sp,48
    80002a1e:	8082                	ret
    panic("usertrap: not from user mode");
    80002a20:	00007517          	auipc	a0,0x7
    80002a24:	ae850513          	addi	a0,a0,-1304 # 80009508 <states.1881+0x98>
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	b42080e7          	jalr	-1214(ra) # 8000056a <panic>
      exit(-1);
    80002a30:	557d                	li	a0,-1
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	7be080e7          	jalr	1982(ra) # 800021f0 <exit>
    80002a3a:	bf45                	j	800029ea <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002a3c:	00000097          	auipc	ra,0x0
    80002a40:	eda080e7          	jalr	-294(ra) # 80002916 <devintr>
    80002a44:	892a                	mv	s2,a0
    80002a46:	c501                	beqz	a0,80002a4e <usertrap+0xa8>
  if(p->killed)
    80002a48:	5c9c                	lw	a5,56(s1)
    80002a4a:	cba1                	beqz	a5,80002a9a <usertrap+0xf4>
    80002a4c:	a091                	j	80002a90 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4e:	142029f3          	csrr	s3,scause
    80002a52:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002a56:	00000097          	auipc	ra,0x0
    80002a5a:	d06080e7          	jalr	-762(ra) # 8000275c <scause_desc>
    80002a5e:	862a                	mv	a2,a0
    80002a60:	40b4                	lw	a3,64(s1)
    80002a62:	85ce                	mv	a1,s3
    80002a64:	00007517          	auipc	a0,0x7
    80002a68:	ac450513          	addi	a0,a0,-1340 # 80009528 <states.1881+0xb8>
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	b60080e7          	jalr	-1184(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a78:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a7c:	00007517          	auipc	a0,0x7
    80002a80:	adc50513          	addi	a0,a0,-1316 # 80009558 <states.1881+0xe8>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	b48080e7          	jalr	-1208(ra) # 800005cc <printf>
    p->killed = 1;
    80002a8c:	4785                	li	a5,1
    80002a8e:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002a90:	557d                	li	a0,-1
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	75e080e7          	jalr	1886(ra) # 800021f0 <exit>
  if(which_dev == 2)
    80002a9a:	4789                	li	a5,2
    80002a9c:	f6f917e3          	bne	s2,a5,80002a0a <usertrap+0x64>
    yield();
    80002aa0:	00000097          	auipc	ra,0x0
    80002aa4:	85a080e7          	jalr	-1958(ra) # 800022fa <yield>
    80002aa8:	b78d                	j	80002a0a <usertrap+0x64>
  int which_dev = 0;
    80002aaa:	4901                	li	s2,0
    80002aac:	b7d5                	j	80002a90 <usertrap+0xea>

0000000080002aae <kerneltrap>:
{
    80002aae:	7179                	addi	sp,sp,-48
    80002ab0:	f406                	sd	ra,40(sp)
    80002ab2:	f022                	sd	s0,32(sp)
    80002ab4:	ec26                	sd	s1,24(sp)
    80002ab6:	e84a                	sd	s2,16(sp)
    80002ab8:	e44e                	sd	s3,8(sp)
    80002aba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ac8:	1004f793          	andi	a5,s1,256
    80002acc:	cb85                	beqz	a5,80002afc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ace:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ad2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ad4:	ef85                	bnez	a5,80002b0c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	e40080e7          	jalr	-448(ra) # 80002916 <devintr>
    80002ade:	cd1d                	beqz	a0,80002b1c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ae0:	4789                	li	a5,2
    80002ae2:	08f50063          	beq	a0,a5,80002b62 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ae6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aea:	10049073          	csrw	sstatus,s1
}
    80002aee:	70a2                	ld	ra,40(sp)
    80002af0:	7402                	ld	s0,32(sp)
    80002af2:	64e2                	ld	s1,24(sp)
    80002af4:	6942                	ld	s2,16(sp)
    80002af6:	69a2                	ld	s3,8(sp)
    80002af8:	6145                	addi	sp,sp,48
    80002afa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002afc:	00007517          	auipc	a0,0x7
    80002b00:	a7c50513          	addi	a0,a0,-1412 # 80009578 <states.1881+0x108>
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	a66080e7          	jalr	-1434(ra) # 8000056a <panic>
    panic("kerneltrap: interrupts enabled");
    80002b0c:	00007517          	auipc	a0,0x7
    80002b10:	a9450513          	addi	a0,a0,-1388 # 800095a0 <states.1881+0x130>
    80002b14:	ffffe097          	auipc	ra,0xffffe
    80002b18:	a56080e7          	jalr	-1450(ra) # 8000056a <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002b1c:	854e                	mv	a0,s3
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	c3e080e7          	jalr	-962(ra) # 8000275c <scause_desc>
    80002b26:	862a                	mv	a2,a0
    80002b28:	85ce                	mv	a1,s3
    80002b2a:	00007517          	auipc	a0,0x7
    80002b2e:	a9650513          	addi	a0,a0,-1386 # 800095c0 <states.1881+0x150>
    80002b32:	ffffe097          	auipc	ra,0xffffe
    80002b36:	a9a080e7          	jalr	-1382(ra) # 800005cc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b3a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b3e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b42:	00007517          	auipc	a0,0x7
    80002b46:	a8e50513          	addi	a0,a0,-1394 # 800095d0 <states.1881+0x160>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	a82080e7          	jalr	-1406(ra) # 800005cc <printf>
    panic("kerneltrap");
    80002b52:	00007517          	auipc	a0,0x7
    80002b56:	a9650513          	addi	a0,a0,-1386 # 800095e8 <states.1881+0x178>
    80002b5a:	ffffe097          	auipc	ra,0xffffe
    80002b5e:	a10080e7          	jalr	-1520(ra) # 8000056a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b62:	fffff097          	auipc	ra,0xfffff
    80002b66:	006080e7          	jalr	6(ra) # 80001b68 <myproc>
    80002b6a:	dd35                	beqz	a0,80002ae6 <kerneltrap+0x38>
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	ffc080e7          	jalr	-4(ra) # 80001b68 <myproc>
    80002b74:	5118                	lw	a4,32(a0)
    80002b76:	478d                	li	a5,3
    80002b78:	f6f717e3          	bne	a4,a5,80002ae6 <kerneltrap+0x38>
    yield();
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	77e080e7          	jalr	1918(ra) # 800022fa <yield>
    80002b84:	b78d                	j	80002ae6 <kerneltrap+0x38>

0000000080002b86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b86:	1101                	addi	sp,sp,-32
    80002b88:	ec06                	sd	ra,24(sp)
    80002b8a:	e822                	sd	s0,16(sp)
    80002b8c:	e426                	sd	s1,8(sp)
    80002b8e:	1000                	addi	s0,sp,32
    80002b90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	fd6080e7          	jalr	-42(ra) # 80001b68 <myproc>
  switch (n)
    80002b9a:	4795                	li	a5,5
    80002b9c:	0497e163          	bltu	a5,s1,80002bde <argraw+0x58>
    80002ba0:	048a                	slli	s1,s1,0x2
    80002ba2:	00007717          	auipc	a4,0x7
    80002ba6:	d7670713          	addi	a4,a4,-650 # 80009918 <nointr_desc.1641+0xa8>
    80002baa:	94ba                	add	s1,s1,a4
    80002bac:	409c                	lw	a5,0(s1)
    80002bae:	97ba                	add	a5,a5,a4
    80002bb0:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002bb2:	713c                	ld	a5,96(a0)
    80002bb4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret
    return p->trapframe->a1;
    80002bc0:	713c                	ld	a5,96(a0)
    80002bc2:	7fa8                	ld	a0,120(a5)
    80002bc4:	bfcd                	j	80002bb6 <argraw+0x30>
    return p->trapframe->a2;
    80002bc6:	713c                	ld	a5,96(a0)
    80002bc8:	63c8                	ld	a0,128(a5)
    80002bca:	b7f5                	j	80002bb6 <argraw+0x30>
    return p->trapframe->a3;
    80002bcc:	713c                	ld	a5,96(a0)
    80002bce:	67c8                	ld	a0,136(a5)
    80002bd0:	b7dd                	j	80002bb6 <argraw+0x30>
    return p->trapframe->a4;
    80002bd2:	713c                	ld	a5,96(a0)
    80002bd4:	6bc8                	ld	a0,144(a5)
    80002bd6:	b7c5                	j	80002bb6 <argraw+0x30>
    return p->trapframe->a5;
    80002bd8:	713c                	ld	a5,96(a0)
    80002bda:	6fc8                	ld	a0,152(a5)
    80002bdc:	bfe9                	j	80002bb6 <argraw+0x30>
  panic("argraw");
    80002bde:	00007517          	auipc	a0,0x7
    80002be2:	d1250513          	addi	a0,a0,-750 # 800098f0 <nointr_desc.1641+0x80>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	984080e7          	jalr	-1660(ra) # 8000056a <panic>

0000000080002bee <fetchaddr>:
{
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	e04a                	sd	s2,0(sp)
    80002bf8:	1000                	addi	s0,sp,32
    80002bfa:	84aa                	mv	s1,a0
    80002bfc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bfe:	fffff097          	auipc	ra,0xfffff
    80002c02:	f6a080e7          	jalr	-150(ra) # 80001b68 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz)
    80002c06:	693c                	ld	a5,80(a0)
    80002c08:	02f4f863          	bgeu	s1,a5,80002c38 <fetchaddr+0x4a>
    80002c0c:	00848713          	addi	a4,s1,8
    80002c10:	02e7e663          	bltu	a5,a4,80002c3c <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c14:	46a1                	li	a3,8
    80002c16:	8626                	mv	a2,s1
    80002c18:	85ca                	mv	a1,s2
    80002c1a:	6d28                	ld	a0,88(a0)
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	c92080e7          	jalr	-878(ra) # 800018ae <copyin>
    80002c24:	00a03533          	snez	a0,a0
    80002c28:	40a00533          	neg	a0,a0
}
    80002c2c:	60e2                	ld	ra,24(sp)
    80002c2e:	6442                	ld	s0,16(sp)
    80002c30:	64a2                	ld	s1,8(sp)
    80002c32:	6902                	ld	s2,0(sp)
    80002c34:	6105                	addi	sp,sp,32
    80002c36:	8082                	ret
    return -1;
    80002c38:	557d                	li	a0,-1
    80002c3a:	bfcd                	j	80002c2c <fetchaddr+0x3e>
    80002c3c:	557d                	li	a0,-1
    80002c3e:	b7fd                	j	80002c2c <fetchaddr+0x3e>

0000000080002c40 <fetchstr>:
{
    80002c40:	7179                	addi	sp,sp,-48
    80002c42:	f406                	sd	ra,40(sp)
    80002c44:	f022                	sd	s0,32(sp)
    80002c46:	ec26                	sd	s1,24(sp)
    80002c48:	e84a                	sd	s2,16(sp)
    80002c4a:	e44e                	sd	s3,8(sp)
    80002c4c:	1800                	addi	s0,sp,48
    80002c4e:	892a                	mv	s2,a0
    80002c50:	84ae                	mv	s1,a1
    80002c52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	f14080e7          	jalr	-236(ra) # 80001b68 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c5c:	86ce                	mv	a3,s3
    80002c5e:	864a                	mv	a2,s2
    80002c60:	85a6                	mv	a1,s1
    80002c62:	6d28                	ld	a0,88(a0)
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	cd6080e7          	jalr	-810(ra) # 8000193a <copyinstr>
  if (err < 0)
    80002c6c:	00054763          	bltz	a0,80002c7a <fetchstr+0x3a>
  return strlen(buf);
    80002c70:	8526                	mv	a0,s1
    80002c72:	ffffe097          	auipc	ra,0xffffe
    80002c76:	3be080e7          	jalr	958(ra) # 80001030 <strlen>
}
    80002c7a:	70a2                	ld	ra,40(sp)
    80002c7c:	7402                	ld	s0,32(sp)
    80002c7e:	64e2                	ld	s1,24(sp)
    80002c80:	6942                	ld	s2,16(sp)
    80002c82:	69a2                	ld	s3,8(sp)
    80002c84:	6145                	addi	sp,sp,48
    80002c86:	8082                	ret

0000000080002c88 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002c88:	1101                	addi	sp,sp,-32
    80002c8a:	ec06                	sd	ra,24(sp)
    80002c8c:	e822                	sd	s0,16(sp)
    80002c8e:	e426                	sd	s1,8(sp)
    80002c90:	1000                	addi	s0,sp,32
    80002c92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c94:	00000097          	auipc	ra,0x0
    80002c98:	ef2080e7          	jalr	-270(ra) # 80002b86 <argraw>
    80002c9c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c9e:	4501                	li	a0,0
    80002ca0:	60e2                	ld	ra,24(sp)
    80002ca2:	6442                	ld	s0,16(sp)
    80002ca4:	64a2                	ld	s1,8(sp)
    80002ca6:	6105                	addi	sp,sp,32
    80002ca8:	8082                	ret

0000000080002caa <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002caa:	1101                	addi	sp,sp,-32
    80002cac:	ec06                	sd	ra,24(sp)
    80002cae:	e822                	sd	s0,16(sp)
    80002cb0:	e426                	sd	s1,8(sp)
    80002cb2:	1000                	addi	s0,sp,32
    80002cb4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	ed0080e7          	jalr	-304(ra) # 80002b86 <argraw>
    80002cbe:	e088                	sd	a0,0(s1)
  return 0;
}
    80002cc0:	4501                	li	a0,0
    80002cc2:	60e2                	ld	ra,24(sp)
    80002cc4:	6442                	ld	s0,16(sp)
    80002cc6:	64a2                	ld	s1,8(sp)
    80002cc8:	6105                	addi	sp,sp,32
    80002cca:	8082                	ret

0000000080002ccc <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002ccc:	1101                	addi	sp,sp,-32
    80002cce:	ec06                	sd	ra,24(sp)
    80002cd0:	e822                	sd	s0,16(sp)
    80002cd2:	e426                	sd	s1,8(sp)
    80002cd4:	e04a                	sd	s2,0(sp)
    80002cd6:	1000                	addi	s0,sp,32
    80002cd8:	84ae                	mv	s1,a1
    80002cda:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002cdc:	00000097          	auipc	ra,0x0
    80002ce0:	eaa080e7          	jalr	-342(ra) # 80002b86 <argraw>
  uint64 addr;
  if (argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ce4:	864a                	mv	a2,s2
    80002ce6:	85a6                	mv	a1,s1
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	f58080e7          	jalr	-168(ra) # 80002c40 <fetchstr>
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	64a2                	ld	s1,8(sp)
    80002cf6:	6902                	ld	s2,0(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <syscall>:
    [SYS_rcu_read_stress] sys_rcu_read_stress,

};

void syscall(void)
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	e04a                	sd	s2,0(sp)
    80002d06:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	e60080e7          	jalr	-416(ra) # 80001b68 <myproc>
    80002d10:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d12:	06053903          	ld	s2,96(a0)
    80002d16:	0a893783          	ld	a5,168(s2)
    80002d1a:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002d1e:	37fd                	addiw	a5,a5,-1
    80002d20:	476d                	li	a4,27
    80002d22:	00f76f63          	bltu	a4,a5,80002d40 <syscall+0x44>
    80002d26:	00369713          	slli	a4,a3,0x3
    80002d2a:	00007797          	auipc	a5,0x7
    80002d2e:	c0678793          	addi	a5,a5,-1018 # 80009930 <syscalls>
    80002d32:	97ba                	add	a5,a5,a4
    80002d34:	639c                	ld	a5,0(a5)
    80002d36:	c789                	beqz	a5,80002d40 <syscall+0x44>
  {
    p->trapframe->a0 = syscalls[num]();
    80002d38:	9782                	jalr	a5
    80002d3a:	06a93823          	sd	a0,112(s2)
    80002d3e:	a839                	j	80002d5c <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002d40:	16048613          	addi	a2,s1,352
    80002d44:	40ac                	lw	a1,64(s1)
    80002d46:	00007517          	auipc	a0,0x7
    80002d4a:	bb250513          	addi	a0,a0,-1102 # 800098f8 <nointr_desc.1641+0x88>
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	87e080e7          	jalr	-1922(ra) # 800005cc <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d56:	70bc                	ld	a5,96(s1)
    80002d58:	577d                	li	a4,-1
    80002d5a:	fbb8                	sd	a4,112(a5)
  }
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	64a2                	ld	s1,8(sp)
    80002d62:	6902                	ld	s2,0(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret

0000000080002d68 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d68:	1101                	addi	sp,sp,-32
    80002d6a:	ec06                	sd	ra,24(sp)
    80002d6c:	e822                	sd	s0,16(sp)
    80002d6e:	1000                	addi	s0,sp,32
  int n;
  if (argint(0, &n) < 0)
    80002d70:	fec40593          	addi	a1,s0,-20
    80002d74:	4501                	li	a0,0
    80002d76:	00000097          	auipc	ra,0x0
    80002d7a:	f12080e7          	jalr	-238(ra) # 80002c88 <argint>
    return -1;
    80002d7e:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002d80:	00054963          	bltz	a0,80002d92 <sys_exit+0x2a>
  exit(n);
    80002d84:	fec42503          	lw	a0,-20(s0)
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	468080e7          	jalr	1128(ra) # 800021f0 <exit>
  return 0; // not reached
    80002d90:	4781                	li	a5,0
}
    80002d92:	853e                	mv	a0,a5
    80002d94:	60e2                	ld	ra,24(sp)
    80002d96:	6442                	ld	s0,16(sp)
    80002d98:	6105                	addi	sp,sp,32
    80002d9a:	8082                	ret

0000000080002d9c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d9c:	1141                	addi	sp,sp,-16
    80002d9e:	e406                	sd	ra,8(sp)
    80002da0:	e022                	sd	s0,0(sp)
    80002da2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	dc4080e7          	jalr	-572(ra) # 80001b68 <myproc>
}
    80002dac:	4128                	lw	a0,64(a0)
    80002dae:	60a2                	ld	ra,8(sp)
    80002db0:	6402                	ld	s0,0(sp)
    80002db2:	0141                	addi	sp,sp,16
    80002db4:	8082                	ret

0000000080002db6 <sys_fork>:

uint64
sys_fork(void)
{
    80002db6:	1141                	addi	sp,sp,-16
    80002db8:	e406                	sd	ra,8(sp)
    80002dba:	e022                	sd	s0,0(sp)
    80002dbc:	0800                	addi	s0,sp,16
  return fork();
    80002dbe:	fffff097          	auipc	ra,0xfffff
    80002dc2:	120080e7          	jalr	288(ra) # 80001ede <fork>
}
    80002dc6:	60a2                	ld	ra,8(sp)
    80002dc8:	6402                	ld	s0,0(sp)
    80002dca:	0141                	addi	sp,sp,16
    80002dcc:	8082                	ret

0000000080002dce <sys_wait>:

uint64
sys_wait(void)
{
    80002dce:	1101                	addi	sp,sp,-32
    80002dd0:	ec06                	sd	ra,24(sp)
    80002dd2:	e822                	sd	s0,16(sp)
    80002dd4:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80002dd6:	fe840593          	addi	a1,s0,-24
    80002dda:	4501                	li	a0,0
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	ece080e7          	jalr	-306(ra) # 80002caa <argaddr>
    80002de4:	87aa                	mv	a5,a0
    return -1;
    80002de6:	557d                	li	a0,-1
  if (argaddr(0, &p) < 0)
    80002de8:	0007c863          	bltz	a5,80002df8 <sys_wait+0x2a>
  return wait(p);
    80002dec:	fe843503          	ld	a0,-24(s0)
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	5c4080e7          	jalr	1476(ra) # 800023b4 <wait>
}
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	6105                	addi	sp,sp,32
    80002dfe:	8082                	ret

0000000080002e00 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e00:	7179                	addi	sp,sp,-48
    80002e02:	f406                	sd	ra,40(sp)
    80002e04:	f022                	sd	s0,32(sp)
    80002e06:	ec26                	sd	s1,24(sp)
    80002e08:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if (argint(0, &n) < 0)
    80002e0a:	fdc40593          	addi	a1,s0,-36
    80002e0e:	4501                	li	a0,0
    80002e10:	00000097          	auipc	ra,0x0
    80002e14:	e78080e7          	jalr	-392(ra) # 80002c88 <argint>
    80002e18:	87aa                	mv	a5,a0
    return -1;
    80002e1a:	557d                	li	a0,-1
  if (argint(0, &n) < 0)
    80002e1c:	0207c063          	bltz	a5,80002e3c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	d48080e7          	jalr	-696(ra) # 80001b68 <myproc>
    80002e28:	4924                	lw	s1,80(a0)
  if (growproc(n) < 0)
    80002e2a:	fdc42503          	lw	a0,-36(s0)
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	03c080e7          	jalr	60(ra) # 80001e6a <growproc>
    80002e36:	00054863          	bltz	a0,80002e46 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002e3a:	8526                	mv	a0,s1
}
    80002e3c:	70a2                	ld	ra,40(sp)
    80002e3e:	7402                	ld	s0,32(sp)
    80002e40:	64e2                	ld	s1,24(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret
    return -1;
    80002e46:	557d                	li	a0,-1
    80002e48:	bfd5                	j	80002e3c <sys_sbrk+0x3c>

0000000080002e4a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e4a:	7139                	addi	sp,sp,-64
    80002e4c:	fc06                	sd	ra,56(sp)
    80002e4e:	f822                	sd	s0,48(sp)
    80002e50:	f426                	sd	s1,40(sp)
    80002e52:	f04a                	sd	s2,32(sp)
    80002e54:	ec4e                	sd	s3,24(sp)
    80002e56:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if (argint(0, &n) < 0)
    80002e58:	fcc40593          	addi	a1,s0,-52
    80002e5c:	4501                	li	a0,0
    80002e5e:	00000097          	auipc	ra,0x0
    80002e62:	e2a080e7          	jalr	-470(ra) # 80002c88 <argint>
    return -1;
    80002e66:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002e68:	06054563          	bltz	a0,80002ed2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002e6c:	00029517          	auipc	a0,0x29
    80002e70:	32c50513          	addi	a0,a0,812 # 8002c198 <tickslock>
    80002e74:	ffffe097          	auipc	ra,0xffffe
    80002e78:	d28080e7          	jalr	-728(ra) # 80000b9c <acquire>
  ticks0 = ticks;
    80002e7c:	00007917          	auipc	s2,0x7
    80002e80:	5e492903          	lw	s2,1508(s2) # 8000a460 <ticks>
  while (ticks - ticks0 < n)
    80002e84:	fcc42783          	lw	a5,-52(s0)
    80002e88:	cf85                	beqz	a5,80002ec0 <sys_sleep+0x76>
    if (myproc()->killed)
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e8a:	00029997          	auipc	s3,0x29
    80002e8e:	30e98993          	addi	s3,s3,782 # 8002c198 <tickslock>
    80002e92:	00007497          	auipc	s1,0x7
    80002e96:	5ce48493          	addi	s1,s1,1486 # 8000a460 <ticks>
    if (myproc()->killed)
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	cce080e7          	jalr	-818(ra) # 80001b68 <myproc>
    80002ea2:	5d1c                	lw	a5,56(a0)
    80002ea4:	ef9d                	bnez	a5,80002ee2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002ea6:	85ce                	mv	a1,s3
    80002ea8:	8526                	mv	a0,s1
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	48c080e7          	jalr	1164(ra) # 80002336 <sleep>
  while (ticks - ticks0 < n)
    80002eb2:	409c                	lw	a5,0(s1)
    80002eb4:	412787bb          	subw	a5,a5,s2
    80002eb8:	fcc42703          	lw	a4,-52(s0)
    80002ebc:	fce7efe3          	bltu	a5,a4,80002e9a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002ec0:	00029517          	auipc	a0,0x29
    80002ec4:	2d850513          	addi	a0,a0,728 # 8002c198 <tickslock>
    80002ec8:	ffffe097          	auipc	ra,0xffffe
    80002ecc:	da4080e7          	jalr	-604(ra) # 80000c6c <release>
  return 0;
    80002ed0:	4781                	li	a5,0
}
    80002ed2:	853e                	mv	a0,a5
    80002ed4:	70e2                	ld	ra,56(sp)
    80002ed6:	7442                	ld	s0,48(sp)
    80002ed8:	74a2                	ld	s1,40(sp)
    80002eda:	7902                	ld	s2,32(sp)
    80002edc:	69e2                	ld	s3,24(sp)
    80002ede:	6121                	addi	sp,sp,64
    80002ee0:	8082                	ret
      release(&tickslock);
    80002ee2:	00029517          	auipc	a0,0x29
    80002ee6:	2b650513          	addi	a0,a0,694 # 8002c198 <tickslock>
    80002eea:	ffffe097          	auipc	ra,0xffffe
    80002eee:	d82080e7          	jalr	-638(ra) # 80000c6c <release>
      return -1;
    80002ef2:	57fd                	li	a5,-1
    80002ef4:	bff9                	j	80002ed2 <sys_sleep+0x88>

0000000080002ef6 <sys_kill>:

uint64
sys_kill(void)
{
    80002ef6:	1101                	addi	sp,sp,-32
    80002ef8:	ec06                	sd	ra,24(sp)
    80002efa:	e822                	sd	s0,16(sp)
    80002efc:	1000                	addi	s0,sp,32
  int pid;

  if (argint(0, &pid) < 0)
    80002efe:	fec40593          	addi	a1,s0,-20
    80002f02:	4501                	li	a0,0
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	d84080e7          	jalr	-636(ra) # 80002c88 <argint>
    80002f0c:	87aa                	mv	a5,a0
    return -1;
    80002f0e:	557d                	li	a0,-1
  if (argint(0, &pid) < 0)
    80002f10:	0007c863          	bltz	a5,80002f20 <sys_kill+0x2a>
  return kill(pid);
    80002f14:	fec42503          	lw	a0,-20(s0)
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	60e080e7          	jalr	1550(ra) # 80002526 <kill>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret

0000000080002f28 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f28:	1101                	addi	sp,sp,-32
    80002f2a:	ec06                	sd	ra,24(sp)
    80002f2c:	e822                	sd	s0,16(sp)
    80002f2e:	e426                	sd	s1,8(sp)
    80002f30:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f32:	00029517          	auipc	a0,0x29
    80002f36:	26650513          	addi	a0,a0,614 # 8002c198 <tickslock>
    80002f3a:	ffffe097          	auipc	ra,0xffffe
    80002f3e:	c62080e7          	jalr	-926(ra) # 80000b9c <acquire>
  xticks = ticks;
    80002f42:	00007497          	auipc	s1,0x7
    80002f46:	51e4a483          	lw	s1,1310(s1) # 8000a460 <ticks>
  release(&tickslock);
    80002f4a:	00029517          	auipc	a0,0x29
    80002f4e:	24e50513          	addi	a0,a0,590 # 8002c198 <tickslock>
    80002f52:	ffffe097          	auipc	ra,0xffffe
    80002f56:	d1a080e7          	jalr	-742(ra) # 80000c6c <release>
  return xticks;
}
    80002f5a:	02049513          	slli	a0,s1,0x20
    80002f5e:	9101                	srli	a0,a0,0x20
    80002f60:	60e2                	ld	ra,24(sp)
    80002f62:	6442                	ld	s0,16(sp)
    80002f64:	64a2                	ld	s1,8(sp)
    80002f66:	6105                	addi	sp,sp,32
    80002f68:	8082                	ret

0000000080002f6a <sys_test_rcu>:

uint64
sys_test_rcu(void)
{
    80002f6a:	1141                	addi	sp,sp,-16
    80002f6c:	e406                	sd	ra,8(sp)
    80002f6e:	e022                	sd	s0,0(sp)
    80002f70:	0800                	addi	s0,sp,16
  test_rcu();
    80002f72:	00004097          	auipc	ra,0x4
    80002f76:	666080e7          	jalr	1638(ra) # 800075d8 <test_rcu>
  return 0;
}
    80002f7a:	4501                	li	a0,0
    80002f7c:	60a2                	ld	ra,8(sp)
    80002f7e:	6402                	ld	s0,0(sp)
    80002f80:	0141                	addi	sp,sp,16
    80002f82:	8082                	ret

0000000080002f84 <sys_rcu_read_only>:

uint64
sys_rcu_read_only(void)
{
    80002f84:	1141                	addi	sp,sp,-16
    80002f86:	e406                	sd	ra,8(sp)
    80002f88:	e022                	sd	s0,0(sp)
    80002f8a:	0800                	addi	s0,sp,16
  rcu_read_only();
    80002f8c:	00004097          	auipc	ra,0x4
    80002f90:	72c080e7          	jalr	1836(ra) # 800076b8 <rcu_read_only>
  return 0;
}
    80002f94:	4501                	li	a0,0
    80002f96:	60a2                	ld	ra,8(sp)
    80002f98:	6402                	ld	s0,0(sp)
    80002f9a:	0141                	addi	sp,sp,16
    80002f9c:	8082                	ret

0000000080002f9e <sys_rcu_read_heavy>:

uint64
sys_rcu_read_heavy(void)
{
    80002f9e:	1141                	addi	sp,sp,-16
    80002fa0:	e406                	sd	ra,8(sp)
    80002fa2:	e022                	sd	s0,0(sp)
    80002fa4:	0800                	addi	s0,sp,16
  rcu_read_heavy();
    80002fa6:	00004097          	auipc	ra,0x4
    80002faa:	7d8080e7          	jalr	2008(ra) # 8000777e <rcu_read_heavy>
  return 0;
}
    80002fae:	4501                	li	a0,0
    80002fb0:	60a2                	ld	ra,8(sp)
    80002fb2:	6402                	ld	s0,0(sp)
    80002fb4:	0141                	addi	sp,sp,16
    80002fb6:	8082                	ret

0000000080002fb8 <sys_rcu_read_write_mix>:

uint64
sys_rcu_read_write_mix(void)
{
    80002fb8:	1141                	addi	sp,sp,-16
    80002fba:	e406                	sd	ra,8(sp)
    80002fbc:	e022                	sd	s0,0(sp)
    80002fbe:	0800                	addi	s0,sp,16
  rcu_read_write_mix();
    80002fc0:	00005097          	auipc	ra,0x5
    80002fc4:	a84080e7          	jalr	-1404(ra) # 80007a44 <rcu_read_write_mix>
  return 0;
}
    80002fc8:	4501                	li	a0,0
    80002fca:	60a2                	ld	ra,8(sp)
    80002fcc:	6402                	ld	s0,0(sp)
    80002fce:	0141                	addi	sp,sp,16
    80002fd0:	8082                	ret

0000000080002fd2 <sys_rcu_read_stress>:

uint64
sys_rcu_read_stress(void)
{
    80002fd2:	1141                	addi	sp,sp,-16
    80002fd4:	e406                	sd	ra,8(sp)
    80002fd6:	e022                	sd	s0,0(sp)
    80002fd8:	0800                	addi	s0,sp,16
  rcu_read_stress();
    80002fda:	00005097          	auipc	ra,0x5
    80002fde:	bde080e7          	jalr	-1058(ra) # 80007bb8 <rcu_read_stress>
  return 0;
    80002fe2:	4501                	li	a0,0
    80002fe4:	60a2                	ld	ra,8(sp)
    80002fe6:	6402                	ld	s0,0(sp)
    80002fe8:	0141                	addi	sp,sp,16
    80002fea:	8082                	ret

0000000080002fec <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fec:	7179                	addi	sp,sp,-48
    80002fee:	f406                	sd	ra,40(sp)
    80002ff0:	f022                	sd	s0,32(sp)
    80002ff2:	ec26                	sd	s1,24(sp)
    80002ff4:	e84a                	sd	s2,16(sp)
    80002ff6:	e44e                	sd	s3,8(sp)
    80002ff8:	e052                	sd	s4,0(sp)
    80002ffa:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ffc:	00007597          	auipc	a1,0x7
    80003000:	a1c58593          	addi	a1,a1,-1508 # 80009a18 <syscalls+0xe8>
    80003004:	00029517          	auipc	a0,0x29
    80003008:	1b450513          	addi	a0,a0,436 # 8002c1b8 <bcache>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	aba080e7          	jalr	-1350(ra) # 80000ac6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003014:	00031797          	auipc	a5,0x31
    80003018:	1a478793          	addi	a5,a5,420 # 800341b8 <bcache+0x8000>
    8000301c:	00031717          	auipc	a4,0x31
    80003020:	4fc70713          	addi	a4,a4,1276 # 80034518 <bcache+0x8360>
    80003024:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80003028:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000302c:	00029497          	auipc	s1,0x29
    80003030:	1ac48493          	addi	s1,s1,428 # 8002c1d8 <bcache+0x20>
    b->next = bcache.head.next;
    80003034:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003036:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003038:	00007a17          	auipc	s4,0x7
    8000303c:	9e8a0a13          	addi	s4,s4,-1560 # 80009a20 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003040:	3b893783          	ld	a5,952(s2)
    80003044:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80003046:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    8000304a:	85d2                	mv	a1,s4
    8000304c:	01048513          	addi	a0,s1,16
    80003050:	00001097          	auipc	ra,0x1
    80003054:	4aa080e7          	jalr	1194(ra) # 800044fa <initsleeplock>
    bcache.head.next->prev = b;
    80003058:	3b893783          	ld	a5,952(s2)
    8000305c:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    8000305e:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003062:	46048493          	addi	s1,s1,1120
    80003066:	fd349de3          	bne	s1,s3,80003040 <binit+0x54>
  }
}
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6942                	ld	s2,16(sp)
    80003072:	69a2                	ld	s3,8(sp)
    80003074:	6a02                	ld	s4,0(sp)
    80003076:	6145                	addi	sp,sp,48
    80003078:	8082                	ret

000000008000307a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000307a:	7179                	addi	sp,sp,-48
    8000307c:	f406                	sd	ra,40(sp)
    8000307e:	f022                	sd	s0,32(sp)
    80003080:	ec26                	sd	s1,24(sp)
    80003082:	e84a                	sd	s2,16(sp)
    80003084:	e44e                	sd	s3,8(sp)
    80003086:	1800                	addi	s0,sp,48
    80003088:	89aa                	mv	s3,a0
    8000308a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000308c:	00029517          	auipc	a0,0x29
    80003090:	12c50513          	addi	a0,a0,300 # 8002c1b8 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	b08080e7          	jalr	-1272(ra) # 80000b9c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000309c:	00031497          	auipc	s1,0x31
    800030a0:	4d44b483          	ld	s1,1236(s1) # 80034570 <bcache+0x83b8>
    800030a4:	00031797          	auipc	a5,0x31
    800030a8:	47478793          	addi	a5,a5,1140 # 80034518 <bcache+0x8360>
    800030ac:	02f48f63          	beq	s1,a5,800030ea <bread+0x70>
    800030b0:	873e                	mv	a4,a5
    800030b2:	a021                	j	800030ba <bread+0x40>
    800030b4:	6ca4                	ld	s1,88(s1)
    800030b6:	02e48a63          	beq	s1,a4,800030ea <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030ba:	449c                	lw	a5,8(s1)
    800030bc:	ff379ce3          	bne	a5,s3,800030b4 <bread+0x3a>
    800030c0:	44dc                	lw	a5,12(s1)
    800030c2:	ff2799e3          	bne	a5,s2,800030b4 <bread+0x3a>
      b->refcnt++;
    800030c6:	44bc                	lw	a5,72(s1)
    800030c8:	2785                	addiw	a5,a5,1
    800030ca:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800030cc:	00029517          	auipc	a0,0x29
    800030d0:	0ec50513          	addi	a0,a0,236 # 8002c1b8 <bcache>
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	b98080e7          	jalr	-1128(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    800030dc:	01048513          	addi	a0,s1,16
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	454080e7          	jalr	1108(ra) # 80004534 <acquiresleep>
      return b;
    800030e8:	a8b9                	j	80003146 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ea:	00031497          	auipc	s1,0x31
    800030ee:	47e4b483          	ld	s1,1150(s1) # 80034568 <bcache+0x83b0>
    800030f2:	00031797          	auipc	a5,0x31
    800030f6:	42678793          	addi	a5,a5,1062 # 80034518 <bcache+0x8360>
    800030fa:	00f48863          	beq	s1,a5,8000310a <bread+0x90>
    800030fe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003100:	44bc                	lw	a5,72(s1)
    80003102:	cf81                	beqz	a5,8000311a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003104:	68a4                	ld	s1,80(s1)
    80003106:	fee49de3          	bne	s1,a4,80003100 <bread+0x86>
  panic("bget: no buffers");
    8000310a:	00007517          	auipc	a0,0x7
    8000310e:	91e50513          	addi	a0,a0,-1762 # 80009a28 <syscalls+0xf8>
    80003112:	ffffd097          	auipc	ra,0xffffd
    80003116:	458080e7          	jalr	1112(ra) # 8000056a <panic>
      b->dev = dev;
    8000311a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000311e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003122:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003126:	4785                	li	a5,1
    80003128:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000312a:	00029517          	auipc	a0,0x29
    8000312e:	08e50513          	addi	a0,a0,142 # 8002c1b8 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	b3a080e7          	jalr	-1222(ra) # 80000c6c <release>
      acquiresleep(&b->lock);
    8000313a:	01048513          	addi	a0,s1,16
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	3f6080e7          	jalr	1014(ra) # 80004534 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003146:	409c                	lw	a5,0(s1)
    80003148:	cb89                	beqz	a5,8000315a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000314a:	8526                	mv	a0,s1
    8000314c:	70a2                	ld	ra,40(sp)
    8000314e:	7402                	ld	s0,32(sp)
    80003150:	64e2                	ld	s1,24(sp)
    80003152:	6942                	ld	s2,16(sp)
    80003154:	69a2                	ld	s3,8(sp)
    80003156:	6145                	addi	sp,sp,48
    80003158:	8082                	ret
    virtio_disk_rw(b, 0);
    8000315a:	4581                	li	a1,0
    8000315c:	8526                	mv	a0,s1
    8000315e:	00003097          	auipc	ra,0x3
    80003162:	f8a080e7          	jalr	-118(ra) # 800060e8 <virtio_disk_rw>
    b->valid = 1;
    80003166:	4785                	li	a5,1
    80003168:	c09c                	sw	a5,0(s1)
  return b;
    8000316a:	b7c5                	j	8000314a <bread+0xd0>

000000008000316c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000316c:	1101                	addi	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	e426                	sd	s1,8(sp)
    80003174:	1000                	addi	s0,sp,32
    80003176:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003178:	0541                	addi	a0,a0,16
    8000317a:	00001097          	auipc	ra,0x1
    8000317e:	454080e7          	jalr	1108(ra) # 800045ce <holdingsleep>
    80003182:	cd01                	beqz	a0,8000319a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003184:	4585                	li	a1,1
    80003186:	8526                	mv	a0,s1
    80003188:	00003097          	auipc	ra,0x3
    8000318c:	f60080e7          	jalr	-160(ra) # 800060e8 <virtio_disk_rw>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret
    panic("bwrite");
    8000319a:	00007517          	auipc	a0,0x7
    8000319e:	8a650513          	addi	a0,a0,-1882 # 80009a40 <syscalls+0x110>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	3c8080e7          	jalr	968(ra) # 8000056a <panic>

00000000800031aa <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b8:	01050913          	addi	s2,a0,16
    800031bc:	854a                	mv	a0,s2
    800031be:	00001097          	auipc	ra,0x1
    800031c2:	410080e7          	jalr	1040(ra) # 800045ce <holdingsleep>
    800031c6:	c92d                	beqz	a0,80003238 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	3c0080e7          	jalr	960(ra) # 8000458a <releasesleep>

  acquire(&bcache.lock);
    800031d2:	00029517          	auipc	a0,0x29
    800031d6:	fe650513          	addi	a0,a0,-26 # 8002c1b8 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	9c2080e7          	jalr	-1598(ra) # 80000b9c <acquire>
  b->refcnt--;
    800031e2:	44bc                	lw	a5,72(s1)
    800031e4:	37fd                	addiw	a5,a5,-1
    800031e6:	0007871b          	sext.w	a4,a5
    800031ea:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800031ec:	eb05                	bnez	a4,8000321c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ee:	6cbc                	ld	a5,88(s1)
    800031f0:	68b8                	ld	a4,80(s1)
    800031f2:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800031f4:	68bc                	ld	a5,80(s1)
    800031f6:	6cb8                	ld	a4,88(s1)
    800031f8:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800031fa:	00031797          	auipc	a5,0x31
    800031fe:	fbe78793          	addi	a5,a5,-66 # 800341b8 <bcache+0x8000>
    80003202:	3b87b703          	ld	a4,952(a5)
    80003206:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    80003208:	00031717          	auipc	a4,0x31
    8000320c:	31070713          	addi	a4,a4,784 # 80034518 <bcache+0x8360>
    80003210:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003212:	3b87b703          	ld	a4,952(a5)
    80003216:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    80003218:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    8000321c:	00029517          	auipc	a0,0x29
    80003220:	f9c50513          	addi	a0,a0,-100 # 8002c1b8 <bcache>
    80003224:	ffffe097          	auipc	ra,0xffffe
    80003228:	a48080e7          	jalr	-1464(ra) # 80000c6c <release>
}
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	64a2                	ld	s1,8(sp)
    80003232:	6902                	ld	s2,0(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret
    panic("brelse");
    80003238:	00007517          	auipc	a0,0x7
    8000323c:	81050513          	addi	a0,a0,-2032 # 80009a48 <syscalls+0x118>
    80003240:	ffffd097          	auipc	ra,0xffffd
    80003244:	32a080e7          	jalr	810(ra) # 8000056a <panic>

0000000080003248 <bpin>:

void
bpin(struct buf *b) {
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	1000                	addi	s0,sp,32
    80003252:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003254:	00029517          	auipc	a0,0x29
    80003258:	f6450513          	addi	a0,a0,-156 # 8002c1b8 <bcache>
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	940080e7          	jalr	-1728(ra) # 80000b9c <acquire>
  b->refcnt++;
    80003264:	44bc                	lw	a5,72(s1)
    80003266:	2785                	addiw	a5,a5,1
    80003268:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000326a:	00029517          	auipc	a0,0x29
    8000326e:	f4e50513          	addi	a0,a0,-178 # 8002c1b8 <bcache>
    80003272:	ffffe097          	auipc	ra,0xffffe
    80003276:	9fa080e7          	jalr	-1542(ra) # 80000c6c <release>
}
    8000327a:	60e2                	ld	ra,24(sp)
    8000327c:	6442                	ld	s0,16(sp)
    8000327e:	64a2                	ld	s1,8(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret

0000000080003284 <bunpin>:

void
bunpin(struct buf *b) {
    80003284:	1101                	addi	sp,sp,-32
    80003286:	ec06                	sd	ra,24(sp)
    80003288:	e822                	sd	s0,16(sp)
    8000328a:	e426                	sd	s1,8(sp)
    8000328c:	1000                	addi	s0,sp,32
    8000328e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003290:	00029517          	auipc	a0,0x29
    80003294:	f2850513          	addi	a0,a0,-216 # 8002c1b8 <bcache>
    80003298:	ffffe097          	auipc	ra,0xffffe
    8000329c:	904080e7          	jalr	-1788(ra) # 80000b9c <acquire>
  b->refcnt--;
    800032a0:	44bc                	lw	a5,72(s1)
    800032a2:	37fd                	addiw	a5,a5,-1
    800032a4:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800032a6:	00029517          	auipc	a0,0x29
    800032aa:	f1250513          	addi	a0,a0,-238 # 8002c1b8 <bcache>
    800032ae:	ffffe097          	auipc	ra,0xffffe
    800032b2:	9be080e7          	jalr	-1602(ra) # 80000c6c <release>
}
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	64a2                	ld	s1,8(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret

00000000800032c0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032c0:	1101                	addi	sp,sp,-32
    800032c2:	ec06                	sd	ra,24(sp)
    800032c4:	e822                	sd	s0,16(sp)
    800032c6:	e426                	sd	s1,8(sp)
    800032c8:	e04a                	sd	s2,0(sp)
    800032ca:	1000                	addi	s0,sp,32
    800032cc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032ce:	00d5d59b          	srliw	a1,a1,0xd
    800032d2:	00031797          	auipc	a5,0x31
    800032d6:	6c27a783          	lw	a5,1730(a5) # 80034994 <sb+0x1c>
    800032da:	9dbd                	addw	a1,a1,a5
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	d9e080e7          	jalr	-610(ra) # 8000307a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032e4:	0074f713          	andi	a4,s1,7
    800032e8:	4785                	li	a5,1
    800032ea:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032ee:	14ce                	slli	s1,s1,0x33
    800032f0:	90d9                	srli	s1,s1,0x36
    800032f2:	00950733          	add	a4,a0,s1
    800032f6:	06074703          	lbu	a4,96(a4)
    800032fa:	00e7f6b3          	and	a3,a5,a4
    800032fe:	c69d                	beqz	a3,8000332c <bfree+0x6c>
    80003300:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003302:	94aa                	add	s1,s1,a0
    80003304:	fff7c793          	not	a5,a5
    80003308:	8ff9                	and	a5,a5,a4
    8000330a:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    8000330e:	00001097          	auipc	ra,0x1
    80003312:	106080e7          	jalr	262(ra) # 80004414 <log_write>
  brelse(bp);
    80003316:	854a                	mv	a0,s2
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	e92080e7          	jalr	-366(ra) # 800031aa <brelse>
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	64a2                	ld	s1,8(sp)
    80003326:	6902                	ld	s2,0(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret
    panic("freeing free block");
    8000332c:	00006517          	auipc	a0,0x6
    80003330:	72450513          	addi	a0,a0,1828 # 80009a50 <syscalls+0x120>
    80003334:	ffffd097          	auipc	ra,0xffffd
    80003338:	236080e7          	jalr	566(ra) # 8000056a <panic>

000000008000333c <balloc>:
{
    8000333c:	711d                	addi	sp,sp,-96
    8000333e:	ec86                	sd	ra,88(sp)
    80003340:	e8a2                	sd	s0,80(sp)
    80003342:	e4a6                	sd	s1,72(sp)
    80003344:	e0ca                	sd	s2,64(sp)
    80003346:	fc4e                	sd	s3,56(sp)
    80003348:	f852                	sd	s4,48(sp)
    8000334a:	f456                	sd	s5,40(sp)
    8000334c:	f05a                	sd	s6,32(sp)
    8000334e:	ec5e                	sd	s7,24(sp)
    80003350:	e862                	sd	s8,16(sp)
    80003352:	e466                	sd	s9,8(sp)
    80003354:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003356:	00031797          	auipc	a5,0x31
    8000335a:	6267a783          	lw	a5,1574(a5) # 8003497c <sb+0x4>
    8000335e:	cbd1                	beqz	a5,800033f2 <balloc+0xb6>
    80003360:	8baa                	mv	s7,a0
    80003362:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003364:	00031b17          	auipc	s6,0x31
    80003368:	614b0b13          	addi	s6,s6,1556 # 80034978 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000336c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000336e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003370:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003372:	6c89                	lui	s9,0x2
    80003374:	a831                	j	80003390 <balloc+0x54>
    brelse(bp);
    80003376:	854a                	mv	a0,s2
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	e32080e7          	jalr	-462(ra) # 800031aa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003380:	015c87bb          	addw	a5,s9,s5
    80003384:	00078a9b          	sext.w	s5,a5
    80003388:	004b2703          	lw	a4,4(s6)
    8000338c:	06eaf363          	bgeu	s5,a4,800033f2 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003390:	41fad79b          	sraiw	a5,s5,0x1f
    80003394:	0137d79b          	srliw	a5,a5,0x13
    80003398:	015787bb          	addw	a5,a5,s5
    8000339c:	40d7d79b          	sraiw	a5,a5,0xd
    800033a0:	01cb2583          	lw	a1,28(s6)
    800033a4:	9dbd                	addw	a1,a1,a5
    800033a6:	855e                	mv	a0,s7
    800033a8:	00000097          	auipc	ra,0x0
    800033ac:	cd2080e7          	jalr	-814(ra) # 8000307a <bread>
    800033b0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033b2:	004b2503          	lw	a0,4(s6)
    800033b6:	000a849b          	sext.w	s1,s5
    800033ba:	8662                	mv	a2,s8
    800033bc:	faa4fde3          	bgeu	s1,a0,80003376 <balloc+0x3a>
      m = 1 << (bi % 8);
    800033c0:	41f6579b          	sraiw	a5,a2,0x1f
    800033c4:	01d7d69b          	srliw	a3,a5,0x1d
    800033c8:	00c6873b          	addw	a4,a3,a2
    800033cc:	00777793          	andi	a5,a4,7
    800033d0:	9f95                	subw	a5,a5,a3
    800033d2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033d6:	4037571b          	sraiw	a4,a4,0x3
    800033da:	00e906b3          	add	a3,s2,a4
    800033de:	0606c683          	lbu	a3,96(a3)
    800033e2:	00d7f5b3          	and	a1,a5,a3
    800033e6:	cd91                	beqz	a1,80003402 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e8:	2605                	addiw	a2,a2,1
    800033ea:	2485                	addiw	s1,s1,1
    800033ec:	fd4618e3          	bne	a2,s4,800033bc <balloc+0x80>
    800033f0:	b759                	j	80003376 <balloc+0x3a>
  panic("balloc: out of blocks");
    800033f2:	00006517          	auipc	a0,0x6
    800033f6:	67650513          	addi	a0,a0,1654 # 80009a68 <syscalls+0x138>
    800033fa:	ffffd097          	auipc	ra,0xffffd
    800033fe:	170080e7          	jalr	368(ra) # 8000056a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003402:	974a                	add	a4,a4,s2
    80003404:	8fd5                	or	a5,a5,a3
    80003406:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000340a:	854a                	mv	a0,s2
    8000340c:	00001097          	auipc	ra,0x1
    80003410:	008080e7          	jalr	8(ra) # 80004414 <log_write>
        brelse(bp);
    80003414:	854a                	mv	a0,s2
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	d94080e7          	jalr	-620(ra) # 800031aa <brelse>
  bp = bread(dev, bno);
    8000341e:	85a6                	mv	a1,s1
    80003420:	855e                	mv	a0,s7
    80003422:	00000097          	auipc	ra,0x0
    80003426:	c58080e7          	jalr	-936(ra) # 8000307a <bread>
    8000342a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000342c:	40000613          	li	a2,1024
    80003430:	4581                	li	a1,0
    80003432:	06050513          	addi	a0,a0,96
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	a4a080e7          	jalr	-1462(ra) # 80000e80 <memset>
  log_write(bp);
    8000343e:	854a                	mv	a0,s2
    80003440:	00001097          	auipc	ra,0x1
    80003444:	fd4080e7          	jalr	-44(ra) # 80004414 <log_write>
  brelse(bp);
    80003448:	854a                	mv	a0,s2
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	d60080e7          	jalr	-672(ra) # 800031aa <brelse>
}
    80003452:	8526                	mv	a0,s1
    80003454:	60e6                	ld	ra,88(sp)
    80003456:	6446                	ld	s0,80(sp)
    80003458:	64a6                	ld	s1,72(sp)
    8000345a:	6906                	ld	s2,64(sp)
    8000345c:	79e2                	ld	s3,56(sp)
    8000345e:	7a42                	ld	s4,48(sp)
    80003460:	7aa2                	ld	s5,40(sp)
    80003462:	7b02                	ld	s6,32(sp)
    80003464:	6be2                	ld	s7,24(sp)
    80003466:	6c42                	ld	s8,16(sp)
    80003468:	6ca2                	ld	s9,8(sp)
    8000346a:	6125                	addi	sp,sp,96
    8000346c:	8082                	ret

000000008000346e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000346e:	7179                	addi	sp,sp,-48
    80003470:	f406                	sd	ra,40(sp)
    80003472:	f022                	sd	s0,32(sp)
    80003474:	ec26                	sd	s1,24(sp)
    80003476:	e84a                	sd	s2,16(sp)
    80003478:	e44e                	sd	s3,8(sp)
    8000347a:	e052                	sd	s4,0(sp)
    8000347c:	1800                	addi	s0,sp,48
    8000347e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003480:	47ad                	li	a5,11
    80003482:	04b7fe63          	bgeu	a5,a1,800034de <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003486:	ff45849b          	addiw	s1,a1,-12
    8000348a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000348e:	0ff00793          	li	a5,255
    80003492:	0ae7e363          	bltu	a5,a4,80003538 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003496:	08852583          	lw	a1,136(a0)
    8000349a:	c5ad                	beqz	a1,80003504 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000349c:	00092503          	lw	a0,0(s2)
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	bda080e7          	jalr	-1062(ra) # 8000307a <bread>
    800034a8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034aa:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800034ae:	02049593          	slli	a1,s1,0x20
    800034b2:	9181                	srli	a1,a1,0x20
    800034b4:	058a                	slli	a1,a1,0x2
    800034b6:	00b784b3          	add	s1,a5,a1
    800034ba:	0004a983          	lw	s3,0(s1)
    800034be:	04098d63          	beqz	s3,80003518 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034c2:	8552                	mv	a0,s4
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	ce6080e7          	jalr	-794(ra) # 800031aa <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034cc:	854e                	mv	a0,s3
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6a02                	ld	s4,0(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034de:	02059493          	slli	s1,a1,0x20
    800034e2:	9081                	srli	s1,s1,0x20
    800034e4:	048a                	slli	s1,s1,0x2
    800034e6:	94aa                	add	s1,s1,a0
    800034e8:	0584a983          	lw	s3,88(s1)
    800034ec:	fe0990e3          	bnez	s3,800034cc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034f0:	4108                	lw	a0,0(a0)
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	e4a080e7          	jalr	-438(ra) # 8000333c <balloc>
    800034fa:	0005099b          	sext.w	s3,a0
    800034fe:	0534ac23          	sw	s3,88(s1)
    80003502:	b7e9                	j	800034cc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003504:	4108                	lw	a0,0(a0)
    80003506:	00000097          	auipc	ra,0x0
    8000350a:	e36080e7          	jalr	-458(ra) # 8000333c <balloc>
    8000350e:	0005059b          	sext.w	a1,a0
    80003512:	08b92423          	sw	a1,136(s2)
    80003516:	b759                	j	8000349c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003518:	00092503          	lw	a0,0(s2)
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	e20080e7          	jalr	-480(ra) # 8000333c <balloc>
    80003524:	0005099b          	sext.w	s3,a0
    80003528:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000352c:	8552                	mv	a0,s4
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	ee6080e7          	jalr	-282(ra) # 80004414 <log_write>
    80003536:	b771                	j	800034c2 <bmap+0x54>
  panic("bmap: out of range");
    80003538:	00006517          	auipc	a0,0x6
    8000353c:	54850513          	addi	a0,a0,1352 # 80009a80 <syscalls+0x150>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	02a080e7          	jalr	42(ra) # 8000056a <panic>

0000000080003548 <iget>:
{
    80003548:	7179                	addi	sp,sp,-48
    8000354a:	f406                	sd	ra,40(sp)
    8000354c:	f022                	sd	s0,32(sp)
    8000354e:	ec26                	sd	s1,24(sp)
    80003550:	e84a                	sd	s2,16(sp)
    80003552:	e44e                	sd	s3,8(sp)
    80003554:	e052                	sd	s4,0(sp)
    80003556:	1800                	addi	s0,sp,48
    80003558:	89aa                	mv	s3,a0
    8000355a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000355c:	00031517          	auipc	a0,0x31
    80003560:	43c50513          	addi	a0,a0,1084 # 80034998 <icache>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	638080e7          	jalr	1592(ra) # 80000b9c <acquire>
  empty = 0;
    8000356c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000356e:	00031497          	auipc	s1,0x31
    80003572:	44a48493          	addi	s1,s1,1098 # 800349b8 <icache+0x20>
    80003576:	00033697          	auipc	a3,0x33
    8000357a:	06268693          	addi	a3,a3,98 # 800365d8 <log>
    8000357e:	a039                	j	8000358c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003580:	02090b63          	beqz	s2,800035b6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003584:	09048493          	addi	s1,s1,144
    80003588:	02d48a63          	beq	s1,a3,800035bc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000358c:	449c                	lw	a5,8(s1)
    8000358e:	fef059e3          	blez	a5,80003580 <iget+0x38>
    80003592:	4098                	lw	a4,0(s1)
    80003594:	ff3716e3          	bne	a4,s3,80003580 <iget+0x38>
    80003598:	40d8                	lw	a4,4(s1)
    8000359a:	ff4713e3          	bne	a4,s4,80003580 <iget+0x38>
      ip->ref++;
    8000359e:	2785                	addiw	a5,a5,1
    800035a0:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800035a2:	00031517          	auipc	a0,0x31
    800035a6:	3f650513          	addi	a0,a0,1014 # 80034998 <icache>
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	6c2080e7          	jalr	1730(ra) # 80000c6c <release>
      return ip;
    800035b2:	8926                	mv	s2,s1
    800035b4:	a03d                	j	800035e2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035b6:	f7f9                	bnez	a5,80003584 <iget+0x3c>
    800035b8:	8926                	mv	s2,s1
    800035ba:	b7e9                	j	80003584 <iget+0x3c>
  if(empty == 0)
    800035bc:	02090c63          	beqz	s2,800035f4 <iget+0xac>
  ip->dev = dev;
    800035c0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035c4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035c8:	4785                	li	a5,1
    800035ca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035ce:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800035d2:	00031517          	auipc	a0,0x31
    800035d6:	3c650513          	addi	a0,a0,966 # 80034998 <icache>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	692080e7          	jalr	1682(ra) # 80000c6c <release>
}
    800035e2:	854a                	mv	a0,s2
    800035e4:	70a2                	ld	ra,40(sp)
    800035e6:	7402                	ld	s0,32(sp)
    800035e8:	64e2                	ld	s1,24(sp)
    800035ea:	6942                	ld	s2,16(sp)
    800035ec:	69a2                	ld	s3,8(sp)
    800035ee:	6a02                	ld	s4,0(sp)
    800035f0:	6145                	addi	sp,sp,48
    800035f2:	8082                	ret
    panic("iget: no inodes");
    800035f4:	00006517          	auipc	a0,0x6
    800035f8:	4a450513          	addi	a0,a0,1188 # 80009a98 <syscalls+0x168>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	f6e080e7          	jalr	-146(ra) # 8000056a <panic>

0000000080003604 <fsinit>:
fsinit(int dev) {
    80003604:	7179                	addi	sp,sp,-48
    80003606:	f406                	sd	ra,40(sp)
    80003608:	f022                	sd	s0,32(sp)
    8000360a:	ec26                	sd	s1,24(sp)
    8000360c:	e84a                	sd	s2,16(sp)
    8000360e:	e44e                	sd	s3,8(sp)
    80003610:	1800                	addi	s0,sp,48
    80003612:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003614:	4585                	li	a1,1
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	a64080e7          	jalr	-1436(ra) # 8000307a <bread>
    8000361e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003620:	00031997          	auipc	s3,0x31
    80003624:	35898993          	addi	s3,s3,856 # 80034978 <sb>
    80003628:	02000613          	li	a2,32
    8000362c:	06050593          	addi	a1,a0,96
    80003630:	854e                	mv	a0,s3
    80003632:	ffffe097          	auipc	ra,0xffffe
    80003636:	8ae080e7          	jalr	-1874(ra) # 80000ee0 <memmove>
  brelse(bp);
    8000363a:	8526                	mv	a0,s1
    8000363c:	00000097          	auipc	ra,0x0
    80003640:	b6e080e7          	jalr	-1170(ra) # 800031aa <brelse>
  if(sb.magic != FSMAGIC)
    80003644:	0009a703          	lw	a4,0(s3)
    80003648:	102037b7          	lui	a5,0x10203
    8000364c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003650:	02f71263          	bne	a4,a5,80003674 <fsinit+0x70>
  initlog(dev, &sb);
    80003654:	00031597          	auipc	a1,0x31
    80003658:	32458593          	addi	a1,a1,804 # 80034978 <sb>
    8000365c:	854a                	mv	a0,s2
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	b3e080e7          	jalr	-1218(ra) # 8000419c <initlog>
}
    80003666:	70a2                	ld	ra,40(sp)
    80003668:	7402                	ld	s0,32(sp)
    8000366a:	64e2                	ld	s1,24(sp)
    8000366c:	6942                	ld	s2,16(sp)
    8000366e:	69a2                	ld	s3,8(sp)
    80003670:	6145                	addi	sp,sp,48
    80003672:	8082                	ret
    panic("invalid file system");
    80003674:	00006517          	auipc	a0,0x6
    80003678:	43450513          	addi	a0,a0,1076 # 80009aa8 <syscalls+0x178>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	eee080e7          	jalr	-274(ra) # 8000056a <panic>

0000000080003684 <iinit>:
{
    80003684:	7179                	addi	sp,sp,-48
    80003686:	f406                	sd	ra,40(sp)
    80003688:	f022                	sd	s0,32(sp)
    8000368a:	ec26                	sd	s1,24(sp)
    8000368c:	e84a                	sd	s2,16(sp)
    8000368e:	e44e                	sd	s3,8(sp)
    80003690:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003692:	00006597          	auipc	a1,0x6
    80003696:	42e58593          	addi	a1,a1,1070 # 80009ac0 <syscalls+0x190>
    8000369a:	00031517          	auipc	a0,0x31
    8000369e:	2fe50513          	addi	a0,a0,766 # 80034998 <icache>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	424080e7          	jalr	1060(ra) # 80000ac6 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036aa:	00031497          	auipc	s1,0x31
    800036ae:	31e48493          	addi	s1,s1,798 # 800349c8 <icache+0x30>
    800036b2:	00033997          	auipc	s3,0x33
    800036b6:	f3698993          	addi	s3,s3,-202 # 800365e8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036ba:	00006917          	auipc	s2,0x6
    800036be:	40e90913          	addi	s2,s2,1038 # 80009ac8 <syscalls+0x198>
    800036c2:	85ca                	mv	a1,s2
    800036c4:	8526                	mv	a0,s1
    800036c6:	00001097          	auipc	ra,0x1
    800036ca:	e34080e7          	jalr	-460(ra) # 800044fa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036ce:	09048493          	addi	s1,s1,144
    800036d2:	ff3498e3          	bne	s1,s3,800036c2 <iinit+0x3e>
}
    800036d6:	70a2                	ld	ra,40(sp)
    800036d8:	7402                	ld	s0,32(sp)
    800036da:	64e2                	ld	s1,24(sp)
    800036dc:	6942                	ld	s2,16(sp)
    800036de:	69a2                	ld	s3,8(sp)
    800036e0:	6145                	addi	sp,sp,48
    800036e2:	8082                	ret

00000000800036e4 <ialloc>:
{
    800036e4:	715d                	addi	sp,sp,-80
    800036e6:	e486                	sd	ra,72(sp)
    800036e8:	e0a2                	sd	s0,64(sp)
    800036ea:	fc26                	sd	s1,56(sp)
    800036ec:	f84a                	sd	s2,48(sp)
    800036ee:	f44e                	sd	s3,40(sp)
    800036f0:	f052                	sd	s4,32(sp)
    800036f2:	ec56                	sd	s5,24(sp)
    800036f4:	e85a                	sd	s6,16(sp)
    800036f6:	e45e                	sd	s7,8(sp)
    800036f8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036fa:	00031717          	auipc	a4,0x31
    800036fe:	28a72703          	lw	a4,650(a4) # 80034984 <sb+0xc>
    80003702:	4785                	li	a5,1
    80003704:	04e7fa63          	bgeu	a5,a4,80003758 <ialloc+0x74>
    80003708:	8aaa                	mv	s5,a0
    8000370a:	8bae                	mv	s7,a1
    8000370c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000370e:	00031a17          	auipc	s4,0x31
    80003712:	26aa0a13          	addi	s4,s4,618 # 80034978 <sb>
    80003716:	00048b1b          	sext.w	s6,s1
    8000371a:	0044d593          	srli	a1,s1,0x4
    8000371e:	018a2783          	lw	a5,24(s4)
    80003722:	9dbd                	addw	a1,a1,a5
    80003724:	8556                	mv	a0,s5
    80003726:	00000097          	auipc	ra,0x0
    8000372a:	954080e7          	jalr	-1708(ra) # 8000307a <bread>
    8000372e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003730:	06050993          	addi	s3,a0,96
    80003734:	00f4f793          	andi	a5,s1,15
    80003738:	079a                	slli	a5,a5,0x6
    8000373a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000373c:	00099783          	lh	a5,0(s3)
    80003740:	c785                	beqz	a5,80003768 <ialloc+0x84>
    brelse(bp);
    80003742:	00000097          	auipc	ra,0x0
    80003746:	a68080e7          	jalr	-1432(ra) # 800031aa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000374a:	0485                	addi	s1,s1,1
    8000374c:	00ca2703          	lw	a4,12(s4)
    80003750:	0004879b          	sext.w	a5,s1
    80003754:	fce7e1e3          	bltu	a5,a4,80003716 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003758:	00006517          	auipc	a0,0x6
    8000375c:	37850513          	addi	a0,a0,888 # 80009ad0 <syscalls+0x1a0>
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	e0a080e7          	jalr	-502(ra) # 8000056a <panic>
      memset(dip, 0, sizeof(*dip));
    80003768:	04000613          	li	a2,64
    8000376c:	4581                	li	a1,0
    8000376e:	854e                	mv	a0,s3
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	710080e7          	jalr	1808(ra) # 80000e80 <memset>
      dip->type = type;
    80003778:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000377c:	854a                	mv	a0,s2
    8000377e:	00001097          	auipc	ra,0x1
    80003782:	c96080e7          	jalr	-874(ra) # 80004414 <log_write>
      brelse(bp);
    80003786:	854a                	mv	a0,s2
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	a22080e7          	jalr	-1502(ra) # 800031aa <brelse>
      return iget(dev, inum);
    80003790:	85da                	mv	a1,s6
    80003792:	8556                	mv	a0,s5
    80003794:	00000097          	auipc	ra,0x0
    80003798:	db4080e7          	jalr	-588(ra) # 80003548 <iget>
}
    8000379c:	60a6                	ld	ra,72(sp)
    8000379e:	6406                	ld	s0,64(sp)
    800037a0:	74e2                	ld	s1,56(sp)
    800037a2:	7942                	ld	s2,48(sp)
    800037a4:	79a2                	ld	s3,40(sp)
    800037a6:	7a02                	ld	s4,32(sp)
    800037a8:	6ae2                	ld	s5,24(sp)
    800037aa:	6b42                	ld	s6,16(sp)
    800037ac:	6ba2                	ld	s7,8(sp)
    800037ae:	6161                	addi	sp,sp,80
    800037b0:	8082                	ret

00000000800037b2 <iupdate>:
{
    800037b2:	1101                	addi	sp,sp,-32
    800037b4:	ec06                	sd	ra,24(sp)
    800037b6:	e822                	sd	s0,16(sp)
    800037b8:	e426                	sd	s1,8(sp)
    800037ba:	e04a                	sd	s2,0(sp)
    800037bc:	1000                	addi	s0,sp,32
    800037be:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c0:	415c                	lw	a5,4(a0)
    800037c2:	0047d79b          	srliw	a5,a5,0x4
    800037c6:	00031597          	auipc	a1,0x31
    800037ca:	1ca5a583          	lw	a1,458(a1) # 80034990 <sb+0x18>
    800037ce:	9dbd                	addw	a1,a1,a5
    800037d0:	4108                	lw	a0,0(a0)
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	8a8080e7          	jalr	-1880(ra) # 8000307a <bread>
    800037da:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037dc:	06050793          	addi	a5,a0,96
    800037e0:	40c8                	lw	a0,4(s1)
    800037e2:	893d                	andi	a0,a0,15
    800037e4:	051a                	slli	a0,a0,0x6
    800037e6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037e8:	04c49703          	lh	a4,76(s1)
    800037ec:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800037f0:	04e49703          	lh	a4,78(s1)
    800037f4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800037f8:	05049703          	lh	a4,80(s1)
    800037fc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003800:	05249703          	lh	a4,82(s1)
    80003804:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003808:	48f8                	lw	a4,84(s1)
    8000380a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000380c:	03400613          	li	a2,52
    80003810:	05848593          	addi	a1,s1,88
    80003814:	0531                	addi	a0,a0,12
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	6ca080e7          	jalr	1738(ra) # 80000ee0 <memmove>
  log_write(bp);
    8000381e:	854a                	mv	a0,s2
    80003820:	00001097          	auipc	ra,0x1
    80003824:	bf4080e7          	jalr	-1036(ra) # 80004414 <log_write>
  brelse(bp);
    80003828:	854a                	mv	a0,s2
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	980080e7          	jalr	-1664(ra) # 800031aa <brelse>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6902                	ld	s2,0(sp)
    8000383a:	6105                	addi	sp,sp,32
    8000383c:	8082                	ret

000000008000383e <idup>:
{
    8000383e:	1101                	addi	sp,sp,-32
    80003840:	ec06                	sd	ra,24(sp)
    80003842:	e822                	sd	s0,16(sp)
    80003844:	e426                	sd	s1,8(sp)
    80003846:	1000                	addi	s0,sp,32
    80003848:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000384a:	00031517          	auipc	a0,0x31
    8000384e:	14e50513          	addi	a0,a0,334 # 80034998 <icache>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	34a080e7          	jalr	842(ra) # 80000b9c <acquire>
  ip->ref++;
    8000385a:	449c                	lw	a5,8(s1)
    8000385c:	2785                	addiw	a5,a5,1
    8000385e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003860:	00031517          	auipc	a0,0x31
    80003864:	13850513          	addi	a0,a0,312 # 80034998 <icache>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	404080e7          	jalr	1028(ra) # 80000c6c <release>
}
    80003870:	8526                	mv	a0,s1
    80003872:	60e2                	ld	ra,24(sp)
    80003874:	6442                	ld	s0,16(sp)
    80003876:	64a2                	ld	s1,8(sp)
    80003878:	6105                	addi	sp,sp,32
    8000387a:	8082                	ret

000000008000387c <ilock>:
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	e426                	sd	s1,8(sp)
    80003884:	e04a                	sd	s2,0(sp)
    80003886:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003888:	c115                	beqz	a0,800038ac <ilock+0x30>
    8000388a:	84aa                	mv	s1,a0
    8000388c:	451c                	lw	a5,8(a0)
    8000388e:	00f05f63          	blez	a5,800038ac <ilock+0x30>
  acquiresleep(&ip->lock);
    80003892:	0541                	addi	a0,a0,16
    80003894:	00001097          	auipc	ra,0x1
    80003898:	ca0080e7          	jalr	-864(ra) # 80004534 <acquiresleep>
  if(ip->valid == 0){
    8000389c:	44bc                	lw	a5,72(s1)
    8000389e:	cf99                	beqz	a5,800038bc <ilock+0x40>
}
    800038a0:	60e2                	ld	ra,24(sp)
    800038a2:	6442                	ld	s0,16(sp)
    800038a4:	64a2                	ld	s1,8(sp)
    800038a6:	6902                	ld	s2,0(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret
    panic("ilock");
    800038ac:	00006517          	auipc	a0,0x6
    800038b0:	23c50513          	addi	a0,a0,572 # 80009ae8 <syscalls+0x1b8>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	cb6080e7          	jalr	-842(ra) # 8000056a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038bc:	40dc                	lw	a5,4(s1)
    800038be:	0047d79b          	srliw	a5,a5,0x4
    800038c2:	00031597          	auipc	a1,0x31
    800038c6:	0ce5a583          	lw	a1,206(a1) # 80034990 <sb+0x18>
    800038ca:	9dbd                	addw	a1,a1,a5
    800038cc:	4088                	lw	a0,0(s1)
    800038ce:	fffff097          	auipc	ra,0xfffff
    800038d2:	7ac080e7          	jalr	1964(ra) # 8000307a <bread>
    800038d6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038d8:	06050593          	addi	a1,a0,96
    800038dc:	40dc                	lw	a5,4(s1)
    800038de:	8bbd                	andi	a5,a5,15
    800038e0:	079a                	slli	a5,a5,0x6
    800038e2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038e4:	00059783          	lh	a5,0(a1)
    800038e8:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    800038ec:	00259783          	lh	a5,2(a1)
    800038f0:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800038f4:	00459783          	lh	a5,4(a1)
    800038f8:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800038fc:	00659783          	lh	a5,6(a1)
    80003900:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003904:	459c                	lw	a5,8(a1)
    80003906:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003908:	03400613          	li	a2,52
    8000390c:	05b1                	addi	a1,a1,12
    8000390e:	05848513          	addi	a0,s1,88
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	5ce080e7          	jalr	1486(ra) # 80000ee0 <memmove>
    brelse(bp);
    8000391a:	854a                	mv	a0,s2
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	88e080e7          	jalr	-1906(ra) # 800031aa <brelse>
    ip->valid = 1;
    80003924:	4785                	li	a5,1
    80003926:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003928:	04c49783          	lh	a5,76(s1)
    8000392c:	fbb5                	bnez	a5,800038a0 <ilock+0x24>
      panic("ilock: no type");
    8000392e:	00006517          	auipc	a0,0x6
    80003932:	1c250513          	addi	a0,a0,450 # 80009af0 <syscalls+0x1c0>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	c34080e7          	jalr	-972(ra) # 8000056a <panic>

000000008000393e <iunlock>:
{
    8000393e:	1101                	addi	sp,sp,-32
    80003940:	ec06                	sd	ra,24(sp)
    80003942:	e822                	sd	s0,16(sp)
    80003944:	e426                	sd	s1,8(sp)
    80003946:	e04a                	sd	s2,0(sp)
    80003948:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000394a:	c905                	beqz	a0,8000397a <iunlock+0x3c>
    8000394c:	84aa                	mv	s1,a0
    8000394e:	01050913          	addi	s2,a0,16
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	c7a080e7          	jalr	-902(ra) # 800045ce <holdingsleep>
    8000395c:	cd19                	beqz	a0,8000397a <iunlock+0x3c>
    8000395e:	449c                	lw	a5,8(s1)
    80003960:	00f05d63          	blez	a5,8000397a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003964:	854a                	mv	a0,s2
    80003966:	00001097          	auipc	ra,0x1
    8000396a:	c24080e7          	jalr	-988(ra) # 8000458a <releasesleep>
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6902                	ld	s2,0(sp)
    80003976:	6105                	addi	sp,sp,32
    80003978:	8082                	ret
    panic("iunlock");
    8000397a:	00006517          	auipc	a0,0x6
    8000397e:	18650513          	addi	a0,a0,390 # 80009b00 <syscalls+0x1d0>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	be8080e7          	jalr	-1048(ra) # 8000056a <panic>

000000008000398a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000398a:	7179                	addi	sp,sp,-48
    8000398c:	f406                	sd	ra,40(sp)
    8000398e:	f022                	sd	s0,32(sp)
    80003990:	ec26                	sd	s1,24(sp)
    80003992:	e84a                	sd	s2,16(sp)
    80003994:	e44e                	sd	s3,8(sp)
    80003996:	e052                	sd	s4,0(sp)
    80003998:	1800                	addi	s0,sp,48
    8000399a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000399c:	05850493          	addi	s1,a0,88
    800039a0:	08850913          	addi	s2,a0,136
    800039a4:	a021                	j	800039ac <itrunc+0x22>
    800039a6:	0491                	addi	s1,s1,4
    800039a8:	01248d63          	beq	s1,s2,800039c2 <itrunc+0x38>
    if(ip->addrs[i]){
    800039ac:	408c                	lw	a1,0(s1)
    800039ae:	dde5                	beqz	a1,800039a6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039b0:	0009a503          	lw	a0,0(s3)
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	90c080e7          	jalr	-1780(ra) # 800032c0 <bfree>
      ip->addrs[i] = 0;
    800039bc:	0004a023          	sw	zero,0(s1)
    800039c0:	b7dd                	j	800039a6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039c2:	0889a583          	lw	a1,136(s3)
    800039c6:	e185                	bnez	a1,800039e6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039c8:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    800039cc:	854e                	mv	a0,s3
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	de4080e7          	jalr	-540(ra) # 800037b2 <iupdate>
}
    800039d6:	70a2                	ld	ra,40(sp)
    800039d8:	7402                	ld	s0,32(sp)
    800039da:	64e2                	ld	s1,24(sp)
    800039dc:	6942                	ld	s2,16(sp)
    800039de:	69a2                	ld	s3,8(sp)
    800039e0:	6a02                	ld	s4,0(sp)
    800039e2:	6145                	addi	sp,sp,48
    800039e4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039e6:	0009a503          	lw	a0,0(s3)
    800039ea:	fffff097          	auipc	ra,0xfffff
    800039ee:	690080e7          	jalr	1680(ra) # 8000307a <bread>
    800039f2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039f4:	06050493          	addi	s1,a0,96
    800039f8:	46050913          	addi	s2,a0,1120
    800039fc:	a811                	j	80003a10 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039fe:	0009a503          	lw	a0,0(s3)
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	8be080e7          	jalr	-1858(ra) # 800032c0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a0a:	0491                	addi	s1,s1,4
    80003a0c:	01248563          	beq	s1,s2,80003a16 <itrunc+0x8c>
      if(a[j])
    80003a10:	408c                	lw	a1,0(s1)
    80003a12:	dde5                	beqz	a1,80003a0a <itrunc+0x80>
    80003a14:	b7ed                	j	800039fe <itrunc+0x74>
    brelse(bp);
    80003a16:	8552                	mv	a0,s4
    80003a18:	fffff097          	auipc	ra,0xfffff
    80003a1c:	792080e7          	jalr	1938(ra) # 800031aa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a20:	0889a583          	lw	a1,136(s3)
    80003a24:	0009a503          	lw	a0,0(s3)
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	898080e7          	jalr	-1896(ra) # 800032c0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a30:	0809a423          	sw	zero,136(s3)
    80003a34:	bf51                	j	800039c8 <itrunc+0x3e>

0000000080003a36 <iput>:
{
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	e04a                	sd	s2,0(sp)
    80003a40:	1000                	addi	s0,sp,32
    80003a42:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a44:	00031517          	auipc	a0,0x31
    80003a48:	f5450513          	addi	a0,a0,-172 # 80034998 <icache>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	150080e7          	jalr	336(ra) # 80000b9c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a54:	4498                	lw	a4,8(s1)
    80003a56:	4785                	li	a5,1
    80003a58:	02f70363          	beq	a4,a5,80003a7e <iput+0x48>
  ip->ref--;
    80003a5c:	449c                	lw	a5,8(s1)
    80003a5e:	37fd                	addiw	a5,a5,-1
    80003a60:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a62:	00031517          	auipc	a0,0x31
    80003a66:	f3650513          	addi	a0,a0,-202 # 80034998 <icache>
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	202080e7          	jalr	514(ra) # 80000c6c <release>
}
    80003a72:	60e2                	ld	ra,24(sp)
    80003a74:	6442                	ld	s0,16(sp)
    80003a76:	64a2                	ld	s1,8(sp)
    80003a78:	6902                	ld	s2,0(sp)
    80003a7a:	6105                	addi	sp,sp,32
    80003a7c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a7e:	44bc                	lw	a5,72(s1)
    80003a80:	dff1                	beqz	a5,80003a5c <iput+0x26>
    80003a82:	05249783          	lh	a5,82(s1)
    80003a86:	fbf9                	bnez	a5,80003a5c <iput+0x26>
    acquiresleep(&ip->lock);
    80003a88:	01048913          	addi	s2,s1,16
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	00001097          	auipc	ra,0x1
    80003a92:	aa6080e7          	jalr	-1370(ra) # 80004534 <acquiresleep>
    release(&icache.lock);
    80003a96:	00031517          	auipc	a0,0x31
    80003a9a:	f0250513          	addi	a0,a0,-254 # 80034998 <icache>
    80003a9e:	ffffd097          	auipc	ra,0xffffd
    80003aa2:	1ce080e7          	jalr	462(ra) # 80000c6c <release>
    itrunc(ip);
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	ee2080e7          	jalr	-286(ra) # 8000398a <itrunc>
    ip->type = 0;
    80003ab0:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	cfc080e7          	jalr	-772(ra) # 800037b2 <iupdate>
    ip->valid = 0;
    80003abe:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003ac2:	854a                	mv	a0,s2
    80003ac4:	00001097          	auipc	ra,0x1
    80003ac8:	ac6080e7          	jalr	-1338(ra) # 8000458a <releasesleep>
    acquire(&icache.lock);
    80003acc:	00031517          	auipc	a0,0x31
    80003ad0:	ecc50513          	addi	a0,a0,-308 # 80034998 <icache>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	0c8080e7          	jalr	200(ra) # 80000b9c <acquire>
    80003adc:	b741                	j	80003a5c <iput+0x26>

0000000080003ade <iunlockput>:
{
    80003ade:	1101                	addi	sp,sp,-32
    80003ae0:	ec06                	sd	ra,24(sp)
    80003ae2:	e822                	sd	s0,16(sp)
    80003ae4:	e426                	sd	s1,8(sp)
    80003ae6:	1000                	addi	s0,sp,32
    80003ae8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003aea:	00000097          	auipc	ra,0x0
    80003aee:	e54080e7          	jalr	-428(ra) # 8000393e <iunlock>
  iput(ip);
    80003af2:	8526                	mv	a0,s1
    80003af4:	00000097          	auipc	ra,0x0
    80003af8:	f42080e7          	jalr	-190(ra) # 80003a36 <iput>
}
    80003afc:	60e2                	ld	ra,24(sp)
    80003afe:	6442                	ld	s0,16(sp)
    80003b00:	64a2                	ld	s1,8(sp)
    80003b02:	6105                	addi	sp,sp,32
    80003b04:	8082                	ret

0000000080003b06 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b06:	1141                	addi	sp,sp,-16
    80003b08:	e422                	sd	s0,8(sp)
    80003b0a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b0c:	411c                	lw	a5,0(a0)
    80003b0e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b10:	415c                	lw	a5,4(a0)
    80003b12:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b14:	04c51783          	lh	a5,76(a0)
    80003b18:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b1c:	05251783          	lh	a5,82(a0)
    80003b20:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b24:	05456783          	lwu	a5,84(a0)
    80003b28:	e99c                	sd	a5,16(a1)
}
    80003b2a:	6422                	ld	s0,8(sp)
    80003b2c:	0141                	addi	sp,sp,16
    80003b2e:	8082                	ret

0000000080003b30 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b30:	497c                	lw	a5,84(a0)
    80003b32:	0ed7e963          	bltu	a5,a3,80003c24 <readi+0xf4>
{
    80003b36:	7159                	addi	sp,sp,-112
    80003b38:	f486                	sd	ra,104(sp)
    80003b3a:	f0a2                	sd	s0,96(sp)
    80003b3c:	eca6                	sd	s1,88(sp)
    80003b3e:	e8ca                	sd	s2,80(sp)
    80003b40:	e4ce                	sd	s3,72(sp)
    80003b42:	e0d2                	sd	s4,64(sp)
    80003b44:	fc56                	sd	s5,56(sp)
    80003b46:	f85a                	sd	s6,48(sp)
    80003b48:	f45e                	sd	s7,40(sp)
    80003b4a:	f062                	sd	s8,32(sp)
    80003b4c:	ec66                	sd	s9,24(sp)
    80003b4e:	e86a                	sd	s10,16(sp)
    80003b50:	e46e                	sd	s11,8(sp)
    80003b52:	1880                	addi	s0,sp,112
    80003b54:	8baa                	mv	s7,a0
    80003b56:	8c2e                	mv	s8,a1
    80003b58:	8ab2                	mv	s5,a2
    80003b5a:	84b6                	mv	s1,a3
    80003b5c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b5e:	9f35                	addw	a4,a4,a3
    return 0;
    80003b60:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b62:	0ad76063          	bltu	a4,a3,80003c02 <readi+0xd2>
  if(off + n > ip->size)
    80003b66:	00e7f463          	bgeu	a5,a4,80003b6e <readi+0x3e>
    n = ip->size - off;
    80003b6a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b6e:	0a0b0963          	beqz	s6,80003c20 <readi+0xf0>
    80003b72:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b74:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b78:	5cfd                	li	s9,-1
    80003b7a:	a82d                	j	80003bb4 <readi+0x84>
    80003b7c:	020a1d93          	slli	s11,s4,0x20
    80003b80:	020ddd93          	srli	s11,s11,0x20
    80003b84:	06090613          	addi	a2,s2,96
    80003b88:	86ee                	mv	a3,s11
    80003b8a:	963a                	add	a2,a2,a4
    80003b8c:	85d6                	mv	a1,s5
    80003b8e:	8562                	mv	a0,s8
    80003b90:	fffff097          	auipc	ra,0xfffff
    80003b94:	a08080e7          	jalr	-1528(ra) # 80002598 <either_copyout>
    80003b98:	05950d63          	beq	a0,s9,80003bf2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b9c:	854a                	mv	a0,s2
    80003b9e:	fffff097          	auipc	ra,0xfffff
    80003ba2:	60c080e7          	jalr	1548(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba6:	013a09bb          	addw	s3,s4,s3
    80003baa:	009a04bb          	addw	s1,s4,s1
    80003bae:	9aee                	add	s5,s5,s11
    80003bb0:	0569f763          	bgeu	s3,s6,80003bfe <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bb4:	000ba903          	lw	s2,0(s7)
    80003bb8:	00a4d59b          	srliw	a1,s1,0xa
    80003bbc:	855e                	mv	a0,s7
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	8b0080e7          	jalr	-1872(ra) # 8000346e <bmap>
    80003bc6:	0005059b          	sext.w	a1,a0
    80003bca:	854a                	mv	a0,s2
    80003bcc:	fffff097          	auipc	ra,0xfffff
    80003bd0:	4ae080e7          	jalr	1198(ra) # 8000307a <bread>
    80003bd4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd6:	3ff4f713          	andi	a4,s1,1023
    80003bda:	40ed07bb          	subw	a5,s10,a4
    80003bde:	413b06bb          	subw	a3,s6,s3
    80003be2:	8a3e                	mv	s4,a5
    80003be4:	2781                	sext.w	a5,a5
    80003be6:	0006861b          	sext.w	a2,a3
    80003bea:	f8f679e3          	bgeu	a2,a5,80003b7c <readi+0x4c>
    80003bee:	8a36                	mv	s4,a3
    80003bf0:	b771                	j	80003b7c <readi+0x4c>
      brelse(bp);
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	fffff097          	auipc	ra,0xfffff
    80003bf8:	5b6080e7          	jalr	1462(ra) # 800031aa <brelse>
      tot = -1;
    80003bfc:	59fd                	li	s3,-1
  }
  return tot;
    80003bfe:	0009851b          	sext.w	a0,s3
}
    80003c02:	70a6                	ld	ra,104(sp)
    80003c04:	7406                	ld	s0,96(sp)
    80003c06:	64e6                	ld	s1,88(sp)
    80003c08:	6946                	ld	s2,80(sp)
    80003c0a:	69a6                	ld	s3,72(sp)
    80003c0c:	6a06                	ld	s4,64(sp)
    80003c0e:	7ae2                	ld	s5,56(sp)
    80003c10:	7b42                	ld	s6,48(sp)
    80003c12:	7ba2                	ld	s7,40(sp)
    80003c14:	7c02                	ld	s8,32(sp)
    80003c16:	6ce2                	ld	s9,24(sp)
    80003c18:	6d42                	ld	s10,16(sp)
    80003c1a:	6da2                	ld	s11,8(sp)
    80003c1c:	6165                	addi	sp,sp,112
    80003c1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c20:	89da                	mv	s3,s6
    80003c22:	bff1                	j	80003bfe <readi+0xce>
    return 0;
    80003c24:	4501                	li	a0,0
}
    80003c26:	8082                	ret

0000000080003c28 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c28:	497c                	lw	a5,84(a0)
    80003c2a:	10d7e863          	bltu	a5,a3,80003d3a <writei+0x112>
{
    80003c2e:	7159                	addi	sp,sp,-112
    80003c30:	f486                	sd	ra,104(sp)
    80003c32:	f0a2                	sd	s0,96(sp)
    80003c34:	eca6                	sd	s1,88(sp)
    80003c36:	e8ca                	sd	s2,80(sp)
    80003c38:	e4ce                	sd	s3,72(sp)
    80003c3a:	e0d2                	sd	s4,64(sp)
    80003c3c:	fc56                	sd	s5,56(sp)
    80003c3e:	f85a                	sd	s6,48(sp)
    80003c40:	f45e                	sd	s7,40(sp)
    80003c42:	f062                	sd	s8,32(sp)
    80003c44:	ec66                	sd	s9,24(sp)
    80003c46:	e86a                	sd	s10,16(sp)
    80003c48:	e46e                	sd	s11,8(sp)
    80003c4a:	1880                	addi	s0,sp,112
    80003c4c:	8b2a                	mv	s6,a0
    80003c4e:	8c2e                	mv	s8,a1
    80003c50:	8ab2                	mv	s5,a2
    80003c52:	8936                	mv	s2,a3
    80003c54:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c56:	00e687bb          	addw	a5,a3,a4
    80003c5a:	0ed7e263          	bltu	a5,a3,80003d3e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c5e:	00043737          	lui	a4,0x43
    80003c62:	0ef76063          	bltu	a4,a5,80003d42 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c66:	0c0b8863          	beqz	s7,80003d36 <writei+0x10e>
    80003c6a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c6c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c70:	5cfd                	li	s9,-1
    80003c72:	a091                	j	80003cb6 <writei+0x8e>
    80003c74:	02099d93          	slli	s11,s3,0x20
    80003c78:	020ddd93          	srli	s11,s11,0x20
    80003c7c:	06048513          	addi	a0,s1,96
    80003c80:	86ee                	mv	a3,s11
    80003c82:	8656                	mv	a2,s5
    80003c84:	85e2                	mv	a1,s8
    80003c86:	953a                	add	a0,a0,a4
    80003c88:	fffff097          	auipc	ra,0xfffff
    80003c8c:	966080e7          	jalr	-1690(ra) # 800025ee <either_copyin>
    80003c90:	07950263          	beq	a0,s9,80003cf4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c94:	8526                	mv	a0,s1
    80003c96:	00000097          	auipc	ra,0x0
    80003c9a:	77e080e7          	jalr	1918(ra) # 80004414 <log_write>
    brelse(bp);
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	fffff097          	auipc	ra,0xfffff
    80003ca4:	50a080e7          	jalr	1290(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ca8:	01498a3b          	addw	s4,s3,s4
    80003cac:	0129893b          	addw	s2,s3,s2
    80003cb0:	9aee                	add	s5,s5,s11
    80003cb2:	057a7663          	bgeu	s4,s7,80003cfe <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cb6:	000b2483          	lw	s1,0(s6)
    80003cba:	00a9559b          	srliw	a1,s2,0xa
    80003cbe:	855a                	mv	a0,s6
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	7ae080e7          	jalr	1966(ra) # 8000346e <bmap>
    80003cc8:	0005059b          	sext.w	a1,a0
    80003ccc:	8526                	mv	a0,s1
    80003cce:	fffff097          	auipc	ra,0xfffff
    80003cd2:	3ac080e7          	jalr	940(ra) # 8000307a <bread>
    80003cd6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd8:	3ff97713          	andi	a4,s2,1023
    80003cdc:	40ed07bb          	subw	a5,s10,a4
    80003ce0:	414b86bb          	subw	a3,s7,s4
    80003ce4:	89be                	mv	s3,a5
    80003ce6:	2781                	sext.w	a5,a5
    80003ce8:	0006861b          	sext.w	a2,a3
    80003cec:	f8f674e3          	bgeu	a2,a5,80003c74 <writei+0x4c>
    80003cf0:	89b6                	mv	s3,a3
    80003cf2:	b749                	j	80003c74 <writei+0x4c>
      brelse(bp);
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	4b4080e7          	jalr	1204(ra) # 800031aa <brelse>
  }

  if(off > ip->size)
    80003cfe:	054b2783          	lw	a5,84(s6)
    80003d02:	0127f463          	bgeu	a5,s2,80003d0a <writei+0xe2>
    ip->size = off;
    80003d06:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d0a:	855a                	mv	a0,s6
    80003d0c:	00000097          	auipc	ra,0x0
    80003d10:	aa6080e7          	jalr	-1370(ra) # 800037b2 <iupdate>

  return tot;
    80003d14:	000a051b          	sext.w	a0,s4
}
    80003d18:	70a6                	ld	ra,104(sp)
    80003d1a:	7406                	ld	s0,96(sp)
    80003d1c:	64e6                	ld	s1,88(sp)
    80003d1e:	6946                	ld	s2,80(sp)
    80003d20:	69a6                	ld	s3,72(sp)
    80003d22:	6a06                	ld	s4,64(sp)
    80003d24:	7ae2                	ld	s5,56(sp)
    80003d26:	7b42                	ld	s6,48(sp)
    80003d28:	7ba2                	ld	s7,40(sp)
    80003d2a:	7c02                	ld	s8,32(sp)
    80003d2c:	6ce2                	ld	s9,24(sp)
    80003d2e:	6d42                	ld	s10,16(sp)
    80003d30:	6da2                	ld	s11,8(sp)
    80003d32:	6165                	addi	sp,sp,112
    80003d34:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d36:	8a5e                	mv	s4,s7
    80003d38:	bfc9                	j	80003d0a <writei+0xe2>
    return -1;
    80003d3a:	557d                	li	a0,-1
}
    80003d3c:	8082                	ret
    return -1;
    80003d3e:	557d                	li	a0,-1
    80003d40:	bfe1                	j	80003d18 <writei+0xf0>
    return -1;
    80003d42:	557d                	li	a0,-1
    80003d44:	bfd1                	j	80003d18 <writei+0xf0>

0000000080003d46 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d46:	1141                	addi	sp,sp,-16
    80003d48:	e406                	sd	ra,8(sp)
    80003d4a:	e022                	sd	s0,0(sp)
    80003d4c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d4e:	4639                	li	a2,14
    80003d50:	ffffd097          	auipc	ra,0xffffd
    80003d54:	234080e7          	jalr	564(ra) # 80000f84 <strncmp>
}
    80003d58:	60a2                	ld	ra,8(sp)
    80003d5a:	6402                	ld	s0,0(sp)
    80003d5c:	0141                	addi	sp,sp,16
    80003d5e:	8082                	ret

0000000080003d60 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d60:	7139                	addi	sp,sp,-64
    80003d62:	fc06                	sd	ra,56(sp)
    80003d64:	f822                	sd	s0,48(sp)
    80003d66:	f426                	sd	s1,40(sp)
    80003d68:	f04a                	sd	s2,32(sp)
    80003d6a:	ec4e                	sd	s3,24(sp)
    80003d6c:	e852                	sd	s4,16(sp)
    80003d6e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d70:	04c51703          	lh	a4,76(a0)
    80003d74:	4785                	li	a5,1
    80003d76:	00f71a63          	bne	a4,a5,80003d8a <dirlookup+0x2a>
    80003d7a:	892a                	mv	s2,a0
    80003d7c:	89ae                	mv	s3,a1
    80003d7e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d80:	497c                	lw	a5,84(a0)
    80003d82:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d84:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d86:	e79d                	bnez	a5,80003db4 <dirlookup+0x54>
    80003d88:	a8a5                	j	80003e00 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d8a:	00006517          	auipc	a0,0x6
    80003d8e:	d7e50513          	addi	a0,a0,-642 # 80009b08 <syscalls+0x1d8>
    80003d92:	ffffc097          	auipc	ra,0xffffc
    80003d96:	7d8080e7          	jalr	2008(ra) # 8000056a <panic>
      panic("dirlookup read");
    80003d9a:	00006517          	auipc	a0,0x6
    80003d9e:	d8650513          	addi	a0,a0,-634 # 80009b20 <syscalls+0x1f0>
    80003da2:	ffffc097          	auipc	ra,0xffffc
    80003da6:	7c8080e7          	jalr	1992(ra) # 8000056a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003daa:	24c1                	addiw	s1,s1,16
    80003dac:	05492783          	lw	a5,84(s2)
    80003db0:	04f4f763          	bgeu	s1,a5,80003dfe <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db4:	4741                	li	a4,16
    80003db6:	86a6                	mv	a3,s1
    80003db8:	fc040613          	addi	a2,s0,-64
    80003dbc:	4581                	li	a1,0
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	d70080e7          	jalr	-656(ra) # 80003b30 <readi>
    80003dc8:	47c1                	li	a5,16
    80003dca:	fcf518e3          	bne	a0,a5,80003d9a <dirlookup+0x3a>
    if(de.inum == 0)
    80003dce:	fc045783          	lhu	a5,-64(s0)
    80003dd2:	dfe1                	beqz	a5,80003daa <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dd4:	fc240593          	addi	a1,s0,-62
    80003dd8:	854e                	mv	a0,s3
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	f6c080e7          	jalr	-148(ra) # 80003d46 <namecmp>
    80003de2:	f561                	bnez	a0,80003daa <dirlookup+0x4a>
      if(poff)
    80003de4:	000a0463          	beqz	s4,80003dec <dirlookup+0x8c>
        *poff = off;
    80003de8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dec:	fc045583          	lhu	a1,-64(s0)
    80003df0:	00092503          	lw	a0,0(s2)
    80003df4:	fffff097          	auipc	ra,0xfffff
    80003df8:	754080e7          	jalr	1876(ra) # 80003548 <iget>
    80003dfc:	a011                	j	80003e00 <dirlookup+0xa0>
  return 0;
    80003dfe:	4501                	li	a0,0
}
    80003e00:	70e2                	ld	ra,56(sp)
    80003e02:	7442                	ld	s0,48(sp)
    80003e04:	74a2                	ld	s1,40(sp)
    80003e06:	7902                	ld	s2,32(sp)
    80003e08:	69e2                	ld	s3,24(sp)
    80003e0a:	6a42                	ld	s4,16(sp)
    80003e0c:	6121                	addi	sp,sp,64
    80003e0e:	8082                	ret

0000000080003e10 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e10:	711d                	addi	sp,sp,-96
    80003e12:	ec86                	sd	ra,88(sp)
    80003e14:	e8a2                	sd	s0,80(sp)
    80003e16:	e4a6                	sd	s1,72(sp)
    80003e18:	e0ca                	sd	s2,64(sp)
    80003e1a:	fc4e                	sd	s3,56(sp)
    80003e1c:	f852                	sd	s4,48(sp)
    80003e1e:	f456                	sd	s5,40(sp)
    80003e20:	f05a                	sd	s6,32(sp)
    80003e22:	ec5e                	sd	s7,24(sp)
    80003e24:	e862                	sd	s8,16(sp)
    80003e26:	e466                	sd	s9,8(sp)
    80003e28:	1080                	addi	s0,sp,96
    80003e2a:	84aa                	mv	s1,a0
    80003e2c:	8b2e                	mv	s6,a1
    80003e2e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e30:	00054703          	lbu	a4,0(a0)
    80003e34:	02f00793          	li	a5,47
    80003e38:	02f70363          	beq	a4,a5,80003e5e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e3c:	ffffe097          	auipc	ra,0xffffe
    80003e40:	d2c080e7          	jalr	-724(ra) # 80001b68 <myproc>
    80003e44:	15853503          	ld	a0,344(a0)
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	9f6080e7          	jalr	-1546(ra) # 8000383e <idup>
    80003e50:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e52:	02f00913          	li	s2,47
  len = path - s;
    80003e56:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e58:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e5a:	4c05                	li	s8,1
    80003e5c:	a865                	j	80003f14 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e5e:	4585                	li	a1,1
    80003e60:	4505                	li	a0,1
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	6e6080e7          	jalr	1766(ra) # 80003548 <iget>
    80003e6a:	89aa                	mv	s3,a0
    80003e6c:	b7dd                	j	80003e52 <namex+0x42>
      iunlockput(ip);
    80003e6e:	854e                	mv	a0,s3
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	c6e080e7          	jalr	-914(ra) # 80003ade <iunlockput>
      return 0;
    80003e78:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e7a:	854e                	mv	a0,s3
    80003e7c:	60e6                	ld	ra,88(sp)
    80003e7e:	6446                	ld	s0,80(sp)
    80003e80:	64a6                	ld	s1,72(sp)
    80003e82:	6906                	ld	s2,64(sp)
    80003e84:	79e2                	ld	s3,56(sp)
    80003e86:	7a42                	ld	s4,48(sp)
    80003e88:	7aa2                	ld	s5,40(sp)
    80003e8a:	7b02                	ld	s6,32(sp)
    80003e8c:	6be2                	ld	s7,24(sp)
    80003e8e:	6c42                	ld	s8,16(sp)
    80003e90:	6ca2                	ld	s9,8(sp)
    80003e92:	6125                	addi	sp,sp,96
    80003e94:	8082                	ret
      iunlock(ip);
    80003e96:	854e                	mv	a0,s3
    80003e98:	00000097          	auipc	ra,0x0
    80003e9c:	aa6080e7          	jalr	-1370(ra) # 8000393e <iunlock>
      return ip;
    80003ea0:	bfe9                	j	80003e7a <namex+0x6a>
      iunlockput(ip);
    80003ea2:	854e                	mv	a0,s3
    80003ea4:	00000097          	auipc	ra,0x0
    80003ea8:	c3a080e7          	jalr	-966(ra) # 80003ade <iunlockput>
      return 0;
    80003eac:	89d2                	mv	s3,s4
    80003eae:	b7f1                	j	80003e7a <namex+0x6a>
  len = path - s;
    80003eb0:	40b48633          	sub	a2,s1,a1
    80003eb4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003eb8:	094cd463          	bge	s9,s4,80003f40 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ebc:	4639                	li	a2,14
    80003ebe:	8556                	mv	a0,s5
    80003ec0:	ffffd097          	auipc	ra,0xffffd
    80003ec4:	020080e7          	jalr	32(ra) # 80000ee0 <memmove>
  while(*path == '/')
    80003ec8:	0004c783          	lbu	a5,0(s1)
    80003ecc:	01279763          	bne	a5,s2,80003eda <namex+0xca>
    path++;
    80003ed0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ed2:	0004c783          	lbu	a5,0(s1)
    80003ed6:	ff278de3          	beq	a5,s2,80003ed0 <namex+0xc0>
    ilock(ip);
    80003eda:	854e                	mv	a0,s3
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	9a0080e7          	jalr	-1632(ra) # 8000387c <ilock>
    if(ip->type != T_DIR){
    80003ee4:	04c99783          	lh	a5,76(s3)
    80003ee8:	f98793e3          	bne	a5,s8,80003e6e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003eec:	000b0563          	beqz	s6,80003ef6 <namex+0xe6>
    80003ef0:	0004c783          	lbu	a5,0(s1)
    80003ef4:	d3cd                	beqz	a5,80003e96 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ef6:	865e                	mv	a2,s7
    80003ef8:	85d6                	mv	a1,s5
    80003efa:	854e                	mv	a0,s3
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	e64080e7          	jalr	-412(ra) # 80003d60 <dirlookup>
    80003f04:	8a2a                	mv	s4,a0
    80003f06:	dd51                	beqz	a0,80003ea2 <namex+0x92>
    iunlockput(ip);
    80003f08:	854e                	mv	a0,s3
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	bd4080e7          	jalr	-1068(ra) # 80003ade <iunlockput>
    ip = next;
    80003f12:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f14:	0004c783          	lbu	a5,0(s1)
    80003f18:	05279763          	bne	a5,s2,80003f66 <namex+0x156>
    path++;
    80003f1c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f1e:	0004c783          	lbu	a5,0(s1)
    80003f22:	ff278de3          	beq	a5,s2,80003f1c <namex+0x10c>
  if(*path == 0)
    80003f26:	c79d                	beqz	a5,80003f54 <namex+0x144>
    path++;
    80003f28:	85a6                	mv	a1,s1
  len = path - s;
    80003f2a:	8a5e                	mv	s4,s7
    80003f2c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f2e:	01278963          	beq	a5,s2,80003f40 <namex+0x130>
    80003f32:	dfbd                	beqz	a5,80003eb0 <namex+0xa0>
    path++;
    80003f34:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f36:	0004c783          	lbu	a5,0(s1)
    80003f3a:	ff279ce3          	bne	a5,s2,80003f32 <namex+0x122>
    80003f3e:	bf8d                	j	80003eb0 <namex+0xa0>
    memmove(name, s, len);
    80003f40:	2601                	sext.w	a2,a2
    80003f42:	8556                	mv	a0,s5
    80003f44:	ffffd097          	auipc	ra,0xffffd
    80003f48:	f9c080e7          	jalr	-100(ra) # 80000ee0 <memmove>
    name[len] = 0;
    80003f4c:	9a56                	add	s4,s4,s5
    80003f4e:	000a0023          	sb	zero,0(s4)
    80003f52:	bf9d                	j	80003ec8 <namex+0xb8>
  if(nameiparent){
    80003f54:	f20b03e3          	beqz	s6,80003e7a <namex+0x6a>
    iput(ip);
    80003f58:	854e                	mv	a0,s3
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	adc080e7          	jalr	-1316(ra) # 80003a36 <iput>
    return 0;
    80003f62:	4981                	li	s3,0
    80003f64:	bf19                	j	80003e7a <namex+0x6a>
  if(*path == 0)
    80003f66:	d7fd                	beqz	a5,80003f54 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f68:	0004c783          	lbu	a5,0(s1)
    80003f6c:	85a6                	mv	a1,s1
    80003f6e:	b7d1                	j	80003f32 <namex+0x122>

0000000080003f70 <dirlink>:
{
    80003f70:	7139                	addi	sp,sp,-64
    80003f72:	fc06                	sd	ra,56(sp)
    80003f74:	f822                	sd	s0,48(sp)
    80003f76:	f426                	sd	s1,40(sp)
    80003f78:	f04a                	sd	s2,32(sp)
    80003f7a:	ec4e                	sd	s3,24(sp)
    80003f7c:	e852                	sd	s4,16(sp)
    80003f7e:	0080                	addi	s0,sp,64
    80003f80:	892a                	mv	s2,a0
    80003f82:	8a2e                	mv	s4,a1
    80003f84:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f86:	4601                	li	a2,0
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	dd8080e7          	jalr	-552(ra) # 80003d60 <dirlookup>
    80003f90:	e93d                	bnez	a0,80004006 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f92:	05492483          	lw	s1,84(s2)
    80003f96:	c49d                	beqz	s1,80003fc4 <dirlink+0x54>
    80003f98:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f9a:	4741                	li	a4,16
    80003f9c:	86a6                	mv	a3,s1
    80003f9e:	fc040613          	addi	a2,s0,-64
    80003fa2:	4581                	li	a1,0
    80003fa4:	854a                	mv	a0,s2
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	b8a080e7          	jalr	-1142(ra) # 80003b30 <readi>
    80003fae:	47c1                	li	a5,16
    80003fb0:	06f51163          	bne	a0,a5,80004012 <dirlink+0xa2>
    if(de.inum == 0)
    80003fb4:	fc045783          	lhu	a5,-64(s0)
    80003fb8:	c791                	beqz	a5,80003fc4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fba:	24c1                	addiw	s1,s1,16
    80003fbc:	05492783          	lw	a5,84(s2)
    80003fc0:	fcf4ede3          	bltu	s1,a5,80003f9a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fc4:	4639                	li	a2,14
    80003fc6:	85d2                	mv	a1,s4
    80003fc8:	fc240513          	addi	a0,s0,-62
    80003fcc:	ffffd097          	auipc	ra,0xffffd
    80003fd0:	ff4080e7          	jalr	-12(ra) # 80000fc0 <strncpy>
  de.inum = inum;
    80003fd4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fd8:	4741                	li	a4,16
    80003fda:	86a6                	mv	a3,s1
    80003fdc:	fc040613          	addi	a2,s0,-64
    80003fe0:	4581                	li	a1,0
    80003fe2:	854a                	mv	a0,s2
    80003fe4:	00000097          	auipc	ra,0x0
    80003fe8:	c44080e7          	jalr	-956(ra) # 80003c28 <writei>
    80003fec:	872a                	mv	a4,a0
    80003fee:	47c1                	li	a5,16
  return 0;
    80003ff0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff2:	02f71863          	bne	a4,a5,80004022 <dirlink+0xb2>
}
    80003ff6:	70e2                	ld	ra,56(sp)
    80003ff8:	7442                	ld	s0,48(sp)
    80003ffa:	74a2                	ld	s1,40(sp)
    80003ffc:	7902                	ld	s2,32(sp)
    80003ffe:	69e2                	ld	s3,24(sp)
    80004000:	6a42                	ld	s4,16(sp)
    80004002:	6121                	addi	sp,sp,64
    80004004:	8082                	ret
    iput(ip);
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	a30080e7          	jalr	-1488(ra) # 80003a36 <iput>
    return -1;
    8000400e:	557d                	li	a0,-1
    80004010:	b7dd                	j	80003ff6 <dirlink+0x86>
      panic("dirlink read");
    80004012:	00006517          	auipc	a0,0x6
    80004016:	b1e50513          	addi	a0,a0,-1250 # 80009b30 <syscalls+0x200>
    8000401a:	ffffc097          	auipc	ra,0xffffc
    8000401e:	550080e7          	jalr	1360(ra) # 8000056a <panic>
    panic("dirlink");
    80004022:	00006517          	auipc	a0,0x6
    80004026:	c1e50513          	addi	a0,a0,-994 # 80009c40 <syscalls+0x310>
    8000402a:	ffffc097          	auipc	ra,0xffffc
    8000402e:	540080e7          	jalr	1344(ra) # 8000056a <panic>

0000000080004032 <namei>:

struct inode*
namei(char *path)
{
    80004032:	1101                	addi	sp,sp,-32
    80004034:	ec06                	sd	ra,24(sp)
    80004036:	e822                	sd	s0,16(sp)
    80004038:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000403a:	fe040613          	addi	a2,s0,-32
    8000403e:	4581                	li	a1,0
    80004040:	00000097          	auipc	ra,0x0
    80004044:	dd0080e7          	jalr	-560(ra) # 80003e10 <namex>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	6105                	addi	sp,sp,32
    8000404e:	8082                	ret

0000000080004050 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004050:	1141                	addi	sp,sp,-16
    80004052:	e406                	sd	ra,8(sp)
    80004054:	e022                	sd	s0,0(sp)
    80004056:	0800                	addi	s0,sp,16
    80004058:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000405a:	4585                	li	a1,1
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	db4080e7          	jalr	-588(ra) # 80003e10 <namex>
}
    80004064:	60a2                	ld	ra,8(sp)
    80004066:	6402                	ld	s0,0(sp)
    80004068:	0141                	addi	sp,sp,16
    8000406a:	8082                	ret

000000008000406c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000406c:	1101                	addi	sp,sp,-32
    8000406e:	ec06                	sd	ra,24(sp)
    80004070:	e822                	sd	s0,16(sp)
    80004072:	e426                	sd	s1,8(sp)
    80004074:	e04a                	sd	s2,0(sp)
    80004076:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004078:	00032917          	auipc	s2,0x32
    8000407c:	56090913          	addi	s2,s2,1376 # 800365d8 <log>
    80004080:	02092583          	lw	a1,32(s2)
    80004084:	03092503          	lw	a0,48(s2)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	ff2080e7          	jalr	-14(ra) # 8000307a <bread>
    80004090:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004092:	03492683          	lw	a3,52(s2)
    80004096:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004098:	02d05763          	blez	a3,800040c6 <write_head+0x5a>
    8000409c:	00032797          	auipc	a5,0x32
    800040a0:	57478793          	addi	a5,a5,1396 # 80036610 <log+0x38>
    800040a4:	06450713          	addi	a4,a0,100
    800040a8:	36fd                	addiw	a3,a3,-1
    800040aa:	1682                	slli	a3,a3,0x20
    800040ac:	9281                	srli	a3,a3,0x20
    800040ae:	068a                	slli	a3,a3,0x2
    800040b0:	00032617          	auipc	a2,0x32
    800040b4:	56460613          	addi	a2,a2,1380 # 80036614 <log+0x3c>
    800040b8:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040ba:	4390                	lw	a2,0(a5)
    800040bc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040be:	0791                	addi	a5,a5,4
    800040c0:	0711                	addi	a4,a4,4
    800040c2:	fed79ce3          	bne	a5,a3,800040ba <write_head+0x4e>
  }
  bwrite(buf);
    800040c6:	8526                	mv	a0,s1
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	0a4080e7          	jalr	164(ra) # 8000316c <bwrite>
  brelse(buf);
    800040d0:	8526                	mv	a0,s1
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	0d8080e7          	jalr	216(ra) # 800031aa <brelse>
}
    800040da:	60e2                	ld	ra,24(sp)
    800040dc:	6442                	ld	s0,16(sp)
    800040de:	64a2                	ld	s1,8(sp)
    800040e0:	6902                	ld	s2,0(sp)
    800040e2:	6105                	addi	sp,sp,32
    800040e4:	8082                	ret

00000000800040e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e6:	00032797          	auipc	a5,0x32
    800040ea:	5267a783          	lw	a5,1318(a5) # 8003660c <log+0x34>
    800040ee:	0af05663          	blez	a5,8000419a <install_trans+0xb4>
{
    800040f2:	7139                	addi	sp,sp,-64
    800040f4:	fc06                	sd	ra,56(sp)
    800040f6:	f822                	sd	s0,48(sp)
    800040f8:	f426                	sd	s1,40(sp)
    800040fa:	f04a                	sd	s2,32(sp)
    800040fc:	ec4e                	sd	s3,24(sp)
    800040fe:	e852                	sd	s4,16(sp)
    80004100:	e456                	sd	s5,8(sp)
    80004102:	0080                	addi	s0,sp,64
    80004104:	00032a97          	auipc	s5,0x32
    80004108:	50ca8a93          	addi	s5,s5,1292 # 80036610 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000410c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000410e:	00032997          	auipc	s3,0x32
    80004112:	4ca98993          	addi	s3,s3,1226 # 800365d8 <log>
    80004116:	0209a583          	lw	a1,32(s3)
    8000411a:	014585bb          	addw	a1,a1,s4
    8000411e:	2585                	addiw	a1,a1,1
    80004120:	0309a503          	lw	a0,48(s3)
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	f56080e7          	jalr	-170(ra) # 8000307a <bread>
    8000412c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000412e:	000aa583          	lw	a1,0(s5)
    80004132:	0309a503          	lw	a0,48(s3)
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	f44080e7          	jalr	-188(ra) # 8000307a <bread>
    8000413e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004140:	40000613          	li	a2,1024
    80004144:	06090593          	addi	a1,s2,96
    80004148:	06050513          	addi	a0,a0,96
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	d94080e7          	jalr	-620(ra) # 80000ee0 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004154:	8526                	mv	a0,s1
    80004156:	fffff097          	auipc	ra,0xfffff
    8000415a:	016080e7          	jalr	22(ra) # 8000316c <bwrite>
    bunpin(dbuf);
    8000415e:	8526                	mv	a0,s1
    80004160:	fffff097          	auipc	ra,0xfffff
    80004164:	124080e7          	jalr	292(ra) # 80003284 <bunpin>
    brelse(lbuf);
    80004168:	854a                	mv	a0,s2
    8000416a:	fffff097          	auipc	ra,0xfffff
    8000416e:	040080e7          	jalr	64(ra) # 800031aa <brelse>
    brelse(dbuf);
    80004172:	8526                	mv	a0,s1
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	036080e7          	jalr	54(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000417c:	2a05                	addiw	s4,s4,1
    8000417e:	0a91                	addi	s5,s5,4
    80004180:	0349a783          	lw	a5,52(s3)
    80004184:	f8fa49e3          	blt	s4,a5,80004116 <install_trans+0x30>
}
    80004188:	70e2                	ld	ra,56(sp)
    8000418a:	7442                	ld	s0,48(sp)
    8000418c:	74a2                	ld	s1,40(sp)
    8000418e:	7902                	ld	s2,32(sp)
    80004190:	69e2                	ld	s3,24(sp)
    80004192:	6a42                	ld	s4,16(sp)
    80004194:	6aa2                	ld	s5,8(sp)
    80004196:	6121                	addi	sp,sp,64
    80004198:	8082                	ret
    8000419a:	8082                	ret

000000008000419c <initlog>:
{
    8000419c:	7179                	addi	sp,sp,-48
    8000419e:	f406                	sd	ra,40(sp)
    800041a0:	f022                	sd	s0,32(sp)
    800041a2:	ec26                	sd	s1,24(sp)
    800041a4:	e84a                	sd	s2,16(sp)
    800041a6:	e44e                	sd	s3,8(sp)
    800041a8:	1800                	addi	s0,sp,48
    800041aa:	892a                	mv	s2,a0
    800041ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041ae:	00032497          	auipc	s1,0x32
    800041b2:	42a48493          	addi	s1,s1,1066 # 800365d8 <log>
    800041b6:	00006597          	auipc	a1,0x6
    800041ba:	98a58593          	addi	a1,a1,-1654 # 80009b40 <syscalls+0x210>
    800041be:	8526                	mv	a0,s1
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	906080e7          	jalr	-1786(ra) # 80000ac6 <initlock>
  log.start = sb->logstart;
    800041c8:	0149a583          	lw	a1,20(s3)
    800041cc:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800041ce:	0109a783          	lw	a5,16(s3)
    800041d2:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800041d4:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041d8:	854a                	mv	a0,s2
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	ea0080e7          	jalr	-352(ra) # 8000307a <bread>
  log.lh.n = lh->n;
    800041e2:	513c                	lw	a5,96(a0)
    800041e4:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041e6:	02f05563          	blez	a5,80004210 <initlog+0x74>
    800041ea:	06450713          	addi	a4,a0,100
    800041ee:	00032697          	auipc	a3,0x32
    800041f2:	42268693          	addi	a3,a3,1058 # 80036610 <log+0x38>
    800041f6:	37fd                	addiw	a5,a5,-1
    800041f8:	1782                	slli	a5,a5,0x20
    800041fa:	9381                	srli	a5,a5,0x20
    800041fc:	078a                	slli	a5,a5,0x2
    800041fe:	06850613          	addi	a2,a0,104
    80004202:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004204:	4310                	lw	a2,0(a4)
    80004206:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004208:	0711                	addi	a4,a4,4
    8000420a:	0691                	addi	a3,a3,4
    8000420c:	fef71ce3          	bne	a4,a5,80004204 <initlog+0x68>
  brelse(buf);
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	f9a080e7          	jalr	-102(ra) # 800031aa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	ece080e7          	jalr	-306(ra) # 800040e6 <install_trans>
  log.lh.n = 0;
    80004220:	00032797          	auipc	a5,0x32
    80004224:	3e07a623          	sw	zero,1004(a5) # 8003660c <log+0x34>
  write_head(); // clear the log
    80004228:	00000097          	auipc	ra,0x0
    8000422c:	e44080e7          	jalr	-444(ra) # 8000406c <write_head>
}
    80004230:	70a2                	ld	ra,40(sp)
    80004232:	7402                	ld	s0,32(sp)
    80004234:	64e2                	ld	s1,24(sp)
    80004236:	6942                	ld	s2,16(sp)
    80004238:	69a2                	ld	s3,8(sp)
    8000423a:	6145                	addi	sp,sp,48
    8000423c:	8082                	ret

000000008000423e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000423e:	1101                	addi	sp,sp,-32
    80004240:	ec06                	sd	ra,24(sp)
    80004242:	e822                	sd	s0,16(sp)
    80004244:	e426                	sd	s1,8(sp)
    80004246:	e04a                	sd	s2,0(sp)
    80004248:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000424a:	00032517          	auipc	a0,0x32
    8000424e:	38e50513          	addi	a0,a0,910 # 800365d8 <log>
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	94a080e7          	jalr	-1718(ra) # 80000b9c <acquire>
  while(1){
    if(log.committing){
    8000425a:	00032497          	auipc	s1,0x32
    8000425e:	37e48493          	addi	s1,s1,894 # 800365d8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004262:	4979                	li	s2,30
    80004264:	a039                	j	80004272 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004266:	85a6                	mv	a1,s1
    80004268:	8526                	mv	a0,s1
    8000426a:	ffffe097          	auipc	ra,0xffffe
    8000426e:	0cc080e7          	jalr	204(ra) # 80002336 <sleep>
    if(log.committing){
    80004272:	54dc                	lw	a5,44(s1)
    80004274:	fbed                	bnez	a5,80004266 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004276:	549c                	lw	a5,40(s1)
    80004278:	0017871b          	addiw	a4,a5,1
    8000427c:	0007069b          	sext.w	a3,a4
    80004280:	0027179b          	slliw	a5,a4,0x2
    80004284:	9fb9                	addw	a5,a5,a4
    80004286:	0017979b          	slliw	a5,a5,0x1
    8000428a:	58d8                	lw	a4,52(s1)
    8000428c:	9fb9                	addw	a5,a5,a4
    8000428e:	00f95963          	bge	s2,a5,800042a0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004292:	85a6                	mv	a1,s1
    80004294:	8526                	mv	a0,s1
    80004296:	ffffe097          	auipc	ra,0xffffe
    8000429a:	0a0080e7          	jalr	160(ra) # 80002336 <sleep>
    8000429e:	bfd1                	j	80004272 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042a0:	00032517          	auipc	a0,0x32
    800042a4:	33850513          	addi	a0,a0,824 # 800365d8 <log>
    800042a8:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800042aa:	ffffd097          	auipc	ra,0xffffd
    800042ae:	9c2080e7          	jalr	-1598(ra) # 80000c6c <release>
      break;
    }
  }
}
    800042b2:	60e2                	ld	ra,24(sp)
    800042b4:	6442                	ld	s0,16(sp)
    800042b6:	64a2                	ld	s1,8(sp)
    800042b8:	6902                	ld	s2,0(sp)
    800042ba:	6105                	addi	sp,sp,32
    800042bc:	8082                	ret

00000000800042be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042be:	7139                	addi	sp,sp,-64
    800042c0:	fc06                	sd	ra,56(sp)
    800042c2:	f822                	sd	s0,48(sp)
    800042c4:	f426                	sd	s1,40(sp)
    800042c6:	f04a                	sd	s2,32(sp)
    800042c8:	ec4e                	sd	s3,24(sp)
    800042ca:	e852                	sd	s4,16(sp)
    800042cc:	e456                	sd	s5,8(sp)
    800042ce:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042d0:	00032497          	auipc	s1,0x32
    800042d4:	30848493          	addi	s1,s1,776 # 800365d8 <log>
    800042d8:	8526                	mv	a0,s1
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	8c2080e7          	jalr	-1854(ra) # 80000b9c <acquire>
  log.outstanding -= 1;
    800042e2:	549c                	lw	a5,40(s1)
    800042e4:	37fd                	addiw	a5,a5,-1
    800042e6:	0007891b          	sext.w	s2,a5
    800042ea:	d49c                	sw	a5,40(s1)
  if(log.committing)
    800042ec:	54dc                	lw	a5,44(s1)
    800042ee:	efb9                	bnez	a5,8000434c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042f0:	06091663          	bnez	s2,8000435c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800042f4:	00032497          	auipc	s1,0x32
    800042f8:	2e448493          	addi	s1,s1,740 # 800365d8 <log>
    800042fc:	4785                	li	a5,1
    800042fe:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004300:	8526                	mv	a0,s1
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	96a080e7          	jalr	-1686(ra) # 80000c6c <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    8000430a:	58dc                	lw	a5,52(s1)
    8000430c:	06f04763          	bgtz	a5,8000437a <end_op+0xbc>
    acquire(&log.lock);
    80004310:	00032497          	auipc	s1,0x32
    80004314:	2c848493          	addi	s1,s1,712 # 800365d8 <log>
    80004318:	8526                	mv	a0,s1
    8000431a:	ffffd097          	auipc	ra,0xffffd
    8000431e:	882080e7          	jalr	-1918(ra) # 80000b9c <acquire>
    log.committing = 0;
    80004322:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80004326:	8526                	mv	a0,s1
    80004328:	ffffe097          	auipc	ra,0xffffe
    8000432c:	194080e7          	jalr	404(ra) # 800024bc <wakeup>
    release(&log.lock);
    80004330:	8526                	mv	a0,s1
    80004332:	ffffd097          	auipc	ra,0xffffd
    80004336:	93a080e7          	jalr	-1734(ra) # 80000c6c <release>
}
    8000433a:	70e2                	ld	ra,56(sp)
    8000433c:	7442                	ld	s0,48(sp)
    8000433e:	74a2                	ld	s1,40(sp)
    80004340:	7902                	ld	s2,32(sp)
    80004342:	69e2                	ld	s3,24(sp)
    80004344:	6a42                	ld	s4,16(sp)
    80004346:	6aa2                	ld	s5,8(sp)
    80004348:	6121                	addi	sp,sp,64
    8000434a:	8082                	ret
    panic("log.committing");
    8000434c:	00005517          	auipc	a0,0x5
    80004350:	7fc50513          	addi	a0,a0,2044 # 80009b48 <syscalls+0x218>
    80004354:	ffffc097          	auipc	ra,0xffffc
    80004358:	216080e7          	jalr	534(ra) # 8000056a <panic>
    wakeup(&log);
    8000435c:	00032497          	auipc	s1,0x32
    80004360:	27c48493          	addi	s1,s1,636 # 800365d8 <log>
    80004364:	8526                	mv	a0,s1
    80004366:	ffffe097          	auipc	ra,0xffffe
    8000436a:	156080e7          	jalr	342(ra) # 800024bc <wakeup>
  release(&log.lock);
    8000436e:	8526                	mv	a0,s1
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	8fc080e7          	jalr	-1796(ra) # 80000c6c <release>
  if(do_commit){
    80004378:	b7c9                	j	8000433a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000437a:	00032a97          	auipc	s5,0x32
    8000437e:	296a8a93          	addi	s5,s5,662 # 80036610 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004382:	00032a17          	auipc	s4,0x32
    80004386:	256a0a13          	addi	s4,s4,598 # 800365d8 <log>
    8000438a:	020a2583          	lw	a1,32(s4)
    8000438e:	012585bb          	addw	a1,a1,s2
    80004392:	2585                	addiw	a1,a1,1
    80004394:	030a2503          	lw	a0,48(s4)
    80004398:	fffff097          	auipc	ra,0xfffff
    8000439c:	ce2080e7          	jalr	-798(ra) # 8000307a <bread>
    800043a0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043a2:	000aa583          	lw	a1,0(s5)
    800043a6:	030a2503          	lw	a0,48(s4)
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	cd0080e7          	jalr	-816(ra) # 8000307a <bread>
    800043b2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043b4:	40000613          	li	a2,1024
    800043b8:	06050593          	addi	a1,a0,96
    800043bc:	06048513          	addi	a0,s1,96
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	b20080e7          	jalr	-1248(ra) # 80000ee0 <memmove>
    bwrite(to);  // write the log
    800043c8:	8526                	mv	a0,s1
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	da2080e7          	jalr	-606(ra) # 8000316c <bwrite>
    brelse(from);
    800043d2:	854e                	mv	a0,s3
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	dd6080e7          	jalr	-554(ra) # 800031aa <brelse>
    brelse(to);
    800043dc:	8526                	mv	a0,s1
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	dcc080e7          	jalr	-564(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e6:	2905                	addiw	s2,s2,1
    800043e8:	0a91                	addi	s5,s5,4
    800043ea:	034a2783          	lw	a5,52(s4)
    800043ee:	f8f94ee3          	blt	s2,a5,8000438a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043f2:	00000097          	auipc	ra,0x0
    800043f6:	c7a080e7          	jalr	-902(ra) # 8000406c <write_head>
    install_trans(); // Now install writes to home locations
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	cec080e7          	jalr	-788(ra) # 800040e6 <install_trans>
    log.lh.n = 0;
    80004402:	00032797          	auipc	a5,0x32
    80004406:	2007a523          	sw	zero,522(a5) # 8003660c <log+0x34>
    write_head();    // Erase the transaction from the log
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	c62080e7          	jalr	-926(ra) # 8000406c <write_head>
    80004412:	bdfd                	j	80004310 <end_op+0x52>

0000000080004414 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004414:	1101                	addi	sp,sp,-32
    80004416:	ec06                	sd	ra,24(sp)
    80004418:	e822                	sd	s0,16(sp)
    8000441a:	e426                	sd	s1,8(sp)
    8000441c:	e04a                	sd	s2,0(sp)
    8000441e:	1000                	addi	s0,sp,32
    80004420:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004422:	00032917          	auipc	s2,0x32
    80004426:	1b690913          	addi	s2,s2,438 # 800365d8 <log>
    8000442a:	854a                	mv	a0,s2
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	770080e7          	jalr	1904(ra) # 80000b9c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004434:	03492603          	lw	a2,52(s2)
    80004438:	47f5                	li	a5,29
    8000443a:	06c7c563          	blt	a5,a2,800044a4 <log_write+0x90>
    8000443e:	00032797          	auipc	a5,0x32
    80004442:	1be7a783          	lw	a5,446(a5) # 800365fc <log+0x24>
    80004446:	37fd                	addiw	a5,a5,-1
    80004448:	04f65e63          	bge	a2,a5,800044a4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000444c:	00032797          	auipc	a5,0x32
    80004450:	1b47a783          	lw	a5,436(a5) # 80036600 <log+0x28>
    80004454:	06f05063          	blez	a5,800044b4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004458:	4781                	li	a5,0
    8000445a:	06c05563          	blez	a2,800044c4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000445e:	44cc                	lw	a1,12(s1)
    80004460:	00032717          	auipc	a4,0x32
    80004464:	1b070713          	addi	a4,a4,432 # 80036610 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    80004468:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000446a:	4314                	lw	a3,0(a4)
    8000446c:	04b68c63          	beq	a3,a1,800044c4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004470:	2785                	addiw	a5,a5,1
    80004472:	0711                	addi	a4,a4,4
    80004474:	fef61be3          	bne	a2,a5,8000446a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004478:	0631                	addi	a2,a2,12
    8000447a:	060a                	slli	a2,a2,0x2
    8000447c:	00032797          	auipc	a5,0x32
    80004480:	15c78793          	addi	a5,a5,348 # 800365d8 <log>
    80004484:	963e                	add	a2,a2,a5
    80004486:	44dc                	lw	a5,12(s1)
    80004488:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000448a:	8526                	mv	a0,s1
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	dbc080e7          	jalr	-580(ra) # 80003248 <bpin>
    log.lh.n++;
    80004494:	00032717          	auipc	a4,0x32
    80004498:	14470713          	addi	a4,a4,324 # 800365d8 <log>
    8000449c:	5b5c                	lw	a5,52(a4)
    8000449e:	2785                	addiw	a5,a5,1
    800044a0:	db5c                	sw	a5,52(a4)
    800044a2:	a835                	j	800044de <log_write+0xca>
    panic("too big a transaction");
    800044a4:	00005517          	auipc	a0,0x5
    800044a8:	6b450513          	addi	a0,a0,1716 # 80009b58 <syscalls+0x228>
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	0be080e7          	jalr	190(ra) # 8000056a <panic>
    panic("log_write outside of trans");
    800044b4:	00005517          	auipc	a0,0x5
    800044b8:	6bc50513          	addi	a0,a0,1724 # 80009b70 <syscalls+0x240>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	0ae080e7          	jalr	174(ra) # 8000056a <panic>
  log.lh.block[i] = b->blockno;
    800044c4:	00c78713          	addi	a4,a5,12
    800044c8:	00271693          	slli	a3,a4,0x2
    800044cc:	00032717          	auipc	a4,0x32
    800044d0:	10c70713          	addi	a4,a4,268 # 800365d8 <log>
    800044d4:	9736                	add	a4,a4,a3
    800044d6:	44d4                	lw	a3,12(s1)
    800044d8:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044da:	faf608e3          	beq	a2,a5,8000448a <log_write+0x76>
  }
  release(&log.lock);
    800044de:	00032517          	auipc	a0,0x32
    800044e2:	0fa50513          	addi	a0,a0,250 # 800365d8 <log>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	786080e7          	jalr	1926(ra) # 80000c6c <release>
}
    800044ee:	60e2                	ld	ra,24(sp)
    800044f0:	6442                	ld	s0,16(sp)
    800044f2:	64a2                	ld	s1,8(sp)
    800044f4:	6902                	ld	s2,0(sp)
    800044f6:	6105                	addi	sp,sp,32
    800044f8:	8082                	ret

00000000800044fa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	e04a                	sd	s2,0(sp)
    80004504:	1000                	addi	s0,sp,32
    80004506:	84aa                	mv	s1,a0
    80004508:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000450a:	00005597          	auipc	a1,0x5
    8000450e:	68658593          	addi	a1,a1,1670 # 80009b90 <syscalls+0x260>
    80004512:	0521                	addi	a0,a0,8
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	5b2080e7          	jalr	1458(ra) # 80000ac6 <initlock>
  lk->name = name;
    8000451c:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004520:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004524:	0204a823          	sw	zero,48(s1)
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	64a2                	ld	s1,8(sp)
    8000452e:	6902                	ld	s2,0(sp)
    80004530:	6105                	addi	sp,sp,32
    80004532:	8082                	ret

0000000080004534 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	e04a                	sd	s2,0(sp)
    8000453e:	1000                	addi	s0,sp,32
    80004540:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004542:	00850913          	addi	s2,a0,8
    80004546:	854a                	mv	a0,s2
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	654080e7          	jalr	1620(ra) # 80000b9c <acquire>
  while (lk->locked) {
    80004550:	409c                	lw	a5,0(s1)
    80004552:	cb89                	beqz	a5,80004564 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004554:	85ca                	mv	a1,s2
    80004556:	8526                	mv	a0,s1
    80004558:	ffffe097          	auipc	ra,0xffffe
    8000455c:	dde080e7          	jalr	-546(ra) # 80002336 <sleep>
  while (lk->locked) {
    80004560:	409c                	lw	a5,0(s1)
    80004562:	fbed                	bnez	a5,80004554 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004564:	4785                	li	a5,1
    80004566:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004568:	ffffd097          	auipc	ra,0xffffd
    8000456c:	600080e7          	jalr	1536(ra) # 80001b68 <myproc>
    80004570:	413c                	lw	a5,64(a0)
    80004572:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004574:	854a                	mv	a0,s2
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	6f6080e7          	jalr	1782(ra) # 80000c6c <release>
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000458a:	1101                	addi	sp,sp,-32
    8000458c:	ec06                	sd	ra,24(sp)
    8000458e:	e822                	sd	s0,16(sp)
    80004590:	e426                	sd	s1,8(sp)
    80004592:	e04a                	sd	s2,0(sp)
    80004594:	1000                	addi	s0,sp,32
    80004596:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004598:	00850913          	addi	s2,a0,8
    8000459c:	854a                	mv	a0,s2
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	5fe080e7          	jalr	1534(ra) # 80000b9c <acquire>
  lk->locked = 0;
    800045a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045aa:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800045ae:	8526                	mv	a0,s1
    800045b0:	ffffe097          	auipc	ra,0xffffe
    800045b4:	f0c080e7          	jalr	-244(ra) # 800024bc <wakeup>
  release(&lk->lk);
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	6b2080e7          	jalr	1714(ra) # 80000c6c <release>
}
    800045c2:	60e2                	ld	ra,24(sp)
    800045c4:	6442                	ld	s0,16(sp)
    800045c6:	64a2                	ld	s1,8(sp)
    800045c8:	6902                	ld	s2,0(sp)
    800045ca:	6105                	addi	sp,sp,32
    800045cc:	8082                	ret

00000000800045ce <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045ce:	7179                	addi	sp,sp,-48
    800045d0:	f406                	sd	ra,40(sp)
    800045d2:	f022                	sd	s0,32(sp)
    800045d4:	ec26                	sd	s1,24(sp)
    800045d6:	e84a                	sd	s2,16(sp)
    800045d8:	e44e                	sd	s3,8(sp)
    800045da:	1800                	addi	s0,sp,48
    800045dc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045de:	00850913          	addi	s2,a0,8
    800045e2:	854a                	mv	a0,s2
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	5b8080e7          	jalr	1464(ra) # 80000b9c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ec:	409c                	lw	a5,0(s1)
    800045ee:	ef99                	bnez	a5,8000460c <holdingsleep+0x3e>
    800045f0:	4481                	li	s1,0
  release(&lk->lk);
    800045f2:	854a                	mv	a0,s2
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	678080e7          	jalr	1656(ra) # 80000c6c <release>
  return r;
}
    800045fc:	8526                	mv	a0,s1
    800045fe:	70a2                	ld	ra,40(sp)
    80004600:	7402                	ld	s0,32(sp)
    80004602:	64e2                	ld	s1,24(sp)
    80004604:	6942                	ld	s2,16(sp)
    80004606:	69a2                	ld	s3,8(sp)
    80004608:	6145                	addi	sp,sp,48
    8000460a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000460c:	0304a983          	lw	s3,48(s1)
    80004610:	ffffd097          	auipc	ra,0xffffd
    80004614:	558080e7          	jalr	1368(ra) # 80001b68 <myproc>
    80004618:	4124                	lw	s1,64(a0)
    8000461a:	413484b3          	sub	s1,s1,s3
    8000461e:	0014b493          	seqz	s1,s1
    80004622:	bfc1                	j	800045f2 <holdingsleep+0x24>

0000000080004624 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004624:	1141                	addi	sp,sp,-16
    80004626:	e406                	sd	ra,8(sp)
    80004628:	e022                	sd	s0,0(sp)
    8000462a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000462c:	00005597          	auipc	a1,0x5
    80004630:	57458593          	addi	a1,a1,1396 # 80009ba0 <syscalls+0x270>
    80004634:	00032517          	auipc	a0,0x32
    80004638:	0f450513          	addi	a0,a0,244 # 80036728 <ftable>
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	48a080e7          	jalr	1162(ra) # 80000ac6 <initlock>
}
    80004644:	60a2                	ld	ra,8(sp)
    80004646:	6402                	ld	s0,0(sp)
    80004648:	0141                	addi	sp,sp,16
    8000464a:	8082                	ret

000000008000464c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000464c:	1101                	addi	sp,sp,-32
    8000464e:	ec06                	sd	ra,24(sp)
    80004650:	e822                	sd	s0,16(sp)
    80004652:	e426                	sd	s1,8(sp)
    80004654:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004656:	00032517          	auipc	a0,0x32
    8000465a:	0d250513          	addi	a0,a0,210 # 80036728 <ftable>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	53e080e7          	jalr	1342(ra) # 80000b9c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004666:	00032497          	auipc	s1,0x32
    8000466a:	0e248493          	addi	s1,s1,226 # 80036748 <ftable+0x20>
    8000466e:	00033717          	auipc	a4,0x33
    80004672:	07a70713          	addi	a4,a4,122 # 800376e8 <disk>
    if(f->ref == 0){
    80004676:	40dc                	lw	a5,4(s1)
    80004678:	cf99                	beqz	a5,80004696 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000467a:	02848493          	addi	s1,s1,40
    8000467e:	fee49ce3          	bne	s1,a4,80004676 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004682:	00032517          	auipc	a0,0x32
    80004686:	0a650513          	addi	a0,a0,166 # 80036728 <ftable>
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	5e2080e7          	jalr	1506(ra) # 80000c6c <release>
  return 0;
    80004692:	4481                	li	s1,0
    80004694:	a819                	j	800046aa <filealloc+0x5e>
      f->ref = 1;
    80004696:	4785                	li	a5,1
    80004698:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000469a:	00032517          	auipc	a0,0x32
    8000469e:	08e50513          	addi	a0,a0,142 # 80036728 <ftable>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	5ca080e7          	jalr	1482(ra) # 80000c6c <release>
}
    800046aa:	8526                	mv	a0,s1
    800046ac:	60e2                	ld	ra,24(sp)
    800046ae:	6442                	ld	s0,16(sp)
    800046b0:	64a2                	ld	s1,8(sp)
    800046b2:	6105                	addi	sp,sp,32
    800046b4:	8082                	ret

00000000800046b6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	1000                	addi	s0,sp,32
    800046c0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046c2:	00032517          	auipc	a0,0x32
    800046c6:	06650513          	addi	a0,a0,102 # 80036728 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	4d2080e7          	jalr	1234(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    800046d2:	40dc                	lw	a5,4(s1)
    800046d4:	02f05263          	blez	a5,800046f8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046d8:	2785                	addiw	a5,a5,1
    800046da:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046dc:	00032517          	auipc	a0,0x32
    800046e0:	04c50513          	addi	a0,a0,76 # 80036728 <ftable>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	588080e7          	jalr	1416(ra) # 80000c6c <release>
  return f;
}
    800046ec:	8526                	mv	a0,s1
    800046ee:	60e2                	ld	ra,24(sp)
    800046f0:	6442                	ld	s0,16(sp)
    800046f2:	64a2                	ld	s1,8(sp)
    800046f4:	6105                	addi	sp,sp,32
    800046f6:	8082                	ret
    panic("filedup");
    800046f8:	00005517          	auipc	a0,0x5
    800046fc:	4b050513          	addi	a0,a0,1200 # 80009ba8 <syscalls+0x278>
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	e6a080e7          	jalr	-406(ra) # 8000056a <panic>

0000000080004708 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004708:	7139                	addi	sp,sp,-64
    8000470a:	fc06                	sd	ra,56(sp)
    8000470c:	f822                	sd	s0,48(sp)
    8000470e:	f426                	sd	s1,40(sp)
    80004710:	f04a                	sd	s2,32(sp)
    80004712:	ec4e                	sd	s3,24(sp)
    80004714:	e852                	sd	s4,16(sp)
    80004716:	e456                	sd	s5,8(sp)
    80004718:	0080                	addi	s0,sp,64
    8000471a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000471c:	00032517          	auipc	a0,0x32
    80004720:	00c50513          	addi	a0,a0,12 # 80036728 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	478080e7          	jalr	1144(ra) # 80000b9c <acquire>
  if(f->ref < 1)
    8000472c:	40dc                	lw	a5,4(s1)
    8000472e:	06f05163          	blez	a5,80004790 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004732:	37fd                	addiw	a5,a5,-1
    80004734:	0007871b          	sext.w	a4,a5
    80004738:	c0dc                	sw	a5,4(s1)
    8000473a:	06e04363          	bgtz	a4,800047a0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000473e:	0004a903          	lw	s2,0(s1)
    80004742:	0094ca83          	lbu	s5,9(s1)
    80004746:	0104ba03          	ld	s4,16(s1)
    8000474a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000474e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004752:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004756:	00032517          	auipc	a0,0x32
    8000475a:	fd250513          	addi	a0,a0,-46 # 80036728 <ftable>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	50e080e7          	jalr	1294(ra) # 80000c6c <release>

  if(ff.type == FD_PIPE){
    80004766:	4785                	li	a5,1
    80004768:	04f90d63          	beq	s2,a5,800047c2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000476c:	3979                	addiw	s2,s2,-2
    8000476e:	4785                	li	a5,1
    80004770:	0527e063          	bltu	a5,s2,800047b0 <fileclose+0xa8>
    begin_op();
    80004774:	00000097          	auipc	ra,0x0
    80004778:	aca080e7          	jalr	-1334(ra) # 8000423e <begin_op>
    iput(ff.ip);
    8000477c:	854e                	mv	a0,s3
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	2b8080e7          	jalr	696(ra) # 80003a36 <iput>
    end_op();
    80004786:	00000097          	auipc	ra,0x0
    8000478a:	b38080e7          	jalr	-1224(ra) # 800042be <end_op>
    8000478e:	a00d                	j	800047b0 <fileclose+0xa8>
    panic("fileclose");
    80004790:	00005517          	auipc	a0,0x5
    80004794:	42050513          	addi	a0,a0,1056 # 80009bb0 <syscalls+0x280>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	dd2080e7          	jalr	-558(ra) # 8000056a <panic>
    release(&ftable.lock);
    800047a0:	00032517          	auipc	a0,0x32
    800047a4:	f8850513          	addi	a0,a0,-120 # 80036728 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	4c4080e7          	jalr	1220(ra) # 80000c6c <release>
  }
}
    800047b0:	70e2                	ld	ra,56(sp)
    800047b2:	7442                	ld	s0,48(sp)
    800047b4:	74a2                	ld	s1,40(sp)
    800047b6:	7902                	ld	s2,32(sp)
    800047b8:	69e2                	ld	s3,24(sp)
    800047ba:	6a42                	ld	s4,16(sp)
    800047bc:	6aa2                	ld	s5,8(sp)
    800047be:	6121                	addi	sp,sp,64
    800047c0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047c2:	85d6                	mv	a1,s5
    800047c4:	8552                	mv	a0,s4
    800047c6:	00000097          	auipc	ra,0x0
    800047ca:	354080e7          	jalr	852(ra) # 80004b1a <pipeclose>
    800047ce:	b7cd                	j	800047b0 <fileclose+0xa8>

00000000800047d0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047d0:	715d                	addi	sp,sp,-80
    800047d2:	e486                	sd	ra,72(sp)
    800047d4:	e0a2                	sd	s0,64(sp)
    800047d6:	fc26                	sd	s1,56(sp)
    800047d8:	f84a                	sd	s2,48(sp)
    800047da:	f44e                	sd	s3,40(sp)
    800047dc:	0880                	addi	s0,sp,80
    800047de:	84aa                	mv	s1,a0
    800047e0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047e2:	ffffd097          	auipc	ra,0xffffd
    800047e6:	386080e7          	jalr	902(ra) # 80001b68 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047ea:	409c                	lw	a5,0(s1)
    800047ec:	37f9                	addiw	a5,a5,-2
    800047ee:	4705                	li	a4,1
    800047f0:	04f76763          	bltu	a4,a5,8000483e <filestat+0x6e>
    800047f4:	892a                	mv	s2,a0
    ilock(f->ip);
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	084080e7          	jalr	132(ra) # 8000387c <ilock>
    stati(f->ip, &st);
    80004800:	fb840593          	addi	a1,s0,-72
    80004804:	6c88                	ld	a0,24(s1)
    80004806:	fffff097          	auipc	ra,0xfffff
    8000480a:	300080e7          	jalr	768(ra) # 80003b06 <stati>
    iunlock(f->ip);
    8000480e:	6c88                	ld	a0,24(s1)
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	12e080e7          	jalr	302(ra) # 8000393e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004818:	46e1                	li	a3,24
    8000481a:	fb840613          	addi	a2,s0,-72
    8000481e:	85ce                	mv	a1,s3
    80004820:	05893503          	ld	a0,88(s2)
    80004824:	ffffd097          	auipc	ra,0xffffd
    80004828:	ffe080e7          	jalr	-2(ra) # 80001822 <copyout>
    8000482c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004830:	60a6                	ld	ra,72(sp)
    80004832:	6406                	ld	s0,64(sp)
    80004834:	74e2                	ld	s1,56(sp)
    80004836:	7942                	ld	s2,48(sp)
    80004838:	79a2                	ld	s3,40(sp)
    8000483a:	6161                	addi	sp,sp,80
    8000483c:	8082                	ret
  return -1;
    8000483e:	557d                	li	a0,-1
    80004840:	bfc5                	j	80004830 <filestat+0x60>

0000000080004842 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004842:	7179                	addi	sp,sp,-48
    80004844:	f406                	sd	ra,40(sp)
    80004846:	f022                	sd	s0,32(sp)
    80004848:	ec26                	sd	s1,24(sp)
    8000484a:	e84a                	sd	s2,16(sp)
    8000484c:	e44e                	sd	s3,8(sp)
    8000484e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004850:	00854783          	lbu	a5,8(a0)
    80004854:	c7c5                	beqz	a5,800048fc <fileread+0xba>
    80004856:	84aa                	mv	s1,a0
    80004858:	89ae                	mv	s3,a1
    8000485a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000485c:	411c                	lw	a5,0(a0)
    8000485e:	4705                	li	a4,1
    80004860:	04e78963          	beq	a5,a4,800048b2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004864:	470d                	li	a4,3
    80004866:	04e78d63          	beq	a5,a4,800048c0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000486a:	4709                	li	a4,2
    8000486c:	08e79063          	bne	a5,a4,800048ec <fileread+0xaa>
    ilock(f->ip);
    80004870:	6d08                	ld	a0,24(a0)
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	00a080e7          	jalr	10(ra) # 8000387c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000487a:	874a                	mv	a4,s2
    8000487c:	5094                	lw	a3,32(s1)
    8000487e:	864e                	mv	a2,s3
    80004880:	4585                	li	a1,1
    80004882:	6c88                	ld	a0,24(s1)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	2ac080e7          	jalr	684(ra) # 80003b30 <readi>
    8000488c:	892a                	mv	s2,a0
    8000488e:	00a05563          	blez	a0,80004898 <fileread+0x56>
      f->off += r;
    80004892:	509c                	lw	a5,32(s1)
    80004894:	9fa9                	addw	a5,a5,a0
    80004896:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004898:	6c88                	ld	a0,24(s1)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	0a4080e7          	jalr	164(ra) # 8000393e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048a2:	854a                	mv	a0,s2
    800048a4:	70a2                	ld	ra,40(sp)
    800048a6:	7402                	ld	s0,32(sp)
    800048a8:	64e2                	ld	s1,24(sp)
    800048aa:	6942                	ld	s2,16(sp)
    800048ac:	69a2                	ld	s3,8(sp)
    800048ae:	6145                	addi	sp,sp,48
    800048b0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048b2:	6908                	ld	a0,16(a0)
    800048b4:	00000097          	auipc	ra,0x0
    800048b8:	3d0080e7          	jalr	976(ra) # 80004c84 <piperead>
    800048bc:	892a                	mv	s2,a0
    800048be:	b7d5                	j	800048a2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048c0:	02451783          	lh	a5,36(a0)
    800048c4:	03079693          	slli	a3,a5,0x30
    800048c8:	92c1                	srli	a3,a3,0x30
    800048ca:	4725                	li	a4,9
    800048cc:	02d76a63          	bltu	a4,a3,80004900 <fileread+0xbe>
    800048d0:	0792                	slli	a5,a5,0x4
    800048d2:	00032717          	auipc	a4,0x32
    800048d6:	db670713          	addi	a4,a4,-586 # 80036688 <devsw>
    800048da:	97ba                	add	a5,a5,a4
    800048dc:	639c                	ld	a5,0(a5)
    800048de:	c39d                	beqz	a5,80004904 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    800048e0:	86b2                	mv	a3,a2
    800048e2:	862e                	mv	a2,a1
    800048e4:	4585                	li	a1,1
    800048e6:	9782                	jalr	a5
    800048e8:	892a                	mv	s2,a0
    800048ea:	bf65                	j	800048a2 <fileread+0x60>
    panic("fileread");
    800048ec:	00005517          	auipc	a0,0x5
    800048f0:	2d450513          	addi	a0,a0,724 # 80009bc0 <syscalls+0x290>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	c76080e7          	jalr	-906(ra) # 8000056a <panic>
    return -1;
    800048fc:	597d                	li	s2,-1
    800048fe:	b755                	j	800048a2 <fileread+0x60>
      return -1;
    80004900:	597d                	li	s2,-1
    80004902:	b745                	j	800048a2 <fileread+0x60>
    80004904:	597d                	li	s2,-1
    80004906:	bf71                	j	800048a2 <fileread+0x60>

0000000080004908 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004908:	715d                	addi	sp,sp,-80
    8000490a:	e486                	sd	ra,72(sp)
    8000490c:	e0a2                	sd	s0,64(sp)
    8000490e:	fc26                	sd	s1,56(sp)
    80004910:	f84a                	sd	s2,48(sp)
    80004912:	f44e                	sd	s3,40(sp)
    80004914:	f052                	sd	s4,32(sp)
    80004916:	ec56                	sd	s5,24(sp)
    80004918:	e85a                	sd	s6,16(sp)
    8000491a:	e45e                	sd	s7,8(sp)
    8000491c:	e062                	sd	s8,0(sp)
    8000491e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004920:	00954783          	lbu	a5,9(a0)
    80004924:	10078863          	beqz	a5,80004a34 <filewrite+0x12c>
    80004928:	892a                	mv	s2,a0
    8000492a:	8aae                	mv	s5,a1
    8000492c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000492e:	411c                	lw	a5,0(a0)
    80004930:	4705                	li	a4,1
    80004932:	02e78263          	beq	a5,a4,80004956 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004936:	470d                	li	a4,3
    80004938:	02e78663          	beq	a5,a4,80004964 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000493c:	4709                	li	a4,2
    8000493e:	0ee79363          	bne	a5,a4,80004a24 <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004942:	0ac05f63          	blez	a2,80004a00 <filewrite+0xf8>
    int i = 0;
    80004946:	4981                	li	s3,0
    80004948:	6b05                	lui	s6,0x1
    8000494a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000494e:	6b85                	lui	s7,0x1
    80004950:	c00b8b9b          	addiw	s7,s7,-1024
    80004954:	a871                	j	800049f0 <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    80004956:	6908                	ld	a0,16(a0)
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	232080e7          	jalr	562(ra) # 80004b8a <pipewrite>
    80004960:	8a2a                	mv	s4,a0
    80004962:	a055                	j	80004a06 <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004964:	02451783          	lh	a5,36(a0)
    80004968:	03079693          	slli	a3,a5,0x30
    8000496c:	92c1                	srli	a3,a3,0x30
    8000496e:	4725                	li	a4,9
    80004970:	0cd76463          	bltu	a4,a3,80004a38 <filewrite+0x130>
    80004974:	0792                	slli	a5,a5,0x4
    80004976:	00032717          	auipc	a4,0x32
    8000497a:	d1270713          	addi	a4,a4,-750 # 80036688 <devsw>
    8000497e:	97ba                	add	a5,a5,a4
    80004980:	679c                	ld	a5,8(a5)
    80004982:	cfcd                	beqz	a5,80004a3c <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004984:	86b2                	mv	a3,a2
    80004986:	862e                	mv	a2,a1
    80004988:	4585                	li	a1,1
    8000498a:	9782                	jalr	a5
    8000498c:	8a2a                	mv	s4,a0
    8000498e:	a8a5                	j	80004a06 <filewrite+0xfe>
    80004990:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004994:	00000097          	auipc	ra,0x0
    80004998:	8aa080e7          	jalr	-1878(ra) # 8000423e <begin_op>
      ilock(f->ip);
    8000499c:	01893503          	ld	a0,24(s2)
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	edc080e7          	jalr	-292(ra) # 8000387c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049a8:	8762                	mv	a4,s8
    800049aa:	02092683          	lw	a3,32(s2)
    800049ae:	01598633          	add	a2,s3,s5
    800049b2:	4585                	li	a1,1
    800049b4:	01893503          	ld	a0,24(s2)
    800049b8:	fffff097          	auipc	ra,0xfffff
    800049bc:	270080e7          	jalr	624(ra) # 80003c28 <writei>
    800049c0:	84aa                	mv	s1,a0
    800049c2:	00a05763          	blez	a0,800049d0 <filewrite+0xc8>
        f->off += r;
    800049c6:	02092783          	lw	a5,32(s2)
    800049ca:	9fa9                	addw	a5,a5,a0
    800049cc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049d0:	01893503          	ld	a0,24(s2)
    800049d4:	fffff097          	auipc	ra,0xfffff
    800049d8:	f6a080e7          	jalr	-150(ra) # 8000393e <iunlock>
      end_op();
    800049dc:	00000097          	auipc	ra,0x0
    800049e0:	8e2080e7          	jalr	-1822(ra) # 800042be <end_op>

      if(r != n1){
    800049e4:	009c1f63          	bne	s8,s1,80004a02 <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    800049e8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049ec:	0149db63          	bge	s3,s4,80004a02 <filewrite+0xfa>
      int n1 = n - i;
    800049f0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049f4:	84be                	mv	s1,a5
    800049f6:	2781                	sext.w	a5,a5
    800049f8:	f8fb5ce3          	bge	s6,a5,80004990 <filewrite+0x88>
    800049fc:	84de                	mv	s1,s7
    800049fe:	bf49                	j	80004990 <filewrite+0x88>
    int i = 0;
    80004a00:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a02:	013a1f63          	bne	s4,s3,80004a20 <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a06:	8552                	mv	a0,s4
    80004a08:	60a6                	ld	ra,72(sp)
    80004a0a:	6406                	ld	s0,64(sp)
    80004a0c:	74e2                	ld	s1,56(sp)
    80004a0e:	7942                	ld	s2,48(sp)
    80004a10:	79a2                	ld	s3,40(sp)
    80004a12:	7a02                	ld	s4,32(sp)
    80004a14:	6ae2                	ld	s5,24(sp)
    80004a16:	6b42                	ld	s6,16(sp)
    80004a18:	6ba2                	ld	s7,8(sp)
    80004a1a:	6c02                	ld	s8,0(sp)
    80004a1c:	6161                	addi	sp,sp,80
    80004a1e:	8082                	ret
    ret = (i == n ? n : -1);
    80004a20:	5a7d                	li	s4,-1
    80004a22:	b7d5                	j	80004a06 <filewrite+0xfe>
    panic("filewrite");
    80004a24:	00005517          	auipc	a0,0x5
    80004a28:	1ac50513          	addi	a0,a0,428 # 80009bd0 <syscalls+0x2a0>
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	b3e080e7          	jalr	-1218(ra) # 8000056a <panic>
    return -1;
    80004a34:	5a7d                	li	s4,-1
    80004a36:	bfc1                	j	80004a06 <filewrite+0xfe>
      return -1;
    80004a38:	5a7d                	li	s4,-1
    80004a3a:	b7f1                	j	80004a06 <filewrite+0xfe>
    80004a3c:	5a7d                	li	s4,-1
    80004a3e:	b7e1                	j	80004a06 <filewrite+0xfe>

0000000080004a40 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a40:	7179                	addi	sp,sp,-48
    80004a42:	f406                	sd	ra,40(sp)
    80004a44:	f022                	sd	s0,32(sp)
    80004a46:	ec26                	sd	s1,24(sp)
    80004a48:	e84a                	sd	s2,16(sp)
    80004a4a:	e44e                	sd	s3,8(sp)
    80004a4c:	e052                	sd	s4,0(sp)
    80004a4e:	1800                	addi	s0,sp,48
    80004a50:	84aa                	mv	s1,a0
    80004a52:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a54:	0005b023          	sd	zero,0(a1)
    80004a58:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a5c:	00000097          	auipc	ra,0x0
    80004a60:	bf0080e7          	jalr	-1040(ra) # 8000464c <filealloc>
    80004a64:	e088                	sd	a0,0(s1)
    80004a66:	c551                	beqz	a0,80004af2 <pipealloc+0xb2>
    80004a68:	00000097          	auipc	ra,0x0
    80004a6c:	be4080e7          	jalr	-1052(ra) # 8000464c <filealloc>
    80004a70:	00aa3023          	sd	a0,0(s4)
    80004a74:	c92d                	beqz	a0,80004ae6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	fd6080e7          	jalr	-42(ra) # 80000a4c <kalloc>
    80004a7e:	892a                	mv	s2,a0
    80004a80:	c125                	beqz	a0,80004ae0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a82:	4985                	li	s3,1
    80004a84:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004a88:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004a8c:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004a90:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004a94:	00005597          	auipc	a1,0x5
    80004a98:	14c58593          	addi	a1,a1,332 # 80009be0 <syscalls+0x2b0>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	02a080e7          	jalr	42(ra) # 80000ac6 <initlock>
  (*f0)->type = FD_PIPE;
    80004aa4:	609c                	ld	a5,0(s1)
    80004aa6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004aaa:	609c                	ld	a5,0(s1)
    80004aac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ab0:	609c                	ld	a5,0(s1)
    80004ab2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ab6:	609c                	ld	a5,0(s1)
    80004ab8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004abc:	000a3783          	ld	a5,0(s4)
    80004ac0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ac4:	000a3783          	ld	a5,0(s4)
    80004ac8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004acc:	000a3783          	ld	a5,0(s4)
    80004ad0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ad4:	000a3783          	ld	a5,0(s4)
    80004ad8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004adc:	4501                	li	a0,0
    80004ade:	a025                	j	80004b06 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ae0:	6088                	ld	a0,0(s1)
    80004ae2:	e501                	bnez	a0,80004aea <pipealloc+0xaa>
    80004ae4:	a039                	j	80004af2 <pipealloc+0xb2>
    80004ae6:	6088                	ld	a0,0(s1)
    80004ae8:	c51d                	beqz	a0,80004b16 <pipealloc+0xd6>
    fileclose(*f0);
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	c1e080e7          	jalr	-994(ra) # 80004708 <fileclose>
  if(*f1)
    80004af2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004af6:	557d                	li	a0,-1
  if(*f1)
    80004af8:	c799                	beqz	a5,80004b06 <pipealloc+0xc6>
    fileclose(*f1);
    80004afa:	853e                	mv	a0,a5
    80004afc:	00000097          	auipc	ra,0x0
    80004b00:	c0c080e7          	jalr	-1012(ra) # 80004708 <fileclose>
  return -1;
    80004b04:	557d                	li	a0,-1
}
    80004b06:	70a2                	ld	ra,40(sp)
    80004b08:	7402                	ld	s0,32(sp)
    80004b0a:	64e2                	ld	s1,24(sp)
    80004b0c:	6942                	ld	s2,16(sp)
    80004b0e:	69a2                	ld	s3,8(sp)
    80004b10:	6a02                	ld	s4,0(sp)
    80004b12:	6145                	addi	sp,sp,48
    80004b14:	8082                	ret
  return -1;
    80004b16:	557d                	li	a0,-1
    80004b18:	b7fd                	j	80004b06 <pipealloc+0xc6>

0000000080004b1a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b1a:	1101                	addi	sp,sp,-32
    80004b1c:	ec06                	sd	ra,24(sp)
    80004b1e:	e822                	sd	s0,16(sp)
    80004b20:	e426                	sd	s1,8(sp)
    80004b22:	e04a                	sd	s2,0(sp)
    80004b24:	1000                	addi	s0,sp,32
    80004b26:	84aa                	mv	s1,a0
    80004b28:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	072080e7          	jalr	114(ra) # 80000b9c <acquire>
  if(writable){
    80004b32:	02090d63          	beqz	s2,80004b6c <pipeclose+0x52>
    pi->writeopen = 0;
    80004b36:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004b3a:	22048513          	addi	a0,s1,544
    80004b3e:	ffffe097          	auipc	ra,0xffffe
    80004b42:	97e080e7          	jalr	-1666(ra) # 800024bc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b46:	2284b783          	ld	a5,552(s1)
    80004b4a:	eb95                	bnez	a5,80004b7e <pipeclose+0x64>
    release(&pi->lock);
    80004b4c:	8526                	mv	a0,s1
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	11e080e7          	jalr	286(ra) # 80000c6c <release>
    kfree((char*)pi);
    80004b56:	8526                	mv	a0,s1
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	dee080e7          	jalr	-530(ra) # 80000946 <kfree>
  } else
    release(&pi->lock);
}
    80004b60:	60e2                	ld	ra,24(sp)
    80004b62:	6442                	ld	s0,16(sp)
    80004b64:	64a2                	ld	s1,8(sp)
    80004b66:	6902                	ld	s2,0(sp)
    80004b68:	6105                	addi	sp,sp,32
    80004b6a:	8082                	ret
    pi->readopen = 0;
    80004b6c:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004b70:	22448513          	addi	a0,s1,548
    80004b74:	ffffe097          	auipc	ra,0xffffe
    80004b78:	948080e7          	jalr	-1720(ra) # 800024bc <wakeup>
    80004b7c:	b7e9                	j	80004b46 <pipeclose+0x2c>
    release(&pi->lock);
    80004b7e:	8526                	mv	a0,s1
    80004b80:	ffffc097          	auipc	ra,0xffffc
    80004b84:	0ec080e7          	jalr	236(ra) # 80000c6c <release>
}
    80004b88:	bfe1                	j	80004b60 <pipeclose+0x46>

0000000080004b8a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b8a:	7159                	addi	sp,sp,-112
    80004b8c:	f486                	sd	ra,104(sp)
    80004b8e:	f0a2                	sd	s0,96(sp)
    80004b90:	eca6                	sd	s1,88(sp)
    80004b92:	e8ca                	sd	s2,80(sp)
    80004b94:	e4ce                	sd	s3,72(sp)
    80004b96:	e0d2                	sd	s4,64(sp)
    80004b98:	fc56                	sd	s5,56(sp)
    80004b9a:	f85a                	sd	s6,48(sp)
    80004b9c:	f45e                	sd	s7,40(sp)
    80004b9e:	f062                	sd	s8,32(sp)
    80004ba0:	ec66                	sd	s9,24(sp)
    80004ba2:	1880                	addi	s0,sp,112
    80004ba4:	84aa                	mv	s1,a0
    80004ba6:	8aae                	mv	s5,a1
    80004ba8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004baa:	ffffd097          	auipc	ra,0xffffd
    80004bae:	fbe080e7          	jalr	-66(ra) # 80001b68 <myproc>
    80004bb2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bb4:	8526                	mv	a0,s1
    80004bb6:	ffffc097          	auipc	ra,0xffffc
    80004bba:	fe6080e7          	jalr	-26(ra) # 80000b9c <acquire>
  while(i < n){
    80004bbe:	0d405163          	blez	s4,80004c80 <pipewrite+0xf6>
    80004bc2:	8ba6                	mv	s7,s1
  int i = 0;
    80004bc4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bc6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004bc8:	22048c93          	addi	s9,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004bcc:	22448c13          	addi	s8,s1,548
    80004bd0:	a08d                	j	80004c32 <pipewrite+0xa8>
      release(&pi->lock);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	098080e7          	jalr	152(ra) # 80000c6c <release>
      return -1;
    80004bdc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bde:	854a                	mv	a0,s2
    80004be0:	70a6                	ld	ra,104(sp)
    80004be2:	7406                	ld	s0,96(sp)
    80004be4:	64e6                	ld	s1,88(sp)
    80004be6:	6946                	ld	s2,80(sp)
    80004be8:	69a6                	ld	s3,72(sp)
    80004bea:	6a06                	ld	s4,64(sp)
    80004bec:	7ae2                	ld	s5,56(sp)
    80004bee:	7b42                	ld	s6,48(sp)
    80004bf0:	7ba2                	ld	s7,40(sp)
    80004bf2:	7c02                	ld	s8,32(sp)
    80004bf4:	6ce2                	ld	s9,24(sp)
    80004bf6:	6165                	addi	sp,sp,112
    80004bf8:	8082                	ret
      wakeup(&pi->nread);
    80004bfa:	8566                	mv	a0,s9
    80004bfc:	ffffe097          	auipc	ra,0xffffe
    80004c00:	8c0080e7          	jalr	-1856(ra) # 800024bc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c04:	85de                	mv	a1,s7
    80004c06:	8562                	mv	a0,s8
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	72e080e7          	jalr	1838(ra) # 80002336 <sleep>
    80004c10:	a839                	j	80004c2e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c12:	2244a783          	lw	a5,548(s1)
    80004c16:	0017871b          	addiw	a4,a5,1
    80004c1a:	22e4a223          	sw	a4,548(s1)
    80004c1e:	1ff7f793          	andi	a5,a5,511
    80004c22:	97a6                	add	a5,a5,s1
    80004c24:	f9f44703          	lbu	a4,-97(s0)
    80004c28:	02e78023          	sb	a4,32(a5)
      i++;
    80004c2c:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c2e:	03495d63          	bge	s2,s4,80004c68 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004c32:	2284a783          	lw	a5,552(s1)
    80004c36:	dfd1                	beqz	a5,80004bd2 <pipewrite+0x48>
    80004c38:	0389a783          	lw	a5,56(s3)
    80004c3c:	fbd9                	bnez	a5,80004bd2 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c3e:	2204a783          	lw	a5,544(s1)
    80004c42:	2244a703          	lw	a4,548(s1)
    80004c46:	2007879b          	addiw	a5,a5,512
    80004c4a:	faf708e3          	beq	a4,a5,80004bfa <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c4e:	4685                	li	a3,1
    80004c50:	01590633          	add	a2,s2,s5
    80004c54:	f9f40593          	addi	a1,s0,-97
    80004c58:	0589b503          	ld	a0,88(s3)
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	c52080e7          	jalr	-942(ra) # 800018ae <copyin>
    80004c64:	fb6517e3          	bne	a0,s6,80004c12 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004c68:	22048513          	addi	a0,s1,544
    80004c6c:	ffffe097          	auipc	ra,0xffffe
    80004c70:	850080e7          	jalr	-1968(ra) # 800024bc <wakeup>
  release(&pi->lock);
    80004c74:	8526                	mv	a0,s1
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	ff6080e7          	jalr	-10(ra) # 80000c6c <release>
  return i;
    80004c7e:	b785                	j	80004bde <pipewrite+0x54>
  int i = 0;
    80004c80:	4901                	li	s2,0
    80004c82:	b7dd                	j	80004c68 <pipewrite+0xde>

0000000080004c84 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c84:	715d                	addi	sp,sp,-80
    80004c86:	e486                	sd	ra,72(sp)
    80004c88:	e0a2                	sd	s0,64(sp)
    80004c8a:	fc26                	sd	s1,56(sp)
    80004c8c:	f84a                	sd	s2,48(sp)
    80004c8e:	f44e                	sd	s3,40(sp)
    80004c90:	f052                	sd	s4,32(sp)
    80004c92:	ec56                	sd	s5,24(sp)
    80004c94:	e85a                	sd	s6,16(sp)
    80004c96:	0880                	addi	s0,sp,80
    80004c98:	84aa                	mv	s1,a0
    80004c9a:	892e                	mv	s2,a1
    80004c9c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c9e:	ffffd097          	auipc	ra,0xffffd
    80004ca2:	eca080e7          	jalr	-310(ra) # 80001b68 <myproc>
    80004ca6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ca8:	8b26                	mv	s6,s1
    80004caa:	8526                	mv	a0,s1
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	ef0080e7          	jalr	-272(ra) # 80000b9c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cb4:	2204a703          	lw	a4,544(s1)
    80004cb8:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cbc:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cc0:	02f71463          	bne	a4,a5,80004ce8 <piperead+0x64>
    80004cc4:	22c4a783          	lw	a5,556(s1)
    80004cc8:	c385                	beqz	a5,80004ce8 <piperead+0x64>
    if(pr->killed){
    80004cca:	038a2783          	lw	a5,56(s4)
    80004cce:	ebc1                	bnez	a5,80004d5e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cd0:	85da                	mv	a1,s6
    80004cd2:	854e                	mv	a0,s3
    80004cd4:	ffffd097          	auipc	ra,0xffffd
    80004cd8:	662080e7          	jalr	1634(ra) # 80002336 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cdc:	2204a703          	lw	a4,544(s1)
    80004ce0:	2244a783          	lw	a5,548(s1)
    80004ce4:	fef700e3          	beq	a4,a5,80004cc4 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ce8:	09505263          	blez	s5,80004d6c <piperead+0xe8>
    80004cec:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cee:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004cf0:	2204a783          	lw	a5,544(s1)
    80004cf4:	2244a703          	lw	a4,548(s1)
    80004cf8:	02f70d63          	beq	a4,a5,80004d32 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cfc:	0017871b          	addiw	a4,a5,1
    80004d00:	22e4a023          	sw	a4,544(s1)
    80004d04:	1ff7f793          	andi	a5,a5,511
    80004d08:	97a6                	add	a5,a5,s1
    80004d0a:	0207c783          	lbu	a5,32(a5)
    80004d0e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d12:	4685                	li	a3,1
    80004d14:	fbf40613          	addi	a2,s0,-65
    80004d18:	85ca                	mv	a1,s2
    80004d1a:	058a3503          	ld	a0,88(s4)
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	b04080e7          	jalr	-1276(ra) # 80001822 <copyout>
    80004d26:	01650663          	beq	a0,s6,80004d32 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d2a:	2985                	addiw	s3,s3,1
    80004d2c:	0905                	addi	s2,s2,1
    80004d2e:	fd3a91e3          	bne	s5,s3,80004cf0 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d32:	22448513          	addi	a0,s1,548
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	786080e7          	jalr	1926(ra) # 800024bc <wakeup>
  release(&pi->lock);
    80004d3e:	8526                	mv	a0,s1
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	f2c080e7          	jalr	-212(ra) # 80000c6c <release>
  return i;
}
    80004d48:	854e                	mv	a0,s3
    80004d4a:	60a6                	ld	ra,72(sp)
    80004d4c:	6406                	ld	s0,64(sp)
    80004d4e:	74e2                	ld	s1,56(sp)
    80004d50:	7942                	ld	s2,48(sp)
    80004d52:	79a2                	ld	s3,40(sp)
    80004d54:	7a02                	ld	s4,32(sp)
    80004d56:	6ae2                	ld	s5,24(sp)
    80004d58:	6b42                	ld	s6,16(sp)
    80004d5a:	6161                	addi	sp,sp,80
    80004d5c:	8082                	ret
      release(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	f0c080e7          	jalr	-244(ra) # 80000c6c <release>
      return -1;
    80004d68:	59fd                	li	s3,-1
    80004d6a:	bff9                	j	80004d48 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d6c:	4981                	li	s3,0
    80004d6e:	b7d1                	j	80004d32 <piperead+0xae>

0000000080004d70 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d70:	df010113          	addi	sp,sp,-528
    80004d74:	20113423          	sd	ra,520(sp)
    80004d78:	20813023          	sd	s0,512(sp)
    80004d7c:	ffa6                	sd	s1,504(sp)
    80004d7e:	fbca                	sd	s2,496(sp)
    80004d80:	f7ce                	sd	s3,488(sp)
    80004d82:	f3d2                	sd	s4,480(sp)
    80004d84:	efd6                	sd	s5,472(sp)
    80004d86:	ebda                	sd	s6,464(sp)
    80004d88:	e7de                	sd	s7,456(sp)
    80004d8a:	e3e2                	sd	s8,448(sp)
    80004d8c:	ff66                	sd	s9,440(sp)
    80004d8e:	fb6a                	sd	s10,432(sp)
    80004d90:	f76e                	sd	s11,424(sp)
    80004d92:	0c00                	addi	s0,sp,528
    80004d94:	84aa                	mv	s1,a0
    80004d96:	dea43c23          	sd	a0,-520(s0)
    80004d9a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d9e:	ffffd097          	auipc	ra,0xffffd
    80004da2:	dca080e7          	jalr	-566(ra) # 80001b68 <myproc>
    80004da6:	892a                	mv	s2,a0

  begin_op();
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	496080e7          	jalr	1174(ra) # 8000423e <begin_op>

  if((ip = namei(path)) == 0){
    80004db0:	8526                	mv	a0,s1
    80004db2:	fffff097          	auipc	ra,0xfffff
    80004db6:	280080e7          	jalr	640(ra) # 80004032 <namei>
    80004dba:	c92d                	beqz	a0,80004e2c <exec+0xbc>
    80004dbc:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dbe:	fffff097          	auipc	ra,0xfffff
    80004dc2:	abe080e7          	jalr	-1346(ra) # 8000387c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dc6:	04000713          	li	a4,64
    80004dca:	4681                	li	a3,0
    80004dcc:	e5040613          	addi	a2,s0,-432
    80004dd0:	4581                	li	a1,0
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	fffff097          	auipc	ra,0xfffff
    80004dd8:	d5c080e7          	jalr	-676(ra) # 80003b30 <readi>
    80004ddc:	04000793          	li	a5,64
    80004de0:	00f51a63          	bne	a0,a5,80004df4 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004de4:	e5042703          	lw	a4,-432(s0)
    80004de8:	464c47b7          	lui	a5,0x464c4
    80004dec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004df0:	04f70463          	beq	a4,a5,80004e38 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004df4:	8526                	mv	a0,s1
    80004df6:	fffff097          	auipc	ra,0xfffff
    80004dfa:	ce8080e7          	jalr	-792(ra) # 80003ade <iunlockput>
    end_op();
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	4c0080e7          	jalr	1216(ra) # 800042be <end_op>
  }
  return -1;
    80004e06:	557d                	li	a0,-1
}
    80004e08:	20813083          	ld	ra,520(sp)
    80004e0c:	20013403          	ld	s0,512(sp)
    80004e10:	74fe                	ld	s1,504(sp)
    80004e12:	795e                	ld	s2,496(sp)
    80004e14:	79be                	ld	s3,488(sp)
    80004e16:	7a1e                	ld	s4,480(sp)
    80004e18:	6afe                	ld	s5,472(sp)
    80004e1a:	6b5e                	ld	s6,464(sp)
    80004e1c:	6bbe                	ld	s7,456(sp)
    80004e1e:	6c1e                	ld	s8,448(sp)
    80004e20:	7cfa                	ld	s9,440(sp)
    80004e22:	7d5a                	ld	s10,432(sp)
    80004e24:	7dba                	ld	s11,424(sp)
    80004e26:	21010113          	addi	sp,sp,528
    80004e2a:	8082                	ret
    end_op();
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	492080e7          	jalr	1170(ra) # 800042be <end_op>
    return -1;
    80004e34:	557d                	li	a0,-1
    80004e36:	bfc9                	j	80004e08 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e38:	854a                	mv	a0,s2
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	df2080e7          	jalr	-526(ra) # 80001c2c <proc_pagetable>
    80004e42:	8baa                	mv	s7,a0
    80004e44:	d945                	beqz	a0,80004df4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e46:	e7042983          	lw	s3,-400(s0)
    80004e4a:	e8845783          	lhu	a5,-376(s0)
    80004e4e:	c7ad                	beqz	a5,80004eb8 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e50:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e52:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004e54:	6c85                	lui	s9,0x1
    80004e56:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e5a:	def43823          	sd	a5,-528(s0)
    80004e5e:	a42d                	j	80005088 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e60:	00005517          	auipc	a0,0x5
    80004e64:	d8850513          	addi	a0,a0,-632 # 80009be8 <syscalls+0x2b8>
    80004e68:	ffffb097          	auipc	ra,0xffffb
    80004e6c:	702080e7          	jalr	1794(ra) # 8000056a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e70:	8756                	mv	a4,s5
    80004e72:	012d86bb          	addw	a3,s11,s2
    80004e76:	4581                	li	a1,0
    80004e78:	8526                	mv	a0,s1
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	cb6080e7          	jalr	-842(ra) # 80003b30 <readi>
    80004e82:	2501                	sext.w	a0,a0
    80004e84:	1aaa9963          	bne	s5,a0,80005036 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004e88:	6785                	lui	a5,0x1
    80004e8a:	0127893b          	addw	s2,a5,s2
    80004e8e:	77fd                	lui	a5,0xfffff
    80004e90:	01478a3b          	addw	s4,a5,s4
    80004e94:	1f897163          	bgeu	s2,s8,80005076 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004e98:	02091593          	slli	a1,s2,0x20
    80004e9c:	9181                	srli	a1,a1,0x20
    80004e9e:	95ea                	add	a1,a1,s10
    80004ea0:	855e                	mv	a0,s7
    80004ea2:	ffffc097          	auipc	ra,0xffffc
    80004ea6:	412080e7          	jalr	1042(ra) # 800012b4 <walkaddr>
    80004eaa:	862a                	mv	a2,a0
    if(pa == 0)
    80004eac:	d955                	beqz	a0,80004e60 <exec+0xf0>
      n = PGSIZE;
    80004eae:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004eb0:	fd9a70e3          	bgeu	s4,s9,80004e70 <exec+0x100>
      n = sz - i;
    80004eb4:	8ad2                	mv	s5,s4
    80004eb6:	bf6d                	j	80004e70 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eb8:	4901                	li	s2,0
  iunlockput(ip);
    80004eba:	8526                	mv	a0,s1
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	c22080e7          	jalr	-990(ra) # 80003ade <iunlockput>
  end_op();
    80004ec4:	fffff097          	auipc	ra,0xfffff
    80004ec8:	3fa080e7          	jalr	1018(ra) # 800042be <end_op>
  p = myproc();
    80004ecc:	ffffd097          	auipc	ra,0xffffd
    80004ed0:	c9c080e7          	jalr	-868(ra) # 80001b68 <myproc>
    80004ed4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ed6:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004eda:	6785                	lui	a5,0x1
    80004edc:	17fd                	addi	a5,a5,-1
    80004ede:	993e                	add	s2,s2,a5
    80004ee0:	757d                	lui	a0,0xfffff
    80004ee2:	00a977b3          	and	a5,s2,a0
    80004ee6:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004eea:	6609                	lui	a2,0x2
    80004eec:	963e                	add	a2,a2,a5
    80004eee:	85be                	mv	a1,a5
    80004ef0:	855e                	mv	a0,s7
    80004ef2:	ffffc097          	auipc	ra,0xffffc
    80004ef6:	756080e7          	jalr	1878(ra) # 80001648 <uvmalloc>
    80004efa:	8b2a                	mv	s6,a0
  ip = 0;
    80004efc:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004efe:	12050c63          	beqz	a0,80005036 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f02:	75f9                	lui	a1,0xffffe
    80004f04:	95aa                	add	a1,a1,a0
    80004f06:	855e                	mv	a0,s7
    80004f08:	ffffd097          	auipc	ra,0xffffd
    80004f0c:	8e8080e7          	jalr	-1816(ra) # 800017f0 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f10:	7c7d                	lui	s8,0xfffff
    80004f12:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f14:	e0043783          	ld	a5,-512(s0)
    80004f18:	6388                	ld	a0,0(a5)
    80004f1a:	c535                	beqz	a0,80004f86 <exec+0x216>
    80004f1c:	e9040993          	addi	s3,s0,-368
    80004f20:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f24:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	10a080e7          	jalr	266(ra) # 80001030 <strlen>
    80004f2e:	2505                	addiw	a0,a0,1
    80004f30:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f34:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f38:	13896363          	bltu	s2,s8,8000505e <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f3c:	e0043d83          	ld	s11,-512(s0)
    80004f40:	000dba03          	ld	s4,0(s11)
    80004f44:	8552                	mv	a0,s4
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	0ea080e7          	jalr	234(ra) # 80001030 <strlen>
    80004f4e:	0015069b          	addiw	a3,a0,1
    80004f52:	8652                	mv	a2,s4
    80004f54:	85ca                	mv	a1,s2
    80004f56:	855e                	mv	a0,s7
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	8ca080e7          	jalr	-1846(ra) # 80001822 <copyout>
    80004f60:	10054363          	bltz	a0,80005066 <exec+0x2f6>
    ustack[argc] = sp;
    80004f64:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f68:	0485                	addi	s1,s1,1
    80004f6a:	008d8793          	addi	a5,s11,8
    80004f6e:	e0f43023          	sd	a5,-512(s0)
    80004f72:	008db503          	ld	a0,8(s11)
    80004f76:	c911                	beqz	a0,80004f8a <exec+0x21a>
    if(argc >= MAXARG)
    80004f78:	09a1                	addi	s3,s3,8
    80004f7a:	fb3c96e3          	bne	s9,s3,80004f26 <exec+0x1b6>
  sz = sz1;
    80004f7e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f82:	4481                	li	s1,0
    80004f84:	a84d                	j	80005036 <exec+0x2c6>
  sp = sz;
    80004f86:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f88:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f8a:	00349793          	slli	a5,s1,0x3
    80004f8e:	f9040713          	addi	a4,s0,-112
    80004f92:	97ba                	add	a5,a5,a4
    80004f94:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004f98:	00148693          	addi	a3,s1,1
    80004f9c:	068e                	slli	a3,a3,0x3
    80004f9e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fa2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fa6:	01897663          	bgeu	s2,s8,80004fb2 <exec+0x242>
  sz = sz1;
    80004faa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fae:	4481                	li	s1,0
    80004fb0:	a059                	j	80005036 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004fb2:	e9040613          	addi	a2,s0,-368
    80004fb6:	85ca                	mv	a1,s2
    80004fb8:	855e                	mv	a0,s7
    80004fba:	ffffd097          	auipc	ra,0xffffd
    80004fbe:	868080e7          	jalr	-1944(ra) # 80001822 <copyout>
    80004fc2:	0a054663          	bltz	a0,8000506e <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004fc6:	060ab783          	ld	a5,96(s5)
    80004fca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fce:	df843783          	ld	a5,-520(s0)
    80004fd2:	0007c703          	lbu	a4,0(a5)
    80004fd6:	cf11                	beqz	a4,80004ff2 <exec+0x282>
    80004fd8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004fda:	02f00693          	li	a3,47
    80004fde:	a039                	j	80004fec <exec+0x27c>
      last = s+1;
    80004fe0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004fe4:	0785                	addi	a5,a5,1
    80004fe6:	fff7c703          	lbu	a4,-1(a5)
    80004fea:	c701                	beqz	a4,80004ff2 <exec+0x282>
    if(*s == '/')
    80004fec:	fed71ce3          	bne	a4,a3,80004fe4 <exec+0x274>
    80004ff0:	bfc5                	j	80004fe0 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ff2:	4641                	li	a2,16
    80004ff4:	df843583          	ld	a1,-520(s0)
    80004ff8:	160a8513          	addi	a0,s5,352
    80004ffc:	ffffc097          	auipc	ra,0xffffc
    80005000:	002080e7          	jalr	2(ra) # 80000ffe <safestrcpy>
  oldpagetable = p->pagetable;
    80005004:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005008:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000500c:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005010:	060ab783          	ld	a5,96(s5)
    80005014:	e6843703          	ld	a4,-408(s0)
    80005018:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000501a:	060ab783          	ld	a5,96(s5)
    8000501e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005022:	85ea                	mv	a1,s10
    80005024:	ffffd097          	auipc	ra,0xffffd
    80005028:	d14080e7          	jalr	-748(ra) # 80001d38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000502c:	0004851b          	sext.w	a0,s1
    80005030:	bbe1                	j	80004e08 <exec+0x98>
    80005032:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005036:	e0843583          	ld	a1,-504(s0)
    8000503a:	855e                	mv	a0,s7
    8000503c:	ffffd097          	auipc	ra,0xffffd
    80005040:	cfc080e7          	jalr	-772(ra) # 80001d38 <proc_freepagetable>
  if(ip){
    80005044:	da0498e3          	bnez	s1,80004df4 <exec+0x84>
  return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	bb7d                	j	80004e08 <exec+0x98>
    8000504c:	e1243423          	sd	s2,-504(s0)
    80005050:	b7dd                	j	80005036 <exec+0x2c6>
    80005052:	e1243423          	sd	s2,-504(s0)
    80005056:	b7c5                	j	80005036 <exec+0x2c6>
    80005058:	e1243423          	sd	s2,-504(s0)
    8000505c:	bfe9                	j	80005036 <exec+0x2c6>
  sz = sz1;
    8000505e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005062:	4481                	li	s1,0
    80005064:	bfc9                	j	80005036 <exec+0x2c6>
  sz = sz1;
    80005066:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000506a:	4481                	li	s1,0
    8000506c:	b7e9                	j	80005036 <exec+0x2c6>
  sz = sz1;
    8000506e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005072:	4481                	li	s1,0
    80005074:	b7c9                	j	80005036 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005076:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000507a:	2b05                	addiw	s6,s6,1
    8000507c:	0389899b          	addiw	s3,s3,56
    80005080:	e8845783          	lhu	a5,-376(s0)
    80005084:	e2fb5be3          	bge	s6,a5,80004eba <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005088:	2981                	sext.w	s3,s3
    8000508a:	03800713          	li	a4,56
    8000508e:	86ce                	mv	a3,s3
    80005090:	e1840613          	addi	a2,s0,-488
    80005094:	4581                	li	a1,0
    80005096:	8526                	mv	a0,s1
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	a98080e7          	jalr	-1384(ra) # 80003b30 <readi>
    800050a0:	03800793          	li	a5,56
    800050a4:	f8f517e3          	bne	a0,a5,80005032 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800050a8:	e1842783          	lw	a5,-488(s0)
    800050ac:	4705                	li	a4,1
    800050ae:	fce796e3          	bne	a5,a4,8000507a <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800050b2:	e4043603          	ld	a2,-448(s0)
    800050b6:	e3843783          	ld	a5,-456(s0)
    800050ba:	f8f669e3          	bltu	a2,a5,8000504c <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050be:	e2843783          	ld	a5,-472(s0)
    800050c2:	963e                	add	a2,a2,a5
    800050c4:	f8f667e3          	bltu	a2,a5,80005052 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050c8:	85ca                	mv	a1,s2
    800050ca:	855e                	mv	a0,s7
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	57c080e7          	jalr	1404(ra) # 80001648 <uvmalloc>
    800050d4:	e0a43423          	sd	a0,-504(s0)
    800050d8:	d141                	beqz	a0,80005058 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    800050da:	e2843d03          	ld	s10,-472(s0)
    800050de:	df043783          	ld	a5,-528(s0)
    800050e2:	00fd77b3          	and	a5,s10,a5
    800050e6:	fba1                	bnez	a5,80005036 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050e8:	e2042d83          	lw	s11,-480(s0)
    800050ec:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050f0:	f80c03e3          	beqz	s8,80005076 <exec+0x306>
    800050f4:	8a62                	mv	s4,s8
    800050f6:	4901                	li	s2,0
    800050f8:	b345                	j	80004e98 <exec+0x128>

00000000800050fa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050fa:	7179                	addi	sp,sp,-48
    800050fc:	f406                	sd	ra,40(sp)
    800050fe:	f022                	sd	s0,32(sp)
    80005100:	ec26                	sd	s1,24(sp)
    80005102:	e84a                	sd	s2,16(sp)
    80005104:	1800                	addi	s0,sp,48
    80005106:	892e                	mv	s2,a1
    80005108:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000510a:	fdc40593          	addi	a1,s0,-36
    8000510e:	ffffe097          	auipc	ra,0xffffe
    80005112:	b7a080e7          	jalr	-1158(ra) # 80002c88 <argint>
    80005116:	04054063          	bltz	a0,80005156 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000511a:	fdc42703          	lw	a4,-36(s0)
    8000511e:	47bd                	li	a5,15
    80005120:	02e7ed63          	bltu	a5,a4,8000515a <argfd+0x60>
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	a44080e7          	jalr	-1468(ra) # 80001b68 <myproc>
    8000512c:	fdc42703          	lw	a4,-36(s0)
    80005130:	01a70793          	addi	a5,a4,26
    80005134:	078e                	slli	a5,a5,0x3
    80005136:	953e                	add	a0,a0,a5
    80005138:	651c                	ld	a5,8(a0)
    8000513a:	c395                	beqz	a5,8000515e <argfd+0x64>
    return -1;
  if(pfd)
    8000513c:	00090463          	beqz	s2,80005144 <argfd+0x4a>
    *pfd = fd;
    80005140:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005144:	4501                	li	a0,0
  if(pf)
    80005146:	c091                	beqz	s1,8000514a <argfd+0x50>
    *pf = f;
    80005148:	e09c                	sd	a5,0(s1)
}
    8000514a:	70a2                	ld	ra,40(sp)
    8000514c:	7402                	ld	s0,32(sp)
    8000514e:	64e2                	ld	s1,24(sp)
    80005150:	6942                	ld	s2,16(sp)
    80005152:	6145                	addi	sp,sp,48
    80005154:	8082                	ret
    return -1;
    80005156:	557d                	li	a0,-1
    80005158:	bfcd                	j	8000514a <argfd+0x50>
    return -1;
    8000515a:	557d                	li	a0,-1
    8000515c:	b7fd                	j	8000514a <argfd+0x50>
    8000515e:	557d                	li	a0,-1
    80005160:	b7ed                	j	8000514a <argfd+0x50>

0000000080005162 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005162:	1101                	addi	sp,sp,-32
    80005164:	ec06                	sd	ra,24(sp)
    80005166:	e822                	sd	s0,16(sp)
    80005168:	e426                	sd	s1,8(sp)
    8000516a:	1000                	addi	s0,sp,32
    8000516c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000516e:	ffffd097          	auipc	ra,0xffffd
    80005172:	9fa080e7          	jalr	-1542(ra) # 80001b68 <myproc>
    80005176:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005178:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffc7820>
    8000517c:	4501                	li	a0,0
    8000517e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005180:	6398                	ld	a4,0(a5)
    80005182:	cb19                	beqz	a4,80005198 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005184:	2505                	addiw	a0,a0,1
    80005186:	07a1                	addi	a5,a5,8
    80005188:	fed51ce3          	bne	a0,a3,80005180 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000518c:	557d                	li	a0,-1
}
    8000518e:	60e2                	ld	ra,24(sp)
    80005190:	6442                	ld	s0,16(sp)
    80005192:	64a2                	ld	s1,8(sp)
    80005194:	6105                	addi	sp,sp,32
    80005196:	8082                	ret
      p->ofile[fd] = f;
    80005198:	01a50793          	addi	a5,a0,26
    8000519c:	078e                	slli	a5,a5,0x3
    8000519e:	963e                	add	a2,a2,a5
    800051a0:	e604                	sd	s1,8(a2)
      return fd;
    800051a2:	b7f5                	j	8000518e <fdalloc+0x2c>

00000000800051a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051a4:	715d                	addi	sp,sp,-80
    800051a6:	e486                	sd	ra,72(sp)
    800051a8:	e0a2                	sd	s0,64(sp)
    800051aa:	fc26                	sd	s1,56(sp)
    800051ac:	f84a                	sd	s2,48(sp)
    800051ae:	f44e                	sd	s3,40(sp)
    800051b0:	f052                	sd	s4,32(sp)
    800051b2:	ec56                	sd	s5,24(sp)
    800051b4:	0880                	addi	s0,sp,80
    800051b6:	89ae                	mv	s3,a1
    800051b8:	8ab2                	mv	s5,a2
    800051ba:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051bc:	fb040593          	addi	a1,s0,-80
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	e90080e7          	jalr	-368(ra) # 80004050 <nameiparent>
    800051c8:	892a                	mv	s2,a0
    800051ca:	12050f63          	beqz	a0,80005308 <create+0x164>
    return 0;

  ilock(dp);
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	6ae080e7          	jalr	1710(ra) # 8000387c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051d6:	4601                	li	a2,0
    800051d8:	fb040593          	addi	a1,s0,-80
    800051dc:	854a                	mv	a0,s2
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	b82080e7          	jalr	-1150(ra) # 80003d60 <dirlookup>
    800051e6:	84aa                	mv	s1,a0
    800051e8:	c921                	beqz	a0,80005238 <create+0x94>
    iunlockput(dp);
    800051ea:	854a                	mv	a0,s2
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	8f2080e7          	jalr	-1806(ra) # 80003ade <iunlockput>
    ilock(ip);
    800051f4:	8526                	mv	a0,s1
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	686080e7          	jalr	1670(ra) # 8000387c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051fe:	2981                	sext.w	s3,s3
    80005200:	4789                	li	a5,2
    80005202:	02f99463          	bne	s3,a5,8000522a <create+0x86>
    80005206:	04c4d783          	lhu	a5,76(s1)
    8000520a:	37f9                	addiw	a5,a5,-2
    8000520c:	17c2                	slli	a5,a5,0x30
    8000520e:	93c1                	srli	a5,a5,0x30
    80005210:	4705                	li	a4,1
    80005212:	00f76c63          	bltu	a4,a5,8000522a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005216:	8526                	mv	a0,s1
    80005218:	60a6                	ld	ra,72(sp)
    8000521a:	6406                	ld	s0,64(sp)
    8000521c:	74e2                	ld	s1,56(sp)
    8000521e:	7942                	ld	s2,48(sp)
    80005220:	79a2                	ld	s3,40(sp)
    80005222:	7a02                	ld	s4,32(sp)
    80005224:	6ae2                	ld	s5,24(sp)
    80005226:	6161                	addi	sp,sp,80
    80005228:	8082                	ret
    iunlockput(ip);
    8000522a:	8526                	mv	a0,s1
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	8b2080e7          	jalr	-1870(ra) # 80003ade <iunlockput>
    return 0;
    80005234:	4481                	li	s1,0
    80005236:	b7c5                	j	80005216 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005238:	85ce                	mv	a1,s3
    8000523a:	00092503          	lw	a0,0(s2)
    8000523e:	ffffe097          	auipc	ra,0xffffe
    80005242:	4a6080e7          	jalr	1190(ra) # 800036e4 <ialloc>
    80005246:	84aa                	mv	s1,a0
    80005248:	c529                	beqz	a0,80005292 <create+0xee>
  ilock(ip);
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	632080e7          	jalr	1586(ra) # 8000387c <ilock>
  ip->major = major;
    80005252:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005256:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000525a:	4785                	li	a5,1
    8000525c:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005260:	8526                	mv	a0,s1
    80005262:	ffffe097          	auipc	ra,0xffffe
    80005266:	550080e7          	jalr	1360(ra) # 800037b2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000526a:	2981                	sext.w	s3,s3
    8000526c:	4785                	li	a5,1
    8000526e:	02f98a63          	beq	s3,a5,800052a2 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005272:	40d0                	lw	a2,4(s1)
    80005274:	fb040593          	addi	a1,s0,-80
    80005278:	854a                	mv	a0,s2
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	cf6080e7          	jalr	-778(ra) # 80003f70 <dirlink>
    80005282:	06054b63          	bltz	a0,800052f8 <create+0x154>
  iunlockput(dp);
    80005286:	854a                	mv	a0,s2
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	856080e7          	jalr	-1962(ra) # 80003ade <iunlockput>
  return ip;
    80005290:	b759                	j	80005216 <create+0x72>
    panic("create: ialloc");
    80005292:	00005517          	auipc	a0,0x5
    80005296:	97650513          	addi	a0,a0,-1674 # 80009c08 <syscalls+0x2d8>
    8000529a:	ffffb097          	auipc	ra,0xffffb
    8000529e:	2d0080e7          	jalr	720(ra) # 8000056a <panic>
    dp->nlink++;  // for ".."
    800052a2:	05295783          	lhu	a5,82(s2)
    800052a6:	2785                	addiw	a5,a5,1
    800052a8:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800052ac:	854a                	mv	a0,s2
    800052ae:	ffffe097          	auipc	ra,0xffffe
    800052b2:	504080e7          	jalr	1284(ra) # 800037b2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052b6:	40d0                	lw	a2,4(s1)
    800052b8:	00005597          	auipc	a1,0x5
    800052bc:	96058593          	addi	a1,a1,-1696 # 80009c18 <syscalls+0x2e8>
    800052c0:	8526                	mv	a0,s1
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	cae080e7          	jalr	-850(ra) # 80003f70 <dirlink>
    800052ca:	00054f63          	bltz	a0,800052e8 <create+0x144>
    800052ce:	00492603          	lw	a2,4(s2)
    800052d2:	00005597          	auipc	a1,0x5
    800052d6:	94e58593          	addi	a1,a1,-1714 # 80009c20 <syscalls+0x2f0>
    800052da:	8526                	mv	a0,s1
    800052dc:	fffff097          	auipc	ra,0xfffff
    800052e0:	c94080e7          	jalr	-876(ra) # 80003f70 <dirlink>
    800052e4:	f80557e3          	bgez	a0,80005272 <create+0xce>
      panic("create dots");
    800052e8:	00005517          	auipc	a0,0x5
    800052ec:	94050513          	addi	a0,a0,-1728 # 80009c28 <syscalls+0x2f8>
    800052f0:	ffffb097          	auipc	ra,0xffffb
    800052f4:	27a080e7          	jalr	634(ra) # 8000056a <panic>
    panic("create: dirlink");
    800052f8:	00005517          	auipc	a0,0x5
    800052fc:	94050513          	addi	a0,a0,-1728 # 80009c38 <syscalls+0x308>
    80005300:	ffffb097          	auipc	ra,0xffffb
    80005304:	26a080e7          	jalr	618(ra) # 8000056a <panic>
    return 0;
    80005308:	84aa                	mv	s1,a0
    8000530a:	b731                	j	80005216 <create+0x72>

000000008000530c <sys_dup>:
{
    8000530c:	7179                	addi	sp,sp,-48
    8000530e:	f406                	sd	ra,40(sp)
    80005310:	f022                	sd	s0,32(sp)
    80005312:	ec26                	sd	s1,24(sp)
    80005314:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005316:	fd840613          	addi	a2,s0,-40
    8000531a:	4581                	li	a1,0
    8000531c:	4501                	li	a0,0
    8000531e:	00000097          	auipc	ra,0x0
    80005322:	ddc080e7          	jalr	-548(ra) # 800050fa <argfd>
    return -1;
    80005326:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005328:	02054363          	bltz	a0,8000534e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000532c:	fd843503          	ld	a0,-40(s0)
    80005330:	00000097          	auipc	ra,0x0
    80005334:	e32080e7          	jalr	-462(ra) # 80005162 <fdalloc>
    80005338:	84aa                	mv	s1,a0
    return -1;
    8000533a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000533c:	00054963          	bltz	a0,8000534e <sys_dup+0x42>
  filedup(f);
    80005340:	fd843503          	ld	a0,-40(s0)
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	372080e7          	jalr	882(ra) # 800046b6 <filedup>
  return fd;
    8000534c:	87a6                	mv	a5,s1
}
    8000534e:	853e                	mv	a0,a5
    80005350:	70a2                	ld	ra,40(sp)
    80005352:	7402                	ld	s0,32(sp)
    80005354:	64e2                	ld	s1,24(sp)
    80005356:	6145                	addi	sp,sp,48
    80005358:	8082                	ret

000000008000535a <sys_read>:
{
    8000535a:	7179                	addi	sp,sp,-48
    8000535c:	f406                	sd	ra,40(sp)
    8000535e:	f022                	sd	s0,32(sp)
    80005360:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005362:	fe840613          	addi	a2,s0,-24
    80005366:	4581                	li	a1,0
    80005368:	4501                	li	a0,0
    8000536a:	00000097          	auipc	ra,0x0
    8000536e:	d90080e7          	jalr	-624(ra) # 800050fa <argfd>
    return -1;
    80005372:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005374:	04054163          	bltz	a0,800053b6 <sys_read+0x5c>
    80005378:	fe440593          	addi	a1,s0,-28
    8000537c:	4509                	li	a0,2
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	90a080e7          	jalr	-1782(ra) # 80002c88 <argint>
    return -1;
    80005386:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005388:	02054763          	bltz	a0,800053b6 <sys_read+0x5c>
    8000538c:	fd840593          	addi	a1,s0,-40
    80005390:	4505                	li	a0,1
    80005392:	ffffe097          	auipc	ra,0xffffe
    80005396:	918080e7          	jalr	-1768(ra) # 80002caa <argaddr>
    return -1;
    8000539a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000539c:	00054d63          	bltz	a0,800053b6 <sys_read+0x5c>
  return fileread(f, p, n);
    800053a0:	fe442603          	lw	a2,-28(s0)
    800053a4:	fd843583          	ld	a1,-40(s0)
    800053a8:	fe843503          	ld	a0,-24(s0)
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	496080e7          	jalr	1174(ra) # 80004842 <fileread>
    800053b4:	87aa                	mv	a5,a0
}
    800053b6:	853e                	mv	a0,a5
    800053b8:	70a2                	ld	ra,40(sp)
    800053ba:	7402                	ld	s0,32(sp)
    800053bc:	6145                	addi	sp,sp,48
    800053be:	8082                	ret

00000000800053c0 <sys_write>:
{
    800053c0:	7179                	addi	sp,sp,-48
    800053c2:	f406                	sd	ra,40(sp)
    800053c4:	f022                	sd	s0,32(sp)
    800053c6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c8:	fe840613          	addi	a2,s0,-24
    800053cc:	4581                	li	a1,0
    800053ce:	4501                	li	a0,0
    800053d0:	00000097          	auipc	ra,0x0
    800053d4:	d2a080e7          	jalr	-726(ra) # 800050fa <argfd>
    return -1;
    800053d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053da:	04054163          	bltz	a0,8000541c <sys_write+0x5c>
    800053de:	fe440593          	addi	a1,s0,-28
    800053e2:	4509                	li	a0,2
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	8a4080e7          	jalr	-1884(ra) # 80002c88 <argint>
    return -1;
    800053ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ee:	02054763          	bltz	a0,8000541c <sys_write+0x5c>
    800053f2:	fd840593          	addi	a1,s0,-40
    800053f6:	4505                	li	a0,1
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	8b2080e7          	jalr	-1870(ra) # 80002caa <argaddr>
    return -1;
    80005400:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005402:	00054d63          	bltz	a0,8000541c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005406:	fe442603          	lw	a2,-28(s0)
    8000540a:	fd843583          	ld	a1,-40(s0)
    8000540e:	fe843503          	ld	a0,-24(s0)
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	4f6080e7          	jalr	1270(ra) # 80004908 <filewrite>
    8000541a:	87aa                	mv	a5,a0
}
    8000541c:	853e                	mv	a0,a5
    8000541e:	70a2                	ld	ra,40(sp)
    80005420:	7402                	ld	s0,32(sp)
    80005422:	6145                	addi	sp,sp,48
    80005424:	8082                	ret

0000000080005426 <sys_close>:
{
    80005426:	1101                	addi	sp,sp,-32
    80005428:	ec06                	sd	ra,24(sp)
    8000542a:	e822                	sd	s0,16(sp)
    8000542c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000542e:	fe040613          	addi	a2,s0,-32
    80005432:	fec40593          	addi	a1,s0,-20
    80005436:	4501                	li	a0,0
    80005438:	00000097          	auipc	ra,0x0
    8000543c:	cc2080e7          	jalr	-830(ra) # 800050fa <argfd>
    return -1;
    80005440:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005442:	02054463          	bltz	a0,8000546a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005446:	ffffc097          	auipc	ra,0xffffc
    8000544a:	722080e7          	jalr	1826(ra) # 80001b68 <myproc>
    8000544e:	fec42783          	lw	a5,-20(s0)
    80005452:	07e9                	addi	a5,a5,26
    80005454:	078e                	slli	a5,a5,0x3
    80005456:	97aa                	add	a5,a5,a0
    80005458:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000545c:	fe043503          	ld	a0,-32(s0)
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	2a8080e7          	jalr	680(ra) # 80004708 <fileclose>
  return 0;
    80005468:	4781                	li	a5,0
}
    8000546a:	853e                	mv	a0,a5
    8000546c:	60e2                	ld	ra,24(sp)
    8000546e:	6442                	ld	s0,16(sp)
    80005470:	6105                	addi	sp,sp,32
    80005472:	8082                	ret

0000000080005474 <sys_fstat>:
{
    80005474:	1101                	addi	sp,sp,-32
    80005476:	ec06                	sd	ra,24(sp)
    80005478:	e822                	sd	s0,16(sp)
    8000547a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000547c:	fe840613          	addi	a2,s0,-24
    80005480:	4581                	li	a1,0
    80005482:	4501                	li	a0,0
    80005484:	00000097          	auipc	ra,0x0
    80005488:	c76080e7          	jalr	-906(ra) # 800050fa <argfd>
    return -1;
    8000548c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000548e:	02054563          	bltz	a0,800054b8 <sys_fstat+0x44>
    80005492:	fe040593          	addi	a1,s0,-32
    80005496:	4505                	li	a0,1
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	812080e7          	jalr	-2030(ra) # 80002caa <argaddr>
    return -1;
    800054a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054a2:	00054b63          	bltz	a0,800054b8 <sys_fstat+0x44>
  return filestat(f, st);
    800054a6:	fe043583          	ld	a1,-32(s0)
    800054aa:	fe843503          	ld	a0,-24(s0)
    800054ae:	fffff097          	auipc	ra,0xfffff
    800054b2:	322080e7          	jalr	802(ra) # 800047d0 <filestat>
    800054b6:	87aa                	mv	a5,a0
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	60e2                	ld	ra,24(sp)
    800054bc:	6442                	ld	s0,16(sp)
    800054be:	6105                	addi	sp,sp,32
    800054c0:	8082                	ret

00000000800054c2 <sys_link>:
{
    800054c2:	7169                	addi	sp,sp,-304
    800054c4:	f606                	sd	ra,296(sp)
    800054c6:	f222                	sd	s0,288(sp)
    800054c8:	ee26                	sd	s1,280(sp)
    800054ca:	ea4a                	sd	s2,272(sp)
    800054cc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054ce:	08000613          	li	a2,128
    800054d2:	ed040593          	addi	a1,s0,-304
    800054d6:	4501                	li	a0,0
    800054d8:	ffffd097          	auipc	ra,0xffffd
    800054dc:	7f4080e7          	jalr	2036(ra) # 80002ccc <argstr>
    return -1;
    800054e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054e2:	10054e63          	bltz	a0,800055fe <sys_link+0x13c>
    800054e6:	08000613          	li	a2,128
    800054ea:	f5040593          	addi	a1,s0,-176
    800054ee:	4505                	li	a0,1
    800054f0:	ffffd097          	auipc	ra,0xffffd
    800054f4:	7dc080e7          	jalr	2012(ra) # 80002ccc <argstr>
    return -1;
    800054f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054fa:	10054263          	bltz	a0,800055fe <sys_link+0x13c>
  begin_op();
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	d40080e7          	jalr	-704(ra) # 8000423e <begin_op>
  if((ip = namei(old)) == 0){
    80005506:	ed040513          	addi	a0,s0,-304
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	b28080e7          	jalr	-1240(ra) # 80004032 <namei>
    80005512:	84aa                	mv	s1,a0
    80005514:	c551                	beqz	a0,800055a0 <sys_link+0xde>
  ilock(ip);
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	366080e7          	jalr	870(ra) # 8000387c <ilock>
  if(ip->type == T_DIR){
    8000551e:	04c49703          	lh	a4,76(s1)
    80005522:	4785                	li	a5,1
    80005524:	08f70463          	beq	a4,a5,800055ac <sys_link+0xea>
  ip->nlink++;
    80005528:	0524d783          	lhu	a5,82(s1)
    8000552c:	2785                	addiw	a5,a5,1
    8000552e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005532:	8526                	mv	a0,s1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	27e080e7          	jalr	638(ra) # 800037b2 <iupdate>
  iunlock(ip);
    8000553c:	8526                	mv	a0,s1
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	400080e7          	jalr	1024(ra) # 8000393e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005546:	fd040593          	addi	a1,s0,-48
    8000554a:	f5040513          	addi	a0,s0,-176
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	b02080e7          	jalr	-1278(ra) # 80004050 <nameiparent>
    80005556:	892a                	mv	s2,a0
    80005558:	c935                	beqz	a0,800055cc <sys_link+0x10a>
  ilock(dp);
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	322080e7          	jalr	802(ra) # 8000387c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005562:	00092703          	lw	a4,0(s2)
    80005566:	409c                	lw	a5,0(s1)
    80005568:	04f71d63          	bne	a4,a5,800055c2 <sys_link+0x100>
    8000556c:	40d0                	lw	a2,4(s1)
    8000556e:	fd040593          	addi	a1,s0,-48
    80005572:	854a                	mv	a0,s2
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	9fc080e7          	jalr	-1540(ra) # 80003f70 <dirlink>
    8000557c:	04054363          	bltz	a0,800055c2 <sys_link+0x100>
  iunlockput(dp);
    80005580:	854a                	mv	a0,s2
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	55c080e7          	jalr	1372(ra) # 80003ade <iunlockput>
  iput(ip);
    8000558a:	8526                	mv	a0,s1
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	4aa080e7          	jalr	1194(ra) # 80003a36 <iput>
  end_op();
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	d2a080e7          	jalr	-726(ra) # 800042be <end_op>
  return 0;
    8000559c:	4781                	li	a5,0
    8000559e:	a085                	j	800055fe <sys_link+0x13c>
    end_op();
    800055a0:	fffff097          	auipc	ra,0xfffff
    800055a4:	d1e080e7          	jalr	-738(ra) # 800042be <end_op>
    return -1;
    800055a8:	57fd                	li	a5,-1
    800055aa:	a891                	j	800055fe <sys_link+0x13c>
    iunlockput(ip);
    800055ac:	8526                	mv	a0,s1
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	530080e7          	jalr	1328(ra) # 80003ade <iunlockput>
    end_op();
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	d08080e7          	jalr	-760(ra) # 800042be <end_op>
    return -1;
    800055be:	57fd                	li	a5,-1
    800055c0:	a83d                	j	800055fe <sys_link+0x13c>
    iunlockput(dp);
    800055c2:	854a                	mv	a0,s2
    800055c4:	ffffe097          	auipc	ra,0xffffe
    800055c8:	51a080e7          	jalr	1306(ra) # 80003ade <iunlockput>
  ilock(ip);
    800055cc:	8526                	mv	a0,s1
    800055ce:	ffffe097          	auipc	ra,0xffffe
    800055d2:	2ae080e7          	jalr	686(ra) # 8000387c <ilock>
  ip->nlink--;
    800055d6:	0524d783          	lhu	a5,82(s1)
    800055da:	37fd                	addiw	a5,a5,-1
    800055dc:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055e0:	8526                	mv	a0,s1
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	1d0080e7          	jalr	464(ra) # 800037b2 <iupdate>
  iunlockput(ip);
    800055ea:	8526                	mv	a0,s1
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	4f2080e7          	jalr	1266(ra) # 80003ade <iunlockput>
  end_op();
    800055f4:	fffff097          	auipc	ra,0xfffff
    800055f8:	cca080e7          	jalr	-822(ra) # 800042be <end_op>
  return -1;
    800055fc:	57fd                	li	a5,-1
}
    800055fe:	853e                	mv	a0,a5
    80005600:	70b2                	ld	ra,296(sp)
    80005602:	7412                	ld	s0,288(sp)
    80005604:	64f2                	ld	s1,280(sp)
    80005606:	6952                	ld	s2,272(sp)
    80005608:	6155                	addi	sp,sp,304
    8000560a:	8082                	ret

000000008000560c <sys_unlink>:
{
    8000560c:	7151                	addi	sp,sp,-240
    8000560e:	f586                	sd	ra,232(sp)
    80005610:	f1a2                	sd	s0,224(sp)
    80005612:	eda6                	sd	s1,216(sp)
    80005614:	e9ca                	sd	s2,208(sp)
    80005616:	e5ce                	sd	s3,200(sp)
    80005618:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000561a:	08000613          	li	a2,128
    8000561e:	f3040593          	addi	a1,s0,-208
    80005622:	4501                	li	a0,0
    80005624:	ffffd097          	auipc	ra,0xffffd
    80005628:	6a8080e7          	jalr	1704(ra) # 80002ccc <argstr>
    8000562c:	18054163          	bltz	a0,800057ae <sys_unlink+0x1a2>
  begin_op();
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	c0e080e7          	jalr	-1010(ra) # 8000423e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005638:	fb040593          	addi	a1,s0,-80
    8000563c:	f3040513          	addi	a0,s0,-208
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	a10080e7          	jalr	-1520(ra) # 80004050 <nameiparent>
    80005648:	84aa                	mv	s1,a0
    8000564a:	c979                	beqz	a0,80005720 <sys_unlink+0x114>
  ilock(dp);
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	230080e7          	jalr	560(ra) # 8000387c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005654:	00004597          	auipc	a1,0x4
    80005658:	5c458593          	addi	a1,a1,1476 # 80009c18 <syscalls+0x2e8>
    8000565c:	fb040513          	addi	a0,s0,-80
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	6e6080e7          	jalr	1766(ra) # 80003d46 <namecmp>
    80005668:	14050a63          	beqz	a0,800057bc <sys_unlink+0x1b0>
    8000566c:	00004597          	auipc	a1,0x4
    80005670:	5b458593          	addi	a1,a1,1460 # 80009c20 <syscalls+0x2f0>
    80005674:	fb040513          	addi	a0,s0,-80
    80005678:	ffffe097          	auipc	ra,0xffffe
    8000567c:	6ce080e7          	jalr	1742(ra) # 80003d46 <namecmp>
    80005680:	12050e63          	beqz	a0,800057bc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005684:	f2c40613          	addi	a2,s0,-212
    80005688:	fb040593          	addi	a1,s0,-80
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	6d2080e7          	jalr	1746(ra) # 80003d60 <dirlookup>
    80005696:	892a                	mv	s2,a0
    80005698:	12050263          	beqz	a0,800057bc <sys_unlink+0x1b0>
  ilock(ip);
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	1e0080e7          	jalr	480(ra) # 8000387c <ilock>
  if(ip->nlink < 1)
    800056a4:	05291783          	lh	a5,82(s2)
    800056a8:	08f05263          	blez	a5,8000572c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056ac:	04c91703          	lh	a4,76(s2)
    800056b0:	4785                	li	a5,1
    800056b2:	08f70563          	beq	a4,a5,8000573c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056b6:	4641                	li	a2,16
    800056b8:	4581                	li	a1,0
    800056ba:	fc040513          	addi	a0,s0,-64
    800056be:	ffffb097          	auipc	ra,0xffffb
    800056c2:	7c2080e7          	jalr	1986(ra) # 80000e80 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056c6:	4741                	li	a4,16
    800056c8:	f2c42683          	lw	a3,-212(s0)
    800056cc:	fc040613          	addi	a2,s0,-64
    800056d0:	4581                	li	a1,0
    800056d2:	8526                	mv	a0,s1
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	554080e7          	jalr	1364(ra) # 80003c28 <writei>
    800056dc:	47c1                	li	a5,16
    800056de:	0af51563          	bne	a0,a5,80005788 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056e2:	04c91703          	lh	a4,76(s2)
    800056e6:	4785                	li	a5,1
    800056e8:	0af70863          	beq	a4,a5,80005798 <sys_unlink+0x18c>
  iunlockput(dp);
    800056ec:	8526                	mv	a0,s1
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	3f0080e7          	jalr	1008(ra) # 80003ade <iunlockput>
  ip->nlink--;
    800056f6:	05295783          	lhu	a5,82(s2)
    800056fa:	37fd                	addiw	a5,a5,-1
    800056fc:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	0b0080e7          	jalr	176(ra) # 800037b2 <iupdate>
  iunlockput(ip);
    8000570a:	854a                	mv	a0,s2
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	3d2080e7          	jalr	978(ra) # 80003ade <iunlockput>
  end_op();
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	baa080e7          	jalr	-1110(ra) # 800042be <end_op>
  return 0;
    8000571c:	4501                	li	a0,0
    8000571e:	a84d                	j	800057d0 <sys_unlink+0x1c4>
    end_op();
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	b9e080e7          	jalr	-1122(ra) # 800042be <end_op>
    return -1;
    80005728:	557d                	li	a0,-1
    8000572a:	a05d                	j	800057d0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000572c:	00004517          	auipc	a0,0x4
    80005730:	51c50513          	addi	a0,a0,1308 # 80009c48 <syscalls+0x318>
    80005734:	ffffb097          	auipc	ra,0xffffb
    80005738:	e36080e7          	jalr	-458(ra) # 8000056a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000573c:	05492703          	lw	a4,84(s2)
    80005740:	02000793          	li	a5,32
    80005744:	f6e7f9e3          	bgeu	a5,a4,800056b6 <sys_unlink+0xaa>
    80005748:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000574c:	4741                	li	a4,16
    8000574e:	86ce                	mv	a3,s3
    80005750:	f1840613          	addi	a2,s0,-232
    80005754:	4581                	li	a1,0
    80005756:	854a                	mv	a0,s2
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	3d8080e7          	jalr	984(ra) # 80003b30 <readi>
    80005760:	47c1                	li	a5,16
    80005762:	00f51b63          	bne	a0,a5,80005778 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005766:	f1845783          	lhu	a5,-232(s0)
    8000576a:	e7a1                	bnez	a5,800057b2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000576c:	29c1                	addiw	s3,s3,16
    8000576e:	05492783          	lw	a5,84(s2)
    80005772:	fcf9ede3          	bltu	s3,a5,8000574c <sys_unlink+0x140>
    80005776:	b781                	j	800056b6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005778:	00004517          	auipc	a0,0x4
    8000577c:	4e850513          	addi	a0,a0,1256 # 80009c60 <syscalls+0x330>
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	dea080e7          	jalr	-534(ra) # 8000056a <panic>
    panic("unlink: writei");
    80005788:	00004517          	auipc	a0,0x4
    8000578c:	4f050513          	addi	a0,a0,1264 # 80009c78 <syscalls+0x348>
    80005790:	ffffb097          	auipc	ra,0xffffb
    80005794:	dda080e7          	jalr	-550(ra) # 8000056a <panic>
    dp->nlink--;
    80005798:	0524d783          	lhu	a5,82(s1)
    8000579c:	37fd                	addiw	a5,a5,-1
    8000579e:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    800057a2:	8526                	mv	a0,s1
    800057a4:	ffffe097          	auipc	ra,0xffffe
    800057a8:	00e080e7          	jalr	14(ra) # 800037b2 <iupdate>
    800057ac:	b781                	j	800056ec <sys_unlink+0xe0>
    return -1;
    800057ae:	557d                	li	a0,-1
    800057b0:	a005                	j	800057d0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800057b2:	854a                	mv	a0,s2
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	32a080e7          	jalr	810(ra) # 80003ade <iunlockput>
  iunlockput(dp);
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	320080e7          	jalr	800(ra) # 80003ade <iunlockput>
  end_op();
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	af8080e7          	jalr	-1288(ra) # 800042be <end_op>
  return -1;
    800057ce:	557d                	li	a0,-1
}
    800057d0:	70ae                	ld	ra,232(sp)
    800057d2:	740e                	ld	s0,224(sp)
    800057d4:	64ee                	ld	s1,216(sp)
    800057d6:	694e                	ld	s2,208(sp)
    800057d8:	69ae                	ld	s3,200(sp)
    800057da:	616d                	addi	sp,sp,240
    800057dc:	8082                	ret

00000000800057de <sys_open>:

uint64
sys_open(void)
{
    800057de:	7131                	addi	sp,sp,-192
    800057e0:	fd06                	sd	ra,184(sp)
    800057e2:	f922                	sd	s0,176(sp)
    800057e4:	f526                	sd	s1,168(sp)
    800057e6:	f14a                	sd	s2,160(sp)
    800057e8:	ed4e                	sd	s3,152(sp)
    800057ea:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057ec:	08000613          	li	a2,128
    800057f0:	f5040593          	addi	a1,s0,-176
    800057f4:	4501                	li	a0,0
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	4d6080e7          	jalr	1238(ra) # 80002ccc <argstr>
    return -1;
    800057fe:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005800:	0c054163          	bltz	a0,800058c2 <sys_open+0xe4>
    80005804:	f4c40593          	addi	a1,s0,-180
    80005808:	4505                	li	a0,1
    8000580a:	ffffd097          	auipc	ra,0xffffd
    8000580e:	47e080e7          	jalr	1150(ra) # 80002c88 <argint>
    80005812:	0a054863          	bltz	a0,800058c2 <sys_open+0xe4>

  begin_op();
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	a28080e7          	jalr	-1496(ra) # 8000423e <begin_op>

  if(omode & O_CREATE){
    8000581e:	f4c42783          	lw	a5,-180(s0)
    80005822:	2007f793          	andi	a5,a5,512
    80005826:	cbdd                	beqz	a5,800058dc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005828:	4681                	li	a3,0
    8000582a:	4601                	li	a2,0
    8000582c:	4589                	li	a1,2
    8000582e:	f5040513          	addi	a0,s0,-176
    80005832:	00000097          	auipc	ra,0x0
    80005836:	972080e7          	jalr	-1678(ra) # 800051a4 <create>
    8000583a:	892a                	mv	s2,a0
    if(ip == 0){
    8000583c:	c959                	beqz	a0,800058d2 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000583e:	04c91703          	lh	a4,76(s2)
    80005842:	478d                	li	a5,3
    80005844:	00f71763          	bne	a4,a5,80005852 <sys_open+0x74>
    80005848:	04e95703          	lhu	a4,78(s2)
    8000584c:	47a5                	li	a5,9
    8000584e:	0ce7ec63          	bltu	a5,a4,80005926 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	dfa080e7          	jalr	-518(ra) # 8000464c <filealloc>
    8000585a:	89aa                	mv	s3,a0
    8000585c:	10050663          	beqz	a0,80005968 <sys_open+0x18a>
    80005860:	00000097          	auipc	ra,0x0
    80005864:	902080e7          	jalr	-1790(ra) # 80005162 <fdalloc>
    80005868:	84aa                	mv	s1,a0
    8000586a:	0e054a63          	bltz	a0,8000595e <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000586e:	04c91703          	lh	a4,76(s2)
    80005872:	478d                	li	a5,3
    80005874:	0cf70463          	beq	a4,a5,8000593c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005878:	4789                	li	a5,2
    8000587a:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    8000587e:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005882:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005886:	f4c42783          	lw	a5,-180(s0)
    8000588a:	0017c713          	xori	a4,a5,1
    8000588e:	8b05                	andi	a4,a4,1
    80005890:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005894:	0037f713          	andi	a4,a5,3
    80005898:	00e03733          	snez	a4,a4
    8000589c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058a0:	4007f793          	andi	a5,a5,1024
    800058a4:	c791                	beqz	a5,800058b0 <sys_open+0xd2>
    800058a6:	04c91703          	lh	a4,76(s2)
    800058aa:	4789                	li	a5,2
    800058ac:	0af70363          	beq	a4,a5,80005952 <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    800058b0:	854a                	mv	a0,s2
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	08c080e7          	jalr	140(ra) # 8000393e <iunlock>
  end_op();
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	a04080e7          	jalr	-1532(ra) # 800042be <end_op>

  return fd;
}
    800058c2:	8526                	mv	a0,s1
    800058c4:	70ea                	ld	ra,184(sp)
    800058c6:	744a                	ld	s0,176(sp)
    800058c8:	74aa                	ld	s1,168(sp)
    800058ca:	790a                	ld	s2,160(sp)
    800058cc:	69ea                	ld	s3,152(sp)
    800058ce:	6129                	addi	sp,sp,192
    800058d0:	8082                	ret
      end_op();
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	9ec080e7          	jalr	-1556(ra) # 800042be <end_op>
      return -1;
    800058da:	b7e5                	j	800058c2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800058dc:	f5040513          	addi	a0,s0,-176
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	752080e7          	jalr	1874(ra) # 80004032 <namei>
    800058e8:	892a                	mv	s2,a0
    800058ea:	c905                	beqz	a0,8000591a <sys_open+0x13c>
    ilock(ip);
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	f90080e7          	jalr	-112(ra) # 8000387c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058f4:	04c91703          	lh	a4,76(s2)
    800058f8:	4785                	li	a5,1
    800058fa:	f4f712e3          	bne	a4,a5,8000583e <sys_open+0x60>
    800058fe:	f4c42783          	lw	a5,-180(s0)
    80005902:	dba1                	beqz	a5,80005852 <sys_open+0x74>
      iunlockput(ip);
    80005904:	854a                	mv	a0,s2
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	1d8080e7          	jalr	472(ra) # 80003ade <iunlockput>
      end_op();
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	9b0080e7          	jalr	-1616(ra) # 800042be <end_op>
      return -1;
    80005916:	54fd                	li	s1,-1
    80005918:	b76d                	j	800058c2 <sys_open+0xe4>
      end_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	9a4080e7          	jalr	-1628(ra) # 800042be <end_op>
      return -1;
    80005922:	54fd                	li	s1,-1
    80005924:	bf79                	j	800058c2 <sys_open+0xe4>
    iunlockput(ip);
    80005926:	854a                	mv	a0,s2
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	1b6080e7          	jalr	438(ra) # 80003ade <iunlockput>
    end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	98e080e7          	jalr	-1650(ra) # 800042be <end_op>
    return -1;
    80005938:	54fd                	li	s1,-1
    8000593a:	b761                	j	800058c2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000593c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005940:	04e91783          	lh	a5,78(s2)
    80005944:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005948:	05091783          	lh	a5,80(s2)
    8000594c:	02f99323          	sh	a5,38(s3)
    80005950:	b73d                	j	8000587e <sys_open+0xa0>
    itrunc(ip);
    80005952:	854a                	mv	a0,s2
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	036080e7          	jalr	54(ra) # 8000398a <itrunc>
    8000595c:	bf91                	j	800058b0 <sys_open+0xd2>
      fileclose(f);
    8000595e:	854e                	mv	a0,s3
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	da8080e7          	jalr	-600(ra) # 80004708 <fileclose>
    iunlockput(ip);
    80005968:	854a                	mv	a0,s2
    8000596a:	ffffe097          	auipc	ra,0xffffe
    8000596e:	174080e7          	jalr	372(ra) # 80003ade <iunlockput>
    end_op();
    80005972:	fffff097          	auipc	ra,0xfffff
    80005976:	94c080e7          	jalr	-1716(ra) # 800042be <end_op>
    return -1;
    8000597a:	54fd                	li	s1,-1
    8000597c:	b799                	j	800058c2 <sys_open+0xe4>

000000008000597e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000597e:	7175                	addi	sp,sp,-144
    80005980:	e506                	sd	ra,136(sp)
    80005982:	e122                	sd	s0,128(sp)
    80005984:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	8b8080e7          	jalr	-1864(ra) # 8000423e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000598e:	08000613          	li	a2,128
    80005992:	f7040593          	addi	a1,s0,-144
    80005996:	4501                	li	a0,0
    80005998:	ffffd097          	auipc	ra,0xffffd
    8000599c:	334080e7          	jalr	820(ra) # 80002ccc <argstr>
    800059a0:	02054963          	bltz	a0,800059d2 <sys_mkdir+0x54>
    800059a4:	4681                	li	a3,0
    800059a6:	4601                	li	a2,0
    800059a8:	4585                	li	a1,1
    800059aa:	f7040513          	addi	a0,s0,-144
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	7f6080e7          	jalr	2038(ra) # 800051a4 <create>
    800059b6:	cd11                	beqz	a0,800059d2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	126080e7          	jalr	294(ra) # 80003ade <iunlockput>
  end_op();
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	8fe080e7          	jalr	-1794(ra) # 800042be <end_op>
  return 0;
    800059c8:	4501                	li	a0,0
}
    800059ca:	60aa                	ld	ra,136(sp)
    800059cc:	640a                	ld	s0,128(sp)
    800059ce:	6149                	addi	sp,sp,144
    800059d0:	8082                	ret
    end_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	8ec080e7          	jalr	-1812(ra) # 800042be <end_op>
    return -1;
    800059da:	557d                	li	a0,-1
    800059dc:	b7fd                	j	800059ca <sys_mkdir+0x4c>

00000000800059de <sys_mknod>:

uint64
sys_mknod(void)
{
    800059de:	7135                	addi	sp,sp,-160
    800059e0:	ed06                	sd	ra,152(sp)
    800059e2:	e922                	sd	s0,144(sp)
    800059e4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	858080e7          	jalr	-1960(ra) # 8000423e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059ee:	08000613          	li	a2,128
    800059f2:	f7040593          	addi	a1,s0,-144
    800059f6:	4501                	li	a0,0
    800059f8:	ffffd097          	auipc	ra,0xffffd
    800059fc:	2d4080e7          	jalr	724(ra) # 80002ccc <argstr>
    80005a00:	04054a63          	bltz	a0,80005a54 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a04:	f6c40593          	addi	a1,s0,-148
    80005a08:	4505                	li	a0,1
    80005a0a:	ffffd097          	auipc	ra,0xffffd
    80005a0e:	27e080e7          	jalr	638(ra) # 80002c88 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a12:	04054163          	bltz	a0,80005a54 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a16:	f6840593          	addi	a1,s0,-152
    80005a1a:	4509                	li	a0,2
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	26c080e7          	jalr	620(ra) # 80002c88 <argint>
     argint(1, &major) < 0 ||
    80005a24:	02054863          	bltz	a0,80005a54 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a28:	f6841683          	lh	a3,-152(s0)
    80005a2c:	f6c41603          	lh	a2,-148(s0)
    80005a30:	458d                	li	a1,3
    80005a32:	f7040513          	addi	a0,s0,-144
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	76e080e7          	jalr	1902(ra) # 800051a4 <create>
     argint(2, &minor) < 0 ||
    80005a3e:	c919                	beqz	a0,80005a54 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	09e080e7          	jalr	158(ra) # 80003ade <iunlockput>
  end_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	876080e7          	jalr	-1930(ra) # 800042be <end_op>
  return 0;
    80005a50:	4501                	li	a0,0
    80005a52:	a031                	j	80005a5e <sys_mknod+0x80>
    end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	86a080e7          	jalr	-1942(ra) # 800042be <end_op>
    return -1;
    80005a5c:	557d                	li	a0,-1
}
    80005a5e:	60ea                	ld	ra,152(sp)
    80005a60:	644a                	ld	s0,144(sp)
    80005a62:	610d                	addi	sp,sp,160
    80005a64:	8082                	ret

0000000080005a66 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a66:	7135                	addi	sp,sp,-160
    80005a68:	ed06                	sd	ra,152(sp)
    80005a6a:	e922                	sd	s0,144(sp)
    80005a6c:	e526                	sd	s1,136(sp)
    80005a6e:	e14a                	sd	s2,128(sp)
    80005a70:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a72:	ffffc097          	auipc	ra,0xffffc
    80005a76:	0f6080e7          	jalr	246(ra) # 80001b68 <myproc>
    80005a7a:	892a                	mv	s2,a0
  
  begin_op();
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	7c2080e7          	jalr	1986(ra) # 8000423e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a84:	08000613          	li	a2,128
    80005a88:	f6040593          	addi	a1,s0,-160
    80005a8c:	4501                	li	a0,0
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	23e080e7          	jalr	574(ra) # 80002ccc <argstr>
    80005a96:	04054b63          	bltz	a0,80005aec <sys_chdir+0x86>
    80005a9a:	f6040513          	addi	a0,s0,-160
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	594080e7          	jalr	1428(ra) # 80004032 <namei>
    80005aa6:	84aa                	mv	s1,a0
    80005aa8:	c131                	beqz	a0,80005aec <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	dd2080e7          	jalr	-558(ra) # 8000387c <ilock>
  if(ip->type != T_DIR){
    80005ab2:	04c49703          	lh	a4,76(s1)
    80005ab6:	4785                	li	a5,1
    80005ab8:	04f71063          	bne	a4,a5,80005af8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005abc:	8526                	mv	a0,s1
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	e80080e7          	jalr	-384(ra) # 8000393e <iunlock>
  iput(p->cwd);
    80005ac6:	15893503          	ld	a0,344(s2)
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	f6c080e7          	jalr	-148(ra) # 80003a36 <iput>
  end_op();
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	7ec080e7          	jalr	2028(ra) # 800042be <end_op>
  p->cwd = ip;
    80005ada:	14993c23          	sd	s1,344(s2)
  return 0;
    80005ade:	4501                	li	a0,0
}
    80005ae0:	60ea                	ld	ra,152(sp)
    80005ae2:	644a                	ld	s0,144(sp)
    80005ae4:	64aa                	ld	s1,136(sp)
    80005ae6:	690a                	ld	s2,128(sp)
    80005ae8:	610d                	addi	sp,sp,160
    80005aea:	8082                	ret
    end_op();
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	7d2080e7          	jalr	2002(ra) # 800042be <end_op>
    return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	b7ed                	j	80005ae0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	fe4080e7          	jalr	-28(ra) # 80003ade <iunlockput>
    end_op();
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	7bc080e7          	jalr	1980(ra) # 800042be <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	bfd1                	j	80005ae0 <sys_chdir+0x7a>

0000000080005b0e <sys_exec>:

uint64
sys_exec(void)
{
    80005b0e:	7145                	addi	sp,sp,-464
    80005b10:	e786                	sd	ra,456(sp)
    80005b12:	e3a2                	sd	s0,448(sp)
    80005b14:	ff26                	sd	s1,440(sp)
    80005b16:	fb4a                	sd	s2,432(sp)
    80005b18:	f74e                	sd	s3,424(sp)
    80005b1a:	f352                	sd	s4,416(sp)
    80005b1c:	ef56                	sd	s5,408(sp)
    80005b1e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b20:	08000613          	li	a2,128
    80005b24:	f4040593          	addi	a1,s0,-192
    80005b28:	4501                	li	a0,0
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	1a2080e7          	jalr	418(ra) # 80002ccc <argstr>
    return -1;
    80005b32:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b34:	0c054a63          	bltz	a0,80005c08 <sys_exec+0xfa>
    80005b38:	e3840593          	addi	a1,s0,-456
    80005b3c:	4505                	li	a0,1
    80005b3e:	ffffd097          	auipc	ra,0xffffd
    80005b42:	16c080e7          	jalr	364(ra) # 80002caa <argaddr>
    80005b46:	0c054163          	bltz	a0,80005c08 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b4a:	10000613          	li	a2,256
    80005b4e:	4581                	li	a1,0
    80005b50:	e4040513          	addi	a0,s0,-448
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	32c080e7          	jalr	812(ra) # 80000e80 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b5c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b60:	89a6                	mv	s3,s1
    80005b62:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b64:	02000a13          	li	s4,32
    80005b68:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b6c:	00391513          	slli	a0,s2,0x3
    80005b70:	e3040593          	addi	a1,s0,-464
    80005b74:	e3843783          	ld	a5,-456(s0)
    80005b78:	953e                	add	a0,a0,a5
    80005b7a:	ffffd097          	auipc	ra,0xffffd
    80005b7e:	074080e7          	jalr	116(ra) # 80002bee <fetchaddr>
    80005b82:	02054a63          	bltz	a0,80005bb6 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b86:	e3043783          	ld	a5,-464(s0)
    80005b8a:	c3b9                	beqz	a5,80005bd0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b8c:	ffffb097          	auipc	ra,0xffffb
    80005b90:	ec0080e7          	jalr	-320(ra) # 80000a4c <kalloc>
    80005b94:	85aa                	mv	a1,a0
    80005b96:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b9a:	cd11                	beqz	a0,80005bb6 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b9c:	6605                	lui	a2,0x1
    80005b9e:	e3043503          	ld	a0,-464(s0)
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	09e080e7          	jalr	158(ra) # 80002c40 <fetchstr>
    80005baa:	00054663          	bltz	a0,80005bb6 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005bae:	0905                	addi	s2,s2,1
    80005bb0:	09a1                	addi	s3,s3,8
    80005bb2:	fb491be3          	bne	s2,s4,80005b68 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb6:	10048913          	addi	s2,s1,256
    80005bba:	6088                	ld	a0,0(s1)
    80005bbc:	c529                	beqz	a0,80005c06 <sys_exec+0xf8>
    kfree(argv[i]);
    80005bbe:	ffffb097          	auipc	ra,0xffffb
    80005bc2:	d88080e7          	jalr	-632(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc6:	04a1                	addi	s1,s1,8
    80005bc8:	ff2499e3          	bne	s1,s2,80005bba <sys_exec+0xac>
  return -1;
    80005bcc:	597d                	li	s2,-1
    80005bce:	a82d                	j	80005c08 <sys_exec+0xfa>
      argv[i] = 0;
    80005bd0:	0a8e                	slli	s5,s5,0x3
    80005bd2:	fc040793          	addi	a5,s0,-64
    80005bd6:	9abe                	add	s5,s5,a5
    80005bd8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005bdc:	e4040593          	addi	a1,s0,-448
    80005be0:	f4040513          	addi	a0,s0,-192
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	18c080e7          	jalr	396(ra) # 80004d70 <exec>
    80005bec:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bee:	10048993          	addi	s3,s1,256
    80005bf2:	6088                	ld	a0,0(s1)
    80005bf4:	c911                	beqz	a0,80005c08 <sys_exec+0xfa>
    kfree(argv[i]);
    80005bf6:	ffffb097          	auipc	ra,0xffffb
    80005bfa:	d50080e7          	jalr	-688(ra) # 80000946 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bfe:	04a1                	addi	s1,s1,8
    80005c00:	ff3499e3          	bne	s1,s3,80005bf2 <sys_exec+0xe4>
    80005c04:	a011                	j	80005c08 <sys_exec+0xfa>
  return -1;
    80005c06:	597d                	li	s2,-1
}
    80005c08:	854a                	mv	a0,s2
    80005c0a:	60be                	ld	ra,456(sp)
    80005c0c:	641e                	ld	s0,448(sp)
    80005c0e:	74fa                	ld	s1,440(sp)
    80005c10:	795a                	ld	s2,432(sp)
    80005c12:	79ba                	ld	s3,424(sp)
    80005c14:	7a1a                	ld	s4,416(sp)
    80005c16:	6afa                	ld	s5,408(sp)
    80005c18:	6179                	addi	sp,sp,464
    80005c1a:	8082                	ret

0000000080005c1c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c1c:	7139                	addi	sp,sp,-64
    80005c1e:	fc06                	sd	ra,56(sp)
    80005c20:	f822                	sd	s0,48(sp)
    80005c22:	f426                	sd	s1,40(sp)
    80005c24:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c26:	ffffc097          	auipc	ra,0xffffc
    80005c2a:	f42080e7          	jalr	-190(ra) # 80001b68 <myproc>
    80005c2e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c30:	fd840593          	addi	a1,s0,-40
    80005c34:	4501                	li	a0,0
    80005c36:	ffffd097          	auipc	ra,0xffffd
    80005c3a:	074080e7          	jalr	116(ra) # 80002caa <argaddr>
    return -1;
    80005c3e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c40:	0e054063          	bltz	a0,80005d20 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c44:	fc840593          	addi	a1,s0,-56
    80005c48:	fd040513          	addi	a0,s0,-48
    80005c4c:	fffff097          	auipc	ra,0xfffff
    80005c50:	df4080e7          	jalr	-524(ra) # 80004a40 <pipealloc>
    return -1;
    80005c54:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c56:	0c054563          	bltz	a0,80005d20 <sys_pipe+0x104>
  fd0 = -1;
    80005c5a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c5e:	fd043503          	ld	a0,-48(s0)
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	500080e7          	jalr	1280(ra) # 80005162 <fdalloc>
    80005c6a:	fca42223          	sw	a0,-60(s0)
    80005c6e:	08054c63          	bltz	a0,80005d06 <sys_pipe+0xea>
    80005c72:	fc843503          	ld	a0,-56(s0)
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	4ec080e7          	jalr	1260(ra) # 80005162 <fdalloc>
    80005c7e:	fca42023          	sw	a0,-64(s0)
    80005c82:	06054863          	bltz	a0,80005cf2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c86:	4691                	li	a3,4
    80005c88:	fc440613          	addi	a2,s0,-60
    80005c8c:	fd843583          	ld	a1,-40(s0)
    80005c90:	6ca8                	ld	a0,88(s1)
    80005c92:	ffffc097          	auipc	ra,0xffffc
    80005c96:	b90080e7          	jalr	-1136(ra) # 80001822 <copyout>
    80005c9a:	02054063          	bltz	a0,80005cba <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c9e:	4691                	li	a3,4
    80005ca0:	fc040613          	addi	a2,s0,-64
    80005ca4:	fd843583          	ld	a1,-40(s0)
    80005ca8:	0591                	addi	a1,a1,4
    80005caa:	6ca8                	ld	a0,88(s1)
    80005cac:	ffffc097          	auipc	ra,0xffffc
    80005cb0:	b76080e7          	jalr	-1162(ra) # 80001822 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cb4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cb6:	06055563          	bgez	a0,80005d20 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005cba:	fc442783          	lw	a5,-60(s0)
    80005cbe:	07e9                	addi	a5,a5,26
    80005cc0:	078e                	slli	a5,a5,0x3
    80005cc2:	97a6                	add	a5,a5,s1
    80005cc4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005cc8:	fc042503          	lw	a0,-64(s0)
    80005ccc:	0569                	addi	a0,a0,26
    80005cce:	050e                	slli	a0,a0,0x3
    80005cd0:	9526                	add	a0,a0,s1
    80005cd2:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005cd6:	fd043503          	ld	a0,-48(s0)
    80005cda:	fffff097          	auipc	ra,0xfffff
    80005cde:	a2e080e7          	jalr	-1490(ra) # 80004708 <fileclose>
    fileclose(wf);
    80005ce2:	fc843503          	ld	a0,-56(s0)
    80005ce6:	fffff097          	auipc	ra,0xfffff
    80005cea:	a22080e7          	jalr	-1502(ra) # 80004708 <fileclose>
    return -1;
    80005cee:	57fd                	li	a5,-1
    80005cf0:	a805                	j	80005d20 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005cf2:	fc442783          	lw	a5,-60(s0)
    80005cf6:	0007c863          	bltz	a5,80005d06 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cfa:	01a78513          	addi	a0,a5,26
    80005cfe:	050e                	slli	a0,a0,0x3
    80005d00:	9526                	add	a0,a0,s1
    80005d02:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005d06:	fd043503          	ld	a0,-48(s0)
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	9fe080e7          	jalr	-1538(ra) # 80004708 <fileclose>
    fileclose(wf);
    80005d12:	fc843503          	ld	a0,-56(s0)
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	9f2080e7          	jalr	-1550(ra) # 80004708 <fileclose>
    return -1;
    80005d1e:	57fd                	li	a5,-1
}
    80005d20:	853e                	mv	a0,a5
    80005d22:	70e2                	ld	ra,56(sp)
    80005d24:	7442                	ld	s0,48(sp)
    80005d26:	74a2                	ld	s1,40(sp)
    80005d28:	6121                	addi	sp,sp,64
    80005d2a:	8082                	ret
    80005d2c:	0000                	unimp
	...

0000000080005d30 <kernelvec>:
    80005d30:	7111                	addi	sp,sp,-256
    80005d32:	e006                	sd	ra,0(sp)
    80005d34:	e40a                	sd	sp,8(sp)
    80005d36:	e80e                	sd	gp,16(sp)
    80005d38:	ec12                	sd	tp,24(sp)
    80005d3a:	f016                	sd	t0,32(sp)
    80005d3c:	f41a                	sd	t1,40(sp)
    80005d3e:	f81e                	sd	t2,48(sp)
    80005d40:	fc22                	sd	s0,56(sp)
    80005d42:	e0a6                	sd	s1,64(sp)
    80005d44:	e4aa                	sd	a0,72(sp)
    80005d46:	e8ae                	sd	a1,80(sp)
    80005d48:	ecb2                	sd	a2,88(sp)
    80005d4a:	f0b6                	sd	a3,96(sp)
    80005d4c:	f4ba                	sd	a4,104(sp)
    80005d4e:	f8be                	sd	a5,112(sp)
    80005d50:	fcc2                	sd	a6,120(sp)
    80005d52:	e146                	sd	a7,128(sp)
    80005d54:	e54a                	sd	s2,136(sp)
    80005d56:	e94e                	sd	s3,144(sp)
    80005d58:	ed52                	sd	s4,152(sp)
    80005d5a:	f156                	sd	s5,160(sp)
    80005d5c:	f55a                	sd	s6,168(sp)
    80005d5e:	f95e                	sd	s7,176(sp)
    80005d60:	fd62                	sd	s8,184(sp)
    80005d62:	e1e6                	sd	s9,192(sp)
    80005d64:	e5ea                	sd	s10,200(sp)
    80005d66:	e9ee                	sd	s11,208(sp)
    80005d68:	edf2                	sd	t3,216(sp)
    80005d6a:	f1f6                	sd	t4,224(sp)
    80005d6c:	f5fa                	sd	t5,232(sp)
    80005d6e:	f9fe                	sd	t6,240(sp)
    80005d70:	d3ffc0ef          	jal	ra,80002aae <kerneltrap>
    80005d74:	6082                	ld	ra,0(sp)
    80005d76:	6122                	ld	sp,8(sp)
    80005d78:	61c2                	ld	gp,16(sp)
    80005d7a:	7282                	ld	t0,32(sp)
    80005d7c:	7322                	ld	t1,40(sp)
    80005d7e:	73c2                	ld	t2,48(sp)
    80005d80:	7462                	ld	s0,56(sp)
    80005d82:	6486                	ld	s1,64(sp)
    80005d84:	6526                	ld	a0,72(sp)
    80005d86:	65c6                	ld	a1,80(sp)
    80005d88:	6666                	ld	a2,88(sp)
    80005d8a:	7686                	ld	a3,96(sp)
    80005d8c:	7726                	ld	a4,104(sp)
    80005d8e:	77c6                	ld	a5,112(sp)
    80005d90:	7866                	ld	a6,120(sp)
    80005d92:	688a                	ld	a7,128(sp)
    80005d94:	692a                	ld	s2,136(sp)
    80005d96:	69ca                	ld	s3,144(sp)
    80005d98:	6a6a                	ld	s4,152(sp)
    80005d9a:	7a8a                	ld	s5,160(sp)
    80005d9c:	7b2a                	ld	s6,168(sp)
    80005d9e:	7bca                	ld	s7,176(sp)
    80005da0:	7c6a                	ld	s8,184(sp)
    80005da2:	6c8e                	ld	s9,192(sp)
    80005da4:	6d2e                	ld	s10,200(sp)
    80005da6:	6dce                	ld	s11,208(sp)
    80005da8:	6e6e                	ld	t3,216(sp)
    80005daa:	7e8e                	ld	t4,224(sp)
    80005dac:	7f2e                	ld	t5,232(sp)
    80005dae:	7fce                	ld	t6,240(sp)
    80005db0:	6111                	addi	sp,sp,256
    80005db2:	10200073          	sret
    80005db6:	00000013          	nop
    80005dba:	00000013          	nop
    80005dbe:	0001                	nop

0000000080005dc0 <timervec>:
    80005dc0:	34051573          	csrrw	a0,mscratch,a0
    80005dc4:	e10c                	sd	a1,0(a0)
    80005dc6:	e510                	sd	a2,8(a0)
    80005dc8:	e914                	sd	a3,16(a0)
    80005dca:	6d0c                	ld	a1,24(a0)
    80005dcc:	7110                	ld	a2,32(a0)
    80005dce:	6194                	ld	a3,0(a1)
    80005dd0:	96b2                	add	a3,a3,a2
    80005dd2:	e194                	sd	a3,0(a1)
    80005dd4:	4589                	li	a1,2
    80005dd6:	14459073          	csrw	sip,a1
    80005dda:	6914                	ld	a3,16(a0)
    80005ddc:	6510                	ld	a2,8(a0)
    80005dde:	610c                	ld	a1,0(a0)
    80005de0:	34051573          	csrrw	a0,mscratch,a0
    80005de4:	30200073          	mret
	...

0000000080005dea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dea:	1141                	addi	sp,sp,-16
    80005dec:	e422                	sd	s0,8(sp)
    80005dee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005df0:	0c0007b7          	lui	a5,0xc000
    80005df4:	4705                	li	a4,1
    80005df6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005df8:	c3d8                	sw	a4,4(a5)
}
    80005dfa:	6422                	ld	s0,8(sp)
    80005dfc:	0141                	addi	sp,sp,16
    80005dfe:	8082                	ret

0000000080005e00 <plicinithart>:

void
plicinithart(void)
{
    80005e00:	1141                	addi	sp,sp,-16
    80005e02:	e406                	sd	ra,8(sp)
    80005e04:	e022                	sd	s0,0(sp)
    80005e06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	d34080e7          	jalr	-716(ra) # 80001b3c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e10:	0085171b          	slliw	a4,a0,0x8
    80005e14:	0c0027b7          	lui	a5,0xc002
    80005e18:	97ba                	add	a5,a5,a4
    80005e1a:	40200713          	li	a4,1026
    80005e1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e22:	00d5151b          	slliw	a0,a0,0xd
    80005e26:	0c2017b7          	lui	a5,0xc201
    80005e2a:	953e                	add	a0,a0,a5
    80005e2c:	00052023          	sw	zero,0(a0)
}
    80005e30:	60a2                	ld	ra,8(sp)
    80005e32:	6402                	ld	s0,0(sp)
    80005e34:	0141                	addi	sp,sp,16
    80005e36:	8082                	ret

0000000080005e38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e38:	1141                	addi	sp,sp,-16
    80005e3a:	e406                	sd	ra,8(sp)
    80005e3c:	e022                	sd	s0,0(sp)
    80005e3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	cfc080e7          	jalr	-772(ra) # 80001b3c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e48:	00d5179b          	slliw	a5,a0,0xd
    80005e4c:	0c201537          	lui	a0,0xc201
    80005e50:	953e                	add	a0,a0,a5
  return irq;
}
    80005e52:	4148                	lw	a0,4(a0)
    80005e54:	60a2                	ld	ra,8(sp)
    80005e56:	6402                	ld	s0,0(sp)
    80005e58:	0141                	addi	sp,sp,16
    80005e5a:	8082                	ret

0000000080005e5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e5c:	1101                	addi	sp,sp,-32
    80005e5e:	ec06                	sd	ra,24(sp)
    80005e60:	e822                	sd	s0,16(sp)
    80005e62:	e426                	sd	s1,8(sp)
    80005e64:	1000                	addi	s0,sp,32
    80005e66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	cd4080e7          	jalr	-812(ra) # 80001b3c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e70:	00d5151b          	slliw	a0,a0,0xd
    80005e74:	0c2017b7          	lui	a5,0xc201
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	c3c4                	sw	s1,4(a5)
}
    80005e7c:	60e2                	ld	ra,24(sp)
    80005e7e:	6442                	ld	s0,16(sp)
    80005e80:	64a2                	ld	s1,8(sp)
    80005e82:	6105                	addi	sp,sp,32
    80005e84:	8082                	ret

0000000080005e86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e86:	1141                	addi	sp,sp,-16
    80005e88:	e406                	sd	ra,8(sp)
    80005e8a:	e022                	sd	s0,0(sp)
    80005e8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e8e:	479d                	li	a5,7
    80005e90:	04a7c463          	blt	a5,a0,80005ed8 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005e94:	00032797          	auipc	a5,0x32
    80005e98:	85478793          	addi	a5,a5,-1964 # 800376e8 <disk>
    80005e9c:	97aa                	add	a5,a5,a0
    80005e9e:	0187c783          	lbu	a5,24(a5)
    80005ea2:	e3b9                	bnez	a5,80005ee8 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005ea4:	00032797          	auipc	a5,0x32
    80005ea8:	84478793          	addi	a5,a5,-1980 # 800376e8 <disk>
    80005eac:	6398                	ld	a4,0(a5)
    80005eae:	00451693          	slli	a3,a0,0x4
    80005eb2:	9736                	add	a4,a4,a3
    80005eb4:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005eb8:	953e                	add	a0,a0,a5
    80005eba:	4785                	li	a5,1
    80005ebc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005ec0:	00032517          	auipc	a0,0x32
    80005ec4:	84050513          	addi	a0,a0,-1984 # 80037700 <disk+0x18>
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	5f4080e7          	jalr	1524(ra) # 800024bc <wakeup>
}
    80005ed0:	60a2                	ld	ra,8(sp)
    80005ed2:	6402                	ld	s0,0(sp)
    80005ed4:	0141                	addi	sp,sp,16
    80005ed6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ed8:	00004517          	auipc	a0,0x4
    80005edc:	db050513          	addi	a0,a0,-592 # 80009c88 <syscalls+0x358>
    80005ee0:	ffffa097          	auipc	ra,0xffffa
    80005ee4:	68a080e7          	jalr	1674(ra) # 8000056a <panic>
    panic("virtio_disk_intr 2");
    80005ee8:	00004517          	auipc	a0,0x4
    80005eec:	db850513          	addi	a0,a0,-584 # 80009ca0 <syscalls+0x370>
    80005ef0:	ffffa097          	auipc	ra,0xffffa
    80005ef4:	67a080e7          	jalr	1658(ra) # 8000056a <panic>

0000000080005ef8 <virtio_disk_init>:
{
    80005ef8:	1101                	addi	sp,sp,-32
    80005efa:	ec06                	sd	ra,24(sp)
    80005efc:	e822                	sd	s0,16(sp)
    80005efe:	e426                	sd	s1,8(sp)
    80005f00:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f02:	00031497          	auipc	s1,0x31
    80005f06:	7e648493          	addi	s1,s1,2022 # 800376e8 <disk>
    80005f0a:	00004597          	auipc	a1,0x4
    80005f0e:	dae58593          	addi	a1,a1,-594 # 80009cb8 <syscalls+0x388>
    80005f12:	00032517          	auipc	a0,0x32
    80005f16:	8fe50513          	addi	a0,a0,-1794 # 80037810 <disk+0x128>
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	bac080e7          	jalr	-1108(ra) # 80000ac6 <initlock>
  disk.desc = kalloc();
    80005f22:	ffffb097          	auipc	ra,0xffffb
    80005f26:	b2a080e7          	jalr	-1238(ra) # 80000a4c <kalloc>
    80005f2a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f2c:	ffffb097          	auipc	ra,0xffffb
    80005f30:	b20080e7          	jalr	-1248(ra) # 80000a4c <kalloc>
    80005f34:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f36:	ffffb097          	auipc	ra,0xffffb
    80005f3a:	b16080e7          	jalr	-1258(ra) # 80000a4c <kalloc>
    80005f3e:	87aa                	mv	a5,a0
    80005f40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f42:	6088                	ld	a0,0(s1)
    80005f44:	14050263          	beqz	a0,80006088 <virtio_disk_init+0x190>
    80005f48:	00031717          	auipc	a4,0x31
    80005f4c:	7a873703          	ld	a4,1960(a4) # 800376f0 <disk+0x8>
    80005f50:	12070c63          	beqz	a4,80006088 <virtio_disk_init+0x190>
    80005f54:	12078a63          	beqz	a5,80006088 <virtio_disk_init+0x190>
  memset(disk.desc, 0, PGSIZE);
    80005f58:	6605                	lui	a2,0x1
    80005f5a:	4581                	li	a1,0
    80005f5c:	ffffb097          	auipc	ra,0xffffb
    80005f60:	f24080e7          	jalr	-220(ra) # 80000e80 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f64:	00031497          	auipc	s1,0x31
    80005f68:	78448493          	addi	s1,s1,1924 # 800376e8 <disk>
    80005f6c:	6605                	lui	a2,0x1
    80005f6e:	4581                	li	a1,0
    80005f70:	6488                	ld	a0,8(s1)
    80005f72:	ffffb097          	auipc	ra,0xffffb
    80005f76:	f0e080e7          	jalr	-242(ra) # 80000e80 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f7a:	6605                	lui	a2,0x1
    80005f7c:	4581                	li	a1,0
    80005f7e:	6888                	ld	a0,16(s1)
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	f00080e7          	jalr	-256(ra) # 80000e80 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f88:	100017b7          	lui	a5,0x10001
    80005f8c:	4398                	lw	a4,0(a5)
    80005f8e:	2701                	sext.w	a4,a4
    80005f90:	747277b7          	lui	a5,0x74727
    80005f94:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f98:	10f71063          	bne	a4,a5,80006098 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f9c:	100017b7          	lui	a5,0x10001
    80005fa0:	43dc                	lw	a5,4(a5)
    80005fa2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fa4:	4709                	li	a4,2
    80005fa6:	0ee79963          	bne	a5,a4,80006098 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005faa:	100017b7          	lui	a5,0x10001
    80005fae:	479c                	lw	a5,8(a5)
    80005fb0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fb2:	0ee79363          	bne	a5,a4,80006098 <virtio_disk_init+0x1a0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fb6:	100017b7          	lui	a5,0x10001
    80005fba:	47d8                	lw	a4,12(a5)
    80005fbc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fbe:	554d47b7          	lui	a5,0x554d4
    80005fc2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005fc6:	0cf71963          	bne	a4,a5,80006098 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fca:	100017b7          	lui	a5,0x10001
    80005fce:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fd2:	4705                	li	a4,1
    80005fd4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fd6:	470d                	li	a4,3
    80005fd8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fda:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fdc:	c7ffe737          	lui	a4,0xc7ffe
    80005fe0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc6ea7>
    80005fe4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fe6:	2701                	sext.w	a4,a4
    80005fe8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fea:	472d                	li	a4,11
    80005fec:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005fee:	5bb0                	lw	a2,112(a5)
    80005ff0:	2601                	sext.w	a2,a2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ff2:	00867793          	andi	a5,a2,8
    80005ff6:	cbcd                	beqz	a5,800060a8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ff8:	100017b7          	lui	a5,0x10001
    80005ffc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006000:	43fc                	lw	a5,68(a5)
    80006002:	2781                	sext.w	a5,a5
    80006004:	ebd5                	bnez	a5,800060b8 <virtio_disk_init+0x1c0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006006:	100017b7          	lui	a5,0x10001
    8000600a:	5bdc                	lw	a5,52(a5)
    8000600c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000600e:	cfcd                	beqz	a5,800060c8 <virtio_disk_init+0x1d0>
  if(max < NUM)
    80006010:	471d                	li	a4,7
    80006012:	0cf77363          	bgeu	a4,a5,800060d8 <virtio_disk_init+0x1e0>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006016:	10001737          	lui	a4,0x10001
    8000601a:	47a1                	li	a5,8
    8000601c:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    8000601e:	00031797          	auipc	a5,0x31
    80006022:	6ca78793          	addi	a5,a5,1738 # 800376e8 <disk>
    80006026:	4394                	lw	a3,0(a5)
    80006028:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    8000602c:	43d4                	lw	a3,4(a5)
    8000602e:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    80006032:	6794                	ld	a3,8(a5)
    80006034:	0006859b          	sext.w	a1,a3
    80006038:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000603c:	9681                	srai	a3,a3,0x20
    8000603e:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    80006042:	6b94                	ld	a3,16(a5)
    80006044:	0006859b          	sext.w	a1,a3
    80006048:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000604c:	9681                	srai	a3,a3,0x20
    8000604e:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006052:	4585                	li	a1,1
    80006054:	c36c                	sw	a1,68(a4)
    disk.free[i] = 1;
    80006056:	4685                	li	a3,1
    80006058:	00b78c23          	sb	a1,24(a5)
    8000605c:	00d78ca3          	sb	a3,25(a5)
    80006060:	00d78d23          	sb	a3,26(a5)
    80006064:	00d78da3          	sb	a3,27(a5)
    80006068:	00d78e23          	sb	a3,28(a5)
    8000606c:	00d78ea3          	sb	a3,29(a5)
    80006070:	00d78f23          	sb	a3,30(a5)
    80006074:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006078:	00466613          	ori	a2,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607c:	db30                	sw	a2,112(a4)
}
    8000607e:	60e2                	ld	ra,24(sp)
    80006080:	6442                	ld	s0,16(sp)
    80006082:	64a2                	ld	s1,8(sp)
    80006084:	6105                	addi	sp,sp,32
    80006086:	8082                	ret
    panic("virtio disk kalloc");
    80006088:	00004517          	auipc	a0,0x4
    8000608c:	c4050513          	addi	a0,a0,-960 # 80009cc8 <syscalls+0x398>
    80006090:	ffffa097          	auipc	ra,0xffffa
    80006094:	4da080e7          	jalr	1242(ra) # 8000056a <panic>
    panic("could not find virtio disk");
    80006098:	00004517          	auipc	a0,0x4
    8000609c:	c4850513          	addi	a0,a0,-952 # 80009ce0 <syscalls+0x3b0>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	4ca080e7          	jalr	1226(ra) # 8000056a <panic>
    panic("virtio disk FEATURES_OK unset");
    800060a8:	00004517          	auipc	a0,0x4
    800060ac:	c5850513          	addi	a0,a0,-936 # 80009d00 <syscalls+0x3d0>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	4ba080e7          	jalr	1210(ra) # 8000056a <panic>
    panic("virtio disk ready not zero");
    800060b8:	00004517          	auipc	a0,0x4
    800060bc:	c6850513          	addi	a0,a0,-920 # 80009d20 <syscalls+0x3f0>
    800060c0:	ffffa097          	auipc	ra,0xffffa
    800060c4:	4aa080e7          	jalr	1194(ra) # 8000056a <panic>
    panic("virtio disk has no queue 0");
    800060c8:	00004517          	auipc	a0,0x4
    800060cc:	c7850513          	addi	a0,a0,-904 # 80009d40 <syscalls+0x410>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	49a080e7          	jalr	1178(ra) # 8000056a <panic>
    panic("virtio disk max queue too short");
    800060d8:	00004517          	auipc	a0,0x4
    800060dc:	c8850513          	addi	a0,a0,-888 # 80009d60 <syscalls+0x430>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	48a080e7          	jalr	1162(ra) # 8000056a <panic>

00000000800060e8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060e8:	7159                	addi	sp,sp,-112
    800060ea:	f486                	sd	ra,104(sp)
    800060ec:	f0a2                	sd	s0,96(sp)
    800060ee:	eca6                	sd	s1,88(sp)
    800060f0:	e8ca                	sd	s2,80(sp)
    800060f2:	e4ce                	sd	s3,72(sp)
    800060f4:	e0d2                	sd	s4,64(sp)
    800060f6:	fc56                	sd	s5,56(sp)
    800060f8:	f85a                	sd	s6,48(sp)
    800060fa:	f45e                	sd	s7,40(sp)
    800060fc:	f062                	sd	s8,32(sp)
    800060fe:	ec66                	sd	s9,24(sp)
    80006100:	e86a                	sd	s10,16(sp)
    80006102:	1880                	addi	s0,sp,112
    80006104:	892a                	mv	s2,a0
    80006106:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006108:	00c52c83          	lw	s9,12(a0)
    8000610c:	001c9c9b          	slliw	s9,s9,0x1
    80006110:	1c82                	slli	s9,s9,0x20
    80006112:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006116:	00031517          	auipc	a0,0x31
    8000611a:	6fa50513          	addi	a0,a0,1786 # 80037810 <disk+0x128>
    8000611e:	ffffb097          	auipc	ra,0xffffb
    80006122:	a7e080e7          	jalr	-1410(ra) # 80000b9c <acquire>
  for(int i = 0; i < 3; i++){
    80006126:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006128:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000612a:	00031b17          	auipc	s6,0x31
    8000612e:	5beb0b13          	addi	s6,s6,1470 # 800376e8 <disk>
  for(int i = 0; i < 3; i++){
    80006132:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006134:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006136:	00031c17          	auipc	s8,0x31
    8000613a:	6dac0c13          	addi	s8,s8,1754 # 80037810 <disk+0x128>
    8000613e:	a8b5                	j	800061ba <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006140:	00fb06b3          	add	a3,s6,a5
    80006144:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006148:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000614a:	0207c563          	bltz	a5,80006174 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000614e:	2485                	addiw	s1,s1,1
    80006150:	0711                	addi	a4,a4,4
    80006152:	1f548763          	beq	s1,s5,80006340 <virtio_disk_rw+0x258>
    idx[i] = alloc_desc();
    80006156:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006158:	00031697          	auipc	a3,0x31
    8000615c:	59068693          	addi	a3,a3,1424 # 800376e8 <disk>
    80006160:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006162:	0186c583          	lbu	a1,24(a3)
    80006166:	fde9                	bnez	a1,80006140 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006168:	2785                	addiw	a5,a5,1
    8000616a:	0685                	addi	a3,a3,1
    8000616c:	ff779be3          	bne	a5,s7,80006162 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006170:	57fd                	li	a5,-1
    80006172:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006174:	02905a63          	blez	s1,800061a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006178:	f9042503          	lw	a0,-112(s0)
    8000617c:	00000097          	auipc	ra,0x0
    80006180:	d0a080e7          	jalr	-758(ra) # 80005e86 <free_desc>
      for(int j = 0; j < i; j++)
    80006184:	4785                	li	a5,1
    80006186:	0297d163          	bge	a5,s1,800061a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000618a:	f9442503          	lw	a0,-108(s0)
    8000618e:	00000097          	auipc	ra,0x0
    80006192:	cf8080e7          	jalr	-776(ra) # 80005e86 <free_desc>
      for(int j = 0; j < i; j++)
    80006196:	4789                	li	a5,2
    80006198:	0097d863          	bge	a5,s1,800061a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000619c:	f9842503          	lw	a0,-104(s0)
    800061a0:	00000097          	auipc	ra,0x0
    800061a4:	ce6080e7          	jalr	-794(ra) # 80005e86 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061a8:	85e2                	mv	a1,s8
    800061aa:	00031517          	auipc	a0,0x31
    800061ae:	55650513          	addi	a0,a0,1366 # 80037700 <disk+0x18>
    800061b2:	ffffc097          	auipc	ra,0xffffc
    800061b6:	184080e7          	jalr	388(ra) # 80002336 <sleep>
  for(int i = 0; i < 3; i++){
    800061ba:	f9040713          	addi	a4,s0,-112
    800061be:	84ce                	mv	s1,s3
    800061c0:	bf59                	j	80006156 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800061c2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800061c6:	00479693          	slli	a3,a5,0x4
    800061ca:	00031797          	auipc	a5,0x31
    800061ce:	51e78793          	addi	a5,a5,1310 # 800376e8 <disk>
    800061d2:	97b6                	add	a5,a5,a3
    800061d4:	4685                	li	a3,1
    800061d6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061d8:	00031597          	auipc	a1,0x31
    800061dc:	51058593          	addi	a1,a1,1296 # 800376e8 <disk>
    800061e0:	00a60793          	addi	a5,a2,10
    800061e4:	0792                	slli	a5,a5,0x4
    800061e6:	97ae                	add	a5,a5,a1
    800061e8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800061ec:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800061f0:	f6070693          	addi	a3,a4,-160
    800061f4:	619c                	ld	a5,0(a1)
    800061f6:	97b6                	add	a5,a5,a3
    800061f8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061fa:	6188                	ld	a0,0(a1)
    800061fc:	96aa                	add	a3,a3,a0
    800061fe:	47c1                	li	a5,16
    80006200:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    80006202:	4785                	li	a5,1
    80006204:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006208:	f9442783          	lw	a5,-108(s0)
    8000620c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006210:	0792                	slli	a5,a5,0x4
    80006212:	953e                	add	a0,a0,a5
    80006214:	06090693          	addi	a3,s2,96
    80006218:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000621a:	6188                	ld	a0,0(a1)
    8000621c:	97aa                	add	a5,a5,a0
    8000621e:	40000693          	li	a3,1024
    80006222:	c794                	sw	a3,8(a5)
  if(write)
    80006224:	0e0d0463          	beqz	s10,8000630c <virtio_disk_rw+0x224>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006228:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    8000622c:	00c7d683          	lhu	a3,12(a5)
    80006230:	0016e693          	ori	a3,a3,1
    80006234:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006238:	f9842583          	lw	a1,-104(s0)
    8000623c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0;
    80006240:	00031697          	auipc	a3,0x31
    80006244:	4a868693          	addi	a3,a3,1192 # 800376e8 <disk>
    80006248:	00260793          	addi	a5,a2,2
    8000624c:	0792                	slli	a5,a5,0x4
    8000624e:	97b6                	add	a5,a5,a3
    80006250:	00078823          	sb	zero,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006254:	0592                	slli	a1,a1,0x4
    80006256:	952e                	add	a0,a0,a1
    80006258:	f9070713          	addi	a4,a4,-112
    8000625c:	9736                	add	a4,a4,a3
    8000625e:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006260:	6298                	ld	a4,0(a3)
    80006262:	972e                	add	a4,a4,a1
    80006264:	4585                	li	a1,1
    80006266:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    80006268:	4509                	li	a0,2
    8000626a:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    8000626e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006272:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006276:	0127b423          	sd	s2,8(a5)

  // avail->idx tells the device how far to look in avail->ring.
  // avail->ring[...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000627a:	6698                	ld	a4,8(a3)
    8000627c:	00275783          	lhu	a5,2(a4)
    80006280:	8b9d                	andi	a5,a5,7
    80006282:	0786                	slli	a5,a5,0x1
    80006284:	97ba                	add	a5,a5,a4
    80006286:	00c79223          	sh	a2,4(a5)
  __sync_synchronize();
    8000628a:	0ff0000f          	fence
  disk.avail->idx += 1;
    8000628e:	6698                	ld	a4,8(a3)
    80006290:	00275783          	lhu	a5,2(a4)
    80006294:	2785                	addiw	a5,a5,1
    80006296:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000629a:	100017b7          	lui	a5,0x10001
    8000629e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062a2:	00492703          	lw	a4,4(s2)
    800062a6:	4785                	li	a5,1
    800062a8:	02f71163          	bne	a4,a5,800062ca <virtio_disk_rw+0x1e2>
    sleep(b, &disk.vdisk_lock);
    800062ac:	00031997          	auipc	s3,0x31
    800062b0:	56498993          	addi	s3,s3,1380 # 80037810 <disk+0x128>
  while(b->disk == 1) {
    800062b4:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062b6:	85ce                	mv	a1,s3
    800062b8:	854a                	mv	a0,s2
    800062ba:	ffffc097          	auipc	ra,0xffffc
    800062be:	07c080e7          	jalr	124(ra) # 80002336 <sleep>
  while(b->disk == 1) {
    800062c2:	00492783          	lw	a5,4(s2)
    800062c6:	fe9788e3          	beq	a5,s1,800062b6 <virtio_disk_rw+0x1ce>
  }

  disk.info[idx[0]].b = 0;
    800062ca:	f9042483          	lw	s1,-112(s0)
    800062ce:	00248793          	addi	a5,s1,2
    800062d2:	00479713          	slli	a4,a5,0x4
    800062d6:	00031797          	auipc	a5,0x31
    800062da:	41278793          	addi	a5,a5,1042 # 800376e8 <disk>
    800062de:	97ba                	add	a5,a5,a4
    800062e0:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800062e4:	00031917          	auipc	s2,0x31
    800062e8:	40490913          	addi	s2,s2,1028 # 800376e8 <disk>
    free_desc(i);
    800062ec:	8526                	mv	a0,s1
    800062ee:	00000097          	auipc	ra,0x0
    800062f2:	b98080e7          	jalr	-1128(ra) # 80005e86 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800062f6:	0492                	slli	s1,s1,0x4
    800062f8:	00093783          	ld	a5,0(s2)
    800062fc:	94be                	add	s1,s1,a5
    800062fe:	00c4d783          	lhu	a5,12(s1)
    80006302:	8b85                	andi	a5,a5,1
    80006304:	cb81                	beqz	a5,80006314 <virtio_disk_rw+0x22c>
      i = disk.desc[i].next;
    80006306:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000630a:	b7cd                	j	800062ec <virtio_disk_rw+0x204>
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    8000630c:	4689                	li	a3,2
    8000630e:	00d79623          	sh	a3,12(a5)
    80006312:	bf29                	j	8000622c <virtio_disk_rw+0x144>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006314:	00031517          	auipc	a0,0x31
    80006318:	4fc50513          	addi	a0,a0,1276 # 80037810 <disk+0x128>
    8000631c:	ffffb097          	auipc	ra,0xffffb
    80006320:	950080e7          	jalr	-1712(ra) # 80000c6c <release>
}
    80006324:	70a6                	ld	ra,104(sp)
    80006326:	7406                	ld	s0,96(sp)
    80006328:	64e6                	ld	s1,88(sp)
    8000632a:	6946                	ld	s2,80(sp)
    8000632c:	69a6                	ld	s3,72(sp)
    8000632e:	6a06                	ld	s4,64(sp)
    80006330:	7ae2                	ld	s5,56(sp)
    80006332:	7b42                	ld	s6,48(sp)
    80006334:	7ba2                	ld	s7,40(sp)
    80006336:	7c02                	ld	s8,32(sp)
    80006338:	6ce2                	ld	s9,24(sp)
    8000633a:	6d42                	ld	s10,16(sp)
    8000633c:	6165                	addi	sp,sp,112
    8000633e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006340:	f9042603          	lw	a2,-112(s0)
    80006344:	00a60713          	addi	a4,a2,10
    80006348:	0712                	slli	a4,a4,0x4
    8000634a:	00031517          	auipc	a0,0x31
    8000634e:	3a650513          	addi	a0,a0,934 # 800376f0 <disk+0x8>
    80006352:	953a                	add	a0,a0,a4
  if(write)
    80006354:	e60d17e3          	bnez	s10,800061c2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006358:	00a60793          	addi	a5,a2,10
    8000635c:	00479693          	slli	a3,a5,0x4
    80006360:	00031797          	auipc	a5,0x31
    80006364:	38878793          	addi	a5,a5,904 # 800376e8 <disk>
    80006368:	97b6                	add	a5,a5,a3
    8000636a:	0007a423          	sw	zero,8(a5)
    8000636e:	b5ad                	j	800061d8 <virtio_disk_rw+0xf0>

0000000080006370 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    80006370:	1101                	addi	sp,sp,-32
    80006372:	ec06                	sd	ra,24(sp)
    80006374:	e822                	sd	s0,16(sp)
    80006376:	e426                	sd	s1,8(sp)
    80006378:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000637a:	00031497          	auipc	s1,0x31
    8000637e:	36e48493          	addi	s1,s1,878 # 800376e8 <disk>
    80006382:	00031517          	auipc	a0,0x31
    80006386:	48e50513          	addi	a0,a0,1166 # 80037810 <disk+0x128>
    8000638a:	ffffb097          	auipc	ra,0xffffb
    8000638e:	812080e7          	jalr	-2030(ra) # 80000b9c <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006392:	0204d783          	lhu	a5,32(s1)
    80006396:	6898                	ld	a4,16(s1)
    80006398:	00275683          	lhu	a3,2(a4)
    8000639c:	8ebd                	xor	a3,a3,a5
    8000639e:	8a9d                	andi	a3,a3,7
    800063a0:	c2b1                	beqz	a3,800063e4 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    800063a2:	078e                	slli	a5,a5,0x3
    800063a4:	97ba                	add	a5,a5,a4
    800063a6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063a8:	00278713          	addi	a4,a5,2
    800063ac:	0712                	slli	a4,a4,0x4
    800063ae:	9726                	add	a4,a4,s1
    800063b0:	01074703          	lbu	a4,16(a4)
    800063b4:	eb31                	bnez	a4,80006408 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    800063b6:	0789                	addi	a5,a5,2
    800063b8:	0792                	slli	a5,a5,0x4
    800063ba:	97a6                	add	a5,a5,s1
    800063bc:	6798                	ld	a4,8(a5)
    800063be:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800063c2:	6788                	ld	a0,8(a5)
    800063c4:	ffffc097          	auipc	ra,0xffffc
    800063c8:	0f8080e7          	jalr	248(ra) # 800024bc <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063cc:	0204d783          	lhu	a5,32(s1)
    800063d0:	2785                	addiw	a5,a5,1
    800063d2:	8b9d                	andi	a5,a5,7
    800063d4:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    800063d8:	6898                	ld	a4,16(s1)
    800063da:	00275683          	lhu	a3,2(a4)
    800063de:	8a9d                	andi	a3,a3,7
    800063e0:	fcf691e3          	bne	a3,a5,800063a2 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063e4:	10001737          	lui	a4,0x10001
    800063e8:	533c                	lw	a5,96(a4)
    800063ea:	8b8d                	andi	a5,a5,3
    800063ec:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800063ee:	00031517          	auipc	a0,0x31
    800063f2:	42250513          	addi	a0,a0,1058 # 80037810 <disk+0x128>
    800063f6:	ffffb097          	auipc	ra,0xffffb
    800063fa:	876080e7          	jalr	-1930(ra) # 80000c6c <release>
}
    800063fe:	60e2                	ld	ra,24(sp)
    80006400:	6442                	ld	s0,16(sp)
    80006402:	64a2                	ld	s1,8(sp)
    80006404:	6105                	addi	sp,sp,32
    80006406:	8082                	ret
      panic("virtio_disk_intr status");
    80006408:	00004517          	auipc	a0,0x4
    8000640c:	97850513          	addi	a0,a0,-1672 # 80009d80 <syscalls+0x450>
    80006410:	ffffa097          	auipc	ra,0xffffa
    80006414:	15a080e7          	jalr	346(ra) # 8000056a <panic>

0000000080006418 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006418:	1141                	addi	sp,sp,-16
    8000641a:	e422                	sd	s0,8(sp)
    8000641c:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000641e:	41f5d79b          	sraiw	a5,a1,0x1f
    80006422:	01d7d79b          	srliw	a5,a5,0x1d
    80006426:	9dbd                	addw	a1,a1,a5
    80006428:	0075f713          	andi	a4,a1,7
    8000642c:	9f1d                	subw	a4,a4,a5
    8000642e:	4785                	li	a5,1
    80006430:	00e797bb          	sllw	a5,a5,a4
    80006434:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006438:	4035d59b          	sraiw	a1,a1,0x3
    8000643c:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    8000643e:	0005c503          	lbu	a0,0(a1)
    80006442:	8d7d                	and	a0,a0,a5
    80006444:	8d1d                	sub	a0,a0,a5
}
    80006446:	00153513          	seqz	a0,a0
    8000644a:	6422                	ld	s0,8(sp)
    8000644c:	0141                	addi	sp,sp,16
    8000644e:	8082                	ret

0000000080006450 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006450:	1141                	addi	sp,sp,-16
    80006452:	e422                	sd	s0,8(sp)
    80006454:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006456:	41f5d79b          	sraiw	a5,a1,0x1f
    8000645a:	01d7d79b          	srliw	a5,a5,0x1d
    8000645e:	9dbd                	addw	a1,a1,a5
    80006460:	4035d71b          	sraiw	a4,a1,0x3
    80006464:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006466:	899d                	andi	a1,a1,7
    80006468:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    8000646a:	4785                	li	a5,1
    8000646c:	00b795bb          	sllw	a1,a5,a1
    80006470:	00054783          	lbu	a5,0(a0)
    80006474:	8ddd                	or	a1,a1,a5
    80006476:	00b50023          	sb	a1,0(a0)
}
    8000647a:	6422                	ld	s0,8(sp)
    8000647c:	0141                	addi	sp,sp,16
    8000647e:	8082                	ret

0000000080006480 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006480:	1141                	addi	sp,sp,-16
    80006482:	e422                	sd	s0,8(sp)
    80006484:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006486:	41f5d79b          	sraiw	a5,a1,0x1f
    8000648a:	01d7d79b          	srliw	a5,a5,0x1d
    8000648e:	9dbd                	addw	a1,a1,a5
    80006490:	4035d71b          	sraiw	a4,a1,0x3
    80006494:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006496:	899d                	andi	a1,a1,7
    80006498:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    8000649a:	4785                	li	a5,1
    8000649c:	00b795bb          	sllw	a1,a5,a1
    800064a0:	fff5c593          	not	a1,a1
    800064a4:	00054783          	lbu	a5,0(a0)
    800064a8:	8dfd                	and	a1,a1,a5
    800064aa:	00b50023          	sb	a1,0(a0)
}
    800064ae:	6422                	ld	s0,8(sp)
    800064b0:	0141                	addi	sp,sp,16
    800064b2:	8082                	ret

00000000800064b4 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800064b4:	715d                	addi	sp,sp,-80
    800064b6:	e486                	sd	ra,72(sp)
    800064b8:	e0a2                	sd	s0,64(sp)
    800064ba:	fc26                	sd	s1,56(sp)
    800064bc:	f84a                	sd	s2,48(sp)
    800064be:	f44e                	sd	s3,40(sp)
    800064c0:	f052                	sd	s4,32(sp)
    800064c2:	ec56                	sd	s5,24(sp)
    800064c4:	e85a                	sd	s6,16(sp)
    800064c6:	e45e                	sd	s7,8(sp)
    800064c8:	0880                	addi	s0,sp,80
    800064ca:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    800064cc:	08b05b63          	blez	a1,80006562 <bd_print_vector+0xae>
    800064d0:	89aa                	mv	s3,a0
    800064d2:	4481                	li	s1,0
  lb = 0;
    800064d4:	4a81                	li	s5,0
  last = 1;
    800064d6:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    800064d8:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    800064da:	00004b97          	auipc	s7,0x4
    800064de:	8beb8b93          	addi	s7,s7,-1858 # 80009d98 <syscalls+0x468>
    800064e2:	a01d                	j	80006508 <bd_print_vector+0x54>
    800064e4:	8626                	mv	a2,s1
    800064e6:	85d6                	mv	a1,s5
    800064e8:	855e                	mv	a0,s7
    800064ea:	ffffa097          	auipc	ra,0xffffa
    800064ee:	0e2080e7          	jalr	226(ra) # 800005cc <printf>
    lb = b;
    last = bit_isset(vector, b);
    800064f2:	85a6                	mv	a1,s1
    800064f4:	854e                	mv	a0,s3
    800064f6:	00000097          	auipc	ra,0x0
    800064fa:	f22080e7          	jalr	-222(ra) # 80006418 <bit_isset>
    800064fe:	892a                	mv	s2,a0
    80006500:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006502:	2485                	addiw	s1,s1,1
    80006504:	009a0d63          	beq	s4,s1,8000651e <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006508:	85a6                	mv	a1,s1
    8000650a:	854e                	mv	a0,s3
    8000650c:	00000097          	auipc	ra,0x0
    80006510:	f0c080e7          	jalr	-244(ra) # 80006418 <bit_isset>
    80006514:	ff2507e3          	beq	a0,s2,80006502 <bd_print_vector+0x4e>
    if(last == 1)
    80006518:	fd691de3          	bne	s2,s6,800064f2 <bd_print_vector+0x3e>
    8000651c:	b7e1                	j	800064e4 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000651e:	000a8563          	beqz	s5,80006528 <bd_print_vector+0x74>
    80006522:	4785                	li	a5,1
    80006524:	00f91c63          	bne	s2,a5,8000653c <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006528:	8652                	mv	a2,s4
    8000652a:	85d6                	mv	a1,s5
    8000652c:	00004517          	auipc	a0,0x4
    80006530:	86c50513          	addi	a0,a0,-1940 # 80009d98 <syscalls+0x468>
    80006534:	ffffa097          	auipc	ra,0xffffa
    80006538:	098080e7          	jalr	152(ra) # 800005cc <printf>
  }
  printf("\n");
    8000653c:	00003517          	auipc	a0,0x3
    80006540:	cc450513          	addi	a0,a0,-828 # 80009200 <digits+0x90>
    80006544:	ffffa097          	auipc	ra,0xffffa
    80006548:	088080e7          	jalr	136(ra) # 800005cc <printf>
}
    8000654c:	60a6                	ld	ra,72(sp)
    8000654e:	6406                	ld	s0,64(sp)
    80006550:	74e2                	ld	s1,56(sp)
    80006552:	7942                	ld	s2,48(sp)
    80006554:	79a2                	ld	s3,40(sp)
    80006556:	7a02                	ld	s4,32(sp)
    80006558:	6ae2                	ld	s5,24(sp)
    8000655a:	6b42                	ld	s6,16(sp)
    8000655c:	6ba2                	ld	s7,8(sp)
    8000655e:	6161                	addi	sp,sp,80
    80006560:	8082                	ret
  lb = 0;
    80006562:	4a81                	li	s5,0
    80006564:	b7d1                	j	80006528 <bd_print_vector+0x74>

0000000080006566 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006566:	00004697          	auipc	a3,0x4
    8000656a:	f126a683          	lw	a3,-238(a3) # 8000a478 <nsizes>
    8000656e:	10d05063          	blez	a3,8000666e <bd_print+0x108>
bd_print() {
    80006572:	711d                	addi	sp,sp,-96
    80006574:	ec86                	sd	ra,88(sp)
    80006576:	e8a2                	sd	s0,80(sp)
    80006578:	e4a6                	sd	s1,72(sp)
    8000657a:	e0ca                	sd	s2,64(sp)
    8000657c:	fc4e                	sd	s3,56(sp)
    8000657e:	f852                	sd	s4,48(sp)
    80006580:	f456                	sd	s5,40(sp)
    80006582:	f05a                	sd	s6,32(sp)
    80006584:	ec5e                	sd	s7,24(sp)
    80006586:	e862                	sd	s8,16(sp)
    80006588:	e466                	sd	s9,8(sp)
    8000658a:	e06a                	sd	s10,0(sp)
    8000658c:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000658e:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006590:	4a85                	li	s5,1
    80006592:	4c41                	li	s8,16
    80006594:	00004b97          	auipc	s7,0x4
    80006598:	814b8b93          	addi	s7,s7,-2028 # 80009da8 <syscalls+0x478>
    lst_print(&bd_sizes[k].free);
    8000659c:	00004a17          	auipc	s4,0x4
    800065a0:	ed4a0a13          	addi	s4,s4,-300 # 8000a470 <bd_sizes>
    printf("  alloc:");
    800065a4:	00004b17          	auipc	s6,0x4
    800065a8:	82cb0b13          	addi	s6,s6,-2004 # 80009dd0 <syscalls+0x4a0>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800065ac:	00004997          	auipc	s3,0x4
    800065b0:	ecc98993          	addi	s3,s3,-308 # 8000a478 <nsizes>
    if(k > 0) {
      printf("  split:");
    800065b4:	00004c97          	auipc	s9,0x4
    800065b8:	82cc8c93          	addi	s9,s9,-2004 # 80009de0 <syscalls+0x4b0>
    800065bc:	a801                	j	800065cc <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    800065be:	0009a683          	lw	a3,0(s3)
    800065c2:	0485                	addi	s1,s1,1
    800065c4:	0004879b          	sext.w	a5,s1
    800065c8:	08d7d563          	bge	a5,a3,80006652 <bd_print+0xec>
    800065cc:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800065d0:	36fd                	addiw	a3,a3,-1
    800065d2:	9e85                	subw	a3,a3,s1
    800065d4:	00da96bb          	sllw	a3,s5,a3
    800065d8:	009c1633          	sll	a2,s8,s1
    800065dc:	85ca                	mv	a1,s2
    800065de:	855e                	mv	a0,s7
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	fec080e7          	jalr	-20(ra) # 800005cc <printf>
    lst_print(&bd_sizes[k].free);
    800065e8:	00549d13          	slli	s10,s1,0x5
    800065ec:	000a3503          	ld	a0,0(s4)
    800065f0:	956a                	add	a0,a0,s10
    800065f2:	00001097          	auipc	ra,0x1
    800065f6:	a4e080e7          	jalr	-1458(ra) # 80007040 <lst_print>
    printf("  alloc:");
    800065fa:	855a                	mv	a0,s6
    800065fc:	ffffa097          	auipc	ra,0xffffa
    80006600:	fd0080e7          	jalr	-48(ra) # 800005cc <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006604:	0009a583          	lw	a1,0(s3)
    80006608:	35fd                	addiw	a1,a1,-1
    8000660a:	412585bb          	subw	a1,a1,s2
    8000660e:	000a3783          	ld	a5,0(s4)
    80006612:	97ea                	add	a5,a5,s10
    80006614:	00ba95bb          	sllw	a1,s5,a1
    80006618:	6b88                	ld	a0,16(a5)
    8000661a:	00000097          	auipc	ra,0x0
    8000661e:	e9a080e7          	jalr	-358(ra) # 800064b4 <bd_print_vector>
    if(k > 0) {
    80006622:	f9205ee3          	blez	s2,800065be <bd_print+0x58>
      printf("  split:");
    80006626:	8566                	mv	a0,s9
    80006628:	ffffa097          	auipc	ra,0xffffa
    8000662c:	fa4080e7          	jalr	-92(ra) # 800005cc <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006630:	0009a583          	lw	a1,0(s3)
    80006634:	35fd                	addiw	a1,a1,-1
    80006636:	412585bb          	subw	a1,a1,s2
    8000663a:	000a3783          	ld	a5,0(s4)
    8000663e:	9d3e                	add	s10,s10,a5
    80006640:	00ba95bb          	sllw	a1,s5,a1
    80006644:	018d3503          	ld	a0,24(s10)
    80006648:	00000097          	auipc	ra,0x0
    8000664c:	e6c080e7          	jalr	-404(ra) # 800064b4 <bd_print_vector>
    80006650:	b7bd                	j	800065be <bd_print+0x58>
    }
  }
}
    80006652:	60e6                	ld	ra,88(sp)
    80006654:	6446                	ld	s0,80(sp)
    80006656:	64a6                	ld	s1,72(sp)
    80006658:	6906                	ld	s2,64(sp)
    8000665a:	79e2                	ld	s3,56(sp)
    8000665c:	7a42                	ld	s4,48(sp)
    8000665e:	7aa2                	ld	s5,40(sp)
    80006660:	7b02                	ld	s6,32(sp)
    80006662:	6be2                	ld	s7,24(sp)
    80006664:	6c42                	ld	s8,16(sp)
    80006666:	6ca2                	ld	s9,8(sp)
    80006668:	6d02                	ld	s10,0(sp)
    8000666a:	6125                	addi	sp,sp,96
    8000666c:	8082                	ret
    8000666e:	8082                	ret

0000000080006670 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006670:	1141                	addi	sp,sp,-16
    80006672:	e422                	sd	s0,8(sp)
    80006674:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006676:	47c1                	li	a5,16
    80006678:	00a7fb63          	bgeu	a5,a0,8000668e <firstk+0x1e>
    8000667c:	872a                	mv	a4,a0
  int k = 0;
    8000667e:	4501                	li	a0,0
    k++;
    80006680:	2505                	addiw	a0,a0,1
    size *= 2;
    80006682:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006684:	fee7eee3          	bltu	a5,a4,80006680 <firstk+0x10>
  }
  return k;
}
    80006688:	6422                	ld	s0,8(sp)
    8000668a:	0141                	addi	sp,sp,16
    8000668c:	8082                	ret
  int k = 0;
    8000668e:	4501                	li	a0,0
    80006690:	bfe5                	j	80006688 <firstk+0x18>

0000000080006692 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006692:	1141                	addi	sp,sp,-16
    80006694:	e422                	sd	s0,8(sp)
    80006696:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006698:	00004797          	auipc	a5,0x4
    8000669c:	dd07b783          	ld	a5,-560(a5) # 8000a468 <bd_base>
    800066a0:	9d9d                	subw	a1,a1,a5
    800066a2:	47c1                	li	a5,16
    800066a4:	00a79533          	sll	a0,a5,a0
    800066a8:	02a5c533          	div	a0,a1,a0
}
    800066ac:	2501                	sext.w	a0,a0
    800066ae:	6422                	ld	s0,8(sp)
    800066b0:	0141                	addi	sp,sp,16
    800066b2:	8082                	ret

00000000800066b4 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800066b4:	1141                	addi	sp,sp,-16
    800066b6:	e422                	sd	s0,8(sp)
    800066b8:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800066ba:	47c1                	li	a5,16
    800066bc:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    800066c0:	02b787bb          	mulw	a5,a5,a1
}
    800066c4:	00004517          	auipc	a0,0x4
    800066c8:	da453503          	ld	a0,-604(a0) # 8000a468 <bd_base>
    800066cc:	953e                	add	a0,a0,a5
    800066ce:	6422                	ld	s0,8(sp)
    800066d0:	0141                	addi	sp,sp,16
    800066d2:	8082                	ret

00000000800066d4 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    800066d4:	7159                	addi	sp,sp,-112
    800066d6:	f486                	sd	ra,104(sp)
    800066d8:	f0a2                	sd	s0,96(sp)
    800066da:	eca6                	sd	s1,88(sp)
    800066dc:	e8ca                	sd	s2,80(sp)
    800066de:	e4ce                	sd	s3,72(sp)
    800066e0:	e0d2                	sd	s4,64(sp)
    800066e2:	fc56                	sd	s5,56(sp)
    800066e4:	f85a                	sd	s6,48(sp)
    800066e6:	f45e                	sd	s7,40(sp)
    800066e8:	f062                	sd	s8,32(sp)
    800066ea:	ec66                	sd	s9,24(sp)
    800066ec:	e86a                	sd	s10,16(sp)
    800066ee:	e46e                	sd	s11,8(sp)
    800066f0:	1880                	addi	s0,sp,112
    800066f2:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800066f4:	00031517          	auipc	a0,0x31
    800066f8:	13c50513          	addi	a0,a0,316 # 80037830 <lock>
    800066fc:	ffffa097          	auipc	ra,0xffffa
    80006700:	4a0080e7          	jalr	1184(ra) # 80000b9c <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006704:	8526                	mv	a0,s1
    80006706:	00000097          	auipc	ra,0x0
    8000670a:	f6a080e7          	jalr	-150(ra) # 80006670 <firstk>
  for (k = fk; k < nsizes; k++) {
    8000670e:	00004797          	auipc	a5,0x4
    80006712:	d6a7a783          	lw	a5,-662(a5) # 8000a478 <nsizes>
    80006716:	02f55d63          	bge	a0,a5,80006750 <bd_malloc+0x7c>
    8000671a:	8c2a                	mv	s8,a0
    8000671c:	00551913          	slli	s2,a0,0x5
    80006720:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006722:	00004997          	auipc	s3,0x4
    80006726:	d4e98993          	addi	s3,s3,-690 # 8000a470 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000672a:	00004a17          	auipc	s4,0x4
    8000672e:	d4ea0a13          	addi	s4,s4,-690 # 8000a478 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006732:	0009b503          	ld	a0,0(s3)
    80006736:	954a                	add	a0,a0,s2
    80006738:	00001097          	auipc	ra,0x1
    8000673c:	88e080e7          	jalr	-1906(ra) # 80006fc6 <lst_empty>
    80006740:	c115                	beqz	a0,80006764 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006742:	2485                	addiw	s1,s1,1
    80006744:	02090913          	addi	s2,s2,32
    80006748:	000a2783          	lw	a5,0(s4)
    8000674c:	fef4c3e3          	blt	s1,a5,80006732 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006750:	00031517          	auipc	a0,0x31
    80006754:	0e050513          	addi	a0,a0,224 # 80037830 <lock>
    80006758:	ffffa097          	auipc	ra,0xffffa
    8000675c:	514080e7          	jalr	1300(ra) # 80000c6c <release>
    return 0;
    80006760:	4b01                	li	s6,0
    80006762:	a0e1                	j	8000682a <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006764:	00004797          	auipc	a5,0x4
    80006768:	d147a783          	lw	a5,-748(a5) # 8000a478 <nsizes>
    8000676c:	fef4d2e3          	bge	s1,a5,80006750 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006770:	00549993          	slli	s3,s1,0x5
    80006774:	00004917          	auipc	s2,0x4
    80006778:	cfc90913          	addi	s2,s2,-772 # 8000a470 <bd_sizes>
    8000677c:	00093503          	ld	a0,0(s2)
    80006780:	954e                	add	a0,a0,s3
    80006782:	00001097          	auipc	ra,0x1
    80006786:	870080e7          	jalr	-1936(ra) # 80006ff2 <lst_pop>
    8000678a:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    8000678c:	00004597          	auipc	a1,0x4
    80006790:	cdc5b583          	ld	a1,-804(a1) # 8000a468 <bd_base>
    80006794:	40b505bb          	subw	a1,a0,a1
    80006798:	47c1                	li	a5,16
    8000679a:	009797b3          	sll	a5,a5,s1
    8000679e:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800067a2:	00093783          	ld	a5,0(s2)
    800067a6:	97ce                	add	a5,a5,s3
    800067a8:	2581                	sext.w	a1,a1
    800067aa:	6b88                	ld	a0,16(a5)
    800067ac:	00000097          	auipc	ra,0x0
    800067b0:	ca4080e7          	jalr	-860(ra) # 80006450 <bit_set>
  for(; k > fk; k--) {
    800067b4:	069c5363          	bge	s8,s1,8000681a <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800067b8:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800067ba:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800067bc:	00004d17          	auipc	s10,0x4
    800067c0:	cacd0d13          	addi	s10,s10,-852 # 8000a468 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800067c4:	85a6                	mv	a1,s1
    800067c6:	34fd                	addiw	s1,s1,-1
    800067c8:	009b9ab3          	sll	s5,s7,s1
    800067cc:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800067d0:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    800067d4:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    800067d8:	412b093b          	subw	s2,s6,s2
    800067dc:	00bb95b3          	sll	a1,s7,a1
    800067e0:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800067e4:	013a07b3          	add	a5,s4,s3
    800067e8:	2581                	sext.w	a1,a1
    800067ea:	6f88                	ld	a0,24(a5)
    800067ec:	00000097          	auipc	ra,0x0
    800067f0:	c64080e7          	jalr	-924(ra) # 80006450 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800067f4:	1981                	addi	s3,s3,-32
    800067f6:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800067f8:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800067fc:	2581                	sext.w	a1,a1
    800067fe:	010a3503          	ld	a0,16(s4)
    80006802:	00000097          	auipc	ra,0x0
    80006806:	c4e080e7          	jalr	-946(ra) # 80006450 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000680a:	85e6                	mv	a1,s9
    8000680c:	8552                	mv	a0,s4
    8000680e:	00001097          	auipc	ra,0x1
    80006812:	81a080e7          	jalr	-2022(ra) # 80007028 <lst_push>
  for(; k > fk; k--) {
    80006816:	fb8497e3          	bne	s1,s8,800067c4 <bd_malloc+0xf0>
  }
  release(&lock);
    8000681a:	00031517          	auipc	a0,0x31
    8000681e:	01650513          	addi	a0,a0,22 # 80037830 <lock>
    80006822:	ffffa097          	auipc	ra,0xffffa
    80006826:	44a080e7          	jalr	1098(ra) # 80000c6c <release>

  return p;
}
    8000682a:	855a                	mv	a0,s6
    8000682c:	70a6                	ld	ra,104(sp)
    8000682e:	7406                	ld	s0,96(sp)
    80006830:	64e6                	ld	s1,88(sp)
    80006832:	6946                	ld	s2,80(sp)
    80006834:	69a6                	ld	s3,72(sp)
    80006836:	6a06                	ld	s4,64(sp)
    80006838:	7ae2                	ld	s5,56(sp)
    8000683a:	7b42                	ld	s6,48(sp)
    8000683c:	7ba2                	ld	s7,40(sp)
    8000683e:	7c02                	ld	s8,32(sp)
    80006840:	6ce2                	ld	s9,24(sp)
    80006842:	6d42                	ld	s10,16(sp)
    80006844:	6da2                	ld	s11,8(sp)
    80006846:	6165                	addi	sp,sp,112
    80006848:	8082                	ret

000000008000684a <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000684a:	7139                	addi	sp,sp,-64
    8000684c:	fc06                	sd	ra,56(sp)
    8000684e:	f822                	sd	s0,48(sp)
    80006850:	f426                	sd	s1,40(sp)
    80006852:	f04a                	sd	s2,32(sp)
    80006854:	ec4e                	sd	s3,24(sp)
    80006856:	e852                	sd	s4,16(sp)
    80006858:	e456                	sd	s5,8(sp)
    8000685a:	e05a                	sd	s6,0(sp)
    8000685c:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    8000685e:	00004a97          	auipc	s5,0x4
    80006862:	c1aaaa83          	lw	s5,-998(s5) # 8000a478 <nsizes>
  return n / BLK_SIZE(k);
    80006866:	00004a17          	auipc	s4,0x4
    8000686a:	c02a3a03          	ld	s4,-1022(s4) # 8000a468 <bd_base>
    8000686e:	41450a3b          	subw	s4,a0,s4
    80006872:	00004497          	auipc	s1,0x4
    80006876:	bfe4b483          	ld	s1,-1026(s1) # 8000a470 <bd_sizes>
    8000687a:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000687e:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006880:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006882:	03595363          	bge	s2,s5,800068a8 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006886:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    8000688a:	013b15b3          	sll	a1,s6,s3
    8000688e:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006892:	2581                	sext.w	a1,a1
    80006894:	6088                	ld	a0,0(s1)
    80006896:	00000097          	auipc	ra,0x0
    8000689a:	b82080e7          	jalr	-1150(ra) # 80006418 <bit_isset>
    8000689e:	02048493          	addi	s1,s1,32
    800068a2:	e501                	bnez	a0,800068aa <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800068a4:	894e                	mv	s2,s3
    800068a6:	bff1                	j	80006882 <size+0x38>
      return k;
    }
  }
  return 0;
    800068a8:	4901                	li	s2,0
}
    800068aa:	854a                	mv	a0,s2
    800068ac:	70e2                	ld	ra,56(sp)
    800068ae:	7442                	ld	s0,48(sp)
    800068b0:	74a2                	ld	s1,40(sp)
    800068b2:	7902                	ld	s2,32(sp)
    800068b4:	69e2                	ld	s3,24(sp)
    800068b6:	6a42                	ld	s4,16(sp)
    800068b8:	6aa2                	ld	s5,8(sp)
    800068ba:	6b02                	ld	s6,0(sp)
    800068bc:	6121                	addi	sp,sp,64
    800068be:	8082                	ret

00000000800068c0 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800068c0:	7159                	addi	sp,sp,-112
    800068c2:	f486                	sd	ra,104(sp)
    800068c4:	f0a2                	sd	s0,96(sp)
    800068c6:	eca6                	sd	s1,88(sp)
    800068c8:	e8ca                	sd	s2,80(sp)
    800068ca:	e4ce                	sd	s3,72(sp)
    800068cc:	e0d2                	sd	s4,64(sp)
    800068ce:	fc56                	sd	s5,56(sp)
    800068d0:	f85a                	sd	s6,48(sp)
    800068d2:	f45e                	sd	s7,40(sp)
    800068d4:	f062                	sd	s8,32(sp)
    800068d6:	ec66                	sd	s9,24(sp)
    800068d8:	e86a                	sd	s10,16(sp)
    800068da:	e46e                	sd	s11,8(sp)
    800068dc:	1880                	addi	s0,sp,112
    800068de:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    800068e0:	00031517          	auipc	a0,0x31
    800068e4:	f5050513          	addi	a0,a0,-176 # 80037830 <lock>
    800068e8:	ffffa097          	auipc	ra,0xffffa
    800068ec:	2b4080e7          	jalr	692(ra) # 80000b9c <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800068f0:	8556                	mv	a0,s5
    800068f2:	00000097          	auipc	ra,0x0
    800068f6:	f58080e7          	jalr	-168(ra) # 8000684a <size>
    800068fa:	84aa                	mv	s1,a0
    800068fc:	00004797          	auipc	a5,0x4
    80006900:	b7c7a783          	lw	a5,-1156(a5) # 8000a478 <nsizes>
    80006904:	37fd                	addiw	a5,a5,-1
    80006906:	0af55d63          	bge	a0,a5,800069c0 <bd_free+0x100>
    8000690a:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    8000690e:	00004c17          	auipc	s8,0x4
    80006912:	b5ac0c13          	addi	s8,s8,-1190 # 8000a468 <bd_base>
  return n / BLK_SIZE(k);
    80006916:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006918:	00004b17          	auipc	s6,0x4
    8000691c:	b58b0b13          	addi	s6,s6,-1192 # 8000a470 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006920:	00004c97          	auipc	s9,0x4
    80006924:	b58c8c93          	addi	s9,s9,-1192 # 8000a478 <nsizes>
    80006928:	a82d                	j	80006962 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000692a:	fff58d9b          	addiw	s11,a1,-1
    8000692e:	a881                	j	8000697e <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006930:	020a0a13          	addi	s4,s4,32
    80006934:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006936:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    8000693a:	40ba85bb          	subw	a1,s5,a1
    8000693e:	009b97b3          	sll	a5,s7,s1
    80006942:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006946:	000b3783          	ld	a5,0(s6)
    8000694a:	97d2                	add	a5,a5,s4
    8000694c:	2581                	sext.w	a1,a1
    8000694e:	6f88                	ld	a0,24(a5)
    80006950:	00000097          	auipc	ra,0x0
    80006954:	b30080e7          	jalr	-1232(ra) # 80006480 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006958:	000ca783          	lw	a5,0(s9)
    8000695c:	37fd                	addiw	a5,a5,-1
    8000695e:	06f4d163          	bge	s1,a5,800069c0 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80006962:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006966:	009b99b3          	sll	s3,s7,s1
    8000696a:	412a87bb          	subw	a5,s5,s2
    8000696e:	0337c7b3          	div	a5,a5,s3
    80006972:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006976:	8b85                	andi	a5,a5,1
    80006978:	fbcd                	bnez	a5,8000692a <bd_free+0x6a>
    8000697a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000697e:	000b3d03          	ld	s10,0(s6)
    80006982:	9d52                	add	s10,s10,s4
    80006984:	010d3503          	ld	a0,16(s10)
    80006988:	00000097          	auipc	ra,0x0
    8000698c:	af8080e7          	jalr	-1288(ra) # 80006480 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006990:	85ee                	mv	a1,s11
    80006992:	010d3503          	ld	a0,16(s10)
    80006996:	00000097          	auipc	ra,0x0
    8000699a:	a82080e7          	jalr	-1406(ra) # 80006418 <bit_isset>
    8000699e:	e10d                	bnez	a0,800069c0 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    800069a0:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    800069a4:	03b989bb          	mulw	s3,s3,s11
    800069a8:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    800069aa:	854a                	mv	a0,s2
    800069ac:	00000097          	auipc	ra,0x0
    800069b0:	630080e7          	jalr	1584(ra) # 80006fdc <lst_remove>
    if(buddy % 2 == 0) {
    800069b4:	001d7d13          	andi	s10,s10,1
    800069b8:	f60d1ce3          	bnez	s10,80006930 <bd_free+0x70>
      p = q;
    800069bc:	8aca                	mv	s5,s2
    800069be:	bf8d                	j	80006930 <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    800069c0:	0496                	slli	s1,s1,0x5
    800069c2:	85d6                	mv	a1,s5
    800069c4:	00004517          	auipc	a0,0x4
    800069c8:	aac53503          	ld	a0,-1364(a0) # 8000a470 <bd_sizes>
    800069cc:	9526                	add	a0,a0,s1
    800069ce:	00000097          	auipc	ra,0x0
    800069d2:	65a080e7          	jalr	1626(ra) # 80007028 <lst_push>
  release(&lock);
    800069d6:	00031517          	auipc	a0,0x31
    800069da:	e5a50513          	addi	a0,a0,-422 # 80037830 <lock>
    800069de:	ffffa097          	auipc	ra,0xffffa
    800069e2:	28e080e7          	jalr	654(ra) # 80000c6c <release>
}
    800069e6:	70a6                	ld	ra,104(sp)
    800069e8:	7406                	ld	s0,96(sp)
    800069ea:	64e6                	ld	s1,88(sp)
    800069ec:	6946                	ld	s2,80(sp)
    800069ee:	69a6                	ld	s3,72(sp)
    800069f0:	6a06                	ld	s4,64(sp)
    800069f2:	7ae2                	ld	s5,56(sp)
    800069f4:	7b42                	ld	s6,48(sp)
    800069f6:	7ba2                	ld	s7,40(sp)
    800069f8:	7c02                	ld	s8,32(sp)
    800069fa:	6ce2                	ld	s9,24(sp)
    800069fc:	6d42                	ld	s10,16(sp)
    800069fe:	6da2                	ld	s11,8(sp)
    80006a00:	6165                	addi	sp,sp,112
    80006a02:	8082                	ret

0000000080006a04 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006a04:	1141                	addi	sp,sp,-16
    80006a06:	e422                	sd	s0,8(sp)
    80006a08:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006a0a:	00004797          	auipc	a5,0x4
    80006a0e:	a5e7b783          	ld	a5,-1442(a5) # 8000a468 <bd_base>
    80006a12:	8d9d                	sub	a1,a1,a5
    80006a14:	47c1                	li	a5,16
    80006a16:	00a797b3          	sll	a5,a5,a0
    80006a1a:	02f5c533          	div	a0,a1,a5
    80006a1e:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006a20:	02f5e5b3          	rem	a1,a1,a5
    80006a24:	c191                	beqz	a1,80006a28 <blk_index_next+0x24>
      n++;
    80006a26:	2505                	addiw	a0,a0,1
  return n ;
}
    80006a28:	6422                	ld	s0,8(sp)
    80006a2a:	0141                	addi	sp,sp,16
    80006a2c:	8082                	ret

0000000080006a2e <log2>:

int
log2(uint64 n) {
    80006a2e:	1141                	addi	sp,sp,-16
    80006a30:	e422                	sd	s0,8(sp)
    80006a32:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006a34:	4705                	li	a4,1
    80006a36:	00a77b63          	bgeu	a4,a0,80006a4c <log2+0x1e>
    80006a3a:	87aa                	mv	a5,a0
  int k = 0;
    80006a3c:	4501                	li	a0,0
    k++;
    80006a3e:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006a40:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006a42:	fef76ee3          	bltu	a4,a5,80006a3e <log2+0x10>
  }
  return k;
}
    80006a46:	6422                	ld	s0,8(sp)
    80006a48:	0141                	addi	sp,sp,16
    80006a4a:	8082                	ret
  int k = 0;
    80006a4c:	4501                	li	a0,0
    80006a4e:	bfe5                	j	80006a46 <log2+0x18>

0000000080006a50 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006a50:	711d                	addi	sp,sp,-96
    80006a52:	ec86                	sd	ra,88(sp)
    80006a54:	e8a2                	sd	s0,80(sp)
    80006a56:	e4a6                	sd	s1,72(sp)
    80006a58:	e0ca                	sd	s2,64(sp)
    80006a5a:	fc4e                	sd	s3,56(sp)
    80006a5c:	f852                	sd	s4,48(sp)
    80006a5e:	f456                	sd	s5,40(sp)
    80006a60:	f05a                	sd	s6,32(sp)
    80006a62:	ec5e                	sd	s7,24(sp)
    80006a64:	e862                	sd	s8,16(sp)
    80006a66:	e466                	sd	s9,8(sp)
    80006a68:	e06a                	sd	s10,0(sp)
    80006a6a:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006a6c:	00b56933          	or	s2,a0,a1
    80006a70:	00f97913          	andi	s2,s2,15
    80006a74:	04091263          	bnez	s2,80006ab8 <bd_mark+0x68>
    80006a78:	8b2a                	mv	s6,a0
    80006a7a:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006a7c:	00004c17          	auipc	s8,0x4
    80006a80:	9fcc2c03          	lw	s8,-1540(s8) # 8000a478 <nsizes>
    80006a84:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006a86:	00004d17          	auipc	s10,0x4
    80006a8a:	9e2d0d13          	addi	s10,s10,-1566 # 8000a468 <bd_base>
  return n / BLK_SIZE(k);
    80006a8e:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006a90:	00004a97          	auipc	s5,0x4
    80006a94:	9e0a8a93          	addi	s5,s5,-1568 # 8000a470 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006a98:	07804563          	bgtz	s8,80006b02 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006a9c:	60e6                	ld	ra,88(sp)
    80006a9e:	6446                	ld	s0,80(sp)
    80006aa0:	64a6                	ld	s1,72(sp)
    80006aa2:	6906                	ld	s2,64(sp)
    80006aa4:	79e2                	ld	s3,56(sp)
    80006aa6:	7a42                	ld	s4,48(sp)
    80006aa8:	7aa2                	ld	s5,40(sp)
    80006aaa:	7b02                	ld	s6,32(sp)
    80006aac:	6be2                	ld	s7,24(sp)
    80006aae:	6c42                	ld	s8,16(sp)
    80006ab0:	6ca2                	ld	s9,8(sp)
    80006ab2:	6d02                	ld	s10,0(sp)
    80006ab4:	6125                	addi	sp,sp,96
    80006ab6:	8082                	ret
    panic("bd_mark");
    80006ab8:	00003517          	auipc	a0,0x3
    80006abc:	33850513          	addi	a0,a0,824 # 80009df0 <syscalls+0x4c0>
    80006ac0:	ffffa097          	auipc	ra,0xffffa
    80006ac4:	aaa080e7          	jalr	-1366(ra) # 8000056a <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006ac8:	000ab783          	ld	a5,0(s5)
    80006acc:	97ca                	add	a5,a5,s2
    80006ace:	85a6                	mv	a1,s1
    80006ad0:	6b88                	ld	a0,16(a5)
    80006ad2:	00000097          	auipc	ra,0x0
    80006ad6:	97e080e7          	jalr	-1666(ra) # 80006450 <bit_set>
    for(; bi < bj; bi++) {
    80006ada:	2485                	addiw	s1,s1,1
    80006adc:	009a0e63          	beq	s4,s1,80006af8 <bd_mark+0xa8>
      if(k > 0) {
    80006ae0:	ff3054e3          	blez	s3,80006ac8 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006ae4:	000ab783          	ld	a5,0(s5)
    80006ae8:	97ca                	add	a5,a5,s2
    80006aea:	85a6                	mv	a1,s1
    80006aec:	6f88                	ld	a0,24(a5)
    80006aee:	00000097          	auipc	ra,0x0
    80006af2:	962080e7          	jalr	-1694(ra) # 80006450 <bit_set>
    80006af6:	bfc9                	j	80006ac8 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006af8:	2985                	addiw	s3,s3,1
    80006afa:	02090913          	addi	s2,s2,32
    80006afe:	f9898fe3          	beq	s3,s8,80006a9c <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006b02:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006b06:	409b04bb          	subw	s1,s6,s1
    80006b0a:	013c97b3          	sll	a5,s9,s3
    80006b0e:	02f4c4b3          	div	s1,s1,a5
    80006b12:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006b14:	85de                	mv	a1,s7
    80006b16:	854e                	mv	a0,s3
    80006b18:	00000097          	auipc	ra,0x0
    80006b1c:	eec080e7          	jalr	-276(ra) # 80006a04 <blk_index_next>
    80006b20:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006b22:	faa4cfe3          	blt	s1,a0,80006ae0 <bd_mark+0x90>
    80006b26:	bfc9                	j	80006af8 <bd_mark+0xa8>

0000000080006b28 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006b28:	7139                	addi	sp,sp,-64
    80006b2a:	fc06                	sd	ra,56(sp)
    80006b2c:	f822                	sd	s0,48(sp)
    80006b2e:	f426                	sd	s1,40(sp)
    80006b30:	f04a                	sd	s2,32(sp)
    80006b32:	ec4e                	sd	s3,24(sp)
    80006b34:	e852                	sd	s4,16(sp)
    80006b36:	e456                	sd	s5,8(sp)
    80006b38:	e05a                	sd	s6,0(sp)
    80006b3a:	0080                	addi	s0,sp,64
    80006b3c:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006b3e:	00058a9b          	sext.w	s5,a1
    80006b42:	0015f793          	andi	a5,a1,1
    80006b46:	ebad                	bnez	a5,80006bb8 <bd_initfree_pair+0x90>
    80006b48:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006b4c:	00599493          	slli	s1,s3,0x5
    80006b50:	00004797          	auipc	a5,0x4
    80006b54:	9207b783          	ld	a5,-1760(a5) # 8000a470 <bd_sizes>
    80006b58:	94be                	add	s1,s1,a5
    80006b5a:	0104bb03          	ld	s6,16(s1)
    80006b5e:	855a                	mv	a0,s6
    80006b60:	00000097          	auipc	ra,0x0
    80006b64:	8b8080e7          	jalr	-1864(ra) # 80006418 <bit_isset>
    80006b68:	892a                	mv	s2,a0
    80006b6a:	85d2                	mv	a1,s4
    80006b6c:	855a                	mv	a0,s6
    80006b6e:	00000097          	auipc	ra,0x0
    80006b72:	8aa080e7          	jalr	-1878(ra) # 80006418 <bit_isset>
  int free = 0;
    80006b76:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006b78:	02a90563          	beq	s2,a0,80006ba2 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006b7c:	45c1                	li	a1,16
    80006b7e:	013599b3          	sll	s3,a1,s3
    80006b82:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006b86:	02090c63          	beqz	s2,80006bbe <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006b8a:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006b8e:	00004597          	auipc	a1,0x4
    80006b92:	8da5b583          	ld	a1,-1830(a1) # 8000a468 <bd_base>
    80006b96:	95ce                	add	a1,a1,s3
    80006b98:	8526                	mv	a0,s1
    80006b9a:	00000097          	auipc	ra,0x0
    80006b9e:	48e080e7          	jalr	1166(ra) # 80007028 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006ba2:	855a                	mv	a0,s6
    80006ba4:	70e2                	ld	ra,56(sp)
    80006ba6:	7442                	ld	s0,48(sp)
    80006ba8:	74a2                	ld	s1,40(sp)
    80006baa:	7902                	ld	s2,32(sp)
    80006bac:	69e2                	ld	s3,24(sp)
    80006bae:	6a42                	ld	s4,16(sp)
    80006bb0:	6aa2                	ld	s5,8(sp)
    80006bb2:	6b02                	ld	s6,0(sp)
    80006bb4:	6121                	addi	sp,sp,64
    80006bb6:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bb8:	fff58a1b          	addiw	s4,a1,-1
    80006bbc:	bf41                	j	80006b4c <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006bbe:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006bc2:	00004597          	auipc	a1,0x4
    80006bc6:	8a65b583          	ld	a1,-1882(a1) # 8000a468 <bd_base>
    80006bca:	95ce                	add	a1,a1,s3
    80006bcc:	8526                	mv	a0,s1
    80006bce:	00000097          	auipc	ra,0x0
    80006bd2:	45a080e7          	jalr	1114(ra) # 80007028 <lst_push>
    80006bd6:	b7f1                	j	80006ba2 <bd_initfree_pair+0x7a>

0000000080006bd8 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006bd8:	711d                	addi	sp,sp,-96
    80006bda:	ec86                	sd	ra,88(sp)
    80006bdc:	e8a2                	sd	s0,80(sp)
    80006bde:	e4a6                	sd	s1,72(sp)
    80006be0:	e0ca                	sd	s2,64(sp)
    80006be2:	fc4e                	sd	s3,56(sp)
    80006be4:	f852                	sd	s4,48(sp)
    80006be6:	f456                	sd	s5,40(sp)
    80006be8:	f05a                	sd	s6,32(sp)
    80006bea:	ec5e                	sd	s7,24(sp)
    80006bec:	e862                	sd	s8,16(sp)
    80006bee:	e466                	sd	s9,8(sp)
    80006bf0:	e06a                	sd	s10,0(sp)
    80006bf2:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006bf4:	00004717          	auipc	a4,0x4
    80006bf8:	88472703          	lw	a4,-1916(a4) # 8000a478 <nsizes>
    80006bfc:	4785                	li	a5,1
    80006bfe:	06e7db63          	bge	a5,a4,80006c74 <bd_initfree+0x9c>
    80006c02:	8aaa                	mv	s5,a0
    80006c04:	8b2e                	mv	s6,a1
    80006c06:	4901                	li	s2,0
  int free = 0;
    80006c08:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006c0a:	00004c97          	auipc	s9,0x4
    80006c0e:	85ec8c93          	addi	s9,s9,-1954 # 8000a468 <bd_base>
  return n / BLK_SIZE(k);
    80006c12:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006c14:	00004b97          	auipc	s7,0x4
    80006c18:	864b8b93          	addi	s7,s7,-1948 # 8000a478 <nsizes>
    80006c1c:	a039                	j	80006c2a <bd_initfree+0x52>
    80006c1e:	2905                	addiw	s2,s2,1
    80006c20:	000ba783          	lw	a5,0(s7)
    80006c24:	37fd                	addiw	a5,a5,-1
    80006c26:	04f95863          	bge	s2,a5,80006c76 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006c2a:	85d6                	mv	a1,s5
    80006c2c:	854a                	mv	a0,s2
    80006c2e:	00000097          	auipc	ra,0x0
    80006c32:	dd6080e7          	jalr	-554(ra) # 80006a04 <blk_index_next>
    80006c36:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006c38:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006c3c:	409b04bb          	subw	s1,s6,s1
    80006c40:	012c17b3          	sll	a5,s8,s2
    80006c44:	02f4c4b3          	div	s1,s1,a5
    80006c48:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006c4a:	85aa                	mv	a1,a0
    80006c4c:	854a                	mv	a0,s2
    80006c4e:	00000097          	auipc	ra,0x0
    80006c52:	eda080e7          	jalr	-294(ra) # 80006b28 <bd_initfree_pair>
    80006c56:	01450d3b          	addw	s10,a0,s4
    80006c5a:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006c5e:	fc99d0e3          	bge	s3,s1,80006c1e <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006c62:	85a6                	mv	a1,s1
    80006c64:	854a                	mv	a0,s2
    80006c66:	00000097          	auipc	ra,0x0
    80006c6a:	ec2080e7          	jalr	-318(ra) # 80006b28 <bd_initfree_pair>
    80006c6e:	00ad0a3b          	addw	s4,s10,a0
    80006c72:	b775                	j	80006c1e <bd_initfree+0x46>
  int free = 0;
    80006c74:	4a01                	li	s4,0
  }
  return free;
}
    80006c76:	8552                	mv	a0,s4
    80006c78:	60e6                	ld	ra,88(sp)
    80006c7a:	6446                	ld	s0,80(sp)
    80006c7c:	64a6                	ld	s1,72(sp)
    80006c7e:	6906                	ld	s2,64(sp)
    80006c80:	79e2                	ld	s3,56(sp)
    80006c82:	7a42                	ld	s4,48(sp)
    80006c84:	7aa2                	ld	s5,40(sp)
    80006c86:	7b02                	ld	s6,32(sp)
    80006c88:	6be2                	ld	s7,24(sp)
    80006c8a:	6c42                	ld	s8,16(sp)
    80006c8c:	6ca2                	ld	s9,8(sp)
    80006c8e:	6d02                	ld	s10,0(sp)
    80006c90:	6125                	addi	sp,sp,96
    80006c92:	8082                	ret

0000000080006c94 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006c94:	7179                	addi	sp,sp,-48
    80006c96:	f406                	sd	ra,40(sp)
    80006c98:	f022                	sd	s0,32(sp)
    80006c9a:	ec26                	sd	s1,24(sp)
    80006c9c:	e84a                	sd	s2,16(sp)
    80006c9e:	e44e                	sd	s3,8(sp)
    80006ca0:	1800                	addi	s0,sp,48
    80006ca2:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006ca4:	00003997          	auipc	s3,0x3
    80006ca8:	7c498993          	addi	s3,s3,1988 # 8000a468 <bd_base>
    80006cac:	0009b483          	ld	s1,0(s3)
    80006cb0:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006cb4:	00003797          	auipc	a5,0x3
    80006cb8:	7c47a783          	lw	a5,1988(a5) # 8000a478 <nsizes>
    80006cbc:	37fd                	addiw	a5,a5,-1
    80006cbe:	4641                	li	a2,16
    80006cc0:	00f61633          	sll	a2,a2,a5
    80006cc4:	85a6                	mv	a1,s1
    80006cc6:	00003517          	auipc	a0,0x3
    80006cca:	13250513          	addi	a0,a0,306 # 80009df8 <syscalls+0x4c8>
    80006cce:	ffffa097          	auipc	ra,0xffffa
    80006cd2:	8fe080e7          	jalr	-1794(ra) # 800005cc <printf>
  bd_mark(bd_base, p);
    80006cd6:	85ca                	mv	a1,s2
    80006cd8:	0009b503          	ld	a0,0(s3)
    80006cdc:	00000097          	auipc	ra,0x0
    80006ce0:	d74080e7          	jalr	-652(ra) # 80006a50 <bd_mark>
  return meta;
}
    80006ce4:	8526                	mv	a0,s1
    80006ce6:	70a2                	ld	ra,40(sp)
    80006ce8:	7402                	ld	s0,32(sp)
    80006cea:	64e2                	ld	s1,24(sp)
    80006cec:	6942                	ld	s2,16(sp)
    80006cee:	69a2                	ld	s3,8(sp)
    80006cf0:	6145                	addi	sp,sp,48
    80006cf2:	8082                	ret

0000000080006cf4 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006cf4:	1101                	addi	sp,sp,-32
    80006cf6:	ec06                	sd	ra,24(sp)
    80006cf8:	e822                	sd	s0,16(sp)
    80006cfa:	e426                	sd	s1,8(sp)
    80006cfc:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006cfe:	00003497          	auipc	s1,0x3
    80006d02:	77a4a483          	lw	s1,1914(s1) # 8000a478 <nsizes>
    80006d06:	fff4879b          	addiw	a5,s1,-1
    80006d0a:	44c1                	li	s1,16
    80006d0c:	00f494b3          	sll	s1,s1,a5
    80006d10:	00003797          	auipc	a5,0x3
    80006d14:	7587b783          	ld	a5,1880(a5) # 8000a468 <bd_base>
    80006d18:	8d1d                	sub	a0,a0,a5
    80006d1a:	40a4853b          	subw	a0,s1,a0
    80006d1e:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006d22:	00905a63          	blez	s1,80006d36 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006d26:	357d                	addiw	a0,a0,-1
    80006d28:	41f5549b          	sraiw	s1,a0,0x1f
    80006d2c:	01c4d49b          	srliw	s1,s1,0x1c
    80006d30:	9ca9                	addw	s1,s1,a0
    80006d32:	98c1                	andi	s1,s1,-16
    80006d34:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006d36:	85a6                	mv	a1,s1
    80006d38:	00003517          	auipc	a0,0x3
    80006d3c:	0f850513          	addi	a0,a0,248 # 80009e30 <syscalls+0x500>
    80006d40:	ffffa097          	auipc	ra,0xffffa
    80006d44:	88c080e7          	jalr	-1908(ra) # 800005cc <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006d48:	00003717          	auipc	a4,0x3
    80006d4c:	72073703          	ld	a4,1824(a4) # 8000a468 <bd_base>
    80006d50:	00003597          	auipc	a1,0x3
    80006d54:	7285a583          	lw	a1,1832(a1) # 8000a478 <nsizes>
    80006d58:	fff5879b          	addiw	a5,a1,-1
    80006d5c:	45c1                	li	a1,16
    80006d5e:	00f595b3          	sll	a1,a1,a5
    80006d62:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006d66:	95ba                	add	a1,a1,a4
    80006d68:	953a                	add	a0,a0,a4
    80006d6a:	00000097          	auipc	ra,0x0
    80006d6e:	ce6080e7          	jalr	-794(ra) # 80006a50 <bd_mark>
  return unavailable;
}
    80006d72:	8526                	mv	a0,s1
    80006d74:	60e2                	ld	ra,24(sp)
    80006d76:	6442                	ld	s0,16(sp)
    80006d78:	64a2                	ld	s1,8(sp)
    80006d7a:	6105                	addi	sp,sp,32
    80006d7c:	8082                	ret

0000000080006d7e <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006d7e:	715d                	addi	sp,sp,-80
    80006d80:	e486                	sd	ra,72(sp)
    80006d82:	e0a2                	sd	s0,64(sp)
    80006d84:	fc26                	sd	s1,56(sp)
    80006d86:	f84a                	sd	s2,48(sp)
    80006d88:	f44e                	sd	s3,40(sp)
    80006d8a:	f052                	sd	s4,32(sp)
    80006d8c:	ec56                	sd	s5,24(sp)
    80006d8e:	e85a                	sd	s6,16(sp)
    80006d90:	e45e                	sd	s7,8(sp)
    80006d92:	e062                	sd	s8,0(sp)
    80006d94:	0880                	addi	s0,sp,80
    80006d96:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006d98:	fff50493          	addi	s1,a0,-1
    80006d9c:	98c1                	andi	s1,s1,-16
    80006d9e:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006da0:	00003597          	auipc	a1,0x3
    80006da4:	0b058593          	addi	a1,a1,176 # 80009e50 <syscalls+0x520>
    80006da8:	00031517          	auipc	a0,0x31
    80006dac:	a8850513          	addi	a0,a0,-1400 # 80037830 <lock>
    80006db0:	ffffa097          	auipc	ra,0xffffa
    80006db4:	d16080e7          	jalr	-746(ra) # 80000ac6 <initlock>
  bd_base = (void *) p;
    80006db8:	00003797          	auipc	a5,0x3
    80006dbc:	6a97b823          	sd	s1,1712(a5) # 8000a468 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006dc0:	409c0933          	sub	s2,s8,s1
    80006dc4:	43f95513          	srai	a0,s2,0x3f
    80006dc8:	893d                	andi	a0,a0,15
    80006dca:	954a                	add	a0,a0,s2
    80006dcc:	8511                	srai	a0,a0,0x4
    80006dce:	00000097          	auipc	ra,0x0
    80006dd2:	c60080e7          	jalr	-928(ra) # 80006a2e <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006dd6:	47c1                	li	a5,16
    80006dd8:	00a797b3          	sll	a5,a5,a0
    80006ddc:	1b27c663          	blt	a5,s2,80006f88 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006de0:	2505                	addiw	a0,a0,1
    80006de2:	00003797          	auipc	a5,0x3
    80006de6:	68a7ab23          	sw	a0,1686(a5) # 8000a478 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006dea:	00003997          	auipc	s3,0x3
    80006dee:	68e98993          	addi	s3,s3,1678 # 8000a478 <nsizes>
    80006df2:	0009a603          	lw	a2,0(s3)
    80006df6:	85ca                	mv	a1,s2
    80006df8:	00003517          	auipc	a0,0x3
    80006dfc:	06050513          	addi	a0,a0,96 # 80009e58 <syscalls+0x528>
    80006e00:	ffff9097          	auipc	ra,0xffff9
    80006e04:	7cc080e7          	jalr	1996(ra) # 800005cc <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006e08:	00003797          	auipc	a5,0x3
    80006e0c:	6697b423          	sd	s1,1640(a5) # 8000a470 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006e10:	0009a603          	lw	a2,0(s3)
    80006e14:	00561913          	slli	s2,a2,0x5
    80006e18:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006e1a:	0056161b          	slliw	a2,a2,0x5
    80006e1e:	4581                	li	a1,0
    80006e20:	8526                	mv	a0,s1
    80006e22:	ffffa097          	auipc	ra,0xffffa
    80006e26:	05e080e7          	jalr	94(ra) # 80000e80 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006e2a:	0009a783          	lw	a5,0(s3)
    80006e2e:	06f05a63          	blez	a5,80006ea2 <bd_init+0x124>
    80006e32:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006e34:	00003a97          	auipc	s5,0x3
    80006e38:	63ca8a93          	addi	s5,s5,1596 # 8000a470 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006e3c:	00003a17          	auipc	s4,0x3
    80006e40:	63ca0a13          	addi	s4,s4,1596 # 8000a478 <nsizes>
    80006e44:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006e46:	00599b93          	slli	s7,s3,0x5
    80006e4a:	000ab503          	ld	a0,0(s5)
    80006e4e:	955e                	add	a0,a0,s7
    80006e50:	00000097          	auipc	ra,0x0
    80006e54:	166080e7          	jalr	358(ra) # 80006fb6 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006e58:	000a2483          	lw	s1,0(s4)
    80006e5c:	34fd                	addiw	s1,s1,-1
    80006e5e:	413484bb          	subw	s1,s1,s3
    80006e62:	009b14bb          	sllw	s1,s6,s1
    80006e66:	fff4879b          	addiw	a5,s1,-1
    80006e6a:	41f7d49b          	sraiw	s1,a5,0x1f
    80006e6e:	01d4d49b          	srliw	s1,s1,0x1d
    80006e72:	9cbd                	addw	s1,s1,a5
    80006e74:	98e1                	andi	s1,s1,-8
    80006e76:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006e78:	000ab783          	ld	a5,0(s5)
    80006e7c:	9bbe                	add	s7,s7,a5
    80006e7e:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006e82:	848d                	srai	s1,s1,0x3
    80006e84:	8626                	mv	a2,s1
    80006e86:	4581                	li	a1,0
    80006e88:	854a                	mv	a0,s2
    80006e8a:	ffffa097          	auipc	ra,0xffffa
    80006e8e:	ff6080e7          	jalr	-10(ra) # 80000e80 <memset>
    p += sz;
    80006e92:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006e94:	0985                	addi	s3,s3,1
    80006e96:	000a2703          	lw	a4,0(s4)
    80006e9a:	0009879b          	sext.w	a5,s3
    80006e9e:	fae7c4e3          	blt	a5,a4,80006e46 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006ea2:	00003797          	auipc	a5,0x3
    80006ea6:	5d67a783          	lw	a5,1494(a5) # 8000a478 <nsizes>
    80006eaa:	4705                	li	a4,1
    80006eac:	06f75163          	bge	a4,a5,80006f0e <bd_init+0x190>
    80006eb0:	02000a13          	li	s4,32
    80006eb4:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006eb6:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006eb8:	00003b17          	auipc	s6,0x3
    80006ebc:	5b8b0b13          	addi	s6,s6,1464 # 8000a470 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006ec0:	00003a97          	auipc	s5,0x3
    80006ec4:	5b8a8a93          	addi	s5,s5,1464 # 8000a478 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006ec8:	37fd                	addiw	a5,a5,-1
    80006eca:	413787bb          	subw	a5,a5,s3
    80006ece:	00fb94bb          	sllw	s1,s7,a5
    80006ed2:	fff4879b          	addiw	a5,s1,-1
    80006ed6:	41f7d49b          	sraiw	s1,a5,0x1f
    80006eda:	01d4d49b          	srliw	s1,s1,0x1d
    80006ede:	9cbd                	addw	s1,s1,a5
    80006ee0:	98e1                	andi	s1,s1,-8
    80006ee2:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006ee4:	000b3783          	ld	a5,0(s6)
    80006ee8:	97d2                	add	a5,a5,s4
    80006eea:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006eee:	848d                	srai	s1,s1,0x3
    80006ef0:	8626                	mv	a2,s1
    80006ef2:	4581                	li	a1,0
    80006ef4:	854a                	mv	a0,s2
    80006ef6:	ffffa097          	auipc	ra,0xffffa
    80006efa:	f8a080e7          	jalr	-118(ra) # 80000e80 <memset>
    p += sz;
    80006efe:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006f00:	2985                	addiw	s3,s3,1
    80006f02:	000aa783          	lw	a5,0(s5)
    80006f06:	020a0a13          	addi	s4,s4,32
    80006f0a:	faf9cfe3          	blt	s3,a5,80006ec8 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006f0e:	197d                	addi	s2,s2,-1
    80006f10:	ff097913          	andi	s2,s2,-16
    80006f14:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006f16:	854a                	mv	a0,s2
    80006f18:	00000097          	auipc	ra,0x0
    80006f1c:	d7c080e7          	jalr	-644(ra) # 80006c94 <bd_mark_data_structures>
    80006f20:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006f22:	85ca                	mv	a1,s2
    80006f24:	8562                	mv	a0,s8
    80006f26:	00000097          	auipc	ra,0x0
    80006f2a:	dce080e7          	jalr	-562(ra) # 80006cf4 <bd_mark_unavailable>
    80006f2e:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006f30:	00003a97          	auipc	s5,0x3
    80006f34:	548a8a93          	addi	s5,s5,1352 # 8000a478 <nsizes>
    80006f38:	000aa783          	lw	a5,0(s5)
    80006f3c:	37fd                	addiw	a5,a5,-1
    80006f3e:	44c1                	li	s1,16
    80006f40:	00f497b3          	sll	a5,s1,a5
    80006f44:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006f46:	00003597          	auipc	a1,0x3
    80006f4a:	5225b583          	ld	a1,1314(a1) # 8000a468 <bd_base>
    80006f4e:	95be                	add	a1,a1,a5
    80006f50:	854a                	mv	a0,s2
    80006f52:	00000097          	auipc	ra,0x0
    80006f56:	c86080e7          	jalr	-890(ra) # 80006bd8 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80006f5a:	000aa603          	lw	a2,0(s5)
    80006f5e:	367d                	addiw	a2,a2,-1
    80006f60:	00c49633          	sll	a2,s1,a2
    80006f64:	41460633          	sub	a2,a2,s4
    80006f68:	41360633          	sub	a2,a2,s3
    80006f6c:	02c51463          	bne	a0,a2,80006f94 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80006f70:	60a6                	ld	ra,72(sp)
    80006f72:	6406                	ld	s0,64(sp)
    80006f74:	74e2                	ld	s1,56(sp)
    80006f76:	7942                	ld	s2,48(sp)
    80006f78:	79a2                	ld	s3,40(sp)
    80006f7a:	7a02                	ld	s4,32(sp)
    80006f7c:	6ae2                	ld	s5,24(sp)
    80006f7e:	6b42                	ld	s6,16(sp)
    80006f80:	6ba2                	ld	s7,8(sp)
    80006f82:	6c02                	ld	s8,0(sp)
    80006f84:	6161                	addi	sp,sp,80
    80006f86:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80006f88:	2509                	addiw	a0,a0,2
    80006f8a:	00003797          	auipc	a5,0x3
    80006f8e:	4ea7a723          	sw	a0,1262(a5) # 8000a478 <nsizes>
    80006f92:	bda1                	j	80006dea <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80006f94:	85aa                	mv	a1,a0
    80006f96:	00003517          	auipc	a0,0x3
    80006f9a:	f0250513          	addi	a0,a0,-254 # 80009e98 <syscalls+0x568>
    80006f9e:	ffff9097          	auipc	ra,0xffff9
    80006fa2:	62e080e7          	jalr	1582(ra) # 800005cc <printf>
    panic("bd_init: free mem");
    80006fa6:	00003517          	auipc	a0,0x3
    80006faa:	f0250513          	addi	a0,a0,-254 # 80009ea8 <syscalls+0x578>
    80006fae:	ffff9097          	auipc	ra,0xffff9
    80006fb2:	5bc080e7          	jalr	1468(ra) # 8000056a <panic>

0000000080006fb6 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80006fb6:	1141                	addi	sp,sp,-16
    80006fb8:	e422                	sd	s0,8(sp)
    80006fba:	0800                	addi	s0,sp,16
  lst->next = lst;
    80006fbc:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80006fbe:	e508                	sd	a0,8(a0)
}
    80006fc0:	6422                	ld	s0,8(sp)
    80006fc2:	0141                	addi	sp,sp,16
    80006fc4:	8082                	ret

0000000080006fc6 <lst_empty>:

int
lst_empty(struct list *lst) {
    80006fc6:	1141                	addi	sp,sp,-16
    80006fc8:	e422                	sd	s0,8(sp)
    80006fca:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80006fcc:	611c                	ld	a5,0(a0)
    80006fce:	40a78533          	sub	a0,a5,a0
}
    80006fd2:	00153513          	seqz	a0,a0
    80006fd6:	6422                	ld	s0,8(sp)
    80006fd8:	0141                	addi	sp,sp,16
    80006fda:	8082                	ret

0000000080006fdc <lst_remove>:

void
lst_remove(struct list *e) {
    80006fdc:	1141                	addi	sp,sp,-16
    80006fde:	e422                	sd	s0,8(sp)
    80006fe0:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80006fe2:	6518                	ld	a4,8(a0)
    80006fe4:	611c                	ld	a5,0(a0)
    80006fe6:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80006fe8:	6518                	ld	a4,8(a0)
    80006fea:	e798                	sd	a4,8(a5)
}
    80006fec:	6422                	ld	s0,8(sp)
    80006fee:	0141                	addi	sp,sp,16
    80006ff0:	8082                	ret

0000000080006ff2 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80006ff2:	1101                	addi	sp,sp,-32
    80006ff4:	ec06                	sd	ra,24(sp)
    80006ff6:	e822                	sd	s0,16(sp)
    80006ff8:	e426                	sd	s1,8(sp)
    80006ffa:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80006ffc:	6104                	ld	s1,0(a0)
    80006ffe:	00a48d63          	beq	s1,a0,80007018 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007002:	8526                	mv	a0,s1
    80007004:	00000097          	auipc	ra,0x0
    80007008:	fd8080e7          	jalr	-40(ra) # 80006fdc <lst_remove>
  return (void *)p;
}
    8000700c:	8526                	mv	a0,s1
    8000700e:	60e2                	ld	ra,24(sp)
    80007010:	6442                	ld	s0,16(sp)
    80007012:	64a2                	ld	s1,8(sp)
    80007014:	6105                	addi	sp,sp,32
    80007016:	8082                	ret
    panic("lst_pop");
    80007018:	00003517          	auipc	a0,0x3
    8000701c:	ea850513          	addi	a0,a0,-344 # 80009ec0 <syscalls+0x590>
    80007020:	ffff9097          	auipc	ra,0xffff9
    80007024:	54a080e7          	jalr	1354(ra) # 8000056a <panic>

0000000080007028 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007028:	1141                	addi	sp,sp,-16
    8000702a:	e422                	sd	s0,8(sp)
    8000702c:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000702e:	611c                	ld	a5,0(a0)
    80007030:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007032:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007034:	611c                	ld	a5,0(a0)
    80007036:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007038:	e10c                	sd	a1,0(a0)
}
    8000703a:	6422                	ld	s0,8(sp)
    8000703c:	0141                	addi	sp,sp,16
    8000703e:	8082                	ret

0000000080007040 <lst_print>:

void
lst_print(struct list *lst)
{
    80007040:	7179                	addi	sp,sp,-48
    80007042:	f406                	sd	ra,40(sp)
    80007044:	f022                	sd	s0,32(sp)
    80007046:	ec26                	sd	s1,24(sp)
    80007048:	e84a                	sd	s2,16(sp)
    8000704a:	e44e                	sd	s3,8(sp)
    8000704c:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000704e:	6104                	ld	s1,0(a0)
    80007050:	02950063          	beq	a0,s1,80007070 <lst_print+0x30>
    80007054:	892a                	mv	s2,a0
    printf(" %p", p);
    80007056:	00003997          	auipc	s3,0x3
    8000705a:	e7298993          	addi	s3,s3,-398 # 80009ec8 <syscalls+0x598>
    8000705e:	85a6                	mv	a1,s1
    80007060:	854e                	mv	a0,s3
    80007062:	ffff9097          	auipc	ra,0xffff9
    80007066:	56a080e7          	jalr	1386(ra) # 800005cc <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000706a:	6084                	ld	s1,0(s1)
    8000706c:	fe9919e3          	bne	s2,s1,8000705e <lst_print+0x1e>
  }
  printf("\n");
    80007070:	00002517          	auipc	a0,0x2
    80007074:	19050513          	addi	a0,a0,400 # 80009200 <digits+0x90>
    80007078:	ffff9097          	auipc	ra,0xffff9
    8000707c:	554080e7          	jalr	1364(ra) # 800005cc <printf>
}
    80007080:	70a2                	ld	ra,40(sp)
    80007082:	7402                	ld	s0,32(sp)
    80007084:	64e2                	ld	s1,24(sp)
    80007086:	6942                	ld	s2,16(sp)
    80007088:	69a2                	ld	s3,8(sp)
    8000708a:	6145                	addi	sp,sp,48
    8000708c:	8082                	ret

000000008000708e <rcu_init>:
  }
}

void
rcu_init(void)
{
    8000708e:	1101                	addi	sp,sp,-32
    80007090:	ec06                	sd	ra,24(sp)
    80007092:	e822                	sd	s0,16(sp)
    80007094:	e426                	sd	s1,8(sp)
    80007096:	1000                	addi	s0,sp,32
  initlock(&rcu_lock, "rcu");
    80007098:	00030497          	auipc	s1,0x30
    8000709c:	7b848493          	addi	s1,s1,1976 # 80037850 <rcu_lock>
    800070a0:	00003597          	auipc	a1,0x3
    800070a4:	e3058593          	addi	a1,a1,-464 # 80009ed0 <syscalls+0x5a0>
    800070a8:	8526                	mv	a0,s1
    800070aa:	ffffa097          	auipc	ra,0xffffa
    800070ae:	a1c080e7          	jalr	-1508(ra) # 80000ac6 <initlock>
  defer_list = 0;
    800070b2:	00003797          	auipc	a5,0x3
    800070b6:	3c07b723          	sd	zero,974(a5) # 8000a480 <defer_list>
  for (int i = 0; i < NCPU; i++)
    rcu_readers[i] = 0;
    800070ba:	0204a023          	sw	zero,32(s1)
    800070be:	0204a223          	sw	zero,36(s1)
    800070c2:	0204a423          	sw	zero,40(s1)
    800070c6:	0204a623          	sw	zero,44(s1)
    800070ca:	0204a823          	sw	zero,48(s1)
    800070ce:	0204aa23          	sw	zero,52(s1)
    800070d2:	0204ac23          	sw	zero,56(s1)
    800070d6:	0204ae23          	sw	zero,60(s1)
}
    800070da:	60e2                	ld	ra,24(sp)
    800070dc:	6442                	ld	s0,16(sp)
    800070de:	64a2                	ld	s1,8(sp)
    800070e0:	6105                	addi	sp,sp,32
    800070e2:	8082                	ret

00000000800070e4 <rcu_read_lock>:

void
rcu_read_lock(void)
{
    800070e4:	1141                	addi	sp,sp,-16
    800070e6:	e406                	sd	ra,8(sp)
    800070e8:	e022                	sd	s0,0(sp)
    800070ea:	0800                	addi	s0,sp,16
  int id = cpuid();
    800070ec:	ffffb097          	auipc	ra,0xffffb
    800070f0:	a50080e7          	jalr	-1456(ra) # 80001b3c <cpuid>
  __sync_add_and_fetch(&rcu_readers[id], 1);
    800070f4:	00251793          	slli	a5,a0,0x2
    800070f8:	00030517          	auipc	a0,0x30
    800070fc:	75850513          	addi	a0,a0,1880 # 80037850 <rcu_lock>
    80007100:	953e                	add	a0,a0,a5
    80007102:	4785                	li	a5,1
    80007104:	02050713          	addi	a4,a0,32
    80007108:	0f50000f          	fence	iorw,ow
    8000710c:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  __sync_synchronize();
    80007110:	0ff0000f          	fence
}
    80007114:	60a2                	ld	ra,8(sp)
    80007116:	6402                	ld	s0,0(sp)
    80007118:	0141                	addi	sp,sp,16
    8000711a:	8082                	ret

000000008000711c <rcu_read_unlock>:

void
rcu_read_unlock(void)
{
    8000711c:	1141                	addi	sp,sp,-16
    8000711e:	e406                	sd	ra,8(sp)
    80007120:	e022                	sd	s0,0(sp)
    80007122:	0800                	addi	s0,sp,16
  __sync_synchronize();
    80007124:	0ff0000f          	fence
  int id = cpuid();
    80007128:	ffffb097          	auipc	ra,0xffffb
    8000712c:	a14080e7          	jalr	-1516(ra) # 80001b3c <cpuid>
  __sync_sub_and_fetch(&rcu_readers[id], 1);
    80007130:	00251793          	slli	a5,a0,0x2
    80007134:	00030517          	auipc	a0,0x30
    80007138:	71c50513          	addi	a0,a0,1820 # 80037850 <rcu_lock>
    8000713c:	953e                	add	a0,a0,a5
    8000713e:	57fd                	li	a5,-1
    80007140:	02050713          	addi	a4,a0,32
    80007144:	0f50000f          	fence	iorw,ow
    80007148:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
}
    8000714c:	60a2                	ld	ra,8(sp)
    8000714e:	6402                	ld	s0,0(sp)
    80007150:	0141                	addi	sp,sp,16
    80007152:	8082                	ret

0000000080007154 <call_rcu>:

void
call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *))
{
    80007154:	1101                	addi	sp,sp,-32
    80007156:	ec06                	sd	ra,24(sp)
    80007158:	e822                	sd	s0,16(sp)
    8000715a:	e426                	sd	s1,8(sp)
    8000715c:	e04a                	sd	s2,0(sp)
    8000715e:	1000                	addi	s0,sp,32
    80007160:	84aa                	mv	s1,a0
  head->func = func;
    80007162:	e10c                	sd	a1,0(a0)

  acquire(&rcu_lock);
    80007164:	00030917          	auipc	s2,0x30
    80007168:	6ec90913          	addi	s2,s2,1772 # 80037850 <rcu_lock>
    8000716c:	854a                	mv	a0,s2
    8000716e:	ffffa097          	auipc	ra,0xffffa
    80007172:	a2e080e7          	jalr	-1490(ra) # 80000b9c <acquire>
  head->next = defer_list;
    80007176:	00003797          	auipc	a5,0x3
    8000717a:	30a78793          	addi	a5,a5,778 # 8000a480 <defer_list>
    8000717e:	6398                	ld	a4,0(a5)
    80007180:	e498                	sd	a4,8(s1)
  defer_list = head;
    80007182:	e384                	sd	s1,0(a5)
  release(&rcu_lock);
    80007184:	854a                	mv	a0,s2
    80007186:	ffffa097          	auipc	ra,0xffffa
    8000718a:	ae6080e7          	jalr	-1306(ra) # 80000c6c <release>
}
    8000718e:	60e2                	ld	ra,24(sp)
    80007190:	6442                	ld	s0,16(sp)
    80007192:	64a2                	ld	s1,8(sp)
    80007194:	6902                	ld	s2,0(sp)
    80007196:	6105                	addi	sp,sp,32
    80007198:	8082                	ret

000000008000719a <synchronize_rcu>:

void
synchronize_rcu(void)
{
    8000719a:	1101                	addi	sp,sp,-32
    8000719c:	ec06                	sd	ra,24(sp)
    8000719e:	e822                	sd	s0,16(sp)
    800071a0:	e426                	sd	s1,8(sp)
    800071a2:	e04a                	sd	s2,0(sp)
    800071a4:	1000                	addi	s0,sp,32
  // Wait for a grace period.
  wait_for_readers();
    800071a6:	00030697          	auipc	a3,0x30
    800071aa:	6ea68693          	addi	a3,a3,1770 # 80037890 <rw.1702>
    for (int i = 0; i < NCPU; i++) {
    800071ae:	00030797          	auipc	a5,0x30
    800071b2:	6c278793          	addi	a5,a5,1730 # 80037870 <rcu_readers>
      if (__sync_fetch_and_add(&rcu_readers[i], 0) > 0) {
    800071b6:	0f50000f          	fence	iorw,ow
    800071ba:	0407a72f          	amoadd.w.aq	a4,zero,(a5)
    800071be:	2701                	sext.w	a4,a4
    800071c0:	fee047e3          	bgtz	a4,800071ae <synchronize_rcu+0x14>
    for (int i = 0; i < NCPU; i++) {
    800071c4:	0791                	addi	a5,a5,4
    800071c6:	fed798e3          	bne	a5,a3,800071b6 <synchronize_rcu+0x1c>

  // Detach the callback list under the lock.
  acquire(&rcu_lock);
    800071ca:	00030917          	auipc	s2,0x30
    800071ce:	68690913          	addi	s2,s2,1670 # 80037850 <rcu_lock>
    800071d2:	854a                	mv	a0,s2
    800071d4:	ffffa097          	auipc	ra,0xffffa
    800071d8:	9c8080e7          	jalr	-1592(ra) # 80000b9c <acquire>
  struct rcu_head *h = defer_list;
    800071dc:	00003797          	auipc	a5,0x3
    800071e0:	2a478793          	addi	a5,a5,676 # 8000a480 <defer_list>
    800071e4:	6384                	ld	s1,0(a5)
  defer_list = 0;
    800071e6:	0007b023          	sd	zero,0(a5)
  release(&rcu_lock);
    800071ea:	854a                	mv	a0,s2
    800071ec:	ffffa097          	auipc	ra,0xffffa
    800071f0:	a80080e7          	jalr	-1408(ra) # 80000c6c <release>

  // Run callbacks without holding rcu_lock.
  while (h) {
    800071f4:	c491                	beqz	s1,80007200 <synchronize_rcu+0x66>
    struct rcu_head *next = h->next;
    800071f6:	8526                	mv	a0,s1
    800071f8:	6484                	ld	s1,8(s1)
    h->func(h);
    800071fa:	611c                	ld	a5,0(a0)
    800071fc:	9782                	jalr	a5
  while (h) {
    800071fe:	fce5                	bnez	s1,800071f6 <synchronize_rcu+0x5c>
    h = next;
  }
}
    80007200:	60e2                	ld	ra,24(sp)
    80007202:	6442                	ld	s0,16(sp)
    80007204:	64a2                	ld	s1,8(sp)
    80007206:	6902                	ld	s2,0(sp)
    80007208:	6105                	addi	sp,sp,32
    8000720a:	8082                	ret

000000008000720c <rcu_poll>:

void
rcu_poll(void)
{
    8000720c:	1101                	addi	sp,sp,-32
    8000720e:	ec06                	sd	ra,24(sp)
    80007210:	e822                	sd	s0,16(sp)
    80007212:	e426                	sd	s1,8(sp)
    80007214:	e04a                	sd	s2,0(sp)
    80007216:	1000                	addi	s0,sp,32
  // Fast check: if there is nothing to reclaim, return immediately.
  acquire(&rcu_lock);
    80007218:	00030497          	auipc	s1,0x30
    8000721c:	63848493          	addi	s1,s1,1592 # 80037850 <rcu_lock>
    80007220:	8526                	mv	a0,s1
    80007222:	ffffa097          	auipc	ra,0xffffa
    80007226:	97a080e7          	jalr	-1670(ra) # 80000b9c <acquire>
  int empty = (defer_list == 0);
    8000722a:	00003917          	auipc	s2,0x3
    8000722e:	25693903          	ld	s2,598(s2) # 8000a480 <defer_list>
  release(&rcu_lock);
    80007232:	8526                	mv	a0,s1
    80007234:	ffffa097          	auipc	ra,0xffffa
    80007238:	a38080e7          	jalr	-1480(ra) # 80000c6c <release>

  if (!empty) {
    8000723c:	00090663          	beqz	s2,80007248 <rcu_poll+0x3c>
    // Wait for a grace period and run all pending callbacks.
    synchronize_rcu();
    80007240:	00000097          	auipc	ra,0x0
    80007244:	f5a080e7          	jalr	-166(ra) # 8000719a <synchronize_rcu>
  }
    80007248:	60e2                	ld	ra,24(sp)
    8000724a:	6442                	ld	s0,16(sp)
    8000724c:	64a2                	ld	s1,8(sp)
    8000724e:	6902                	ld	s2,0(sp)
    80007250:	6105                	addi	sp,sp,32
    80007252:	8082                	ret

0000000080007254 <rcu_hnode_free_cb>:
}

// RCU callback to free a node after a grace period.
static void
rcu_hnode_free_cb(struct rcu_head *head)
{
    80007254:	1141                	addi	sp,sp,-16
    80007256:	e406                	sd	ra,8(sp)
    80007258:	e022                	sd	s0,0(sp)
    8000725a:	0800                	addi	s0,sp,16
  struct rcu_hnode *node = container_of(head, struct rcu_hnode, rcu);
  kfree((void *)node);
    8000725c:	ffff9097          	auipc	ra,0xffff9
    80007260:	6ea080e7          	jalr	1770(ra) # 80000946 <kfree>
}
    80007264:	60a2                	ld	ra,8(sp)
    80007266:	6402                	ld	s0,0(sp)
    80007268:	0141                	addi	sp,sp,16
    8000726a:	8082                	ret

000000008000726c <rcu_hash_init>:
{
    8000726c:	7139                	addi	sp,sp,-64
    8000726e:	fc06                	sd	ra,56(sp)
    80007270:	f822                	sd	s0,48(sp)
    80007272:	f426                	sd	s1,40(sp)
    80007274:	f04a                	sd	s2,32(sp)
    80007276:	ec4e                	sd	s3,24(sp)
    80007278:	e852                	sd	s4,16(sp)
    8000727a:	e456                	sd	s5,8(sp)
    8000727c:	0080                	addi	s0,sp,64
    8000727e:	89aa                	mv	s3,a0
  ht->lock = (struct spinlock *)kalloc();
    80007280:	ffff9097          	auipc	ra,0xffff9
    80007284:	7cc080e7          	jalr	1996(ra) # 80000a4c <kalloc>
    80007288:	00a9b023          	sd	a0,0(s3)
  if (ht->lock == 0) {
    8000728c:	c131                	beqz	a0,800072d0 <rcu_hash_init+0x64>
    8000728e:	00898493          	addi	s1,s3,8
    80007292:	20898a93          	addi	s5,s3,520
    80007296:	4901                	li	s2,0
    initlock(&ht->lock[i], "rcu_ht");
    80007298:	00003a17          	auipc	s4,0x3
    8000729c:	c68a0a13          	addi	s4,s4,-920 # 80009f00 <syscalls+0x5d0>
    800072a0:	0009b503          	ld	a0,0(s3)
    800072a4:	85d2                	mv	a1,s4
    800072a6:	954a                	add	a0,a0,s2
    800072a8:	ffffa097          	auipc	ra,0xffffa
    800072ac:	81e080e7          	jalr	-2018(ra) # 80000ac6 <initlock>
    ht->bucket[i] = 0;
    800072b0:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < RCU_HT_NBUCKET; i++) {
    800072b4:	02090913          	addi	s2,s2,32
    800072b8:	04a1                	addi	s1,s1,8
    800072ba:	ff5493e3          	bne	s1,s5,800072a0 <rcu_hash_init+0x34>
}
    800072be:	70e2                	ld	ra,56(sp)
    800072c0:	7442                	ld	s0,48(sp)
    800072c2:	74a2                	ld	s1,40(sp)
    800072c4:	7902                	ld	s2,32(sp)
    800072c6:	69e2                	ld	s3,24(sp)
    800072c8:	6a42                	ld	s4,16(sp)
    800072ca:	6aa2                	ld	s5,8(sp)
    800072cc:	6121                	addi	sp,sp,64
    800072ce:	8082                	ret
    panic("rcu_hash_init: no memory for locks");
    800072d0:	00003517          	auipc	a0,0x3
    800072d4:	c0850513          	addi	a0,a0,-1016 # 80009ed8 <syscalls+0x5a8>
    800072d8:	ffff9097          	auipc	ra,0xffff9
    800072dc:	292080e7          	jalr	658(ra) # 8000056a <panic>

00000000800072e0 <rcu_hash_insert>:

// Insert a new (key, value) if key is not present.
int
rcu_hash_insert(struct rcu_hash_table *ht, uint64 key, uint64 value)
{
    800072e0:	7139                	addi	sp,sp,-64
    800072e2:	fc06                	sd	ra,56(sp)
    800072e4:	f822                	sd	s0,48(sp)
    800072e6:	f426                	sd	s1,40(sp)
    800072e8:	f04a                	sd	s2,32(sp)
    800072ea:	ec4e                	sd	s3,24(sp)
    800072ec:	e852                	sd	s4,16(sp)
    800072ee:	e456                	sd	s5,8(sp)
    800072f0:	0080                	addi	s0,sp,64
    800072f2:	89aa                	mv	s3,a0
    800072f4:	84ae                	mv	s1,a1
    800072f6:	8a32                	mv	s4,a2
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);
    800072f8:	03f5f913          	andi	s2,a1,63
    800072fc:	00591a93          	slli	s5,s2,0x5
    80007300:	6108                	ld	a0,0(a0)
    80007302:	9556                	add	a0,a0,s5
    80007304:	ffffa097          	auipc	ra,0xffffa
    80007308:	898080e7          	jalr	-1896(ra) # 80000b9c <acquire>

  // Reject duplicate keys for simplicity.
  struct rcu_hnode *p = ht->bucket[idx];
    8000730c:	090e                	slli	s2,s2,0x3
    8000730e:	994e                	add	s2,s2,s3
    80007310:	00893783          	ld	a5,8(s2)
  while (p) {
    80007314:	c791                	beqz	a5,80007320 <rcu_hash_insert+0x40>
    if (p->key == key) {
    80007316:	6f98                	ld	a4,24(a5)
    80007318:	04970463          	beq	a4,s1,80007360 <rcu_hash_insert+0x80>
      release(&ht->lock[idx]);
      return -1;
    }
    p = p->next;
    8000731c:	6b9c                	ld	a5,16(a5)
  while (p) {
    8000731e:	ffe5                	bnez	a5,80007316 <rcu_hash_insert+0x36>
  }

  struct rcu_hnode *node = (struct rcu_hnode *)kalloc();
    80007320:	ffff9097          	auipc	ra,0xffff9
    80007324:	72c080e7          	jalr	1836(ra) # 80000a4c <kalloc>
  if (node == 0) {
    80007328:	c529                	beqz	a0,80007372 <rcu_hash_insert+0x92>
    release(&ht->lock[idx]);
    return -1;
  }

  node->key = key;
    8000732a:	ed04                	sd	s1,24(a0)
  node->value = value;
    8000732c:	03453023          	sd	s4,32(a0)

  // Insert at bucket head.
  node->next = ht->bucket[idx];
    80007330:	00893783          	ld	a5,8(s2)
    80007334:	e91c                	sd	a5,16(a0)
  rcu_assign_pointer(ht->bucket[idx], node);
    80007336:	0ff0000f          	fence
    8000733a:	00a93423          	sd	a0,8(s2)

  release(&ht->lock[idx]);
    8000733e:	0009b503          	ld	a0,0(s3)
    80007342:	9556                	add	a0,a0,s5
    80007344:	ffffa097          	auipc	ra,0xffffa
    80007348:	928080e7          	jalr	-1752(ra) # 80000c6c <release>
  return 0;
    8000734c:	4501                	li	a0,0
}
    8000734e:	70e2                	ld	ra,56(sp)
    80007350:	7442                	ld	s0,48(sp)
    80007352:	74a2                	ld	s1,40(sp)
    80007354:	7902                	ld	s2,32(sp)
    80007356:	69e2                	ld	s3,24(sp)
    80007358:	6a42                	ld	s4,16(sp)
    8000735a:	6aa2                	ld	s5,8(sp)
    8000735c:	6121                	addi	sp,sp,64
    8000735e:	8082                	ret
      release(&ht->lock[idx]);
    80007360:	0009b503          	ld	a0,0(s3)
    80007364:	9556                	add	a0,a0,s5
    80007366:	ffffa097          	auipc	ra,0xffffa
    8000736a:	906080e7          	jalr	-1786(ra) # 80000c6c <release>
      return -1;
    8000736e:	557d                	li	a0,-1
    80007370:	bff9                	j	8000734e <rcu_hash_insert+0x6e>
    release(&ht->lock[idx]);
    80007372:	0009b503          	ld	a0,0(s3)
    80007376:	9556                	add	a0,a0,s5
    80007378:	ffffa097          	auipc	ra,0xffffa
    8000737c:	8f4080e7          	jalr	-1804(ra) # 80000c6c <release>
    return -1;
    80007380:	557d                	li	a0,-1
    80007382:	b7f1                	j	8000734e <rcu_hash_insert+0x6e>

0000000080007384 <rcu_hash_lookup>:

// Lookup must be called inside an RCU read-side critical section.
int
rcu_hash_lookup(struct rcu_hash_table *ht, uint64 key, uint64 *valuep)
{
    80007384:	7179                	addi	sp,sp,-48
    80007386:	f406                	sd	ra,40(sp)
    80007388:	f022                	sd	s0,32(sp)
    8000738a:	ec26                	sd	s1,24(sp)
    8000738c:	e84a                	sd	s2,16(sp)
    8000738e:	e44e                	sd	s3,8(sp)
    80007390:	1800                	addi	s0,sp,48
    80007392:	892a                	mv	s2,a0
    80007394:	84ae                	mv	s1,a1
    80007396:	89b2                	mv	s3,a2
  int idx = hash_key(key);
  int found = 0;

  rcu_read_lock();
    80007398:	00000097          	auipc	ra,0x0
    8000739c:	d4c080e7          	jalr	-692(ra) # 800070e4 <rcu_read_lock>

  struct rcu_hnode *p = rcu_dereference(ht->bucket[idx]);
    800073a0:	0ff0000f          	fence
    800073a4:	03f4f513          	andi	a0,s1,63
    800073a8:	050e                	slli	a0,a0,0x3
    800073aa:	992a                	add	s2,s2,a0
    800073ac:	00893783          	ld	a5,8(s2)
  while (p) {
    800073b0:	cb95                	beqz	a5,800073e4 <rcu_hash_lookup+0x60>
    if (p->key == key) {
    800073b2:	6f98                	ld	a4,24(a5)
    800073b4:	02970163          	beq	a4,s1,800073d6 <rcu_hash_lookup+0x52>
      if (valuep)
        *valuep = p->value;
      found = 1;
      break;
    }
    p = p->next;
    800073b8:	6b9c                	ld	a5,16(a5)
  while (p) {
    800073ba:	ffe5                	bnez	a5,800073b2 <rcu_hash_lookup+0x2e>
  int found = 0;
    800073bc:	4481                	li	s1,0
  }

  rcu_read_unlock();
    800073be:	00000097          	auipc	ra,0x0
    800073c2:	d5e080e7          	jalr	-674(ra) # 8000711c <rcu_read_unlock>
  return found;
}
    800073c6:	8526                	mv	a0,s1
    800073c8:	70a2                	ld	ra,40(sp)
    800073ca:	7402                	ld	s0,32(sp)
    800073cc:	64e2                	ld	s1,24(sp)
    800073ce:	6942                	ld	s2,16(sp)
    800073d0:	69a2                	ld	s3,8(sp)
    800073d2:	6145                	addi	sp,sp,48
    800073d4:	8082                	ret
      found = 1;
    800073d6:	4485                	li	s1,1
      if (valuep)
    800073d8:	fe0983e3          	beqz	s3,800073be <rcu_hash_lookup+0x3a>
        *valuep = p->value;
    800073dc:	739c                	ld	a5,32(a5)
    800073de:	00f9b023          	sd	a5,0(s3)
    800073e2:	bff1                	j	800073be <rcu_hash_lookup+0x3a>
  int found = 0;
    800073e4:	4481                	li	s1,0
    800073e6:	bfe1                	j	800073be <rcu_hash_lookup+0x3a>

00000000800073e8 <rcu_hash_remove>:

// Remove a key and defer freeing its node via RCU.
int
rcu_hash_remove(struct rcu_hash_table *ht, uint64 key)
{
    800073e8:	7179                	addi	sp,sp,-48
    800073ea:	f406                	sd	ra,40(sp)
    800073ec:	f022                	sd	s0,32(sp)
    800073ee:	ec26                	sd	s1,24(sp)
    800073f0:	e84a                	sd	s2,16(sp)
    800073f2:	e44e                	sd	s3,8(sp)
    800073f4:	e052                	sd	s4,0(sp)
    800073f6:	1800                	addi	s0,sp,48
    800073f8:	89aa                	mv	s3,a0
    800073fa:	892e                	mv	s2,a1
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);
    800073fc:	03f5f493          	andi	s1,a1,63
    80007400:	00549a13          	slli	s4,s1,0x5
    80007404:	6108                	ld	a0,0(a0)
    80007406:	9552                	add	a0,a0,s4
    80007408:	ffff9097          	auipc	ra,0xffff9
    8000740c:	794080e7          	jalr	1940(ra) # 80000b9c <acquire>

  struct rcu_hnode *prev = 0;
  struct rcu_hnode *p = ht->bucket[idx];
    80007410:	048e                	slli	s1,s1,0x3
    80007412:	009986b3          	add	a3,s3,s1
    80007416:	6684                	ld	s1,8(a3)

  while (p) {
    80007418:	c891                	beqz	s1,8000742c <rcu_hash_remove+0x44>
  struct rcu_hnode *prev = 0;
    8000741a:	4701                	li	a4,0
    8000741c:	a011                	j	80007420 <rcu_hash_remove+0x38>
    if (p->key == key)
      break;
    prev = p;
    p = p->next;
    8000741e:	84be                	mv	s1,a5
    if (p->key == key)
    80007420:	6c9c                	ld	a5,24(s1)
    80007422:	03278363          	beq	a5,s2,80007448 <rcu_hash_remove+0x60>
    p = p->next;
    80007426:	689c                	ld	a5,16(s1)
  while (p) {
    80007428:	8726                	mv	a4,s1
    8000742a:	fbf5                	bnez	a5,8000741e <rcu_hash_remove+0x36>
  }

  if (p == 0) {
    release(&ht->lock[idx]);
    8000742c:	0009b503          	ld	a0,0(s3)
    80007430:	9552                	add	a0,a0,s4
    80007432:	ffffa097          	auipc	ra,0xffffa
    80007436:	83a080e7          	jalr	-1990(ra) # 80000c6c <release>
    return 0;
    8000743a:	4501                	li	a0,0
    8000743c:	a815                	j	80007470 <rcu_hash_remove+0x88>

  // Unlink from the bucket list.
  if (prev)
    prev->next = p->next;
  else
    rcu_assign_pointer(ht->bucket[idx], p->next);
    8000743e:	0ff0000f          	fence
    80007442:	689c                	ld	a5,16(s1)
    80007444:	e69c                	sd	a5,8(a3)
    80007446:	a021                	j	8000744e <rcu_hash_remove+0x66>
  if (prev)
    80007448:	db7d                	beqz	a4,8000743e <rcu_hash_remove+0x56>
    prev->next = p->next;
    8000744a:	689c                	ld	a5,16(s1)
    8000744c:	eb1c                	sd	a5,16(a4)

  release(&ht->lock[idx]);
    8000744e:	0009b503          	ld	a0,0(s3)
    80007452:	9552                	add	a0,a0,s4
    80007454:	ffffa097          	auipc	ra,0xffffa
    80007458:	818080e7          	jalr	-2024(ra) # 80000c6c <release>

  // Actual free happens after a grace period.
  call_rcu(&p->rcu, rcu_hnode_free_cb);
    8000745c:	00000597          	auipc	a1,0x0
    80007460:	df858593          	addi	a1,a1,-520 # 80007254 <rcu_hnode_free_cb>
    80007464:	8526                	mv	a0,s1
    80007466:	00000097          	auipc	ra,0x0
    8000746a:	cee080e7          	jalr	-786(ra) # 80007154 <call_rcu>
  return 1;
    8000746e:	4505                	li	a0,1
}
    80007470:	70a2                	ld	ra,40(sp)
    80007472:	7402                	ld	s0,32(sp)
    80007474:	64e2                	ld	s1,24(sp)
    80007476:	6942                	ld	s2,16(sp)
    80007478:	69a2                	ld	s3,8(sp)
    8000747a:	6a02                	ld	s4,0(sp)
    8000747c:	6145                	addi	sp,sp,48
    8000747e:	8082                	ret

0000000080007480 <rcu_free_callback>:
}

// Callback executed after the grace period.
static void
rcu_free_callback(struct rcu_head *head)
{
    80007480:	1101                	addi	sp,sp,-32
    80007482:	ec06                	sd	ra,24(sp)
    80007484:	e822                	sd	s0,16(sp)
    80007486:	e426                	sd	s1,8(sp)
    80007488:	1000                	addi	s0,sp,32
    8000748a:	84aa                	mv	s1,a0
    rcu_callback_counter++;
    8000748c:	00003717          	auipc	a4,0x3
    80007490:	01c70713          	addi	a4,a4,28 # 8000a4a8 <rcu_callback_counter>
    80007494:	631c                	ld	a5,0(a4)
    80007496:	0785                	addi	a5,a5,1
    80007498:	e31c                	sd	a5,0(a4)
    struct test_data *d = rcu_to_test_data(head);
    printf("[callback] free old value=%d\n", d->value);
    8000749a:	ff852583          	lw	a1,-8(a0)
    8000749e:	00003517          	auipc	a0,0x3
    800074a2:	a6a50513          	addi	a0,a0,-1430 # 80009f08 <syscalls+0x5d8>
    800074a6:	ffff9097          	auipc	ra,0xffff9
    800074aa:	126080e7          	jalr	294(ra) # 800005cc <printf>
    kfree((char *)d);
    800074ae:	ff848513          	addi	a0,s1,-8
    800074b2:	ffff9097          	auipc	ra,0xffff9
    800074b6:	494080e7          	jalr	1172(ra) # 80000946 <kfree>
}
    800074ba:	60e2                	ld	ra,24(sp)
    800074bc:	6442                	ld	s0,16(sp)
    800074be:	64a2                	ld	s1,8(sp)
    800074c0:	6105                	addi	sp,sp,32
    800074c2:	8082                	ret

00000000800074c4 <rwlock_init>:
{
    800074c4:	1101                	addi	sp,sp,-32
    800074c6:	ec06                	sd	ra,24(sp)
    800074c8:	e822                	sd	s0,16(sp)
    800074ca:	e426                	sd	s1,8(sp)
    800074cc:	1000                	addi	s0,sp,32
    800074ce:	84aa                	mv	s1,a0
  initlock(&lk->lock, name);
    800074d0:	ffff9097          	auipc	ra,0xffff9
    800074d4:	5f6080e7          	jalr	1526(ra) # 80000ac6 <initlock>
  lk->readers = 0;
    800074d8:	0204a023          	sw	zero,32(s1)
  lk->writer = 0;
    800074dc:	0204a223          	sw	zero,36(s1)
}
    800074e0:	60e2                	ld	ra,24(sp)
    800074e2:	6442                	ld	s0,16(sp)
    800074e4:	64a2                	ld	s1,8(sp)
    800074e6:	6105                	addi	sp,sp,32
    800074e8:	8082                	ret

00000000800074ea <rlock>:
{
    800074ea:	1101                	addi	sp,sp,-32
    800074ec:	ec06                	sd	ra,24(sp)
    800074ee:	e822                	sd	s0,16(sp)
    800074f0:	e426                	sd	s1,8(sp)
    800074f2:	e04a                	sd	s2,0(sp)
    800074f4:	1000                	addi	s0,sp,32
    800074f6:	892a                	mv	s2,a0
    acquire(&lk->lock);
    800074f8:	84aa                	mv	s1,a0
    800074fa:	8526                	mv	a0,s1
    800074fc:	ffff9097          	auipc	ra,0xffff9
    80007500:	6a0080e7          	jalr	1696(ra) # 80000b9c <acquire>
    if (lk->writer == 0) {
    80007504:	02492783          	lw	a5,36(s2)
    80007508:	c799                	beqz	a5,80007516 <rlock+0x2c>
    release(&lk->lock);
    8000750a:	8526                	mv	a0,s1
    8000750c:	ffff9097          	auipc	ra,0xffff9
    80007510:	760080e7          	jalr	1888(ra) # 80000c6c <release>
    acquire(&lk->lock);
    80007514:	b7dd                	j	800074fa <rlock+0x10>
      lk->readers++;
    80007516:	02092783          	lw	a5,32(s2)
    8000751a:	2785                	addiw	a5,a5,1
    8000751c:	02f92023          	sw	a5,32(s2)
      release(&lk->lock);
    80007520:	8526                	mv	a0,s1
    80007522:	ffff9097          	auipc	ra,0xffff9
    80007526:	74a080e7          	jalr	1866(ra) # 80000c6c <release>
}
    8000752a:	60e2                	ld	ra,24(sp)
    8000752c:	6442                	ld	s0,16(sp)
    8000752e:	64a2                	ld	s1,8(sp)
    80007530:	6902                	ld	s2,0(sp)
    80007532:	6105                	addi	sp,sp,32
    80007534:	8082                	ret

0000000080007536 <runlock>:
{
    80007536:	1101                	addi	sp,sp,-32
    80007538:	ec06                	sd	ra,24(sp)
    8000753a:	e822                	sd	s0,16(sp)
    8000753c:	e426                	sd	s1,8(sp)
    8000753e:	1000                	addi	s0,sp,32
    80007540:	84aa                	mv	s1,a0
  acquire(&lk->lock);
    80007542:	ffff9097          	auipc	ra,0xffff9
    80007546:	65a080e7          	jalr	1626(ra) # 80000b9c <acquire>
  lk->readers--;
    8000754a:	509c                	lw	a5,32(s1)
    8000754c:	37fd                	addiw	a5,a5,-1
    8000754e:	d09c                	sw	a5,32(s1)
  release(&lk->lock);
    80007550:	8526                	mv	a0,s1
    80007552:	ffff9097          	auipc	ra,0xffff9
    80007556:	71a080e7          	jalr	1818(ra) # 80000c6c <release>
}
    8000755a:	60e2                	ld	ra,24(sp)
    8000755c:	6442                	ld	s0,16(sp)
    8000755e:	64a2                	ld	s1,8(sp)
    80007560:	6105                	addi	sp,sp,32
    80007562:	8082                	ret

0000000080007564 <wlock>:
{
    80007564:	1101                	addi	sp,sp,-32
    80007566:	ec06                	sd	ra,24(sp)
    80007568:	e822                	sd	s0,16(sp)
    8000756a:	e426                	sd	s1,8(sp)
    8000756c:	e04a                	sd	s2,0(sp)
    8000756e:	1000                	addi	s0,sp,32
    80007570:	892a                	mv	s2,a0
    acquire(&lk->lock);
    80007572:	84aa                	mv	s1,a0
    80007574:	8526                	mv	a0,s1
    80007576:	ffff9097          	auipc	ra,0xffff9
    8000757a:	626080e7          	jalr	1574(ra) # 80000b9c <acquire>
    if (lk->writer == 0 && lk->readers == 0) {
    8000757e:	02093783          	ld	a5,32(s2)
    80007582:	c799                	beqz	a5,80007590 <wlock+0x2c>
    release(&lk->lock);
    80007584:	8526                	mv	a0,s1
    80007586:	ffff9097          	auipc	ra,0xffff9
    8000758a:	6e6080e7          	jalr	1766(ra) # 80000c6c <release>
    acquire(&lk->lock);
    8000758e:	b7dd                	j	80007574 <wlock+0x10>
      lk->writer = 1;
    80007590:	4785                	li	a5,1
    80007592:	02f92223          	sw	a5,36(s2)
      release(&lk->lock);
    80007596:	8526                	mv	a0,s1
    80007598:	ffff9097          	auipc	ra,0xffff9
    8000759c:	6d4080e7          	jalr	1748(ra) # 80000c6c <release>
}
    800075a0:	60e2                	ld	ra,24(sp)
    800075a2:	6442                	ld	s0,16(sp)
    800075a4:	64a2                	ld	s1,8(sp)
    800075a6:	6902                	ld	s2,0(sp)
    800075a8:	6105                	addi	sp,sp,32
    800075aa:	8082                	ret

00000000800075ac <wunlock>:
{
    800075ac:	1101                	addi	sp,sp,-32
    800075ae:	ec06                	sd	ra,24(sp)
    800075b0:	e822                	sd	s0,16(sp)
    800075b2:	e426                	sd	s1,8(sp)
    800075b4:	1000                	addi	s0,sp,32
    800075b6:	84aa                	mv	s1,a0
  acquire(&lk->lock);
    800075b8:	ffff9097          	auipc	ra,0xffff9
    800075bc:	5e4080e7          	jalr	1508(ra) # 80000b9c <acquire>
  lk->writer = 0;
    800075c0:	0204a223          	sw	zero,36(s1)
  release(&lk->lock);
    800075c4:	8526                	mv	a0,s1
    800075c6:	ffff9097          	auipc	ra,0xffff9
    800075ca:	6a6080e7          	jalr	1702(ra) # 80000c6c <release>
}
    800075ce:	60e2                	ld	ra,24(sp)
    800075d0:	6442                	ld	s0,16(sp)
    800075d2:	64a2                	ld	s1,8(sp)
    800075d4:	6105                	addi	sp,sp,32
    800075d6:	8082                	ret

00000000800075d8 <test_rcu>:

void test_rcu(void)
{
    800075d8:	1101                	addi	sp,sp,-32
    800075da:	ec06                	sd	ra,24(sp)
    800075dc:	e822                	sd	s0,16(sp)
    800075de:	e426                	sd	s1,8(sp)
    800075e0:	e04a                	sd	s2,0(sp)
    800075e2:	1000                	addi	s0,sp,32
    printf("=== RCU test start ===\n");
    800075e4:	00003517          	auipc	a0,0x3
    800075e8:	94450513          	addi	a0,a0,-1724 # 80009f28 <syscalls+0x5f8>
    800075ec:	ffff9097          	auipc	ra,0xffff9
    800075f0:	fe0080e7          	jalr	-32(ra) # 800005cc <printf>

    struct test_data *d1 = (struct test_data *)kalloc();
    800075f4:	ffff9097          	auipc	ra,0xffff9
    800075f8:	458080e7          	jalr	1112(ra) # 80000a4c <kalloc>
    if (!d1)
    800075fc:	c54d                	beqz	a0,800076a6 <test_rcu+0xce>
    {
        printf("kalloc failed\n");
        return;
    }
    d1->value = 100;
    800075fe:	06400793          	li	a5,100
    80007602:	c11c                	sw	a5,0(a0)

    rcu_assign_pointer(global_test_ptr, d1);
    80007604:	0ff0000f          	fence
    80007608:	00003497          	auipc	s1,0x3
    8000760c:	e9048493          	addi	s1,s1,-368 # 8000a498 <global_test_ptr>
    80007610:	e088                	sd	a0,0(s1)
    printf("[init] global=%d\n", global_test_ptr->value);
    80007612:	410c                	lw	a1,0(a0)
    80007614:	00003517          	auipc	a0,0x3
    80007618:	93c50513          	addi	a0,a0,-1732 # 80009f50 <syscalls+0x620>
    8000761c:	ffff9097          	auipc	ra,0xffff9
    80007620:	fb0080e7          	jalr	-80(ra) # 800005cc <printf>

    // reader
    rcu_read_lock();
    80007624:	00000097          	auipc	ra,0x0
    80007628:	ac0080e7          	jalr	-1344(ra) # 800070e4 <rcu_read_lock>
    struct test_data *local = rcu_dereference(global_test_ptr);
    8000762c:	0ff0000f          	fence
    printf("[reader] read value=%d\n", local->value);
    80007630:	609c                	ld	a5,0(s1)
    80007632:	438c                	lw	a1,0(a5)
    80007634:	00003517          	auipc	a0,0x3
    80007638:	93450513          	addi	a0,a0,-1740 # 80009f68 <syscalls+0x638>
    8000763c:	ffff9097          	auipc	ra,0xffff9
    80007640:	f90080e7          	jalr	-112(ra) # 800005cc <printf>
    rcu_read_unlock();
    80007644:	00000097          	auipc	ra,0x0
    80007648:	ad8080e7          	jalr	-1320(ra) # 8000711c <rcu_read_unlock>

    struct test_data *d2 = (struct test_data *)kalloc();
    8000764c:	ffff9097          	auipc	ra,0xffff9
    80007650:	400080e7          	jalr	1024(ra) # 80000a4c <kalloc>
    d2->value = 200;
    80007654:	0c800793          	li	a5,200
    80007658:	c11c                	sw	a5,0(a0)

    struct test_data *old = global_test_ptr;
    8000765a:	0004b903          	ld	s2,0(s1)
    rcu_assign_pointer(global_test_ptr, d2);
    8000765e:	0ff0000f          	fence
    80007662:	e088                	sd	a0,0(s1)

    printf("[writer] updated global to %d\n", global_test_ptr->value);
    80007664:	410c                	lw	a1,0(a0)
    80007666:	00003517          	auipc	a0,0x3
    8000766a:	91a50513          	addi	a0,a0,-1766 # 80009f80 <syscalls+0x650>
    8000766e:	ffff9097          	auipc	ra,0xffff9
    80007672:	f5e080e7          	jalr	-162(ra) # 800005cc <printf>

    call_rcu(&old->rcu, rcu_free_callback);
    80007676:	00000597          	auipc	a1,0x0
    8000767a:	e0a58593          	addi	a1,a1,-502 # 80007480 <rcu_free_callback>
    8000767e:	00890513          	addi	a0,s2,8
    80007682:	00000097          	auipc	ra,0x0
    80007686:	ad2080e7          	jalr	-1326(ra) # 80007154 <call_rcu>

    printf("=== RCU test done ===\n");
    8000768a:	00003517          	auipc	a0,0x3
    8000768e:	91650513          	addi	a0,a0,-1770 # 80009fa0 <syscalls+0x670>
    80007692:	ffff9097          	auipc	ra,0xffff9
    80007696:	f3a080e7          	jalr	-198(ra) # 800005cc <printf>
}
    8000769a:	60e2                	ld	ra,24(sp)
    8000769c:	6442                	ld	s0,16(sp)
    8000769e:	64a2                	ld	s1,8(sp)
    800076a0:	6902                	ld	s2,0(sp)
    800076a2:	6105                	addi	sp,sp,32
    800076a4:	8082                	ret
        printf("kalloc failed\n");
    800076a6:	00003517          	auipc	a0,0x3
    800076aa:	89a50513          	addi	a0,a0,-1894 # 80009f40 <syscalls+0x610>
    800076ae:	ffff9097          	auipc	ra,0xffff9
    800076b2:	f1e080e7          	jalr	-226(ra) # 800005cc <printf>
        return;
    800076b6:	b7d5                	j	8000769a <test_rcu+0xc2>

00000000800076b8 <rcu_read_only>:

void rcu_read_only(void)
{
    800076b8:	1101                	addi	sp,sp,-32
    800076ba:	ec06                	sd	ra,24(sp)
    800076bc:	e822                	sd	s0,16(sp)
    800076be:	e426                	sd	s1,8(sp)
    800076c0:	e04a                	sd	s2,0(sp)
    800076c2:	1000                	addi	s0,sp,32
    printf("=== RCU read-only test ===\n");
    800076c4:	00003517          	auipc	a0,0x3
    800076c8:	8f450513          	addi	a0,a0,-1804 # 80009fb8 <syscalls+0x688>
    800076cc:	ffff9097          	auipc	ra,0xffff9
    800076d0:	f00080e7          	jalr	-256(ra) # 800005cc <printf>

    uint64 read_count = 0;
    uint64 start = ticks; // start time in ticks
    800076d4:	00003917          	auipc	s2,0x3
    800076d8:	d8c96903          	lwu	s2,-628(s2) # 8000a460 <ticks>
    800076dc:	009894b7          	lui	s1,0x989
    800076e0:	68048493          	addi	s1,s1,1664 # 989680 <_entry-0x7f676980>

    int iter = 10 * 1000 * 1000; // run more to get meaningful data
    for (int i = 0; i < iter; i++)
    {
        rcu_read_lock();
    800076e4:	00000097          	auipc	ra,0x0
    800076e8:	a00080e7          	jalr	-1536(ra) # 800070e4 <rcu_read_lock>
        struct test_data *p = rcu_dereference(global_test_ptr);
    800076ec:	0ff0000f          	fence
        if (p)
        {
            int v = p->value;
            (void)v;
        }
        rcu_read_unlock();
    800076f0:	00000097          	auipc	ra,0x0
    800076f4:	a2c080e7          	jalr	-1492(ra) # 8000711c <rcu_read_unlock>
    for (int i = 0; i < iter; i++)
    800076f8:	34fd                	addiw	s1,s1,-1
    800076fa:	f4ed                	bnez	s1,800076e4 <rcu_read_only+0x2c>
        read_count++;
    }

    uint64 end = ticks; // end time
    800076fc:	00003497          	auipc	s1,0x3
    80007700:	d644e483          	lwu	s1,-668(s1) # 8000a460 <ticks>
    uint64 duration = end - start;
    80007704:	412484b3          	sub	s1,s1,s2

    printf("read-only test done\n");
    80007708:	00003517          	auipc	a0,0x3
    8000770c:	8d050513          	addi	a0,a0,-1840 # 80009fd8 <syscalls+0x6a8>
    80007710:	ffff9097          	auipc	ra,0xffff9
    80007714:	ebc080e7          	jalr	-324(ra) # 800005cc <printf>
    printf("Total read operations: %u\n", read_count);
    80007718:	009895b7          	lui	a1,0x989
    8000771c:	68058593          	addi	a1,a1,1664 # 989680 <_entry-0x7f676980>
    80007720:	00003517          	auipc	a0,0x3
    80007724:	8d050513          	addi	a0,a0,-1840 # 80009ff0 <syscalls+0x6c0>
    80007728:	ffff9097          	auipc	ra,0xffff9
    8000772c:	ea4080e7          	jalr	-348(ra) # 800005cc <printf>
    printf("Total time: %u ticks\n", duration);
    80007730:	85a6                	mv	a1,s1
    80007732:	00003517          	auipc	a0,0x3
    80007736:	8de50513          	addi	a0,a0,-1826 # 8000a010 <syscalls+0x6e0>
    8000773a:	ffff9097          	auipc	ra,0xffff9
    8000773e:	e92080e7          	jalr	-366(ra) # 800005cc <printf>

    if (duration > 0)
    80007742:	c48d                	beqz	s1,8000776c <rcu_read_only+0xb4>
    {
        printf("Reads per tick: %u\n", read_count / duration);
    80007744:	009895b7          	lui	a1,0x989
    80007748:	68058593          	addi	a1,a1,1664 # 989680 <_entry-0x7f676980>
    8000774c:	0295d5b3          	divu	a1,a1,s1
    80007750:	00003517          	auipc	a0,0x3
    80007754:	8d850513          	addi	a0,a0,-1832 # 8000a028 <syscalls+0x6f8>
    80007758:	ffff9097          	auipc	ra,0xffff9
    8000775c:	e74080e7          	jalr	-396(ra) # 800005cc <printf>
    }
    else
    {
        printf("Duration < 1 tick, measurement too small.\n");
    }
}
    80007760:	60e2                	ld	ra,24(sp)
    80007762:	6442                	ld	s0,16(sp)
    80007764:	64a2                	ld	s1,8(sp)
    80007766:	6902                	ld	s2,0(sp)
    80007768:	6105                	addi	sp,sp,32
    8000776a:	8082                	ret
        printf("Duration < 1 tick, measurement too small.\n");
    8000776c:	00003517          	auipc	a0,0x3
    80007770:	8d450513          	addi	a0,a0,-1836 # 8000a040 <syscalls+0x710>
    80007774:	ffff9097          	auipc	ra,0xffff9
    80007778:	e58080e7          	jalr	-424(ra) # 800005cc <printf>
}
    8000777c:	b7d5                	j	80007760 <rcu_read_only+0xa8>

000000008000777e <rcu_read_heavy>:

void
rcu_read_heavy(void)
{
    8000777e:	711d                	addi	sp,sp,-96
    80007780:	ec86                	sd	ra,88(sp)
    80007782:	e8a2                	sd	s0,80(sp)
    80007784:	e4a6                	sd	s1,72(sp)
    80007786:	e0ca                	sd	s2,64(sp)
    80007788:	fc4e                	sd	s3,56(sp)
    8000778a:	f852                	sd	s4,48(sp)
    8000778c:	f456                	sd	s5,40(sp)
    8000778e:	f05a                	sd	s6,32(sp)
    80007790:	ec5e                	sd	s7,24(sp)
    80007792:	e862                	sd	s8,16(sp)
    80007794:	e466                	sd	s9,8(sp)
    80007796:	e06a                	sd	s10,0(sp)
    80007798:	1080                	addi	s0,sp,96
  // -------------------------------
  // Part 1: RCU read-heavy test
  // -------------------------------
  printf("=== RCU read-heavy test ===\n");
    8000779a:	00003517          	auipc	a0,0x3
    8000779e:	8d650513          	addi	a0,a0,-1834 # 8000a070 <syscalls+0x740>
    800077a2:	ffff9097          	auipc	ra,0xffff9
    800077a6:	e2a080e7          	jalr	-470(ra) # 800005cc <printf>

  // reset global pointer for the test
  global_test_ptr = 0;
    800077aa:	00003797          	auipc	a5,0x3
    800077ae:	ce07b723          	sd	zero,-786(a5) # 8000a498 <global_test_ptr>

  uint64 read_count = 0;
  uint64 write_count = 0;
  uint64 callback_before = rcu_callback_counter;
    800077b2:	00003c97          	auipc	s9,0x3
    800077b6:	cf6cbc83          	ld	s9,-778(s9) # 8000a4a8 <rcu_callback_counter>
  uint64 start = ticks;
    800077ba:	00003b17          	auipc	s6,0x3
    800077be:	ca6b6b03          	lwu	s6,-858(s6) # 8000a460 <ticks>
  uint64 now = start;

  // run the test for at least 10 ticks
  while (now - start < 10) {
    // RCU reader: lock, dereference, unlock
    rcu_read_lock();
    800077c2:	00000097          	auipc	ra,0x0
    800077c6:	922080e7          	jalr	-1758(ra) # 800070e4 <rcu_read_lock>
    struct test_data *p = rcu_dereference(global_test_ptr);
    800077ca:	0ff0000f          	fence
    if (p) {
      int v = p->value;
      (void)v;
    }
    rcu_read_unlock();
    800077ce:	00000097          	auipc	ra,0x0
    800077d2:	94e080e7          	jalr	-1714(ra) # 8000711c <rcu_read_unlock>
    read_count++;
    800077d6:	4905                	li	s2,1
  uint64 write_count = 0;
    800077d8:	4b81                	li	s7,0
    }

    // let scheduler/idle path run RCU callbacks
    rcu_poll();

    now = ticks;
    800077da:	00003a97          	auipc	s5,0x3
    800077de:	c86a8a93          	addi	s5,s5,-890 # 8000a460 <ticks>
  while (now - start < 10) {
    800077e2:	4a25                	li	s4,9
    if (read_count % 5000 == 0) {
    800077e4:	6985                	lui	s3,0x1
    800077e6:	38898993          	addi	s3,s3,904 # 1388 <_entry-0x7fffec78>
        struct test_data *old = global_test_ptr;
    800077ea:	00003c17          	auipc	s8,0x3
    800077ee:	caec0c13          	addi	s8,s8,-850 # 8000a498 <global_test_ptr>
          call_rcu(&old->rcu, rcu_free_callback);
    800077f2:	00000d17          	auipc	s10,0x0
    800077f6:	c8ed0d13          	addi	s10,s10,-882 # 80007480 <rcu_free_callback>
    rcu_poll();
    800077fa:	00000097          	auipc	ra,0x0
    800077fe:	a12080e7          	jalr	-1518(ra) # 8000720c <rcu_poll>
    now = ticks;
    80007802:	000ae483          	lwu	s1,0(s5)
  while (now - start < 10) {
    80007806:	416484b3          	sub	s1,s1,s6
    8000780a:	049a6763          	bltu	s4,s1,80007858 <rcu_read_heavy+0xda>
    rcu_read_lock();
    8000780e:	00000097          	auipc	ra,0x0
    80007812:	8d6080e7          	jalr	-1834(ra) # 800070e4 <rcu_read_lock>
    struct test_data *p = rcu_dereference(global_test_ptr);
    80007816:	0ff0000f          	fence
    rcu_read_unlock();
    8000781a:	00000097          	auipc	ra,0x0
    8000781e:	902080e7          	jalr	-1790(ra) # 8000711c <rcu_read_unlock>
    read_count++;
    80007822:	0905                	addi	s2,s2,1
    if (read_count % 5000 == 0) {
    80007824:	033977b3          	remu	a5,s2,s3
    80007828:	fbe9                	bnez	a5,800077fa <rcu_read_heavy+0x7c>
      struct test_data *d = (struct test_data *)kalloc();
    8000782a:	ffff9097          	auipc	ra,0xffff9
    8000782e:	222080e7          	jalr	546(ra) # 80000a4c <kalloc>
      if (d) {
    80007832:	d561                	beqz	a0,800077fa <rcu_read_heavy+0x7c>
        d->value = (int)read_count;
    80007834:	01252023          	sw	s2,0(a0)
        struct test_data *old = global_test_ptr;
    80007838:	000c3783          	ld	a5,0(s8)
        rcu_assign_pointer(global_test_ptr, d);
    8000783c:	0ff0000f          	fence
    80007840:	00ac3023          	sd	a0,0(s8)
        if (old != 0) {
    80007844:	dbdd                	beqz	a5,800077fa <rcu_read_heavy+0x7c>
          call_rcu(&old->rcu, rcu_free_callback);
    80007846:	85ea                	mv	a1,s10
    80007848:	00878513          	addi	a0,a5,8
    8000784c:	00000097          	auipc	ra,0x0
    80007850:	908080e7          	jalr	-1784(ra) # 80007154 <call_rcu>
          write_count++;
    80007854:	0b85                	addi	s7,s7,1
    80007856:	b755                	j	800077fa <rcu_read_heavy+0x7c>
  }

  uint64 duration = now - start;
  uint64 callback_after = rcu_callback_counter;
  uint64 callbacks_executed = callback_after - callback_before;
    80007858:	00003797          	auipc	a5,0x3
    8000785c:	c507b783          	ld	a5,-944(a5) # 8000a4a8 <rcu_callback_counter>
    80007860:	41978cb3          	sub	s9,a5,s9

  printf("[RCU] duration ticks: %d\n", (int)duration);
    80007864:	0004859b          	sext.w	a1,s1
    80007868:	00003517          	auipc	a0,0x3
    8000786c:	82850513          	addi	a0,a0,-2008 # 8000a090 <syscalls+0x760>
    80007870:	ffff9097          	auipc	ra,0xffff9
    80007874:	d5c080e7          	jalr	-676(ra) # 800005cc <printf>
  printf("[RCU] total reads : %d\n", (int)read_count);
    80007878:	0009059b          	sext.w	a1,s2
    8000787c:	00003517          	auipc	a0,0x3
    80007880:	83450513          	addi	a0,a0,-1996 # 8000a0b0 <syscalls+0x780>
    80007884:	ffff9097          	auipc	ra,0xffff9
    80007888:	d48080e7          	jalr	-696(ra) # 800005cc <printf>
  printf("[RCU] total writes: %d\n", (int)write_count);
    8000788c:	000b859b          	sext.w	a1,s7
    80007890:	00003517          	auipc	a0,0x3
    80007894:	83850513          	addi	a0,a0,-1992 # 8000a0c8 <syscalls+0x798>
    80007898:	ffff9097          	auipc	ra,0xffff9
    8000789c:	d34080e7          	jalr	-716(ra) # 800005cc <printf>
  printf("[RCU] callbacks executed: %d\n", (int)callbacks_executed);
    800078a0:	000c859b          	sext.w	a1,s9
    800078a4:	00003517          	auipc	a0,0x3
    800078a8:	83c50513          	addi	a0,a0,-1988 # 8000a0e0 <syscalls+0x7b0>
    800078ac:	ffff9097          	auipc	ra,0xffff9
    800078b0:	d20080e7          	jalr	-736(ra) # 800005cc <printf>

  if (duration > 0) {
    printf("[RCU] reads per tick : %d\n",
           (int)(read_count / duration));
    800078b4:	029955b3          	divu	a1,s2,s1
    printf("[RCU] reads per tick : %d\n",
    800078b8:	2581                	sext.w	a1,a1
    800078ba:	00003517          	auipc	a0,0x3
    800078be:	84650513          	addi	a0,a0,-1978 # 8000a100 <syscalls+0x7d0>
    800078c2:	ffff9097          	auipc	ra,0xffff9
    800078c6:	d0a080e7          	jalr	-758(ra) # 800005cc <printf>
    printf("[RCU] writes per tick: %d\n",
           (int)(write_count / duration));
    800078ca:	029bd5b3          	divu	a1,s7,s1
    printf("[RCU] writes per tick: %d\n",
    800078ce:	2581                	sext.w	a1,a1
    800078d0:	00003517          	auipc	a0,0x3
    800078d4:	85050513          	addi	a0,a0,-1968 # 8000a120 <syscalls+0x7f0>
    800078d8:	ffff9097          	auipc	ra,0xffff9
    800078dc:	cf4080e7          	jalr	-780(ra) # 800005cc <printf>
  }

  // -------------------------------
  // Part 2: RW-lock read-heavy test
  // -------------------------------
  printf("=== RW-lock read-heavy test ===\n");
    800078e0:	00003517          	auipc	a0,0x3
    800078e4:	86050513          	addi	a0,a0,-1952 # 8000a140 <syscalls+0x810>
    800078e8:	ffff9097          	auipc	ra,0xffff9
    800078ec:	ce4080e7          	jalr	-796(ra) # 800005cc <printf>

  // test pointer protected by rwlock
  static struct test_data *rw_ptr = 0;
  static struct rwlock rw;

  rwlock_init(&rw, "rwbench");
    800078f0:	00030497          	auipc	s1,0x30
    800078f4:	fa048493          	addi	s1,s1,-96 # 80037890 <rw.1702>
    800078f8:	00003597          	auipc	a1,0x3
    800078fc:	87058593          	addi	a1,a1,-1936 # 8000a168 <syscalls+0x838>
    80007900:	8526                	mv	a0,s1
    80007902:	00000097          	auipc	ra,0x0
    80007906:	bc2080e7          	jalr	-1086(ra) # 800074c4 <rwlock_init>
  rw_ptr = 0;
    8000790a:	00003797          	auipc	a5,0x3
    8000790e:	b607bf23          	sd	zero,-1154(a5) # 8000a488 <rw_ptr.1701>

  uint64 rw_read_count = 0;
  uint64 rw_write_count = 0;
  uint64 start2 = ticks;
    80007912:	00003b97          	auipc	s7,0x3
    80007916:	b4ebeb83          	lwu	s7,-1202(s7) # 8000a460 <ticks>
  uint64 now2 = start2;

  while (now2 - start2 < 10) {
    // reader: shared lock
    rlock(&rw);
    8000791a:	8526                	mv	a0,s1
    8000791c:	00000097          	auipc	ra,0x0
    80007920:	bce080e7          	jalr	-1074(ra) # 800074ea <rlock>
    struct test_data *p2 = rw_ptr;
    if (p2) {
      int v2 = p2->value;
      (void)v2;
    }
    runlock(&rw);
    80007924:	8526                	mv	a0,s1
    80007926:	00000097          	auipc	ra,0x0
    8000792a:	c10080e7          	jalr	-1008(ra) # 80007536 <runlock>
    rw_read_count++;
    8000792e:	4905                	li	s2,1
  uint64 rw_write_count = 0;
    80007930:	4c01                	li	s8,0
        }
      }
      wunlock(&rw);
    }

    now2 = ticks;
    80007932:	00003b17          	auipc	s6,0x3
    80007936:	b2eb0b13          	addi	s6,s6,-1234 # 8000a460 <ticks>
  while (now2 - start2 < 10) {
    8000793a:	4aa5                	li	s5,9
    rlock(&rw);
    8000793c:	89a6                	mv	s3,s1
    if (rw_read_count % 5000 == 0) {
    8000793e:	6a05                	lui	s4,0x1
    80007940:	388a0a13          	addi	s4,s4,904 # 1388 <_entry-0x7fffec78>
        struct test_data *old2 = rw_ptr;
    80007944:	00003c97          	auipc	s9,0x3
    80007948:	b44c8c93          	addi	s9,s9,-1212 # 8000a488 <rw_ptr.1701>
    8000794c:	a031                	j	80007958 <rcu_read_heavy+0x1da>
      wunlock(&rw);
    8000794e:	854e                	mv	a0,s3
    80007950:	00000097          	auipc	ra,0x0
    80007954:	c5c080e7          	jalr	-932(ra) # 800075ac <wunlock>
    now2 = ticks;
    80007958:	000b6483          	lwu	s1,0(s6)
  while (now2 - start2 < 10) {
    8000795c:	417484b3          	sub	s1,s1,s7
    80007960:	049ae863          	bltu	s5,s1,800079b0 <rcu_read_heavy+0x232>
    rlock(&rw);
    80007964:	854e                	mv	a0,s3
    80007966:	00000097          	auipc	ra,0x0
    8000796a:	b84080e7          	jalr	-1148(ra) # 800074ea <rlock>
    runlock(&rw);
    8000796e:	854e                	mv	a0,s3
    80007970:	00000097          	auipc	ra,0x0
    80007974:	bc6080e7          	jalr	-1082(ra) # 80007536 <runlock>
    rw_read_count++;
    80007978:	0905                	addi	s2,s2,1
    if (rw_read_count % 5000 == 0) {
    8000797a:	034977b3          	remu	a5,s2,s4
    8000797e:	ffe9                	bnez	a5,80007958 <rcu_read_heavy+0x1da>
      wlock(&rw);
    80007980:	854e                	mv	a0,s3
    80007982:	00000097          	auipc	ra,0x0
    80007986:	be2080e7          	jalr	-1054(ra) # 80007564 <wlock>
      struct test_data *d2 = (struct test_data *)kalloc();
    8000798a:	ffff9097          	auipc	ra,0xffff9
    8000798e:	0c2080e7          	jalr	194(ra) # 80000a4c <kalloc>
    80007992:	87aa                	mv	a5,a0
      if (d2) {
    80007994:	dd4d                	beqz	a0,8000794e <rcu_read_heavy+0x1d0>
        d2->value = (int)rw_read_count;
    80007996:	01252023          	sw	s2,0(a0)
        struct test_data *old2 = rw_ptr;
    8000799a:	000cb503          	ld	a0,0(s9)
        rw_ptr = d2;
    8000799e:	00fcb023          	sd	a5,0(s9)
        if (old2) {
    800079a2:	d555                	beqz	a0,8000794e <rcu_read_heavy+0x1d0>
          kfree((char *)old2);  // no RCU, safe after exclusive lock
    800079a4:	ffff9097          	auipc	ra,0xffff9
    800079a8:	fa2080e7          	jalr	-94(ra) # 80000946 <kfree>
          rw_write_count++;
    800079ac:	0c05                	addi	s8,s8,1
    800079ae:	b745                	j	8000794e <rcu_read_heavy+0x1d0>
  }

  uint64 duration2 = now2 - start2;

  printf("[RW ] duration ticks: %d\n", (int)duration2);
    800079b0:	0004859b          	sext.w	a1,s1
    800079b4:	00002517          	auipc	a0,0x2
    800079b8:	7bc50513          	addi	a0,a0,1980 # 8000a170 <syscalls+0x840>
    800079bc:	ffff9097          	auipc	ra,0xffff9
    800079c0:	c10080e7          	jalr	-1008(ra) # 800005cc <printf>
  printf("[RW ] total reads : %d\n", (int)rw_read_count);
    800079c4:	0009059b          	sext.w	a1,s2
    800079c8:	00002517          	auipc	a0,0x2
    800079cc:	7c850513          	addi	a0,a0,1992 # 8000a190 <syscalls+0x860>
    800079d0:	ffff9097          	auipc	ra,0xffff9
    800079d4:	bfc080e7          	jalr	-1028(ra) # 800005cc <printf>
  printf("[RW ] total writes: %d\n", (int)rw_write_count);
    800079d8:	000c059b          	sext.w	a1,s8
    800079dc:	00002517          	auipc	a0,0x2
    800079e0:	7cc50513          	addi	a0,a0,1996 # 8000a1a8 <syscalls+0x878>
    800079e4:	ffff9097          	auipc	ra,0xffff9
    800079e8:	be8080e7          	jalr	-1048(ra) # 800005cc <printf>

  if (duration2 > 0) {
    printf("[RW ] reads per tick : %d\n",
           (int)(rw_read_count / duration2));
    800079ec:	029955b3          	divu	a1,s2,s1
    printf("[RW ] reads per tick : %d\n",
    800079f0:	2581                	sext.w	a1,a1
    800079f2:	00002517          	auipc	a0,0x2
    800079f6:	7ce50513          	addi	a0,a0,1998 # 8000a1c0 <syscalls+0x890>
    800079fa:	ffff9097          	auipc	ra,0xffff9
    800079fe:	bd2080e7          	jalr	-1070(ra) # 800005cc <printf>
    printf("[RW ] writes per tick: %d\n",
           (int)(rw_write_count / duration2));
    80007a02:	029c55b3          	divu	a1,s8,s1
    printf("[RW ] writes per tick: %d\n",
    80007a06:	2581                	sext.w	a1,a1
    80007a08:	00002517          	auipc	a0,0x2
    80007a0c:	7d850513          	addi	a0,a0,2008 # 8000a1e0 <syscalls+0x8b0>
    80007a10:	ffff9097          	auipc	ra,0xffff9
    80007a14:	bbc080e7          	jalr	-1092(ra) # 800005cc <printf>
  }

  printf("=== read-heavy comparison done ===\n");
    80007a18:	00002517          	auipc	a0,0x2
    80007a1c:	7e850513          	addi	a0,a0,2024 # 8000a200 <syscalls+0x8d0>
    80007a20:	ffff9097          	auipc	ra,0xffff9
    80007a24:	bac080e7          	jalr	-1108(ra) # 800005cc <printf>
}
    80007a28:	60e6                	ld	ra,88(sp)
    80007a2a:	6446                	ld	s0,80(sp)
    80007a2c:	64a6                	ld	s1,72(sp)
    80007a2e:	6906                	ld	s2,64(sp)
    80007a30:	79e2                	ld	s3,56(sp)
    80007a32:	7a42                	ld	s4,48(sp)
    80007a34:	7aa2                	ld	s5,40(sp)
    80007a36:	7b02                	ld	s6,32(sp)
    80007a38:	6be2                	ld	s7,24(sp)
    80007a3a:	6c42                	ld	s8,16(sp)
    80007a3c:	6ca2                	ld	s9,8(sp)
    80007a3e:	6d02                	ld	s10,0(sp)
    80007a40:	6125                	addi	sp,sp,96
    80007a42:	8082                	ret

0000000080007a44 <rcu_read_write_mix>:


static struct test_data *mix_test_ptr = 0;

void rcu_read_write_mix(void)
{
    80007a44:	715d                	addi	sp,sp,-80
    80007a46:	e486                	sd	ra,72(sp)
    80007a48:	e0a2                	sd	s0,64(sp)
    80007a4a:	fc26                	sd	s1,56(sp)
    80007a4c:	f84a                	sd	s2,48(sp)
    80007a4e:	f44e                	sd	s3,40(sp)
    80007a50:	f052                	sd	s4,32(sp)
    80007a52:	ec56                	sd	s5,24(sp)
    80007a54:	e85a                	sd	s6,16(sp)
    80007a56:	e45e                	sd	s7,8(sp)
    80007a58:	e062                	sd	s8,0(sp)
    80007a5a:	0880                	addi	s0,sp,80
    printf("=== RCU read-write mix ===\n");
    80007a5c:	00002517          	auipc	a0,0x2
    80007a60:	7cc50513          	addi	a0,a0,1996 # 8000a228 <syscalls+0x8f8>
    80007a64:	ffff9097          	auipc	ra,0xffff9
    80007a68:	b68080e7          	jalr	-1176(ra) # 800005cc <printf>

    // --- initialization ---
    if (mix_test_ptr == 0)
    80007a6c:	00003797          	auipc	a5,0x3
    80007a70:	a247b783          	ld	a5,-1500(a5) # 8000a490 <mix_test_ptr>
    80007a74:	cb85                	beqz	a5,80007aa4 <rcu_read_write_mix+0x60>
        rcu_assign_pointer(mix_test_ptr, init);
    }

    uint64 read_count = 0;
    uint64 write_count = 0;
    uint64 callback_before = rcu_callback_counter;
    80007a76:	00003c17          	auipc	s8,0x3
    80007a7a:	a32c3c03          	ld	s8,-1486(s8) # 8000a4a8 <rcu_callback_counter>

    uint64 start = ticks;
    80007a7e:	00003b17          	auipc	s6,0x3
    80007a82:	9e2b6b03          	lwu	s6,-1566(s6) # 8000a460 <ticks>
    uint64 write_count = 0;
    80007a86:	4981                	li	s3,0
        if ((read_count % 3) == 0)
        {
            struct test_data *d = kalloc();
            d->value = read_count;

            struct test_data *old = mix_test_ptr;
    80007a88:	00003917          	auipc	s2,0x3
    80007a8c:	a0890913          	addi	s2,s2,-1528 # 8000a490 <mix_test_ptr>
            rcu_assign_pointer(mix_test_ptr, d);

            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
    80007a90:	00000b97          	auipc	s7,0x0
    80007a94:	9f0b8b93          	addi	s7,s7,-1552 # 80007480 <rcu_free_callback>
            }
            rcu_read_unlock();
            read_count++;
        }

        now = ticks;
    80007a98:	00003a97          	auipc	s5,0x3
    80007a9c:	9c8a8a93          	addi	s5,s5,-1592 # 8000a460 <ticks>
    while (now - start < 10)
    80007aa0:	4a25                	li	s4,9
    80007aa2:	a825                	j	80007ada <rcu_read_write_mix+0x96>
        struct test_data *init = kalloc();
    80007aa4:	ffff9097          	auipc	ra,0xffff9
    80007aa8:	fa8080e7          	jalr	-88(ra) # 80000a4c <kalloc>
        init->value = -1;
    80007aac:	57fd                	li	a5,-1
    80007aae:	c11c                	sw	a5,0(a0)
        rcu_assign_pointer(mix_test_ptr, init);
    80007ab0:	0ff0000f          	fence
    80007ab4:	00003797          	auipc	a5,0x3
    80007ab8:	9ca7be23          	sd	a0,-1572(a5) # 8000a490 <mix_test_ptr>
    80007abc:	bf6d                	j	80007a76 <rcu_read_write_mix+0x32>
                call_rcu(&old->rcu, rcu_free_callback);
    80007abe:	85de                	mv	a1,s7
    80007ac0:	00878513          	addi	a0,a5,8
    80007ac4:	fffff097          	auipc	ra,0xfffff
    80007ac8:	690080e7          	jalr	1680(ra) # 80007154 <call_rcu>
                write_count++;
    80007acc:	0985                	addi	s3,s3,1
        now = ticks;
    80007ace:	000ae483          	lwu	s1,0(s5)
    while (now - start < 10)
    80007ad2:	416484b3          	sub	s1,s1,s6
    80007ad6:	029a6063          	bltu	s4,s1,80007af6 <rcu_read_write_mix+0xb2>
            struct test_data *d = kalloc();
    80007ada:	ffff9097          	auipc	ra,0xffff9
    80007ade:	f72080e7          	jalr	-142(ra) # 80000a4c <kalloc>
            d->value = read_count;
    80007ae2:	00052023          	sw	zero,0(a0)
            struct test_data *old = mix_test_ptr;
    80007ae6:	00093783          	ld	a5,0(s2)
            rcu_assign_pointer(mix_test_ptr, d);
    80007aea:	0ff0000f          	fence
    80007aee:	00a93023          	sd	a0,0(s2)
            if (old != 0)
    80007af2:	f7f1                	bnez	a5,80007abe <rcu_read_write_mix+0x7a>
    80007af4:	bfe9                	j	80007ace <rcu_read_write_mix+0x8a>
    }

    uint64 duration = now - start;
    uint64 callback_after = rcu_callback_counter;
    uint64 callbacks = callback_after - callback_before;
    80007af6:	00003797          	auipc	a5,0x3
    80007afa:	9b27b783          	ld	a5,-1614(a5) # 8000a4a8 <rcu_callback_counter>
    80007afe:	41878c33          	sub	s8,a5,s8

    // --- results ---
    printf("mix test done\n");
    80007b02:	00002517          	auipc	a0,0x2
    80007b06:	74650513          	addi	a0,a0,1862 # 8000a248 <syscalls+0x918>
    80007b0a:	ffff9097          	auipc	ra,0xffff9
    80007b0e:	ac2080e7          	jalr	-1342(ra) # 800005cc <printf>
    printf("Duration: %u ticks\n", duration);
    80007b12:	85a6                	mv	a1,s1
    80007b14:	00002517          	auipc	a0,0x2
    80007b18:	74450513          	addi	a0,a0,1860 # 8000a258 <syscalls+0x928>
    80007b1c:	ffff9097          	auipc	ra,0xffff9
    80007b20:	ab0080e7          	jalr	-1360(ra) # 800005cc <printf>
    printf("Reads: %u\n", read_count);
    80007b24:	4581                	li	a1,0
    80007b26:	00002517          	auipc	a0,0x2
    80007b2a:	74a50513          	addi	a0,a0,1866 # 8000a270 <syscalls+0x940>
    80007b2e:	ffff9097          	auipc	ra,0xffff9
    80007b32:	a9e080e7          	jalr	-1378(ra) # 800005cc <printf>
    printf("Writes: %u\n", write_count);
    80007b36:	85ce                	mv	a1,s3
    80007b38:	00002517          	auipc	a0,0x2
    80007b3c:	74850513          	addi	a0,a0,1864 # 8000a280 <syscalls+0x950>
    80007b40:	ffff9097          	auipc	ra,0xffff9
    80007b44:	a8c080e7          	jalr	-1396(ra) # 800005cc <printf>
    printf("Callbacks executed: %u\n", callbacks);
    80007b48:	85e2                	mv	a1,s8
    80007b4a:	00002517          	auipc	a0,0x2
    80007b4e:	74650513          	addi	a0,a0,1862 # 8000a290 <syscalls+0x960>
    80007b52:	ffff9097          	auipc	ra,0xffff9
    80007b56:	a7a080e7          	jalr	-1414(ra) # 800005cc <printf>

    printf("Reads per tick: %u\n", read_count / duration);
    80007b5a:	4581                	li	a1,0
    80007b5c:	00002517          	auipc	a0,0x2
    80007b60:	4cc50513          	addi	a0,a0,1228 # 8000a028 <syscalls+0x6f8>
    80007b64:	ffff9097          	auipc	ra,0xffff9
    80007b68:	a68080e7          	jalr	-1432(ra) # 800005cc <printf>
    printf("Writes per tick: %u\n", write_count / duration);
    80007b6c:	0299d5b3          	divu	a1,s3,s1
    80007b70:	00002517          	auipc	a0,0x2
    80007b74:	73850513          	addi	a0,a0,1848 # 8000a2a8 <syscalls+0x978>
    80007b78:	ffff9097          	auipc	ra,0xffff9
    80007b7c:	a54080e7          	jalr	-1452(ra) # 800005cc <printf>

    double avg_latency = (double)duration / (double)(read_count + write_count);
    80007b80:	d234f7d3          	fcvt.d.lu	fa5,s1
    80007b84:	d239f753          	fcvt.d.lu	fa4,s3
    printf("Average ticks per operation: %f\n", avg_latency);
    80007b88:	1ae7f7d3          	fdiv.d	fa5,fa5,fa4
    80007b8c:	e20785d3          	fmv.x.d	a1,fa5
    80007b90:	00002517          	auipc	a0,0x2
    80007b94:	73050513          	addi	a0,a0,1840 # 8000a2c0 <syscalls+0x990>
    80007b98:	ffff9097          	auipc	ra,0xffff9
    80007b9c:	a34080e7          	jalr	-1484(ra) # 800005cc <printf>
    // {
    //     double interference =
    //         (avg_latency - read_only_avg_latency) / read_only_avg_latency;
    //     printf("Interference ratio (writer impact): %f\n", interference);
    // }
}
    80007ba0:	60a6                	ld	ra,72(sp)
    80007ba2:	6406                	ld	s0,64(sp)
    80007ba4:	74e2                	ld	s1,56(sp)
    80007ba6:	7942                	ld	s2,48(sp)
    80007ba8:	79a2                	ld	s3,40(sp)
    80007baa:	7a02                	ld	s4,32(sp)
    80007bac:	6ae2                	ld	s5,24(sp)
    80007bae:	6b42                	ld	s6,16(sp)
    80007bb0:	6ba2                	ld	s7,8(sp)
    80007bb2:	6c02                	ld	s8,0(sp)
    80007bb4:	6161                	addi	sp,sp,80
    80007bb6:	8082                	ret

0000000080007bb8 <rcu_read_stress>:

void rcu_read_stress(void)
{
    80007bb8:	7119                	addi	sp,sp,-128
    80007bba:	fc86                	sd	ra,120(sp)
    80007bbc:	f8a2                	sd	s0,112(sp)
    80007bbe:	f4a6                	sd	s1,104(sp)
    80007bc0:	f0ca                	sd	s2,96(sp)
    80007bc2:	ecce                	sd	s3,88(sp)
    80007bc4:	e8d2                	sd	s4,80(sp)
    80007bc6:	e4d6                	sd	s5,72(sp)
    80007bc8:	e0da                	sd	s6,64(sp)
    80007bca:	fc5e                	sd	s7,56(sp)
    80007bcc:	f862                	sd	s8,48(sp)
    80007bce:	f466                	sd	s9,40(sp)
    80007bd0:	f06a                	sd	s10,32(sp)
    80007bd2:	ec6e                	sd	s11,24(sp)
    80007bd4:	a422                	fsd	fs0,8(sp)
    80007bd6:	0100                	addi	s0,sp,128
    printf("=== RCU stress test ===\n");
    80007bd8:	00002517          	auipc	a0,0x2
    80007bdc:	71050513          	addi	a0,a0,1808 # 8000a2e8 <syscalls+0x9b8>
    80007be0:	ffff9097          	auipc	ra,0xffff9
    80007be4:	9ec080e7          	jalr	-1556(ra) # 800005cc <printf>

    // ---- initialize pointer once ----
    if (global_test_ptr == 0)
    80007be8:	00003797          	auipc	a5,0x3
    80007bec:	8b07b783          	ld	a5,-1872(a5) # 8000a498 <global_test_ptr>
    80007bf0:	cf85                	beqz	a5,80007c28 <rcu_read_stress+0x70>
    }

    // ---- quantitative counters ----
    uint64 read_count = 0;
    uint64 write_count = 0;
    uint64 callback_before = rcu_callback_counter;
    80007bf2:	00003d97          	auipc	s11,0x3
    80007bf6:	8b6dbd83          	ld	s11,-1866(s11) # 8000a4a8 <rcu_callback_counter>

    // measure at least 20 ticks (~200ms) to show stress behavior
    uint64 start = ticks;
    80007bfa:	00003c97          	auipc	s9,0x3
    80007bfe:	866cec83          	lwu	s9,-1946(s9) # 8000a460 <ticks>
    uint64 write_count = 0;
    80007c02:	4981                	li	s3,0
    uint64 read_count = 0;
    80007c04:	4901                	li	s2,0
    uint64 now = start;

    while (now - start < 20)
    {
        int op = write_count % 7; // change frequency of writer
    80007c06:	4a9d                	li	s5,7
            struct test_data *d = kalloc();
            if (!d)
                panic("kalloc failed");
            d->value = write_count;

            struct test_data *old = global_test_ptr;
    80007c08:	00003c17          	auipc	s8,0x3
    80007c0c:	890c0c13          	addi	s8,s8,-1904 # 8000a498 <global_test_ptr>
            rcu_assign_pointer(global_test_ptr, d);

            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
    80007c10:	00000d17          	auipc	s10,0x0
    80007c14:	870d0d13          	addi	s10,s10,-1936 # 80007480 <rcu_free_callback>
            rcu_read_unlock();
            read_count++;
        }

        // occasionally flush RCU callbacks
        if ((read_count & 0xFFF) == 0)
    80007c18:	6a05                	lui	s4,0x1
    80007c1a:	1a7d                	addi	s4,s4,-1
            rcu_poll();

        now = ticks;
    80007c1c:	00003b97          	auipc	s7,0x3
    80007c20:	844b8b93          	addi	s7,s7,-1980 # 8000a460 <ticks>
    while (now - start < 20)
    80007c24:	4b4d                	li	s6,19
    80007c26:	a891                	j	80007c7a <rcu_read_stress+0xc2>
        struct test_data *init = kalloc();
    80007c28:	ffff9097          	auipc	ra,0xffff9
    80007c2c:	e24080e7          	jalr	-476(ra) # 80000a4c <kalloc>
        init->value = -1;
    80007c30:	57fd                	li	a5,-1
    80007c32:	c11c                	sw	a5,0(a0)
        rcu_assign_pointer(global_test_ptr, init);
    80007c34:	0ff0000f          	fence
    80007c38:	00003797          	auipc	a5,0x3
    80007c3c:	86a7b023          	sd	a0,-1952(a5) # 8000a498 <global_test_ptr>
    80007c40:	bf4d                	j	80007bf2 <rcu_read_stress+0x3a>
                panic("kalloc failed");
    80007c42:	00002517          	auipc	a0,0x2
    80007c46:	6c650513          	addi	a0,a0,1734 # 8000a308 <syscalls+0x9d8>
    80007c4a:	ffff9097          	auipc	ra,0xffff9
    80007c4e:	920080e7          	jalr	-1760(ra) # 8000056a <panic>
            rcu_read_lock();
    80007c52:	fffff097          	auipc	ra,0xfffff
    80007c56:	492080e7          	jalr	1170(ra) # 800070e4 <rcu_read_lock>
            struct test_data *p = rcu_dereference(global_test_ptr);
    80007c5a:	0ff0000f          	fence
            rcu_read_unlock();
    80007c5e:	fffff097          	auipc	ra,0xfffff
    80007c62:	4be080e7          	jalr	1214(ra) # 8000711c <rcu_read_unlock>
            read_count++;
    80007c66:	0905                	addi	s2,s2,1
        if ((read_count & 0xFFF) == 0)
    80007c68:	014977b3          	and	a5,s2,s4
    80007c6c:	c3a9                	beqz	a5,80007cae <rcu_read_stress+0xf6>
        now = ticks;
    80007c6e:	000be483          	lwu	s1,0(s7)
    while (now - start < 20)
    80007c72:	419484b3          	sub	s1,s1,s9
    80007c76:	049b6163          	bltu	s6,s1,80007cb8 <rcu_read_stress+0x100>
        if (op == 0)
    80007c7a:	0359f7b3          	remu	a5,s3,s5
    80007c7e:	fbf1                	bnez	a5,80007c52 <rcu_read_stress+0x9a>
            struct test_data *d = kalloc();
    80007c80:	ffff9097          	auipc	ra,0xffff9
    80007c84:	dcc080e7          	jalr	-564(ra) # 80000a4c <kalloc>
            if (!d)
    80007c88:	dd4d                	beqz	a0,80007c42 <rcu_read_stress+0x8a>
            d->value = write_count;
    80007c8a:	01352023          	sw	s3,0(a0)
            struct test_data *old = global_test_ptr;
    80007c8e:	000c3783          	ld	a5,0(s8)
            rcu_assign_pointer(global_test_ptr, d);
    80007c92:	0ff0000f          	fence
    80007c96:	00ac3023          	sd	a0,0(s8)
            if (old != 0)
    80007c9a:	d7f9                	beqz	a5,80007c68 <rcu_read_stress+0xb0>
                call_rcu(&old->rcu, rcu_free_callback);
    80007c9c:	85ea                	mv	a1,s10
    80007c9e:	00878513          	addi	a0,a5,8
    80007ca2:	fffff097          	auipc	ra,0xfffff
    80007ca6:	4b2080e7          	jalr	1202(ra) # 80007154 <call_rcu>
                write_count++;
    80007caa:	0985                	addi	s3,s3,1
    80007cac:	bf75                	j	80007c68 <rcu_read_stress+0xb0>
            rcu_poll();
    80007cae:	fffff097          	auipc	ra,0xfffff
    80007cb2:	55e080e7          	jalr	1374(ra) # 8000720c <rcu_poll>
    80007cb6:	bf65                	j	80007c6e <rcu_read_stress+0xb6>
    }

    uint64 duration = now - start;
    uint64 callback_after = rcu_callback_counter;
    uint64 callbacks = callback_after - callback_before;
    80007cb8:	00002797          	auipc	a5,0x2
    80007cbc:	7f07b783          	ld	a5,2032(a5) # 8000a4a8 <rcu_callback_counter>
    80007cc0:	41b78db3          	sub	s11,a5,s11

    // ---- Results ----
    printf("stress test done\n");
    80007cc4:	00002517          	auipc	a0,0x2
    80007cc8:	65450513          	addi	a0,a0,1620 # 8000a318 <syscalls+0x9e8>
    80007ccc:	ffff9097          	auipc	ra,0xffff9
    80007cd0:	900080e7          	jalr	-1792(ra) # 800005cc <printf>
    printf("Duration: %u ticks\n", duration);
    80007cd4:	85a6                	mv	a1,s1
    80007cd6:	00002517          	auipc	a0,0x2
    80007cda:	58250513          	addi	a0,a0,1410 # 8000a258 <syscalls+0x928>
    80007cde:	ffff9097          	auipc	ra,0xffff9
    80007ce2:	8ee080e7          	jalr	-1810(ra) # 800005cc <printf>
    printf("Total reads: %u\n", read_count);
    80007ce6:	85ca                	mv	a1,s2
    80007ce8:	00002517          	auipc	a0,0x2
    80007cec:	64850513          	addi	a0,a0,1608 # 8000a330 <syscalls+0xa00>
    80007cf0:	ffff9097          	auipc	ra,0xffff9
    80007cf4:	8dc080e7          	jalr	-1828(ra) # 800005cc <printf>
    printf("Total writes: %u\n", write_count);
    80007cf8:	85ce                	mv	a1,s3
    80007cfa:	00002517          	auipc	a0,0x2
    80007cfe:	64e50513          	addi	a0,a0,1614 # 8000a348 <syscalls+0xa18>
    80007d02:	ffff9097          	auipc	ra,0xffff9
    80007d06:	8ca080e7          	jalr	-1846(ra) # 800005cc <printf>
    printf("Callbacks executed: %u\n", callbacks);
    80007d0a:	85ee                	mv	a1,s11
    80007d0c:	00002517          	auipc	a0,0x2
    80007d10:	58450513          	addi	a0,a0,1412 # 8000a290 <syscalls+0x960>
    80007d14:	ffff9097          	auipc	ra,0xffff9
    80007d18:	8b8080e7          	jalr	-1864(ra) # 800005cc <printf>
    printf("Reads per tick: %u\n", read_count / duration);
    80007d1c:	029955b3          	divu	a1,s2,s1
    80007d20:	00002517          	auipc	a0,0x2
    80007d24:	30850513          	addi	a0,a0,776 # 8000a028 <syscalls+0x6f8>
    80007d28:	ffff9097          	auipc	ra,0xffff9
    80007d2c:	8a4080e7          	jalr	-1884(ra) # 800005cc <printf>
    printf("Writes per tick: %u\n", write_count / duration);
    80007d30:	0299d5b3          	divu	a1,s3,s1
    80007d34:	00002517          	auipc	a0,0x2
    80007d38:	57450513          	addi	a0,a0,1396 # 8000a2a8 <syscalls+0x978>
    80007d3c:	ffff9097          	auipc	ra,0xffff9
    80007d40:	890080e7          	jalr	-1904(ra) # 800005cc <printf>

    double avg_latency = (double)duration / (double)(read_count + write_count);
    80007d44:	d234f453          	fcvt.d.lu	fs0,s1
    80007d48:	994e                	add	s2,s2,s3
    80007d4a:	d23977d3          	fcvt.d.lu	fa5,s2
    80007d4e:	1af47453          	fdiv.d	fs0,fs0,fa5
    printf("Average ticks per operation: %f\n", avg_latency);
    80007d52:	e20405d3          	fmv.x.d	a1,fs0
    80007d56:	00002517          	auipc	a0,0x2
    80007d5a:	56a50513          	addi	a0,a0,1386 # 8000a2c0 <syscalls+0x990>
    80007d5e:	ffff9097          	auipc	ra,0xffff9
    80007d62:	86e080e7          	jalr	-1938(ra) # 800005cc <printf>

    if (read_only_avg_latency > 0)
    80007d66:	00002797          	auipc	a5,0x2
    80007d6a:	73a7b707          	fld	fa4,1850(a5) # 8000a4a0 <read_only_avg_latency>
    80007d6e:	f20007d3          	fmv.d.x	fa5,zero
    80007d72:	a2e797d3          	flt.d	a5,fa5,fa4
    80007d76:	e39d                	bnez	a5,80007d9c <rcu_read_stress+0x1e4>
        double interference =
            (avg_latency - read_only_avg_latency) / read_only_avg_latency;
        printf("Interference ratio (writer impact): %f\n", interference);
    }

    if (callbacks != write_count)
    80007d78:	05b99163          	bne	s3,s11,80007dba <rcu_read_stress+0x202>
    {
        printf("WARNING: callback mismatch (Possible memory leak or RCU bug!)\n");
    }
}
    80007d7c:	70e6                	ld	ra,120(sp)
    80007d7e:	7446                	ld	s0,112(sp)
    80007d80:	74a6                	ld	s1,104(sp)
    80007d82:	7906                	ld	s2,96(sp)
    80007d84:	69e6                	ld	s3,88(sp)
    80007d86:	6a46                	ld	s4,80(sp)
    80007d88:	6aa6                	ld	s5,72(sp)
    80007d8a:	6b06                	ld	s6,64(sp)
    80007d8c:	7be2                	ld	s7,56(sp)
    80007d8e:	7c42                	ld	s8,48(sp)
    80007d90:	7ca2                	ld	s9,40(sp)
    80007d92:	7d02                	ld	s10,32(sp)
    80007d94:	6de2                	ld	s11,24(sp)
    80007d96:	2422                	fld	fs0,8(sp)
    80007d98:	6109                	addi	sp,sp,128
    80007d9a:	8082                	ret
            (avg_latency - read_only_avg_latency) / read_only_avg_latency;
    80007d9c:	0ae47453          	fsub.d	fs0,fs0,fa4
        printf("Interference ratio (writer impact): %f\n", interference);
    80007da0:	1ae477d3          	fdiv.d	fa5,fs0,fa4
    80007da4:	e20785d3          	fmv.x.d	a1,fa5
    80007da8:	00002517          	auipc	a0,0x2
    80007dac:	5b850513          	addi	a0,a0,1464 # 8000a360 <syscalls+0xa30>
    80007db0:	ffff9097          	auipc	ra,0xffff9
    80007db4:	81c080e7          	jalr	-2020(ra) # 800005cc <printf>
    80007db8:	b7c1                	j	80007d78 <rcu_read_stress+0x1c0>
        printf("WARNING: callback mismatch (Possible memory leak or RCU bug!)\n");
    80007dba:	00002517          	auipc	a0,0x2
    80007dbe:	5ce50513          	addi	a0,a0,1486 # 8000a388 <syscalls+0xa58>
    80007dc2:	ffff9097          	auipc	ra,0xffff9
    80007dc6:	80a080e7          	jalr	-2038(ra) # 800005cc <printf>
}
    80007dca:	bf4d                	j	80007d7c <rcu_read_stress+0x1c4>
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
